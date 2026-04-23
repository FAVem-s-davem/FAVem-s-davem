## Main game scene manager
## Uses editor-placed player + spawners and handles runtime spawning/commands
extends Node2D

class_name GameScene

const MARKER_RADIUS: float = 300.0
const MARKER_FONT_SIZE: int = 350
const MARKER_OUTLINE = 20
const BUFFER_FONT_SIZE: int = 264
const BUFFER_TEXT_OFFSET: float = 1100.0

@export var student_scene: PackedScene = preload("res://scenes/Student.tscn")

@export_node_path("Player") var player_path: NodePath = NodePath("Player")
@export_node_path() var room_path: NodePath = NodePath("Map/Areas/Rooms")
@export_node_path() var spawner_path: NodePath = NodePath("Map/Areas/Spawners")

@onready var hint_menu = $"../CanvasLayer/Control/Hud/HintMenu"
@onready var command_buffer = $"../CanvasLayer/Control/Hud/CommandBuffer"

const QuestManagerScript = preload("res://scripts/quests/quest_manager.gd")

static var MARKER_COUNT = 4

var player: Player
var quest_manager
var game_loop_manager: GameLoopManager

var rooms: Array[Room] = []
var spawners: Array[Spawner] = []

var to_spawn: Array[int]

var markers: Array = []
var input: InputHandler
var parser: CommandParser
var dispatcher: CommandDispatcher

func _process(delta: float) -> void:
	queue_redraw()

func _ready() -> void:
	_initialize_input_parser()
	_resolve_player()
	_resolve_rooms()
	_resolve_spawners()
	_resolve_quest_manager()
	_resolve_game_loop_manager()

func _initialize_input_parser() -> void:
	parser = CommandParser.new()

	parser.actions_updated.connect(hint_menu.update_actions)
	parser.buffer_updated.connect(command_buffer.update_buffer)
	
	parser.reset()

	dispatcher = CommandDispatcher.new(self)
	dispatcher.macro_toggle.connect(command_buffer.set_macro)

	markers.resize(MARKER_COUNT + 1)
	for i in range(markers.size()):
		markers[i] = null

	input = InputHandler.new(self)
	input.key_pressed.connect(command_buffer.command_clear)
	input.valid_command.connect(command_buffer.command_success)
	input.invalid_command.connect(command_buffer.command_invalid)
	add_child(input)


func _resolve_player() -> void:
	player = get_node_or_null(player_path) as Player
	if player == null:
		push_error("Player not found at path: %s" % player_path)
		return
	player.parent = self

func _resolve_rooms() -> void:
	rooms.clear()

	var rooms_root := get_node_or_null(room_path)
	if rooms_root == null:
		push_error("Rooms root not found at path: %s" % room_path)
		return

	for child in rooms_root.get_children():
		var room := child as Room
		if room != null:
			rooms.append(room)

	print("Loaded %d room(s)" % rooms.size())


func _resolve_spawners() -> void:
	spawners.clear()

	var spawners_root := get_node_or_null(spawner_path)
	if spawners_root == null:
		push_warning("Spawners root not found at path: %s" % spawner_path)
		return

	for child in spawners_root.get_children():
		var spawner := child as Spawner
		if spawner != null:
			spawners.append(spawner)

	print("Loaded %d spawner(s)" % spawners.size())


func _resolve_quest_manager() -> void:
	quest_manager = get_node_or_null("QuestManager")

	if quest_manager == null:
		quest_manager = QuestManagerScript.new()
		quest_manager.name = "QuestManager"
		add_child(quest_manager)

	quest_manager.initialize_for_rooms(rooms)


func _resolve_game_loop_manager() -> void:
	game_loop_manager = get_node_or_null("GameLoopManager") as GameLoopManager
	if game_loop_manager == null:
		push_warning("GameLoopManager child is missing on GameScene")
		return

	game_loop_manager.initialize(self)


# Spawns students based on active quests across all available spawners.
func spawn_students_for_active_quests() -> void:
	if quest_manager == null:
		push_warning("GameScene: QuestManager not ready")
		return

	if spawners.is_empty():
		push_warning("GameScene: No spawners available for quest spawning")
		return

	
	var prep_spawners: Array[Spawner] = []
	
	for spawner in spawners:
		for i in range(spawner.weight):
			prep_spawners.append(spawner)

	for timetable in quest_manager.timetables:
		var quest = timetable.get_active_quest()
		if quest == null:
			continue

		for _i in range(quest.required_count):
			var spawner: Spawner = prep_spawners.pick_random()
			spawner.spawn_student(quest.required_student_type, quest.required_student_number)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode == KEY_G:
			spawn_student_at(get_global_mouse_position())

func _draw():
	# --- existing marker drawing ---
	for i in range(markers.size()):
		var pos = markers[i]
		if pos == null:
			continue
		
		var local_pos = pos
		draw_circle(local_pos, MARKER_RADIUS, Color.RED)
		draw_circle(local_pos, MARKER_RADIUS, Color.BLACK, false, MARKER_OUTLINE)

		var font = ThemeDB.fallback_font
		var font_size = MARKER_FONT_SIZE

		var text = str(i)
		var text_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
		var ascent = font.get_ascent(font_size)
		var descent = font.get_descent(font_size)

		var text_height = ascent + descent
		var text_pos = local_pos - Vector2(text_size.x / 2.0, text_height / 2.0 - ascent)

		var outline_size = MARKER_OUTLINE

		# --- Draw outline (8 directions) ---
		for x in range(-outline_size, outline_size + 1):
			for y in range(-outline_size, outline_size + 1):
				if x == 0 and y == 0:
					continue
				draw_string(font, text_pos + Vector2(x, y), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.BLACK)

		# --- Draw main text ---
		draw_string(font, text_pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.WHITE)

	if input == null or player == null:
		return

## Spawn a single student at the given position
func spawn_student_at(position_arg: Vector2) -> void:
	if student_scene == null:
		push_error("StudentScene not assigned")
		return
	
	var student = student_scene.instantiate()
	if student == null:
		push_error("StudentScene root is not a valid Node2D")
		return
	
	student.global_position = position_arg
	add_child(student)

## Spawn multiple students at random positions
func spawn_students(count: int) -> void:
	for i in range(count):
		var random_pos = Vector2(randf_range(0, 1100), randf_range(0, 600))
		spawn_student_at(random_pos)

func create_marker(number: int):
	if number > MARKER_COUNT or number <= 0:
		return
	print("Create marker ", number, " at ", player.global_position)
	markers[number] = player.global_position
	queue_redraw()

func send_player_to_marker(number: int):
	if number <= 0 or number > MARKER_COUNT:
		return
	if markers[number] != null and player != null:
		player.global_position = markers[number]
