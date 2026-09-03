extends SceneTree

var _failures: PackedStringArray = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	print("FRONTLINE_PROTOTYPE_B_CORE_INTEGRATION_SMOKE_BEGIN")
	var packed := load("res://scenes/discovery/PrototypeB_CommandBattle.tscn") as PackedScene
	_require(packed != null, "PROTOTYPE_B_CORE_SCENE_LOAD_PASS")
	if packed == null:
		quit(1)
		return

	var battle := packed.instantiate() as PrototypeBCommandBattle
	_require(battle != null, "PROTOTYPE_B_CORE_SCENE_INSTANTIATE_PASS")
	if battle == null:
		quit(1)
		return
	root.add_child(battle)
	await process_frame
	await process_frame

	var snapshot: Dictionary = battle.debug_snapshot()
	_require(bool(snapshot.get("core_consumer", false)), "PROTOTYPE_B_CORE_CONSUMER_PASS")
	_require(int(snapshot.get("formation_count", 0)) == 5, "PROTOTYPE_B_BLUE_FORMATION_STRUCTURE_PASS")
	_require(int(snapshot.get("enemy_formation_count", 0)) == 3, "PROTOTYPE_B_RED_FORMATION_ACTIVITY_PASS")
	_require(int(snapshot.get("sector_count", 0)) == 3, "PROTOTYPE_B_MULTI_DEMAND_STRUCTURE_PASS")
	_require(not bool(snapshot.get("reserve_committed", true)), "PROTOTYPE_B_RESERVE_INITIAL_STATE_PASS")
	_require(str(snapshot.get("enemy_command_path", "")) == "TASK_COMMAND_SERVICE", "PROTOTYPE_B_ENEMY_COMMON_COMMAND_PATH_PASS")
	_require(bool(snapshot.get("shared_task_command_service", false)), "PROTOTYPE_B_SHARED_TASK_SERVICE_PASS")

	var alpha := battle.debug_get_blue_agent(0)
	var red_one := battle.debug_get_red_agent(0)
	_require(alpha is FormationAgent2D and red_one is FormationAgent2D, "PROTOTYPE_B_CORE_AGENT_TYPES_PASS")
	_require(not battle.blue_meta[0].has("position") and not battle.blue_meta[0].has("task"), "PROTOTYPE_B_DUPLICATE_LOCAL_TASK_MOVEMENT_SIM_REMOVED_PASS")

	var start_position := alpha.state.position
	for _frame: int in range(24):
		await process_frame
	_require(alpha.state.position.distance_to(start_position) > 1.0, "PROTOTYPE_B_CORE_AGENT_MOVEMENT_PASS")
	_require(alpha.state.position.is_equal_approx(alpha.global_position), "PROTOTYPE_B_CORE_STATE_POSITION_AUTHORITY_PASS")

	alpha.state.apply_damage(10)
	var restored := alpha.state.restore_health(5)
	_require(restored == 5 and alpha.state.current_hp == 95, "PROTOTYPE_B_CORE_HEALTH_RECOVERY_PASS")

	var command_service := battle.debug_get_command_service()
	var revision_before_player := command_service.get_command_revision()
	battle.debug_select_formation(4)
	battle.debug_assign_task(PrototypeBCommandBattle.SECTOR_RIDGE)
	await process_frame
	snapshot = battle.debug_snapshot()
	_require(bool(snapshot.get("reserve_committed", false)), "PROTOTYPE_B_RESERVE_COMMIT_PASS")
	_require(int(snapshot.get("reserve_task", -1)) == PrototypeBCommandBattle.SECTOR_RIDGE, "PROTOTYPE_B_RESERVE_TASK_PASS")
	_require(command_service.get_command_revision() == revision_before_player + 1, "PROTOTYPE_B_PLAYER_COMMAND_THROUGH_TASK_SERVICE_PASS")
	_require(battle.debug_get_blue_agent(4).state.current_task == FormationTask.ASSIGN, "PROTOTYPE_B_RESERVE_CORE_TASK_ACCEPT_PASS")

	battle.debug_select_formation(2)
	battle.debug_assign_task(PrototypeBCommandBattle.SECTOR_CROSSING)
	await process_frame
	snapshot = battle.debug_snapshot()
	_require(int(snapshot.get("charlie_task", -1)) == PrototypeBCommandBattle.SECTOR_CROSSING, "PROTOTYPE_B_RETASK_CONSEQUENCE_PASS")
	_require(int(snapshot.get("decision_count", 0)) == 2, "PROTOTYPE_B_PLAYER_DECISION_COUNT_PASS")

	var revision_before_enemy := command_service.get_command_revision()
	battle.debug_force_enemy_phase(2)
	# The command service mutates task state synchronously. Snapshot before the
	# normal scenario clock advances again so this hook tests the forced phase only.
	snapshot = battle.debug_snapshot()
	var red_tasks: Array = snapshot.get("red_tasks", []) as Array
	_require(int(snapshot.get("phase_index", -1)) == 2, "PROTOTYPE_B_ENEMY_ESCALATION_PHASE_PASS")
	_require(red_tasks.size() == 3 and int(red_tasks[0]) == 2 and int(red_tasks[1]) == 2 and int(red_tasks[2]) == 1, "PROTOTYPE_B_ENEMY_RETASK_PATTERN_PASS")
	_require(command_service.get_command_revision() == revision_before_enemy + 3, "PROTOTYPE_B_ENEMY_COMMANDS_THROUGH_TASK_SERVICE_PASS")

	# Freeze automatic scene processing and drive the two staging lifecycles
	# deterministically. These checks specifically guard the former mismatch where
	# Core stopped on a 40 px AStar cell center while scenario arrival checks used
	# the original staging world coordinate.
	battle.set_process(false)
	for index: int in range(5):
		battle.debug_get_blue_agent(index).set_process(false)
	for index: int in range(3):
		battle.debug_get_red_agent(index).set_process(false)

	alpha.state.apply_damage(55)
	battle._update_blue_recovery(0.1)
	var alpha_meta: Dictionary = battle.blue_meta[0]
	_require(bool(alpha_meta["auto_withdraw"]), "PROTOTYPE_B_ALPHA_FALLBACK_TRIGGER_PASS")
	var alpha_fallback_path := alpha.get_navigation_path()
	_require(not alpha_fallback_path.is_empty() and alpha_fallback_path[alpha_fallback_path.size() - 1].distance_to(PrototypeBCommandBattle.BLUE_STAGING_POSITIONS[0]) <= 0.01, "PROTOTYPE_B_ALPHA_CORE_STAGING_ENDPOINT_PASS")
	for _tick: int in range(64):
		alpha.force_tick_for_test(10.0)
	_require(not alpha.has_active_navigation_path(), "PROTOTYPE_B_ALPHA_FALLBACK_PATH_COMPLETE_PASS")
	_require(alpha.state.position.distance_to(PrototypeBCommandBattle.BLUE_STAGING_POSITIONS[0]) <= 0.01, "PROTOTYPE_B_ALPHA_STAGING_ARRIVAL_PASS")
	battle._update_blue_recovery(6.0)
	alpha_meta = battle.blue_meta[0]
	_require(not bool(alpha_meta["auto_withdraw"]), "PROTOTYPE_B_ALPHA_RECOVERY_CLEAR_PASS")
	_require(int(alpha_meta["assigned_sector"]) == PrototypeBCommandBattle.SECTOR_RIDGE and alpha.state.current_task == FormationTask.ASSIGN, "PROTOTYPE_B_ALPHA_RECOVERY_RESUME_PASS")

	var echo := battle.debug_get_blue_agent(4)
	for _tick: int in range(64):
		echo.force_tick_for_test(10.0)
	_require(not echo.has_active_navigation_path(), "PROTOTYPE_B_ECHO_COMMIT_PATH_COMPLETE_PASS")
	battle.sector_control[PrototypeBCommandBattle.SECTOR_RIDGE] = 100.0
	battle.sector_pressure[PrototypeBCommandBattle.SECTOR_RIDGE] = 0.0
	battle._update_reserve_recovery(PrototypeBCommandBattle.RESERVE_STABLE_RETURN_SECONDS + 0.1)
	var echo_meta: Dictionary = battle.blue_meta[4]
	_require(not bool(echo_meta["committed"]) and bool(echo_meta["returning_reserve"]) and int(echo_meta["assigned_sector"]) == PrototypeBCommandBattle.TASK_HOLD, "PROTOTYPE_B_ECHO_RETURN_TO_RESERVE_TRIGGER_PASS")
	var echo_return_path := echo.get_navigation_path()
	_require(not echo_return_path.is_empty() and echo_return_path[echo_return_path.size() - 1].distance_to(PrototypeBCommandBattle.BLUE_STAGING_POSITIONS[4]) <= 0.01, "PROTOTYPE_B_ECHO_CORE_STAGING_ENDPOINT_PASS")
	for _tick: int in range(64):
		echo.force_tick_for_test(10.0)
	_require(echo.state.position.distance_to(PrototypeBCommandBattle.BLUE_STAGING_POSITIONS[4]) <= 0.01, "PROTOTYPE_B_ECHO_STAGING_ARRIVAL_PASS")
	battle._update_blue_recovery(0.1)
	echo_meta = battle.blue_meta[4]
	_require(not bool(echo_meta["committed"]) and not bool(echo_meta["returning_reserve"]) and int(echo_meta["assigned_sector"]) == PrototypeBCommandBattle.TASK_HOLD, "PROTOTYPE_B_ECHO_RESERVE_FLAG_CLEAR_PASS")
	_require(echo.state.current_task == FormationTask.HOLD, "PROTOTYPE_B_ECHO_RETURN_CANCEL_TO_HOLD_PASS")
	print("FRONTLINE_PROTOTYPE_B_STAGING_LIFECYCLE_PASS")

	snapshot = battle.debug_snapshot()
	_require(str(snapshot.get("battle_state", "")) == "RUNNING", "PROTOTYPE_B_OUTCOME_PATH_REMAINS_ACTIVE_PASS")
	print("FRONTLINE_PROTOTYPE_B_REPRESENTATIVE_STRUCTURE_PRESERVED_PASS")

	battle.queue_free()
	await process_frame
	if _failures.is_empty():
		print("FRONTLINE_PROTOTYPE_B_CORE_INTEGRATION_SMOKE_PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error("PROTOTYPE_B_CORE_INTEGRATION_FAILURE %s" % failure)
		quit(1)

func _require(condition: bool, marker: String) -> void:
	if condition:
		print(marker)
	else:
		_failures.append(marker)
		push_error("FAILED %s" % marker)
