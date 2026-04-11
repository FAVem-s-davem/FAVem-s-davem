extends Control

signal restart_requested



func _ready():
	# grab focus for keyboard navigation
	$MainMenu/VBoxContainer/Start.grab_focus()

	# Connect menu navigation buttons
	$MainMenu/VBoxContainer/Settings.pressed.connect(_on_settings_pressed)
	$MainMenu/VBoxContainer/About.pressed.connect(_on_about_pressed)
	$MainMenu/VBoxContainer/Quit.pressed.connect(_on_quit_pressed)
	if has_node("MainMenu/VBoxContainer/Restart"):
		$MainMenu/VBoxContainer/Restart.pressed.connect(_on_restart_pressed)

	$About/Back.pressed.connect(_on_back_pressed)
	$Settings/VBoxContainer/Back.pressed.connect(_on_back_pressed)

func _on_quit_pressed():
	get_tree().quit()


func _on_restart_pressed() -> void:
	restart_requested.emit()

func _on_about_pressed():
	$MainMenu.visible = false
	$About.visible = true
	await get_tree().process_frame
	$About/Back.grab_focus()

func _on_settings_pressed():
	$MainMenu.visible = false
	$Settings.visible = true
	await get_tree().process_frame
	$Settings/VBoxContainer/Back.grab_focus()

func _on_back_pressed():
	$About.visible = false
	$Settings.visible = false
	$MainMenu.visible = true
	await get_tree().process_frame
	$MainMenu/VBoxContainer/Start.grab_focus()


# Controls visibility of Restart button in main menu.
func set_restart_visible(value: bool) -> void:
	if has_node("MainMenu/VBoxContainer/Restart"):
		$MainMenu/VBoxContainer/Restart.visible = value
