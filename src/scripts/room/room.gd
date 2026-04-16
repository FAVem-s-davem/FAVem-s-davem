extends Area2D
class_name Room

@export var room_size: int = -1

# Emits when assigned quest state changes for this room.
signal quest_state_changed(room: Room, quest, is_completed: bool)

# Current quest assigned to this room.
var assigned_quest = null

# Students currently inside this room.
var students_inside: Array[Student] = []

func _process(_delta):
	queue_redraw()

func _draw() -> void:
	
	var poly_node := get_node_or_null("CollisionPolygon2D") as CollisionPolygon2D
	if poly_node == null:
		return

	var polygon: PackedVector2Array = poly_node.polygon
	if polygon.is_empty():
		return

	# --- Use bounding box center (better for rooms) ---
	var rect := Rect2(polygon[0], Vector2.ZERO)
	for p in polygon:
		rect = rect.expand(p)

	var center := poly_node.position + rect.get_center()

	# --- Draw room name ---
	var font = ThemeDB.fallback_font

	var text := name

	var main_size = 350
	var outline_size = main_size + 20

	# Measure using main size
	var text_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, main_size)
	var ascent = font.get_ascent(main_size)
	var descent = font.get_descent(main_size)

	var text_height = ascent + descent
	var base_pos = center - Vector2(text_size.x / 2.0, text_height / 2.0 - ascent)

	# --- Draw main text ---
	draw_string(
		font,
		base_pos,
		text,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		main_size,
		Color.BLACK
	)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	monitoring = true
	monitorable = true

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	var poly_node := get_node_or_null("CollisionPolygon2D") as CollisionPolygon2D
	if poly_node == null:
		return
	poly_node.visible = false


# Assigns (or replaces) current quest for this room.
func assign_quest(quest) -> void:
	assigned_quest = quest
	_recheck_assigned_quest()

func _on_body_entered(body: Node2D) -> void:
	print("body " + body.name + " entered" + self.name)
	var student := body as Student
	if student == null:
		return

	if not students_inside.has(student):
		students_inside.append(student)

	_recheck_assigned_quest()

func _on_body_exited(body: Node2D) -> void:
	var student := body as Student
	if student == null:
		return

	students_inside.erase(student)
	_recheck_assigned_quest()


# Returns a copy of current students in this room.
func get_students_inside() -> Array[Student]:
	return students_inside.duplicate()


# Checks quest completion state from current room contents.
func _recheck_assigned_quest() -> void:
	if assigned_quest == null:
		return

	var was_completed: bool = assigned_quest.is_completed
	var now_completed: bool = assigned_quest.matches_students(students_inside)

	assigned_quest.set_completed(now_completed)

	if was_completed != now_completed:
		var type_name := StudentTypes.type_name_to_string(assigned_quest.required_student_type)
		if now_completed:
			print("[Quest] COMPLETED in room '%s': type=%s, count=%d" % [
				name,
				type_name,
				assigned_quest.required_count
			])
		else:
			print("[Quest] INVALIDATED in room '%s': type=%s, count=%d" % [
				name,
				type_name,
				assigned_quest.required_count
			])

		quest_state_changed.emit(self, assigned_quest, now_completed)
