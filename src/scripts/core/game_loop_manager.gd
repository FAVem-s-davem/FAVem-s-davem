extends Node
class_name GameLoopManager

signal day_finished

# Main day loop phases.
enum LoopPhase {
	PREPARATION,
	QUEST,
	END_COUNTDOWN,
	FINISHED,
}

@export var preparation_duration: float = 15.0
@export var quest_phase_duration: float = 45.0
@export var end_countdown_duration: float = 5.0

# References resolved from the running scene.
var game_scene: GameScene
var quest_manager: QuestManager
var phase_label: Label

# Runtime state.
var current_phase: int = LoopPhase.PREPARATION
var current_quest_index: int = -1
var phase_time_left: float = 0.0
var is_initialized: bool = false


func initialize(scene: GameScene) -> void:
	# Bind scene references and start from preparation.
	game_scene = scene
	quest_manager = scene.quest_manager as QuestManager
	phase_label = scene.get_node_or_null("../CanvasLayer/Control/Hud/GamePhase") as Label

	if quest_manager == null:
		push_error("GameLoopManager: QuestManager not available")
		return

	is_initialized = true
	_start_preparation_phase()


func _process(delta: float) -> void:
	# Tick timer and switch phases when time runs out.
	if not is_initialized:
		return
	if current_phase == LoopPhase.FINISHED:
		return

	phase_time_left -= delta
	_update_phase_label()

	if phase_time_left > 0.0:
		return
	
	_end_phase()

	match current_phase:
		LoopPhase.PREPARATION:
			_start_quest_phase(0)
		LoopPhase.QUEST:
			if current_quest_index + 1 < quest_manager.quests_in_timetable:
				_start_quest_phase(current_quest_index + 1)
			else:
				_start_end_countdown_phase()
		LoopPhase.END_COUNTDOWN:
			_finish_day()

func _end_phase() -> void:
	if current_phase == LoopPhase.QUEST:
		for timetable in quest_manager.timetables:
			timetable.get_active_quest().complete();

func _start_preparation_phase() -> void:
	# Intro window before quests start.
	current_phase = LoopPhase.PREPARATION
	current_quest_index = -1
	phase_time_left = preparation_duration
	_update_phase_label()


func _start_quest_phase(quest_index: int) -> void:
	# Activate a specific quest index for all timetables.
	current_phase = LoopPhase.QUEST
	current_quest_index = quest_index
	phase_time_left = quest_phase_duration

	_activate_quest_phase(quest_index)
	_update_phase_label()


func _start_end_countdown_phase() -> void:
	# Final countdown after all quest phases are done.
	current_phase = LoopPhase.END_COUNTDOWN
	phase_time_left = end_countdown_duration
	_update_phase_label()


func _activate_quest_phase(quest_index: int) -> void:
	# Assign this quest in every timetable.
	for i in range(quest_manager.timetables.size()):
		quest_manager.assign_quest(i, quest_index)

	# Spawn students based on currently active quests.
	game_scene.spawn_students_for_active_quests()


func _finish_day() -> void:
	# Lock phase and show end screen UI.
	current_phase = LoopPhase.FINISHED
	phase_time_left = 0.0
	_update_phase_label()
	day_finished.emit()
	_show_game_end_screen()


func _show_game_end_screen() -> void:
	# Hide gameplay and show GameEnd panel.
	var ui_root := get_tree().root.get_node_or_null("Main/CanvasLayer/Control") as Control
	var scene_root := get_tree().root.get_node_or_null("Main/GameScene") as CanvasItem
	if ui_root == null:
		push_error("GameLoopManager: UI root not found")
		return

	var menu := ui_root.get_node_or_null("Menu") as Control
	var hud := ui_root.get_node_or_null("Hud") as Control

	if hud != null:
		hud.visible = false

	# Hide gameplay world so map/camera state is not visible behind menu.
	if scene_root != null:
		scene_root.visible = false

	if menu != null:
		menu.visible = true
		if menu.has_node("MainMenu"):
			menu.get_node("MainMenu").visible = false
		if menu.has_node("About"):
			menu.get_node("About").visible = false
		if menu.has_node("Settings"):
			menu.get_node("Settings").visible = false
		if menu.has_node("GameEnd"):
			menu.get_node("GameEnd").visible = true

	get_tree().paused = true


func _update_phase_label() -> void:
	# Display current phase and remaining time on HUD.
	if phase_label == null:
		return

	var seconds_left := int(ceil(maxf(phase_time_left, 0.0)))

	match current_phase:
		LoopPhase.PREPARATION:
			phase_label.text = "Preparation: %ds" % seconds_left
		LoopPhase.QUEST:
			phase_label.text = "%d. quest phase: %ds" % [current_quest_index + 1, seconds_left]
		LoopPhase.END_COUNTDOWN:
			phase_label.text = "Day ending in: %ds" % seconds_left
		LoopPhase.FINISHED:
			phase_label.text = "Day ended"
