extends "res://scripts/production/golden/golden_world_v23.gd"

# V24 is the corrective pass after the V23 runtime image review.
# Compatibility rendering exposed several HQ props with white/failed authored
# materials. Keep the geometry, force stable scene-coherent fallback materials,
# and add clearly readable vehicle churn instead of another broad terrain tint.

var _v24_wood_material: StandardMaterial3D
var _v24_bush_material: StandardMaterial3D
var _v24_dry_bush_material: StandardMaterial3D
var _v24_rock_material: StandardMaterial3D
var _v24_track_material: StandardMaterial3D


func _build_materials() -> void:
	super._build_materials()
	_v24_wood_material = _pbr_material("grass_path_3", Vector3(5.0, 5.0, 5.0), Color(0.27, 0.19, 0.11))
	_v24_wood_material.roughness = 0.92
	_v24_bush_material = _pbr_material("leafy_grass", Vector3(4.0, 4.0, 4.0), Color(0.20, 0.30, 0.13))
	_v24_bush_material.roughness = 0.95
	_v24_dry_bush_material = _pbr_material("grass_path_3", Vector3(5.5, 5.5, 5.5), Color(0.35, 0.29, 0.17))
	_v24_dry_bush_material.roughness = 0.96
	_v24_rock_material = _pbr_material("gravel_ground_01", Vector3(5.5, 5.5, 5.5), Color(0.38, 0.36, 0.31))
	_v24_rock_material.roughness = 0.96
	_v24_track_material = _pbr_material("aerial_mud_1", Vector3(8.5, 8.5, 8.5), Color(0.23, 0.17, 0.105))
	_v24_track_material.roughness = 0.95


func _add_v23_ground_breakup() -> void:
	super._add_v23_ground_breakup()
	# Parallel irregular strips make the foreground armor feel physically tied
	# to the battlefield. They follow the existing BLUE approach axis and a
	# smaller RED/town movement line; no route or gameplay geometry changes.
	_add_v24_track_strip(Vector3(-36,0,14.8), Vector3(4,0,-2.0), 0.72, 0.0, "V24BlueTrackA")
	_add_v24_track_strip(Vector3(-35,0,12.3), Vector3(5,0,-4.4), 0.62, 0.9, "V24BlueTrackB")
	_add_v24_track_strip(Vector3(16,0,-4.0), Vector3(51,0,-7.2), 0.54, 0.4, "V24TownTrackA")
	_add_v24_track_strip(Vector3(18,0,-1.5), Vector3(48,0,-4.6), 0.44, 1.3, "V24TownTrackB")


func _add_v24_track_strip(start: Vector3, finish: Vector3, width: float, wobble_phase: float, node_name: String) -> void:
	if _v24_track_material == null:
		return
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var steps := 18
	var delta := finish - start
	var planar := Vector2(delta.x, delta.z)
	if planar.length_squared() < 0.0001:
		return
	var tangent := planar.normalized()
	var normal2 := Vector2(-tangent.y, tangent.x)
	for i: int in range(steps):
		var t0 := float(i) / float(steps)
		var t1 := float(i + 1) / float(steps)
		var c0 := start.lerp(finish, t0)
		var c1 := start.lerp(finish, t1)
		var wobble0 := sin(t0 * 10.5 + wobble_phase) * 0.28
		var wobble1 := sin(t1 * 10.5 + wobble_phase) * 0.28
		c0.x += normal2.x * wobble0
		c0.z += normal2.y * wobble0
		c1.x += normal2.x * wobble1
		c1.z += normal2.y * wobble1
		var half0 := width * (0.80 + 0.16 * sin(float(i) * 1.73 + wobble_phase))
		var half1 := width * (0.80 + 0.16 * sin(float(i + 1) * 1.73 + wobble_phase))
		var l0 := Vector3(c0.x + normal2.x * half0, 0, c0.z + normal2.y * half0)
		var r0 := Vector3(c0.x - normal2.x * half0, 0, c0.z - normal2.y * half0)
		var l1 := Vector3(c1.x + normal2.x * half1, 0, c1.z + normal2.y * half1)
		var r1 := Vector3(c1.x - normal2.x * half1, 0, c1.z - normal2.y * half1)
		l0.y = height_at(l0.x, l0.z) + 0.065
		r0.y = height_at(r0.x, r0.z) + 0.065
		l1.y = height_at(l1.x, l1.z) + 0.065
		r1.y = height_at(r1.x, r1.z) + 0.065
		_add_v24_track_vertex(st, l0, Vector2(0.0, t0 * 8.0))
		_add_v24_track_vertex(st, r0, Vector2(1.0, t0 * 8.0))
		_add_v24_track_vertex(st, l1, Vector2(0.0, t1 * 8.0))
		_add_v24_track_vertex(st, r0, Vector2(1.0, t0 * 8.0))
		_add_v24_track_vertex(st, r1, Vector2(1.0, t1 * 8.0))
		_add_v24_track_vertex(st, l1, Vector2(0.0, t1 * 8.0))
	var strip := MeshInstance3D.new()
	strip.name = node_name
	strip.mesh = st.commit()
	strip.material_override = _v24_track_material
	strip.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(strip)


func _add_v24_track_vertex(st: SurfaceTool, p: Vector3, uv: Vector2) -> void:
	st.set_normal(_terrain_normal(p.x, p.z))
	st.set_uv(uv)
	st.add_vertex(p)


func _add_v23_hq_prop(path: String, p: Vector3, target_size: float, yaw_deg: float, node_name: String) -> void:
	if not ResourceLoader.exists(path):
		return
	var packed := load(path) as PackedScene
	if packed == null:
		return
	var root := packed.instantiate() as Node3D
	if root == null:
		return
	fit_instance_to_size(root, target_size)
	p.y = height_at(p.x, p.z) + 0.02
	root.position = p
	root.rotation_degrees.y = yaw_deg
	root.name = node_name
	_v24_force_prop_material(root, path)
	add_child(root)


func _v24_force_prop_material(root: Node3D, path: String) -> void:
	var material: Material = _v24_rock_material
	if path.contains("Fence") or path.contains("Branch"):
		material = _v24_wood_material
	elif path.contains("Bush_Dried"):
		material = _v24_dry_bush_material
	elif path.contains("Bush"):
		material = _v24_bush_material
	for node_variant: Node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := node_variant as MeshInstance3D
		if mesh_instance == null or mesh_instance.mesh == null:
			continue
		for surface: int in range(mesh_instance.mesh.get_surface_count()):
			mesh_instance.set_surface_override_material(surface, material)
