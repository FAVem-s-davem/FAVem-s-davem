extends Node2D

class_name NavigationManager

var nav_region := NavigationRegion2D.new()
var nav_poly := NavigationPolygon.new()

var outer_boundary: PackedVector2Array
var obstacles: Array[PackedVector2Array] = []

func set_walkable_area(vertices: Array):
	outer_boundary = PackedVector2Array(vertices)
	
func add_obstacle(vertices: Array):
	obstacles.append(PackedVector2Array(vertices))
	
func bake_navigation():
	nav_poly.clear()

	# Outer walkable area FIRST
	nav_poly.add_outline(outer_boundary)

	# Then obstacles (holes)
	for obs in obstacles:
		nav_poly.add_outline(obs)

	nav_poly.make_polygons_from_outlines()

	nav_region.navigation_polygon = nav_poly
	
	if nav_region.get_parent() == null:
		add_child(nav_region)
