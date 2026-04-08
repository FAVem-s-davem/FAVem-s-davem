extends VBoxContainer

# Dictionary to store hints: { "hint_key": "hint_text", ... }
var hints: Dictionary = {
  "a": "Select",
  "A": "Append to selected",
  "q": "record macro",
  "@": "run macro",
  "m": "make a marker",
  "g": "go to marker",
  "s": "send selected to marker", 
  "d": "deselect",
  "D": "deselect all"
}

func _ready():
	_update_display()
	pass

# Set hints from a dictionary of string:string pairs
func set_hints(new_hints: Dictionary):
	hints = new_hints
	_update_display()

# Clear all hints
func clear_hints():
	hints.clear()
	_update_display()

# Update the visual display of all hints
func _update_display():
	# Clear existing child nodes (labels)
	for child in get_children():
		child.queue_free()
	
	# Create a label for each hint
	for key in hints.keys():
		var panel = PanelContainer.new()
		var label = Label.new()
		label.text = "[ %s ]: %s" % [key, hints[key]]
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		panel.add_child(label)
		add_child(panel)
