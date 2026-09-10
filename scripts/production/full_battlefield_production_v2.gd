extends "res://scripts/production/river_town_visual_slice.gd"
## Battle-scale visual scene built outward from the proven River Town high-fidelity module.
## Foreground deliberately reuses the exact local-fidelity house, armor, rut, puddle,
## groundcover, vegetation and clutter methods instead of rebuilding them at lower quality.

const FULL_OUT := "res://artifacts/full_battlefield_v2"
const HERO_HOUSE := "res://scenes/production/RiverTownHeroHouseHF.tscn"
const CITY_REAL := "res://assets/golden_scene/city_real/"
const VEHICLES := "res://assets/golden_scene/vehicles/"
const INFANTRY := "res://assets/golden_scene/infantry/"

var battlefield_units := 0
var battlefield_buildings := 0
var battlefield_trees := 0
var battlefield_smoke := 0

func _ready() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-frame="):
			capture_frame = maxi(1,int(argument.get_slice("=",1)))
	rng.seed = 730128
	noise.seed = 1203
	noise.frequency = .12
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
	get_viewport().scaling_3d_scale = 1.5

	# Keep the approved local-slice lighting/material pipeline.
	create_lighting()
	create_materials()
	create_battlefield_materials()
	prepare_puddle_sites()

	# One continuous terrain. The exact local HF patch is retained in the foreground.
	create_terrain(-430.0,430.0,-650.0,190.0,3.0,false)
	create_terrain(-46.0,46.0,-48.0,52.0,.16,true)

	# Exact Codex-uploaded local-fidelity foreground methods.
	create_road_detail()
	create_architecture()
	create_armor()
	create_vegetation()
	create_clutter()

	# Build outward from that foreground module.
	create_operational_roads()
	create_battle_river_bridge()
	create_bridgehead_force()
	create_continuous_town()
	create_flank_landscape()
	create_far_industry()
	create_battle_smoke_and_fire()
	create_far_forest_only()

	var reflection := ReflectionProbe.new()
	reflection.name = "FullBattlefieldReflection"
	reflection.position = Vector3(15,16,-115)
	reflection.size = Vector3(390,100,440)
	reflection.max_distance = 520
	reflection.box_projection = true
	reflection.cull_mask = 1
	reflection.intensity = .90
	add_child(reflection)

	# Keep foreground assets large enough to read while still containing river, city and horizon.
	camera.position = Vector3(92.0,46.0,112.0)
	camera.look_at(Vector3(18.0,2.0,-145.0))
	camera.fov = 48.0
	camera.near = .25
	camera.far = 1500.0
	camera.current = true

	print("FRONTLINE_FULL_BATTLEFIELD_V2_READY renderer=",RenderingServer.get_current_rendering_method(),
		" adapter=",RenderingServer.get_video_adapter_name(),
		" units=",battlefield_units,
		" buildings=",battlefield_buildings,
		" trees=",battlefield_trees,
		" smoke=",battlefield_smoke,
		" foreground_hf=true")
	set_process(true)
	capture_pending = "--capture" in OS.get_cmdline_user_args()

func create_battlefield_materials() -> void:
	mats["asphalt_v2"] = surface("asphalt_02",Color(.64,.62,.57),.55)
	mats["dry_field_v2"] = surface("dirt_aerial_03",Color(.78,.72,.58),.38)
	mats["green_field_v2"] = surface("leafy_grass",Color(.62,.68,.46),.44)
	mats["industrial_v2"] = surface("t_concrete_wall_002",Color(.54,.54,.51),.80)

func create_strip(a: Vector3,b: Vector3,width: float,material: Material,segments: int = 32) -> MeshInstance3D:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var direction := Vector2(b.x-a.x,b.z-a.z).normalized()
	var side := Vector2(-direction.y,direction.x)
	for i in range(segments):
		var t0 := float(i)/segments
		var t1 := float(i+1)/segments
		var c0 := Vector2(a.x,a.z).lerp(Vector2(b.x,b.z),t0)
		var c1 := Vector2(a.x,a.z).lerp(Vector2(b.x,b.z),t1)
		var l0 := c0+side*width*.5
		var r0 := c0-side*width*.5
		var l1 := c1+side*width*.5
		var r1 := c1-side*width*.5
		var pts := [
			Vector3(l0.x,height_at(l0.x,l0.y)+.055,l0.y),
			Vector3(r0.x,height_at(r0.x,r0.y)+.055,r0.y),
			Vector3(r1.x,height_at(r1.x,r1.y)+.055,r1.y),
			Vector3(l0.x,height_at(l0.x,l0.y)+.055,l0.y),
			Vector3(r1.x,height_at(r1.x,r1.y)+.055,r1.y),
			Vector3(l1.x,height_at(l1.x,l1.y)+.055,l1.y)
		]
		for p in pts:
			st.set_uv(Vector2(p.x,p.z)*.075)
			st.add_vertex(p)
	st.generate_normals()
	st.generate_tangents()
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	mi.material_override = material
	mi.gi_mode = GeometryInstance3D.GI_MODE_STATIC
	add_child(mi)
	return mi

func create_hf_rutted_route(a: Vector2,b: Vector2,width: float = 6.2) -> void:
	# Same road_surface_v2 displacement resource used by Batch 03, extended along a battle route.
	var direction := (b-a).normalized()
	var side := Vector2(-direction.y,direction.x)
	var length := a.distance_to(b)
	var along_steps := maxi(2,int(length/.55))
	var across_steps := maxi(4,int(width/.28))
	var vertices := PackedVector3Array()
	var nx := across_steps+1
	for iz in range(along_steps+1):
		var d := length*float(iz)/along_steps
		var center := a+direction*d
		for ix in range(nx):
			var lateral := -width*.5+width*float(ix)/across_steps
			var p2 := center+side*lateral
			var y := height_at(p2.x,p2.y)+ROAD_PROFILE.displacement(lateral,d-length*.35)+.035
			vertices.append(Vector3(p2.x,y,p2.y))
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for iz in range(along_steps+1):
		for ix in range(nx):
			var p := vertices[iz*nx+ix]
			var l := max(0,ix-1)
			var r := min(nx-1,ix+1)
			var za := max(0,iz-1)
			var zb := min(along_steps,iz+1)
			var px0 := vertices[iz*nx+l]
			var px1 := vertices[iz*nx+r]
			var pz0 := vertices[za*nx+ix]
			var pz1 := vertices[zb*nx+ix]
			var normal := (pz1-pz0).cross(px1-px0).normalized()
			if normal.y < 0:
				normal = -normal
			st.set_normal(normal)
			st.set_uv(Vector2(p.x,p.z))
			st.add_vertex(p)
	for iz in range(along_steps):
		for ix in range(nx-1):
			var k := iz*nx+ix
			for index in [k,k+1,k+nx,k+1,k+nx+1,k+nx]:
				st.add_index(index)
	st.generate_tangents()
	var route := MeshInstance3D.new()
	route.name = "HF_RuttedOperationalRoute"
	route.mesh = st.commit()
	route.material_override = get_node("SculptedNearTerrain").material_override
	route.gi_mode = GeometryInstance3D.GI_MODE_STATIC
	add_child(route)

func create_operational_roads() -> void:
	create_hf_rutted_route(Vector2(7,42),Vector2(30,-58),6.5)
	create_strip(Vector3(30,0,-58),Vector3(34,0,-68),7.0,mats["asphalt_v2"],10)
	create_strip(Vector3(35,0,-132),Vector3(42,0,-160),8.0,mats["asphalt_v2"],12)
	create_strip(Vector3(42,0,-160),Vector3(150,0,-222),7.0,mats["asphalt_v2"],36)
	create_strip(Vector3(42,0,-160),Vector3(-72,0,-226),6.0,mats["asphalt_v2"],36)

func create_battle_river_bridge() -> void:
	var water := ShaderMaterial.new()
	water.shader = load("res://scripts/production/visual_slice_water.gdshader")
	var plane := PlaneMesh.new()
	plane.size = Vector2(610,66)
	var river := add_mesh(plane,water,Vector3(0,1.15,-100))
	river.name = "BattleRiver"

	# More substantial engineered crossing while retaining River Town materials.
	block(Vector3(35,3.35,-100),Vector3(9.0,.72,68),"stone")
	for z in [-127.0,-113.0,-99.0,-85.0,-71.0]:
		for x in [31.7,38.3]:
			block(Vector3(x,1.25,z),Vector3(1.05,4.45,1.55),"stone")
	for x in [30.5,39.5]:
		rod(Vector3(x,4.55,-134),Vector3(x,4.55,-66),.09,"metal")
		rod(Vector3(x,3.93,-134),Vector3(x,3.93,-66),.065,"metal")
		for z in range(-133,-65,2):
			rod(Vector3(x,3.55,float(z)),Vector3(x,4.55,float(z)),.055,"metal")

func style_abrams_v2(tank: Node3D) -> void:
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
			var name := original.resource_name.to_lower()
			var role := 0.0
			if "rubber" in name:
				role = 1.0
			elif "gear" in name or "radiator" in name or "screw" in name:
				role = 2.0
			elif name == "light":
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

func add_abrams(x: float,z: float,yaw: float,scale3: float = 1.0) -> void:
	var tank := spawn(ASSET+"abrams.glb",Vector3(x,height_at(x,z)+.03,z),scale3,yaw)
	style_abrams_v2(tank)
	battlefield_units += 1

func create_bridgehead_force() -> void:
	# Staggered combat mass around the proven hero foreground, not a symbolic route marker.
	for spec in [
		Vector4(40,54,172,1.0),Vector4(66,46,177,.96),Vector4(-34,50,169,.98),
		Vector4(-65,62,174,.96),Vector4(84,24,177,.96),Vector4(-82,30,171,.94),
		Vector4(12,-18,178,.96),Vector4(25,-48,179,.94)
	]:
		var s: Vector4 = spec
		add_abrams(s.x,s.y,s.z,s.w)
	for z in [-68.0,-83.0,-101.0,-119.0,-133.0]:
		add_abrams(35,z,180,.90)

	for p in [
		Vector3(52,39,174),Vector3(-50,43,170),Vector3(75,14,177),
		Vector3(-67,18,173),Vector3(22,-34,179),Vector3(29,-58,180)
	]:
		spawn(VEHICLES+"ifv.glb",Vector3(p.x,height_at(p.x,p.y)+.03,p.y),.78,p.z)
		battlefield_units += 1

	# Infantry stays small and subordinate to armor.
	for group in range(7):
		var cx := -72.0+group*24.0
		var cz := 42.0-(group%2)*16.0
		for i in range(4):
			var x := cx+(i%2)*2.4+rng.randf_range(-.7,.7)
			var z := cz+floori(i/2.0)*3.0+rng.randf_range(-.7,.7)
			spawn(INFANTRY+"soldier.glb",Vector3(x,height_at(x,z),z),.085,rng.randf_range(160,200))
			battlefield_units += 1

func spawn_hf_house(x: float,z: float,yaw: float,scale3: float = 1.0) -> void:
	var house := spawn(HERO_HOUSE,Vector3(x,height_at(x,z)-.04,z),scale3,yaw,false)
	house.name = "HF_UrbanHouse_%03d" % battlefield_buildings
	battlefield_buildings += 1

func create_continuous_town() -> void:
	# Front edge uses the exact HF house scene. Lower-cost matching houses only appear deeper.
	for spec in [
		Vector4(-52,-158,5,.88),Vector4(-25,-162,-4,.92),Vector4(2,-160,3,.90),
		Vector4(70,-166,-5,.90),Vector4(98,-170,4,.86),Vector4(128,-174,-3,.88),
		Vector4(-42,-190,-5,.82),Vector4(5,-194,4,.84),Vector4(88,-199,-4,.83)
	]:
		var s: Vector4 = spec
		spawn_hf_house(s.x,s.y,s.z,s.w)

	var regular: Array[String] = [ASSET+"house_damaged.glb",ASSET+"house_intact.glb"]
	for row in range(5):
		for col in range(11):
			if col == 4 or col == 8:
				continue
			var x := -78.0+col*24.0+rng.randf_range(-2.0,2.0)
			var z := -220.0-row*25.0+rng.randf_range(-2.0,2.0)
			var file := regular[(row+col)%2]
			spawn(file,Vector3(x,height_at(x,z),z),rng.randf_range(.88,1.08),rng.randf_range(-8,8),true)
			battlefield_buildings += 1

	var church := spawn(CITY_REAL+"church_landmark.glb",Vector3(155,height_at(155,-255),-255),1.55,-3)
	battlefield_buildings += 1
	for child: Node in church.find_children("*","MeshInstance3D",true,false):
		var mi := child as MeshInstance3D
		if mi.mesh == null:
			continue
		for i in range(mi.mesh.get_surface_count()):
			var m := mi.get_active_material(i)
			var key := m.resource_name.to_lower() if m != null else ""
			mi.set_surface_override_material(i,mats["roof"] if "roof" in key else mats["stone"])

	# Urban debris is concentrated along the active front and street edges.
	for i in range(260):
		var x := rng.randf_range(-82,188)
		var z := rng.randf_range(-335,-148)
		if rng.randf() < .32 and absf(posmod(x+82.0,48.0)-24.0) < 8.0:
			continue
		spawn(ASSET+"rock_moss_set_01_"+str(i%6)+".glb",
			Vector3(x,height_at(x,z)-.025,z),rng.randf_range(.12,.38),rng.randf()*360)

func create_field_patch(center: Vector2,size: Vector2,material: Material) -> void:
	var a := Vector3(center.x-size.x*.5,0,center.y-size.y*.5)
	var b := Vector3(center.x+size.x*.5,0,center.y+size.y*.5)
	create_strip(Vector3(a.x,0,center.y),Vector3(b.x,0,center.y),size.y,material,maxi(8,int(size.x/5.0)))

func create_tree_line_v2(a: Vector2,b: Vector2,spacing: float) -> void:
	var count := maxi(1,int(a.distance_to(b)/spacing))
	for i in range(count+1):
		var t := float(i)/count
		var p := a.lerp(b,t)+Vector2(rng.randf_range(-2.2,2.2),rng.randf_range(-2.2,2.2))
		var file := ASSET+"island_tree_01_0.glb" if i%3 else ASSET+"fir_sapling_medium_"+str(i%3)+".glb"
		spawn(file,Vector3(p.x,height_at(p.x,p.y),p.y),rng.randf_range(1.0,1.55),rng.randf()*360)
		battlefield_trees += 1

func create_flank_landscape() -> void:
	create_field_patch(Vector2(-145,52),Vector2(110,78),mats["dry_field_v2"])
	create_field_patch(Vector2(145,48),Vector2(105,82),mats["green_field_v2"])
	create_field_patch(Vector2(-165,-40),Vector2(95,52),mats["green_field_v2"])
	create_field_patch(Vector2(175,-38),Vector2(92,56),mats["dry_field_v2"])

	create_tree_line_v2(Vector2(-225,105),Vector2(-120,72),12.0)
	create_tree_line_v2(Vector2(105,104),Vector2(235,62),12.0)
	create_tree_line_v2(Vector2(-240,-66),Vector2(-130,-74),13.0)
	create_tree_line_v2(Vector2(120,-58),Vector2(250,-76),13.0)
	create_tree_line_v2(Vector2(-250,-138),Vector2(-120,-142),14.0)
	create_tree_line_v2(Vector2(205,-138),Vector2(270,-205),14.0)

func create_far_industry() -> void:
	var z := -455.0
	for i in range(6):
		var x := -165.0+i*65.0
		var y := height_at(x,z)
		block(Vector3(x,y+7,z),Vector3(38,14,30),"industrial_v2")
		block(Vector3(x+9,y+15,z-3),Vector3(13,17,13),"industrial_v2")
		battlefield_buildings += 2
	for x in [-190.0,-65.0,75.0,190.0]:
		var y := height_at(x,z-15)
		rod(Vector3(x,y,z-15),Vector3(x,y+55,z-15),2.3,"industrial_v2")
	for x in [-120.0,-45.0,30.0]:
		var rz := -540.0
		var y := height_at(x,rz)
		rod(Vector3(x,y,rz),Vector3(x,y+25,rz),.55,"metal")
		var dome := SphereMesh.new()
		dome.radius = 4.2
		dome.height = 8.4
		dome.radial_segments = 20
		dome.rings = 10
		add_mesh(dome,mats["stone"],Vector3(x,y+28,rz),Vector3(1,.55,1))

func add_fire_v2(pos: Vector3,scale3: float) -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(1.0,.20,.035)
	material.emission_enabled = true
	material.emission = Color(1.0,.11,.015)
	material.emission_energy_multiplier = 6.5
	var mesh := SphereMesh.new()
	mesh.radius = scale3
	mesh.height = scale3*2.
	mesh.radial_segments = 10
	mesh.rings = 6
	add_mesh(mesh,material,pos,Vector3(1,.72,1))
	var light := OmniLight3D.new()
	light.position = pos+Vector3(0,1.5,0)
	light.light_color = Color(1.0,.30,.08)
	light.light_energy = 4.0
	light.omni_range = 16.0
	light.shadow_enabled = false
	add_child(light)

func create_battle_smoke_and_fire() -> void:
	var volume := NoiseTexture3D.new()
	volume.width = 64
	volume.height = 64
	volume.depth = 64
	volume.seamless = true
	var source := FastNoiseLite.new()
	source.seed = 876
	source.frequency = .075
	source.fractal_octaves = 4
	volume.noise = source
	for item in [
		[Vector3(-45,0,-190),Vector3(18,45,18)],
		[Vector3(40,0,-220),Vector3(22,58,22)],
		[Vector3(112,0,-268),Vector3(20,53,20)],
		[Vector3(175,0,-210),Vector3(24,66,24)],
		[Vector3(-72,0,-292),Vector3(20,49,20)],
		[Vector3(80,0,-455),Vector3(28,78,26)]
	]:
		var pos: Vector3 = item[0]
		var size3: Vector3 = item[1]
		var fog := FogVolume.new()
		fog.size = size3
		var mat := ShaderMaterial.new()
		mat.shader = load("res://scripts/production/visual_slice_smoke.gdshader")
		mat.set_shader_parameter("volume_noise",volume)
		fog.material = mat
		fog.position = Vector3(pos.x,height_at(pos.x,pos.z)+size3.y*.44,pos.z)
		add_child(fog)
		battlefield_smoke += 1
	for p in [
		Vector3(-43,0,-188),Vector3(42,0,-218),Vector3(114,0,-266),
		Vector3(176,0,-208),Vector3(-70,0,-290)
	]:
		p.y = height_at(p.x,p.z)+1.8
		add_fire_v2(p,1.45)

func create_far_forest_only() -> void:
	var file := ASSET+"impostors/manifest.json"
	if not FileAccess.file_exists(file):
		return
	var records: Array = JSON.parse_string(FileAccess.get_file_as_string(file))
	for variant in range(records.size()):
		var record: Dictionary = records[variant]
		var mat := StandardMaterial3D.new()
		mat.albedo_texture = load(record["file"])
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
		mat.alpha_scissor_threshold = .10
		mat.cull_mode = BaseMaterial3D.CULL_DISABLED
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.billboard_mode = BaseMaterial3D.BILLBOARD_FIXED_Y
		mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
		var quad := QuadMesh.new()
		quad.size = Vector2.ONE*float(record["size"])
		quad.material = mat
		var mm := MultiMesh.new()
		mm.transform_format = MultiMesh.TRANSFORM_3D
		mm.mesh = quad
		var transforms: Array[Transform3D] = []
		var requested := 170 if variant < 6 else 650
		for i in range(requested):
			var x := rng.randf_range(-410,410)
			var z := rng.randf_range(-640,-390)
			# Keep a clear urban/industrial basin in the centre of the frame.
			if x > -210 and x < 260 and z > -520:
				continue
			var sc := rng.randf_range(1.15,1.85)
			if variant >= 6:
				sc *= 1.55
			transforms.append(Transform3D(Basis.IDENTITY.scaled(Vector3.ONE*sc),
				Vector3(x,height_at(x,z)+float(record["center_y"])*sc,z)))
		mm.instance_count = transforms.size()
		for i in range(transforms.size()):
			mm.set_instance_transform(i,transforms[i])
		var inst := MultiMeshInstance3D.new()
		inst.multimesh = mm
		inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(inst)

func capture() -> void:
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(FULL_OUT)
	var image := get_viewport().get_texture().get_image()
	var path := FULL_OUT+"/full_battlefield_v2_actual_1920x1080.png"
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
		"foreground_local_fidelity_reused":true,
		"hero_house_scene":HERO_HOUSE,
		"road_profile":"res://assets/visual_slice/profiles/road_surface_v2.tres",
		"cover_field":"res://assets/visual_slice/profiles/groundcover_field.tres",
		"grass_instances":grass_instance_count,
		"battlefield_units":battlefield_units,
		"battlefield_buildings":battlefield_buildings,
		"battlefield_trees":battlefield_trees,
		"battlefield_smoke_columns":battlefield_smoke,
		"draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
		"rendered_primitives":Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME),
		"capture_frame":capture_frame
	}
	report["wall_clock_frame_ms_mean"] = wall_average
	report["wall_clock_frame_ms_p95"] = wall_frame_times[min(wall_frame_times.size()-1,int(wall_frame_times.size()*.95))] if not wall_frame_times.is_empty() else 0.0
	FileAccess.open(FULL_OUT+"/runtime_metrics.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("FRONTLINE_FULL_BATTLEFIELD_V2_CAPTURED ",path," ",image.get_size()," average_ms=",average)
	get_tree().quit(err)
