extends "res://scripts/production/river_town_visual_slice.gd"
## Full battlefield visual-production scene.
## Reuses the proven River Town rendering/material methods while rebuilding composition at battle scale.
## No gameplay state is instantiated or modified.

const FULL_OUT := "res://artifacts/full_battlefield_v1"
const CITY := "res://assets/golden_scene/city_hq/"
const CITY_REAL := "res://assets/golden_scene/city_real/"
const VEHICLES := "res://assets/golden_scene/vehicles/"
const INFANTRY := "res://assets/golden_scene/infantry/"

var battlefield_unit_count := 0
var battlefield_building_count := 0
var battlefield_tree_count := 0
var smoke_column_count := 0

func _ready() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-frame="):
			capture_frame = maxi(1, int(argument.get_slice("=", 1)))
		if argument.begins_with("--capture-label="):
			capture_label = argument.get_slice("=", 1).validate_filename()
	rng.seed = 20260910
	noise.seed = 1203
	noise.frequency = 0.12
	noise.fractal_octaves = 4
	mud_height = (load(ASSET+"surfaces/aerial_mud_1_disp.png") as Texture2D).get_image()
	if mud_height.is_compressed():
		mud_height.decompress()
	mud_height.resize(512,512,Image.INTERPOLATE_BILINEAR)
	COVER_FIELD.build()
	get_window().size = Vector2i(1920,1080)
	get_window().content_scale_size = Vector2i(1920,1080)
	get_viewport().msaa_3d = Viewport.MSAA_4X
	get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
	get_viewport().scaling_3d_scale = 1.25

	create_lighting()
	create_materials()
	create_battlefield_materials()
	prepare_puddle_sites()

	# Global terrain first; a denser near patch preserves the local-fidelity foreground method.
	create_terrain(-430.0,430.0,-720.0,180.0,3.0,false)
	create_terrain(-46.0,46.0,-48.0,52.0,0.35,true)

	create_field_system()
	create_global_river_and_bridge()
	create_urban_battle_zone()
	create_armor_push()
	create_infantry_columns()
	create_tree_belts()
	create_industrial_horizon()
	create_war_atmosphere()
	create_distant_forest()

	var reflection := ReflectionProbe.new()
	reflection.name = "BattlefieldReflection"
	reflection.position = Vector3(20,18,-120)
	reflection.size = Vector3(520,120,560)
	reflection.max_distance = 720
	reflection.box_projection = true
	reflection.cull_mask = 1
	reflection.intensity = 0.82
	add_child(reflection)

	# High oblique RTS war-photography framing: foreground force, river/bridge, city and horizon in one view.
	camera.position = Vector3(245.0,138.0,315.0)
	camera.look_at(Vector3(15.0,3.0,-175.0))
	camera.fov = 47.0
	camera.near = 0.5
	camera.far = 1900.0
	camera.current = true

	print("FRONTLINE_FULL_BATTLEFIELD_READY renderer=",RenderingServer.get_current_rendering_method(),
		" adapter=",RenderingServer.get_video_adapter_name(),
		" units=",battlefield_unit_count,
		" buildings=",battlefield_building_count,
		" trees=",battlefield_tree_count,
		" smoke=",smoke_column_count)
	set_process(true)
	capture_pending = "--capture" in OS.get_cmdline_user_args()

func create_battlefield_materials() -> void:
	mats["field_dry"] = surface("dirt_aerial_03",Color(0.72,0.68,0.55),0.42)
	mats["field_green"] = surface("leafy_grass",Color(0.55,0.62,0.42),0.48)
	mats["field_mud"] = surface("aerial_mud_1",Color(0.68,0.60,0.49),0.46)
	mats["asphalt"] = surface("asphalt_02",Color(0.52,0.50,0.46),0.60)
	mats["industrial"] = surface("t_concrete_wall_002",Color(0.58,0.57,0.53),0.70)

func create_surface_patch(rect: Rect2, material: Material, step: float, patch_name: String) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var nx := maxi(1,int(ceil(rect.size.x/step)))
	var nz := maxi(1,int(ceil(rect.size.y/step)))
	for iz in range(nz):
		var z0 := rect.position.y + rect.size.y*float(iz)/float(nz)
		var z1 := rect.position.y + rect.size.y*float(iz+1)/float(nz)
		for ix in range(nx):
			var x0 := rect.position.x + rect.size.x*float(ix)/float(nx)
			var x1 := rect.position.x + rect.size.x*float(ix+1)/float(nx)
			var a := Vector3(x0,height_at(x0,z0)+.035,z0)
			var b := Vector3(x1,height_at(x1,z0)+.035,z0)
			var c := Vector3(x1,height_at(x1,z1)+.035,z1)
			var d := Vector3(x0,height_at(x0,z1)+.035,z1)
			for p in [a,b,c,a,c,d]:
				st.set_uv(Vector2(p.x,p.z)*.055)
				st.add_vertex(p)
	st.generate_normals()
	st.generate_tangents()
	var mi := MeshInstance3D.new()
	mi.name = patch_name
	mi.mesh = st.commit()
	mi.material_override = material
	mi.gi_mode = GeometryInstance3D.GI_MODE_STATIC
	add_child(mi)

func road_polyline(points: Array[Vector3], width: float) -> void:
	for i in range(points.size()-1):
		var a := points[i]
		var b := points[i+1]
		var mid := (a+b)*.5
		var direction := b-a
		var length := Vector2(direction.x,direction.z).length()
		mid.y = height_at(mid.x,mid.z)+.08
		var road := block(mid,Vector3(width,.12,length),"asphalt")
		road.rotation.y = atan2(direction.x,direction.z)

func create_field_system() -> void:
	# Large irregular agricultural masses replace the old three-lane/board composition.
	var patches := [
		[Rect2(-255,10,92,105),"field_dry"],
		[Rect2(-155,25,82,92),"field_green"],
		[Rect2(-65,35,76,88),"field_mud"],
		[Rect2(55,22,84,98),"field_dry"],
		[Rect2(150,-5,94,100),"field_green"],
		[Rect2(-285,-70,96,62),"field_green"],
		[Rect2(-170,-75,84,58),"field_dry"],
		[Rect2(120,-72,88,58),"field_mud"]
	]
	var n := 0
	for item in patches:
		create_surface_patch(item[0],mats[item[1]],4.0,"AgriculturalPatch_%02d" % n)
		n += 1
	road_polyline([
		Vector3(-235,0,125),Vector3(-170,0,90),Vector3(-95,0,58),Vector3(-20,0,30),
		Vector3(28,0,-18),Vector3(35,0,-58)
	],7.0)
	road_polyline([
		Vector3(220,0,82),Vector3(150,0,48),Vector3(90,0,15),Vector3(50,0,-28),
		Vector3(35,0,-58)
	],6.0)
	road_polyline([
		Vector3(35,0,-142),Vector3(70,0,-165),Vector3(116,0,-188),Vector3(165,0,-210)
	],7.5)

func create_global_river_and_bridge() -> void:
	var water := ShaderMaterial.new()
	water.shader = load("res://scripts/production/visual_slice_water.gdshader")
	var river := PlaneMesh.new()
	river.size = Vector2(720,78)
	var river_node := add_mesh(river,water,Vector3(0,1.10,-101))
	river_node.name = "StrategicRiver"

	# Main engineered bridge.
	block(Vector3(35,3.35,-100),Vector3(9.2,.72,92),"stone")
	for z in [-135.0,-119.0,-103.0,-87.0,-71.0]:
		for x in [31.5,38.5]:
			block(Vector3(x,1.25,z),Vector3(1.15,4.5,1.6),"stone")
	for x in [30.5,39.5]:
		rod(Vector3(x,4.55,-146),Vector3(x,4.55,-54),.10,"metal")
		rod(Vector3(x,3.92,-146),Vector3(x,3.92,-54),.075,"metal")
		for z in range(-145,-54,3):
			rod(Vector3(x,3.55,float(z)),Vector3(x,4.55,float(z)),.06,"metal")

	# Broken secondary crossing, visible as war damage rather than another gameplay lane.
	for segment in [Vector3(-112,2.7,-100),Vector3(-84,2.65,-100)]:
		var deck := block(segment,Vector3(23,.55,7.0),"stone")
		deck.rotation.y = .04 if segment.x < -100 else -.08
	for x in [-122.0,-101.0,-94.0,-73.0]:
		block(Vector3(x,1.1,-100),Vector3(1.1,3.8,1.5),"stone")

func style_abrams(tank: Node3D) -> void:
	for child: Node in tank.find_children("*","MeshInstance3D",true,false):
		var mi := child as MeshInstance3D
		if mi.mesh == null:
			continue
		for i in range(mi.mesh.get_surface_count()):
			var original := mi.get_active_material(i) as StandardMaterial3D
			if original == null:
				continue
			var material := ShaderMaterial.new()
			material.shader = load("res://scripts/production/visual_slice_armor.gdshader")
			material.set_shader_parameter("paint_texture",original.albedo_texture)
			material.set_shader_parameter("paint_color",original.albedo_color)
			material.set_shader_parameter("normal_texture",original.normal_texture)
			material.set_shader_parameter("has_normal",original.normal_enabled)
			material.set_shader_parameter("rough_texture",original.roughness_texture)
			material.set_shader_parameter("roughness_factor",original.roughness)
			material.set_shader_parameter("ground_y",tank.position.y)
			material.set_shader_parameter("authored_metallic",original.metallic)
			material.set_shader_parameter("authored_specular",original.metallic_specular)
			material.set_shader_parameter("metal_texture",original.metallic_texture)
			material.set_shader_parameter("has_metal_texture",original.metallic_texture != null)
			material.set_shader_parameter("ao_texture",original.ao_texture)
			material.set_shader_parameter("has_ao",original.ao_enabled)
			material.set_shader_parameter("vehicle_inverse",tank.global_transform.affine_inverse())
			var material_name := original.resource_name.to_lower()
			var role := 0.0
			if "rubber" in material_name:
				role = 1.0
			elif "gear" in material_name or "radiator" in material_name or "screw" in material_name:
				role = 2.0
			elif material_name == "light":
				role = 3.0
			material.set_shader_parameter("surface_role",role)
			var channels: Array[Vector4] = [
				Vector4(1,0,0,0),Vector4(0,1,0,0),Vector4(0,0,1,0),
				Vector4(0,0,0,1),Vector4(.333,.333,.333,0)
			]
			material.set_shader_parameter("rough_channel",channels[original.roughness_texture_channel])
			material.set_shader_parameter("metal_channel",channels[original.metallic_texture_channel])
			material.set_shader_parameter("ao_channel",channels[original.ao_texture_channel])
			mi.set_surface_override_material(i,material)

func spawn_battle_vehicle(file: String, x: float, z: float, yaw: float, scale3: float = 1.0, hero_material: bool = false) -> Node3D:
	var vehicle := spawn(file,Vector3(x,height_at(x,z)+.04,z),scale3,yaw)
	if hero_material and file.ends_with("abrams.glb"):
		style_abrams(vehicle)
	battlefield_unit_count += 1
	return vehicle

func create_armor_push() -> void:
	# Foreground force mass: staggered columns, not lane markers.
	var armor_specs := [
		Vector4(-225,110,170,1.0),Vector4(-190,95,174,1.0),Vector4(-158,122,168,1.0),
		Vector4(-130,82,176,1.0),Vector4(-98,106,171,1.0),Vector4(-65,70,177,1.0),
		Vector4(-28,94,170,1.0),Vector4(8,63,177,1.0),Vector4(62,80,170,1.0),
		Vector4(108,54,174,1.0),Vector4(158,72,168,1.0),Vector4(202,42,176,1.0)
	]
	for i in range(armor_specs.size()):
		var s: Vector4 = armor_specs[i]
		spawn_battle_vehicle(ASSET+"abrams.glb",s.x,s.y,s.z,s.w,i < 6)
	var ifv_specs := [
		Vector3(-205,72,171),Vector3(-170,58,176),Vector3(-118,55,173),Vector3(-75,42,177),
		Vector3(-25,48,172),Vector3(45,38,178),Vector3(92,32,172),Vector3(142,25,176),
		Vector3(185,18,171)
	]
	for p in ifv_specs:
		spawn_battle_vehicle(VEHICLES+"ifv.glb",p.x,p.y,p.z,.78,false)

	# Vehicles committed onto the bridge and bridgehead.
	for z in [-54.0,-70.0,-88.0,-108.0,-126.0]:
		spawn_battle_vehicle(ASSET+"abrams.glb",35.0,z,180.0,.94,z>-90.0)
	for z in [-62.0,-80.0,-118.0,-136.0]:
		spawn_battle_vehicle(VEHICLES+"ifv.glb",29.0,z,180.0,.76,false)

func create_infantry_columns() -> void:
	for group in range(8):
		var cx := -205.0 + group*48.0
		var cz := 72.0 - (group%3)*18.0
		for i in range(5):
			var x := cx + (i%3)*3.2 + rng.randf_range(-1.2,1.2)
			var z := cz + floori(i/3.0)*4.0 + rng.randf_range(-1.0,1.0)
			spawn(INFANTRY+"soldier.glb",Vector3(x,height_at(x,z),z),1.0,rng.randf_range(150,205))
			battlefield_unit_count += 1
	for i in range(14):
		var x := rng.randf_range(52,150)
		var z := rng.randf_range(-155,-126)
		spawn(INFANTRY+"soldier.glb",Vector3(x,height_at(x,z),z),1.0,rng.randf()*360)
		battlefield_unit_count += 1

func create_urban_battle_zone() -> void:
	var core_models: Array[String] = [
		ASSET+"house_intact.glb",
		ASSET+"house_damaged.glb",
		CITY_REAL+"ordinary_house_textured.glb",
		CITY+"00_shop_front11.glb",
		CITY+"01_shop_front10.glb",
		CITY+"02_shop_front9.glb",
		CITY+"03_shop_front8.glb",
		CITY+"04_shop_front7.glb",
		CITY+"05_shop_front5.glb",
		CITY+"06_shop_front6.glb"
	]
	for row in range(7):
		for col in range(13):
			if col == 4 or col == 9:
				continue
			if row == 2 and col in [5,6,7]:
				continue
			var x := -68.0 + col*22.0 + rng.randf_range(-2.5,2.5)
			var z := -158.0 - row*23.0 + rng.randf_range(-2.5,2.5)
			var model_path := core_models[(row*5+col*3)%core_models.size()]
			if rng.randf() < .30:
				model_path = ASSET+"house_damaged.glb"
			var sc := rng.randf_range(.74,.98)
			var architecture := model_path.begins_with(ASSET)
			spawn(model_path,Vector3(x,height_at(x,z),z),sc,rng.randf_range(-8,8),architecture)
			battlefield_building_count += 1

	var church := spawn(CITY_REAL+"church_landmark.glb",Vector3(150,height_at(150,-235),-235),1.35,-4)
	battlefield_building_count += 1
	for child: Node in church.find_children("*","MeshInstance3D",true,false):
		var mi := child as MeshInstance3D
		for i in range(mi.mesh.get_surface_count()):
			var m := mi.get_active_material(i)
			var key := m.resource_name.to_lower() if m != null else ""
			mi.set_surface_override_material(i,mats["roof"] if "roof" in key else mats["stone"])

	# Dense rubble bands give the city a continuous destroyed fabric instead of isolated houses.
	for i in range(220):
		var x := rng.randf_range(-65,225)
		var z := rng.randf_range(-315,-145)
		if rng.randf() < .35 and absf(posmod(x+80.0,44.0)-22.0) < 8.0:
			continue
		spawn(ASSET+"rock_moss_set_01_"+str(i%6)+".glb",
			Vector3(x,height_at(x,z)-.02,z),
			rng.randf_range(.10,.34),rng.randf()*360)

func create_tree_line(a: Vector2, b: Vector2, spacing: float, scale_min: float = 1.0, scale_max: float = 1.5) -> void:
	var distance := a.distance_to(b)
	var count := maxi(1,int(distance/spacing))
	for i in range(count+1):
		var t := float(i)/float(count)
		var p := a.lerp(b,t)
		p += Vector2(rng.randf_range(-2.2,2.2),rng.randf_range(-2.2,2.2))
		var file := ASSET+"island_tree_01_0.glb" if i%3 != 0 else ASSET+"fir_sapling_medium_"+str(i%3)+".glb"
		spawn(file,Vector3(p.x,height_at(p.x,p.y),p.y),rng.randf_range(scale_min,scale_max),rng.randf()*360)
		battlefield_tree_count += 1

func create_tree_belts() -> void:
	create_tree_line(Vector2(-300,132),Vector2(-170,95),14.0,1.0,1.45)
	create_tree_line(Vector2(-165,12),Vector2(-65,-15),13.0,1.0,1.55)
	create_tree_line(Vector2(62,112),Vector2(205,75),14.0,1.0,1.5)
	create_tree_line(Vector2(112,-25),Vector2(245,-58),13.0,1.05,1.65)
	create_tree_line(Vector2(-290,-70),Vector2(-180,-92),15.0,1.0,1.55)
	create_tree_line(Vector2(-285,-138),Vector2(-180,-142),14.0,1.0,1.6)
	create_tree_line(Vector2(240,-125),Vector2(300,-245),14.0,1.0,1.7)

	for i in range(145):
		var x := rng.randf_range(-300,290)
		var z := rng.randf_range(-130,135)
		if absf(z+100.0) < 42.0:
			continue
		if rng.randf() < .55:
			spawn(ASSET+"shrub_02_"+str(i%4)+".glb",Vector3(x,height_at(x,z),z),rng.randf_range(.45,.92),rng.randf()*360)

func create_industrial_horizon() -> void:
	var base_z := -445.0
	for i in range(7):
		var x := -190.0 + i*58.0
		var y := height_at(x,base_z)
		block(Vector3(x,y+7,base_z),Vector3(34,14,28),"industrial")
		block(Vector3(x+8,y+15,base_z-3),Vector3(12,17,12),"industrial")
		battlefield_building_count += 2
	for x in [-205.0,-90.0,40.0,175.0]:
		var y := height_at(x,base_z-16)
		rod(Vector3(x,y,base_z-16),Vector3(x,y+52,base_z-16),2.4,"industrial")
		battlefield_building_count += 1
	# Radar/communications ridge.
	for x in [-155.0,-95.0,-35.0]:
		var z := -560.0
		var y := height_at(x,z)
		rod(Vector3(x,y,z),Vector3(x,y+27,z),.65,"metal")
		var dome := SphereMesh.new()
		dome.radius = 4.5
		dome.height = 9.0
		dome.radial_segments = 24
		dome.rings = 12
		add_mesh(dome,mats["stone"],Vector3(x,y+30,z),Vector3(1.0,.55,1.0))

func add_fire_glow(pos: Vector3, radius: float = 2.0) -> void:
	var fire_mat := StandardMaterial3D.new()
	fire_mat.albedo_color = Color(1.0,.18,.025)
	fire_mat.emission_enabled = true
	fire_mat.emission = Color(1.0,.11,.015)
	fire_mat.emission_energy_multiplier = 7.0
	var sphere := SphereMesh.new()
	sphere.radius = radius
	sphere.height = radius*2.0
	sphere.radial_segments = 10
	sphere.rings = 6
	add_mesh(sphere,fire_mat,pos,Vector3(1.0,.65,1.0))
	var light := OmniLight3D.new()
	light.position = pos+Vector3(0,2,0)
	light.light_color = Color(1.0,.24,.06)
	light.light_energy = 5.0
	light.omni_range = 18.0
	light.shadow_enabled = false
	add_child(light)

func create_war_atmosphere() -> void:
	var volume := NoiseTexture3D.new()
	volume.width = 64
	volume.height = 64
	volume.depth = 64
	volume.seamless = true
	var source := FastNoiseLite.new()
	source.seed = 9317
	source.frequency = .071
	source.fractal_octaves = 4
	volume.noise = source
	var columns := [
		[Vector3(-35,0,-190),Vector3(22,58,22)],
		[Vector3(65,0,-220),Vector3(30,74,28)],
		[Vector3(132,0,-265),Vector3(25,66,24)],
		[Vector3(205,0,-205),Vector3(28,82,28)],
		[Vector3(-80,0,-285),Vector3(24,62,24)],
		[Vector3(-110,0,-445),Vector3(28,95,28)],
		[Vector3(85,0,-455),Vector3(34,110,32)],
		[Vector3(190,0,-430),Vector3(26,78,25)]
	]
	for item in columns:
		var pos: Vector3 = item[0]
		var size3: Vector3 = item[1]
		var fog := FogVolume.new()
		fog.size = size3
		var mat := ShaderMaterial.new()
		mat.shader = load("res://scripts/production/visual_slice_smoke.gdshader")
		mat.set_shader_parameter("volume_noise",volume)
		fog.material = mat
		fog.position = Vector3(pos.x,height_at(pos.x,pos.z)+size3.y*.43,pos.z)
		add_child(fog)
		smoke_column_count += 1

	for p in [
		Vector3(-32,0,-190),Vector3(68,0,-218),Vector3(135,0,-263),
		Vector3(202,0,-203),Vector3(-78,0,-283)
	]:
		p.y = height_at(p.x,p.z)+2.0
		add_fire_glow(p,1.8)

func capture() -> void:
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(FULL_OUT)
	var image := get_viewport().get_texture().get_image()
	var path := FULL_OUT+"/full_battlefield_actual_1920x1080.png"
	var err := image.save_png(path)
	var average := 0.0
	for value in times:
		average += value/maxi(times.size(),1)
	var wall_average := 0.0
	for elapsed in wall_frame_times:
		wall_average += elapsed/maxi(1,wall_frame_times.size())
	wall_frame_times.sort()
	var report := {
		"captured_at_utc":Time.get_datetime_string_from_system(true),
		"engine":Engine.get_version_info(),
		"renderer":RenderingServer.get_current_rendering_method(),
		"gpu":RenderingServer.get_video_adapter_name(),
		"width":image.get_width(),
		"height":image.get_height(),
		"save_error":err,
		"camera_position":str(camera.position),
		"camera_rotation":str(camera.rotation_degrees),
		"fov":camera.fov,
		"internal_3d_render_scale":get_viewport().scaling_3d_scale,
		"average_frame_ms_short_capture":average,
		"sample_count":times.size(),
		"screenshot_source":"Viewport.get_texture().get_image() after frame_post_draw",
		"post_capture_image_editing":false,
		"gameplay_changes":false,
		"visual_acceptance":"NOT_CLAIMED",
		"composition":"foreground armor + strategic river/bridge + continuous urban battle zone + flank farmland + industrial horizon",
		"units":battlefield_unit_count,
		"buildings":battlefield_building_count,
		"trees":battlefield_tree_count,
		"smoke_columns":smoke_column_count,
		"draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
		"rendered_primitives":Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME),
		"capture_frame":capture_frame
	}
	report["wall_clock_frame_ms_mean"] = wall_average
	report["wall_clock_frame_ms_p95"] = wall_frame_times[min(wall_frame_times.size()-1,int(wall_frame_times.size()*.95))] if not wall_frame_times.is_empty() else 0.0
	FileAccess.open(FULL_OUT+"/runtime_metrics.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("FRONTLINE_FULL_BATTLEFIELD_CAPTURED ",path," ",image.get_size()," average_ms=",average)
	get_tree().quit(err)
