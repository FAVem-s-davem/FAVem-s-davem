extends Node

class_name InputHandler

signal command_executed(command)
signal key_pressed()
signal valid_command()
signal invalid_command()

var input_buffer := ""
var buffer_timer := 0.0
var buffer_timeout := 4.0
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
		var is_enter = keycode == KEY_ENTER or keycode == KEY_KP_ENTER
		var is_backspace = keycode == KEY_BACKSPACE
		var is_at = char(event.unicode) == "@"

		# 🔥 Allow Enter + Backspace now
		if not (is_letter or is_number or is_at or is_enter or is_backspace):
			return

		emit_signal("key_pressed")

		# =========================
		# 🔥 ENTER → EXECUTE
		# =========================
		if is_enter:
			print("ENTER PRESSED")

			var result = parser.feed("Enter")

			if result.status == "complete":
				var cmd: Command = result.command
				emit_signal("valid_command")

				parent.dispatcher.process_command(cmd)

				buffer_timer = buffer_timeout
				reset_parser()

			elif result.status == "invalid":
				print("INVALID COMMAND")
				emit_signal("invalid_command") # 🔥 NEW
				clear_buffer()

			return


		# =========================
		# 🔥 BACKSPACE (optional but recommended)
		# =========================
		if is_backspace:
			if input_buffer.length() > 0:
				input_buffer = input_buffer.substr(0, input_buffer.length() - 1)
				parser.reset() # simplest approach (reparse later if needed)

			parent.queue_redraw()
			return


		# =========================
		# NORMAL CHARACTER INPUT
		# =========================
		var key = OS.get_keycode_string(keycode)

		if is_letter:
			key = key.to_upper() if event.shift_pressed else key.to_lower()

		if is_at:
			key = "@" if event.shift_pressed else "2"

		# movement (optional later)
		if key in ["h", "j", "k", "l"]:
			return

		if parser.is_idle():
			clear_buffer()

		input_buffer += key
		parent.queue_redraw()
		buffer_timer = buffer_timeout

		print("BUFFER:", input_buffer)

		var result = parser.feed(key)

		# 🔥 NO MORE AUTO-EXECUTION
		if result.status == "invalid":
			print("INVALID COMMAND")
			clear_buffer()
			
func _process(delta):
	if buffer_timer > 0:
		buffer_timer -= delta
		if buffer_timer <= 0:
			clear_buffer()

func clear_buffer():
	input_buffer = ""
	#emit_signal("key_pressed")
	parent.queue_redraw()
	parser.reset()
	

func reset_parser():
	parser.reset()
