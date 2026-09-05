class_name GoldenWorldV20Terrain
extends RefCounted

static func apply(world: GoldenWorldV1) -> void:
	if world._terrain_material == null or world._terrain_material.shader == null:
		return
	var code := world._terrain_material.shader.code
	code = code.replace(
		"vec3 grass_macro = mix(vec3(0.13, 0.225, 0.075), vec3(0.205, 0.31, 0.115), broad);",
		"vec3 grass_macro = mix(vec3(0.085, 0.145, 0.050), vec3(0.155, 0.225, 0.080), broad);"
	)
	code = code.replace(
		"vec3 g = mix(grass_macro, g_tex, 0.46);",
		"vec3 g = mix(grass_macro, g_tex, 0.64);"
	)
	code = code.replace(
		"vec3 d = mix(vec3(0.225, 0.175, 0.105), d_tex, 0.48);",
		"vec3 d = mix(vec3(0.19, 0.135, 0.075), d_tex, 0.62);"
	)
	code = code.replace(
		"vec3 m = mix(vec3(0.18, 0.145, 0.095), m_tex, 0.52);",
		"vec3 m = mix(vec3(0.13, 0.105, 0.070), m_tex, 0.66);"
	)
	code = code.replace(
		"NORMAL_MAP_DEPTH = 0.34;",
		"NORMAL_MAP_DEPTH = 0.48;"
	)
	world._terrain_material.shader.code = code


static func apply_environment(world: GoldenWorldV1) -> void:
	var env_node := world.get_node_or_null("GoldenWorldEnvironment") as WorldEnvironment
	if env_node != null and env_node.environment != null:
		var env := env_node.environment
		env.background_energy_multiplier = 0.96
		env.ambient_light_color = Color(0.42,0.46,0.48)
		env.ambient_light_energy = 0.48
		env.fog_light_color = Color(0.46,0.50,0.50)
		env.fog_light_energy = 0.56
		env.fog_density = 0.00115
		env.fog_height_density = 0.0075
		env.fog_aerial_perspective = 0.27
	var sun := world.get_node_or_null("MorningSun") as DirectionalLight3D
	if sun != null:
		sun.light_energy = 1.72
