extends QualityTestWorldV1

const HOUSE_0 := "res://assets/golden_scene/city_v20/family_house_00.glb"
const HOUSE_1 := "res://assets/golden_scene/city_v20/family_house_01.glb"
const HOUSE_2 := "res://assets/golden_scene/city_v20/family_house_02.glb"
const HOUSE_3 := "res://assets/golden_scene/city_v20/family_house_03.glb"
const TREE_A := "res://assets/golden_scene/nature_hq/glTF/EA01_Env_Tree_01c.glb"
const TREE_B := "res://assets/golden_scene/nature_hq/glTF/EA01_Env_Tree_03a.glb"
const TREE_C := "res://assets/golden_scene/nature_hq/glTF/EA01_Env_Tree_05d.glb"

func _preflight() -> void:
	for path: String in [MBT, IFV, HOUSE_0, HOUSE_1, HOUSE_2, HOUSE_3, TREE_A, TREE_B, TREE_C]:
		if not ResourceLoader.exists(path):
			push_error("QUALITY_TEST_REQUIRED_ASSET_MISSING path=%s" % path)


func _build_environment() -> void:
	super._build_environment()
	var env_node := get_node_or_null("QualityEnvironment") as WorldEnvironment
	if env_node != null and env_node.environment != null:
		var env := env_node.environment
		env.background_energy_multiplier = 0.78
		env.ambient_light_energy = 0.34
		env.fog_density = 0.0024
		env.fog_height_density = 0.011
		if env.sky != null and env.sky.sky_material is ProceduralSkyMaterial:
			var sky := env.sky.sky_material as ProceduralSkyMaterial
			sky.sky_top_color = Color(0.19,0.30,0.42)
			sky.sky_horizon_color = Color(0.55,0.61,0.61)
			sky.ground_bottom_color = Color(0.24,0.25,0.21)
			sky.ground_horizon_color = Color(0.45,0.46,0.39)
	var sun := get_node_or_null("QualityKeySun") as DirectionalLight3D
	if sun != null:
		sun.light_energy = 1.52


func _build_ground() -> void:
	var ground := MeshInstance3D.new()
	ground.name = "QualityTerrainEnvelope"
	var plane := PlaneMesh.new()
	plane.size = Vector2(180.0, 120.0)
	plane.subdivide_width = 72
	plane.subdivide_depth = 48
	ground.mesh = plane
	var ground_mat := _ground_material()
	var code := ground_mat.shader.code
	code = code.replace(
		"grass * vec3(0.72,0.80,0.62)",
		"grass * vec3(0.50,0.63,0.42)"
	)
	code = code.replace(
		"dirt * vec3(0.75,0.64,0.49)",
		"dirt * vec3(0.62,0.52,0.38)"
	)
	ground_mat.shader.code = code
	ground.material_override = ground_mat
	add_child(ground)

	_add_patch("VillageShoulder", Vector3(7.0,0.055,-1.0), Vector2(10.5,96.0), -9.0,
		_pbr("gravel_ground_01",Vector3(11,11,11),Color(0.48,0.46,0.41),0.90))
	_add_patch("VillageRoad", Vector3(7.0,0.075,-1.0), Vector2(5.9,96.0), -9.0,
		_pbr("asphalt_02",Vector3(13,13,13),Color(0.36,0.37,0.36),0.82))
	_add_masked_patch("ArmorChurn", Vector3(-7.0,0.082,8.0), Vector2(25.0,11.0), 5.0,
		"grass_path_3", Color(0.42,0.34,0.23))
	_add_masked_patch("BattleMud", Vector3(18.0,0.086,-4.0), Vector2(18.0,13.0), -5.0,
		"aerial_mud_1", Color(0.39,0.31,0.23))


func _build_buildings() -> void:
	_add_asset(HOUSE_0, Vector3(18.0,0.10,-13.0), 10.6, 8.0, "FamilyHouseA")
	_add_asset(HOUSE_1, Vector3(25.0,0.10,-3.0), 11.2, -12.0, "FamilyHouseB")
	var damaged := _add_asset(HOUSE_2, Vector3(20.0,0.10,8.0), 10.8, 7.0, "DamagedFamilyHouse")
	if damaged != null:
		_tint_surfaces(damaged, Color(0.46,0.40,0.34))
	_add_asset(HOUSE_3, Vector3(12.0,0.10,16.0), 10.4, -7.0, "FamilyHouseD")
	building_count = 4


func _build_vehicles() -> void:
	var mbt := _add_asset(MBT, Vector3(-9.0,0.18,7.0), 8.2, -72.0, "HeroAbrams")
	if mbt != null:
		_override_material(mbt, _vehicle_material(Color(0.20,0.24,0.13),0.28))
	var ifv := _add_asset(IFV, Vector3(-1.0,0.16,12.5), 6.5, -76.0, "SupportIFV")
	if ifv != null:
		_override_material(ifv, _vehicle_material(Color(0.18,0.21,0.12),0.22))
	var wreck := _add_asset(IFV, Vector3(12.0,0.12,-4.0), 5.8, 38.0, "BurnedIFV")
	if wreck != null:
		wreck.rotation_degrees.z = -7.0
		_override_material(wreck, _wreck_material())
	vehicle_count = 3


func _build_trees() -> void:
	var placements: Array = [
		[TREE_A,Vector3(31,0,-18),11.5,12.0],
		[TREE_B,Vector3(37,0,-7),12.5,78.0],
		[TREE_C,Vector3(34,0,8),11.0,164.0],
		[TREE_A,Vector3(29,0,21),12.0,244.0],
		[TREE_B,Vector3(-25,0,-17),13.0,310.0],
		[TREE_C,Vector3(-31,0,3),10.5,28.0],
		[TREE_A,Vector3(42,0,20),11.0,206.0],
	]
	for i: int in range(placements.size()):
		var d: Array = placements[i]
		_add_asset(d[0], d[1], d[2], d[3], "QualityTree_%02d" % i)
		tree_count += 1


func _build_camera() -> void:
	camera = Camera3D.new()
	camera.name = "QualityCamera"
	camera.fov = 45.0
	camera.position = Vector3(-25.0,19.5,27.0)
	add_child(camera)
	camera.look_at(Vector3(7.0,1.0,1.0),Vector3.UP)
	camera.current = true


func _vehicle_material(color: Color, metallic_value: float) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.metallic = metallic_value
	mat.roughness = 0.72
	mat.specular = 0.36
	return mat


func _tint_surfaces(root: Node3D, tint: Color) -> void:
	for item: Node in root.find_children("*","MeshInstance3D",true,false):
		var mi := item as MeshInstance3D
		if mi == null or mi.mesh == null:
			continue
		for s: int in range(mi.mesh.get_surface_count()):
			var source := mi.get_active_material(s)
			if source is StandardMaterial3D:
				var mat := source.duplicate() as StandardMaterial3D
				mat.albedo_color = Color(
					mat.albedo_color.r * tint.r,
					mat.albedo_color.g * tint.g,
					mat.albedo_color.b * tint.b,
					mat.albedo_color.a
				)
				mat.roughness = maxf(mat.roughness,0.82)
				mi.set_surface_override_material(s,mat)


func _add_masked_patch(name_value: String, p: Vector3, size: Vector2, yaw: float, id: String, tint: Color) -> void:
	var node := MeshInstance3D.new()
	node.name = name_value
	var plane := PlaneMesh.new()
	plane.size = size
	node.mesh = plane
	node.position = p
	node.rotation_degrees.y = yaw
	var shader := Shader.new()
	shader.code = """
shader_type spatial;
render_mode blend_mix, depth_prepass_alpha, cull_back;
uniform sampler2D surface_tex : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform vec3 tint : source_color;
void fragment() {
	vec2 p = abs(UV - vec2(0.5)) * 2.0;
	float edge = 1.0 - smoothstep(0.62,0.96,max(p.x,p.y));
	vec3 tex = texture(surface_tex,UV * 5.0).rgb;
	ALBEDO = tex * tint;
	ROUGHNESS = 0.94;
	ALPHA = edge * 0.92;
}
"""
	var mat := ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("surface_tex",load("res://assets/golden_scene/pbr/%s_diff_1k.png" % id))
	mat.set_shader_parameter("tint",Vector3(tint.r,tint.g,tint.b))
	node.material_override = mat
	add_child(node)
