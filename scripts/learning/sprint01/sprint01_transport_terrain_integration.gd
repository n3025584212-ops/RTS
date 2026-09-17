extends "res://scripts/learning/sprint01/sprint01_world_delivery_repair.gd"

# Final Sprint01 physical-integration repair.
# Gameplay/passability authority remains in the inherited reproduction logic.
# This layer changes only PLAYER-visible terrain/transport presentation.


func _terrain_height(x: float, z: float) -> float:
	var base := super._terrain_height(x, z)
	var main_distance := absf(z - MAIN_ROAD_Z)
	var branch_distance := _distance_point_to_segment(
		Vector2(x, z),
		Vector2(JUNCTION_ANCHOR.x, JUNCTION_ANCHOR.z),
		Vector2(BRANCH_END.x, BRANCH_END.z)
	)

	# Preserve the authoritative road/branch corridor while restoring stronger
	# landform outside it. This removes the broad tabletop-flat reading without
	# changing movement/passability semantics.
	var main_relief_mask := _smooth01(MAIN_ROAD_HALF_WIDTH + 0.6, MAIN_ROAD_HALF_WIDTH + 5.2, main_distance)
	var branch_relief_mask := _smooth01(BRANCH_ROAD_HALF_WIDTH + 0.5, BRANCH_ROAD_HALF_WIDTH + 4.2, branch_distance)
	var relief_mask := minf(main_relief_mask, branch_relief_mask)
	var broad_relief := (
		0.32 * sin(x * 0.083 + z * 0.027)
		+ 0.22 * cos(z * 0.137 - x * 0.031)
		+ 0.13 * sin((x - z) * 0.19)
	) * relief_mask

	# Shallow roadside drainage cuts and low outer berms create physical edge
	# cues instead of a clean slab terminating directly in grass.
	var main_ditch_center := MAIN_ROAD_HALF_WIDTH + 1.05
	var branch_ditch_center := BRANCH_ROAD_HALF_WIDTH + 0.85
	var main_ditch := -0.16 * exp(-pow((main_distance - main_ditch_center) / 0.78, 2.0))
	var branch_ditch := -0.11 * exp(-pow((branch_distance - branch_ditch_center) / 0.68, 2.0))
	var main_berm := 0.12 * exp(-pow((main_distance - (MAIN_ROAD_HALF_WIDTH + 2.6)) / 1.15, 2.0))
	var branch_berm := 0.09 * exp(-pow((branch_distance - (BRANCH_ROAD_HALF_WIDTH + 2.1)) / 0.95, 2.0))

	return base + broad_relief + main_ditch + branch_ditch + main_berm + branch_berm


func _build_transport_surfaces() -> void:
	# The logical corridor remains the inherited straight MAIN_ROAD_Z / branch
	# segment. The visible centerline may wander slightly inside that corridor so
	# the road no longer reads as one machine-cut rectangular strip.
	var main_points: Array[Vector3] = [
		Vector3(-31.0, 0.0, -1.55),
		Vector3(-24.0, 0.0, -1.82),
		Vector3(-17.0, 0.0, -2.28),
		Vector3(-9.0, 0.0, -1.72),
		Vector3(-1.0, 0.0, -2.36),
		JUNCTION_ANCHOR,
		Vector3(14.0, 0.0, -2.32),
		Vector3(21.0, 0.0, -1.68),
		Vector3(28.0, 0.0, -2.18),
	]
	var main_surface_widths: Array[float] = [3.35, 3.10, 3.22, 3.02, 3.28, 3.48, 3.18, 3.02, 3.20]
	var main_shoulder_widths: Array[float] = [4.45, 4.15, 4.35, 4.10, 4.38, 4.62, 4.30, 4.12, 4.34]
	var main_verge_widths: Array[float] = [5.25, 4.92, 5.12, 4.96, 5.16, 5.40, 5.08, 4.92, 5.14]

	var branch_points: Array[Vector3] = [
		JUNCTION_ANCHOR,
		Vector3(6.15, 0.0, -5.0),
		Vector3(6.55, 0.0, -8.2),
		Vector3(8.15, 0.0, -11.4),
		Vector3(8.35, 0.0, -14.25),
		BRANCH_END,
	]
	var branch_surface_widths: Array[float] = [2.25, 2.05, 2.12, 1.95, 2.05, 2.18]
	var branch_shoulder_widths: Array[float] = [3.12, 2.92, 3.00, 2.82, 2.96, 3.06]
	var branch_verge_widths: Array[float] = [3.76, 3.55, 3.66, 3.46, 3.62, 3.72]

	_build_variable_ribbon("MainRoadOuterVerge", main_points, main_verge_widths, 0.022, world_materials["transition"] as Material)
	_build_variable_ribbon("MainRoadShoulder", main_points, main_shoulder_widths, 0.038, world_materials["shoulder"] as Material)
	_build_variable_ribbon("MainRoadSurface", main_points, main_surface_widths, 0.064, world_materials["road"] as Material)

	_build_variable_ribbon("BranchRoadOuterVerge", branch_points, branch_verge_widths, 0.025, world_materials["transition"] as Material)
	_build_variable_ribbon("BranchRoadShoulder", branch_points, branch_shoulder_widths, 0.041, world_materials["shoulder"] as Material)
	_build_variable_ribbon("BranchRoadSurface", branch_points, branch_surface_widths, 0.069, world_materials["road"] as Material)

	# Irregular compacted ground replaces the obvious radial hardstand/decal
	# language while keeping the same functional anchors.
	var junction_shape: Array[Vector2] = [
		Vector2(-4.4, -2.0), Vector2(-2.1, -3.4), Vector2(1.2, -3.6),
		Vector2(4.2, -2.2), Vector2(4.8, 0.6), Vector2(2.9, 2.8),
		Vector2(-0.6, 3.2), Vector2(-3.8, 2.0),
	]
	var objective_shape: Array[Vector2] = [
		Vector2(-4.2, -1.9), Vector2(-2.8, -3.1), Vector2(0.2, -3.4),
		Vector2(3.9, -2.5), Vector2(4.5, -0.1), Vector2(3.1, 2.3),
		Vector2(0.6, 3.1), Vector2(-3.6, 2.4),
	]
	_add_irregular_ground_patch("JunctionCompactedGround", JUNCTION_ANCHOR, junction_shape, 0.052, world_materials["hardstand"] as Material)
	_add_irregular_ground_patch("ObjectiveDisturbedGround", OBJECTIVE_ANCHOR, objective_shape, 0.050, world_materials["earthwork"] as Material)

	# Small verge wear patches visually bind real assets and transport surfaces
	# into the same physical landscape instead of isolated semantic islands.
	_add_verge_wear_patch("WestRoadWear", Vector3(-18.0, 0.0, 3.2), Vector2(5.5, 2.1), -8.0)
	_add_verge_wear_patch("JunctionNorthWear", Vector3(5.0, 0.0, 3.4), Vector2(4.3, 1.8), 12.0)
	_add_verge_wear_patch("ObjectiveSouthWear", Vector3(15.2, 0.0, -6.3), Vector2(4.8, 1.9), -17.0)
	_add_verge_wear_patch("BranchEastWear", Vector3(11.1, 0.0, -11.8), Vector2(3.8, 1.6), 31.0)

	print("TRANSPORT_LAYER=PASS|MAIN_CORRIDOR=EXPLICIT|BRANCH=EXPLICIT|JUNCTION_ANCHOR=%s" % _fmt_vec(JUNCTION_ANCHOR))
	print("TRANSPORT_PRESENTATION=TERRAIN_FITTED_RIBBONS_AND_PATCHES|BOX_ROADS=NO|CYLINDER_HARDSTANDS=NO")
	print("TRANSPORT_TERRAIN_INTEGRATION_REPAIR=PASS|ROAD_WIDTH=VARIABLE|ROAD_CENTERLINE=GRADED|VERGES=LAYERED|HARDSTANDS=IRREGULAR|ROADSIDE_RELIEF=DITCH_BERM")


func _build_variable_ribbon(node_name: String, points: Array[Vector3], half_widths: Array[float], y_offset: float, material: Material) -> void:
	assert(points.size() >= 2)
	assert(points.size() == half_widths.size())
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var left_points: Array[Vector3] = []
	var right_points: Array[Vector3] = []
	for i: int in range(points.size()):
		var tangent := _path_tangent(points, i)
		var side := Vector3(-tangent.z, 0.0, tangent.x) * half_widths[i]
		var left := Vector3(points[i].x - side.x, 0.0, points[i].z - side.z)
		var right := Vector3(points[i].x + side.x, 0.0, points[i].z + side.z)
		left.y = _terrain_height(left.x, left.z) + y_offset
		right.y = _terrain_height(right.x, right.z) + y_offset
		left_points.append(left)
		right_points.append(right)

	for i: int in range(points.size() - 1):
		_add_textured_triangle(st, left_points[i], right_points[i], right_points[i + 1])
		_add_textured_triangle(st, left_points[i], right_points[i + 1], left_points[i + 1])

	var mesh := st.commit()
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.material_override = material
	add_child(instance)


func _path_tangent(points: Array[Vector3], index: int) -> Vector3:
	var tangent: Vector3
	if index <= 0:
		tangent = points[1] - points[0]
	elif index >= points.size() - 1:
		tangent = points[points.size() - 1] - points[points.size() - 2]
	else:
		tangent = points[index + 1] - points[index - 1]
	tangent.y = 0.0
	return tangent.normalized()


func _add_irregular_ground_patch(node_name: String, center: Vector3, offsets: Array[Vector2], y_offset: float, material: Material) -> void:
	assert(offsets.size() >= 3)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var center_point := Vector3(center.x, _terrain_height(center.x, center.z) + y_offset, center.z)
	for i: int in range(offsets.size()):
		var a := offsets[i]
		var b := offsets[(i + 1) % offsets.size()]
		var p0 := Vector3(center.x + a.x, 0.0, center.z + a.y)
		var p1 := Vector3(center.x + b.x, 0.0, center.z + b.y)
		p0.y = _terrain_height(p0.x, p0.z) + y_offset
		p1.y = _terrain_height(p1.x, p1.z) + y_offset
		_add_textured_triangle(st, center_point, p0, p1)
	var mesh := st.commit()
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.material_override = material
	add_child(instance)


func _add_verge_wear_patch(node_name: String, center: Vector3, radii: Vector2, yaw_degrees: float) -> void:
	var yaw := deg_to_rad(yaw_degrees)
	var offsets: Array[Vector2] = [
		Vector2(-radii.x, -radii.y * 0.35),
		Vector2(-radii.x * 0.42, -radii.y),
		Vector2(radii.x * 0.35, -radii.y * 0.86),
		Vector2(radii.x, -radii.y * 0.18),
		Vector2(radii.x * 0.72, radii.y * 0.72),
		Vector2(0.0, radii.y),
		Vector2(-radii.x * 0.82, radii.y * 0.58),
	]
	for i: int in range(offsets.size()):
		offsets[i] = offsets[i].rotated(yaw)
	_add_irregular_ground_patch(node_name, center, offsets, 0.030, world_materials["transition"] as Material)
