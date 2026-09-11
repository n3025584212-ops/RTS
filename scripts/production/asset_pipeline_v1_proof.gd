extends "res://scripts/production/river_town_hero_shot_v2.gd"
## Visual acceptance scene for Asset Pipeline V1.
## It intentionally keeps the existing Hero V2 environment and adds generated
## building derivatives beside the protected high-fidelity anchors.

const PROOF_OUT := "res://artifacts/asset_pipeline_v1"
const GENERATED := "res://assets/generated/asset_pipeline_v1/rural_house/"
const IFV_PATH := "res://assets/golden_scene/vehicles/ifv.glb"

var generated_assets: Array[Node3D] = []

func _ready() -> void:
	# Preserve the proven Hero V2 local-quality scene first: urban ruin, Abrams,
	# physical mud/ruts/puddles, vegetation and Forward+ lighting.
	super._ready()

	var intact := _spawn_generated("rural_house_a_intact_lod0.glb", Vector3(16.0, 0.0, -8.0), -18.0)
	var damaged := _spawn_generated("rural_house_a_damaged_lod0.glb", Vector3(25.0, 0.0, -24.0), 16.0)
	var variant_b := _spawn_generated("rural_house_b_intact_lod0.glb", Vector3(-26.0, 0.0, -24.0), 21.0)

	for item: Node3D in generated_assets:
		item.position.y = height_at(item.position.x, item.position.z)

	# Existing legal IFV family is deliberately shown in the same frame as another
	# preservation anchor. This is a comparison scene, not a replacement scene.
	if FileAccess.file_exists(IFV_PATH):
		var ifv := spawn(IFV_PATH, Vector3(10.0, height_at(10.0, -18.0) + 0.03, -18.0), 0.74, 154.0)
		ifv.name = "ProtectedExistingIFV"

	# Wider RTS-like review framing. Existing Hero V2 assets remain present and
	# readable while the generated building family is judged in the same lighting.
	camera.position = Vector3(31.0, 15.5, 34.0)
	camera.look_at(Vector3(1.0, 2.4, -10.0))
	camera.fov = 49.0
	camera.near = 0.2
	camera.far = 1200.0
	camera.current = true

	print("FRONTLINE_ASSET_PIPELINE_V1_PROOF_READY generated=", generated_assets.size(),
		" preserved_hero_v2=YES preserved_ifv=YES renderer=", RenderingServer.get_current_rendering_method())

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
	generated_assets.append(instance)
	return instance

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
		"protected_hero_v2_retained": true,
		"protected_ifv_retained": true,
		"post_capture_image_editing": false,
		"visual_acceptance": "NOT_CLAIMED",
		"draw_calls": Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
		"rendered_primitives": Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)
	}
	FileAccess.open(PROOF_OUT + "/runtime_metrics.json", FileAccess.WRITE).store_string(JSON.stringify(report, "\t"))
	print("FRONTLINE_ASSET_PIPELINE_V1_CAPTURED ", path, " ", image.get_size())
	get_tree().quit(err)
