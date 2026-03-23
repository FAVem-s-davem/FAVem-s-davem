class_name StudentTypes

enum Type {
	MATH,
	CS,
}

const STUDENT_TYPE_NAMES := [
	"math",
	"inf",
]

static func student_type_to_string(type: int) -> String:
	if type >= 0 and type < STUDENT_TYPE_NAMES.size():
		return STUDENT_TYPE_NAMES[type]
	return "unknown"
