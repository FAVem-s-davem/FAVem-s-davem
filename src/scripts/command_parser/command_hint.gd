extends Node

class_name CommandHint

var key: String
var description: String
var icon: String
var color: Color

func _init(_key: String, _description: String = "", _icon: String = "", _color: Color = Color.BLACK) -> void:
	key = _key
	description = _description
	icon = _icon
	color = _color
		
