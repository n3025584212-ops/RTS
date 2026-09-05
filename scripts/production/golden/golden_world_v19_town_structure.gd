class_name GoldenWorldV19TownStructure
extends RefCounted

static func add(world: GoldenWorldV1) -> void:
	_add_streets(world)
	_add_yard_boundaries(world)


static func _add_streets(world: GoldenWorldV1) -> void:
	for data: Array in [
		[[Vector3(21,0,-19), Vector3(43,0,-18), Vector3(63,0,-17), Vector3(84,0,-16)], 2.45, "TownStreetNorth"],
		[[Vector3(20,0,10), Vector3(42,0,9), Vector3(63,0,10), Vector3(83,0,12)], 2.35, "TownStreetSouth"],
		[[Vector3(49,0,-31), Vector3(50,0,-16), Vector3(50,0,1), Vector3(51,0,25)], 2.30, "TownStreetEast"],
		[[Vector3(68,0,-28), Vector3(68,0,-13), Vector3(69,0,4), Vector3(70,0,24)], 2.20, "TownStreetFarEast"]
	]:
		world._add_road_polyline(data[0], data[1], world._road_material, data[2])


static func _add_yard_boundaries(world: GoldenWorldV1) -> void:
	var fences := world._filter_paths(
		world.nature_resource_paths,
		["fence_simple", "fence_planks", "fence_gate"]
	)
	if fences.is_empty():
		return
	var positions: Array[Vector3] = [
		Vector3(29,0,-23), Vector3(39,0,-23), Vector3(58,0,-22), Vector3(72,0,-22),
		Vector3(29,0,-12), Vector3(41,0,-12), Vector3(58,0,-11), Vector3(72,0,-10),
		Vector3(29,0,4), Vector3(41,0,4), Vector3(58,0,4), Vector3(72,0,5),
		Vector3(29,0,16), Vector3(41,0,16), Vector3(58,0,16), Vector3(72,0,17)
	]
	for i: int in range(positions.size()):
		var fence := world._instantiate_scene(fences[i % fences.size()])
		if fence == null:
			continue
		var p := positions[i]
		p.y = world.height_at(p.x, p.z)
		fence.position = p
		fence.rotation_degrees.y = 90.0 if i % 4 in [1, 2] else 0.0
		world.fit_instance_to_size(fence, 2.5 + float(i % 3) * 0.28)
		fence.name = "TownYardBoundary_%02d" % i
		world.add_child(fence)
		world.town_instance_count += 1
