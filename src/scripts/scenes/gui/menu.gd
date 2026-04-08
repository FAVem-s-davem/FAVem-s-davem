extends Control



func _ready():
	# Connect menu navigation buttons
	$MainMenu/VBoxContainer/About.pressed.connect(_on_about_pressed)
	$About/Back.pressed.connect(_on_about_back_pressed)

	# Set up focus for About menu
	$About/Back.focus_mode = Control.FOCUS_ALL

	# Ensure MainMenu is visible and grab focus for Start button
	$MainMenu.visible = true
	$About.visible = false
	await get_tree().process_frame
	$MainMenu/VBoxContainer/Start.grab_focus()

func _on_about_pressed():
	$MainMenu.visible = false
	$About.visible = true
	await get_tree().process_frame
	$About/Back.grab_focus()

func _on_about_back_pressed():
	$About.visible = false
	$MainMenu.visible = true
	await get_tree().process_frame
	$MainMenu/VBoxContainer/Start.grab_focus()
