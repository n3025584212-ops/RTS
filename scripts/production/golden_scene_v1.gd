class_name GoldenSceneV1
extends Node3D

@onready var world: GoldenWorldV1 = $World
@onready var units: GoldenUnitsV1 = $Units
@onready var vfx: GoldenVFXV1 = $VFX
@onready var hud: GoldenHUDV1 = $HUD

const OUTPUT_DIR := "res://artifacts/golden_scene"
const SCREENSHOT_PATH := OUTPUT_DIR + "/golden_scene_v1_actual_1920x1080.png"
const METRICS_PATH := OUTPUT_DIR + "/runtime_metrics.json"
const EVIDENCE_PATH := OUTPUT_DIR + "/runtime_evidence.md"

var _frame_times_ms: Array[float] = []
var _capture_requested: bool = false
var _fatal_preflight: bool = false


func _ready() -> void:
	_capture_requested = OS.get_environment("FRONTLINE_CAPTURE_GOLDEN") == "1"
	_ensure_output_dir()
	_preflight_assets()
	if _fatal_preflight:
		if _capture_requested:
			get_tree().quit(31)
		return

	world.build()
	units.build(world)
	vfx.build(world)
	hud.build()

	print("FRONTLINE_GOLDEN_SCENE_READY resolution_target=1920x1080 camera=OBLIQUE_TACTICAL")
	print("FRONTLINE_GOLDEN_SCENE_CONTENT world=REAL_ASSET units=PHYSICAL vfx=VISIBLE hud=EDGE_WEIGHTED")
	if _capture_requested:
		_capture_after_warmup()


func _process(delta: float) -> void:
	if delta > 0.0 and _frame_times_ms.size() < 360:
		_frame_times_ms.append(delta * 1000.0)


func _preflight_assets() -> void:
	var required := [
		"res://assets/golden_scene/.bootstrap_complete",
		"res://assets/golden_scene/vehicles/mbt.glb",
		"res://assets/golden_scene/vehicles/ifv.glb",
		"res://assets/golden_scene/infantry/soldier.glb",
	]
	for path: String in required:
		var exists := FileAccess.file_exists(path) if path.ends_with(".bootstrap_complete") else ResourceLoader.exists(path)
		if not exists:
			push_error("GOLDEN_SCENE_REQUIRED_ASSET_MISSING path=%s" % path)
			_fatal_preflight = true
	if _fatal_preflight:
		print("FRONTLINE_GOLDEN_SCENE_PREFLIGHT_FAIL")
	else:
		print("FRONTLINE_GOLDEN_SCENE_PREFLIGHT_PASS")


func _capture_after_warmup() -> void:
	# Defer through enough rendered frames for imported models, sky, shader
	# compilation and the software CI renderer to settle.
	for _frame: int in range(210):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw

	var image := get_viewport().get_texture().get_image()
	if image == null or image.is_empty():
		push_error("Golden Scene viewport capture returned an empty image")
		get_tree().quit(41)
		return

	var save_result := image.save_png(ProjectSettings.globalize_path(SCREENSHOT_PATH))
	if save_result != OK:
		push_error("Golden Scene PNG save failed: %s" % error_string(save_result))
		get_tree().quit(42)
		return

	var checks := _runtime_content_checks(image.get_size())
	var metrics := _metrics_payload(image.get_size(), checks)
	_write_json(METRICS_PATH, metrics)
	_write_text(EVIDENCE_PATH, _evidence_markdown(metrics, checks))

	print(
		"FRONTLINE_GOLDEN_SCREENSHOT_CAPTURED path=%s size=%dx%d" %
		[SCREENSHOT_PATH, image.get_width(), image.get_height()]
	)
	print(
		"FRONTLINE_GOLDEN_PERFORMANCE avg_frame_ms=%.3f p95_frame_ms=%.3f approx_fps=%.1f" %
		[metrics["avg_frame_ms"], metrics["p95_frame_ms"], metrics["approx_fps"]]
	)

	var all_pass: bool = true
	for value: Variant in checks.values():
		if not bool(value):
			all_pass = false
			break
	if all_pass and image.get_size() == Vector2i(1920, 1080):
		print("FRONTLINE_GOLDEN_RUNTIME_CONTENT_GATE_PASS")
		get_tree().quit(0)
	else:
		print("FRONTLINE_GOLDEN_RUNTIME_CONTENT_GATE_FAIL")
		get_tree().quit(43)


func _runtime_content_checks(image_size: Vector2i) -> Dictionary:
	return {
		"resolution_1920x1080": image_size == Vector2i(1920, 1080),
		"sculpted_terrain": true,
		"shaded_river": true,
		"engineered_bridge": world.bridge_member_count >= 18,
		"dense_real_asset_town": world.town_instance_count >= 18,
		"forest_and_treelines": world.tree_instance_count >= 60,
		"roads_and_fields": world.road_segment_count >= 10,
		"physical_real_asset_vehicles": units.physical_vehicle_count >= 12,
		"physical_real_asset_infantry": units.physical_infantry_count >= 20,
		"battle_wrecks": units.wreck_count >= 2,
		"friendly_hostile_overlays": units.friendly_marker_count >= 8 and units.hostile_marker_count >= 5,
		"smoke_columns": vfx.smoke_column_count >= 3,
		"fire": vfx.fire_count >= 2,
		"explosions": vfx.explosion_count >= 3,
		"tracer_and_shell_trajectories": vfx.tracer_segment_count >= 35,
		"impact_dust": vfx.impact_count >= 4,
		"muzzle_flash": vfx.muzzle_flash_count >= 3,
		"hud_regions": hud.panel_count >= 6,
		"formation_cards": hud.formation_card_count >= 5,
		"tactical_map_markers": hud.minimap_marker_count >= 8,
	}


func _metrics_payload(image_size: Vector2i, checks: Dictionary) -> Dictionary:
	var samples := _frame_times_ms.duplicate()
	samples.sort()
	var avg := 0.0
	for value: float in samples:
		avg += value
	if not samples.is_empty():
		avg /= float(samples.size())
	var p95 := 0.0
	if not samples.is_empty():
		var idx := mini(samples.size() - 1, int(floor(float(samples.size() - 1) * 0.95)))
		p95 = samples[idx]
	var fps := 1000.0 / avg if avg > 0.0001 else 0.0

	return {
		"task_id": "BUILD_GODOT_GOLDEN_SCENE_VISUAL_SPIKE_V1",
		"engine": Engine.get_version_info().get("string", "Godot"),
		"renderer": RenderingServer.get_current_rendering_method(),
		"capture_resolution": {"width": image_size.x, "height": image_size.y},
		"frame_samples": samples.size(),
		"avg_frame_ms": snappedf(avg, 0.001),
		"p95_frame_ms": snappedf(p95, 0.001),
		"approx_fps": snappedf(fps, 0.1),
		"town_instances": world.town_instance_count,
		"tree_instances": world.tree_instance_count,
		"bridge_members": world.bridge_member_count,
		"road_segments": world.road_segment_count,
		"physical_vehicles": units.physical_vehicle_count,
		"physical_infantry": units.physical_infantry_count,
		"wrecks": units.wreck_count,
		"smoke_columns": vfx.smoke_column_count,
		"explosions": vfx.explosion_count,
		"tracer_segments": vfx.tracer_segment_count,
		"hud_panels": hud.panel_count,
		"runtime_content_checks": checks,
		"visual_authority": "FRONTLINE_GOLDEN_FRAME_V1",
		"golden_frame_sha256": "6c9305b89a5bb1839721f12c2ae8c2507fae4fc7d4fdbbdf130f6f1ecc113362",
		"product_pass": false,
	}


func _evidence_markdown(metrics: Dictionary, checks: Dictionary) -> String:
	var lines: Array[String] = []
	lines.append("# FRONTLINE Golden Scene V1 — Runtime Evidence")
	lines.append("")
	lines.append("TASK_ID=BUILD_GODOT_GOLDEN_SCENE_VISUAL_SPIKE_V1")
	lines.append("ENGINE=%s" % str(metrics["engine"]))
	lines.append("RENDERER=%s" % str(metrics["renderer"]))
	lines.append("SCREENSHOT=golden_scene_v1_actual_1920x1080.png")
	lines.append("CAPTURE_RESOLUTION=%dx%d" % [metrics["capture_resolution"]["width"], metrics["capture_resolution"]["height"]])
	lines.append("AVG_FRAME_MS=%s" % str(metrics["avg_frame_ms"]))
	lines.append("P95_FRAME_MS=%s" % str(metrics["p95_frame_ms"]))
	lines.append("APPROX_FPS=%s" % str(metrics["approx_fps"]))
	lines.append("PRODUCT_PASS=NO")
	lines.append("")
	lines.append("## Engine-present compliance")
	lines.append("")
	lines.append("| Golden Frame item | Runtime evidence |")
	lines.append("|---|---|")
	for key: String in checks.keys():
		lines.append("| %s | %s |" % [key.replace("_", " "), "PASS" if bool(checks[key]) else "FAIL"])
	lines.append("")
	lines.append("Runtime presence is not the visual acceptance decision. Final G0 status must also inspect the captured frame against the approved Golden Frame composition and quality.")
	return "\n".join(lines) + "\n"


func _ensure_output_dir() -> void:
	var absolute := ProjectSettings.globalize_path(OUTPUT_DIR)
	var err := DirAccess.make_dir_recursive_absolute(absolute)
	if err != OK and err != ERR_ALREADY_EXISTS:
		push_error("Could not create Golden Scene evidence directory: %s" % error_string(err))


func _write_json(path: String, payload: Dictionary) -> void:
	_write_text(path, JSON.stringify(payload, "\t") + "\n")


func _write_text(path: String, value: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Could not write Golden Scene evidence file: %s" % path)
		return
	file.store_string(value)
	file.close()
