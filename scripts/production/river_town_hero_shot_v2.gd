extends "res://scripts/production/river_town_visual_slice.gd"
## Independent authored local composition. The comparison scene is never edited.
var hero_building: Node3D
var hero_tank: Node3D
var detail_random:=RandomNumberGenerator.new()
var rubble_displacement:Image

func _ready() -> void:
	super._ready()
	capture_view="hero_v2"
	if capture_label=="local_high_fidelity":capture_label="hero_v2_01"
	camera.name="HeroShotV2Camera"
	camera.position=Vector3(15,12,21)
	camera.look_at(Vector3(-4,.4,-2))
	camera.fov=40
	# Tight elevated local composition: the reference direction concerns the
	# relationship between ground, vegetation, architecture and vehicles.
	for child in get_children():
		if child is DirectionalLight3D:
			child.rotation_degrees=Vector3(-32,22,0)
			child.light_color=Color(1.,.89,.73)
		if child is WorldEnvironment:
			child.environment.ambient_light_color=Color(.58,.68,.82)
	print("HERO_V2_READY scene=res://scenes/production/RiverTownHeroShotV2.tscn")

func base_height_at(x:float,z:float)->float:
	var existing:=super.base_height_at(x,z)
	# A raised farmstead apron, subsided verge and real collapse piles define space.
	var apron:=.34*exp(-pow((x+10)/8.,4.)-pow((z+7)/7.,4.))
	var collapse:=.68*exp(-pow((x+4.1)/2.5,2.)-pow((z+.6)/3.6,2.))
	var verge:=.21*exp(-pow((x-8.8)/1.8,2.)-pow((z-5.)/13.,2.))
	return existing+apron+collapse+verge

func create_architecture()->void:
	hero_building=spawn(ASSET+"hero_v2/urban_ruin/urban_ruin.gltf",Vector3(-9,height_at(-9,-5)-.12,-5),1.,8)
	hero_building.name="UrbanCornerRuinV2"
	for child in hero_building.find_children("*","MeshInstance3D",true,false):
		var mi:=child as MeshInstance3D
		for i in range(mi.mesh.get_surface_count()):
			var original:=mi.get_active_material(i) as StandardMaterial3D
			if original==null:continue
			var m:=original.duplicate() as StandardMaterial3D
			m.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
			if "charred" in original.resource_name.to_lower():m.albedo_color=Color(.34,.29,.23)
			mi.set_surface_override_material(i,m)
	spawn(ASSET+"house_intact.glb",Vector3(-18,height_at(-18,-39),-39),.92,22,true)
	spawn(ASSET+"house_damaged.glb",Vector3(10,height_at(10,-52),-52),.86,-14,true)
	spawn(ASSET+"house_intact.glb",Vector3(36,height_at(36,-67),-67),.8,28,true)

func create_smoke()->void:
	super.create_smoke()
	for child in get_children():
		if child is FogVolume:
			var local_smoke:=FogVolume.new()
			local_smoke.name="SmoulderingMidgroundVolume"
			local_smoke.size=Vector3(8,13,8)
			local_smoke.position=Vector3(-8,height_at(-8,-18)+5.8,-18)
			local_smoke.material=child.material.duplicate()
			local_smoke.material.set_shader_parameter("opacity",.065)
			add_child(local_smoke)
			break

func create_armor()->void:
	hero_tank=spawn(ASSET+"hero_v2/abrams_v2.glb",Vector3(2.5,height_at(2.5,7)+.035,7),1.0,145)
	hero_tank.name="AbramsV2_AuthoredMaterialSurfaces"
	# Respect the source atlas and separate its actual authored surfaces.
	# The prior global noise/dust shader is not applied to this asset.
	for child in hero_tank.find_children("*","MeshInstance3D",true,false):
		var mi:=child as MeshInstance3D
		for i in range(mi.mesh.get_surface_count()):
			var original:=mi.get_active_material(i) as StandardMaterial3D
			if original==null:continue
			var m:=original.duplicate() as StandardMaterial3D
			var key:=original.resource_name.to_lower()
			m.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
			m.clearcoat_enabled=false
			# The source G channel is near zero. Separate dielectric coats and bare
			# steel explicitly; the original albedo atlases remain intact.
			if "rubber" in key:
				m.metallic=0.;m.roughness_texture=null;m.roughness=.91;m.albedo_color=Color(.32,.35,.35)
			elif "exposedsteel" in key:
				m.metallic=.8;m.roughness=.36
			elif "gear" in key or "metal_wheels" in key or "radiator" in key:
				m.metallic=.85;m.roughness_texture=null;m.roughness=.36;m.albedo_color=Color(.52,.55,.58)
			elif key=="light":
				m.metallic=.35;m.roughness_texture=null;m.roughness=.10;m.clearcoat_enabled=true;m.clearcoat=.8
			else:
				m.metallic=.18;m.roughness_texture=null;m.roughness=.64
				m.albedo_color=Color(.65,.78,.60)
			mi.set_surface_override_material(i,m)
	add_running_gear_mud()

func fragment_mesh(seed_id:int)->ArrayMesh:
	var rr:=RandomNumberGenerator.new();rr.seed=seed_id
	var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var corners:Array[Vector3]=[]
	for z in [-1.,1.]:
		for y in [-1.,1.]:
			for x in [-1.,1.]:corners.append(Vector3(x,y,z)*.5+Vector3(rr.randf_range(-.12,.12),rr.randf_range(-.09,.09),rr.randf_range(-.12,.12)))
	for face in [[0,1,3,2],[4,6,7,5],[0,4,5,1],[2,3,7,6],[0,2,6,4],[1,5,7,3]]:
		for index in [0,1,2,0,2,3]:
			var p:Vector3=corners[face[index]];st.set_uv(Vector2(p.x+p.z,p.y)*.7);st.add_vertex(p)
	st.generate_normals();st.generate_tangents();return st.commit()

func scatter_group(name3:String,mesh:Mesh,material:Material,transforms:Array[Transform3D])->void:
	var mm:=MultiMesh.new();mm.transform_format=MultiMesh.TRANSFORM_3D;mm.mesh=mesh;mm.instance_count=transforms.size()
	for i in range(transforms.size()):mm.set_instance_transform(i,transforms[i])
	var inst:=MultiMeshInstance3D.new();inst.name=name3;inst.multimesh=mm;inst.material_override=material;add_child(inst)

func add_running_gear_mud()->void:
	var mud:=surface("aerial_mud_1",Color(.16,.125,.075));mud.roughness=.72
	var random3:=RandomNumberGenerator.new();random3.seed=88212
	var transforms:Array[Transform3D]=[]
	for i in range(170):
		var side:=1. if i%2==0 else -1.
		var p:=Vector3(side*1.73,random3.randf_range(.20,.63),random3.randf_range(-2.85,2.7))
		var s:=Vector3(random3.randf_range(.05,.17),random3.randf_range(.05,.15),random3.randf_range(.08,.24))
		transforms.append(hero_tank.global_transform*Transform3D(Basis.from_euler(Vector3(random3.randf(),random3.randf(),random3.randf())).scaled(s),p))
	scatter_group("Adhered mud between running gear",fragment_mesh(12),mud,transforms)

func create_clutter()->void:
	detail_random.seed=992712
	rubble_displacement=(load(ASSET+"hero_v2/rubble_height.jpg") as Texture2D).get_image()
	if rubble_displacement.is_compressed():rubble_displacement.decompress()
	rubble_displacement.resize(512,512,Image.INTERPOLATE_BILINEAR)
	create_rubble_patch(Vector2(-5.4,.8),Vector2(6.0,5.0))
	create_rubble_patch(Vector2(10.,1.5),Vector2(1.8,6.0))
	var stone:=surface("plastered_wall_02",Color(.52,.51,.46),.5)
	stone.albedo_texture=load(ASSET+"hero_v2/stone_diff.jpg");stone.normal_texture=load(ASSET+"hero_v2/stone_normal.jpg")
	var bricks:=surface("brick_wall_005",Color(.53,.38,.27),.4)
	var wood:=surface("wood_planks",Color(.30,.26,.20),.6)
	var drymud:=surface("aerial_mud_1",Color(.31,.24,.155),.6)
	var wetmud:=surface("aerial_mud_1",Color(.23,.185,.12),.6);wetmud.roughness=.74
	# Collapse follows the missing bay. Material pieces have actual thickness.
	for group in range(5):
		var transforms:Array[Transform3D]=[]
		for i in range(180 if group<3 else 80):
			var angle:=detail_random.randf()*TAU
			var radius:=pow(detail_random.randf(),.7)*4.8
			var x:float=-4.5+cos(angle)*radius
			var z:float=-.4+sin(angle)*radius*.65
			var size3:=Vector3(detail_random.randf_range(.15,.55),detail_random.randf_range(.10,.32),detail_random.randf_range(.18,.58))
			if group==3:size3*=Vector3(2.4,.7,2.2)
			if group==4:size3=Vector3(.16,.15,detail_random.randf_range(.7,2.8))
			var y:=height_at(x,z)+size3.y*.28
			transforms.append(Transform3D(Basis.from_euler(Vector3(detail_random.randf_range(-.6,.6),detail_random.randf()*TAU,detail_random.randf_range(-.5,.5))).scaled(size3),Vector3(x,y,z)))
		scatter_group("Collapse debris "+str(group),fragment_mesh(81+group),[stone,bricks,stone,stone,wood][group],transforms)
	# Clods are thrown onto the shoulders, with flattened fragments beside tracks.
	for group in range(3):
		var transforms:Array[Transform3D]=[]
		for i in range(330):
			var z:=detail_random.randf_range(-10,24)
			if sin(z*.79+group*2.1)<-.1:continue
			var side:float=-1 if i%2 else 1
			var x:=lane_x(z)+side*detail_random.randf_range(1.8,3.7)
			var size3:=Vector3(detail_random.randf_range(.10,.32),detail_random.randf_range(.055,.16),detail_random.randf_range(.14,.42))
			transforms.append(Transform3D(Basis.from_euler(Vector3(.1,detail_random.randf()*TAU,.12)).scaled(size3),Vector3(x,height_at(x,z)+.035,z)))
		scatter_group("Shoulder mud clods "+str(group),fragment_mesh(127+group),wetmud if group==0 else drymud,transforms)
	# A broken boundary wall is a medium-scale silhouette, not a row of props.
	for row in range(5):
		for i in range(17):
			var z:float=-7+i*.67
			if i>10 and row>maxi(0,14-i):continue
			if i>5 and i<9 and row>1:continue
			var x:=10.3+sin(z*.1)*.4
			var mi:=add_mesh(fragment_mesh(i%4+601),stone,Vector3(x,height_at(x,z)+.18+row*.30,z),Vector3(.54,.30,.65))
			mi.rotation.y=detail_random.randf_range(-.08,.08)
	for i in range(30):
		var x:=9.3+detail_random.randf()*2.5;var z:=detail_random.randf_range(-4,7)
		add_mesh(fragment_mesh(i%4+601),stone,Vector3(x,height_at(x,z)+.1,z),Vector3(.4,.23,.5),detail_random.randf()*TAU)
	# Reuse full textured props only where sheltered by the boundary.
	spawn(ASSET+"wooden_military_crate.glb",Vector3(11.4,height_at(11.4,-1),-1),1.,15)
	spawn(ASSET+"barrel_03_0.glb",Vector3(11,height_at(11,-3),-3),1.,-20)

func rubble_surface_y(p:Vector2,center:Vector2,radius:Vector2)->float:
	var radial:=((p-center)/radius).length()
	var edge:=1.-smoothstep(.55,1.0,radial)
	var uv:=p*.48
	var pixel:=Vector2(fposmod(uv.x,1.),fposmod(uv.y,1.))*512.
	var ix:=floori(pixel.x);var iz:=floori(pixel.y)
	var relief:=lerpf(lerpf(rubble_displacement.get_pixel(ix%512,iz%512).r,rubble_displacement.get_pixel((ix+1)%512,iz%512).r,pixel.x-ix),lerpf(rubble_displacement.get_pixel(ix%512,(iz+1)%512).r,rubble_displacement.get_pixel((ix+1)%512,(iz+1)%512).r,pixel.x-ix),pixel.y-iz)
	return height_at(p.x,p.y)-.045+edge*(.09+relief*.36)

func create_rubble_patch(center:Vector2,radius:Vector2)->void:
	var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var nx:=ceili(radius.x*2./.05)+1;var nz:=ceili(radius.y*2./.05)+1
	for iz in range(nz):
		for ix in range(nx):
			var p:=center-radius+Vector2(float(ix)/(nx-1),float(iz)/(nz-1))*radius*2.
			var normal:=Vector3(rubble_surface_y(p-Vector2(.035,0),center,radius)-rubble_surface_y(p+Vector2(.035,0),center,radius),.07,rubble_surface_y(p-Vector2(0,.035),center,radius)-rubble_surface_y(p+Vector2(0,.035),center,radius)).normalized()
			st.set_normal(normal);st.set_uv(p*.48);st.add_vertex(Vector3(p.x,rubble_surface_y(p,center,radius),p.y))
	for iz in range(nz-1):
		for ix in range(nx-1):
			var a:=iz*nx+ix
			for index in [a,a+1,a+nx,a+1,a+nx+1,a+nx]:st.add_index(index)
	st.generate_tangents()
	var m:=StandardMaterial3D.new();m.albedo_texture=load(ASSET+"hero_v2/rubble_diff.jpg")
	m.albedo_color=Color(.63,.59,.52);m.normal_enabled=true;m.normal_texture=load(ASSET+"hero_v2/rubble_normal.jpg")
	m.normal_scale=.8;m.roughness_texture=load(ASSET+"hero_v2/rubble_rough.jpg")
	m.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	var patch:=add_mesh(st.commit(),m,Vector3.ZERO);patch.name="PhysicalScannedRubbleApron"

func create_vegetation()->void:
	super.create_vegetation()
	# Clear the new occupied footprint by moving plants into the adjoining verge.
	for child in get_children():
		if not child is MultiMeshInstance3D or not child.name.begins_with("grass_"):continue
		var mm:MultiMesh=child.multimesh
		for i in range(mm.instance_count):
			var t:=mm.get_instance_transform(i)
			var local3:=hero_building.to_local(t.origin)
			if absf(local3.x)<4.9 and absf(local3.z)<4.9:
				t.origin.x+=19.;t.origin.y=height_at(t.origin.x,t.origin.z)+.025;mm.set_instance_transform(i,t)
	# Populate the former house exclusion area as an adjoining grass verge.
	var verge_rng:=RandomNumberGenerator.new();verge_rng.seed=71632
	for child in get_children():
		if not child is MultiMeshInstance3D or not child.name.begins_with("grass_"):continue
		var mm:MultiMesh=child.multimesh
		for i in range(mini(3200,mm.instance_count)):
			var t:=mm.get_instance_transform(i)
			var p:=Vector3(verge_rng.randf_range(-20,-4),0,verge_rng.randf_range(3.5,17))
			var lp:=hero_building.to_local(p)
			if absf(lp.x)<4.9 and absf(lp.z)<4.9:continue
			p.y=height_at(p.x,p.z)+.02;t.origin=p;mm.set_instance_transform(i,t)
	# Dense hedgerow mass behind the broken boundary frames the open road.
	for i in range(17):
		var x:=12.4+sin(i*1.73)*1.1;var z:float=-22+i*1.8
		spawn(ASSET+"shrub_02_"+str(i%4)+".glb",Vector3(x,height_at(x,z),z),.85+(i%3)*.12,i*47.)
	for spec in [Vector4(-14.8,5.5,.7,20),Vector4(-13.,9.5,.55,110),Vector4(-17.7,10.,.8,205),Vector4(11.8,8.7,.66,33)]:
		spawn(ASSET+"shrub_02_1.glb",Vector3(spec.x,height_at(spec.x,spec.y),spec.y),spec.z,spec.w)
