extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle01/Battle01.tscn")

var _failures: PackedStringArray = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	print("FRONTLINE_SEEDED_RED_DEFENSE_POSTURES_SMOKE_BEGIN")

	await _exercise_explicit_seed_override()
	await _exercise_normal_player_replay_sequence()

	var same_a: Dictionary = await _spawn_battle(12)
	var same_b: Dictionary = await _spawn_battle(12)
	var same_seed_pass: bool = (
		str(same_a["posture"]) == str(same_b["posture"])
		and _snapshots_equal(same_a["snapshot"], same_b["snapshot"])
	)
	_require(same_seed_pass, "RED_POSTURE_SAME_SEED_DETERMINISTIC_PASS")
	await _dispose_battle(same_a["battle"] as Node)
	await _dispose_battle(same_b["battle"] as Node)

	var posture_a: Dictionary = await _spawn_battle(0)
	var posture_b: Dictionary = await _spawn_battle(1)
	var posture_c: Dictionary = await _spawn_battle(2)

	_require(str(posture_a["posture"]) == "BRIDGE_LOCK", "RED_POSTURE_A_BRIDGE_LOCK_PASS")
	_require(str(posture_b["posture"]) == "VILLAGE_SCREEN", "RED_POSTURE_B_VILLAGE_SCREEN_PASS")
	_require(str(posture_c["posture"]) == "SOUTH_SCREEN", "RED_POSTURE_C_SOUTH_SCREEN_PASS")

	var roster_pass: bool = _roster_is_frozen(posture_a) and _roster_is_frozen(posture_b) and _roster_is_frozen(posture_c)
	_require(roster_pass, "RED_POSTURE_ROSTER_UNCHANGED_PASS")

	var real_difference: bool = (
		_key_position_differs(posture_a, posture_b, "RED INF-02")
		and _key_position_differs(posture_a, posture_c, "RED INF-02")
		and _key_position_differs(posture_a, posture_b, "RED ARMOR-01")
		and _key_position_differs(posture_a, posture_c, "RED ARMOR-01")
		and _key_position_differs(posture_a, posture_b, "RED SUPPLY-01")
		and _key_position_differs(posture_a, posture_c, "RED SUPPLY-01")
		and _deployment_is_legal(posture_a)
		and _deployment_is_legal(posture_b)
		and _deployment_is_legal(posture_c)
	)
	_require(real_difference, "RED_POSTURE_REAL_DEPLOYMENT_DIFFERENCE_PASS")

	var dormant_pass: bool = _dormant_preserved(posture_a) and _dormant_preserved(posture_b) and _dormant_preserved(posture_c)
	_require(dormant_pass, "RED_POSTURE_DORMANT_REINFORCEMENT_PRESERVED_PASS")

	var return_b_pass: bool = _exercise_posture_return(posture_b, Vector2(1060.0, 660.0))
	_require(return_b_pass, "RED_POSTURE_B_RETURN_ANCHOR_PASS")
	var return_c_pass: bool = _exercise_posture_return(posture_c, Vector2(1340.0, 1380.0))
	_require(return_c_pass, "RED_POSTURE_C_RETURN_ANCHOR_PASS")
	_require(return_b_pass and return_c_pass, "RED_POSTURE_RETURN_ANCHOR_PASS")

	var lock_pass: bool = _exercise_posture_lock(posture_b)
	_require(lock_pass, "RED_POSTURE_LOCKED_AFTER_START_PASS")

	await _dispose_battle(posture_a["battle"] as Node)
	await _dispose_battle(posture_b["battle"] as Node)
	await _dispose_battle(posture_c["battle"] as Node)

	# Use fresh posture-specific Battle01 instances because the full finite logistics
	# chain intentionally destroys each RED Supply truck at the end.
	var logistics_b: Dictionary = await _spawn_battle(1)
	var logistics_b_pass: bool = _exercise_full_logistics_chain(logistics_b)
	_require(logistics_b_pass, "RED_POSTURE_B_FULL_LOGISTICS_CHAIN_PASS")
	await _dispose_battle(logistics_b["battle"] as Node)

	var logistics_c: Dictionary = await _spawn_battle(2)
	var logistics_c_pass: bool = _exercise_full_logistics_chain(logistics_c)
	_require(logistics_c_pass, "RED_POSTURE_C_FULL_LOGISTICS_CHAIN_PASS")
	await _dispose_battle(logistics_c["battle"] as Node)
	_require(logistics_b_pass and logistics_c_pass, "RED_POSTURE_LOGISTICS_COMPATIBILITY_PASS")

	var fog_a: Dictionary = await _spawn_battle(4, Vector2(360.0, 260.0))
	var fog_b: Dictionary = await _spawn_battle(4, Vector2(3020.0, 1640.0))
	var no_hidden_dependency: bool = (
		str(fog_a["posture"]) == str(fog_b["posture"])
		and _snapshots_equal(fog_a["snapshot"], fog_b["snapshot"])
	)
	_require(no_hidden_dependency, "RED_POSTURE_NO_HIDDEN_BLUE_DEPENDENCE_PASS")
	await _dispose_battle(fog_a["battle"] as Node)
	await _dispose_battle(fog_b["battle"] as Node)

	if _failures.is_empty():
		print("FRONTLINE_SEEDED_RED_DEFENSE_POSTURES_SMOKE_PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error("SEEDED_RED_POSTURE_SMOKE_FAILURE %s" % failure)
		quit(1)

func _exercise_explicit_seed_override() -> void:
	BattleFormalCombatRoster.reset_normal_run_sequence_for_test()
	var counter_before: int = BattleFormalCombatRoster.get_normal_run_index_for_test()

	# Editor/debug explicit override path: production resolver must honor it without
	# consuming the normal-player replay sequence.
	var battle: Node2D = BATTLE_SCENE.instantiate() as Node2D
	var roster_pre_ready: BattleFormalCombatRoster = battle.get_node("FormalCombatRoster") as BattleFormalCombatRoster
	roster_pre_ready.battle01_seed = 1
	root.add_child(battle)
	await process_frame
	await process_frame
	battle.process_mode = Node.PROCESS_MODE_DISABLED
	var roster: BattleFormalCombatRoster = battle.get_node("FormalCombatRoster") as BattleFormalCombatRoster
	var editor_override_pass: bool = (
		roster.get_battle01_seed() == 1
		and roster.get_selected_posture() == BattleFormalCombatRoster.POSTURE_B
		and BattleFormalCombatRoster.get_normal_run_index_for_test() == counter_before
	)
	await _dispose_battle(battle)

	# Environment override uses the same production resolver priority and also must
	# not consume the normal sequence. Preserve the caller's environment exactly.
	var had_env: bool = OS.has_environment("BATTLE01_SEED")
	var saved_env: String = OS.get_environment("BATTLE01_SEED") if had_env else ""
	OS.set_environment("BATTLE01_SEED", "2")
	var env_battle: Node2D = BATTLE_SCENE.instantiate() as Node2D
	root.add_child(env_battle)
	await process_frame
	await process_frame
	env_battle.process_mode = Node.PROCESS_MODE_DISABLED
	var env_roster: BattleFormalCombatRoster = env_battle.get_node("FormalCombatRoster") as BattleFormalCombatRoster
	var env_override_pass: bool = (
		env_roster.get_battle01_seed() == 2
		and env_roster.get_selected_posture() == BattleFormalCombatRoster.POSTURE_C
		and BattleFormalCombatRoster.get_normal_run_index_for_test() == counter_before
	)
	await _dispose_battle(env_battle)
	if had_env:
		OS.set_environment("BATTLE01_SEED", saved_env)
	else:
		OS.unset_environment("BATTLE01_SEED")

	_require(editor_override_pass and env_override_pass, "RED_POSTURE_EXPLICIT_SEED_OVERRIDE_PASS")

func _exercise_normal_player_replay_sequence() -> void:
	# This proof deliberately uses SceneTree current_scene + reload_current_scene,
	# not force_seed_for_test(), so it follows the actual HUD Restart route.
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--battle01-seed="):
			_require(false, "RED_POSTURE_NORMAL_REPLAY_SEQUENCE_PASS")
			_require(false, "RED_POSTURE_NORMAL_REPLAY_WRAP_PASS")
			return

	var had_env: bool = OS.has_environment("BATTLE01_SEED")
	var saved_env: String = OS.get_environment("BATTLE01_SEED") if had_env else ""
	if had_env:
		OS.unset_environment("BATTLE01_SEED")

	BattleFormalCombatRoster.reset_normal_run_sequence_for_test()
	var changed: Error = change_scene_to_packed(BATTLE_SCENE)
	if changed != OK:
		_require(false, "RED_POSTURE_NORMAL_REPLAY_SEQUENCE_PASS")
		_require(false, "RED_POSTURE_NORMAL_REPLAY_WRAP_PASS")
		_restore_seed_environment(had_env, saved_env)
		return
	await scene_changed

	var run1: Dictionary = _current_scene_seed_posture()
	_require(int(run1["seed"]) == 0 and str(run1["posture"]) == BattleFormalCombatRoster.POSTURE_A, "RED_POSTURE_NORMAL_RUN_1_BRIDGE_LOCK_PASS")

	var reload2: Error = reload_current_scene()
	if reload2 == OK:
		await scene_changed
	var run2: Dictionary = _current_scene_seed_posture()
	_require(reload2 == OK and int(run2["seed"]) == 1 and str(run2["posture"]) == BattleFormalCombatRoster.POSTURE_B, "RED_POSTURE_NORMAL_RUN_2_VILLAGE_SCREEN_PASS")

	var reload3: Error = reload_current_scene()
	if reload3 == OK:
		await scene_changed
	var run3: Dictionary = _current_scene_seed_posture()
	_require(reload3 == OK and int(run3["seed"]) == 2 and str(run3["posture"]) == BattleFormalCombatRoster.POSTURE_C, "RED_POSTURE_NORMAL_RUN_3_SOUTH_SCREEN_PASS")

	var sequence_pass: bool = (
		int(run1["seed"]) == 0
		and str(run1["posture"]) == BattleFormalCombatRoster.POSTURE_A
		and int(run2["seed"]) == 1
		and str(run2["posture"]) == BattleFormalCombatRoster.POSTURE_B
		and int(run3["seed"]) == 2
		and str(run3["posture"]) == BattleFormalCombatRoster.POSTURE_C
	)
	_require(sequence_pass, "RED_POSTURE_NORMAL_REPLAY_SEQUENCE_PASS")

	var reload4: Error = reload_current_scene()
	if reload4 == OK:
		await scene_changed
	var run4: Dictionary = _current_scene_seed_posture()
	_require(reload4 == OK and int(run4["seed"]) == 0 and str(run4["posture"]) == BattleFormalCombatRoster.POSTURE_A, "RED_POSTURE_NORMAL_REPLAY_WRAP_PASS")

	# Leave a harmless placeholder current scene so all remaining focused Battle01
	# instances are programmatic regressions and do not consume the normal counter.
	var placeholder: Node = Node.new()
	placeholder.name = "SeededPostureSmokeHarness"
	var leave_error: Error = change_scene_to_node(placeholder)
	if leave_error == OK:
		await scene_changed
	_restore_seed_environment(had_env, saved_env)

func _restore_seed_environment(had_env: bool, saved_env: String) -> void:
	if had_env:
		OS.set_environment("BATTLE01_SEED", saved_env)
	else:
		OS.unset_environment("BATTLE01_SEED")

func _current_scene_seed_posture() -> Dictionary:
	var battle: Node = current_scene
	if battle == null:
		return {"seed": -999, "posture": "NONE"}
	var roster: BattleFormalCombatRoster = battle.get_node_or_null("FormalCombatRoster") as BattleFormalCombatRoster
	if roster == null:
		return {"seed": -999, "posture": "NONE"}
	return {
		"seed": roster.get_battle01_seed(),
		"posture": roster.get_selected_posture(),
	}

func _spawn_battle(seed: int, hidden_blue_position: Vector2 = Vector2(-1.0, -1.0)) -> Dictionary:
	var battle: Node2D = BATTLE_SCENE.instantiate() as Node2D
	var roster_pre_ready: BattleFormalCombatRoster = battle.get_node("FormalCombatRoster") as BattleFormalCombatRoster
	roster_pre_ready.force_seed_for_test(seed)
	if hidden_blue_position.x >= 0.0:
		var blue_hidden: BattleFormation = battle.get_node("BlueFormation") as BattleFormation
		blue_hidden.global_position = hidden_blue_position
	root.add_child(battle)
	await process_frame
	await process_frame
	battle.process_mode = Node.PROCESS_MODE_DISABLED

	var roster: BattleFormalCombatRoster = battle.get_node("FormalCombatRoster") as BattleFormalCombatRoster
	var ai: BattleEnemyAILogisticsController = battle.get_node("EnemyAIController") as BattleEnemyAILogisticsController
	var navigation: BattleNavigation = battle.get_node("Navigation") as BattleNavigation
	return {
		"battle": battle,
		"roster": roster,
		"ai": ai,
		"navigation": navigation,
		"posture": roster.get_selected_posture(),
		"seed": roster.get_battle01_seed(),
		"snapshot": _capture_snapshot(roster, ai),
	}

func _capture_snapshot(roster: BattleFormalCombatRoster, ai: BattleEnemyAILogisticsController) -> Dictionary:
	var result: Dictionary = {}
	var units: Array[BattleFormation] = []
	units.append_array(roster.get_initial_enemy_combat_formations())
	units.append_array(roster.get_initial_supply_trucks())
	for unit: BattleFormation in units:
		var agent: Dictionary = ai._agents[unit]
		result[unit.display_name] = {
			"position": unit.global_position,
			"home": Vector2(agent["home"]),
			"assigned_anchor": Vector2(agent["assigned_anchor"]),
		}
	return result

func _snapshots_equal(left: Dictionary, right: Dictionary) -> bool:
	var names: Array[String] = ["RED INF-01", "RED INF-02", "RED ARMOR-01", "RED SUPPLY-01"]
	for unit_name: String in names:
		if not left.has(unit_name) or not right.has(unit_name):
			return false
		var left_data: Dictionary = left[unit_name]
		var right_data: Dictionary = right[unit_name]
		if not Vector2(left_data["position"]).is_equal_approx(Vector2(right_data["position"])):
			return false
		if not Vector2(left_data["home"]).is_equal_approx(Vector2(right_data["home"])):
			return false
		if not Vector2(left_data["assigned_anchor"]).is_equal_approx(Vector2(right_data["assigned_anchor"])):
			return false
	return true

func _roster_is_frozen(context: Dictionary) -> bool:
	var roster: BattleFormalCombatRoster = context["roster"] as BattleFormalCombatRoster
	var counts: Dictionary = roster.get_roster_counts()
	return (
		int(counts["enemy_infantry"]) == 2
		and int(counts["enemy_armor"]) == 1
		and int(counts["enemy_supply_truck"]) == 1
		and int(counts["reinforcement_infantry"]) == 1
		and int(counts["reinforcement_armor"]) == 1
	)

func _key_position_differs(left: Dictionary, right: Dictionary, unit_name: String) -> bool:
	var left_snapshot: Dictionary = left["snapshot"]
	var right_snapshot: Dictionary = right["snapshot"]
	var left_data: Dictionary = left_snapshot[unit_name]
	var right_data: Dictionary = right_snapshot[unit_name]
	return Vector2(left_data["position"]).distance_to(Vector2(right_data["position"])) >= 120.0

func _deployment_is_legal(context: Dictionary) -> bool:
	var battle: Node2D = context["battle"] as Node2D
	var navigation: BattleNavigation = context["navigation"] as BattleNavigation
	var roster: BattleFormalCombatRoster = context["roster"] as BattleFormalCombatRoster
	var central: BattleObjective = battle.get_node("CentralBridgehead") as BattleObjective
	var industrial: BattleObjective = battle.get_node("IndustrialObjective") as BattleObjective
	for unit_name: String in ["RED INF-01", "RED INF-02", "RED ARMOR-01", "RED SUPPLY-01"]:
		var point: Vector2 = Vector2(roster.get_posture_deployment()[unit_name])
		if not navigation.is_world_walkable(point):
			return false
		if point.distance_to(central.global_position) <= central.capture_radius:
			return false
		if point.distance_to(industrial.global_position) <= industrial.capture_radius:
			return false
		if navigation.find_path(point, central.global_position).is_empty():
			return false
	return true

func _dormant_preserved(context: Dictionary) -> bool:
	var roster: BattleFormalCombatRoster = context["roster"] as BattleFormalCombatRoster
	for unit: BattleFormation in roster.get_reinforcement_formations():
		if unit.visible or unit.process_mode != Node.PROCESS_MODE_DISABLED:
			return false
	return true

func _exercise_posture_return(context: Dictionary, expected_anchor: Vector2) -> bool:
	var roster: BattleFormalCombatRoster = context["roster"] as BattleFormalCombatRoster
	var ai: BattleEnemyAILogisticsController = context["ai"] as BattleEnemyAILogisticsController
	var navigation: BattleNavigation = context["navigation"] as BattleNavigation
	var inf2: BattleFormation = roster.enemy_infantry[1]
	var agent: Dictionary = ai._agents[inf2]
	var posture_anchor: Vector2 = Vector2(agent["assigned_anchor"])
	if not posture_anchor.is_equal_approx(expected_anchor):
		return false
	if not Vector2(agent["home"]).is_equal_approx(expected_anchor):
		return false
	var displaced: Vector2 = navigation.clamp_to_walkable(posture_anchor + Vector2(-240.0, 120.0))
	if displaced.distance_to(posture_anchor) < 100.0:
		return false
	inf2.global_position = displaced
	inf2.stop()
	ai._return_unit(inf2)
	for _step: int in range(400):
		if inf2.get_order() == "HOLD":
			break
		inf2._update_movement(0.10)
	return inf2.get_order() == "HOLD" and inf2.global_position.distance_to(posture_anchor) <= 5.0

func _exercise_posture_lock(context: Dictionary) -> bool:
	var battle: Node2D = context["battle"] as Node2D
	var roster: BattleFormalCombatRoster = context["roster"] as BattleFormalCombatRoster
	var ai: BattleEnemyAILogisticsController = context["ai"] as BattleEnemyAILogisticsController
	var central: BattleObjective = battle.get_node("CentralBridgehead") as BattleObjective
	var blue: BattleFormation = battle.get_node("BlueFormation") as BattleFormation
	var initial_posture: String = roster.get_selected_posture()
	var initial_deployment: Dictionary = roster.get_posture_deployment()
	blue.global_position = Vector2(900.0, 640.0)
	ai._force_intel_for_ci(blue, BattleEnemyAIController.CONFIRMED, blue.global_position, true)
	central.contested = true
	central.capturing_faction = "BLUE"
	central.progress = 0.3
	central._refresh_state(false)
	ai._decision_tick()
	return roster.is_posture_locked() and roster.get_selected_posture() == initial_posture and _deployment_dictionary_equal(initial_deployment, roster.get_posture_deployment())

func _deployment_dictionary_equal(left: Dictionary, right: Dictionary) -> bool:
	for unit_name: String in ["RED INF-01", "RED INF-02", "RED ARMOR-01", "RED SUPPLY-01"]:
		if not left.has(unit_name) or not right.has(unit_name):
			return false
		if not Vector2(left[unit_name]).is_equal_approx(Vector2(right[unit_name])):
			return false
	return true

func _exercise_full_logistics_chain(context: Dictionary) -> bool:
	var battle: Node2D = context["battle"] as Node2D
	var roster: BattleFormalCombatRoster = context["roster"] as BattleFormalCombatRoster
	var ai: BattleEnemyAILogisticsController = context["ai"] as BattleEnemyAILogisticsController
	var navigation: BattleNavigation = context["navigation"] as BattleNavigation
	var central: BattleObjective = battle.get_node("CentralBridgehead") as BattleObjective
	var industrial: BattleObjective = battle.get_node("IndustrialObjective") as BattleObjective
	var armor: BattleFormation = roster.enemy_armor[0]
	var supply: BattleFormation = roster.enemy_supply_trucks[0]
	var deployment: Dictionary = roster.get_posture_deployment()

	var supply_home: Vector2 = Vector2(deployment["RED SUPPLY-01"])
	var rear_slot_legal: bool = (
		supply.global_position.is_equal_approx(supply_home)
		and navigation.is_world_walkable(supply_home)
		and supply_home.distance_to(central.global_position) > central.capture_radius
		and supply_home.distance_to(industrial.global_position) > industrial.capture_radius
	)

	armor.current_ammo = armor.ammo_capacity / 2
	armor.stop()
	supply.stop()
	var armor_hp_before: int = armor.current_hp
	var ammo_before: int = armor.current_ammo
	var expected_restore: int = int(round(float(armor.ammo_capacity) * 0.5))
	var armor_start: Vector2 = armor.global_position
	var supply_start: Vector2 = supply.global_position
	var charges_before: int = supply.get_supply_charges()

	ai.force_red_resupply_decision_for_test()
	var started: bool = ai.is_red_resupply_active() and ai.get_red_resupply_target() == armor and ai.get_red_resupply_truck() == supply
	var rendezvous: Vector2 = ai.get_red_resupply_rendezvous()
	var rendezvous_legal: bool = (
		navigation.is_world_walkable(rendezvous)
		and not navigation.find_path(armor.global_position, rendezvous).is_empty()
		and not navigation.find_path(supply.global_position, rendezvous).is_empty()
		and rendezvous.distance_to(central.global_position) >= 300.0
		and rendezvous.distance_to(industrial.global_position) >= 300.0
	)

	_advance_red_to_transfer(ai, armor, supply)
	var moved: bool = armor.global_position.distance_to(armor_start) > 20.0 and supply.global_position.distance_to(supply_start) > 20.0
	var transferring: bool = (
		ai.get_red_resupply_phase() == "TRANSFERRING"
		and armor.global_position.distance_to(supply.global_position) <= BattleEnemyAILogisticsController.RED_SUPPLY_RANGE
	)

	ai.advance_red_resupply_for_test(BattleEnemyAILogisticsController.RED_SUPPLY_DURATION + 0.01)
	var transfer_complete: bool = (
		not ai.is_red_resupply_active()
		and armor.current_ammo == mini(armor.ammo_capacity, ammo_before + expected_restore)
		and armor.current_hp == armor_hp_before
		and supply.get_supply_charges() == charges_before - 1
	)

	# A destroyed finite RED Supply truck loses its remaining charge and cannot
	# create any additional sustain. No combat Formation ammo may recover by itself.
	armor.stop()
	supply.stop()
	armor.current_ammo = 0
	var ammo_before_destroyed_attempt: int = armor.current_ammo
	supply.take_damage(supply.max_hp + 1)
	var destruction_loses_sustain: bool = not supply.is_alive and supply.get_supply_charges() == 0
	ai.force_red_resupply_decision_for_test()
	ai.advance_red_resupply_for_test(5.0)
	var future_resupply_blocked: bool = not ai.is_red_resupply_active() and armor.current_ammo == ammo_before_destroyed_attempt

	return (
		rear_slot_legal
		and charges_before == 2
		and started
		and rendezvous_legal
		and moved
		and transferring
		and transfer_complete
		and destruction_loses_sustain
		and future_resupply_blocked
		and not supply.can_attack
		and not supply.can_capture
		and not supply.can_contest
	)

func _advance_red_to_transfer(ai: BattleEnemyAILogisticsController, target: BattleFormation, supply: BattleFormation) -> void:
	for _step: int in range(480):
		if ai.get_red_resupply_phase() == "TRANSFERRING":
			return
		target._update_movement(0.10)
		supply._update_movement(0.10)
		ai.advance_red_resupply_for_test(0.10)

func _dispose_battle(battle: Node) -> void:
	if battle != null and is_instance_valid(battle):
		battle.queue_free()
	await process_frame

func _require(condition: bool, marker: String) -> void:
	if condition:
		print(marker)
	else:
		_failures.append(marker)
		push_error("FAILED %s" % marker)
