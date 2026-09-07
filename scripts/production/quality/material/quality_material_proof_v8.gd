extends "res://scripts/production/quality/material/quality_material_proof_v7.gd"

const ABRAMS_CC0_V8 := "res://assets/golden_scene/quality_material_v3/abrams_cc0_candidate.glb"

var _grass_mesh_v8: ArrayMesh
var _grass_mat_v8: StandardMaterial3D


func _preflight() -> void:
	super._preflight()
	if not ResourceLoader.exists(ABRAMS_CC0_V8):
		push_error("MATERIAL_PROOF_REQUIRED_ASSET_MISSING path=%s" % ABRAMS_CC0_V8)


func _build_house_proof() -> void:
	super._build_house_proof()
	if house_root != null:
		house_root.rotation_degrees.y = 194.0
		_ground_visual_to(house_root,0.018)


func _build_abrams_proof() -> void:
	var center: Vector3 = Vector3(45,0,0)
	_add_pad(center,Vector2(20,20))
	abrams_root = _spawn_scaled(ABRAMS_CC0_V8,center,8.6,-18.0,"MaterialProofAbramsV8CC0")
	if abrams_root == null:
		return
	proof_checks["abrams_loaded"] = true
	_ground_visual_to(abrams_root,0.045)

	var inspection_fill: OmniLight3D = OmniLight3D.new()
	inspection_fill.name = "AbramsV8InspectionFill"
	inspection_fill.position = center+Vector3(5.8,4.7,7.5)
	inspection_fill.light_color = Color(0.80,0.85,0.92)
	inspection_fill.light_energy = 3.2
	inspection_fill.omni_range = 20.0
	inspection_fill.shadow_enabled = false
	add_child(inspection_fill)

	var side_fill: OmniLight3D = OmniLight3D.new()
	side_fill.name = "AbramsV8SideFill"
	side_fill.position = center+Vector3(7.6,3.2,-1.4)
	side_fill.light_color = Color(0.90,0.91,0.86)
	side_fill.light_energy = 4.0
	side_fill.omni_range = 17.0
	side_fill.shadow_enabled = false
	add_child(side_fill)

	var hull: ShaderMaterial = _vehicle_hull_shader_v3()
	var side_skirt: ShaderMaterial = hull.duplicate() as ShaderMaterial
	side_skirt.set_shader_parameter("panel_variant",0.36)
	side_skirt.set_shader_parameter("panel_dust",1.0)
	side_skirt.set_shader_parameter("side_skirt_factor",1.35)
	var track: ShaderMaterial = _track_material_v4()
	var rubber: StandardMaterial3D = _rubber_material_v3()
	var gun: ShaderMaterial = _gun_material_v4()
	var optics: StandardMaterial3D = _optics_material()
	var exhaust: ShaderMaterial = _exhaust_material_v4()
	var layered_count: int = 0
	var body_index: int = 0

	for mi: MeshInstance3D in _collect_meshes(abrams_root):
		if mi.mesh == null:
			continue
		for surface: int in range(mi.mesh.get_surface_count()):
			var key: String = (mi.name+" "+mi.mesh.surface_get_name(surface)).to_lower()
			var source: Material = mi.mesh.surface_get_material(surface)
			var source_name: String = ""
			if source != null:
				source_name = source.resource_name.to_lower()
				key += " "+source_name
			var chosen: Material = hull
			if key.contains("wheel") or key.contains("tire") or key.contains("tyre") or key.contains("road"):
				chosen = rubber
			elif key.contains("track") or key.contains("sprocket") or key.contains("idler") or key.contains("chain"):
				chosen = track
			elif key.contains("barrel") or key.contains("gun") or key.contains("cannon"):
				chosen = gun
			elif key.contains("optic") or key.contains("glass") or key.contains("sight") or key.contains("periscope"):
				chosen = optics
			elif key.contains("exhaust") or key.contains("grille") or key.contains("grill"):
				chosen = exhaust
			elif key.contains("skirt") or key.contains("fender") or key.contains("side"):
				chosen = side_skirt
			else:
				var panel: ShaderMaterial = hull.duplicate() as ShaderMaterial
				var panel_variant: float = 0.34+0.36*float((body_index*37)%101)/100.0
				var panel_dust: float = 0.18+0.68*float((body_index*23+17)%89)/88.0
				panel.set_shader_parameter("panel_variant",panel_variant)
				panel.set_shader_parameter("panel_dust",panel_dust)
				chosen = panel
				body_index += 1
			mi.set_surface_override_material(surface,chosen)
			layered_count += 1
			print("FRONTLINE_ABRAMS_V8_SURFACE key=%s class=%s" % [key,chosen.get_class()])
	proof_checks["vehicle_surface_layers"] = layered_count > 0

	_add_vehicle_ruts(center,-18.0)
	_add_vehicle_context_v3(center)
	_add_extended_pad_v7(center,34.0)


func _add_ground_dense_vegetation_v5(center: Vector3) -> void:
	if _grass_mesh_v8 == null:
		_grass_mesh_v8 = _make_grass_mesh_v8()
	if _grass_mat_v8 == null:
		_grass_mat_v8 = _make_grass_material_v8()
	for i: int in range(118):
		var gx: float = -4.66+float((i*47+13)%197)/196.0*9.32
		var gz: float = -4.62+float((i*71+29)%211)/210.0*9.24
		var rut_near: bool = absf(gx+1.18) < 0.30 or absf(gx-1.22) < 0.30
		if rut_near and i%5 != 0:
			continue
		var node: MeshInstance3D = MeshInstance3D.new()
		node.name = "GroundGrassV8_%03d" % i
		node.mesh = _grass_mesh_v8
		node.material_override = _grass_mat_v8
		node.position = center+Vector3(gx,_ground_height_v4(gx,gz)+0.010,gz)
		node.rotation_degrees.y = 13.0+47.0*float(i)
		var s: float = 0.72+0.10*float(i%5)
		node.scale = Vector3(s,0.82+0.08*float(i%4),s)
		add_child(node)


func _make_grass_mesh_v8() -> ArrayMesh:
	var vertices: PackedVector3Array = PackedVector3Array()
	var normals: PackedVector3Array = PackedVector3Array()
	var colors: PackedColorArray = PackedColorArray()
	var indices: PackedInt32Array = PackedInt32Array()
	for i: int in range(14):
		var angle: float = float(i)*2.399963+0.31*float(i%3)
		var radial: float = 0.025+0.020*float(i%4)
		var center: Vector3 = Vector3(cos(angle)*radial,0.0,sin(angle)*radial)
		var side: Vector3 = Vector3(-sin(angle),0.0,cos(angle))
		var forward: Vector3 = Vector3(cos(angle),0.0,sin(angle))
		var height_value: float = 0.20+0.028*float((i*5)%7)
		var half_width: float = 0.013+0.0025*float(i%3)
		var bend: Vector3 = forward*(0.030+0.008*float(i%4))
		var v0: Vector3 = center-side*half_width
		var v1: Vector3 = center+side*half_width
		var v2: Vector3 = center+Vector3(0,height_value,0)+bend+side*half_width*0.18
		var v3: Vector3 = center+Vector3(0,height_value,0)+bend-side*half_width*0.18
		var base_index: int = vertices.size()
		vertices.append_array(PackedVector3Array([v0,v1,v2,v3]))
		var n: Vector3 = forward.normalized()
		normals.append_array(PackedVector3Array([n,n,n,n]))
		var tone: float = 0.82+0.035*float(i%5)
		var col: Color = Color(0.16*tone,0.40*tone,0.075*tone,1.0)
		colors.append_array(PackedColorArray([col,col,Color(col.r*1.08,col.g*1.10,col.b*1.02,1),Color(col.r*1.08,col.g*1.10,col.b*1.02,1)]))
		indices.append_array(PackedInt32Array([base_index,base_index+1,base_index+2,base_index,base_index+2,base_index+3]))
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_COLOR] = colors
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh: ArrayMesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
	return mesh


func _make_grass_material_v8() -> StandardMaterial3D:
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color.WHITE
	mat.vertex_color_use_as_albedo = true
	mat.metallic = 0.0
	mat.metallic_specular = 0.18
	mat.roughness = 0.88
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	return mat


func _capture_all() -> void:
	await _capture_view(HOUSE_SHOT_V2,Vector3(13.2,5.75,16.3),Vector3(0,2.82,0))
	await _capture_view(ABRAMS_SHOT_V2,Vector3(50.3,3.05,7.9),Vector3(45,1.22,0))
	await _capture_view(GROUND_SHOT_V2,Vector3(92.65,2.55,4.15),Vector3(90,0.0,0))
	_write_metrics_v8()
	var all_pass: bool = true
	for value: Variant in proof_checks.values():
		if not bool(value):
			all_pass = false
	print("FRONTLINE_MATERIAL_PROOF_TECH_%s" % ("PASS" if all_pass else "FAIL"))
	get_tree().quit(0 if all_pass else 63)


func _write_metrics_v8() -> void:
	var payload: Dictionary = {
		"task_id": "QUALITY_MATERIAL_PROOF_V8_GOLDEN_FRAME_CONVERGENCE",
		"engine": Engine.get_version_info().get("string","Godot"),
		"renderer": RenderingServer.get_current_rendering_method(),
		"checks": proof_checks,
		"visual_pass": false,
		"house_asset": HOUSE_STATIC_V5,
		"abrams_asset": ABRAMS_CC0_V8,
		"ground_geometry": "104x104 microterrain + opaque geometry blade grass",
		"captures": [HOUSE_SHOT_V2,ABRAMS_SHOT_V2,GROUND_SHOT_V2]
	}
	var file: FileAccess = FileAccess.open(METRICS_PATH,FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(payload,"\t")+"\n")
		file.close()
