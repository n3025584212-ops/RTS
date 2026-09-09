class_name Battle3DWorld
extends Node3D

const GROUND_COLOR := Color(0.12, 0.16, 0.13)
const ROAD_COLOR := Color(0.24, 0.23, 0.20)
const DIRT_ROAD_COLOR := Color(0.22, 0.24, 0.19)
const RIVER_COLOR := Color(0.035, 0.16, 0.25)
const BRIDGE_COLOR := Color(0.32, 0.31, 0.27)
const VILLAGE_COLOR := Color(0.30, 0.28, 0.23)
const INDUSTRIAL_COLOR := Color(0.28, 0.25, 0.23)
const EARTHWORK_COLOR := Color(0.20, 0.22, 0.16)
const FOOT_LINK_COLOR := Color(0.34, 0.31, 0.25)
const VISUAL_ASSET := "res://assets/visual_slice/"
const VISUAL_PBR := "res://assets/visual_slice/surfaces/"

var _hard_blocker_mesh_count: int = 0
var _north_foot_link_visual_ready: bool = false

func _ready() -> void:
	add_to_group("battle3d_world")
	_build_lighting()
	_build_ground()
	_build_routes_and_river()
	_build_authoritative_terrain()
	_build_industrial_detail()
	_build_rear_area()
	print("FRONTLINE_3D_WORLD_READY map=32x18 river=YES bridge=YES village=YES industrial=YES")
	print("FRONTLINE_3D_ROUTE_IDENTITY_READY blockers=%d north_foot_link=YES south_open_lane=YES" % _hard_blocker_mesh_count)

func _build_lighting() -> void:
	var environment_node := WorldEnvironment.new()
	environment_node.name = "WorldEnvironment"
	var environment := Environment.new()
	environment.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sky_material := ShaderMaterial.new()
	sky_material.shader = load("res://scripts/production/visual_slice_sky.gdshader")
	sky_material.set_shader_parameter("panorama", load(VISUAL_ASSET + "sky.hdr"))
	sky.sky_material = sky_material
	environment.sky = sky
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.54, 0.62, 0.72)
	environment.ambient_light_energy = 0.48
	environment.reflected_light_source = Environment.REFLECTION_SOURCE_SKY
	environment.tonemap_mode = Environment.TONE_MAPPER_ACES
	environment.tonemap_exposure = 0.98
	environment.ssao_enabled = true
	environment.ssao_radius = 1.25
	environment.ssao_intensity = 1.28
	environment.ssao_power = 1.15
	environment.ssil_enabled = true
	environment.ssil_radius = 2.0
	environment.ssil_intensity = 0.34
	environment.ssr_enabled = true
	environment.ssr_max_steps = 40
	environment.fog_enabled = true
	environment.fog_light_color = Color(0.59, 0.63, 0.66)
	environment.fog_light_energy = 0.65
	environment.fog_density = 0.0022
	environment.fog_sky_affect = 0.16
	environment.fog_height = 1.8
	environment.fog_height_density = 0.008
	environment.volumetric_fog_enabled = true
	environment.volumetric_fog_density = 0.00055
	environment.volumetric_fog_albedo = Color(0.61, 0.65, 0.68)
	environment.volumetric_fog_length = 95.0
	environment.volumetric_fog_ambient_inject = 0.18
	environment_node.environment = environment
	add_child(environment_node)

	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	sun.rotation_degrees = Vector3(-34.0, 48.0, 0.0)
	sun.light_color = Color(1.0, 0.86, 0.69)
	sun.light_energy = 1.52
	sun.shadow_enabled = true
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS
	sun.directional_shadow_max_distance = 70.0
	sun.shadow_bias = 0.02
	sun.shadow_normal_bias = 0.28
	sun.light_angular_distance = 0.55
	add_child(sun)

	var reflection := ReflectionProbe.new()
	reflection.name = "BattleReflectionProbe"
	reflection.position = Vector3(16.0, 2.6, 9.0)
	reflection.size = Vector3(34.0, 12.0, 20.0)
	reflection.max_distance = 44.0
	reflection.box_projection = true
	reflection.intensity = 0.82
	add_child(reflection)

func _build_ground() -> void:
	# Keep a dark structural base below the visible PBR surface so the gameplay
	# coordinate plane remains robust while the player sees a continuous material field.
	_add_box("GroundBase", Vector2(1600.0, 900.0), Vector2(3200.0, 1800.0), 0.12, -0.06, GROUND_COLOR, 0.0, 0.98)

	var ground_mesh := PlaneMesh.new()
	ground_mesh.size = Vector2(72.0, 48.0)
	ground_mesh.subdivide_width = 144
	ground_mesh.subdivide_depth = 96
	var ground := MeshInstance3D.new()
	ground.name = "Battle01PBRGround"
	ground.mesh = ground_mesh
	ground.position = Vector3(16.0, 0.015, 9.0)
	ground.material_override = _battle_terrain_material()
	ground.gi_mode = GeometryInstance3D.GI_MODE_STATIC
	add_child(ground)

func _build_routes_and_river() -> void:
	var river_mesh := PlaneMesh.new()
	river_mesh.size = Vector2(2.42, 18.0)
	var river := MeshInstance3D.new()
	river.name = "River"
	river.mesh = river_mesh
	river.position = Vector3(16.0, 0.065, 9.0)
	river.material_override = _water_material()
	add_child(river)
	_add_road_segment("MainRoadWest", Vector2(420.0, 900.0), Vector2(1458.0, 900.0), 72.0, ROAD_COLOR)
	_add_road_segment("MainRoadEast", Vector2(1742.0, 900.0), Vector2(2850.0, 900.0), 72.0, ROAD_COLOR)
	_add_box("CentralBridge", Vector2(1600.0, 900.0), Vector2(284.0, 220.0), 0.18, 0.18, BRIDGE_COLOR, 0.18, 0.62)
	for z_offset: float in [-92.0, 92.0]:
		_add_road_segment("BridgeRail_%s" % str(z_offset), Vector2(1458.0, 900.0 + z_offset), Vector2(1742.0, 900.0 + z_offset), 10.0, Color(0.42, 0.41, 0.36), 0.12)

	_add_route_polyline("NorthStreetWest", PackedVector2Array([
		Vector2(500.0, 860.0), Vector2(900.0, 640.0), Vector2(1060.0, 620.0), Vector2(1420.0, 700.0), Vector2(1460.0, 840.0)
	]), 62.0, DIRT_ROAD_COLOR)
	_add_route_polyline("NorthStreetEast", PackedVector2Array([
		Vector2(1740.0, 840.0), Vector2(1880.0, 700.0), Vector2(2200.0, 620.0), Vector2(2360.0, 700.0)
	]), 62.0, DIRT_ROAD_COLOR)

	_add_route_polyline("SouthVehicleLaneWest", PackedVector2Array([
		Vector2(520.0, 1040.0), Vector2(900.0, 1360.0), Vector2(1320.0, 1400.0), Vector2(1440.0, 1080.0)
	]), 120.0, DIRT_ROAD_COLOR)
	_add_route_polyline("SouthVehicleLaneEast", PackedVector2Array([
		Vector2(1760.0, 1080.0), Vector2(2200.0, 1400.0), Vector2(2440.0, 1320.0), Vector2(2660.0, 1060.0)
	]), 120.0, DIRT_ROAD_COLOR)

func _build_authoritative_terrain() -> void:
	var village_index: int = 0
	for blocker: Rect2 in BattleRouteTerrain.VILLAGE_BLOCKERS:
		_add_village_blocker("VillageHard_%d" % village_index, blocker, village_index)
		village_index += 1

	var central_index: int = 0
	for blocker: Rect2 in BattleRouteTerrain.CENTRAL_BLOCKERS:
		_add_blocker_box("CentralHard_%d" % central_index, blocker, 0.42, EARTHWORK_COLOR)
		central_index += 1

	var south_index: int = 0
	for blocker: Rect2 in BattleRouteTerrain.SOUTH_BLOCKERS:
		_add_blocker_box("SouthEarthwork_%d" % south_index, blocker, 0.36, EARTHWORK_COLOR)
		south_index += 1

	var industrial_index: int = 0
	for blocker: Rect2 in BattleRouteTerrain.INDUSTRIAL_BLOCKERS:
		_add_blocker_box("IndustrialHard_%d" % industrial_index, blocker, 0.72, INDUSTRIAL_COLOR)
		industrial_index += 1

	_add_road_segment("NorthFootLink", BattleRouteTerrain.NORTH_FOOT_LINK_ENTRY, BattleRouteTerrain.NORTH_FOOT_LINK_EXIT, 28.0, FOOT_LINK_COLOR, 0.060)
	_add_road_segment("NorthFootLinkEdgeNorth", Vector2(1080.0, 432.0), Vector2(1440.0, 432.0), 8.0, Color(0.26, 0.25, 0.21), 0.10)
	_add_road_segment("NorthFootLinkEdgeSouth", Vector2(1080.0, 488.0), Vector2(1440.0, 488.0), 8.0, Color(0.26, 0.25, 0.21), 0.10)
	_build_village_vegetation()
	_north_foot_link_visual_ready = true

func _build_industrial_detail() -> void:
	_add_cylinder("StackWest", Vector2(2530.0, 470.0), 18.0, 1.25, Color(0.30, 0.27, 0.24), 0.20, 0.72)
	_add_cylinder("StackEast", Vector2(2860.0, 470.0), 18.0, 1.25, Color(0.30, 0.27, 0.24), 0.20, 0.72)
	_add_cylinder("StorageTankA", Vector2(2600.0, 1100.0), 28.0, 0.42, Color(0.36, 0.34, 0.31), 0.42, 0.48)
	_add_cylinder("StorageTankB", Vector2(2670.0, 1100.0), 28.0, 0.42, Color(0.36, 0.34, 0.31), 0.42, 0.48)

func _build_rear_area() -> void:
	for index: int in range(4):
		var center := Vector2(220.0 + index * 120.0, 700.0 + (index % 2) * 110.0)
		_add_box("RearShelter_%d" % index, center, Vector2(80.0, 56.0), 0.32, 0.32, Color(0.14, 0.24, 0.28), 0.0, 0.92)

func get_hard_blocker_mesh_count() -> int:
	return _hard_blocker_mesh_count

func has_north_foot_link_visual() -> bool:
	return _north_foot_link_visual_ready

func _add_village_blocker(name_value: String, rect: Rect2, index: int) -> void:
	# Gameplay blocking remains authoritative in BattleRouteTerrain. This low
	# foundation preserves the map read while the visible mass is a real house.
	_add_box(name_value + "_Foundation", rect.get_center(), rect.size, 0.07, 0.035, Color(0.19, 0.17, 0.14), 0.0, 0.92)
	_hard_blocker_mesh_count += 1

	var variants := [
		VISUAL_ASSET + "hero_house_ruined.glb",
		VISUAL_ASSET + "house_damaged.glb",
		VISUAL_ASSET + "house_intact.glb"
	]
	var path: String = variants[index % variants.size()]
	if not ResourceLoader.exists(path):
		return
	var packed := load(path) as PackedScene
	if packed == null:
		return
	var house := packed.instantiate() as Node3D
	if house == null:
		return
	house.name = name_value + "_VisualHouse"
	add_child(house)
	var center := Battle3DAdapter.sim_to_world(rect.get_center(), 0.02)
	house.position = center
	house.rotation_degrees.y = [12.0, -18.0, 7.0, 22.0, -11.0][index % 5]
	_fit_scene_extent(house, maxf(rect.size.x, rect.size.y) * Battle3DAdapter.SIM_TO_WORLD_SCALE * 0.94)
	_rebind_house_materials(house)


func _build_village_vegetation() -> void:
	var tree_path := VISUAL_ASSET + "island_tree_01_0.glb"
	var fir_path := VISUAL_ASSET + "fir_sapling_medium_0.glb"
	var shrub_paths := [
		VISUAL_ASSET + "shrub_02_0.glb", VISUAL_ASSET + "shrub_02_1.glb",
		VISUAL_ASSET + "shrub_02_2.glb", VISUAL_ASSET + "shrub_02_3.glb"
	]
	var tree_points := [
		Vector2(9.8, 2.2), Vector2(10.2, 4.8), Vector2(10.0, 7.2),
		Vector2(12.8, 2.0), Vector2(14.8, 1.8), Vector2(18.9, 2.0),
		Vector2(20.0, 4.8), Vector2(20.6, 7.1), Vector2(7.4, 5.0),
		Vector2(23.0, 5.1), Vector2(7.8, 13.9), Vector2(23.8, 14.2)
	]
	for i in range(tree_points.size()):
		var path := tree_path if i % 3 == 0 else fir_path
		_spawn_environment_model(path, Vector3(tree_points[i].x, 0.0, tree_points[i].y), 2.2 + float(i % 3) * .45, float(i * 37))

	for i in range(28):
		var x := 8.2 + float((i * 47) % 145) / 10.0
		var z := 1.8 + float((i * 29) % 132) / 10.0
		if absf(x - 16.0) < 1.7 or absf(z - 9.0) < .85:
			continue
		_spawn_environment_model(shrub_paths[i % shrub_paths.size()], Vector3(x, 0.0, z), .55 + float(i % 4) * .09, float(i * 53))


func _spawn_environment_model(path: String, position_value: Vector3, target_extent: float, yaw: float) -> void:
	if not ResourceLoader.exists(path):
		return
	var packed := load(path) as PackedScene
	if packed == null:
		return
	var root := packed.instantiate() as Node3D
	if root == null:
		return
	add_child(root)
	root.position = position_value
	root.rotation_degrees.y = yaw
	_fit_scene_extent(root, target_extent)


func _fit_scene_extent(root: Node3D, target_extent: float) -> void:
	var extent := 0.0
	for node: Node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := node as MeshInstance3D
		if mesh_instance.mesh == null:
			continue
		var size := mesh_instance.get_aabb().size
		extent = maxf(extent, maxf(size.x, maxf(size.y, size.z)))
	if extent > .0001:
		root.scale = Vector3.ONE * (target_extent / extent)


func _rebind_house_materials(root: Node3D) -> void:
	for node: Node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := node as MeshInstance3D
		if mesh_instance.mesh == null:
			continue
		for surface_index in range(mesh_instance.mesh.get_surface_count()):
			var original := mesh_instance.get_active_material(surface_index)
			if original == null:
				continue
			var key := original.resource_name.to_lower()
			var replacement: Material = null
			if key == "plaster":
				var plaster := ShaderMaterial.new()
				plaster.shader = load("res://scripts/production/visual_slice_plaster.gdshader")
				plaster.set_shader_parameter("color_texture", load(VISUAL_PBR + "worn_plaster_wall_diff.jpg"))
				plaster.set_shader_parameter("normal_texture", load(VISUAL_PBR + "worn_plaster_wall_nor_gl.jpg"))
				replacement = plaster
			elif key == "roof":
				replacement = _surface_material("roof_tiles_14", Color(.43,.32,.24), .78)
			elif key == "brick":
				replacement = _surface_material("brick_wall_005", Color(.46,.35,.27), .86)
			elif key == "wood":
				replacement = _surface_material("dirt_aerial_03", Color(.18,.12,.075), .88)
			elif key == "trim":
				replacement = _surface_material("worn_plaster_wall", Color(.58,.56,.50), .82)
			elif key == "glass":
				var glass := _make_material(Color(.045,.07,.075), .34, .18)
				replacement = glass
			elif key == "metal":
				replacement = _make_material(Color(.13,.14,.13), .62, .48)
			elif key == "interior":
				replacement = _make_material(Color(.07,.065,.05), 0.0, .94)
			if replacement != null:
				mesh_instance.set_surface_override_material(surface_index, replacement)


func _add_blocker_box(name_value: String, rect: Rect2, height: float, color: Color) -> void:
	if name_value.begins_with("CentralHard") or name_value.begins_with("SouthEarthwork"):
		_add_earthwork_visual(name_value, rect)
	elif name_value.begins_with("IndustrialHard"):
		_add_industrial_visual(name_value, rect, height)
	else:
		_add_box(name_value, rect.get_center(), rect.size, height, height, color, 0.0, 0.90)
	_hard_blocker_mesh_count += 1


func _add_earthwork_visual(name_value: String, rect: Rect2) -> void:
	var center := rect.get_center()
	var world_center := Battle3DAdapter.sim_to_world(center, .08)
	var size_world := Vector3(
		Battle3DAdapter.sim_length_to_world(rect.size.x),
		.16,
		Battle3DAdapter.sim_length_to_world(rect.size.y)
	)
	var base_mesh := BoxMesh.new()
	base_mesh.size = size_world
	var base := MeshInstance3D.new()
	base.name = name_value
	base.mesh = base_mesh
	base.position = world_center
	base.material_override = _surface_material("aerial_mud_1", Color(.42,.32,.21), .88)
	add_child(base)

	var stone := _surface_material("gravel_ground_01", Color(.42,.39,.31), .92)
	for i in range(8):
		var rock_mesh := SphereMesh.new()
		rock_mesh.radius = .18
		rock_mesh.height = .34
		rock_mesh.radial_segments = 7
		rock_mesh.rings = 4
		var rock := MeshInstance3D.new()
		rock.mesh = rock_mesh
		rock.scale = Vector3(1.0 + float(i % 3) * .18, .55 + float(i % 2) * .12, .78)
		rock.position = world_center + Vector3(
			-size_world.x*.40 + float(i % 4) * size_world.x*.26,
			.10,
			-size_world.z*.30 + float(i / 4) * size_world.z*.55
		)
		rock.rotation_degrees.y = float(i * 41)
		rock.material_override = stone
		add_child(rock)


func _add_industrial_visual(name_value: String, rect: Rect2, height: float) -> void:
	var center := rect.get_center()
	var footprint := Vector3(
		Battle3DAdapter.sim_length_to_world(rect.size.x),
		maxf(height, .72),
		Battle3DAdapter.sim_length_to_world(rect.size.y)
	)
	var body_mesh := BoxMesh.new()
	body_mesh.size = footprint
	var body := MeshInstance3D.new()
	body.name = name_value
	body.mesh = body_mesh
	body.position = Battle3DAdapter.sim_to_world(center, footprint.y*.5)
	body.material_override = _surface_material("worn_plaster_wall", Color(.37,.37,.32), .80)
	add_child(body)

	var roof_mesh := BoxMesh.new()
	roof_mesh.size = Vector3(footprint.x*1.05,.09,footprint.z*1.05)
	var roof := MeshInstance3D.new()
	roof.name = name_value + "_Roof"
	roof.mesh = roof_mesh
	roof.position = body.position + Vector3(0,footprint.y*.52,0)
	roof.material_override = _make_material(Color(.12,.13,.12),.58,.48)
	add_child(roof)

	for side in [-1.0,1.0]:
		var vent_mesh := CylinderMesh.new()
		vent_mesh.top_radius=.10
		vent_mesh.bottom_radius=.12
		vent_mesh.height=.32
		vent_mesh.radial_segments=12
		var vent := MeshInstance3D.new()
		vent.mesh=vent_mesh
		vent.position=roof.position+Vector3(side*footprint.x*.22,.19,0)
		vent.material_override=_make_material(Color(.18,.17,.15),.72,.42)
		add_child(vent)

func _add_route_polyline(prefix: String, points: PackedVector2Array, width_sim: float, color: Color) -> void:
	for index: int in range(1, points.size()):
		_add_road_segment("%s_%d" % [prefix, index], points[index - 1], points[index], width_sim, color)

func _add_road_segment(name_value: String, a_sim: Vector2, b_sim: Vector2, width_sim: float, color: Color, top_y: float = 0.055) -> void:
	var a_world := Battle3DAdapter.sim_to_world(a_sim, top_y)
	var b_world := Battle3DAdapter.sim_to_world(b_sim, top_y)
	var delta := b_world - a_world
	var length := Vector2(delta.x, delta.z).length()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(length, 0.03, Battle3DAdapter.sim_length_to_world(width_sim))
	var instance := MeshInstance3D.new()
	instance.name = name_value
	instance.mesh = mesh
	instance.position = (a_world + b_world) * 0.5
	instance.rotation.y = -atan2(delta.z, delta.x)
	if name_value.begins_with("BridgeRail"):
		instance.material_override = _make_material(Color(.20,.21,.20), .68, .43)
	elif color == ROAD_COLOR:
		instance.material_override = _surface_material("asphalt_02", Color(0.52, 0.50, 0.47), 0.38)
	else:
		instance.material_override = _surface_material("gravel_ground_01", Color(0.52, 0.45, 0.33), 0.76)
	add_child(instance)

func _add_box(name_value: String, center_sim: Vector2, size_sim: Vector2, height: float, top_y: float, color: Color, metallic: float, roughness: float) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = Vector3(Battle3DAdapter.sim_length_to_world(size_sim.x), height, Battle3DAdapter.sim_length_to_world(size_sim.y))
	var instance := MeshInstance3D.new()
	instance.name = name_value
	instance.mesh = mesh
	instance.position = Battle3DAdapter.sim_to_world(center_sim, top_y - height * 0.5)
	if name_value == "CentralBridge":
		instance.material_override = _surface_material("asphalt_02", Color(.44,.42,.39), .46)
	else:
		instance.material_override = _make_material(color, metallic, roughness)
	add_child(instance)
	return instance

func _add_cylinder(name_value: String, center_sim: Vector2, radius_sim: float, height: float, color: Color, metallic: float, roughness: float) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = Battle3DAdapter.sim_length_to_world(radius_sim)
	mesh.bottom_radius = Battle3DAdapter.sim_length_to_world(radius_sim)
	mesh.height = height
	var instance := MeshInstance3D.new()
	instance.name = name_value
	instance.mesh = mesh
	instance.position = Battle3DAdapter.sim_to_world(center_sim, height * 0.5)
	instance.material_override = _make_material(color, metallic, roughness)
	add_child(instance)
	return instance

func _battle_terrain_material() -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = load("res://scripts/battle01/battle01_terrain.gdshader")
	material.set_shader_parameter("grass_color", load(VISUAL_PBR + "leafy_grass_diff.jpg"))
	material.set_shader_parameter("soil_color", load(VISUAL_PBR + "aerial_mud_1_diff.jpg"))
	material.set_shader_parameter("soil_normal", load(VISUAL_PBR + "aerial_mud_1_nor_gl.jpg"))
	material.set_shader_parameter("soil_roughness", load(VISUAL_PBR + "aerial_mud_1_rough.png"))
	material.set_shader_parameter("gravel_color", load(VISUAL_PBR + "gravel_ground_01_diff.jpg"))
	material.set_shader_parameter("asphalt_color", load(VISUAL_PBR + "asphalt_02_diff.jpg"))
	return material

func _water_material() -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = load("res://scripts/battle01/battle01_water.gdshader")
	return material

func _surface_material(base: String, tint: Color, roughness: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = tint
	material.roughness = roughness
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	var diff := VISUAL_PBR + base + "_diff.jpg"
	if FileAccess.file_exists(diff):
		material.albedo_texture = load(diff)
	var normal := VISUAL_PBR + base + "_nor_gl.jpg"
	if FileAccess.file_exists(normal):
		material.normal_enabled = true
		material.normal_texture = load(normal)
		material.normal_scale = 0.58
	var rough := VISUAL_PBR + base + "_rough.jpg"
	if FileAccess.file_exists(rough):
		material.roughness_texture = load(rough)
	return material

func _make_material(color: Color, metallic: float, roughness: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.metallic = metallic
	material.roughness = roughness
	return material
