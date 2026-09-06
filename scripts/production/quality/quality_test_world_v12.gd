extends "res://scripts/production/quality/quality_test_world_v11.gd"

func _build_industrial_compound() -> void:
	# Keep the industrial compound laterally separated from the church so it
	# reads as its own low-rise yard rather than a backdrop glued to the landmark.
	var center := Vector3(54,0,3)
	var footprint := Vector2(16.0,9.5)
	var yaw := -8.0
	var ground_max := _footprint_ground_max(center.x,center.z,footprint,yaw)
	var ground_min := _footprint_ground_min(center.x,center.z,footprint,yaw)

	_add_industrial_shell_v12(center,footprint,yaw,ground_min,ground_max)

	# Two adjacent low front bays.
	_add_factory_module(
		FACTORY_MOD_0,
		Vector3(49.0,ground_max+0.04,7.0),
		7.8,
		-8.0,
		"IndustrialFrontBayA"
	)
	_add_factory_module(
		FACTORY_MOD_1,
		Vector3(56.0,ground_max+0.04,6.0),
		7.8,
		-8.0,
		"IndustrialFrontBayB"
	)
	# One perpendicular side/loading bay gives the compound visible depth.
	_add_factory_module(
		FACTORY_MOD_2,
		Vector3(62.0,ground_max+0.04,1.4),
		7.4,
		82.0,
		"IndustrialSideLoadingBay"
	)

	print(
		"FRONTLINE_QUALITY_FACTORY_COMPOUND_V12 base_min=%.3f base_max=%.3f modules=3" %
		[ground_min,ground_max]
	)


func _add_industrial_shell_v12(
	center: Vector3,
	footprint: Vector2,
	yaw: float,
	ground_min: float,
	ground_max: float
) -> void:
	_add_foundation_pad(
		center,footprint,yaw,ground_min,ground_max,
		Color(0.24,0.23,0.205),"IndustrialCompoundV12_Foundation"
	)

	var shell := MeshInstance3D.new()
	shell.name = "IndustrialCompoundV12_Shell"
	var box := BoxMesh.new()
	box.size = Vector3(14.2,4.2,7.8)
	shell.mesh = box
	shell.position = Vector3(center.x,ground_max+2.1,center.z)
	shell.rotation_degrees.y = yaw
	shell.material_override = _industrial_wall_material()
	add_child(shell)

	var roof := MeshInstance3D.new()
	roof.name = "IndustrialCompoundV12_Roof"
	var roof_box := BoxMesh.new()
	roof_box.size = Vector3(14.8,0.28,8.4)
	roof.mesh = roof_box
	roof.position = Vector3(center.x,ground_max+4.34,center.z)
	roof.rotation_degrees.y = yaw
	roof.material_override = _industrial_roof_material()
	add_child(roof)

	# Dark concrete apron anchors the loading bays to the terrain.
	_add_masked_patch(
		"IndustrialLoadingApron",
		Vector3(center.x-0.5,ground_max+0.055,center.z+5.3),
		Vector2(14.0,5.2),
		yaw,
		"gravel_ground_01",
		Color(0.34,0.33,0.30)
	)
