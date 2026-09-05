class_name GoldenWorldV18Materials
extends RefCounted

static func apply(world: GoldenWorldV1) -> void:
	world._building_materials = [
		world._surface_detail_material("t_concrete_wall_002", Color(0.39,0.36,0.29), 0.42),
		world._surface_detail_material("t_concrete_wall_002", Color(0.52,0.43,0.31), 0.44),
		world._surface_detail_material("brick_wall_005", Color(0.43,0.23,0.14), 0.48),
		world._surface_detail_material("t_concrete_wall_002", Color(0.30,0.33,0.33), 0.40),
	]
	world._roof_materials = [
		world._surface_detail_material("brick_wall_005", Color(0.16,0.075,0.045), 0.40),
		world._surface_detail_material("brick_wall_005", Color(0.085,0.095,0.095), 0.38),
		world._surface_detail_material("t_concrete_wall_002", Color(0.14,0.13,0.11), 0.34),
	]
	world._church_wall_material = world._surface_detail_material(
		"t_concrete_wall_002", Color(0.51,0.47,0.39), 0.38
	)


static func apply_environment(world: GoldenWorldV1) -> void:
	var env_node := world.get_node_or_null("GoldenWorldEnvironment") as WorldEnvironment
	if env_node == null or env_node.environment == null:
		return
	var env := env_node.environment
	env.background_energy_multiplier = 1.18
	env.ambient_light_energy = 0.76
	env.fog_light_color = Color(0.62,0.64,0.61)
	env.fog_density = 0.00082
	env.fog_aerial_perspective = 0.28
	if env.sky != null and env.sky.sky_material is ProceduralSkyMaterial:
		var sky := env.sky.sky_material as ProceduralSkyMaterial
		sky.sky_top_color = Color(0.37,0.49,0.60)
		sky.sky_horizon_color = Color(0.72,0.75,0.72)
		sky.ground_horizon_color = Color(0.59,0.58,0.50)
