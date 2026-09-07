extends "res://scripts/production/quality/quality_test_world_v16.gd"

func _build_environment() -> void:
	var env_node := WorldEnvironment.new()
	env_node.name = "V16EnvironmentRefined"
	var env := Environment.new()

	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.36,0.47,0.58)
	sky_mat.sky_horizon_color = Color(0.72,0.70,0.62)
	sky_mat.ground_bottom_color = Color(0.18,0.20,0.16)
	sky_mat.ground_horizon_color = Color(0.53,0.52,0.43)
	sky_mat.sun_angle_max = 6.0
	var sky := Sky.new()
	sky.sky_material = sky_mat

	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.background_energy_multiplier = 1.10
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.86
	env.reflected_light_source = Environment.REFLECTION_SOURCE_SKY

	env.fog_enabled = true
	env.fog_light_color = Color(0.66,0.67,0.62)
	env.fog_light_energy = 0.62
	env.fog_density = 0.0024
	env.fog_height = 5.0
	env.fog_height_density = 0.006
	env.fog_aerial_perspective = 0.48
	env.fog_sky_affect = 0.18

	env.volumetric_fog_enabled = true
	env.volumetric_fog_density = 0.0032
	env.volumetric_fog_albedo = Color(0.78,0.77,0.72)
	env.volumetric_fog_emission = Color(0.015,0.014,0.012)
	env.volumetric_fog_emission_energy = 0.12
	env.volumetric_fog_length = 52.0
	env.volumetric_fog_detail_spread = 2.3
	env.volumetric_fog_ambient_inject = 0.58

	env.ssao_enabled = true
	env.ssao_radius = 1.45
	env.ssao_intensity = 1.05
	env.ssao_power = 1.08
	env.ssao_detail = 0.62
	env.ssao_light_affect = 0.11

	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.adjustment_enabled = true
	env.adjustment_brightness = 1.06
	env.adjustment_contrast = 1.05
	env.adjustment_saturation = 0.96

	env_node.environment = env
	add_child(env_node)

	var sun := DirectionalLight3D.new()
	sun.name = "V16WarmSunRefined"
	sun.rotation_degrees = Vector3(-36.0,-48.0,0.0)
	sun.light_color = Color(1.0,0.88,0.72)
	sun.light_energy = 1.35
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 145.0
	sun.shadow_bias = 0.040
	sun.shadow_normal_bias = 1.0
	add_child(sun)

	var fill := DirectionalLight3D.new()
	fill.name = "V16CoolFillRefined"
	fill.rotation_degrees = Vector3(-62.0,140.0,0.0)
	fill.light_color = Color(0.44,0.57,0.69)
	fill.light_energy = 0.25
	add_child(fill)


func _road_mask(x: float,z: float) -> float:
	var d := _road_distance(Vector2(x,z))
	return 1.0-smoothstep(1.9,4.8,d)


func _terrain_height(x: float,z: float) -> float:
	var rolling := 0.54*sin(x*0.044)+0.36*cos(z*0.057)+0.22*sin((x+z)*0.071)
	var broad := 0.62*exp(-pow((x+42.0)/38.0,2.0)-pow((z+28.0)/42.0,2.0))
	var town := _town_mask(x,z)
	var village_level := 0.06+0.08*sin(x*0.055)
	var base := lerpf(rolling+broad,village_level,town*0.68)
	var road := _road_mask(x,z)
	base -= road*0.24
	var field := _field_mask(x,z)
	base += field*(0.08*sin(x*0.58+z*0.12)+0.05*sin(x*0.23-z*0.41))
	base -= _crater(x,z,11.0,3.0,4.1,0.44)
	base -= _crater(x,z,18.0,11.0,3.3,0.34)
	base -= _crater(x,z,-22.0,-10.0,3.7,0.27)
	return base


func _terrain_material_v16() -> ShaderMaterial:
	var mat := super._terrain_material_v16()
	if mat != null and mat.shader != null:
		var code := mat.shader.code
		code = code.replace("vec3(0.58,0.67,0.44)","vec3(0.64,0.76,0.49)")
		code = code.replace("vec3(0.66,0.55,0.39)","vec3(0.59,0.49,0.34)")
		code = code.replace("vec3(0.50,0.41,0.31)","vec3(0.43,0.35,0.27)")
		code = code.replace("road*0.82","road*0.66")
		code = code.replace("town*0.19","town*0.10")
		code = code.replace("road*0.20","road*0.26")
		code = code.replace("field*0.22","field*0.32")
		mat.shader.code = code
	return mat


func _build_trees() -> void:
	var tree_placements: Array = [
		[Vector3(-34,0,-34),10.0,14.0],
		[Vector3(-24,0,-39),10.8,48.0],
		[Vector3(-12,0,-41),9.4,88.0],
		[Vector3(1,0,-42),10.5,133.0],
		[Vector3(14,0,-41),9.7,176.0],
		[Vector3(27,0,-39),10.8,218.0],
		[Vector3(40,0,-36),9.6,262.0],
		[Vector3(51,0,-31),10.4,314.0],
		[Vector3(57,0,-20),9.6,31.0],
		[Vector3(49,0,15),9.4,65.0],
		[Vector3(39,0,25),9.8,126.0],
		[Vector3(-29,0,24),9.3,204.0]
	]
	for i: int in range(tree_placements.size()):
		var d: Array = tree_placements[i]
		var p: Vector3 = d[0]
		p.y = _terrain_height(p.x,p.z)
		_add_asset(TREE_HERO,p,d[1],d[2],"V16TreeRefined_%02d" % i)
		tree_count += 1

	var shrub_placements: Array = [
		[SHRUB_01,Vector3(6,0,-4),4.1,15.0],
		[SHRUB_02,Vector3(12,0,-7),4.3,71.0],
		[SHRUB_03,Vector3(19,0,-8),3.3,123.0],
		[SHRUB_01,Vector3(27,0,4),3.9,181.0],
		[SHRUB_02,Vector3(31,0,9),4.2,229.0],
		[SHRUB_03,Vector3(8,0,18),3.4,278.0],
		[SHRUB_01,Vector3(35,0,18),3.8,321.0],
		[SHRUB_02,Vector3(42,0,-10),4.1,32.0],
		[SHRUB_03,Vector3(-15,0,20),3.3,94.0],
		[SHRUB_02,Vector3(-20,0,27),3.8,151.0],
		[SHRUB_01,Vector3(-6,0,-21),3.7,201.0],
		[SHRUB_03,Vector3(23,0,-24),3.1,253.0]
	]
	for i: int in range(shrub_placements.size()):
		var d: Array = shrub_placements[i]
		var p: Vector3 = d[1]
		p.y = _terrain_height(p.x,p.z)+0.01
		_add_asset(d[0],p,d[2],d[3],"V16ShrubRefined_%02d" % i)

	var grass_placements: Array[Vector3] = [
		Vector3(-26,0,22),Vector3(-23,0,16),Vector3(-21,0,29),
		Vector3(-17,0,25),Vector3(-13,0,31),Vector3(-11,0,17),
		Vector3(-7,0,27),Vector3(-3,0,22),Vector3(1,0,25),
		Vector3(4,0,18),Vector3(8,0,21),Vector3(12,0,16),
		Vector3(16,0,20),Vector3(21,0,17),Vector3(26,0,13),
		Vector3(31,0,9),Vector3(35,0,4),Vector3(40,0,-2),
		Vector3(-10,0,-17),Vector3(-2,0,-21),Vector3(7,0,-23),
		Vector3(17,0,-25),Vector3(27,0,-23),Vector3(37,0,-19)
	]
	for i: int in range(grass_placements.size()):
		var p: Vector3 = grass_placements[i]
		p.y = _terrain_height(p.x,p.z)+0.005
		_add_asset(GRASS_MEDIUM,p,4.2,13.0+float(i)*31.0,"V16GrassRefined_%02d" % i)

	var weed_placements: Array[Vector3] = [
		Vector3(7,0,-2),Vector3(11,0,3),Vector3(18,0,4),Vector3(23,0,7),
		Vector3(28,0,10),Vector3(33,0,-5),Vector3(37,0,-12),Vector3(7,0,13),
		Vector3(-9,0,12),Vector3(-14,0,21),Vector3(3,0,16),Vector3(15,0,-15)
	]
	for i: int in range(weed_placements.size()):
		var p: Vector3 = weed_placements[i]
		p.y = _terrain_height(p.x,p.z)+0.005
		_add_asset(WEED,p,2.1,9.0+float(i)*37.0,"V16WeedRefined_%02d" % i)


func _build_vehicles() -> void:
	var olive := StandardMaterial3D.new()
	olive.albedo_color = Color(0.15,0.19,0.075)
	olive.metallic = 0.16
	olive.metallic_specular = 0.32
	olive.roughness = 0.80

	var olive2 := StandardMaterial3D.new()
	olive2.albedo_color = Color(0.13,0.17,0.065)
	olive2.metallic = 0.14
	olive2.roughness = 0.82

	var enemy_mat := StandardMaterial3D.new()
	enemy_mat.albedo_color = Color(0.16,0.085,0.050)
	enemy_mat.metallic = 0.12
	enemy_mat.roughness = 0.83

	var p_mbt := Vector3(-10,0,14)
	p_mbt.y = _terrain_height(p_mbt.x,p_mbt.z)+0.10
	var mbt := _add_asset(MBT,p_mbt,6.4,-55.0,"V16AbramsRefined")
	if mbt != null:
		_override_material(mbt,olive)

	var p_ifv := Vector3(-5,0,7)
	p_ifv.y = _terrain_height(p_ifv.x,p_ifv.z)+0.09
	var ifv := _add_asset(IFV,p_ifv,5.1,-38.0,"V16BlueIFVRefined")
	if ifv != null:
		_override_material(ifv,olive2)

	var p_wreck := Vector3(11,0,3)
	p_wreck.y = _terrain_height(p_wreck.x,p_wreck.z)+0.07
	var wreck := _add_asset(IFV,p_wreck,4.7,36.0,"V16BurnedIFVRefined")
	if wreck != null:
		wreck.rotation_degrees.z = -7.0
		_override_material(wreck,_wreck_material())

	var p_enemy := Vector3(30,0,-7)
	p_enemy.y = _terrain_height(p_enemy.x,p_enemy.z)+0.08
	var enemy := _add_asset(IFV,p_enemy,4.7,142.0,"V16EnemyIFVRefined")
	if enemy != null:
		_override_material(enemy,enemy_mat)

	_add_infantry_v16()
	vehicle_count = 4


func _build_camera() -> void:
	camera = Camera3D.new()
	camera.name = "V16QualityCameraRefined"
	camera.fov = 42.0
	camera.position = Vector3(-24.5,14.2,29.5)
	add_child(camera)
	camera.look_at(Vector3(14.0,1.0,-2.5),Vector3.UP)
	camera.current = true
