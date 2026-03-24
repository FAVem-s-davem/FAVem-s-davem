extends StaticBody2D
class_name SvgMapCollider

class SvgShapeData:
	var points: PackedVector2Array = PackedVector2Array()
	var closed: bool = false
	var stroke_color: Color = Color.WHITE
	var stroke_width: float = 1.0

	func _init(_points: PackedVector2Array = PackedVector2Array(), _closed: bool = false, _stroke_color: Color = Color.WHITE, _stroke_width: float = 1.0) -> void:
		points = _points
		closed = _closed
		stroke_color = _stroke_color
		stroke_width = _stroke_width


var shapes: Array[SvgShapeData] = []
var collision_segments: Array[CollisionShape2D] = []


func _ready() -> void:
	pass


func clear_geometry() -> void:
	for c in collision_segments:
		if is_instance_valid(c):
			c.queue_free()
	collision_segments.clear()
	shapes.clear()


func init_from_svg(svg_text: String) -> void:
	clear_geometry()

	var parsed := _parse_svg(svg_text)
	if parsed.is_empty():
		push_warning("SVG parser found no drawable shapes.")
		return

	shapes = parsed
	_create_collision_from_shapes()
	queue_redraw()


func _create_collision_from_shapes() -> void:
	for shape_data in shapes:
		var pts := shape_data.points
		if pts.size() < 2:
			continue

		for i in range(pts.size() - 1):
			_add_segment(pts[i], pts[i + 1])

		if shape_data.closed and pts.size() > 2:
			_add_segment(pts[pts.size() - 1], pts[0])


func _add_segment(a: Vector2, b: Vector2) -> void:
	var segment := SegmentShape2D.new()
	segment.a = a
	segment.b = b

	var collision := CollisionShape2D.new()
	collision.shape = segment
	add_child(collision)
	collision_segments.append(collision)


func _draw() -> void:
	for shape_data in shapes:
		var pts := shape_data.points
		if pts.size() < 2:
			continue

		for i in range(pts.size() - 1):
			draw_line(pts[i], pts[i + 1], shape_data.stroke_color, shape_data.stroke_width)

		if shape_data.closed and pts.size() > 2:
			draw_line(pts[pts.size() - 1], pts[0], shape_data.stroke_color, shape_data.stroke_width)


static func _parse_svg(svg_text: String) -> Array[SvgShapeData]:
	var raw := svg_text.strip_edges()
	if raw.is_empty():
		return []

	# Allow SVG fragments, not only a full <svg> document.
	if not raw.begins_with("<svg"):
		raw = "<svg xmlns=\"http://www.w3.org/2000/svg\">" + raw + "</svg>"

	var parser := XMLParser.new()
	var err := parser.open_buffer(raw.to_utf8_buffer())
	if err != OK:
		push_error("XMLParser.open_buffer failed: %s" % err)
		return []

	@warning_ignore("shadowed_variable")
	var shapes: Array[SvgShapeData] = []
	var transform_stack: Array[Transform2D] = [Transform2D.IDENTITY]
	var style_stack: Array[Dictionary] = [_default_style()]
	var ignored_depth := 0

	while true:
		err = parser.read()
		if err == ERR_FILE_EOF:
			break
		if err != OK:
			push_error("XMLParser.read failed: %s" % err)
			break

		var node_type := parser.get_node_type()

		if node_type == XMLParser.NODE_ELEMENT:
			var tag := parser.get_node_name().to_lower()
			var attrs := _collect_attributes(parser)

			if ignored_depth > 0:
				if not parser.is_empty():
					ignored_depth += 1
				continue

			if _is_ignored_container(tag):
				if not parser.is_empty():
					ignored_depth = 1
				continue

			var parent_transform: Transform2D = transform_stack[transform_stack.size() - 1]
			var parent_style: Dictionary = style_stack[style_stack.size() - 1]
			var local_transform := _parse_transform(attrs.get("transform", ""))
			var combined_transform := parent_transform * local_transform
			var combined_style := _merge_style(parent_style, attrs)

			if _is_container(tag):
				# Push inherited state for children.
				transform_stack.append(combined_transform)
				style_stack.append(combined_style)
				continue

			var shape := _shape_from_element(tag, attrs, combined_transform, combined_style)
			if shape != null and shape.points.size() >= 2:
				shapes.append(shape)

		elif node_type == XMLParser.NODE_ELEMENT_END:
			var end_tag := parser.get_node_name().to_lower()

			if ignored_depth > 0:
				ignored_depth -= 1
				continue

			if _is_container(end_tag):
				if transform_stack.size() > 1:
					transform_stack.pop_back()
				if style_stack.size() > 1:
					style_stack.pop_back()

	return shapes


static func _shape_from_element(tag: String, attrs: Dictionary, xform: Transform2D, inherited_style: Dictionary) -> SvgShapeData:
	var pts: PackedVector2Array = PackedVector2Array()
	var closed := false

	match tag:
		"path":
			var d := String(attrs.get("d", ""))
			pts = _parse_path_d(d, xform)
			closed = _path_is_closed(d)

		"polyline":
			pts = _parse_points_attr(String(attrs.get("points", "")), xform)
			closed = false

		"polygon":
			pts = _parse_points_attr(String(attrs.get("points", "")), xform)
			closed = true

		"line":
			var x1 := _parse_float(String(attrs.get("x1", "0")))
			var y1 := _parse_float(String(attrs.get("y1", "0")))
			var x2 := _parse_float(String(attrs.get("x2", "0")))
			var y2 := _parse_float(String(attrs.get("y2", "0")))
			pts.append(xform * Vector2(x1, y1))
			pts.append(xform * Vector2(x2, y2))
			closed = false

		"rect":
			var x := _parse_float(String(attrs.get("x", "0")))
			var y := _parse_float(String(attrs.get("y", "0")))
			var w := _parse_float(String(attrs.get("width", "0")))
			var h := _parse_float(String(attrs.get("height", "0")))

			if w > 0.0 and h > 0.0:
				pts.append(xform * Vector2(x, y))
				pts.append(xform * Vector2(x + w, y))
				pts.append(xform * Vector2(x + w, y + h))
				pts.append(xform * Vector2(x, y + h))
				closed = true

		"circle":
			var cx := _parse_float(String(attrs.get("cx", "0")))
			var cy := _parse_float(String(attrs.get("cy", "0")))
			var r := _parse_float(String(attrs.get("r", "0")))
			if r > 0.0:
				pts = _approximate_ellipse(xform, Vector2(cx, cy), r, r, 24)
				closed = true

		"ellipse":
			var ecx := _parse_float(String(attrs.get("cx", "0")))
			var ecy := _parse_float(String(attrs.get("cy", "0")))
			var rx := _parse_float(String(attrs.get("rx", "0")))
			var ry := _parse_float(String(attrs.get("ry", "0")))
			if rx > 0.0 and ry > 0.0:
				pts = _approximate_ellipse(xform, Vector2(ecx, ecy), rx, ry, 24)
				closed = true

		_:
			return null

	if pts.size() < 2:
		return null

	var stroke_color := _parse_color(String(inherited_style.get("stroke", "#ffffff")))
	var stroke_width := _parse_float(String(inherited_style.get("stroke-width", "1.0")))

	return SvgShapeData.new(pts, closed, stroke_color, stroke_width)


static func _default_style() -> Dictionary:
	return {
		"stroke": "#ffffff",
		"stroke-width": "1.0",
		"fill": "none",
	}


static func _merge_style(parent_style: Dictionary, attrs: Dictionary) -> Dictionary:
	var out := parent_style.duplicate(true)

	# Style attribute: "key:value; key:value"
	if attrs.has("style"):
		var style_text := String(attrs["style"])
		for part in style_text.split(";"):
			var pair := part.strip_edges()
			if pair.is_empty():
				continue
			var colon := pair.find(":")
			if colon == -1:
				continue
			var key := pair.substr(0, colon).strip_edges().to_lower()
			var value := pair.substr(colon + 1).strip_edges()
			if not key.is_empty():
				out[key] = value

	# Direct SVG attributes override style attribute.
	for key in ["stroke", "stroke-width", "fill", "opacity", "fill-opacity", "stroke-opacity"]:
		if attrs.has(key):
			out[key] = String(attrs[key])

	return out


static func _collect_attributes(parser: XMLParser) -> Dictionary:
	var attrs := {}
	for i in range(parser.get_attribute_count()):
		attrs[parser.get_attribute_name(i).to_lower()] = parser.get_attribute_value(i)
	return attrs


static func _is_container(tag: String) -> bool:
	return tag == "svg" or tag == "g" or tag == "a"


static func _is_ignored_container(tag: String) -> bool:
	return tag == "defs" or tag == "clippath" or tag == "mask" or tag == "symbol" or tag == "marker" or tag == "pattern" or tag == "metadata" or tag == "title" or tag == "desc"


static func _parse_points_attr(points_text: String, xform: Transform2D) -> PackedVector2Array:
	var nums := _parse_number_list(points_text)
	var pts := PackedVector2Array()

	var i := 0
	while i + 1 < nums.size():
		pts.append(xform * Vector2(nums[i], nums[i + 1]))
		i += 2

	return pts


static func _parse_path_d(d: String, xform: Transform2D) -> PackedVector2Array:
	var tokens := _tokenize_path_data(d)
	var pts := PackedVector2Array()

	if tokens.is_empty():
		return pts

	var i := 0
	var cmd := ""
	var current := Vector2.ZERO
	var subpath_start := Vector2.ZERO
	var prev_cubic_ctrl := Vector2.ZERO
	var prev_quad_ctrl := Vector2.ZERO
	var prev_cmd := ""

	while i < tokens.size():
		var t := tokens[i]

		if _is_path_command(t):
			cmd = t
			i += 1
		elif cmd.is_empty():
			# Invalid path data, ignore.
			break

		match cmd:
			"M", "m":
				var first_pair := true
				while i + 1 < tokens.size() and not _is_path_command(tokens[i]):
					var p := _read_svg_point(tokens, i, cmd == "m", current)
					if first_pair:
						current = p
						subpath_start = p
						pts.append(xform * p)
						first_pair = false
					else:
						current = p
						pts.append(xform * p)
					i += 2
					prev_cubic_ctrl = current
					prev_quad_ctrl = current
					prev_cmd = cmd

					# After the first moveto pair, extra pairs are implicit lineto.
					cmd = "L" if cmd == "M" else "l"

			"L", "l":
				while i + 1 < tokens.size() and not _is_path_command(tokens[i]):
					var p2 := _read_svg_point(tokens, i, cmd == "l", current)
					current = p2
					pts.append(xform * current)
					i += 2
					prev_cubic_ctrl = current
					prev_quad_ctrl = current
					prev_cmd = cmd

			"H", "h":
				while i < tokens.size() and not _is_path_command(tokens[i]):
					var x := _parse_float(tokens[i])
					current.x = current.x + x if cmd == "h" else x
					pts.append(xform * current)
					i += 1
					prev_cubic_ctrl = current
					prev_quad_ctrl = current
					prev_cmd = cmd

			"V", "v":
				while i < tokens.size() and not _is_path_command(tokens[i]):
					var y := _parse_float(tokens[i])
					current.y = current.y + y if cmd == "v" else y
					pts.append(xform * current)
					i += 1
					prev_cubic_ctrl = current
					prev_quad_ctrl = current
					prev_cmd = cmd

			"C", "c":
				while i + 5 < tokens.size() and not _is_path_command(tokens[i]):
					var c1 := _read_svg_point(tokens, i, cmd == "c", current)
					var c2 := _read_svg_point(tokens, i + 2, cmd == "c", current)
					var endp := _read_svg_point(tokens, i + 4, cmd == "c", current)
					_approximate_cubic(pts, xform, current, c1, c2, endp, 12)
					current = endp
					prev_cubic_ctrl = c2
					prev_quad_ctrl = current
					prev_cmd = cmd
					i += 6

			"S", "s":
				while i + 3 < tokens.size() and not _is_path_command(tokens[i]):
					var refl := current
					if prev_cmd == "C" or prev_cmd == "c" or prev_cmd == "S" or prev_cmd == "s":
						refl = current * 2.0 - prev_cubic_ctrl
					var c2s := _read_svg_point(tokens, i, cmd == "s", current)
					var end_s := _read_svg_point(tokens, i + 2, cmd == "s", current)
					_approximate_cubic(pts, xform, current, refl, c2s, end_s, 12)
					current = end_s
					prev_cubic_ctrl = c2s
					prev_quad_ctrl = current
					prev_cmd = cmd
					i += 4

			"Q", "q":
				while i + 3 < tokens.size() and not _is_path_command(tokens[i]):
					var qc := _read_svg_point(tokens, i, cmd == "q", current)
					var qend := _read_svg_point(tokens, i + 2, cmd == "q", current)
					_approximate_quadratic(pts, xform, current, qc, qend, 10)
					current = qend
					prev_quad_ctrl = qc
					prev_cubic_ctrl = current
					prev_cmd = cmd
					i += 4

			"T", "t":
				while i + 1 < tokens.size() and not _is_path_command(tokens[i]):
					var qrefl := current
					if prev_cmd == "Q" or prev_cmd == "q" or prev_cmd == "T" or prev_cmd == "t":
						qrefl = current * 2.0 - prev_quad_ctrl
					var tqend := _read_svg_point(tokens, i, cmd == "t", current)
					_approximate_quadratic(pts, xform, current, qrefl, tqend, 10)
					current = tqend
					prev_quad_ctrl = qrefl
					prev_cubic_ctrl = current
					prev_cmd = cmd
					i += 2

			"A", "a":
				while i + 6 < tokens.size() and not _is_path_command(tokens[i]):
					var rx: float = abs(_parse_float(tokens[i]))
					var ry: float = abs(_parse_float(tokens[i + 1]))
					var rot: float = _parse_float(tokens[i + 2])

					var large_arc: bool = int(_parse_float(tokens[i + 3])) != 0
					var sweep: bool = int(_parse_float(tokens[i + 4])) != 0

					var end_a: Vector2 = _read_svg_point(tokens, i + 5, cmd == "a", current)

					_approximate_arc(pts, xform, current, rx, ry, rot, large_arc, sweep, end_a, 16)

					current = end_a
					prev_cubic_ctrl = current
					prev_quad_ctrl = current
					prev_cmd = cmd

					i += 7

			"Z", "z":
				# The close is represented by the shape's closed flag.
				current = subpath_start
				prev_cubic_ctrl = current
				prev_quad_ctrl = current
				prev_cmd = cmd
				i += 0
				cmd = ""
				i += 1

			_:
				# Unknown command: stop parsing this path.
				break

	return pts


static func _path_is_closed(d: String) -> bool:
	return d.find("Z") != -1 or d.find("z") != -1


static func _tokenize_path_data(d: String) -> PackedStringArray:
	var re := RegEx.create_from_string(r"[MmZzLlHhVvCcSsQqTtAa]|[-+]?(?:\d*\.\d+|\d+)(?:[eE][-+]?\d+)?")
	var out := PackedStringArray()
	for m in re.search_all(d):
		var s := m.get_string()
		if not s.is_empty():
			out.append(s)
	return out


static func _is_path_command(token: String) -> bool:
	return token.length() == 1 and "MmZzLlHhVvCcSsQqTtAa".find(token) != -1


static func _read_svg_point(tokens: PackedStringArray, index: int, relative: bool, current: Vector2) -> Vector2:
	var x := _parse_float(tokens[index])
	var y := _parse_float(tokens[index + 1])
	if relative:
		return current + Vector2(x, y)
	return Vector2(x, y)


static func _approximate_cubic(out_pts: PackedVector2Array, xform: Transform2D, p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, steps: int) -> void:
	for s in range(1, steps + 1):
		var t := float(s) / float(steps)
		var u := 1.0 - t
		var p := (u * u * u * p0) + (3.0 * u * u * t * p1) + (3.0 * u * t * t * p2) + (t * t * t * p3)
		out_pts.append(xform * p)


static func _approximate_quadratic(out_pts: PackedVector2Array, xform: Transform2D, p0: Vector2, p1: Vector2, p2: Vector2, steps: int) -> void:
	for s in range(1, steps + 1):
		var t := float(s) / float(steps)
		var u := 1.0 - t
		var p := (u * u * p0) + (2.0 * u * t * p1) + (t * t * p2)
		out_pts.append(xform * p)


static func _approximate_ellipse(xform: Transform2D, center: Vector2, rx: float, ry: float, steps: int) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in range(steps):
		var a := TAU * float(i) / float(steps)
		var p := Vector2(center.x + cos(a) * rx, center.y + sin(a) * ry)
		pts.append(xform * p)
	return pts


static func _approximate_arc(
	out_pts: PackedVector2Array,
	xform: Transform2D,
	p0: Vector2,
	rx_in: float,
	ry_in: float,
	rotation_deg: float,
	large_arc: bool,
	sweep: bool,
	p1: Vector2,
	segments: int
) -> void:

	if p0.is_equal_approx(p1) or rx_in <= 0.0 or ry_in <= 0.0:
		out_pts.append(xform * p1)
		return

	var rx: float = abs(rx_in)
	var ry: float = abs(ry_in)

	var phi: float = deg_to_rad(rotation_deg)
	var cos_phi: float = cos(phi)
	var sin_phi: float = sin(phi)

	var dx2: float = (p0.x - p1.x) * 0.5
	var dy2: float = (p0.y - p1.y) * 0.5

	var x1p: float = cos_phi * dx2 + sin_phi * dy2
	var y1p: float = -sin_phi * dx2 + cos_phi * dy2

	var rx_sq: float = rx * rx
	var ry_sq: float = ry * ry
	var x1p_sq: float = x1p * x1p
	var y1p_sq: float = y1p * y1p

	var lambda: float = x1p_sq / rx_sq + y1p_sq / ry_sq
	if lambda > 1.0:
		var s: float = sqrt(lambda)
		rx *= s
		ry *= s
		rx_sq = rx * rx
		ry_sq = ry * ry

	var sign: float = -1.0 if large_arc == sweep else 1.0

	var numerator: float = max(0.0, rx_sq * ry_sq - rx_sq * y1p_sq - ry_sq * x1p_sq)
	var denom: float = rx_sq * y1p_sq + ry_sq * x1p_sq

	var coef: float = 0.0
	if denom != 0.0:
		coef = sign * sqrt(numerator / denom)

	var cxp: float = coef * (rx * y1p / ry)
	var cyp: float = coef * (-ry * x1p / rx)

	var cx: float = cos_phi * cxp - sin_phi * cyp + (p0.x + p1.x) * 0.5
	var cy: float = sin_phi * cxp + cos_phi * cyp + (p0.y + p1.y) * 0.5

	var center: Vector2 = Vector2(cx, cy)

	var v1: Vector2 = Vector2((x1p - cxp) / rx, (y1p - cyp) / ry)
	var v2: Vector2 = Vector2((-x1p - cxp) / rx, (-y1p - cyp) / ry)

	var theta1: float = _vector_angle(v1)
	var delta_theta: float = _vector_angle_between(v1, v2)

	if not sweep and delta_theta > 0.0:
		delta_theta -= TAU
	elif sweep and delta_theta < 0.0:
		delta_theta += TAU

	for s_i in range(1, segments + 1):
		var t: float = float(s_i) / float(segments)
		var theta: float = theta1 + delta_theta * t

		var x: float = rx * cos(theta)
		var y: float = ry * sin(theta)

		var px: float = cos_phi * x - sin_phi * y + center.x
		var py: float = sin_phi * x + cos_phi * y + center.y

		out_pts.append(xform * Vector2(px, py))


static func _vector_angle(v: Vector2) -> float:
	return atan2(v.y, v.x)


static func _vector_angle_between(a: Vector2, b: Vector2) -> float:
	var cross := a.x * b.y - a.y * b.x
	var dot := a.x * b.x + a.y * b.y
	return atan2(cross, dot)


static func _parse_transform(text: String) -> Transform2D:
	var result := Transform2D.IDENTITY
	var s := text.strip_edges()
	if s.is_empty():
		return result

	var re := RegEx.create_from_string(r"([a-zA-Z]+)\s*\(([^)]*)\)")
	for m in re.search_all(s):
		var name := m.get_string(1).to_lower()
		var args := _parse_number_list(m.get_string(2))

		var local := Transform2D.IDENTITY

		match name:
			"matrix":
				if args.size() >= 6:
					local = Transform2D(
						Vector2(args[0], args[1]),
						Vector2(args[2], args[3]),
						Vector2(args[4], args[5])
					)

			"translate":
				var tx := args[0] if args.size() >= 1 else 0.0
				var ty := args[1] if args.size() >= 2 else 0.0
				local = Transform2D.IDENTITY.translated(Vector2(tx, ty))

			"scale":
				var sx := args[0] if args.size() >= 1 else 1.0
				var sy := args[1] if args.size() >= 2 else sx
				local = Transform2D.IDENTITY.scaled(Vector2(sx, sy))

			"rotate":
				if args.size() >= 3:
					var angle := deg_to_rad(args[0])
					var cx := args[1]
					var cy := args[2]
					local = Transform2D.IDENTITY
					local = local.translated(Vector2(cx, cy))
					local = local.rotated(angle)
					local = local.translated(Vector2(-cx, -cy))
				elif args.size() >= 1:
					local = Transform2D.IDENTITY.rotated(deg_to_rad(args[0]))

			"skewx":
				if args.size() >= 1:
					var t := tan(deg_to_rad(args[0]))
					local = Transform2D(Vector2(1, 0), Vector2(t, 1), Vector2.ZERO)

			"skewy":
				if args.size() >= 1:
					var t2 := tan(deg_to_rad(args[0]))
					local = Transform2D(Vector2(1, t2), Vector2(0, 1), Vector2.ZERO)

			_:
				pass

		result = result * local

	return result


static func _parse_number_list(text: String) -> Array[float]:
	var nums: Array[float] = []
	var re := RegEx.create_from_string(r"[-+]?(?:\d*\.\d+|\d+)(?:[eE][-+]?\d+)?")
	for m in re.search_all(text):
		nums.append(_parse_float(m.get_string()))
	return nums


static func _parse_float(text: String) -> float:
	var s := text.strip_edges()
	if s.is_empty():
		return 0.0

	# Trim common suffixes like "px".
	var end := 0
	while end < s.length():
		var ch := s.substr(end, 1)
		if (ch >= "0" and ch <= "9") or ch == "-" or ch == "+" or ch == "." or ch == "e" or ch == "E":
			end += 1
		else:
			break

	if end == 0:
		return 0.0

	return float(s.substr(0, end))


static func _parse_color(text: String) -> Color:
	var s := text.strip_edges().to_lower()
	if s.is_empty() or s == "none":
		return Color.WHITE
	if s.begins_with("#"):
		return Color.html(s)
	return Color.WHITE
