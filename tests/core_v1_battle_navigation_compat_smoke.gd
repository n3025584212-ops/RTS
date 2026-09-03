extends SceneTree

var _failures: PackedStringArray = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	print("FRONTLINE_CORE_V1_BATTLE_NAV_COMPAT_BEGIN")
	var host := Node2D.new()
	root.add_child(host)
	var navigation := BattleNavigation.new()
	host.add_child(navigation)
	await process_frame

	var central_vehicle: PackedVector2Array = navigation.get_named_route_for_mobility(&"central", BattleRouteTerrain.MOBILITY_VEHICLE)
	_require(not central_vehicle.is_empty(), "BATTLE_NAV_CORE_SERVICE_CENTRAL_PATH_PASS")
	_require(navigation.path_crosses_bridge(central_vehicle), "BATTLE_NAV_CORE_SERVICE_BRIDGE_PASS")
	_require(not navigation.path_crosses_river_outside_bridge(central_vehicle), "BATTLE_NAV_CORE_SERVICE_RIVER_RULE_PASS")

	var entry: Vector2 = navigation.get_north_foot_link_entry()
	var exit: Vector2 = navigation.get_north_foot_link_exit()
	var foot_path: PackedVector2Array = navigation.find_path_for_mobility(entry, exit, BattleRouteTerrain.MOBILITY_FOOT)
	var vehicle_path: PackedVector2Array = navigation.find_path_for_mobility(entry, exit, BattleRouteTerrain.MOBILITY_VEHICLE)
	_require(not foot_path.is_empty() and navigation.path_uses_north_foot_link(foot_path), "BATTLE_NAV_CORE_SERVICE_FOOT_PROFILE_PASS")
	_require(not vehicle_path.is_empty() and not navigation.path_uses_north_foot_link(vehicle_path), "BATTLE_NAV_CORE_SERVICE_VEHICLE_PROFILE_PASS")
	_require(navigation.get_path_length(vehicle_path) > navigation.get_path_length(foot_path), "BATTLE_NAV_CORE_SERVICE_PROFILE_COST_PASS")

	host.queue_free()
	await process_frame
	if _failures.is_empty():
		print("FRONTLINE_CORE_V1_BATTLE_NAV_COMPAT_PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error("CORE_V1_BATTLE_NAV_COMPAT_FAILURE %s" % failure)
		quit(1)

func _require(condition: bool, marker: String) -> void:
	if condition:
		print(marker)
	else:
		_failures.append(marker)
		push_error("FAILED %s" % marker)
