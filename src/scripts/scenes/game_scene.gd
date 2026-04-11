## Main game scene manager
## Uses editor-placed player + spawners and handles runtime spawning/commands
extends Node2D

class_name GameScene

const MARKER_RADIUS: float = 132.0
const MARKER_FONT_SIZE: int = 154
const BUFFER_FONT_SIZE: int = 264
const BUFFER_TEXT_OFFSET: float = 1100.0

@export var student_scene: PackedScene = preload("res://scenes/Student.tscn")

@export_node_path("Player") var player_path: NodePath = NodePath("Player")

@onready var hint_menu = $"../CanvasLayer/Control/Hud/HintMenu"
@onready var command_buffer = $"../CanvasLayer/Control/Hud/CommandBuffer"


var markers: Array = []

var player: Player

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

	_resolve_nodes()


func _resolve_nodes() -> void:
	player = get_node_or_null(player_path) as Player
	if player == null:
		push_error("Player not found at path: %s" % player_path)
		return
	


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
	print("Create marker ", number, " at ", player.global_position)
	markers[number] = player.global_position
	queue_redraw()

func send_player_to_marker(number: int):
	if number < 0 or number >= markers.size():
		return
	if markers[number] != null and player != null:
		player.global_position = markers[number]
