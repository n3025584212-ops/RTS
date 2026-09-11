extends "res://scripts/production/river_town_visual_slice.gd"
## Asset Pipeline V2 proof.
## Hard rule: preserve the accepted Run #5 local baseline exactly, including the
## original assets/visual_slice/abrams.glb armor path. No IFV or replacement tank
## is injected by this proof scene.

const PROOF_OUT := "res://artifacts/asset_pipeline_v2"
const GENERATED_HOUSE := "res://assets/generated/asset_pipeline_v1/rural_house/rural_house_a_intact_lod0.glb"
const PROCESSED_URBAN_RUIN := "res://assets/generated/asset_pipeline_v2/source_derivatives/urban_ruin_processed.glb"
const PROCESSED_CHURCH := "res://assets/generated/asset_pipeline_v2/source_derivatives/church_landmark_processed.glb"

var proof_assets: Array[Node3D] = []
var generated_materials: Dictionary = {}
var pbr_rebound_surfaces := 0

func _ready() -> void:
	# This calls the accepted Run #5 baseline implementation. Its create_armor()
	# uses assets/visual_slice/abrams.glb and visual_slice_armor.gdshader.
	super._ready()
	_build_material_bridge()

	# Deliberately three different model classes, not A/B copies of one generator:
	# 1) one procedural rural-house prototype,
	# 2) a processed modular urban ruin source,
	# 3) a processed church/landmark source.
	_spawn_proof_asset(GENERATED_HOUSE, "GeneratedRuralHouse", Vector3(18.0, 0.0, -8.0), -18.0, 1.0, true)
	_spawn_proof_asset(PROCESSED_URBAN_RUIN, "ProcessedUrbanRuin", Vector3(29.0, 0.0, -31.0), 19.0, 0.72, false)
	_spawn_proof_asset(PROCESSED_CHURCH, "ProcessedChurchLandmark", Vector3(-31.0, 0.0, -36.0), -11.0, 0.88, false)

	for item: Node3D in proof_assets:
		item.position.y = height_at(item.position.x, item.position.z)

	# Wider review framing, but no vehicle model/material is changed here.
	camera.position = Vector3(31.0, 15.5, 34.0)
	camera.look_at(Vector3(0.0, 2.4, -12.0))
	camera.fov = 49.0
	camera.near = 0.2
	camera.far = 1200.0
	camera.current = true

	print("FRONTLINE_ASSET_PIPELINE_V2_PROOF_READY model_classes=3",
		" pbr_rebound_surfaces=", pbr_rebound_surfaces,
		" accepted_run5_abrams=assets/visual_slice/abrams.glb",
		" extra_vehicle_assets_added=NO renderer=", RenderingServer.get_current_rendering_method())

func _build_material_bridge() -> void:
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

func _spawn_proof_asset(path: String, label: String, position3: Vector3, yaw_degrees: float, scale3: float, bridge_materials: bool) -> Node3D:
	if not FileAccess.file_exists(path):
		push_error("Asset Pipeline V2 proof missing model: " + path)
		return Node3D.new()
	var packed := load(path) as PackedScene
	if packed == null:
		push_error("Asset Pipeline V2 proof could not load model: " + path)
		return Node3D.new()
	var instance := packed.instantiate() as Node3D
	instance.name = label
	instance.position = position3
	instance.rotation_degrees.y = yaw_degrees
	instance.scale = Vector3.ONE * scale3
	add_child(instance)
	if bridge_materials:
		_apply_shared_pbr(instance)
	proof_assets.append(instance)
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
	var path := PROOF_OUT + "/asset_pipeline_v2_actual_1920x1080.png"
	var err := image.save_png(path)
	var report := {
		"captured_at_utc": Time.get_datetime_string_from_system(true),
		"engine": Engine.get_version_info(),
		"renderer": RenderingServer.get_current_rendering_method(),
		"gpu": RenderingServer.get_video_adapter_name(),
		"width": image.get_width(),
		"height": image.get_height(),
		"save_error": err,
		"proof_model_classes": 3,
		"proof_models": ["generated_rural_house", "processed_urban_ruin", "processed_church_landmark"],
		"pbr_rebound_surfaces": pbr_rebound_surfaces,
		"accepted_run5_abrams_path": "res://assets/visual_slice/abrams.glb",
		"extra_vehicle_assets_added": false,
		"accepted_high_fidelity_assets_deleted_or_replaced": false,
		"post_capture_image_editing": false,
		"visual_acceptance": "NOT_CLAIMED",
		"draw_calls": Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
		"rendered_primitives": Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)
	}
	FileAccess.open(PROOF_OUT + "/runtime_metrics.json", FileAccess.WRITE).store_string(JSON.stringify(report, "\t"))
	print("FRONTLINE_ASSET_PIPELINE_V2_CAPTURED ", path, " ", image.get_size())
	get_tree().quit(err)
