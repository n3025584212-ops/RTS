extends "res://scripts/production/golden/golden_units_v21.gd"

# V22 runtime review: the new focal Abrams geometry was a clear fidelity gain,
# but it read over-scale and the authored IFV/soldier materials were too pale
# under the scene lighting. Keep their textures/normals and only modulate them.

func _spawn_model(path: String, p: Vector3, target_size: float, yaw: float, node_name: String) -> Node3D:
	var resolved_path := path
	var hq_mbt := path == MBT_PATH and _use_hq_mbt(node_name)
	if hq_mbt:
		resolved_path = HQ_MBT_PATH

	var packed := load(resolved_path) as PackedScene
	if packed == null:
		push_error("Golden Scene required model failed to load: %s" % resolved_path)
		return null
	var root := packed.instantiate() as Node3D
	if root == null:
		push_error("Golden Scene required model is not Node3D: %s" % resolved_path)
		return null

	root.name = node_name
	var final_size := target_size * 1.01 if hq_mbt else target_size
	_world.fit_instance_to_size(root, final_size)
	p.y = _world.height_at(p.x, p.z) + 0.10
	root.position = p
	root.rotation_degrees.y = yaw

	if path == MBT_PATH and not hq_mbt:
		_override_mesh_materials(
			root,
			_hostile_vehicle_material if node_name.begins_with("RED_") else _friendly_vehicle_material
		)
	elif path == IFV_PATH:
		_tint_authored_materials(
			root,
			Color(0.52, 0.56, 0.40) if not node_name.begins_with("RED_") else Color(0.56, 0.47, 0.34),
			_hostile_vehicle_material if node_name.begins_with("RED_") else _friendly_vehicle_material
		)
	elif path == SOLDIER_PATH:
		_tint_authored_materials(
			root,
			Color(0.46, 0.52, 0.31) if not node_name.begins_with("RED_") else Color(0.50, 0.43, 0.29),
			_infantry_material
		)

	add_child(root)
	return root


func _tint_authored_materials(root: Node3D, tint: Color, fallback: Material) -> void:
	var touched := false
	for node_variant: Node in root.find_children("*", "MeshInstance3D", true, false):
		var mi := node_variant as MeshInstance3D
		if mi == null or mi.mesh == null:
			continue
		for surface: int in range(mi.mesh.get_surface_count()):
			var source := mi.get_active_material(surface)
			if source is StandardMaterial3D:
				var mat := (source as StandardMaterial3D).duplicate(true) as StandardMaterial3D
				var c := mat.albedo_color
				mat.albedo_color = Color(
					c.r * tint.r,
					c.g * tint.g,
					c.b * tint.b,
					c.a
				)
				mat.roughness = maxf(mat.roughness, 0.56)
				mi.set_surface_override_material(surface, mat)
				touched = true
	if not touched:
		_override_mesh_materials(root, fallback)
