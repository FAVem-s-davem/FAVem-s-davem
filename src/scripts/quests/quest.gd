extends RefCounted
class_name Quest

# Emits when quest completion changes.
signal completed_changed(quest: Quest, is_completed: bool)
signal count_changed(quest: Quest)

# Required student type for this quest (StudentTypes.Type value).
var required_student_type: int = -1
var required_student_number: int = -1

# Required exact number of students.
var required_count: int = 0
var current_count: int = 0

# Whether quest is currently fulfilled.
var is_completed: bool = false

var active_students: Array[Student] = []


func _init(student_type: int = -1, student_number: int = -1, count: int = 0) -> void:
	required_student_type = student_type
	required_student_number = student_number
	required_count = max(0, count)


# Returns true only if exactly required_count students are present
# and all of them match required_student_type.
func matches_students(students: Array[Student]) -> bool:
	var matches := true
	var count := 0
	active_students.clear()

	if students.size() != required_count:
		matches = false

	for student in students:
		if student == null:
			matches =  false
			continue
		if student.student_type != required_student_type:
			matches = false
			continue
		if required_student_number != -1 and student.type_number != required_student_number:
			matches = false
			continue
			
		count += 1
		active_students.append(student)


	current_count = count
	count_changed.emit(self)
	return matches


# Updates completion state and emits only on change.
func set_completed(value: bool) -> void:
	if is_completed == value:
		return

	is_completed = value
	completed_changed.emit(self, is_completed)

func complete():
	if is_completed:
		print("quest complete")
		for student in active_students:
			student.remove()
