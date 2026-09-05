class_name GoldenWorldV20TownCore
extends RefCounted

static func build(world: GoldenWorldV1) -> void:
	var houses := world._find_3d_resources("res://assets/golden_scene/city_v20")
	if houses.size() < 3:
		push_error("V20 recovery requires at least three family-house GLBs.")
		return
	var positions: Array[Vector3] = [
		Vector3(26,0,-23), Vector3(39,0,-23), Vector3(55,0,-22),
		Vector3(70,0,-21), Vector3(28,0,-10), Vector3(47,0,-10),
		Vector3(65,0,-8), Vector3(29,0,8), Vector3(46,0,9),
		Vector3(63,0,10), Vector3(36,0,22), Vector3(56,0,23)
	]
	for i: int in range(positions.size()):
		var house := world._instantiate_scene(houses[i % houses.size()])
		if house == null:
			continue
		var p := positions[i]
		p.x += sin(float(i) * 1.29) * 0.7
		p.z += cos(float(i) * 1.61) * 0.5
		p.y = world.height_at(p.x, p.z)
		house.position = p
		house.rotation_degrees.y = float((i % 4) * 90) + sin(float(i) * 0.73) * 4.0
		world.fit_instance_to_size(house, 5.6 + float(i % 3) * 0.35)
		house.name = "V20FamilyHouse_%02d" % i
		world.add_child(house)
		world.town_instance_count += 1
	_add_church(world)


static func _add_church(world: GoldenWorldV1) -> void:
	var churches := world._filter_paths(world.city_real_resource_paths, ["church_landmark"])
	if churches.is_empty():
		return
	var church := world._instantiate_scene(churches[0])
	if church == null:
		return
	world.fit_instance_to_size(church, 14.0)
	church.position = Vector3(54.0, world.height_at(54.0, -34.0), -34.0)
	church.rotation_degrees.y = 8.0
	world._apply_building_surface_materials(
		church, world._church_wall_material, world._roof_materials[1], world._trim_material
	)
	church.name = "V20TownLandmark"
	world.add_child(church)
	world.town_instance_count += 1
