extends "res://scripts/production/quality/quality_test_world_v8.gd"

const CHURCH := "res://assets/golden_scene/city_real/church_landmark.glb"
const SOLDIER := "res://assets/golden_scene/infantry/soldier.glb"
const TREE_HERO := "res://assets/golden_scene/quality_v7/tree_small_02_lod.glb"
const SHRUB_01 := "res://assets/golden_scene/quality_v16/shrub_01_lod.glb"
const SHRUB_02 := "res://assets/golden_scene/quality_v16/shrub_02_lod.glb"
const SHRUB_03 := "res://assets/golden_scene/quality_v16/shrub_03_lod.glb"
const GRASS_MEDIUM := "res://assets/golden_scene/quality_v16/grass_medium_02_lod.glb"
const WEED := "res://assets/golden_scene/quality_v16/weed_plant_02_lod.glb"
const RUBBLE_SMALL := "res://assets/golden_scene/nature/062_rock_smallA.glb"
const RUBBLE_LARGE := "res://assets/golden_scene/nature/056_rock_largeA.glb"

const TERRAIN_X_MIN := -105.0
const TERRAIN_X_MAX := 115.0
const TERRAIN_Z_MIN := -92.0
const TERRAIN_Z_MAX := 96.0

func _preflight() -> void:
	for path: String in [
		MBT, IFV, SOLDIER,
		HOUSE_0, HOUSE_1, HOUSE_2, HOUSE_3, HOUSE_4, CHURCH,
		TREE_HERO, SHRUB_01, SHRUB_02, SHRUB_03, GRASS_MEDIUM, WEED,
		RUBBLE_SMALL, RUBBLE_LARGE
	]:
		if not ResourceLoader.exists(path):
			push_error("QUALITY_TEST_REQUIRED_ASSET_MISSING path=%s" % path)


func _build_environment() -> void:
	var env_node := WorldEnvironment.new()
	env_node.name = "V16Environment"
	var env := Environment.new()

	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.23,0.31,0.39)
	sky_mat.sky_horizon_color = Color(0.63,0.62,0.56)
	sky_mat.ground_bottom_color = Color(0.10,0.11,0.095)
	sky_mat.ground_horizon_color = Color(0.43,0.43,0.36)
	sky_mat.sun_angle_max = 7.5
	var sky := Sky.new()
	sky.sky_material = sky_mat

	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.background_energy_multiplier = 0.92
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.64
	env.reflected_light_source = Environment.REFLECTION_SOURCE_SKY

	env.fog_enabled = true
	env.fog_light_color = Color(0.57,0.56,0.51)
	env.fog_light_energy = 0.58
	env.fog_density = 0.0041
	env.fog_height = 3.8
	env.fog_height_density = 0.012
	env.fog_aerial_perspective = 0.68
	env.fog_sky_affect = 0.34

	env.volumetric_fog_enabled = true
	env.volumetric_fog_density = 0.008
	env.volumetric_fog_albedo = Color(0.74,0.72,0.66)
	env.volumetric_fog_emission = Color(0.02,0.018,0.014)
	env.volumetric_fog_emission_energy = 0.25
	env.volumetric_fog_length = 58.0
	env.volumetric_fog_detail_spread = 2.0
	env.volumetric_fog_ambient_inject = 0.42

	env.ssao_enabled = true
	env.ssao_radius = 1.8
	env.ssao_intensity = 1.35
	env.ssao_power = 1.15
	env.ssao_detail = 0.72
	env.ssao_light_affect = 0.14

	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.adjustment_enabled = true
	env.adjustment_brightness = 1.00
	env.adjustment_contrast = 1.08
	env.adjustment_saturation = 0.90

	env_node.environment = env
	add_child(env_node)

	var sun := DirectionalLight3D.new()
	sun.name = "V16WarmSun"
	sun.rotation_degrees = Vector3(-39.0,-46.0,0.0)
	sun.light_color = Color(1.0,0.84,0.67)
	sun.light_energy = 1.42
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 145.0
	sun.shadow_bias = 0.035
	sun.shadow_normal_bias = 1.0
	add_child(sun)

	var fill := DirectionalLight3D.new()
	fill.name = "V16CoolFill"
	fill.rotation_degrees = Vector3(-63.0,138.0,0.0)
	fill.light_color = Color(0.38,0.49,0.60)
	fill.light_energy = 0.18
	add_child(fill)


func _build_ground() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var nx := 149
	var nz := 121
	var dx := (TERRAIN_X_MAX-TERRAIN_X_MIN)/float(nx-1)
	var dz := (TERRAIN_Z_MAX-TERRAIN_Z_MIN)/float(nz-1)

	for zi: int in range(nz-1):
		for xi: int in range(nx-1):
			var x0 := TERRAIN_X_MIN+float(xi)*dx
			var x1 := x0+dx
			var z0 := TERRAIN_Z_MIN+float(zi)*dz
			var z1 := z0+dz
			var p00 := Vector3(x0,_terrain_height(x0,z0),z0)
			var p10 := Vector3(x1,_terrain_height(x1,z0),z0)
			var p01 := Vector3(x0,_terrain_height(x0,z1),z1)
			var p11 := Vector3(x1,_terrain_height(x1,z1),z1)
			_add_terrain_vertex_v16(st,p00)
			_add_terrain_vertex_v16(st,p10)
			_add_terrain_vertex_v16(st,p01)
			_add_terrain_vertex_v16(st,p10)
			_add_terrain_vertex_v16(st,p11)
			_add_terrain_vertex_v16(st,p01)

	var terrain := MeshInstance3D.new()
	terrain.name = "V16EnvironmentTerrain"
	terrain.mesh = st.commit()
	terrain.material_override = _terrain_material_v16()
	terrain.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	add_child(terrain)

	_add_puddle(Vector3(-11,0,18),Vector2(2.4,0.70),-38.0)
	_add_puddle(Vector3(2,0,9),Vector2(1.8,0.58),-43.0)
	_add_puddle(Vector3(13,0,1),Vector2(2.0,0.62),-42.0)
	_add_puddle(Vector3(25,0,-7),Vector2(1.55,0.52),-39.0)

	_add_scorch_disc(Vector3(11,0,3),5.2)
	_add_scorch_disc(Vector3(18,0,11),4.4)


func _terrain_height(x: float,z: float) -> float:
	var rolling := 0.54*sin(x*0.044)+0.36*cos(z*0.057)+0.22*sin((x+z)*0.071)
	var broad := 0.62*exp(-pow((x+42.0)/38.0,2.0)-pow((z+28.0)/42.0,2.0))
	var town := _town_mask(x,z)
	var village_level := 0.06+0.08*sin(x*0.055)
	var base := lerpf(rolling+broad,village_level,town*0.74)
	var road := _road_mask(x,z)
	base -= road*0.38
	var field := _field_mask(x,z)
	base += field*(0.07*sin(x*0.58+z*0.12)+0.045*sin(x*0.23-z*0.41))
	base -= _crater(x,z,11.0,3.0,4.1,0.48)
	base -= _crater(x,z,18.0,11.0,3.3,0.38)
	base -= _crater(x,z,-22.0,-10.0,3.7,0.30)
	return base


func _crater(x: float,z: float,cx: float,cz: float,radius: float,depth: float) -> float:
	var d2 := pow((x-cx)/radius,2.0)+pow((z-cz)/radius,2.0)
	return depth*exp(-d2*2.2)


func _town_mask(x: float,z: float) -> float:
	var p := Vector2((x-23.0)/31.0,(z-1.0)/27.0)
	return 1.0-smoothstep(0.58,1.05,p.length())


func _field_mask(x: float,z: float) -> float:
	var a := Vector2((x+45.0)/42.0,(z+35.0)/22.0).length()
	var b := Vector2((x-52.0)/38.0,(z+45.0)/21.0).length()
	var c := Vector2((x+48.0)/40.0,(z-46.0)/20.0).length()
	return maxf(
		1.0-smoothstep(0.68,1.05,a),
		maxf(1.0-smoothstep(0.70,1.05,b),1.0-smoothstep(0.70,1.05,c))
	)


func _road_mask(x: float,z: float) -> float:
	var d := _road_distance(Vector2(x,z))
	return 1.0-smoothstep(3.0,8.2,d)


func _road_distance(p: Vector2) -> float:
	var d := INF
	d = minf(d,_segment_distance(p,Vector2(-36,48),Vector2(-24,35)))
	d = minf(d,_segment_distance(p,Vector2(-24,35),Vector2(-12,23)))
	d = minf(d,_segment_distance(p,Vector2(-12,23),Vector2(1,11)))
	d = minf(d,_segment_distance(p,Vector2(1,11),Vector2(15,1)))
	d = minf(d,_segment_distance(p,Vector2(15,1),Vector2(29,-9)))
	d = minf(d,_segment_distance(p,Vector2(29,-9),Vector2(48,-18)))
	return d


func _segment_distance(p: Vector2,a: Vector2,b: Vector2) -> float:
	var ab := b-a
	var denom := maxf(ab.length_squared(),0.0001)
	var t := clampf((p-a).dot(ab)/denom,0.0,1.0)
	return p.distance_to(a+ab*t)


func _terrain_normal_v16(x: float,z: float) -> Vector3:
	var e := 0.38
	var dx := _terrain_height(x+e,z)-_terrain_height(x-e,z)
	var dz := _terrain_height(x,z+e)-_terrain_height(x,z-e)
	return Vector3(-dx/(2.0*e),1.0,-dz/(2.0*e)).normalized()


func _add_terrain_vertex_v16(st: SurfaceTool,p: Vector3) -> void:
	st.set_normal(_terrain_normal_v16(p.x,p.z))
	st.set_uv(Vector2(
		(p.x-TERRAIN_X_MIN)/(TERRAIN_X_MAX-TERRAIN_X_MIN),
		(p.z-TERRAIN_Z_MIN)/(TERRAIN_Z_MAX-TERRAIN_Z_MIN)
	))
	st.set_color(Color(
		_road_mask(p.x,p.z),
		_town_mask(p.x,p.z),
		_field_mask(p.x,p.z),
		_churn_mask(p.x,p.z)
	))
	st.add_vertex(p)


func _churn_mask(x: float,z: float) -> float:
	var a := Vector2((x+7.0)/19.0,(z-12.0)/10.0).length()
	var b := Vector2((x-14.0)/15.0,(z-5.0)/11.0).length()
	return maxf(1.0-smoothstep(0.58,1.0,a),1.0-smoothstep(0.55,1.0,b))


func _terrain_material_v16() -> ShaderMaterial:
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
	vec2 uv=UV*29.0;
	float road=COLOR.r;
	float town=COLOR.g;
	float field=COLOR.b;
	float churn=COLOR.a;
	vec3 grass=texture(grass_diff,uv).rgb*vec3(0.58,0.67,0.44);
	vec3 dirt=texture(dirt_diff,uv*0.86).rgb*vec3(0.66,0.55,0.39);
	vec3 mud=texture(mud_diff,uv*0.78).rgb*vec3(0.50,0.41,0.31);
	float macro=0.92+0.08*sin(wp.x*0.071+sin(wp.z*0.043)*2.0);
	float dry=field*(0.46+0.18*sin(wp.x*0.11+wp.z*0.07));
	float dirt_mix=clamp(road*0.82+town*0.19+dry*0.34,0.0,0.88);
	float mud_mix=clamp(churn*0.46+road*0.20,0.0,0.62);
	vec3 base=mix(grass,dirt,dirt_mix);
	base=mix(base,mud,mud_mix);
	base*=macro;
	base=mix(base,base*vec3(0.88,0.84,0.70),field*0.22);
	ALBEDO=base;
	NORMAL_MAP=mix(
		mix(texture(grass_nor,uv).rgb,texture(dirt_nor,uv*0.86).rgb,dirt_mix),
		texture(mud_nor,uv*0.78).rgb,mud_mix
	);
	NORMAL_MAP_DEPTH=0.56;
	ROUGHNESS=mix(0.91,0.78,road*0.18);
	SPECULAR=0.27;
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


func _add_puddle(xz: Vector3,size: Vector2,yaw: float) -> void:
	var node := MeshInstance3D.new()
	node.name = "V16RoadPuddle"
	var disc := CylinderMesh.new()
	disc.top_radius = 1.0
	disc.bottom_radius = 1.0
	disc.height = 0.018
	disc.radial_segments = 24
	node.mesh = disc
	node.scale = Vector3(size.x,1.0,size.y)
	node.position = Vector3(xz.x,_terrain_height(xz.x,xz.z)+0.022,xz.z)
	node.rotation_degrees.y = yaw
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.12,0.15,0.14,0.48)
	mat.metallic = 0.08
	mat.roughness = 0.25
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	node.material_override = mat
	add_child(node)


func _add_scorch_disc(xz: Vector3,radius: float) -> void:
	var node := MeshInstance3D.new()
	node.name = "V16Scorch"
	var disc := CylinderMesh.new()
	disc.top_radius = 1.0
	disc.bottom_radius = 1.0
	disc.height = 0.025
	disc.radial_segments = 28
	node.mesh = disc
	node.scale = Vector3(radius,1.0,radius*0.72)
	node.position = Vector3(xz.x,_terrain_height(xz.x,xz.z)+0.026,xz.z)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.075,0.060,0.045)
	mat.roughness = 0.98
	node.material_override = mat
	add_child(node)


func _build_buildings() -> void:
	var placements: Array = [
		[HOUSE_0,Vector3(12,0,-11),9.7,8.0,"V16HouseA",Color(0.78,0.74,0.66),Vector2(7.0,6.0)],
		[HOUSE_1,Vector3(23,0,-1),10.0,-12.0,"V16HouseB",Color(0.72,0.69,0.62),Vector2(7.2,6.2)],
		[HOUSE_2,Vector3(16,0,11),9.8,7.0,"V16DamagedHouse",Color(0.48,0.39,0.31),Vector2(7.0,6.0)],
		[HOUSE_3,Vector3(29,0,14),9.2,-5.0,"V16RearHouse",Color(0.70,0.66,0.59),Vector2(6.8,5.8)],
		[HOUSE_4,Vector3(34,0,-13),8.9,14.0,"V16RearHouseB",Color(0.66,0.63,0.57),Vector2(6.6,5.8)]
	]
	for d: Array in placements:
		var node := _add_grounded_building(
			d[0],d[1],d[2],d[3],d[4],d[6],Color(0.25,0.22,0.18)
		)
		if node != null:
			_tint_surfaces(node,d[5])

	var church := _add_grounded_building(
		CHURCH,Vector3(43,0,-22),16.8,11.0,
		"V16ChurchLandmark",Vector2(10.5,7.8),Color(0.25,0.23,0.20)
	)
	if church != null:
		_tint_surfaces(church,Color(0.72,0.68,0.60))

	building_count = 6
	_add_village_fences()
	_add_damage_cluster(Vector3(16,0,11),0.0)
	_add_damage_cluster(Vector3(10,0,3),68.0)
	_add_wall_scar(Vector3(13.9,2.2,7.8),7.0,Vector2(2.4,1.5))
	_add_wall_scar(Vector3(42.1,3.5,-18.4),11.0,Vector2(1.7,2.0))


func _add_village_fences() -> void:
	var fence_mat := StandardMaterial3D.new()
	fence_mat.albedo_color = Color(0.19,0.13,0.075)
	fence_mat.roughness = 0.96
	var placements: Array = [
		[FENCE_PLANKS,Vector3(8,0,-7),2.8,8.0],
		[FENCE_SIMPLE,Vector3(11,0,-4),2.8,96.0],
		[FENCE_GATE,Vector3(19,0,-5),2.8,82.0],
		[FENCE_PLANKS,Vector3(27,0,4),2.8,-8.0],
		[FENCE_SIMPLE,Vector3(29,0,8),2.8,80.0],
		[FENCE_PLANKS,Vector3(10,0,15),2.8,5.0],
		[FENCE_GATE,Vector3(32,0,-9),2.8,79.0]
	]
	for i: int in range(placements.size()):
		var d: Array = placements[i]
		var p: Vector3 = d[1]
		p.y = _terrain_height(p.x,p.z)+0.02
		var fence := _add_asset(d[0],p,d[2],d[3],"V16Fence_%02d" % i)
		if fence != null:
			_override_material(fence,fence_mat)


func _add_damage_cluster(center: Vector3,yaw: float) -> void:
	var rubble_mat := StandardMaterial3D.new()
	rubble_mat.albedo_color = Color(0.18,0.16,0.13)
	rubble_mat.roughness = 0.97
	var placements: Array = [
		[RUBBLE_LARGE,Vector3(-1.7,0,-0.8),1.25,yaw+12.0],
		[RUBBLE_SMALL,Vector3(0.2,0,0.4),0.82,yaw+47.0],
		[RUBBLE_SMALL,Vector3(1.45,0,-0.15),0.68,yaw+93.0],
		[RUBBLE_SMALL,Vector3(-0.55,0,1.18),0.72,yaw+138.0],
		[RUBBLE_SMALL,Vector3(1.8,0,1.15),0.58,yaw+176.0]
	]
	for i: int in range(placements.size()):
		var d: Array = placements[i]
		var offset: Vector3 = d[1]
		var p: Vector3 = center+offset
		p.y = _terrain_height(p.x,p.z)+0.02
		var rock := _add_asset(d[0],p,d[2],d[3],"V16Rubble_%02d" % i)
		if rock != null:
			_override_material(rock,rubble_mat)


func _add_wall_scar(position_value: Vector3,yaw: float,size: Vector2) -> void:
	var scar := MeshInstance3D.new()
	scar.name = "V16WallScar"
	var quad := QuadMesh.new()
	quad.size = size
	scar.mesh = quad
	scar.position = position_value
	scar.rotation_degrees = Vector3(0.0,yaw,0.0)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.075,0.058,0.045,0.70)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.roughness = 0.98
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	scar.material_override = mat
	add_child(scar)


func _build_trees() -> void:
	var tree_placements: Array = [
		[Vector3(-34,0,-43),9.5,14.0],
		[Vector3(-22,0,-49),10.2,48.0],
		[Vector3(-8,0,-52),8.9,88.0],
		[Vector3(7,0,-53),10.0,133.0],
		[Vector3(21,0,-51),9.2,176.0],
		[Vector3(36,0,-47),10.3,218.0],
		[Vector3(50,0,-40),9.0,262.0],
		[Vector3(57,0,-28),9.8,314.0],
		[Vector3(45,0,21),8.8,65.0],
		[Vector3(-29,0,25),8.7,204.0]
	]
	for i: int in range(tree_placements.size()):
		var d: Array = tree_placements[i]
		var p: Vector3 = d[0]
		p.y = _terrain_height(p.x,p.z)
		_add_asset(TREE_HERO,p,d[1],d[2],"V16Tree_%02d" % i)
		tree_count += 1

	var shrub_placements: Array = [
		[SHRUB_01,Vector3(7,0,-5),3.0,15.0],
		[SHRUB_02,Vector3(13,0,-7),3.2,71.0],
		[SHRUB_03,Vector3(20,0,-8),2.4,123.0],
		[SHRUB_01,Vector3(30,0,4),2.8,181.0],
		[SHRUB_02,Vector3(32,0,9),3.0,229.0],
		[SHRUB_03,Vector3(9,0,18),2.5,278.0],
		[SHRUB_01,Vector3(36,0,18),2.8,321.0],
		[SHRUB_02,Vector3(42,0,-10),3.0,32.0],
		[SHRUB_03,Vector3(-15,0,20),2.3,94.0],
		[SHRUB_02,Vector3(-20,0,28),2.8,151.0]
	]
	for i: int in range(shrub_placements.size()):
		var d: Array = shrub_placements[i]
		var p: Vector3 = d[1]
		p.y = _terrain_height(p.x,p.z)+0.01
		_add_asset(d[0],p,d[2],d[3],"V16Shrub_%02d" % i)

	var grass_placements: Array[Vector3] = [
		Vector3(-24,0,23),Vector3(-20,0,18),Vector3(-18,0,31),
		Vector3(-12,0,29),Vector3(-9,0,17),Vector3(-5,0,26),
		Vector3(1,0,22),Vector3(5,0,18),Vector3(9,0,15),
		Vector3(15,0,18),Vector3(20,0,16),Vector3(26,0,12),
		Vector3(31,0,7),Vector3(36,0,2),Vector3(40,0,-4),
		Vector3(-5,0,-18),Vector3(4,0,-22),Vector3(23,0,-26)
	]
	for i: int in range(grass_placements.size()):
		var p: Vector3 = grass_placements[i]
		p.y = _terrain_height(p.x,p.z)+0.005
		_add_asset(GRASS_MEDIUM,p,2.6,17.0+float(i)*37.0,"V16Grass_%02d" % i)

	var weed_placements: Array[Vector3] = [
		Vector3(8,0,-2),Vector3(12,0,3),Vector3(19,0,4),Vector3(23,0,8),
		Vector3(29,0,10),Vector3(34,0,-6),Vector3(37,0,-12),Vector3(7,0,13),
		Vector3(-10,0,12),Vector3(-15,0,22)
	]
	for i: int in range(weed_placements.size()):
		var p: Vector3 = weed_placements[i]
		p.y = _terrain_height(p.x,p.z)+0.005
		_add_asset(WEED,p,1.5,11.0+float(i)*41.0,"V16Weed_%02d" % i)


func _build_vehicles() -> void:
	var p_mbt := Vector3(-10,0,14)
	p_mbt.y = _terrain_height(p_mbt.x,p_mbt.z)+0.12
	var mbt := _add_asset(MBT,p_mbt,6.6,-55.0,"V16Abrams")
	if mbt != null:
		_apply_vehicle_materials_v16(mbt,Color(0.31,0.34,0.18),Color(0.20,0.22,0.11))

	var p_ifv := Vector3(-5,0,7)
	p_ifv.y = _terrain_height(p_ifv.x,p_ifv.z)+0.10
	var ifv := _add_asset(IFV,p_ifv,5.3,-38.0,"V16BlueIFV")
	if ifv != null:
		_apply_vehicle_materials_v16(ifv,Color(0.29,0.32,0.17),Color(0.18,0.20,0.10))

	var p_wreck := Vector3(11,0,3)
	p_wreck.y = _terrain_height(p_wreck.x,p_wreck.z)+0.08
	var wreck := _add_asset(IFV,p_wreck,4.8,36.0,"V16BurnedIFV")
	if wreck != null:
		wreck.rotation_degrees.z = -7.0
		_override_material(wreck,_wreck_material())

	var p_enemy := Vector3(30,0,-7)
	p_enemy.y = _terrain_height(p_enemy.x,p_enemy.z)+0.09
	var enemy := _add_asset(IFV,p_enemy,4.8,142.0,"V16EnemyIFV")
	if enemy != null:
		_apply_vehicle_materials_v16(enemy,Color(0.23,0.15,0.10),Color(0.13,0.09,0.06))

	_add_infantry_v16()
	vehicle_count = 4


func _apply_vehicle_materials_v16(root: Node3D,a: Color,b: Color) -> void:
	var hull := _vehicle_hull_material_v16(a,b)
	var track := StandardMaterial3D.new()
	track.albedo_color = Color(0.045,0.048,0.041)
	track.metallic = 0.34
	track.roughness = 0.88
	var metal := StandardMaterial3D.new()
	metal.albedo_color = Color(0.085,0.090,0.080)
	metal.metallic = 0.46
	metal.roughness = 0.72
	var meshes: Array[MeshInstance3D] = []
	if root is MeshInstance3D:
		meshes.append(root as MeshInstance3D)
	for item: Node in root.find_children("*","MeshInstance3D",true,false):
		var mi := item as MeshInstance3D
		if mi != null:
			meshes.append(mi)
	for mi: MeshInstance3D in meshes:
		if mi.mesh == null:
			continue
		for surface: int in range(mi.mesh.get_surface_count()):
			var key: String = (mi.name+" "+mi.mesh.surface_get_name(surface)).to_lower()
			var src := mi.mesh.surface_get_material(surface)
			if src != null:
				key += " "+src.resource_name.to_lower()
			var chosen: Material = hull
			if key.contains("track") or key.contains("wheel") or key.contains("tire") or key.contains("rubber"):
				chosen = track
			elif key.contains("gun") or key.contains("barrel") or key.contains("exhaust"):
				chosen = metal
			mi.set_surface_override_material(surface,chosen)


func _vehicle_hull_material_v16(a: Color,b: Color) -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
shader_type spatial;
varying vec3 lp;
uniform vec3 color_a : source_color;
uniform vec3 color_b : source_color;
void vertex(){ lp=VERTEX; }
void fragment(){
	float n=sin(lp.x*1.19+lp.z*0.57)+0.65*sin(lp.z*1.71-lp.x*0.43);
	float patch=smoothstep(-0.26,0.42,n);
	float dirt=0.5+0.5*sin(lp.x*5.3+lp.z*4.1);
	vec3 base=mix(color_a,color_b,patch*0.32);
	base=mix(base,base*vec3(0.67,0.58,0.42),dirt*0.12);
	ALBEDO=base;
	METALLIC=0.18;
	ROUGHNESS=0.79;
	SPECULAR=0.30;
}
"""
	var mat := ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("color_a",Vector3(a.r,a.g,a.b))
	mat.set_shader_parameter("color_b",Vector3(b.r,b.g,b.b))
	return mat


func _add_infantry_v16() -> void:
	var placements: Array = [
		[Vector3(-13,0,10),-46.0],
		[Vector3(-10,0,8),-39.0],
		[Vector3(-7,0,6),-31.0],
		[Vector3(-3,0,4),-24.0]
	]
	var uniform := StandardMaterial3D.new()
	uniform.albedo_color = Color(0.16,0.18,0.10)
	uniform.roughness = 0.90
	for i: int in range(placements.size()):
		var p: Vector3 = placements[i][0]
		p.y = _terrain_height(p.x,p.z)
		var soldier := _add_grounded_prop_v16(
			SOLDIER,p,1.95,placements[i][1],"V16Infantry_%02d" % i
		)
		if soldier != null:
			_override_material(soldier,uniform)


func _add_grounded_prop_v16(path: String,p: Vector3,target: float,yaw: float,name_value: String) -> Node3D:
	var packed := load(path) as PackedScene
	if packed == null:
		return null
	var node := packed.instantiate() as Node3D
	if node == null:
		return null
	node.name = name_value
	_fit(node,target)
	node.rotation_degrees.y = yaw
	var bottom := _mesh_bottom_local(node)
	node.position = Vector3(p.x,p.y-bottom+0.012,p.z)
	add_child(node)
	return node


func _build_camera() -> void:
	camera = Camera3D.new()
	camera.name = "V16QualityCamera"
	camera.fov = 40.0
	camera.position = Vector3(-25.0,18.2,31.5)
	add_child(camera)
	camera.look_at(Vector3(13.5,0.2,-2.5),Vector3.UP)
	camera.current = true
