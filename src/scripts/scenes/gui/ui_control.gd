extends Control

var has_started_game: bool = false

@onready var _menu_bg = get_node("/root/Main/MenuBackground")

func _ready():
	$Menu.visible = true
	$Hud.visible = false
	get_node("/root/Main/GameScene").visible = false
	get_tree().paused = true
	# Ensure UI nodes process during pause
	self.process_mode = Control.ProcessMode.PROCESS_MODE_ALWAYS

	$Menu/MainMenu/PanelContainer/VBoxContainer/Start.pressed.connect(_on_start_button_pressed)
	$Menu.restart_requested.connect(_on_restart_requested)
	$Menu.set_restart_visible(false)

	_menu_bg.start()

func _on_start_button_pressed():
	has_started_game = true
	_menu_bg.stop()
	$Menu.visible = false
	$Hud.visible = true
	get_node("/root/Main/GameScene").visible = true
	get_tree().paused = false
	$Menu/MainMenu/PanelContainer/VBoxContainer/Start.text = "CONTINUE"
	$Menu.set_restart_visible(false)
	# Hand camera back to the player
	var player_cam := get_node_or_null("/root/Main/GameScene/Player/Camera2D") as Camera2D
	if player_cam != null:
		player_cam.make_current()


func _on_restart_requested() -> void:
	# Must unpause first so reload can proceed cleanly.
	get_tree().paused = false
	get_tree().reload_current_scene()

func _input(event):
	# pausing the game, going to menu
	if event.is_action_pressed("ui_cancel"):
		$Menu.visible = true
		$Hud.visible = false

		# in case esc pressed from about/settings menu
		$Menu/MainMenu.visible = true
		$Menu/About.visible = false
		$Menu/Settings.visible = false

		get_node("/root/Main/GameScene").visible = false
		get_tree().paused = true
		$Menu.set_restart_visible(has_started_game)
		_menu_bg.start()

		$Menu/MainMenu/PanelContainer/VBoxContainer/Start.grab_focus()
