extends "res://scripts/production/quality/quality_test_world_v2.gd"

func _build_environment() -> void:
	super._build_environment()
	var env_node := get_node_or_null("QualityEnvironment") as WorldEnvironment
	if env_node != null and env_node.environment != null:
		var env := env_node.environment
		env.background_energy_multiplier = 0.72
		env.ambient_light_energy = 0.38
		env.fog_density = 0.0030
		env.fog_aerial_perspective = 0.42
	var sun := get_node_or_null("QualityKeySun") as DirectionalLight3D
	if sun != null:
		sun.light_energy = 1.30


func _build_ground() -> void:
	var ground := MeshInstance3D.new()
	ground.name = "QualityTerrainEnvelope"
	var plane := PlaneMesh.new()
	plane.size = Vector2(210.0, 150.0)
	plane.subdivide_width = 80
	plane.subdivide_depth = 56
	ground.mesh = plane
	var ground_mat := _ground_material()
	var code := ground_mat.shader.code
	code = code.replace(
		"grass * vec3(0.72,0.80,0.62)",
		"grass * vec3(0.43,0.56,0.34)"
	)
	code = code.replace(
		"dirt * vec3(0.75,0.64,0.49)",
		"dirt * vec3(0.56,0.46,0.33)"
	)
	ground_mat.shader.code = code
	ground.material_override = ground_mat
	add_child(ground)

	_add_soft_road(Vector3(7.0,0.072,-1.0),Vector2(7.8,118.0),-9.0)
	_add_masked_patch("BattleMud",Vector3(17.0,0.084,-4.0),Vector2(16.0,11.0),-5.0,
		"aerial_mud_1",Color(0.34,0.27,0.20))


func _build_trees() -> void:
	var placements: Array = [
		[TREE_A,Vector3(31,0,-18),11.8,12.0],
		[TREE_B,Vector3(37,0,-7),12.8,78.0],
		[TREE_C,Vector3(34,0,8),11.5,164.0],
		[TREE_A,Vector3(29,0,21),12.2,244.0],
		[TREE_B,Vector3(-25,0,-17),13.0,310.0],
		[TREE_C,Vector3(-31,0,3),10.8,28.0],
		[TREE_A,Vector3(42,0,20),11.4,206.0],
	]
	for i: int in range(placements.size()):
		var d: Array = placements[i]
		var tree := _add_asset(d[0],d[1],d[2],d[3],"QualityTree_%02d" % i)
		if tree != null:
			_apply_tree_materials(tree,i)
		tree_count += 1


func _build_camera() -> void:
	camera = Camera3D.new()
	camera.name = "QualityCamera"
	camera.fov = 46.0
	camera.position = Vector3(-25.5,17.5,27.5)
	add_child(camera)
	camera.look_at(Vector3(7.0,1.25,1.0),Vector3.UP)
	camera.current = true


func _vehicle_material(color: Color, metallic_value: float) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.metallic = metallic_value
	mat.metallic_specular = 0.34
	mat.roughness = 0.74
	return mat


func _apply_tree_materials(root: Node3D, variant: int) -> void:
	var bark := StandardMaterial3D.new()
	bark.albedo_color = Color(0.16,0.105,0.060)
	bark.roughness = 0.96
	var leaves := StandardMaterial3D.new()
	var leaf_colors := [
		Color(0.085,0.14,0.050),
		Color(0.11,0.17,0.060),
		Color(0.075,0.12,0.045),
	]
	leaves.albedo_color = leaf_colors[variant % leaf_colors.size()]
	leaves.roughness = 0.94
	leaves.cull_mode = BaseMaterial3D.CULL_DISABLED
	for item: Node in root.find_children("*","MeshInstance3D",true,false):
		var mi := item as MeshInstance3D
		if mi == null or mi.mesh == null:
			continue
		for surface: int in range(mi.mesh.get_surface_count()):
			var key: String = (str(mi.name) + " " + str(mi.mesh.surface_get_name(surface))).to_lower()
			var src := mi.mesh.surface_get_material(surface)
			if src != null:
				key += " " + src.resource_name.to_lower()
			var chosen: Material = leaves
			if key.contains("bark") or key.contains("trunk") or key.contains("wood") or key.contains("branch"):
				chosen = bark
			mi.set_surface_override_material(surface,chosen)


func _add_soft_road(p: Vector3, size: Vector2, yaw: float) -> void:
	var node := MeshInstance3D.new()
	node.name = "SoftVillageRoad"
	var plane := PlaneMesh.new()
	plane.size = size
	plane.subdivide_depth = 20
	node.mesh = plane
	node.position = p
	node.rotation_degrees.y = yaw
	var shader := Shader.new()
	shader.code = """
shader_type spatial;
render_mode blend_mix, depth_prepass_alpha, cull_back;
uniform sampler2D road_tex : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
void fragment() {
	float lateral = abs(UV.x - 0.5) * 2.0;
	float edge = 1.0 - smoothstep(0.76,1.0,lateral);
	vec3 tex = texture(road_tex,UV * vec2(3.0,18.0)).rgb;
	ALBEDO = tex * vec3(0.48,0.43,0.34);
	ROUGHNESS = 0.94;
	ALPHA = edge;
}
"""
	var mat := ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("road_tex",load("res://assets/golden_scene/pbr/grass_path_3_diff_1k.png"))
	node.material_override = mat
	add_child(node)
