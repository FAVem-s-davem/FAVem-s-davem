extends HBoxContainer

var buffer = "command"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_dislpay()
	
func set_msg(msg):
	buffer = msg
	_update_dislpay()
	
func update_buffer(msg):
	set_msg(msg) 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _update_dislpay():
	for child in get_children():
		child.queue_free()
	
	var panel = PanelContainer.new()
	var label = Label.new()
	label.text = buffer
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	panel.add_child(label)
	add_child(panel)
