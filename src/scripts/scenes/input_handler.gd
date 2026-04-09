extends Node

class_name InputHandler

signal command_executed(command)

var input_buffer := ""
var buffer_timer := 0.0
var buffer_timeout := 2.0
var parser: CommandParser
var parent: GameScene

func _init(_parent: GameScene) -> void:
	parent = _parent
	parser = parent.parser

func _input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		var keycode = event.keycode

		var is_letter = keycode >= KEY_A and keycode <= KEY_Z
		var is_number = keycode >= KEY_0 and keycode <= KEY_9
		var is_at = char(event.unicode) == "@"

		if not (is_letter or is_number or is_at):
			return

		var key = OS.get_keycode_string(keycode)

		if is_letter:
			key = key.to_upper() if event.shift_pressed else key.to_lower()
		if is_at:
			key = "@" if event.shift_pressed else "2"
			

		# movement (optional later)
		if parser.is_idle() and key in ["h", "j", "k", "l"]:
			return

		if parser.is_idle():
			clear_buffer()

		input_buffer += key
		parent.queue_redraw()
		buffer_timer = buffer_timeout
		
		print("BUFFER:", input_buffer)

		var result = parser.feed(key)

		# 🔥 THIS IS THE MISSING PIECE
		if result.status == "complete":
			var cmd: Command = result.command
			
			parent.dispatcher.process_command(cmd)
			
			# keep buffer visible for a moment
			buffer_timer = buffer_timeout
			
			reset_parser() # 🔥 reset parsing, but keep text

		elif result.status == "invalid":
			print("INVALID COMMAND")
			clear_buffer()
			
			
func _process(delta):
	if buffer_timer > 0:
		buffer_timer -= delta
		if buffer_timer <= 0:
			clear_buffer()

func clear_buffer():
	input_buffer = ""
	parent.queue_redraw()
	parser.reset()
	

func reset_parser():
	parser.reset()
