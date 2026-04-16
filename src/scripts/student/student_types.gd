class_name StudentTypes

# Departments
enum Type {
	INF,
	MATH,
	GEO,
	MECH,
}

# Student type header
# Holds info about department, specialization and icon
class StudentTypeInfo:
	var student_type: Type # department
	var number: int # specialization
	var icon_path: String # icon

	func _init(_student_type: Type, _number: int, _icon_path: String):
		student_type = _student_type
		number = _number
		icon_path = _icon_path

# department names
const TYPE_NAME_STRINGS := ["inf", "math", "geo", "mech"]
# department colors
const TYPE_COLORS := [
	Color(0.95, 0.85, 0.35), # inf -> yellow
	Color(1.0, 0.55, 0.2),   # math -> orange
	Color(0.35, 0.85, 0.45), # geo -> green
	Color(0.35, 0.55, 0.96), # mech -> blue
]
# indices to specializations
const TYPE_NUMBERS: Array[int] = [1, 2, 3, 4, 5, 6]

# shortcuts for departments
static var TypeShortcuts := {
	Type.INF: "i",
	Type.MATH: "m",
	Type.GEO: "g",
	Type.MECH: "e",
}

# student types
static var TYPE_INFOS: Array[StudentTypeInfo] = [	
	# inf
	StudentTypeInfo.new(Type.INF, -1, "res://assets/student_icons/inf.png"),
	
	StudentTypeInfo.new(Type.INF, 1, "res://assets/student_icons/inf_01.png"),
	StudentTypeInfo.new(Type.INF, 2, "res://assets/student_icons/inf_02.png"),
	StudentTypeInfo.new(Type.INF, 3, "res://assets/student_icons/inf_03.svg"),
	StudentTypeInfo.new(Type.INF, 4, "res://assets/student_icons/inf_04.png"),
	StudentTypeInfo.new(Type.INF, 5, "res://assets/student_icons/inf_05.svg"),
	StudentTypeInfo.new(Type.INF, 6, "res://assets/student_icons/inf_06.png"),

	# math
	StudentTypeInfo.new(Type.MATH, -1, "res://assets/student_icons/math.png"),

	StudentTypeInfo.new(Type.MATH, 1, "res://assets/student_icons/math_01.png"),
	StudentTypeInfo.new(Type.MATH, 2, "res://assets/student_icons/math_02.png"),
	StudentTypeInfo.new(Type.MATH, 3, "res://assets/student_icons/math_03.svg"),
	StudentTypeInfo.new(Type.MATH, 4, "res://assets/student_icons/math_04.svg"),
	StudentTypeInfo.new(Type.MATH, 5, "res://icon.svg"),
	StudentTypeInfo.new(Type.MATH, 6, "res://icon.svg"),

	# geo
	StudentTypeInfo.new(Type.GEO, -1, "res://assets/student_icons/geo.png"),

	StudentTypeInfo.new(Type.GEO, 1, "res://assets/student_icons/geo_01.svg"),
	StudentTypeInfo.new(Type.GEO, 2, "res://assets/student_icons/geo_02.png"),
	StudentTypeInfo.new(Type.GEO, 3, "res://assets/student_icons/geo_03.png"),
	StudentTypeInfo.new(Type.GEO, 4, "res://assets/student_icons/geo_04.svg"),
	StudentTypeInfo.new(Type.GEO, 5, "res://icon.svg"),
	StudentTypeInfo.new(Type.GEO, 6, "res://icon.svg"),

	# mech
	StudentTypeInfo.new(Type.MECH, -1, "res://assets/student_icons/mech.png"),

	StudentTypeInfo.new(Type.MECH, 1, "res://assets/student_icons/mech_01.svg"),
	StudentTypeInfo.new(Type.MECH, 2, "res://assets/student_icons/mech_02.png"),
	StudentTypeInfo.new(Type.MECH, 3, "res://assets/student_icons/mech_03.png"),
	StudentTypeInfo.new(Type.MECH, 4, "res://assets/student_icons/mech_04.svg"),
	StudentTypeInfo.new(Type.MECH, 5, "res://icon.svg"),
	StudentTypeInfo.new(Type.MECH, 6, "res://icon.svg"),
]

# get student name from type
static func type_name_to_string(student_type: Type) -> String:
	if student_type >= 0 and student_type < TYPE_NAME_STRINGS.size():
		return TYPE_NAME_STRINGS[student_type]
	return "unknown"

# get student color from type
static func type_color(student_type: Type) -> Color:
	if student_type >= 0 and student_type < TYPE_COLORS.size():
		return TYPE_COLORS[student_type]
	return Color.WHITE


# get specialization numbers by type
static func get_numbers_for_type(_student_type: Type) -> Array[int]:
	return TYPE_NUMBERS.duplicate()


# parse type from shortcut
static func parse_type(type_text: String) -> int:
	for key in TypeShortcuts:
		if TypeShortcuts[key] == type_text.to_lower():
			return key
	return -1

# parse specialization number from string
static func parse_type_number(number: String) -> int:
	if not number.is_valid_int():
		return -1

	var parsed := int(number)
	if parsed < 0 or parsed > 5:
		return -1

	return parsed

# get type info by type and number
static func get_type_info(student_type: Type, type_number: int) -> StudentTypeInfo:
	for info in TYPE_INFOS:
		if info.student_type == student_type and info.number == type_number:
			return info
	return null
