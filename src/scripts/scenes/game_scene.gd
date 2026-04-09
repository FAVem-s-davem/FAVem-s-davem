## Main game scene manager
## Spawns and manages player, students, and map objects
extends Node2D

class_name GameScene

@export var student_scene: PackedScene = preload("res://scenes/Student.tscn")
@export var player_scene: PackedScene = preload("res://scenes/Player.tscn")
@export var map_scene: PackedScene = preload("res://scenes/MapObject.tscn")
@export var teacher_scene: PackedScene = preload("res://scenes/Teacher.tscn")

@export var teacher_respawn_delay: float = 3.0

@export_file("*.svg") var svg_path: String = "res://assets/fav2.svg"

@onready var hint_menu = $"../CanvasLayer/Control/Hud/HintMenu"

var markers: Array = []

var navigation_manager: NavigationManager

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
	#parser.buffer_updated.connect(hint_menu.update_buffer) # optional
	
	dispatcher = CommandDispatcher.new(self)
	
	input = InputHandler.new(self)
	add_child(input)
	
	for i in range(10):
		markers.append(null)
	
	navigation_manager = NavigationManager.new()
	add_child(navigation_manager)
	
	if student_scene == null:
		push_error("StudentScene not assigned")
		return
	
	if player_scene == null:
		push_error("PlayerScene not assigned")
		return
	
	if map_scene == null:
		push_error("MapScene not assigned")
		return
	
	var polygons = get_svg_polygons_by_fill(svg_path)
	
	#spawn_students(10)
	spawn_map(polygons.get("none", []))
	navigation_manager.bake_navigation()
	
	spawn_player(polygons.get("green", []))
	#spawn_teacher()
	spawn_student_spawners(polygons.get("red", []))

	spawn_teacher_spawners(polygons.get("blue", []))
	
	while free_teacher_spawners.size() > 0:
		spawn_teacher_by_spawner()
		
	var timer := Timer.new()
	timer.wait_time = 2.0  # spawn every 2 seconds
	timer.autostart = true
	timer.one_shot = false

	timer.timeout.connect(_on_student_spawn_timer)

	add_child(timer)
	
func _on_student_spawn_timer() -> void:
	spawn_student_by_spawner()

"""
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode == KEY_G:
			spawn_student_at(get_global_mouse_position())
		if event.keycode == KEY_P:
			spawn_student_by_spawner()
		if event.keycode == KEY_T:
			spawn_teacher_by_spawner()
			"""
			

func _draw():
	# --- existing marker drawing ---
	for i in range(markers.size()):
		var pos = markers[i]
		if pos == null:
			continue
		
		var local_pos = to_local(pos)
		draw_circle(local_pos, 12.0, Color.BLUE)

		var font = ThemeDB.fallback_font
		var font_size = 14
		
		var text = str(i)
		var text_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
		draw_string(font, local_pos - text_size / 2, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.WHITE)

	# --- 🔥 NEW: draw input buffer ---
	var buffer_text = input.input_buffer
	
	if buffer_text != "":
		var font = ThemeDB.fallback_font
		var font_size = 24
		
		var padding = 10
		var pos = player.global_position + Vector2(0, 100)
		
		# optional background
		var text_size = font.get_string_size(buffer_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
		var rect = Rect2(pos - Vector2(5, 25), text_size + Vector2(10, 10))
		
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


## Spawn the player
func spawn_player(polygons: Array) -> void:
	if player_scene == null:
		push_error("PlayerScene not assigned")
		return
	var spawner = Spawner.new()
	spawner.scene = player_scene
	spawner.setup(parse_polygon_points(polygons[0]))
	add_child(spawner)
	player = spawner.spawn()
	if player == null:
		push_error("PlayerScene root is not a valid Node2D")
		return
	
	player.parent = self
	spawner.queue_free()


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



## Spawn map objects from SVG file
func spawn_map(polygons: Array) -> void:
	if map_scene == null:
		push_error("MapScene not assigned")
		return
	

	print("Loaded %d polygons from SVG" % polygons.size())
	
	for poly_string in polygons:
		var map_obj = map_scene.instantiate()
		if map_obj == null:
			push_error("MapScene root is not valid")
			return
		
		# Initialize map object with polygon data
		map_obj.init(poly_string, navigation_manager)
		add_child(map_obj)
		
		
func spawn_student_spawners(polygons: Array) -> void:
	for polygon in polygons:
		var spawner = Spawner.new()
		spawner.scene = student_scene
		spawner.setup(parse_polygon_points(polygon))
		student_spawners.append(spawner)
		add_child(spawner)
		
func spawn_teacher_spawners(polygons: Array) -> void:
	for polygon in polygons:
		var spawner = Spawner.new()
		spawner.scene = teacher_scene
		spawner.setup(parse_polygon_points(polygon))
		free_teacher_spawners[spawner] = null
		add_child(spawner)
	
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

	# 🔥 important: listen for removal
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

## Extract polygon tags from SVG file
func get_svg_polygons_by_fill(path: String) -> Dictionary:
	var result := {}

	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_warning("Could not open SVG file: %s" % path)
		return result

	var svg_text = file.get_as_text()

	var regex = RegEx.new()
	regex.compile(r"<polygon[^>]*>")

	var matches = regex.search_all(svg_text)

	for match in matches:
		var polygon_tag = match.get_string()

		var fill = extract_fill(polygon_tag)

		# Normalize fill (optional but useful)
		if fill == "":
			fill = "none"

		if not result.has(fill):
			result[fill] = []

		result[fill].append(polygon_tag)

	return result
	
func extract_fill(tag: String) -> String:
	var regex = RegEx.new()
	regex.compile(r'fill="([^"]*)"')

	var match = regex.search(tag)
	if match:
		return match.get_string(1).to_lower()

	return "" # no fill found


func parse_polygon_points(tag: String) -> PackedVector2Array:
	var regex = RegEx.new()
	regex.compile(r'points="([^"]*)"')

	var match = regex.search(tag)
	if match == null:
		return PackedVector2Array()

	var points_str = match.get_string(1)
	var points = PackedVector2Array()

	var pairs = points_str.split(" ")

	for pair in pairs:
		if pair.strip_edges() == "":
			continue

		var coords = pair.split(",")
		if coords.size() != 2:
			continue

		var x = float(coords[0])
		var y = float(coords[1])

		points.append(Vector2(x, y))

	return points


func create_marker(number: int):
	print("Create marker ", number, " at ", player.global_position)
	markers[number] = player.global_position
	queue_redraw()

func send_player_to_marker(number: int):
	if markers[number] != null:
		player.global_position = markers[number]
