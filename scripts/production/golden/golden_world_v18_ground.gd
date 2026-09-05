class_name GoldenWorldV18Ground
extends RefCounted

static func add(world: GoldenWorldV1) -> void:
	_add_vehicle_disturbance(world)
	_add_rock_and_scrub_breakup(world)


static func _add_vehicle_disturbance(world: GoldenWorldV1) -> void:
	var track_mat := world._pbr_material(
		"grass_path_3", Vector3(7.0,7.0,7.0), Color(0.27,0.22,0.15)
	)
	var churn_mat := world._pbr_material(
		"aerial_mud_1", Vector3(6.0,6.0,6.0), Color(0.30,0.23,0.16)
	)
	for points: Array in [
		[Vector3(-47,0,13), Vector3(-32,0,10), Vector3(-18,0,7), Vector3(-4,0,3)],
		[Vector3(-40,0,20), Vector3(-27,0,15), Vector3(-12,0,11), Vector3(2,0,5)],
		[Vector3(20,0,-18), Vector3(31,0,-11), Vector3(42,0,-6), Vector3(54,0,-3)]
	]:
		world._add_road_ribbon(points, 0.52, track_mat, "VehicleTrack", 0.115)
	for points: Array in [
		[Vector3(5,0,-5), Vector3(13,0,-3), Vector3(21,0,-2)],
		[Vector3(34,0,14), Vector3(43,0,10), Vector3(53,0,8)]
	]:
		world._add_road_ribbon(points, 1.4, churn_mat, "BattleChurn", 0.105)


static func _add_rock_and_scrub_breakup(world: GoldenWorldV1) -> void:
	var rock_paths := world._filter_paths(
		world.nature_resource_paths,
		["rock_smallA", "rock_smallB", "rock_smallC", "rock_smallD", "rock_smallFlat"]
	)
	var bush_paths := world._filter_paths(
		world.nature_resource_paths,
		["plant_bushDetailed", "plant_bushSmall", "grass_large", "grass_leafsLarge"]
	)
	var rock_positions: Array[Vector3] = [
		Vector3(-54,0,25), Vector3(-44,0,15), Vector3(-34,0,33), Vector3(-24,0,22),
		Vector3(-10,0,25), Vector3(15,0,23), Vector3(19,0,-25), Vector3(70,0,32)
	]
	if not rock_paths.is_empty():
		for i: int in range(rock_positions.size()):
			world._add_nature_instance(
				rock_paths[i % rock_paths.size()],
				rock_positions[i],
				0.7 + float(i % 3) * 0.18,
				float((i * 61) % 360)
			)
	var bush_positions: Array[Vector3] = [
		Vector3(-58,0,38), Vector3(-47,0,40), Vector3(-35,0,37), Vector3(-20,0,42),
		Vector3(18,0,31), Vector3(69,0,35), Vector3(78,0,29), Vector3(16,0,-31)
	]
	if not bush_paths.is_empty():
		for i: int in range(bush_positions.size()):
			world._add_nature_instance(
				bush_paths[i % bush_paths.size()],
				bush_positions[i],
				1.2 + float(i % 3) * 0.22,
				float((i * 37) % 360)
			)
