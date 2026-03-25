class_name StudentTypes

enum Type {
	MATH,
	CS,
	GEO,
	INF_GEO,
	MECH
}

enum Faculty {
	MATH,
	CS,
	GEO,
	MECH,
	PHYS,
}

const FACULTY_COLORS := {
	Faculty.MATH: Color.ORANGE,
	Faculty.CS: Color.YELLOW,
	Faculty.GEO: Color.GREEN,
	Faculty.MECH: Color.BLUE,
	Faculty.PHYS: Color.PURPLE,
}

const STUDENT_TYPE_INFO := {
	Type.MATH: {"path": "math", "variations_count": 4, "major": [Faculty.MATH]},
	Type.CS: {"path": "inf", "variations_count": 6, "major": [Faculty.CS]},
	Type.GEO: {"path": "geo", "variations_count": 4, "major": [Faculty.GEO]},
	Type.INF_GEO: {"path": "infgeo", "variations_count": 5, "major": [Faculty.GEO, Faculty.CS]},
	Type.MECH: {"path": "mech", "variations_count": 4, "major": [Faculty.MECH]},
}


static func student_type_to_string(type: int) -> String:
	if type in STUDENT_TYPE_INFO.keys():
		var info = STUDENT_TYPE_INFO[type]           # get the dictionary/object
		var index = randi_range(1, info["variations_count"])  # random variation
		var index_str = str(index).pad_zeros(2)      # always two digits
		return info["path"] + "_" + index_str        # construct filename
	return "unknown"
