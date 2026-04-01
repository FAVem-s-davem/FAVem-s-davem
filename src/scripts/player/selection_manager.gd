## Manages selection of student units
## Uses signal-based pattern for decoupling
extends Node
class_name SelectionManager

var owner_player: Player
var selected: Array[Student] = []


func _init(player: Player) -> void:
	owner_player = player


## Select a list of students, deselecting any previously selected
func select(students: Array[Student]) -> void:
	clear()
	
	for student in students:
		if student == null:
			continue
		
		# Emit selection signal if student supports it
		if student.has_signal("selected"):
			student.selected.emit(owner_player)
		selected.append(student)


## Add students to selection without clearing existing
func add(students: Array[Student]) -> void:
	for student in students:
		if student == null:
			continue
		
		# Check if already selected
		if student not in selected:
			if student.has_signal("selected"):
				student.selected.emit(owner_player)
			selected.append(student)


## Clear all selected students
func clear() -> void:
	# Make a copy since deselect may modify the array
	var copy = selected.duplicate()
	
	for student in copy:
		if student == null:
			continue
		
		if student.has_signal("deselected"):
			student.deselected.emit()
	
	selected.clear()


## Remove specific student from selection
func deselect(student: Student) -> void:
	if student in selected:
		selected.erase(student)


## Get all currently selected students
func get_selected() -> Array[Student]:
	return selected
