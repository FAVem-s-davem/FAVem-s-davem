extends Panel

var buffer = ""
var macro = ""
var command_lbl: Label
var macro_lbl: Label
var background: ColorRect
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	command_lbl = get_node("MarginContainer/HBoxContainer/Command") as Label
	command_lbl.text = buffer
	
	macro_lbl = get_node("MarginContainer/HBoxContainer/Macro") as Label
	
	background = get_node("ColorRect") as ColorRect
	
	_update_display()
	
	
func command_success():
	print("success")
	if background != null:
		background.color = Color.GREEN
		background.color.a = 0.8
		
func command_clear():
	print("clear")
	if background != null:
		background.color = Color.BLACK
		background.color.a = 0.8
		
func command_invalid():
	print("invalid")
	if background != null:
		background.color = Color.RED
		background.color.a = 0.8
	
func set_macro(m):
	if m == "":
		macro = m
	else:
		macro = "Recording: " + m
	_update_display()
	

func set_msg(msg):
	buffer = msg
	_update_display()
	
func update_buffer(msg):
	set_msg(msg) 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func command_passed() -> void:
	pass

func _update_display():
	if command_lbl != null:
		command_lbl.text = buffer
		
	if macro_lbl != null:
		macro_lbl.text = macro
