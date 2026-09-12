extends "res://scripts/production/golden/golden_world_v24.gd"

# V25 focuses on the two largest V24 still-frame gaps without replacing the
# proven town layout: grade the authored family-house materials so the town no
# longer reads as bright toy blocks, and blend the vehicle churn into terrain
# rather than leaving dark painted strips.


func _build_materials() -> void:
	super._build_materials()
	if _v24_track_material != null:
		_v24_track_material.albedo_color = Color(0.35, 0.285, 0.195)
		_v24_track_material.roughness = 0.96


func _build_town() -> void:
	super._build_town()
	_grade_v25_family_houses()
	_add_v25_lot_grounding()


func _add_v24_track_strip(start: Vector3, finish: Vector3, width: float, wobble_phase: float, node_name: String) -> void:
	# V24 proved that churn helps contact, but it was too wide/dark. Preserve the
	# terrain-conforming mesh and irregular edges at roughly half the width.
	super._add_v24_track_strip(start, finish, width * 0.56, wobble_phase, node_name)


func _grade_v25_family_houses() -> void:
	var tints: Array[Color] = [
		Color(0.76, 0.78, 0.72),
		Color(0.82, 0.75, 0.66),
		Color(0.72, 0.74, 0.70),
		Color(0.79, 0.72, 0.64),
		Color(0.70, 0.73, 0.68),
		Color(0.84, 0.77, 0.69)
	]
	for i: int in range(22):
		var house := get_node_or_null("V21TownHouse_%02d" % i) as Node3D
		if house == null:
			continue
		_v25_grade_authored_materials(house, tints[i % tints.size()], i)


func _v25_grade_authored_materials(root: Node3D, tint: Color, index: int) -> void:
	for node_variant: Node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := node_variant as MeshInstance3D
		if mesh_instance == null or mesh_instance.mesh == null:
			continue
		for surface: int in range(mesh_instance.mesh.get_surface_count()):
			var source := mesh_instance.get_active_material(surface)
			if source is StandardMaterial3D:
				var material := (source as StandardMaterial3D).duplicate(true) as StandardMaterial3D
				var base := material.albedo_color
				var local_tint := tint
				# A few combat-facing structures are deliberately sootier, but still
				# preserve the authored diffuse/normal maps and geometry.
				if index in [4, 8, 13, 17]:
					local_tint *= Color(0.76, 0.74, 0.70)
				material.albedo_color = Color(
					base.r * local_tint.r,
					base.g * local_tint.g,
					base.b * local_tint.b,
					base.a
				)
				material.roughness = maxf(material.roughness, 0.70)
				material.metallic = minf(material.metallic, 0.08)
				mesh_instance.set_surface_override_material(surface, material)


func _add_v25_lot_grounding() -> void:
	var lots: Array = [
		[Vector3(25,0,-26), Vector2(4.7,3.3), -8.0, _v23_dry_material],
		[Vector3(45,0,-25), Vector2(5.0,3.1), 7.0, _v23_mud_material],
		[Vector3(68,0,-24), Vector2(4.6,3.0), -4.0, _v23_dry_material],
		[Vector3(25,0,10), Vector2(4.4,3.0), 12.0, _v23_mud_material],
		[Vector3(47,0,10), Vector2(4.8,3.1), -9.0, _v23_dry_material],
		[Vector3(69,0,11), Vector2(4.6,3.0), 5.0, _v23_mud_material],
		[Vector3(52,0,-3), Vector2(4.4,2.8), 14.0, _v23_dry_material]
	]
	for i: int in range(lots.size()):
		var data: Array = lots[i]
		_add_v23_ground_patch(
			data[0], data[1], float(data[2]), data[3], "V25LotGround_%02d" % i
		)
