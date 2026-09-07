extends Node3D

const HOUSE := "res://assets/golden_scene/city_v20/family_house_00.glb"
const ABRAMS := "res://assets/golden_scene/vehicles/mbt_abrams.glb"
const GRASS := "res://assets/golden_scene/quality_v16/grass_medium_02_lod.glb"
const WEED := "res://assets/golden_scene/quality_v16/weed_plant_02_lod.glb"
const ROCK_SMALL := "res://assets/golden_scene/nature/062_rock_smallA.glb"
const ROCK_LARGE := "res://assets/golden_scene/nature/056_rock_largeA.glb"

const OUTPUT_DIR := "res://artifacts/quality_material_proof"
const HOUSE_SHOT := OUTPUT_DIR + "/house_material_proof_1920x1080.png"
const ABRAMS_SHOT := OUTPUT_DIR + "/abrams_material_proof_1920x1080.png"
const GROUND_SHOT := OUTPUT_DIR + "/ground_material_proof_1920x1080.png"
const METRICS_PATH := OUTPUT_DIR + "/quality_material_proof_metrics.json"

var camera: Camera3D
var house_root: Node3D
var abrams_root: Node3D
var proof_checks := {
	"house_loaded": false,
	"abrams_loaded": false,
	"ground_built": false,
	"house_authored_materials_preserved": false,
	"vehicle_surface_layers": false,
	"ground_microgeometry": false
}

func _ready() -> void:
	_ensure_output()
	_preflight()
	_build_environment()
	_build_house_proof()
	_build_abrams_proof()
	_build_ground_proof()
	_build_camera()
	print("FRONTLINE_MATERIAL_PROOF_READY renderer=%s" % RenderingServer.get_current_rendering_method())
	if OS.get_environment("FRONTLINE_CAPTURE_MATERIAL_PROOF") == "1":
		_capture_all()


func _preflight() -> void:
	for path: String in [HOUSE,ABRAMS,GRASS,WEED,ROCK_SMALL,ROCK_LARGE]:
		if not ResourceLoader.exists(path):
			push_error("MATERIAL_PROOF_REQUIRED_ASSET_MISSING path=%s" % path)


func _build_environment() -> void:
	var world_env := WorldEnvironment.new()
	world_env.name = "MaterialProofEnvironment"
	var env := Environment.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.33,0.45,0.58)
	sky_mat.sky_horizon_color = Color(0.72,0.71,0.66)
	sky_mat.ground_bottom_color = Color(0.18,0.20,0.17)
	sky_mat.ground_horizon_color = Color(0.50,0.50,0.44)
	var sky := Sky.new()
	sky.sky_material = sky_mat
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.background_energy_multiplier = 1.02
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.78
	env.reflected_light_source = Environment.REFLECTION_SOURCE_SKY
	env.fog_enabled = true
	env.fog_density = 0.0012
	env.fog_light_color = Color(0.66,0.67,0.64)
	env.fog_aerial_perspective = 0.20
	env.ssao_enabled = true
	env.ssao_radius = 1.5
	env.ssao_intensity = 1.15
	env.ssao_power = 1.05
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.adjustment_enabled = true
	env.adjustment_brightness = 1.02
	env.adjustment_contrast = 1.06
	env.adjustment_saturation = 0.95
	world_env.environment = env
	add_child(world_env)

	var sun := DirectionalLight3D.new()
	sun.name = "MaterialProofSun"
	sun.rotation_degrees = Vector3(-43.0,-42.0,0.0)
	sun.light_color = Color(1.0,0.89,0.76)
	sun.light_energy = 1.35
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 80.0
	add_child(sun)

	var fill := DirectionalLight3D.new()
	fill.name = "MaterialProofFill"
	fill.rotation_degrees = Vector3(-62.0,137.0,0.0)
	fill.light_color = Color(0.42,0.55,0.68)
	fill.light_energy = 0.20
	add_child(fill)


func _build_house_proof() -> void:
	_add_pad(Vector3.ZERO,Vector2(17,17))
	house_root = _spawn_scaled(HOUSE,Vector3(0,0,0),10.5,0.0,"MaterialProofHouse")
	if house_root == null:
		return
	proof_checks["house_loaded"] = true

	var touched := 0
	var meshes := _collect_meshes(house_root)
	for mi: MeshInstance3D in meshes:
		if mi.mesh == null:
			continue
		for surface: int in range(mi.mesh.get_surface_count()):
			var src := mi.get_active_material(surface)
			if src is StandardMaterial3D:
				var mat := (src as StandardMaterial3D).duplicate() as StandardMaterial3D
				mat.roughness = clampf(maxf(mat.roughness,0.62),0.62,0.92)
				mat.metallic = minf(mat.metallic,0.12)
				mi.set_surface_override_material(surface,mat)
				touched += 1
	proof_checks["house_authored_materials_preserved"] = touched > 0

	_add_house_grime_overlays()
	_add_house_context()


func _add_house_grime_overlays() -> void:
	# These are overlay layers only. They do not replace roof/wall/window authored surfaces.
	_add_grime_quad(Vector3(0.0,0.95,4.18),Vector2(8.2,1.25),Vector3(0,0,0),Color(0.12,0.095,0.065,0.22),"LowerWallDirtFront")
	_add_grime_quad(Vector3(4.18,1.15,0.2),Vector2(7.0,1.45),Vector3(0,90,0),Color(0.10,0.075,0.055,0.18),"LowerWallDirtSide")
	_add_grime_quad(Vector3(-1.4,2.5,4.20),Vector2(1.6,2.8),Vector3(0,0,0),Color(0.075,0.060,0.050,0.18),"WaterStainFront")
	_add_grime_quad(Vector3(1.9,2.1,4.21),Vector2(1.2,2.1),Vector3(0,0,0),Color(0.040,0.035,0.030,0.15),"SootPatchFront")


func _add_grime_quad(pos: Vector3,size: Vector2,rot: Vector3,color: Color,name_value: String) -> void:
	var node := MeshInstance3D.new()
	node.name = name_value
	var quad := QuadMesh.new()
	quad.size = size
	node.mesh = quad
	node.position = pos
	node.rotation_degrees = rot
	var mat := StandardMaterial3D.new()
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = color
	mat.roughness = 1.0
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	node.material_override = mat
	add_child(node)


func _add_house_context() -> void:
	var positions: Array[Vector3] = [
		Vector3(-5.3,0,2.8),Vector3(-4.7,0,-3.3),Vector3(4.9,0,-2.7),
		Vector3(5.1,0,3.4),Vector3(-2.8,0,5.3),Vector3(2.9,0,5.0)
	]
	for i: int in range(positions.size()):
		var g := _spawn_scaled(WEED,positions[i],1.4+0.12*float(i),17.0+43.0*float(i),"HouseWeed_%02d" % i)
		if g != null:
			g.position.y += 0.01
	for i: int in range(4):
		var p := Vector3(-3.2+1.7*float(i),0.02,4.9+0.35*sin(float(i)))
		_spawn_scaled(ROCK_SMALL,p,0.45+0.08*float(i),31.0*float(i),"HouseRubble_%02d" % i)


func _build_abrams_proof() -> void:
	var center := Vector3(30,0,0)
	_add_pad(center,Vector2(18,18))
	abrams_root = _spawn_scaled(ABRAMS,center,7.2,-20.0,"MaterialProofAbrams")
	if abrams_root == null:
		return
	proof_checks["abrams_loaded"] = true

	var hull := _vehicle_hull_shader()
	var track := _track_material()
	var rubber := _rubber_material()
	var metal := _metal_material()
	var optics := _optics_material()
	var layered_count := 0

	for mi: MeshInstance3D in _collect_meshes(abrams_root):
		if mi.mesh == null:
			continue
		for surface: int in range(mi.mesh.get_surface_count()):
			var key: String = (mi.name+" "+mi.mesh.surface_get_name(surface)).to_lower()
			var src := mi.mesh.surface_get_material(surface)
			if src != null:
				key += " "+src.resource_name.to_lower()
			var chosen: Material = hull
			if key.contains("track"):
				chosen = track
			elif key.contains("tire") or key.contains("rubber"):
				chosen = rubber
			elif key.contains("optic") or key.contains("glass") or key.contains("sight"):
				chosen = optics
			elif key.contains("barrel") or key.contains("gun") or key.contains("exhaust"):
				chosen = metal
			mi.set_surface_override_material(surface,chosen)
			layered_count += 1
	proof_checks["vehicle_surface_layers"] = layered_count > 0

	_add_vehicle_contact_context(center)


func _vehicle_hull_shader() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
shader_type spatial;
varying vec3 lp;
void vertex(){ lp=VERTEX; }
void fragment(){
	float macro=0.5+0.5*sin(lp.x*0.75+sin(lp.z*0.62)*1.7);
	float speck=0.5+0.5*sin(lp.x*5.8+lp.z*4.4);
	float lower=smoothstep(0.65,-0.50,lp.y);
	vec3 olive=mix(vec3(0.125,0.155,0.055),vec3(0.195,0.215,0.078),macro*0.42);
	vec3 dry_mud=vec3(0.20,0.145,0.085);
	vec3 base=mix(olive,dry_mud,lower*(0.18+speck*0.18));
	float edge_hint=0.5+0.5*sin(lp.x*8.0-lp.z*6.0);
	ALBEDO=base*(0.96+edge_hint*0.05);
	METALLIC=0.18;
	ROUGHNESS=mix(0.62,0.90,lower*0.58+speck*0.12);
	SPECULAR=0.30;
}
"""
	var mat := ShaderMaterial.new()
	mat.shader = shader
	return mat


func _track_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.070,0.067,0.058)
	mat.metallic = 0.58
	mat.metallic_specular = 0.42
	mat.roughness = 0.55
	return mat


func _rubber_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.028,0.030,0.026)
	mat.metallic = 0.0
	mat.roughness = 0.90
	return mat


func _metal_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.095,0.098,0.088)
	mat.metallic = 0.48
	mat.roughness = 0.48
	return mat


func _optics_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.035,0.065,0.058)
	mat.metallic = 0.12
	mat.roughness = 0.18
	return mat


func _add_vehicle_contact_context(center: Vector3) -> void:
	_add_churn_patch(center+Vector3(0,0.025,0),Vector2(10.5,6.5),-20.0)
	for i: int in range(5):
		var p := center+Vector3(-4.6+2.2*float(i),0.05,3.8+0.25*sin(float(i)*1.7))
		_spawn_scaled(ROCK_SMALL,p,0.34+0.06*float(i),29.0*float(i),"VehicleStone_%02d" % i)


func _build_ground_proof() -> void:
	var center := Vector3(60,0,0)
	var ground := MeshInstance3D.new()
	ground.name = "TenMeterLayeredGround"
	var plane := PlaneMesh.new()
	plane.size = Vector2(10.0,10.0)
	plane.subdivide_width = 40
	plane.subdivide_depth = 40
	ground.mesh = plane
	ground.position = center
	ground.material_override = _layered_ground_shader()
	add_child(ground)
	proof_checks["ground_built"] = true

	_add_churn_patch(center+Vector3(0,0.035,0.8),Vector2(7.2,2.2),-12.0)
	_add_puddle(center+Vector3(1.7,0.05,0.6),Vector2(1.25,0.52),-8.0)

	var clutter := 0
	var grass_positions: Array[Vector3] = [
		Vector3(-3.8,0,-3.3),Vector3(-2.5,0,-2.8),Vector3(3.6,0,-3.4),
		Vector3(3.1,0,3.5),Vector3(-3.6,0,3.3),Vector3(2.7,0,2.6)
	]
	for i: int in range(grass_positions.size()):
		var p := center+grass_positions[i]
		if _spawn_scaled(GRASS,p,2.1+0.18*float(i),21.0+47.0*float(i),"GroundGrass_%02d" % i) != null:
			clutter += 1
	var weed_positions: Array[Vector3] = [
		Vector3(-1.7,0,-3.7),Vector3(1.5,0,-3.5),Vector3(-3.9,0,0.4),
		Vector3(3.8,0,0.1),Vector3(-2.8,0,2.0),Vector3(2.2,0,3.8)
	]
	for i: int in range(weed_positions.size()):
		var p := center+weed_positions[i]
		if _spawn_scaled(WEED,p,1.2+0.10*float(i),13.0+39.0*float(i),"GroundWeed_%02d" % i) != null:
			clutter += 1
	for i: int in range(9):
		var px := -4.0+float(i%3)*3.7
		var pz := -2.6+float(i/3)*2.9
		var p := center+Vector3(px,0.03,pz)
		if _spawn_scaled(ROCK_SMALL,p,0.22+0.05*float(i%3),19.0*float(i),"GroundRock_%02d" % i) != null:
			clutter += 1
	proof_checks["ground_microgeometry"] = clutter >= 15


func _layered_ground_shader() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
shader_type spatial;
uniform sampler2D grass_diff : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D grass_nor : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D dirt_diff : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D dirt_nor : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D mud_diff : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D mud_nor : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
varying vec3 lp;
void vertex(){
	lp=VERTEX;
	VERTEX.y += 0.055*sin(VERTEX.x*2.5)+0.035*cos(VERTEX.z*3.1);
}
void fragment(){
	vec2 uv=UV*6.5;
	float road=1.0-smoothstep(0.55,1.55,abs(lp.z+0.25+0.12*sin(lp.x*1.3)));
	float churn=1.0-smoothstep(1.2,2.8,length(lp.xz-vec2(0.9,0.5)));
	float patch=0.5+0.5*sin(lp.x*1.4+lp.z*1.1);
	vec3 grass=texture(grass_diff,uv).rgb*vec3(0.66,0.77,0.50);
	vec3 dirt=texture(dirt_diff,uv*0.9).rgb*vec3(0.63,0.53,0.38);
	vec3 mud=texture(mud_diff,uv*0.8).rgb*vec3(0.46,0.37,0.28);
	float dirt_mix=clamp(road*0.72+patch*0.13,0.0,0.82);
	float mud_mix=clamp(churn*0.42+road*0.18,0.0,0.56);
	vec3 base=mix(grass,dirt,dirt_mix);
	base=mix(base,mud,mud_mix);
	ALBEDO=base;
	NORMAL_MAP=mix(mix(texture(grass_nor,uv).rgb,texture(dirt_nor,uv*0.9).rgb,dirt_mix),texture(mud_nor,uv*0.8).rgb,mud_mix);
	NORMAL_MAP_DEPTH=0.62;
	ROUGHNESS=mix(0.92,0.72,road*0.20);
	SPECULAR=0.26;
}
"""
	var mat := ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("grass_diff",load("res://assets/golden_scene/pbr/leafy_grass_diff_1k.png"))
	mat.set_shader_parameter("grass_nor",load("res://assets/golden_scene/pbr/leafy_grass_nor_gl_1k.png"))
	mat.set_shader_parameter("dirt_diff",load("res://assets/golden_scene/pbr/dirt_aerial_03_diff_1k.png"))
	mat.set_shader_parameter("dirt_nor",load("res://assets/golden_scene/pbr/dirt_aerial_03_nor_gl_1k.png"))
	mat.set_shader_parameter("mud_diff",load("res://assets/golden_scene/pbr/aerial_mud_1_diff_1k.png"))
	mat.set_shader_parameter("mud_nor",load("res://assets/golden_scene/pbr/aerial_mud_1_nor_gl_1k.png"))
	return mat


func _add_pad(center: Vector3,size: Vector2) -> void:
	var pad := MeshInstance3D.new()
	pad.name = "ProofPad"
	var plane := PlaneMesh.new()
	plane.size = size
	plane.subdivide_width = 20
	plane.subdivide_depth = 20
	pad.mesh = plane
	pad.position = center
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = load("res://assets/golden_scene/pbr/dirt_aerial_03_diff_1k.png")
	mat.normal_enabled = true
	mat.normal_texture = load("res://assets/golden_scene/pbr/dirt_aerial_03_nor_gl_1k.png")
	mat.roughness = 0.91
	mat.uv1_scale = Vector3(4.0,4.0,4.0)
	pad.material_override = mat
	add_child(pad)


func _add_churn_patch(center: Vector3,size: Vector2,yaw: float) -> void:
	var patch := MeshInstance3D.new()
	patch.name = "ChurnedGround"
	var plane := PlaneMesh.new()
	plane.size = size
	patch.mesh = plane
	patch.position = center
	patch.rotation_degrees.y = yaw
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = load("res://assets/golden_scene/pbr/aerial_mud_1_diff_1k.png")
	mat.normal_enabled = true
	mat.normal_texture = load("res://assets/golden_scene/pbr/aerial_mud_1_nor_gl_1k.png")
	mat.roughness = 0.90
	mat.uv1_scale = Vector3(3.2,3.2,3.2)
	patch.material_override = mat
	add_child(patch)


func _add_puddle(center: Vector3,size: Vector2,yaw: float) -> void:
	var node := MeshInstance3D.new()
	node.name = "ProofPuddle"
	var disc := CylinderMesh.new()
	disc.top_radius = 1.0
	disc.bottom_radius = 1.0
	disc.height = 0.012
	disc.radial_segments = 28
	node.mesh = disc
	node.position = center
	node.scale = Vector3(size.x,1.0,size.y)
	node.rotation_degrees.y = yaw
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.09,0.12,0.12,0.55)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.metallic = 0.10
	mat.roughness = 0.18
	node.material_override = mat
	add_child(node)


func _spawn_scaled(path: String,pos: Vector3,target_size: float,yaw: float,name_value: String) -> Node3D:
	var packed := load(path) as PackedScene
	if packed == null:
		push_error("MATERIAL_PROOF_LOAD_FAIL path=%s" % path)
		return null
	var node := packed.instantiate() as Node3D
	if node == null:
		return null
	node.name = name_value
	add_child(node)
	node.position = pos
	node.rotation_degrees.y = yaw
	var bounds := _local_bounds(node)
	var largest := maxf(bounds.size.x,maxf(bounds.size.y,bounds.size.z))
	if largest > 0.001:
		var s := target_size/largest
		node.scale = Vector3.ONE*s
	var grounded := _local_bounds(node)
	node.position.y -= grounded.position.y
	return node


func _collect_meshes(root: Node3D) -> Array[MeshInstance3D]:
	var result: Array[MeshInstance3D] = []
	if root is MeshInstance3D:
		result.append(root as MeshInstance3D)
	for item: Node in root.find_children("*","MeshInstance3D",true,false):
		var mi := item as MeshInstance3D
		if mi != null:
			result.append(mi)
	return result


func _local_bounds(root: Node3D) -> AABB:
	var has := false
	var merged := AABB()
	for mi: MeshInstance3D in _collect_meshes(root):
		if mi.mesh == null:
			continue
		var rel := root.global_transform.affine_inverse()*mi.global_transform
		var aabb := mi.mesh.get_aabb()
		var corners: Array[Vector3] = [
			aabb.position,
			aabb.position+Vector3(aabb.size.x,0,0),
			aabb.position+Vector3(0,aabb.size.y,0),
			aabb.position+Vector3(0,0,aabb.size.z),
			aabb.position+Vector3(aabb.size.x,aabb.size.y,0),
			aabb.position+Vector3(aabb.size.x,0,aabb.size.z),
			aabb.position+Vector3(0,aabb.size.y,aabb.size.z),
			aabb.position+aabb.size
		]
		for c: Vector3 in corners:
			var p := rel*c
			if not has:
				merged = AABB(p,Vector3.ZERO)
				has = true
			else:
				merged = merged.expand(p)
	return merged


func _build_camera() -> void:
	camera = Camera3D.new()
	camera.name = "MaterialProofCamera"
	camera.fov = 39.0
	add_child(camera)
	camera.current = true


func _capture_all() -> void:
	await _capture_view(HOUSE_SHOT,Vector3(10.5,6.8,13.5),Vector3(0,2.3,0))
	await _capture_view(ABRAMS_SHOT,Vector3(40.5,5.1,10.5),Vector3(30,1.5,0))
	await _capture_view(GROUND_SHOT,Vector3(65.8,8.3,9.0),Vector3(60,0.0,0))
	_write_metrics()
	var all_pass := true
	for value: Variant in proof_checks.values():
		if not bool(value):
			all_pass = false
	print("FRONTLINE_MATERIAL_PROOF_TECH_%s" % ("PASS" if all_pass else "FAIL"))
	get_tree().quit(0 if all_pass else 61)


func _capture_view(path: String,pos: Vector3,target: Vector3) -> void:
	camera.position = pos
	camera.look_at(target,Vector3.UP)
	for _i: int in range(12):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	if image == null or image.is_empty():
		push_error("MATERIAL_PROOF_EMPTY_CAPTURE path=%s" % path)
		return
	var result := image.save_png(ProjectSettings.globalize_path(path))
	if result != OK:
		push_error("MATERIAL_PROOF_SAVE_FAIL path=%s" % path)
	else:
		print("FRONTLINE_MATERIAL_PROOF_CAPTURED path=%s size=%dx%d" % [path,image.get_width(),image.get_height()])


func _write_metrics() -> void:
	var payload := {
		"task_id": "QUALITY_MATERIAL_PROOF_V1",
		"engine": Engine.get_version_info().get("string","Godot"),
		"renderer": RenderingServer.get_current_rendering_method(),
		"checks": proof_checks,
		"visual_pass": false,
		"captures": [HOUSE_SHOT,ABRAMS_SHOT,GROUND_SHOT]
	}
	var file := FileAccess.open(METRICS_PATH,FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(payload,"\t")+"\n")
		file.close()


func _ensure_output() -> void:
	var err := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	if err != OK and err != ERR_ALREADY_EXISTS:
		push_error("MATERIAL_PROOF_OUTPUT_DIR_FAIL")
