class_name Quest

var counts := {}


func _init() -> void:
	for type in StudentTypes.Type.values():
		counts[type] = randi() % 3
		print("Quest count: ", counts[type])


func is_complete() -> bool:
	for value in counts.values():
		if value > 0:
			return false
	return true
