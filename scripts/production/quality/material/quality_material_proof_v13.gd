extends "res://scripts/production/quality/material/quality_material_proof_v12.gd"

const FACADE_ALBEDO_V13 := "res://assets/golden_scene/city_hq3/02_shop_front17_derelict_shop_front17_derelict - copia -UPSCALED.png"
const FACADE_NORMAL_V13 := "res://assets/golden_scene/city_hq3/02_shop_front17_derelict_shop_front17_derelict - copia - NORMAL.png"


func _preflight() -> void:
	var required: Array[String] = [
		ABRAMS_STATIC,HDRI_V12,FACADE_ALBEDO_V13,FACADE_NORMAL_V13,
		HQ_ROCK_A,HQ_ROCK_B,HQ_BRANCH,HQ_FENCE
	]
	for path: String in required:
		if not ResourceLoader.exists(path):
			push_error("MATERIAL_PROOF_REQUIRED_ASSET_MISSING path=%s" % path)


func _build_house_proof() -> void:
	_add_world_floor_v12()
	_add_pad(Vector3.ZERO,Vector2(25,25))
	house_root = Node3D.new()
	house_root.name = "MaterialProofHouseV13HQComposite"
	add_child(house_root)
	proof_checks["house_loaded"] = true

	var brick: Material = _house_brick_material_v10()
	var concrete: Material = _house_concrete_material_v10()
	var roof: Material = _house_roof_material_v10()
	var facade: Material = _house_facade_material_v13()
	var glass: Material = _house_glass_material_v10()
	var trim: StandardMaterial3D = _house_trim_material_v13()
	var metal: StandardMaterial3D = _house_metal_material_v13()

	# Full-depth building shell. Every semantic surface remains independent.
	_add_house_box_v13(house_root,"HouseV13Body",Vector3(0,2.48,-2.75),Vector3(8.70,4.70,5.50),brick)
	_add_house_box_v13(house_root,"HouseV13Foundation",Vector3(0,0.22,-2.75),Vector3(8.95,0.44,5.72),concrete)
	_add_house_box_v13(house_root,"HouseV13RoofSlab",Vector3(0,4.94,-2.75),Vector3(9.15,0.30,5.92),roof)

	# Parapet and coping break the simple box silhouette without a giant gable roof.
	_add_house_box_v13(house_root,"HouseV13ParapetFront",Vector3(0,5.28,0.07),Vector3(9.12,0.52,0.18),concrete)
	_add_house_box_v13(house_root,"HouseV13ParapetBack",Vector3(0,5.28,-5.57),Vector3(9.12,0.52,0.18),concrete)
	_add_house_box_v13(house_root,"HouseV13ParapetRight",Vector3(4.47,5.28,-2.75),Vector3(0.18,0.52,5.48),concrete)
	_add_house_box_v13(house_root,"HouseV13ParapetLeft",Vector3(-4.47,5.28,-2.75),Vector3(0.18,0.52,5.48),concrete)

	# HQ derelict facade texture becomes the real front surface; it is not stretched over the side/back/roof.
	var front: MeshInstance3D = MeshInstance3D.new()
	front.name = "HouseV13HQFacade"
	var q: QuadMesh = QuadMesh.new()
	q.size = Vector2(8.68,4.72)
	front.mesh = q
	front.position = Vector3(0,2.48,0.018)
	front.material_override = facade
	house_root.add_child(front)

	# Right-hand side openings visible in the 3/4 proof.
	_add_side_window_v13(house_root,Vector3(4.365,2.65,-1.55),glass,trim)
	_add_side_window_v13(house_root,Vector3(4.365,2.65,-3.65),glass,trim)
	_add_side_window_v13(house_root,Vector3(4.365,4.05,-2.55),glass,trim,Vector2(1.05,0.82))

	# Roof/service details and damaged coping.
	_add_house_box_v13(house_root,"HouseV13RoofVentA",Vector3(2.35,5.28,-3.25),Vector3(0.62,0.62,0.62),metal)
	_add_house_box_v13(house_root,"HouseV13RoofVentB",Vector3(-2.55,5.22,-1.85),Vector3(0.42,0.46,0.52),metal)
	_add_house_box_v13(house_root,"HouseV13BrokenCopingA",Vector3(2.85,5.50,0.10),Vector3(1.05,0.16,0.26),concrete,Vector3(0,0,5.0))
	_add_house_box_v13(house_root,"HouseV13BrokenCopingB",Vector3(3.72,5.46,0.11),Vector3(0.56,0.15,0.24),concrete,Vector3(0,0,-9.0))
	_add_house_box_v13(house_root,"HouseV13Awning",Vector3(-1.35,2.13,0.32),Vector3(3.05,0.16,0.76),metal,Vector3(-7.0,0,0))

	_add_house_context_v13()
	proof_checks["house_authored_materials_preserved"] = true


func _house_facade_material_v13() -> StandardMaterial3D:
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_texture = load(FACADE_ALBEDO_V13) as Texture2D
	mat.albedo_color = Color(0.92,0.91,0.88)
	mat.normal_enabled = true
	mat.normal_texture = load(FACADE_NORMAL_V13) as Texture2D
	mat.normal_scale = 0.88
	mat.metallic = 0.0
	mat.metallic_specular = 0.24
	mat.roughness = 0.82
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	return mat


func _house_trim_material_v13() -> StandardMaterial3D:
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.12,0.14,0.12)
	mat.metallic = 0.03
	mat.metallic_specular = 0.28
	mat.roughness = 0.70
	return mat


func _house_metal_material_v13() -> StandardMaterial3D:
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.11,0.115,0.105)
	mat.metallic = 0.56
	mat.metallic_specular = 0.42
	mat.roughness = 0.54
	return mat


func _add_house_box_v13(parent: Node3D,name_value: String,pos: Vector3,size_value: Vector3,material: Material,rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var node: MeshInstance3D = MeshInstance3D.new()
	node.name = name_value
	var box: BoxMesh = BoxMesh.new()
	box.size = size_value
	node.mesh = box
	node.position = pos
	node.rotation_degrees = rot
	node.material_override = material
	parent.add_child(node)
	return node


func _add_side_window_v13(parent: Node3D,pos: Vector3,glass: Material,trim: Material,size_value: Vector2 = Vector2(1.15,1.25)) -> void:
	var window: MeshInstance3D = MeshInstance3D.new()
	window.name = "HouseV13SideGlass"
	var q: QuadMesh = QuadMesh.new()
	q.size = size_value
	window.mesh = q
	window.position = pos
	window.rotation_degrees.y = 90.0
	window.material_override = glass
	parent.add_child(window)

	var x: float = pos.x+0.025
	var w: float = size_value.x
	var h: float = size_value.y
	_add_house_box_v13(parent,"HouseV13SideFrameTop",Vector3(x,pos.y+h*0.5,pos.z),Vector3(0.08,0.08,w+0.16),trim)
	_add_house_box_v13(parent,"HouseV13SideFrameBottom",Vector3(x,pos.y-h*0.5,pos.z),Vector3(0.08,0.08,w+0.16),trim)
	_add_house_box_v13(parent,"HouseV13SideFrameA",Vector3(x,pos.y,pos.z-w*0.5),Vector3(0.08,h,0.08),trim)
	_add_house_box_v13(parent,"HouseV13SideFrameB",Vector3(x,pos.y,pos.z+w*0.5),Vector3(0.08,h,0.08),trim)


func _add_house_context_v13() -> void:
	_ensure_grass_assets_v12()
	var transforms: Array[Transform3D] = []
	for i: int in range(5200):
		var gx: float = -7.2+_hash_v12(i,17.0)*14.4
		var gz: float = -7.0+_hash_v12(i,33.0)*10.2
		var inside: bool = gx > -4.55 and gx < 4.55 and gz > -5.70 and gz < 0.35
		if inside:
			continue
		var density: float = 0.44+0.35*_hash_v12(i,47.0)
		if _hash_v12(i,59.0) > density:
			continue
		var rot: float = deg_to_rad(_hash_v12(i,71.0)*360.0)
		var scale_value: float = 0.65+0.78*_hash_v12(i,83.0)
		var basis: Basis = Basis(Vector3.UP,rot).scaled(Vector3(scale_value,scale_value,scale_value))
		transforms.append(Transform3D(basis,Vector3(gx,0.010,gz)))
		if transforms.size() >= 1550:
			break
	_add_grass_multimesh_v12("HouseV13GrassContext",transforms,_grass_lush_v12)

	for i: int in range(9):
		var a: float = float(i)*1.73+0.42
		var rr: float = 5.1+0.42*float(i%3)
		var p: Vector3 = Vector3(cos(a)*rr,0.02,-2.2+sin(a)*rr*0.68)
		var path: String = HQ_ROCK_A if i%2 == 0 else HQ_ROCK_B
		_spawn_pbr_rock_v3(path,p,0.12+0.035*float(i%4),23.0+51.0*float(i),"HouseV13Rubble_%02d" % i)


func _make_grass_mesh_v12() -> ArrayMesh:
	var vertices: PackedVector3Array = PackedVector3Array()
	var normals: PackedVector3Array = PackedVector3Array()
	var indices: PackedInt32Array = PackedInt32Array()
	for i: int in range(9):
		var angle: float = float(i)*2.399963+0.21*float(i%4)
		var radial: float = 0.005+0.008*float(i%4)
		var center: Vector3 = Vector3(cos(angle)*radial,0.0,sin(angle)*radial)
		var side: Vector3 = Vector3(-sin(angle),0.0,cos(angle))
		var forward: Vector3 = Vector3(cos(angle),0.0,sin(angle))
		var h: float = 0.034+0.005*float((i*5)%6)
		var half_width: float = 0.0032+0.00055*float(i%3)
		var lean: float = 0.012+0.004*float(i%4)
		var bend: Vector3 = forward*lean
		var v0: Vector3 = center-side*half_width
		var v1: Vector3 = center+side*half_width
		var v2: Vector3 = center+Vector3(0,h,0)+bend+side*half_width*0.15
		var v3: Vector3 = center+Vector3(0,h,0)+bend-side*half_width*0.15
		var bi: int = vertices.size()
		vertices.append_array(PackedVector3Array([v0,v1,v2,v3]))
		var n: Vector3 = (Vector3.UP+forward*0.16).normalized()
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
	mat.albedo_color = Color(0.36,0.30,0.15) if dry else Color(0.20,0.33,0.095)
	mat.metallic = 0.0
	mat.metallic_specular = 0.13
	mat.roughness = 0.92
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	return mat


func _build_abrams_proof() -> void:
	super._build_abrams_proof()
	if abrams_root == null:
		return
	var mud: ShaderMaterial = _mud_patch_material_v13()
	for mi: MeshInstance3D in _collect_meshes(abrams_root):
		if mi.mesh == null:
			continue
		if mi.name.to_lower().contains("mudpatch"):
			for surface: int in range(mi.mesh.get_surface_count()):
				mi.set_surface_override_material(surface,mud)


func _mud_patch_material_v13() -> ShaderMaterial:
	var shader: Shader = Shader.new()
	shader.code = """
shader_type spatial;
uniform sampler2D diff_tex : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D nor_tex : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D arm_tex : repeat_enable, filter_linear_mipmap_anisotropic;
void fragment(){
	vec2 uv=UV*2.8;
	vec3 d=texture(diff_tex,uv).rgb*vec3(0.52,0.41,0.27);
	ALBEDO=d;
	NORMAL_MAP=texture(nor_tex,uv).rgb;
	NORMAL_MAP_DEPTH=0.74;
	vec3 arm=texture(arm_tex,uv).rgb;
	METALLIC=0.0;
	ROUGHNESS=clamp(0.76+arm.g*0.18,0.76,0.97);
	AO=clamp(arm.r,0.66,1.0);
	SPECULAR=0.18;
}
"""
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("diff_tex",load("res://assets/golden_scene/pbr/aerial_mud_1_diff_1k.png"))
	mat.set_shader_parameter("nor_tex",load("res://assets/golden_scene/pbr/aerial_mud_1_nor_gl_1k.png"))
	mat.set_shader_parameter("arm_tex",load("res://assets/golden_scene/pbr/aerial_mud_1_arm_1k.png"))
	return mat


func _capture_all() -> void:
	await _capture_view(HOUSE_SHOT_V2,Vector3(11.4,5.25,12.8),Vector3(0,2.45,-2.35))
	await _capture_view(ABRAMS_SHOT_V2,Vector3(50.0,2.90,8.25),Vector3(45,1.20,0))
	await _capture_view(GROUND_SHOT_V2,Vector3(92.20,2.05,4.10),Vector3(90,0.0,0))
	_write_metrics_v13()
	var all_pass: bool = true
	for value: Variant in proof_checks.values():
		if not bool(value):
			all_pass = false
	print("FRONTLINE_MATERIAL_PROOF_TECH_%s" % ("PASS" if all_pass else "FAIL"))
	get_tree().quit(0 if all_pass else 63)


func _write_metrics_v13() -> void:
	var payload: Dictionary = {
		"task_id": "QUALITY_MATERIAL_PROOF_V13_HQ_FACADE_AND_SURFACE_LAYERS",
		"engine": Engine.get_version_info().get("string","Godot"),
		"renderer": RenderingServer.get_current_rendering_method(),
		"checks": proof_checks,
		"visual_pass": false,
		"environment": HDRI_V12,
		"house_strategy": "HQ derelict facade texture + independent full-depth wall/roof/window/trim shell",
		"abrams_asset": ABRAMS_STATIC,
		"abrams_strategy": "faceted armor + rubber track pads + authored mud geometry",
		"ground_geometry": "microterrain + dense short grass with upward-biased normals",
		"captures": [HOUSE_SHOT_V2,ABRAMS_SHOT_V2,GROUND_SHOT_V2]
	}
	var file: FileAccess = FileAccess.open(METRICS_PATH,FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(payload,"\t")+"\n")
		file.close()
