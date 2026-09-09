extends "res://scripts/production/golden/golden_world_v21.gd"

# V22 corrects the first V21 runtime review: V21 proved the higher-detail asset
# path, but the capture was still washed out, the river/bridge read too flat,
# and natural ground contact remained sparse.

func _build_materials() -> void:
	super._build_materials()

	if _terrain_material != null and _terrain_material.shader != null:
		var code := _terrain_material.shader.code
		code = code.replace(
			"ALBEDO = base;",
			"ALBEDO = base * vec3(0.76, 0.82, 0.72);"
		)
		_terrain_material.shader.code = code

	if _water_material != null and _water_material.shader != null:
		var water_code := _water_material.shader.code
		water_code = water_code.replace(
			"ALBEDO = mix(deep, shallow, 0.26 + ripple * 0.08);",
			"""float shore = 1.0 - smoothstep(0.00, 0.15, min(UV.x, 1.0 - UV.x));
	vec3 water_base = mix(deep, shallow, 0.24 + ripple * 0.10);
	ALBEDO = mix(water_base, vec3(0.18, 0.245, 0.235), shore * 0.26);"""
		)
		_water_material.shader.code = water_code

	if _bridge_steel is StandardMaterial3D:
		var steel := _bridge_steel as StandardMaterial3D
		steel.albedo_color = Color(0.19, 0.21, 0.20)
		steel.metallic = 0.52
		steel.roughness = 0.58


func _build_environment() -> void:
	super._build_environment()
	var env_node := get_node_or_null("GoldenWorldEnvironment") as WorldEnvironment
	if env_node != null and env_node.environment != null:
		var env := env_node.environment
		env.background_energy_multiplier = 0.88
		env.ambient_light_color = Color(0.34, 0.38, 0.40)
		env.ambient_light_energy = 0.28
		env.fog_light_color = Color(0.52, 0.58, 0.60)
		env.fog_light_energy = 0.58
		env.fog_density = 0.00138
		env.fog_height = 6.5
		env.fog_height_density = 0.0085
		env.fog_aerial_perspective = 0.34
		env.fog_sky_affect = 0.32
		if env.sky != null and env.sky.sky_material is ProceduralSkyMaterial:
			var sky := env.sky.sky_material as ProceduralSkyMaterial
			sky.sky_top_color = Color(0.18, 0.31, 0.43)
			sky.sky_horizon_color = Color(0.60, 0.67, 0.69)
			sky.ground_bottom_color = Color(0.20, 0.29, 0.33)
			sky.ground_horizon_color = Color(0.54, 0.60, 0.60)

	var sun := get_node_or_null("MorningSun") as DirectionalLight3D
	if sun != null:
		sun.light_color = Color(1.0, 0.92, 0.80)
		sun.light_energy = 1.62

	var fill := get_node_or_null("CoolSkyFill") as DirectionalLight3D
	if fill != null:
		fill.light_energy = 0.045


func _build_water() -> void:
	super._build_water()
	_add_shoreline_vegetation()


func _add_shoreline_vegetation() -> void:
	var bank_plants := _filter_paths(nature_resource_paths, [
		"plant_bushDetailed", "plant_bushSmall", "grass_large", "grass_leafsLarge"
	])
	if bank_plants.is_empty():
		return
	for i: int in range(18):
		var z := -44.0 + float(i) * 5.1
		if absf(z) < 6.5:
			continue
		var center_x := _river_center_x(z)
		var side := -1.0 if i % 2 == 0 else 1.0
		var x := center_x + side * (RIVER_HALF_WIDTH + 2.4 + float(i % 3) * 0.35)
		_add_nature_instance(
			bank_plants[i % bank_plants.size()],
			Vector3(x, 0, z),
			0.85 + float(i % 4) * 0.16,
			float((i * 53) % 360)
		)


func _build_forests_and_hedgerows() -> void:
	super._build_forests_and_hedgerows()
	var scrub := _filter_paths(nature_resource_paths, [
		"plant_bushDetailed", "plant_bushSmall", "grass_large"
	])
	if scrub.is_empty():
		return
	var positions: Array[Vector3] = [
		Vector3(-52,0,25), Vector3(-47,0,18), Vector3(-42,0,30), Vector3(-35,0,22),
		Vector3(-28,0,27), Vector3(-18,0,33), Vector3(-8,0,27), Vector3(12,0,29),
		Vector3(18,0,21), Vector3(16,0,-25), Vector3(20,0,-31), Vector3(75,0,29),
		Vector3(80,0,24), Vector3(81,0,-18), Vector3(74,0,-25), Vector3(67,0,-34)
	]
	for i: int in range(positions.size()):
		_add_nature_instance(
			scrub[i % scrub.size()],
			positions[i],
			1.15 + float(i % 3) * 0.22,
			float((i * 47) % 360)
		)
