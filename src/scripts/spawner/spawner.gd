extends Area2D
class_name Spawner

const MAX_POINT_ATTEMPTS: int = 20

@onready var collision_polygon: CollisionPolygon2D = $CollisionPolygon2D

var game_scene: GameScene


func _ready() -> void:
	_resolve_game_scene()


# Spawns one student of requested type from this spawner.
func spawn_student(student_type: int):
	if game_scene == null:
		_resolve_game_scene()
	if game_scene == null:
		push_error("Spawner: GameScene not found")
		return null

	if game_scene.student_scene == null:
		push_error("Spawner: GameScene student_scene is not assigned")
		return null

	var student := game_scene.student_scene.instantiate() as Student
	if student == null:
		push_error("Spawner: student_scene root is not Student")
		return null

	student.set_student_type(student_type)
	student.global_position = _get_spawn_position()
	game_scene.add_child(student)

	return student


func _resolve_game_scene() -> void:
	game_scene = get_tree().root.get_node_or_null("Main/GameScene") as GameScene


func _get_spawn_position() -> Vector2:
	if collision_polygon == null or collision_polygon.polygon.is_empty():
		return global_position

	var global_polygon: PackedVector2Array = []
	for p in collision_polygon.polygon:
		global_polygon.append(collision_polygon.to_global(p))

	var min_x := INF
	var min_y := INF
	var max_x := -INF
	var max_y := -INF

	for p in global_polygon:
		min_x = minf(min_x, p.x)
		min_y = minf(min_y, p.y)
		max_x = maxf(max_x, p.x)
		max_y = maxf(max_y, p.y)

	for _i in range(MAX_POINT_ATTEMPTS):
		var candidate := Vector2(
			randf_range(min_x, max_x),
			randf_range(min_y, max_y)
		)
		if Geometry2D.is_point_in_polygon(candidate, global_polygon):
			return candidate

	# Fallback center if random attempts miss.
	var sum := Vector2.ZERO
	for p in global_polygon:
		sum += p
	return sum / float(global_polygon.size())