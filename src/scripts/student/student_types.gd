class_name StudentTypes

enum DeptName {
	KMA,
	KIV,
	KME,
	KGM,
}

enum SpecName {
	CALCULUS,
	GEOMETRY,
	GRAPHICS,
	DATABASE,
	MATERIALS,
	BIOMECH,
	GEODET,
	CARTOGRAPHY,	
}

const DEPT_NAME_STRINGS := [
	"kma",
	"kiv",
	"kme",
	"kgm",
]

const SPEC_NAME_STRINGS := [
	"calculus",
	"geometry",
	"graphics",
	"database",
	"materials",
	"biomech",
	"geodet",
	"cartography",
]

# Mapping department -> list of specializations
const DEPT_TO_SPECS := {
	DeptName.KMA: [
		SpecName.CALCULUS,
		SpecName.GEOMETRY,
	],
	DeptName.KIV: [
		SpecName.GRAPHICS,
		SpecName.DATABASE,
	],
	DeptName.KME: [
		SpecName.MATERIALS,
		SpecName.BIOMECH,
	],
	DeptName.KGM: [
		SpecName.GEODET,
		SpecName.CARTOGRAPHY,
	],
}

static var DeptShortcuts = {
	DeptName.KMA: "a",
	DeptName.KIV: "i",
	DeptName.KME: "e",
	DeptName.KGM: "g",
}

static var SpecShortcuts = {
	SpecName.CALCULUS: "c",
	SpecName.GEOMETRY: "g",
	SpecName.GRAPHICS: "g",
	SpecName.DATABASE: "d",
	SpecName.MATERIALS: "m",
	SpecName.BIOMECH: "b",
	SpecName.GEODET: "g",
	SpecName.CARTOGRAPHY: "c"
}

static func dept_name_to_string(dept: int) -> String:
	if dept >= 0 and dept < DEPT_NAME_STRINGS.size():
		return DEPT_NAME_STRINGS[dept]
	return "unknown"

static func spec_name_to_string(spec: int) -> String:
	if spec >= 0 and spec < SPEC_NAME_STRINGS.size():
		return SPEC_NAME_STRINGS[spec]
	return "unknown"

static func get_specs_from_dept(dept: int) -> Array:
	if DEPT_TO_SPECS.has(dept):
		return DEPT_TO_SPECS[dept]
	return []
