## Manages cursor following for students within detection range
## When player holds right-click, students in the detection area follow the cursor.
## Students automatically stop following when released or moved out of range.
extends Node2D

class_name CursorFollowManager

var detection_area: Area2D
var students_following: Array[Node2D] = []
var cursor_pos: Vector2 = Vector2.ZERO
var detection_radius: float = 100.0


func _ready() -> void:
	_setup_detection_area()


## Creates a circular Area2D for detecting nearby students
func _setup_detection_area() -> void:
	detection_area = Area2D.new()
	detection_area.name = "CursorFollowDetectionArea"
	add_child(detection_area)
	
	var collision_shape = CollisionShape2D.new()
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = detection_radius
	collision_shape.shape = circle_shape
	detection_area.add_child(collision_shape)


## Main loop: updates detection area and handles student following
func _process(_delta: float) -> void:
	cursor_pos = get_global_mouse_position()
	detection_area.global_position = cursor_pos
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		_update_following_students()
	else:
		_stop_all_following_students()


## Updates targets for students in range and removes those who left
func _update_following_students() -> void:
	var nearby_students = detection_area.get_overlapping_bodies()
	
	# Update target for all students in range
	for student in nearby_students:
		if student.is_in_group("selectable_units"):
			student.move_toward_target(cursor_pos)
			if student not in students_following:
				students_following.append(student)
	
	# Remove students that left the area
	var out_of_range = _get_out_of_range_students()
	for student in out_of_range:
		student.clear_target()
		students_following.erase(student)


## Returns students that are too far from cursor or deleted
func _get_out_of_range_students() -> Array[Node2D]:
	var out_of_range: Array[Node2D] = []
	
	for student in students_following:
		if not is_instance_valid(student):
			out_of_range.append(student)
		elif student.global_position.distance_to(cursor_pos) > detection_radius:
			out_of_range.append(student)
	
	return out_of_range


## Stops all students from following cursor
func _stop_all_following_students() -> void:
	for student in students_following:
		if is_instance_valid(student):
			student.clear_target()
	students_following.clear()

