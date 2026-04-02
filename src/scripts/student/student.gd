## A selectable student unit
## Responds to player selection and follows the player within defined ranges
extends CharacterBody2D

class_name Student

signal selected(player: Node2D)
signal deselected

@export var max_speed: float = 400.0
@export var acceleration: float = 1000.0
@export var friction: float = 1000.0

var dept: StudentTypes.DeptName
var spec: StudentTypes.SpecName

var player: Node2D = null
var target_position: Vector2 = Vector2.ZERO
var has_target: bool = false

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D


func _ready() -> void:
	set_motion_mode(CharacterBody2D.MOTION_MODE_FLOATING)
	add_to_group("selectable_units")
	add_to_group("collectable")
	
	nav_agent.radius = 25.0
	nav_agent.path_desired_distance = 1000.0
	nav_agent.target_desired_distance = 40.0
	
	# Connect to selection signals
	selected.connect(_on_selected)
	deselected.connect(_on_deselected)
	
	# Assign random type and correct icon
	_assign_random_type()
	#print(StudentTypes.student_type_to_string(student_type))
	_load_icon_by_type()
	
	# Load a random student icon
	#_load_random_icon()

func _physics_process(delta: float) -> void:
	var input_direction = Vector2.ZERO
	
	if player != null:
		input_direction = _get_player_direction()
	elif has_target:
		input_direction = _get_target_direction()
	
	var target_velocity = input_direction * max_speed
	
	if input_direction == Vector2.ZERO:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	else:
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
	
	move_and_slide()
	_handle_collisions()


func _get_target_direction() -> Vector2:
	if nav_agent.is_navigation_finished():
		has_target = false
		return Vector2.ZERO
	
	var next_point: Vector2 = nav_agent.get_next_path_position()
	return (next_point - global_position).normalized()


func _get_player_direction() -> Vector2:
	if player == null:
		return Vector2.ZERO
	
	var to_player = player.global_position - global_position
	var dist = to_player.length()
	
	# Immediate deselect
	if dist > player.get_deselect_ring():
		deselected.emit()
		clear_target()
		return Vector2.ZERO
	
	# STOP zone
	if dist <= player.get_stop_ring():
		clear_target()
		return Vector2.ZERO
	
	# FOLLOW
	var stop_dist = player.get_stop_ring()

	# Direction from player → student
	var dir = (global_position - player.global_position).normalized()

	# Target point on the ring
	var target_pos = player.global_position + dir * stop_dist

	nav_agent.target_position = target_pos
	
	return _get_target_direction()


func _handle_collisions() -> void:
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider != null and collider is CharacterBody2D and collider.is_in_group("selectable_units"):
			var push_dir = -collision.get_normal()
			var their_velocity = collider.velocity
			collider.velocity = their_velocity.lerp(push_dir * 100.0, 0.1)


## Called when this student is selected
func _on_selected(p: Node2D) -> void:
	player = p
	clear_target()
	_highlight()


## Called when this student is deselected
func _on_deselected() -> void:
	if player != null:
		player.get_selection().deselect(self)
	
	player = null
	clear_target()
	_unhighlight()


func move_toward_target(pos: Vector2) -> void:
	player = null  # 👈 THIS IS CRITICAL
	nav_agent.target_position = pos
	has_target = true


func clear_target() -> void:
	has_target = false
	nav_agent.target_position = global_position


## Highlight the student with a reddish tint
func _highlight() -> void:
	var sprite = get_node_or_null("Sprite2D")
	if sprite != null and sprite is Sprite2D:
		sprite.modulate = Color(1.0, 0.6, 0.6)


## Reset student to normal color
func _unhighlight() -> void:
	var sprite = get_node_or_null("Sprite2D")
	if sprite != null and sprite is Sprite2D:
		sprite.modulate = Color(1.0, 1.0, 1.0)
		

func _assign_random_type() -> void:
	var depts = StudentTypes.DeptName.values()
	dept = depts[randi() % depts.size()]
	
	var specs = StudentTypes.get_specs_from_dept(dept)
	spec = specs[randi() % specs.size()]


func _load_icon_by_type() -> void:
	var dept_name: String = StudentTypes.dept_name_to_string(dept)
	var spec_name: String = StudentTypes.spec_name_to_string(spec)

	var path := "res://assets/student_icons/%s_%s.png" % [dept_name, spec_name]
	print(path)

	var tex: Texture2D = load(path)
	if tex == null:
		push_warning("Failed to load texture: " + path)
		return

	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	if sprite:
		sprite.texture = tex

		var target_size := 32.0
		var max_dim := maxf(tex.get_width(), tex.get_height())
		var scale_factor := target_size / max_dim

		sprite.scale = Vector2(scale_factor, scale_factor)


## Load a random student icon from assets
func _load_random_icon() -> void:
	var dir = DirAccess.open("res://assets/student_icons/")
	if dir == null:
		push_warning("Could not open student_icons directory")
		return
	
	var valid_icons: Array[String] = []
	dir.list_dir_begin()
	
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".png"):
			if file_name not in valid_icons:
				valid_icons.append(file_name)
		file_name = dir.get_next()
	
	if valid_icons.is_empty():
		push_warning("No PNG icons found in student_icons")
		return
	
	# Pick random icon
	var chosen_file = valid_icons[randi() % valid_icons.size()]
	var tex = load("res://assets/student_icons/" + chosen_file)
	
	var sprite = get_node_or_null("Sprite2D")
	if sprite != null and sprite is Sprite2D and tex != null:
		sprite.texture = tex
		# Scale to roughly 32x32
		var scale_factor = 32.0 / maxf(tex.get_width(), tex.get_height())
		sprite.scale = Vector2(scale_factor, scale_factor)
