extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle01/Battle01.tscn")

var _failures: PackedStringArray = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	print("FRONTLINE_ROUTE_IDENTITY_SMOKE_BEGIN")
	var battle: Node = BATTLE_SCENE.instantiate()
	root.add_child(battle)
	await process_frame
	await process_frame
	await process_frame

	var navigation: BattleNavigation = battle.get_node_or_null("Navigation") as BattleNavigation
	var visibility: BattleVisibilityField = battle.get_node_or_null("VisibilityField") as BattleVisibilityField
	var world3d: Battle3DWorld = battle.get_node_or_null("World3D") as Battle3DWorld
	var recon: BattleFormation = battle.get_node_or_null("BlueRecon") as BattleFormation
	var infantry: BattleFormation = battle.get_node_or_null("BlueInfantry") as BattleFormation
	var ifv: BattleFormation = battle.get_node_or_null("BlueFormation") as BattleFormation
	var logistics: BattleFormation = battle.get_node_or_null("BlueSupply") as BattleFormation
	var armor: BattleFormation = _find_formation_by_display_name(battle, "RED ARMOR-01")

	if navigation == null or visibility == null or world3d == null or recon == null or infantry == null or ifv == null or logistics == null or armor == null:
		_failures.append("SETUP_INCOMPLETE")
		push_error("Route identity smoke setup incomplete.")
		_finish(battle)
		return

	battle.process_mode = Node.PROCESS_MODE_DISABLED

	var central_vehicle: PackedVector2Array = navigation.get_named_route_for_mobility(&"central", BattleRouteTerrain.MOBILITY_VEHICLE)
	var north_vehicle: PackedVector2Array = navigation.get_named_route_for_mobility(&"north", BattleRouteTerrain.MOBILITY_VEHICLE)
	var south_vehicle: PackedVector2Array = navigation.get_named_route_for_mobility(&"south", BattleRouteTerrain.MOBILITY_VEHICLE)
	var central_foot: PackedVector2Array = navigation.get_named_route_for_mobility(&"central", BattleRouteTerrain.MOBILITY_FOOT)
	var central_length: float = navigation.get_path_length(central_vehicle)
	var north_length: float = navigation.get_path_length(north_vehicle)
	var south_length: float = navigation.get_path_length(south_vehicle)

	_require(not central_vehicle.is_empty() and central_length < north_length and central_length < south_length, "CENTRAL_ROUTE_SHORTEST_PASS")
	_require(not central_foot.is_empty() and not central_vehicle.is_empty(), "CENTRAL_ALL_MOBILITY_ACCESS_PASS")
	_require(visibility.has_line_of_sight(BattleRouteTerrain.CENTRAL_EXPOSURE_A, BattleRouteTerrain.CENTRAL_EXPOSURE_B), "CENTRAL_EXPOSURE_LOS_CLEAR_PASS")

	_require(not north_vehicle.is_empty(), "NORTH_ROUTE_VALID_PASS")
	var foot_entry: Vector2 = navigation.get_north_foot_link_entry()
	var foot_exit: Vector2 = navigation.get_north_foot_link_exit()
	var north_foot_shortcut: PackedVector2Array = navigation.find_path_for_mobility(foot_entry, foot_exit, BattleRouteTerrain.MOBILITY_FOOT)
	var north_vehicle_detour: PackedVector2Array = navigation.find_path_for_mobility(foot_entry, foot_exit, BattleRouteTerrain.MOBILITY_VEHICLE)
	var foot_uses_link: bool = not north_foot_shortcut.is_empty() and navigation.path_uses_north_foot_link(north_foot_shortcut)
	var vehicle_avoids_link: bool = not north_vehicle_detour.is_empty() and not navigation.path_uses_north_foot_link(north_vehicle_detour)
	var foot_length: float = navigation.get_path_length(north_foot_shortcut)
	var vehicle_detour_length: float = navigation.get_path_length(north_vehicle_detour)

	_require(foot_uses_link, "NORTH_FOOT_LINK_RECON_PASS")
	_require(foot_uses_link, "NORTH_FOOT_LINK_INFANTRY_PASS")
	_require(vehicle_avoids_link, "NORTH_FOOT_LINK_IFV_BLOCKED_PASS")
	_require(vehicle_avoids_link, "NORTH_FOOT_LINK_ARMOR_BLOCKED_PASS")
	_require(vehicle_avoids_link, "NORTH_FOOT_LINK_LOGISTICS_BLOCKED_PASS")
	_require(vehicle_avoids_link and vehicle_detour_length > foot_length + 80.0, "NORTH_VEHICLE_STREET_DETOUR_PASS")

	var north_broken_a: bool = not visibility.has_line_of_sight(Vector2(1040.0, 320.0), Vector2(1500.0, 320.0))
	var north_broken_b: bool = not visibility.has_line_of_sight(Vector2(1040.0, 540.0), Vector2(1460.0, 540.0))
	var north_local_clear: bool = visibility.has_line_of_sight(Vector2(1000.0, 660.0), Vector2(1320.0, 660.0))
	_require(north_broken_a and north_broken_b and north_local_clear, "NORTH_BROKEN_LOS_PASS")

	_require(not south_vehicle.is_empty() and south_length > central_length and south_length > north_length, "SOUTH_ROUTE_LONGEST_PASS")
	_require(not navigation.get_named_route_for_mobility(&"south", BattleRouteTerrain.MOBILITY_VEHICLE).is_empty(), "SOUTH_IFV_ACCESS_PASS")
	_require(not navigation.find_path_for_mobility(Vector2(1900.0, 900.0), BattleRouteTerrain.SOUTH_REAR_STAGING, BattleRouteTerrain.MOBILITY_VEHICLE).is_empty(), "SOUTH_ARMOR_ACCESS_PASS")
	_require(not navigation.find_path_for_mobility(Vector2(2180.0, 1060.0), BattleRouteTerrain.SOUTH_REAR_STAGING, BattleRouteTerrain.MOBILITY_VEHICLE).is_empty(), "SOUTH_LOGISTICS_ACCESS_PASS")
	_require(visibility.has_line_of_sight(BattleRouteTerrain.SOUTH_LONG_LOS_A, BattleRouteTerrain.SOUTH_LONG_LOS_B), "SOUTH_LONG_LOS_PASS")
	_require(not navigation.find_path_for_mobility(BattleRouteTerrain.SOUTH_REAR_STAGING, BattleRouteTerrain.SOUTH_REAR_PRESSURE_TARGET, BattleRouteTerrain.MOBILITY_VEHICLE).is_empty(), "SOUTH_REAR_PRESSURE_ACCESS_PASS")

	var bridge_rule: bool = (
		navigation.path_crosses_bridge(central_vehicle)
		and navigation.path_crosses_bridge(north_vehicle)
		and navigation.path_crosses_bridge(south_vehicle)
		and not navigation.path_crosses_river_outside_bridge(central_vehicle)
		and not navigation.path_crosses_river_outside_bridge(north_vehicle)
		and not navigation.path_crosses_river_outside_bridge(south_vehicle)
		and not navigation.is_world_walkable_for_mobility(Vector2(1600.0, 400.0), BattleRouteTerrain.MOBILITY_FOOT)
		and navigation.is_world_walkable_for_mobility(Vector2(1600.0, 900.0), BattleRouteTerrain.MOBILITY_VEHICLE)
	)
	_require(bridge_rule, "RIVER_ONLY_BRIDGE_CROSSING_PASS")

	var nav_blockers: Array[Rect2] = navigation.get_hard_blockers()
	var los_blockers: Array[Rect2] = visibility.get_terrain_blockers()
	var geometry_sync: bool = _rect_arrays_equal(nav_blockers, los_blockers)
	geometry_sync = geometry_sync and world3d.get_hard_blocker_mesh_count() == nav_blockers.size()
	geometry_sync = geometry_sync and world3d.has_north_foot_link_visual()
	_require(geometry_sync, "ROUTE_TERRAIN_NAV_LOS_SYNC_PASS")

	var posture_anchors: Array[Vector2] = [
		Vector2(1420.0, 700.0), Vector2(1900.0, 900.0), Vector2(2180.0, 1060.0),
		Vector2(1060.0, 660.0), Vector2(1900.0, 1060.0), Vector2(2300.0, 1180.0),
		Vector2(1340.0, 1380.0), Vector2(1900.0, 700.0), Vector2(2260.0, 1340.0),
	]
	var anchors_ok: bool = true
	for anchor: Vector2 in posture_anchors:
		if not navigation.is_world_walkable_for_mobility(anchor, BattleRouteTerrain.MOBILITY_VEHICLE):
			anchors_ok = false
			break
		if navigation.find_path_for_mobility(Vector2(520.0, 900.0), anchor, BattleRouteTerrain.MOBILITY_VEHICLE).is_empty():
			anchors_ok = false
			break
	_require(anchors_ok, "SEEDED_POSTURE_ANCHORS_ROUTE_GEOMETRY_PASS")

	# Existing isolated real-Formation movement checks remain as baseline coverage.
	recon.global_position = foot_entry
	recon.stop()
	var recon_issued: bool = recon.issue_move(foot_exit)
	var recon_path: PackedVector2Array = recon.get_navigation_path()
	var recon_used_link: bool = recon_issued and navigation.path_uses_north_foot_link(recon_path)
	_advance_formation(recon)
	_require(recon_used_link and recon.global_position.distance_to(foot_exit) <= 6.0, "FORMATION_RECON_FOOT_MOVEMENT_PASS")

	infantry.global_position = foot_entry
	infantry.stop()
	var infantry_issued: bool = infantry.issue_move(foot_exit)
	var infantry_path: PackedVector2Array = infantry.get_navigation_path()
	var infantry_used_link: bool = infantry_issued and navigation.path_uses_north_foot_link(infantry_path)
	_advance_formation(infantry)
	_require(infantry_used_link and infantry.global_position.distance_to(foot_exit) <= 6.0, "FORMATION_INFANTRY_FOOT_MOVEMENT_PASS")

	ifv.global_position = foot_entry
	ifv.stop()
	var ifv_issued: bool = ifv.issue_move(foot_exit)
	var ifv_path: PackedVector2Array = ifv.get_navigation_path()
	var ifv_street_only: bool = ifv_issued and not navigation.path_uses_north_foot_link(ifv_path)
	_advance_formation(ifv)
	_require(ifv_street_only and ifv.global_position.distance_to(foot_exit) <= 6.0, "FORMATION_IFV_NORTH_STREET_MOVEMENT_PASS")

	armor.global_position = Vector2(1900.0, 900.0)
	armor.stop()
	var armor_issued: bool = armor.issue_move(BattleRouteTerrain.SOUTH_REAR_STAGING)
	_advance_formation(armor)
	_require(armor_issued and armor.global_position.distance_to(navigation.clamp_to_walkable_for_mobility(BattleRouteTerrain.SOUTH_REAR_STAGING, BattleRouteTerrain.MOBILITY_VEHICLE)) <= 6.0, "FORMATION_ARMOR_SOUTH_MOVEMENT_PASS")

	ifv.global_position = Vector2(520.0, 900.0)
	ifv.stop()
	var central_target := Vector2(1360.0, 900.0)
	var central_issued: bool = ifv.issue_move(central_target)
	_advance_formation(ifv)
	_require(central_issued and ifv.global_position.distance_to(navigation.clamp_to_walkable_for_mobility(central_target, BattleRouteTerrain.MOBILITY_VEHICLE)) <= 6.0, "FORMATION_VEHICLE_CENTRAL_MOVEMENT_PASS")
	_require(navigation.mobility_for_formation(logistics) == BattleRouteTerrain.MOBILITY_VEHICLE, "LOGISTICS_VEHICLE_PROFILE_PASS")

	# Formation-aware mobility regression A: Recon + IFV exact overlap.
	recon.global_position = foot_entry
	ifv.global_position = foot_entry
	recon.stop()
	ifv.stop()
	var overlap_recon_issued: bool = recon.issue_move(foot_exit)
	var overlap_recon_path: PackedVector2Array = recon.get_navigation_path()
	var overlap_ifv_issued: bool = ifv.issue_move(foot_exit)
	var overlap_ifv_path: PackedVector2Array = ifv.get_navigation_path()
	var overlap_recon_ok: bool = overlap_recon_issued and not overlap_recon_path.is_empty() and navigation.path_uses_north_foot_link(overlap_recon_path)
	var overlap_ifv_ok: bool = overlap_ifv_issued and not overlap_ifv_path.is_empty() and not navigation.path_uses_north_foot_link(overlap_ifv_path)
	_advance_formation(recon)
	_advance_formation(ifv)
	overlap_recon_ok = overlap_recon_ok and recon.global_position.distance_to(foot_exit) <= 6.0
	overlap_ifv_ok = overlap_ifv_ok and ifv.global_position.distance_to(foot_exit) <= 6.0
	_require(overlap_recon_ok, "FORMATION_RECON_FOOT_ACCESS_WITH_VEHICLE_OVERLAP_PASS")
	_require(overlap_ifv_ok, "FORMATION_IFV_VEHICLE_ACCESS_WITH_FOOT_OVERLAP_PASS")

	# Formation-aware mobility regression B: Infantry + Armor within the old 3-unit inference tolerance.
	infantry.global_position = foot_entry
	armor.global_position = foot_entry + Vector2(2.0, 0.0)
	infantry.stop()
	armor.stop()
	var near_infantry_issued: bool = infantry.issue_move(foot_exit)
	var near_infantry_path: PackedVector2Array = infantry.get_navigation_path()
	var near_armor_issued: bool = armor.issue_move(foot_exit)
	var near_armor_path: PackedVector2Array = armor.get_navigation_path()
	var near_infantry_ok: bool = near_infantry_issued and not near_infantry_path.is_empty() and navigation.path_uses_north_foot_link(near_infantry_path)
	var near_armor_ok: bool = near_armor_issued and not near_armor_path.is_empty() and not navigation.path_uses_north_foot_link(near_armor_path)
	_advance_formation(infantry)
	_advance_formation(armor)
	near_infantry_ok = near_infantry_ok and infantry.global_position.distance_to(foot_exit) <= 6.0
	near_armor_ok = near_armor_ok and armor.global_position.distance_to(foot_exit) <= 6.0
	_require(near_infantry_ok, "FORMATION_INFANTRY_FOOT_ACCESS_NEAR_ARMOR_PASS")
	_require(near_armor_ok, "FORMATION_ARMOR_VEHICLE_ACCESS_NEAR_INFANTRY_PASS")

	# Formation-aware mobility regression C: Logistics + Recon exact overlap.
	logistics.global_position = foot_entry
	recon.global_position = foot_entry
	logistics.stop()
	recon.stop()
	var logistics_overlap_issued: bool = logistics.issue_move(foot_exit)
	var logistics_overlap_path: PackedVector2Array = logistics.get_navigation_path()
	var logistics_overlap_ok: bool = logistics_overlap_issued and not logistics_overlap_path.is_empty() and not navigation.path_uses_north_foot_link(logistics_overlap_path)
	_advance_formation(logistics)
	logistics_overlap_ok = logistics_overlap_ok and logistics.global_position.distance_to(foot_exit) <= 6.0
	_require(logistics_overlap_ok, "FORMATION_LOGISTICS_VEHICLE_ACCESS_WITH_RECON_OVERLAP_PASS")

	var formation_aware_binding_ok: bool = overlap_recon_ok and overlap_ifv_ok and near_infantry_ok and near_armor_ok and logistics_overlap_ok
	_require(formation_aware_binding_ok, "FORMATION_AWARE_MOBILITY_BINDING_PASS")

	print("ROUTE_LENGTHS central=%.1f north=%.1f south=%.1f foot_link=%.1f vehicle_detour=%.1f" % [
		central_length, north_length, south_length, foot_length, vehicle_detour_length
	])

	_finish(battle)

func _advance_formation(formation: BattleFormation) -> void:
	for _step: int in range(900):
		if formation.get_order() == "HOLD":
			return
		formation._update_movement(0.10)

func _find_formation_by_display_name(node: Node, display_name: String) -> BattleFormation:
	if node is BattleFormation:
		var formation: BattleFormation = node as BattleFormation
		if formation.display_name == display_name:
			return formation
	for child: Node in node.get_children():
		var found: BattleFormation = _find_formation_by_display_name(child, display_name)
		if found != null:
			return found
	return null

func _rect_arrays_equal(a: Array[Rect2], b: Array[Rect2]) -> bool:
	if a.size() != b.size():
		return false
	for index: int in range(a.size()):
		if a[index] != b[index]:
			return false
	return true

func _require(condition: bool, marker: String) -> void:
	if condition:
		print(marker)
	else:
		_failures.append(marker)
		push_error("FAILED %s" % marker)

func _finish(battle: Node) -> void:
	if _failures.is_empty():
		print("FRONTLINE_ROUTE_IDENTITY_TERRAIN_LOS_SMOKE_PASS")
		if battle != null:
			battle.queue_free()
		quit(0)
		return
	for failure: String in _failures:
		push_error("ROUTE_IDENTITY_SMOKE_FAILURE %s" % failure)
	if battle != null:
		battle.queue_free()
	quit(1)
