class_name Battle3DWorld
extends Node3D

const GROUND_COLOR := Color(0.12, 0.16, 0.13)
const ROAD_COLOR := Color(0.24, 0.23, 0.20)
const DIRT_ROAD_COLOR := Color(0.22, 0.24, 0.19)
const RIVER_COLOR := Color(0.035, 0.16, 0.25)
const BRIDGE_COLOR := Color(0.32, 0.31, 0.27)
const VILLAGE_COLOR := Color(0.30, 0.28, 0.23)
const INDUSTRIAL_COLOR := Color(0.28, 0.25, 0.23)

func _ready() -> void:
	add_to_group("battle3d_world")
	_build_lighting()
	_build_ground()
	_build_routes_and_river()
	_build_village()
	_build_industrial_zone()
	_build_rear_area()
	print("FRONTLINE_3D_WORLD_READY map=32x18 river=YES bridge=YES village=YES industrial=YES")

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
	_add_box("NorthVillageGround", Vector2(1500.0, 430.0), Vector2(760.0, 360.0), 0.025, 0.025, Color(0.18, 0.17, 0.14), 0.0, 0.95)
	_add_box("IndustrialGround", Vector2(2720.0, 900.0), Vector2(560.0, 760.0), 0.025, 0.025, Color(0.17, 0.15, 0.14), 0.0, 0.93)

func _build_routes_and_river() -> void:
	_add_box("River", Vector2(1600.0, 900.0), Vector2(240.0, 1800.0), 0.035, 0.035, RIVER_COLOR, 0.0, 0.30)
	_add_road_segment("MainRoadWest", Vector2(420.0, 900.0), Vector2(1458.0, 900.0), 34.0, ROAD_COLOR)
	_add_road_segment("MainRoadEast", Vector2(1742.0, 900.0), Vector2(2850.0, 900.0), 34.0, ROAD_COLOR)
	_add_box("CentralBridge", Vector2(1600.0, 900.0), Vector2(284.0, 220.0), 0.18, 0.18, BRIDGE_COLOR, 0.18, 0.62)
	for z_offset: float in [-92.0, 92.0]:
		_add_road_segment("BridgeRail_%s" % str(z_offset), Vector2(1458.0, 900.0 + z_offset), Vector2(1742.0, 900.0 + z_offset), 10.0, Color(0.42, 0.41, 0.36), 0.12)

	_add_route_polyline("NorthRoute", PackedVector2Array([
		Vector2(500.0, 860.0), Vector2(960.0, 540.0), Vector2(1240.0, 560.0), Vector2(1460.0, 840.0)
	]), 24.0, DIRT_ROAD_COLOR)
	_add_route_polyline("SouthRoute", PackedVector2Array([
		Vector2(520.0, 1040.0), Vector2(980.0, 1390.0), Vector2(2100.0, 1390.0), Vector2(2660.0, 1060.0)
	]), 26.0, DIRT_ROAD_COLOR)

func _build_village() -> void:
	for row: int in range(2):
		for column: int in range(5):
			var center := Vector2(1206.0 + column * 142.0, 329.0 + row * 150.0)
			_add_box("Village_%d_%d" % [row, column], center, Vector2(92.0, 78.0), 0.55, 0.55, VILLAGE_COLOR, 0.0, 0.88)

func _build_industrial_zone() -> void:
	for index: int in range(4):
		var center := Vector2(2582.0 + (index % 2) * 250.0, 675.0 + int(index / 2) * 330.0)
		_add_box("Warehouse_%d" % index, center, Vector2(185.0, 170.0), 0.72, 0.72, INDUSTRIAL_COLOR, 0.18, 0.68)
	_add_cylinder("StackWest", Vector2(2530.0, 470.0), 18.0, 1.25, Color(0.30, 0.27, 0.24), 0.20, 0.72)
	_add_cylinder("StackEast", Vector2(2860.0, 470.0), 18.0, 1.25, Color(0.30, 0.27, 0.24), 0.20, 0.72)
	_add_cylinder("StorageTankA", Vector2(2600.0, 1010.0), 28.0, 0.42, Color(0.36, 0.34, 0.31), 0.42, 0.48)
	_add_cylinder("StorageTankB", Vector2(2670.0, 1010.0), 28.0, 0.42, Color(0.36, 0.34, 0.31), 0.42, 0.48)

func _build_rear_area() -> void:
	for index: int in range(4):
		var center := Vector2(220.0 + index * 120.0, 700.0 + (index % 2) * 110.0)
		_add_box("RearShelter_%d" % index, center, Vector2(80.0, 56.0), 0.32, 0.32, Color(0.14, 0.24, 0.28), 0.0, 0.92)

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
	mesh.size = Vector3(
		Battle3DAdapter.sim_length_to_world(size_sim.x),
		height,
		Battle3DAdapter.sim_length_to_world(size_sim.y)
	)
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
