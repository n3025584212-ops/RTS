extends "res://scripts/production/river_town_visual_slice.gd"
## Direct source proof for the six existing CC0 V20 Family House models.
## This scene deliberately uses the Run #5 baseline script, so create_armor()
## remains the accepted assets/visual_slice/abrams.glb implementation.

const PROOF_OUT := "res://artifacts/asset_family_v20"
const FAMILY_DIR := "res://assets/golden_scene/city_v20/"
# First direct proof showed imported source houses at only ~1.6-2.1 m tall.
# The source collection is therefore normalized as a family by a single 3x unit
# conversion, yielding plausible ~4.7-6.4 m residential height without changing
# the relative proportions between the six authored models.
const SOURCE_SCALE := 3.0
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
	# Abrams. Dynamic dispatch calls this proof's create_architecture/background.
	super._ready()

	# Review-board framing only, not production settlement topology.
	# Front row left->right = 00,01,02; rear row left->right = 03,04,05.
	camera.position = Vector3(0.0, 22.0, 56.0)
	camera.look_at(Vector3(0.0, 3.0, -22.0))
	camera.fov = 52.0
	camera.near = 0.2
	camera.far = 1200.0
	camera.current = true

	print("FRONTLINE_V20_FAMILY_PROOF_READY family_house_count=", family_houses.size(),
		" source_scale=", SOURCE_SCALE,
		" original_run5_abrams=YES extra_vehicle_count=0 background_buildings=NO renderer=",
		RenderingServer.get_current_rendering_method())

func create_architecture() -> void:
	# Keep one already-proven HF building as an in-frame quality ruler, without
	# reintroducing the old generic house family from the base scene.
	var anchor := spawn("res://scenes/production/RiverTownHeroHouseHF.tscn", Vector3(-42.0, height_at(-42.0, 2.0)-.05, 2.0), 0.92, 28.0)
	anchor.name = "ProtectedHeroHouseHF_QualityAnchor"
	create_hero_house_finish(anchor)

	# Controlled 2x3 review arrangement. This is deliberately easy to read and is
	# not a proposed battlefield/village layout.
	var placements: Array[Dictionary] = [
		{"p": Vector3(-27.0, 0.0, -14.0), "yaw": 8.0},
		{"p": Vector3(0.0, 0.0, -15.5), "yaw": -8.0},
		{"p": Vector3(27.0, 0.0, -14.0), "yaw": 11.0},
		{"p": Vector3(-27.0, 0.0, -39.0), "yaw": -6.0},
		{"p": Vector3(0.0, 0.0, -40.5), "yaw": 8.0},
		{"p": Vector3(27.0, 0.0, -39.0), "yaw": -10.0},
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
		var house := spawn(path, p, SOURCE_SCALE, float(spec["yaw"]), false)
		house.name = "V20_Source_%02d_%s" % [i, file_name.get_basename()]
		family_houses.append(house)
		house_bounds[house.name] = _combined_world_aabb(house)

func create_background() -> void:
	# The base Run #5 background includes additional houses. They are intentionally
	# suppressed only in this review scene so the six V20 sources cannot be confused
	# with unrelated historical building assets. Terrain, vegetation, sky, road,
	# water, atmosphere and the accepted Abrams remain the real Run #5 systems.
	pass

func _combined_world_aabb(root: Node3D) -> Dictionary:
	var initialized := false
	var world_box := AABB()
	for node: Node in root.find_children("*", "MeshInstance3D", true, false):
		var mi := node as MeshInstance3D
		if mi.mesh == null:
			continue
		var local_box := mi.get_aabb()
		for x in [local_box.position.x, local_box.end.x]:
			for y in [local_box.position.y, local_box.end.y]:
				for z in [local_box.position.z, local_box.end.z]:
					var corner := mi.to_global(Vector3(x, y, z))
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
		"source_scale": SOURCE_SCALE,
		"house_bounds_world": house_bounds,
		"review_mapping": "front-left/right: 00,01,02; rear-left/right: 03,04,05",
		"background_buildings_disabled": true,
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
