extends Node

class_name InputHandler

signal command_executed(command)

var input_buffer := ""
var buffer_timer := 0.0
var buffer_timeout := 0.7
var parser = CommandParser.new()

func _input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		var keycode = event.keycode

		# Check if alphanumeric
		var is_letter = keycode >= KEY_A and keycode <= KEY_Z
		var is_number = keycode >= KEY_0 and keycode <= KEY_9

		if not (is_letter or is_number):
			return

		var key = OS.get_keycode_string(keycode)

		# Force lowercase unless shift is pressed
		if is_letter:
			if event.shift_pressed:
				key = key.to_upper()
			else:
				key = key.to_lower()
				
		if key.to_lower() in ["h", "j", "k", "l"]:
			return

		input_buffer += key
		buffer_timer = buffer_timeout
		
		print(input_buffer)

		var result = parser.feed(key)
		
func parse_buffer():
	match input_buffer:
		"dd":
			emit_signal("command_executed", "delete_line")
			clear_buffer()

		"gg":
			emit_signal("command_executed", "go_top")
			clear_buffer()

		"yw":
			emit_signal("command_executed", "yank_word")
			clear_buffer()
			
			
func _process(delta):
	if buffer_timer > 0:
		buffer_timer -= delta
		if buffer_timer <= 0:
			clear_buffer()

func clear_buffer():
	input_buffer = ""
	parser.reset()
