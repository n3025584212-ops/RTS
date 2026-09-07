extends "res://scripts/production/quality/quality_test_world_v14.gd"

const RUBBLE_SMALL := "res://assets/golden_scene/nature/062_rock_smallA.glb"
const RUBBLE_LARGE := "res://assets/golden_scene/nature/056_rock_largeA.glb"

func _preflight() -> void:
	super._preflight()
	for path: String in [RUBBLE_SMALL,RUBBLE_LARGE]:
		if not ResourceLoader.exists(path):
			push_error("QUALITY_TEST_REQUIRED_ASSET_MISSING path=%s" % path)


func _build_environment() -> void:
	super._build_environment()
	var env_node := get_node_or_null("QualityEnvironment") as WorldEnvironment
	if env_node != null and env_node.environment != null:
		var env := env_node.environment
		env.background_energy_multiplier = 1.02
		env.ambient_light_energy = 0.76
		env.fog_density = 0.00335
		env.fog_aerial_perspective = 0.62
		env.adjustment_contrast = 1.06
		env.adjustment_saturation = 0.88
		if env.sky != null and env.sky.sky_material is ProceduralSkyMaterial:
			var sky_mat := env.sky.sky_material as ProceduralSkyMaterial
			sky_mat.sky_top_color = Color(0.34,0.43,0.50)
			sky_mat.sky_horizon_color = Color(0.64,0.65,0.61)
			sky_mat.ground_horizon_color = Color(0.50,0.50,0.44)


func _design_terrain_material() -> ShaderMaterial:
	var mat := super._design_terrain_material()
	if mat != null and mat.shader != null:
		var code := mat.shader.code
		code = code.replace("field_a*0.36","field_a*0.56")
		code = code.replace("field_b*0.22","field_b*0.34")
		code = code.replace("town*0.22","town*0.28")
		code = code.replace("churn*0.34","churn*0.42")
		mat.shader.code = code
	return mat


func _build_buildings() -> void:
	super._build_buildings()
	_add_rubble_cluster(Vector3(18,0,9),0.0)
	_add_rubble_cluster(Vector3(11,0,3),75.0)


func _add_rubble_cluster(center: Vector3,yaw: float) -> void:
	var placements: Array = [
		[RUBBLE_LARGE,Vector3(-1.4,0,-0.7),1.2,yaw+12.0],
		[RUBBLE_SMALL,Vector3(0.2,0,0.4),0.75,yaw+47.0],
		[RUBBLE_SMALL,Vector3(1.3,0,-0.2),0.65,yaw+91.0],
		[RUBBLE_SMALL,Vector3(-0.4,0,1.1),0.62,yaw+131.0]
	]
	var rubble_mat := StandardMaterial3D.new()
	rubble_mat.albedo_color = Color(0.19,0.17,0.145)
	rubble_mat.roughness = 0.97
	for i: int in range(placements.size()):
		var d: Array = placements[i]
		var offset: Vector3 = d[1]
		var p: Vector3 = center + offset
		p.y = _terrain_height(p.x,p.z)+0.02
		var rock := _add_asset(d[0],p,d[2],d[3],"BattleRubble_%02d" % i)
		if rock != null:
			_override_material(rock,rubble_mat)


func _build_trees() -> void:
	# Background treeline: a visible depth layer, not isolated specimen trees.
	var placements: Array = [
		[Vector3(-38,0,-39),9.0,12.0],
		[Vector3(-28,0,-45),10.0,51.0],
		[Vector3(-17,0,-49),8.8,92.0],
		[Vector3(-6,0,-51),10.2,133.0],
		[Vector3(6,0,-52),9.2,176.0],
		[Vector3(18,0,-51),10.0,214.0],
		[Vector3(30,0,-48),8.9,252.0],
		[Vector3(42,0,-44),10.3,292.0],
		[Vector3(53,0,-37),9.1,330.0],
		[Vector3(58,0,-26),9.8,29.0],
		[Vector3(48,0,17),8.7,83.0],
		[Vector3(39,0,28),9.2,147.0],
		[Vector3(-30,0,24),8.6,213.0]
	]
	for i: int in range(placements.size()):
		var d: Array = placements[i]
		var p: Vector3 = d[0]
		p.y = _terrain_height(p.x,p.z)
		_add_asset(V7_TREE,p,d[1],d[2],"DesignTreeline_%02d" % i)
		tree_count += 1

	var bushes: Array[Vector3] = [
		Vector3(7,0,-5),Vector3(12,0,-6),Vector3(20,0,-7),
		Vector3(29,0,4),Vector3(31,0,8),Vector3(9,0,17),
		Vector3(35,0,18),Vector3(43,0,-10)
	]
	for i: int in range(bushes.size()):
		var p: Vector3 = bushes[i]
		p.y = _terrain_height(p.x,p.z)+0.02
		var bush := _add_asset(BUSH,p,1.9,17.0+float(i)*39.0,"DesignHedge_%02d" % i)
		if bush != null:
			_override_material(bush,_bush_material())


func _add_infantry_group() -> void:
	var placements: Array = [
		[Vector3(-11,0,10),-46.0],
		[Vector3(-9,0,8),-39.0],
		[Vector3(-6,0,7),-31.0],
		[Vector3(-3,0,4),-24.0],
		[Vector3(0,0,2),-18.0],
		[Vector3(3,0,0),-12.0]
	]
	var uniform := StandardMaterial3D.new()
	uniform.albedo_color = Color(0.17,0.20,0.11)
	uniform.roughness = 0.90
	for i: int in range(placements.size()):
		var p: Vector3 = placements[i][0]
		p.y = _terrain_height(p.x,p.z)
		var soldier := _add_grounded_prop(
			SOLDIER,p,2.05,placements[i][1],"BlueInfantry_%02d" % i
		)
		if soldier != null:
			_override_material(soldier,uniform)


func _build_camera() -> void:
	camera = Camera3D.new()
	camera.name = "QualityCamera"
	camera.fov = 39.0
	camera.position = Vector3(-23.5,16.8,27.0)
	add_child(camera)
	camera.look_at(Vector3(12.5,0.4,-2.0),Vector3.UP)
	camera.current = true
