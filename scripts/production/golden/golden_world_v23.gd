extends "res://scripts/production/golden/golden_world_v22.gd"

# V23 is a finish integration pass over V22. It does not change the approved
# bridge-river-town composition. The purpose is to remove the remaining
# "models placed on a green sheet" read by improving ground breakup, natural
# contact, town edge dressing, riverbank detail, and depth/contrast.

const V23_HQ_ROOT := "res://assets/golden_scene/nature_hq/glTF"
const V23_FENCE_PATH := V23_HQ_ROOT + "/EA01_Env_Fence_Wood_01a.glb"
const V23_FENCE_ALT_PATH := V23_HQ_ROOT + "/EA01_Env_Fence_Wood_02b.glb"
const V23_BUSH_PATH := V23_HQ_ROOT + "/EA01_Env_Bush_02b.glb"
const V23_BUSH_ALT_PATH := V23_HQ_ROOT + "/EA01_Env_Bush_Dried_02.glb"
const V23_ROCK_PATH := V23_HQ_ROOT + "/EA01_Env_Rock_01b.glb"
const V23_ROCK_FLAT_PATH := V23_HQ_ROOT + "/EA01_Env_Rock_Flat_01c.glb"
const V23_BRANCH_PATH := V23_HQ_ROOT + "/EA01_Env_Branch_02.glb"

var _v23_mud_material: Material
var _v23_dry_material: Material
var _v23_char_material: StandardMaterial3D


func _build_materials() -> void:
	super._build_materials()
	_v23_mud_material = _pbr_material(
		"aerial_mud_1",
		Vector3(4.8, 4.8, 4.8),
		Color(0.30, 0.24, 0.16)
	)
	_v23_dry_material = _pbr_material(
		"aerial_mud_1",
		Vector3(7.2, 7.2, 7.2),
		Color(0.46, 0.39, 0.27)
	)
	_v23_char_material = StandardMaterial3D.new()
	_v23_char_material.albedo_color = Color(0.065, 0.058, 0.049)
	_v23_char_material.roughness = 0.97


func _build_environment() -> void:
	super._build_environment()
	var env_node := get_node_or_null("GoldenWorldEnvironment") as WorldEnvironment
	if env_node != null and env_node.environment != null:
		var env := env_node.environment
		# V22 was still slightly flat/grey. Lower ambient fill and retain a thin
		# aerial layer so foreground, town, and ridge separate without fogging
		# the whole frame.
		env.background_energy_multiplier = 0.94
		env.ambient_light_color = Color(0.30, 0.34, 0.36)
		env.ambient_light_energy = 0.235
		env.fog_light_color = Color(0.48, 0.54, 0.56)
		env.fog_light_energy = 0.48
		env.fog_density = 0.00105
		env.fog_height = 5.2
		env.fog_height_density = 0.0105
		env.fog_aerial_perspective = 0.44
		env.fog_sky_affect = 0.24

	var sun := get_node_or_null("MorningSun") as DirectionalLight3D
	if sun != null:
		sun.rotation_degrees = Vector3(-41.0, -51.0, 0.0)
		sun.light_color = Color(1.0, 0.91, 0.79)
		sun.light_energy = 1.88


func _build_roads() -> void:
	super._build_roads()
	_add_v23_ground_breakup()


func _build_town() -> void:
	super._build_town()
	_add_v23_town_dressing()


func _build_water() -> void:
	super._build_water()
	_add_v23_bank_detail()


func _build_forests_and_hedgerows() -> void:
	super._build_forests_and_hedgerows()
	_add_v23_hq_vegetation()


func _add_v23_ground_breakup() -> void:
	var patches: Array = [
		[Vector3(-24,0,7), Vector2(12.5,5.2), -7.0, _v23_mud_material],
		[Vector3(-11,0,4), Vector2(10.5,4.2), -10.0, _v23_dry_material],
		[Vector3(0,0,0), Vector2(8.0,3.2), -4.0, _v23_mud_material],
		[Vector3(17,0,-4), Vector2(7.2,3.4), 8.0, _v23_char_material],
		[Vector3(30,0,-7), Vector2(8.6,3.6), -9.0, _v23_mud_material],
		[Vector3(43,0,-5), Vector2(7.6,3.1), 15.0, _v23_dry_material],
		[Vector3(53,0,8), Vector2(6.8,3.4), -18.0, _v23_char_material],
		[Vector3(25,0,12), Vector2(7.8,4.0), 21.0, _v23_dry_material],
		[Vector3(64,0,-12), Vector2(8.2,3.7), -13.0, _v23_mud_material],
		[Vector3(72,0,9), Vector2(6.8,3.3), 10.0, _v23_dry_material]
	]
	for i: int in range(patches.size()):
		var data: Array = patches[i]
		var center: Vector3 = data[0]
		var radii: Vector2 = data[1]
		var yaw_deg: float = float(data[2])
		var material: Material = data[3]
		_add_v23_ground_patch(center, radii, yaw_deg, material, "V23GroundBreak_%02d" % i)


func _add_v23_ground_patch(center: Vector3, radii: Vector2, yaw_deg: float, material: Material, node_name: String) -> void:
	if material == null:
		return
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var segments := 18
	var yaw := deg_to_rad(yaw_deg)
	var center_y := height_at(center.x, center.z) + 0.055
	var center_p := Vector3(center.x, center_y, center.z)
	for i: int in range(segments):
		var a0 := TAU * float(i) / float(segments)
		var a1 := TAU * float(i + 1) / float(segments)
		var r0 := 1.0 + 0.09 * sin(float(i) * 2.31 + center.x * 0.07)
		var r1 := 1.0 + 0.09 * sin(float(i + 1) * 2.31 + center.x * 0.07)
		var p0 := _v23_patch_edge(center, radii, yaw, a0, r0)
		var p1 := _v23_patch_edge(center, radii, yaw, a1, r1)
		_add_v23_patch_vertex(st, center_p, Vector2(0.5, 0.5))
		_add_v23_patch_vertex(st, p0, Vector2(0.5 + cos(a0) * 0.5, 0.5 + sin(a0) * 0.5))
		_add_v23_patch_vertex(st, p1, Vector2(0.5 + cos(a1) * 0.5, 0.5 + sin(a1) * 0.5))
	var patch := MeshInstance3D.new()
	patch.name = node_name
	patch.mesh = st.commit()
	patch.material_override = material
	patch.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(patch)


func _v23_patch_edge(center: Vector3, radii: Vector2, yaw: float, angle: float, radial_scale: float) -> Vector3:
	var lx := cos(angle) * radii.x * radial_scale
	var lz := sin(angle) * radii.y * radial_scale
	var wx := center.x + cos(yaw) * lx - sin(yaw) * lz
	var wz := center.z + sin(yaw) * lx + cos(yaw) * lz
	return Vector3(wx, height_at(wx, wz) + 0.052, wz)


func _add_v23_patch_vertex(st: SurfaceTool, p: Vector3, uv: Vector2) -> void:
	st.set_normal(_terrain_normal(p.x, p.z))
	st.set_uv(uv)
	st.add_vertex(p)


func _add_v23_town_dressing() -> void:
	var props: Array = [
		[V23_FENCE_PATH, Vector3(22,0,-15), 5.8, 8.0],
		[V23_FENCE_ALT_PATH, Vector3(34,0,-17), 5.4, -6.0],
		[V23_FENCE_PATH, Vector3(48,0,-17), 5.9, 4.0],
		[V23_FENCE_ALT_PATH, Vector3(64,0,-17), 5.6, -8.0],
		[V23_FENCE_PATH, Vector3(31,0,5), 5.4, 92.0],
		[V23_FENCE_ALT_PATH, Vector3(58,0,5), 5.6, 88.0],
		[V23_BUSH_PATH, Vector3(37,0,-13), 3.6, 23.0],
		[V23_BUSH_ALT_PATH, Vector3(53,0,14), 3.4, -18.0],
		[V23_BUSH_PATH, Vector3(72,0,-7), 3.8, 74.0],
		[V23_ROCK_PATH, Vector3(28,0,-2), 2.3, 31.0],
		[V23_ROCK_FLAT_PATH, Vector3(50,0,-1), 2.5, 12.0],
		[V23_BRANCH_PATH, Vector3(61,0,12), 2.8, 67.0]
	]
	for i: int in range(props.size()):
		var data: Array = props[i]
		var path: String = data[0]
		var p: Vector3 = data[1]
		_add_v23_hq_prop(path, p, float(data[2]), float(data[3]), "V23TownDress_%02d" % i)


func _add_v23_bank_detail() -> void:
	var bank_paths: Array[String] = [V23_ROCK_PATH, V23_ROCK_FLAT_PATH, V23_BUSH_PATH]
	for i: int in range(14):
		var z := -45.0 + float(i) * 7.0
		if absf(z) < 7.0:
			continue
		var center_x := _river_center_x(z)
		var side := -1.0 if i % 2 == 0 else 1.0
		var x := center_x + side * (RIVER_HALF_WIDTH + 1.7 + float(i % 3) * 0.38)
		_add_v23_hq_prop(
			bank_paths[i % bank_paths.size()],
			Vector3(x, 0, z),
			2.0 + float(i % 4) * 0.30,
			float((i * 61) % 360),
			"V23BankDetail_%02d" % i
		)


func _add_v23_hq_vegetation() -> void:
	var vegetation: Array = [
		[V23_BUSH_PATH, Vector3(-42,0,18), 4.0, 13.0],
		[V23_BUSH_ALT_PATH, Vector3(-33,0,26), 3.7, 71.0],
		[V23_BUSH_PATH, Vector3(-20,0,31), 4.2, 114.0],
		[V23_BUSH_PATH, Vector3(14,0,26), 3.8, 38.0],
		[V23_BUSH_ALT_PATH, Vector3(18,0,-28), 4.0, 93.0],
		[V23_BUSH_PATH, Vector3(77,0,27), 4.1, 156.0],
		[V23_BUSH_ALT_PATH, Vector3(80,0,-25), 3.9, 212.0],
		[V23_ROCK_PATH, Vector3(-35,0,-29), 2.6, 44.0]
	]
	for i: int in range(vegetation.size()):
		var data: Array = vegetation[i]
		var path: String = data[0]
		var p: Vector3 = data[1]
		_add_v23_hq_prop(path, p, float(data[2]), float(data[3]), "V23NaturalContact_%02d" % i)


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
	add_child(root)
