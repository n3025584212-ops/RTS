class_name GoldenWorldV17Forest
extends RefCounted

static func build(world: GoldenWorldV1) -> void:
	if world.nature_resource_paths.is_empty():
		return

	var light_paths := world._filter_paths(world.nature_resource_paths, [
		"pineTallA_detailed", "pineTallB_detailed", "pineTallC_detailed", "pineTallD_detailed"
	])
	if light_paths.is_empty():
		light_paths = world._filter_paths(world.nature_resource_paths, ["pineTall", "pineDefault"])

	if not world.nature_real_resource_paths.is_empty():
		var real_path := world.nature_real_resource_paths[0]
		var positions: Array[Vector3] = [
			Vector3(-58,0,-31), Vector3(-52,0,-35), Vector3(-46,0,-32),
			Vector3(-40,0,-37), Vector3(-34,0,-34), Vector3(-29,0,-40),
			Vector3(-23,0,-36), Vector3(24,0,-42), Vector3(30,0,-46),
			Vector3(36,0,-43), Vector3(43,0,-47), Vector3(50,0,-44),
			Vector3(57,0,-49), Vector3(64,0,-45), Vector3(70,0,-48),
			Vector3(76,0,-42), Vector3(81,0,-37), Vector3(72,0,-33)
		]
		for i: int in range(positions.size()):
			world._add_real_tree_instance(
				real_path,
				positions[i],
				8.4 + float(i % 5) * 0.52,
				float((i * 43) % 360)
			)

	# Only distant skyline silhouettes use the lightweight tree family.
	for i: int in range(14):
		var x := -96.0 + fmod(float(i) * 10.4, 92.0)
		var z := -74.0 + fmod(float(i) * 7.3, 8.0)
		world._add_nature_instance(
			light_paths[i % light_paths.size()],
			Vector3(x,0,z),
			3.7 + float(i % 4) * 0.42,
			float((i * 47) % 360)
		)
	for i: int in range(7):
		var x := 30.0 + float(i) * 7.0
		var z := -70.0 + sin(float(i) * 1.37) * 2.0
		world._add_nature_instance(
			light_paths[i % light_paths.size()],
			Vector3(x,0,z),
			3.6 + float(i % 3) * 0.38,
			float((i * 53) % 360)
		)

	var hedge_paths := world._filter_paths(world.nature_resource_paths, ["tree_small", "tree_thin"])
	if hedge_paths.is_empty():
		hedge_paths = light_paths
	for i: int in range(8):
		var x := -62.0 + float(i) * 8.8
		var z := 43.0 + sin(float(i) * 1.7) * 1.2
		world._add_nature_instance(
			hedge_paths[i % hedge_paths.size()],
			Vector3(x,0,z),
			2.1 + float(i % 2) * 0.20,
			float((i * 33) % 360)
		)
