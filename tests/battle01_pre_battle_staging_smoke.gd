extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle01/Battle01.tscn")

var _failures: PackedStringArray = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	print("FRONTLINE_PRE_BATTLE_STAGING_SMOKE_BEGIN")
	var battle: Node = BATTLE_SCENE.instantiate()
	root.add_child(battle)
	var staging: BattlePreBattleStagingController = battle.get_node_or_null("PreBattleStaging") as BattlePreBattleStagingController
	if staging == null:
		_failures.append("STAGING_CONTROLLER_MISSING")
		_finish(battle)
		return
	staging.force_keep_staging_for_test()
	await process_frame
	await process_frame
	await process_frame
	await process_frame

	var navigation: BattleNavigation = battle.get_node("Navigation") as BattleNavigation
	var selection: BattleSelectionController = battle.get_node("SelectionController") as BattleSelectionController
	var war_flow: BattlePlayerWarFlow = battle.get_node("PlayerWarFlow") as BattlePlayerWarFlow
	var enemy_ai: Node = battle.get_node("EnemyAIController")
	var intel: BattleIntelTracker = battle.get_node("IntelTracker") as BattleIntelTracker
	var central: BattleObjective = battle.get_node("CentralBridgehead") as BattleObjective
	var industrial: BattleObjective = battle.get_node("IndustrialObjective") as BattleObjective
	var roster: BattleFormalCombatRoster = battle.get_node("FormalCombatRoster") as BattleFormalCombatRoster
	var recon: BattleFormation = battle.get_node("BlueRecon") as BattleFormation
	var infantry: BattleFormation = battle.get_node("BlueInfantry") as BattleFormation
	var ifv: BattleFormation = battle.get_node("BlueFormation") as BattleFormation
	var supply: BattleFormation = battle.get_node("BlueSupply") as BattleFormation

	var posture_before: String = roster.get_selected_posture()
	var seed_before: int = roster.get_battle01_seed()
	var red_before: Dictionary = _red_position_snapshot(battle)
	var hp_before: Dictionary = _blue_hp_snapshot([recon, infantry, ifv, supply])
	var ammo_before: Dictionary = _blue_ammo_snapshot([recon, infantry, ifv, supply])
	var central_owner_before: String = central.get_control_owner()
	var industrial_owner_before: String = industrial.get_control_owner()

	_require(staging.is_staging_active() and is_equal_approx(staging.get_battle_elapsed_for_test(), 0.0), "STAGING_RUNTIME_ACTIVE_PASS")
	_require(not enemy_ai.is_processing() and not intel.is_processing() and not central.is_processing() and not industrial.is_processing() and not war_flow.is_processing(), "STAGING_SIMULATION_SYSTEMS_FROZEN_PASS")
	_require(not recon.is_processing() and not infantry.is_processing() and not ifv.is_processing() and not supply.is_processing(), "STAGING_FRIENDLY_EXECUTION_FROZEN_PASS")
	_require(staging.all_staged_positions_valid(), "STAGING_DEFAULT_BLUE_POSITIONS_VALID_PASS")
	_require(staging.has_staging_boundary_visual_for_test(), "STAGING_BOUNDARY_VISIBLE_PASS")
	_require(_find_button_by_text(battle, "START BATTLE") != null, "START_BATTLE_MOUSE_BUTTON_PASS")

	for _frame: int in range(18):
		await process_frame
	_require(is_equal_approx(staging.get_battle_elapsed_for_test(), 0.0), "STAGING_COMBAT_CLOCK_FROZEN_PASS")
	_require(_red_positions_equal(red_before, _red_position_snapshot(battle)), "STAGING_ENEMY_AI_NO_MOVEMENT_PASS")
	_require(_blue_snapshots_equal(hp_before, _blue_hp_snapshot([recon, infantry, ifv, supply])) and _blue_snapshots_equal(ammo_before, _blue_ammo_snapshot([recon, infantry, ifv, supply])), "STAGING_NO_DAMAGE_AMMO_CONSUMPTION_PASS")
	_require(central.get_control_owner() == central_owner_before and industrial.get_control_owner() == industrial_owner_before and central.progress <= 0.001 and industrial.progress <= 0.001, "STAGING_OBJECTIVE_PROGRESS_FROZEN_PASS")

	var placement_ok: bool = true
	placement_ok = staging.place_formation_for_test(recon, Vector2(740.0, 560.0)) and placement_ok
	placement_ok = staging.place_formation_for_test(infantry, Vector2(700.0, 1160.0)) and placement_ok
	placement_ok = staging.place_formation_for_test(ifv, Vector2(520.0, 820.0)) and placement_ok
	placement_ok = staging.place_formation_for_test(supply, Vector2(340.0, 1120.0)) and placement_ok
	_require(placement_ok and staging.all_staged_positions_valid(), "STAGING_ALL_BLUE_REPLACEMENT_PASS")

	var ifv_valid_position: Vector2 = ifv.global_position
	staging.begin_placement_drag(ifv)
	staging.update_placement_drag(Vector2(1040.0, 900.0))
	var invalid_commit: bool = staging.end_placement_drag(Vector2(1040.0, 900.0))
	_require(not invalid_commit and ifv.global_position.is_equal_approx(ifv_valid_position), "STAGING_INVALID_PLACEMENT_REVERT_PASS")

	var recon_valid_position: Vector2 = recon.global_position
	var too_close: Vector2 = ifv.global_position + Vector2(80.0, 0.0)
	staging.begin_placement_drag(recon)
	staging.update_placement_drag(too_close)
	var separation_commit: bool = staging.end_placement_drag(too_close)
	_require(not separation_commit and recon.global_position.is_equal_approx(recon_valid_position), "STAGING_FORMATION_SEPARATION_PASS")

	var recon_before_queue: Vector2 = recon.global_position
	selection.select_only(recon)
	var move_target: Vector2 = navigation.get_north_foot_link_exit()
	var move_queued: bool = selection.issue_move(move_target) == 1
	for _frame: int in range(6):
		await process_frame
	_require(move_queued and staging.get_initial_intent_for(recon) == "MOVE" and recon.get_order() == "HOLD" and recon.global_position.is_equal_approx(recon_before_queue), "STAGING_INITIAL_MOVE_QUEUE_NO_EXECUTION_PASS")

	var ifv_before_queue: Vector2 = ifv.global_position
	selection.select_only(ifv)
	var advance_target := Vector2(1360.0, 900.0)
	var advance_queued: bool = selection.issue_advance(advance_target) == 1
	for _frame: int in range(6):
		await process_frame
	_require(advance_queued and staging.get_initial_intent_for(ifv) == "ADVANCE" and ifv.get_order() == "HOLD" and ifv.global_position.is_equal_approx(ifv_before_queue), "STAGING_INITIAL_ADVANCE_QUEUE_NO_EXECUTION_PASS")

	selection.select_only(supply)
	var supply_move_target := Vector2(1000.0, 1080.0)
	var supply_move_queued: bool = selection.issue_move(supply_move_target) == 1
	var supply_advance_rejected: bool = selection.issue_advance(Vector2(1200.0, 1080.0)) == 0
	_require(supply_move_queued and supply_advance_rejected and staging.get_initial_intent_for(supply) == "MOVE", "STAGING_LOGISTICS_ADVANCE_REJECT_PASS")

	selection.select_only(infantry)
	_require(staging.clear_initial_selected() == 1 and staging.get_initial_intent_for(infantry) == "HOLD", "STAGING_INITIAL_HOLD_PASS")
	selection.select_only(ifv)
	selection.toggle_hold_fire_selected()
	_require(ifv.is_hold_fire_enabled(), "STAGING_HOLD_FIRE_PRESET_PASS")

	var red_hidden: bool = true
	for red: BattleFormation in _all_red_formations(battle):
		if red.intel_state != BattleIntelTracker.UNSEEN:
			red_hidden = false
			break
	var posture_leaked: bool = _ui_contains_text(battle, posture_before)
	_require(red_hidden and not posture_leaked, "STAGING_FOW_NO_POSTURE_LEAK_PASS")

	var posture_after_reposition: String = roster.get_selected_posture()
	var seed_after_reposition: int = roster.get_battle01_seed()
	_require(posture_after_reposition == posture_before and seed_after_reposition == seed_before and roster.is_posture_locked(), "STAGING_REPOSITION_NO_RED_REROLL_PASS")

	var reserve_before: Dictionary = war_flow.get_reserve_status()
	_require(not bool(reserve_before.get("unlocked", false)) and war_flow.deploy_reserve("INFANTRY") == null, "STAGING_RESERVE_LOCK_PASS")
	_require(not war_flow.try_supply_selected(), "STAGING_RESUPPLY_BLOCK_PASS")
	_require(war_flow.withdraw_selected(true) == 0, "STAGING_WITHDRAW_BLOCK_PASS")

	selection.select_only(recon)
	selection.add_to_selection(ifv)
	var started: bool = staging.start_battle_for_test()
	var posture_after_start: String = roster.get_selected_posture()
	var seed_after_start: int = roster.get_battle01_seed()
	_require(started and not staging.is_staging_active(), "STAGING_START_TRANSITION_PASS")
	_require(staging.get_t0_activation_count_for_test() == 4 and is_equal_approx(staging.get_battle_elapsed_for_test(), 0.0), "STAGING_SIMULTANEOUS_T0_EXECUTION_PASS")
	_require(recon.get_order() == "MOVE" and ifv.get_order() == "ADVANCE" and infantry.get_order() == "HOLD" and supply.get_order() == "MOVE", "STAGING_INITIAL_INTENTS_ACTIVATED_PASS")
	_require(ifv.is_hold_fire_enabled(), "STAGING_HOLD_FIRE_CARRYOVER_PASS")
	_require(posture_after_start == posture_before and seed_after_start == seed_before, "STAGING_START_NO_RED_REROLL_PASS")
	_require(enemy_ai.is_processing() and intel.is_processing() and central.is_processing() and industrial.is_processing() and war_flow.is_processing(), "STAGING_SIMULATION_ACTIVATED_AT_T0_PASS")

	await process_frame
	await process_frame
	_require(staging.get_battle_elapsed_for_test() > 0.0, "STAGING_BATTLE_CLOCK_STARTED_PASS")
	_require(ifv.get_fire_serial() == 0, "STAGING_HOLD_FIRE_FINAL_VETO_PASS")

	battle.queue_free()
	await process_frame
	var restarted: Node = BATTLE_SCENE.instantiate()
	root.add_child(restarted)
	var staging_restart: BattlePreBattleStagingController = restarted.get_node("PreBattleStaging") as BattlePreBattleStagingController
	staging_restart.force_keep_staging_for_test()
	await process_frame
	await process_frame
	await process_frame
	_require(staging_restart.is_staging_active() and staging_restart.all_staged_positions_valid(), "STAGING_RESTART_RETURNS_TO_STAGING_PASS")

	_finish(restarted)

func _all_red_formations(node: Node) -> Array[BattleFormation]:
	var result: Array[BattleFormation] = []
	_collect_red(node, result)
	return result

func _collect_red(node: Node, result: Array[BattleFormation]) -> void:
	if node is BattleFormation:
		var formation := node as BattleFormation
		if formation.faction == "RED":
			result.append(formation)
	for child: Node in node.get_children():
		_collect_red(child, result)

func _red_position_snapshot(battle: Node) -> Dictionary:
	var snapshot: Dictionary = {}
	for red: BattleFormation in _all_red_formations(battle):
		snapshot[red.display_name] = red.global_position
	return snapshot

func _red_positions_equal(a: Dictionary, b: Dictionary) -> bool:
	if a.size() != b.size():
		return false
	for key: Variant in a.keys():
		if not b.has(key) or not Vector2(a[key]).is_equal_approx(Vector2(b[key])):
			return false
	return true

func _blue_hp_snapshot(formations: Array[BattleFormation]) -> Dictionary:
	var result: Dictionary = {}
	for formation: BattleFormation in formations:
		result[formation.display_name] = formation.current_hp
	return result

func _blue_ammo_snapshot(formations: Array[BattleFormation]) -> Dictionary:
	var result: Dictionary = {}
	for formation: BattleFormation in formations:
		result[formation.display_name] = formation.current_ammo
	return result

func _blue_snapshots_equal(a: Dictionary, b: Dictionary) -> bool:
	return a == b

func _find_button_by_text(node: Node, text_value: String) -> Button:
	if node is Button and (node as Button).text == text_value:
		return node as Button
	for child: Node in node.get_children():
		var found: Button = _find_button_by_text(child, text_value)
		if found != null:
			return found
	return null

func _ui_contains_text(node: Node, needle: String) -> bool:
	if needle.is_empty():
		return false
	if node is Label and needle in (node as Label).text:
		return true
	if node is Button and needle in (node as Button).text:
		return true
	for child: Node in node.get_children():
		if _ui_contains_text(child, needle):
			return true
	return false

func _require(condition: bool, marker: String) -> void:
	if condition:
		print(marker)
	else:
		_failures.append(marker)
		push_error("FAILED %s" % marker)

func _finish(battle: Node) -> void:
	if _failures.is_empty():
		print("FRONTLINE_PRE_BATTLE_STAGING_SMOKE_PASS")
		if battle != null:
			battle.queue_free()
		quit(0)
		return
	for failure: String in _failures:
		push_error("PRE_BATTLE_STAGING_SMOKE_FAILURE %s" % failure)
	if battle != null:
		battle.queue_free()
	quit(1)
