## Animated menu background: map + wandering students + slow camera fly-through
extends Node2D

const STUDENT_SCENE: PackedScene = preload("res://scenes/Student.tscn")

const STUDENT_COUNT: int = 150
const CAMERA_MOVE_DURATION: float = 9.0
const CAMERA_PAUSE_DURATION: float = 1.5
const CAMERA_ZOOM: float = 0.08

# Waypoints derived from spawner/room positions on the FAV map.
const WAYPOINTS: Array[Vector2] = [
	Vector2(36772, 58244),
	Vector2(63190, 60435),
	Vector2(55927, 62119),
	Vector2(24151, 64484),
	Vector2(9909,  64508),
	Vector2(17343, 64428),
]

# Positions inside the navigable area used for initial student placement.
const SPAWN_POSITIONS: Array[Vector2] = [
	Vector2(36772, 58244),
	Vector2(35561, 69225),
	Vector2(37958, 69208),
	Vector2(63190, 60435),
	Vector2(55927, 62119),
	Vector2(24151, 64484),
	Vector2(9909,  64508),
	Vector2(17343, 64428),
]

var _camera: Camera2D
var _tween: Tween
var _current_waypoint: int = 0
var _students_spawned: bool = false


func _ready() -> void:
	_camera = $Camera2D
	_camera.zoom = Vector2(CAMERA_ZOOM, CAMERA_ZOOM)
	_camera.position_smoothing_enabled = false


func start() -> void:
	_camera.make_current()
	if not _students_spawned:
		_spawn_students()
		_students_spawned = true
	_current_waypoint = 0
	_camera.global_position = WAYPOINTS[0]
	_advance_to_next_waypoint()


func stop() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = null
	for child in get_children():
		if child is CharacterBody2D:
			child.queue_free()
	_students_spawned = false


func _spawn_students() -> void:
	var spread: float = 1800.0
	var per_position: int = max(1, STUDENT_COUNT / SPAWN_POSITIONS.size())
	var spawned: int = 0

	for base_pos in SPAWN_POSITIONS:
		for _i in range(per_position):
			if spawned >= STUDENT_COUNT:
				return
			var student: Student = STUDENT_SCENE.instantiate() as Student
			var offset := Vector2(
				randf_range(-spread, spread),
				randf_range(-spread, spread)
			)
			student.global_position = base_pos + offset
			add_child(student)
			spawned += 1


func _advance_to_next_waypoint() -> void:
	_current_waypoint = (_current_waypoint + 1) % WAYPOINTS.size()
	var target: Vector2 = WAYPOINTS[_current_waypoint]

	_tween = create_tween()
	_tween.tween_property(_camera, "global_position", target, CAMERA_MOVE_DURATION) \
		.set_ease(Tween.EASE_IN_OUT) \
		.set_trans(Tween.TRANS_SINE)
	_tween.tween_interval(CAMERA_PAUSE_DURATION)
	_tween.tween_callback(_advance_to_next_waypoint)
