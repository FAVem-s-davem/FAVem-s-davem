extends Control

signal restart_requested



func _ready():
	# grab focus for keyboard navigation
	$MainMenu/PanelContainer/VBoxContainer/Start.grab_focus()

	# Connect menu navigation buttons
	$MainMenu/PanelContainer/VBoxContainer/Settings.pressed.connect(_on_settings_pressed)
	$MainMenu/PanelContainer/VBoxContainer/About.pressed.connect(_on_about_pressed)
	$MainMenu/PanelContainer/VBoxContainer/Quit.pressed.connect(_on_quit_pressed)
	$MainMenu/PanelContainer/VBoxContainer/Restart.pressed.connect(_on_restart_pressed)
	$GameEnd/BackToMenu.pressed.connect(_on_restart_pressed)

	$About/PanelContainer/MarginContainer/VBoxContainer/Back.pressed.connect(_on_back_pressed)
	$Settings.back_pressed.connect(_on_back_pressed)

func _on_quit_pressed():
	get_tree().quit()


func _on_restart_pressed() -> void:
	restart_requested.emit()

func _on_about_pressed():
	$MainMenu.visible = false
	$About.visible = true
	await get_tree().process_frame
	$About/PanelContainer/MarginContainer/VBoxContainer/Back.grab_focus()

func _on_settings_pressed():
	$MainMenu.visible = false
	$Settings.visible = true
	await get_tree().process_frame
	$Settings/PanelContainer/MarginContainer/VBoxContainer/Back.grab_focus()

func _on_back_pressed():
	$About.visible = false
	$Settings.visible = false
	$MainMenu.visible = true
	await get_tree().process_frame
	$MainMenu/PanelContainer/VBoxContainer/Start.grab_focus()


# Controls visibility of Restart button in main menu.
func set_restart_visible(value: bool) -> void:
	if has_node("MainMenu/PanelContainer/VBoxContainer/Restart"):
		$MainMenu/PanelContainer/VBoxContainer/Restart.visible = value

func set_pause_mode(paused: bool) -> void:
	$MainMenu/LogoContainer.visible = not paused
	$MainMenu/PauzaLabel.visible = paused
