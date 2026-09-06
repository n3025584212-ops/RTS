extends "res://scripts/production/quality/quality_test_world_v7.gd"

func _build_buildings() -> void:
	var placements: Array = [
		[HOUSE_0,Vector3(15,0,-14),9.6,8.0,"VillageHouseA",Color(0.78,0.77,0.73),Vector2(7.0,6.0)],
		[HOUSE_1,Vector3(25,0,0),10.0,-11.0,"VillageHouseB",Color(0.76,0.75,0.71),Vector2(7.2,6.2)],
		[HOUSE_2,Vector3(16,0,13),9.7,6.0,"DamagedVillageHouse",Color(0.50,0.43,0.36),Vector2(7.0,6.0)]
	]
	for d: Array in placements:
		var node := _add_grounded_building(
			d[0], d[1], d[2], d[3], d[4], d[6], Color(0.30,0.27,0.22)
		)
		if node != null:
			_tint_surfaces(node,d[5])

	var factory := _add_grounded_building(
		V7_FACTORY,
		Vector3(39,0,-8),
		30.0,
		18.0,
		"V7FactoryFacade",
		Vector2(20.0,9.5),
		Color(0.25,0.24,0.22)
	)
	if factory != null:
		_soften_factory_materials(factory)

	building_count = 4
	_build_yard_boundaries()


func _add_grounded_building(
	path: String,
	xz: Vector3,
	target: float,
	yaw: float,
	name_value: String,
	footprint: Vector2,
	foundation_color: Color
) -> Node3D:
	var packed := load(path) as PackedScene
	if packed == null:
		push_error("QUALITY_TEST_ASSET_LOAD_FAIL path=%s" % path)
		return null
	var node := packed.instantiate() as Node3D
	if node == null:
		return null

	node.name = name_value
	_fit(node,target)
	node.rotation_degrees.y = yaw

	var ground_max := _footprint_ground_max(xz.x,xz.z,footprint,yaw)
	var ground_min := _footprint_ground_min(xz.x,xz.z,footprint,yaw)
	var local_bottom := _mesh_bottom_local(node)
	node.position = Vector3(xz.x,ground_max-local_bottom+0.025,xz.z)
	add_child(node)

	_add_foundation_pad(
		Vector3(xz.x,0.0,xz.z),
		footprint,
		yaw,
		ground_min,
		ground_max,
		foundation_color,
		name_value + "_Foundation"
	)
	print(
		"FRONTLINE_QUALITY_BUILDING_GROUNDED name=%s bottom=%.3f ground_min=%.3f ground_max=%.3f final_y=%.3f" %
		[name_value,local_bottom,ground_min,ground_max,node.position.y]
	)
	return node


func _mesh_bottom_local(root: Node3D) -> float:
	var minimum := INF
	for item: Node in root.find_children("*","MeshInstance3D",true,false):
		var mi := item as MeshInstance3D
		if mi == null or mi.mesh == null:
			continue
		var relative := _relative_transform(root,mi)
		var aabb := mi.mesh.get_aabb()
		for corner: Vector3 in _aabb_corners(aabb):
			var p := relative * corner
			minimum = minf(minimum,p.y)
	if is_inf(minimum):
		return 0.0
	return minimum * root.scale.y


func _relative_transform(root: Node3D, node: Node3D) -> Transform3D:
	var chain: Array[Node3D] = []
	var cursor: Node = node
	while cursor != null and cursor != root:
		if cursor is Node3D:
			chain.push_front(cursor as Node3D)
		cursor = cursor.get_parent()
	var result := Transform3D.IDENTITY
	for part: Node3D in chain:
		result = result * part.transform
	return result


func _aabb_corners(aabb: AABB) -> Array[Vector3]:
	var p := aabb.position
	var s := aabb.size
	return [
		p,
		p+Vector3(s.x,0,0),
		p+Vector3(0,s.y,0),
		p+Vector3(0,0,s.z),
		p+Vector3(s.x,s.y,0),
		p+Vector3(s.x,0,s.z),
		p+Vector3(0,s.y,s.z),
		p+s
	]


func _footprint_ground_max(cx: float,cz: float,size: Vector2,yaw: float) -> float:
	var values := _footprint_ground_samples(cx,cz,size,yaw)
	var result := -INF
	for value: float in values:
		result = maxf(result,value)
	return result


func _footprint_ground_min(cx: float,cz: float,size: Vector2,yaw: float) -> float:
	var values := _footprint_ground_samples(cx,cz,size,yaw)
	var result := INF
	for value: float in values:
		result = minf(result,value)
	return result


func _footprint_ground_samples(cx: float,cz: float,size: Vector2,yaw: float) -> Array[float]:
	var half := size*0.5
	var angle := deg_to_rad(yaw)
	var basis_x := Vector2(cos(angle),-sin(angle))
	var basis_z := Vector2(sin(angle),cos(angle))
	var local_points: Array[Vector2] = [
		Vector2(-half.x,-half.y),Vector2(0,-half.y),Vector2(half.x,-half.y),
		Vector2(-half.x,0),Vector2(0,0),Vector2(half.x,0),
		Vector2(-half.x,half.y),Vector2(0,half.y),Vector2(half.x,half.y)
	]
	var result: Array[float] = []
	for lp: Vector2 in local_points:
		var world := Vector2(cx,cz)+basis_x*lp.x+basis_z*lp.y
		result.append(_terrain_height(world.x,world.y))
	return result


func _add_foundation_pad(
	center: Vector3,
	size: Vector2,
	yaw: float,
	ground_min: float,
	ground_max: float,
	color: Color,
	name_value: String
) -> void:
	var height := maxf(0.18,ground_max-ground_min+0.12)
	var pad := MeshInstance3D.new()
	pad.name = name_value
	var box := BoxMesh.new()
	box.size = Vector3(size.x,height,size.y)
	pad.mesh = box
	pad.position = Vector3(center.x,ground_max-height*0.5+0.005,center.z)
	pad.rotation_degrees.y = yaw
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.96
	mat.albedo_texture = load("res://assets/golden_scene/pbr/gravel_ground_01_diff_1k.png")
	mat.normal_enabled = true
	mat.normal_texture = load("res://assets/golden_scene/pbr/gravel_ground_01_nor_gl_1k.png")
	mat.uv1_scale = Vector3(2.5,2.5,2.5)
	pad.material_override = mat
	add_child(pad)
