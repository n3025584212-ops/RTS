extends "res://scripts/production/golden/golden_world_v25.gd"

# V26 moves from finish-only tuning to battlefield organization. The approved
# contract calls for a wooded NW ridge, populated distance and an eastern
# industrial edge. V25 still read as one clean town on a broad empty surface.

var _v26_industrial_wall: Material
var _v26_industrial_dark: Material


func _build_materials() -> void:
	super._build_materials()
	_v26_industrial_wall = _pbr_material(
		"t_concrete_wall_002", Vector3(5.5, 5.5, 5.5), Color(0.43, 0.44, 0.40)
	)
	_v26_industrial_dark = _pbr_material(
		"t_concrete_wall_002", Vector3(7.0, 7.0, 7.0), Color(0.25, 0.27, 0.26)
	)


func _build_town() -> void:
	super._build_town()
	_add_v26_east_edge()
	_add_v26_battlefield_clutter()


func _build_forests_and_hedgerows() -> void:
	super._build_forests_and_hedgerows()
	_add_v26_ridge_density()


func _add_v26_east_edge() -> void:
	var candidates := _filter_paths(
		city_resource_paths,
		["building-a", "building-b", "building-c", "building-d", "building-e", "building-f", "building-g"]
	)
	if candidates.is_empty():
		return
	var placements: Array = [
		[Vector3(88,0,-18), 7.6, 88.0],
		[Vector3(94,0,-5), 8.4, 92.0],
		[Vector3(92,0,10), 7.2, 89.0],
		[Vector3(87,0,23), 7.8, 94.0],
		[Vector3(100,0,3), 6.8, 86.0]
	]
	for i: int in range(placements.size()):
		var data: Array = placements[i]
		var building := _instantiate_scene(candidates[i % candidates.size()])
		if building == null:
			continue
		var p: Vector3 = data[0]
		p.y = height_at(p.x, p.z)
		building.position = p
		building.rotation_degrees.y = float(data[2])
		fit_instance_to_size(building, float(data[1]))
		_override_materials(
			building,
			_v26_industrial_dark if i % 3 == 1 else _v26_industrial_wall
		)
		building.name = "V26EastIndustrial_%02d" % i
		add_child(building)
		town_instance_count += 1

	# Put yard scars and service-space dirt between the town and the new edge so
	# the structures do not float as a second isolated row.
	for i: int in range(5):
		var x := 82.0 + float(i) * 4.4
		var z := -17.0 + float(i) * 9.2
		_add_v23_ground_patch(
			Vector3(x,0,z),
			Vector2(5.6 + float(i % 2), 3.8),
			float(-8 + i * 5),
			_v23_mud_material if i % 2 == 0 else _v23_dry_material,
			"V26IndustrialYard_%02d" % i
		)


func _add_v26_ridge_density() -> void:
	var tree_paths := _filter_paths(
		nature_resource_paths,
		["pineTallA_detailed", "pineTallB_detailed", "pineTallC_detailed", "pineTallD_detailed"]
	)
	if tree_paths.is_empty():
		tree_paths = _filter_paths(nature_resource_paths, ["pineTall", "pineDefault"])
	if tree_paths.is_empty():
		return

	# NW ridge: intentionally irregular spacing and size, with gaps for terrain
	# readability. The old sparse skyline made the whole map feel miniature.
	for i: int in range(34):
		var band := i % 4
		var x := -88.0 + fmod(float(i) * 8.9, 68.0)
		var z := -23.0 - float(band) * 7.2 - fmod(float(i * 13), 5.5)
		_add_nature_instance(
			tree_paths[i % tree_paths.size()],
			Vector3(x,0,z),
			4.6 + float((i * 3) % 7) * 0.34,
			float((i * 47 + 19) % 360)
		)

	# Far-eastern tree break prevents the industrial edge and town from ending
	# abruptly against a bare hill.
	for i: int in range(14):
		var x := 72.0 + float(i) * 3.8
		var z := -43.0 - sin(float(i) * 1.31) * 5.0
		_add_nature_instance(
			tree_paths[(i + 2) % tree_paths.size()],
			Vector3(x,0,z),
			4.0 + float(i % 5) * 0.33,
			float((i * 61) % 360)
		)


func _add_v26_battlefield_clutter() -> void:
	# Small, low-contrast scars connect combat events to the terrain instead of
	# leaving fire/smoke as floating VFX islands.
	var scars: Array = [
		[Vector3(15,0,1), Vector2(2.2,1.4), -12.0],
		[Vector3(31,0,-7), Vector2(2.8,1.7), 18.0],
		[Vector3(39,0,8), Vector2(2.4,1.5), -27.0],
		[Vector3(49,0,-6), Vector2(2.1,1.4), 9.0],
		[Vector3(53,0,-21), Vector2(2.7,1.7), -6.0],
		[Vector3(61,0,10), Vector2(2.3,1.5), 14.0]
	]
	for i: int in range(scars.size()):
		var data: Array = scars[i]
		_add_v23_ground_patch(data[0], data[1], float(data[2]), _v23_char_material, "V26Scorch_%02d" % i)
