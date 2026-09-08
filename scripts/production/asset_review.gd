extends SceneTree

var stage: Node3D
var cam: Camera3D

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	root.size = Vector2i(1920,1080)
	root.content_scale_size = Vector2i(1920,1080)
	root.msaa_3d = Viewport.MSAA_4X
	stage = Node3D.new()
	root.add_child(stage)
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.21,0.25,0.29)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.65,0.76,0.88)
	env.ambient_light_energy = 0.6
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.ssao_enabled = true
	var world := WorldEnvironment.new()
	world.environment = env
	stage.add_child(world)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-48,-35,0)
	light.light_energy = 1.5
	light.shadow_enabled = true
	stage.add_child(light)
	cam = Camera3D.new()
	stage.add_child(cam)
	cam.position = Vector3(13,10,16)
	cam.look_at(Vector3(0,2,0))
	cam.fov = 43
	cam.current = true
	var floor_node := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(200,200)
	floor_node.mesh = plane
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.24,0.25,0.24)
	mat.roughness = 0.9
	floor_node.material_override = mat
	stage.add_child(floor_node)
	var assets := ["city_v20/family_house_01.glb","city_hq/03_shop_front8.glb","vehicles/mbt_abrams.glb","nature_real/pine_sapling_small_lod.glb"]
	DirAccess.make_dir_recursive_absolute("res://artifacts/visual_reset")
	for asset: String in assets:
		var model: Node3D = load("res://assets/golden_scene/"+asset).instantiate()
		stage.add_child(model)
		var bounds := get_bounds(model)
		var factor := 10.0 / maxf(bounds.size.x,bounds.size.z)
		model.scale *= factor
		model.position = Vector3(-bounds.get_center().x,-bounds.position.y,-bounds.get_center().z)*factor
		print("ASSET_REVIEW ",asset," bounds=",bounds," normalized=",factor)
		for i in range(10):
			await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://artifacts/visual_reset/"+asset.get_file().get_basename()+"_raw.png")
		model.queue_free()
		await process_frame
	quit()

func get_bounds(node: Node3D) -> AABB:
	var result := AABB()
	var valid := false
	for child: Node in node.find_children("*","MeshInstance3D",true,false):
		var mesh := child as MeshInstance3D
		if mesh.mesh == null: continue
		var box: AABB = mesh.global_transform * mesh.get_aabb()
		if not valid: result = box; valid = true
		else: result = result.merge(box)
	return result
