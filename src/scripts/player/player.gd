## Main player character controller
## Handles movement input and manages selected units
extends CharacterBody2D

class_name Player

@export var max_speed: float = 4400.0
@export var acceleration: float = 22000.0
@export var friction: float = 8800.0

# Ring distances for student behavior
@export var deselect_ring: float = 3300.0
@export var catchup_ring: float = 1650.0
@export var stop_ring: float = 1100.0

const COLLISION_PUSH_FORCE: float = 2200.0
const TRAIL_STIFFNESS: float = 12.0  # spring stiffness
const TRAIL_DAMPING: float = 7.0     # spring damping
const TRAIL_SCALE: float = 0.02      # how far arms trail relative to velocity

var selection: SelectionManager
var parent: GameScene

var arm_l_rest: Vector2
var arm_r_rest: Vector2
var arm_l_pos: Vector2
var arm_r_pos: Vector2
var arm_l_vel: Vector2 = Vector2.ZERO
var arm_r_vel: Vector2 = Vector2.ZERO

@onready var rig: Node2D = $Rig
@onready var arm_l: Node2D = $Rig/ArmL
@onready var arm_r: Node2D = $Rig/ArmR

func _enter_tree() -> void:
	selection = SelectionManager.new(self)
	set_physics_process(true)


func _ready() -> void:
	set_motion_mode(CharacterBody2D.MOTION_MODE_FLOATING)
	set_physics_process(true)
	arm_l_rest = arm_l.position
	arm_r_rest = arm_r.position
	arm_l_pos = arm_l_rest
	arm_r_pos = arm_r_rest
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

	_update_rig(delta)

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


func _update_rig(delta: float) -> void:
	# Arms trail opposite to movement direction
	var trail := -velocity * TRAIL_SCALE
	var target_l := arm_l_rest + trail
	var target_r := arm_r_rest + trail

	# Spring physics for ArmL
	var force_l := (target_l - arm_l_pos) * TRAIL_STIFFNESS
	arm_l_vel += force_l * delta
	arm_l_vel -= arm_l_vel * TRAIL_DAMPING * delta
	arm_l_pos += arm_l_vel * delta
	arm_l.position = arm_l_pos

	# Spring physics for ArmR
	var force_r := (target_r - arm_r_pos) * TRAIL_STIFFNESS
	arm_r_vel += force_r * delta
	arm_r_vel -= arm_r_vel * TRAIL_DAMPING * delta
	arm_r_pos += arm_r_vel * delta
	arm_r.position = arm_r_pos


func _draw() -> void:
	var center = Vector2.ZERO
	
	# Draw selection rings
	draw_circle(center, deselect_ring, Color(0.9, 0.9, 0.9), false, 8.0, true)
	draw_circle(center, catchup_ring, Color(0.3, 0.3, 0.3), false, 4.0, true)
	draw_circle(center, stop_ring, Color(0.3, 0.3, 0.3), false, 8.0, true)


# Getters for student reference
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
			
			if global_pos.distance_to(self.global_position) <= deselect_ring:
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
