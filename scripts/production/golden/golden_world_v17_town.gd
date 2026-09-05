class_name GoldenWorldV17Town
extends RefCounted

static func build(world: GoldenWorldV1) -> void:
	if world.city_resource_paths.is_empty():
		return

	var base_paths := world._filter_paths(
		world.city_resource_paths,
		["building", "house", "commercial", "office", "store", "apartment"]
	)
	if base_paths.is_empty():
		base_paths = world.city_resource_paths.duplicate()

	var low_rise: Array[String] = []
	for path: String in base_paths:
		var lower := path.to_lower()
		if not lower.contains("skyscraper") and not lower.contains("low-detail"):
			low_rise.append(path)
	var background_paths := low_rise if not low_rise.is_empty() else base_paths

	_add_background_edge(world, background_paths)
	_add_landmark(world)
	_add_real_house_blocks(world)
	_add_real_kit_boundaries(world)


static func _add_background_edge(world: GoldenWorldV1, paths: Array[String]) -> void:
	var positions: Array[Vector3] = [
		Vector3(82,0,-27), Vector3(86,0,-3), Vector3(81,0,24)
	]
	for i: int in range(positions.size()):
		var node := world._instantiate_scene(paths[i % paths.size()])
		if node == null:
			continue
		var p := positions[i]
		p.y = world.height_at(p.x, p.z)
		node.position = p
		node.rotation_degrees.y = 90.0 if i == 1 else 0.0
		world.fit_instance_to_size(node, 4.5 + float(i) * 0.25)
		world._override_materials(
			node, world._building_materials[(i + 1) % world._building_materials.size()]
		)
		node.name = "TownBackgroundBuilding_%02d" % i
		world.add_child(node)
		world.town_instance_count += 1


static func _add_landmark(world: GoldenWorldV1) -> void:
	var church_paths := world._filter_paths(world.city_real_resource_paths, ["church_landmark"])
	if church_paths.is_empty():
		return
	var church := world._instantiate_scene(church_paths[0])
	if church == null:
		return
	world.fit_instance_to_size(church, 14.5)
	church.position = Vector3(52.0, world.height_at(52.0, -34.0), -34.0)
	church.rotation_degrees.y = 10.0
	world._apply_building_surface_materials(
		church, world._church_wall_material, world._roof_materials[1], world._trim_material
	)
	church.name = "TownChurchLandmark"
	world.add_child(church)
	world.town_instance_count += 1


static func _add_real_house_blocks(world: GoldenWorldV1) -> void:
	var house_paths := world._filter_paths(
		world.city_real_resource_paths, ["ordinary_house_textured"]
	)
	if house_paths.is_empty():
		return
	var house_path := house_paths[0]
	var index := 0

	# Two compact street grids separated by the east-west and north-south roads.
	for row: int in range(6):
		for col: int in range(6):
			var x := 25.0 + float(col) * 10.2
			var z := -28.0 + float(row) * 10.8
			if absf(z + 5.5) < 4.2:
				continue
			if absf(x - 34.0) < 4.3 and row in [1, 2, 3, 4]:
				continue
			x += sin(float(index) * 1.73) * 0.85
			z += cos(float(index) * 1.21) * 0.65
			_add_house(world, house_path, Vector3(x,0,z), index)
			index += 1

	# Fill the eastern depth edge so the town does not terminate in open grass.
	for p: Vector3 in [
		Vector3(76,0,-18), Vector3(80,0,-7), Vector3(79,0,7), Vector3(76,0,19),
		Vector3(63,0,28), Vector3(49,0,28)
	]:
		_add_house(world, house_path, p, index)
		index += 1


static func _add_house(
	world: GoldenWorldV1, house_path: String, p: Vector3, index: int
) -> void:
	var house := world._instantiate_scene(house_path)
	if house == null:
		return
	p.y = world.height_at(p.x, p.z)
	house.position = p
	house.rotation_degrees.y = float((index % 4) * 90) + sin(float(index) * 1.31) * 3.0
	world.fit_instance_to_size(house, 5.5 + float(index % 4) * 0.34)

	var wall_cycle: Array[int] = [1, 2, 0, 3, 1, 0]
	var wall := world._building_materials[wall_cycle[index % wall_cycle.size()]]
	var roof := world._roof_materials[index % world._roof_materials.size()]
	if index in [2, 8, 17, 22, 27]:
		wall = world._roof_materials[2]
		roof = world._roof_materials[1]
	world._apply_building_surface_materials(house, wall, roof, world._trim_material)
	house.name = "TownTexturedHouse_%02d" % index
	world.add_child(house)
	world.town_instance_count += 1


static func _add_real_kit_boundaries(world: GoldenWorldV1) -> void:
	var fence_paths := world._filter_paths(world.city_resource_paths, ["fence", "wall"])
	if fence_paths.is_empty():
		return
	var positions: Array[Vector3] = [
		Vector3(31,0,-21), Vector3(46,0,-21), Vector3(60,0,-20), Vector3(73,0,-19),
		Vector3(33,0,1), Vector3(46,0,1), Vector3(59,0,1), Vector3(72,0,2),
		Vector3(31,0,23), Vector3(45,0,23), Vector3(59,0,24), Vector3(72,0,23)
	]
	for i: int in range(positions.size()):
		var boundary := world._instantiate_scene(fence_paths[i % fence_paths.size()])
		if boundary == null:
			continue
		var p := positions[i]
		p.y = world.height_at(p.x, p.z)
		boundary.position = p
		boundary.rotation_degrees.y = 90.0 if i % 2 == 0 else 0.0
		world.fit_instance_to_size(boundary, 3.0 + float(i % 3) * 0.35)
		world._override_materials(boundary, world._building_materials[3])
		boundary.name = "TownLotBoundary_%02d" % i
		world.add_child(boundary)
		world.town_instance_count += 1
