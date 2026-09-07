extends "res://scripts/production/quality/material/quality_material_proof_v10.gd"

const HOUSE_REAL_V11 := "res://assets/golden_scene/city_v20/family_house_01.glb"


func _preflight() -> void:
	var required: Array[String] = [
		HOUSE_REAL_V11,ABRAMS_STATIC,HDRI_V10,
		GRASS,WEED,HQ_ROCK_A,HQ_ROCK_B,HQ_BRANCH,HQ_FENCE
	]
	for path: String in required:
		if not ResourceLoader.exists(path):
			push_error("MATERIAL_PROOF_REQUIRED_ASSET_MISSING path=%s" % path)


func _build_house_proof() -> void:
	_add_pad(Vector3.ZERO,Vector2(24,24))
	house_root = _spawn_scaled(HOUSE_REAL_V11,Vector3.ZERO,10.8,0.0,"MaterialProofHouseV11Real")
	if house_root == null:
		return
	proof_checks["house_loaded"] = true
	_ground_visual_to(house_root,0.018)

	var y_bounds: Vector2 = _world_y_bounds(house_root)
	var touched: int = 0
	for mi: MeshInstance3D in _collect_meshes(house_root):
		if mi.mesh == null:
			continue
		for surface: int in range(mi.mesh.get_surface_count()):
			var source: Material = mi.get_active_material(surface)
			if source is StandardMaterial3D:
				var standard: StandardMaterial3D = source as StandardMaterial3D
				if standard.albedo_texture != null:
					mi.set_surface_override_material(surface,_house_authored_surface_v3(standard,y_bounds))
				else:
					var preserved: StandardMaterial3D = standard.duplicate() as StandardMaterial3D
					preserved.roughness = clampf(maxf(preserved.roughness,0.58),0.58,0.94)
					preserved.metallic = minf(preserved.metallic,0.08)
					mi.set_surface_override_material(surface,preserved)
				touched += 1
				print("FRONTLINE_HOUSE_V11_AUTHORED mesh=%s surface=%s material=%s textured=%s" % [
					mi.name,mi.mesh.surface_get_name(surface),standard.resource_name,str(standard.albedo_texture != null)
				])
	proof_checks["house_authored_materials_preserved"] = touched > 0

	_add_house_contact_detail_v10(Vector3.ZERO)
	_add_house_real_context_v11(Vector3.ZERO)

	var facade_fill: OmniLight3D = OmniLight3D.new()
	facade_fill.name = "HouseV11FacadeFill"
	facade_fill.position = Vector3(7.5,4.8,7.0)
	facade_fill.light_color = Color(0.90,0.91,0.84)
	facade_fill.light_energy = 1.85
	facade_fill.omni_range = 18.0
	facade_fill.shadow_enabled = false
	add_child(facade_fill)


func _add_house_real_context_v11(center: Vector3) -> void:
	var rubble: Array[Vector3] = [
		Vector3(-4.2,0.02,3.9),Vector3(-3.6,0.02,4.4),Vector3(-2.8,0.02,4.6),
		Vector3(3.2,0.02,4.5),Vector3(3.8,0.02,4.0),Vector3(4.4,0.02,3.2),
		Vector3(-4.6,0.02,-2.1),Vector3(4.5,0.02,-2.3)
	]
	for i: int in range(rubble.size()):
		var path: String = HQ_ROCK_A if i%2 == 0 else HQ_ROCK_B
		_spawn_pbr_rock_v3(path,center+rubble[i],0.13+0.035*float(i%4),31.0+47.0*float(i),"HouseRealRubbleV11_%02d" % i)


func _add_ground_dense_vegetation_v5(center: Vector3) -> void:
	super._add_ground_dense_vegetation_v5(center)
	var real_positions: Array[Vector2] = [
		Vector2(-4.1,-3.4),Vector2(-3.7,-2.8),Vector2(-3.3,-3.7),Vector2(-3.9,2.7),
		Vector2(-3.3,3.2),Vector2(-2.8,2.4),Vector2(-0.3,-4.0),Vector2(0.4,-3.6),
		Vector2(0.2,3.9),Vector2(0.9,3.5),Vector2(3.3,-3.2),Vector2(3.8,-2.6),
		Vector2(3.2,2.8),Vector2(3.8,2.2),Vector2(4.1,0.8),Vector2(-4.0,0.7),
		Vector2(-2.6,-1.4),Vector2(-2.9,0.8),Vector2(2.6,-1.2),Vector2(2.9,0.9),
		Vector2(-0.4,1.8),Vector2(0.6,-1.9),Vector2(-4.4,-0.9),Vector2(4.3,-0.7)
	]
	for i: int in range(real_positions.size()):
		var p2: Vector2 = real_positions[i]
		var path: String = GRASS if i%5 != 0 else WEED
		var target_size: float = 0.28+0.045*float(i%5)
		var plant: Node3D = _spawn_scaled(path,center+Vector3(p2.x,0,p2.y),target_size,17.0+59.0*float(i),"GroundRealPlantV11_%02d" % i)
		if plant != null:
			_ground_visual_to(plant,center.y+_ground_height_v4(p2.x,p2.y)+0.008)
			_fix_foliage_v6(plant)


func _build_abrams_proof() -> void:
	super._build_abrams_proof()
	if abrams_root == null:
		return
	var marking: StandardMaterial3D = _marking_material_v11()
	for mi: MeshInstance3D in _collect_meshes(abrams_root):
		if mi.mesh == null:
			continue
		var mesh_key: String = mi.name.to_lower()
		if mesh_key.contains("marking"):
			for surface: int in range(mi.mesh.get_surface_count()):
				mi.set_surface_override_material(surface,marking)


func _marking_material_v11() -> StandardMaterial3D:
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.46,0.44,0.31)
	mat.metallic = 0.02
	mat.metallic_specular = 0.24
	mat.roughness = 0.78
	return mat


func _vehicle_hull_shader_v3() -> ShaderMaterial:
	var mat: ShaderMaterial = super._vehicle_hull_shader_v3()
	var code: String = mat.shader.code
	code = code.replace("vec3 olive_dark=vec3(0.067,0.074,0.034);","vec3 olive_dark=vec3(0.050,0.061,0.026);")
	code = code.replace("vec3 olive_mid=vec3(0.116,0.119,0.052);","vec3 olive_mid=vec3(0.086,0.099,0.039);")
	code = code.replace("vec3 olive_light=vec3(0.169,0.158,0.073);","vec3 olive_light=vec3(0.132,0.137,0.055);")
	code = code.replace(
		"vec3 dust=vec3(0.225,0.178,0.100)*mix(0.72,1.22,1.0-tex_luma);",
		"vec3 dust=vec3(0.185,0.150,0.086)*mix(0.72,1.18,1.0-tex_luma);"
	)
	code = code.replace(
		"vec3 dry_mud=m_diff*vec3(0.62,0.49,0.31);",
		"vec3 dry_mud=m_diff*vec3(0.50,0.41,0.27);"
	)
	code = code.replace("base=mix(base,dry_mud,grime*0.88);","base=mix(base,dry_mud,grime*0.72);")
	mat.shader.code = code
	return mat


func _capture_all() -> void:
	await _capture_view(HOUSE_SHOT_V2,Vector3(10.9,5.7,13.6),Vector3(0,2.35,0))
	await _capture_view(ABRAMS_SHOT_V2,Vector3(50.0,2.90,8.15),Vector3(45,1.20,0))
	await _capture_view(GROUND_SHOT_V2,Vector3(92.35,2.15,4.00),Vector3(90,0.0,0))
	_write_metrics_v11()
	var all_pass: bool = true
	for value: Variant in proof_checks.values():
		if not bool(value):
			all_pass = false
	print("FRONTLINE_MATERIAL_PROOF_TECH_%s" % ("PASS" if all_pass else "FAIL"))
	get_tree().quit(0 if all_pass else 63)


func _write_metrics_v11() -> void:
	var payload: Dictionary = {
		"task_id": "QUALITY_MATERIAL_PROOF_V11_REAL_ASSET_CONVERGENCE",
		"engine": Engine.get_version_info().get("string","Godot"),
		"renderer": RenderingServer.get_current_rendering_method(),
		"checks": proof_checks,
		"visual_pass": false,
		"environment": HDRI_V10,
		"house_asset": HOUSE_REAL_V11,
		"house_strategy": "CC0 baked family-house + preserved authored texture + V3 detail layering",
		"abrams_asset": ABRAMS_STATIC,
		"ground_geometry": "104x104 microterrain + clustered custom grass + real Poly Haven grass accents",
		"captures": [HOUSE_SHOT_V2,ABRAMS_SHOT_V2,GROUND_SHOT_V2]
	}
	var file: FileAccess = FileAccess.open(METRICS_PATH,FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(payload,"\t")+"\n")
		file.close()
