class_name Command

const StudentTypesDb = preload("res://scripts/student/student_types.gd")

enum OpType {
	RECORD_MACRO,
	RUN_MACRO,
	SET_MARKER,
	GOTO_MARKER,
	SELECT,
	SELECT_ALL,
	DESELECT,
	DESELECT_ALL,
	SEND,
	SEND_ALL,
}

static var OP_KEY_TO_TYPE = {
	"q": Command.OpType.RECORD_MACRO,
	"@": Command.OpType.RUN_MACRO,
	"m": Command.OpType.SET_MARKER,
	"g": Command.OpType.GOTO_MARKER,
	"a": Command.OpType.SELECT,
	"A": Command.OpType.SELECT_ALL,
	"d": Command.OpType.DESELECT,
	"D": Command.OpType.DESELECT_ALL,
	"s": Command.OpType.SEND,
	"S": Command.OpType.SEND_ALL,
}

static var OPS = {
	"q": {
		"type": "record_macro",
		"mode": "single_arg",
		"desc": "Record macro"
	},
	"@": {
		"type": "run_macro",
		"mode": "single_arg",
		"desc": "Run macro"
	},
	# marker commands (special, no args)
	"m": {
		"type": "set_marker",
		"needs_marker": true,
		"takes_args": false,
		"desc": "Set marker"
	},
	"g": {
		"type": "goto_marker",
		"needs_marker": true,
		"takes_args": false,
		"desc": "Go to marker"
	},

	# generic object operations
	"a": {
		"type": "select_students",
		"needs_marker": false,
		"takes_args": true,
		"desc": "Select type"
	},
	"A": {
		"type": "select_all",
		"needs_marker": false,
		"takes_args": false,
		"desc": "Select all"
	},
	"d": {
		"type": "deselect_students",
		"needs_marker": false,
		"takes_args": true,
		"desc": "Deselect type"
	},
	"D": {
		"type": "deselect_all_students",
		"needs_marker": false,
		"takes_args": false,
		"desc": "Deselect all"
	},
	"s": {
		"type": "send_students",
		"needs_marker": true,
		"takes_args": true,
		"desc": "Send type"
	},
	"S": {
		"type": "send_all",
		"needs_marker": true,
		"takes_args": false,
		"desc": "Send all"
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
	var type_label := StudentTypesDb.type_name_to_string(StudentTypesDb.parse_type(arg1))
	var number_value := StudentTypesDb.parse_type_number(arg2)
	var number_label := "all"
	if number_value != -1:
		number_label = str(number_value)

	return "CMD %s | count=%d | arg1=%s | arg2=%s | marker=%d" % [
		op_type,
		count,
		type_label,
		number_label,
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
