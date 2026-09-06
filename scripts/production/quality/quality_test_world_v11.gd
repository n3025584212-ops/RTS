extends "res://scripts/production/quality/quality_test_world_v10.gd"

const FACTORY_MOD_0 := "res://assets/golden_scene/quality_v11_factory/factory_module_00.glb"
const FACTORY_MOD_1 := "res://assets/golden_scene/quality_v11_factory/factory_module_01.glb"
const FACTORY_MOD_2 := "res://assets/golden_scene/quality_v11_factory/factory_module_02.glb"

func _preflight() -> void:
	# Keep V10's proven asset set except the rejected residential block.
	for path: String in [
		MBT,IFV,HOUSE_0,HOUSE_1,HOUSE_2,HOUSE_3,V7_TREE,CHURCH,
		QUALITY_HDRI,FENCE_SIMPLE,FENCE_PLANKS,FENCE_GATE,
		FACTORY_MOD_0,FACTORY_MOD_1,FACTORY_MOD_2
	]:
		var exists := FileAccess.file_exists(path) if path.ends_with(".hdr") else ResourceLoader.exists(path)
		if not exists:
			push_error("QUALITY_TEST_REQUIRED_ASSET_MISSING path=%s" % path)


func _build_buildings() -> void:
	var placements: Array = [
		[HOUSE_0,Vector3(14,0,-14),9.5,8.0,"VillageHouseA",Color(0.80,0.78,0.73),Vector2(7.0,6.0)],
		[HOUSE_1,Vector3(25,0,-1),9.9,-11.0,"VillageHouseB",Color(0.78,0.77,0.72),Vector2(7.2,6.2)],
		[HOUSE_2,Vector3(16,0,13),9.6,6.0,"DamagedVillageHouse",Color(0.52,0.44,0.36),Vector2(7.0,6.0)],
		[HOUSE_3,Vector3(31,0,15),9.2,-4.0,"RearVillageHouse",Color(0.76,0.75,0.71),Vector2(6.8,5.8)]
	]
	for d: Array in placements:
		var node := _add_grounded_building(
			d[0],d[1],d[2],d[3],d[4],d[6],Color(0.28,0.25,0.21)
		)
		if node != null:
			_tint_surfaces(node,d[5])

	var church := _add_grounded_building(
		CHURCH,Vector3(42,0,-13),17.0,12.0,
		"VillageChurchLandmark",Vector2(11.0,8.0),Color(0.29,0.27,0.23)
	)
	if church != null:
		_apply_landmark_materials(church)

	_build_industrial_compound()
	building_count = 6
	_build_yard_boundaries()


func _build_industrial_compound() -> void:
	var center := Vector3(53,0,-28)
	var footprint := Vector2(19.0,12.0)
	var yaw := -6.0
	var ground_max := _footprint_ground_max(center.x,center.z,footprint,yaw)
	var ground_min := _footprint_ground_min(center.x,center.z,footprint,yaw)

	_add_industrial_shell(center,footprint,yaw,ground_min,ground_max)

	# Two adjoining front modules plus one side/loading module.
	_add_factory_module(
		FACTORY_MOD_0,
		Vector3(47.7,ground_max+0.04,-23.8),
		10.6,
		-6.0,
		"IndustrialFrontA"
	)
	_add_factory_module(
		FACTORY_MOD_1,
		Vector3(56.8,ground_max+0.04,-24.8),
		10.6,
		-6.0,
		"IndustrialFrontB"
	)
	_add_factory_module(
		FACTORY_MOD_2,
		Vector3(63.0,ground_max+0.04,-30.4),
		10.2,
		84.0,
		"IndustrialLoadingSide"
	)

	print(
		"FRONTLINE_QUALITY_FACTORY_COMPOUND base_min=%.3f base_max=%.3f modules=3" %
		[ground_min,ground_max]
	)


func _add_factory_module(
	path: String,
	position_value: Vector3,
	target: float,
	yaw: float,
	name_value: String
) -> void:
	var packed := load(path) as PackedScene
	if packed == null:
		push_error("QUALITY_TEST_ASSET_LOAD_FAIL path=%s" % path)
		return
	var node := packed.instantiate() as Node3D
	if node == null:
		return
	node.name = name_value
	_fit(node,target)
	node.rotation_degrees.y = yaw
	var bottom := _mesh_bottom_local(node)
	node.position = Vector3(
		position_value.x,
		position_value.y-bottom+0.015,
		position_value.z
	)
	add_child(node)
	_preserve_pbr_roughness(node)


func _add_industrial_shell(
	center: Vector3,
	footprint: Vector2,
	yaw: float,
	ground_min: float,
	ground_max: float
) -> void:
	var base_height := maxf(0.28,ground_max-ground_min+0.16)
	_add_foundation_pad(
		center,footprint,yaw,ground_min,ground_max,
		Color(0.25,0.24,0.21),"IndustrialCompound_Foundation"
	)

	var shell := MeshInstance3D.new()
	shell.name = "IndustrialCompound_Shell"
	var box := BoxMesh.new()
	box.size = Vector3(17.2,5.2,10.0)
	shell.mesh = box
	shell.position = Vector3(center.x,ground_max+2.6,center.z)
	shell.rotation_degrees.y = yaw
	shell.material_override = _industrial_wall_material()
	add_child(shell)

	var roof := MeshInstance3D.new()
	roof.name = "IndustrialCompound_Roof"
	var roof_box := BoxMesh.new()
	roof_box.size = Vector3(17.8,0.34,10.6)
	roof.mesh = roof_box
	roof.position = Vector3(center.x,ground_max+5.34,center.z)
	roof.rotation_degrees.y = yaw
	roof.material_override = _industrial_roof_material()
	add_child(roof)


func _industrial_wall_material() -> StandardMaterial3D:
	var mat := _pbr(
		"brick_wall_005",Vector3(5.5,5.5,5.5),
		Color(0.58,0.50,0.42),0.84
	)
	return mat


func _industrial_roof_material() -> StandardMaterial3D:
	var mat := _pbr(
		"asphalt_02",Vector3(5.0,5.0,5.0),
		Color(0.20,0.21,0.20),0.91
	)
	return mat


func _build_camera() -> void:
	camera = Camera3D.new()
	camera.name = "QualityCamera"
	camera.fov = 40.0
	camera.position = Vector3(-26.0,21.0,32.0)
	add_child(camera)
	camera.look_at(Vector3(15.0,-0.3,-1.0),Vector3.UP)
	camera.current = true
