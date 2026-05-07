extends Control

var has_started_game: bool = false
static var _auto_start: bool = false

@onready var _menu_bg = get_node("/root/Main/MenuBackground")

var _music: AudioStreamPlayer

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

	_music = AudioStreamPlayer.new()
	_music.stream = load("res://assets/music/game_loop_music.mp3")
	_music.autoplay = false
	add_child(_music)
	_music.finished.connect(_on_music_finished)

	var slider := $Menu/Settings/VBoxContainer/HBoxContainer/HSlider as HSlider
	slider.value_changed.connect(_on_music_volume_changed)

	_menu_bg.start()

	if _auto_start:
		_auto_start = false
		_on_start_button_pressed()


func _on_start_button_pressed():
	has_started_game = true
	_menu_bg.stop()
	_menu_bg.visible = false
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
	_music.stream_paused = false
	if not _music.playing:
		_music.play()


func _on_music_volume_changed(value: float) -> void:
	_music.volume_db = linear_to_db(value / 100.0) if value > 0.0 else -80.0


func _on_music_finished() -> void:
	if not get_tree().paused:
		_music.play()


func _on_restart_requested() -> void:
	get_tree().paused = false
	_auto_start = true
	get_tree().reload_current_scene()

func _input(event):
	if not event.is_action_pressed("ui_cancel"):
		return

	if $Menu.visible:
		# ESC v submenu → zpět na hlavní menu
		if not $Menu/MainMenu.visible:
			$Menu/MainMenu.visible = true
			$Menu/About.visible = false
			$Menu/Settings.visible = false
			$Menu/MainMenu/PanelContainer/VBoxContainer/Start.grab_focus()
			return
		# ESC na hlavním menu → zpět do hry (jen pokud už hra běžela)
		if has_started_game:
			_on_start_button_pressed()
		return

	# Hra běží → otevřít menu
	$Menu.visible = true
	$Hud.visible = false
	$Menu/MainMenu.visible = true
	$Menu/About.visible = false
	$Menu/Settings.visible = false
	get_node("/root/Main/GameScene").visible = false
	get_tree().paused = true
	$Menu.set_restart_visible(has_started_game)
	_menu_bg.visible = true
	_menu_bg.start()
	_music.stream_paused = true
	$Menu/MainMenu/PanelContainer/VBoxContainer/Start.grab_focus()
