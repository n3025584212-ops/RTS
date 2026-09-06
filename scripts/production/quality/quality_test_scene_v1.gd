class_name QualityTestSceneV1
extends Node3D

@onready var world: QualityTestWorldV1 = $World
@onready var vfx: QualityTestVFXV1 = $VFX

const OUTPUT_DIR := "res://artifacts/quality_test_scene"
const SCREENSHOT_PATH := OUTPUT_DIR + "/quality_test_scene_v1_actual_1920x1080.png"
const METRICS_PATH := OUTPUT_DIR + "/quality_test_scene_v1_metrics.json"

var _frame_times_ms: Array[float] = []

func _ready() -> void:
	_ensure_output()
	world.build()
	vfx.build()
	print("FRONTLINE_QUALITY_TEST_SCENE_READY resolution_target=1920x1080 renderer=%s" %
		RenderingServer.get_current_rendering_method())
	if OS.get_environment("FRONTLINE_CAPTURE_QUALITY_SLICE") == "1":
		_capture()


func _process(delta: float) -> void:
	if delta > 0.0 and _frame_times_ms.size() < 240:
		_frame_times_ms.append(delta * 1000.0)


func _capture() -> void:
	for _i: int in range(18):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	if image == null or image.is_empty():
		push_error("QUALITY_TEST_EMPTY_CAPTURE")
		get_tree().quit(51)
		return
	var result := image.save_png(ProjectSettings.globalize_path(SCREENSHOT_PATH))
	if result != OK:
		push_error("QUALITY_TEST_CAPTURE_SAVE_FAIL")
		get_tree().quit(52)
		return
	var checks := {
		"resolution": image.get_size() == Vector2i(1920,1080),
		"real_buildings": world.building_count >= 3,
		"real_vehicles": world.vehicle_count >= 3,
		"real_trees": world.tree_count >= 5,
		"particle_smoke": vfx.smoke_emitters >= 1,
		"particle_fire": vfx.fire_emitters >= 1,
		"particle_sparks": vfx.spark_emitters >= 1,
	}
	var all_pass := true
	for value: Variant in checks.values():
		if not bool(value):
			all_pass = false
	var payload := {
		"task_id": "BUILD_QUALITY_TEST_SCENE_V1",
		"engine": Engine.get_version_info().get("string","Godot"),
		"renderer": RenderingServer.get_current_rendering_method(),
		"capture_width": image.get_width(),
		"capture_height": image.get_height(),
		"buildings": world.building_count,
		"vehicles": world.vehicle_count,
		"trees": world.tree_count,
		"smoke_emitters": vfx.smoke_emitters,
		"fire_emitters": vfx.fire_emitters,
		"spark_emitters": vfx.spark_emitters,
		"checks": checks,
		"visual_pass": false,
	}
	var file := FileAccess.open(METRICS_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(payload, "\t") + "\n")
		file.close()
	print("FRONTLINE_QUALITY_SCREENSHOT_CAPTURED path=%s size=%dx%d" %
		[SCREENSHOT_PATH,image.get_width(),image.get_height()])
	print("FRONTLINE_QUALITY_TECH_GATE_%s" % ("PASS" if all_pass else "FAIL"))
	get_tree().quit(0 if all_pass else 53)


func _ensure_output() -> void:
	var err := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	if err != OK and err != ERR_ALREADY_EXISTS:
		push_error("QUALITY_TEST_OUTPUT_DIR_FAIL")
