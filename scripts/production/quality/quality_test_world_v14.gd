extends "res://scripts/production/quality/quality_test_world_v13.gd"

func _build_environment() -> void:
	var env_node := WorldEnvironment.new()
	env_node.name = "QualityEnvironment"
	var env := Environment.new()

	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.27,0.36,0.44)
	sky_mat.sky_horizon_color = Color(0.60,0.61,0.58)
	sky_mat.ground_bottom_color = Color(0.20,0.21,0.18)
	sky_mat.ground_horizon_color = Color(0.46,0.47,0.41)
	sky_mat.sun_angle_max = 8.0
	var sky := Sky.new()
	sky.sky_material = sky_mat

	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.background_energy_multiplier = 0.95
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.72
	env.reflected_light_source = Environment.REFLECTION_SOURCE_SKY

	env.fog_enabled = true
	env.fog_light_color = Color(0.56,0.58,0.55)
	env.fog_light_energy = 0.56
	env.fog_density = 0.0029
	env.fog_height = 4.5
	env.fog_height_density = 0.007
	env.fog_aerial_perspective = 0.52
	env.fog_sky_affect = 0.22

	env.ssao_enabled = true
	env.ssao_radius = 1.25
	env.ssao_intensity = 0.85
	env.ssao_power = 1.05
	env.ssao_detail = 0.55
	env.ssao_light_affect = 0.10

	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.adjustment_enabled = true
	env.adjustment_brightness = 1.02
	env.adjustment_contrast = 1.04
	env.adjustment_saturation = 0.91

	env_node.environment = env
	add_child(env_node)

	var sun := DirectionalLight3D.new()
	sun.name = "QualityKeySun"
	sun.rotation_degrees = Vector3(-46.0,-37.0,0.0)
	sun.light_color = Color(1.0,0.93,0.84)
	sun.light_energy = 1.05
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 125.0
	sun.shadow_bias = 0.045
	sun.shadow_normal_bias = 1.2
	add_child(sun)

	var fill := DirectionalLight3D.new()
	fill.name = "QualityCoolFill"
	fill.rotation_degrees = Vector3(-58.0,142.0,0.0)
	fill.light_color = Color(0.48,0.57,0.64)
	fill.light_energy = 0.22
	add_child(fill)


func _build_ground() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var nx := 121
	var nz := 105
	var dx := (V5_X_MAX-V5_X_MIN)/float(nx-1)
	var dz := (V5_Z_MAX-V5_Z_MIN)/float(nz-1)
	for zi: int in range(nz-1):
		for xi: int in range(nx-1):
			var x0 := V5_X_MIN+float(xi)*dx
			var x1 := x0+dx
			var z0 := V5_Z_MIN+float(zi)*dz
			var z1 := z0+dz
			var p00 := Vector3(x0,_terrain_height(x0,z0),z0)
			var p10 := Vector3(x1,_terrain_height(x1,z0),z0)
			var p01 := Vector3(x0,_terrain_height(x0,z1),z1)
			var p11 := Vector3(x1,_terrain_height(x1,z1),z1)
			_add_v5_terrain_vertex(st,p00)
			_add_v5_terrain_vertex(st,p10)
			_add_v5_terrain_vertex(st,p01)
			_add_v5_terrain_vertex(st,p10)
			_add_v5_terrain_vertex(st,p11)
			_add_v5_terrain_vertex(st,p01)

	var terrain := MeshInstance3D.new()
	terrain.name = "DesignMacroTerrain"
	terrain.mesh = st.commit()
	terrain.material_override = _design_terrain_material()
	terrain.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	add_child(terrain)

	var road_points: Array[Vector3] = [
		Vector3(-22,0,73),Vector3(-14,0,50),Vector3(-8,0,34),
		Vector3(-3,0,23),Vector3(2,0,14),Vector3(8,0,6),
		Vector3(16,0,-2),Vector3(27,0,-9),Vector3(43,0,-15)
	]
	_add_road_ribbon(
		road_points,7.0,"gravel_ground_01",
		Color(0.47,0.44,0.38),"DesignRoadShoulder",0.055
	)
	_add_road_ribbon(
		road_points,4.6,"grass_path_3",
		Color(0.50,0.44,0.34),"DesignVillageRoad",0.075
	)

	_add_scorch_patch(Vector3(10,0,3),7.0,15.0)
	_add_scorch_patch(Vector3(17,0,10),5.4,-6.0)


func _design_terrain_material() -> ShaderMaterial:
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
	vec2 uv=UV*24.0;
	vec3 grass=texture(grass_diff,uv).rgb*vec3(0.58,0.68,0.47);
	vec3 dirt=texture(dirt_diff,uv*0.82).rgb*vec3(0.70,0.60,0.45);
	vec3 mud=texture(mud_diff,uv*0.72).rgb*vec3(0.58,0.49,0.38);

	vec2 pa=(wp.xz-vec2(-42.0,-35.0))/vec2(38.0,18.0);
	float field_a=1.0-smoothstep(0.72,1.05,length(pa));
	vec2 pb=(wp.xz-vec2(47.0,-48.0))/vec2(33.0,16.0);
	float field_b=1.0-smoothstep(0.74,1.05,length(pb));
	vec2 pt=(wp.xz-vec2(20.0,1.0))/vec2(30.0,26.0);
	float town=1.0-smoothstep(0.58,1.0,length(pt));
	vec2 pc=(wp.xz-vec2(-5.0,10.0))/vec2(19.0,11.0);
	float churn=1.0-smoothstep(0.55,1.0,length(pc));

	float dirt_mix=clamp(field_a*0.36+town*0.22,0.0,0.48);
	float mud_mix=clamp(churn*0.34+town*0.08,0.0,0.40);
	vec3 base=mix(grass,dirt,dirt_mix);
	base=mix(base,mud,mud_mix);
	base=mix(base,base*vec3(0.82,0.90,0.76),field_b*0.22);

	ALBEDO=base;
	NORMAL_MAP=mix(
		mix(texture(grass_nor,uv).rgb,texture(dirt_nor,uv*0.82).rgb,dirt_mix),
		texture(mud_nor,uv*0.72).rgb,mud_mix
	);
	NORMAL_MAP_DEPTH=0.48;
	ROUGHNESS=0.91;
	SPECULAR=0.25;
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


func _build_vehicles() -> void:
	var p_mbt := Vector3(-8,0,13)
	p_mbt.y = _terrain_height(p_mbt.x,p_mbt.z)+0.14
	var mbt := _add_asset(MBT,p_mbt,6.6,-57.0,"HeroAbrams")
	if mbt != null:
		_override_material(mbt,_solid_vehicle_material(Color(0.30,0.33,0.17),0.16))

	var p_ifv := Vector3(-4,0,5)
	p_ifv.y = _terrain_height(p_ifv.x,p_ifv.z)+0.12
	var ifv := _add_asset(IFV,p_ifv,5.2,-39.0,"SupportIFV")
	if ifv != null:
		_override_material(ifv,_solid_vehicle_material(Color(0.28,0.31,0.16),0.14))

	var p_wreck := Vector3(10,0,3)
	p_wreck.y = _terrain_height(p_wreck.x,p_wreck.z)+0.09
	var wreck := _add_asset(IFV,p_wreck,4.8,37.0,"BurnedIFV")
	if wreck != null:
		wreck.rotation_degrees.z=-6.0
		_override_material(wreck,_wreck_material())

	var p_red := Vector3(31,0,-6)
	p_red.y = _terrain_height(p_red.x,p_red.z)+0.11
	var red_ifv := _add_asset(IFV,p_red,4.9,142.0,"EnemyIFV")
	if red_ifv != null:
		_override_material(red_ifv,_solid_vehicle_material(Color(0.23,0.14,0.09),0.12))

	_add_infantry_group()
	vehicle_count=4


func _solid_vehicle_material(color: Color, metallic_value: float) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color=color
	mat.metallic=metallic_value
	mat.metallic_specular=0.34
	mat.roughness=0.76
	return mat
