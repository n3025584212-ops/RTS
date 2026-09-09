extends Node3D
## Visual-only production slice. Does not instantiate or write gameplay state.

const OUT := "res://artifacts/visual_reset"
const ASSET := "res://assets/visual_slice/"
const PBR := "res://assets/visual_slice/surfaces/"
var rng := RandomNumberGenerator.new()
var noise := FastNoiseLite.new()
var camera: Camera3D
var mats: Dictionary = {}
var models: Dictionary = {}
var times: Array[float] = []
var capture_pending := false
var frames := 0
var mud_height: Image

func _ready() -> void:
	rng.seed = 730128
	noise.seed = 1203
	noise.frequency = 0.12
	noise.fractal_octaves = 4
	mud_height=(load(ASSET+"surfaces/aerial_mud_1_disp.png") as Texture2D).get_image()
	if mud_height.is_compressed():mud_height.decompress()
	mud_height.resize(256,256,Image.INTERPOLATE_BILINEAR)
	get_window().size = Vector2i(1920,1080)
	get_window().content_scale_size = Vector2i(1920,1080)
	get_viewport().msaa_3d = Viewport.MSAA_4X
	get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
	get_viewport().scaling_3d_scale = 1.5
	create_lighting()
	create_materials()
	create_terrain(-360.0,360.0,-680.0,100.0,3.0,false)
	create_terrain(-46.0,46.0,-48.0,52.0,0.16,true)
	create_architecture()
	create_armor()
	create_vegetation()
	create_clutter()
	create_background()
	create_water()
	var reflection:=ReflectionProbe.new()
	reflection.position=Vector3(2,3,6)
	reflection.size=Vector3(55,18,70)
	reflection.max_distance=85
	reflection.box_projection=true
	reflection.cull_mask=1
	reflection.intensity=.9
	add_child(reflection)
	create_smoke()
	print("FRONTLINE_RIVER_TOWN_READY renderer=",RenderingServer.get_current_rendering_method()," adapter=",RenderingServer.get_video_adapter_name())
	set_process(true)
	capture_pending = "--capture" in OS.get_cmdline_user_args()

func create_lighting() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sky_material := ShaderMaterial.new()
	sky_material.shader=load("res://scripts/production/visual_slice_sky.gdshader")
	sky_material.set_shader_parameter("panorama",load(ASSET+"sky.hdr"))
	sky.sky_material=sky_material
	env.sky = sky
	env.sky_rotation = Vector3.ZERO
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(.60,.68,.82)
	env.ambient_light_energy = 0.50
	env.reflected_light_source = Environment.REFLECTION_SOURCE_SKY
	env.sdfgi_enabled = false
	env.sdfgi_cascades = 3
	env.sdfgi_min_cell_size = .3
	env.sdfgi_use_occlusion = true
	env.sdfgi_energy = .75
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.tonemap_exposure = 0.95
	env.ssao_enabled = true
	env.ssao_radius = 1.5
	env.ssao_intensity = 1.8
	env.ssao_power = 1.3
	env.ssil_enabled = true
	env.ssil_radius = 3.0
	env.ssil_intensity = 0.45
	env.fog_enabled = true
	env.fog_light_color = Color(0.58,0.63,0.66)
	env.fog_light_energy = 0.75
	env.fog_density = 0.0018
	env.fog_sky_affect = 0.12
	env.fog_height = 2.0
	env.fog_height_density = 0.005
	env.volumetric_fog_enabled = true
	env.volumetric_fog_density = .00035
	env.volumetric_fog_albedo = Color(.60,.65,.69)
	env.volumetric_fog_length = 360
	env.volumetric_fog_ambient_inject = .15
	env.ssr_enabled = true
	env.ssr_max_steps = 48
	var world := WorldEnvironment.new()
	world.environment = env
	add_child(world)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-28,55,0)
	sun.light_color = Color(1.0,0.85,0.65)
	sun.light_energy = 1.8
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 180
	sun.shadow_bias = 0.025
	sun.shadow_normal_bias = 0.35
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS
	sun.light_angular_distance = 0.6
	add_child(sun)
	camera = Camera3D.new()
	camera.name = "ApprovedReferenceCamera"
	add_child(camera)
	camera.position = Vector3(9.0,6.4,20.5)
	camera.look_at(Vector3(-3.0,-5.0,-23.0))
	camera.fov = 54
	camera.far = 1200
	camera.near = 0.2
	camera.current = true

func simple(color: Color, roughness: float = 0.85) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = roughness
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	return mat

func surface(base: String, tint: Color, scale_uv: float = 1.0) -> StandardMaterial3D:
	var mat := simple(tint)
	var file := ASSET+"surfaces/"+base+"_diff.jpg"
	if FileAccess.file_exists(file):
		mat.albedo_texture = load(file)
		var n := ASSET+"surfaces/"+base+"_nor_gl.jpg"
		if FileAccess.file_exists(n):
			mat.normal_enabled = true
			mat.normal_texture = load(n)
			mat.normal_scale = 0.65
		var r := ASSET+"surfaces/"+base+"_rough.jpg"
		if FileAccess.file_exists(r): mat.roughness_texture = load(r)
	else:
		mat.albedo_texture = load(PBR+"t_concrete_wall_002_diff.jpg")
	mat.uv1_scale = Vector3.ONE*scale_uv
	return mat

func create_materials() -> void:
	var plaster:=ShaderMaterial.new();plaster.shader=load("res://scripts/production/visual_slice_plaster.gdshader")
	plaster.set_shader_parameter("color_texture",load(ASSET+"surfaces/worn_plaster_wall_diff.jpg"))
	plaster.set_shader_parameter("normal_texture",load(ASSET+"surfaces/worn_plaster_wall_nor_gl.jpg"))
	mats["plaster"]=plaster
	mats["roof"] = surface("roof_tiles_14",Color(0.43,0.32,0.24),1.2)
	mats["brick"] = simple(Color(0.43,0.35,0.27))
	mats["brick"].albedo_texture = load(PBR+"brick_wall_005_diff.jpg")
	mats["brick"].normal_enabled = true
	mats["brick"].normal_texture = load(PBR+"brick_wall_005_nor_gl.jpg")
	mats["wood"] = simple(Color(0.13,0.105,0.075))
	mats["wood"].albedo_texture = load(PBR+"dirt_aerial_03_diff.jpg")
	mats["trim"] = surface("worn_plaster_wall",Color(0.62,0.62,0.55),1.4)
	mats["interior"] = simple(Color(0.11,0.10,0.078))
	mats["glass"] = simple(Color(0.044,0.069,0.071),0.21)
	mats["glass"].metallic = 0.42
	mats["metal"] = simple(Color(0.17,0.18,0.17),0.56)
	mats["metal"].metallic = 0.60
	mats["stone"] = surface("worn_plaster_wall",Color(0.47,0.48,0.42),2.0)
	mats["rust"] = simple(Color(0.22,0.11,0.054))
	mats["sandbag"] = simple(Color(0.29,0.27,0.19))
	mats["sandbag"].albedo_texture = load(PBR+"dirt_aerial_03_diff.jpg")

func lane_x(z: float) -> float:
	return 1.3+0.12*z+1.2*sin(z*0.045)

func height_at(x: float,z: float) -> float:
	var h := noise.get_noise_2d(x,z)*0.17 + noise.get_noise_2d(x*0.19,z*0.19)*0.5
	h += noise.get_noise_2d(x*9,z*9)*.035*smoothstep(-110,-60,z)
	if z>-48 and z<52 and absf(x)<46:
		var mud_weight:=1.0-smoothstep(2.8,6.2,absf(x-lane_x(z)))
		var hx:int=posmod(int(floor(z*.10*256)),256);var hz:int=posmod(int(floor(x*.10*256)),256)
		h+=(mud_height.get_pixel(hx,hz).r-.5)*.55*mud_weight
		h+=noise.get_noise_2d(x*22,z*22)*.12*mud_weight
	var bank := smoothstep(-77.0,-111.0,z)
	h += bank*3.0
	h -= (1.0-smoothstep(16.0,26.0,absf(z+100.0)))*4.0
	if z < -120:
		h += pow((-z-120)/75.0,1.05)*8.5 + sin(x*.020+z*.015)*4.0*smoothstep(-120,-200,z)
	var rut := minf(absf(x-lane_x(z)-1.3),absf(x-lane_x(z)+1.3))
	h -= (1.0-smoothstep(0.25,0.72,rut))*0.24*(1.0-smoothstep(24,30,z))
	return h

func create_terrain(x0: float,x1: float,z0: float,z1: float,step: float,near_patch: bool) -> void:
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var tangents := PackedFloat32Array()
	var indices := PackedInt32Array()
	var nx := int((x1-x0)/step)+1
	var nz := int((z1-z0)/step)+1
	for iz in range(nz):
		var z := z0+iz*step
		for ix in range(nx):
			var x := x0+ix*step
			var y := height_at(x,z) + (0.018 if near_patch else 0.0)
			vertices.append(Vector3(x,y,z))
			normals.append(Vector3(height_at(x-.08,z)-height_at(x+.08,z),.16,height_at(x,z-.08)-height_at(x,z+.08)).normalized())
			uvs.append(Vector2(x,z))
			tangents.append_array(PackedFloat32Array([1,0,0,1]))
	for z in range(nz-1):
		for x in range(nx-1):
			var a := z*nx+x
			indices.append_array(PackedInt32Array([a,a+1,a+nx,a+1,a+nx+1,a+nx]))
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX]=vertices;arrays[Mesh.ARRAY_NORMAL]=normals;arrays[Mesh.ARRAY_TEX_UV]=uvs;arrays[Mesh.ARRAY_INDEX]=indices;arrays[Mesh.ARRAY_TANGENT]=tangents
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
	var mat := ShaderMaterial.new()
	mat.shader = load("res://scripts/production/visual_slice_terrain.gdshader")
	for pair in [["grass_color","leafy_grass_diff"],["soil_color","aerial_mud_1_diff"],["soil_normal","aerial_mud_1_nor_gl"],["gravel_color","gravel_ground_01_diff"],["asphalt_color","asphalt_02_diff"]]:
		mat.set_shader_parameter(pair[0],load(PBR+pair[1]+".jpg"))
	mat.set_shader_parameter("soil_roughness",load(PBR+"aerial_mud_1_rough.png"))
	var mi := MeshInstance3D.new()
	mi.mesh = mesh;mi.material_override = mat
	mi.gi_mode=GeometryInstance3D.GI_MODE_STATIC
	mi.name = "SculptedNearTerrain" if near_patch else "ValleyTerrain"
	add_child(mi)

func spawn(file: String,position3: Vector3,scale3: float=1.0,yaw: float=0.0,architecture: bool=false) -> Node3D:
	if not models.has(file): models[file] = load(file)
	var model: Node3D = models[file].instantiate()
	add_child(model)
	model.position = position3
	model.rotation_degrees.y = yaw
	model.scale = Vector3.ONE*scale3
	if architecture:
		for child: Node in model.find_children("*","MeshInstance3D",true,false):
			var mi := child as MeshInstance3D
			mi.gi_mode=GeometryInstance3D.GI_MODE_STATIC
			for i in range(mi.mesh.get_surface_count()):
				var material := mi.get_active_material(i)
				if material != null and mats.has(material.resource_name): mi.set_surface_override_material(i,mats[material.resource_name])
	return model

func create_architecture() -> void:
	spawn(ASSET+"hero_house_ruined.glb",Vector3(-11,height_at(-11,4)-.05,4),1.05,25,true)
	spawn(ASSET+"house_damaged.glb",Vector3(-6,height_at(-6,-40),-40),.91,18,true)
	spawn(ASSET+"house_intact.glb",Vector3(5,height_at(5,-55),-55),.82,-12,true)
	spawn(ASSET+"house_damaged.glb",Vector3(55,height_at(55,-68),-68),.82,-14,true)
	spawn(ASSET+"house_intact.glb",Vector3(-36,height_at(-36,-37),-37),.95,80,true)
	for pos in [Vector3(-28,0,-1),Vector3(-1,0,-5),Vector3(-25,0,12),Vector3(10,0,7),Vector3(18,0,2)]:
		create_wall(pos,6.0)

func add_mesh(mesh: Mesh, mat: Material, pos: Vector3, scale3: Vector3=Vector3.ONE, yaw: float=0.0) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh=mesh;mi.material_override=mat;mi.position=pos;mi.scale=scale3;mi.rotation.y=yaw
	add_child(mi)
	return mi

func block(pos: Vector3,size3: Vector3,material: String) -> MeshInstance3D:
	var box := BoxMesh.new();box.size=size3
	return add_mesh(box,mats[material],pos)

func rod(a: Vector3,b: Vector3,radius: float,material: String) -> void:
	var mesh := CylinderMesh.new();mesh.top_radius=radius;mesh.bottom_radius=radius;mesh.height=a.distance_to(b);mesh.radial_segments=8
	var mi := add_mesh(mesh,mats[material],(a+b)*0.5)
	mi.quaternion = Quaternion(Vector3.UP,(b-a).normalized())

func create_wall(origin: Vector3,length: float) -> void:
	for row in range(4):
		for i in range(int(length/.65)):
			if rng.randf()<.15 and row>1:continue
			var p := origin+Vector3((i+.5)*.65,0,0)
			p.y=height_at(p.x,p.z)+.16+row*.29
			var mi := block(p,Vector3(.63,.275,.40),"stone")
			mi.rotation.y=rng.randf_range(-.045,.045)
	for x in [0.0,length]:
		var p := origin+Vector3(x,0,0);p.y=height_at(p.x,p.z)+.8
		block(p,Vector3(.59,1.6,.59),"stone")
		block(p+Vector3(0,.86,0),Vector3(.72,.12,.72),"trim")

func create_armor() -> void:
	var tank := spawn(ASSET+"abrams.glb",Vector3(2.5,height_at(2.5,7.0)+.03,7),1.0,170)
	tank.name = "M1A2_SEPv3_dannzjs_CC_BY_4"
	for child: Node in tank.find_children("*","MeshInstance3D",true,false):
		var mi := child as MeshInstance3D
		for i in range(mi.mesh.get_surface_count()):
			var original := mi.get_active_material(i) as StandardMaterial3D
			if original != null:
				var material := ShaderMaterial.new()
				material.shader=load("res://scripts/production/visual_slice_armor.gdshader")
				material.set_shader_parameter("paint_texture",original.albedo_texture)
				material.set_shader_parameter("paint_color",original.albedo_color)
				material.set_shader_parameter("normal_texture",original.normal_texture)
				material.set_shader_parameter("has_normal",original.normal_enabled)
				material.set_shader_parameter("rough_texture",original.roughness_texture)
				material.set_shader_parameter("roughness_factor",original.roughness)
				material.set_shader_parameter("ground_y",tank.position.y)
				var channels: Array[Vector4]=[Vector4(1,0,0,0),Vector4(0,1,0,0),Vector4(0,0,1,0),Vector4(0,0,0,1),Vector4(.333,.333,.333,0)]
				material.set_shader_parameter("rough_channel",channels[original.roughness_texture_channel])
				mi.set_surface_override_material(i,material)

func create_groundcover() -> void:
	var variants: Array[String]=["grass_bermuda_01_3","grass_bermuda_01_5","grass_bermuda_01_7","grass_medium_01_0","grass_medium_01_3","grass_medium_01_5"]
	for variant in range(variants.size()):
		var plant:Node3D=load(ASSET+variants[variant]+".glb").instantiate();add_child(plant)
		var source:MeshInstance3D=plant.find_children("*","MeshInstance3D",true,false)[0]
		var mesh:Mesh=source.mesh.duplicate();var local_transform:=source.global_transform
		for surface_index in range(mesh.get_surface_count()):
			var original:=mesh.surface_get_material(surface_index) as StandardMaterial3D
			var material:=ShaderMaterial.new()
			material.shader=load("res://scripts/production/visual_slice_grass.gdshader")
			material.set_shader_parameter("color_texture",original.albedo_texture)
			material.set_shader_parameter("normal_texture",original.normal_texture)
			var family:="grass_bermuda_01" if variant<3 else "grass_medium_01"
			material.set_shader_parameter("alpha_texture",load(PBR+family+"_alpha_1k.png"))
			mesh.surface_set_material(surface_index,material)
		plant.free()
		var transforms:Array[Transform3D]=[]
		for i in range(65000 if variant<3 else 15000):
			var x:=rng.randf_range(-29,26);var z:=rng.randf_range(-37,22)
			if absf(z+19-sin(x*.04)*2)<3.9:continue
			if x>-19 and x<-4 and z>-3 and z<12:continue
			var lane:=absf(x-lane_x(z))
			var probability:=smoothstep(2.4,4.7,lane)*(.6+.5*noise.get_noise_2d(x*.8,z*.8))
			if rng.randf()>probability:continue
			var s:=rng.randf_range(3.0,5.2) if variant<3 else rng.randf_range(1.1,2.0)
			var basis:=Basis(Vector3.UP,rng.randf()*TAU).scaled(Vector3.ONE*s)
			transforms.append(Transform3D(basis,Vector3(x,height_at(x,z)+.02,z))*local_transform)
		var mm:=MultiMesh.new();mm.transform_format=MultiMesh.TRANSFORM_3D;mm.mesh=mesh;mm.instance_count=transforms.size()
		for i in range(transforms.size()):mm.set_instance_transform(i,transforms[i])
		var inst:=MultiMeshInstance3D.new();inst.multimesh=mm;inst.name=variants[variant]
		inst.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		add_child(inst)
		print("SOURCE_GRASS_INSTANCES ",variants[variant]," ",transforms.size())

func create_vegetation() -> void:
	create_groundcover()
	var tree := ASSET+"island_tree_01_0.glb"
	if FileAccess.file_exists(tree):
		for p in [Vector3(-23,0,9),Vector3(-21,0,-12),Vector3(-15,0,-23),Vector3(12,0,-37),Vector3(28,0,-24),Vector3(30,0,-62)]:
			p.y=height_at(p.x,p.z)
			spawn(tree,p,1.7,rng.randf()*360)
		for i in range(14):
			var x:=rng.randf_range(-39,20);var z:=rng.randf_range(-67,-29)
			spawn(tree,Vector3(x,height_at(x,z),z),rng.randf_range(1.1,1.75),rng.randf()*360)
	for p in [Vector3(-26,0,3),Vector3(-24,0,-18),Vector3(10,0,-30),Vector3(29,0,-41),Vector3(-42,0,-61),Vector3(20,0,-70)]:
		p.y=height_at(p.x,p.z)
		spawn(ASSET+"fir_sapling_medium_0.glb",p,rng.randf_range(1.05,1.35),rng.randf()*360)
	for i in range(95):
		var x := rng.randf_range(-32,33);var z := rng.randf_range(-42,28)
		if absf(x-lane_x(z))<4.5 or absf(z+19-sin(x*.04)*2)<4:continue
		if x>-20 and x<-6 and z>-7 and z<6:continue
		spawn(ASSET+"shrub_02_"+str(i%4)+".glb",Vector3(x,height_at(x,z),z),rng.randf_range(.4,.85),rng.randf()*360)

func create_clutter() -> void:
	var rubble_mesh := SphereMesh.new();rubble_mesh.radius=.5;rubble_mesh.height=1;rubble_mesh.radial_segments=6;rubble_mesh.rings=3
	for i in range(640):
		var x := rng.randf_range(-31,33);var z := rng.randf_range(-33,25)
		var lane := absf(x-lane_x(z))
		if lane<1.1 and rng.randf()<.8:continue
		var s := rng.randf_range(.09,.35)
		if rng.randf()<.07:s*=2.2
		var mi := add_mesh(rubble_mesh,mats["stone"] if i%3 else mats["brick"],Vector3(x,height_at(x,z)+s*.25,z),Vector3(s*1.2,s*.7,s),rng.randf()*TAU)
		mi.rotation.x=rng.randf()*.7
	# Telegraph poles define the road corridor and connect foreground to town.
	for x in [-41.0,-17.0,13.0,39.0,65.0]:
		var z := -24+sin(x*.04)*2;var y := height_at(x,z)
		rod(Vector3(x,y,z),Vector3(x,y+8,z),.095,"wood")
		rod(Vector3(x-1.25,y+6.8,z),Vector3(x+1.25,y+6.8,z),.075,"wood")
		for dx in [-1.0,-.45,.45,1.0]:rod(Vector3(x+dx,y+6.8,z),Vector3(x+dx,y+7.05,z),.055,"glass")
	# Foreground wooden fence with irregular missing slats.
	for x in range(11,17):
		if x%5==0:continue
		var y := height_at(x,4)
		var mi := block(Vector3(x,y+.8,4),Vector3(.18,1.65,.085),"wood");mi.rotation.z=rng.randf_range(-.16,.16)
	rod(Vector3(10,height_at(10,4)+.45,4),Vector3(17,height_at(17,4)+.45,4),.055,"wood")
	for row in range(3):
		for i in range(6):
			var mesh := SphereMesh.new();mesh.radius=.5;mesh.height=1;mesh.radial_segments=12;mesh.rings=6
			add_mesh(mesh,mats["sandbag"],Vector3(10+i*.66,height_at(10+i*.66,7)+1.1+row*.28,7),Vector3(.75,.33,.45),rng.randf_range(-.1,.1))
	for pos in [Vector3(20,0,21),Vector3(24,0,19)]:
		pos.y=height_at(pos.x,pos.z)+.48
		var barrel := CylinderMesh.new();barrel.top_radius=.33;barrel.bottom_radius=.33;barrel.height=.96;barrel.radial_segments=16
		add_mesh(barrel,mats["rust"],pos)
	for i in range(110):
		var x:=rng.randf_range(-19,18);var z:=rng.randf_range(-22,21)
		if absf(x-lane_x(z))<1.0:continue
		spawn(ASSET+"rock_moss_set_01_"+str(i%6)+".glb",Vector3(x,height_at(x,z)-.03,z),rng.randf_range(.10,.30),rng.randf()*360)
	var barrel:=spawn(ASSET+"barrel_03_0.glb",Vector3(10.5,height_at(10.5,10)+.3,10),1.0,20)
	barrel.rotation.z=1.2
	spawn(ASSET+"barrel_03_0.glb",Vector3(12,height_at(12,6),6),1.0,-30)
	spawn(ASSET+"wooden_military_crate.glb",Vector3(11,height_at(11,8)+.12,8),1.0,12)
	for i in range(8):
		var plank:=block(Vector3(9.6+rng.randf(),height_at(10,8)+.35,8.4+rng.randf()),Vector3(.17,.09,1.9),"wood")
		plank.rotation=Vector3(rng.randf_range(-.5,.5),rng.randf_range(-.5,.5),rng.randf_range(-.3,.3))

func create_background() -> void:
	for i in range(19):
		var x := -84+(i%7)*25+rng.randf_range(-5,5)
		var z := -121-floori(i/7.0)*29+rng.randf_range(-8,8)
		spawn(ASSET+"house_intact.glb",Vector3(x,height_at(x,z),z),rng.randf_range(.7,1.05),rng.randf_range(-20,25),true)
	var church := spawn("res://assets/golden_scene/city_real/church_landmark.glb",Vector3(-36,height_at(-36,-135),-135),1.0,0)
	# Rebind the imported untextured church by its authored material names.
	for child: Node in church.find_children("*","MeshInstance3D",true,false):
		var mi := child as MeshInstance3D
		for i in range(mi.mesh.get_surface_count()):
			var m := mi.get_active_material(i)
			var key: String = m.resource_name.to_lower() if m!=null else ""
			mi.set_surface_override_material(i,mats["roof"] if "roof" in key else mats["stone"])
	for i in range(60):
		var x := rng.randf_range(-150,150);var z := rng.randf_range(-260,-60)
		if z>-115 and z<-84:continue
		var tree := ASSET+"fir_sapling_medium_"+str(i%3)+".glb"
		spawn(tree,Vector3(x,height_at(x,z),z),rng.randf_range(.9,2.0),rng.randf()*360)
	create_distant_forest()

func create_distant_forest() -> void:
	var file := ASSET+"impostors/manifest.json"
	if not FileAccess.file_exists(file):return
	var records: Array=JSON.parse_string(FileAccess.get_file_as_string(file))
	for variant in range(records.size()):
		var record:Dictionary=records[variant]
		var mat:=StandardMaterial3D.new();mat.albedo_texture=load(record["file"])
		mat.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR;mat.alpha_scissor_threshold=.10
		mat.cull_mode=BaseMaterial3D.CULL_DISABLED;mat.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.billboard_mode=BaseMaterial3D.BILLBOARD_FIXED_Y
		mat.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
		var quad:=QuadMesh.new();quad.size=Vector2.ONE*float(record["size"]);quad.material=mat
		var mm:=MultiMesh.new();mm.transform_format=MultiMesh.TRANSFORM_3D;mm.mesh=quad
		var transforms:Array[Transform3D]=[]
		for i in range(520 if variant<6 else 2100):
			var x:=rng.randf_range(-345,345);var z:=rng.randf_range(-650,-80)
			if z>-115 and z<-82:continue
			var s:=rng.randf_range(1.1,2.0)
			if variant>=6:s*=1.7
			if noise.get_noise_2d(x*.8,z*.8)<-.2:continue
			transforms.append(Transform3D(Basis.IDENTITY.scaled(Vector3.ONE*s),Vector3(x,height_at(x,z)+float(record["center_y"])*s,z)))
		mm.instance_count=transforms.size()
		for i in range(transforms.size()):mm.set_instance_transform(i,transforms[i])
		var inst:=MultiMeshInstance3D.new();inst.multimesh=mm;inst.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(inst)

func create_water() -> void:
	var water := simple(Color(.065,.056,.039),.09);water.metallic=.0;water.metallic_specular=.85
	var plane := PlaneMesh.new();plane.size=Vector2(350,40)
	add_mesh(plane,water,Vector3(0,1.15,-100))
	# Bridge deck, girders, pier heads, abutments and open metal balustrades.
	block(Vector3(35,3.35,-100),Vector3(8.0,.65,57),"stone")
	for z in [-120.0,-107.0,-94.0,-81.0]:
		for x in [32.0,38.0]:block(Vector3(x,1.3,z),Vector3(.95,4.3,1.35),"stone")
	for x in [31.15,38.85]:
		rod(Vector3(x,4.5,-128),Vector3(x,4.5,-72),.08,"metal")
		rod(Vector3(x,3.9,-128),Vector3(x,3.9,-72),.065,"metal")
		for z in range(-128,-71,2):rod(Vector3(x,3.55,z),Vector3(x,4.5,z),.055,"metal")
	# Small still puddles sit inside ruts and inherit environment reflection.
	for i in range(23):
		var z := rng.randf_range(-8,25);var x := lane_x(z)+(1.3 if i%2 else -1.3)
		var st := SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
		var points: Array[Vector3] = []
		var width := rng.randf_range(.35,.80);var length := rng.randf_range(.4,1.65)
		for j in range(18):
			var angle := TAU*j/18.0;var radius := rng.randf_range(.75,1.15)
			points.append(Vector3(cos(angle)*width*radius,0,sin(angle)*length*radius))
		for j in range(18):
			for v in [Vector3.ZERO,points[j],points[(j+1)%18]]:
				st.set_normal(Vector3.UP);st.add_vertex(v)
		var puddle:=add_mesh(st.commit(),water,Vector3(x,height_at(x,z)+.20,z))
		puddle.layers=2

func create_smoke() -> void:
	var volume := NoiseTexture3D.new()
	volume.width=64;volume.height=64;volume.depth=64
	volume.seamless=true
	var source := FastNoiseLite.new();source.seed=876;source.frequency=.075;source.fractal_octaves=4
	volume.noise=source
	for item in [[Vector3(-14,0,-77),Vector3(20,39,20)],[Vector3(32,0,-160),Vector3(28,56,26)],[Vector3(-70,0,-195),Vector3(24,49,24)]]:
		var pos: Vector3=item[0];var size3: Vector3=item[1]
		var fog := FogVolume.new();fog.size=size3
		var mat := ShaderMaterial.new();mat.shader=load("res://scripts/production/visual_slice_smoke.gdshader")
		mat.set_shader_parameter("volume_noise",volume)
		fog.material=mat
		fog.position=Vector3(pos.x,height_at(pos.x,pos.z)+size3.y*.44,pos.z)
		add_child(fog)

func _process(delta: float) -> void:
	frames += 1
	if frames>12:times.append(delta*1000.0)
	if capture_pending and frames==36:
		capture_pending=false
		capture()

func capture() -> void:
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(OUT)
	var image := get_viewport().get_texture().get_image()
	var path := OUT+"/river_town_actual_1920x1080.png"
	var err := image.save_png(path)
	var avg := 0.0
	for value in times:avg+=value/maxi(times.size(),1)
	var report := {"captured_at_utc":Time.get_datetime_string_from_system(true),"engine":Engine.get_version_info(),"renderer":RenderingServer.get_current_rendering_method(),"gpu":RenderingServer.get_video_adapter_name(),"width":image.get_width(),"height":image.get_height(),"save_error":err,"camera_position":str(camera.position),"camera_rotation":str(camera.rotation_degrees),"fov":camera.fov,"internal_3d_render_scale":get_viewport().scaling_3d_scale,"average_frame_ms_short_capture":avg,"sample_count":times.size(),"screenshot_source":"Viewport.get_texture().get_image() after frame_post_draw","post_capture_image_editing":false,"gameplay_changes":false,"visual_acceptance":"NOT_CLAIMED"}
	FileAccess.open(OUT+"/runtime_metrics.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("FRONTLINE_RIVER_TOWN_CAPTURED ",path," ",image.get_size()," average_ms=",avg)
	get_tree().quit(err)
