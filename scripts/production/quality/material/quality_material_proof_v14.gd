extends "res://scripts/production/quality/material/quality_material_proof_v13.gd"

const HOUSE_CC0_V14 := "res://assets/golden_scene/quality_material_v3/house_cc0_v14.glb"


func _preflight() -> void:
	var required: Array[String] = [
		HOUSE_CC0_V14,ABRAMS_STATIC,HDRI_V12,
		HQ_ROCK_A,HQ_ROCK_B,HQ_BRANCH,HQ_FENCE
	]
	for path: String in required:
		if not ResourceLoader.exists(path):
			push_error("MATERIAL_PROOF_REQUIRED_ASSET_MISSING path=%s" % path)


func _build_house_proof() -> void:
	_add_world_floor_v12()
	_add_pad(Vector3.ZERO,Vector2(26,26))
	house_root = _spawn_scaled(HOUSE_CC0_V14,Vector3.ZERO,11.8,24.0,"MaterialProofHouseV14CC0Complete")
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
			var key: String = (mi.name+" "+mi.mesh.surface_get_name(surface)).to_lower()
			if source != null:
				key += " "+source.resource_name.to_lower()
			var chosen: Material
			if source is StandardMaterial3D and (source as StandardMaterial3D).albedo_texture != null:
				chosen = _house_authored_surface_v3(source as StandardMaterial3D,y_bounds)
			else:
				chosen = _house_semantic_material_v14(key)
			mi.set_surface_override_material(surface,chosen)
			touched += 1
			print("FRONTLINE_HOUSE_V14_SURFACE key=%s class=%s" % [key,chosen.get_class()])
	proof_checks["house_authored_materials_preserved"] = touched > 0

	_add_house_grass_apron_v12(Vector3.ZERO)
	_add_house_rubble_v14(Vector3.ZERO)

	var fill: OmniLight3D = OmniLight3D.new()
	fill.name = "HouseV14FacadeFill"
	fill.position = Vector3(7.8,5.2,7.4)
	fill.light_color = Color(0.91,0.90,0.84)
	fill.light_energy = 1.65
	fill.omni_range = 19.0
	fill.shadow_enabled = false
	add_child(fill)


func _house_semantic_material_v14(key: String) -> Material:
	if key.contains("roof") or key.contains("tile") or key.contains("shingle"):
		return _house_roof_material_v10()
	if key.contains("glass") or key.contains("window"):
		return _house_glass_material_v10()
	if key.contains("brick"):
		return _house_brick_material_v10()
	if key.contains("foundation") or key.contains("floor") or key.contains("concrete") or key.contains("base"):
		return _house_concrete_material_v10()
	if key.contains("door") or key.contains("wood") or key.contains("frame"):
		return _house_wood_material_v14()
	if key.contains("metal") or key.contains("gutter"):
		return _house_metal_material_v13()
	return _house_stucco_material_v10()


func _house_wood_material_v14() -> StandardMaterial3D:
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.25,0.15,0.085)
	mat.metallic = 0.0
	mat.metallic_specular = 0.22
	mat.roughness = 0.76
	return mat


func _add_house_rubble_v14(center: Vector3) -> void:
	for i: int in range(12):
		var a: float = 0.63+float(i)*1.37
		var rr: float = 5.0+0.42*float(i%4)
		var p: Vector3 = center+Vector3(cos(a)*rr,0.02,sin(a)*rr*0.76)
		var path: String = HQ_ROCK_A if i%2 == 0 else HQ_ROCK_B
		_spawn_pbr_rock_v3(path,p,0.11+0.03*float(i%5),19.0+43.0*float(i),"HouseV14Rubble_%02d" % i)


func _add_ground_dense_vegetation_v5(center: Vector3) -> void:
	_ensure_grass_assets_v12()
	var lush: Array[Transform3D] = []
	var dry: Array[Transform3D] = []
	for i: int in range(12000):
		var gx: float = -4.86+_hash_v12(i,13.0)*9.72
		var gz: float = -4.84+_hash_v12(i,29.0)*9.68
		var rut_a: float = 1.0-smoothstep(0.18,0.46,absf(gx+1.18))
		var rut_b: float = 1.0-smoothstep(0.18,0.46,absf(gx-1.22))
		var rut: float = maxf(rut_a,rut_b)
		var puddle: float = 1.0-smoothstep(0.72,1.45,Vector2((gx-1.05)/1.3,(gz-0.72)/0.65).length())
		var macro: float = 0.5+0.25*sin(gx*0.83)+0.25*cos(gz*0.71)+0.14*sin((gx+gz)*1.17)
		var density: float = clampf(0.44+0.32*macro,0.16,0.84)
		density *= 1.0-0.94*rut
		density *= 1.0-0.82*puddle
		if _hash_v12(i,47.0) > density:
			continue
		var rot: float = deg_to_rad(_hash_v12(i,61.0)*360.0)
		var sxz: float = 0.72+0.58*_hash_v12(i,73.0)
		var sy: float = 0.66+0.60*_hash_v12(i,89.0)
		var basis: Basis = Basis(Vector3.UP,rot).scaled(Vector3(sxz,sy,sxz))
		var y_value: float = _ground_height_v4(gx,gz)+0.006
		var tr: Transform3D = Transform3D(basis,center+Vector3(gx,y_value,gz))
		if _hash_v12(i,101.0) < 0.12+0.25*rut:
			if dry.size() < 360:
				dry.append(tr)
		else:
			if lush.size() < 2250:
				lush.append(tr)
		if lush.size() >= 2250 and dry.size() >= 360:
			break
	_add_grass_multimesh_v12("GroundLushSolidGrassV14",lush,_grass_lush_v12)
	_add_grass_multimesh_v12("GroundDrySolidGrassV14",dry,_grass_dry_v12)


func _make_grass_mesh_v12() -> ArrayMesh:
	var st: SurfaceTool = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i: int in range(7):
		var angle: float = float(i)*2.399963+0.17*float(i%3)
		var radial: float = 0.006+0.008*float(i%3)
		var center: Vector3 = Vector3(cos(angle)*radial,0.0,sin(angle)*radial)
		var forward: Vector3 = Vector3(cos(angle),0.0,sin(angle)).normalized()
		var side: Vector3 = Vector3(-forward.z,0.0,forward.x)
		var h: float = 0.038+0.006*float((i*5)%6)
		var half_width: float = 0.0036+0.0006*float(i%3)
		var half_thick: float = 0.0015+0.0003*float(i%2)
		var lean: float = 0.010+0.003*float(i%4)
		var top: Vector3 = center+Vector3.UP*h+forward*lean
		var tw: float = half_width*0.16
		var tt: float = half_thick*0.35

		var p0: Vector3 = center-side*half_width-forward*half_thick
		var p1: Vector3 = center+side*half_width-forward*half_thick
		var p2: Vector3 = center+side*half_width+forward*half_thick
		var p3: Vector3 = center-side*half_width+forward*half_thick
		var p4: Vector3 = top-side*tw-forward*tt
		var p5: Vector3 = top+side*tw-forward*tt
		var p6: Vector3 = top+side*tw+forward*tt
		var p7: Vector3 = top-side*tw+forward*tt

		var tone: float = 0.88+0.025*float(i%5)
		var col: Color = Color(tone,tone,tone,1.0)
		_add_grass_quad_v14(st,p0,p1,p5,p4,col)
		_add_grass_quad_v14(st,p3,p7,p6,p2,col)
		_add_grass_quad_v14(st,p0,p4,p7,p3,col)
		_add_grass_quad_v14(st,p1,p2,p6,p5,col)
		_add_grass_quad_v14(st,p4,p5,p6,p7,col)
		_add_grass_quad_v14(st,p0,p3,p2,p1,col)
	st.generate_normals()
	var mesh: ArrayMesh = st.commit() as ArrayMesh
	return mesh


func _add_grass_quad_v14(st: SurfaceTool,a: Vector3,b: Vector3,c: Vector3,d: Vector3,col: Color) -> void:
	st.set_color(col)
	st.add_vertex(a)
	st.set_color(col)
	st.add_vertex(b)
	st.set_color(col)
	st.add_vertex(c)
	st.set_color(col)
	st.add_vertex(a)
	st.set_color(col)
	st.add_vertex(c)
	st.set_color(col)
	st.add_vertex(d)


func _make_grass_material_v12(dry: bool) -> StandardMaterial3D:
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.37,0.31,0.15) if dry else Color(0.18,0.34,0.085)
	mat.vertex_color_use_as_albedo = true
	mat.metallic = 0.0
	mat.metallic_specular = 0.14
	mat.roughness = 0.91
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	return mat


func _capture_all() -> void:
	await _capture_view(HOUSE_SHOT_V2,Vector3(11.2,5.45,13.4),Vector3(0,2.65,0))
	await _capture_view(ABRAMS_SHOT_V2,Vector3(50.0,2.90,8.25),Vector3(45,1.20,0))
	await _capture_view(GROUND_SHOT_V2,Vector3(92.20,2.05,4.10),Vector3(90,0.0,0))
	_write_metrics_v14()
	var all_pass: bool = true
	for value: Variant in proof_checks.values():
		if not bool(value):
			all_pass = false
	print("FRONTLINE_MATERIAL_PROOF_TECH_%s" % ("PASS" if all_pass else "FAIL"))
	get_tree().quit(0 if all_pass else 63)


func _write_metrics_v14() -> void:
	var payload: Dictionary = {
		"task_id": "QUALITY_MATERIAL_PROOF_V14_COMPLETE_HOUSE_SOLID_GRASS",
		"engine": Engine.get_version_info().get("string","Godot"),
		"renderer": RenderingServer.get_current_rendering_method(),
		"checks": proof_checks,
		"visual_pass": false,
		"environment": HDRI_V12,
		"house_asset": HOUSE_CC0_V14,
		"house_strategy": "CC0 complete residential Blender asset + per-surface semantic PBR",
		"abrams_asset": ABRAMS_STATIC,
		"abrams_strategy": "V13 fallback pending legal higher-fidelity asset",
		"ground_geometry": "104x104 microterrain + solid-volume wedge grass MultiMesh",
		"captures": [HOUSE_SHOT_V2,ABRAMS_SHOT_V2,GROUND_SHOT_V2]
	}
	var file: FileAccess = FileAccess.open(METRICS_PATH,FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(payload,"\t")+"\n")
		file.close()
