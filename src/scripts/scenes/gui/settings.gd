extends Control

signal back_pressed
signal music_volume_changed(value: float)

const _MSAA_VALUES = [
	Viewport.MSAA_DISABLED,
	Viewport.MSAA_2X,
	Viewport.MSAA_4X,
	Viewport.MSAA_8X,
]
const _RESOLUTIONS = [Vector2i(960, 540), Vector2i(1440, 810), Vector2i(1920, 1080)]

func _ready() -> void:
	$PanelContainer/MarginContainer/VBoxContainer/Back.pressed.connect(func(): back_pressed.emit())

	var slider := $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/HSlider as HSlider
	slider.value_changed.connect(func(v: float): music_volume_changed.emit(v))

	var fullscreen := $PanelContainer/MarginContainer/VBoxContainer/HBoxFullscreen/FullscreenToggle as CheckBox
	fullscreen.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	fullscreen.toggled.connect(_on_fullscreen_toggled)

	var vsync := $PanelContainer/MarginContainer/VBoxContainer/HBoxVSync/VSyncToggle as CheckBox
	vsync.button_pressed = DisplayServer.window_get_vsync_mode() != DisplayServer.VSYNC_DISABLED
	vsync.toggled.connect(_on_vsync_toggled)

	var msaa := $PanelContainer/MarginContainer/VBoxContainer/HBoxMSAA/AntialiasingOption as OptionButton
	msaa.add_item("Off")
	msaa.add_item("2×")
	msaa.add_item("4×")
	msaa.add_item("8×")
	msaa.selected = 0
	msaa.item_selected.connect(_on_msaa_changed)

	var res := $PanelContainer/MarginContainer/VBoxContainer/HBoxResolution/ResolutionOption as OptionButton
	res.add_item("50%")
	res.add_item("75%")
	res.add_item("100%")
	res.selected = 2
	res.item_selected.connect(_on_resolution_changed)


func _on_fullscreen_toggled(pressed: bool) -> void:
	if pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_vsync_toggled(pressed: bool) -> void:
	if pressed:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)


func _on_msaa_changed(index: int) -> void:
	get_viewport().msaa_2d = _MSAA_VALUES[index]


func _on_resolution_changed(index: int) -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		return
	DisplayServer.window_set_size(_RESOLUTIONS[index])
