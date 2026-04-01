class_name CommandDispatcher

var parent: GameScene

var current_macro_key = ""
var current_macro_commands: Array[Command] = []
var is_running_macro = false

var macros = {}

func _init(_parent: GameScene) -> void:
	parent = _parent

func process_command(command: Command):
	if current_macro_key != "" and command.op_type != Command.OpType.RUN_MACRO and command.op_type != Command.OpType.RECORD_MACRO:
		current_macro_commands.append(command.copy())
	
	match command.op_type:

		Command.OpType.SET_MARKER:
			parent.create_marker(command.marker)

		Command.OpType.GOTO_MARKER:
			print("Go to marker:", command.marker)
			parent.send_player_to_marker(command.marker)

		Command.OpType.SELECT:
			print("Select students:", command)
			parent.player.select_by_type(command.arg1, command.arg2, command.count, false)

		Command.OpType.APPEND:
			print("Append students:", command)
			parent.player.select_by_type(command.arg1, command.arg2, command.count, true)


		Command.OpType.DESELECT:
			print("Deselect students:", command)

		Command.OpType.DESELECT_ALL:
			print("Deselect ALL students")
		
		Command.OpType.RECORD_MACRO:
			handle_macro_record(command.arg1)
			
		Command.OpType.RUN_MACRO:
			handle_macro_run(command.arg1)
		

func handle_macro_record(key: String):
	if current_macro_key == "":
		print("Start recording macro:", key)
		current_macro_key = key
	
	elif current_macro_key == key:
		print("Stop recording macro:", key)
		macros[current_macro_key] = current_macro_commands.duplicate()
		current_macro_commands.clear()
		current_macro_key = ""
	
	else:
		print("Switch recording from", current_macro_key, "to", key)
		macros[current_macro_key] = current_macro_commands.duplicate()
		current_macro_commands.clear()
		current_macro_key = key
		
func handle_macro_run(key: String):
	if macros.has(key):
		if is_running_macro:
			print("Nested macros blocked")
			return
		
		is_running_macro = true
		
		for command in macros[key]:
			process_command(command)
		
		is_running_macro = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
