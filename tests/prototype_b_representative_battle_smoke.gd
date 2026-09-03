extends SceneTree

var _failures: PackedStringArray = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	print("FRONTLINE_PROTOTYPE_B_REPRESENTATIVE_BATTLE_SMOKE_BEGIN")
	var packed := load("res://scenes/discovery/PrototypeB_CommandBattle.tscn") as PackedScene
	_require(packed != null, "PROTOTYPE_B_REPRESENTATIVE_SCENE_LOAD_PASS")
	if packed == null:
		quit(1)
		return

	var battle := packed.instantiate() as PrototypeBRepresentativeBattle
	_require(battle != null, "PROTOTYPE_B_REPRESENTATIVE_SCENE_TYPE_PASS")
	if battle == null:
		quit(1)
		return
	root.add_child(battle)
	await process_frame
	await process_frame

	var snapshot := battle.debug_representative_snapshot()
	_require(str(snapshot.get("enemy_commander_mode", "")) == "STATE_DRIVEN", "PROTOTYPE_B_STATE_DRIVEN_COMMANDER_MODE_PASS")
	_require(int(snapshot.get("formation_count", 0)) == 5 and int(snapshot.get("enemy_formation_count", 0)) == 3 and int(snapshot.get("sector_count", 0)) == 3, "PROTOTYPE_B_REPRESENTATIVE_STRUCTURE_PASS")
	_require(not bool(snapshot.get("red_reserve_committed", true)), "PROTOTYPE_B_RED_RESERVE_INITIAL_UNCOMMITTED_PASS")
	var initial_red_tasks: Array = snapshot.get("red_tasks", []) as Array
	_require(initial_red_tasks.size() == 3 and int(initial_red_tasks[0]) == PrototypeBCommandBattle.SECTOR_RIDGE and int(initial_red_tasks[1]) == PrototypeBCommandBattle.SECTOR_RELAY and int(initial_red_tasks[2]) == PrototypeBCommandBattle.TASK_HOLD, "PROTOTYPE_B_RED_INITIAL_COMMITMENT_STRUCTURE_PASS")

	# Freeze normal clocks and drive a deterministic battlefield state. A strong
	# BLUE control gain at CROSSING must cause RED to commit its previously free
	# formation through the same TaskCommandService used by BLUE.
	battle.set_process(false)
	for index: int in range(5):
		battle.debug_get_blue_agent(index).set_process(false)
	for index: int in range(3):
		battle.debug_get_red_agent(index).set_process(false)

	battle.sector_control[PrototypeBCommandBattle.SECTOR_CROSSING] = 78.0
	battle.sector_control[PrototypeBCommandBattle.SECTOR_RIDGE] = 0.0
	battle.sector_control[PrototypeBCommandBattle.SECTOR_RELAY] = -20.0
	var command_service := battle.debug_get_command_service()
	var revision_before_enemy := command_service.get_command_revision()
	battle.debug_force_enemy_reassess()
	snapshot = battle.debug_representative_snapshot()
	var red_tasks: Array = snapshot.get("red_tasks", []) as Array
	_require(bool(snapshot.get("red_reserve_committed", false)), "PROTOTYPE_B_STATE_DRIVEN_RED_RESERVE_COMMIT_PASS")
	_require(int(snapshot.get("enemy_focus_sector", -1)) == PrototypeBCommandBattle.SECTOR_CROSSING, "PROTOTYPE_B_STATE_DRIVEN_RED_FOCUS_PASS")
	_require(red_tasks.size() == 3 and int(red_tasks[2]) == PrototypeBCommandBattle.SECTOR_CROSSING, "PROTOTYPE_B_STATE_DRIVEN_RED_TASK_PASS")
	_require(command_service.get_command_revision() > revision_before_enemy, "PROTOTYPE_B_STATE_DRIVEN_RED_SHARED_COMMAND_SERVICE_PASS")
	_require(battle.debug_get_red_agent(2).state.current_task == FormationTask.ASSIGN, "PROTOTYPE_B_STATE_DRIVEN_RED_CORE_TASK_PASS")

	# Put the committed RED reserve in the threatened sector so the support test
	# exercises real FormationState consequences instead of a score-only modifier.
	var red_reserve := battle.debug_get_red_agent(2)
	var red_target := battle._red_target_for(2, PrototypeBCommandBattle.SECTOR_CROSSING)
	red_reserve.state.set_position(red_target)
	red_reserve.global_position = red_target
	battle._recompute_sector_pressure()
	var pressure_before_support := battle.sector_pressure[PrototypeBCommandBattle.SECTOR_CROSSING]
	var hp_before_support := red_reserve.state.current_hp

	var support_accepted := battle.debug_use_support(PrototypeBCommandBattle.SECTOR_CROSSING)
	_require(support_accepted, "PROTOTYPE_B_LIMITED_SUPPORT_FIRST_MISSION_ACCEPT_PASS")
	battle.debug_force_support_tick(1.1)
	snapshot = battle.debug_representative_snapshot()
	_require(int(snapshot.get("support_charges", -1)) == 1, "PROTOTYPE_B_LIMITED_SUPPORT_CHARGE_COST_PASS")
	_require(int(snapshot.get("support_active_sector", -1)) == PrototypeBCommandBattle.SECTOR_CROSSING, "PROTOTYPE_B_LIMITED_SUPPORT_SECTOR_COMMIT_PASS")
	_require(red_reserve.state.current_hp < hp_before_support, "PROTOTYPE_B_LIMITED_SUPPORT_FORMATION_DAMAGE_PASS")
	_require(battle.sector_intel[PrototypeBCommandBattle.SECTOR_CROSSING] >= 0.92, "PROTOTYPE_B_LIMITED_SUPPORT_INTEL_CERTAINTY_PASS")
	_require(battle.sector_pressure[PrototypeBCommandBattle.SECTOR_CROSSING] < pressure_before_support, "PROTOTYPE_B_LIMITED_SUPPORT_SUPPRESSION_PASS")

	var second_immediate := battle.debug_use_support(PrototypeBCommandBattle.SECTOR_RIDGE)
	_require(not second_immediate and battle.support_charges == 1, "PROTOTYPE_B_LIMITED_SUPPORT_NO_SPAM_PASS")

	battle.debug_force_support_tick(PrototypeBRepresentativeBattle.SUPPORT_DURATION_SECONDS + 0.2)
	battle.debug_force_support_tick(PrototypeBRepresentativeBattle.SUPPORT_COOLDOWN_SECONDS + 0.2)
	var second_later := battle.debug_use_support(PrototypeBCommandBattle.SECTOR_RIDGE)
	_require(second_later and battle.support_charges == 0, "PROTOTYPE_B_LIMITED_SUPPORT_LATER_TRADEOFF_PASS")

	# Sector trend must report battlefield direction from live control movement,
	# not a recommended answer generated by UI policy.
	battle.last_control_sample[PrototypeBCommandBattle.SECTOR_RIDGE] = 0.0
	battle.sector_control[PrototypeBCommandBattle.SECTOR_RIDGE] = 24.0
	battle.debug_force_trend_sample()
	snapshot = battle.debug_representative_snapshot()
	var trends: Array = snapshot.get("sector_trends", []) as Array
	_require(trends.size() == 3 and str(trends[PrototypeBCommandBattle.SECTOR_RIDGE]) == "GAINING", "PROTOTYPE_B_BATTLEFIELD_TREND_STATE_PASS")
	_require(str(snapshot.get("battle_state", "")) == "RUNNING", "PROTOTYPE_B_REPRESENTATIVE_OUTCOME_PATH_ACTIVE_PASS")

	print("FRONTLINE_PROTOTYPE_B_STATE_DRIVEN_ENEMY_RESPONSE_PASS")
	print("FRONTLINE_PROTOTYPE_B_LIMITED_COMMANDER_SUPPORT_PASS")
	print("FRONTLINE_PROTOTYPE_B_BATTLEFIELD_TRENDS_PASS")

	battle.queue_free()
	await process_frame
	if _failures.is_empty():
		print("FRONTLINE_PROTOTYPE_B_REPRESENTATIVE_BATTLE_SMOKE_PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error("PROTOTYPE_B_REPRESENTATIVE_BATTLE_FAILURE %s" % failure)
		quit(1)

func _require(condition: bool, marker: String) -> void:
	if condition:
		print(marker)
	else:
		_failures.append(marker)
		push_error("FAILED %s" % marker)
