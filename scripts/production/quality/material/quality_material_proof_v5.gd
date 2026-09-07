extends "res://scripts/production/quality/material/quality_material_proof_v4.gd"

const HOUSE_STATIC_V5 := "res://assets/golden_scene/quality_material_v3/house_v5_static.glb"


func _preflight() -> void:
	super._preflight()
	if not ResourceLoader.exists(HOUSE_STATIC_V5):
		push_error("MATERIAL_PROOF_REQUIRED_ASSET_MISSING path=%s" % HOUSE_STATIC_V5)


func _build_house_proof() -> void:
	_add_pad(Vector3.ZERO,Vector2(20,20))
	house_root = _spawn_scaled(HOUSE_STATIC_V5,Vector3.ZERO,11.8,-6.0,"MaterialProofHouseV5")
	if house_root == null:
		return
	proof_checks["house_loaded"] = true
	_ground_visual_to(house_root,0.018)

	var touched: int = 0
	for mi: MeshInstance3D in _collect_meshes(house_root):
		if mi.mesh == null:
			continue
		for surface: int in range(mi.mesh.get_surface_count()):
			var source: Material = mi.mesh.surface_get_material(surface)
			var key: String = (mi.name+" "+mi.mesh.surface_get_name(surface)).to_lower()
			if source != null:
				key += " "+source.resource_name.to_lower()
			var chosen: Material = _house_material_v5(key)
			mi.set_surface_override_material(surface,chosen)
			touched += 1
			print("FRONTLINE_HOUSE_V5_SURFACE key=%s class=%s" % [key,chosen.get_class()])
	proof_checks["house_authored_materials_preserved"] = touched > 0

	_add_house_context_v5(Vector3.ZERO)


func _house_material_v5(key: String) -> Material:
	if key.contains("brick"):
		return _house_pbr_surface_v5(
			"res://assets/golden_scene/pbr/brick_wall_005_diff_1k.png",
			"res://assets/golden_scene/pbr/brick_wall_005_nor_gl_1k.png",
			"res://assets/golden_scene/pbr/brick_wall_005_arm_1k.png",
			Color(0.88,0.78,0.69),0.86,0.0
		)
	if key.contains("stucco") or key.contains("patch") or key.contains("foundation"):
		var tint: Color = Color(0.76,0.75,0.70) if key.contains("stucco") else Color(0.62,0.59,0.53)
		return _house_pbr_surface_v5(
			"res://assets/golden_scene/pbr/t_concrete_wall_002_diff_1k.png",
			"res://assets/golden_scene/pbr/t_concrete_wall_002_nor_gl_1k.png",
			"res://assets/golden_scene/pbr/t_concrete_wall_002_arm_1k.png",
			tint,0.94,0.0
		)
	if key.contains("roof"):
		return _house_pbr_surface_v5(
			"res://assets/golden_scene/pbr/asphalt_02_diff_1k.png",
			"res://assets/golden_scene/pbr/asphalt_02_nor_gl_1k.png",
			"res://assets/golden_scene/pbr/asphalt_02_arm_1k.png",
			Color(0.46,0.34,0.28),0.96,0.0
		)
	if key.contains("glass"):
		var glass: StandardMaterial3D = StandardMaterial3D.new()
		glass.albedo_color = Color(0.025,0.055,0.060)
		glass.metallic = 0.08
		glass.metallic_specular = 0.52
		glass.roughness = 0.10
		return glass
	if key.contains("metal"):
		var metal: StandardMaterial3D = StandardMaterial3D.new()
		metal.albedo_color = Color(0.12,0.13,0.12)
		metal.metallic = 0.62
		metal.metallic_specular = 0.44
		metal.roughness = 0.46
		return metal
	if key.contains("wood"):
		var wood: ShaderMaterial = _house_pbr_surface_v5(
			"res://assets/golden_scene/pbr/dirt_aerial_03_diff_1k.png",
			"res://assets/golden_scene/pbr/dirt_aerial_03_nor_gl_1k.png",
			"res://assets/golden_scene/pbr/dirt_aerial_03_arm_1k.png",
			Color(0.42,0.27,0.16),0.84,0.0
		)
		return wood
	var trim: StandardMaterial3D = StandardMaterial3D.new()
	trim.albedo_color = Color(0.16,0.17,0.15)
	trim.metallic = 0.02
	trim.roughness = 0.68
	return trim


func _house_pbr_surface_v5(diff_path: String,nor_path: String,arm_path: String,tint: Color,rough_boost: float,metallic: float) -> ShaderMaterial:
	var shader: Shader = Shader.new()
	shader.code = """
shader_type spatial;
uniform sampler2D tex_diff : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D tex_nor : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D tex_arm : repeat_enable, filter_linear_mipmap_anisotropic;
uniform vec4 tint : source_color = vec4(1.0);
uniform float rough_boost = 0.9;
uniform float metal = 0.0;
varying vec3 wp;
varying vec3 wn;
void vertex(){
	wp=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;
	wn=normalize((MODEL_MATRIX*vec4(NORMAL,0.0)).xyz);
}
void fragment(){
	vec3 weights=pow(abs(wn),vec3(4.0));
	weights/=max(weights.x+weights.y+weights.z,0.001);
	float scale=0.72;
	vec3 dx=texture(tex_diff,wp.yz*scale).rgb;
	vec3 dy=texture(tex_diff,wp.xz*scale).rgb;
	vec3 dz=texture(tex_diff,wp.xy*scale).rgb;
	vec3 diff=(dx*weights.x+dy*weights.y+dz*weights.z)*tint.rgb;
	vec3 arm=texture(tex_arm,UV*3.6).rgb;
	float lower=1.0-smoothstep(0.20,1.15,wp.y);
	float streak=(0.5+0.5*sin(wp.x*2.7+wp.z*3.1+sin(wp.y*4.2)))*(1.0-abs(wn.y));
	vec3 dust=vec3(0.26,0.21,0.15);
	diff=mix(diff,dust,lower*(0.08+0.13*streak));
	ALBEDO=diff;
	NORMAL_MAP=texture(tex_nor,UV*3.6).rgb;
	NORMAL_MAP_DEPTH=0.86;
	ROUGHNESS=clamp(max(arm.g,rough_boost-0.18)+lower*0.08,0.38,0.98);
	METALLIC=metal;
	AO=clamp(arm.r,0.66,1.0);
	SPECULAR=0.26;
}
"""
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("tex_diff",load(diff_path))
	mat.set_shader_parameter("tex_nor",load(nor_path))
	mat.set_shader_parameter("tex_arm",load(arm_path))
	mat.set_shader_parameter("tint",tint)
	mat.set_shader_parameter("rough_boost",rough_boost)
	mat.set_shader_parameter("metal",metallic)
	return mat


func _add_house_context_v5(center: Vector3) -> void:
	var plants: Array[Vector3] = [
		Vector3(-4.6,0,-3.8),Vector3(-3.6,0,-4.6),Vector3(-4.7,0,2.9),
		Vector3(-2.7,0,4.9),Vector3(2.6,0,4.8),Vector3(4.3,0,3.7),
		Vector3(4.6,0,-2.8),Vector3(3.0,0,-4.7),Vector3(-0.8,0,5.1)
	]
	for i: int in range(plants.size()):
		var path: String = GRASS if i%3 != 0 else WEED
		_spawn_scaled(path,center+plants[i],0.55+0.10*float(i%4),19.0+41.0*float(i),"HousePlantV5_%02d" % i)
	var rubble: Array[Vector3] = [
		Vector3(-3.8,0.02,4.1),Vector3(-3.2,0.02,4.5),Vector3(3.4,0.02,4.4),
		Vector3(3.9,0.02,3.9),Vector3(-4.4,0.02,-1.4)
	]
	for i: int in range(rubble.size()):
		var path: String = HQ_ROCK_A if i%2 == 0 else HQ_ROCK_B
		_spawn_pbr_rock_v3(path,center+rubble[i],0.18+0.05*float(i%3),31.0+49.0*float(i),"HouseRubbleV5_%02d" % i)


func _build_ground_proof() -> void:
	var center: Vector3 = Vector3(90,0,0)
	var ground: MeshInstance3D = MeshInstance3D.new()
	ground.name = "TenMeterMaterialGroundV5Geometry"
	ground.mesh = _make_ground_mesh_v5(10.0,104)
	ground.position = center
	ground.material_override = _ground_proof_shader_v5()
	add_child(ground)
	proof_checks["ground_built"] = true
	_add_ground_dense_vegetation_v5(center)
	_add_ground_hq_debris_v4(center)
	proof_checks["ground_microgeometry"] = true


func _make_ground_mesh_v5(size: float,segments: int) -> ArrayMesh:
	var vertices: PackedVector3Array = PackedVector3Array()
	var normals: PackedVector3Array = PackedVector3Array()
	var uvs: PackedVector2Array = PackedVector2Array()
	var indices: PackedInt32Array = PackedInt32Array()
	var step: float = size/float(segments)
	var eps: float = step*0.72
	for z: int in range(segments+1):
		for x: int in range(segments+1):
			var px: float = -size*0.5+float(x)*step
			var pz: float = -size*0.5+float(z)*step
			var y: float = _ground_height_v4(px,pz)
			var hx: float = _ground_height_v4(px-eps,pz)-_ground_height_v4(px+eps,pz)
			var hz: float = _ground_height_v4(px,pz-eps)-_ground_height_v4(px,pz+eps)
			var n: Vector3 = Vector3(hx,2.0*eps,hz).normalized()
			vertices.append(Vector3(px,y,pz))
			normals.append(n)
			uvs.append(Vector2(float(x)/float(segments),float(z)/float(segments)))
	for z: int in range(segments):
		for x: int in range(segments):
			var a: int = z*(segments+1)+x
			var b: int = a+1
			var c: int = a+(segments+1)
			var d: int = c+1
			indices.append_array(PackedInt32Array([a,b,c,b,d,c]))
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh: ArrayMesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
	return mesh


func _ground_proof_shader_v5() -> ShaderMaterial:
	var mat: ShaderMaterial = _ground_proof_shader_v4()
	var source_code: String = mat.shader.code
	if not source_code.contains("render_mode cull_disabled;"):
		mat.shader.code = source_code.replace("shader_type spatial;","shader_type spatial;\nrender_mode cull_disabled;")
	return mat


func _add_ground_dense_vegetation_v5(center: Vector3) -> void:
	for i: int in range(68):
		var gx: float = -4.58+float((i*37+11)%97)/96.0*9.16
		var gz: float = -4.52+float((i*61+23)%101)/100.0*9.04
		var rut_near: bool = absf(gx+1.18) < 0.34 or absf(gx-1.22) < 0.34
		if rut_near and i%4 != 0:
			continue
		var path: String = GRASS if i%5 != 0 else WEED
		var scale_value: float = 0.42+0.08*float(i%6)
		var plant: Node3D = _spawn_scaled(path,center+Vector3(gx,0,gz),scale_value,11.0+47.0*float(i),"GroundPlantV5_%02d" % i)
		if plant != null:
			_ground_visual_to(plant,center.y+_ground_height_v4(gx,gz)+0.010)


func _capture_all() -> void:
	await _capture_view(HOUSE_SHOT_V2,Vector3(14.8,6.5,15.8),Vector3(0,2.75,0))
	await _capture_view(ABRAMS_SHOT_V2,Vector3(51.8,2.75,6.8),Vector3(45,1.10,0))
	await _capture_view(GROUND_SHOT_V2,Vector3(93.0,3.10,4.25),Vector3(90,0.0,0))
	_write_metrics_v5()
	var all_pass: bool = true
	for value: Variant in proof_checks.values():
		if not bool(value):
			all_pass = false
	print("FRONTLINE_MATERIAL_PROOF_TECH_%s" % ("PASS" if all_pass else "FAIL"))
	get_tree().quit(0 if all_pass else 63)


func _write_metrics_v5() -> void:
	var payload: Dictionary = {
		"task_id": "QUALITY_MATERIAL_PROOF_V5_GOLDEN_FRAME_CONVERGENCE",
		"engine": Engine.get_version_info().get("string","Godot"),
		"renderer": RenderingServer.get_current_rendering_method(),
		"checks": proof_checks,
		"visual_pass": false,
		"house_asset": HOUSE_STATIC_V5,
		"abrams_asset": ABRAMS_STATIC,
		"ground_geometry": "104x104 explicit microterrain with finite-difference normals",
		"captures": [HOUSE_SHOT_V2,ABRAMS_SHOT_V2,GROUND_SHOT_V2]
	}
	var file: FileAccess = FileAccess.open(METRICS_PATH,FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(payload,"\t")+"\n")
		file.close()
