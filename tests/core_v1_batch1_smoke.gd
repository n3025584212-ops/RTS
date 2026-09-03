extends SceneTree

var _failures: PackedStringArray = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	print("FRONTLINE_CORE_V1_BATCH1_SMOKE_BEGIN")
	var navigation := NavigationService.new()
	var profiles: Array[StringName] = [&"FOOT", &"VEHICLE"]
	var blocked_query := func(world_point: Vector2, profile: StringName) -> bool:
		return profile == &"VEHICLE" and Rect2(Vector2(360.0, 80.0), Vector2(80.0, 160.0)).has_point(world_point)
	navigation.configure(Vector2(800.0, 320.0), Vector2(40.0, 40.0), profiles, blocked_query, 8)

	_require(navigation.has_profile(&"FOOT") and navigation.has_profile(&"VEHICLE"), "CORE_NAV_PROFILES_PASS")
	_require(navigation.is_world_walkable(Vector2(400.0, 160.0), &"FOOT"), "CORE_NAV_FOOT_ACCESS_PASS")
	_require(not navigation.is_world_walkable(Vector2(400.0, 160.0), &"VEHICLE"), "CORE_NAV_VEHICLE_BLOCK_PASS")
	var foot_path: PackedVector2Array = navigation.find_path(Vector2(100.0, 160.0), Vector2(700.0, 160.0), &"FOOT")
	var vehicle_path: PackedVector2Array = navigation.find_path(Vector2(100.0, 160.0), Vector2(700.0, 160.0), &"VEHICLE")
	_require(not foot_path.is_empty() and not vehicle_path.is_empty(), "CORE_NAV_PATH_PASS")
	_require(navigation.get_path_length(vehicle_path) > navigation.get_path_length(foot_path), "CORE_NAV_MOBILITY_COST_DIFFERENCE_PASS")

	var attacker := FormationState.new().configure(&"BLUE_A", "BLUE A", &"BLUE", Vector2.ZERO, 120.0, 100, 6, &"FOOT")
	var target := FormationState.new().configure(&"RED_A", "RED A", &"RED", Vector2.ZERO, 100.0, 90, 4, &"FOOT")
	var damage: int = CombatResolver.apply_attack(attacker, target, 20, 1.25)
	_require(damage == 25 and target.current_hp == 65 and attacker.current_ammo == 5, "CORE_COMBAT_DETERMINISTIC_PASS")
	_require(CombatResolver.apply_attack(attacker, target, 20, 1.0, true) == 0 and attacker.current_ammo == 5, "CORE_COMBAT_HOLD_FIRE_VETO_PASS")

	var agent := FormationAgent2D.new()
	root.add_child(agent)
	agent.configure(&"BLUE_CORE", "BLUE CORE", &"BLUE", Vector2(100.0, 80.0), 160.0, 100, 8, &"FOOT")
	agent.set_navigation_service(navigation)
	var commands := TaskCommandService.new()
	root.add_child(commands)
	var issued: int = commands.assign_area([agent], Vector2(700.0, 80.0), &"EAST_TASK", 2)
	_require(issued == 1 and agent.state.current_task == FormationTask.ASSIGN, "CORE_TASK_ASSIGN_PASS")
	_require(agent.state.execution_state == FormationState.EXECUTION_MOVING, "CORE_AUTONOMY_PATH_ACCEPT_PASS")

	for _step: int in range(120):
		agent.force_tick_for_test(0.05)
		if not agent.has_active_navigation_path():
			break
	_require(agent.state.position.distance_to(Vector2(700.0, 80.0)) <= 45.0, "CORE_AGENT_MOVEMENT_PASS")
	_require(agent.state.execution_state == FormationState.EXECUTION_EXECUTING, "CORE_PERSISTENT_TASK_EXECUTION_PASS")

	var retask_count: int = commands.move([agent], Vector2(140.0, 240.0), 5)
	_require(retask_count == 1 and agent.state.current_task == FormationTask.MOVE, "CORE_RETASK_PASS")
	for _step: int in range(160):
		agent.force_tick_for_test(0.05)
		if not agent.has_active_navigation_path():
			break
	_require(agent.state.execution_state == FormationState.EXECUTION_COMPLETE, "CORE_NONPERSISTENT_MOVE_COMPLETE_PASS")
	_require(commands.get_command_revision() == 2, "CORE_COMMAND_REVISION_PASS")

	agent.queue_free()
	commands.queue_free()
	await process_frame
	if _failures.is_empty():
		print("FRONTLINE_CORE_V1_BATCH1_SMOKE_PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error("CORE_V1_BATCH1_FAILURE %s" % failure)
		quit(1)

func _require(condition: bool, marker: String) -> void:
	if condition:
		print(marker)
	else:
		_failures.append(marker)
		push_error("FAILED %s" % marker)
