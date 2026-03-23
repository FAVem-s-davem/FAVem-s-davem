## Map object that creates collision walls from SVG polygon data
## Displays the polygon and provides collision for player/students
extends StaticBody2D

var polygon_data: Polygon.PolygonData = null
var collision_segments: Array[CollisionShape2D] = []


func _ready() -> void:
	# Collision shapes will be created in init()
	pass


## Initialize this map object with SVG polygon string
func init(polygon_string: String) -> void:
	# Parse the SVG polygon
	polygon_data = Polygon.from_svg_polygon(polygon_string)
	
	if polygon_data == null or polygon_data.vertices.is_empty():
		push_warning("Failed to parse polygon from SVG")
		return
	
	# Set up collision walls from individual segments
	_create_walls()
	queue_redraw()


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
