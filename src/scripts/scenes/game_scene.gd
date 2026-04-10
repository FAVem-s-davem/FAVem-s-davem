## Main game scene manager
## Uses editor-placed player + spawners and handles runtime spawning/commands
extends Node2D

class_name GameScene

const MARKER_RADIUS: float = 132.0
const MARKER_FONT_SIZE: int = 154
const BUFFER_FONT_SIZE: int = 264
const BUFFER_TEXT_OFFSET: float = 1100.0

@export var student_scene: PackedScene = preload("res://scenes/Student.tscn")
@export var teacher_scene: PackedScene = preload("res://scenes/Teacher.tscn")

@export var teacher_respawn_delay: float = 3.0
@export var student_spawn_interval: float = 2.0
@export var auto_spawn_students: bool = true
@export var fill_all_teacher_spawners_on_start: bool = true

@export_node_path("Player") var player_path: NodePath = NodePath("Player")
@export_node_path("Node2D") var spawners_root_path: NodePath = NodePath("Map/Areas/Spawners")

@onready var hint_menu = $"../CanvasLayer/Control/Hud/HintMenu"
@onready var command_buffer = $"../CanvasLayer/Control/Hud/CommandBuffer"


var markers: Array = []

var player: Player
var student_spawners: Array[Spawner] = []

# Dictionary used as set
var free_teacher_spawners: Dictionary = {}
var occupied_teacher_spawners: Dictionary = {}

var input: InputHandler
var parser: CommandParser
var dispatcher: CommandDispatcher


func _ready() -> void:
	parser = CommandParser.new()

	parser.actions_updated.connect(hint_menu.update_actions)
	parser.buffer_updated.connect(command_buffer.update_buffer)
	parser.reset()

	dispatcher = CommandDispatcher.new(self)

	input = InputHandler.new(self)
	add_child(input)

	markers.resize(10)
	for i in range(markers.size()):
		markers[i] = null

	_resolve_player()
	_collect_spawners_from_scene()

	if fill_all_teacher_spawners_on_start:
		while free_teacher_spawners.size() > 0:
			spawn_teacher_by_spawner()

	if auto_spawn_students:
		var timer := Timer.new()
		timer.wait_time = student_spawn_interval
		timer.autostart = true
		timer.one_shot = false
		timer.timeout.connect(_on_student_spawn_timer)
		add_child(timer)


func _resolve_player() -> void:
	player = get_node_or_null(player_path) as Player
	if player == null:
		push_error("Player not found at path: %s" % player_path)
		return
	player.parent = self


func _collect_spawners_from_scene() -> void:
	student_spawners.clear()
	free_teacher_spawners.clear()
	occupied_teacher_spawners.clear()

	var root := get_node_or_null(spawners_root_path)
	if root == null:
		push_warning("Spawners root not found at path: %s" % spawners_root_path)
		return

	var all_spawners := _find_spawners_recursive(root)
	for spawner in all_spawners:
		if spawner.scene == null:
			push_warning("Spawner '%s' has no scene assigned, skipping" % spawner.name)
			continue

		if student_scene != null and spawner.scene == student_scene:
			student_spawners.append(spawner)
			continue

		if teacher_scene != null and spawner.scene == teacher_scene:
			free_teacher_spawners[spawner] = null


func _find_spawners_recursive(node: Node) -> Array[Spawner]:
	var result: Array[Spawner] = []

	for child in node.get_children():
		if child is Spawner:
			result.append(child as Spawner)

		result.append_array(_find_spawners_recursive(child))

	return result
	
func _on_student_spawn_timer() -> void:
	spawn_student_by_spawner()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode == KEY_G:
			spawn_student_at(get_global_mouse_position())
		if event.keycode == KEY_P:
			spawn_student_by_spawner()
		if event.keycode == KEY_T:
			spawn_teacher_by_spawner()

func _draw():
	# --- existing marker drawing ---
	for i in range(markers.size()):
		var pos = markers[i]
		if pos == null:
			continue
		
		var local_pos = to_local(pos)
		draw_circle(local_pos, MARKER_RADIUS, Color.BLUE)

		var font = ThemeDB.fallback_font
		var font_size = MARKER_FONT_SIZE
		
		var text = str(i)
		var text_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
		draw_string(font, local_pos - text_size / 2, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.WHITE)

	if input == null or player == null:
		return

	# --- draw input buffer ---
	var buffer_text = input.input_buffer
	
	if buffer_text != "":
		var font = ThemeDB.fallback_font
		var font_size = BUFFER_FONT_SIZE

		var padding = 50
		var pos = player.global_position + Vector2(0, BUFFER_TEXT_OFFSET)

		var text_size = font.get_string_size(buffer_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
		var ascent = font.get_ascent(font_size)
		var rect = Rect2(pos - Vector2(padding / 2.0, ascent + padding / 2.0), text_size + Vector2(padding, padding))

		draw_rect(rect, Color(0, 0, 0, 0.6))

		draw_string(font, pos, buffer_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.WHITE)


## Spawn a single student at the given position
func spawn_student_at(position: Vector2) -> void:
	if student_scene == null:
		push_error("StudentScene not assigned")
		return
	
	var student = student_scene.instantiate()
	if student == null:
		push_error("StudentScene root is not a valid Node2D")
		return
	
	student.global_position = position
	add_child(student)


## Spawn multiple students at random positions
func spawn_students(count: int) -> void:
	for i in range(count):
		var random_pos = Vector2(randf_range(0, 1100), randf_range(0, 600))
		spawn_student_at(random_pos)


## Spawn teacher
func spawn_teacher() -> void:
	if teacher_scene == null:
		push_error("TeacherScene not assigned")
		return
	
	var teacher = teacher_scene.instantiate()
	if teacher == null:
		push_error("TeacherScene root is not a valid Node2D")
		return
	
	teacher.global_position = Vector2(200, 200)
	add_child(teacher)

func spawn_student_by_spawner() -> void:
	# remove invalid spawners
	student_spawners = student_spawners.filter(func(s): return is_instance_valid(s))

	if student_spawners.is_empty():
		return

	var spawner = student_spawners.pick_random()
	spawner.spawn()
	
func spawn_teacher_by_spawner() -> void:
	if free_teacher_spawners.is_empty():
		print("No free teacher spawners")
		return

	var spawner = free_teacher_spawners.keys().pick_random()
	free_teacher_spawners.erase(spawner)

	var spawned = spawner.spawn()
	if spawned == null:
		return

	spawned.spawner = spawner

	# important: listen for removal
	spawned.tree_exited.connect(_on_teacher_removed.bind(spawner))

	occupied_teacher_spawners[spawner] = spawned

func respawn_teacher_with_delay() -> void:
	var tree := get_tree()
	if tree == null:
		return

	await tree.create_timer(teacher_respawn_delay).timeout

	if not is_inside_tree():
		return

	spawn_teacher_by_spawner()

func _on_teacher_removed(spawner: Spawner) -> void:
	if occupied_teacher_spawners.has(spawner):
		occupied_teacher_spawners.erase(spawner)

	free_teacher_spawners[spawner] = null

	call_deferred("respawn_teacher_with_delay")


func create_marker(number: int):
	print("Create marker ", number, " at ", player.global_position)
	markers[number] = player.global_position
	queue_redraw()

func send_player_to_marker(number: int):
	if number < 0 or number >= markers.size():
		return
	if markers[number] != null and player != null:
		player.global_position = markers[number]
