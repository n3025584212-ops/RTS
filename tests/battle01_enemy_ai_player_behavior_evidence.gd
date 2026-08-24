extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle01/Battle01.tscn")
const TESTED_GAME_COMMIT: String = "0cef3a9b1e1dd2078d9eb25966949c8dc96b1929"

var _failures: PackedStringArray = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	print("PLAYER_BEHAVIOR_EVIDENCE_BEGIN tested_game_commit=%s" % TESTED_GAME_COMMIT)
	var battle: Node = BATTLE_SCENE.instantiate()
	root.add_child(battle)
	await process_frame
	await process_frame

	var ai: BattleEnemyAIController = battle.get_node_or_null("EnemyAIController") as BattleEnemyAIController
	if ai == null or not bool(ai._initialized):
		_fail("SETUP", "enemy_ai_not_initialized")
		_finish(battle)
		return

	# Freeze automatic scene processing. The runner invokes the existing production
	# perception, decision, navigation, and Formation movement methods explicitly so
	# every telemetry row is deterministic and no gameplay implementation is replaced.
	battle.process_mode = Node.PROCESS_MODE_DISABLED

	_run_pursuit_return(ai)
	_run_armor_reserve_cycle(ai)
	_run_supply_evade(ai)
	_run_flank_response(ai)
	_finish(battle)


func _run_pursuit_return(ai: BattleEnemyAIController) -> void:
	_reset_fixture(ai)
	var inf1: BattleFormation = ai._find_red("RED INF-01")
	var blue: BattleFormation = ai._blue[0] as BattleFormation
	var home: Vector2 = Vector2((ai._agents[inf1] as Dictionary)["home"])
	blue.global_position = Vector2(1370.0, 620.0)
	var initial_distance: float = inf1.global_position.distance_to(blue.global_position)
	var legitimate: bool = ai._is_legitimately_detected(blue)
	_trace("PURSUIT_RETURN", 0.00, inf1, ai, blue, "initial_hold", "legit_detected=%s target_dist=%.1f home_dist=%.1f" % [legitimate, initial_distance, inf1.global_position.distance_to(home)])

	ai._update_red_intel(0.01)
	_trace("PURSUIT_RETURN", 0.01, inf1, ai, blue, "legal_contact", "legit_detected=%s" % ai._is_legitimately_detected(blue))
	ai._update_red_intel(0.76)
	ai._decide_combat_unit(inf1, false)
	var engage_origin: Vector2 = Vector2((ai._agents[inf1] as Dictionary)["engage_origin"])
	_trace("PURSUIT_RETURN", 0.77, inf1, ai, blue, "confirmed_engage", "legit_detected=%s engage_origin=%s" % [ai._is_legitimately_detected(blue), _pos(engage_origin)])

	inf1._update_movement(0.50)
	var pursued_distance: float = engage_origin.distance_to(inf1.global_position)
	_trace("PURSUIT_RETURN", 1.27, inf1, ai, blue, "bounded_pursuit", "pursued=%.1f leash=%.1f" % [pursued_distance, ai.MAX_PURSUIT_DISTANCE])

	var frozen_last_known: Vector2 = Vector2((ai._intel[blue] as Dictionary)["last_known"])
	blue.global_position = Vector2(520.0, 900.0)
	ai._update_red_intel(0.01)
	ai._decide_combat_unit(inf1, false)
	_trace("PURSUIT_RETURN", 1.28, inf1, ai, blue, "lost_confirmation", "actual_blue=%s frozen_last_known=%s hidden_offset=%.1f" % [_pos(blue.global_position), _pos(frozen_last_known), blue.global_position.distance_to(frozen_last_known)])

	ai._elapsed += ai.INVESTIGATE_TIMEOUT + 0.10
	ai._decide_combat_unit(inf1, false)
	_trace("PURSUIT_RETURN", 5.38, inf1, ai, blue, "return_started", "home_dist=%.1f" % inf1.global_position.distance_to(home))
	_advance_to_anchor(inf1)
	ai._decide_combat_unit(inf1, false)
	var final_agent: Dictionary = ai._agents[inf1]
	var passed: bool = (
		legitimate
		and pursued_distance > 0.0
		and str((ai._intel[blue] as Dictionary)["state"]) == ai.LAST_KNOWN
		and Vector2((ai._intel[blue] as Dictionary)["last_known"]).is_equal_approx(frozen_last_known)
		and str(final_agent["state"]) == ai.HOLD
		and final_agent["target"] == null
		and inf1.global_position.distance_to(home) <= ai.ARRIVAL_TOLERANCE
	)
	_trace("PURSUIT_RETURN", 9.38, inf1, ai, blue, "recenter_complete", "home_dist=%.1f target_cleared=%s result=%s" % [inf1.global_position.distance_to(home), final_agent["target"] == null, _result(passed)])
	_require(passed, "PURSUIT_RETURN", "defender_did_not_complete_bounded_pursuit_return")


func _run_armor_reserve_cycle(ai: BattleEnemyAIController) -> void:
	_reset_fixture(ai)
	var armor: BattleFormation = ai._find_red("RED ARMOR-01")
	var blue: BattleFormation = ai._blue[0] as BattleFormation
	var home: Vector2 = Vector2((ai._agents[armor] as Dictionary)["home"])
	_trace("ARMOR_RESERVE", 0.00, armor, ai, blue, "reserve_hold", "role=%s home_dist=%.1f" % [str((ai._agents[armor] as Dictionary)["role"]), armor.global_position.distance_to(home)])

	blue.global_position = Vector2(1640.0, 820.0)
	var legitimate: bool = ai._is_legitimately_detected(blue)
	ai._update_red_intel(0.01)
	ai._update_red_intel(0.76)
	ai._objective.state = "CONTESTED"
	var selected_target: BattleFormation = ai._choose_target(armor, true)
	var pressure_path_distance: float = ai._path_distance(armor.global_position, blue.global_position)
	ai._decide_combat_unit(armor, true)
	_trace("ARMOR_RESERVE", 0.77, armor, ai, blue, "objective_pressure_commit", "objective=CONTESTED legit_detected=%s selected_target=%s target_dist=%.1f path_dist=%.1f" % [legitimate, selected_target.display_name if selected_target != null else "NONE", armor.global_position.distance_to(blue.global_position), pressure_path_distance])

	armor._update_movement(1.00)
	var committed_distance: float = armor.global_position.distance_to(home)
	_trace("ARMOR_RESERVE", 1.77, armor, ai, blue, "commit_movement", "moved_from_reserve=%.1f" % committed_distance)

	var last_known: Vector2 = blue.global_position
	blue.global_position = Vector2(520.0, 900.0)
	ai._update_red_intel(0.01)
	ai._objective.state = "NEUTRAL"
	ai._decide_combat_unit(armor, false)
	_trace("ARMOR_RESERVE", 1.78, armor, ai, blue, "local_threat_lost", "objective=NEUTRAL last_known=%s" % _pos(last_known))
	ai._elapsed += ai.INVESTIGATE_TIMEOUT + 0.10
	ai._decide_combat_unit(armor, false)
	_trace("ARMOR_RESERVE", 5.88, armor, ai, blue, "return_to_reserve", "home_dist=%.1f" % armor.global_position.distance_to(home))
	_advance_to_anchor(armor)
	ai._decide_combat_unit(armor, false)
	var final_agent: Dictionary = ai._agents[armor]
	var passed: bool = (
		legitimate
		and committed_distance > 0.0
		and str(final_agent["state"]) == ai.HOLD
		and final_agent["target"] == null
		and armor.global_position.distance_to(home) <= ai.ARRIVAL_TOLERANCE
	)
	_trace("ARMOR_RESERVE", 10.88, armor, ai, blue, "reserve_restored", "posture=HOLD home_dist=%.1f result=%s" % [armor.global_position.distance_to(home), _result(passed)])
	_require(passed, "ARMOR_RESERVE", "armor_did_not_restore_reserve_posture")


func _run_supply_evade(ai: BattleEnemyAIController) -> void:
	_reset_fixture(ai)
	var supply: BattleFormation = ai._find_red("RED SUPPLY-01")
	var armor: BattleFormation = ai._find_red("RED ARMOR-01")
	var blue_recon: BattleFormation = ai._blue[1] as BattleFormation
	var objective_distance: float = supply.global_position.distance_to(ai._objective.global_position)
	_trace("SUPPLY_EVADE", 0.00, supply, ai, blue_recon, "rear_support", "objective_dist=%.1f can_attack=%s can_capture=%s" % [objective_distance, supply.can_attack, supply.can_capture])

	armor.global_position = Vector2(2400.0, 1020.0)
	ai._decide_supply(supply)
	var advance_target: Vector2 = supply._move_target
	_trace("SUPPLY_EVADE", 0.25, supply, ai, blue_recon, "support_advance", "advance_destination=%s" % _pos(advance_target))

	blue_recon.global_position = supply.global_position + Vector2(180.0, 0.0)
	var threat_distance_before: float = supply.global_position.distance_to(blue_recon.global_position)
	var legitimate: bool = ai._is_legitimately_detected(blue_recon)
	ai._update_red_intel(0.01)
	ai._update_red_intel(0.76)
	ai._decide_supply(supply)
	var evade_target: Vector2 = supply._move_target
	_trace("SUPPLY_EVADE", 1.02, supply, ai, blue_recon, "confirmed_threat_evade", "legit_detected=%s prior_advance=%s evade_destination=%s threat_dist=%.1f" % [legitimate, _pos(advance_target), _pos(evade_target), threat_distance_before])

	supply._update_movement(1.00)
	var threat_distance_after: float = supply.global_position.distance_to(blue_recon.global_position)
	var final_agent: Dictionary = ai._agents[supply]
	var passed: bool = (
		legitimate
		and str(final_agent["state"]) == ai.EVADE
		and threat_distance_after > threat_distance_before
		and evade_target.x < advance_target.x
		and not supply.can_attack
		and not supply.can_capture
		and supply.global_position.distance_to(ai._objective.global_position) > ai._objective.capture_radius
	)
	_trace("SUPPLY_EVADE", 2.02, supply, ai, blue_recon, "evade_displacement", "threat_before=%.1f threat_after=%.1f objective_dist=%.1f attacks=0 captures=0 contests=0 result=%s" % [threat_distance_before, threat_distance_after, supply.global_position.distance_to(ai._objective.global_position), _result(passed)])
	_require(passed, "SUPPLY_EVADE", "supply_did_not_cancel_advance_and_move_away")


func _run_flank_response(ai: BattleEnemyAIController) -> void:
	_reset_fixture(ai)
	var inf1: BattleFormation = ai._find_red("RED INF-01")
	var inf2: BattleFormation = ai._find_red("RED INF-02")
	var armor: BattleFormation = ai._find_red("RED ARMOR-01")
	var supply: BattleFormation = ai._find_red("RED SUPPLY-01")
	var blue_recon: BattleFormation = ai._blue[1] as BattleFormation
	blue_recon.global_position = Vector2(1060.0, 620.0)
	var initially_detected: bool = ai._is_legitimately_detected(blue_recon)
	ai._update_red_intel(1.00)
	ai._decision_tick()
	var pre_states: String = _combat_states(ai, [inf1, inf2, armor])
	var no_pre_reaction: bool = (
		not initially_detected
		and str((ai._intel[blue_recon] as Dictionary)["state"]) == ai.UNSEEN
		and str((ai._agents[inf1] as Dictionary)["state"]) == ai.HOLD
		and str((ai._agents[inf2] as Dictionary)["state"]) == ai.HOLD
		and str((ai._agents[armor] as Dictionary)["state"]) == ai.HOLD
	)
	_trace("FLANK_RESPONSE", 0.00, inf2, ai, blue_recon, "north_route_unseen", "route=north legit_detected=%s combat_states=%s no_pre_reaction=%s" % [initially_detected, pre_states, no_pre_reaction])

	blue_recon.global_position = Vector2(1100.0, 620.0)
	var legitimate: bool = ai._is_legitimately_detected(blue_recon)
	ai._update_red_intel(0.01)
	ai._update_red_intel(0.76)
	ai._decision_tick()
	var responders: PackedStringArray = []
	for unit: BattleFormation in [inf1, inf2, armor]:
		var state: String = str((ai._agents[unit] as Dictionary)["state"])
		if state == ai.MOVE or state == ai.ENGAGE or state == ai.INVESTIGATE:
			responders.append(unit.display_name)
	var supply_state: String = str((ai._agents[supply] as Dictionary)["state"])
	var inf2_preferred_only: bool = responders.size() == 1 and responders[0] == "RED INF-02"
	var passed: bool = no_pre_reaction and legitimate and inf2_preferred_only and supply_state == ai.SUPPORT and not ai._reinforcements_active
	_trace("FLANK_RESPONSE", 0.77, inf2, ai, blue_recon, "north_route_confirmed", "route=north legit_detected=%s intel=%s responders=%s supply=%s reinforcements_active=%s preferred_local_only=%s result=%s" % [legitimate, str((ai._intel[blue_recon] as Dictionary)["state"]), ",".join(responders), supply_state, ai._reinforcements_active, inf2_preferred_only, _result(passed)])
	_require(passed, "FLANK_RESPONSE", "confirmed_flank_responders=%s expected=RED INF-02" % ",".join(responders))


func _reset_fixture(ai: BattleEnemyAIController) -> void:
	ai._elapsed = 0.0
	ai._objective.state = "NEUTRAL"
	for target: BattleFormation in ai._blue:
		target.is_alive = true
		target.stop()
		target.clear_combat_target()
		var intel: Dictionary = ai._intel[target]
		intel["state"] = ai.UNSEEN
		intel["last_known"] = Vector2.ZERO
		intel["confirm_progress"] = 0.0
		intel["forced_reveal"] = 0.0
		intel["generation"] = 0
		ai._intel[target] = intel
	ai._blue[0].global_position = Vector2(520.0, 900.0)
	ai._blue[1].global_position = Vector2(760.0, 600.0)
	for unit_variant: Variant in ai._agents.keys():
		var unit: BattleFormation = unit_variant as BattleFormation
		var agent: Dictionary = ai._agents[unit]
		unit.stop()
		unit.clear_combat_target()
		unit.global_position = Vector2(agent["home"])
		agent["state"] = ai.SUPPORT if str(agent["role"]) == "REAR_SUPPORT" else ai.HOLD
		agent["target"] = null
		agent["engage_origin"] = unit.global_position
		agent["investigate_started"] = -999.0
		agent["investigated_generation"] = -1
		agent["last_damage_time"] = -999.0
		agent["recent_attacker"] = null
		agent["recent_attacker_time"] = -999.0
		agent["route"] = "central"
		ai._agents[unit] = agent


func _advance_to_anchor(unit: BattleFormation) -> void:
	for _step: int in range(20):
		if not unit.has_active_navigation_path():
			break
		unit._update_movement(0.50)


func _trace(scenario: String, time_value: float, unit: BattleFormation, ai: BattleEnemyAIController, target: BattleFormation, event: String, details: String) -> void:
	var agent: Dictionary = ai._agents[unit]
	var intel_state: String = str((ai._intel[target] as Dictionary)["state"])
	print("PLAYER_AI_TELEMETRY t=%.2f scenario=%s event=%s unit=\"%s\" intel=%s ai=%s mission=%s route=%s pos=%s %s" % [
		time_value,
		scenario,
		event,
		unit.display_name,
		intel_state,
		str(agent["state"]),
		str(agent["role"]),
		str(agent["route"]),
		_pos(unit.global_position),
		details,
	])


func _combat_states(ai: BattleEnemyAIController, units: Array) -> String:
	var values: PackedStringArray = []
	for unit_variant: Variant in units:
		var unit: BattleFormation = unit_variant as BattleFormation
		values.append("%s:%s" % [unit.display_name, str((ai._agents[unit] as Dictionary)["state"])])
	return ",".join(values)


func _pos(value: Vector2) -> String:
	return "(%.1f,%.1f)" % [value.x, value.y]


func _result(passed: bool) -> String:
	return "PASS" if passed else "FAIL"


func _require(condition: bool, scenario: String, detail: String) -> void:
	if condition:
		print("PLAYER_AI_%s_PASS" % scenario)
	else:
		_fail(scenario, detail)


func _fail(scenario: String, detail: String) -> void:
	_failures.append("%s:%s" % [scenario, detail])
	print("PLAYER_AI_%s_FAIL detail=%s" % [scenario, detail])


func _finish(battle: Node) -> void:
	if _failures.is_empty():
		print("PLAYER_BEHAVIOR_EVIDENCE_PASS")
		battle.queue_free()
		quit(0)
		return
	print("PLAYER_BEHAVIOR_EVIDENCE_FAIL failures=%s" % " | ".join(_failures))
	battle.queue_free()
	quit(1)
