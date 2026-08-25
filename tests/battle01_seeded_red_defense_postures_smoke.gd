extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle01/Battle01.tscn")

var _failures: PackedStringArray = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	print("FRONTLINE_SEEDED_RED_DEFENSE_POSTURES_SMOKE_BEGIN")

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

	var return_pass: bool = _exercise_posture_return(posture_c)
	_require(return_pass, "RED_POSTURE_RETURN_ANCHOR_PASS")

	var lock_pass: bool = _exercise_posture_lock(posture_b)
	_require(lock_pass, "RED_POSTURE_LOCKED_AFTER_START_PASS")

	var logistics_pass: bool = _exercise_logistics_compatibility(posture_b) and _exercise_logistics_compatibility(posture_c)
	_require(logistics_pass, "RED_POSTURE_LOGISTICS_COMPATIBILITY_PASS")

	await _dispose_battle(posture_a["battle"] as Node)
	await _dispose_battle(posture_b["battle"] as Node)
	await _dispose_battle(posture_c["battle"] as Node)

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

func _exercise_posture_return(context: Dictionary) -> bool:
	var roster: BattleFormalCombatRoster = context["roster"] as BattleFormalCombatRoster
	var ai: BattleEnemyAILogisticsController = context["ai"] as BattleEnemyAILogisticsController
	var navigation: BattleNavigation = context["navigation"] as BattleNavigation
	var inf2: BattleFormation = roster.enemy_infantry[1]
	var agent: Dictionary = ai._agents[inf2]
	var posture_anchor: Vector2 = Vector2(agent["assigned_anchor"])
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
	return inf2.global_position.distance_to(posture_anchor) <= 5.0 and Vector2((ai._agents[inf2] as Dictionary)["home"]).is_equal_approx(posture_anchor)

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

func _exercise_logistics_compatibility(context: Dictionary) -> bool:
	var battle: Node2D = context["battle"] as Node2D
	var roster: BattleFormalCombatRoster = context["roster"] as BattleFormalCombatRoster
	var ai: BattleEnemyAILogisticsController = context["ai"] as BattleEnemyAILogisticsController
	var armor: BattleFormation = roster.enemy_armor[0]
	var supply: BattleFormation = roster.enemy_supply_trucks[0]
	var initial_support: bool = str((ai._agents[supply] as Dictionary)["state"]) == BattleEnemyAIController.SUPPORT

	armor.current_ammo = 0
	armor.stop()
	supply.stop()
	ai.force_red_resupply_decision_for_test()
	var resupply_works: bool = ai.is_red_resupply_active() and ai.get_red_resupply_target() == armor and (ai.get_red_resupply_phase() == "MOVING" or ai.get_red_resupply_phase() == "TRANSFERRING")
	ai.cancel_red_resupply_for_test()

	var blue: BattleFormation = battle.get_node("BlueFormation") as BattleFormation
	blue.global_position = supply.global_position + Vector2(-120.0, 0.0)
	ai._force_intel_for_ci(blue, BattleEnemyAIController.CONFIRMED, blue.global_position, true)
	ai._decide_supply(supply)
	var evade_works: bool = str((ai._agents[supply] as Dictionary)["state"]) == BattleEnemyAIController.EVADE
	return initial_support and resupply_works and evade_works and supply.get_supply_charges() == 2 and not supply.can_attack and not supply.can_capture and not supply.can_contest

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
