extends "res://scripts/production/quality/quality_test_world_v8.gd"

const CHURCH := "res://assets/golden_scene/city_real/church_landmark.glb"

func _preflight() -> void:
	for path: String in [
		MBT,IFV,HOUSE_0,HOUSE_1,HOUSE_2,HOUSE_3,V7_TREE,CHURCH,
		QUALITY_HDRI,FENCE_SIMPLE,FENCE_PLANKS,FENCE_GATE
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
		CHURCH,
		Vector3(42,0,-13),
		17.5,
		12.0,
		"VillageChurchLandmark",
		Vector2(11.0,8.0),
		Color(0.29,0.27,0.23)
	)
	if church != null:
		_tint_surfaces(church,Color(0.82,0.80,0.74))

	building_count = 5
	_build_yard_boundaries()


func _build_trees() -> void:
	var placements: Array = [
		[Vector3(31,0,-31),9.2,18.0],
		[Vector3(39,0,-27),10.0,72.0],
		[Vector3(49,0,-21),8.6,137.0],
		[Vector3(51,0,4),9.8,206.0],
		[Vector3(46,0,25),9.0,271.0],
		[Vector3(33,0,36),10.2,322.0],
		[Vector3(-40,0,-26),9.6,42.0],
		[Vector3(-50,0,-7),8.7,188.0]
	]
	for i: int in range(placements.size()):
		var d: Array = placements[i]
		var p: Vector3 = d[0]
		p.y = _terrain_height(p.x,p.z)
		_add_asset(V7_TREE,p,d[1],d[2],"QualityBroadleaf_%02d" % i)
		tree_count += 1


func _build_camera() -> void:
	camera = Camera3D.new()
	camera.name = "QualityCamera"
	camera.fov = 40.0
	camera.position = Vector3(-26.0,21.5,31.5)
	add_child(camera)
	camera.look_at(Vector3(13.0,-0.4,1.0),Vector3.UP)
	camera.current = true
