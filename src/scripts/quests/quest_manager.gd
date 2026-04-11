extends Node
class_name QuestManager

const QuestScript = preload("res://scripts/quests/quest.gd")
const TimetableScript = preload("res://scripts/quests/timetable.gd")

# Number of timetables managed by this manager.
@export var number_of_timetables: int = 5

# Maximum quests in each timetable.
@export var quests_in_timetable: int = 3

# Optional upper bound for generated student count per quest.
@export var max_students_per_quest: int = 4

# All managed timetables.
var timetables: Array = []


func _ready() -> void:
	randomize()


# Builds timetables for rooms and assigns initial quests.
func initialize_for_rooms(rooms: Array[Room]) -> void:
	timetables.clear()

	if rooms.is_empty():
		push_warning("QuestManager: No rooms passed for timetable initialization")
		return

	var count: int = min(number_of_timetables, rooms.size())

	for i in range(count):
		var room := rooms[i]
		var timetable = TimetableScript.new(quests_in_timetable)
		timetable.assign_room(room)

		_generate_default_quests(timetable, room)
		timetable.assign_quest(0)

		timetables.append(timetable)

	print("QuestManager: Initialized %d timetable(s)" % timetables.size())
	_print_quests_by_room()


# Assigns the next (or specific) quest for a timetable/room index.
func assign_quest(timetable_index: int, quest_index: int = -1):
	if timetable_index < 0 or timetable_index >= timetables.size():
		push_warning("QuestManager: timetable index out of range: %d" % timetable_index)
		return null

	return timetables[timetable_index].assign_quest(quest_index)


# Returns current active quest for timetable index.
func get_active_quest(timetable_index: int):
	if timetable_index < 0 or timetable_index >= timetables.size():
		return null
	return timetables[timetable_index].get_active_quest()


# Creates starter quests for a timetable.
func _generate_default_quests(timetable, room: Room) -> void:
	var type_values: Array = StudentTypes.Type.values()
	var max_count_for_room := max_students_per_quest

	if room.room_size > 0:
		max_count_for_room = min(max_students_per_quest, room.room_size)

	for _i in range(quests_in_timetable):
		var required_type: int = type_values[randi() % type_values.size()]
		var required_count: int = randi_range(1, max(1, max_count_for_room))
		var quest = QuestScript.new(required_type, required_count)
		timetable.add_quest(quest)


# Prints all quests grouped by room.
func _print_quests_by_room() -> void:
	for timetable in timetables:
		var room: Room = timetable.room
		if room == null:
			print("[Quests] <no room assigned>")
			continue

		print("[Quests] Room '%s'" % [room.name])

		for i in range(timetable.quests.size()):
			var quest = timetable.quests[i]
			var type_name := StudentTypes.type_name_to_string(quest.required_student_type)
			print("  - Q%d: type=%s, count=%d, completed=%s" % [
				i,
				type_name,
				quest.required_count,
				str(quest.is_completed)
			])
