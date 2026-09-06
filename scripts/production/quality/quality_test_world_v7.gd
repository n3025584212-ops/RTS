extends "res://scripts/production/quality/quality_test_world_v6.gd"

const V7_TREE := "res://assets/golden_scene/quality_v7/tree_small_02_lod.glb"
const V7_FACTORY := "res://assets/golden_scene/quality_v7/modular_factory_facade.glb"

func _preflight() -> void:
	super._preflight()
	for path: String in [V7_TREE,V7_FACTORY]:
		if not ResourceLoader.exists(path):
			push_error("QUALITY_TEST_REQUIRED_ASSET_MISSING path=%s" % path)


func _build_buildings() -> void:
	var placements: Array = [
		[HOUSE_0,Vector3(15,0,-14),9.6,8.0,"VillageHouseA",Color(0.78,0.77,0.73)],
		[HOUSE_1,Vector3(25,0,0),10.0,-11.0,"VillageHouseB",Color(0.76,0.75,0.71)],
		[HOUSE_2,Vector3(16,0,13),9.7,6.0,"DamagedVillageHouse",Color(0.50,0.43,0.36)]
	]
	for d: Array in placements:
		var p: Vector3 = d[1]
		p.y = _terrain_height(p.x,p.z) + 0.08
		var node := _add_asset(d[0],p,d[2],d[3],d[4])
		if node != null:
			_tint_surfaces(node,d[5])

	var factory_p := Vector3(39,0,-8)
	factory_p.y = _terrain_height(factory_p.x,factory_p.z) + 0.08
	var factory := _add_asset(V7_FACTORY,factory_p,30.0,18.0,"V7FactoryFacade")
	if factory != null:
		_soften_factory_materials(factory)

	building_count = 4
	_build_yard_boundaries()


func _soften_factory_materials(root: Node3D) -> void:
	for item: Node in root.find_children("*","MeshInstance3D",true,false):
		var mi := item as MeshInstance3D
		if mi == null or mi.mesh == null:
			continue
		for surface: int in range(mi.mesh.get_surface_count()):
			var source := mi.get_active_material(surface)
			if source is StandardMaterial3D:
				var mat := source.duplicate() as StandardMaterial3D
				mat.roughness = maxf(mat.roughness,0.62)
				mi.set_surface_override_material(surface,mat)


func _build_trees() -> void:
	var placements: Array = [
		[Vector3(31,0,-30),9.4,18.0],
		[Vector3(40,0,-25),10.2,72.0],
		[Vector3(47,0,-16),8.8,137.0],
		[Vector3(48,0,5),10.0,206.0],
		[Vector3(43,0,22),9.2,271.0],
		[Vector3(31,0,34),10.4,322.0],
		[Vector3(-38,0,-25),9.8,42.0],
		[Vector3(-48,0,-5),8.9,188.0]
	]
	for i: int in range(placements.size()):
		var d: Array = placements[i]
		var p: Vector3 = d[0]
		p.y = _terrain_height(p.x,p.z)
		_add_asset(V7_TREE,p,d[1],d[2],"V7Broadleaf_%02d" % i)
		tree_count += 1


func _build_camera() -> void:
	camera = Camera3D.new()
	camera.name = "QualityCamera"
	camera.fov = 39.0
	camera.position = Vector3(-25.0,21.0,31.0)
	add_child(camera)
	camera.look_at(Vector3(12.0,-0.6,1.0),Vector3.UP)
	camera.current = true
