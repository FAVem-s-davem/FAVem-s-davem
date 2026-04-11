extends PanelContainer
class_name QuestBoard

const ROOM_NAME_PANEL_SCENE: PackedScene = preload("res://scenes/gui/hud/quest_board/room_name_panel.tscn")
const ICON_PANEL_SCENE: PackedScene = preload("res://scenes/gui/hud/quest_board/icon_panel.tscn")

@onready var quest_grid: GridContainer = $VBoxContainer/quest_grid

var game_scene: GameScene
var quest_manager: QuestManager


func _ready() -> void:
	_resolve_scene_and_manager()
	_build_board()


func _resolve_scene_and_manager() -> void:
	game_scene = get_tree().root.get_node_or_null("Main/GameScene") as GameScene
	if game_scene == null:
		push_error("QuestBoard: GameScene not found at Main/GameScene")
		return

	quest_manager = game_scene.get_node_or_null("QuestManager") as QuestManager
	if quest_manager == null:
		push_error("QuestBoard: QuestManager not found under GameScene")


func _build_board() -> void:
	if quest_grid == null:
		return
	if quest_manager == null:
		return

	for child in quest_grid.get_children():
		child.queue_free()

	quest_grid.columns = max(1, quest_manager.quests_in_timetable + 1)

	for timetable in quest_manager.timetables:
		_add_room_name_cell(timetable.room)
		_add_quest_cells_for_timetable(timetable)


func _add_room_name_cell(room: Room) -> void:
	var panel := ROOM_NAME_PANEL_SCENE.instantiate() as PanelContainer
	if panel == null:
		return

	var label := panel.get_node_or_null("Label") as Label
	if label != null:
		if room != null:
			label.text = str(room.name)
		else:
			label.text = "<No Room>"

	quest_grid.add_child(panel)


func _add_quest_cells_for_timetable(timetable) -> void:
	for i in range(quest_manager.quests_in_timetable):
		var panel := ICON_PANEL_SCENE.instantiate() as PanelContainer
		if panel == null:
			continue

		if i < timetable.quests.size():
			var quest = timetable.quests[i]
			_apply_quest_to_icon_panel(panel, quest)
			var callback := _on_quest_completed_changed.bind(panel)
			if not quest.completed_changed.is_connected(callback):
				quest.completed_changed.connect(callback)
		else:
			_apply_empty_panel(panel)

		quest_grid.add_child(panel)


func _apply_quest_to_icon_panel(panel: PanelContainer, quest) -> void:
	var icon_count := panel.get_node_or_null("VBoxContainer/IconCount") as Label
	var icon := panel.get_node_or_null("VBoxContainer/Icon") as TextureRect

	if icon_count != null:
		icon_count.text = str(quest.required_count)

	if icon != null:
		icon.texture = _get_texture_for_type(quest.required_student_type)

	_set_panel_completed_style(panel, quest.is_completed)


func _apply_empty_panel(panel: PanelContainer) -> void:
	var icon_count := panel.get_node_or_null("VBoxContainer/IconCount") as Label
	var icon := panel.get_node_or_null("VBoxContainer/Icon") as TextureRect

	if icon_count != null:
		icon_count.text = "-"

	if icon != null:
		icon.texture = null

	_set_panel_background_color(panel, Color(0.35, 0.35, 0.35, 0.8))


func _get_texture_for_type(student_type: int) -> Texture2D:
	var info := StudentTypes.get_type_info(student_type, 1)
	if info == null:
		return null
	return load(info.icon_path) as Texture2D


func _on_quest_completed_changed(_quest, is_completed: bool, panel: PanelContainer) -> void:
	_set_panel_completed_style(panel, is_completed)


func _set_panel_completed_style(panel: PanelContainer, is_completed: bool) -> void:
	if is_completed:
		_set_panel_background_color(panel, Color(0.55, 1.0, 0.55, 1.0))
	else:
		panel.remove_theme_stylebox_override("panel")


func _set_panel_background_color(panel: PanelContainer, color: Color) -> void:
	var style := panel.get_theme_stylebox("panel")
	var flat := style as StyleBoxFlat

	if flat == null:
		flat = StyleBoxFlat.new()
	else:
		flat = flat.duplicate() as StyleBoxFlat

	flat.bg_color = color
	panel.add_theme_stylebox_override("panel", flat)
