class_name Quest

var dept_counts := {}   # DeptName -> int
var spec_counts := {}   # SpecName -> int


func _init() -> void:
	_generate_mixed_quest()


func _generate_mixed_quest() -> void:
	var has_any := false

	# Generate dept requirements
	for dept in StudentTypes.DeptName.values():
		var count := randi() % 3   # 0–2
		if count > 0:
			dept_counts[dept] = count
			has_any = true
			print("Quest: ", count, " from ", StudentTypes.dept_name_to_string(dept))

	# Generate spec requirements
	for spec in StudentTypes.SpecName.values():
		var count := randi() % 2   # 0–1
		if count > 0:
			spec_counts[spec] = count
			has_any = true
			print("Quest: ", count, " of ", StudentTypes.spec_name_to_string(spec))

	# 🔥 Ensure quest is NOT empty
	if not has_any:
		_force_non_empty()


func _force_non_empty() -> void:
	# Randomly choose to add either a dept or spec requirement
	if randi() % 2 == 0:
		var dept = StudentTypes.DeptName.values().pick_random()
		dept_counts[dept] = 1
		print("Forced Quest: 1 from ", StudentTypes.dept_name_to_string(dept))
	else:
		var spec = StudentTypes.SpecName.values().pick_random()
		spec_counts[spec] = 1
		print("Forced Quest: 1 of ", StudentTypes.spec_name_to_string(spec))
			
func is_complete() -> bool:
	for value in dept_counts.values():
		if value > 0:
			return false

	for value in spec_counts.values():
		if value > 0:
			return false

	return true
	
func register_student(dept: int, spec: int) -> bool:
	if spec_counts.has(spec) and spec_counts[spec] > 0:
		spec_counts[spec] -= 1
		return true

	if dept_counts.has(dept) and dept_counts[dept] > 0:
		dept_counts[dept] -= 1
		return true

	return false


func get_description() -> String:
	var parts: Array[String] = []

	for dept in dept_counts.keys():
		var count: int = dept_counts[dept]
		if count > 0:
			parts.append("%d %s" % [
				count,
				StudentTypes.dept_name_to_string(dept).to_upper()
			])

	for spec in spec_counts.keys():
		var count: int = spec_counts[spec]
		if count > 0:
			parts.append("%d %s" % [
				count,
				StudentTypes.spec_name_to_string(spec)
			])

	return ", ".join(parts)
