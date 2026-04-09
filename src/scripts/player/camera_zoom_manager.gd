extends Camera2D

const DEFAULT_ZOOM: float = 0.15
const ZOOM_STEP: float = 0.02
const ZOOM_MIN: float = 0.04
const ZOOM_MAX: float = 0.5
const ZOOM_SPEED: float = 10.0
const HOLD_SPEED: float = 0.05  # how fast the target zoom changes while holding

@export var camera_zoom: float = DEFAULT_ZOOM
var target_zoom: float = DEFAULT_ZOOM

func _ready() -> void:
	zoom = Vector2(camera_zoom, camera_zoom)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Camera_Zoom_In"):
		target_zoom = clamp(target_zoom + ZOOM_STEP, ZOOM_MIN, ZOOM_MAX)
	
	if event.is_action_pressed("Camera_Zoom_Out"):
		target_zoom = clamp(target_zoom - ZOOM_STEP, ZOOM_MIN, ZOOM_MAX)

func _process(delta: float) -> void:
	# hold
	if Input.is_action_pressed("Camera_Zoom_In"):
		target_zoom = clamp(target_zoom + HOLD_SPEED * delta, ZOOM_MIN, ZOOM_MAX)
	
	if Input.is_action_pressed("Camera_Zoom_Out"):
		target_zoom = clamp(target_zoom - HOLD_SPEED * delta, ZOOM_MIN, ZOOM_MAX)
	
	camera_zoom = lerp(camera_zoom, target_zoom, 1.0 - exp(-ZOOM_SPEED * delta))
	zoom = Vector2(camera_zoom, camera_zoom)
