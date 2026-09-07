extends "res://scripts/production/quality/material/quality_material_proof_v6.gd"


func _build_house_proof() -> void:
	super._build_house_proof()
	if house_root != null:
		house_root.rotation_degrees.y = 14.0
		_ground_visual_to(house_root,0.018)
	_add_extended_pad_v7(Vector3.ZERO,32.0)


func _build_abrams_proof() -> void:
	super._build_abrams_proof()
	_add_extended_pad_v7(Vector3(45,0,0),34.0)


func _add_extended_pad_v7(center: Vector3,size_value: float) -> void:
	var node: MeshInstance3D = MeshInstance3D.new()
	node.name = "ExtendedInspectionGroundV7"
	var plane: PlaneMesh = PlaneMesh.new()
	plane.size = Vector2(size_value,size_value)
	plane.subdivide_width = 32
	plane.subdivide_depth = 32
	node.mesh = plane
	node.position = center+Vector3(0,-0.018,0)
	node.material_override = _quality_pad_shader()
	add_child(node)


func _house_material_v5(key: String) -> Material:
	if key.contains("stucco"):
		return _house_stucco_material_v7()
	if key.contains("glass"):
		return _house_glass_material_v7()
	if key.contains("roof"):
		var roof: ShaderMaterial = super._house_pbr_surface_v5(
			"res://assets/golden_scene/pbr/asphalt_02_diff_1k.png",
			"res://assets/golden_scene/pbr/asphalt_02_nor_gl_1k.png",
			"res://assets/golden_scene/pbr/asphalt_02_arm_1k.png",
			Color(0.68,0.52,0.43),0.86,0.0
		)
		var roof_code: String = roof.shader.code
		roof_code = roof_code.replace("float scale=0.72;","float scale=0.46;")
		roof_code = roof_code.replace("UV*3.6","UV*2.35")
		roof.shader.code = roof_code
		return roof
	if key.contains("brick"):
		var brick: ShaderMaterial = super._house_pbr_surface_v5(
			"res://assets/golden_scene/pbr/brick_wall_005_diff_1k.png",
			"res://assets/golden_scene/pbr/brick_wall_005_nor_gl_1k.png",
			"res://assets/golden_scene/pbr/brick_wall_005_arm_1k.png",
			Color(0.86,0.76,0.68),0.82,0.0
		)
		var brick_code: String = brick.shader.code
		brick_code = brick_code.replace("float scale=0.72;","float scale=0.52;")
		brick_code = brick_code.replace("UV*3.6","UV*2.70")
		brick.shader.code = brick_code
		return brick
	return super._house_material_v5(key)


func _house_stucco_material_v7() -> ShaderMaterial:
	var shader: Shader = Shader.new()
	shader.code = """
shader_type spatial;
uniform sampler2D micro_diff : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D micro_nor : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D micro_arm : repeat_enable, filter_linear_mipmap_anisotropic;
varying vec3 wp;
varying vec3 wn;
void vertex(){
	wp=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;
	wn=normalize((MODEL_MATRIX*vec4(NORMAL,0.0)).xyz);
}
void fragment(){
	vec3 weights=pow(abs(wn),vec3(4.0));
	weights/=max(weights.x+weights.y+weights.z,0.001);
	float s=1.32;
	vec3 dx=texture(micro_diff,wp.yz*s).rgb;
	vec3 dy=texture(micro_diff,wp.xz*s).rgb;
	vec3 dz=texture(micro_diff,wp.xy*s).rgb;
	float luma=dot(dx*weights.x+dy*weights.y+dz*weights.z,vec3(0.2126,0.7152,0.0722));
	float macro=0.5+0.5*sin(wp.x*0.47+wp.z*0.39+sin(wp.y*0.63)*1.4);
	float vertical=1.0-abs(wn.y);
	float lower=1.0-smoothstep(0.18,1.25,wp.y);
	float rain=vertical*(0.5+0.5*sin(wp.x*1.37+wp.z*1.91+wp.y*0.31));
	vec3 warm=vec3(0.50,0.48,0.42);
	vec3 light=vec3(0.68,0.66,0.58);
	vec3 base=mix(warm,light,0.48+0.30*macro+0.08*(luma-0.5));
	base=mix(base,vec3(0.27,0.24,0.19),lower*(0.10+0.10*rain));
	ALBEDO=base;
	NORMAL_MAP=texture(micro_nor,UV*4.2).rgb;
	NORMAL_MAP_DEPTH=0.38;
	ROUGHNESS=clamp(0.78+texture(micro_arm,UV*4.2).g*0.16+lower*0.06,0.76,0.96);
	AO=clamp(texture(micro_arm,UV*4.2).r,0.78,1.0);
	SPECULAR=0.20;
}
"""
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("micro_diff",load("res://assets/golden_scene/pbr/dirt_aerial_03_diff_1k.png"))
	mat.set_shader_parameter("micro_nor",load("res://assets/golden_scene/pbr/dirt_aerial_03_nor_gl_1k.png"))
	mat.set_shader_parameter("micro_arm",load("res://assets/golden_scene/pbr/dirt_aerial_03_arm_1k.png"))
	return mat


func _house_glass_material_v7() -> StandardMaterial3D:
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.11,0.20,0.22)
	mat.metallic = 0.04
	mat.metallic_specular = 0.66
	mat.roughness = 0.09
	mat.emission_enabled = true
	mat.emission = Color(0.018,0.035,0.040)
	mat.emission_energy_multiplier = 0.42
	return mat


func _add_house_context_v5(center: Vector3) -> void:
	for i: int in range(44):
		var gx: float = -6.1+float((i*31+7)%101)/100.0*12.2
		var gz: float = -5.8+float((i*47+19)%103)/102.0*11.6
		if absf(gx) < 4.2 and absf(gz) < 3.6:
			continue
		var h: float = 0.15+0.035*float(i%5)
		_add_grass_tuft(center+Vector3(gx,0.018,gz),h,17.0+53.0*float(i))
	var rubble: Array[Vector3] = [
		Vector3(-4.0,0.02,4.3),Vector3(-3.4,0.02,4.7),
		Vector3(3.5,0.02,4.5),Vector3(4.1,0.02,4.0),Vector3(-4.6,0.02,-1.7)
	]
	for i: int in range(rubble.size()):
		var path: String = HQ_ROCK_A if i%2 == 0 else HQ_ROCK_B
		_spawn_pbr_rock_v3(path,center+rubble[i],0.16+0.045*float(i%3),31.0+49.0*float(i),"HouseRubbleV7_%02d" % i)


func _ground_height_v4(x: float,z: float) -> float:
	var macro: float = 0.032*sin(x*0.62)+0.025*cos(z*0.71)+0.016*sin((x+z)*1.47)
	var micro: float = 0.009*sin(x*4.8+z*2.9)+0.006*cos(z*6.1-x*1.7)
	var rut_a: float = exp(-pow((x+1.18+0.09*sin(z*0.91))/0.27,2.0))
	var rut_b: float = exp(-pow((x-1.22-0.08*sin(z*0.83+1.1))/0.27,2.0))
	var ends: float = 1.0-smoothstep(3.65,4.72,absf(z))
	var rut: float = (rut_a+rut_b)*ends
	var churn_dist: float = Vector2(x-0.55,z-0.25).length()
	var churn: float = (1.0-smoothstep(0.70,2.20,churn_dist))*(0.50+0.38*sin(x*3.8+z*4.4))
	var puddle: float = 1.0-smoothstep(0.72,1.35,Vector2((x-1.05)/1.3,(z-0.72)/0.65).length())
	return macro+micro-0.052*rut-0.020*churn-0.018*puddle


func _add_ground_dense_vegetation_v5(center: Vector3) -> void:
	for i: int in range(148):
		var gx: float = -4.72+float((i*37+11)%211)/210.0*9.44
		var gz: float = -4.68+float((i*61+23)%223)/222.0*9.36
		var rut_near: bool = absf(gx+1.18) < 0.31 or absf(gx-1.22) < 0.31
		if rut_near and i%5 != 0:
			continue
		var height_value: float = 0.12+0.025*float(i%7)
		if i%11 == 0:
			height_value += 0.10
		var y_value: float = _ground_height_v4(gx,gz)+0.012
		_add_grass_tuft(center+Vector3(gx,y_value,gz),height_value,13.0+47.0*float(i))


func _ground_proof_shader_v5() -> ShaderMaterial:
	var mat: ShaderMaterial = super._ground_proof_shader_v5()
	var code: String = mat.shader.code
	code = code.replace("vec2 uv=UV*6.6;","vec2 uv=UV*4.8;")
	code = code.replace(
		"float dirt_mask=clamp(0.07+0.30*broad+0.13*fine+rut*0.18,0.0,0.58);",
		"float dirt_mask=clamp(0.05+0.24*broad+0.10*fine+rut*0.22,0.0,0.54);"
	)
	code = code.replace(
		"vec3 grass=texture(grass_diff,uv).rgb*vec3(0.56,0.76,0.39);",
		"vec3 grass=texture(grass_diff,uv).rgb*vec3(0.50,0.72,0.35);"
	)
	code = code.replace(
		"float mud_mask=clamp(rut*0.52+churn*0.38+puddle*0.34,0.0,0.72);",
		"float mud_mask=clamp(rut*0.38+churn*0.26+puddle*0.30,0.0,0.62);"
	)
	mat.shader.code = code
	return mat


func _vehicle_hull_shader_v3() -> ShaderMaterial:
	var mat: ShaderMaterial = super._vehicle_hull_shader_v3()
	var code: String = mat.shader.code
	code = code.replace(
		"vec3 olive_dark=vec3(0.060,0.073,0.030);",
		"vec3 olive_dark=vec3(0.067,0.074,0.034);"
	)
	code = code.replace(
		"vec3 olive_mid=vec3(0.105,0.116,0.047);",
		"vec3 olive_mid=vec3(0.116,0.119,0.052);"
	)
	code = code.replace(
		"vec3 olive_light=vec3(0.155,0.158,0.067);",
		"vec3 olive_light=vec3(0.169,0.158,0.073);"
	)
	code = code.replace(
		"float field=0.5+0.5*sin(wp.x*1.73-wp.z*1.31+sin(wp.y*1.9)); ALBEDO=base*mix(0.91,1.07,field)+vec3(0.085,0.080,0.055)*wear;",
		"float skirt_dust=clamp(side_skirt_factor*0.11+low*0.08,0.0,0.22); base=mix(base,vec3(0.245,0.196,0.116),skirt_dust); float field=0.5+0.5*sin(wp.x*1.73-wp.z*1.31+sin(wp.y*1.9)); ALBEDO=base*mix(0.90,1.08,field)+vec3(0.085,0.080,0.055)*wear;"
	)
	mat.shader.code = code
	return mat


func _track_material_v4() -> ShaderMaterial:
	var mat: ShaderMaterial = super._track_material_v4()
	var code: String = mat.shader.code
	code = code.replace("vec3 steel=vec3(0.115,0.105,0.085);","vec3 steel=vec3(0.145,0.132,0.105);")
	code = code.replace(
		"ALBEDO=mix(steel,mud,0.36+0.32*wet);",
		"ALBEDO=mix(steel,mud,0.28+0.28*wet);"
	)
	code = code.replace(
		"METALLIC=clamp(0.48+0.20*wear-0.28*wet,0.20,0.68);",
		"METALLIC=clamp(0.52+0.22*wear-0.24*wet,0.24,0.72);"
	)
	mat.shader.code = code
	return mat


func _capture_all() -> void:
	await _capture_view(HOUSE_SHOT_V2,Vector3(13.2,5.75,16.3),Vector3(0,2.82,0))
	await _capture_view(ABRAMS_SHOT_V2,Vector3(50.3,3.05,7.9),Vector3(45,1.22,0))
	await _capture_view(GROUND_SHOT_V2,Vector3(92.65,2.55,4.15),Vector3(90,0.0,0))
	_write_metrics_v7()
	var all_pass: bool = true
	for value: Variant in proof_checks.values():
		if not bool(value):
			all_pass = false
	print("FRONTLINE_MATERIAL_PROOF_TECH_%s" % ("PASS" if all_pass else "FAIL"))
	get_tree().quit(0 if all_pass else 63)


func _write_metrics_v7() -> void:
	var payload: Dictionary = {
		"task_id": "QUALITY_MATERIAL_PROOF_V7_GOLDEN_FRAME_CONVERGENCE",
		"engine": Engine.get_version_info().get("string","Godot"),
		"renderer": RenderingServer.get_current_rendering_method(),
		"checks": proof_checks,
		"visual_pass": false,
		"house_asset": HOUSE_STATIC_V5,
		"abrams_asset": ABRAMS_STATIC,
		"ground_geometry": "104x104 microterrain + dense deterministic blade-card grass",
		"captures": [HOUSE_SHOT_V2,ABRAMS_SHOT_V2,GROUND_SHOT_V2]
	}
	var file: FileAccess = FileAccess.open(METRICS_PATH,FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(payload,"\t")+"\n")
		file.close()
