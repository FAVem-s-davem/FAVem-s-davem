class_name Command

enum OpType {
	RECORD_MACRO,
	RUN_MACRO,
	SET_MARKER,
	GOTO_MARKER,
	SELECT,
	APPEND,
	DESELECT,
	DESELECT_ALL,
	SEND,
}

static var OP_KEY_TO_TYPE = {
	"q": Command.OpType.RECORD_MACRO,
	"w": Command.OpType.RUN_MACRO,
	"m": Command.OpType.SET_MARKER,
	"g": Command.OpType.GOTO_MARKER,
	"a": Command.OpType.SELECT,
	"A": Command.OpType.APPEND,
	"d": Command.OpType.DESELECT,
	"D": Command.OpType.DESELECT_ALL,
	"s": Command.OpType.SEND,
}

static var OPS = {
	"q": {
		"type": "record_macro",
		"mode": "single_arg",
	},
	"w": {
		"type": "run_macro",
		"mode": "single_arg",
	},
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
		"takes_args": false
	},
	"s": {
		"type": "send_students",
		"needs_marker": true,
		"takes_args": true
	},
}

var op_type: OpType
var count: int = 1
var arg1: String = ""
var arg2: String = ""
var marker: int = -1

func _init(_op := OpType.SELECT, _count := 1, _arg1 := "", _arg2 := "", _marker := -1):
	op_type = _op
	count = _count
	arg1 = _arg1
	arg2 = _arg2
	marker = _marker


func as_string() -> String:
	return "Command(op=%s, count=%d, arg1=%s, arg2=%s, marker=%d)" % [
		op_type, count, arg1, arg2, marker
	]

func has_arg2() -> bool:
	return arg2 != ""

func has_marker() -> bool:
	return marker != -1
	



func debug_string() -> String:
	return "CMD %s | count=%d | arg1=%s | arg2=%s | marker=%d" % [
		op_type,
		count,
		StudentTypes.dept_name_to_string(StudentTypes.parse_dept(arg1)),
		StudentTypes.spec_name_to_string(StudentTypes.parse_spec(arg1, arg2)),
		marker
	]
	
func copy() -> Command:
	return Command.new(
		op_type,
		count,
		arg1,
		arg2,
		marker
	)
