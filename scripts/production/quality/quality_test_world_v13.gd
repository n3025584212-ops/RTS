extends "res://scripts/production/quality/quality_test_world_v12.gd"

const SOLDIER := "res://assets/golden_scene/infantry/soldier.glb"
const BUSH := "res://assets/golden_scene/nature/048_plant_bushDetailed.glb"

func _preflight() -> void:
	for path: String in [
		MBT, IFV, SOLDIER,
		HOUSE_0, HOUSE_1, HOUSE_2, HOUSE_3, HOUSE_4, CHURCH,
		V7_TREE, BUSH,
		QUALITY_HDRI,
		FENCE_SIMPLE, FENCE_PLANKS, FENCE_GATE
	]:
		var exists := FileAccess.file_exists(path) if path.ends_with(".hdr") else ResourceLoader.exists(path)
		if not exists:
			push_error("QUALITY_TEST_REQUIRED_ASSET_MISSING path=%s" % path)


func _build_environment() -> void:
	var env_node := WorldEnvironment.new()
	env_node.name = "QualityEnvironment"
	var env := Environment.new()

	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.16,0.23,0.29)
	sky_mat.sky_horizon_color = Color(0.46,0.50,0.50)
	sky_mat.ground_bottom_color = Color(0.12,0.13,0.11)
	sky_mat.ground_horizon_color = Color(0.34,0.36,0.32)
	sky_mat.sun_angle_max = 9.0
	var sky := Sky.new()
	sky.sky_material = sky_mat

	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.background_energy_multiplier = 0.72
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.52
	env.reflected_light_source = Environment.REFLECTION_SOURCE_SKY

	env.fog_enabled = true
	env.fog_light_color = Color(0.45,0.48,0.47)
	env.fog_light_energy = 0.50
	env.fog_density = 0.0037
	env.fog_height = 4.0
	env.fog_height_density = 0.010
	env.fog_aerial_perspective = 0.58
	env.fog_sky_affect = 0.30

	env.ssao_enabled = true
	env.ssao_radius = 2.0
	env.ssao_intensity = 2.2
	env.ssao_power = 1.25
	env.ssao_detail = 0.75
	env.ssao_light_affect = 0.18

	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.adjustment_enabled = true
	env.adjustment_brightness = 0.96
	env.adjustment_contrast = 1.10
	env.adjustment_saturation = 0.88

	env_node.environment = env
	add_child(env_node)

	var sun := DirectionalLight3D.new()
	sun.name = "QualityKeySun"
	sun.rotation_degrees = Vector3(-43.0,-38.0,0.0)
	sun.light_color = Color(1.0,0.90,0.78)
	sun.light_energy = 1.32
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 125.0
	sun.shadow_bias = 0.035
	sun.shadow_normal_bias = 1.0
	add_child(sun)

	var fill := DirectionalLight3D.new()
	fill.name = "QualityCoolFill"
	fill.rotation_degrees = Vector3(-62.0,138.0,0.0)
	fill.light_color = Color(0.39,0.48,0.56)
	fill.light_energy = 0.12
	add_child(fill)


func _build_ground() -> void:
	super._build_ground()

	# Re-establish a single darker village road over the earlier test ribbons.
	var road_points: Array[Vector3] = [
		Vector3(-22,0,73),Vector3(-14,0,50),Vector3(-8,0,34),
		Vector3(-3,0,23),Vector3(2,0,14),Vector3(8,0,6),
		Vector3(16,0,-2),Vector3(27,0,-9),Vector3(43,0,-15)
	]
	_add_road_ribbon(
		road_points,7.2,"gravel_ground_01",
		Color(0.31,0.29,0.25),"DesignRoadShoulder",0.105
	)
	_add_road_ribbon(
		road_points,4.8,"grass_path_3",
		Color(0.38,0.32,0.24),"DesignVillageRoad",0.125
	)

	# Macro parcels visible in the same local camera: dry crop, churned soil,
	# and darker grass. They break the single-tabletop grass read.
	for data: Array in [
		[Vector3(-42,0,-35),Vector2(58,26),7.0,"dirt_aerial_03",Color(0.44,0.36,0.25)],
		[Vector3(47,0,-48),Vector2(50,24),-6.0,"grass_path_3",Color(0.34,0.39,0.25)],
		[Vector3(-50,0,42),Vector2(54,22),5.0,"aerial_mud_1",Color(0.33,0.28,0.21)]
	]:
		var p: Vector3 = data[0]
		p.y = _terrain_height(p.x,p.z)+0.070
		_add_masked_patch("DesignFieldParcel",p,data[1],data[2],data[3],data[4])

	# Vehicle disturbance and battle history around the approach.
	for data: Array in [
		[Vector3(-7,0,12),Vector2(17,7),-8.0,"aerial_mud_1",Color(0.30,0.25,0.18)],
		[Vector3(10,0,3),Vector2(10,7),12.0,"aerial_mud_1",Color(0.24,0.20,0.16)],
		[Vector3(17,0,10),Vector2(10,8),6.0,"dirt_aerial_03",Color(0.31,0.25,0.18)]
	]:
		var p: Vector3 = data[0]
		p.y = _terrain_height(p.x,p.z)+0.138
		_add_masked_patch("DesignBattleDisturbance",p,data[1],data[2],data[3],data[4])

	_add_scorch_patch(Vector3(10,0,3),7.4,15.0)
	_add_scorch_patch(Vector3(17,0,10),5.8,-6.0)


func _build_buildings() -> void:
	var placements: Array = [
		[HOUSE_0,Vector3(14,0,-10),9.3,9.0,"VillageHouseA",Color(0.78,0.75,0.68),Vector2(7.0,6.0)],
		[HOUSE_1,Vector3(24,0,-1),9.7,-12.0,"VillageHouseB",Color(0.72,0.70,0.64),Vector2(7.2,6.2)],
		[HOUSE_2,Vector3(16,0,10),9.5,7.0,"DamagedVillageHouse",Color(0.47,0.39,0.31),Vector2(7.0,6.0)],
		[HOUSE_3,Vector3(29,0,14),9.0,-4.0,"RearVillageHouse",Color(0.69,0.67,0.61),Vector2(6.8,5.8)],
		[HOUSE_4,Vector3(35,0,-12),8.7,15.0,"RearVillageHouseB",Color(0.66,0.65,0.60),Vector2(6.6,5.8)]
	]
	for d: Array in placements:
		var node := _add_grounded_building(
			d[0],d[1],d[2],d[3],d[4],d[6],Color(0.25,0.23,0.19)
		)
		if node != null:
			_tint_surfaces(node,d[5])

	var church := _add_grounded_building(
		CHURCH,Vector3(42,0,-22),16.5,11.0,
		"VillageChurchLandmark",Vector2(10.5,7.8),Color(0.25,0.24,0.21)
	)
	if church != null:
		_apply_landmark_materials(church)

	building_count = 6
	_build_design_fences()


func _build_design_fences() -> void:
	var fence_mat := StandardMaterial3D.new()
	fence_mat.albedo_color = Color(0.18,0.12,0.075)
	fence_mat.roughness = 0.96
	var placements: Array = [
		[FENCE_PLANKS,Vector3(10,0,-7),2.8,8.0],
		[FENCE_SIMPLE,Vector3(12,0,-5),2.8,96.0],
		[FENCE_GATE,Vector3(20,0,-5),2.8,82.0],
		[FENCE_PLANKS,Vector3(28,0,5),2.8,-10.0],
		[FENCE_SIMPLE,Vector3(29,0,9),2.8,80.0],
		[FENCE_PLANKS,Vector3(12,0,14),2.8,5.0],
		[FENCE_SIMPLE,Vector3(8,0,16),2.8,95.0],
		[FENCE_GATE,Vector3(33,0,-8),2.8,78.0]
	]
	for i: int in range(placements.size()):
		var d: Array = placements[i]
		var p: Vector3 = d[1]
		p.y = _terrain_height(p.x,p.z)+0.04
		var fence := _add_asset(d[0],p,d[2],d[3],"DesignFence_%02d" % i)
		if fence != null:
			_override_material(fence,fence_mat)


func _build_trees() -> void:
	var placements: Array = [
		[Vector3(-33,0,-31),9.0,22.0],
		[Vector3(-20,0,-39),10.0,82.0],
		[Vector3(-5,0,-45),9.4,144.0],
		[Vector3(12,0,-47),10.2,205.0],
		[Vector3(28,0,-45),9.0,268.0],
		[Vector3(45,0,-40),10.4,320.0],
		[Vector3(54,0,-27),9.2,38.0],
		[Vector3(48,0,15),8.8,101.0],
		[Vector3(38,0,27),9.5,172.0],
		[Vector3(-27,0,23),8.8,242.0]
	]
	for i: int in range(placements.size()):
		var d: Array = placements[i]
		var p: Vector3 = d[0]
		p.y = _terrain_height(p.x,p.z)
		_add_asset(V7_TREE,p,d[1],d[2],"DesignTree_%02d" % i)
		tree_count += 1

	var bushes: Array[Vector3] = [
		Vector3(10,0,-3),Vector3(19,0,-6),Vector3(30,0,4),
		Vector3(9,0,19),Vector3(35,0,19),Vector3(43,0,-8)
	]
	for i: int in range(bushes.size()):
		var p := bushes[i]
		p.y = _terrain_height(p.x,p.z)+0.02
		var bush := _add_asset(BUSH,p,1.7,15.0+float(i)*47.0,"DesignBush_%02d" % i)
		if bush != null:
			_override_material(bush,_bush_material())


func _bush_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.10,0.18,0.07)
	mat.roughness = 0.96
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	return mat


func _build_vehicles() -> void:
	var p_mbt := Vector3(-8,0,13)
	p_mbt.y = _terrain_height(p_mbt.x,p_mbt.z)+0.14
	var mbt := _add_asset(MBT,p_mbt,6.6,-57.0,"HeroAbrams")
	if mbt != null:
		_apply_design_vehicle_materials(mbt,Color(0.34,0.36,0.20),Color(0.19,0.21,0.11))

	var p_ifv := Vector3(-4,0,5)
	p_ifv.y = _terrain_height(p_ifv.x,p_ifv.z)+0.12
	var ifv := _add_asset(IFV,p_ifv,5.2,-39.0,"SupportIFV")
	if ifv != null:
		_apply_design_vehicle_materials(ifv,Color(0.31,0.34,0.18),Color(0.17,0.19,0.10))

	var p_wreck := Vector3(10,0,3)
	p_wreck.y = _terrain_height(p_wreck.x,p_wreck.z)+0.09
	var wreck := _add_asset(IFV,p_wreck,4.8,37.0,"BurnedIFV")
	if wreck != null:
		wreck.rotation_degrees.z = -6.0
		_override_material(wreck,_wreck_material())

	var p_red := Vector3(31,0,-6)
	p_red.y = _terrain_height(p_red.x,p_red.z)+0.11
	var red_ifv := _add_asset(IFV,p_red,4.9,142.0,"EnemyIFV")
	if red_ifv != null:
		_apply_design_vehicle_materials(red_ifv,Color(0.27,0.18,0.12),Color(0.13,0.08,0.06))

	_add_infantry_group()
	vehicle_count = 4


func _apply_design_vehicle_materials(root: Node3D, a: Color, b: Color) -> void:
	var hull := _vehicle_finish_material(a,b)
	var track := StandardMaterial3D.new()
	track.albedo_color = Color(0.045,0.047,0.040)
	track.metallic = 0.34
	track.roughness = 0.88
	var metal := StandardMaterial3D.new()
	metal.albedo_color = Color(0.09,0.095,0.085)
	metal.metallic = 0.52
	metal.roughness = 0.70

	if root is MeshInstance3D:
		_apply_vehicle_mesh_material(root as MeshInstance3D,hull,track,metal)
	for item: Node in root.find_children("*","MeshInstance3D",true,false):
		var mi := item as MeshInstance3D
		if mi != null:
			_apply_vehicle_mesh_material(mi,hull,track,metal)


func _apply_vehicle_mesh_material(mi: MeshInstance3D,hull: Material,track: Material,metal: Material) -> void:
	if mi.mesh == null:
		return
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


func _vehicle_finish_material(a: Color,b: Color) -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
shader_type spatial;
varying vec3 lp;
uniform vec3 color_a : source_color;
uniform vec3 color_b : source_color;
void vertex(){ lp=VERTEX; }
void fragment(){
	float n=sin(lp.x*1.21+lp.z*0.53)+sin(lp.z*1.67-lp.x*0.41);
	float camo=smoothstep(-0.30,0.38,n);
	float lower=smoothstep(0.55,-0.55,lp.y);
	float speck=0.5+0.5*sin(lp.x*8.0+sin(lp.z*5.0));
	vec3 base=mix(color_a,color_b,camo*0.36);
	base=mix(base,vec3(0.18,0.14,0.09),lower*(0.18+0.12*speck));
	ALBEDO=base;
	METALLIC=0.20;
	ROUGHNESS=0.76;
	SPECULAR=0.31;
}
"""
	var mat := ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("color_a",Vector3(a.r,a.g,a.b))
	mat.set_shader_parameter("color_b",Vector3(b.r,b.g,b.b))
	return mat


func _add_infantry_group() -> void:
	var placements: Array = [
		[Vector3(-12,0,10),-45.0],
		[Vector3(-10,0,8),-38.0],
		[Vector3(-7,0,7),-31.0],
		[Vector3(-2,0,2),-22.0],
		[Vector3(1,0,0),-16.0]
	]
	for i: int in range(placements.size()):
		var p: Vector3 = placements[i][0]
		p.y = _terrain_height(p.x,p.z)
		_add_grounded_prop(SOLDIER,p,1.85,placements[i][1],"BlueInfantry_%02d" % i)


func _add_grounded_prop(path: String,p: Vector3,target: float,yaw: float,name_value: String) -> Node3D:
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
	node.position = Vector3(p.x,p.y-bottom+0.015,p.z)
	add_child(node)
	return node


func _build_camera() -> void:
	camera = Camera3D.new()
	camera.name = "QualityCamera"
	camera.fov = 41.0
	camera.position = Vector3(-27.0,18.8,31.0)
	add_child(camera)
	camera.look_at(Vector3(11.0,0.2,-2.0),Vector3.UP)
	camera.current = true
