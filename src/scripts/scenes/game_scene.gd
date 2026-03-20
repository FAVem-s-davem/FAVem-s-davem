## Main game scene manager
## Spawns and manages player, students, and map objects
extends Node2D

@export var student_scene: PackedScene = preload("res://scenes/Student.tscn")
@export var player_scene: PackedScene = preload("res://scenes/Player.tscn")
@export var map_scene: PackedScene = preload("res://scenes/MapObject.tscn")

var player: Node2D


func _ready() -> void:
	if student_scene == null:
		push_error("StudentScene not assigned")
		return
	
	if player_scene == null:
		push_error("PlayerScene not assigned")
		return
	
	if map_scene == null:
		push_error("MapScene not assigned")
		return
	
	spawn_player()
	spawn_students(10)
	spawn_map()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode == KEY_G:
			spawn_student_at(get_global_mouse_position())


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
func spawn_player() -> void:
	if player_scene == null:
		push_error("PlayerScene not assigned")
		return
	
	var player = player_scene.instantiate()
	if player == null:
		push_error("PlayerScene root is not a valid Node2D")
		return
	
	player.global_position = Vector2(100, 100)
	add_child(player)


## Spawn map objects from SVG file
func spawn_map() -> void:
	if map_scene == null:
		push_error("MapScene not assigned")
		return
	
	var polygons = _get_svg_polygons("res://assets/test.svg")
	print("Loaded %d polygons from SVG" % polygons.size())
	
	for poly_string in polygons:
		var map_obj = map_scene.instantiate()
		if map_obj == null:
			push_error("MapScene root is not valid")
			return
		
		# Initialize map object with polygon data
		map_obj.init(poly_string)
		add_child(map_obj)


## Extract polygon tags from SVG file
func _get_svg_polygons(path: String) -> Array[String]:
	var polygons: Array[String] = []
	
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_warning("Could not open SVG file: %s" % path)
		return polygons
	
	var svg_text = file.get_as_text()
	
	# Simple regex-like extraction of polygon tags
	# This is a basic implementation - may need refinement
	var regex = RegEx.new()
	regex.compile(r"<polygon[^>]*(?:\/>|>[\s\S]*?<\/polygon>)")
	
	var matches = regex.search_all(svg_text)
	for match in matches:
		polygons.append(match.get_string())
	
	return polygons
