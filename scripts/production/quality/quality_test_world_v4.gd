extends "res://scripts/production/quality/quality_test_world_v3.gd"

const REAL_PINE := "res://assets/golden_scene/nature_real/pine_sapling_small_lod.glb"
const QUALITY_HDRI := "res://assets/golden_scene/hdri/hochsal_field_1k.hdr"

const X_MIN := -92.0
const X_MAX := 92.0
const Z_MIN := -72.0
const Z_MAX := 72.0

func _preflight() -> void:
	for path: String in [MBT, IFV, HOUSE_0, HOUSE_1, HOUSE_2, HOUSE_3, REAL_PINE, QUALITY_HDRI]:
		var ok := FileAccess.file_exists(path) if path.ends_with(".hdr") else ResourceLoader.exists(path)
		if not ok:
			push_error("QUALITY_TEST_REQUIRED_ASSET_MISSING path=%s" % path)


func _build_environment() -> void:
	var env_node := WorldEnvironment.new()
	env_node.name = "QualityEnvironment"
	var env := Environment.new()
	var panorama := PanoramaSkyMaterial.new()
	panorama.panorama = load(QUALITY_HDRI)
	panorama.energy_multiplier = 0.86
	var sky := Sky.new()
	sky.sky_material = panorama
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.background_energy_multiplier = 0.82
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.62
	env.reflected_light_source = Environment.REFLECTION_SOURCE_SKY
	env.fog_enabled = true
	env.fog_light_color = Color(0.58,0.61,0.58)
	env.fog_light_energy = 0.54
	env.fog_density = 0.00155
	env.fog_height = 4.0
	env.fog_height_density = 0.006
	env.fog_aerial_perspective = 0.38
	env.fog_sky_affect = 0.16
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.adjustment_enabled = true
	env.adjustment_contrast = 1.05
	env.adjustment_saturation = 0.94
	env_node.environment = env
	add_child(env_node)

	var sun := DirectionalLight3D.new()
	sun.name = "QualityKeySun"
	sun.rotation_degrees = Vector3(-46.0,-34.0,0.0)
	sun.light_color = Color(1.0,0.93,0.84)
	sun.light_energy = 1.42
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 120.0
	add_child(sun)


func _build_ground() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var nx := 97
	var nz := 73
	var dx := (X_MAX - X_MIN) / float(nx - 1)
	var dz := (Z_MAX - Z_MIN) / float(nz - 1)
	for zi: int in range(nz - 1):
		for xi: int in range(nx - 1):
			var x0 := X_MIN + float(xi) * dx
			var x1 := x0 + dx
			var z0 := Z_MIN + float(zi) * dz
			var z1 := z0 + dz
			var p00 := Vector3(x0,_terrain_height(x0,z0),z0)
			var p10 := Vector3(x1,_terrain_height(x1,z0),z0)
			var p01 := Vector3(x0,_terrain_height(x0,z1),z1)
			var p11 := Vector3(x1,_terrain_height(x1,z1),z1)
			_add_terrain_vertex(st,p00)
			_add_terrain_vertex(st,p10)
			_add_terrain_vertex(st,p01)
			_add_terrain_vertex(st,p10)
			_add_terrain_vertex(st,p11)
			_add_terrain_vertex(st,p01)
	var terrain := MeshInstance3D.new()
	terrain.name = "QualitySculptedTerrain"
	terrain.mesh = st.commit()
	terrain.material_override = _quality_terrain_material()
	terrain.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	add_child(terrain)

	var road_points: Array[Vector3] = [
		Vector3(-9,0,34), Vector3(-4,0,23), Vector3(1,0,14),
		Vector3(7,0,6), Vector3(15,0,-1), Vector3(25,0,-8), Vector3(39,0,-13)
	]
	_add_road_ribbon(road_points,8.2,"gravel_ground_01",Color(0.42,0.39,0.33),"QualityRoadShoulder",0.040)
	_add_road_ribbon(road_points,5.8,"grass_path_3",Color(0.55,0.49,0.38),"QualityVillageRoad",0.060)

	for data: Array in [
		[Vector3(18,0,-12),Vector2(14,10),8.0,"gravel_ground_01",Color(0.46,0.43,0.37)],
		[Vector3(26,0,-2),Vector2(15,10),-8.0,"dirt_aerial_03",Color(0.54,0.47,0.36)],
		[Vector3(19,0,9),Vector2(14,10),6.0,"aerial_mud_1",Color(0.39,0.32,0.24)],
		[Vector3(10,0,18),Vector2(13,9),-5.0,"gravel_ground_01",Color(0.44,0.42,0.36)]
	]:
		var p: Vector3 = data[0]
		p.y = _terrain_height(p.x,p.z) + 0.075
		_add_masked_patch("QualityYard",p,data[1],data[2],data[3],data[4])


func _terrain_height(x: float, z: float) -> float:
	var rolling := 0.55 * sin(x * 0.045) + 0.38 * cos(z * 0.058) + 0.22 * sin((x + z) * 0.075)
	var west_rise := 1.15 * exp(-pow((x + 40.0) / 30.0,2.0) - pow((z + 25.0) / 35.0,2.0))
	var town_shelf := -0.42 * exp(-pow((x - 18.0) / 24.0,2.0) - pow((z - 2.0) / 28.0,2.0))
	var shell_dip := -0.32 * exp(-pow((x - 7.0) / 7.0,2.0) - pow((z - 2.0) / 7.0,2.0))
	return rolling + west_rise + town_shelf + shell_dip


func _terrain_normal(x: float, z: float) -> Vector3:
	var e := 0.45
	var dx := _terrain_height(x + e,z) - _terrain_height(x - e,z)
	var dz := _terrain_height(x,z + e) - _terrain_height(x,z - e)
	return Vector3(-dx / (2.0 * e),1.0,-dz / (2.0 * e)).normalized()


func _add_terrain_vertex(st: SurfaceTool, p: Vector3) -> void:
	st.set_normal(_terrain_normal(p.x,p.z))
	st.set_uv(Vector2((p.x-X_MIN)/(X_MAX-X_MIN),(p.z-Z_MIN)/(Z_MAX-Z_MIN)))
	st.add_vertex(p)


func _quality_terrain_material() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
shader_type spatial;
uniform sampler2D grass_diff : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D grass_nor : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D dirt_diff : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D dirt_nor : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D mud_diff : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D mud_nor : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
varying vec3 wp;
void vertex(){ wp=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz; }
void fragment(){
	vec2 uv=UV*22.0;
	vec3 grass=texture(grass_diff,uv).rgb*vec3(0.62,0.74,0.52);
	vec3 dirt=texture(dirt_diff,uv*0.82).rgb*vec3(0.68,0.58,0.44);
	vec3 mud=texture(mud_diff,uv*0.72).rgb*vec3(0.60,0.50,0.39);
	float town=1.0-smoothstep(10.0,34.0,length(wp.xz-vec2(18.0,2.0)));
	float churn=1.0-smoothstep(5.0,20.0,length(wp.xz-vec2(-5.0,12.0)));
	float scar=1.0-smoothstep(3.0,11.0,length(wp.xz-vec2(8.0,1.0)));
	float dirt_mix=clamp(town*0.30+churn*0.18,0.0,0.42);
	float mud_mix=clamp(scar*0.34+churn*0.12,0.0,0.40);
	vec3 base=mix(grass,dirt,dirt_mix);
	base=mix(base,mud,mud_mix);
	ALBEDO=base;
	NORMAL_MAP=mix(mix(texture(grass_nor,uv).rgb,texture(dirt_nor,uv*0.82).rgb,dirt_mix),texture(mud_nor,uv*0.72).rgb,mud_mix);
	NORMAL_MAP_DEPTH=0.56;
	ROUGHNESS=0.91;
	SPECULAR=0.26;
}
"""
	var mat := ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("grass_diff",load("res://assets/golden_scene/pbr/leafy_grass_diff_1k.png"))
	mat.set_shader_parameter("grass_nor",load("res://assets/golden_scene/pbr/leafy_grass_nor_gl_1k.png"))
	mat.set_shader_parameter("dirt_diff",load("res://assets/golden_scene/pbr/dirt_aerial_03_diff_1k.png"))
	mat.set_shader_parameter("dirt_nor",load("res://assets/golden_scene/pbr/dirt_aerial_03_nor_gl_1k.png"))
	mat.set_shader_parameter("mud_diff",load("res://assets/golden_scene/pbr/aerial_mud_1_diff_1k.png"))
	mat.set_shader_parameter("mud_nor",load("res://assets/golden_scene/pbr/aerial_mud_1_nor_gl_1k.png"))
	return mat


func _add_road_ribbon(points: Array[Vector3], width: float, texture_id: String, tint: Color, name_value: String, y_offset: float) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var distance_accum := 0.0
	for i: int in range(points.size()-1):
		var a := points[i]
		var b := points[i+1]
		a.y = _terrain_height(a.x,a.z) + y_offset
		b.y = _terrain_height(b.x,b.z) + y_offset
		var dir := Vector2(b.x-a.x,b.z-a.z).normalized()
		var side := Vector2(-dir.y,dir.x) * (width * 0.5)
		var al := Vector3(a.x+side.x,_terrain_height(a.x+side.x,a.z+side.y)+y_offset,a.z+side.y)
		var ar := Vector3(a.x-side.x,_terrain_height(a.x-side.x,a.z-side.y)+y_offset,a.z-side.y)
		var bl := Vector3(b.x+side.x,_terrain_height(b.x+side.x,b.z+side.y)+y_offset,b.z+side.y)
		var br := Vector3(b.x-side.x,_terrain_height(b.x-side.x,b.z-side.y)+y_offset,b.z-side.y)
		var seg_len := a.distance_to(b)
		var v0 := distance_accum / 5.0
		var v1 := (distance_accum + seg_len) / 5.0
		_add_ribbon_vertex(st,al,Vector2(0.0,v0))
		_add_ribbon_vertex(st,ar,Vector2(1.0,v0))
		_add_ribbon_vertex(st,bl,Vector2(0.0,v1))
		_add_ribbon_vertex(st,ar,Vector2(1.0,v0))
		_add_ribbon_vertex(st,br,Vector2(1.0,v1))
		_add_ribbon_vertex(st,bl,Vector2(0.0,v1))
		distance_accum += seg_len
	var road := MeshInstance3D.new()
	road.name = name_value
	road.mesh = st.commit()
	road.material_override = _road_material(texture_id,tint)
	add_child(road)


func _add_ribbon_vertex(st: SurfaceTool, p: Vector3, uv: Vector2) -> void:
	st.set_normal(_terrain_normal(p.x,p.z))
	st.set_uv(uv)
	st.add_vertex(p)


func _road_material(texture_id: String, tint: Color) -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
shader_type spatial;
render_mode blend_mix, depth_prepass_alpha, cull_back;
uniform sampler2D diff : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D nor : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
uniform vec3 tint : source_color;
void fragment(){
	float edge=smoothstep(0.0,0.13,UV.x)*smoothstep(0.0,0.13,1.0-UV.x);
	vec3 tex=texture(diff,UV).rgb;
	ALBEDO=tex*tint;
	NORMAL_MAP=texture(nor,UV).rgb;
	NORMAL_MAP_DEPTH=0.42;
	ROUGHNESS=0.92;
	ALPHA=edge;
}
"""
	var mat := ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("diff",load("res://assets/golden_scene/pbr/%s_diff_1k.png" % texture_id))
	mat.set_shader_parameter("nor",load("res://assets/golden_scene/pbr/%s_nor_gl_1k.png" % texture_id))
	mat.set_shader_parameter("tint",Vector3(tint.r,tint.g,tint.b))
	return mat


func _build_buildings() -> void:
	var placements: Array = [
		[HOUSE_0,Vector3(18,0,-12),10.6,8.0,"FamilyHouseA"],
		[HOUSE_1,Vector3(26,0,-2),11.2,-12.0,"FamilyHouseB"],
		[HOUSE_2,Vector3(19,0,9),10.8,7.0,"DamagedFamilyHouse"],
		[HOUSE_3,Vector3(10,0,18),10.4,-7.0,"FamilyHouseD"]
	]
	for d: Array in placements:
		var p: Vector3 = d[1]
		p.y = _terrain_height(p.x,p.z) + 0.09
		var node := _add_asset(d[0],p,d[2],d[3],d[4])
		if node != null and d[4] == "DamagedFamilyHouse":
			_tint_surfaces(node,Color(0.55,0.48,0.40))
	building_count = 4


func _build_vehicles() -> void:
	var p_mbt := Vector3(-9,0,10)
	p_mbt.y = _terrain_height(p_mbt.x,p_mbt.z) + 0.16
	var mbt := _add_asset(MBT,p_mbt,8.0,-68.0,"HeroAbrams")
	if mbt != null:
		_override_material(mbt,_vehicle_material(Color(0.29,0.32,0.17),0.30))
	var p_ifv := Vector3(-1,0,15)
	p_ifv.y = _terrain_height(p_ifv.x,p_ifv.z) + 0.14
	var ifv := _add_asset(IFV,p_ifv,6.4,-73.0,"SupportIFV")
	if ifv != null:
		_override_material(ifv,_vehicle_material(Color(0.25,0.28,0.15),0.24))
	var p_wreck := Vector3(9,0,1)
	p_wreck.y = _terrain_height(p_wreck.x,p_wreck.z) + 0.11
	var wreck := _add_asset(IFV,p_wreck,5.7,36.0,"BurnedIFV")
	if wreck != null:
		wreck.rotation_degrees.z = -6.0
		_override_material(wreck,_wreck_material())
	vehicle_count = 3


func _build_trees() -> void:
	var placements: Array = [
		[Vector3(39,0,-18),12.5,18.0],
		[Vector3(40,0,8),11.2,102.0],
		[Vector3(31,0,28),13.0,218.0],
		[Vector3(-34,0,-22),12.0,304.0]
	]
	for i: int in range(placements.size()):
		var d: Array = placements[i]
		var p: Vector3 = d[0]
		p.y = _terrain_height(p.x,p.z)
		_add_asset(REAL_PINE,p,d[1],d[2],"RealPine_%02d" % i)
		tree_count += 1


func _build_camera() -> void:
	camera = Camera3D.new()
	camera.name = "QualityCamera"
	camera.fov = 43.0
	camera.position = Vector3(-25.0,18.5,29.0)
	add_child(camera)
	camera.look_at(Vector3(8.0,1.0,2.0),Vector3.UP)
	camera.current = true
