extends Area2D
class_name Room

@export var room_number: int = -1
@export var room_size: int = -1

# Emits when assigned quest state changes for this room.
signal quest_state_changed(room: Room, quest, is_completed: bool)

# Current quest assigned to this room.
var assigned_quest = null

# Students currently inside this room.
var students_inside: Array[Student] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	monitoring = true
	monitorable = true

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


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
		quest_state_changed.emit(self, assigned_quest, now_completed)
