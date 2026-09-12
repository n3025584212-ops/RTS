extends "res://scripts/production/river_town_workshop_validation.gd"
## Reuses one fully constructed Hero V2 world; every image is a real viewport.
func _ready() -> void:
	super._ready()
	capture_pending = false
	call_deferred("capture_batch")

func capture_batch() -> void:
	var views: Array = [["workshop",2,"workshop_lod2"]]
	if "--all-views" in OS.get_cmdline_user_args():
		views = [["workshop",0,"workshop_front"],["rear",0,"workshop_rear"],["overview",-1,"workshop_overview"],["detail",0,"workshop_detail"],["workshop",1,"workshop_lod1"],["workshop",2,"workshop_lod2"],["reference",-1,"workshop_reference"]]
	for spec in views:
		print("WORKSHOP_BATCH_BEGIN ",spec[2])
		asset_view = spec[0]
		workshop.set_lod_override(spec[1])
		set_asset_camera()
		times.clear()
		wall_frame_times.clear()
		for frame in range(32):
			await get_tree().process_frame
			if frame % 8 == 7: print("WORKSHOP_BATCH_SETTLE ",spec[2]," ",frame+1)
		await RenderingServer.frame_post_draw
		var screenshot := get_viewport().get_texture().get_image()
		var folder: String = OUT+"/"+spec[2]
		DirAccess.make_dir_recursive_absolute(folder)
		var error := screenshot.save_png(folder+"/river_town_actual_1920x1080.png")
		var mean := 0.0
		for ms in wall_frame_times: mean += ms/maxi(1,wall_frame_times.size())
		var report := {"engine":Engine.get_version_info(),"renderer":RenderingServer.get_current_rendering_method(),"gpu":RenderingServer.get_video_adapter_name(),"width":screenshot.get_width(),"height":screenshot.get_height(),"save_error":error,"captured_at_utc":Time.get_datetime_string_from_system(true),"camera_position":str(camera.position),"camera_rotation":str(camera.rotation_degrees),"fov":camera.fov,"asset_view":asset_view,"forced_lod":spec[1],"settling_frames":32,"internal_3d_render_scale":get_viewport().scaling_3d_scale,"grass_instances":grass_instance_count,"wall_clock_frame_ms_mean":mean,"draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),"rendered_primitives":Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME),"screenshot_source":"Viewport.get_texture().get_image() after frame_post_draw","post_capture_image_editing":false,"gameplay_changes":false}
		report["asset_glb_sha256"] = {}
		for level in range(3):
			report["asset_glb_sha256"]["lod%d" % level] = FileAccess.get_sha256("res://assets/visual_slice/industrial_workshop/repair_workshop_lod%d.glb" % level)
		FileAccess.open(folder+"/runtime_metrics.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
		print("WORKSHOP_BATCH_CAPTURE ",spec[2]," error=",error)
		if error != OK:
			get_tree().quit(error)
			return
	get_tree().quit()
