extends Node2D

const OUT := "res://artifacts/battle01_visual"
const BATTLE_SCENE := preload("res://scenes/battle01/Battle01.tscn")

var battle: Node
var frames := 0
var capture_requested := false

func _ready() -> void:
	get_window().size = Vector2i(1920,1080)
	get_window().content_scale_size = Vector2i(1920,1080)
	get_viewport().msaa_3d = Viewport.MSAA_4X
	get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
	get_viewport().scaling_3d_scale = 1.5
	battle = BATTLE_SCENE.instantiate()
	add_child(battle)
	capture_requested = "--capture" in OS.get_cmdline_user_args()
	print("FRONTLINE_BATTLE01_VISUAL_PROOF_READY gameplay_scene=Battle01")
	set_process(true)

func _process(_delta: float) -> void:
	frames += 1
	if capture_requested and frames == 2:
		capture_requested = false
		_capture()

func _capture() -> void:
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var image := get_viewport().get_texture().get_image()
	var path := OUT + "/battle01_actual_gameplay_1920x1080.png"
	var error := image.save_png(ProjectSettings.globalize_path(path))
	var payload := {
		"engine": Engine.get_version_info(),
		"renderer": RenderingServer.get_current_rendering_method(),
		"gpu": RenderingServer.get_video_adapter_name(),
		"width": image.get_width(),
		"height": image.get_height(),
		"internal_3d_render_scale": get_viewport().scaling_3d_scale,
		"source_scene": "res://scenes/battle01/Battle01.tscn",
		"gameplay_scene_instantiated": battle != null,
		"post_capture_image_editing": false,
		"save_error": error
	}
	FileAccess.open(OUT + "/runtime_metrics.json", FileAccess.WRITE).store_string(JSON.stringify(payload, "\t"))
	print("FRONTLINE_BATTLE01_GAMEPLAY_CAPTURED ",path," ",image.get_size())
	get_tree().quit(error)
