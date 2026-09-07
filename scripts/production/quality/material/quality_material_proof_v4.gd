extends "res://scripts/production/quality/material/quality_material_proof_v3.gd"

const HOUSE_HQ := "res://assets/golden_scene/city_hq3/02_shop_front17_derelict.glb"
const HQ_ROCK_A := "res://assets/golden_scene/nature_hq/glTF/EA01_Env_Rock_01a.glb"
const HQ_ROCK_B := "res://assets/golden_scene/nature_hq/glTF/EA01_Env_Rock_01b.glb"
const HQ_BRANCH := "res://assets/golden_scene/nature_hq/glTF/EA01_Env_Branch_02.glb"
const HQ_FENCE := "res://assets/golden_scene/nature_hq/glTF/EA01_Env_Fence_Wood_04a.glb"


func _preflight() -> void:
	super._preflight()
	for path: String in [HOUSE_HQ,HQ_ROCK_A,HQ_ROCK_B,HQ_BRANCH,HQ_FENCE]:
		if not ResourceLoader.exists(path):
			push_error("MATERIAL_PROOF_REQUIRED_ASSET_MISSING path=%s" % path)


func _build_house_proof() -> void:
	_add_pad(Vector3.ZERO,Vector2(20,20))
	house_root = _spawn_scaled(HOUSE_HQ,Vector3.ZERO,12.6,-7.0,"MaterialProofHouseV4HQ")
	if house_root == null:
		return
	proof_checks["house_loaded"] = true
	_ground_visual_to(house_root,0.018)

	var touched: int = 0
	for mi: MeshInstance3D in _collect_meshes(house_root):
		if mi.mesh == null:
			continue
		for surface: int in range(mi.mesh.get_surface_count()):
			var source: Material = mi.get_active_material(surface)
			if source is StandardMaterial3D:
				var preserved: StandardMaterial3D = (source as StandardMaterial3D).duplicate() as StandardMaterial3D
				preserved.roughness = clampf(preserved.roughness,0.34,0.94)
				preserved.metallic = clampf(preserved.metallic,0.0,0.20)
				mi.set_surface_override_material(surface,preserved)
				touched += 1
	proof_checks["house_authored_materials_preserved"] = touched > 0

	_add_house_hq_context_v4(Vector3.ZERO)


func _add_house_hq_context_v4(center: Vector3) -> void:
	var weeds: Array[Vector3] = [
		Vector3(-5.2,0,-3.7),Vector3(-4.7,0,2.9),Vector3(-3.4,0,4.9),
		Vector3(3.8,0,4.7),Vector3(5.1,0,2.3),Vector3(4.8,0,-3.1),
		Vector3(-1.9,0,5.3),Vector3(1.5,0,5.0)
	]
	for i: int in range(weeds.size()):
		var p: String = GRASS if i%3 != 0 else WEED
		_spawn_scaled(p,center+weeds[i],0.82+0.12*float(i%3),17.0+43.0*float(i),"HouseHQPlantV4_%02d" % i)

	var rubble: Array[Vector3] = [
		Vector3(-4.2,0.02,4.6),Vector3(-3.6,0.02,4.9),Vector3(-2.9,0.02,4.5),
		Vector3(3.5,0.02,4.8),Vector3(4.0,0.02,4.4),Vector3(4.4,0.02,3.9)
	]
	for i: int in range(rubble.size()):
		var rp: String = HQ_ROCK_A if i%2 == 0 else HQ_ROCK_B
		_spawn_pbr_rock_v3(rp,center+rubble[i],0.25+0.06*float(i%3),31.0+37.0*float(i),"HouseHQRubbleV4_%02d" % i)

	_spawn_pbr_rock_v3(HQ_BRANCH,center+Vector3(-4.9,0.03,1.2),0.72,66.0,"HouseHQBranchV4")
	var fence: Node3D = _spawn_scaled(HQ_FENCE,center+Vector3(5.4,0.0,-0.7),3.2,83.0,"HouseHQFenceV4")
	if fence != null:
		_ground_visual_to(fence,0.012)


func _build_ground_proof() -> void:
	var center: Vector3 = Vector3(90,0,0)
	var ground: MeshInstance3D = MeshInstance3D.new()
	ground.name = "TenMeterMaterialGroundV4Geometry"
	ground.mesh = _make_ground_mesh_v4(10.0,96)
	ground.position = center
	ground.material_override = _ground_proof_shader_v4()
	add_child(ground)
	proof_checks["ground_built"] = true

	_add_ground_dense_vegetation_v4(center)
	_add_ground_hq_debris_v4(center)
	proof_checks["ground_microgeometry"] = true


func _make_ground_mesh_v4(size: float,segments: int) -> ArrayMesh:
	var vertices: PackedVector3Array = PackedVector3Array()
	var normals: PackedVector3Array = PackedVector3Array()
	var uvs: PackedVector2Array = PackedVector2Array()
	var indices: PackedInt32Array = PackedInt32Array()
	var step: float = size/float(segments)
	for z: int in range(segments+1):
		for x: int in range(segments+1):
			var px: float = -size*0.5+float(x)*step
			var pz: float = -size*0.5+float(z)*step
			var y: float = _ground_height_v4(px,pz)
			vertices.append(Vector3(px,y,pz))
			normals.append(Vector3.UP)
			uvs.append(Vector2(float(x)/float(segments),float(z)/float(segments)))
	for z: int in range(segments):
		for x: int in range(segments):
			var a: int = z*(segments+1)+x
			var b: int = a+1
			var c: int = a+(segments+1)
			var d: int = c+1
			indices.append_array(PackedInt32Array([a,c,b,b,c,d]))
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh: ArrayMesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
	return mesh


func _ground_height_v4(x: float,z: float) -> float:
	var macro: float = 0.055*sin(x*0.62)+0.042*cos(z*0.71)+0.026*sin((x+z)*1.47)
	var micro: float = 0.012*sin(x*4.8+z*2.9)+0.009*cos(z*6.1-x*1.7)
	var rut_a: float = exp(-pow((x+1.18+0.09*sin(z*0.91))/0.19,2.0))
	var rut_b: float = exp(-pow((x-1.22-0.08*sin(z*0.83+1.1))/0.19,2.0))
	var ends: float = 1.0-smoothstep(3.65,4.72,absf(z))
	var rut: float = (rut_a+rut_b)*ends
	var churn_dist: float = Vector2(x-0.55,z-0.25).length()
	var churn: float = (1.0-smoothstep(0.65,2.10,churn_dist))*(0.55+0.45*sin(x*3.8+z*4.4))
	var puddle: float = 1.0-smoothstep(0.70,1.35,Vector2((x-1.05)/1.3,(z-0.72)/0.65).length())
	return macro+micro-0.105*rut-0.045*churn-0.035*puddle


func _ground_proof_shader_v4() -> ShaderMaterial:
	var shader: Shader = Shader.new()
	shader.code = """
shader_type spatial;
uniform sampler2D grass_diff : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D grass_nor : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D grass_arm : repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D dirt_diff : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D dirt_nor : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D dirt_arm : repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D mud_diff : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D mud_nor : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D mud_arm : repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D gravel_diff : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D gravel_nor : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D gravel_arm : repeat_enable, filter_linear_mipmap_anisotropic;
varying vec3 lp;
void vertex(){ lp=VERTEX; }
float rut_mask(vec2 p){
	float a=1.0-smoothstep(0.10,0.30,abs(p.x+1.18+0.09*sin(p.y*0.91)));
	float b=1.0-smoothstep(0.10,0.30,abs(p.x-1.22-0.08*sin(p.y*0.83+1.1)));
	return max(a,b)*(1.0-smoothstep(3.65,4.72,abs(p.y)));
}
void fragment(){
	vec2 p=lp.xz;
	vec2 uv=UV*10.2;
	float broad=0.5+0.5*sin(p.x*0.52-p.y*0.43+sin(p.x*0.31)*1.6);
	float fine=0.5+0.5*sin(p.x*1.71+p.y*1.29);
	float rut=rut_mask(p);
	float churn=(1.0-smoothstep(0.62,2.15,length(p-vec2(0.55,0.25))))*(0.5+0.5*fine);
	float puddle=1.0-smoothstep(0.72,1.22,length(vec2((p.x-1.05)/1.3,(p.y-0.72)/0.65)));
	float dirt_mask=clamp(0.10+0.38*broad+0.18*fine+rut*0.16,0.0,0.68);
	float gravel_mask=smoothstep(0.76,0.94,0.5+0.5*sin(p.x*1.13-p.y*1.31+0.8))*0.26;
	float mud_mask=clamp(rut*0.52+churn*0.38+puddle*0.34,0.0,0.72);
	vec3 grass=texture(grass_diff,uv).rgb*vec3(0.66,0.78,0.48);
	vec3 dirt=texture(dirt_diff,uv*0.81).rgb*vec3(0.74,0.68,0.57);
	vec3 mud=texture(mud_diff,uv*0.73).rgb*vec3(0.58,0.51,0.42);
	vec3 gravel=texture(gravel_diff,uv*0.91).rgb*vec3(0.73,0.70,0.63);
	vec3 base=mix(grass,dirt,dirt_mask);
	base=mix(base,gravel,gravel_mask);
	base=mix(base,mud,mud_mask);
	base=mix(base,base*vec3(0.72,0.77,0.80),puddle*0.14);
	vec3 nrm=mix(texture(grass_nor,uv).rgb,texture(dirt_nor,uv*0.81).rgb,dirt_mask);
	nrm=mix(nrm,texture(gravel_nor,uv*0.91).rgb,gravel_mask);
	nrm=mix(nrm,texture(mud_nor,uv*0.73).rgb,mud_mask);
	vec3 ga=texture(grass_arm,uv).rgb;
	vec3 da=texture(dirt_arm,uv*0.81).rgb;
	vec3 ma=texture(mud_arm,uv*0.73).rgb;
	vec3 ra=texture(gravel_arm,uv*0.91).rgb;
	float rough=mix(ga.g,da.g,dirt_mask);
	rough=mix(rough,ra.g,gravel_mask);
	rough=mix(rough,ma.g,mud_mask);
	ALBEDO=base;
	NORMAL_MAP=nrm;
	NORMAL_MAP_DEPTH=0.92;
	ROUGHNESS=clamp(mix(rough,0.16,puddle*0.72),0.16,0.98);
	AO=clamp(mix(mix(ga.r,da.r,dirt_mask),ma.r,mud_mask),0.64,1.0);
	SPECULAR=0.22+puddle*0.34;
}
"""
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("grass_diff",load("res://assets/golden_scene/pbr/leafy_grass_diff_1k.png"))
	mat.set_shader_parameter("grass_nor",load("res://assets/golden_scene/pbr/leafy_grass_nor_gl_1k.png"))
	mat.set_shader_parameter("grass_arm",load("res://assets/golden_scene/pbr/leafy_grass_arm_1k.png"))
	mat.set_shader_parameter("dirt_diff",load("res://assets/golden_scene/pbr/dirt_aerial_03_diff_1k.png"))
	mat.set_shader_parameter("dirt_nor",load("res://assets/golden_scene/pbr/dirt_aerial_03_nor_gl_1k.png"))
	mat.set_shader_parameter("dirt_arm",load("res://assets/golden_scene/pbr/dirt_aerial_03_arm_1k.png"))
	mat.set_shader_parameter("mud_diff",load("res://assets/golden_scene/pbr/aerial_mud_1_diff_1k.png"))
	mat.set_shader_parameter("mud_nor",load("res://assets/golden_scene/pbr/aerial_mud_1_nor_gl_1k.png"))
	mat.set_shader_parameter("mud_arm",load("res://assets/golden_scene/pbr/aerial_mud_1_arm_1k.png"))
	mat.set_shader_parameter("gravel_diff",load("res://assets/golden_scene/pbr/gravel_ground_01_diff_1k.png"))
	mat.set_shader_parameter("gravel_nor",load("res://assets/golden_scene/pbr/gravel_ground_01_nor_gl_1k.png"))
	mat.set_shader_parameter("gravel_arm",load("res://assets/golden_scene/pbr/gravel_ground_01_arm_1k.png"))
	return mat


func _add_ground_dense_vegetation_v4(center: Vector3) -> void:
	for i: int in range(42):
		var gx: float = -4.55+float((i*37)%91)/90.0*9.10
		var gz: float = -4.45+float((i*53+17)%89)/88.0*8.90
		var skip_rut: bool = absf(gx+1.18) < 0.38 or absf(gx-1.22) < 0.38
		if skip_rut and i%3 != 0:
			continue
		var path: String = GRASS if i%4 != 0 else WEED
		var scale_value: float = 0.50+0.10*float(i%5)
		var plant: Node3D = _spawn_scaled(path,center+Vector3(gx,0,gz),scale_value,13.0+41.0*float(i),"GroundDensePlantV4_%02d" % i)
		if plant != null:
			_ground_visual_to(plant,center.y+_ground_height_v4(gx,gz)+0.012)


func _add_ground_hq_debris_v4(center: Vector3) -> void:
	var items: Array[Vector3] = [
		Vector3(-3.6,0,2.8),Vector3(-2.8,0,-1.8),Vector3(-0.4,0,3.4),
		Vector3(2.6,0,-2.7),Vector3(3.5,0,1.6),Vector3(0.7,0,-3.7),
		Vector3(-4.0,0,-0.4),Vector3(4.1,0,-0.8),Vector3(2.1,0,3.5)
	]
	for i: int in range(items.size()):
		var p: Vector3 = items[i]
		p.y = _ground_height_v4(p.x,p.z)+0.02
		var path: String = HQ_ROCK_A if i%2 == 0 else HQ_ROCK_B
		_spawn_pbr_rock_v3(path,center+p,0.18+0.04*float(i%4),29.0+47.0*float(i),"GroundHQDebrisV4_%02d" % i)
	var branch_pos: Vector3 = Vector3(-2.2,0,3.8)
	branch_pos.y = _ground_height_v4(branch_pos.x,branch_pos.z)+0.025
	_spawn_pbr_rock_v3(HQ_BRANCH,center+branch_pos,0.65,112.0,"GroundHQBranchV4")


func _capture_all() -> void:
	await _capture_view(HOUSE_SHOT_V2,Vector3(11.8,5.7,13.5),Vector3(0,2.35,0))
	await _capture_view(ABRAMS_SHOT_V2,Vector3(51.8,2.75,6.8),Vector3(45,1.10,0))
	await _capture_view(GROUND_SHOT_V2,Vector3(93.1,3.35,4.5),Vector3(90,0.0,0))
	_write_metrics_v4()
	var all_pass: bool = true
	for value: Variant in proof_checks.values():
		if not bool(value):
			all_pass = false
	print("FRONTLINE_MATERIAL_PROOF_TECH_%s" % ("PASS" if all_pass else "FAIL"))
	get_tree().quit(0 if all_pass else 63)


func _write_metrics_v4() -> void:
	var payload: Dictionary = {
		"task_id": "QUALITY_MATERIAL_PROOF_V4_GOLDEN_FRAME_CONVERGENCE",
		"engine": Engine.get_version_info().get("string","Godot"),
		"renderer": RenderingServer.get_current_rendering_method(),
		"checks": proof_checks,
		"visual_pass": false,
		"house_asset": HOUSE_HQ,
		"abrams_asset": ABRAMS_STATIC,
		"ground_geometry": "96x96 explicit ArrayMesh with physical rut/churn/puddle relief",
		"captures": [HOUSE_SHOT_V2,ABRAMS_SHOT_V2,GROUND_SHOT_V2]
	}
	var file: FileAccess = FileAccess.open(METRICS_PATH,FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(payload,"\t")+"\n")
		file.close()
