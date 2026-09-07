extends "res://scripts/production/quality/material/quality_material_proof_v8.gd"

var _short_grass_mesh_v9: ArrayMesh
var _short_grass_mat_v9: StandardMaterial3D


func _build_house_proof() -> void:
	super._build_house_proof()
	var roof_fill: OmniLight3D = OmniLight3D.new()
	roof_fill.name = "HouseV9RoofFill"
	roof_fill.position = Vector3(-4.5,8.8,5.5)
	roof_fill.light_color = Color(0.96,0.88,0.76)
	roof_fill.light_energy = 2.4
	roof_fill.omni_range = 19.0
	roof_fill.shadow_enabled = false
	add_child(roof_fill)


func _house_material_v5(key: String) -> Material:
	if key.contains("roof"):
		return _house_roof_material_v9()
	if key.contains("glass"):
		return _house_glass_material_v9()
	return super._house_material_v5(key)


func _house_roof_material_v9() -> ShaderMaterial:
	var shader: Shader = Shader.new()
	shader.code = """
shader_type spatial;
uniform sampler2D nor_tex : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D arm_tex : repeat_enable, filter_linear_mipmap_anisotropic;
varying vec3 wp;
void vertex(){ wp=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz; }
void fragment(){
	float broad=0.5+0.5*sin(wp.x*0.74+wp.z*0.91);
	float fine=0.5+0.5*sin(wp.x*4.7-wp.z*5.3);
	vec3 dark=vec3(0.105,0.060,0.043);
	vec3 warm=vec3(0.185,0.105,0.072);
	ALBEDO=mix(dark,warm,0.24+0.38*broad+0.08*fine);
	NORMAL_MAP=texture(nor_tex,UV*3.2).rgb;
	NORMAL_MAP_DEPTH=0.55;
	vec3 arm=texture(arm_tex,UV*3.2).rgb;
	ROUGHNESS=clamp(0.72+arm.g*0.20,0.72,0.94);
	AO=clamp(arm.r,0.74,1.0);
	SPECULAR=0.24;
}
"""
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("nor_tex",load("res://assets/golden_scene/pbr/asphalt_02_nor_gl_1k.png"))
	mat.set_shader_parameter("arm_tex",load("res://assets/golden_scene/pbr/asphalt_02_arm_1k.png"))
	return mat


func _house_glass_material_v9() -> ShaderMaterial:
	var shader: Shader = Shader.new()
	shader.code = """
shader_type spatial;
void fragment(){
	float facing=clamp(dot(normalize(NORMAL),normalize(VIEW)),0.0,1.0);
	float fres=pow(1.0-facing,3.0);
	float streak=0.5+0.5*sin(UV.x*9.0+UV.y*3.0);
	vec3 deep=vec3(0.025,0.070,0.078);
	vec3 sky=vec3(0.20,0.34,0.38);
	ALBEDO=mix(deep,sky,0.20+0.52*fres+0.05*streak);
	METALLIC=0.05;
	ROUGHNESS=0.08+0.10*(1.0-fres);
	SPECULAR=0.72;
}
"""
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = shader
	return mat


func _build_abrams_proof() -> void:
	var center: Vector3 = Vector3(45,0,0)
	var yaw: float = 162.0
	_add_pad(center,Vector2(20,20))
	abrams_root = _spawn_scaled(ABRAMS_STATIC,center,8.6,yaw,"MaterialProofAbramsV9Front")
	if abrams_root == null:
		return
	proof_checks["abrams_loaded"] = true
	_ground_abrams_by_wheels(abrams_root,0.045)

	var inspection_fill: OmniLight3D = OmniLight3D.new()
	inspection_fill.name = "AbramsV9FrontFill"
	inspection_fill.position = center+Vector3(5.5,4.8,7.4)
	inspection_fill.light_color = Color(0.82,0.86,0.92)
	inspection_fill.light_energy = 3.0
	inspection_fill.omni_range = 20.0
	inspection_fill.shadow_enabled = false
	add_child(inspection_fill)

	var side_fill: OmniLight3D = OmniLight3D.new()
	side_fill.name = "AbramsV9SideFill"
	side_fill.position = center+Vector3(-4.0,3.0,6.4)
	side_fill.light_color = Color(0.91,0.88,0.80)
	side_fill.light_energy = 2.8
	side_fill.omni_range = 17.0
	side_fill.shadow_enabled = false
	add_child(side_fill)

	var hull: ShaderMaterial = _vehicle_hull_shader_v3()
	var side_skirt: ShaderMaterial = hull.duplicate() as ShaderMaterial
	side_skirt.set_shader_parameter("panel_variant",0.37)
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
			if key.contains("wheel"):
				chosen = rubber
			elif key.contains("track") or key.contains("sprocket") or key.contains("idler") or key.contains("towcable"):
				chosen = track
			elif key.contains("barrel") or key.contains("gun"):
				chosen = gun
			elif key.contains("guide") or key.contains("optic") or key.contains("glass") or key.contains("sight"):
				chosen = optics
			elif key.contains("material.001") or key.contains("sideskirt"):
				chosen = side_skirt
			elif key.contains("exhaust"):
				chosen = exhaust
			elif key.contains("body"):
				var panel: ShaderMaterial = hull.duplicate() as ShaderMaterial
				var panel_variant: float = 0.34+0.38*float((body_index*37)%101)/100.0
				var panel_dust: float = 0.18+0.70*float((body_index*23+17)%89)/88.0
				panel.set_shader_parameter("panel_variant",panel_variant)
				panel.set_shader_parameter("panel_dust",panel_dust)
				chosen = panel
				body_index += 1
			mi.set_surface_override_material(surface,chosen)
			layered_count += 1
	proof_checks["vehicle_surface_layers"] = layered_count > 0

	_add_vehicle_ruts(center,yaw)
	_add_vehicle_context_v3(center)
	_add_extended_pad_v7(center,34.0)


func _add_ground_dense_vegetation_v5(center: Vector3) -> void:
	if _short_grass_mesh_v9 == null:
		_short_grass_mesh_v9 = _make_short_grass_mesh_v9()
	if _short_grass_mat_v9 == null:
		_short_grass_mat_v9 = _make_short_grass_material_v9()

	var mm: MultiMesh = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = _short_grass_mesh_v9
	mm.instance_count = 420
	for i: int in range(420):
		var gx: float = -4.82+float((i*71+17)%421)/420.0*9.64
		var gz: float = -4.78+float((i*113+37)%431)/430.0*9.56
		var rut_near: bool = absf(gx+1.18) < 0.27 or absf(gx-1.22) < 0.27
		var sy: float = 0.78+0.055*float(i%7)
		var sxz: float = 0.76+0.045*float(i%6)
		if rut_near:
			sy *= 0.58
			sxz *= 0.72
		var angle: float = deg_to_rad(17.0+137.5*float(i))
		var basis: Basis = Basis(Vector3.UP,angle)
		basis = basis.scaled(Vector3(sxz,sy,sxz))
		var y_value: float = _ground_height_v4(gx,gz)+0.008
		mm.set_instance_transform(i,Transform3D(basis,center+Vector3(gx,y_value,gz)))
	var mmi: MultiMeshInstance3D = MultiMeshInstance3D.new()
	mmi.name = "GroundShortGrassMultiMeshV9"
	mmi.multimesh = mm
	mmi.material_override = _short_grass_mat_v9
	add_child(mmi)


func _make_short_grass_mesh_v9() -> ArrayMesh:
	var vertices: PackedVector3Array = PackedVector3Array()
	var normals: PackedVector3Array = PackedVector3Array()
	var colors: PackedColorArray = PackedColorArray()
	var indices: PackedInt32Array = PackedInt32Array()
	for i: int in range(9):
		var angle: float = float(i)*2.399963+0.23*float(i%3)
		var radial: float = 0.010+0.011*float(i%3)
		var center: Vector3 = Vector3(cos(angle)*radial,0.0,sin(angle)*radial)
		var side: Vector3 = Vector3(-sin(angle),0.0,cos(angle))
		var forward: Vector3 = Vector3(cos(angle),0.0,sin(angle))
		var height_value: float = 0.075+0.012*float((i*5)%7)
		var half_width: float = 0.0045+0.0007*float(i%3)
		var bend: Vector3 = forward*(0.012+0.004*float(i%3))
		var v0: Vector3 = center-side*half_width
		var v1: Vector3 = center+side*half_width
		var v2: Vector3 = center+Vector3(0,height_value,0)+bend+side*half_width*0.12
		var v3: Vector3 = center+Vector3(0,height_value,0)+bend-side*half_width*0.12
		var base_index: int = vertices.size()
		vertices.append_array(PackedVector3Array([v0,v1,v2,v3]))
		var n: Vector3 = forward.normalized()
		normals.append_array(PackedVector3Array([n,n,n,n]))
		var tone: float = 0.82+0.030*float(i%5)
		var col: Color = Color(0.13*tone,0.36*tone,0.060*tone,1.0)
		colors.append_array(PackedColorArray([col,col,Color(col.r*1.06,col.g*1.10,col.b*1.04,1),Color(col.r*1.06,col.g*1.10,col.b*1.04,1)]))
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


func _make_short_grass_material_v9() -> StandardMaterial3D:
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color.WHITE
	mat.vertex_color_use_as_albedo = true
	mat.metallic = 0.0
	mat.metallic_specular = 0.16
	mat.roughness = 0.90
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	return mat


func _capture_all() -> void:
	await _capture_view(HOUSE_SHOT_V2,Vector3(13.2,5.75,16.3),Vector3(0,2.82,0))
	await _capture_view(ABRAMS_SHOT_V2,Vector3(50.3,3.00,7.9),Vector3(45,1.18,0))
	await _capture_view(GROUND_SHOT_V2,Vector3(92.45,2.25,4.05),Vector3(90,0.0,0))
	_write_metrics_v9()
	var all_pass: bool = true
	for value: Variant in proof_checks.values():
		if not bool(value):
			all_pass = false
	print("FRONTLINE_MATERIAL_PROOF_TECH_%s" % ("PASS" if all_pass else "FAIL"))
	get_tree().quit(0 if all_pass else 63)


func _write_metrics_v9() -> void:
	var payload: Dictionary = {
		"task_id": "QUALITY_MATERIAL_PROOF_V9_GOLDEN_FRAME_CONVERGENCE",
		"engine": Engine.get_version_info().get("string","Godot"),
		"renderer": RenderingServer.get_current_rendering_method(),
		"checks": proof_checks,
		"visual_pass": false,
		"house_asset": HOUSE_STATIC_V5,
		"abrams_asset": ABRAMS_STATIC,
		"ground_geometry": "104x104 microterrain + 420-instance short-grass MultiMesh",
		"captures": [HOUSE_SHOT_V2,ABRAMS_SHOT_V2,GROUND_SHOT_V2]
	}
	var file: FileAccess = FileAccess.open(METRICS_PATH,FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(payload,"\t")+"\n")
		file.close()
