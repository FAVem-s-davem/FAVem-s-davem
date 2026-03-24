class_name StudentTypes

enum Type {
	MATH,
	CS,
	GEO,
	INF_GEO,
	MECH
}


const STUDENT_TYPE_INFO := {
	Type.MATH: {"path": "math", "variations_count": 4},
	Type.CS: {"path": "inf", "variations_count": 6},
	Type.GEO: {"path": "geo", "variations_count": 4},
	Type.INF_GEO: {"path": "infgeo", "variations_count": 5},
	Type.MECH: {"path": "mech", "variations_count": 4},
}

static func student_type_to_string(type: int) -> String:
	if type in student_type_info.keys():
		var info = student_type_info[type]           # get the dictionary/object
		var index = randi_range(1, info["variations_count"])  # random variation
		var index_str = str(index).pad_zeros(2)      # always two digits
		return info["path"] + "_" + index_str        # construct filename
	return "unknown"
