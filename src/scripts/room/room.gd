extends Area2D
class_name Room

@export var room_number: int = -1
@export var room_size: int = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _on_body_entered(body: Node2D) -> void:
	print("Body entered:", body.name)

func _on_body_exited(body: Node2D) -> void:
	print("Body exited:", body.name)

func _on_area_entered(area: Area2D) -> void:
	print("Area entered:", area.name)

func _on_area_exited(area: Area2D) -> void:
	print("Area exited:", area.name)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
