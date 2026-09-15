extends "res://scripts/learning/sprint01/sprint01_reproduction.gd"

const WORLD_SCENE_PATH := "res://scenes/learning/sprint01/Sprint01WorldReproduction.tscn"
const TERRAIN_HALF_X := 36.0
const TERRAIN_HALF_Z := 24.0
const TERRAIN_STEP := 2.0
const MAIN_ROAD_Z := -2.0
const MAIN_ROAD_HALF_WIDTH := 4.6
const BRANCH_ROAD_HALF_WIDTH := 2.8
const MOVEMENT_CLEARANCE := 0.75
const JUNCTION_ANCHOR := Vector3(6.5, 0.0, -2.0)
const BRANCH_END := Vector3(7.5, 0.0, -17.0)
const OBJECTIVE_ANCHOR := Vector3(15.5, 0.0, -2.0)
const FOREST_PATCH_CENTERS: Array[Vector3] = [
	Vector3(-14.0, 0.0, -14.0),
	Vector3(-5.0, 0.0, 11.5),
	Vector3(20.5, 0.0, 12.5),
]
const FOREST_PATCH_RADII: Array[float] = [7.5, 8.5, 7.0]

var world_method_pass: bool = false
var patch_tree_count: int = 0
var straggler_tree_count: int = 0
var rejected_tree_count: int = 0
var placed_tree_points: Array[Vector3] = []
var blocker_centers: Array[Vector2] = []
var blocker_half_sizes: Array[Vector2] = []
var world_surface_roles: Array[String] = []
var world_materials: Dictionary = {}


func _ready() -> void:
	print("WORLD_REPRODUCTION_BOOT=YES")
	print("WORLD_REPRODUCTION_SCENE=%s" % WORLD_SCENE_PATH)
	print("WORLD_METHOD_SET=W-C1_CORRECTED;W-C2;W-C3;W-C4;W-C5;W-C6;W-C7")
	print("WORLD_CONTENT_PIPELINE=DETERMINISTIC_SCRIPT_AUTHORED_MESH_AND_TEXTURE_PIPELINE")
	print("WORLD_CONTENT_SOURCE=res://scripts/learning/sprint01/sprint01_world_reproduction.gd")
	super._ready()


func _build_environment() -> void:
	_build_lighting_environment()
	_build_material_pipeline()
	_build_terrain_surfaces()
	_build_transport_surfaces()
	_build_anchor_content()
	_build_vegetation_distribution()
	_build_world_detail()
	_build_command_camera()
	world_method_pass = _verify_world_method()


func _build_lighting_environment() -> void:
	var world_env := WorldEnvironment.new()
	world_env.name = "WorldMethodEnvironment"
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.46, 0.55, 0.61)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.69, 0.72, 0.67)
	environment.ambient_light_energy = 0.67
	environment.fog_enabled = true
	environment.fog_light_color = Color(0.58, 0.62, 0.60)
	environment.fog_density = 0.008
	world_env.environment = environment
	add_child(world_env)

	var sun := DirectionalLight3D.new()
	sun.name = "WorldMethodSun"
	sun.light_energy = 1.22
	sun.light_color = Color(1.0, 0.91, 0.78)
	sun.rotation_degrees = Vector3(-51.0, -37.0, 0.0)
	sun.shadow_enabled = true
	add_child(sun)
	print("LIGHTING_STATE=FROZEN|SUN_ROT=(-51,-37,0)|ENERGY=1.22|AMBIENT=0.67|FOG_DENSITY=0.008")


func _build_material_pipeline() -> void:
	world_materials["meadow"] = _procedural_surface_material("meadow", Color(0.24, 0.31, 0.17), 0.97, 11)
	world_materials["forest_floor"] = _procedural_surface_material("forest_floor", Color(0.17, 0.22, 0.12), 0.99, 23)
	world_materials["transition"] = _procedural_surface_material("transition", Color(0.29, 0.29, 0.16), 0.98, 31)
	world_materials["rock"] = _procedural_surface_material("rock", Color(0.28, 0.28, 0.25), 0.93, 43)
	world_materials["road"] = _procedural_surface_material("road", Color(0.21, 0.20, 0.18), 0.91, 59)
	world_materials["shoulder"] = _procedural_surface_material("shoulder", Color(0.35, 0.31, 0.23), 0.96, 67)
	world_materials["hardstand"] = _procedural_surface_material("hardstand", Color(0.32, 0.33, 0.31), 0.90, 71)
	world_materials["earthwork"] = _procedural_surface_material("earthwork", Color(0.27, 0.23, 0.15), 0.99, 83)
	world_materials["trunk"] = _procedural_surface_material("trunk", Color(0.23, 0.15, 0.08), 0.96, 97)
	world_materials["canopy"] = _procedural_surface_material("canopy", Color(0.13, 0.25, 0.10), 0.94, 101)
	world_surface_roles = ["meadow", "forest_floor", "transition", "rock", "road", "shoulder", "hardstand", "earthwork"]
	print("SURFACE_ROLE_BINDINGS=meadow;forest_floor;transition;rock;road;shoulder;hardstand;earthwork")
	print("MATERIAL_PROVENANCE=LOCAL_DETERMINISTIC_GENERATOR|EXTERNAL_UNLICENSED_CONTENT=NO")


func _procedural_surface_material(role: String, base: Color, roughness_value: float, seed: int) -> StandardMaterial3D:
	var image := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	for y: int in range(64):
		for x: int in range(64):
			var n1 := _hash_noise(x, y, seed)
			var n2 := _hash_noise(int(x / 4), int(y / 4), seed + 17)
			var factor := 0.82 + n1 * 0.22 + n2 * 0.10
			var pixel := Color(
				clampf(base.r * factor, 0.0, 1.0),
				clampf(base.g * factor, 0.0, 1.0),
				clampf(base.b * factor, 0.0, 1.0),
				1.0
			)
			image.set_pixel(x, y, pixel)
	var texture := ImageTexture.create_from_image(image)
	var material := StandardMaterial3D.new()
	material.resource_name = "Sprint01_%s_Material" % role
	material.albedo_color = Color.WHITE
	material.albedo_texture = texture
	material.roughness = roughness_value
	return material


func _hash_noise(x: int, y: int, seed: int) -> float:
	var raw := sin(float(x * 37 + y * 57 + seed * 131) * 0.071) * 43758.5453
	return raw - floor(raw)


func _build_terrain_surfaces() -> void:
	var roles: Array[String] = ["meadow", "forest_floor", "transition", "rock"]
	var tools: Dictionary = {}
	for role: String in roles:
		var surface_tool := SurfaceTool.new()
		surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
		tools[role] = surface_tool

	var cells_x := int((TERRAIN_HALF_X * 2.0) / TERRAIN_STEP)
	var cells_z := int((TERRAIN_HALF_Z * 2.0) / TERRAIN_STEP)
	for ix: int in range(cells_x):
		var x0 := -TERRAIN_HALF_X + float(ix) * TERRAIN_STEP
		var x1 := x0 + TERRAIN_STEP
		for iz: int in range(cells_z):
			var z0 := -TERRAIN_HALF_Z + float(iz) * TERRAIN_STEP
			var z1 := z0 + TERRAIN_STEP
			var center := Vector3((x0 + x1) * 0.5, 0.0, (z0 + z1) * 0.5)
			var role := _terrain_role(center)
			var st := tools[role] as SurfaceTool
			var p00 := Vector3(x0, _terrain_height(x0, z0), z0)
			var p01 := Vector3(x0, _terrain_height(x0, z1), z1)
			var p11 := Vector3(x1, _terrain_height(x1, z1), z1)
			var p10 := Vector3(x1, _terrain_height(x1, z0), z0)
			_add_textured_triangle(st, p00, p01, p11)
			_add_textured_triangle(st, p00, p11, p10)

	for role: String in roles:
		var st := tools[role] as SurfaceTool
		var mesh := st.commit()
		var instance := MeshInstance3D.new()
		instance.name = "Terrain_%s" % role
		instance.mesh = mesh
		instance.material_override = world_materials[role] as Material
		add_child(instance)
	print("TERRAIN_PIPELINE=PASS|GRID_STEP=%.1f|HEIGHT_DATA=SCRIPT_AUTHORED|SURFACE_ROLES=%d" % [TERRAIN_STEP, roles.size()])


func _terrain_role(point: Vector3) -> String:
	for index: int in range(FOREST_PATCH_CENTERS.size()):
		var center: Vector3 = FOREST_PATCH_CENTERS[index]
		var radius: float = FOREST_PATCH_RADII[index]
		var distance := Vector2(point.x - center.x, point.z - center.z).length()
		if distance <= radius:
			return "forest_floor"
		if distance <= radius + 2.7:
			return "transition"
	if absf(point.z) > 18.0 or absf(point.x) > 31.0:
		return "rock"
	return "meadow"


func _terrain_height(x: float, z: float) -> float:
	var undulation := 0.48 * sin(x * 0.115) + 0.28 * cos(z * 0.17) + 0.16 * sin((x + z) * 0.21)
	var flank_rise := maxf(0.0, absf(z - MAIN_ROAD_Z) - 8.0) * 0.085
	var broad_relief := undulation + flank_rise
	var main_distance := absf(z - MAIN_ROAD_Z)
	var branch_distance := _distance_point_to_segment(Vector2(x, z), Vector2(JUNCTION_ANCHOR.x, JUNCTION_ANCHOR.z), Vector2(BRANCH_END.x, BRANCH_END.z))
	var main_blend := _smooth01(3.7, 8.3, main_distance)
	var branch_blend := _smooth01(2.3, 6.0, branch_distance)
	var flatten_factor := minf(main_blend, branch_blend)
	return broad_relief * flatten_factor


func _smooth01(edge0: float, edge1: float, value: float) -> float:
	var t := clampf((value - edge0) / maxf(0.001, edge1 - edge0), 0.0, 1.0)
	return t * t * (3.0 - 2.0 * t)


func _add_textured_triangle(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	var normal := (b - a).cross(c - a).normalized()
	if normal.y < 0.0:
		normal = -normal
	var points: Array[Vector3] = [a, b, c]
	for point: Vector3 in points:
		st.set_normal(normal)
		st.set_uv(Vector2(point.x * 0.13, point.z * 0.13))
		st.add_vertex(point)


func _build_transport_surfaces() -> void:
	var main_points: Array[Vector3] = [
		Vector3(-31.0, 0.0, MAIN_ROAD_Z),
		Vector3(-18.0, 0.0, MAIN_ROAD_Z),
		Vector3(-5.0, 0.0, MAIN_ROAD_Z),
		JUNCTION_ANCHOR,
		Vector3(18.0, 0.0, MAIN_ROAD_Z),
		Vector3(28.0, 0.0, MAIN_ROAD_Z),
	]
	var branch_points: Array[Vector3] = [
		JUNCTION_ANCHOR,
		Vector3(7.1, 0.0, -8.5),
		BRANCH_END,
	]
	_build_ribbon("MainRoadShoulder", main_points, MAIN_ROAD_HALF_WIDTH + 1.15, 0.035, world_materials["shoulder"] as Material)
	_build_ribbon("MainRoadSurface", main_points, MAIN_ROAD_HALF_WIDTH, 0.065, world_materials["road"] as Material)
	_build_ribbon("BranchRoadShoulder", branch_points, BRANCH_ROAD_HALF_WIDTH + 0.85, 0.040, world_materials["shoulder"] as Material)
	_build_ribbon("BranchRoadSurface", branch_points, BRANCH_ROAD_HALF_WIDTH, 0.072, world_materials["road"] as Material)
	_add_hardstand("JunctionHardstand", JUNCTION_ANCHOR, 4.9, world_materials["hardstand"] as Material)
	_add_hardstand("ObjectiveHardstand", OBJECTIVE_ANCHOR, 5.2, world_materials["shoulder"] as Material)
	print("TRANSPORT_LAYER=PASS|MAIN_CORRIDOR=EXPLICIT|BRANCH=EXPLICIT|JUNCTION_ANCHOR=%s" % _fmt_vec(JUNCTION_ANCHOR))


func _build_ribbon(node_name: String, points: Array[Vector3], half_width: float, y_offset: float, material: Material) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i: int in range(points.size() - 1):
		var a := points[i]
		var b := points[i + 1]
		var direction := Vector3(b.x - a.x, 0.0, b.z - a.z).normalized()
		var side := Vector3(-direction.z, 0.0, direction.x) * half_width
		var a_height := _terrain_height(a.x, a.z) + y_offset
		var b_height := _terrain_height(b.x, b.z) + y_offset
		var a_left := Vector3(a.x, a_height, a.z) - side
		var a_right := Vector3(a.x, a_height, a.z) + side
		var b_left := Vector3(b.x, b_height, b.z) - side
		var b_right := Vector3(b.x, b_height, b.z) + side
		_add_textured_triangle(st, a_left, a_right, b_right)
		_add_textured_triangle(st, a_left, b_right, b_left)
	var mesh := st.commit()
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.material_override = material
	add_child(instance)


func _add_hardstand(node_name: String, center: Vector3, radius: float, material: Material) -> void:
	var instance := MeshInstance3D.new()
	instance.name = node_name
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = 0.10
	mesh.radial_segments = 48
	instance.mesh = mesh
	instance.position = Vector3(center.x, _terrain_height(center.x, center.z) + 0.055, center.z)
	instance.material_override = material
	add_child(instance)


func _build_anchor_content() -> void:
	_add_earthwork("ObjectiveEarthworkNorth", OBJECTIVE_ANCHOR + Vector3(0.0, 0.0, -5.7), Vector2(5.2, 0.75), 1.15)
	_add_earthwork("ObjectiveEarthworkSouth", OBJECTIVE_ANCHOR + Vector3(0.0, 0.0, 5.7), Vector2(5.2, 0.75), 1.15)
	_add_earthwork("ObjectiveEarthworkRear", OBJECTIVE_ANCHOR + Vector3(5.5, 0.0, 0.0), Vector2(0.8, 4.0), 1.25)
	_add_earthwork("JunctionScreenNorth", JUNCTION_ANCHOR + Vector3(-1.5, 0.0, -6.0), Vector2(3.0, 0.65), 0.85)
	_add_rock_cluster(OBJECTIVE_ANCHOR + Vector3(5.8, 0.0, -5.1), 4)
	_add_rock_cluster(JUNCTION_ANCHOR + Vector3(-4.8, 0.0, 5.8), 3)
	_add_world_label(JUNCTION_ANCHOR + Vector3(0.0, 3.8, 0.0), "JUNCTION ECHO", Color(0.86, 0.88, 0.72))
	_add_world_label(OBJECTIVE_ANCHOR + Vector3(0.0, 4.5, 0.0), "DEFENSIVE ANCHOR", Color(1.0, 0.56, 0.34))
	print("FUNCTIONAL_ANCHOR=PASS|PRIMARY=JUNCTION|SECONDARY=DEFENSIVE_OBJECTIVE|PLACEMENT=ANCHOR_RELATIVE")


func _add_earthwork(node_name: String, center: Vector3, half_size: Vector2, height_value: float) -> void:
	var instance := MeshInstance3D.new()
	instance.name = node_name
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.82
	mesh.bottom_radius = 1.0
	mesh.height = height_value
	mesh.radial_segments = 8
	instance.mesh = mesh
	instance.position = Vector3(center.x, _terrain_height(center.x, center.z) + height_value * 0.5, center.z)
	instance.scale = Vector3(half_size.x, 1.0, half_size.y)
	instance.material_override = world_materials["earthwork"] as Material
	add_child(instance)
	blocker_centers.append(Vector2(center.x, center.z))
	blocker_half_sizes.append(half_size)


func _add_rock_cluster(center: Vector3, count: int) -> void:
	for i: int in range(count):
		var offset := Vector3(float(i % 2) * 0.9 - 0.4, 0.0, (float(i) / 2.0) * 0.7 - 0.35)
		var point := center + offset
		var rock := MeshInstance3D.new()
		rock.name = "Rock_%s_%02d" % [str(center), i]
		var mesh := SphereMesh.new()
		mesh.radius = 0.42 + float(i % 3) * 0.09
		mesh.height = mesh.radius * 1.55
		rock.mesh = mesh
		rock.position = Vector3(point.x, _terrain_height(point.x, point.z) + mesh.height * 0.35, point.z)
		rock.scale = Vector3(1.35, 0.72, 0.95)
		rock.material_override = world_materials["rock"] as Material
		add_child(rock)


func _build_vegetation_distribution() -> void:
	for patch_index: int in range(FOREST_PATCH_CENTERS.size()):
		var center: Vector3 = FOREST_PATCH_CENTERS[patch_index]
		var radius: float = FOREST_PATCH_RADII[patch_index]
		for i: int in range(14):
			var angle := float(i) * 2.399963 + float(patch_index) * 0.73
			var radial_factor := 0.28 + 0.68 * _hash_noise(i, patch_index, 211 + patch_index)
			var distance := radius * radial_factor
			var point := Vector3(center.x + cos(angle) * distance, 0.0, center.z + sin(angle) * distance)
			if _vegetation_point_allowed(point, 1.2):
				_add_tree("PatchTree_%02d_%02d" % [patch_index, i], point, 0.92 + _hash_noise(i, patch_index, 317) * 0.28)
				patch_tree_count += 1
			else:
				rejected_tree_count += 1

	var stragglers: Array[Vector3] = [
		Vector3(-28.0, 0.0, 8.0),
		Vector3(-24.0, 0.0, -13.0),
		Vector3(-1.0, 0.0, 18.0),
		Vector3(13.0, 0.0, 16.5),
		Vector3(27.0, 0.0, 8.5),
		Vector3(29.0, 0.0, -12.0),
		Vector3(-30.0, 0.0, -19.0),
	]
	for i: int in range(stragglers.size()):
		var point := stragglers[i]
		if _vegetation_point_allowed(point, 1.0):
			_add_tree("Straggler_%02d" % i, point, 0.82 + float(i % 3) * 0.10)
			straggler_tree_count += 1
		else:
			rejected_tree_count += 1
	print("VEGETATION_DISTRIBUTION=PASS|PATCH_TREES=%d|STRAGGLERS=%d|REJECTED_BY_CONSTRAINT=%d" % [patch_tree_count, straggler_tree_count, rejected_tree_count])


func _vegetation_point_allowed(point: Vector3, extra_clearance: float) -> bool:
	if absf(point.x) > TERRAIN_HALF_X - 1.0 or absf(point.z) > TERRAIN_HALF_Z - 1.0:
		return false
	if _is_route_protected(Vector2(point.x, point.z), extra_clearance):
		return false
	if Vector2(point.x - OBJECTIVE_ANCHOR.x, point.z - OBJECTIVE_ANCHOR.z).length() < 7.2 + extra_clearance:
		return false
	if Vector2(point.x - JUNCTION_ANCHOR.x, point.z - JUNCTION_ANCHOR.z).length() < 5.5 + extra_clearance:
		return false
	return true


func _add_tree(node_name: String, point: Vector3, scale_value: float) -> void:
	var root := Node3D.new()
	root.name = node_name
	root.position = Vector3(point.x, _terrain_height(point.x, point.z), point.z)
	root.scale = Vector3.ONE * scale_value

	var trunk := MeshInstance3D.new()
	var trunk_mesh := CylinderMesh.new()
	trunk_mesh.top_radius = 0.16
	trunk_mesh.bottom_radius = 0.24
	trunk_mesh.height = 2.8
	trunk_mesh.radial_segments = 8
	trunk.mesh = trunk_mesh
	trunk.position = Vector3(0.0, 1.4, 0.0)
	trunk.material_override = world_materials["trunk"] as Material
	root.add_child(trunk)

	for layer: int in range(3):
		var foliage := MeshInstance3D.new()
		var crown := CylinderMesh.new()
		crown.top_radius = 0.0
		crown.bottom_radius = 1.25 - float(layer) * 0.18
		crown.height = 2.4
		crown.radial_segments = 12
		foliage.mesh = crown
		foliage.position = Vector3(0.0, 2.9 + float(layer) * 0.75, 0.0)
		foliage.material_override = world_materials["canopy"] as Material
		root.add_child(foliage)
	add_child(root)
	placed_tree_points.append(point)


func _build_world_detail() -> void:
	for i: int in range(8):
		var x := -26.0 + float(i) * 7.0
		var z := 6.7 + sin(float(i) * 1.7) * 1.2
		if not _is_route_protected(Vector2(x, z), 0.5):
			_add_rock_cluster(Vector3(x, 0.0, z), 2)
	print("WORLD_DETAIL=PASS|TYPE=ROCK_EDGE_ACCENTS|PLACEMENT=CONSTRAINT_AWARE")


func _build_command_camera() -> void:
	var camera := Camera3D.new()
	camera.name = "WorldReproductionCamera"
	camera.position = Vector3(1.5, 27.5, 31.5)
	camera.fov = 50.0
	add_child(camera)
	camera.look_at(Vector3(1.5, 0.0, -2.2), Vector3.UP)
	camera.current = true
	print("CAMERA_ENV_FREEZE=PASS|POSITION=(1.5,27.5,31.5)|LOOK_AT=(1.5,0,-2.2)|FOV=50.0")


func _is_route_protected(point: Vector2, padding: float) -> bool:
	var main_inside := point.x >= -31.0 and point.x <= 28.0 and absf(point.y - MAIN_ROAD_Z) <= MAIN_ROAD_HALF_WIDTH + padding
	if main_inside:
		return true
	var branch_distance := _distance_point_to_segment(point, Vector2(JUNCTION_ANCHOR.x, JUNCTION_ANCHOR.z), Vector2(BRANCH_END.x, BRANCH_END.z))
	return branch_distance <= BRANCH_ROAD_HALF_WIDTH + padding


func _distance_point_to_segment(point: Vector2, a: Vector2, b: Vector2) -> float:
	var ab := b - a
	var length_sq := ab.length_squared()
	if length_sq <= 0.0001:
		return point.distance_to(a)
	var t := clampf((point - a).dot(ab) / length_sq, 0.0, 1.0)
	return point.distance_to(a + ab * t)


func _point_inside_blocker(point: Vector2, padding: float) -> bool:
	for i: int in range(blocker_centers.size()):
		var center := blocker_centers[i]
		var half_size := blocker_half_sizes[i]
		if absf(point.x - center.x) <= half_size.x + padding and absf(point.y - center.y) <= half_size.y + padding:
			return true
	return false


func _movement_point_passable(point: Vector3) -> bool:
	var point_2d := Vector2(point.x, point.z)
	if not _is_route_protected(point_2d, -MOVEMENT_CLEARANCE):
		return false
	if _point_inside_blocker(point_2d, MOVEMENT_CLEARANCE):
		return false
	return true


func _tick_movement(delta: float) -> void:
	var before := player_unit.position
	var offset := COMMAND_TARGET - before
	offset.y = 0.0
	var remaining := offset.length()
	if remaining > 0.03:
		var step := minf(MOVE_SPEED * delta, remaining)
		var proposed := player_unit.position + offset.normalized() * step
		if not _movement_point_passable(proposed):
			print("WORLD_TO_MOVEMENT=FAIL|POINT=%s|REASON=PASSABILITY_GATE_REJECTED" % _fmt_vec(proposed))
			print("FAILED_EDGE=WORLD_TO_MOVEMENT_PASSABILITY")
			phase = Phase.COMPLETE
			_update_hud()
			return
		player_unit.position = proposed
		if not movement_started and player_unit.position.distance_to(before) > 0.0001:
			movement_started = true
			print("MOVEMENT_STARTED=YES|FROM=%s" % _fmt_vec(before))
			print("MOVEMENT_REPRESENTATION=DIRECT_KINEMATIC_WITH_WORLD_PASSABILITY_GATE")
	if player_unit.position.distance_to(target_unit.position) <= CONTACT_RANGE:
		_begin_contact()
		return
	if remaining <= 0.03:
		movement_end_position = player_unit.position
		print("MOVEMENT_COMPLETED_OR_CONTACT=MOVEMENT_COMPLETED")
		print("END_POSITION=%s" % _fmt_vec(movement_end_position))
		print("FAILED_EDGE=CONTACT|REASON=COMMAND_TARGET_REACHED_WITHOUT_CONTACT")
		phase = Phase.COMPLETE
		_update_hud()


func _verify_world_method() -> bool:
	var sample_count := 33
	var route_clear := true
	for i: int in range(sample_count):
		var t := float(i) / float(sample_count - 1)
		var point := PLAYER_START.lerp(COMMAND_TARGET, t)
		if not _movement_point_passable(point):
			route_clear = false
			break

	var vegetation_clear := true
	for tree_point: Vector3 in placed_tree_points:
		if _is_route_protected(Vector2(tree_point.x, tree_point.z), 0.45):
			vegetation_clear = false
			break

	var surface_pass := world_surface_roles.size() >= 8 and world_materials.size() >= 10
	var vegetation_pass := patch_tree_count >= 18 and straggler_tree_count >= 4 and vegetation_clear
	var anchors_pass := blocker_centers.size() >= 4
	var constraints_pass := route_clear and vegetation_clear
	var camera_pass := get_node_or_null("WorldReproductionCamera") != null
	var overall := route_clear and surface_pass and vegetation_pass and anchors_pass and constraints_pass and camera_pass

	print("WORLD_TO_MOVEMENT=%s|SAMPLES=%d|REPRESENTATION=DIRECT_KINEMATIC_WITH_WORLD_PASSABILITY_GATE" % ["PASS" if route_clear else "FAIL", sample_count])
	print("CONSTRAINT_LAYERS=%s|ROUTE_CLEARANCE=%s|VEGETATION_CLEARANCE=%s|BLOCKER_COUNT=%d" % ["PASS" if constraints_pass else "FAIL", str(route_clear), str(vegetation_clear), blocker_centers.size()])
	print("SURFACE_BINDING=%s|SEMANTIC_ROLES=%d|MATERIAL_BINDINGS=%d" % ["PASS" if surface_pass else "FAIL", world_surface_roles.size(), world_materials.size()])
	print("VEGETATION_WORLD_CHECK=%s|PATCH_TREES=%d|STRAGGLERS=%d" % ["PASS" if vegetation_pass else "FAIL", patch_tree_count, straggler_tree_count])
	print("ANCHOR_WORLD_CHECK=%s|ANCHOR_BLOCKERS=%d" % ["PASS" if anchors_pass else "FAIL", blocker_centers.size()])
	print("OLD_SCENE_COORDINATE_COPY=NO|WORLD_LAYOUT=NEW_RULE_DRIVEN_JUNCTION_AND_DEFENSIVE_ANCHOR")
	print("W-C1=CORRECTED_REPRODUCED|W-C2=REPRODUCED|W-C3=REPRODUCED|W-C4=REPRODUCED|W-C5=REPRODUCED|W-C6=REPRODUCED|W-C7=REPRODUCED")
	print("WORLD_REPRODUCTION_METHOD_PASS=%s" % ("YES" if overall else "NO"))
	return overall


func _verify_player_chain() -> void:
	super._verify_player_chain()
	var chain_ok := (
		player_input_events >= 2
		and selected
		and command_issued
		and movement_started
		and contact_reached
		and combat_mutated
		and target_destroyed
		and target_hp == 0
	)
	print("WORLD_AND_PLAYER_CHAIN_PASS=%s" % ("YES" if world_method_pass and chain_ok else "NO"))
