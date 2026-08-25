extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle01/Battle01.tscn")

var _failures: PackedStringArray = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	print("FRONTLINE_RESUPPLY_RED_LOGISTICS_SMOKE_BEGIN")
	await _scenario_blue_west_rendezvous_and_transfer()
	await _scenario_blue_interrupts_no_charge_and_destroyed()
	await _scenario_blue_forward_rally()
	await _scenario_red_priority_transfer_evade_and_destroyed()
	await _scenario_blue_withdraw_override()
	await _scenario_blue_movement_or_range_interrupt()
	await _scenario_red_dormant_reinforcement_excluded()
	await _scenario_red_local_lull_required()
	await _scenario_red_no_hidden_blue_info()

	if _failures.is_empty():
		print("FRONTLINE_RESUPPLY_RED_LOGISTICS_SMOKE_PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error("RESUPPLY_RED_LOGISTICS_SMOKE_FAILURE %s" % failure)
		quit(1)

func _spawn_battle() -> Node2D:
	var battle: Node2D = BATTLE_SCENE.instantiate() as Node2D
	root.add_child(battle)
	await process_frame
	await process_frame
	await process_frame
	battle.process_mode = Node.PROCESS_MODE_DISABLED
	return battle

func _dispose_battle(battle: Node) -> void:
	if battle != null and is_instance_valid(battle):
		battle.queue_free()
	await process_frame

func _scenario_blue_west_rendezvous_and_transfer() -> void:
	var battle: Node2D = await _spawn_battle()
	var controller: BattleResupplyController = battle.get_node("ResupplyController") as BattleResupplyController
	var flow: BattlePlayerWarFlow = battle.get_node("PlayerWarFlow") as BattlePlayerWarFlow
	var selection: BattleSelectionController = battle.get_node("SelectionController") as BattleSelectionController
	var infantry: BattleFormation = battle.get_node("BlueInfantry") as BattleFormation
	var supply: BattleFormation = battle.get_node("BlueSupply") as BattleFormation

	infantry.global_position = Vector2(1040.0, 900.0)
	supply.global_position = Vector2(420.0, 1080.0)
	infantry.current_ammo = 0
	infantry.stop()
	supply.stop()
	selection.select_only(infantry)
	var hp_before: int = infantry.current_hp
	var charges_before: int = supply.get_supply_charges()
	var started: bool = controller.start_resupply_selected()
	var automatic_assignment: bool = controller.get_resupply_truck() == supply and controller.get_resupply_target() == infantry
	var west_selected: bool = controller.get_rendezvous_name() == "WEST_REAR_RALLY"
	var moved_to_rendezvous: bool = infantry.get_order() == "RESUPPLY" and supply.get_order() == "RESUPPLY"
	_require(started and automatic_assignment and west_selected and moved_to_rendezvous, "BLUE_RESUPPLY_INTENT_WEST_RENDEZVOUS_PASS")

	_advance_blue_to_transfer(controller, infantry, supply)
	_require(controller.get_resupply_phase() == "TRANSFERRING" and flow.is_supply_active(), "BLUE_RESUPPLY_TRANSFER_STARTED_PASS")
	flow._update_supply(4.01)
	controller.force_update_for_test(0.0)
	var expected_restore: int = int(round(float(infantry.ammo_capacity) * 0.5))
	_require(infantry.current_ammo == expected_restore and supply.get_supply_charges() == charges_before - 1, "BLUE_RESUPPLY_AMMO_50_PERCENT_CHARGE_PASS")
	_require(infantry.current_hp == hp_before, "BLUE_RESUPPLY_HP_RESTORE_DISABLED_PASS")
	_require(not controller.is_resupply_active(), "BLUE_RESUPPLY_INTENT_COMPLETE_PASS")

	await _dispose_battle(battle)

func _scenario_blue_interrupts_no_charge_and_destroyed() -> void:
	var battle: Node2D = await _spawn_battle()
	var controller: BattleResupplyController = battle.get_node("ResupplyController") as BattleResupplyController
	var flow: BattlePlayerWarFlow = battle.get_node("PlayerWarFlow") as BattlePlayerWarFlow
	var selection: BattleSelectionController = battle.get_node("SelectionController") as BattleSelectionController
	var infantry: BattleFormation = battle.get_node("BlueInfantry") as BattleFormation
	var supply: BattleFormation = battle.get_node("BlueSupply") as BattleFormation
	var red: BattleFormation = battle.get_node("RedFormation") as BattleFormation

	# Direct MOVE override: current direct order must survive cancellation.
	_prepare_blue_transfer(controller, infantry, supply)
	flow._update_supply(1.0)
	var charge_before_move: int = supply.get_supply_charges()
	selection.select_only(infantry)
	var move_issued: int = selection.issue_move(Vector2(760.0, 1080.0))
	controller.force_update_for_test(0.0)
	_require(move_issued == 1 and not controller.is_resupply_active() and not flow.is_supply_active() and flow.get_supply_progress() == 0.0 and supply.get_supply_charges() == charge_before_move and infantry.get_order() == "MOVE", "BLUE_RESUPPLY_DIRECT_MOVE_OVERRIDE_PASS")

	# Damage interrupts the vulnerable transfer and does not consume a charge.
	infantry.stop()
	infantry.global_position = BattlePlayerWarFlow.WEST_REAR_RALLY
	supply.global_position = BattlePlayerWarFlow.WEST_REAR_RALLY
	infantry.current_ammo = 0
	_prepare_blue_transfer(controller, infantry, supply)
	flow._update_supply(1.0)
	var charge_before_damage: int = supply.get_supply_charges()
	infantry.take_damage(1)
	flow._update_supply(0.01)
	controller.force_update_for_test(0.0)
	_require(not controller.is_resupply_active() and flow.get_supply_progress() == 0.0 and supply.get_supply_charges() == charge_before_damage, "BLUE_RESUPPLY_DAMAGE_INTERRUPT_PASS")

	# Target firing interrupts and resets without charge consumption.
	infantry.global_position = BattlePlayerWarFlow.WEST_REAR_RALLY
	supply.global_position = BattlePlayerWarFlow.WEST_REAR_RALLY
	infantry.current_ammo = 1
	infantry.stop()
	supply.stop()
	_prepare_blue_transfer(controller, infantry, supply)
	flow._update_supply(1.0)
	var charge_before_fire: int = supply.get_supply_charges()
	red.global_position = infantry.global_position + Vector2(100.0, 0.0)
	red.set_intel_state(BattleIntelTracker.CONFIRMED)
	infantry.set_combat_target(red)
	infantry._update_combat()
	flow._update_supply(0.01)
	controller.force_update_for_test(0.0)
	_require(not controller.is_resupply_active() and flow.get_supply_progress() == 0.0 and supply.get_supply_charges() == charge_before_fire, "BLUE_RESUPPLY_FIRE_INTERRUPT_PASS")

	# No charges rejects the intent.
	while supply.consume_supply_charge():
		pass
	infantry.current_ammo = 0
	selection.select_only(infantry)
	var no_charge_rejected: bool = not controller.start_resupply_selected()
	_require(no_charge_rejected and supply.get_supply_charges() == 0, "BLUE_RESUPPLY_NO_CHARGE_REJECT_PASS")

	# Destroyed Logistics removes future BLUE sustain without causing stand-alone defeat.
	var battle2: Node2D = await _spawn_battle()
	var controller2: BattleResupplyController = battle2.get_node("ResupplyController") as BattleResupplyController
	var flow2: BattlePlayerWarFlow = battle2.get_node("PlayerWarFlow") as BattlePlayerWarFlow
	var infantry2: BattleFormation = battle2.get_node("BlueInfantry") as BattleFormation
	var supply2: BattleFormation = battle2.get_node("BlueSupply") as BattleFormation
	infantry2.current_ammo = 0
	supply2.take_damage(supply2.max_hp + 1)
	var destroyed_rejected: bool = not controller2.start_resupply(infantry2)
	_require(not supply2.is_alive and supply2.get_supply_charges() == 0 and destroyed_rejected and not flow2.is_match_finished(), "BLUE_RESUPPLY_SUPPLY_DESTROYED_PASS")

	await _dispose_battle(battle2)
	await _dispose_battle(battle)

func _scenario_blue_forward_rally() -> void:
	var battle: Node2D = await _spawn_battle()
	var controller: BattleResupplyController = battle.get_node("ResupplyController") as BattleResupplyController
	var flow: BattlePlayerWarFlow = battle.get_node("PlayerWarFlow") as BattlePlayerWarFlow
	var central: BattleObjective = battle.get_node("CentralBridgehead") as BattleObjective
	var infantry: BattleFormation = battle.get_node("BlueInfantry") as BattleFormation
	var supply: BattleFormation = battle.get_node("BlueSupply") as BattleFormation

	central.force_owner_for_test(BattleObjective.OWNER_PLAYER)
	flow._on_central_capture_completed(BattleObjective.OWNER_PLAYER, BattleObjective.OWNER_AI)
	flow._update_forward_rally()
	infantry.global_position = Vector2(1320.0, 1080.0)
	supply.global_position = Vector2(1280.0, 1080.0)
	infantry.current_ammo = 0
	infantry.stop()
	supply.stop()
	var started: bool = controller.start_resupply(infantry)
	_require(flow.is_forward_rally_active() and started and controller.get_rendezvous_name() == "BRIDGEHEAD_FORWARD_RALLY", "BLUE_RESUPPLY_FORWARD_RALLY_PASS")

	await _dispose_battle(battle)

func _scenario_red_priority_transfer_evade_and_destroyed() -> void:
	var battle: Node2D = await _spawn_battle()
	var ai: BattleEnemyAILogisticsController = battle.get_node("EnemyAIController") as BattleEnemyAILogisticsController
	var roster: BattleFormalCombatRoster = battle.get_node("FormalCombatRoster") as BattleFormalCombatRoster
	var armor: BattleFormation = roster.enemy_armor[0]
	var inf1: BattleFormation = roster.enemy_infantry[0]
	var inf2: BattleFormation = roster.enemy_infantry[1]
	var supply: BattleFormation = roster.enemy_supply_trucks[0]
	var blue: BattleFormation = battle.get_node("BlueFormation") as BattleFormation

	# Armor at <=50% has priority even when Infantry is more depleted.
	armor.current_ammo = 8
	inf1.current_ammo = 0
	inf2.current_ammo = 2
	var armor_hp_before: int = armor.current_hp
	var armor_start: Vector2 = armor.global_position
	var supply_start: Vector2 = supply.global_position
	var charges_before: int = supply.get_supply_charges()
	ai.force_red_resupply_decision_for_test()
	_require(ai.get_red_resupply_target() == armor, "RED_RESUPPLY_ARMOR_PRIORITY_PASS")
	var rendezvous: Vector2 = ai.get_red_resupply_rendezvous()
	_require(rendezvous.distance_to(battle.get_node("CentralBridgehead").global_position) >= 300.0, "RED_RESUPPLY_REAR_RENDEZVOUS_PASS")

	_advance_red_to_transfer(ai, armor, supply)
	var actual_movement: bool = armor.global_position.distance_to(armor_start) > 20.0 and supply.global_position.distance_to(supply_start) > 20.0
	_require(ai.get_red_resupply_phase() == "TRANSFERRING" and actual_movement, "RED_RESUPPLY_ACTUAL_RENDEZVOUS_MOVEMENT_PASS")
	ai.advance_red_resupply_for_test(4.01)
	_require(armor.current_ammo == 16 and supply.get_supply_charges() == charges_before - 1 and armor.current_hp == armor_hp_before, "RED_RESUPPLY_ACTUAL_TRANSFER_PASS")

	# With no depleted Armor, select most depleted Infantry, then stable identity on ties.
	armor.current_ammo = armor.ammo_capacity
	inf1.current_ammo = 8
	inf2.current_ammo = 4
	ai.force_red_resupply_decision_for_test()
	_require(ai.get_red_resupply_target() == inf2, "RED_RESUPPLY_INFANTRY_MOST_DEPLETED_PASS")
	ai.cancel_red_resupply_for_test()
	inf1.current_ammo = 4
	inf2.current_ammo = 4
	ai.force_red_resupply_decision_for_test()
	_require(ai.get_red_resupply_target() == inf1, "RED_RESUPPLY_STABLE_TIE_BREAK_PASS")
	ai.cancel_red_resupply_for_test()

	# Legitimately confirmed BLUE threat cancels unfinished transfer and existing EVADE takes priority.
	armor.current_ammo = 8
	inf1.current_ammo = inf1.ammo_capacity
	inf2.current_ammo = inf2.ammo_capacity
	ai.force_red_resupply_decision_for_test()
	_advance_red_to_transfer(ai, armor, supply)
	var charge_before_evade: int = supply.get_supply_charges()
	blue.global_position = supply.global_position + Vector2(120.0, 0.0)
	blue.stop()
	ai._update_red_intel(0.01)
	ai._update_red_intel(0.80)
	ai._decision_tick()
	_require(not ai.is_red_resupply_active() and supply.get_supply_charges() == charge_before_evade and ai.get_red_supply_state_for_test() == BattleEnemyAIController.EVADE, "RED_RESUPPLY_EVADE_OVERRIDE_PASS")

	# Destroyed RED Supply has zero finite charges and cannot recover another Formation.
	supply.take_damage(supply.max_hp + 1)
	armor.current_ammo = 0
	var ammo_before_destroyed_attempt: int = armor.current_ammo
	ai.force_red_resupply_decision_for_test()
	ai.advance_red_resupply_for_test(5.0)
	_require(not supply.is_alive and supply.get_supply_charges() == 0 and not ai.is_red_resupply_active() and armor.current_ammo == ammo_before_destroyed_attempt, "RED_RESUPPLY_SUPPLY_DESTROYED_FINITE_PASS")

	await _dispose_battle(battle)

func _prepare_blue_transfer(controller: BattleResupplyController, target: BattleFormation, supply: BattleFormation) -> void:
	target.global_position = BattlePlayerWarFlow.WEST_REAR_RALLY
	supply.global_position = BattlePlayerWarFlow.WEST_REAR_RALLY
	target.stop()
	supply.stop()
	if target.current_ammo >= target.ammo_capacity:
		target.current_ammo = 0
	controller.start_resupply(target)
	controller.force_update_for_test(0.0)
	# The actual rendezvous is the clamped walkable grid point, not the raw rally constant.
	# Advance real movement until the transfer actually starts, like gameplay does.
	_advance_blue_to_transfer(controller, target, supply)

func _advance_blue_to_transfer(controller: BattleResupplyController, target: BattleFormation, supply: BattleFormation) -> void:
	for _step: int in range(360):
		if controller.get_resupply_phase() == "TRANSFERRING":
			return
		target._update_movement(0.10)
		supply._update_movement(0.10)
		controller.force_update_for_test(0.10)

func _advance_red_to_transfer(ai: BattleEnemyAILogisticsController, target: BattleFormation, supply: BattleFormation) -> void:
	for _step: int in range(480):
		if ai.get_red_resupply_phase() == "TRANSFERRING":
			return
		target._update_movement(0.10)
		supply._update_movement(0.10)
		ai.advance_red_resupply_for_test(0.10)

func _scenario_blue_withdraw_override() -> void:
	var battle: Node2D = await _spawn_battle()
	var controller: BattleResupplyController = battle.get_node("ResupplyController") as BattleResupplyController
	var flow: BattlePlayerWarFlow = battle.get_node("PlayerWarFlow") as BattlePlayerWarFlow
	var selection: BattleSelectionController = battle.get_node("SelectionController") as BattleSelectionController
	var infantry: BattleFormation = battle.get_node("BlueInfantry") as BattleFormation
	var supply: BattleFormation = battle.get_node("BlueSupply") as BattleFormation

	# BLUE target + Logistics inside a real TRANSFERRING resupply; player issues WITHDRAW.
	_prepare_blue_transfer(controller, infantry, supply)
	flow._update_supply(1.0)
	selection.select_only(infantry)
	var charge_before: int = supply.get_supply_charges()
	var withdrawn: int = flow.withdraw_selected(false)
	flow._update_supply(0.01)
	controller.force_update_for_test(0.0)
	var cancelled: bool = not controller.is_resupply_active() and flow.get_supply_progress() == 0.0 and supply.get_supply_charges() == charge_before and infantry.get_order() == "WITHDRAW"
	# The WITHDRAW order must survive: resupply automation must not grab the formation back.
	controller.force_update_for_test(0.25)
	controller.force_update_for_test(0.25)
	controller.force_update_for_test(0.25)
	var order_kept: bool = not controller.is_resupply_active() and infantry.get_order() == "WITHDRAW"
	_require(withdrawn == 1 and cancelled and order_kept, "BLUE_RESUPPLY_DIRECT_WITHDRAW_OVERRIDE_PASS")

	await _dispose_battle(battle)

func _scenario_blue_movement_or_range_interrupt() -> void:
	var battle: Node2D = await _spawn_battle()
	var controller: BattleResupplyController = battle.get_node("ResupplyController") as BattleResupplyController
	var flow: BattlePlayerWarFlow = battle.get_node("PlayerWarFlow") as BattlePlayerWarFlow
	var infantry: BattleFormation = battle.get_node("BlueInfantry") as BattleFormation
	var supply: BattleFormation = battle.get_node("BlueSupply") as BattleFormation

	# Interrupt A: target moves during a live transfer -> cancel/reset, no charge spent.
	_prepare_blue_transfer(controller, infantry, supply)
	flow._update_supply(1.0)
	var charge_before_move: int = supply.get_supply_charges()
	infantry.issue_move(Vector2(720.0, 1200.0))
	flow._update_supply(0.01)
	controller.force_update_for_test(0.0)
	var move_interrupt: bool = not controller.is_resupply_active() and flow.get_supply_progress() == 0.0 and supply.get_supply_charges() == charge_before_move

	# Interrupt B: supplier is displaced beyond legal transfer range -> cancel/reset, no charge spent.
	_prepare_blue_transfer(controller, infantry, supply)
	flow._update_supply(1.0)
	var charge_before_range: int = supply.get_supply_charges()
	supply.global_position = infantry.global_position + Vector2(300.0, 0.0)
	flow._update_supply(0.01)
	controller.force_update_for_test(0.0)
	var range_interrupt: bool = not controller.is_resupply_active() and flow.get_supply_progress() == 0.0 and supply.get_supply_charges() == charge_before_range
	_require(move_interrupt and range_interrupt, "BLUE_RESUPPLY_MOVEMENT_OR_RANGE_INTERRUPT_PASS")

	await _dispose_battle(battle)

func _scenario_red_dormant_reinforcement_excluded() -> void:
	var battle: Node2D = await _spawn_battle()
	var ai: BattleEnemyAILogisticsController = battle.get_node("EnemyAIController") as BattleEnemyAILogisticsController
	var roster: BattleFormalCombatRoster = battle.get_node("FormalCombatRoster") as BattleFormalCombatRoster
	var armor: BattleFormation = roster.enemy_armor[0]
	var inf1: BattleFormation = roster.enemy_infantry[0]
	var inf2: BattleFormation = roster.enemy_infantry[1]
	var reinf_inf: BattleFormation = roster.reinforcement_infantry[0]
	var reinf_armor: BattleFormation = roster.reinforcement_armor[0]

	# Dormant reinforcements are NOT candidates even at the lowest ammo.
	armor.current_ammo = armor.ammo_capacity
	inf1.current_ammo = inf1.ammo_capacity
	inf2.current_ammo = inf2.ammo_capacity
	reinf_inf.current_ammo = 0
	reinf_armor.current_ammo = reinf_armor.ammo_capacity
	ai.force_red_resupply_decision_for_test()
	var excluded: bool = ai.get_red_resupply_target() == null and ai.get_red_resupply_phase() == "IDLE"

	# After formal activation they enter the ordinary candidate rules.
	ai._activate_reinforcements("qa_dormant_exclusion_test")
	ai.force_red_resupply_decision_for_test()
	var now_candidate: bool = ai.get_red_resupply_target() == reinf_inf
	_require(excluded and now_candidate, "RED_RESUPPLY_DORMANT_REINFORCEMENT_EXCLUDED_PASS")

	await _dispose_battle(battle)

func _scenario_red_local_lull_required() -> void:
	var battle: Node2D = await _spawn_battle()
	var ai: BattleEnemyAILogisticsController = battle.get_node("EnemyAIController") as BattleEnemyAILogisticsController
	var roster: BattleFormalCombatRoster = battle.get_node("FormalCombatRoster") as BattleFormalCombatRoster
	var armor: BattleFormation = roster.enemy_armor[0]
	var inf1: BattleFormation = roster.enemy_infantry[0]
	var inf2: BattleFormation = roster.enemy_infantry[1]
	var truck: BattleFormation = roster.enemy_supply_trucks[0]
	var objective: BattleObjective = battle.get_node("CentralBridgehead") as BattleObjective
	var blue: BattleFormation = battle.get_node("BlueFormation") as BattleFormation

	# Isolate the Supply truck so a local threat cannot drive EVADE instead of the lull gate.
	truck.global_position = Vector2(500.0, 300.0)

	# Reject A: recent damage on the candidate is NOT a local lull.
	armor.current_ammo = 8
	inf1.current_ammo = inf1.ammo_capacity
	inf2.current_ammo = inf2.ammo_capacity
	armor.take_damage(1)
	ai.force_red_resupply_decision_for_test()
	var damage_reject: bool = ai.get_red_resupply_target() == null and ai.get_red_resupply_phase() == "IDLE"

	# Reject B: target actively ENGAGEing a legitimately CONFIRMED BLUE is NOT a local lull.
	armor.current_ammo = armor.ammo_capacity
	inf1.current_ammo = 0
	blue.global_position = inf1.global_position + Vector2(0.0, 150.0)
	ai._update_red_intel(0.01)
	ai._update_red_intel(0.80)
	ai._decision_tick()
	var engaged: bool = ai._find_red("RED INF-01") != null
	ai.force_red_resupply_decision_for_test()
	var engage_reject: bool = ai.get_red_resupply_target() == null and ai.get_red_resupply_phase() == "IDLE"

	# Reject C: objective emergency is NOT a local lull.
	objective.state = "CONTESTED"
	ai.force_red_resupply_decision_for_test()
	var emergency_reject: bool = ai.get_red_resupply_target() == null and ai.get_red_resupply_phase() == "IDLE"
	_require(engaged and damage_reject and engage_reject and emergency_reject, "RED_RESUPPLY_LOCAL_LULL_REQUIRED_PASS")

	await _dispose_battle(battle)

func _scenario_red_no_hidden_blue_info() -> void:
	var battle: Node2D = await _spawn_battle()
	var ai: BattleEnemyAILogisticsController = battle.get_node("EnemyAIController") as BattleEnemyAILogisticsController
	var roster: BattleFormalCombatRoster = battle.get_node("FormalCombatRoster") as BattleFormalCombatRoster
	var armor: BattleFormation = roster.enemy_armor[0]
	var inf1: BattleFormation = roster.enemy_infantry[0]
	var inf2: BattleFormation = roster.enemy_infantry[1]
	var truck: BattleFormation = roster.enemy_supply_trucks[0]
	var blue: BattleFormation = battle.get_node("BlueFormation") as BattleFormation

	armor.current_ammo = 8
	inf1.current_ammo = inf1.ammo_capacity
	inf2.current_ammo = inf2.ammo_capacity

	# Hidden BLUE far away (UNSEEN by RED): baseline decision.
	blue.global_position = Vector2(400.0, 400.0)
	ai.force_red_resupply_decision_for_test()
	var baseline_target: BattleFormation = ai.get_red_resupply_target()
	var baseline_rendezvous: Vector2 = ai.get_red_resupply_rendezvous()
	var baseline_started: bool = ai.is_red_resupply_active()
	ai.cancel_red_resupply_for_test()

	# Move the hidden BLUE right next to the Supply truck while still UNSEEN:
	# candidate, rendezvous and startup decision must not change.
	blue.global_position = truck.global_position + Vector2(50.0, 0.0)
	ai.force_red_resupply_decision_for_test()
	var unchanged: bool = (
		ai.get_red_resupply_target() == baseline_target
		and ai.get_red_resupply_rendezvous().is_equal_approx(baseline_rendezvous)
		and ai.is_red_resupply_active() == baseline_started
	)

	# Only the legal Intel pipeline (detect -> CONTACT -> CONFIRMED) may flip RED behavior.
	ai._update_red_intel(0.01)
	ai._update_red_intel(0.80)
	ai._decision_tick()
	var revealed: bool = not ai.is_red_resupply_active() and ai.get_red_supply_state_for_test() == BattleEnemyAIController.EVADE
	_require(unchanged and revealed, "RED_RESUPPLY_NO_HIDDEN_BLUE_INFO_PASS")

	await _dispose_battle(battle)

func _require(condition: bool, marker: String) -> void:
	if condition:
		print(marker)
	else:
		_failures.append(marker)
		push_error("FAILED %s" % marker)
