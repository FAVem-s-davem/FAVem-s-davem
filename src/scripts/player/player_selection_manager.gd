## Handles drag-selection of students
## Draw a box to select multiple units
extends Node2D

var player: Player
var selection: SelectionManager

var dragging: bool = false
var drag_start: Vector2 = Vector2.ZERO
var drag_end: Vector2 = Vector2.ZERO


func _ready() -> void:
	player = get_parent()
	
	if player != null and player.has_method("get_selection"):
		selection = player.get_selection()
	
	set_process_input(true)


func _input(event: InputEvent) -> void:
	var mb = event as InputEventMouseButton
	"""
	if mb != null:
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				dragging = true
				drag_start = get_global_mouse_position()
			else:
				dragging = false
				drag_end = get_global_mouse_position()
				
				# Create selection rect
				var rect = Rect2(drag_start, drag_end - drag_start)
				rect = rect.abs()
				
				# Get all students in the rect
				var units = _get_units_inside(player.global_position, player.deselect_ring)
				
				# Check if shift is pressed for additive selection
				var shift_pressed = Input.is_key_pressed(KEY_SHIFT)
				
				if selection != null:
					if shift_pressed:
						selection.add(units)
					else:
						selection.select(units)
				
				queue_redraw()
	"""
	var mm = event as InputEventMouseMotion
	
	if mm != null and dragging:
		drag_end = get_global_mouse_position()
		queue_redraw()


func _draw() -> void:
	if not dragging:
		return
	
	var local_start = to_local(drag_start)
	var local_end = to_local(drag_end)
	
	var rect = Rect2(local_start, local_end - local_start)
	rect = rect.abs()
	
	draw_rect(rect, Color(0, 1, 0, 0.2), true)
	draw_rect(rect, Color(0, 1, 0), false, 2.0)


## Get all selectable units within the given rectangle
func _get_units_inside(center: Vector2, radius: float) -> Array[Node2D]:
	var units: Array[Node2D] = []
	
	var all_nodes = get_tree().get_nodes_in_group("selectable_units")
	
	for node in all_nodes:
		if node is Node2D:
			var global_pos = node.global_position
			
			if global_pos.distance_to(center) <= radius:
				units.append(node)
	
	return units
