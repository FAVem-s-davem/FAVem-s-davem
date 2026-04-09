class_name CommandParser

enum State {
	IDLE,
	READING_OP,
	READING_COUNT,
	READING_ARG1,
	READING_ARG2,
	READING_MARKER
}

signal actions_updated(actions: Dictionary)
signal buffer_updated(buffer: String)

var state = State.IDLE

# buffer for keylogger
var buffer: Array = []

# parsed components
var op: String = ""
var count_str: String = ""
var arg1: String = ""
var arg2: String = ""
var marker: int = -1


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
	emit_signal("actions_updated", get_available_actions())
	emit_signal("buffer_updated", get_buffer_string())



func is_idle() -> bool:
	return state == State.IDLE


func get_buffer_string() -> String:
	return "".join(buffer)

func feed(key: String) -> Dictionary:
	buffer.append(key)

	var result: Dictionary

	match state:
		State.IDLE:
			result = _handle_idle(key)

		State.READING_OP:
			result = _handle_after_op(key)

		State.READING_COUNT:
			result = _handle_count(key)

		State.READING_ARG1:
			result = _handle_arg1(key)

		State.READING_ARG2:
			result = _handle_arg2(key)

		State.READING_MARKER:
			result = _handle_marker(key)

	# 🔥 ALWAYS print after processing
	print("STATE:", state)
	var actions = get_available_actions()
	print("ACTIONS:", actions)
	emit_signal("actions_updated", actions)
	emit_signal("buffer_updated", get_buffer_string())

	return result


# =========================
# State Handlers
# =========================

func _handle_idle(key):
	if key in Command.OPS:
		op = key
		
		var op_data = Command.OPS[key]
		
		if Command.OP_KEY_TO_TYPE[key] == Command.OpType.DESELECT_ALL:
			return _complete()
		
		if op_data.get("mode", "") == "single_arg":
			state = State.READING_ARG1
		
		elif not op_data.get("takes_args", true):
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
	if _is_letter(key):
		arg1 = key
		return _after_arg1()

	return _invalid()


func _after_arg1():
	var op_data = Command.OPS.get(op, {})
	
	# 🔥 NEW: single arg commands
	if op_data.get("mode", "") == "single_arg":
		return _complete()

	# existing logic
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


	var op_type = Command.OP_KEY_TO_TYPE.get(op, Command.OpType.SELECT)

	var cmd = Command.new(
		op_type,
		_get_count(),
		arg1,
		arg2,
		marker
	)

	print("COMMAND EXECUTED -> ", cmd.as_string())

	reset()

	return {
		"status": "complete",
		"command": cmd
	}


func _invalid():
	reset()
	return { "status": "invalid" }


func _get_count() -> int:
	return -1 if count_str == "" else int(count_str)


func _needs_marker() -> bool:
	return Command.OPS.get(op, {}).get("needs_marker", false)
	
func _is_upper(c: String) -> bool:
	return c == c.to_upper() and c != c.to_lower()

func _is_lower(c: String) -> bool:
	return c == c.to_lower() and c != c.to_upper()


func _is_letter(k: String) -> bool:
	return k.length() == 1 and k.is_valid_identifier()

# =================== Hints ========================

func get_available_actions() -> Dictionary:
	var result := {}
	
	match state:

		State.IDLE:
			return _actions_idle()

		State.READING_OP:
			return _actions_after_op()

		State.READING_COUNT:
			return _actions_after_count()

		State.READING_ARG1:
			return _actions_arg1()

		State.READING_ARG2:
			return _actions_arg2()

		State.READING_MARKER:
			return _actions_marker()

	print(result)
	return result
	
func _actions_after_op() -> Dictionary:
	var result := {}
	
	result["0-9"] = "Set count"
	
	# uppercase = "all"
	for dept in StudentTypes.DeptShortcuts:
		var key = StudentTypes.DeptShortcuts[dept]
		var name = StudentTypes.dept_name_to_string(dept)
		
		result[key.to_upper()] = "Select ALL " + name
		result[key] = "Select from " + name
	
	return result
	
func _actions_after_count() -> Dictionary:
	return _actions_after_op()
	
func _actions_arg2() -> Dictionary:
	var result := {}
	
	var dept = StudentTypes.parse_dept(arg1)
	
	for spec in StudentTypes.get_specs_from_dept(dept):
		var key = StudentTypes.SpecShortcuts[spec]
		var name = StudentTypes.spec_name_to_string(spec)
		
		result[key] = name
	
	return result
	
func _actions_marker() -> Dictionary:
	var result := {}
	
	for i in range(10):
		result[str(i)] = "Marker " + str(i)
	
	return result
	
func _actions_arg1() -> Dictionary:
	var result := {}
	
	var op_data = Command.OPS.get(op, {})
	
	if op_data.get("mode") == "single_arg":
		for c in "abcdefghijklmnopqrstuvwxyz":
			result[c] = "Register " + c
		return result
	
	# fallback
	return _actions_after_op()
	
func _actions_idle() -> Dictionary:
	var result := {}
	
	for key in Command.OPS:
		result[key] = Command.OPS[key].get("type", "")
	
	return result
