## Main player character controller
## Handles movement input and manages selected units
extends CharacterBody2D

class_name Player

@export var max_speed: float = 3000.0
@export var acceleration: float = 22000.0
@export var friction: float = 8800.0

# Ring distances for student behavior
@export var select_ring: float = 3300.0
@export var deselect_ring: float = 6600.0
@export var catchup_ring: float = 1650.0
@export var stop_ring: float = 1100.0

const COLLISION_PUSH_FORCE: float = 2200.0

var selection: SelectionManager

var parent: GameScene

func _enter_tree() -> void:
	selection = SelectionManager.new(self)
	set_physics_process(true)


func _ready() -> void:
	set_motion_mode(CharacterBody2D.MOTION_MODE_FLOATING)
	set_physics_process(true)
	print("Player ready")


func _physics_process(delta: float) -> void:
	# Get input direction
	var dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# WASD controls instead of arrow keys
	if Input.is_action_pressed("Player_Go_Up"):
		dir.y -= 1
	if Input.is_action_pressed("Player_Go_Down"):
		dir.y += 1
	if Input.is_action_pressed("Player_Go_Left"):
		dir.x -= 1
	if Input.is_action_pressed("Player_Go_Right"):
		dir.x += 1
	
	dir = dir.normalized()
	
	# Calculate velocity with acceleration/friction
	var target_velocity = dir * max_speed
	velocity = velocity.move_toward(target_velocity, acceleration * delta)
	
	move_and_slide()
	
	# Handle collisions with selectable units
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider != null and collider is CharacterBody2D and collider.is_in_group("selectable_units"):
			var push_dir = -collision.get_normal()
			# Gentle push for units we collide with
			var their_velocity = collider.velocity
			collider.velocity = their_velocity.lerp(push_dir * COLLISION_PUSH_FORCE, 0.2)
	
	queue_redraw()


func _draw() -> void:
	var center = Vector2.ZERO
	
	# Draw selection rings
	draw_circle(center, select_ring, Color(0.6, 0.9, 1.0), false, 6.0, true)
	draw_circle(center, deselect_ring, Color(0.9, 0.9, 0.9), false, 8.0, true)
	draw_circle(center, catchup_ring, Color(0.3, 0.3, 0.3), false, 4.0, true)
	draw_circle(center, stop_ring, Color(0.3, 0.3, 0.3), false, 8.0, true)


# Getters for student reference
func get_select_ring() -> float:
	return select_ring


func get_deselect_ring() -> float:
	return deselect_ring


func get_catchup_ring() -> float:
	return catchup_ring


func get_stop_ring() -> float:
	return stop_ring


func get_selection() -> SelectionManager:
	return selection
	
	
## Get all selectable units within the given rectangle
func _get_units_inside() -> Array[Student]:
	var units: Array[Student] = []
	
	var all_nodes = get_tree().get_nodes_in_group("selectable_units")
	
	for node in all_nodes:
		if node is Student:
			var global_pos = node.global_position
			
			if global_pos.distance_to(self.global_position) <= select_ring:
				units.append(node)
	
	return units

func select_by_type(dept: String, spec: String, count: int, append: bool):
	var deptValue = StudentTypes.parse_dept(dept)
	var students = _get_units_inside()
	var specValue = null if spec == "" else StudentTypes.parse_spec(dept, spec)
	var to_select: Array[Student] = []
	
	if not append:
		selection.clear()
	
	for student in students:
		if student.dept == deptValue and (specValue == null or student.spec == specValue):
			to_select.append(student)
			
	if count != -1:
		to_select = to_select.slice(0, count)
		
	if append:
		selection.add(to_select)
	else:
		selection.select(to_select)
		
	print("selected: ", selection.get_selected().size())
	

func deselect_by_type(dept: String, spec: String, count: int):
	var deptValue = StudentTypes.parse_dept(dept)
	var students = selection.get_selected()
	var specValue = null if spec == "" else StudentTypes.parse_spec(dept, spec)
	var to_deselect: Array[Student] = []
	
	
	for student in students:
		if student.dept == deptValue and (specValue == null or student.spec == specValue):
			to_deselect.append(student)
			
	if count != -1:
		to_deselect = to_deselect.slice(0, count)
		
	for student in to_deselect:
		selection.deselect(student)
		
	print("selected: ", selection.get_selected().size())
	
	
func send_students(dept: String, spec: String, count: int, marker: int):
	if parent.markers[marker] == null:
		return
		
	var deptValue = StudentTypes.parse_dept(dept)
	var students = selection.get_selected()
	var specValue = null if spec == "" else StudentTypes.parse_spec(dept, spec)
	var to_deselect: Array[Student] = []
	
	
	for student in students:
		if student.dept == deptValue and (specValue == null or student.spec == specValue):
			to_deselect.append(student)
			
	if count != -1:
		to_deselect = to_deselect.slice(0, count)
		
	for student in to_deselect:
		selection.deselect(student)
		student.move_toward_target(parent.markers[marker])
		
	print("selected: ", selection.get_selected().size())
