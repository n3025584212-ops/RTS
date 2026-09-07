extends "res://scripts/production/quality/material/quality_material_proof_v9.gd"

const HDRI_V10 := "res://assets/golden_scene/hdri/hochsal_field_1k.hdr"

var _grass_clump_mesh_v10: ArrayMesh


func _preflight() -> void:
	var required: Array[String] = [
		HOUSE_STATIC_V5,ABRAMS_STATIC,HDRI_V10,
		GRASS,WEED,HQ_ROCK_A,HQ_ROCK_B,HQ_BRANCH,HQ_FENCE
	]
	for path: String in required:
		if not ResourceLoader.exists(path):
			push_error("MATERIAL_PROOF_REQUIRED_ASSET_MISSING path=%s" % path)


func _build_environment() -> void:
	var world_env: WorldEnvironment = WorldEnvironment.new()
	world_env.name = "MaterialProofEnvironmentV10HDRI"
	var env: Environment = Environment.new()

	var pano_texture: Texture2D = load(HDRI_V10) as Texture2D
	var sky_mat: PanoramaSkyMaterial = PanoramaSkyMaterial.new()
	sky_mat.panorama = pano_texture
	sky_mat.energy_multiplier = 0.82
	var sky: Sky = Sky.new()
	sky.sky_material = sky_mat

	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.background_energy_multiplier = 0.78
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.62
	env.reflected_light_source = Environment.REFLECTION_SOURCE_SKY
	env.fog_enabled = true
	env.fog_density = 0.0008
	env.fog_light_color = Color(0.69,0.72,0.69)
	env.fog_aerial_perspective = 0.32
	env.ssao_enabled = true
	env.ssao_radius = 1.75
	env.ssao_intensity = 1.22
	env.ssao_power = 1.08
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.adjustment_enabled = true
	env.adjustment_brightness = 1.01
	env.adjustment_contrast = 1.08
	env.adjustment_saturation = 0.96
	world_env.environment = env
	add_child(world_env)

	var sun: DirectionalLight3D = DirectionalLight3D.new()
	sun.name = "MaterialProofSunV10"
	sun.rotation_degrees = Vector3(-38.0,-52.0,0.0)
	sun.light_color = Color(1.0,0.91,0.78)
	sun.light_energy = 1.65
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 90.0
	add_child(sun)

	var fill: DirectionalLight3D = DirectionalLight3D.new()
	fill.name = "MaterialProofFillV10"
	fill.rotation_degrees = Vector3(-58.0,132.0,0.0)
	fill.light_color = Color(0.48,0.60,0.74)
	fill.light_energy = 0.16
	add_child(fill)


func _build_house_proof() -> void:
	super._build_house_proof()
	if house_root == null:
		return
	_add_house_contact_detail_v10(Vector3.ZERO)


func _house_material_v5(key: String) -> Material:
	if key.contains("stucco"):
		return _house_stucco_material_v10()
	if key.contains("brick"):
		return _house_brick_material_v10()
	if key.contains("foundation") or key.contains("patch"):
		return _house_concrete_material_v10()
	if key.contains("roof"):
		return _house_roof_material_v10()
	if key.contains("glass"):
		return _house_glass_material_v10()
	return super._house_material_v5(key)


func _house_stucco_material_v10() -> ShaderMaterial:
	var shader: Shader = Shader.new()
	shader.code = """
shader_type spatial;
uniform sampler2D diff_tex : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D nor_tex : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D arm_tex : repeat_enable, filter_linear_mipmap_anisotropic;
varying vec3 wp;
varying vec3 wn;
void vertex(){
	wp=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;
	wn=normalize((MODEL_MATRIX*vec4(NORMAL,0.0)).xyz);
}
void fragment(){
	vec2 uv=UV*3.25;
	vec3 tex=texture(diff_tex,uv).rgb;
	float tl=dot(tex,vec3(0.2126,0.7152,0.0722));
	float macro=0.5+0.5*sin(wp.x*0.53+wp.z*0.39+sin(wp.y*0.71)*1.4);
	float vertical=1.0-abs(wn.y);
	float lower=1.0-smoothstep(0.20,1.35,wp.y);
	float rain=vertical*(0.5+0.5*sin(wp.x*1.63+wp.z*1.17+wp.y*0.37));
	float blotch=smoothstep(0.58,0.88,0.5+0.5*sin(wp.x*0.91-wp.z*0.73+sin(wp.y*1.4)));
	vec3 plaster=mix(vec3(0.46,0.44,0.38),vec3(0.64,0.62,0.54),0.40+0.38*macro);
	plaster*=mix(0.88,1.08,tl);
	plaster=mix(plaster,vec3(0.23,0.21,0.17),lower*(0.10+0.14*rain));
	plaster=mix(plaster,vec3(0.35,0.32,0.27),blotch*vertical*0.07);
	ALBEDO=plaster;
	NORMAL_MAP=texture(nor_tex,uv).rgb;
	NORMAL_MAP_DEPTH=0.62;
	vec3 arm=texture(arm_tex,uv).rgb;
	ROUGHNESS=clamp(0.72+arm.g*0.20+lower*0.06+rain*0.04,0.72,0.98);
	AO=clamp(arm.r,0.72,1.0);
	SPECULAR=0.20;
}
"""
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("diff_tex",load("res://assets/golden_scene/pbr/t_concrete_wall_002_diff_1k.png"))
	mat.set_shader_parameter("nor_tex",load("res://assets/golden_scene/pbr/t_concrete_wall_002_nor_gl_1k.png"))
	mat.set_shader_parameter("arm_tex",load("res://assets/golden_scene/pbr/t_concrete_wall_002_arm_1k.png"))
	return mat


func _house_brick_material_v10() -> ShaderMaterial:
	var shader: Shader = Shader.new()
	shader.code = """
shader_type spatial;
uniform sampler2D diff_tex : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D nor_tex : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D arm_tex : repeat_enable, filter_linear_mipmap_anisotropic;
varying vec3 wp;
void vertex(){ wp=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz; }
void fragment(){
	vec2 uv=UV*3.0;
	vec3 tex=texture(diff_tex,uv).rgb;
	float lower=1.0-smoothstep(0.18,1.28,wp.y);
	float patch=0.5+0.5*sin(wp.x*0.73+wp.z*0.59+sin(wp.y*1.23));
	vec3 brick=tex*vec3(0.88,0.76,0.67);
	brick*=mix(0.84,1.08,patch);
	brick=mix(brick,vec3(0.19,0.16,0.12),lower*(0.11+0.10*patch));
	ALBEDO=brick;
	NORMAL_MAP=texture(nor_tex,uv).rgb;
	NORMAL_MAP_DEPTH=0.88;
	vec3 arm=texture(arm_tex,uv).rgb;
	ROUGHNESS=clamp(0.68+arm.g*0.24+lower*0.07,0.68,0.97);
	AO=clamp(arm.r,0.68,1.0);
	SPECULAR=0.22;
}
"""
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("diff_tex",load("res://assets/golden_scene/pbr/brick_wall_005_diff_1k.png"))
	mat.set_shader_parameter("nor_tex",load("res://assets/golden_scene/pbr/brick_wall_005_nor_gl_1k.png"))
	mat.set_shader_parameter("arm_tex",load("res://assets/golden_scene/pbr/brick_wall_005_arm_1k.png"))
	return mat


func _house_concrete_material_v10() -> ShaderMaterial:
	var mat: ShaderMaterial = _house_stucco_material_v10()
	var code: String = mat.shader.code
	code = code.replace(
		"vec3 plaster=mix(vec3(0.46,0.44,0.38),vec3(0.64,0.62,0.54),0.40+0.38*macro);",
		"vec3 plaster=mix(vec3(0.30,0.29,0.26),vec3(0.48,0.46,0.40),0.38+0.32*macro);"
	)
	code = code.replace("NORMAL_MAP_DEPTH=0.62;","NORMAL_MAP_DEPTH=0.76;")
	mat.shader.code = code
	return mat


func _house_roof_material_v10() -> ShaderMaterial:
	var shader: Shader = Shader.new()
	shader.code = """
shader_type spatial;
uniform sampler2D diff_tex : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D nor_tex : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D arm_tex : repeat_enable, filter_linear_mipmap_anisotropic;
varying vec3 wp;
void vertex(){ wp=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz; }
void fragment(){
	vec2 uv=UV*3.0;
	vec3 t=texture(diff_tex,uv).rgb;
	float macro=0.5+0.5*sin(wp.x*0.79+wp.z*0.93);
	float lichen=smoothstep(0.70,0.91,0.5+0.5*sin(wp.x*1.37-wp.z*1.09+sin(wp.y)));
	vec3 roof=t*mix(vec3(0.46,0.28,0.22),vec3(0.70,0.44,0.31),0.28+0.34*macro);
	roof=mix(roof,vec3(0.22,0.25,0.16),lichen*0.13);
	ALBEDO=roof;
	NORMAL_MAP=texture(nor_tex,uv).rgb;
	NORMAL_MAP_DEPTH=0.78;
	vec3 arm=texture(arm_tex,uv).rgb;
	ROUGHNESS=clamp(0.70+arm.g*0.22+lichen*0.05,0.70,0.96);
	AO=clamp(arm.r,0.70,1.0);
	SPECULAR=0.23;
}
"""
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("diff_tex",load("res://assets/golden_scene/pbr/asphalt_02_diff_1k.png"))
	mat.set_shader_parameter("nor_tex",load("res://assets/golden_scene/pbr/asphalt_02_nor_gl_1k.png"))
	mat.set_shader_parameter("arm_tex",load("res://assets/golden_scene/pbr/asphalt_02_arm_1k.png"))
	return mat


func _house_glass_material_v10() -> ShaderMaterial:
	var shader: Shader = Shader.new()
	shader.code = """
shader_type spatial;
void fragment(){
	float facing=clamp(dot(normalize(NORMAL),normalize(VIEW)),0.0,1.0);
	float fres=pow(1.0-facing,3.0);
	float dirt=0.5+0.5*sin(UV.x*17.0+UV.y*4.0+sin(UV.y*13.0));
	vec3 deep=vec3(0.018,0.052,0.058);
	vec3 sky=vec3(0.25,0.38,0.40);
	ALBEDO=mix(deep,sky,0.24+0.58*fres);
	ALBEDO=mix(ALBEDO,vec3(0.16,0.14,0.11),smoothstep(0.88,0.98,dirt)*0.08);
	METALLIC=0.04;
	ROUGHNESS=0.07+0.12*(1.0-fres)+0.05*smoothstep(0.86,0.96,dirt);
	SPECULAR=0.76;
}
"""
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = shader
	return mat


func _add_house_contact_detail_v10(center: Vector3) -> void:
	if _grass_clump_mesh_v10 == null:
		_grass_clump_mesh_v10 = _make_grass_clump_mesh_v10()
	var mat: StandardMaterial3D = _make_grass_material_v10(false)
	var positions: Array[Vector3] = [
		Vector3(-4.7,0,3.4),Vector3(-4.3,0,4.0),Vector3(-3.6,0,4.6),
		Vector3(3.5,0,4.7),Vector3(4.1,0,4.1),Vector3(4.6,0,3.3),
		Vector3(-4.9,0,-2.8),Vector3(4.7,0,-2.5)
	]
	for i: int in range(positions.size()):
		var node: MeshInstance3D = MeshInstance3D.new()
		node.name = "HouseContactGrassV10_%02d" % i
		node.mesh = _grass_clump_mesh_v10
		node.material_override = mat
		node.position = center+positions[i]+Vector3(0,0.018,0)
		node.rotation_degrees.y = 27.0+53.0*float(i)
		var s: float = 0.90+0.08*float(i%4)
		node.scale = Vector3(s,0.85+0.06*float(i%3),s)
		add_child(node)


func _add_ground_dense_vegetation_v5(center: Vector3) -> void:
	if _grass_clump_mesh_v10 == null:
		_grass_clump_mesh_v10 = _make_grass_clump_mesh_v10()
	_add_clustered_grass_v10(center,282,false)
	_add_clustered_grass_v10(center,92,true)


func _add_clustered_grass_v10(center: Vector3,count: int,dry: bool) -> void:
	var clusters: Array[Vector2]
	if dry:
		clusters = [
			Vector2(-1.75,-3.2),Vector2(-0.75,-2.0),Vector2(1.65,-1.6),
			Vector2(0.70,2.7),Vector2(-1.55,3.2),Vector2(3.6,0.4)
		]
	else:
		clusters = [
			Vector2(-3.7,-3.2),Vector2(-3.5,2.4),Vector2(-3.8,0.2),
			Vector2(-0.1,-3.8),Vector2(0.3,3.8),Vector2(3.5,-2.8),
			Vector2(3.7,2.5),Vector2(4.0,0.2)
		]

	var mm: MultiMesh = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = _grass_clump_mesh_v10
	mm.instance_count = count
	for i: int in range(count):
		var cluster_index: int = (i*7+3)%clusters.size()
		var cp: Vector2 = clusters[cluster_index]
		var angle: float = float(i)*2.399963+float(cluster_index)*0.71
		var ring_seed: float = float((i*37+cluster_index*19)%101)/100.0
		var radius: float = (0.12+1.15*sqrt(ring_seed))*(0.72 if dry else 1.0)
		var gx: float = clampf(cp.x+cos(angle)*radius,-4.72,4.72)
		var gz: float = clampf(cp.y+sin(angle)*radius,-4.68,4.68)
		var rut_a: float = 1.0-smoothstep(0.24,0.48,absf(gx+1.18))
		var rut_b: float = 1.0-smoothstep(0.24,0.48,absf(gx-1.22))
		var rut: float = maxf(rut_a,rut_b)
		var sy: float = (0.78+0.08*float(i%6))*(0.62+0.38*(1.0-rut))
		var sxz: float = (0.82+0.065*float(i%5))*(0.72+0.28*(1.0-rut))
		if dry:
			sy *= 0.82
			sxz *= 0.88
		var rot: float = deg_to_rad(13.0+137.5*float(i)+17.0*float(cluster_index))
		var basis: Basis = Basis(Vector3.UP,rot)
		basis = basis.scaled(Vector3(sxz,sy,sxz))
		var y_value: float = _ground_height_v4(gx,gz)+0.008
		mm.set_instance_transform(i,Transform3D(basis,center+Vector3(gx,y_value,gz)))

	var mmi: MultiMeshInstance3D = MultiMeshInstance3D.new()
	mmi.name = "GroundDryGrassClusterV10" if dry else "GroundLushGrassClusterV10"
	mmi.multimesh = mm
	mmi.material_override = _make_grass_material_v10(dry)
	add_child(mmi)


func _make_grass_clump_mesh_v10() -> ArrayMesh:
	var vertices: PackedVector3Array = PackedVector3Array()
	var normals: PackedVector3Array = PackedVector3Array()
	var colors: PackedColorArray = PackedColorArray()
	var indices: PackedInt32Array = PackedInt32Array()
	for i: int in range(13):
		var angle: float = float(i)*2.399963+0.19*float(i%4)
		var radial: float = 0.008+0.012*float(i%4)
		var center: Vector3 = Vector3(cos(angle)*radial,0.0,sin(angle)*radial)
		var side: Vector3 = Vector3(-sin(angle),0.0,cos(angle))
		var forward: Vector3 = Vector3(cos(angle),0.0,sin(angle))
		var height_value: float = 0.060+0.010*float((i*5)%8)
		var half_width: float = 0.0038+0.0007*float(i%3)
		var bend: Vector3 = forward*(0.008+0.003*float(i%4))
		var v0: Vector3 = center-side*half_width
		var v1: Vector3 = center+side*half_width
		var v2: Vector3 = center+Vector3(0,height_value,0)+bend+side*half_width*0.10
		var v3: Vector3 = center+Vector3(0,height_value,0)+bend-side*half_width*0.10
		var bi: int = vertices.size()
		vertices.append_array(PackedVector3Array([v0,v1,v2,v3]))
		var n: Vector3 = forward.normalized()
		normals.append_array(PackedVector3Array([n,n,n,n]))
		var tone: float = 0.83+0.028*float(i%5)
		var col: Color = Color(0.16*tone,0.42*tone,0.075*tone,1.0)
		colors.append_array(PackedColorArray([col,col,Color(col.r*1.05,col.g*1.09,col.b*1.03,1),Color(col.r*1.05,col.g*1.09,col.b*1.03,1)]))
		indices.append_array(PackedInt32Array([bi,bi+1,bi+2,bi,bi+2,bi+3]))
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_COLOR] = colors
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh: ArrayMesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
	return mesh


func _make_grass_material_v10(dry: bool) -> StandardMaterial3D:
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	if dry:
		mat.albedo_color = Color(0.43,0.34,0.15)
		mat.vertex_color_use_as_albedo = false
	else:
		mat.albedo_color = Color.WHITE
		mat.vertex_color_use_as_albedo = true
	mat.metallic = 0.0
	mat.metallic_specular = 0.15
	mat.roughness = 0.92
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	return mat


func _vehicle_hull_shader_v3() -> ShaderMaterial:
	var mat: ShaderMaterial = super._vehicle_hull_shader_v3()
	var code: String = mat.shader.code
	code = code.replace(
		"float skirt_dust=clamp(side_skirt_factor*0.11+low*0.08,0.0,0.22); base=mix(base,vec3(0.245,0.196,0.116),skirt_dust); float field=0.5+0.5*sin(wp.x*1.73-wp.z*1.31+sin(wp.y*1.9)); ALBEDO=base*mix(0.90,1.08,field)+vec3(0.085,0.080,0.055)*wear;",
		"float skirt_dust=clamp(side_skirt_factor*0.13+low*0.10,0.0,0.27); base=mix(base,vec3(0.245,0.196,0.116),skirt_dust); float field=0.5+0.5*sin(wp.x*1.73-wp.z*1.31+sin(wp.y*1.9)); float mottling=0.5+0.5*sin(wp.x*3.7+wp.z*2.9+sin(wp.y*4.1)); base*=mix(0.90,1.07,mottling); ALBEDO=base*mix(0.89,1.09,field)+vec3(0.090,0.083,0.058)*wear;"
	)
	code = code.replace("NORMAL_MAP_DEPTH=0.80;","NORMAL_MAP_DEPTH=0.98;")
	code = code.replace(
		"ROUGHNESS=clamp(rough+dry_patch*0.15+face_dust*0.18+side_skirt_factor*0.08-wear*0.25,0.44,0.98);",
		"ROUGHNESS=clamp(rough+dry_patch*0.18+face_dust*0.20+side_skirt_factor*0.10-wear*0.28+0.035*mottling,0.42,0.98);"
	)
	mat.shader.code = code
	return mat


func _track_material_v4() -> ShaderMaterial:
	var mat: ShaderMaterial = super._track_material_v4()
	var code: String = mat.shader.code
	code = code.replace("NORMAL_MAP_DEPTH=0.46;","NORMAL_MAP_DEPTH=0.62;")
	code = code.replace(
		"ALBEDO=mix(steel,mud,0.28+0.28*wet);",
		"ALBEDO=mix(steel,mud,0.24+0.32*wet); ALBEDO*=mix(0.78,1.12,wear);"
	)
	code = code.replace(
		"ROUGHNESS=clamp(0.52+0.25*wet+ma.g*0.16,0.50,0.90);",
		"ROUGHNESS=clamp(0.48+0.29*wet+ma.g*0.18-wear*0.08,0.44,0.92);"
	)
	mat.shader.code = code
	return mat


func _capture_all() -> void:
	await _capture_view(HOUSE_SHOT_V2,Vector3(13.0,5.65,16.1),Vector3(0,2.84,0))
	await _capture_view(ABRAMS_SHOT_V2,Vector3(50.0,2.90,8.15),Vector3(45,1.20,0))
	await _capture_view(GROUND_SHOT_V2,Vector3(92.35,2.15,4.00),Vector3(90,0.0,0))
	_write_metrics_v10()
	var all_pass: bool = true
	for value: Variant in proof_checks.values():
		if not bool(value):
			all_pass = false
	print("FRONTLINE_MATERIAL_PROOF_TECH_%s" % ("PASS" if all_pass else "FAIL"))
	get_tree().quit(0 if all_pass else 63)


func _write_metrics_v10() -> void:
	var payload: Dictionary = {
		"task_id": "QUALITY_MATERIAL_PROOF_V10_GOLDEN_FRAME_CONVERGENCE",
		"engine": Engine.get_version_info().get("string","Godot"),
		"renderer": RenderingServer.get_current_rendering_method(),
		"checks": proof_checks,
		"visual_pass": false,
		"environment": HDRI_V10,
		"house_asset": HOUSE_STATIC_V5,
		"abrams_asset": ABRAMS_STATIC,
		"ground_geometry": "104x104 microterrain + clustered lush/dry grass MultiMesh",
		"captures": [HOUSE_SHOT_V2,ABRAMS_SHOT_V2,GROUND_SHOT_V2]
	}
	var file: FileAccess = FileAccess.open(METRICS_PATH,FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(payload,"\t")+"\n")
		file.close()
