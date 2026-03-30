class_name CommandParser

enum State {
	IDLE,
	READING_OP,
	READING_COUNT,
	READING_ARG1,
	READING_ARG2,
	READING_MARKER
}

var state = State.IDLE

# buffer for keylogger
var buffer: Array = []

# parsed components
var op: String = ""
var count_str: String = ""
var arg1: String = ""
var arg2: String = ""
var marker: int = -1

var OPS = {
	# marker commands (special, no args)
	"m": {
		"type": "set_marker",
		"needs_marker": true,
		"takes_args": false
	},
	"g": {
		"type": "goto_marker",
		"needs_marker": true,
		"takes_args": false
	},

	# generic object operations
	"a": {
		"type": "select_students",
		"needs_marker": false,
		"takes_args": true
	},
	"A": {
		"type": "append_students",
		"needs_marker": false,
		"takes_args": true
	},
	"d": {
		"type": "deselect_students",
		"needs_marker": false,
		"takes_args": true
	},
	"D": {
		"type": "deselect_all_students",
		"needs_marker": false,
		"takes_args": true
	}
}

# =========================
# Public API
# =========================

func reset():
	state = State.IDLE
	buffer.clear()
	op = ""
	count_str = ""
	arg1 = ""
	arg2 = ""
	marker = -1


func is_idle() -> bool:
	return state == State.IDLE


func get_buffer_string() -> String:
	return "".join(buffer)

func feed(key: String) -> Dictionary:
	# returns:
	# { "status": "incomplete" | "complete" | "invalid", "command": {...} }

	buffer.append(key)

	match state:

		State.IDLE:
			return _handle_idle(key)

		State.READING_OP:
			return _handle_after_op(key)

		State.READING_COUNT:
			return _handle_count(key)

		State.READING_ARG1:
			return _handle_arg1(key)

		State.READING_ARG2:
			return _handle_arg2(key)

		State.READING_MARKER:
			return _handle_marker(key)

	return { "status": "invalid" }


# =========================
# State Handlers
# =========================

func _handle_idle(key):
	if key in OPS:
		op = key

		if not OPS[key]["takes_args"]:
			# m / g → go straight to marker
			state = State.READING_MARKER
		else:
			state = State.READING_OP

		return { "status": "incomplete" }

	return _invalid()


func _handle_after_op(key):
	if key.is_valid_int():
		count_str = key
		state = State.READING_COUNT
		return { "status": "incomplete" }

	if _is_letter(key):
		arg1 = key
		return _after_arg1()

	return _invalid()


func _handle_count(key):
	if key.is_valid_int():
		count_str += key
		return { "status": "incomplete" }

	if _is_letter(key):
		arg1 = key
		return _after_arg1()

	return _invalid()


func _handle_arg1(key):
	# not used (handled inline)
	return _invalid()


func _after_arg1():
	if _is_upper(arg1):
		if _needs_marker():
			state = State.READING_MARKER
			return { "status": "incomplete" }
		else:
			return _complete()

	else:
		state = State.READING_ARG2
		return { "status": "incomplete" }


func _handle_arg2(key):
	if _is_letter(key):
		arg2 = key

		if _needs_marker():
			state = State.READING_MARKER
			return { "status": "incomplete" }
		else:
			return _complete()

	return _invalid()


func _handle_marker(key):
	if key.is_valid_int():
		marker = int(key)
		return _complete()

	return _invalid()


# =========================
# Helpers
# =========================

func _complete():
	print("COMPLETE")
	var cmd = {
		"op": op,
		"count": _get_count(),
		"arg1": arg1,
		"arg2": arg2,
		"marker": marker
	}

	# 🔽 DEBUG PRINT (this is your "command handler" moment)
	print("COMMAND EXECUTED -> ", cmd)

	reset()

	return {
		"status": "complete",
		"command": cmd
		}


func _invalid():
	reset()
	return { "status": "invalid" }


func _get_count() -> int:
	return 1 if count_str == "" else int(count_str)


func _needs_marker() -> bool:
	return OPS.get(op, {}).get("needs_marker", false)
	
func _is_upper(c: String) -> bool:
	return c == c.to_upper() and c != c.to_lower()

func _is_lower(c: String) -> bool:
	return c == c.to_lower() and c != c.to_upper()


func _is_letter(k: String) -> bool:
	return k.length() == 1 and k.is_valid_identifier()
