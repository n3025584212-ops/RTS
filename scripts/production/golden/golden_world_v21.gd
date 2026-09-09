extends "res://scripts/production/golden/golden_world_v17.gd"

# V21 is a finish-quality pass over the proven Golden World. It keeps the
# production layout and legal asset pipeline, but fixes the rejected-frame
# scale, ground contact, town density, bridge read, and atmospheric hierarchy.

func _build_materials() -> void:
	super._build_materials()
	if _terrain_material != null and _terrain_material.shader != null:
		var code := _terrain_material.shader.code
		code = code.replace("vec2 uv = UV * 6.5;", "vec2 uv = UV * 18.0;")
		code = code.replace("NORMAL_MAP_DEPTH = 0.48;", "NORMAL_MAP_DEPTH = 0.62;")
		code = code.replace(
			"vec3 g_tex = texture(grass_diff, uv).rgb;",
			"vec3 g_tex = mix(texture(grass_diff, uv).rgb, texture(grass_diff, uv * 2.73).rgb, 0.16);"
		)
		code = code.replace(
			"vec3 d_tex = texture(dirt_diff, uv * 0.72).rgb;",
			"vec3 d_tex = mix(texture(dirt_diff, uv * 0.72).rgb, texture(dirt_diff, uv * 2.11).rgb, 0.12);"
		)
		_terrain_material.shader.code = code

	if _water_material != null and _water_material.shader != null:
		var water_code := _water_material.shader.code
		water_code = water_code.replace(
			"vec3 deep = vec3(0.025, 0.115, 0.145);",
			"vec3 deep = vec3(0.020, 0.075, 0.095);"
		)
		water_code = water_code.replace(
			"vec3 shallow = vec3(0.060, 0.210, 0.225);",
			"vec3 shallow = vec3(0.075, 0.180, 0.185);"
		)
		water_code = water_code.replace("ROUGHNESS = 0.20;", "ROUGHNESS = 0.12;")
		water_code = water_code.replace("SPECULAR = 0.72;", "SPECULAR = 0.88;")
		water_code = water_code.replace("ALPHA = 0.88;", "ALPHA = 0.94;")
		_water_material.shader.code = water_code

	if _bank_material != null:
		_bank_material.albedo_color = Color(0.43, 0.35, 0.25)
		_bank_material.roughness = 0.94


func _build_environment() -> void:
	super._build_environment()
	var env_node := get_node_or_null("GoldenWorldEnvironment") as WorldEnvironment
	if env_node != null and env_node.environment != null:
		var env := env_node.environment
		env.background_energy_multiplier = 1.08
		env.ambient_light_color = Color(0.39, 0.43, 0.45)
		env.ambient_light_energy = 0.40
		env.fog_light_color = Color(0.56, 0.61, 0.62)
		env.fog_light_energy = 0.72
		env.fog_density = 0.00165
		env.fog_height = 6.0
		env.fog_height_density = 0.010
		env.fog_aerial_perspective = 0.38
		env.fog_sky_affect = 0.30
		if env.sky != null and env.sky.sky_material is ProceduralSkyMaterial:
			var sky := env.sky.sky_material as ProceduralSkyMaterial
			sky.sky_top_color = Color(0.22, 0.34, 0.46)
			sky.sky_horizon_color = Color(0.64, 0.69, 0.70)
			sky.ground_bottom_color = Color(0.42, 0.47, 0.47)
			sky.ground_horizon_color = Color(0.61, 0.62, 0.57)

	var sun := get_node_or_null("MorningSun") as DirectionalLight3D
	if sun != null:
		sun.rotation_degrees = Vector3(-38.0, -48.0, 0.0)
		sun.light_color = Color(1.0, 0.93, 0.82)
		sun.light_energy = 2.05
		sun.directional_shadow_max_distance = 230.0

	var fill := get_node_or_null("CoolSkyFill") as DirectionalLight3D
	if fill != null:
		fill.light_energy = 0.06


func _build_fields() -> void:
	var fields: Array = [
		[Vector3(-53,0,18), Vector2(23,13), -8.0, _field_material_c],
		[Vector3(-31,0,25), Vector2(17,11), -3.0, _field_material_a],
		[Vector3(-11,0,31), Vector2(14,9), 5.0, _field_material_b],
		[Vector3(-50,0,40), Vector2(20,9), 3.0, _field_material_b],
		[Vector3(-24,0,-34), Vector2(23,9), -5.0, _field_material_a],
		[Vector3(-51,0,-29), Vector2(17,8), 7.0, _field_material_c],
		[Vector3(43,0,35), Vector2(17,9), 8.0, _field_material_a],
		[Vector3(70,0,31), Vector2(18,10), -5.0, _field_material_c],
		[Vector3(79,0,12), Vector2(14,9), 4.0, _field_material_b],
		[Vector3(75,0,-32), Vector2(18,9), -6.0, _field_material_a]
	]
	for i: int in range(fields.size()):
		var data: Array = fields[i]
		_add_conforming_field(data[0], data[1], data[3], float(data[2]), "V21Field_%02d" % i)
	GoldenWorldV18Ground.add(self)


func _add_conforming_field(center: Vector3, size: Vector2, material: Material, yaw_deg: float, name_value: String) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var sx := 12
	var sz := 8
	var angle := deg_to_rad(yaw_deg)
	for zi: int in range(sz):
		for xi: int in range(sx):
			var u0 := float(xi) / float(sx)
			var u1 := float(xi + 1) / float(sx)
			var v0 := float(zi) / float(sz)
			var v1 := float(zi + 1) / float(sz)
			var p00 := _field_point(center, size, angle, u0, v0)
			var p10 := _field_point(center, size, angle, u1, v0)
			var p01 := _field_point(center, size, angle, u0, v1)
			var p11 := _field_point(center, size, angle, u1, v1)
			_add_field_vertex(st, p00, Vector2(u0, v0))
			_add_field_vertex(st, p10, Vector2(u1, v0))
			_add_field_vertex(st, p01, Vector2(u0, v1))
			_add_field_vertex(st, p10, Vector2(u1, v0))
			_add_field_vertex(st, p11, Vector2(u1, v1))
			_add_field_vertex(st, p01, Vector2(u0, v1))
	var patch := MeshInstance3D.new()
	patch.name = name_value
	patch.mesh = st.commit()
	patch.material_override = material
	patch.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(patch)


func _field_point(center: Vector3, size: Vector2, angle: float, u: float, v: float) -> Vector3:
	var lx := (u - 0.5) * size.x
	var lz := (v - 0.5) * size.y
	var wx := center.x + cos(angle) * lx - sin(angle) * lz
	var wz := center.z + sin(angle) * lx + cos(angle) * lz
	return Vector3(wx, height_at(wx, wz) + 0.035, wz)


func _add_field_vertex(st: SurfaceTool, p: Vector3, uv: Vector2) -> void:
	st.set_normal(_terrain_normal(p.x, p.z))
	st.set_uv(uv)
	st.add_vertex(p)


func _build_roads() -> void:
	super._build_roads()
	_add_damage_marks()


func _add_damage_marks() -> void:
	var mud := _pbr_material("aerial_mud_1", Vector3(4.0,4.0,4.0), Color(0.24,0.19,0.13))
	var char := StandardMaterial3D.new()
	char.albedo_color = Color(0.075, 0.067, 0.057)
	char.roughness = 0.96
	var marks: Array = [
		[Vector3(8,0,-3), 2.6, 0.72, 18.0, char],
		[Vector3(18,0,-6), 3.4, 0.58, -12.0, mud],
		[Vector3(31,0,-8), 3.2, 0.74, 33.0, char],
		[Vector3(43,0,10), 2.8, 0.62, -26.0, mud],
		[Vector3(52,0,7), 3.8, 0.55, 11.0, char],
		[Vector3(61,0,-12), 2.7, 0.68, 47.0, mud],
		[Vector3(-13,0,7), 2.6, 0.48, 9.0, mud]
	]
	for i: int in range(marks.size()):
		var data: Array = marks[i]
		var p: Vector3 = data[0]
		var disc := MeshInstance3D.new()
		disc.name = "BattleScorch_%02d" % i
		var mesh := CylinderMesh.new()
		mesh.top_radius = float(data[1])
		mesh.bottom_radius = float(data[1])
		mesh.height = 0.035
		mesh.radial_segments = 24
		disc.mesh = mesh
		disc.position = Vector3(p.x, height_at(p.x, p.z) + 0.12, p.z)
		disc.scale = Vector3(1.0, 1.0, float(data[2]))
		disc.rotation_degrees.y = float(data[3])
		disc.material_override = data[4]
		add_child(disc)


func _build_bridge() -> void:
	super._build_bridge()
	var west_x := RIVER_X - RIVER_HALF_WIDTH - 2.0
	var east_x := RIVER_X + RIVER_HALF_WIDTH + 2.0
	_add_flat_segment(
		"V21BridgeAsphalt",
		Vector3(west_x, 1.03, 0.0),
		Vector3(east_x, 1.03, 0.0),
		3.35,
		_road_material
	)
	for x: float in [west_x - 0.65, east_x + 0.65]:
		_add_bridge_box(Vector3(x, -0.02, 0.0), Vector3(1.55, 2.05, 6.1), _bridge_concrete, "V21BridgeAbutment")
	for x: float in [RIVER_X - 4.0, RIVER_X - 1.3, RIVER_X + 1.3, RIVER_X + 4.0]:
		_add_bridge_box(Vector3(x, 0.48, 0.0), Vector3(1.45, 0.28, 5.15), _bridge_concrete, "V21PierCap")
	for z_side: float in [-2.08, 2.08]:
		_add_beam("V21GuardRail", Vector3(west_x,1.48,z_side), Vector3(east_x,1.48,z_side), 0.10, _bridge_steel)
		for section: int in range(8):
			var x := lerpf(west_x, east_x, float(section) / 7.0)
			_add_beam("V21GuardPost", Vector3(x,1.08,z_side), Vector3(x,1.52,z_side), 0.08, _bridge_steel)


func _add_bridge_box(pos: Vector3, size_value: Vector3, material: Material, name_value: String) -> void:
	var node := MeshInstance3D.new()
	node.name = name_value
	var mesh := BoxMesh.new()
	mesh.size = size_value
	node.mesh = mesh
	node.position = pos
	node.material_override = material
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	add_child(node)
	bridge_member_count += 1


func _build_town() -> void:
	var houses := _find_3d_resources("res://assets/golden_scene/city_v20")
	if houses.is_empty():
		super._build_town()
		return

	GoldenWorldV20TownStreets.add(self)
	var positions: Array[Vector3] = [
		Vector3(24,0,-27), Vector3(34,0,-25), Vector3(46,0,-26), Vector3(68,0,-25),
		Vector3(25,0,-9), Vector3(44,0,-8), Vector3(68,0,-8),
		Vector3(25,0,10), Vector3(47,0,10), Vector3(69,0,11),
		Vector3(26,0,23), Vector3(47,0,24), Vector3(69,0,23),
		Vector3(33,0,-4), Vector3(52,0,-3), Vector3(73,0,-1),
		Vector3(33,0,16), Vector3(55,0,17), Vector3(76,0,17),
		Vector3(18,0,-20), Vector3(18,0,5), Vector3(60,0,-29)
	]
	for i: int in range(positions.size()):
		var house := _instantiate_scene(houses[i % houses.size()])
		if house == null:
			continue
		var p := positions[i]
		p.x += sin(float(i) * 1.41) * 0.65
		p.z += cos(float(i) * 1.07) * 0.55
		p.y = height_at(p.x, p.z)
		house.position = p
		house.rotation_degrees.y = float((i * 73) % 360)
		fit_instance_to_size(house, 7.7 + float(i % 4) * 0.42)
		if i in [5, 16]:
			_apply_building_surface_materials(house, _building_materials[2], _roof_materials[1], _trim_material)
		house.name = "V21TownHouse_%02d" % i
		add_child(house)
		town_instance_count += 1

	var churches := _filter_paths(city_real_resource_paths, ["church_landmark"])
	if not churches.is_empty():
		var church := _instantiate_scene(churches[0])
		if church != null:
			fit_instance_to_size(church, 18.0)
			church.position = Vector3(55.0, height_at(55.0, -39.0), -39.0)
			church.rotation_degrees.y = 8.0
			_apply_building_surface_materials(church, _church_wall_material, _roof_materials[1], _trim_material)
			church.name = "V21TownLandmark"
			add_child(church)
			town_instance_count += 1


func _build_water() -> void:
	super._build_water()
	var rocks := _filter_paths(nature_resource_paths, ["rock_smallA", "rock_smallB", "rock_smallC", "rock_smallFlat"])
	if rocks.is_empty():
		return
	for i: int in range(18):
		var z := -49.0 + float(i) * 5.6
		if absf(z) < 7.0:
			continue
		var center_x := _river_center_x(z)
		var side := -1.0 if i % 2 == 0 else 1.0
		var x := center_x + side * (RIVER_HALF_WIDTH + 1.45 + float(i % 3) * 0.45)
		_add_nature_instance(
			rocks[i % rocks.size()],
			Vector3(x,0,z),
			0.55 + float(i % 4) * 0.13,
			float((i * 67) % 360)
		)


func _build_forests_and_hedgerows() -> void:
	super._build_forests_and_hedgerows()
	if nature_real_resource_paths.is_empty():
		return
	var real_path := nature_real_resource_paths[0]
	var extra: Array[Vector3] = [
		Vector3(17,0,-34), Vector3(22,0,-39), Vector3(29,0,-43),
		Vector3(35,0,-48), Vector3(75,0,-38), Vector3(81,0,-34),
		Vector3(84,0,-27), Vector3(15,0,28), Vector3(21,0,34),
		Vector3(-36,0,-45), Vector3(-44,0,-42), Vector3(-52,0,-39)
	]
	for i: int in range(extra.size()):
		_add_real_tree_instance(real_path, extra[i], 8.8 + float(i % 4) * 0.55, float((i * 41) % 360))


func _build_camera() -> void:
	super._build_camera()
	if camera != null:
		camera.fov = 39.5
		camera.position = Vector3(-57.0, 39.0, 52.0)
		camera.look_at(Vector3(12.0, 0.8, -6.0), Vector3.UP)
