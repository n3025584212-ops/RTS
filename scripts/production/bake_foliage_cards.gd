extends SceneTree
## Conventional distant vegetation impostors, baked from licensed mesh assets in Godot.
var viewport: SubViewport
func _initialize() -> void:
	call_deferred("bake")
func bake() -> void:
	viewport=SubViewport.new();viewport.size=Vector2i(512,512);viewport.transparent_bg=true
	viewport.own_world_3d=true;viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	viewport.msaa_3d=Viewport.MSAA_4X
	root.add_child(viewport)
	var env:=WorldEnvironment.new();env.environment=Environment.new()
	env.environment.background_mode=Environment.BG_CLEAR_COLOR
	env.environment.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color=Color(.71,.77,.86);env.environment.ambient_light_energy=.75
	env.environment.tonemap_mode=Environment.TONE_MAPPER_LINEAR
	viewport.add_child(env)
	var light:=DirectionalLight3D.new();light.rotation_degrees=Vector3(-28,118,0)
	light.light_energy=.85;light.light_color=Color(1,.90,.72);viewport.add_child(light)
	var camera:=Camera3D.new();camera.projection=Camera3D.PROJECTION_ORTHOGONAL;viewport.add_child(camera);camera.current=true
	var records:=[]
	DirAccess.make_dir_recursive_absolute("res://assets/visual_slice/impostors")
	for name in ["fir_sapling_medium_0","fir_sapling_medium_1","fir_sapling_medium_2","island_tree_01_0"]:
		var tree:Node3D=load("res://assets/visual_slice/"+name+".glb").instantiate();viewport.add_child(tree)
		var bounds:=AABB();var first:=true
		for node:Node in tree.find_children("*","MeshInstance3D",true,false):
			var mi:=node as MeshInstance3D
			var box:=mi.global_transform*mi.get_aabb()
			bounds=box if first else bounds.merge(box);first=false
			for i in range(mi.mesh.get_surface_count()):
				var mat:=mi.get_active_material(i) as StandardMaterial3D
				if mat!=null and mat.transparency!=BaseMaterial3D.TRANSPARENCY_DISABLED:
					mat=mat.duplicate();mat.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR;mat.alpha_scissor_threshold=.22
					mi.set_surface_override_material(i,mat)
		var size:=maxf(bounds.size.x,bounds.size.y)*1.12
		camera.size=size
		camera.position=bounds.get_center()+Vector3(0,1.2,25)
		camera.look_at(bounds.get_center())
		for angle in [0,90]:
			tree.rotation_degrees.y=angle
			for f in range(5):await process_frame
			await RenderingServer.frame_post_draw
			var path:String="res://assets/visual_slice/impostors/"+name+"_"+str(angle)+".png"
			var result:=viewport.get_texture().get_image().save_png(path)
			records.append({"file":path,"size":size,"center_y":bounds.get_center().y,"source":name+".glb","engine":Engine.get_version_info(),"error":result})
			print("BAKED_FOLIAGE ",path)
		tree.queue_free();await process_frame
	FileAccess.open("res://assets/visual_slice/impostors/manifest.json",FileAccess.WRITE).store_string(JSON.stringify(records,"\t"))
	quit()
