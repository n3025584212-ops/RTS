class_name GoldenWorldV17Materials
extends RefCounted

static func apply(world: GoldenWorldV1) -> void:
	world._building_materials = [
		world._surface_detail_material("t_concrete_wall_002", Color(0.46, 0.43, 0.35), 0.28),
		world._surface_detail_material("t_concrete_wall_002", Color(0.58, 0.50, 0.39), 0.30),
		world._surface_detail_material("brick_wall_005", Color(0.47, 0.29, 0.18), 0.34),
		world._surface_detail_material("t_concrete_wall_002", Color(0.36, 0.39, 0.39), 0.26),
	]
	world._roof_materials = [
		world._surface_detail_material("brick_wall_005", Color(0.18, 0.10, 0.065), 0.30),
		world._surface_detail_material("brick_wall_005", Color(0.105, 0.115, 0.115), 0.28),
		world._surface_detail_material("t_concrete_wall_002", Color(0.17, 0.16, 0.14), 0.24),
	]
	world._church_wall_material = world._surface_detail_material(
		"t_concrete_wall_002", Color(0.62, 0.57, 0.47), 0.31
	)

	if world._road_material != null:
		world._road_material.albedo_color = Color(0.39, 0.40, 0.38)
	if world._dirt_road_material != null:
		world._dirt_road_material.albedo_color = Color(0.39, 0.33, 0.23)
	if world._shoulder_material != null:
		world._shoulder_material.albedo_color = Color(0.32, 0.30, 0.27)
	if world._bank_material != null:
		world._bank_material.albedo_color = Color(0.53, 0.43, 0.31)

	if world._field_material_a != null:
		world._field_material_a.set_shader_parameter("color_a", Vector3(0.22, 0.28, 0.08))
		world._field_material_a.set_shader_parameter("color_b", Vector3(0.11, 0.15, 0.045))
	if world._field_material_b != null:
		world._field_material_b.set_shader_parameter("color_a", Vector3(0.31, 0.24, 0.075))
		world._field_material_b.set_shader_parameter("color_b", Vector3(0.16, 0.12, 0.038))
	if world._field_material_c != null:
		world._field_material_c.set_shader_parameter("color_a", Vector3(0.27, 0.17, 0.07))
		world._field_material_c.set_shader_parameter("color_b", Vector3(0.13, 0.08, 0.032))

	_deepen_terrain(world)


static func apply_environment(world: GoldenWorldV1) -> void:
	var env_node := world.get_node_or_null("GoldenWorldEnvironment") as WorldEnvironment
	if env_node != null and env_node.environment != null:
		var env := env_node.environment
		env.background_energy_multiplier = 1.08
		env.ambient_light_color = Color(0.54, 0.57, 0.58)
		env.ambient_light_energy = 0.72
		env.fog_light_color = Color(0.58, 0.61, 0.59)
		env.fog_light_energy = 0.72
		env.fog_density = 0.00105
		env.fog_height = 4.0
		env.fog_height_density = 0.007
		env.fog_aerial_perspective = 0.24
		env.fog_sky_affect = 0.16
		if env.sky != null and env.sky.sky_material is ProceduralSkyMaterial:
			var sky := env.sky.sky_material as ProceduralSkyMaterial
			sky.sky_top_color = Color(0.30, 0.43, 0.56)
			sky.sky_horizon_color = Color(0.69, 0.73, 0.72)
			sky.ground_bottom_color = Color(0.18, 0.19, 0.16)
			sky.ground_horizon_color = Color(0.55, 0.55, 0.48)
	var sun := world.get_node_or_null("MorningSun") as DirectionalLight3D
	if sun != null:
		sun.light_energy = 1.56


static func _deepen_terrain(world: GoldenWorldV1) -> void:
	if world._terrain_material == null or world._terrain_material.shader == null:
		return
	var code := world._terrain_material.shader.code
	code = code.replace(
		"float dirt_mix = clamp(dry * 0.22 + river * 0.12, 0.0, 0.36);",
		"float dirt_mix = clamp(dry * 0.34 + river * 0.18, 0.0, 0.48);"
	)
	code = code.replace(
		"float mud_mix = river * 0.24;",
		"float mud_mix = clamp(river * 0.33 + (1.0 - broad) * 0.055, 0.0, 0.42);"
	)
	code = code.replace(
		"base = mix(base, m, mud_mix);",
		"""base = mix(base, m, mud_mix);
	float bridge_scar = 1.0 - smoothstep(3.5, 12.0, length(world_pos.xz - vec2(13.0, -2.5)));
	float town_scar = 1.0 - smoothstep(5.0, 17.0, length(world_pos.xz - vec2(45.0, -5.0)));
	float east_scar = 1.0 - smoothstep(4.0, 13.0, length(world_pos.xz - vec2(55.0, 10.0)));
	float blue_churn = 1.0 - smoothstep(4.0, 16.0, length(world_pos.xz - vec2(-18.0, 6.0)));
	float scar_noise = 0.58 + 0.42 * hash21(floor(world_pos.xz * 0.47));
	float battle_scar = max(max(bridge_scar, town_scar * 0.82), max(east_scar * 0.72, blue_churn * 0.58)) * scar_noise;
	base = mix(base, vec3(0.105, 0.085, 0.062), clamp(battle_scar * 0.52, 0.0, 0.58));"""
	)
	code = code.replace(
		"base = mix(base, vec3(0.22, 0.245, 0.20), far_mix * 0.58);",
		"base = mix(base, vec3(0.24, 0.255, 0.215), far_mix * 0.48);"
	)
	world._terrain_material.shader.code = code
