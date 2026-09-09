extends SceneTree
## Checks the reusable scene contract. Visual acceptance still requires Forward+.
func _initialize() -> void:
	call_deferred("verify")

func verify() -> void:
	var scene := load("res://scenes/production/RiverTownHeroHouseHF.tscn") as PackedScene
	var instances: Array[Node3D] = []
	var failures: Array[String] = []
	for i in range(3):
		var house := scene.instantiate() as Node3D
		house.position = Vector3(i*22.,i*.7,-i*6.)
		house.rotation_degrees.y = i*67.
		house.scale = Vector3.ONE*(1.+i*.13)
		root.add_child(house)
		instances.append(house)
	await process_frame
	instances[1].position += Vector3(5.,1.,3.)
	await process_frame
	for index in range(instances.size()):
		var house := instances[index]
		if house.finishes.size() != 2:failures.append("House %d did not bind both finishes" % index)
		if index > 0 and house.finishes[0] == instances[0].finishes[0]:
			failures.append("House %d shares mutable finish settings" % index)
		var meshes := house.find_children("*","MeshInstance3D",true,false)
		if meshes.size() != 8:failures.append("House %d changed authored mesh batching" % index)
		var reference := instances[0].find_children("*","MeshInstance3D",true,false)
		for part in range(min(meshes.size(),reference.size())):
			if meshes[part].mesh != reference[part].mesh:failures.append("Repeated house duplicated its mesh")
			if not meshes[part].transform.is_equal_approx(Transform3D.IDENTITY):
				failures.append("Mesh part left the common object coordinate system")
			for surface_index in range(meshes[part].mesh.get_surface_count()):
				if meshes[part].get_active_material(surface_index) == null:failures.append("Missing house material")
	var road = load("res://assets/visual_slice/profiles/road_high_fidelity.tres")
	var h0: float = road.displacement(road.track_half_spacing,10.)
	var h1: float = road.displacement(road.track_half_spacing,10.+road.tread_pitch)
	if absf(h0-h1)>.0001:failures.append("Tread spacing is not repeatable")
	var report := {"instances":3,"placements":"translated, rotated, uniformly scaled, then moved after ready","mesh_resources_shared":true,"surfaces_per_house":8,"failures":failures,"passed":failures.is_empty()}
	report["renderer"]=RenderingServer.get_current_rendering_method()
	report["gpu"]=RenderingServer.get_video_adapter_name()
	DirAccess.make_dir_recursive_absolute("res://artifacts/visual_reset")
	FileAccess.open("res://artifacts/visual_reset/replication_validation.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LOCAL_FIDELITY_REPLICATION ",JSON.stringify(report))
	await process_frame
	await process_frame
	for house in instances:house.queue_free()
	await process_frame
	await process_frame
	quit(0 if failures.is_empty() else 1)
