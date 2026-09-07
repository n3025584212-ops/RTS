extends "res://scripts/production/quality/material/quality_material_proof_v10.gd"

const HDRI_V12 := "res://assets/golden_scene/hdri/kloppenheim_05_1k.hdr"

var _grass_mesh_v12: ArrayMesh
var _grass_lush_v12: StandardMaterial3D
var _grass_dry_v12: StandardMaterial3D
var _world_floor_added_v12: bool = false


func _preflight() -> void:
	var required: Array[String] = [
		HOUSE_STATIC_V5,ABRAMS_STATIC,HDRI_V12,
		HQ_ROCK_A,HQ_ROCK_B,HQ_BRANCH,HQ_FENCE
	]
	for path: String in required:
		if not ResourceLoader.exists(path):
			push_error("MATERIAL_PROOF_REQUIRED_ASSET_MISSING path=%s" % path)


func _build_environment() -> void:
	var world_env: WorldEnvironment = WorldEnvironment.new()
	world_env.name = "MaterialProofEnvironmentV12HDRI"
	var env: Environment = Environment.new()
	var pano_texture: Texture2D = load(HDRI_V12) as Texture2D
	var sky_mat: PanoramaSkyMaterial = PanoramaSkyMaterial.new()
	sky_mat.panorama = pano_texture
	sky_mat.energy_multiplier = 0.72
	var sky: Sky = Sky.new()
	sky.sky_material = sky_mat
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.background_energy_multiplier = 0.70
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.78
	env.reflected_light_source = Environment.REFLECTION_SOURCE_SKY
	env.fog_enabled = true
	env.fog_density = 0.00045
	env.fog_light_color = Color(0.67,0.70,0.69)
	env.fog_aerial_perspective = 0.30
	env.ssao_enabled = true
	env.ssao_radius = 1.65
	env.ssao_intensity = 1.18
	env.ssao_power = 1.06
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.adjustment_enabled = true
	env.adjustment_brightness = 1.00
	env.adjustment_contrast = 1.06
	env.adjustment_saturation = 0.90
	world_env.environment = env
	add_child(world_env)

	var sun: DirectionalLight3D = DirectionalLight3D.new()
	sun.name = "MaterialProofSunV12"
	sun.rotation_degrees = Vector3(-41.0,-48.0,0.0)
	sun.light_color = Color(1.0,0.92,0.82)
	sun.light_energy = 1.30
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 120.0
	add_child(sun)

	var fill: DirectionalLight3D = DirectionalLight3D.new()
	fill.name = "MaterialProofFillV12"
	fill.rotation_degrees = Vector3(-61.0,137.0,0.0)
	fill.light_color = Color(0.46,0.57,0.70)
	fill.light_energy = 0.18
	add_child(fill)


func _build_house_proof() -> void:
	_add_world_floor_v12()
	super._build_house_proof()
	if house_root == null:
		return
	_add_house_grass_apron_v12(Vector3.ZERO)


func _build_abrams_proof() -> void:
	_add_world_floor_v12()
	super._build_abrams_proof()
	if abrams_root == null:
		return
	var marking: StandardMaterial3D = _marking_material_v12()
	for mi: MeshInstance3D in _collect_meshes(abrams_root):
		if mi.mesh == null:
			continue
		if mi.name.to_lower().contains("marking"):
			for surface: int in range(mi.mesh.get_surface_count()):
				mi.set_surface_override_material(surface,marking)


func _build_ground_proof() -> void:
	_add_world_floor_v12()
	super._build_ground_proof()


func _add_world_floor_v12() -> void:
	if _world_floor_added_v12:
		return
	_world_floor_added_v12 = true
	var node: MeshInstance3D = MeshInstance3D.new()
	node.name = "MaterialProofContinuousWorldFloorV12"
	var plane: PlaneMesh = PlaneMesh.new()
	plane.size = Vector2(160.0,72.0)
	plane.subdivide_width = 72
	plane.subdivide_depth = 40
	node.mesh = plane
	node.position = Vector3(45.0,-0.075,0.0)
	node.material_override = _world_floor_material_v12()
	add_child(node)


func _world_floor_material_v12() -> ShaderMaterial:
	var shader: Shader = Shader.new()
	shader.code = """
shader_type spatial;
uniform sampler2D grass_diff : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D grass_nor : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D grass_arm : repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D dirt_diff : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D dirt_nor : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D dirt_arm : repeat_enable, filter_linear_mipmap_anisotropic;
varying vec3 lp;
float hash21(vec2 p){ return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453); }
float noise2(vec2 p){
	vec2 i=floor(p); vec2 f=fract(p); f=f*f*(3.0-2.0*f);
	return mix(mix(hash21(i),hash21(i+vec2(1,0)),f.x),mix(hash21(i+vec2(0,1)),hash21(i+vec2(1,1)),f.x),f.y);
}
void vertex(){
	lp=VERTEX;
	VERTEX.y += 0.018*sin(VERTEX.x*0.19)+0.013*cos(VERTEX.z*0.23);
}
void fragment(){
	vec2 uv=UV*18.0;
	float macro=noise2(lp.xz*0.075);
	float macro2=noise2(lp.xz*0.21+vec2(7.3,2.1));
	float dirt_mask=clamp(0.24+0.52*macro+0.12*macro2,0.12,0.78);
	vec3 grass=texture(grass_diff,uv).rgb*vec3(0.33,0.42,0.25);
	vec3 dirt=texture(dirt_diff,uv*0.82).rgb*vec3(0.58,0.49,0.38);
	vec3 ga=texture(grass_arm,uv).rgb;
	vec3 da=texture(dirt_arm,uv*0.82).rgb;
	ALBEDO=mix(grass,dirt,dirt_mask);
	NORMAL_MAP=mix(texture(grass_nor,uv).rgb,texture(dirt_nor,uv*0.82).rgb,dirt_mask);
	NORMAL_MAP_DEPTH=0.63;
	ROUGHNESS=clamp(mix(ga.g,da.g,dirt_mask)+0.10,0.66,0.97);
	AO=clamp(mix(ga.r,da.r,dirt_mask),0.72,1.0);
	SPECULAR=0.20;
}
"""
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("grass_diff",load("res://assets/golden_scene/pbr/grass_path_3_diff_1k.png"))
	mat.set_shader_parameter("grass_nor",load("res://assets/golden_scene/pbr/grass_path_3_nor_gl_1k.png"))
	mat.set_shader_parameter("grass_arm",load("res://assets/golden_scene/pbr/grass_path_3_arm_1k.png"))
	mat.set_shader_parameter("dirt_diff",load("res://assets/golden_scene/pbr/dirt_aerial_03_diff_1k.png"))
	mat.set_shader_parameter("dirt_nor",load("res://assets/golden_scene/pbr/dirt_aerial_03_nor_gl_1k.png"))
	mat.set_shader_parameter("dirt_arm",load("res://assets/golden_scene/pbr/dirt_aerial_03_arm_1k.png"))
	return mat


func _house_roof_material_v10() -> ShaderMaterial:
	var shader: Shader = Shader.new()
	shader.code = """
shader_type spatial;
uniform sampler2D diff_tex : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D nor_tex : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D arm_tex : repeat_enable, filter_linear_mipmap_anisotropic;
varying vec3 wp;
float hash21(vec2 p){ return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453); }
float noise2(vec2 p){
	vec2 i=floor(p); vec2 f=fract(p); f=f*f*(3.0-2.0*f);
	return mix(mix(hash21(i),hash21(i+vec2(1,0)),f.x),mix(hash21(i+vec2(0,1)),hash21(i+vec2(1,1)),f.x),f.y);
}
void vertex(){ wp=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz; }
void fragment(){
	vec2 uv=UV*3.15;
	vec3 tex=texture(diff_tex,uv).rgb;
	float macro=noise2(wp.xz*0.38);
	float repair=noise2(wp.xz*1.17+vec2(3.2,6.7));
	float moss=smoothstep(0.70,0.88,noise2(wp.xz*0.72+vec2(8.1,1.4)));
	vec3 warm=tex*mix(vec3(0.60,0.38,0.28),vec3(0.92,0.63,0.44),0.30+0.48*macro);
	warm=mix(warm,vec3(0.31,0.34,0.22),moss*0.16);
	warm*=mix(0.88,1.09,repair);
	ALBEDO=warm;
	NORMAL_MAP=texture(nor_tex,uv).rgb;
	NORMAL_MAP_DEPTH=0.82;
	vec3 arm=texture(arm_tex,uv).rgb;
	ROUGHNESS=clamp(0.66+arm.g*0.24+moss*0.08,0.66,0.96);
	AO=clamp(arm.r,0.70,1.0);
	SPECULAR=0.25;
}
"""
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("diff_tex",load("res://assets/golden_scene/pbr/asphalt_02_diff_1k.png"))
	mat.set_shader_parameter("nor_tex",load("res://assets/golden_scene/pbr/asphalt_02_nor_gl_1k.png"))
	mat.set_shader_parameter("arm_tex",load("res://assets/golden_scene/pbr/asphalt_02_arm_1k.png"))
	return mat


func _add_house_grass_apron_v12(center: Vector3) -> void:
	_ensure_grass_assets_v12()
	var transforms: Array[Transform3D] = []
	for i: int in range(2600):
		var gx: float = -7.4+_hash_v12(i,11.0)*14.8
		var gz: float = -6.8+_hash_v12(i,23.0)*13.6
		var outside_house: bool = absf(gx) > 4.25 or absf(gz) > 3.25
		if not outside_house:
			continue
		var ring: float = minf(absf(gx)-4.25,absf(gz)-3.25)
		var keep: float = 0.46+0.38*_hash_v12(i,41.0)
		if ring > 2.2:
			keep *= 0.60
		if _hash_v12(i,57.0) > keep:
			continue
		var rot: float = deg_to_rad(_hash_v12(i,71.0)*360.0)
		var scale_value: float = 0.68+0.58*_hash_v12(i,83.0)
		var basis: Basis = Basis(Vector3.UP,rot).scaled(Vector3(scale_value,scale_value,scale_value))
		transforms.append(Transform3D(basis,center+Vector3(gx,0.012,gz)))
		if transforms.size() >= 1100:
			break
	_add_grass_multimesh_v12("HouseGrassApronV12",transforms,_grass_lush_v12)


func _add_ground_dense_vegetation_v5(center: Vector3) -> void:
	_ensure_grass_assets_v12()
	var lush: Array[Transform3D] = []
	var dry: Array[Transform3D] = []
	for i: int in range(14000):
		var gx: float = -4.86+_hash_v12(i,13.0)*9.72
		var gz: float = -4.84+_hash_v12(i,29.0)*9.68
		var rut_a: float = 1.0-smoothstep(0.18,0.46,absf(gx+1.18))
		var rut_b: float = 1.0-smoothstep(0.18,0.46,absf(gx-1.22))
		var rut: float = maxf(rut_a,rut_b)
		var puddle: float = 1.0-smoothstep(0.72,1.45,Vector2((gx-1.05)/1.3,(gz-0.72)/0.65).length())
		var macro: float = 0.5+0.25*sin(gx*0.83)+0.25*cos(gz*0.71)+0.14*sin((gx+gz)*1.17)
		var density: float = clampf(0.48+0.38*macro,0.18,0.92)
		density *= 1.0-0.92*rut
		density *= 1.0-0.75*puddle
		if _hash_v12(i,47.0) > density:
			continue
		var rot: float = deg_to_rad(_hash_v12(i,61.0)*360.0)
		var sxz: float = 0.62+0.72*_hash_v12(i,73.0)
		var sy: float = 0.50+0.72*_hash_v12(i,89.0)
		var basis: Basis = Basis(Vector3.UP,rot).scaled(Vector3(sxz,sy,sxz))
		var y_value: float = _ground_height_v4(gx,gz)+0.006
		var tr: Transform3D = Transform3D(basis,center+Vector3(gx,y_value,gz))
		if _hash_v12(i,101.0) < 0.16+0.28*rut:
			dry.append(tr)
		else:
			lush.append(tr)
		if lush.size() >= 4800 and dry.size() >= 700:
			break
	_add_grass_multimesh_v12("GroundLushCarpetV12",lush,_grass_lush_v12)
	_add_grass_multimesh_v12("GroundDryCarpetV12",dry,_grass_dry_v12)


func _ensure_grass_assets_v12() -> void:
	if _grass_mesh_v12 == null:
		_grass_mesh_v12 = _make_grass_mesh_v12()
	if _grass_lush_v12 == null:
		_grass_lush_v12 = _make_grass_material_v12(false)
	if _grass_dry_v12 == null:
		_grass_dry_v12 = _make_grass_material_v12(true)


func _make_grass_mesh_v12() -> ArrayMesh:
	var vertices: PackedVector3Array = PackedVector3Array()
	var normals: PackedVector3Array = PackedVector3Array()
	var indices: PackedInt32Array = PackedInt32Array()
	for i: int in range(7):
		var angle: float = float(i)*2.399963+0.17*float(i%3)
		var radial: float = 0.004+0.007*float(i%3)
		var center: Vector3 = Vector3(cos(angle)*radial,0.0,sin(angle)*radial)
		var side: Vector3 = Vector3(-sin(angle),0.0,cos(angle))
		var forward: Vector3 = Vector3(cos(angle),0.0,sin(angle))
		var h: float = 0.038+0.0065*float((i*5)%6)
		var half_width: float = 0.0023+0.00045*float(i%3)
		var bend: Vector3 = forward*(0.004+0.0016*float(i%4))
		var v0: Vector3 = center-side*half_width
		var v1: Vector3 = center+side*half_width
		var v2: Vector3 = center+Vector3(0,h,0)+bend+side*half_width*0.08
		var v3: Vector3 = center+Vector3(0,h,0)+bend-side*half_width*0.08
		var bi: int = vertices.size()
		vertices.append_array(PackedVector3Array([v0,v1,v2,v3]))
		var n: Vector3 = forward.normalized()
		normals.append_array(PackedVector3Array([n,n,n,n]))
		indices.append_array(PackedInt32Array([bi,bi+1,bi+2,bi,bi+2,bi+3]))
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh: ArrayMesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
	return mesh


func _make_grass_material_v12(dry: bool) -> StandardMaterial3D:
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.34,0.27,0.12) if dry else Color(0.16,0.31,0.085)
	mat.metallic = 0.0
	mat.metallic_specular = 0.15
	mat.roughness = 0.91
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	return mat


func _add_grass_multimesh_v12(name_value: String,transforms: Array[Transform3D],material: Material) -> void:
	if transforms.is_empty():
		return
	var mm: MultiMesh = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = _grass_mesh_v12
	mm.instance_count = transforms.size()
	for i: int in range(transforms.size()):
		mm.set_instance_transform(i,transforms[i])
	var mmi: MultiMeshInstance3D = MultiMeshInstance3D.new()
	mmi.name = name_value
	mmi.multimesh = mm
	mmi.material_override = material
	add_child(mmi)


func _hash_v12(i: int,salt: float) -> float:
	var value: float = sin(float(i)*12.9898+salt*78.233)*43758.5453
	return absf(value-floor(value))


func _ground_proof_shader_v5() -> ShaderMaterial:
	var shader: Shader = Shader.new()
	shader.code = """
shader_type spatial;
render_mode cull_disabled;
uniform sampler2D grass_diff : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D grass_nor : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D grass_arm : repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D dirt_diff : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D dirt_nor : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D dirt_arm : repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D mud_diff : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D mud_nor : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D mud_arm : repeat_enable, filter_linear_mipmap_anisotropic;
varying vec3 lp;
float hash21(vec2 p){ return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453); }
float noise2(vec2 p){
	vec2 i=floor(p); vec2 f=fract(p); f=f*f*(3.0-2.0*f);
	return mix(mix(hash21(i),hash21(i+vec2(1,0)),f.x),mix(hash21(i+vec2(0,1)),hash21(i+vec2(1,1)),f.x),f.y);
}
void vertex(){ lp=VERTEX; }
void fragment(){
	vec2 uv=UV*4.6;
	float broad=noise2(lp.xz*0.42);
	float fine=noise2(lp.xz*1.37+vec2(4.1,7.3));
	float rut_a=exp(-pow((lp.x+1.18+0.09*sin(lp.z*0.91))/0.29,2.0));
	float rut_b=exp(-pow((lp.x-1.22-0.08*sin(lp.z*0.83+1.1))/0.29,2.0));
	float ends=1.0-smoothstep(3.65,4.72,abs(lp.z));
	float rut=(rut_a+rut_b)*ends;
	float churn=(1.0-smoothstep(0.75,2.20,length(lp.xz-vec2(0.55,0.25))))*(0.45+0.35*fine);
	float puddle=1.0-smoothstep(0.72,1.35,length(vec2((lp.x-1.05)/1.3,(lp.z-0.72)/0.65)));
	float dirt_mask=clamp(0.18+0.40*broad+0.12*fine+rut*0.28+churn*0.18,0.08,0.82);
	float mud_mask=clamp(rut*0.42+churn*0.28+puddle*0.44,0.0,0.72);
	vec3 grass=texture(grass_diff,uv).rgb*vec3(0.32,0.43,0.24);
	vec3 dirt=texture(dirt_diff,uv*0.87).rgb*vec3(0.60,0.50,0.38);
	vec3 mud=texture(mud_diff,uv*0.72+vec2(0.17,0.09)).rgb*vec3(0.50,0.40,0.30);
	vec3 base=mix(grass,dirt,dirt_mask);
	base=mix(base,mud,mud_mask);
	ALBEDO=base;
	vec3 gn=texture(grass_nor,uv).rgb;
	vec3 dn=texture(dirt_nor,uv*0.87).rgb;
	vec3 mn=texture(mud_nor,uv*0.72+vec2(0.17,0.09)).rgb;
	NORMAL_MAP=mix(mix(gn,dn,dirt_mask),mn,mud_mask);
	NORMAL_MAP_DEPTH=0.80;
	vec3 ga=texture(grass_arm,uv).rgb;
	vec3 da=texture(dirt_arm,uv*0.87).rgb;
	vec3 ma=texture(mud_arm,uv*0.72+vec2(0.17,0.09)).rgb;
	ROUGHNESS=clamp(mix(mix(ga.g,da.g,dirt_mask),ma.g,mud_mask)+0.06,0.54,0.98);
	AO=clamp(mix(mix(ga.r,da.r,dirt_mask),ma.r,mud_mask),0.68,1.0);
	SPECULAR=0.22;
}
"""
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("grass_diff",load("res://assets/golden_scene/pbr/grass_path_3_diff_1k.png"))
	mat.set_shader_parameter("grass_nor",load("res://assets/golden_scene/pbr/grass_path_3_nor_gl_1k.png"))
	mat.set_shader_parameter("grass_arm",load("res://assets/golden_scene/pbr/grass_path_3_arm_1k.png"))
	mat.set_shader_parameter("dirt_diff",load("res://assets/golden_scene/pbr/dirt_aerial_03_diff_1k.png"))
	mat.set_shader_parameter("dirt_nor",load("res://assets/golden_scene/pbr/dirt_aerial_03_nor_gl_1k.png"))
	mat.set_shader_parameter("dirt_arm",load("res://assets/golden_scene/pbr/dirt_aerial_03_arm_1k.png"))
	mat.set_shader_parameter("mud_diff",load("res://assets/golden_scene/pbr/aerial_mud_1_diff_1k.png"))
	mat.set_shader_parameter("mud_nor",load("res://assets/golden_scene/pbr/aerial_mud_1_nor_gl_1k.png"))
	mat.set_shader_parameter("mud_arm",load("res://assets/golden_scene/pbr/aerial_mud_1_arm_1k.png"))
	return mat


func _vehicle_hull_shader_v3() -> ShaderMaterial:
	var shader: Shader = Shader.new()
	shader.code = """
shader_type spatial;
uniform sampler2D dirt_diff : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D dirt_nor : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D dirt_arm : repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D mud_diff : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D mud_nor : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D mud_arm : repeat_enable, filter_linear_mipmap_anisotropic;
uniform float panel_variant = 0.5;
uniform float panel_dust = 0.5;
uniform float side_skirt_factor = 0.0;
varying vec3 wp;
varying vec3 wn;
float hash21(vec2 p){ return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453); }
float noise2(vec2 p){
	vec2 i=floor(p); vec2 f=fract(p); f=f*f*(3.0-2.0*f);
	return mix(mix(hash21(i),hash21(i+vec2(1,0)),f.x),mix(hash21(i+vec2(0,1)),hash21(i+vec2(1,1)),f.x),f.y);
}
float fbm(vec2 p){
	float v=0.0; float a=0.5;
	for(int i=0;i<4;i++){ v+=a*noise2(p); p=p*2.03+vec2(17.1,9.2); a*=0.5; }
	return v;
}
void vertex(){
	wp=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;
	wn=normalize((MODEL_MATRIX*vec4(NORMAL,0.0)).xyz);
}
void fragment(){
	vec2 uv=UV*4.1;
	float macro=fbm(wp.xz*0.34);
	float mid=fbm(wp.xz*1.10+vec2(wp.y*0.17,3.1));
	float micro=noise2(wp.xz*6.7+vec2(wp.y*2.1,0.0));
	float low=1.0-smoothstep(0.38,1.45,wp.y);
	float vertical=clamp(1.0-abs(wn.y),0.0,1.0);
	float streak=vertical*smoothstep(0.54,0.86,fbm(vec2(wp.x*0.85+wp.z*0.45,wp.y*2.4)));
	vec3 td=texture(dirt_diff,uv).rgb;
	vec3 ta=texture(dirt_arm,uv).rgb;
	vec3 md=texture(mud_diff,uv*0.72+vec2(0.13,0.07)).rgb;
	vec3 ma=texture(mud_arm,uv*0.72+vec2(0.13,0.07)).rgb;
	float tex_luma=dot(td,vec3(0.2126,0.7152,0.0722));
	vec3 olive=vec3(0.082,0.091,0.040);
	olive*=mix(0.84,1.18,panel_variant);
	olive*=mix(0.82,1.14,macro);
	olive=mix(olive,vec3(0.118,0.119,0.055),mid*0.28);
	float dry=smoothstep(0.38,0.78,1.0-tex_luma)*(0.08+0.15*panel_dust+0.10*side_skirt_factor);
	float splash=low*smoothstep(0.48,0.78,mid)*(0.22+0.40*panel_dust+0.20*side_skirt_factor);
	float grime=clamp(dry+splash+streak*(0.06+0.13*panel_dust),0.0,0.62);
	vec3 dust=vec3(0.19,0.155,0.090)*mix(0.82,1.14,micro);
	vec3 mud=md*vec3(0.48,0.40,0.27);
	vec3 base=mix(olive,dust,grime*0.55);
	base=mix(base,mud,splash*0.58);
	float fleck=smoothstep(0.965,0.995,micro+0.16*hash21(wp.xz*31.0));
	base+=vec3(0.055,0.052,0.038)*fleck*(1.0-low);
	ALBEDO=base;
	NORMAL_MAP=mix(texture(dirt_nor,uv).rgb,texture(mud_nor,uv*0.72+vec2(0.13,0.07)).rgb,splash);
	NORMAL_MAP_DEPTH=0.88;
	METALLIC=0.018+fleck*0.18;
	float rough=mix(clamp(0.50+ta.g*0.34,0.50,0.84),clamp(0.69+ma.g*0.23,0.69,0.96),splash);
	ROUGHNESS=clamp(rough+dry*0.18+streak*0.07+micro*0.05-fleck*0.10,0.46,0.97);
	AO=clamp(mix(ta.r,ma.r,splash),0.70,1.0);
	SPECULAR=0.30;
}
"""
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("dirt_diff",load("res://assets/golden_scene/pbr/dirt_aerial_03_diff_1k.png"))
	mat.set_shader_parameter("dirt_nor",load("res://assets/golden_scene/pbr/dirt_aerial_03_nor_gl_1k.png"))
	mat.set_shader_parameter("dirt_arm",load("res://assets/golden_scene/pbr/dirt_aerial_03_arm_1k.png"))
	mat.set_shader_parameter("mud_diff",load("res://assets/golden_scene/pbr/aerial_mud_1_diff_1k.png"))
	mat.set_shader_parameter("mud_nor",load("res://assets/golden_scene/pbr/aerial_mud_1_nor_gl_1k.png"))
	mat.set_shader_parameter("mud_arm",load("res://assets/golden_scene/pbr/aerial_mud_1_arm_1k.png"))
	return mat


func _track_material_v4() -> ShaderMaterial:
	var shader: Shader = Shader.new()
	shader.code = """
shader_type spatial;
uniform sampler2D mud_diff : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D mud_nor : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D mud_arm : repeat_enable, filter_linear_mipmap_anisotropic;
varying vec3 wp;
float hash21(vec2 p){ return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453); }
void vertex(){ wp=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz; }
void fragment(){
	vec2 uv=UV*3.7;
	vec3 md=texture(mud_diff,uv).rgb;
	vec3 ma=texture(mud_arm,uv).rgb;
	float n=hash21(floor(wp.xz*23.0));
	float wet=smoothstep(0.48,0.76,1.0-dot(md,vec3(0.2126,0.7152,0.0722)));
	float wear=smoothstep(0.58,0.90,n);
	vec3 steel=vec3(0.13,0.12,0.095);
	vec3 mud=md*vec3(0.46,0.38,0.26);
	ALBEDO=mix(steel,mud,0.26+0.38*wet);
	ALBEDO+=vec3(0.08,0.075,0.065)*wear*(1.0-wet);
	NORMAL_MAP=texture(mud_nor,uv).rgb;
	NORMAL_MAP_DEPTH=0.68;
	METALLIC=clamp(0.48+wear*0.20-wet*0.24,0.22,0.70);
	ROUGHNESS=clamp(0.48+wet*0.30+ma.g*0.15-wear*0.08,0.44,0.92);
	AO=clamp(ma.r,0.70,1.0);
	SPECULAR=0.38;
}
"""
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("mud_diff",load("res://assets/golden_scene/pbr/aerial_mud_1_diff_1k.png"))
	mat.set_shader_parameter("mud_nor",load("res://assets/golden_scene/pbr/aerial_mud_1_nor_gl_1k.png"))
	mat.set_shader_parameter("mud_arm",load("res://assets/golden_scene/pbr/aerial_mud_1_arm_1k.png"))
	return mat


func _marking_material_v12() -> StandardMaterial3D:
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.42,0.40,0.28)
	mat.metallic = 0.01
	mat.metallic_specular = 0.22
	mat.roughness = 0.80
	return mat


func _capture_all() -> void:
	await _capture_view(HOUSE_SHOT_V2,Vector3(13.0,5.55,16.3),Vector3(0,2.82,0))
	await _capture_view(ABRAMS_SHOT_V2,Vector3(50.0,2.90,8.25),Vector3(45,1.20,0))
	await _capture_view(GROUND_SHOT_V2,Vector3(92.20,2.05,4.10),Vector3(90,0.0,0))
	_write_metrics_v12()
	var all_pass: bool = true
	for value: Variant in proof_checks.values():
		if not bool(value):
			all_pass = false
	print("FRONTLINE_MATERIAL_PROOF_TECH_%s" % ("PASS" if all_pass else "FAIL"))
	get_tree().quit(0 if all_pass else 63)


func _write_metrics_v12() -> void:
	var payload: Dictionary = {
		"task_id": "QUALITY_MATERIAL_PROOF_V12_CONTINUOUS_SURFACE_CONVERGENCE",
		"engine": Engine.get_version_info().get("string","Godot"),
		"renderer": RenderingServer.get_current_rendering_method(),
		"checks": proof_checks,
		"visual_pass": false,
		"environment": HDRI_V12,
		"house_asset": HOUSE_STATIC_V5,
		"house_strategy": "V10 hard-surface house + continuous field + repaired roof PBR",
		"abrams_asset": ABRAMS_STATIC,
		"abrams_strategy": "V10/V11 faceted armor + multi-scale CARC/dirt material",
		"ground_geometry": "104x104 microterrain + 4.8k lush / 0.7k dry short-grass MultiMesh carpet",
		"captures": [HOUSE_SHOT_V2,ABRAMS_SHOT_V2,GROUND_SHOT_V2]
	}
	var file: FileAccess = FileAccess.open(METRICS_PATH,FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(payload,"\t")+"\n")
		file.close()
