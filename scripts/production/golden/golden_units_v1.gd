class_name GoldenUnitsV1
extends Node3D

const MBT_PATH := "res://assets/golden_scene/vehicles/mbt.glb"
const IFV_PATH := "res://assets/golden_scene/vehicles/ifv.glb"
const SOLDIER_PATH := "res://assets/golden_scene/infantry/soldier.glb"

var physical_vehicle_count: int = 0
var physical_infantry_count: int = 0
var wreck_count: int = 0
var friendly_marker_count: int = 0
var hostile_marker_count: int = 0

var _world: GoldenWorldV1
var _blue_marker_material: StandardMaterial3D
var _red_marker_material: StandardMaterial3D
var _wreck_material: StandardMaterial3D


func build(world: GoldenWorldV1) -> void:
	_world = world
	_blue_marker_material = _emissive_material(Color(0.12, 0.48, 1.0), Color(0.08, 0.34, 1.0), 2.4)
	_red_marker_material = _emissive_material(Color(1.0, 0.16, 0.10), Color(1.0, 0.06, 0.02), 2.2)
	_wreck_material = StandardMaterial3D.new()
	_wreck_material.albedo_color = Color(0.075, 0.068, 0.055)
	_wreck_material.metallic = 0.48
	_wreck_material.roughness = 0.82

	_require_model(MBT_PATH, "MBT")
	_require_model(IFV_PATH, "IFV")
	_require_model(SOLDIER_PATH, "INFANTRY")

	_build_blue_armored_column()
	_build_blue_infantry()
	_build_red_defenders()
	_build_wreck_history()
	_build_routes_and_objective_markers()

	print(
		"FRONTLINE_GOLDEN_UNITS_READY vehicles=%d infantry=%d wrecks=%d blue_markers=%d red_markers=%d" %
		[physical_vehicle_count, physical_infantry_count, wreck_count, friendly_marker_count, hostile_marker_count]
	)


func _build_blue_armored_column() -> void:
	var mbt_positions := [
		Vector3(-34, 0, 14), Vector3(-27, 0, 12), Vector3(-20, 0, 9),
		Vector3(-13, 0, 7), Vector3(-7, 0, 5)
	]
	for i: int in range(mbt_positions.size()):
		var p: Vector3 = mbt_positions[i]
		var unit := _spawn_model(MBT_PATH, p, 7.0, -8.0 + float(i) * 2.0, "BLUE_MBT_%02d" % i)
		if unit != null:
			_add_tactical_marker(unit.position + Vector3(0, 3.6, 0), "▲ 1-%d  MBT" % (i + 1), true)
			physical_vehicle_count += 1

	var ifv_positions := [
		Vector3(-39, 0, 22), Vector3(-31, 0, 23), Vector3(-22, 0, 20),
		Vector3(-14, 0, 18)
	]
	for i: int in range(ifv_positions.size()):
		var p: Vector3 = ifv_positions[i]
		var unit := _spawn_model(IFV_PATH, p, 6.5, -12.0 + float(i) * 3.0, "BLUE_IFV_%02d" % i)
		if unit != null:
			_add_tactical_marker(unit.position + Vector3(0, 3.4, 0), "◆ 2-%d  IFV" % (i + 1), true)
			physical_vehicle_count += 1


func _build_blue_infantry() -> void:
	for squad: int in range(3):
		var squad_origin := Vector3(-26.0 + float(squad) * 9.0, 0.0, 28.0 - float(squad) * 3.0)
		for soldier: int in range(6):
			var lateral := float(soldier % 3) * 1.45 - 1.45
			var depth := float(soldier / 3) * 1.65
			var p := squad_origin + Vector3(lateral, 0.0, depth)
			var unit := _spawn_model(SOLDIER_PATH, p, 1.82, 172.0 + float(soldier * 5), "BLUE_INF_%d_%d" % [squad, soldier])
			if unit != null:
				physical_infantry_count += 1
		_add_tactical_marker(
			Vector3(squad_origin.x, _world.height_at(squad_origin.x, squad_origin.z) + 3.0, squad_origin.z),
			"● MECH INF %d" % (squad + 1),
			true
		)


func _build_red_defenders() -> void:
	var red_mbt_positions := [
		Vector3(30, 0, -8), Vector3(39, 0, -5), Vector3(48, 0, -9)
	]
	for i: int in range(red_mbt_positions.size()):
		var unit := _spawn_model(MBT_PATH, red_mbt_positions[i], 6.8, 165.0 + float(i) * 4.0, "RED_MBT_%02d" % i)
		if unit != null:
			_add_tactical_marker(unit.position + Vector3(0, 3.6, 0), "▼ ENY ARMOR", false)
			physical_vehicle_count += 1

	var red_ifv_positions := [
		Vector3(24, 0, -18), Vector3(43, 0, 12)
	]
	for i: int in range(red_ifv_positions.size()):
		var unit := _spawn_model(IFV_PATH, red_ifv_positions[i], 6.3, 178.0 - float(i) * 10.0, "RED_IFV_%02d" % i)
		if unit != null:
			_add_tactical_marker(unit.position + Vector3(0, 3.3, 0), "▼ ENY IFV", false)
			physical_vehicle_count += 1

	for squad: int in range(2):
		var origin := Vector3(28.0 + float(squad) * 13.0, 0.0, 16.0 - float(squad) * 26.0)
		for soldier: int in range(5):
			var p := origin + Vector3(float(soldier % 3) * 1.25, 0, float(soldier / 3) * 1.45)
			var unit := _spawn_model(SOLDIER_PATH, p, 1.78, -8.0 + float(soldier * 7), "RED_INF_%d_%d" % [squad, soldier])
			if unit != null:
				physical_infantry_count += 1
		_add_tactical_marker(
			Vector3(origin.x, _world.height_at(origin.x, origin.z) + 3.0, origin.z),
			"▼ ENY INF",
			false
		)


func _build_wreck_history() -> void:
	var wreck_positions := [
		Vector3(8.5, 0, -3.2), Vector3(20.0, 0, 4.5), Vector3(33.0, 0, 19.0)
	]
	for i: int in range(wreck_positions.size()):
		var path := MBT_PATH if i != 1 else IFV_PATH
		var wreck := _spawn_model(path, wreck_positions[i], 6.4, 76.0 + float(i) * 31.0, "WRECK_%02d" % i)
		if wreck == null:
			continue
		wreck.rotation_degrees.z = -4.0 - float(i) * 3.0
		_override_mesh_materials(wreck, _wreck_material)
		wreck_count += 1
		physical_vehicle_count += 1


func _build_routes_and_objective_markers() -> void:
	_add_world_label(Vector3(6.0, 7.5, 0.0), "A  BRIDGE", Color(0.25, 0.72, 1.0), 30)
	_add_world_label(Vector3(34.0, 10.5, -2.0), "C  RIVER TOWN", Color(1.0, 0.32, 0.20), 28)
	_add_world_label(Vector3(-36.0, 12.0, -19.0), "B  RIDGE", Color(0.25, 0.72, 1.0), 27)

	var route_mat := _transparent_emissive(Color(0.10, 0.52, 1.0, 0.65), 1.4)
	var route := [
		Vector3(-37, 0, 14), Vector3(-25, 0, 11), Vector3(-13, 0, 7),
		Vector3(-3, 0, 3), Vector3(5, 0, 1)
	]
	for i: int in range(1, route.size()):
		var a: Vector3 = route[i - 1]
		var b: Vector3 = route[i]
		a.y = _world.height_at(a.x, a.z) + 0.32
		b.y = _world.height_at(b.x, b.z) + 0.32
		_add_beam(a, b, 0.10, route_mat, "BLUE_TASK_ROUTE")


func _spawn_model(path: String, p: Vector3, target_size: float, yaw: float, node_name: String) -> Node3D:
	var packed := load(path) as PackedScene
	if packed == null:
		push_error("Golden Scene required model failed to load: %s" % path)
		return null
	var root := packed.instantiate() as Node3D
	if root == null:
		push_error("Golden Scene required model is not Node3D: %s" % path)
		return null
	root.name = node_name
	_world.fit_instance_to_size(root, target_size)
	p.y = _world.height_at(p.x, p.z) + 0.10
	root.position = p
	root.rotation_degrees.y = yaw
	add_child(root)
	return root


func _add_tactical_marker(p: Vector3, text_value: String, friendly: bool) -> void:
	var ring := MeshInstance3D.new()
	ring.name = "FriendlyMarker" if friendly else "HostileMarker"
	var torus := TorusMesh.new()
	torus.inner_radius = 0.62
	torus.outer_radius = 0.76
	torus.rings = 24
	torus.ring_segments = 8
	ring.mesh = torus
	ring.position = Vector3(p.x, p.y - 2.9, p.z)
	ring.material_override = _blue_marker_material if friendly else _red_marker_material
	add_child(ring)

	var label := Label3D.new()
	label.text = text_value
	label.font_size = 32
	label.outline_size = 7
	label.modulate = Color(0.45, 0.78, 1.0) if friendly else Color(1.0, 0.42, 0.30)
	label.position = p
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.fixed_size = true
	label.pixel_size = 0.0036
	add_child(label)

	if friendly:
		friendly_marker_count += 1
	else:
		hostile_marker_count += 1


func _add_world_label(p: Vector3, text_value: String, color: Color, font_size: int) -> void:
	var label := Label3D.new()
	label.text = text_value
	label.font_size = font_size
	label.outline_size = 8
	label.modulate = color
	label.position = p
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.fixed_size = true
	label.pixel_size = 0.0038
	add_child(label)


func _add_beam(a: Vector3, b: Vector3, thickness: float, material: Material, node_name: String) -> void:
	var dir := b - a
	var mesh := BoxMesh.new()
	mesh.size = Vector3(dir.length(), thickness, thickness)
	var beam := MeshInstance3D.new()
	beam.name = node_name
	beam.mesh = mesh
	var x_axis := dir.normalized()
	var z_axis := x_axis.cross(Vector3.UP)
	if z_axis.length_squared() < 0.0001:
		z_axis = Vector3.FORWARD
	z_axis = z_axis.normalized()
	var y_axis := z_axis.cross(x_axis).normalized()
	beam.transform = Transform3D(Basis(x_axis, y_axis, z_axis), (a + b) * 0.5)
	beam.material_override = material
	add_child(beam)


func _override_mesh_materials(root: Node3D, material: Material) -> void:
	if root is MeshInstance3D:
		(root as MeshInstance3D).material_override = material
	for child: Node in root.get_children():
		if child is Node3D:
			_override_mesh_materials(child as Node3D, material)


func _require_model(path: String, label: String) -> void:
	if not ResourceLoader.exists(path):
		push_error("Golden Scene missing required %s model at %s" % [label, path])


func _emissive_material(color: Color, emission: Color, energy: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = emission
	material.emission_energy_multiplier = energy
	material.metallic = 0.12
	material.roughness = 0.36
	return material


func _transparent_emissive(color: Color, energy: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = Color(color.r, color.g, color.b)
	material.emission_energy_multiplier = energy
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return material
