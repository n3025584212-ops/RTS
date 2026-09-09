extends "res://scripts/production/golden/golden_units_v1.gd"

const HQ_MBT_PATH := "res://assets/golden_scene/quality_material_v3/mbt_abrams_static.glb"


func build(world: GoldenWorldV1) -> void:
	if not ResourceLoader.exists(HQ_MBT_PATH):
		push_error("Golden Scene V21 missing high-fidelity MBT at %s" % HQ_MBT_PATH)
	super.build(world)


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
	var final_size := target_size * 1.18 if hq_mbt else target_size
	_world.fit_instance_to_size(root, final_size)
	p.y = _world.height_at(p.x, p.z) + 0.10
	root.position = p
	root.rotation_degrees.y = yaw

	# Preserve authored materials wherever they exist. The previous global
	# material override was one of the main reasons vehicles and infantry read
	# as flat toys. Only distant legacy MBTs still use the tactical camo shader.
	if path == MBT_PATH and not hq_mbt:
		_override_mesh_materials(
			root,
			_hostile_vehicle_material if node_name.begins_with("RED_") else _friendly_vehicle_material
		)
	elif path == IFV_PATH:
		_preserve_or_tint_if_empty(root, node_name.begins_with("RED_"))
	elif path == SOLDIER_PATH:
		_preserve_or_tint_infantry_if_empty(root)

	add_child(root)
	return root


func _use_hq_mbt(node_name: String) -> bool:
	return node_name in [
		"BLUE_MBT_00", "BLUE_MBT_01", "BLUE_MBT_02",
		"RED_MBT_00", "RED_MBT_01"
	]


func _preserve_or_tint_if_empty(root: Node3D, hostile: bool) -> void:
	var authored := false
	for node_variant: Node in root.find_children("*", "MeshInstance3D", true, false):
		var mi := node_variant as MeshInstance3D
		if mi == null or mi.mesh == null:
			continue
		for surface: int in range(mi.mesh.get_surface_count()):
			if mi.mesh.surface_get_material(surface) != null:
				authored = true
				break
		if authored:
			break
	if not authored:
		_override_mesh_materials(root, _hostile_vehicle_material if hostile else _friendly_vehicle_material)


func _preserve_or_tint_infantry_if_empty(root: Node3D) -> void:
	var authored := false
	for node_variant: Node in root.find_children("*", "MeshInstance3D", true, false):
		var mi := node_variant as MeshInstance3D
		if mi == null or mi.mesh == null:
			continue
		for surface: int in range(mi.mesh.get_surface_count()):
			if mi.mesh.surface_get_material(surface) != null:
				authored = true
				break
		if authored:
			break
	if not authored:
		_override_mesh_materials(root, _infantry_material)
