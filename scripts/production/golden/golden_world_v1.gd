class_name GoldenWorldV1
extends Node3D

const MAP_X_MIN := -132.0
const MAP_X_MAX := 148.0
const MAP_Z_MIN := -108.0
const MAP_Z_MAX := 104.0
const RIVER_X := 6.0
const RIVER_HALF_WIDTH := 6.2

var city_resource_paths: Array[String] = []
var city_hd_resource_paths: Array[String] = []
var city_hq_resource_paths: Array[String] = []
var city_hq3_resource_paths: Array[String] = []
var city_real_resource_paths: Array[String] = []
var nature_resource_paths: Array[String] = []
var nature_hq_resource_paths: Array[String] = []
var town_instance_count: int = 0
var tree_instance_count: int = 0
var bridge_member_count: int = 0
var road_segment_count: int = 0
var camera: Camera3D

var _terrain_material: ShaderMaterial
var _water_material: ShaderMaterial
var _road_material: StandardMaterial3D
var _dirt_road_material: StandardMaterial3D
var _bridge_concrete: StandardMaterial3D
var _bridge_steel: StandardMaterial3D
var _field_material_a: ShaderMaterial
var _field_material_b: ShaderMaterial
var _foliage_materials: Array[StandardMaterial3D] = []
var _rock_material: StandardMaterial3D
var _building_materials: Array[Material] = []
var _roof_materials: Array[Material] = []
var _trim_material: Material
var _church_wall_material: Material
var _bank_material: StandardMaterial3D
var _shoulder_material: StandardMaterial3D


func build() -> void:
	city_resource_paths = _find_3d_resources("res://assets/golden_scene/city")
	city_hd_resource_paths = _find_3d_resources("res://assets/golden_scene/city_hd")
	city_hq_resource_paths = _find_3d_resources("res://assets/golden_scene/city_hq")
	city_hq3_resource_paths = _find_3d_resources("res://assets/golden_scene/city_hq3")
	city_real_resource_paths = _find_3d_resources("res://assets/golden_scene/city_real")
	nature_resource_paths = _find_3d_resources("res://assets/golden_scene/nature")
	nature_hq_resource_paths = _find_3d_resources("res://assets/golden_scene/nature_hq")
	if city_resource_paths.is_empty():
		push_error("Golden Scene requires vendored city assets; none were imported.")
	if nature_resource_paths.is_empty():
		push_error("Golden Scene requires vendored nature assets; none were imported.")

	_build_materials()
	_build_environment()
	_build_terrain()
	_build_water()
	_build_fields()
	_build_roads()
	_build_bridge()
	_build_town()
	_build_forests_and_hedgerows()
	_build_camera()

	print(
		"FRONTLINE_GOLDEN_WORLD_READY town=%d trees=%d bridge_members=%d roads=%d" %
		[town_instance_count, tree_instance_count, bridge_member_count, road_segment_count]
	)


func height_at(x: float, z: float) -> float:
	var rolling := 0.55 * sin(x * 0.085) + 0.42 * cos(z * 0.11) + 0.24 * sin((x + z) * 0.16)
	var west_ridge := 6.5 * exp(-pow((x + 37.0) / 19.0, 2.0) - pow((z + 18.0) / 17.0, 2.0))
	var north_hills := 3.0 * exp(-pow((x - 4.0) / 34.0, 2.0) - pow((z + 39.0) / 13.0, 2.0))
	var east_rise := 2.4 * exp(-pow((x - 52.0) / 17.0, 2.0) - pow((z + 19.0) / 26.0, 2.0))
	var distant_ridge := 5.2 * exp(-pow((z + 82.0) / 25.0, 2.0)) * (0.78 + 0.22 * cos(x * 0.043))
	var far_east_hill := 3.4 * exp(-pow((x - 78.0) / 35.0, 2.0) - pow((z + 62.0) / 31.0, 2.0))
	var river_cut := 4.9 * exp(-pow((x - RIVER_X) / 6.8, 2.0))
	var floodplain := 0.9 * exp(-pow((x - RIVER_X) / 13.0, 2.0))
	return rolling + west_ridge + north_hills + east_rise + distant_ridge + far_east_hill - river_cut - floodplain


func fit_instance_to_size(root: Node3D, target_max_dimension: float) -> float:
	var max_dim := 0.0
	var meshes := root.find_children("*", "MeshInstance3D", true, false)
	for node_variant: Node in meshes:
		var mesh_instance := node_variant as MeshInstance3D
		if mesh_instance == null or mesh_instance.mesh == null:
			continue
		var size := mesh_instance.mesh.get_aabb().size
		max_dim = maxf(max_dim, maxf(size.x, maxf(size.y, size.z)))
	if max_dim <= 0.0001:
		return 1.0
	var factor := target_max_dimension / max_dim
	root.scale = Vector3.ONE * factor
	return factor


func _build_materials() -> void:
	_terrain_material = ShaderMaterial.new()
	var terrain_shader := Shader.new()
	terrain_shader.code = """
shader_type spatial;
render_mode cull_back;
uniform sampler2D grass_diff : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D grass_nor : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D dirt_diff : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D dirt_nor : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D mud_diff : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D mud_nor : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
varying vec3 world_pos;
void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}
float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}
void fragment() {
	vec2 uv = UV * 6.5;
	float broad = clamp(0.5 + 0.22 * sin(world_pos.x * 0.075) + 0.18 * cos(world_pos.z * 0.095) + 0.10 * sin((world_pos.x + world_pos.z) * 0.045), 0.0, 1.0);
	float river = 1.0 - smoothstep(8.5, 19.0, abs(world_pos.x - 6.0));
	float dry = smoothstep(0.28, 0.72, broad);
	vec3 g_tex = texture(grass_diff, uv).rgb;
	vec3 d_tex = texture(dirt_diff, uv * 0.72).rgb;
	vec3 m_tex = texture(mud_diff, uv * 0.58).rgb;
	vec3 grass_macro = mix(vec3(0.13, 0.225, 0.075), vec3(0.205, 0.31, 0.115), broad);
	vec3 g = mix(grass_macro, g_tex, 0.20);
	vec3 d = mix(vec3(0.225, 0.175, 0.105), d_tex, 0.30);
	vec3 m = mix(vec3(0.18, 0.145, 0.095), m_tex, 0.34);
	vec3 gn = texture(grass_nor, uv).rgb;
	vec3 dn = texture(dirt_nor, uv * 0.82).rgb;
	vec3 mn = texture(mud_nor, uv * 0.65).rgb;
	float dirt_mix = clamp(dry * 0.10 + river * 0.10, 0.0, 0.22);
	float mud_mix = river * 0.18;
	vec3 base = mix(g, d, dirt_mix);
	base = mix(base, m, mud_mix);
	float far_mix = smoothstep(48.0, 105.0, -world_pos.z);
	base = mix(base, vec3(0.22, 0.245, 0.20), far_mix * 0.58);
	ALBEDO = base;
	NORMAL_MAP = mix(mix(gn, dn, dirt_mix), mn, mud_mix);
	NORMAL_MAP_DEPTH = 0.22;
	ROUGHNESS = mix(0.93, 0.68, mud_mix);
	METALLIC = 0.0;
	SPECULAR = 0.30;
}
"""
	_terrain_material.shader = terrain_shader
	_terrain_material.set_shader_parameter("grass_diff", load("res://assets/golden_scene/pbr/leafy_grass_diff_1k.png"))
	_terrain_material.set_shader_parameter("grass_nor", load("res://assets/golden_scene/pbr/leafy_grass_nor_gl_1k.png"))
	_terrain_material.set_shader_parameter("dirt_diff", load("res://assets/golden_scene/pbr/dirt_aerial_03_diff_1k.png"))
	_terrain_material.set_shader_parameter("dirt_nor", load("res://assets/golden_scene/pbr/dirt_aerial_03_nor_gl_1k.png"))
	_terrain_material.set_shader_parameter("mud_diff", load("res://assets/golden_scene/pbr/aerial_mud_1_diff_1k.png"))
	_terrain_material.set_shader_parameter("mud_nor", load("res://assets/golden_scene/pbr/aerial_mud_1_nor_gl_1k.png"))

	_water_material = ShaderMaterial.new()
	var water_shader := Shader.new()
	water_shader.code = """
shader_type spatial;
render_mode blend_mix, depth_prepass_alpha, cull_back;
void vertex() {
	VERTEX.y += sin(VERTEX.z * 0.72 + TIME * 0.8) * 0.055;
	VERTEX.y += cos(VERTEX.x * 1.45 - TIME * 1.05) * 0.032;
}
void fragment() {
	float ripple = sin(UV.y * 145.0 + TIME * 0.8) * 0.5 + 0.5;
	vec3 deep = vec3(0.025, 0.115, 0.145);
	vec3 shallow = vec3(0.060, 0.210, 0.225);
	ALBEDO = mix(deep, shallow, 0.26 + ripple * 0.08);
	ROUGHNESS = 0.20;
	METALLIC = 0.08;
	SPECULAR = 0.72;
	ALPHA = 0.88;
}
"""
	_water_material.shader = water_shader

	_road_material = _pbr_material("asphalt_02", Vector3(12.0, 12.0, 12.0), Color(0.72, 0.72, 0.70))
	_dirt_road_material = _pbr_material("grass_path_3", Vector3(8.0, 8.0, 8.0), Color(0.48, 0.43, 0.32))
	_shoulder_material = _pbr_material("gravel_ground_01", Vector3(9.0, 9.0, 9.0), Color(0.48, 0.44, 0.36))
	_bank_material = _pbr_material("aerial_mud_1", Vector3(6.0, 6.0, 6.0), Color(0.70, 0.62, 0.48))
	_bridge_concrete = _pbr_material("t_concrete_wall_002", Vector3(6.0, 6.0, 6.0), Color(0.62, 0.63, 0.60))
	_bridge_steel = _standard_material(Color(0.13, 0.15, 0.14), 0.68, 0.34)

	_field_material_a = _field_shader(Color(0.26, 0.33, 0.11), Color(0.15, 0.20, 0.065))
	_field_material_b = _field_shader(Color(0.34, 0.28, 0.105), Color(0.19, 0.15, 0.055))
	_foliage_materials = [
		_standard_material(Color(0.105, 0.155, 0.070), 0.0, 0.96),
		_standard_material(Color(0.135, 0.190, 0.082), 0.0, 0.95),
		_standard_material(Color(0.165, 0.215, 0.095), 0.0, 0.94),
		_standard_material(Color(0.090, 0.130, 0.060), 0.0, 0.98),
	]
	_rock_material = _standard_material(Color(0.28, 0.27, 0.235), 0.02, 0.92)
	_building_materials = [
		_surface_detail_material("t_concrete_wall_002", Color(0.34, 0.35, 0.32), 0.16),
		_surface_detail_material("t_concrete_wall_002", Color(0.50, 0.45, 0.36), 0.17),
		_surface_detail_material("brick_wall_005", Color(0.40, 0.27, 0.19), 0.20),
		_surface_detail_material("t_concrete_wall_002", Color(0.29, 0.31, 0.31), 0.14),
	]
	_roof_materials = [
		_surface_detail_material("brick_wall_005", Color(0.16, 0.11, 0.085), 0.24),
		_surface_detail_material("brick_wall_005", Color(0.12, 0.13, 0.13), 0.20),
		_surface_detail_material("t_concrete_wall_002", Color(0.20, 0.19, 0.17), 0.16),
	]
	_trim_material = _standard_material(Color(0.16, 0.17, 0.16), 0.02, 0.74)
	_church_wall_material = _surface_detail_material("t_concrete_wall_002", Color(0.56, 0.52, 0.43), 0.24)


func _build_environment() -> void:
	var env_node := WorldEnvironment.new()
	env_node.name = "GoldenWorldEnvironment"
	var env := Environment.new()

	# Compatibility-render proof must never fall back to a black horizon.
	# Keep the visible background independent from Sky/fog/tonemap while using
	# explicit ambient and directional lighting for world readability.
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.32, 0.43, 0.53)
	env.background_energy_multiplier = 1.02
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.48, 0.53, 0.56)
	env.ambient_light_energy = 0.62
	env.reflected_light_source = Environment.REFLECTION_SOURCE_DISABLED
	env.fog_enabled = false
	env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	env_node.environment = env
	add_child(env_node)

	var sun := DirectionalLight3D.new()
	sun.name = "MorningSun"
	sun.rotation_degrees = Vector3(-43.0, -38.0, 0.0)
	sun.light_color = Color(1.0, 0.96, 0.88)
	sun.light_energy = 1.42
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 180.0
	add_child(sun)

	var fill := DirectionalLight3D.new()
	fill.name = "CoolSkyFill"
	fill.rotation_degrees = Vector3(-70.0, 145.0, 0.0)
	fill.light_color = Color(0.50, 0.62, 0.72)
	fill.light_energy = 0.10
	fill.shadow_enabled = false
	add_child(fill)


func _build_terrain() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var nx := 109
	var nz := 83
	var dx := (MAP_X_MAX - MAP_X_MIN) / float(nx - 1)
	var dz := (MAP_Z_MAX - MAP_Z_MIN) / float(nz - 1)

	for zi: int in range(nz - 1):
		for xi: int in range(nx - 1):
			var x0 := MAP_X_MIN + float(xi) * dx
			var x1 := x0 + dx
			var z0 := MAP_Z_MIN + float(zi) * dz
			var z1 := z0 + dz
			var p00 := Vector3(x0, height_at(x0, z0), z0)
			var p01 := Vector3(x0, height_at(x0, z1), z1)
			var p10 := Vector3(x1, height_at(x1, z0), z0)
			var p11 := Vector3(x1, height_at(x1, z1), z1)
			# Godot front faces use clockwise winding. Keep the valley top surface
			# front-facing so lighting, shadows and PBR material read correctly.
			_add_terrain_vertex(st, p00)
			_add_terrain_vertex(st, p10)
			_add_terrain_vertex(st, p01)
			_add_terrain_vertex(st, p10)
			_add_terrain_vertex(st, p11)
			_add_terrain_vertex(st, p01)

	var mesh := st.commit()
	var terrain := MeshInstance3D.new()
	terrain.name = "SculptedValleyTerrain"
	terrain.mesh = mesh
	terrain.material_override = _terrain_material
	terrain.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	add_child(terrain)


func _add_terrain_vertex(st: SurfaceTool, p: Vector3) -> void:
	st.set_normal(_terrain_normal(p.x, p.z))
	st.set_color(_terrain_color(p.x, p.z))
	st.set_uv(Vector2(
		(p.x - MAP_X_MIN) / (MAP_X_MAX - MAP_X_MIN),
		(p.z - MAP_Z_MIN) / (MAP_Z_MAX - MAP_Z_MIN)
	))
	st.add_vertex(p)


func _terrain_color(x: float, z: float) -> Color:
	var h := height_at(x, z)
	var broad := 0.5 + 0.5 * sin(x * 0.17 + z * 0.11)
	var micro := 0.5 + 0.5 * sin(x * 0.73 - z * 0.49)
	var grass := Color(0.14, 0.22, 0.09)
	var dry := Color(0.28, 0.27, 0.115)
	var soil := Color(0.25, 0.18, 0.09)
	var c := grass.lerp(dry, clampf(0.22 + broad * 0.34, 0.0, 1.0))
	if h > 3.2:
		c = c.lerp(Color(0.105, 0.16, 0.075), 0.38)
	if absf(x - RIVER_X) < 11.5:
		c = c.lerp(soil, 0.34)
	return c * (0.88 + micro * 0.16)


func _terrain_normal(x: float, z: float) -> Vector3:
	var e := 0.45
	var dx := height_at(x + e, z) - height_at(x - e, z)
	var dz := height_at(x, z + e) - height_at(x, z - e)
	return Vector3(-dx / (2.0 * e), 1.0, -dz / (2.0 * e)).normalized()


func _river_center_x(z: float) -> float:
	return RIVER_X + sin(z * 0.055) * 0.85 + sin(z * 0.135) * 0.28


func _build_water() -> void:
	# Meandering world-space river ribbon. The water and both banks follow the
	# same centerline so the capture no longer reads as a flat rectangular plane.
	var water_st := SurfaceTool.new()
	water_st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var bank_st_w := SurfaceTool.new()
	bank_st_w.begin(Mesh.PRIMITIVE_TRIANGLES)
	var bank_st_e := SurfaceTool.new()
	bank_st_e.begin(Mesh.PRIMITIVE_TRIANGLES)
	var segments := 92
	for i: int in range(segments):
		var z0 := lerpf(MAP_Z_MIN - 3.0, MAP_Z_MAX + 3.0, float(i) / float(segments))
		var z1 := lerpf(MAP_Z_MIN - 3.0, MAP_Z_MAX + 3.0, float(i + 1) / float(segments))
		var c0 := _river_center_x(z0)
		var c1 := _river_center_x(z1)
		var w0 := RIVER_HALF_WIDTH + sin(z0 * 0.10) * 0.45
		var w1 := RIVER_HALF_WIDTH + sin(z1 * 0.10) * 0.45
		_add_surface_quad(
			water_st,
			Vector3(c0 - w0, -1.02, z0), Vector3(c0 + w0, -1.02, z0),
			Vector3(c1 - w1, -1.02, z1), Vector3(c1 + w1, -1.02, z1),
			float(i) / float(segments), float(i + 1) / float(segments)
		)
		var outer_w0 := c0 - w0 - 2.6
		var outer_w1 := c1 - w1 - 2.6
		_add_surface_quad(
			bank_st_w,
			Vector3(outer_w0, height_at(outer_w0, z0) + 0.04, z0), Vector3(c0 - w0, -0.88, z0),
			Vector3(outer_w1, height_at(outer_w1, z1) + 0.04, z1), Vector3(c1 - w1, -0.88, z1),
			float(i) / float(segments), float(i + 1) / float(segments)
		)
		var outer_e0 := c0 + w0 + 2.6
		var outer_e1 := c1 + w1 + 2.6
		_add_surface_quad(
			bank_st_e,
			Vector3(c0 + w0, -0.88, z0), Vector3(outer_e0, height_at(outer_e0, z0) + 0.04, z0),
			Vector3(c1 + w1, -0.88, z1), Vector3(outer_e1, height_at(outer_e1, z1) + 0.04, z1),
			float(i) / float(segments), float(i + 1) / float(segments)
		)

	var water := MeshInstance3D.new()
	water.name = "ShadedRiverWater"
	water.mesh = water_st.commit()
	water.material_override = _water_material
	add_child(water)

	for pair: Array in [["WestRiverBank", bank_st_w.commit()], ["EastRiverBank", bank_st_e.commit()]]:
		var bank := MeshInstance3D.new()
		bank.name = pair[0]
		bank.mesh = pair[1]
		bank.material_override = _bank_material
		add_child(bank)


func _add_surface_quad(st: SurfaceTool, a0: Vector3, b0: Vector3, a1: Vector3, b1: Vector3, v0: float, v1: float) -> void:
	st.set_normal(Vector3.UP)
	st.set_uv(Vector2(0.0, v0))
	st.add_vertex(a0)
	st.set_normal(Vector3.UP)
	st.set_uv(Vector2(1.0, v0))
	st.add_vertex(b0)
	st.set_normal(Vector3.UP)
	st.set_uv(Vector2(0.0, v1))
	st.add_vertex(a1)
	st.set_normal(Vector3.UP)
	st.set_uv(Vector2(1.0, v0))
	st.add_vertex(b0)
	st.set_normal(Vector3.UP)
	st.set_uv(Vector2(1.0, v1))
	st.add_vertex(b1)
	st.set_normal(Vector3.UP)
	st.set_uv(Vector2(0.0, v1))
	st.add_vertex(a1)


func _build_fields() -> void:
	var patches := [
		[Vector3(-45, 0, 20), Vector2(21, 13), -7.0, _field_material_a],
		[Vector3(-22, 0, 27), Vector2(17, 12), 4.0, _field_material_b],
		[Vector3(-46, 0, 36), Vector2(18, 10), 2.0, _field_material_b],
		[Vector3(-19, 0, -31), Vector2(22, 9), -5.0, _field_material_a],
		[Vector3(42, 0, 31), Vector2(17, 9), 8.0, _field_material_a],
		[Vector3(52, 0, 14), Vector2(12, 10), -4.0, _field_material_b],
	]
	for i: int in range(patches.size()):
		var data: Array = patches[i]
		var p: Vector3 = data[0]
		p.y = height_at(p.x, p.z) + 0.08
		var size: Vector2 = data[1]
		var patch := MeshInstance3D.new()
		patch.name = "FarmField_%02d" % i
		var plane := PlaneMesh.new()
		plane.size = size
		plane.subdivide_width = 8
		plane.subdivide_depth = 8
		patch.mesh = plane
		patch.position = p
		patch.rotation_degrees.y = float(data[2])
		patch.material_override = data[3]
		add_child(patch)


func _build_roads() -> void:
	_add_road_polyline([
		Vector3(-62, 0, 1.2), Vector3(-34, 0, 0.6), Vector3(-9, 0, 0.0),
		Vector3(1.0, 0, 0.0), Vector3(15.0, 0, 0.0), Vector3(36, 0, -1.5), Vector3(62, 0, -4.0)
	], 3.4, _road_material, "PrimaryRoad")
	_add_road_polyline([
		Vector3(-52, 0, 31), Vector3(-33, 0, 20), Vector3(-18, 0, 8), Vector3(-7, 0, 2)
	], 1.9, _dirt_road_material, "FarmRoad")
	_add_road_polyline([
		Vector3(18, 0, -30), Vector3(23, 0, -16), Vector3(28, 0, -4), Vector3(36, 0, 9), Vector3(48, 0, 22)
	], 2.8, _road_material, "TownSpine")
	_add_road_polyline([
		Vector3(14, 0, 14), Vector3(25, 0, 8), Vector3(39, 0, 4), Vector3(54, 0, 6)
	], 2.0, _dirt_road_material, "EastApproach")
	_add_road_polyline([
		Vector3(15, 0, -8), Vector3(27, 0, -7), Vector3(40, 0, -6), Vector3(56, 0, -5)
	], 2.8, _road_material, "TownCrossStreet")
	_add_road_polyline([
		Vector3(31, 0, -28), Vector3(32, 0, -16), Vector3(33, 0, -4), Vector3(34, 0, 11), Vector3(35, 0, 23)
	], 2.6, _road_material, "TownNorthSouthStreet")


func _add_road_polyline(points: Array, width: float, material: Material, prefix: String) -> void:
	if points.size() < 2:
		return
	if _shoulder_material != null and not prefix.contains("Shoulder"):
		_add_road_ribbon(points, width + 0.7, _shoulder_material, prefix + "_Shoulder", 0.055)
	_add_road_ribbon(points, width, material, prefix, 0.10)


func _add_road_ribbon(points: Array, width: float, material: Material, prefix: String, lift: float) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var lefts: Array[Vector3] = []
	var rights: Array[Vector3] = []
	for i: int in range(points.size()):
		var p: Vector3 = points[i]
		var prev: Vector3 = points[maxi(0, i - 1)]
		var next: Vector3 = points[mini(points.size() - 1, i + 1)]
		var tangent := Vector2(next.x - prev.x, next.z - prev.z).normalized()
		var normal2 := Vector2(-tangent.y, tangent.x) * (width * 0.5)
		var left := Vector3(p.x + normal2.x, height_at(p.x + normal2.x, p.z + normal2.y) + lift, p.z + normal2.y)
		var right := Vector3(p.x - normal2.x, height_at(p.x - normal2.x, p.z - normal2.y) + lift, p.z - normal2.y)
		lefts.append(left)
		rights.append(right)
	for i: int in range(points.size() - 1):
		_add_surface_quad(st, lefts[i], rights[i], lefts[i + 1], rights[i + 1], float(i), float(i + 1))
		road_segment_count += 1
	var road := MeshInstance3D.new()
	road.name = prefix
	road.mesh = st.commit()
	road.material_override = material
	road.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(road)


func _add_flat_segment(name_value: String, a: Vector3, b: Vector3, width: float, material: Material) -> void:
	var delta := b - a
	var horizontal_length := Vector2(delta.x, delta.z).length()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(horizontal_length, 0.07, width)
	var node := MeshInstance3D.new()
	node.name = name_value
	node.mesh = mesh
	node.position = (a + b) * 0.5
	node.rotation.y = -atan2(delta.z, delta.x)
	node.material_override = material
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(node)


func _build_bridge() -> void:
	var deck_y := 0.95
	var west_x := RIVER_X - RIVER_HALF_WIDTH - 2.0
	var east_x := RIVER_X + RIVER_HALF_WIDTH + 2.0
	_add_flat_segment(
		"BridgeDeck",
		Vector3(west_x, deck_y, 0.0),
		Vector3(east_x, deck_y, 0.0),
		4.6,
		_bridge_concrete
	)
	bridge_member_count += 1

	# Four piers, side trusses and diagonal members: visually reads as engineered
	# bridge geometry instead of a single delivery box.
	for x: float in [RIVER_X - 4.0, RIVER_X - 1.3, RIVER_X + 1.3, RIVER_X + 4.0]:
		var pier := MeshInstance3D.new()
		pier.name = "BridgePier"
		var pier_mesh := CylinderMesh.new()
		pier_mesh.top_radius = 0.52
		pier_mesh.bottom_radius = 0.72
		pier_mesh.height = 3.2
		pier_mesh.radial_segments = 12
		pier.mesh = pier_mesh
		pier.position = Vector3(x, -0.55, 0.0)
		pier.material_override = _bridge_concrete
		add_child(pier)
		bridge_member_count += 1

	for z_side: float in [-2.15, 2.15]:
		_add_beam("BridgeTopRail", Vector3(west_x, deck_y + 1.5, z_side), Vector3(east_x, deck_y + 1.5, z_side), 0.18, _bridge_steel)
		for section: int in range(6):
			var xa := lerpf(west_x, east_x, float(section) / 6.0)
			var xb := lerpf(west_x, east_x, float(section + 1) / 6.0)
			_add_beam("BridgeVertical", Vector3(xa, deck_y + 0.15, z_side), Vector3(xa, deck_y + 1.5, z_side), 0.13, _bridge_steel)
			if section % 2 == 0:
				_add_beam("BridgeDiagonal", Vector3(xa, deck_y + 0.20, z_side), Vector3(xb, deck_y + 1.45, z_side), 0.13, _bridge_steel)
			else:
				_add_beam("BridgeDiagonal", Vector3(xa, deck_y + 1.45, z_side), Vector3(xb, deck_y + 0.20, z_side), 0.13, _bridge_steel)


func _add_beam(name_value: String, a: Vector3, b: Vector3, thickness: float, material: Material) -> MeshInstance3D:
	var dir := b - a
	var length := dir.length()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(length, thickness, thickness)
	var node := MeshInstance3D.new()
	node.name = name_value
	node.mesh = mesh
	var x_axis := dir.normalized()
	var z_axis := x_axis.cross(Vector3.UP)
	if z_axis.length_squared() < 0.0001:
		z_axis = Vector3.FORWARD
	z_axis = z_axis.normalized()
	var y_axis := z_axis.cross(x_axis).normalized()
	node.transform = Transform3D(Basis(x_axis, y_axis, z_axis), (a + b) * 0.5)
	node.material_override = material
	add_child(node)
	bridge_member_count += 1
	return node


func _build_town() -> void:
	if city_resource_paths.is_empty():
		return
	var all_buildings := _filter_paths(city_resource_paths, ["building", "house", "commercial", "office", "store", "apartment"])
	if all_buildings.is_empty():
		all_buildings = city_resource_paths.duplicate()

	var low_rise: Array[String] = []
	var landmark_paths: Array[String] = []
	for path: String in all_buildings:
		var lower := path.to_lower()
		if lower.contains("skyscraper"):
			landmark_paths.append(path)
		elif not lower.contains("low-detail"):
			low_rise.append(path)
	var building_paths := low_rise if not low_rise.is_empty() else all_buildings

	# Dense but readable river-town blocks. The primary road and east approach
	# leave real gaps through the settlement rather than creating one asset wall.
	var positions: Array[Vector3] = []
	for row: int in range(5):
		for col: int in range(7):
			var x := 23.0 + float(col) * 6.1 + sin(float(row * 7 + col) * 1.17) * 1.05
			var z := -27.0 + float(row) * 9.6 + cos(float(col * 5 + row) * 0.91) * 1.05
			# Preserve the east-west main street and a north-south town spine.
			if absf(z + 5.8) < 2.0:
				z += 3.8
			if absf(x - 33.0) < 2.3:
				x += 3.6
			positions.append(Vector3(x, 0, z))

	for i: int in range(mini(positions.size(), 6)):
		var path := building_paths[i % building_paths.size()]
		var instance := _instantiate_scene(path)
		if instance == null:
			continue
		var pos := positions[i]
		pos.y = height_at(pos.x, pos.z)
		instance.position = pos
		var street_yaw := 0.0 if i % 3 != 0 else 90.0
		instance.rotation_degrees.y = street_yaw + sin(float(i) * 1.71) * 7.0
		fit_instance_to_size(instance, 4.8 + float(i % 5) * 0.58)
		var preserve_source_materials := path.begins_with("res://assets/golden_scene/city_hq/")
		if not preserve_source_materials and not _building_materials.is_empty():
			var building_material_index: int = 0
			if i % 7 == 0:
				building_material_index = 2
			else:
				var concrete_cycle: Array[int] = [0, 1, 3]
				building_material_index = concrete_cycle[i % concrete_cycle.size()]
			_override_materials(instance, _building_materials[building_material_index])
		instance.name = "TownBuilding_%02d" % i
		add_child(instance)
		town_instance_count += 1

	# One genuine imported tall building provides the approved orientation
	# landmark without turning the whole village into a skyline.
	var landmark_path: String = landmark_paths[0] if not landmark_paths.is_empty() else building_paths[0]
	var church_paths := _filter_paths(city_real_resource_paths, ["church_landmark"])
	if not church_paths.is_empty():
		landmark_path = church_paths[0]
	var landmark := _instantiate_scene(landmark_path)
	if landmark != null:
		fit_instance_to_size(landmark, 13.5)
		landmark.position = Vector3(52.0, height_at(52.0, -34.0), -34.0)
		landmark.rotation_degrees.y = 10.0
		_apply_building_surface_materials(landmark, _church_wall_material, _roof_materials[1], _trim_material)
		landmark.name = "TownChurchLandmark"
		add_child(landmark)
		town_instance_count += 1

	# V7: the split photo-textured assets are shallow shopfront buildings.
	# Treat them as street-scale frontage, not as the settlement's massing.
	if not city_hq_resource_paths.is_empty():
		var hq_positions: Array[Vector3] = [
			Vector3(40.0, 0, -6.8), Vector3(59.0, 0, 7.0)
		]
		for i: int in range(hq_positions.size()):
			var path := city_hq_resource_paths[(i + 2) % city_hq_resource_paths.size()]
			var shop := _instantiate_scene(path)
			if shop == null:
				continue
			var p := hq_positions[i]
			p.y = height_at(p.x, p.z)
			shop.position = p
			shop.rotation_degrees.y = 0.0
			fit_instance_to_size(shop, 4.0 + float(i % 3) * 0.35)
			shop.name = "TownPhotoShop_%02d" % i
			add_child(shop)
			town_instance_count += 1

	# V12: properly exported CC0 house source retains its authored textures.
	# Repeated rotations/scales build a low-rise river town; one real church is
	# the sole vertical landmark.
	var real_house_paths := _filter_paths(city_real_resource_paths, ["ordinary_house_textured"])
	if not real_house_paths.is_empty():
		var house_path := real_house_paths[0]
		var house_positions: Array[Vector3] = [
			Vector3(28.0, 0, -25.0), Vector3(39.0, 0, -24.0), Vector3(65.0, 0, -22.0),
			Vector3(29.0, 0, -12.0), Vector3(48.0, 0, -13.0), Vector3(67.0, 0, -10.0),
			Vector3(28.0, 0, 8.0), Vector3(43.0, 0, 10.0), Vector3(60.0, 0, 11.0),
			Vector3(72.0, 0, 18.0), Vector3(36.0, 0, 23.0), Vector3(54.0, 0, 24.0)
		]
		for i: int in range(house_positions.size()):
			var house := _instantiate_scene(house_path)
			if house == null:
				continue
			var p := house_positions[i]
			p.y = height_at(p.x, p.z)
			house.position = p
			house.rotation_degrees.y = float((i % 4) * 90) + sin(float(i) * 1.31) * 4.0
			fit_instance_to_size(house, 5.4 + float(i % 3) * 0.42)
			var wall_cycle: Array[int] = [1, 2, 0, 3]
			var wall_material := _building_materials[wall_cycle[i % wall_cycle.size()]]
			var roof_material := _roof_materials[i % _roof_materials.size()]
			_apply_building_surface_materials(house, wall_material, roof_material, _trim_material)
			house.name = "TownTexturedHouse_%02d" % i
			add_child(house)
			town_instance_count += 1


func _build_forests_and_hedgerows() -> void:
	if nature_resource_paths.is_empty():
		return
	var tree_paths: Array[String] = []
	for hq_path: String in nature_hq_resource_paths:
		var lower := hq_path.to_lower()
		if (lower.contains("ea01_env_tree_01c.glb") or lower.contains("ea01_env_tree_02a.glb") or lower.contains("ea01_env_tree_03a.glb") or lower.contains("ea01_env_tree_04a.glb") or lower.contains("ea01_env_tree_05d.glb") or lower.contains("ea01_env_tree_06d.glb")):
			tree_paths.append(hq_path)
	if tree_paths.is_empty():
		tree_paths = _filter_paths(nature_resource_paths, ["tree", "trunk"])
	if tree_paths.is_empty():
		tree_paths = nature_resource_paths.duplicate()

	# Dense west/north ridge forest.
	for i: int in range(36):
		var t := float(i)
		var x := -54.0 + fmod(t * 7.7, 37.0)
		var z := -38.0 + fmod(t * 11.3, 28.0)
		if i % 3 == 0:
			x = 47.0 + fmod(t * 3.1, 14.0)
			z = -40.0 + fmod(t * 8.9, 70.0)
		_add_nature_instance(tree_paths[i % tree_paths.size()], Vector3(x, 0, z), 4.6 + float(i % 5) * 0.55, float((i * 41) % 360))

	var hedge_paths := _filter_paths(nature_hq_resource_paths, ["Env_Bush_02b.glb", "Env_Bush_02c.glb", "Env_Bush_02d.glb", "Env_Bush_02f.glb"])
	if not hedge_paths.is_empty():
		for i: int in range(8):
			var x := -48.0 + float(i) * 4.1
			var z := 31.0 + sin(float(i) * 1.43) * 2.8
			_add_nature_instance(hedge_paths[i % hedge_paths.size()], Vector3(x, 0, z), 1.15 + float(i % 3) * 0.14, float((i * 29) % 360))

	# Distant tree screen adds scale/depth behind the defended settlement.
	if not tree_paths.is_empty():
		for i: int in range(18):
			var x := 22.0 + float(i) * 2.85
			var z := -49.0 + sin(float(i) * 1.37) * 4.2
			_add_nature_instance(tree_paths[i % tree_paths.size()], Vector3(x, 0, z), 5.0 + float(i % 4) * 0.55, float((i * 53) % 360))


func _add_nature_instance(path: String, p: Vector3, target_size: float, yaw: float) -> void:
	var instance := _instantiate_scene(path)
	if instance == null:
		return
	p.y = height_at(p.x, p.z)
	instance.position = p
	instance.rotation_degrees.y = yaw
	fit_instance_to_size(instance, target_size)
	var lower_path := path.to_lower()
	if path.begins_with("res://assets/golden_scene/nature_hq/"):
		var hq_material_index := absi(path.hash()) % _foliage_materials.size()
		_override_materials(instance, _foliage_materials[hq_material_index])
	elif lower_path.contains("rock") or lower_path.contains("cliff"):
		_override_materials(instance, _rock_material)
	elif not _foliage_materials.is_empty():
		var material_index := absi(path.hash()) % _foliage_materials.size()
		_override_materials(instance, _foliage_materials[material_index])
	add_child(instance)
	tree_instance_count += 1


func _build_camera() -> void:
	camera = Camera3D.new()
	camera.name = "GoldenTacticalCamera"
	camera.current = true
	camera.fov = 42.0
	camera.near = 0.15
	camera.far = 360.0
	# Golden Frame composition: BLUE foreground at lower-left, bridge on the
	# central diagonal, dense town and RED contact beyond it. Roughly 46 degrees
	# downward so terrain dominates instead of the horizon/sky.
	camera.position = Vector3(-60.0, 33.0, 56.0)
	add_child(camera)
	camera.look_at(Vector3(4.0, 1.0, -1.5), Vector3.UP)


func _find_3d_resources(root: String) -> Array[String]:
	var result: Array[String] = []
	_scan_resources_recursive(root, result)
	result.sort()
	return result


func _scan_resources_recursive(path: String, result: Array[String]) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		return
	dir.list_dir_begin()
	while true:
		var entry := dir.get_next()
		if entry.is_empty():
			break
		if entry.begins_with("."):
			continue
		var full := path.path_join(entry)
		if dir.current_is_dir():
			_scan_resources_recursive(full, result)
		else:
			var ext := entry.get_extension().to_lower()
			if ext in ["glb", "gltf"]:
				result.append(full)
	dir.list_dir_end()


func _filter_paths(paths: Array[String], tokens: Array[String]) -> Array[String]:
	var out: Array[String] = []
	for path: String in paths:
		var lower := path.to_lower()
		for token: String in tokens:
			if lower.contains(token.to_lower()):
				out.append(path)
				break
	return out


func _instantiate_scene(path: String) -> Node3D:
	var resource := load(path)
	if resource is PackedScene:
		var node := (resource as PackedScene).instantiate()
		if node is Node3D:
			return node as Node3D
	return null


func _apply_building_surface_materials(root: Node3D, wall_material: Material, roof_material: Material, trim_material: Material) -> void:
	if root is MeshInstance3D:
		var mesh_instance := root as MeshInstance3D
		if mesh_instance.mesh != null:
			for surface: int in range(mesh_instance.mesh.get_surface_count()):
				var key: String = (mesh_instance.name + " " + mesh_instance.mesh.surface_get_name(surface)).to_lower()
				var source_material := mesh_instance.mesh.surface_get_material(surface)
				if source_material != null:
					key += " " + source_material.resource_name.to_lower()
				var chosen: Material = wall_material
				if key.contains("roof") or key.contains("tile") or key.contains("shingle") or key.contains("top"):
					chosen = roof_material
				elif key.contains("window") or key.contains("glass") or key.contains("door") or key.contains("trim") or key.contains("frame"):
					chosen = trim_material
				mesh_instance.set_surface_override_material(surface, chosen)
	for child: Node in root.get_children():
		if child is Node3D:
			_apply_building_surface_materials(child as Node3D, wall_material, roof_material, trim_material)


func _override_materials(root: Node3D, material: Material) -> void:
	if root is MeshInstance3D:
		(root as MeshInstance3D).material_override = material
	for child: Node in root.get_children():
		if child is Node3D:
			_override_materials(child as Node3D, material)


func _standard_material(color: Color, metallic: float, roughness: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.metallic = metallic
	material.roughness = roughness
	return material


func _surface_detail_material(asset_id: String, base_color: Color, detail_strength: float) -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
shader_type spatial;
uniform sampler2D detail_diff : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D detail_nor : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
uniform vec3 base_color : source_color;
uniform float detail_strength = 0.2;
void fragment() {
	vec2 uv = UV * 1.6;
	vec3 tex = texture(detail_diff, uv).rgb;
	float l = dot(tex, vec3(0.2126, 0.7152, 0.0722));
	vec3 normalized_detail = mix(vec3(l), tex, 0.45);
	ALBEDO = mix(base_color, normalized_detail * base_color * 1.75, detail_strength);
	NORMAL_MAP = texture(detail_nor, uv).rgb;
	NORMAL_MAP_DEPTH = 0.18;
	ROUGHNESS = 0.84;
	METALLIC = 0.0;
	SPECULAR = 0.28;
}
"""
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("detail_diff", load("res://assets/golden_scene/pbr/%s_diff_1k.png" % asset_id))
	material.set_shader_parameter("detail_nor", load("res://assets/golden_scene/pbr/%s_nor_gl_1k.png" % asset_id))
	material.set_shader_parameter("base_color", Vector3(base_color.r, base_color.g, base_color.b))
	material.set_shader_parameter("detail_strength", detail_strength)
	return material


func _pbr_material(asset_id: String, tile: Vector3, tint: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = tint
	material.albedo_texture = load("res://assets/golden_scene/pbr/%s_diff_1k.png" % asset_id)
	material.normal_enabled = true
	material.normal_texture = load("res://assets/golden_scene/pbr/%s_nor_gl_1k.png" % asset_id)
	material.roughness = 0.82
	material.uv1_scale = tile
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	return material


func _field_shader(a: Color, b: Color) -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
shader_type spatial;
uniform vec3 color_a : source_color;
uniform vec3 color_b : source_color;
void fragment() {
	float rows = smoothstep(0.42, 0.68, abs(sin(UV.x * 82.0)));
	float cross = 0.975 + 0.025 * sin(UV.y * 42.0);
	ALBEDO = mix(color_a, color_b, rows * 0.20) * cross;
	ROUGHNESS = 0.96;
}
"""
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("color_a", Vector3(a.r, a.g, a.b))
	material.set_shader_parameter("color_b", Vector3(b.r, b.g, b.b))
	return material
