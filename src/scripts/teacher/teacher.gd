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

	var type: int = student.student_type

	if quest.counts[type] > 0:
		quest.counts[type] -= 1

		print("Collected type ", type, " remaining: ", quest.counts[type])

		student.deselected.emit()
		student.queue_free()
	else:
		print("Type not needed!")
		return

	# Check completion
	if quest.is_complete():
		print("Quest complete!")
		queue_free()


func _draw() -> void:
	draw_circle(Vector2.ZERO, range, Color(0.9, 0.9, 0.9), false, 2.0)
