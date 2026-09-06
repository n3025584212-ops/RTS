extends "res://scripts/production/quality/quality_test_world_v4.gd"

const HOUSE_4 := "res://assets/golden_scene/city_v20/family_house_04.glb"
const HOUSE_5 := "res://assets/golden_scene/city_v20/family_house_05.glb"

const V5_X_MIN := -230.0
const V5_X_MAX := 230.0
const V5_Z_MIN := -200.0
const V5_Z_MAX := 200.0

func _preflight() -> void:
	super._preflight()
	for path: String in [HOUSE_4,HOUSE_5]:
		if not ResourceLoader.exists(path):
			push_error("QUALITY_TEST_REQUIRED_ASSET_MISSING path=%s" % path)


func _build_environment() -> void:
	super._build_environment()
	var env_node := get_node_or_null("QualityEnvironment") as WorldEnvironment
	if env_node != null and env_node.environment != null:
		var env := env_node.environment
		env.background_energy_multiplier = 0.70
		env.ambient_light_energy = 0.50
		env.fog_density = 0.00245
		env.fog_height_density = 0.008
		env.fog_aerial_perspective = 0.52
		env.fog_sky_affect = 0.24
		env.adjustment_contrast = 1.08
		env.adjustment_saturation = 0.88
	var sun := get_node_or_null("QualityKeySun") as DirectionalLight3D
	if sun != null:
		sun.light_energy = 1.24


func _build_ground() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var nx := 121
	var nz := 105
	var dx := (V5_X_MAX - V5_X_MIN) / float(nx - 1)
	var dz := (V5_Z_MAX - V5_Z_MIN) / float(nz - 1)
	for zi: int in range(nz - 1):
		for xi: int in range(nx - 1):
			var x0 := V5_X_MIN + float(xi) * dx
			var x1 := x0 + dx
			var z0 := V5_Z_MIN + float(zi) * dz
			var z1 := z0 + dz
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
	terrain.name = "QualityExtendedTerrain"
	terrain.mesh = st.commit()
	terrain.material_override = _quality_terrain_material()
	terrain.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	add_child(terrain)

	var road_points: Array[Vector3] = [
		Vector3(-20,0,72),Vector3(-13,0,50),Vector3(-8,0,34),Vector3(-4,0,23),
		Vector3(1,0,14),Vector3(7,0,6),Vector3(15,0,-1),Vector3(25,0,-8),
		Vector3(40,0,-14),Vector3(62,0,-21)
	]
	_add_road_ribbon(road_points,8.8,"gravel_ground_01",Color(0.37,0.35,0.30),"V5RoadShoulder",0.040)
	_add_road_ribbon(road_points,5.7,"grass_path_3",Color(0.50,0.44,0.34),"V5VillageRoad",0.062)

	for data: Array in [
		[Vector3(-55,0,-38),Vector2(64,34),-7.0,"dirt_aerial_03",Color(0.48,0.41,0.31)],
		[Vector3(58,0,-44),Vector2(52,31),6.0,"grass_path_3",Color(0.50,0.48,0.33)],
		[Vector3(-48,0,58),Vector2(70,30),5.0,"dirt_aerial_03",Color(0.52,0.44,0.31)],
		[Vector3(68,0,43),Vector2(54,29),-8.0,"aerial_mud_1",Color(0.45,0.39,0.29)]
	]:
		var fp: Vector3 = data[0]
		fp.y = _terrain_height(fp.x,fp.z) + 0.052
		_add_masked_patch("V5Field",fp,data[1],data[2],data[3],data[4])

	for data: Array in [
		[Vector3(17,0,-13),Vector2(15,11),8.0,"gravel_ground_01",Color(0.42,0.40,0.35)],
		[Vector3(27,0,-3),Vector2(15,11),-8.0,"dirt_aerial_03",Color(0.48,0.42,0.34)],
		[Vector3(19,0,9),Vector2(15,11),6.0,"aerial_mud_1",Color(0.36,0.30,0.24)],
		[Vector3(9,0,19),Vector2(14,10),-5.0,"gravel_ground_01",Color(0.41,0.39,0.34)]
	]:
		var yp: Vector3 = data[0]
		yp.y = _terrain_height(yp.x,yp.z) + 0.074
		_add_masked_patch("V5VillageYard",yp,data[1],data[2],data[3],data[4])


func _add_v5_terrain_vertex(st: SurfaceTool, p: Vector3) -> void:
	st.set_normal(_terrain_normal(p.x,p.z))
	st.set_uv(Vector2(
		(p.x-V5_X_MIN)/(V5_X_MAX-V5_X_MIN),
		(p.z-V5_Z_MIN)/(V5_Z_MAX-V5_Z_MIN)
	))
	st.add_vertex(p)


func _build_buildings() -> void:
	var placements: Array = [
		[HOUSE_0,Vector3(17,0,-13),10.1,8.0,"FamilyHouseA",Color(0.86,0.84,0.80)],
		[HOUSE_1,Vector3(27,0,-3),10.7,-12.0,"FamilyHouseB",Color(0.84,0.82,0.78)],
		[HOUSE_2,Vector3(19,0,9),10.3,7.0,"DamagedFamilyHouse",Color(0.58,0.50,0.42)],
		[HOUSE_3,Vector3(9,0,19),9.9,-7.0,"FamilyHouseD",Color(0.85,0.83,0.79)],
		[HOUSE_4,Vector3(33,0,16),9.5,14.0,"RearHouseE",Color(0.78,0.79,0.76)],
		[HOUSE_5,Vector3(39,0,-16),9.2,-4.0,"RearHouseF",Color(0.80,0.78,0.74)]
	]
	for d: Array in placements:
		var p: Vector3 = d[1]
		p.y = _terrain_height(p.x,p.z) + 0.08
		var node := _add_asset(d[0],p,d[2],d[3],d[4])
		if node != null:
			_tint_surfaces(node,d[5])
	building_count = placements.size()


func _build_vehicles() -> void:
	var p_mbt := Vector3(-8,0,12)
	p_mbt.y = _terrain_height(p_mbt.x,p_mbt.z) + 0.15
	var mbt := _add_asset(MBT,p_mbt,7.2,-66.0,"HeroAbrams")
	if mbt != null:
		_override_material(mbt,_vehicle_material(Color(0.31,0.34,0.18),0.28))

	var p_ifv := Vector3(0,0,18)
	p_ifv.y = _terrain_height(p_ifv.x,p_ifv.z) + 0.13
	var ifv := _add_asset(IFV,p_ifv,5.8,-72.0,"SupportIFV")
	if ifv != null:
		_override_material(ifv,_vehicle_material(Color(0.29,0.31,0.17),0.22))

	var p_wreck := Vector3(10,0,2)
	p_wreck.y = _terrain_height(p_wreck.x,p_wreck.z) + 0.10
	var wreck := _add_asset(IFV,p_wreck,5.2,35.0,"BurnedIFV")
	if wreck != null:
		wreck.rotation_degrees.z = -6.0
		_override_material(wreck,_wreck_material())
	vehicle_count = 3


func _build_trees() -> void:
	var placements: Array = [
		[Vector3(31,0,-31),11.0,18.0],[Vector3(40,0,-27),12.0,82.0],
		[Vector3(48,0,-18),10.6,134.0],[Vector3(50,0,-5),11.5,205.0],
		[Vector3(47,0,10),10.5,266.0],[Vector3(42,0,25),12.2,319.0],
		[Vector3(31,0,35),11.0,44.0],[Vector3(-40,0,-30),12.0,302.0],
		[Vector3(-50,0,-10),10.5,226.0]
	]
	for i: int in range(placements.size()):
		var d: Array = placements[i]
		var p: Vector3 = d[0]
		p.y = _terrain_height(p.x,p.z)
		_add_asset(REAL_PINE,p,d[1],d[2],"V5RealPine_%02d" % i)
		tree_count += 1


func _build_camera() -> void:
	camera = Camera3D.new()
	camera.name = "QualityCamera"
	camera.fov = 42.0
	camera.position = Vector3(-26.5,17.2,30.5)
	add_child(camera)
	camera.look_at(Vector3(10.0,1.0,2.0),Vector3.UP)
	camera.current = true
