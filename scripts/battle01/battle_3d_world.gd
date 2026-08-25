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
	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	sun.rotation_degrees = Vector3(-58.0, -32.0, 0.0)
	sun.light_energy = 1.15
	sun.shadow_enabled = true
	add_child(sun)

	var environment_node := WorldEnvironment.new()
	environment_node.name = "WorldEnvironment"
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.055, 0.075, 0.085)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.52, 0.58, 0.62)
	environment.ambient_light_energy = 0.55
	environment_node.environment = environment
	add_child(environment_node)

func _build_ground() -> void:
	_add_box("Ground", Vector2(1600.0, 900.0), Vector2(3200.0, 1800.0), 0.16, 0.0, GROUND_COLOR, 0.0, 0.95)
	_add_box("WestRearGround", Vector2(430.0, 900.0), Vector2(620.0, 680.0), 0.025, 0.025, Color(0.10, 0.20, 0.24), 0.0, 0.90)
	_add_box("NorthVillageGround", Vector2(1500.0, 430.0), Vector2(900.0, 500.0), 0.025, 0.025, Color(0.18, 0.17, 0.14), 0.0, 0.95)
	_add_box("SouthManeuverGround", Vector2(1560.0, 1380.0), Vector2(1800.0, 250.0), 0.025, 0.025, Color(0.14, 0.17, 0.13), 0.0, 0.95)
	_add_box("IndustrialGround", Vector2(2720.0, 900.0), Vector2(560.0, 760.0), 0.025, 0.025, Color(0.17, 0.15, 0.14), 0.0, 0.93)

func _build_routes_and_river() -> void:
	_add_box("River", Vector2(1600.0, 900.0), Vector2(240.0, 1800.0), 0.035, 0.035, RIVER_COLOR, 0.0, 0.30)
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
		_add_blocker_box("VillageHard_%d" % village_index, blocker, 0.62, VILLAGE_COLOR)
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

func _add_blocker_box(name_value: String, rect: Rect2, height: float, color: Color) -> void:
	_add_box(name_value, rect.get_center(), rect.size, height, height, color, 0.0, 0.90)
	_hard_blocker_mesh_count += 1

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
	instance.material_override = _make_material(color, 0.0, 0.88)
	add_child(instance)

func _add_box(name_value: String, center_sim: Vector2, size_sim: Vector2, height: float, top_y: float, color: Color, metallic: float, roughness: float) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = Vector3(Battle3DAdapter.sim_length_to_world(size_sim.x), height, Battle3DAdapter.sim_length_to_world(size_sim.y))
	var instance := MeshInstance3D.new()
	instance.name = name_value
	instance.mesh = mesh
	instance.position = Battle3DAdapter.sim_to_world(center_sim, top_y - height * 0.5)
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

func _make_material(color: Color, metallic: float, roughness: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.metallic = metallic
	material.roughness = roughness
	return material
