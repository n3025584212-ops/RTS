extends "res://scripts/production/river_town_hero_shot_v2.gd"
## Additive asset validation in the existing complete Hero V2 environment.
var workshop: Node3D
var asset_view := "workshop"

func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--asset-view="): asset_view = arg.get_slice("=",1)
	super._ready()
	workshop = (load("res://scenes/production/RepairWorkshop.tscn") as PackedScene).instantiate()
	workshop.position = Vector3(23, height_at(23,-7)+.10,-7)
	workshop.rotation_degrees.y = -10.0
	add_child(workshop)
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--asset-lod="): workshop.set_lod_override(int(arg.get_slice("=",1)))
	# Only relocate grass covered by the added building; keep every instance.
	for child in get_children():
		if not child is MultiMeshInstance3D or not child.name.begins_with("grass_"): continue
		var mm: MultiMesh = child.multimesh
		for i in range(mm.instance_count):
			var t := mm.get_instance_transform(i)
			var local := workshop.to_local(t.origin)
			if absf(local.x)<6.65 and local.z>-6.6 and local.z<8.3:
				t.origin.x += 16.0
				t.origin.y = height_at(t.origin.x,t.origin.z)+.02
				mm.set_instance_transform(i,t)
	set_asset_camera()
	capture_view = "industrial_"+asset_view
	print("WORKSHOP_VALIDATION_READY asset_view=",asset_view," forced_lod=",workshop.forced_lod)

func set_asset_camera() -> void:
	if asset_view == "workshop":
		camera.position = workshop.to_global(Vector3(16,10,21))
		camera.look_at(workshop.to_global(Vector3(0,2.5,0)))
		camera.fov = 46.0
	elif asset_view == "rear":
		camera.position = workshop.to_global(Vector3(-16,9,-20))
		camera.look_at(workshop.to_global(Vector3(0,2.4,0)))
		camera.fov = 46.0
	elif asset_view == "detail":
		camera.position = workshop.to_global(Vector3(8.5,4.4,13.5))
		camera.look_at(workshop.to_global(Vector3(1.4,2.3,5.4)))
		camera.fov = 49.0
	elif asset_view == "overview":
		camera.position = Vector3(39,26,48)
		camera.look_at(Vector3(5,1,-3))
		camera.fov = 48.0
	elif asset_view == "reference":
		camera.position = Vector3(15,12,21)
		camera.look_at(Vector3(-4,.4,-2))
		camera.fov = 40.0
