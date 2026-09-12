extends "res://scripts/production/river_town_visual_slice.gd"
## Direct source proof for the six existing CC0 V20 Family House models.
## This scene deliberately uses the Run #5 baseline script, so create_armor()
## remains the accepted assets/visual_slice/abrams.glb implementation.

const PROOF_OUT := "res://artifacts/asset_family_v20"
const FAMILY_DIR := "res://assets/golden_scene/city_v20/"
const FAMILY_FILES: Array[String] = [
	"family_house_00.glb",
	"family_house_01.glb",
	"family_house_02.glb",
	"family_house_03.glb",
	"family_house_04.glb",
	"family_house_05.glb",
]

var family_houses: Array[Node3D] = []
var house_bounds: Dictionary = {}

func _ready() -> void:
	# The base _ready() builds the Run #5 terrain, PBR, vegetation and the original
	# Abrams. Dynamic dispatch calls this proof's create_architecture().
	super._ready()

	# Wide RTS review framing: one frame must expose repetition, silhouette diversity,
	# scale problems and material failures across the whole six-model family.
	camera.position = Vector3(53.0, 23.0, 43.0)
	camera.look_at(Vector3(0.0, 2.3, -33.0))
	camera.fov = 49.0
	camera.near = 0.2
	camera.far = 1200.0
	camera.current = true

	print("FRONTLINE_V20_FAMILY_PROOF_READY family_house_count=", family_houses.size(),
		" original_run5_abrams=YES extra_vehicle_count=0 renderer=", RenderingServer.get_current_rendering_method())

func create_architecture() -> void:
	# Keep one already-proven HF building as an in-frame quality ruler, without
	# reintroducing the old generic house family from the base scene.
	var anchor := spawn("res://scenes/production/RiverTownHeroHouseHF.tscn", Vector3(-35.0, height_at(-35.0, 0.0)-.05, 0.0), 0.92, 28.0)
	anchor.name = "ProtectedHeroHouseHF_QualityAnchor"
	create_hero_house_finish(anchor)

	# Irregular village cluster. This is intentionally not a row and not a route/lane.
	var placements: Array[Dictionary] = [
		{"p": Vector3(-26.0, 0.0, -21.0), "yaw": 14.0},
		{"p": Vector3(-5.0, 0.0, -27.0), "yaw": -31.0},
		{"p": Vector3(18.0, 0.0, -20.0), "yaw": 23.0},
		{"p": Vector3(-22.0, 0.0, -49.0), "yaw": 67.0},
		{"p": Vector3(3.0, 0.0, -54.0), "yaw": -12.0},
		{"p": Vector3(28.0, 0.0, -45.0), "yaw": 38.0},
	]

	for i in range(FAMILY_FILES.size()):
		var file_name := FAMILY_FILES[i]
		var path := FAMILY_DIR + file_name
		if not FileAccess.file_exists(path):
			push_error("V20 family proof missing source asset: " + path)
			continue
		var spec := placements[i]
		var p: Vector3 = spec["p"]
		p.y = height_at(p.x, p.z)
		# architecture=false is deliberate: preserve each GLB's actual imported source
		# materials first. A white/broken source must remain visible as a failure.
		var house := spawn(path, p, 1.0, float(spec["yaw"]), false)
		house.name = "V20_Source_%02d_%s" % [i, file_name.get_basename()]
		family_houses.append(house)
		house_bounds[house.name] = _combined_local_aabb(house)

func _combined_local_aabb(root: Node3D) -> Dictionary:
	var initialized := false
	var world_box := AABB()
	for node: Node in root.find_children("*", "MeshInstance3D", true, false):
		var mi := node as MeshInstance3D
		if mi.mesh == null:
			continue
		var local_box := mi.get_aabb()
		var corners: Array[Vector3] = []
		for x in [local_box.position.x, local_box.end.x]:
			for y in [local_box.position.y, local_box.end.y]:
				for z in [local_box.position.z, local_box.end.z]:
					corners.append(root.to_local(mi.to_global(Vector3(x, y, z))))
		for corner in corners:
			if not initialized:
				world_box = AABB(corner, Vector3.ZERO)
				initialized = true
			else:
				world_box = world_box.expand(corner)
	return {
		"position": str(world_box.position),
		"size": str(world_box.size),
		"volume": world_box.get_volume(),
	}

func capture() -> void:
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(PROOF_OUT)
	var image := get_viewport().get_texture().get_image()
	var png_path := PROOF_OUT + "/asset_family_v20_actual_1920x1080.png"
	var err := image.save_png(png_path)
	var report := {
		"captured_at_utc": Time.get_datetime_string_from_system(true),
		"engine": Engine.get_version_info(),
		"renderer": RenderingServer.get_current_rendering_method(),
		"gpu": RenderingServer.get_video_adapter_name(),
		"width": image.get_width(),
		"height": image.get_height(),
		"save_error": err,
		"family_house_count": family_houses.size(),
		"family_files": FAMILY_FILES,
		"house_bounds": house_bounds,
		"original_run5_abrams_retained": true,
		"original_run5_baseline_script": "res://scripts/production/river_town_visual_slice.gd",
		"extra_vehicle_count": 0,
		"source_materials_preserved": true,
		"fallback_material_masking": false,
		"protected_hero_house_hf_retained": true,
		"post_capture_image_editing": false,
		"visual_acceptance": "NOT_CLAIMED",
		"draw_calls": Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
		"rendered_primitives": Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME),
	}
	FileAccess.open(PROOF_OUT + "/runtime_metrics.json", FileAccess.WRITE).store_string(JSON.stringify(report, "\t"))
	print("FRONTLINE_V20_FAMILY_CAPTURED ", png_path, " ", image.get_size(), " houses=", family_houses.size())
	get_tree().quit(err)
