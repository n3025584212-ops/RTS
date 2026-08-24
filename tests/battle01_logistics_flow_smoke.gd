extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle01/Battle01.tscn")

var _failures: PackedStringArray = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	print("FRONTLINE_LOGISTICS_FLOW_SMOKE_BEGIN")
	await _scenario_supply_success_and_interrupt()
	await _scenario_supply_death()
	await _scenario_withdraw_supply_reenter()
	await _scenario_objective_reserve_victory()
	await _scenario_ifv_death_and_force_collapse()
	await _scenario_unused_reserve_prevents_defeat()

	if _failures.is_empty():
		print("FRONTLINE_LOGISTICS_FLOW_SMOKE_PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error("LOGISTICS_FLOW_SMOKE_FAILURE %s" % failure)
		quit(1)

func _spawn_battle() -> Node2D:
	var battle: Node2D = BATTLE_SCENE.instantiate() as Node2D
	root.add_child(battle)
	await process_frame
	await process_frame
	battle.process_mode = Node.PROCESS_MODE_DISABLED
	var ai: BattleEnemyAIController = battle.get_node("EnemyAIController") as BattleEnemyAIController
	ai.process_mode = Node.PROCESS_MODE_DISABLED
	return battle

func _dispose_battle(battle: Node) -> void:
	if battle != null and is_instance_valid(battle):
		battle.queue_free()
	await process_frame

func _scenario_supply_success_and_interrupt() -> void:
	var battle: Node2D = await _spawn_battle()
	var flow: BattlePlayerWarFlow = battle.get_node("PlayerWarFlow") as BattlePlayerWarFlow
	var supply: BattleFormation = battle.get_node("BlueSupply") as BattleFormation
	var infantry: BattleFormation = battle.get_node("BlueInfantry") as BattleFormation
	_require(flow.get_friendlies().size() == 4, "PLAYER_ACTIVE_FORCE_PASS")
	_require(not supply.can_attack and not supply.can_capture and supply.supply_capacity == 2 and supply.get_supply_charges() == 2, "BLUE_SUPPLY_ROLE_PASS")

	supply.global_position = Vector2(520.0, 1080.0)
	infantry.global_position = Vector2(620.0, 1080.0)
	supply.stop()
	infantry.stop()
	var initial_charges: int = supply.get_supply_charges()
	var invalid_full_target: bool = not flow.start_supply(supply, infantry)
	_require(invalid_full_target and supply.get_supply_charges() == initial_charges, "SUPPLY_INVALID_TARGET_PASS")

	infantry.current_ammo = 0
	var hp_before: int = infantry.current_hp
	var started: bool = flow.start_supply(supply, infantry)
	flow._update_supply(4.01)
	var half_restore: int = int(round(float(infantry.ammo_capacity) * 0.5))
	_require(started and infantry.current_ammo == half_restore and supply.get_supply_charges() == 1 and infantry.current_hp == hp_before, "SUPPLY_SUCCESS_PASS")
	_require(infantry.current_hp == hp_before, "SUPPLY_HP_RESTORE_DISABLED_PASS")
	_require(infantry.current_ammo == half_restore, "SUPPLY_AMMO_RESTORE_PASS")

	infantry.current_ammo = 0
	supply.stop()
	infantry.stop()
	var interrupt_started: bool = flow.start_supply(supply, infantry)
	flow._update_supply(1.5)
	var charges_before_interrupt: int = supply.get_supply_charges()
	infantry.issue_move(Vector2(760.0, 1080.0))
	flow._update_supply(0.01)
	_require(interrupt_started and not flow.is_supply_active() and flow.get_supply_progress() == 0.0 and supply.get_supply_charges() == charges_before_interrupt, "SUPPLY_MOVEMENT_INTERRUPT_PASS")

	infantry.stop()
	infantry.global_position = Vector2(620.0, 1080.0)
	supply.global_position = Vector2(520.0, 1080.0)
	infantry.current_ammo = 0
	var second_started: bool = flow.start_supply(supply, infantry)
	flow._update_supply(4.01)
	_require(second_started and supply.get_supply_charges() == 0 and infantry.current_ammo == half_restore, "SUPPLY_CHARGES_PASS")

	await _dispose_battle(battle)

func _scenario_supply_death() -> void:
	var battle: Node2D = await _spawn_battle()
	var flow: BattlePlayerWarFlow = battle.get_node("PlayerWarFlow") as BattlePlayerWarFlow
	var supply: BattleFormation = battle.get_node("BlueSupply") as BattleFormation
	var infantry: BattleFormation = battle.get_node("BlueInfantry") as BattleFormation

	supply.global_position = Vector2(520.0, 1080.0)
	infantry.global_position = Vector2(620.0, 1080.0)
	infantry.current_ammo = 0
	supply.stop()
	infantry.stop()
	flow.start_supply(supply, infantry)
	flow._update_supply(1.0)
	supply.take_damage(supply.max_hp + 1)
	flow._update_supply(0.01)
	_require(not supply.is_alive and supply.get_supply_charges() == 0 and not flow.is_supply_active() and not flow.is_match_finished(), "SUPPLY_DEATH_CHARGES_LOST_PASS")

	await _dispose_battle(battle)

func _scenario_withdraw_supply_reenter() -> void:
	var battle: Node2D = await _spawn_battle()
	var flow: BattlePlayerWarFlow = battle.get_node("PlayerWarFlow") as BattlePlayerWarFlow
	var selection: BattleSelectionController = battle.get_node("SelectionController") as BattleSelectionController
	var navigation: BattleNavigation = battle.get_node("Navigation") as BattleNavigation
	var infantry: BattleFormation = battle.get_node("BlueInfantry") as BattleFormation
	var supply: BattleFormation = battle.get_node("BlueSupply") as BattleFormation

	infantry.global_position = Vector2(1000.0, 900.0)
	infantry.current_ammo = 0
	selection.select_only(infantry)
	var withdraw_issued: int = flow.withdraw_selected(false)
	_advance_formation(infantry)
	var expected_rally: Vector2 = navigation.clamp_to_walkable(BattlePlayerWarFlow.WEST_REAR_RALLY)
	var rear_distance: float = infantry.global_position.distance_to(expected_rally)

	supply.global_position = expected_rally + Vector2(-100.0, 0.0)
	supply.stop()
	infantry.stop()
	var supplied: bool = flow.start_supply(supply, infantry)
	flow._update_supply(4.01)
	var ammo_after: int = infantry.current_ammo
	var reenter: bool = infantry.issue_move(Vector2(1200.0, 900.0))
	_require(withdraw_issued == 1 and rear_distance <= 4.0 and supplied and ammo_after > 0 and reenter and infantry.get_order() == "MOVE", "WITHDRAW_SUPPLY_REENTER_PASS")

	await _dispose_battle(battle)

func _scenario_objective_reserve_victory() -> void:
	var battle: Node2D = await _spawn_battle()
	var flow: BattlePlayerWarFlow = battle.get_node("PlayerWarFlow") as BattlePlayerWarFlow
	var central: BattleObjective = battle.get_node("CentralBridgehead") as BattleObjective
	var industrial: BattleObjective = battle.get_node("IndustrialObjective") as BattleObjective
	var infantry: BattleFormation = battle.get_node("BlueInfantry") as BattleFormation
	var red: BattleFormation = battle.get_node("RedFormation") as BattleFormation
	var navigation: BattleNavigation = battle.get_node("Navigation") as BattleNavigation
	var ai: BattleEnemyAIController = battle.get_node("EnemyAIController") as BattleEnemyAIController

	infantry.current_ammo = 0
	infantry.global_position = central.global_position
	infantry.stop()
	central._process(14.90)
	var owner_before_full: String = central.get_control_owner()
	central._process(0.20)
	var reserve_status: Dictionary = flow.get_reserve_status()
	_require(owner_before_full == BattleObjective.OWNER_AI and central.get_control_owner() == BattleObjective.OWNER_PLAYER, "BRIDGEHEAD_15S_CAPTURE_PASS")
	_require(infantry.current_ammo == 0 and central.get_control_owner() == BattleObjective.OWNER_PLAYER, "ZERO_AMMO_CAPTURE_PASS")
	_require(bool(reserve_status["unlocked"]) and not industrial.is_player_capture_locked() and flow.is_forward_rally_active(), "BRIDGEHEAD_STAGE_CHANGE_PASS")
	_require(bool(reserve_status["unlocked"]), "RESERVE_UNLOCK_PASS")
	_require(not industrial.is_player_capture_locked(), "INDUSTRIAL_UNLOCK_PASS")
	_require(bool(ai._reinforcements_active), "BRIDGEHEAD_RED_REINFORCEMENT_TRIGGER_PASS")
	_require(not flow.is_match_finished(), "CENTRAL_ALONE_NO_VICTORY_PASS")

	var reserve: BattleFormation = flow.deploy_reserve("ARMOR")
	var second_choice: BattleFormation = flow.deploy_reserve("INFANTRY")
	var expected_entry: Vector2 = navigation.clamp_to_walkable(BattlePlayerWarFlow.WEST_REAR_ENTRY)
	_require(reserve != null and reserve.display_name == "BLUE RESERVE ARMOR-01" and reserve.global_position.distance_to(expected_entry) <= 1.0 and second_choice == null, "RESERVE_COMMIT_WEST_ENTRY_PASS")

	infantry.global_position = industrial.global_position
	red.global_position = industrial.global_position
	infantry.stop()
	red.stop()
	industrial._process(1.0)
	var contested_pass: bool = industrial.is_contested() and industrial.progress == 0.0
	red.global_position = Vector2(1370.0, 900.0)
	industrial._process(14.90)
	var industrial_owner_before_full: String = industrial.get_control_owner()
	industrial._process(0.20)
	_require(contested_pass and industrial_owner_before_full == BattleObjective.OWNER_AI and industrial.get_control_owner() == BattleObjective.OWNER_PLAYER, "INDUSTRIAL_15S_CONTEST_PASS")
	_require(flow.is_match_finished() and flow.is_victory(), "DUAL_OBJECTIVE_VICTORY_PASS")

	await _dispose_battle(battle)

func _scenario_ifv_death_and_force_collapse() -> void:
	var battle: Node2D = await _spawn_battle()
	var flow: BattlePlayerWarFlow = battle.get_node("PlayerWarFlow") as BattlePlayerWarFlow
	var ifv: BattleFormation = battle.get_node("BlueFormation") as BattleFormation
	var recon: BattleFormation = battle.get_node("BlueRecon") as BattleFormation
	var infantry: BattleFormation = battle.get_node("BlueInfantry") as BattleFormation
	var supply: BattleFormation = battle.get_node("BlueSupply") as BattleFormation

	ifv.take_damage(ifv.max_hp + 1)
	flow.force_evaluate_match_state()
	_require(not ifv.is_alive and not flow.is_match_finished(), "IFV_DEATH_NO_AUTO_DEFEAT_PASS")

	recon.take_damage(recon.max_hp + 1)
	infantry.take_damage(infantry.max_hp + 1)
	flow.force_evaluate_match_state()
	_require(supply.is_alive and flow.is_match_finished() and not flow.is_victory(), "FORCE_COLLAPSE_DEFEAT_PASS")

	await _dispose_battle(battle)

func _scenario_unused_reserve_prevents_defeat() -> void:
	var battle: Node2D = await _spawn_battle()
	var flow: BattlePlayerWarFlow = battle.get_node("PlayerWarFlow") as BattlePlayerWarFlow
	var ifv: BattleFormation = battle.get_node("BlueFormation") as BattleFormation
	var recon: BattleFormation = battle.get_node("BlueRecon") as BattleFormation
	var infantry: BattleFormation = battle.get_node("BlueInfantry") as BattleFormation

	flow._on_central_capture_completed(BattleObjective.OWNER_PLAYER, BattleObjective.OWNER_AI)
	ifv.take_damage(ifv.max_hp + 1)
	recon.take_damage(recon.max_hp + 1)
	infantry.take_damage(infantry.max_hp + 1)
	flow.force_evaluate_match_state()
	_require(not flow.is_match_finished() and bool(flow.get_reserve_status()["deployable"]), "UNUSED_RESERVE_PREVENTS_DEFEAT_PASS")

	var reserve: BattleFormation = flow.deploy_reserve("INFANTRY")
	if reserve != null:
		reserve.take_damage(reserve.max_hp + 1)
	flow.force_evaluate_match_state()
	_require(flow.is_match_finished() and not flow.is_victory(), "RESERVE_EXHAUSTED_COLLAPSE_DEFEAT_PASS")

	await _dispose_battle(battle)

func _advance_formation(formation: BattleFormation) -> void:
	for _step: int in range(240):
		if formation.get_order() == "HOLD":
			return
		formation._update_movement(0.10)

func _require(condition: bool, marker: String) -> void:
	if condition:
		print(marker)
	else:
		_failures.append(marker)
		push_error("FAILED %s" % marker)
