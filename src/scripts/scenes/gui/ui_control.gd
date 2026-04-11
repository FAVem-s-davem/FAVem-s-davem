extends Control

var has_started_game: bool = false

func _ready():
	$Menu.visible = true
	$Hud.visible = false
	get_node("/root/Main/GameScene").visible = false
	get_tree().paused = true
	# Ensure UI nodes process during pause
	self.process_mode = Control.ProcessMode.PROCESS_MODE_ALWAYS

	$Menu/MainMenu/VBoxContainer/Start.pressed.connect(_on_start_button_pressed)
	$Menu.restart_requested.connect(_on_restart_requested)
	$Menu.set_restart_visible(false)

func _on_start_button_pressed():
	has_started_game = true
	$Menu.visible = false
	$Hud.visible = true
	get_node("/root/Main/GameScene").visible = true
	get_tree().paused = false
	$Menu/MainMenu/VBoxContainer/Start.text = "CONTINUE"
	$Menu.set_restart_visible(false)


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
		

		$Menu/MainMenu/VBoxContainer/Start.grab_focus()
