## Map object that creates collision walls from SVG polygon data
## Displays the polygon and provides collision for player/students
extends StaticBody2D

var polygon_data: Polygon.PolygonData = null
var collision_segments: Array[CollisionShape2D] = []


func _ready() -> void:
	# Collision shapes will be created in init()
	pass


## Initialize this map object with SVG polygon string
func init(polygon_string: String, nav_manager: NavigationManager, world_scale: float = 1.0) -> void:
	polygon_data = Polygon.from_svg_polygon(polygon_string)

	if polygon_data == null or polygon_data.vertices.is_empty():
		push_warning("Failed to parse polygon from SVG")
		return

	for i in range(polygon_data.vertices.size()):
		polygon_data.vertices[i] *= world_scale
	polygon_data.pen_width *= world_scale

	_create_walls()

	var margin := 50.0 * world_scale
	
	var verts := polygon_data.vertices.duplicate()

	if nav_manager.outer_boundary == null:
		# Outer MUST be clockwise
		verts = ensure_clockwise(verts)
		
		# Then shrink inward
		var shrunk = offset_polygon(verts, -margin)
		nav_manager.set_walkable_area(shrunk)
	else:
		# Obstacles MUST be counter-clockwise
		verts = ensure_counter_clockwise(verts)
		
		# Then expand outward
		var expanded = offset_polygon(verts, -margin)
		nav_manager.add_obstacle(expanded)

	queue_redraw()

func is_clockwise(poly: PackedVector2Array) -> bool:
	var sum := 0.0
	for i in range(poly.size()):
		var a = poly[i]
		var b = poly[(i + 1) % poly.size()]
		sum += (b.x - a.x) * (b.y + a.y)
	return sum > 0.0

func ensure_clockwise(poly: PackedVector2Array) -> PackedVector2Array:
	if not is_clockwise(poly):
		poly.reverse()
	return poly
	
func ensure_counter_clockwise(poly: PackedVector2Array) -> PackedVector2Array:
	if is_clockwise(poly):
		poly.reverse()
	return poly

## Create collision walls from polygon vertices using segment shapes
## This matches the C++ behavior of creating SegmentShape2D for each edge
func _create_walls() -> void:
	if polygon_data == null or polygon_data.vertices.is_empty():
		return
	
	var vertices = polygon_data.vertices
	var size = vertices.size()
	
	# Create a CollisionShape2D for each edge segment
	for i in range(size):
		var a = vertices[i]
		var b = vertices[(i + 1) % size]
		
		# Create segment shape
		var segment = SegmentShape2D.new()
		segment.a = a
		segment.b = b
		
		# Create collision shape node
		var collision = CollisionShape2D.new()
		collision.shape = segment
		
		add_child(collision)
		collision_segments.append(collision)


## Draw the polygon visually
func _draw() -> void:
	if polygon_data == null or polygon_data.vertices.is_empty():
		return
	
	var vertices = polygon_data.vertices
	var size = vertices.size()
	
	# Draw lines between each vertex and the next (looping back to first)
	for i in range(size):
		var start = vertices[i]
		var end = vertices[(i + 1) % size]
		draw_line(start, end, polygon_data.color, polygon_data.pen_width)

func offset_polygon(poly: PackedVector2Array, amount: float) -> PackedVector2Array:
	var result = PackedVector2Array()
	var count = poly.size()
	
	if count < 3:
		return poly
	
	for i in range(count):
		var prev = poly[(i - 1 + count) % count]
		var curr = poly[i]
		var next = poly[(i + 1) % count]
		
		var dir1 = (curr - prev).normalized()
		var dir2 = (next - curr).normalized()
		
		var normal1 = Vector2(-dir1.y, dir1.x)
		var normal2 = Vector2(-dir2.y, dir2.x)
		
		var avg_normal = (normal1 + normal2).normalized()
		
		result.append(curr + avg_normal * amount)
	
	return result
