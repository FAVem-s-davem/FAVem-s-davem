extends Node2D
class_name Spawner

@export var scene: PackedScene

var polygon: PackedVector2Array
var bounds: Rect2

func setup(poly: PackedVector2Array):
	polygon = poly
	bounds = get_polygon_bounds(poly)
	queue_redraw() # 🔥 important: tells Godot to redraw

func spawn() -> CharacterBody2D:
	var spawned = scene.instantiate()
	spawned.global_position = get_random_point()
	get_parent().add_child.call_deferred(spawned) # safer than current_scene
	return spawned

func get_random_point() -> Vector2:
	for i in range(100):
		var p = Vector2(
			randf_range(bounds.position.x, bounds.position.x + bounds.size.x),
			randf_range(bounds.position.y, bounds.position.y + bounds.size.y)
		)

		if Geometry2D.is_point_in_polygon(p, polygon):
			return to_global(p)

	return to_global(bounds.position)

func get_polygon_bounds(poly: PackedVector2Array) -> Rect2:
	var min_x = poly[0].x
	var max_x = poly[0].x
	var min_y = poly[0].y
	var max_y = poly[0].y

	for p in poly:
		min_x = min(min_x, p.x)
		max_x = max(max_x, p.x)
		min_y = min(min_y, p.y)
		max_y = max(max_y, p.y)

	return Rect2(
		Vector2(min_x, min_y),
		Vector2(max_x - min_x, max_y - min_y)
	)

# 🎨 DRAWING
func _draw():
	if polygon.is_empty():
		return

	# Fill color (semi-transparent green)
	draw_polygon(polygon, [Color(0, 1, 0, 0.3)])

	# Outline (optional, looks nice)
	for i in range(polygon.size()):
		var a = polygon[i]
		var b = polygon[(i + 1) % polygon.size()]
		draw_line(a, b, Color(0, 1, 0), 2)
