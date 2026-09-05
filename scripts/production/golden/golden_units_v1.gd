class_name GoldenUnitsV1
extends Node3D

const MBT_PATH := "res://assets/golden_scene/vehicles/mbt_abrams.glb"
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
var _friendly_vehicle_material: ShaderMaterial
var _hostile_vehicle_material: ShaderMaterial
var _infantry_material: StandardMaterial3D


func build(world: GoldenWorldV1) -> void:
	_world = world
	_blue_marker_material = _emissive_material(Color(0.12, 0.48, 1.0), Color(0.08, 0.34, 1.0), 2.4)
	_red_marker_material = _emissive_material(Color(1.0, 0.16, 0.10), Color(1.0, 0.06, 0.02), 2.2)
	_wreck_material = StandardMaterial3D.new()
	_wreck_material.albedo_color = Color(0.075, 0.068, 0.055)
	_wreck_material.metallic = 0.48
	_wreck_material.roughness = 0.82
	_friendly_vehicle_material = _vehicle_camo_material(
		Color(0.22, 0.27, 0.14), Color(0.11, 0.14, 0.075), Color(0.31, 0.27, 0.15)
	)
	_hostile_vehicle_material = _vehicle_camo_material(
		Color(0.25, 0.22, 0.13), Color(0.12, 0.115, 0.075), Color(0.32, 0.30, 0.22)
	)
	_infantry_material = StandardMaterial3D.new()
	_infantry_material.albedo_color = Color(0.19, 0.22, 0.13)
	_infantry_material.roughness = 0.86

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
		Vector3(-23, 0, 5), Vector3(-16, 0, 3), Vector3(-9, 0, 1),
		Vector3(-2, 0, -1), Vector3(4, 0, -3)
	]
	for i: int in range(mbt_positions.size()):
		var p: Vector3 = mbt_positions[i]
		var unit := _spawn_model(MBT_PATH, p, 7.8, -8.0 + float(i) * 2.0, "BLUE_MBT_%02d" % i)
		if unit != null:
			if i == 2:
				_add_tactical_marker(unit.position + Vector3(0, 3.2, 0), "1-1 ARMOR", true)
			physical_vehicle_count += 1

	var ifv_positions := [
		Vector3(-29, 0, 12), Vector3(-21, 0, 11), Vector3(-13, 0, 9),
		Vector3(-5, 0, 7)
	]
	for i: int in range(ifv_positions.size()):
		var p: Vector3 = ifv_positions[i]
		var unit := _spawn_model(IFV_PATH, p, 6.7, -12.0 + float(i) * 3.0, "BLUE_IFV_%02d" % i)
		if unit != null:
			if i == 1:
				_add_tactical_marker(unit.position + Vector3(0, 3.0, 0), "2-1 IFV", true)
			physical_vehicle_count += 1


func _build_blue_infantry() -> void:
	for squad: int in range(3):
		var squad_origin := Vector3(-18.0 + float(squad) * 8.0, 0.0, 12.0 - float(squad) * 2.0)
		for soldier: int in range(6):
			var lateral := float(soldier % 3) * 1.45 - 1.45
			var depth := float(soldier / 3) * 1.65
			var p := squad_origin + Vector3(lateral, 0.0, depth)
			var unit := _spawn_model(SOLDIER_PATH, p, 1.95, 172.0 + float(soldier * 5), "BLUE_INF_%d_%d" % [squad, soldier])
			if unit != null:
				physical_infantry_count += 1
		if squad == 1:
			_add_tactical_marker(
				Vector3(squad_origin.x, _world.height_at(squad_origin.x, squad_origin.z) + 2.7, squad_origin.z),
				"MECH INF",
				true
			)


func _build_red_defenders() -> void:
	var red_mbt_positions := [
		Vector3(30, 0, -8), Vector3(39, 0, -5), Vector3(48, 0, -9)
	]
	for i: int in range(red_mbt_positions.size()):
		var unit := _spawn_model(MBT_PATH, red_mbt_positions[i], 7.2, 165.0 + float(i) * 4.0, "RED_MBT_%02d" % i)
		if unit != null:
			if i == 1:
				_add_tactical_marker(unit.position + Vector3(0, 3.1, 0), "ENY ARMOR", false)
			physical_vehicle_count += 1

	var red_ifv_positions := [
		Vector3(24, 0, -18), Vector3(43, 0, 12)
	]
	for i: int in range(red_ifv_positions.size()):
		var unit := _spawn_model(IFV_PATH, red_ifv_positions[i], 6.0, 178.0 - float(i) * 10.0, "RED_IFV_%02d" % i)
		if unit != null:
			if i == 0:
				_add_tactical_marker(unit.position + Vector3(0, 3.0, 0), "ENY IFV", false)
			physical_vehicle_count += 1

	for squad: int in range(2):
		var origin := Vector3(28.0 + float(squad) * 13.0, 0.0, 16.0 - float(squad) * 26.0)
		for soldier: int in range(5):
			var p := origin + Vector3(float(soldier % 3) * 1.25, 0, float(soldier / 3) * 1.45)
			var unit := _spawn_model(SOLDIER_PATH, p, 1.92, -8.0 + float(soldier * 7), "RED_INF_%d_%d" % [squad, soldier])
			if unit != null:
				physical_infantry_count += 1
		if squad == 0:
			_add_tactical_marker(
				Vector3(origin.x, _world.height_at(origin.x, origin.z) + 2.7, origin.z),
				"ENY INF",
				false
			)


func _build_wreck_history() -> void:
	var wreck_positions := [
		Vector3(13.5, 0, -2.8), Vector3(31.0, 0, -6.5), Vector3(52.0, 0, 8.5)
	]
	for i: int in range(wreck_positions.size()):
		var path := MBT_PATH if i != 1 else IFV_PATH
		var wreck := _spawn_model(path, wreck_positions[i], 5.9, 76.0 + float(i) * 31.0, "WRECK_%02d" % i)
		if wreck == null:
			continue
		wreck.rotation_degrees.z = -4.0 - float(i) * 3.0
		_override_mesh_materials(wreck, _wreck_material)
		wreck_count += 1
		physical_vehicle_count += 1


func _build_routes_and_objective_markers() -> void:
	_add_world_label(Vector3(6.0, 4.8, 0.0), "A • BRIDGE", Color(0.25, 0.72, 1.0), 10)
	_add_world_label(Vector3(34.0, 6.0, -2.0), "C • TOWN", Color(1.0, 0.32, 0.20), 10)
	_add_world_label(Vector3(-36.0, 7.0, -19.0), "B • RIDGE", Color(0.25, 0.72, 1.0), 10)

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
	if path == MBT_PATH or path == IFV_PATH:
		_override_mesh_materials(root, _hostile_vehicle_material if node_name.begins_with("RED_") else _friendly_vehicle_material)
	elif path == SOLDIER_PATH:
		_override_mesh_materials(root, _infantry_material)
	add_child(root)
	return root


func _add_tactical_marker(p: Vector3, text_value: String, friendly: bool) -> void:
	var ring := MeshInstance3D.new()
	ring.name = "FriendlyMarker" if friendly else "HostileMarker"
	var torus := TorusMesh.new()
	torus.inner_radius = 0.33
	torus.outer_radius = 0.43
	torus.rings = 24
	torus.ring_segments = 8
	ring.mesh = torus
	ring.position = Vector3(p.x, p.y - 2.65, p.z)
	ring.material_override = _blue_marker_material if friendly else _red_marker_material
	add_child(ring)

	var label := Label3D.new()
	label.text = text_value
	label.font_size = 8
	label.outline_size = 2
	label.modulate = Color(0.45, 0.78, 1.0) if friendly else Color(1.0, 0.42, 0.30)
	label.position = p
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.fixed_size = true
	label.pixel_size = 0.0015
	add_child(label)

	if friendly:
		friendly_marker_count += 1
	else:
		hostile_marker_count += 1


func _add_world_label(p: Vector3, text_value: String, color: Color, font_size: int) -> void:
	var label := Label3D.new()
	label.text = text_value
	label.font_size = maxi(font_size, 18)
	label.outline_size = 3
	label.modulate = color
	label.position = p
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = false
	label.fixed_size = false
	label.pixel_size = 0.012
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


func _vehicle_camo_material(c1: Color, c2: Color, c3: Color) -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
shader_type spatial;
uniform vec3 camo_a : source_color;
uniform vec3 camo_b : source_color;
uniform vec3 camo_c : source_color;
void fragment() {
	float p1 = sin(VERTEX.x * 2.3 + VERTEX.z * 1.7);
	float p2 = cos(VERTEX.z * 3.1 - VERTEX.y * 2.0);
	vec3 color = mix(camo_a, camo_b, smoothstep(-0.18, 0.28, p1));
	color = mix(color, camo_c, smoothstep(0.35, 0.72, p2) * 0.45);
	ALBEDO = color;
	METALLIC = 0.30;
	ROUGHNESS = 0.58;
	SPECULAR = 0.42;
}
"""
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("camo_a", Vector3(c1.r, c1.g, c1.b))
	material.set_shader_parameter("camo_b", Vector3(c2.r, c2.g, c2.b))
	material.set_shader_parameter("camo_c", Vector3(c3.r, c3.g, c3.b))
	return material


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
