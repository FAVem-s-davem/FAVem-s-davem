## Main player character controller
## Handles movement input and manages selected units
extends CharacterBody2D

class_name Player

@export var max_speed: float = 400.0
@export var acceleration: float = 2000.0
@export var friction: float = 800.0

# Ring distances for student behavior
@export var deselect_ring: float = 300.0
@export var catchup_ring: float = 150.0
@export var stop_ring: float = 100.0

var selection: SelectionManager


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
			collider.velocity = their_velocity.lerp(push_dir * 200.0, 0.2)
	
	queue_redraw()


func _draw() -> void:
	var center = Vector2.ZERO
	
	# Draw selection rings
	draw_circle(center, deselect_ring, Color(0.9, 0.9, 0.9), false, 2.0)
	draw_circle(center, catchup_ring, Color(0.3, 0.3, 0.3), false, 1.0)
	draw_circle(center, stop_ring, Color(0.3, 0.3, 0.3), false, 2.0)


# Getters for student reference
func get_deselect_ring() -> float:
	return deselect_ring


func get_catchup_ring() -> float:
	return catchup_ring


func get_stop_ring() -> float:
	return stop_ring


func get_selection() -> SelectionManager:
	return selection
