## Polygon utility for parsing SVG polygons
## Static class for converting SVG polygon data to usable format
class_name Polygon


## Data structure for parsed polygon
class PolygonData:
	var vertices: PackedVector2Array
	var color: Color
	var pen_width: float
	
	func _init(verts: PackedVector2Array = PackedVector2Array(), col: Color = Color.WHITE, width: float = 1.0):
		vertices = verts
		color = col
		pen_width = width


## Parse an SVG polygon tag and extract vertices, color, and stroke width
static func from_svg_polygon(svg_tag: String) -> PolygonData:
	var vertices: PackedVector2Array = []
	var color: Color = Color.WHITE
	var pen_width: float = 1.0
	
	if svg_tag.is_empty():
		push_warning("Empty SVG tag provided")
		return PolygonData.new(vertices, color, pen_width)
	
	# Extract points attribute
	var points_regex = RegEx.new()
	if points_regex.compile(r'points\s*=\s*"([^"]+)"') != OK:
		push_error("Failed to compile points regex")
		return PolygonData.new(vertices, color, pen_width)
	
	var points_match = points_regex.search(svg_tag)
	
	if points_match:
		var points_str = points_match.get_string(1)
		# Parse "x1,y1 x2,y2 x3,y3..." format
		var points = points_str.split(" ")
		
		for point in points:
			point = point.strip_edges()
			if point.is_empty():
				continue
			
			var coords = point.split(",")
			if coords.size() == 2:
				var x = float(coords[0])
				var y = float(coords[1])
				vertices.append(Vector2(x, y))
	
	if vertices.is_empty():
		push_warning("No vertices found in SVG polygon")
		return PolygonData.new(vertices, color, pen_width)
	
	# Extract stroke color
	var stroke_regex = RegEx.new()
	if stroke_regex.compile(r'stroke\s*=\s*"([^"]+)"') == OK:
		var stroke_match = stroke_regex.search(svg_tag)
		if stroke_match:
			var stroke_color = stroke_match.get_string(1)
			if stroke_color.begins_with("#"):
				color = Color.html(stroke_color)
	
	# Extract stroke width
	var width_regex = RegEx.new()
	if width_regex.compile(r'stroke-width\s*=\s*"([^"]+)"') == OK:
		var width_match = width_regex.search(svg_tag)
		if width_match:
			pen_width = float(width_match.get_string(1))
	
	return PolygonData.new(vertices, color, pen_width)
