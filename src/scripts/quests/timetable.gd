extends RefCounted
class_name Timetable

# Emits when a quest is assigned to a room.
signal quest_assigned(room: Room, quest)

# Max number of quests stored in this timetable.
var quests_in_timetable: int = 3

# Target room for this timetable.
var room: Room = null

# Quest list for this timetable.
var quests: Array = []

# Current active quest index in quests.
var active_quest_index: int = -1


func _init(max_quests: int = 3) -> void:
	quests_in_timetable = max(1, max_quests)


# Sets which room this timetable controls.
func assign_room(target_room: Room) -> void:
	room = target_room


# Adds a quest if timetable has capacity.
func add_quest(quest) -> bool:
	if quest == null:
		return false
	if quests.size() >= quests_in_timetable:
		return false

	quests.append(quest)
	return true


# Assigns quest by index or cycles to next if index is -1.
func assign_quest(index: int = -1):
	if room == null:
		return null
	if quests.is_empty():
		return null

	if index < 0:
		active_quest_index = (active_quest_index + 1) % quests.size()
	else:
		if index >= quests.size():
			return null
		active_quest_index = index

	var quest = quests[active_quest_index]
	room.assign_quest(quest)
	quest_assigned.emit(room, quest)
	return quest


# Returns active quest or null.
func get_active_quest():
	if active_quest_index < 0 or active_quest_index >= quests.size():
		return null
	return quests[active_quest_index]
