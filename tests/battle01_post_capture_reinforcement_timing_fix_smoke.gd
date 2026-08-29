extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle01/Battle01.tscn")

var _failures: PackedStringArray = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	print("FRONTLINE_POST_CAPTURE_REINFORCEMENT_TIMING_FIX_SMOKE_BEGIN")
	await _scenario_pre_capture_dormant_and_gate_preserved()
	await _scenario_post_capture_full_delay_and_immediate_armor()
	await _scenario_delay_crosses_150_without_preemption()
	await _scenario_150_fallback_before_capture_no_duplicate()
	await _scenario_150_fallback_without_capture()

	if _failures.is_empty():
		print("FRONTLINE_POST_CAPTURE_REINFORCEMENT_TIMING_FIX_SMOKE_PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error("POST_CAPTURE_REINFORCEMENT_TIMING_SMOKE_FAILURE %s" % failure)
		quit(1)

func _scenario_pre_capture_dormant_and_gate_preserved() -> void:
	var c: Dictionary = await _spawn_battle()
	var ai: BattleEnemyAIPostCaptureReinforcementController = c["ai"] as BattleEnemyAIPostCaptureReinforcementController
	var armor: BattleFormation = c["armor"] as BattleFormation
	var blue: BattleFormation = c["blue"] as BattleFormation
	var objective: BattleObjective = c["objective"] as BattleObjective

	ai._elapsed = 149.0
	_require(_reinforcements_dormant(ai), "PRE_CAPTURE_REINFORCEMENTS_DORMANT_BEFORE_150_PASS")

	_clear_blue_intel(ai)
	blue.global_position = objective.global_position
	_force_confirmed(ai, blue)
	objective.state = "CAPTURING"
	objective.capturing_faction = "BLUE"
	objective.progress = 0.5
	ai._decision_tick()
	var armor_agent: Dictionary = ai._agents[armor]
	var gate_preserved: bool = (
		ai.is_pre_first_central_armor_gate_active_for_test()
		and armor_agent["target"] == null
		and (str(armor_agent["state"]) == ai.HOLD or str(armor_agent["state"]) == ai.RETURN)
		and armor.global_position.distance_to(objective.global_position) > objective.capture_radius
	)
	_require(gate_preserved, "PRE_CAPTURE_ARMOR_GATE_PRESERVED_PASS")
	await _dispose_battle(c)

func _scenario_post_capture_full_delay_and_immediate_armor() -> void:
	var c: Dictionary = await _spawn_battle()
	var ai: BattleEnemyAIPostCaptureReinforcementController = c["ai"] as BattleEnemyAIPostCaptureReinforcementController
	var armor: BattleFormation = c["armor"] as BattleFormation
	var blue: BattleFormation = c["blue"] as BattleFormation
	var objective: BattleObjective = c["objective"] as BattleObjective
	var reinf_inf: BattleFormation = c["reinf_inf"] as BattleFormation
	var reinf_armor: BattleFormation = c["reinf_armor"] as BattleFormation

	ai._elapsed = 30.0
	_clear_blue_intel(ai)
	blue.global_position = objective.global_position
	_force_confirmed(ai, blue)
	objective._complete_capture(BattleObjective.OWNER_PLAYER)

	var delay_started: bool = (
		ai.get_first_player_central_capture_completed_for_test()
		and ai.is_post_capture_reinforcement_delay_active_for_test()
		and is_equal_approx(ai.get_post_capture_reinforcement_delay_started_at_for_test(), 30.0)
		and _reinforcements_dormant(ai)
	)
	_require(delay_started, "POST_CAPTURE_15S_DELAY_STARTED_PASS")

	ai._decision_tick()
	var armor_state: String = str((ai._agents[armor] as Dictionary)["state"])
	var immediate_armor: bool = (
		not ai.is_pre_first_central_armor_gate_active_for_test()
		and (armor_state == ai.ENGAGE or armor_state == ai.MOVE)
		and not bool((ai._agents[reinf_inf] as Dictionary)["active"])
		and not bool((ai._agents[reinf_armor] as Dictionary)["active"])
	)
	_require(immediate_armor, "INITIAL_RED_ARMOR_IMMEDIATE_COUNTERATTACK_PASS")

	var started_at: float = ai.get_post_capture_reinforcement_delay_started_at_for_test()
	ai._elapsed = started_at + 14.99
	ai._process(0.0)
	_require(not bool((ai._agents[reinf_inf] as Dictionary)["active"]), "REINFORCEMENT_INFANTRY_0_TO_14_99_DORMANT_PASS")
	_require(not bool((ai._agents[reinf_armor] as Dictionary)["active"]), "REINFORCEMENT_ARMOR_0_TO_14_99_DORMANT_PASS")

	ai._elapsed = started_at + 15.0
	ai._process(0.0)
	var exact_activation: bool = (
		bool((ai._agents[reinf_inf] as Dictionary)["active"])
		and bool((ai._agents[reinf_armor] as Dictionary)["active"])
		and ai._reinforcements_active
		and not ai.is_post_capture_reinforcement_delay_active_for_test()
		and ai.get_reinforcement_activation_count_for_test() == 1
	)
	_require(exact_activation, "POST_CAPTURE_15S_REINFORCEMENTS_ACTIVATE_ONCE_PASS")

	var roster_preserved: bool = (
		ai._reinforcements.size() == 2
		and _count_named(ai._reinforcements, "RED REINFORCEMENT INF-01") == 1
		and _count_named(ai._reinforcements, "RED REINFORCEMENT ARMOR-01") == 1
	)
	_require(roster_preserved, "REINFORCEMENT_ROSTER_INF1_ARMOR1_PRESERVED_PASS")
	await _dispose_battle(c)

func _scenario_delay_crosses_150_without_preemption() -> void:
	var c: Dictionary = await _spawn_battle()
	var ai: BattleEnemyAIPostCaptureReinforcementController = c["ai"] as BattleEnemyAIPostCaptureReinforcementController
	var objective: BattleObjective = c["objective"] as BattleObjective

	ai._elapsed = 149.0
	objective._complete_capture(BattleObjective.OWNER_PLAYER)
	var started_at: float = ai.get_post_capture_reinforcement_delay_started_at_for_test()
	ai._process(1.5)
	var crossed_without_activation: bool = (
		ai._elapsed >= 150.0
		and ai.is_post_capture_reinforcement_delay_active_for_test()
		and not ai._reinforcements_active
		and ai.get_reinforcement_activation_count_for_test() == 0
	)
	_require(crossed_without_activation, "FIXED_TIME_150S_CANNOT_PREEMPT_ACTIVE_DELAY_PASS")

	ai._elapsed = started_at + 14.99
	ai._process(0.0)
	_require(not ai._reinforcements_active, "FULL_15S_WINDOW_PRESERVED_AFTER_150_CROSS_PASS")
	ai._elapsed = started_at + 15.0
	ai._process(0.0)
	_require(ai._reinforcements_active and ai.get_reinforcement_activation_count_for_test() == 1, "DELAY_AFTER_150_CROSS_ACTIVATES_ONCE_PASS")
	await _dispose_battle(c)

func _scenario_150_fallback_before_capture_no_duplicate() -> void:
	var c: Dictionary = await _spawn_battle()
	var ai: BattleEnemyAIPostCaptureReinforcementController = c["ai"] as BattleEnemyAIPostCaptureReinforcementController
	var objective: BattleObjective = c["objective"] as BattleObjective

	ai._elapsed = 149.9
	ai._process(0.2)
	var pre_capture_active: bool = ai._reinforcements_active and ai.get_reinforcement_activation_count_for_test() == 1
	_require(pre_capture_active, "FIXED_TIME_150S_PRECAPTURE_ACTIVATION_PASS")

	objective._complete_capture(BattleObjective.OWNER_PLAYER)
	ai._process(20.0)
	var no_duplicate: bool = (
		ai._reinforcements_active
		and ai.get_reinforcement_activation_count_for_test() == 1
		and not ai.is_post_capture_reinforcement_delay_active_for_test()
	)
	_require(no_duplicate, "PREACTIVE_150S_CAPTURE_NO_DUPLICATE_REINFORCEMENT_PASS")
	await _dispose_battle(c)

func _scenario_150_fallback_without_capture() -> void:
	var c: Dictionary = await _spawn_battle()
	var ai: BattleEnemyAIPostCaptureReinforcementController = c["ai"] as BattleEnemyAIPostCaptureReinforcementController
	var objective: BattleObjective = c["objective"] as BattleObjective

	ai._elapsed = 149.75
	ai._process(0.30)
	var fallback_pass: bool = (
		objective.get_control_owner() != BattleObjective.OWNER_PLAYER
		and not ai.get_first_player_central_capture_completed_for_test()
		and ai._reinforcements_active
		and ai.get_reinforcement_activation_count_for_test() == 1
	)
	_require(fallback_pass, "FIXED_TIME_150S_NO_CENTRAL_FALLBACK_PASS")
	await _dispose_battle(c)

func _spawn_battle() -> Dictionary:
	var battle: Node2D = BATTLE_SCENE.instantiate() as Node2D
	var roster_pre_ready: BattleFormalCombatRoster = battle.get_node("FormalCombatRoster") as BattleFormalCombatRoster
	roster_pre_ready.force_seed_for_test(0)
	root.add_child(battle)
	for _frame: int in range(5):
		await process_frame
	battle.process_mode = Node.PROCESS_MODE_DISABLED
	var roster: BattleFormalCombatRoster = battle.get_node("FormalCombatRoster") as BattleFormalCombatRoster
	var ai: BattleEnemyAIPostCaptureReinforcementController = battle.get_node("EnemyAIController") as BattleEnemyAIPostCaptureReinforcementController
	return {
		"battle": battle,
		"ai": ai,
		"objective": battle.get_node("CentralBridgehead") as BattleObjective,
		"blue": battle.get_node("BlueFormation") as BattleFormation,
		"armor": roster.enemy_armor[0] as BattleFormation,
		"reinf_inf": roster.reinforcement_infantry[0] as BattleFormation,
		"reinf_armor": roster.reinforcement_armor[0] as BattleFormation,
	}

func _clear_blue_intel(ai: BattleEnemyAIPostCaptureReinforcementController) -> void:
	for target: BattleFormation in ai._blue:
		if target != null and is_instance_valid(target):
			ai._force_intel_for_ci(target, ai.UNSEEN, target.global_position, false)

func _force_confirmed(ai: BattleEnemyAIPostCaptureReinforcementController, target: BattleFormation) -> void:
	ai._force_intel_for_ci(target, ai.CONFIRMED, target.global_position, true)

func _reinforcements_dormant(ai: BattleEnemyAIPostCaptureReinforcementController) -> bool:
	if ai._reinforcements_active or ai._reinforcements.size() != 2:
		return false
	for unit: BattleFormation in ai._reinforcements:
		if unit == null or not ai._agents.has(unit):
			return false
		if bool((ai._agents[unit] as Dictionary)["active"]):
			return false
	return true

func _count_named(units: Array[BattleFormation], display_name: String) -> int:
	var count: int = 0
	for unit: BattleFormation in units:
		if unit != null and unit.display_name == display_name:
			count += 1
	return count

func _dispose_battle(context: Dictionary) -> void:
	var battle: Node = context.get("battle") as Node
	if battle != null and is_instance_valid(battle):
		battle.queue_free()
	await process_frame
	await process_frame

func _require(condition: bool, marker: String) -> void:
	if condition:
		print(marker)
	else:
		_failures.append(marker)
		push_error("FAILED %s" % marker)
