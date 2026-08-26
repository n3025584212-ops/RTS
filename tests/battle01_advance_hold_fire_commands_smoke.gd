extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle01/Battle01.tscn")

var _failures: PackedStringArray = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	print("FRONTLINE_ADVANCE_HOLD_FIRE_COMMANDS_SMOKE_BEGIN")
	await _scenario_real_advance_and_move_difference()
	await _scenario_confirmed_only()
	await _scenario_los_range_target_loss()
	await _scenario_deterministic_target()
	await _scenario_hold_fire()
	await _scenario_direct_overrides()
	await _scenario_formation_aware_and_logistics()
	await _scenario_reserve_compatibility()

	if _failures.is_empty():
		print("FRONTLINE_ADVANCE_HOLD_FIRE_COMMANDS_SMOKE_PASS")
		quit(0)
	else:
		for failure: String in _failures:
			push_error("ADVANCE_HOLD_FIRE_SMOKE_FAILURE %s" % failure)
		quit(1)

func _scenario_real_advance_and_move_difference() -> void:
	var context: Dictionary = await _spawn_battle()
	var infantry: BattleFormation = context["infantry"] as BattleFormation
	var target: BattleFormation = context["red_inf2"] as BattleFormation
	var selection: BattleSelectionController = context["selection"] as BattleSelectionController
	var input3d: Battle3DInput = context["input3d"] as Battle3DInput
	var intel: BattleIntelTracker = context["intel"] as BattleIntelTracker

	infantry.global_position = Vector2(600.0, 700.0)
	target.global_position = Vector2(760.0, 700.0)
	infantry.stop()
	target.stop()
	_force_intel(intel, target, BattleIntelTracker.CONFIRMED)

	var move_ammo_before: int = infantry.current_ammo
	var move_hp_before: int = target.current_hp
	selection.select_only(infantry)
	selection.issue_move(Vector2(900.0, 700.0), 0.0)
	selection.force_advance_decision_for_test()
	infantry._fire_cooldown = 0.0
	infantry._update_combat()
	var move_did_not_auto_acquire: bool = infantry.current_ammo == move_ammo_before and target.current_hp == move_hp_before

	infantry.stop()
	infantry.global_position = Vector2(600.0, 700.0)
	var advance_started: bool = input3d.issue_advance_for_test(infantry, Vector2(900.0, 700.0))
	selection.force_advance_decision_for_test()
	var fire_before: int = infantry.get_fire_serial()
	var ammo_before: int = infantry.current_ammo
	var hp_before: int = target.current_hp
	infantry._fire_cooldown = 0.0
	infantry._update_combat()
	var damage_expected: int = infantry.calculate_attack_damage(target)
	var legal_fire: bool = (
		infantry.current_ammo == ammo_before - 1
		and infantry.get_fire_serial() == fire_before + 1
		and target.current_hp == hp_before - damage_expected
	)
	_require(move_did_not_auto_acquire and legal_fire, "MOVE_ADVANCE_BEHAVIOR_DIFFERENCE_PASS")
	_require(legal_fire, "ADVANCE_LEGAL_FIRE_PASS")

	var start: Vector2 = infantry.global_position
	_advance_movement_to_hold(infantry)
	var movement_pass: bool = advance_started and start.distance_to(infantry.global_position) > 100.0 and infantry.get_order() == "HOLD" and infantry.global_position.distance_to(Vector2(900.0, 700.0)) <= 6.0
	_require(movement_pass, "ADVANCE_REAL_MOVEMENT_PASS")
	await _dispose_battle(context)

func _scenario_confirmed_only() -> void:
	var context: Dictionary = await _spawn_battle()
	var infantry: BattleFormation = context["infantry"] as BattleFormation
	var target: BattleFormation = context["red_inf2"] as BattleFormation
	var selection: BattleSelectionController = context["selection"] as BattleSelectionController
	var intel: BattleIntelTracker = context["intel"] as BattleIntelTracker

	infantry.global_position = Vector2(600.0, 620.0)
	target.global_position = Vector2(760.0, 620.0)
	infantry.stop()
	target.stop()
	selection.select_only(infantry)
	selection.issue_advance(Vector2(920.0, 620.0), 0.0)

	_force_intel(intel, target, BattleIntelTracker.CONTACT)
	_force_intel(intel, target, BattleIntelTracker.UNSEEN)
	var hidden_pass: bool = _assert_no_advance_fire(selection, infantry, target)
	_force_intel(intel, target, BattleIntelTracker.CONTACT)
	var contact_pass: bool = _assert_no_advance_fire(selection, infantry, target)
	_force_intel(intel, target, BattleIntelTracker.LAST_KNOWN)
	var last_known_pass: bool = _assert_no_advance_fire(selection, infantry, target)

	_force_intel(intel, target, BattleIntelTracker.CONFIRMED)
	selection.force_advance_decision_for_test()
	var ammo_before: int = infantry.current_ammo
	var fire_before: int = infantry.get_fire_serial()
	infantry._fire_cooldown = 0.0
	infantry._update_combat()
	var confirmed_pass: bool = infantry.current_ammo == ammo_before - 1 and infantry.get_fire_serial() == fire_before + 1
	_require(hidden_pass and contact_pass and last_known_pass and confirmed_pass, "ADVANCE_CONFIRMED_ONLY_PASS")
	await _dispose_battle(context)

func _scenario_los_range_target_loss() -> void:
	var context: Dictionary = await _spawn_battle()
	var ifv: BattleFormation = context["ifv"] as BattleFormation
	var target: BattleFormation = context["red_inf2"] as BattleFormation
	var selection: BattleSelectionController = context["selection"] as BattleSelectionController
	var intel: BattleIntelTracker = context["intel"] as BattleIntelTracker

	# Central hard blocker lies directly between these points. IFV range is 280.
	ifv.global_position = Vector2(1060.0, 900.0)
	target.global_position = Vector2(1340.0, 900.0)
	ifv.stop()
	target.stop()
	_force_intel(intel, target, BattleIntelTracker.CONFIRMED)
	selection.select_only(ifv)
	selection.issue_advance(Vector2(900.0, 1300.0), 0.0)
	var los_pass: bool = _assert_no_advance_fire(selection, ifv, target)
	_require(los_pass, "ADVANCE_LOS_GATE_PASS")

	# Out of range must not redirect the original ADVANCE destination or chase.
	ifv.stop()
	ifv.global_position = Vector2(600.0, 700.0)
	target.global_position = Vector2(940.0, 700.0)
	_force_intel(intel, target, BattleIntelTracker.CONFIRMED)
	selection.select_only(ifv)
	var destination := Vector2(1220.0, 700.0)
	selection.issue_advance(destination, 0.0)
	var recorded_destination: Vector2 = selection.get_advance_destination_for_test(ifv)
	var before: Vector2 = ifv.global_position
	var no_fire: bool = _assert_no_advance_fire(selection, ifv, target)
	ifv._update_movement(0.10)
	var no_chase: bool = no_fire and selection.is_advancing(ifv) and selection.get_advance_destination_for_test(ifv).is_equal_approx(recorded_destination) and ifv.global_position.x > before.x
	_require(no_chase, "ADVANCE_NO_CHASE_OUT_OF_RANGE_PASS")

	# A legal target can be acquired, then losing CONFIRMED must clear fire while the
	# same movement intent continues.
	target.global_position = ifv.global_position + Vector2(160.0, 0.0)
	_force_intel(intel, target, BattleIntelTracker.CONFIRMED)
	selection.force_advance_decision_for_test()
	_force_intel(intel, target, BattleIntelTracker.LAST_KNOWN)
	var ammo_before_loss: int = ifv.current_ammo
	var fire_before_loss: int = ifv.get_fire_serial()
	var move_before_loss: Vector2 = ifv.global_position
	selection.force_advance_decision_for_test()
	ifv._fire_cooldown = 0.0
	ifv._update_combat()
	ifv._update_movement(0.10)
	var loss_pass: bool = (
		ifv.current_ammo == ammo_before_loss
		and ifv.get_fire_serial() == fire_before_loss
		and selection.is_advancing(ifv)
		and selection.get_advance_destination_for_test(ifv).is_equal_approx(recorded_destination)
		and ifv.global_position.distance_to(move_before_loss) > 0.1
	)
	_require(loss_pass, "ADVANCE_TARGET_LOSS_CONTINUES_PASS")
	await _dispose_battle(context)

func _scenario_deterministic_target() -> void:
	var context: Dictionary = await _spawn_battle()
	var infantry: BattleFormation = context["infantry"] as BattleFormation
	var red1: BattleFormation = context["red_inf1"] as BattleFormation
	var red2: BattleFormation = context["red_inf2"] as BattleFormation
	var selection: BattleSelectionController = context["selection"] as BattleSelectionController
	var intel: BattleIntelTracker = context["intel"] as BattleIntelTracker

	infantry.global_position = Vector2(600.0, 500.0)
	red1.global_position = Vector2(700.0, 480.0)
	red2.global_position = Vector2(700.0, 520.0)
	infantry.stop()
	red1.stop()
	red2.stop()
	_force_intel(intel, red1, BattleIntelTracker.CONFIRMED)
	_force_intel(intel, red2, BattleIntelTracker.CONFIRMED)
	selection.select_only(infantry)
	selection.issue_advance(Vector2(900.0, 500.0), 0.0)
	selection.force_advance_decision_for_test()
	var hp1: int = red1.current_hp
	var hp2: int = red2.current_hp
	infantry._fire_cooldown = 0.0
	infantry._update_combat()
	var lexical_tie_pass: bool = red1.current_hp < hp1 and red2.current_hp == hp2

	# Nearest wins when distances differ.
	red1.current_hp = hp1
	red2.current_hp = hp2
	red1.global_position = Vector2(780.0, 500.0)
	red2.global_position = Vector2(700.0, 500.0)
	selection.force_advance_decision_for_test()
	infantry._fire_cooldown = 0.0
	infantry._update_combat()
	var nearest_pass: bool = red1.current_hp == hp1 and red2.current_hp < hp2
	_require(lexical_tie_pass and nearest_pass, "ADVANCE_DETERMINISTIC_TARGET_PASS")
	await _dispose_battle(context)

func _scenario_hold_fire() -> void:
	var context: Dictionary = await _spawn_battle()
	var infantry: BattleFormation = context["infantry"] as BattleFormation
	var recon: BattleFormation = context["recon"] as BattleFormation
	var ifv: BattleFormation = context["ifv"] as BattleFormation
	var armor: BattleFormation = context["blue_armor_proxy"] as BattleFormation
	var supply: BattleFormation = context["supply"] as BattleFormation
	var target: BattleFormation = context["red_inf2"] as BattleFormation
	var selection: BattleSelectionController = context["selection"] as BattleSelectionController
	var intel: BattleIntelTracker = context["intel"] as BattleIntelTracker

	infantry.global_position = Vector2(600.0, 700.0)
	target.global_position = Vector2(760.0, 700.0)
	infantry.stop()
	target.stop()
	_force_intel(intel, target, BattleIntelTracker.CONFIRMED)
	selection.select_only(infantry)
	selection.toggle_hold_fire_selected()
	infantry.set_combat_target(target) # deliberate final-veto probe
	var ammo_before: int = infantry.current_ammo
	var fire_before: int = infantry.get_fire_serial()
	var hp_before: int = target.current_hp
	for _i: int in range(4):
		infantry._fire_cooldown = 0.0
		infantry._update_combat()
	_require(infantry.current_ammo == ammo_before and infantry.get_fire_serial() == fire_before and target.current_hp == hp_before, "HOLD_FIRE_SUPPRESSES_ATTACK_PASS")

	# HOLD FIRE is independent from MOVE.
	selection.issue_move(Vector2(820.0, 700.0), 0.0)
	_advance_movement_to_hold(infantry)
	_require(infantry.global_position.distance_to(Vector2(820.0, 700.0)) <= 6.0 and infantry.is_hold_fire_enabled(), "HOLD_FIRE_MOVE_ALLOWED_PASS")

	# HOLD FIRE + ADVANCE moves with zero shots, then explicit release while the same
	# ADVANCE remains active resumes legal fire.
	infantry.global_position = Vector2(600.0, 700.0)
	infantry.stop()
	target.global_position = Vector2(760.0, 700.0)
	_force_intel(intel, target, BattleIntelTracker.CONFIRMED)
	selection.select_only(infantry)
	selection.issue_advance(Vector2(1100.0, 700.0), 0.0)
	selection.force_advance_decision_for_test()
	var no_fire_ammo: int = infantry.current_ammo
	var no_fire_serial: int = infantry.get_fire_serial()
	for _step: int in range(4):
		infantry._fire_cooldown = 0.0
		infantry._update_combat()
		infantry._update_movement(0.10)
	var held_advance: bool = selection.is_advancing(infantry) and infantry.current_ammo == no_fire_ammo and infantry.get_fire_serial() == no_fire_serial and infantry.is_hold_fire_enabled()
	_require(held_advance, "HOLD_FIRE_ADVANCE_NO_FIRE_PASS")

	selection.toggle_hold_fire_selected()
	selection.force_advance_decision_for_test()
	var release_ammo: int = infantry.current_ammo
	var release_fire: int = infantry.get_fire_serial()
	infantry._fire_cooldown = 0.0
	infantry._update_combat()
	var release_pass: bool = selection.is_advancing(infantry) and not infantry.is_hold_fire_enabled() and infantry.current_ammo == release_ammo - 1 and infantry.get_fire_serial() == release_fire + 1
	_require(release_pass, "HOLD_FIRE_RELEASE_RESUMES_FIRE_PASS")

	# Fire discipline must not alter any role's capture/contest contract.
	var objective_before: Dictionary = {
		"recon": Vector2i(int(recon.can_capture), int(recon.can_contest)),
		"inf": Vector2i(int(infantry.can_capture), int(infantry.can_contest)),
		"ifv": Vector2i(int(ifv.can_capture), int(ifv.can_contest)),
		"armor": Vector2i(int(armor.can_capture), int(armor.can_contest)),
		"supply": Vector2i(int(supply.can_capture), int(supply.can_contest)),
	}
	recon.set_hold_fire_enabled(true)
	infantry.set_hold_fire_enabled(true)
	ifv.set_hold_fire_enabled(true)
	armor.set_hold_fire_enabled(true)
	var objective_after: Dictionary = {
		"recon": Vector2i(int(recon.can_capture), int(recon.can_contest)),
		"inf": Vector2i(int(infantry.can_capture), int(infantry.can_contest)),
		"ifv": Vector2i(int(ifv.can_capture), int(ifv.can_contest)),
		"armor": Vector2i(int(armor.can_capture), int(armor.can_contest)),
		"supply": Vector2i(int(supply.can_capture), int(supply.can_contest)),
	}
	_require(objective_before == objective_after, "HOLD_FIRE_OBJECTIVE_RULES_UNCHANGED_PASS")

	# Recon detection/intel still runs while its fire discipline is HOLD FIRE.
	recon.global_position = Vector2(600.0, 600.0)
	target.global_position = Vector2(760.0, 600.0)
	_force_intel(intel, target, BattleIntelTracker.UNSEEN)
	intel._process(0.01)
	intel._process(0.80)
	_require(recon.is_hold_fire_enabled() and intel.get_intel_state_for(target) == BattleIntelTracker.CONFIRMED, "HOLD_FIRE_INTEL_UNCHANGED_PASS")
	await _dispose_battle(context)

func _scenario_direct_overrides() -> void:
	var context: Dictionary = await _spawn_battle()
	var infantry: BattleFormation = context["infantry"] as BattleFormation
	var selection: BattleSelectionController = context["selection"] as BattleSelectionController
	var flow: BattlePlayerWarFlow = context["flow"] as BattlePlayerWarFlow
	var resupply: BattleResupplyController = context["resupply"] as BattleResupplyController

	infantry.global_position = Vector2(600.0, 900.0)
	infantry.stop()
	selection.select_only(infantry)
	selection.issue_advance(Vector2(1200.0, 900.0), 0.0)
	selection.issue_move(Vector2(800.0, 900.0), 0.0)
	_require(infantry.get_order() == "MOVE" and not selection.is_advancing(infantry) and selection.get_advance_destination_for_test(infantry) == Vector2.ZERO, "ADVANCE_DIRECT_MOVE_OVERRIDE_PASS")

	infantry.stop()
	selection.select_only(infantry)
	selection.issue_advance(Vector2(1200.0, 900.0), 0.0)
	var withdrew: int = flow.withdraw_selected(false)
	_require(withdrew == 1 and infantry.get_order() == "WITHDRAW" and not selection.is_advancing(infantry), "ADVANCE_WITHDRAW_OVERRIDE_PASS")

	infantry.stop()
	infantry.current_ammo = 0
	infantry.set_hold_fire_enabled(true)
	selection.select_only(infantry)
	selection.issue_advance(Vector2(1200.0, 900.0), 0.0)
	var resupply_started: bool = resupply.start_resupply(infantry)
	var resupply_override: bool = resupply_started and not selection.is_advancing(infantry) and infantry.get_order() != "ADVANCE" and infantry.is_hold_fire_enabled()
	_require(resupply_override, "ADVANCE_RESUPPLY_OVERRIDE_PASS")
	await _dispose_battle(context)

func _scenario_formation_aware_and_logistics() -> void:
	var context: Dictionary = await _spawn_battle()
	var recon: BattleFormation = context["recon"] as BattleFormation
	var ifv: BattleFormation = context["ifv"] as BattleFormation
	var infantry: BattleFormation = context["infantry"] as BattleFormation
	var supply: BattleFormation = context["supply"] as BattleFormation
	var selection: BattleSelectionController = context["selection"] as BattleSelectionController
	var navigation: BattleNavigation = context["navigation"] as BattleNavigation

	var entry: Vector2 = navigation.get_north_foot_link_entry()
	var exit: Vector2 = navigation.get_north_foot_link_exit()
	recon.global_position = entry
	ifv.global_position = entry
	recon.stop()
	ifv.stop()
	selection.select_only(recon)
	selection.add_to_selection(ifv)
	var issued: int = selection.issue_advance(exit, 0.0)
	var recon_path: PackedVector2Array = recon.get_navigation_path()
	var ifv_path: PackedVector2Array = ifv.get_navigation_path()
	var mobility_pass: bool = issued == 2 and navigation.path_uses_north_foot_link(recon_path) and not navigation.path_uses_north_foot_link(ifv_path)
	_require(mobility_pass, "ADVANCE_FORMATION_AWARE_MOBILITY_PASS")

	supply.stop()
	selection.select_only(supply)
	var supply_only: int = selection.issue_advance(Vector2(900.0, 900.0), 0.0)
	selection.select_only(infantry)
	selection.add_to_selection(supply)
	var mixed: int = selection.issue_advance(Vector2(900.0, 900.0), 0.0)
	var logistics_pass: bool = supply_only == 0 and supply.get_order() != "ADVANCE" and mixed == 1 and infantry.get_order() == "ADVANCE" and supply.get_order() != "ADVANCE"
	_require(logistics_pass, "LOGISTICS_ADVANCE_REJECTED_PASS")
	await _dispose_battle(context)

func _scenario_reserve_compatibility() -> void:
	var context: Dictionary = await _spawn_battle()
	var selection: BattleSelectionController = context["selection"] as BattleSelectionController
	var flow: BattlePlayerWarFlow = context["flow"] as BattlePlayerWarFlow
	flow._on_central_capture_completed(BattleObjective.OWNER_PLAYER, BattleObjective.OWNER_AI)
	var reserve: BattleFormation = flow.deploy_reserve("INFANTRY")
	var reserve_pass: bool = reserve != null
	if reserve != null:
		selection.select_only(reserve)
		var advanced: int = selection.issue_advance(Vector2(900.0, 900.0), 0.0)
		var held: int = selection.toggle_hold_fire_selected()
		reserve_pass = advanced == 1 and held == 1 and selection.is_advancing(reserve) and reserve.is_hold_fire_enabled()
	_require(reserve_pass, "RESERVE_COMMAND_COMPATIBILITY_PASS")
	await _dispose_battle(context)

func _spawn_battle() -> Dictionary:
	var battle: Node2D = BATTLE_SCENE.instantiate() as Node2D
	root.add_child(battle)
	await process_frame
	await process_frame
	await process_frame
	battle.process_mode = Node.PROCESS_MODE_DISABLED

	var roster: BattleFormalCombatRoster = battle.get_node("FormalCombatRoster") as BattleFormalCombatRoster
	return {
		"battle": battle,
		"selection": battle.get_node("SelectionController") as BattleSelectionController,
		"input3d": battle.get_node("Battle3DInput") as Battle3DInput,
		"intel": battle.get_node("IntelTracker") as BattleIntelTracker,
		"navigation": battle.get_node("Navigation") as BattleNavigation,
		"visibility": battle.get_node("VisibilityField") as BattleVisibilityField,
		"flow": battle.get_node("PlayerWarFlow") as BattlePlayerWarFlow,
		"resupply": battle.get_node("ResupplyController") as BattleResupplyController,
		"recon": battle.get_node("BlueRecon") as BattleFormation,
		"infantry": battle.get_node("BlueInfantry") as BattleFormation,
		"ifv": battle.get_node("BlueFormation") as BattleFormation,
		"supply": battle.get_node("BlueSupply") as BattleFormation,
		# Existing Armor definition is needed only to prove the role flags remain frozen;
		# the dormant RED reinforcement uses the same definition without changing roster state.
		"blue_armor_proxy": roster.reinforcement_armor[0] as BattleFormation,
		"red_inf1": roster.enemy_infantry[0] as BattleFormation,
		"red_inf2": roster.enemy_infantry[1] as BattleFormation,
	}

func _force_intel(intel: BattleIntelTracker, target: BattleFormation, state: String) -> void:
	if intel.get_intel_state_for(target) == state:
		var alternate: String = BattleIntelTracker.CONTACT if state != BattleIntelTracker.CONTACT else BattleIntelTracker.UNSEEN
		intel._set_target_state(target, alternate)
	intel._set_target_state(target, state)

func _assert_no_advance_fire(selection: BattleSelectionController, formation: BattleFormation, target: BattleFormation) -> bool:
	selection.force_advance_decision_for_test()
	var ammo_before: int = formation.current_ammo
	var fire_before: int = formation.get_fire_serial()
	var hp_before: int = target.current_hp
	formation._fire_cooldown = 0.0
	formation._update_combat()
	return formation.current_ammo == ammo_before and formation.get_fire_serial() == fire_before and target.current_hp == hp_before

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
