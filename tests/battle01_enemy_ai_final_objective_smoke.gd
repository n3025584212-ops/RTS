extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle01/Battle01.tscn")

var _failures: PackedStringArray = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	print("FRONTLINE_ENEMY_AI_FINAL_OBJECTIVE_SMOKE_BEGIN")
	var battle: Node2D = BATTLE_SCENE.instantiate() as Node2D
	root.add_child(battle)
	await process_frame
	await process_frame
	battle.process_mode = Node.PROCESS_MODE_DISABLED

	var ai: BattleEnemyAIController = battle.get_node("EnemyAIController") as BattleEnemyAIController
	var central: BattleObjective = battle.get_node("CentralBridgehead") as BattleObjective
	var industrial: BattleObjective = battle.get_node("IndustrialObjective") as BattleObjective
	var roster: BattleFormalCombatRoster = battle.get_node("FormalCombatRoster") as BattleFormalCombatRoster
	var blue_inf: BattleFormation = battle.get_node("BlueInfantry") as BattleFormation
	var inf1: BattleFormation = battle.get_node("RedFormation") as BattleFormation
	var inf2: BattleFormation = battle.get_node("RedInfantry2") as BattleFormation
	var armor: BattleFormation = battle.get_node("RedArmor1") as BattleFormation
	var supply: BattleFormation = battle.get_node("RedSupplyTruck1") as BattleFormation
	var reinf_inf: BattleFormation = battle.get_node("ReinforcementInfantry1") as BattleFormation

	_require(ai != null and industrial != null and roster != null, "AI_FINAL_OBJECTIVE_INTERFACE_READY_PASS")
	_reset_blue_intel(ai)
	ai._decision_tick()
	var no_premature: bool = (
		industrial.is_player_capture_locked()
		and not ai._is_final_objective_pressure()
		and str((ai._agents[inf1] as Dictionary)["state"]) == BattleEnemyAIController.HOLD
		and str((ai._agents[inf2] as Dictionary)["state"]) == BattleEnemyAIController.HOLD
		and str((ai._agents[armor] as Dictionary)["state"]) == BattleEnemyAIController.HOLD
	)
	_require(no_premature, "AI_FINAL_OBJECTIVE_NO_PREMATURE_REACTION_PASS")

	industrial.unlock_player_capture()
	_set_player_capture_pressure(industrial, 0.25)
	_reset_blue_intel(ai)
	blue_inf.global_position = Vector2(420.0, 420.0)
	ai._decision_tick()

	var inf2_agent: Dictionary = ai._agents[inf2]
	var response_path: PackedVector2Array = inf2.get_navigation_path()
	var expected_destination: Vector2 = ai._navigation.clamp_to_walkable(industrial.global_position)
	var response_destination_valid: bool = not response_path.is_empty() and response_path[response_path.size() - 1].distance_to(expected_destination) <= 1.0
	_require(str(inf2_agent["state"]) == BattleEnemyAIController.MOVE and response_destination_valid, "AI_FINAL_OBJECTIVE_PRESSURE_RESPONSE_PASS")
	_require(inf2_agent["target"] == null and response_destination_valid and response_path[response_path.size() - 1].distance_to(blue_inf.global_position) > 500.0, "AI_FINAL_OBJECTIVE_NO_HIDDEN_BLUE_TRACKING_PASS")

	central.contested = true
	central.capturing_faction = "BLUE"
	central.progress = 0.20
	central._refresh_state(false)
	inf1.stop()
	inf2.stop()
	ai._decision_tick()
	var simultaneous_responder: BattleFormation = ai._select_final_objective_responder(true)
	var central_preserved: bool = (
		simultaneous_responder != inf1
		and (str((ai._agents[inf1]] as Dictionary)["state"]) == BattleEnemyAIController.MOVE or str((ai._agents[inf1] as Dictionary)["state"]) == BattleEnemyAIController.ENGAGE or inf1.global_position.distance_to(central.global_position) <= BattleEnemyAIController.ARRIVAL_TOLERANCE)
	)
	_require(central_preserved, "AI_FINAL_OBJECTIVE_CENTRAL_DEFENSE_PRESERVED_PASS")

	central.contested = false
	central.capturing_faction = ""
	central.progress = 0.0
	central.control_owner = BattleObjective.OWNER_AI
	central._refresh_state(false)
	inf2.global_position = industrial.global_position + Vector2(-120.0, 0.0)
	inf2.stop()
	blue_inf.global_position = industrial.global_position
	ai._force_intel_for_ci(blue_inf, BattleEnemyAIController.CONFIRMED, blue_inf.global_position, true)
	ai._decide_final_objective_responder(inf2)
	var combat_agent: Dictionary = ai._agents[inf2]
	_require(str(combat_agent["state"]) == BattleEnemyAIController.ENGAGE and combat_agent["target"] == blue_inf, "AI_FINAL_OBJECTIVE_COMBAT_RESPONDER_PASS")

	var supply_excluded: bool = (
		ai._select_final_objective_responder(false) != supply
		and ai._is_supply_objective_excluded(industrial.global_position)
		and not supply.can_attack
		and not supply.can_capture
	)
	_require(supply_excluded, "AI_FINAL_OBJECTIVE_SUPPLY_EXCLUDED_PASS")

	var fixed_trigger_unchanged: bool = ai._reinforcement_trigger_reason(BattleEnemyAIController.REINFORCEMENT_TIME, false, false) == "fixed_time"
	var central_loss_trigger_unchanged: bool = ai._reinforcement_trigger_reason(0.0, true, false) == "objective_loss"
	ai._activate_reinforcements("final_objective_smoke_existing_trigger")
	var inf2_saved: Dictionary = ai._agents[inf2]
	inf2_saved["active"] = false
	ai._agents[inf2] = inf2_saved
	var reinforcement_responder: BattleFormation = ai._select_final_objective_responder(false)
	var roster_counts: Dictionary = roster.get_roster_counts()
	var reinforcement_eligible: bool = (
		fixed_trigger_unchanged
		and central_loss_trigger_unchanged
		and reinforcement_responder == reinf_inf
		and bool((ai._agents[reinf_inf] as Dictionary)["active"])
		and int(roster_counts["reinforcement_infantry"]) == 1
		and int(roster_counts["reinforcement_armor"]) == 1
	)
	_require(reinforcement_eligible, "AI_FINAL_OBJECTIVE_REINFORCEMENT_ELIGIBLE_PASS")
	inf2_saved["active"] = true
	ai._agents[inf2] = inf2_saved

	_reset_blue_intel(ai)
	industrial.control_owner = BattleObjective.OWNER_AI
	industrial.contested = false
	industrial.capturing_faction = ""
	industrial.progress = 0.0
	industrial._refresh_state(false)
	inf2.global_position = industrial.global_position + Vector2(-120.0, 0.0)
	inf2.stop()
	ai._decision_tick()
	var recenter_state: String = str((ai._agents[inf2] as Dictionary)["state"])
	_require(recenter_state == BattleEnemyAIController.RETURN or recenter_state == BattleEnemyAIController.HOLD, "AI_FINAL_OBJECTIVE_RETURN_OR_RECENTER_PASS")

	_set_player_capture_pressure(industrial, 0.40)
	var deterministic_a: BattleFormation = ai._select_final_objective_responder(false)
	var deterministic_b: BattleFormation = ai._select_final_objective_responder(false)
	var route_a: String = ai._select_route_name(inf2.global_position, industrial.global_position)
	var route_b: String = ai._select_route_name(inf2.global_position, industrial.global_position)
	_require(deterministic_a == deterministic_b and route_a == route_b, "AI_FINAL_OBJECTIVE_DETERMINISTIC_PASS")

	if _failures.is_empty():
		print("FRONTLINE_ENEMY_AI_FINAL_OBJECTIVE_SMOKE_PASS")
		battle.queue_free()
		await process_frame
		quit(0)
	else:
		for failure: String in _failures:
			push_error("FINAL_OBJECTIVE_AI_SMOKE_FAILURE %s" % failure)
		battle.queue_free()
		await process_frame
		quit(1)

func _reset_blue_intel(ai: BattleEnemyAIController) -> void:
	for target: BattleFormation in ai._blue:
		if target == null or not ai._intel.has(target):
			continue
		var record: Dictionary = ai._intel[target]
		record["state"] = BattleEnemyAIController.UNSEEN
		record["last_known"] = Vector2.ZERO
		record["confirm_progress"] = 0.0
		record["forced_reveal"] = 0.0
		ai._intel[target] = record

func _set_player_capture_pressure(objective: BattleObjective, progress: float) -> void:
	objective.control_owner = BattleObjective.OWNER_AI
	objective.contested = false
	objective.capturing_faction = "BLUE"
	objective.progress = progress
	objective._refresh_state(false)

func _require(condition: bool, marker: String) -> void:
	if condition:
		print(marker)
	else:
		_failures.append(marker)
		push_error("FAILED %s" % marker)
