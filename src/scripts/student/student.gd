## A selectable student unit
## Responds to player selection and follows the player within defined ranges
extends CharacterBody2D

signal selected(player: Node2D)
signal deselected

@export var max_speed: float = 200.0
@export var acceleration: float = 500.0
@export var friction: float = 100.0

var student_type: StudentTypes.Type

var player: Node2D = null


func _ready() -> void:
	set_motion_mode(CharacterBody2D.MOTION_MODE_FLOATING)
	add_to_group("selectable_units")
	add_to_group("collectable")
	
	# Connect to selection signals
	selected.connect(_on_selected)
	deselected.connect(_on_deselected)
	
	# Assign random type and correct icon
	_assign_random_type()
	print(StudentTypes.student_type_to_string(student_type))
	_load_icon_by_type()
	
	# Load a random student icon
	#_load_random_icon()


func _physics_process(delta: float) -> void:
	var input_direction = Vector2.ZERO
	
	if player != null:
		var to_player = player.global_position - global_position
		var dist = to_player.length()
		
		# Outside deselect ring - deselect self
		if dist > player.get_deselect_ring():
			deselected.emit()
		# Outside stop ring - move toward player
		elif dist > player.get_stop_ring():
			input_direction = to_player.normalized()
			
			# Boost speed if outside catchup ring
			if dist > player.get_catchup_ring():
				input_direction *= 1.5
		# Inside stop ring - back away from player
		elif dist < player.get_stop_ring():
			input_direction = -1.5 * (1.0 - dist / player.get_stop_ring()) * to_player.normalized()
	
	# Apply velocity with acceleration
	var target_velocity = input_direction * max_speed
	velocity = velocity.move_toward(target_velocity, acceleration * delta)
	
	move_and_slide()
	
	# Handle collisions with other bodies
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider != null and collider is CharacterBody2D and collider.is_in_group("selectable_units"):
			var push_dir = -collision.get_normal()
			# Softer push between students
			var their_velocity = collider.velocity
			collider.velocity = their_velocity.lerp(push_dir * 100.0, 0.1)


## Called when this student is selected
func _on_selected(p: Node2D) -> void:
	player = p
	_highlight()


## Called when this student is deselected
func _on_deselected() -> void:
	if player != null:
		player.get_selection().deselect(self)
		player = null
	
	_unhighlight()


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
	var values = StudentTypes.Type.values()
	student_type = values[randi() % values.size()]


func _load_icon_by_type() -> void:
	var type_name: String = StudentTypes.student_type_to_string(student_type)
	var path := "res://assets/student_icons/%s_01.png" % type_name
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
