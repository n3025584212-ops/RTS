extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle01/Battle01.tscn")

var _failures: PackedStringArray = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	print("FRONTLINE_PRE_RESERVE_CENTRAL_PROGRESSION_FIX_SMOKE_BEGIN")
	await _scenario_capturing_does_not_commit_armor()
	await _scenario_contested_does_not_commit_armor()
	await _scenario_infantry_loss_does_not_bypass_gate()
	await _scenario_direct_self_defense()
	await _scenario_rear_security()
	await _scenario_pursuit_leash()
	await _scenario_post_capture_counterattack_and_contest()

	if _failures.is_empty():
		print("FRONTLINE_PRE_RESERVE_CENTRAL_PROGRESSION_FIX_SMOKE_PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error("PRE_RESERVE_CENTRAL_FIX_SMOKE_FAILURE %s" % failure)
		quit(1)

func _scenario_capturing_does_not_commit_armor() -> void:
	var c: Dictionary = await _spawn_battle()
	var ai: BattleEnemyAIPreReserveProgressionController = c["ai"] as BattleEnemyAIPreReserveProgressionController
	var armor: BattleFormation = c["armor"] as BattleFormation
	var blue: BattleFormation = c["blue"] as BattleFormation
	var objective: BattleObjective = c["objective"] as BattleObjective
	_clear_blue_intel(ai)
	blue.global_position = objective.global_position
	_force_confirmed(ai, blue)
	objective.state = "CAPTURING"
	objective.capturing_faction = "BLUE"
	objective.progress = 0.5
	ai._decision_tick()
	var agent: Dictionary = ai._agents[armor]
	var scenario_pass: bool = (
		ai.is_pre_first_central_armor_gate_active_for_test()
		and agent["target"] == null
		and (str(agent["state"]) == ai.HOLD or str(agent["state"]) == ai.RETURN)
		and armor.global_position.distance_to(objective.global_position) > objective.capture_radius
		and not ai._armor_commit_allowed(armor)
	)
	_require(scenario_pass, "PRE_CAPTURE_CAPTURING_NO_ARMOR_DENIAL_PASS")
	await _dispose_battle(c)

func _scenario_contested_does_not_commit_armor() -> void:
	var c: Dictionary = await _spawn_battle()
	var ai: BattleEnemyAIPreReserveProgressionController = c["ai"] as BattleEnemyAIPreReserveProgressionController
	var armor: BattleFormation = c["armor"] as BattleFormation
	var blue: BattleFormation = c["blue"] as BattleFormation
	var objective: BattleObjective = c["objective"] as BattleObjective
	_clear_blue_intel(ai)
	blue.global_position = objective.global_position
	_force_confirmed(ai, blue)
	objective.state = "CONTESTED"
	objective.contested = true
	ai._decision_tick()
	var agent: Dictionary = ai._agents[armor]
	var scenario_pass: bool = (
		agent["target"] == null
		and (str(agent["state"]) == ai.HOLD or str(agent["state"]) == ai.RETURN)
		and armor.global_position.distance_to(objective.global_position) > objective.capture_radius
		and not ai._armor_commit_allowed(armor)
	)
	_require(scenario_pass, "PRE_CAPTURE_CONTESTED_NO_ARMOR_DENIAL_PASS")
	await _dispose_battle(c)

func _scenario_infantry_loss_does_not_bypass_gate() -> void:
	var c: Dictionary = await _spawn_battle()
	var ai: BattleEnemyAIPreReserveProgressionController = c["ai"] as BattleEnemyAIPreReserveProgressionController
	var armor: BattleFormation = c["armor"] as BattleFormation
	var inf1: BattleFormation = c["inf1"] as BattleFormation
	var inf2: BattleFormation = c["inf2"] as BattleFormation
	var blue: BattleFormation = c["blue"] as BattleFormation
	var objective: BattleObjective = c["objective"] as BattleObjective
	_clear_blue_intel(ai)
	inf1.is_alive = false
	var inf2_agent: Dictionary = ai._agents[inf2]
	inf2_agent["state"] = ai.ENGAGE
	ai._agents[inf2] = inf2_agent
	# Inside the old DEFENSE_RADIUS but outside both Central core and the Armor's
	# 350-unit local reserve leash. This used to satisfy the second commit bypass.
	blue.global_position = objective.global_position + Vector2(-300.0, 0.0)
	_force_confirmed(ai, blue)
	objective.state = "AI_CONTROLLED"
	ai._decision_tick()
	var armor_agent: Dictionary = ai._agents[armor]
	var scenario_pass: bool = (
		armor_agent["target"] == null
		and (str(armor_agent["state"]) == ai.HOLD or str(armor_agent["state"]) == ai.RETURN)
		and not ai._armor_commit_allowed(armor)
	)
	_require(scenario_pass, "PRE_CAPTURE_INFANTRY_LOSS_NO_ARMOR_DENIAL_PASS")
	await _dispose_battle(c)

func _scenario_direct_self_defense() -> void:
	var c: Dictionary = await _spawn_battle()
	var ai: BattleEnemyAIPreReserveProgressionController = c["ai"] as BattleEnemyAIPreReserveProgressionController
	var armor: BattleFormation = c["armor"] as BattleFormation
	var blue: BattleFormation = c["blue"] as BattleFormation
	var objective: BattleObjective = c["objective"] as BattleObjective
	_clear_blue_intel(ai)
	# Primary Armor seed-0 anchor is 300 units east of Central. Put the attacker in
	# the Central core but exactly within Armor range: return fire is legal, movement
	# into the core is not.
	blue.global_position = objective.global_position
	_force_confirmed(ai, blue)
	var armor_agent: Dictionary = ai._agents[armor]
	armor_agent["recent_attacker"] = blue
	armor_agent["recent_attacker_time"] = ai._elapsed
	ai._agents[armor] = armor_agent
	objective.state = "CAPTURING"
	objective.capturing_faction = "BLUE"
	objective.progress = 0.4
	var armor_position_before: Vector2 = armor.global_position
	var hp_before: int = blue.current_hp
	var ammo_before: int = armor.current_ammo
	ai._decision_tick()
	armor._fire_cooldown = 0.0
	armor._update_combat()
	armor_agent = ai._agents[armor]
	var scenario_pass: bool = (
		str(armor_agent["state"]) == ai.ENGAGE
		and armor_agent["target"] == blue
		and armor.global_position.is_equal_approx(armor_position_before)
		and armor.global_position.distance_to(objective.global_position) > objective.capture_radius
		and armor.current_ammo == ammo_before - 1
		and blue.current_hp < hp_before
	)
	_require(scenario_pass, "ARMOR_LOCAL_SELF_DEFENSE_PASS")
	await _dispose_battle(c)

func _scenario_rear_security() -> void:
	var c: Dictionary = await _spawn_battle()
	var ai: BattleEnemyAIPreReserveProgressionController = c["ai"] as BattleEnemyAIPreReserveProgressionController
	var armor: BattleFormation = c["armor"] as BattleFormation
	var supply: BattleFormation = c["supply"] as BattleFormation
	var blue: BattleFormation = c["blue"] as BattleFormation
	var objective: BattleObjective = c["objective"] as BattleObjective
	_clear_blue_intel(ai)
	blue.global_position = supply.global_position + Vector2(-160.0, 0.0)
	_force_confirmed(ai, blue)
	objective.state = "CAPTURING"
	objective.capturing_faction = "BLUE"
	objective.progress = 0.3
	ai._decision_tick()
	var agent: Dictionary = ai._agents[armor]
	var scenario_pass: bool = (
		str(agent["state"]) == ai.ENGAGE
		and agent["target"] == blue
		and blue.global_position.distance_to(supply.global_position) <= ai.SUPPLY_THREAT_RADIUS + 100.0
		and blue.global_position.distance_to(objective.global_position) > objective.capture_radius
	)
	_require(scenario_pass, "ARMOR_REAR_SECURITY_PASS")
	await _dispose_battle(c)

func _scenario_pursuit_leash() -> void:
	var c: Dictionary = await _spawn_battle()
	var ai: BattleEnemyAIPreReserveProgressionController = c["ai"] as BattleEnemyAIPreReserveProgressionController
	var armor: BattleFormation = c["armor"] as BattleFormation
	var blue: BattleFormation = c["blue"] as BattleFormation
	_clear_blue_intel(ai)
	var anchor: Vector2 = Vector2((ai._agents[armor] as Dictionary)["assigned_anchor"])
	blue.global_position = anchor + Vector2(200.0, 0.0)
	_force_confirmed(ai, blue)
	ai._decision_tick()
	var engaged: bool = str((ai._agents[armor] as Dictionary)["state"]) == ai.ENGAGE
	blue.global_position = anchor + Vector2(ai.MAX_PURSUIT_DISTANCE + 150.0, 0.0)
	_force_confirmed(ai, blue)
	ai._decision_tick()
	var agent: Dictionary = ai._agents[armor]
	var bounded: bool = (
		engaged
		and agent["target"] == null
		and (str(agent["state"]) == ai.RETURN or str(agent["state"]) == ai.HOLD)
	)
	_require(bounded, "ARMOR_PURSUIT_LEASH_PASS")
	await _dispose_battle(c)

func _scenario_post_capture_counterattack_and_contest() -> void:
	var c: Dictionary = await _spawn_battle()
	var ai: BattleEnemyAIPreReserveProgressionController = c["ai"] as BattleEnemyAIPreReserveProgressionController
	var armor: BattleFormation = c["armor"] as BattleFormation
	var blue: BattleFormation = c["blue"] as BattleFormation
	var objective: BattleObjective = c["objective"] as BattleObjective
	_clear_blue_intel(ai)
	blue.global_position = objective.global_position
	_force_confirmed(ai, blue)
	objective._complete_capture(BattleObjective.OWNER_PLAYER)
	ai._decision_tick()
	var post_agent: Dictionary = ai._agents[armor]
	var counterattack_pass: bool = (
		ai.get_first_player_central_capture_completed_for_test()
		and not ai.is_pre_first_central_armor_gate_active_for_test()
		and (str(post_agent["state"]) == ai.ENGAGE or str(post_agent["state"]) == ai.MOVE)
	)
	_require(counterattack_pass, "POST_FIRST_CAPTURE_COUNTERATTACK_PASS")

	# Re-arm the post-capture objective mission without giving the AI precise BLUE
	# intel. Existing objective-emergency logic should now move Armor into Central,
	# where its frozen Contest=YES role can deny the PLAYER-owned objective.
	armor.stop()
	armor.clear_combat_target()
	var reset_agent: Dictionary = ai._agents[armor]
	reset_agent["state"] = ai.HOLD
	reset_agent["target"] = null
	ai._agents[armor] = reset_agent
	_clear_blue_intel(ai)
	blue.global_position = objective.global_position
	objective.state = "CAPTURED"
	ai._decision_tick()
	var mission_started: bool = str((ai._agents[armor] as Dictionary)["state"]) == ai.MOVE
	_advance_movement_to_hold(armor)
	objective._process(0.10)
	var contest_pass: bool = (
		mission_started
		and armor.is_contest_capable()
		and armor.global_position.distance_to(objective.global_position) <= objective.capture_radius
		and objective.is_contested()
	)
	_require(contest_pass, "POST_FIRST_CAPTURE_ARMOR_CONTEST_PASS")
	await _dispose_battle(c)

func _spawn_battle() -> Dictionary:
	var battle: Node2D = BATTLE_SCENE.instantiate() as Node2D
	var roster_pre_ready: BattleFormalCombatRoster = battle.get_node("FormalCombatRoster") as BattleFormalCombatRoster
	roster_pre_ready.force_seed_for_test(0)
	root.add_child(battle)
	await process_frame
	await process_frame
	await process_frame
	await process_frame
	battle.process_mode = Node.PROCESS_MODE_DISABLED
	var roster: BattleFormalCombatRoster = battle.get_node("FormalCombatRoster") as BattleFormalCombatRoster
	var ai: BattleEnemyAIPreReserveProgressionController = battle.get_node("EnemyAIController") as BattleEnemyAIPreReserveProgressionController
	return {
		"battle": battle,
		"ai": ai,
		"objective": battle.get_node("CentralBridgehead") as BattleObjective,
		"blue": battle.get_node("BlueFormation") as BattleFormation,
		"blue_infantry": battle.get_node("BlueInfantry") as BattleFormation,
		"armor": roster.enemy_armor[0] as BattleFormation,
		"supply": roster.enemy_supply_trucks[0] as BattleFormation,
		"inf1": roster.enemy_infantry[0] as BattleFormation,
		"inf2": roster.enemy_infantry[1] as BattleFormation,
	}

func _clear_blue_intel(ai: BattleEnemyAIPreReserveProgressionController) -> void:
	for target: BattleFormation in ai._blue:
		if target != null and is_instance_valid(target):
			ai._force_intel_for_ci(target, ai.UNSEEN, target.global_position, false)

func _force_confirmed(ai: BattleEnemyAIPreReserveProgressionController, target: BattleFormation) -> void:
	ai._force_intel_for_ci(target, ai.CONFIRMED, target.global_position, true)

func _advance_movement_to_hold(formation: BattleFormation) -> void:
	for _step: int in range(1200):
		if formation.get_order() == "HOLD":
			return
		formation._update_movement(0.10)

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
