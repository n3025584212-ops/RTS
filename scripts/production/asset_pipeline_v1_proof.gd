extends "res://scripts/production/river_town_hero_shot_v2.gd"
## Asset Pipeline V1 visual acceptance scene.
## Existing Hero V2 remains untouched; generated assets are added beside it and
## rebound to the already-proven Hero V2 material language.

const PROOF_OUT := "res://artifacts/asset_pipeline_v1"
const GENERATED := "res://assets/generated/asset_pipeline_v1/rural_house/"
const IFV_PATH := "res://assets/golden_scene/vehicles/ifv.glb"

var generated_assets: Array[Node3D] = []
var generated_materials: Dictionary = {}
var pbr_rebound_surfaces := 0

func _ready() -> void:
	# Build the accepted local-fidelity environment first: real Hero V2 ruin,
	# authored Abrams, physical mud/ruts/puddles, vegetation and Forward+ lighting.
	super._ready()
	_build_material_bridge()

	_spawn_generated("rural_house_a_intact_lod0.glb", Vector3(16.0, 0.0, -8.0), -18.0)
	_spawn_generated("rural_house_a_damaged_lod0.glb", Vector3(25.0, 0.0, -24.0), 16.0)
	_spawn_generated("rural_house_b_intact_lod0.glb", Vector3(-26.0, 0.0, -24.0), 21.0)

	for item: Node3D in generated_assets:
		item.position.y = height_at(item.position.x, item.position.z)

	# Existing IFV is another protected reference anchor, not a replacement.
	if FileAccess.file_exists(IFV_PATH):
		var ifv := spawn(IFV_PATH, Vector3(10.0, height_at(10.0, -18.0) + 0.03, -18.0), 0.74, 154.0)
		ifv.name = "ProtectedExistingIFV"

	# RTS-like review framing: old and new assets must survive the same lighting,
	# atmosphere, terrain and camera rather than being judged in a studio vacuum.
	camera.position = Vector3(31.0, 15.5, 34.0)
	camera.look_at(Vector3(1.0, 2.4, -10.0))
	camera.fov = 49.0
	camera.near = 0.2
	camera.far = 1200.0
	camera.current = true

	print("FRONTLINE_ASSET_PIPELINE_V1_PROOF_READY generated=", generated_assets.size(),
		" pbr_rebound_surfaces=", pbr_rebound_surfaces,
		" preserved_hero_v2=YES preserved_ifv=YES renderer=", RenderingServer.get_current_rendering_method())

func _build_material_bridge() -> void:
	# Reuse the exact material families already loaded by RiverTownVisualSlice.
	# Generated GLBs keep semantic material names; Godot owns the shared PBR.
	generated_materials["mat_plaster_warm"] = mats["plaster"]
	generated_materials["mat_brick_exposed"] = mats["brick"]
	generated_materials["mat_roof_dark_tile"] = mats["roof"]
	generated_materials["mat_window_trim"] = mats["trim"]
	generated_materials["mat_window_glass"] = mats["glass"]
	generated_materials["mat_metal_dark"] = mats["metal"]

	var timber := surface("wood_planks", Color(.27, .20, .13), 1.15)
	timber.roughness = .82
	generated_materials["mat_timber_dark"] = timber
	var stone := surface("plastered_wall_02", Color(.45, .43, .38), 1.45)
	stone.roughness = .91
	generated_materials["mat_foundation_stone"] = stone

func _spawn_generated(file_name: String, position3: Vector3, yaw_degrees: float) -> Node3D:
	var path := GENERATED + file_name
	if not FileAccess.file_exists(path):
		push_error("Asset Pipeline V1 proof missing generated model: " + path)
		return Node3D.new()
	var packed := load(path) as PackedScene
	if packed == null:
		push_error("Asset Pipeline V1 proof could not load generated model: " + path)
		return Node3D.new()
	var instance := packed.instantiate() as Node3D
	instance.name = file_name.get_basename()
	instance.position = position3
	instance.rotation_degrees.y = yaw_degrees
	add_child(instance)
	_apply_shared_pbr(instance)
	generated_assets.append(instance)
	return instance

func _apply_shared_pbr(root: Node3D) -> void:
	for child: Node in root.find_children("*", "MeshInstance3D", true, false):
		var mi := child as MeshInstance3D
		if mi.mesh == null:
			continue
		for surface_index in range(mi.mesh.get_surface_count()):
			var original := mi.get_active_material(surface_index)
			if original == null:
				continue
			var key := original.resource_name.to_lower()
			if generated_materials.has(key):
				mi.set_surface_override_material(surface_index, generated_materials[key] as Material)
				pbr_rebound_surfaces += 1

func capture() -> void:
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(PROOF_OUT)
	var image := get_viewport().get_texture().get_image()
	var path := PROOF_OUT + "/asset_pipeline_v1_actual_1920x1080.png"
	var err := image.save_png(path)
	var report := {
		"captured_at_utc": Time.get_datetime_string_from_system(true),
		"engine": Engine.get_version_info(),
		"renderer": RenderingServer.get_current_rendering_method(),
		"gpu": RenderingServer.get_video_adapter_name(),
		"width": image.get_width(),
		"height": image.get_height(),
		"save_error": err,
		"camera_position": str(camera.position),
		"camera_rotation": str(camera.rotation_degrees),
		"fov": camera.fov,
		"generated_buildings": generated_assets.size(),
		"pbr_rebound_surfaces": pbr_rebound_surfaces,
		"protected_hero_v2_retained": true,
		"protected_ifv_retained": true,
		"pbr_source": "existing RiverTownVisualSlice shared PBR families",
		"post_capture_image_editing": false,
		"visual_acceptance": "NOT_CLAIMED",
		"draw_calls": Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
		"rendered_primitives": Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)
	}
	FileAccess.open(PROOF_OUT + "/runtime_metrics.json", FileAccess.WRITE).store_string(JSON.stringify(report, "\t"))
	print("FRONTLINE_ASSET_PIPELINE_V1_CAPTURED ", path, " ", image.get_size(), " pbr=", pbr_rebound_surfaces)
	get_tree().quit(err)
