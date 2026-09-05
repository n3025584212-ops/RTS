class_name GoldenWorldV18TownDetail
extends RefCounted

static func add(world: GoldenWorldV1) -> void:
	var detailed_paths := world._filter_paths(
		world.city_hq3_resource_paths, ["warehouse_front", "derelict"]
	)
	if detailed_paths.is_empty():
		return

	var positions: Array[Vector3] = [
		Vector3(62.0,0,-28.0),
		Vector3(74.0,0,14.0)
	]
	for i: int in range(mini(positions.size(), detailed_paths.size())):
		var node := world._instantiate_scene(detailed_paths[i])
		if node == null:
			continue
		var p := positions[i]
		p.y = world.height_at(p.x, p.z)
		node.position = p
		node.rotation_degrees.y = 90.0 if i == 0 else 0.0
		world.fit_instance_to_size(node, 8.2 if i == 0 else 6.2)
		node.name = "TownDetailedWarEdge_%02d" % i
		world.add_child(node)
		world.town_instance_count += 1
