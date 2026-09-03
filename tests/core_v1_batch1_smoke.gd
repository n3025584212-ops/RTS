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

	# Explicit common commander-facing contract: ASSIGN -> RETASK -> CANCEL.
	var first_task := FormationTask.assign_to(Vector2(700.0, 80.0), &"EAST_TASK", 2)
	var assigned: int = commands.assign([agent], first_task)
	_require(assigned == 1 and commands.get_last_operation() == TaskCommandService.OP_ASSIGN, "CORE_COMMAND_ASSIGN_SURFACE_PASS")
	_require(agent.state.current_task == FormationTask.ASSIGN and agent.state.execution_state == FormationState.EXECUTION_MOVING, "CORE_TASK_ASSIGN_PASS")

	for _step: int in range(30):
		agent.force_tick_for_test(0.05)
	var position_before_retask: Vector2 = agent.state.position
	var replacement := FormationTask.assign_to(Vector2(140.0, 240.0), &"SOUTH_TASK", 5)
	var retasked: int = commands.retask([agent], replacement)
	var current_after_retask: FormationTask = agent.get_current_task()
	_require(retasked == 1 and commands.get_last_operation() == TaskCommandService.OP_RETASK, "CORE_COMMAND_RETASK_SURFACE_PASS")
	_require(current_after_retask.target_id == &"SOUTH_TASK" and current_after_retask.target_position == Vector2(140.0, 240.0), "CORE_RETASK_REPLACES_TASK_PASS")
	_require(agent.state.position == position_before_retask and agent.has_active_navigation_path(), "CORE_RETASK_REPLACES_PATH_WITHOUT_TELEPORT_PASS")

	var cancelled: int = commands.cancel([agent])
	var current_after_cancel: FormationTask = agent.get_current_task()
	var last_recorded: FormationTask = commands.get_last_task(agent)
	_require(cancelled == 1 and commands.get_last_operation() == TaskCommandService.OP_CANCEL, "CORE_COMMAND_CANCEL_SURFACE_PASS")
	_require(current_after_cancel.task_type == FormationTask.HOLD and not agent.has_active_navigation_path(), "CORE_CANCEL_RETURNS_TO_HOLD_PASS")
	_require(agent.state.execution_state == FormationState.EXECUTION_HOLDING, "CORE_CANCEL_STOPS_LOCAL_EXECUTION_PASS")
	_require(last_recorded != null and last_recorded.task_type == FormationTask.HOLD, "CORE_CANCEL_RECORDED_BY_COMMAND_SERVICE_PASS")
	_require(commands.get_command_revision() == 3, "CORE_ASSIGN_RETASK_CANCEL_REVISION_PASS")
	print("FRONTLINE_CORE_TASK_COMMAND_ASSIGN_RETASK_CANCEL_PASS")

	# Existing movement/persistent-task execution remains covered after the command
	# surface change.
	var reissued: int = commands.assign_area([agent], Vector2(700.0, 80.0), &"EAST_TASK", 2)
	_require(reissued == 1 and agent.state.execution_state == FormationState.EXECUTION_MOVING, "CORE_AUTONOMY_PATH_ACCEPT_PASS")
	for _step: int in range(160):
		agent.force_tick_for_test(0.05)
		if not agent.has_active_navigation_path():
			break
	_require(agent.state.position.distance_to(Vector2(700.0, 80.0)) <= 45.0, "CORE_AGENT_MOVEMENT_PASS")
	_require(agent.state.execution_state == FormationState.EXECUTION_EXECUTING, "CORE_PERSISTENT_TASK_EXECUTION_PASS")

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
