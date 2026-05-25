extends Control

var has_started_game: bool = false
static var _auto_start: bool = false

@onready var _menu_bg = get_node("/root/Main/MenuBackground")

var _menu_music: AudioStreamPlayer
var _game_music: AudioStreamPlayer
var _music_volume_db: float = 0.0

var _transition_mat: ShaderMaterial
var _transitioning: bool = false

const _IRIS_OPEN: float = 1.5
const _IRIS_CLOSED: float = 0.0
const _IRIS_DURATION: float = 0.3
const _MUSIC_FADE_DURATION: float = 0.5

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

	_menu_music = AudioStreamPlayer.new()
	_menu_music.stream = load("res://assets/music/main_menu_1.mp3")
	add_child(_menu_music)
	_menu_music.finished.connect(func(): _menu_music.play())

	_game_music = AudioStreamPlayer.new()
	_game_music.stream = load("res://assets/music/game_loop_music_v3.mp3")
	add_child(_game_music)
	_game_music.finished.connect(func(): _game_music.play())

	$Menu/Settings.music_volume_changed.connect(_on_music_volume_changed)

	_setup_iris()
	_menu_bg.start()
	_menu_music.play()

	var glm := get_node_or_null("/root/Main/GameScene/GameLoopManager") as GameLoopManager
	if glm != null:
		glm.day_finished.connect(_on_day_finished)

	if _auto_start:
		_auto_start = false
		_on_start_button_pressed()


func _setup_iris() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 10
	layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(layer)

	var rect := ColorRect.new()
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(rect)

	_transition_mat = ShaderMaterial.new()
	_transition_mat.shader = load("res://assets/shaders/iris_wipe.gdshader")
	_transition_mat.set_shader_parameter("radius", _IRIS_OPEN)
	rect.material = _transition_mat


func _iris_close(fade_target: AudioStreamPlayer) -> Tween:
	var tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).set_parallel(true)
	tween.tween_method(
		func(r: float): _transition_mat.set_shader_parameter("radius", r),
		_IRIS_OPEN, _IRIS_CLOSED, _IRIS_DURATION
	).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(fade_target, "volume_db", -80.0, _MUSIC_FADE_DURATION)
	return tween


func _iris_open(fade_target: AudioStreamPlayer) -> Tween:
	var tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).set_parallel(true)
	tween.tween_method(
		func(r: float): _transition_mat.set_shader_parameter("radius", r),
		_IRIS_CLOSED, _IRIS_OPEN, _IRIS_DURATION
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(fade_target, "volume_db", _music_volume_db, _MUSIC_FADE_DURATION)
	return tween


func _on_start_button_pressed():
	if _transitioning:
		return
	_transitioning = true

	await _iris_close(_menu_music).finished

	var first_start := not has_started_game
	has_started_game = true
	_menu_bg.stop()
	_menu_bg.visible = false
	$Menu.visible = false
	$Hud.visible = true
	get_node("/root/Main/GameScene").visible = true
	get_tree().paused = false
	$Menu/MainMenu/PanelContainer/VBoxContainer/Start.text = "CONTINUE"
	$Menu.set_restart_visible(false)
	$Menu.set_pause_mode(false)
	var player_cam := get_node_or_null("/root/Main/GameScene/Player/Camera2D") as Camera2D
	if player_cam != null:
		player_cam.make_current()

	_menu_music.stop()
	_menu_music.volume_db = _music_volume_db
	_game_music.volume_db = -80.0
	if first_start:
		_game_music.play()
	else:
		_game_music.stream_paused = false

	await _iris_open(_game_music).finished
	_transitioning = false


func _on_music_volume_changed(value: float) -> void:
	_music_volume_db = linear_to_db(value / 100.0) if value > 0.0 else -80.0
	if _menu_music.playing:
		_menu_music.volume_db = _music_volume_db
	if _game_music.playing and not _game_music.stream_paused:
		_game_music.volume_db = _music_volume_db


func _on_day_finished() -> void:
	_game_music.stop()
	_menu_music.volume_db = -80.0
	_menu_music.play()
	var tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(_menu_music, "volume_db", _music_volume_db, _MUSIC_FADE_DURATION)


func _on_restart_requested() -> void:
	get_tree().paused = false
	_auto_start = true
	get_tree().reload_current_scene()


func _input(event):
	if _transitioning:
		return
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

	# Hra běží → otevřít menu (pauza)
	_transitioning = true

	await _iris_close(_game_music).finished

	_game_music.stream_paused = true
	_game_music.volume_db = _music_volume_db
	$Menu.visible = true
	$Hud.visible = false
	$Menu/MainMenu.visible = true
	$Menu/About.visible = false
	$Menu/Settings.visible = false
	$Menu.set_pause_mode(true)
	get_node("/root/Main/GameScene").visible = false
	get_tree().paused = true
	$Menu.set_restart_visible(has_started_game)
	_menu_bg.visible = true
	_menu_bg.start()
	$Menu/MainMenu/PanelContainer/VBoxContainer/Start.grab_focus()

	await _iris_open(_menu_music).finished  # menu hudba nehraje během pauzy, takže se iris jen otevře
	_transition_mat.set_shader_parameter("radius", _IRIS_OPEN)
	_transitioning = false
