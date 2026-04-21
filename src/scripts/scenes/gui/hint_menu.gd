extends VBoxContainer

# Dictionary to store hints: { "hint_key": "hint_text", ... }
var hints: Array[CommandHint] = []

func _ready():
	_update_display()
	pass

# Set hints from a dictionary of string:string pairs
func set_hints(new_hints: Array[CommandHint]):
	hints = new_hints
	_update_display()

# Clear all hints
func clear_hints():
	hints.clear()
	_update_display()
	
func update_actions(new_hints: Array[CommandHint]):
	set_hints(new_hints)

# Update the visual display of all hints
func _update_display():
	# Clear existing child nodes
	for child in get_children():
		child.queue_free()
	
	for hint in hints:
		var panel = PanelContainer.new()
		var label = Label.new()
		label.text = "[ %s ]: %s" % [key, hints[key]]
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		label.add_theme_font_size_override("font_size", 24)

		# Background
		var style = StyleBoxFlat.new()
		style.bg_color = hint.color
		style.border_color = Color.BLACK if hint.color.get_luminance() > 0.5 else Color.WHITE
		style.corner_radius_top_left = 6
		style.corner_radius_top_right = 6
		style.corner_radius_bottom_left = 6
		style.corner_radius_bottom_right = 6
		style.content_margin_left = 6
		style.content_margin_right = 6
		style.content_margin_top = 4
		style.content_margin_bottom = 4
		
		panel.add_theme_stylebox_override("panel", style)

		# =====================
		# LEFT: [ key ] :
		# =====================
		var key_label = Label.new()
		key_label.text = "[ %s ]:" % hint.key
		key_label.add_theme_font_size_override("font_size", 32)

		# Match contrast
		if hint.color.get_luminance() > 0.5:
			key_label.add_theme_color_override("font_color", Color.BLACK)
		else:
			key_label.add_theme_color_override("font_color", Color.WHITE)

		hbox.add_child(key_label)

		# =====================
		# RIGHT: icon OR text
		# =====================
		if hint.icon != "":
			var texture_rect = TextureRect.new()
			var tex = load(hint.icon)
			
			if tex:
				texture_rect.texture = tex
				texture_rect.custom_minimum_size = Vector2(48, 48)
				texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			
			hbox.add_child(texture_rect)
		else:
			var label = Label.new()
			label.text = hint.description
			label.autowrap_mode = TextServer.AUTOWRAP_WORD
			label.add_theme_font_size_override("font_size", 32)

			# Match contrast
			if hint.color.get_luminance() > 0.5:
				label.add_theme_color_override("font_color", Color.BLACK)
			else:
				label.add_theme_color_override("font_color", Color.WHITE)

			hbox.add_child(label)

		# spacing
		hbox.add_theme_constant_override("separation", 8)

		panel.add_child(hbox)
		add_child(panel)
