## Manages cursor following for students within detection range
## When player holds right-click, students in the detection area follow the cursor.
## Only works if the cursor area overlaps with the player's influence area.
extends Node2D

class_name CursorFollowManager

var detection_area: Area2D
var students_following: Array[Node2D] = []
var cursor_pos: Vector2 = Vector2.ZERO
var detection_radius: float = 100.0
var player: Node2D
var radius_step: float = 10.0  # How much to change per scroll
var min_radius: float = 50.0
var max_radius: float = 300.0


func _ready() -> void:
	queue_free()
	player = get_parent()
	_setup_detection_area()
	set_process_input(true)


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


func _input(event: InputEvent) -> void:
	var scroll_event = event as InputEventMouseButton
	if scroll_event == null:
		return
	
	# Scroll up - increase radius
	if scroll_event.button_index == MOUSE_BUTTON_WHEEL_UP and scroll_event.pressed:
		_change_detection_radius(radius_step)
	# Scroll down - decrease radius
	elif scroll_event.button_index == MOUSE_BUTTON_WHEEL_DOWN and scroll_event.pressed:
		_change_detection_radius(-radius_step)


## Updates the detection radius and visual area
func _change_detection_radius(delta: float) -> void:
	detection_radius = clamp(detection_radius + delta, min_radius, max_radius)
	
	# Update the collision shape
	var collision_shape = detection_area.get_child(0) as CollisionShape2D
	if collision_shape != null and collision_shape.shape is CircleShape2D:
		(collision_shape.shape as CircleShape2D).radius = detection_radius


## Main loop: updates detection area and handles student following
func _process(_delta: float) -> void:
	cursor_pos = get_global_mouse_position()
	detection_area.global_position = cursor_pos
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		_update_following_students()
	else:
		_stop_all_following_students()
	
	queue_redraw()


func _draw() -> void:
	# Convert global cursor position to local coordinates for drawing
	var local_cursor = to_local(cursor_pos)
	
	# Draw detection area as a light circle around cursor
	var color = Color(0.7, 0.7, 1.0, 0.3)  # Light blue, semi-transparent
	draw_circle(local_cursor, detection_radius, color)


## Updates targets for students in range and removes those who left
func _update_following_students() -> void:
	# Only allow cursor following if cursor is within player's influence
	if not _is_cursor_in_player_area():
		_stop_all_following_students()
		return
	
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


## Checks if cursor detection area overlaps with player's influence area
func _is_cursor_in_player_area() -> bool:
	if player == null:
		return false
	var dist = cursor_pos.distance_to(player.global_position)
	# Areas overlap if distance <= sum of their radii
	return dist <= (player.get_deselect_ring() + detection_radius)


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
