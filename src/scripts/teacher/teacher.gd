extends CharacterBody2D

@export var range: float = 200.0

var quest: Quest = Quest.new()
var spawner: Spawner

var detection_area: Area2D

func _ready() -> void:
	detection_area = get_node_or_null("DetectionArea") as Area2D
	
	if detection_area == null:
		push_warning("DetectionArea not found!")
		return
	
	var shape_node := detection_area.get_node("CollisionShape2D") as CollisionShape2D
	var shape := shape_node.shape as CircleShape2D
	
	if shape:
		shape.radius = range
	
	detection_area.body_entered.connect(_on_body_entered)

	queue_redraw()


func _on_body_entered(body: Node2D) -> void:
	if body == null:
		return
	
	var student := body as CharacterBody2D
	if student == null or not student.is_in_group("collectable"):
		return
	
	# Prevent double processing
	if student.has_meta("collected"):
		return
	student.set_meta("collected", true)

	var dept: int = student.dept
	var spec: int = student.spec

	# Try to register student
	if not quest.register_student(dept, spec):
		print("Student not needed!")
		return

	print("Accepted: ",
		StudentTypes.dept_name_to_string(dept), " / ",
		StudentTypes.spec_name_to_string(spec)
	)

	student.deselected.emit()
	student.queue_free()

	# Check completion
	if quest.is_complete():
		print("Quest complete!")
		queue_free()
	queue_redraw()


func _draw() -> void:
	# Draw detection radius
	draw_circle(Vector2.ZERO, range, Color(0.9, 0.9, 0.9), false, 2.0)

	# Draw quest text
	var text := quest.get_description()

	if text == "":
		return

	var font := ThemeDB.fallback_font
	var font_size := 16

	var text_size := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)

	var pos := Vector2(
		-text_size.x / 2,
		-range - 10
	)

	draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.WHITE)
