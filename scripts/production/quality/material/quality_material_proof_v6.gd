extends "res://scripts/production/quality/material/quality_material_proof_v5.gd"


func _build_house_proof() -> void:
	super._build_house_proof()
	var key_fill: OmniLight3D = OmniLight3D.new()
	key_fill.name = "HouseV6FacadeFill"
	key_fill.position = Vector3(8.5,5.4,8.8)
	key_fill.light_color = Color(0.92,0.91,0.84)
	key_fill.light_energy = 4.2
	key_fill.omni_range = 21.0
	key_fill.shadow_enabled = false
	add_child(key_fill)

	var side_fill: OmniLight3D = OmniLight3D.new()
	side_fill.name = "HouseV6SideFill"
	side_fill.position = Vector3(-6.0,4.2,-2.5)
	side_fill.light_color = Color(0.56,0.66,0.76)
	side_fill.light_energy = 1.55
	side_fill.omni_range = 15.0
	side_fill.shadow_enabled = false
	add_child(side_fill)


func _house_material_v5(key: String) -> Material:
	if key.contains("glass"):
		var glass: StandardMaterial3D = StandardMaterial3D.new()
		glass.albedo_color = Color(0.075,0.135,0.150)
		glass.metallic = 0.10
		glass.metallic_specular = 0.55
		glass.roughness = 0.14
		return glass
	if key.contains("trim"):
		var trim: StandardMaterial3D = StandardMaterial3D.new()
		trim.albedo_color = Color(0.24,0.26,0.22)
		trim.metallic = 0.03
		trim.metallic_specular = 0.36
		trim.roughness = 0.62
		return trim
	if key.contains("metal"):
		var metal: StandardMaterial3D = StandardMaterial3D.new()
		metal.albedo_color = Color(0.17,0.18,0.17)
		metal.metallic = 0.66
		metal.metallic_specular = 0.46
		metal.roughness = 0.42
		return metal
	return super._house_material_v5(key)


func _add_house_context_v5(center: Vector3) -> void:
	var plants: Array[Vector3] = [
		Vector3(-4.6,0,-3.8),Vector3(-3.6,0,-4.6),Vector3(-4.7,0,2.9),
		Vector3(-2.7,0,4.9),Vector3(2.6,0,4.8),Vector3(4.3,0,3.7),
		Vector3(4.6,0,-2.8),Vector3(3.0,0,-4.7),Vector3(-0.8,0,5.1),
		Vector3(0.9,0,4.9),Vector3(-4.9,0,0.8)
	]
	for i: int in range(plants.size()):
		var path: String = GRASS if i%3 != 0 else WEED
		var plant: Node3D = _spawn_scaled(path,center+plants[i],0.54+0.09*float(i%4),19.0+41.0*float(i),"HousePlantV6_%02d" % i)
		if plant != null:
			_fix_foliage_v6(plant)
	var rubble: Array[Vector3] = [
		Vector3(-3.8,0.02,4.1),Vector3(-3.2,0.02,4.5),Vector3(3.4,0.02,4.4),
		Vector3(3.9,0.02,3.9),Vector3(-4.4,0.02,-1.4)
	]
	for i: int in range(rubble.size()):
		var path: String = HQ_ROCK_A if i%2 == 0 else HQ_ROCK_B
		_spawn_pbr_rock_v3(path,center+rubble[i],0.18+0.05*float(i%3),31.0+49.0*float(i),"HouseRubbleV6_%02d" % i)


func _add_ground_dense_vegetation_v5(center: Vector3) -> void:
	for i: int in range(72):
		var gx: float = -4.58+float((i*37+11)%97)/96.0*9.16
		var gz: float = -4.52+float((i*61+23)%101)/100.0*9.04
		var rut_near: bool = absf(gx+1.18) < 0.34 or absf(gx-1.22) < 0.34
		if rut_near and i%4 != 0:
			continue
		var path: String = GRASS if i%5 != 0 else WEED
		var scale_value: float = 0.44+0.075*float(i%6)
		var plant: Node3D = _spawn_scaled(path,center+Vector3(gx,0,gz),scale_value,11.0+47.0*float(i),"GroundPlantV6_%02d" % i)
		if plant != null:
			_ground_visual_to(plant,center.y+_ground_height_v4(gx,gz)+0.010)
			_fix_foliage_v6(plant)


func _fix_foliage_v6(root: Node3D) -> void:
	for mi: MeshInstance3D in _collect_meshes(root):
		if mi.mesh == null:
			continue
		for surface: int in range(mi.mesh.get_surface_count()):
			var source: Material = mi.get_active_material(surface)
			if source is StandardMaterial3D:
				var mat: StandardMaterial3D = (source as StandardMaterial3D).duplicate() as StandardMaterial3D
				mat.cull_mode = BaseMaterial3D.CULL_DISABLED
				mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
				mat.alpha_scissor_threshold = 0.34
				mat.roughness = maxf(mat.roughness,0.82)
				var src_color: Color = mat.albedo_color
				mat.albedo_color = Color(
					clampf(src_color.r*1.08,0.0,1.0),
					clampf(src_color.g*1.18,0.0,1.0),
					clampf(src_color.b*1.02,0.0,1.0),
					src_color.a
				)
				mi.set_surface_override_material(surface,mat)


func _ground_proof_shader_v5() -> ShaderMaterial:
	var mat: ShaderMaterial = super._ground_proof_shader_v5()
	var code: String = mat.shader.code
	code = code.replace("vec2 uv=UV*10.2;","vec2 uv=UV*6.6;")
	code = code.replace(
		"float dirt_mask=clamp(0.10+0.38*broad+0.18*fine+rut*0.16,0.0,0.68);",
		"float dirt_mask=clamp(0.07+0.30*broad+0.13*fine+rut*0.18,0.0,0.58);"
	)
	code = code.replace(
		"vec3 grass=texture(grass_diff,uv).rgb*vec3(0.66,0.78,0.48);",
		"vec3 grass=texture(grass_diff,uv).rgb*vec3(0.56,0.76,0.39);"
	)
	code = code.replace(
		"vec3 base=mix(grass,dirt,dirt_mask);",
		"vec3 base=mix(grass,dirt,dirt_mask); base*=mix(vec3(0.90,0.94,0.84),vec3(1.06,1.04,0.94),clamp(broad*0.58+fine*0.15,0.0,1.0));"
	)
	mat.shader.code = code
	return mat


func _vehicle_hull_shader_v3() -> ShaderMaterial:
	var mat: ShaderMaterial = super._vehicle_hull_shader_v3()
	var code: String = mat.shader.code
	code = code.replace(
		"base=mix(base,dust,(face_dust+streak)*0.28);",
		"base=mix(base,dust,(face_dust+streak)*0.38);"
	)
	code = code.replace(
		"ALBEDO=base+vec3(0.085,0.080,0.055)*wear;",
		"float field=0.5+0.5*sin(wp.x*1.73-wp.z*1.31+sin(wp.y*1.9)); ALBEDO=base*mix(0.91,1.07,field)+vec3(0.085,0.080,0.055)*wear;"
	)
	code = code.replace("NORMAL_MAP_DEPTH=0.80;","NORMAL_MAP_DEPTH=0.92;")
	mat.shader.code = code
	return mat


func _rubber_material_v3() -> StandardMaterial3D:
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.060,0.061,0.054)
	mat.metallic = 0.0
	mat.metallic_specular = 0.24
	mat.roughness = 0.84
	return mat


func _optics_material() -> StandardMaterial3D:
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.018,0.065,0.072)
	mat.metallic = 0.10
	mat.metallic_specular = 0.56
	mat.roughness = 0.10
	return mat


func _capture_all() -> void:
	await _capture_view(HOUSE_SHOT_V2,Vector3(14.2,6.15,15.0),Vector3(0,2.78,0))
	await _capture_view(ABRAMS_SHOT_V2,Vector3(51.5,2.82,6.55),Vector3(45,1.18,0))
	await _capture_view(GROUND_SHOT_V2,Vector3(92.8,2.85,4.0),Vector3(90,0.0,0))
	_write_metrics_v6()
	var all_pass: bool = true
	for value: Variant in proof_checks.values():
		if not bool(value):
			all_pass = false
	print("FRONTLINE_MATERIAL_PROOF_TECH_%s" % ("PASS" if all_pass else "FAIL"))
	get_tree().quit(0 if all_pass else 63)


func _write_metrics_v6() -> void:
	var payload: Dictionary = {
		"task_id": "QUALITY_MATERIAL_PROOF_V6_GOLDEN_FRAME_CONVERGENCE",
		"engine": Engine.get_version_info().get("string","Godot"),
		"renderer": RenderingServer.get_current_rendering_method(),
		"checks": proof_checks,
		"visual_pass": false,
		"house_asset": HOUSE_STATIC_V5,
		"abrams_asset": ABRAMS_STATIC,
		"ground_geometry": "104x104 microterrain + corrected foliage alpha materials",
		"captures": [HOUSE_SHOT_V2,ABRAMS_SHOT_V2,GROUND_SHOT_V2]
	}
	var file: FileAccess = FileAccess.open(METRICS_PATH,FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(payload,"\t")+"\n")
		file.close()
