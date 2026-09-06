class_name QualityTestWorldV1
extends Node3D

const MBT := "res://assets/golden_scene/vehicles/mbt_abrams.glb"
const IFV := "res://assets/golden_scene/vehicles/ifv.glb"
const WAREHOUSE := "res://assets/golden_scene/city_hq3/00_warehouse_front.glb"
const DERELICT := "res://assets/golden_scene/city_hq3/02_shop_front17_derelict.glb"
const SHOP := "res://assets/golden_scene/city_hq3/03_shop_front15.glb"
const TREE := "res://assets/golden_scene/nature_real/pine_sapling_small_lod.glb"

var building_count: int = 0
var vehicle_count: int = 0
var tree_count: int = 0
var camera: Camera3D

func build() -> void:
	_preflight()
	_build_environment()
	_build_ground()
	_build_buildings()
	_build_vehicles()
	_build_trees()
	_build_camera()
	print("FRONTLINE_QUALITY_WORLD_READY buildings=%d vehicles=%d trees=%d" %
		[building_count, vehicle_count, tree_count])


func _preflight() -> void:
	for path: String in [MBT, IFV, WAREHOUSE, DERELICT, SHOP, TREE]:
		if not ResourceLoader.exists(path):
			push_error("QUALITY_TEST_REQUIRED_ASSET_MISSING path=%s" % path)


func _build_environment() -> void:
	var env_node := WorldEnvironment.new()
	env_node.name = "QualityEnvironment"
	var env := Environment.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.16, 0.27, 0.39)
	sky_mat.sky_horizon_color = Color(0.58, 0.63, 0.62)
	sky_mat.ground_bottom_color = Color(0.09, 0.10, 0.085)
	sky_mat.ground_horizon_color = Color(0.39, 0.40, 0.34)
	sky_mat.sun_angle_max = 13.0
	var sky := Sky.new()
	sky.sky_material = sky_mat
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.background_energy_multiplier = 0.86
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.38, 0.42, 0.44)
	env.ambient_light_energy = 0.40
	env.reflected_light_source = Environment.REFLECTION_SOURCE_SKY
	env.fog_enabled = true
	env.fog_light_color = Color(0.43, 0.46, 0.45)
	env.fog_light_energy = 0.52
	env.fog_density = 0.0032
	env.fog_height = 3.0
	env.fog_height_density = 0.015
	env.fog_aerial_perspective = 0.34
	env.fog_sky_affect = 0.18
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env_node.environment = env
	add_child(env_node)

	var sun := DirectionalLight3D.new()
	sun.name = "QualityKeySun"
	sun.rotation_degrees = Vector3(-48.0, -34.0, 0.0)
	sun.light_color = Color(1.0, 0.91, 0.78)
	sun.light_energy = 1.88
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 95.0
	add_child(sun)

	var fill := DirectionalLight3D.new()
	fill.name = "QualitySkyFill"
	fill.rotation_degrees = Vector3(-68.0, 142.0, 0.0)
	fill.light_color = Color(0.44, 0.56, 0.66)
	fill.light_energy = 0.08
	add_child(fill)


func _build_ground() -> void:
	var ground := MeshInstance3D.new()
	ground.name = "QualityLayeredGround"
	var plane := PlaneMesh.new()
	plane.size = Vector2(78.0, 52.0)
	plane.subdivide_width = 48
	plane.subdivide_depth = 32
	ground.mesh = plane
	ground.material_override = _ground_material()
	add_child(ground)

	_add_patch("GravelShoulder", Vector3(6.0, 0.055, -1.0), Vector2(9.4, 49.0), -9.0,
		_pbr("gravel_ground_01", Vector3(10,10,10), Color(0.58,0.55,0.49), 0.88))
	_add_patch("AsphaltRoad", Vector3(6.0, 0.075, -1.0), Vector2(5.8, 49.0), -9.0,
		_pbr("asphalt_02", Vector3(12,12,12), Color(0.48,0.49,0.47), 0.78))
	_add_patch("VehicleChurn", Vector3(-8.0, 0.065, 8.0), Vector2(21.0, 8.5), 6.0,
		_pbr("grass_path_3", Vector3(7,7,7), Color(0.52,0.44,0.31), 0.91))
	_add_patch("BurntMud", Vector3(17.5, 0.070, -3.5), Vector2(13.0, 10.0), -8.0,
		_pbr("aerial_mud_1", Vector3(6,6,6), Color(0.43,0.35,0.25), 0.94))


func _ground_material() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
shader_type spatial;
uniform sampler2D grass_diff : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D grass_nor : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D dirt_diff : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D dirt_nor : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
varying vec3 wp;
void vertex() {
	VERTEX.y += 0.28 * sin(VERTEX.x * 0.10) + 0.18 * cos(VERTEX.z * 0.13);
	wp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}
void fragment() {
	vec2 uv = UV * 8.0;
	vec3 grass = texture(grass_diff, uv).rgb;
	vec3 dirt = texture(dirt_diff, uv * 0.72).rgb;
	float village_edge = 1.0 - smoothstep(9.0, 26.0, length(wp.xz - vec2(18.0, 2.0)));
	float armor_wear = 1.0 - smoothstep(5.0, 20.0, length(wp.xz - vec2(-7.0, 8.0)));
	float mix_dirt = clamp(village_edge * 0.38 + armor_wear * 0.22, 0.0, 0.48);
	ALBEDO = mix(grass * vec3(0.72,0.80,0.62), dirt * vec3(0.75,0.64,0.49), mix_dirt);
	NORMAL_MAP = mix(texture(grass_nor, uv).rgb, texture(dirt_nor, uv * 0.72).rgb, mix_dirt);
	NORMAL_MAP_DEPTH = 0.55;
	ROUGHNESS = 0.92;
	SPECULAR = 0.28;
}
"""
	var mat := ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("grass_diff", load("res://assets/golden_scene/pbr/leafy_grass_diff_1k.png"))
	mat.set_shader_parameter("grass_nor", load("res://assets/golden_scene/pbr/leafy_grass_nor_gl_1k.png"))
	mat.set_shader_parameter("dirt_diff", load("res://assets/golden_scene/pbr/dirt_aerial_03_diff_1k.png"))
	mat.set_shader_parameter("dirt_nor", load("res://assets/golden_scene/pbr/dirt_aerial_03_nor_gl_1k.png"))
	return mat


func _build_buildings() -> void:
	_add_asset(WAREHOUSE, Vector3(20.5, 0.10, -11.0), 13.0, 14.0, "HeroWarehouse")
	_add_asset(DERELICT, Vector3(20.0, 0.10, -1.5), 10.5, -9.0, "DamagedFront")
	_add_asset(SHOP, Vector3(24.0, 0.10, 10.5), 10.2, 7.0, "TownShop")
	building_count = 3


func _build_vehicles() -> void:
	_add_asset(MBT, Vector3(-10.5, 0.18, 7.0), 8.2, -72.0, "HeroAbrams")
	_add_asset(IFV, Vector3(-2.0, 0.16, 12.0), 6.5, -77.0, "SupportIFV")
	var wreck := _add_asset(IFV, Vector3(12.5, 0.12, -4.0), 5.8, 38.0, "BurnedIFV")
	if wreck != null:
		wreck.rotation_degrees.z = -7.0
		_override_material(wreck, _wreck_material())
	vehicle_count = 3


func _build_trees() -> void:
	var placements: Array = [
		[Vector3(29,0,-17), 7.5, 12.0],
		[Vector3(33,0,-6), 8.8, 94.0],
		[Vector3(31,0,7), 7.0, 184.0],
		[Vector3(27,0,18), 8.2, 260.0],
		[Vector3(-22,0,-13), 9.0, 318.0]
	]
	for i: int in range(placements.size()):
		var d: Array = placements[i]
		_add_asset(TREE, d[0], d[1], d[2], "QualityTree_%02d" % i)
		tree_count += 1


func _build_camera() -> void:
	camera = Camera3D.new()
	camera.name = "QualityCamera"
	camera.fov = 43.0
	camera.position = Vector3(-31.0, 21.5, 32.0)
	camera.look_at(Vector3(6.0, 1.7, 0.5), Vector3.UP)
	camera.current = true
	add_child(camera)


func _add_patch(name_value: String, p: Vector3, size: Vector2, yaw: float, mat: Material) -> void:
	var node := MeshInstance3D.new()
	node.name = name_value
	var plane := PlaneMesh.new()
	plane.size = size
	plane.subdivide_width = 4
	plane.subdivide_depth = 12
	node.mesh = plane
	node.position = p
	node.rotation_degrees.y = yaw
	node.material_override = mat
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	add_child(node)


func _add_asset(path: String, p: Vector3, target: float, yaw: float, name_value: String) -> Node3D:
	var packed := load(path) as PackedScene
	if packed == null:
		push_error("QUALITY_TEST_ASSET_LOAD_FAIL path=%s" % path)
		return null
	var node := packed.instantiate() as Node3D
	if node == null:
		return null
	node.name = name_value
	_fit(node, target)
	node.position = p
	node.rotation_degrees.y = yaw
	add_child(node)
	return node


func _fit(root: Node3D, target: float) -> void:
	var max_dim := 0.0
	for item: Node in root.find_children("*", "MeshInstance3D", true, false):
		var mi := item as MeshInstance3D
		if mi != null and mi.mesh != null:
			var s := mi.mesh.get_aabb().size
			max_dim = maxf(max_dim, maxf(s.x, maxf(s.y, s.z)))
	if max_dim > 0.001:
		root.scale = Vector3.ONE * (target / max_dim)


func _pbr(id: String, tile: Vector3, tint: Color, roughness: float) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = tint
	mat.albedo_texture = load("res://assets/golden_scene/pbr/%s_diff_1k.png" % id)
	mat.normal_enabled = true
	mat.normal_texture = load("res://assets/golden_scene/pbr/%s_nor_gl_1k.png" % id)
	mat.uv1_scale = tile
	mat.roughness = roughness
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	return mat


func _wreck_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.075, 0.065, 0.052)
	mat.metallic = 0.42
	mat.roughness = 0.86
	return mat


func _override_material(root: Node3D, mat: Material) -> void:
	if root is MeshInstance3D:
		(root as MeshInstance3D).material_override = mat
	for child: Node in root.get_children():
		if child is Node3D:
			_override_material(child as Node3D, mat)
