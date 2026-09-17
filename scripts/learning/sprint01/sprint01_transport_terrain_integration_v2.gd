extends "res://scripts/learning/sprint01/sprint01_transport_terrain_integration.gd"

# Sprint01 transport-terrain visual integration V2.
# Gameplay, movement/passability and combat authority remain inherited.
# This layer only changes PLAYER-visible physical composition.


func _terrain_height(x: float, z: float) -> float:
	var base := super._terrain_height(x, z)
	var main_distance := absf(z - MAIN_ROAD_Z)
	var branch_distance := _distance_point_to_segment(
		Vector2(x, z),
		Vector2(JUNCTION_ANCHOR.x, JUNCTION_ANCHOR.z),
		Vector2(BRANCH_END.x, BRANCH_END.z)
	)

	var corridor_distance := minf(main_distance, branch_distance)
	var outer_mask := _smooth01(4.4, 10.0, corridor_distance)
	var ridge := (
		0.52 * sin(x * 0.062 + 0.9)
		+ 0.34 * cos(z * 0.105 - 0.7)
		+ 0.18 * sin((x + z) * 0.145)
	) * outer_mask

	var main_drain := -0.20 * exp(-pow((main_distance - 3.25) / 0.58, 2.0))
	var main_bank := 0.16 * exp(-pow((main_distance - 5.10) / 1.05, 2.0))
	var branch_drain := -0.14 * exp(-pow((branch_distance - 2.35) / 0.52, 2.0))
	var branch_bank := 0.11 * exp(-pow((branch_distance - 3.75) / 0.88, 2.0))

	return base + ridge + main_drain + main_bank + branch_drain + branch_bank


func _build_transport_surfaces() -> void:
	var main_points: Array[Vector3] = [
		Vector3(-31.0, 0.0, -0.65),
		Vector3(-26.0, 0.0, -0.95),
		Vector3(-20.0, 0.0, -1.72),
		Vector3(-14.0, 0.0, -2.75),
		Vector3(-8.0, 0.0, -3.18),
		Vector3(-2.0, 0.0, -2.48),
		JUNCTION_ANCHOR,
		Vector3(12.0, 0.0, -1.15),
		Vector3(18.0, 0.0, -1.58),
		Vector3(23.0, 0.0, -2.62),
		Vector3(28.0, 0.0, -3.18),
	]
	var main_surface_widths: Array[float] = [2.35, 2.25, 2.18, 2.30, 2.12, 2.20, 2.52, 2.28, 2.16, 2.25, 2.35]
	var main_shoulder_widths: Array[float] = [3.05, 2.92, 2.88, 3.02, 2.84, 2.90, 3.25, 2.98, 2.86, 2.94, 3.06]
	var main_verge_widths: Array[float] = [3.72, 3.55, 3.48, 3.68, 3.46, 3.52, 3.92, 3.62, 3.50, 3.58, 3.74]

	var branch_points: Array[Vector3] = [
		JUNCTION_ANCHOR,
		Vector3(7.1, 0.0, -4.2),
		Vector3(7.4, 0.0, -6.5),
		Vector3(7.9, 0.0, -8.8),
		Vector3(8.8, 0.0, -11.1),
		Vector3(8.9, 0.0, -13.6),
		BRANCH_END,
	]
	var branch_surface_widths: Array[float] = [1.70, 1.66, 1.60, 1.64, 1.58, 1.64, 1.72]
	var branch_shoulder_widths: Array[float] = [2.35, 2.30, 2.24, 2.30, 2.22, 2.28, 2.36]
	var branch_verge_widths: Array[float] = [2.92, 2.86, 2.80, 2.88, 2.78, 2.84, 2.94]

	_build_variable_ribbon("MainRoadOuterVergeV2", main_points, main_verge_widths, 0.018, world_materials["transition"] as Material)
	_build_variable_ribbon("MainRoadShoulderV2", main_points, main_shoulder_widths, 0.032, world_materials["shoulder"] as Material)
	_build_variable_ribbon("MainRoadSurfaceV2", main_points, main_surface_widths, 0.057, world_materials["road"] as Material)

	_build_variable_ribbon("BranchRoadOuterVergeV2", branch_points, branch_verge_widths, 0.020, world_materials["transition"] as Material)
	_build_variable_ribbon("BranchRoadShoulderV2", branch_points, branch_shoulder_widths, 0.034, world_materials["shoulder"] as Material)
	_build_variable_ribbon("BranchRoadSurfaceV2", branch_points, branch_surface_widths, 0.060, world_materials["road"] as Material)

	var junction_shape: Array[Vector2] = [
		Vector2(-3.0, -1.2), Vector2(-1.7, -2.4), Vector2(0.8, -2.7),
		Vector2(3.1, -1.5), Vector2(3.4, 0.7), Vector2(1.8, 2.0),
		Vector2(-0.7, 2.1), Vector2(-2.8, 1.2),
	]
	var objective_shape: Array[Vector2] = [
		Vector2(-2.9, -1.5), Vector2(-1.4, -2.5), Vector2(1.1, -2.4),
		Vector2(3.0, -1.3), Vector2(2.8, 1.2), Vector2(1.0, 2.1),
		Vector2(-1.7, 1.9), Vector2(-3.1, 0.5),
	]
	_add_irregular_ground_patch("JunctionCompactedGroundV2", JUNCTION_ANCHOR, junction_shape, 0.046, world_materials["hardstand"] as Material)
	_add_irregular_ground_patch("ObjectiveDisturbedGroundV2", OBJECTIVE_ANCHOR, objective_shape, 0.045, world_materials["earthwork"] as Material)

	_add_verge_wear_patch("WestApproachWearV2", Vector3(-23.0, 0.0, 2.1), Vector2(3.4, 1.15), -13.0)
	_add_verge_wear_patch("WestBendWearV2", Vector3(-11.5, 0.0, 1.2), Vector2(3.0, 1.05), 8.0)
	_add_verge_wear_patch("JunctionNorthWearV2", Vector3(4.2, 0.0, 1.7), Vector2(2.7, 1.0), 14.0)
	_add_verge_wear_patch("EastApproachWearV2", Vector3(20.5, 0.0, 1.5), Vector2(3.1, 1.1), -7.0)
	_add_verge_wear_patch("BranchEastWearV2", Vector3(11.0, 0.0, -10.0), Vector2(2.6, 1.0), 29.0)

	print("TRANSPORT_LAYER=PASS|MAIN_CORRIDOR=EXPLICIT|BRANCH=EXPLICIT|JUNCTION_ANCHOR=%s" % _fmt_vec(JUNCTION_ANCHOR))
	print("TRANSPORT_PRESENTATION=TERRAIN_FITTED_RIBBONS_AND_PATCHES|BOX_ROADS=NO|CYLINDER_HARDSTANDS=NO")
	print("TRANSPORT_TERRAIN_INTEGRATION_V2=PASS|VISIBLE_ASPHALT=NARROWER|MAIN_CENTERLINE=MEANDERED|BRANCH=GRADED|HARDSTANDS=COMPACT_ASYMMETRIC|RELIEF=STRONGER")


func _add_real_world_delivery_assets() -> void:
	# Keep the proven base asset set. Add only a small number of extra physical
	# anchors so software-rendered CI retains the validated combat timing.
	super._add_real_world_delivery_assets()
	_instance_delivery_scene(HOUSE_INTACT_PATH, Vector3(20.5, 0.0, 6.2), 0.36, 212.0, "DeliveryHouse_V2_East01")
	_instance_delivery_scene(HOUSE_INTACT_PATH, Vector3(-22.5, 0.0, 8.5), 0.31, 20.0, "DeliveryHouse_V2_West01")
	_instance_delivery_scene(SHRUB_PATH, Vector3(-18.0, 0.0, 4.8), 0.70, 41.0, "DeliveryShrub_V2_West")
	_instance_delivery_scene(SHRUB_PATH, Vector3(17.0, 0.0, 4.2), 0.70, 133.0, "DeliveryShrub_V2_East")
	_instance_delivery_scene(ROCK_A_PATH, Vector3(-7.0, 0.0, 4.6), 0.46, 77.0, "DeliveryRock_V2_West")
	_instance_delivery_scene(ROCK_B_PATH, Vector3(11.2, 0.0, -8.2), 0.46, 211.0, "DeliveryRock_V2_Branch")
	print("DELIVERY_ASSET_INTEGRATION_V2=PASS|EXTRA_HOUSES=2|EXTRA_SHRUBS=2|EXTRA_ROCKS=2")
