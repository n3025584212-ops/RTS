extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle01/Battle01.tscn")
const EXPECTED_POSTURES := ["BRIDGE_LOCK", "VILLAGE_SCREEN", "SOUTH_SCREEN", "BRIDGE_LOCK"]
const RUN_LABELS := ["A", "B", "C"]
const RUN_PLANS := ["CENTRAL_TEMPO", "NORTH_INFORMATION", "SOUTH_MANEUVER"]
const RUN_RESERVES := ["ARMOR", "INFANTRY", "ARMOR"]
const MAX_MATCH_SECONDS: float = 300.0

var _failures: PackedStringArray = []
var _runs: Array[Dictionary] = []
var _current: Dictionary = {}
var _battle: Node2D
var _staging: BattlePreBattleStagingController
var _camera: BattleCamera3D
var _presentation: Battle3DPresentation
var _selection: BattleSelectionController
var _war_flow: BattlePlayerWarFlow
var _resupply: BattleResupplyController
var _roster: BattleFormalCombatRoster
var _intel: BattleIntelTracker
var _central: BattleObjective
var _industrial: BattleObjective
var _ai: BattleEnemyAIController
var _minimap: BattleMinimap
var _recon: BattleFormation
var _infantry: BattleFormation
var _ifv: BattleFormation
var _supply: BattleFormation
var _last_sample_time: float = -1.0
var _last_positions: Dictionary = {}
var _last_motion_times: Dictionary = {}
var _fow_violation: bool = false
var _softlock_found: bool = false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	print("FRONTLINE_INTEGRATED_PLAYER_FLOW_EVIDENCE_BEGIN")
	print("INTEGRATED_ENGINE=%s" % Engine.get_version_info().get("string", "UNKNOWN"))
	for run_index: int in range(3):
		if not await _load_normal_battle(EXPECTED_POSTURES[run_index]):
			_finish()
			return
		await _run_victory_session(run_index)
		if not _war_flow.is_victory():
			_fail("RUN_%s_NORMAL_VICTORY_NOT_REACHED" % RUN_LABELS[run_index])
			_finish()
			return
		_runs.append(_current.duplicate(true))
		if not await _restart_through_hud(EXPECTED_POSTURES[run_index + 1]):
			_finish()
			return

	print("INTEGRATED_POSTURE_SEQUENCE_A_B_C_A_PASS")
	await _run_defeat_control()
	_emit_final_markers()
	_finish()


func _load_normal_battle(expected_posture: String) -> bool:
	var err: Error = change_scene_to_packed(BATTLE_SCENE)
	if err != OK:
		_fail("NORMAL_SCENE_LOAD_FAILED_%s" % err)
		return false
	for _frame: int in range(10):
		await process_frame
	return _bind_current_battle(expected_posture)


func _bind_current_battle(expected_posture: String) -> bool:
	_battle = current_scene as Node2D
	if _battle == null:
		_fail("CURRENT_SCENE_NOT_BATTLE01")
		return false
	_staging = _battle.get_node_or_null("PreBattleStaging") as BattlePreBattleStagingController
	_camera = _battle.get_node_or_null("World3D/BattleCamera3D") as BattleCamera3D
	_presentation = _battle.get_node_or_null("World3D/Presentation3D") as Battle3DPresentation
	_selection = _battle.get_node_or_null("SelectionController") as BattleSelectionController
	_war_flow = _battle.get_node_or_null("PlayerWarFlow") as BattlePlayerWarFlow
	_resupply = _battle.get_node_or_null("ResupplyController") as BattleResupplyController
	_roster = _battle.get_node_or_null("FormalCombatRoster") as BattleFormalCombatRoster
	_intel = _battle.get_node_or_null("IntelTracker") as BattleIntelTracker
	_central = _battle.get_node_or_null("CentralBridgehead") as BattleObjective
	_industrial = _battle.get_node_or_null("IndustrialObjective") as BattleObjective
	_ai = _battle.get_node_or_null("EnemyAIController") as BattleEnemyAIController
	_minimap = _find_minimap(_battle)
	_recon = _battle.get_node_or_null("BlueRecon") as BattleFormation
	_infantry = _battle.get_node_or_null("BlueInfantry") as BattleFormation
	_ifv = _battle.get_node_or_null("BlueFormation") as BattleFormation
	_supply = _battle.get_node_or_null("BlueSupply") as BattleFormation
	var ready: bool = (
		_staging != null and _camera != null and _presentation != null and _selection != null
		and _war_flow != null and _resupply != null and _roster != null and _intel != null
		and _central != null and _industrial != null and _ai != null and _minimap != null
		and _recon != null and _infantry != null and _ifv != null and _supply != null
	)
	if not ready:
		_fail("INTEGRATED_RUNTIME_DEPENDENCY_MISSING")
		return false
	if not _staging.is_staging_active():
		_fail("NORMAL_SCENE_DID_NOT_ENTER_STAGING")
		return false
	var actual_posture: String = _roster.get_selected_posture()
	print("INTEGRATED_SESSION_READY posture=%s expected=%s run_index=%d" % [actual_posture, expected_posture, BattleFormalCombatRoster.get_normal_run_index_for_test()])
	if actual_posture != expected_posture:
		_fail("POSTURE_SEQUENCE_EXPECTED_%s_ACTUAL_%s" % [expected_posture, actual_posture])
		return false
	return true


func _run_victory_session(run_index: int) -> void:
	_current = _new_run_record(run_index)
	_last_sample_time = -1.0
	_last_positions.clear()
	_last_motion_times.clear()
	var label: String = RUN_LABELS[run_index]
	print("INTEGRATED_RUN_%s_BEGIN posture=%s plan=%s" % [label, _roster.get_selected_posture(), RUN_PLANS[run_index]])

	await _verify_staging_and_fow()
	await _redeploy_all_blue()
	await _queue_initial_plan(run_index)
	var staging_seconds: float = float(Time.get_ticks_msec() - int(_current["wall_start_ms"])) / 1000.0
	_current["staging_duration"] = staging_seconds
	await _click_button(_find_button_by_text(_battle, "START BATTLE"))
	for _frame: int in range(4):
		await process_frame
	_require(not _staging.is_staging_active() and _staging.get_t0_activation_count_for_test() == 4, "RUN_%s_STAGING_START_PASS" % label)

	if run_index == 0:
		await _run_a_opening()
	elif run_index == 1:
		await _run_b_opening()
	else:
		await _run_c_opening()

	if _war_flow.is_match_finished():
		_finalize_run_record()
		return
	await _fight_central(run_index)
	if run_index == 0:
		_current["advance_fire_delta"] = _ifv.get_fire_serial() - int(_current.get("advance_fire_start", _ifv.get_fire_serial()))
	if _war_flow.is_match_finished():
		_finalize_run_record()
		return
	await _capture_objective(_central, "CENTRAL", 90.0)
	if _central.get_control_owner() != BattleObjective.OWNER_PLAYER:
		_fail("RUN_%s_CENTRAL_CAPTURE_NOT_REACHED" % label)
		_finalize_run_record()
		return

	await _commit_reserve(RUN_RESERVES[run_index])
	await _counterattack_and_resupply(run_index)
	if _war_flow.is_match_finished():
		_finalize_run_record()
		return
	await _fight_to_industrial(run_index)
	if not _war_flow.is_match_finished():
		await _capture_objective(_industrial, "INDUSTRIAL", 100.0)
	if not _war_flow.is_match_finished():
		# Re-secure Central if a reinforcement contested it while the player moved east.
		await _fight_central(run_index)
		await _capture_objective(_central, "CENTRAL_RECOVERY", 70.0)
		await _capture_objective(_industrial, "INDUSTRIAL_RECOVERY", 70.0)
	await _wait_until_match_finished(40.0)
	_finalize_run_record()


func _new_run_record(run_index: int) -> Dictionary:
	return {
		"label": RUN_LABELS[run_index],
		"posture": _roster.get_selected_posture(),
		"plan": RUN_PLANS[run_index],
		"reserve": RUN_RESERVES[run_index],
		"wall_start_ms": Time.get_ticks_msec(),
		"staging_duration": 0.0,
		"first_contact": -1.0,
		"central_contest": -1.0,
		"central_capture": -1.0,
		"counterattack": -1.0,
		"reserve_use": -1.0,
		"industrial_contact": -1.0,
		"total_duration": -1.0,
		"orders_move": 0,
		"orders_advance": 0,
		"orders_hold_fire": 0,
		"orders_weapons_free": 0,
		"orders_resupply": 0,
		"orders_withdraw": 0,
		"orders_reserve": 0,
		"start_nodes": Performance.get_monitor(Performance.OBJECT_NODE_COUNT),
		"end_nodes": 0,
		"move_fire_delta": -1,
		"advance_fire_delta": -1,
		"hold_fire_move_distance": 0.0,
		"hold_fire_fire_delta": -1,
		"weapons_free_fire_delta": -1,
		"blue_resupply_complete": false,
		"blue_resupply_interrupt": false,
		"red_supply_pressure": false,
		"counterattack_pressure": false,
		"intel_contact_seen": false,
		"intel_confirmed_seen": false,
		"intel_last_known_seen": false,
		"central_contested_seen": false,
		"route_travel_time": -1.0,
		"route_path_length": 0.0,
		"north_foot_used": false,
		"vehicle_foot_link_rejected": false,
		"south_vehicle_stable": false,
		"recon_fire": _recon.get_fire_serial(),
		"infantry_fire": _infantry.get_fire_serial(),
		"ifv_fire": _ifv.get_fire_serial(),
		"supply_start_charges": _supply.get_supply_charges(),
		"result": "RUNNING",
	}


func _verify_staging_and_fow() -> void:
	_require(_central.get_control_owner() == BattleObjective.OWNER_AI and _industrial.is_player_capture_locked(), "INTEGRATED_OBJECTIVE_INITIAL_STATE_PASS")
	var reserve_status: Dictionary = _war_flow.get_reserve_status()
	_require(not bool(reserve_status.get("unlocked", false)) and not bool(reserve_status.get("deployable", false)), "INTEGRATED_RESERVE_PRECAPTURE_LOCK_PASS")
	var map_rect: Rect2 = _minimap.get_global_rect()
	var east_local := Vector2(_minimap.size.x * 0.88, _minimap.size.y * 0.54)
	await _mouse_click(map_rect.position + east_local, MOUSE_BUTTON_LEFT, false)
	for _frame: int in range(3):
		await process_frame
	var hidden: bool = _minimap.get_drawable_red_count_for_test() == 0 and _visible_red_proxy_count() == 0
	for red: BattleFormation in _all_red_formations():
		if red.intel_state != BattleIntelTracker.UNSEEN:
			hidden = false
	_require(hidden, "INTEGRATED_STAGING_CAMERA_EAST_FOW_PASS")


func _redeploy_all_blue() -> void:
	var placements: Array[Dictionary] = [
		{"unit": _recon, "point": Vector2(740.0, 560.0)},
		{"unit": _infantry, "point": Vector2(700.0, 1160.0)},
		{"unit": _ifv, "point": Vector2(520.0, 820.0)},
		{"unit": _supply, "point": Vector2(340.0, 1120.0)},
	]
	for record: Dictionary in placements:
		var unit: BattleFormation = record["unit"] as BattleFormation
		var target: Vector2 = record["point"] as Vector2
		await _drag_formation(unit, target)
	_require(_staging.all_staged_positions_valid(), "INTEGRATED_ALL_BLUE_REAL_INPUT_REDEPLOY_PASS")


func _queue_initial_plan(run_index: int) -> void:
	if run_index == 0:
		await _issue_order([_ifv], Vector2(1040.0, 700.0), false)
		await _issue_order([_recon], Vector2(900.0, 500.0), true)
		await _issue_order([_infantry], Vector2(500.0, 1200.0), false)
		await _issue_order([_supply], Vector2(340.0, 1200.0), false)
	elif run_index == 1:
		await _issue_order([_recon], Vector2(900.0, 640.0), false)
		await _issue_order([_infantry], Vector2(900.0, 700.0), true)
		await _issue_order([_ifv], Vector2(1040.0, 900.0), false)
		await _issue_order([_supply], Vector2(980.0, 1120.0), false)
	else:
		await _issue_order([_ifv], Vector2(900.0, 1360.0), true)
		await _issue_order([_supply], Vector2(860.0, 1240.0), false)
		await _issue_order([_recon], Vector2(1040.0, 900.0), false)
		await _issue_order([_infantry], Vector2(1080.0, 1040.0), true)


func _run_a_opening() -> void:
	var start_time: float = _elapsed()
	var fire_before: int = _ifv.get_fire_serial()
	await _wait_until_unit_settled(_ifv, 22.0)
	_current["route_travel_time"] = _elapsed() - start_time
	_current["move_fire_delta"] = _ifv.get_fire_serial() - fire_before
	print("INTEGRATED_MOVE_OBSERVATION unit=%s fire_delta=%d travel=%.2f" % [_ifv.display_name, int(_current["move_fire_delta"]), float(_current["route_travel_time"])])
	var advance_before: int = _ifv.get_fire_serial()
	_current["advance_fire_start"] = advance_before
	_current["route_path_length"] = _path_length_for(_ifv, Vector2(2080.0, 900.0))


func _run_b_opening() -> void:
	var start_position: Vector2 = _recon.global_position
	var fire_before: int = _recon.get_fire_serial()
	await _select_units([_recon])
	await _key_tap(KEY_H)
	_count("orders_hold_fire")
	await _issue_order([_recon], Vector2(1180.0, 620.0), false)
	await _wait_sim_seconds(2.2)
	_current["hold_fire_move_distance"] = start_position.distance_to(_recon.global_position)
	_current["hold_fire_fire_delta"] = _recon.get_fire_serial() - fire_before
	await _select_units([_recon])
	await _key_tap(KEY_H)
	_count("orders_weapons_free")
	var free_before: int = _recon.get_fire_serial()
	await _issue_order([_recon, _infantry], Vector2(1540.0, 700.0), true)
	await _wait_for_fire_delta(_recon, free_before, 22.0)
	_current["weapons_free_fire_delta"] = _recon.get_fire_serial() - free_before
	var nav: BattleNavigation = _battle.get_node("Navigation") as BattleNavigation
	var recon_path: PackedVector2Array = nav.find_path_for_formation(_recon, Vector2(1540.0, 700.0))
	var ifv_path: PackedVector2Array = nav.find_path_for_formation(_ifv, Vector2(1540.0, 700.0))
	var supply_path: PackedVector2Array = nav.find_path_for_formation(_supply, Vector2(1540.0, 700.0))
	_current["north_foot_used"] = nav.path_uses_north_foot_link(recon_path)
	_current["vehicle_foot_link_rejected"] = not nav.path_uses_north_foot_link(ifv_path) and not nav.path_uses_north_foot_link(supply_path)
	_current["route_path_length"] = nav.get_path_length(recon_path)
	_current["route_travel_time"] = _elapsed()
	await _issue_order([_ifv], Vector2(2100.0, 900.0), true)
	await _issue_order([_supply], Vector2(1260.0, 1080.0), false)


func _run_c_opening() -> void:
	var nav: BattleNavigation = _battle.get_node("Navigation") as BattleNavigation
	var start_time: float = _elapsed()
	var south_path: PackedVector2Array = nav.find_path_for_formation(_ifv, Vector2(1320.0, 1400.0))
	_current["route_path_length"] = nav.get_path_length(south_path)
	await _issue_order([_ifv], Vector2(1320.0, 1400.0), true)
	await _issue_order([_supply], Vector2(1260.0, 1400.0), false)
	await _wait_until_near(_ifv, Vector2(1320.0, 1400.0), 80.0, 30.0)
	_current["route_travel_time"] = _elapsed() - start_time
	_current["south_vehicle_stable"] = _ifv.is_alive and not _ifv.has_active_navigation_path() and _supply.is_alive
	await _issue_order([_ifv, _infantry, _recon], Vector2(2080.0, 1080.0), true)
	await _issue_order([_supply], Vector2(1540.0, 1240.0), false)


func _fight_central(run_index: int) -> void:
	await _kite_initial_red_infantry(run_index)
	print("INTEGRATED_PRE_ARMOR_STATUS blue=%s red=%s" % [_formation_status(_war_flow.get_friendlies()), _formation_status(_all_red_formations())])
	if not _war_flow.is_match_finished():
		await _kite_initial_red_armor()


func _kite_initial_red_infantry(run_index: int) -> void:
	if not _ifv.is_alive:
		return
	# Recon observes outside RED Infantry weapon range; Infantry and Logistics stay
	# behind the contact line. IFV alternates ADVANCE fire with movement-only
	# displacement whenever a confirmed infantry defender closes inside 235.
	var recon_observation: Vector2 = Vector2(520.0, 520.0) if run_index != 2 else Vector2(520.0, 1240.0)
	await _issue_order([_recon], recon_observation, false)
	await _issue_order([_infantry], Vector2(500.0, 1200.0), false)
	await _issue_order([_supply], Vector2(340.0, 1200.0), false)
	await _issue_order([_ifv], Vector2(1000.0, 700.0), false)
	await _wait_for_group_settle([_ifv], 8.0)
	var deadline: float = _elapsed() + 48.0
	while _initial_red_infantry_alive_count() > 0 and _ifv.is_alive and not _war_flow.is_match_finished() and _elapsed() < deadline:
		var defenders_before: int = _initial_red_infantry_alive_count()
		await _issue_order([_ifv], Vector2(1580.0, 700.0), true)
		var attack_deadline: float = minf(deadline, _elapsed() + 9.0)
		while _initial_red_infantry_alive_count() == defenders_before and _ifv.is_alive and not _war_flow.is_match_finished() and _elapsed() < attack_deadline:
			await process_frame
			_observe_frame()
		if _ifv.is_alive:
			await _issue_order([_ifv], Vector2(820.0, 700.0), false)
			await _wait_sim_seconds(4.0)
	print("INTEGRATED_IFV_INFANTRY_KITE_RESULT defenders_alive=%d ifv_hp=%d ifv_ammo=%d" % [_initial_red_infantry_alive_count(), _ifv.current_hp, _ifv.current_ammo])


func _lure_initial_red_armor_east() -> void:
	var armor: BattleFormation = _roster.enemy_armor[0] if not _roster.enemy_armor.is_empty() else null
	if armor == null or not armor.is_alive:
		return
	# The foot-mobile Recon crosses north of the central exposure and continues
	# east. This is a normal movement-only decoy: it never receives a combat target.
	if _recon.is_alive:
		await _issue_order([_recon], Vector2(1060.0, 460.0), false)
		await _wait_until_near(_recon, Vector2(1060.0, 460.0), 70.0, 6.0)
		await _issue_order([_recon], Vector2(1460.0, 460.0), false)
		await _wait_until_near(_recon, Vector2(1460.0, 460.0), 70.0, 6.0)
		await _issue_order([_recon], Vector2(2100.0, 700.0), false)
		await _wait_until_near(_recon, Vector2(2100.0, 700.0), 80.0, 8.0)
		await _wait_sim_seconds(0.9)
		if _recon.is_alive:
			await _issue_order([_recon], Vector2(2680.0, 620.0), false)
	var first_deadline: float = _elapsed() + 18.0
	while armor.is_alive and armor.global_position.x < 2120.0 and _elapsed() < first_deadline and not _war_flow.is_match_finished():
		await process_frame
		_observe_frame()
	# Logistics is already on the South vehicle lane. Continue east to sustain the
	# displacement if Recon loses contact; both are non-capture roles.
	if _supply.is_alive:
		await _issue_order([_supply], Vector2(2100.0, 1000.0), false)
		await _wait_until_near(_supply, Vector2(2100.0, 1000.0), 80.0, 8.0)
		await _wait_sim_seconds(0.9)
		if _supply.is_alive:
			await _issue_order([_supply], Vector2(3020.0, 1060.0), false)
	var second_deadline: float = _elapsed() + 16.0
	while armor.is_alive and armor.global_position.x < 2320.0 and _elapsed() < second_deadline and not _war_flow.is_match_finished():
		await process_frame
		_observe_frame()
	print("INTEGRATED_ARMOR_LURE_RESULT armor_pos=%s armor_hp=%d recon_alive=%s supply_alive=%s" % [armor.global_position, armor.current_hp, _recon.is_alive, _supply.is_alive])


func _kite_initial_red_armor() -> void:
	var armor: BattleFormation = _roster.enemy_armor[0] if not _roster.enemy_armor.is_empty() else null
	if armor == null or not armor.is_alive:
		return
	var damage_memory: Dictionary = {}
	var retreat_until: Dictionary = {}
	for unit: BattleFormation in _alive_combat_friendlies():
		damage_memory[unit] = unit.get_damage_serial()
		retreat_until[unit] = -1.0
	await _issue_order(_alive_combat_friendlies(), Vector2(1500.0, 700.0), false)
	await _wait_for_group_settle(_alive_combat_friendlies(), 10.0)
	await _issue_order(_alive_combat_friendlies(), Vector2(2240.0, 900.0), true)
	var deadline: float = _elapsed() + 55.0
	var last_attack_order: float = _elapsed()
	while armor.is_alive and not _war_flow.is_match_finished() and _elapsed() < deadline:
		await process_frame
		_observe_frame()
		for unit: BattleFormation in _alive_combat_friendlies():
			if not damage_memory.has(unit):
				damage_memory[unit] = unit.get_damage_serial()
				retreat_until[unit] = -1.0
			if unit.get_damage_serial() > int(damage_memory[unit]):
				damage_memory[unit] = unit.get_damage_serial()
				retreat_until[unit] = _elapsed() + 5.0
				var away: Vector2 = (unit.global_position - armor.global_position).normalized()
				if away.length() < 0.1:
					away = Vector2.LEFT
				await _issue_order([unit], unit.global_position + away * 620.0, false)
				print("INTEGRATED_ARMOR_KITE_WITHDRAW unit=%s hp=%d armor_hp=%d" % [unit.display_name, unit.current_hp, armor.current_hp])
			elif float(retreat_until.get(unit, -1.0)) > 0.0 and _elapsed() >= float(retreat_until[unit]):
				var next_hit: int = armor.calculate_attack_damage(unit)
				if unit.current_hp > next_hit:
					retreat_until[unit] = -1.0
					await _issue_order([unit], armor.global_position + Vector2(420.0, 0.0), true)
		if _elapsed() - last_attack_order >= 5.0:
			var attackers: Array[BattleFormation] = []
			for unit: BattleFormation in _alive_combat_friendlies():
				if float(retreat_until.get(unit, -1.0)) < 0.0:
					attackers.append(unit)
			if not attackers.is_empty():
				await _issue_order(attackers, armor.global_position + Vector2(420.0, 0.0), true)
			last_attack_order = _elapsed()
	print("INTEGRATED_ARMOR_KITE_RESULT alive=%s hp=%d" % [armor.is_alive, armor.current_hp])


func _capture_objective(objective: BattleObjective, phase: String, timeout: float) -> void:
	if _war_flow.is_match_finished() or objective.get_control_owner() == BattleObjective.OWNER_PLAYER and not objective.is_contested():
		return
	var capture_units: Array[BattleFormation] = _alive_capture_friendlies()
	if capture_units.is_empty():
		return
	await _issue_order(capture_units, objective.global_position, false)
	var started: float = _elapsed()
	var last_reissue: float = started
	while not _war_flow.is_match_finished() and _elapsed() - started < timeout:
		await process_frame
		_observe_frame()
		if objective.get_control_owner() == BattleObjective.OWNER_PLAYER and not objective.is_contested():
			print("INTEGRATED_%s_CAPTURE_COMPLETE t=%.2f" % [phase, _elapsed()])
			return
		if objective.is_contested() and _elapsed() - last_reissue >= 5.0:
			await _issue_order(_alive_combat_friendlies(), objective.global_position + Vector2(420.0, 0.0), true)
			last_reissue = _elapsed()
	print("INTEGRATED_%s_CAPTURE_TIMEOUT owner=%s contested=%s progress=%.3f" % [phase, objective.get_control_owner(), objective.is_contested(), objective.progress])


func _commit_reserve(kind: String) -> void:
	var before: Dictionary = _war_flow.get_reserve_status()
	_require(bool(before.get("unlocked", false)) and bool(before.get("deployable", false)), "INTEGRATED_RESERVE_UNLOCK_PASS")
	var hud: BattleHUD = _battle.get_node("HUD") as BattleHUD
	var button: Button = hud._reserve_inf_button if kind == "INFANTRY" else hud._reserve_armor_button
	await _click_button(button)
	for _frame: int in range(3):
		await process_frame
	var after: Dictionary = _war_flow.get_reserve_status()
	if bool(after.get("committed", false)) and str(after.get("choice", "")) == kind:
		_count("orders_reserve")
		_current["reserve_use"] = _elapsed()
	else:
		_fail("RESERVE_%s_REAL_BUTTON_COMMIT_FAILED" % kind)


func _counterattack_and_resupply(run_index: int) -> void:
	await _wait_sim_seconds(2.0)
	# The first player capture activates the frozen RED reinforcement response.
	if _ai._reinforcements_active:
		_current["counterattack_pressure"] = true
		if float(_current["counterattack"]) < 0.0:
			_current["counterattack"] = _elapsed()
	var depleted: BattleFormation = _most_depleted_combat()
	if depleted != null and _supply.is_alive and _supply.get_supply_charges() > 0:
		if run_index == 0:
			await _resupply_interrupt_then_complete(depleted)
		else:
			await _resupply_complete(depleted)
	# Fight the actual reinforcement counterattack around Central.
	for target: Vector2 in [Vector2(2020.0, 900.0), Vector2(1280.0, 900.0), Vector2(2180.0, 1040.0)]:
		if _war_flow.is_match_finished():
			return
		await _issue_order(_alive_combat_friendlies(), target, true)
		await _wait_sim_seconds(13.0)
		if _active_red_combat_alive_count() == 0:
			break


func _resupply_interrupt_then_complete(target: BattleFormation) -> void:
	var charges_before: int = _supply.get_supply_charges()
	await _select_units([target])
	await _key_tap(KEY_F)
	_count("orders_resupply")
	if await _wait_for_resupply_phase("TRANSFERRING", 45.0):
		await _wait_sim_seconds(1.0)
		await _issue_order([target], target.global_position + Vector2(-240.0, 80.0), false)
		await _wait_sim_seconds(0.4)
		_current["blue_resupply_interrupt"] = not _resupply.is_resupply_active() and _supply.get_supply_charges() == charges_before
	if target.is_alive and target.current_ammo < target.ammo_capacity and _supply.get_supply_charges() > 0:
		await _resupply_complete(target)


func _resupply_complete(target: BattleFormation) -> void:
	if target == null or not target.is_alive or target.current_ammo >= target.ammo_capacity or not _supply.is_alive or _supply.get_supply_charges() <= 0:
		return
	var ammo_before: int = target.current_ammo
	var charges_before: int = _supply.get_supply_charges()
	await _select_units([target])
	await _key_tap(KEY_F)
	_count("orders_resupply")
	var started: bool = _resupply.is_resupply_active()
	var deadline: float = _elapsed() + 60.0
	while _resupply.is_resupply_active() and not _war_flow.is_match_finished() and _elapsed() < deadline:
		await process_frame
		_observe_frame()
	var expected_restore: int = maxi(1, int(round(float(target.ammo_capacity) * 0.5)))
	var expected_ammo: int = mini(target.ammo_capacity, ammo_before + expected_restore)
	var complete: bool = started and target.current_ammo == expected_ammo and _supply.get_supply_charges() == charges_before - 1
	_current["blue_resupply_complete"] = bool(_current["blue_resupply_complete"]) or complete
	print("INTEGRATED_RESUPPLY_OBSERVATION target=%s ammo=%d->%d expected=%d charges=%d->%d complete=%s" % [target.display_name, ammo_before, target.current_ammo, expected_ammo, charges_before, _supply.get_supply_charges(), complete])


func _fight_to_industrial(run_index: int) -> void:
	if _industrial.is_player_capture_locked():
		_fail("INDUSTRIAL_REMAINED_LOCKED_AFTER_CENTRAL")
		return
	var waypoints: Array[Vector2]
	if run_index == 2:
		waypoints = [Vector2(2200.0, 1400.0), Vector2(2520.0, 1240.0), Vector2(2960.0, 840.0), Vector2(2360.0, 840.0)]
	elif run_index == 1:
		waypoints = [Vector2(2200.0, 620.0), Vector2(2520.0, 700.0), Vector2(2960.0, 840.0), Vector2(2360.0, 840.0)]
	else:
		waypoints = [Vector2(2320.0, 900.0), Vector2(2960.0, 840.0), Vector2(2360.0, 840.0)]
	for target: Vector2 in waypoints:
		if _war_flow.is_match_finished():
			return
		await _issue_order(_alive_combat_friendlies(), target, true)
		if _supply.is_alive:
			await _issue_order([_supply], target + Vector2(-320.0, 220.0), false)
		await _wait_sim_seconds(15.0)


func _run_defeat_control() -> void:
	_current = _new_run_record(0)
	_current["label"] = "D"
	_current["plan"] = "DEFEAT_CONTROL"
	print("INTEGRATED_DEFEAT_CONTROL_BEGIN posture=%s" % _roster.get_selected_posture())
	await _verify_staging_and_fow()
	await _redeploy_all_blue()
	await _issue_order([_ifv], Vector2(2200.0, 900.0), false)
	await _issue_order([_infantry], Vector2(2200.0, 900.0), false)
	await _issue_order([_recon], Vector2(1040.0, 900.0), false)
	await _issue_order([_supply], Vector2(900.0, 1120.0), false)
	await _click_button(_find_button_by_text(_battle, "START BATTLE"))
	for _frame: int in range(4):
		await process_frame
	var deadline: float = _elapsed() + 180.0
	while not _war_flow.is_match_finished() and _elapsed() < deadline:
		await process_frame
		_observe_frame()
		# Reissue movement-only sacrificial orders if navigation completed before combat loss.
		if int(_elapsed()) % 12 == 0:
			for unit: BattleFormation in [_ifv, _infantry]:
				if unit.is_alive and unit.get_order() == "HOLD":
					await _issue_order([unit], Vector2(2400.0, 900.0), false)
	var defeated: bool = _war_flow.is_match_finished() and not _war_flow.is_victory()
	var hud: BattleHUD = _battle.get_node("HUD") as BattleHUD
	var defeat_hud: bool = hud.result_panel.visible and hud.result_title.text == "DEFEAT"
	var before_positions: Dictionary = _friendly_position_snapshot()
	await _issue_order([_recon], Vector2(400.0, 400.0), false, false)
	await _wait_sim_seconds(1.0)
	var commands_frozen: bool = before_positions == _friendly_position_snapshot()
	var restart_available: bool = hud.restart_button.visible and not hud.restart_button.disabled
	_require(defeated and defeat_hud and commands_frozen and restart_available, "INTEGRATED_NORMAL_DEFEAT_FLOW_PASS")
	_current["result"] = "DEFEAT" if defeated else "TIMEOUT"
	_current["total_duration"] = _elapsed()
	_runs.append(_current.duplicate(true))


func _restart_through_hud(expected_posture: String) -> bool:
	var previous: Node = _battle
	var restart: Button = _battle.get_node("HUD/Root/VictoryPanel/VBox/Restart") as Button
	await _click_button(restart)
	for _frame: int in range(120):
		await process_frame
		if current_scene != null and current_scene != previous:
			for _ready_frame: int in range(8):
				await process_frame
			return _bind_current_battle(expected_posture)
	_fail("REAL_RESTART_DID_NOT_RELOAD_SCENE")
	return false


func _finalize_run_record() -> void:
	_current["total_duration"] = _elapsed()
	_current["end_nodes"] = Performance.get_monitor(Performance.OBJECT_NODE_COUNT)
	_current["result"] = "VICTORY" if _war_flow.is_victory() else "DEFEAT" if _war_flow.is_match_finished() else "TIMEOUT"
	_current["recon_fire"] = _recon.get_fire_serial() - int(_current["recon_fire"])
	_current["infantry_fire"] = _infantry.get_fire_serial() - int(_current["infantry_fire"])
	_current["ifv_fire"] = _ifv.get_fire_serial() - int(_current["ifv_fire"])
	print("INTEGRATED_RUN_%s_RESULT=%s duration=%.2f nodes_start=%d nodes_end=%d" % [_current["label"], _current["result"], _current["total_duration"], int(_current["start_nodes"]), int(_current["end_nodes"])])
	print("INTEGRATED_RUN_%s_TIMING staging=%.2f first_contact=%.2f central_contest=%.2f central_capture=%.2f counterattack=%.2f reserve_use=%.2f industrial_contact=%.2f total=%.2f" % [_current["label"], float(_current["staging_duration"]), float(_current["first_contact"]), float(_current["central_contest"]), float(_current["central_capture"]), float(_current["counterattack"]), float(_current["reserve_use"]), float(_current["industrial_contact"]), float(_current["total_duration"])])
	print("INTEGRATED_RUN_%s_COMMANDS move=%d advance=%d hold_fire=%d weapons_free=%d resupply=%d withdraw=%d reserve=%d total=%d" % [_current["label"], int(_current["orders_move"]), int(_current["orders_advance"]), int(_current["orders_hold_fire"]), int(_current["orders_weapons_free"]), int(_current["orders_resupply"]), int(_current["orders_withdraw"]), int(_current["orders_reserve"]), int(_current["orders_move"]) + int(_current["orders_advance"]) + int(_current["orders_hold_fire"]) + int(_current["orders_weapons_free"]) + int(_current["orders_resupply"]) + int(_current["orders_withdraw"]) + int(_current["orders_reserve"])])
	print("INTEGRATED_RUN_%s_RUNTIME move_fire_delta=%d advance_fire_delta=%d recon_fire=%d infantry_fire=%d ifv_fire=%d red_supply_pressure=%s counterattack_pressure=%s fow_violation=%s softlock=%s" % [_current["label"], int(_current["move_fire_delta"]), int(_current["advance_fire_delta"]), int(_current["recon_fire"]), int(_current["infantry_fire"]), int(_current["ifv_fire"]), _current["red_supply_pressure"], _current["counterattack_pressure"], _fow_violation, _softlock_found])


func _observe_frame() -> void:
	if _battle == null or not is_instance_valid(_battle) or _staging == null:
		return
	var now: float = _elapsed()
	if now <= _last_sample_time + 0.20:
		return
	_last_sample_time = now
	for red: BattleFormation in _all_red_formations():
		var state: String = _intel.get_intel_state_for(red)
		if state == BattleIntelTracker.CONTACT:
			_current["intel_contact_seen"] = true
		elif state == BattleIntelTracker.CONFIRMED:
			_current["intel_confirmed_seen"] = true
		elif state == BattleIntelTracker.LAST_KNOWN:
			_current["intel_last_known_seen"] = true
		if state != BattleIntelTracker.UNSEEN and float(_current["first_contact"]) < 0.0:
			_current["first_contact"] = now
		if state == BattleIntelTracker.CONFIRMED and red.global_position.x > 2200.0 and float(_current["industrial_contact"]) < 0.0:
			_current["industrial_contact"] = now
	if _central.is_contested():
		_current["central_contested_seen"] = true
		if float(_current["central_contest"]) < 0.0:
			_current["central_contest"] = now
	if _central.get_control_owner() == BattleObjective.OWNER_PLAYER and float(_current["central_capture"]) < 0.0:
		_current["central_capture"] = now
	if _ai._reinforcements_active:
		if float(_current["counterattack"]) < 0.0:
			_current["counterattack"] = now
		for red: BattleFormation in _all_red_formations():
			if red.display_name.begins_with("RED REINFORCEMENT") and red.is_alive and red.get_order() != "HOLD":
				_current["counterattack_pressure"] = true
	var supply_agent: Dictionary = _ai._agents.get(_find_red_supply(), {})
	if not supply_agent.is_empty() and str(supply_agent.get("state", "")) == BattleEnemyAIController.EVADE:
		_current["red_supply_pressure"] = true
	_check_fow_presentation()
	_check_motion_watchdog(now)


func _check_fow_presentation() -> void:
	for red: BattleFormation in _all_red_formations():
		if _intel.get_intel_state_for(red) == BattleIntelTracker.UNSEEN:
			var proxy: Node3D = _presentation._proxies.get(red) as Node3D
			if proxy != null and proxy.visible:
				_fow_violation = true


func _check_motion_watchdog(now: float) -> void:
	for unit: BattleFormation in _all_formations():
		if not unit.is_alive or not unit.has_active_navigation_path():
			_last_positions.erase(unit)
			_last_motion_times.erase(unit)
			continue
		if not _last_positions.has(unit):
			_last_positions[unit] = unit.global_position
			_last_motion_times[unit] = now
			continue
		var prior: Vector2 = _last_positions[unit]
		if prior.distance_to(unit.global_position) > 1.0:
			_last_positions[unit] = unit.global_position
			_last_motion_times[unit] = now
		elif now - float(_last_motion_times.get(unit, now)) > 12.0:
			_softlock_found = true
			print("INTEGRATED_SOFTLOCK_CONTEXT unit=%s order=%s pos=%s path_points=%d" % [unit.display_name, unit.get_order(), unit.global_position, unit.get_navigation_path().size()])


func _wait_sim_seconds(seconds: float) -> void:
	var deadline: float = _elapsed() + seconds
	while not _war_flow.is_match_finished() and _elapsed() < deadline:
		await process_frame
		_observe_frame()


func _wait_until_match_finished(timeout: float) -> void:
	var deadline: float = _elapsed() + timeout
	while not _war_flow.is_match_finished() and _elapsed() < deadline:
		await process_frame
		_observe_frame()


func _wait_until_unit_settled(unit: BattleFormation, timeout: float) -> void:
	var deadline: float = _elapsed() + timeout
	while unit.is_alive and unit.has_active_navigation_path() and not _war_flow.is_match_finished() and _elapsed() < deadline:
		await process_frame
		_observe_frame()


func _wait_for_group_settle(units: Array[BattleFormation], timeout: float) -> void:
	var deadline: float = _elapsed() + timeout
	while not _war_flow.is_match_finished() and _elapsed() < deadline:
		var moving: bool = false
		for unit: BattleFormation in units:
			if unit != null and unit.is_alive and unit.has_active_navigation_path():
				moving = true
				break
		if not moving:
			return
		await process_frame
		_observe_frame()


func _wait_until_near(unit: BattleFormation, point: Vector2, radius: float, timeout: float) -> void:
	var deadline: float = _elapsed() + timeout
	while unit.is_alive and unit.global_position.distance_to(point) > radius and not _war_flow.is_match_finished() and _elapsed() < deadline:
		await process_frame
		_observe_frame()


func _wait_for_fire_delta(unit: BattleFormation, before: int, timeout: float) -> void:
	var deadline: float = _elapsed() + timeout
	while unit.is_alive and unit.get_fire_serial() == before and not _war_flow.is_match_finished() and _elapsed() < deadline:
		await process_frame
		_observe_frame()


func _wait_for_resupply_phase(phase: String, timeout: float) -> bool:
	var deadline: float = _elapsed() + timeout
	while _resupply.is_resupply_active() and _resupply.get_resupply_phase() != phase and not _war_flow.is_match_finished() and _elapsed() < deadline:
		await process_frame
		_observe_frame()
	return _resupply.is_resupply_active() and _resupply.get_resupply_phase() == phase


func _elapsed() -> float:
	return _staging.get_battle_elapsed_for_test() if _staging != null and is_instance_valid(_staging) else 0.0


func _issue_order(units: Array[BattleFormation], target: Vector2, advance: bool, count_command: bool = true) -> void:
	var eligible: Array[BattleFormation] = []
	for unit: BattleFormation in units:
		if unit != null and is_instance_valid(unit) and unit.is_alive and (not advance or not unit.is_supply_truck()):
			eligible.append(unit)
	if eligible.is_empty() or _war_flow.is_match_finished():
		return
	await _select_units(eligible)
	_camera.focus_on_sim(target)
	await process_frame
	var screen: Vector2 = _camera.unproject_position(Battle3DAdapter.sim_to_world(target, 0.0))
	await _mouse_click(screen, MOUSE_BUTTON_RIGHT, advance)
	if count_command:
		_count("orders_advance" if advance else "orders_move")


func _select_units(units: Array[BattleFormation]) -> void:
	var first: bool = true
	for unit: BattleFormation in units:
		if unit == null or not is_instance_valid(unit) or not unit.is_alive:
			continue
		_camera.focus_on_sim(unit.global_position)
		await process_frame
		var screen: Vector2 = _camera.unproject_position(_presentation.get_world_position_for(unit))
		if first:
			await _mouse_click(screen, MOUSE_BUTTON_LEFT, false)
			first = false
		else:
			await _key_down(KEY_SHIFT)
			await _mouse_click(screen, MOUSE_BUTTON_LEFT, true)
			await _key_up(KEY_SHIFT)


func _drag_formation(unit: BattleFormation, target: Vector2) -> void:
	_camera.focus_on_sim(unit.global_position)
	await process_frame
	var from_screen: Vector2 = _camera.unproject_position(_presentation.get_world_position_for(unit))
	_camera.focus_on_sim(target)
	await process_frame
	var to_screen: Vector2 = _camera.unproject_position(Battle3DAdapter.sim_to_world(target, 0.0))
	# Re-focus the source so the first press lands on the actual formation proxy.
	_camera.focus_on_sim(unit.global_position)
	await process_frame
	from_screen = _camera.unproject_position(_presentation.get_world_position_for(unit))
	# Convert the target while retaining this camera transform.
	to_screen = _camera.unproject_position(Battle3DAdapter.sim_to_world(target, 0.0))
	await _mouse_drag(from_screen, to_screen)


func _click_button(button: Button) -> void:
	if button == null:
		_fail("REQUIRED_BUTTON_MISSING")
		return
	await _mouse_click(button.get_global_rect().get_center(), MOUSE_BUTTON_LEFT, false)


func _mouse_click(viewport_position: Vector2, button_index: int, shift_pressed: bool) -> void:
	var input_position: Vector2 = root.get_screen_transform() * viewport_position
	var press := InputEventMouseButton.new()
	press.button_index = button_index
	press.pressed = true
	press.position = input_position
	press.global_position = input_position
	press.shift_pressed = shift_pressed
	Input.parse_input_event(press)
	await process_frame
	var release := InputEventMouseButton.new()
	release.button_index = button_index
	release.pressed = false
	release.position = input_position
	release.global_position = input_position
	release.shift_pressed = shift_pressed
	Input.parse_input_event(release)
	await process_frame


func _mouse_drag(from_viewport: Vector2, to_viewport: Vector2) -> void:
	var from_input: Vector2 = root.get_screen_transform() * from_viewport
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = from_input
	press.global_position = from_input
	Input.parse_input_event(press)
	await process_frame
	var previous: Vector2 = from_input
	for point: Vector2 in [from_viewport.lerp(to_viewport, 0.33), from_viewport.lerp(to_viewport, 0.66), to_viewport]:
		var input_point: Vector2 = root.get_screen_transform() * point
		var motion := InputEventMouseMotion.new()
		motion.position = input_point
		motion.global_position = input_point
		motion.relative = input_point - previous
		motion.button_mask = MOUSE_BUTTON_MASK_LEFT
		Input.parse_input_event(motion)
		previous = input_point
		await process_frame
	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.pressed = false
	release.position = previous
	release.global_position = previous
	Input.parse_input_event(release)
	await process_frame


func _key_tap(keycode: int) -> void:
	await _key_down(keycode)
	await _key_up(keycode)


func _key_down(keycode: int) -> void:
	var event := InputEventKey.new()
	event.keycode = keycode
	event.physical_keycode = keycode
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame


func _key_up(keycode: int) -> void:
	var event := InputEventKey.new()
	event.keycode = keycode
	event.physical_keycode = keycode
	event.pressed = false
	Input.parse_input_event(event)
	await process_frame


func _count(key: String) -> void:
	_current[key] = int(_current.get(key, 0)) + 1


func _alive_combat_friendlies() -> Array[BattleFormation]:
	var result: Array[BattleFormation] = []
	for unit: BattleFormation in _war_flow.get_friendlies():
		if unit != null and unit.is_alive and unit.can_attack:
			result.append(unit)
	return result


func _alive_capture_friendlies() -> Array[BattleFormation]:
	var result: Array[BattleFormation] = []
	for unit: BattleFormation in _war_flow.get_friendlies():
		if unit != null and unit.is_alive and unit.is_capture_capable():
			result.append(unit)
	return result


func _most_depleted_combat() -> BattleFormation:
	var best: BattleFormation
	var ratio: float = 1.0
	for unit: BattleFormation in _alive_combat_friendlies():
		if unit.ammo_capacity <= 0 or unit.current_ammo >= unit.ammo_capacity:
			continue
		var candidate_ratio: float = float(unit.current_ammo) / float(unit.ammo_capacity)
		if best == null or candidate_ratio < ratio:
			best = unit
			ratio = candidate_ratio
	return best


func _initial_red_combat_alive_count() -> int:
	var count: int = 0
	for unit: BattleFormation in _roster.get_initial_enemy_combat_formations():
		if unit.is_alive:
			count += 1
	return count


func _initial_red_infantry_alive_count() -> int:
	var count: int = 0
	for unit: BattleFormation in _roster.enemy_infantry:
		if unit.is_alive:
			count += 1
	return count


func _active_red_combat_alive_count() -> int:
	var count: int = 0
	for unit: BattleFormation in _all_red_formations():
		if unit.is_alive and unit.can_attack and unit.process_mode != Node.PROCESS_MODE_DISABLED:
			count += 1
	return count


func _find_red_supply() -> BattleFormation:
	for unit: BattleFormation in _all_red_formations():
		if unit.is_supply_truck():
			return unit
	return null


func _all_formations() -> Array[BattleFormation]:
	var result: Array[BattleFormation] = []
	_collect_formations(_battle, result, "")
	return result


func _all_red_formations() -> Array[BattleFormation]:
	var result: Array[BattleFormation] = []
	_collect_formations(_battle, result, "RED")
	return result


func _collect_formations(node: Node, result: Array[BattleFormation], faction_filter: String) -> void:
	if node is BattleFormation:
		var formation := node as BattleFormation
		if faction_filter.is_empty() or formation.faction == faction_filter:
			result.append(formation)
	for child: Node in node.get_children():
		_collect_formations(child, result, faction_filter)


func _find_minimap(node: Node) -> BattleMinimap:
	if node is BattleMinimap:
		return node as BattleMinimap
	for child: Node in node.get_children():
		var found: BattleMinimap = _find_minimap(child)
		if found != null:
			return found
	return null


func _find_button_by_text(node: Node, value: String) -> Button:
	if node is Button and (node as Button).text == value:
		return node as Button
	for child: Node in node.get_children():
		var found: Button = _find_button_by_text(child, value)
		if found != null:
			return found
	return null


func _visible_red_proxy_count() -> int:
	var count: int = 0
	for red: BattleFormation in _all_red_formations():
		var proxy: Node3D = _presentation._proxies.get(red) as Node3D
		if proxy != null and proxy.visible:
			count += 1
	return count


func _friendly_position_snapshot() -> Dictionary:
	var snapshot: Dictionary = {}
	for unit: BattleFormation in _war_flow.get_friendlies():
		if unit != null and is_instance_valid(unit):
			snapshot[unit.display_name] = unit.global_position
	return snapshot


func _path_length_for(unit: BattleFormation, target: Vector2) -> float:
	var nav: BattleNavigation = _battle.get_node("Navigation") as BattleNavigation
	return nav.get_path_length(nav.find_path_for_formation(unit, target))


func _formation_status(units: Array) -> String:
	var rows := PackedStringArray()
	for value: Variant in units:
		var unit := value as BattleFormation
		if unit != null:
			rows.append("%s:alive=%s,hp=%d,ammo=%d,fire=%d,pos=(%.0f,%.0f)" % [unit.display_name, unit.is_alive, unit.current_hp, unit.current_ammo, unit.get_fire_serial(), unit.global_position.x, unit.global_position.y])
	return " | ".join(rows)


func _emit_final_markers() -> void:
	for record: Dictionary in _runs:
		var label: String = str(record["label"])
		var total_commands: int = 0
		for key: String in ["orders_move", "orders_advance", "orders_hold_fire", "orders_weapons_free", "orders_resupply", "orders_withdraw", "orders_reserve"]:
			total_commands += int(record.get(key, 0))
		print("INTEGRATED_RUN_%s_SUMMARY result=%s posture=%s reserve=%s staging=%.2f first_contact=%.2f central_contest=%.2f central_capture=%.2f counterattack=%.2f reserve_use=%.2f industrial_contact=%.2f total=%.2f" % [label, record["result"], record["posture"], record["reserve"], float(record["staging_duration"]), float(record["first_contact"]), float(record["central_contest"]), float(record["central_capture"]), float(record["counterattack"]), float(record["reserve_use"]), float(record["industrial_contact"]), float(record["total_duration"])])
		print("INTEGRATED_RUN_%s_COMMANDS move=%d advance=%d hold_fire=%d weapons_free=%d resupply=%d withdraw=%d reserve=%d total=%d" % [label, int(record["orders_move"]), int(record["orders_advance"]), int(record["orders_hold_fire"]), int(record["orders_weapons_free"]), int(record["orders_resupply"]), int(record["orders_withdraw"]), int(record["orders_reserve"]), total_commands])
		print("INTEGRATED_RUN_%s_CONTRIBUTIONS recon_fire=%d infantry_fire=%d ifv_fire=%d supply_charges_used=%d red_supply_pressure=%s counterattack_pressure=%s" % [label, int(record["recon_fire"]), int(record["infantry_fire"]), int(record["ifv_fire"]), int(record["supply_start_charges"]) - (_supply.get_supply_charges() if label == "D" else 0), record["red_supply_pressure"], record["counterattack_pressure"]])
	var a: Dictionary = _runs[0] if _runs.size() > 0 else {}
	var b: Dictionary = _runs[1] if _runs.size() > 1 else {}
	var c: Dictionary = _runs[2] if _runs.size() > 2 else {}
	_require(not a.is_empty() and int(a.get("move_fire_delta", -1)) == 0 and int(a.get("advance_fire_delta", 0)) > 0, "INTEGRATED_MOVE_ADVANCE_DISTINCTION_PASS")
	_require(not b.is_empty() and float(b.get("hold_fire_move_distance", 0.0)) > 10.0 and int(b.get("hold_fire_fire_delta", -1)) == 0 and int(b.get("weapons_free_fire_delta", 0)) > 0, "INTEGRATED_HOLD_FIRE_TACTICAL_USE_PASS")
	var resupply_complete_count: int = 0
	for record: Dictionary in _runs:
		if bool(record.get("blue_resupply_complete", false)):
			resupply_complete_count += 1
	_require(resupply_complete_count >= 2, "INTEGRATED_BLUE_RESUPPLY_COMPLETE_PASS")
	_require(not a.is_empty() and bool(a.get("blue_resupply_interrupt", false)), "INTEGRATED_BLUE_RESUPPLY_INTERRUPT_PASS")
	var red_pressure: bool = false
	var counter_pressure: bool = false
	for record: Dictionary in _runs:
		red_pressure = red_pressure or bool(record.get("red_supply_pressure", false))
		counter_pressure = counter_pressure or bool(record.get("counterattack_pressure", false))
	_require(red_pressure, "INTEGRATED_RED_LOGISTICS_PLAYER_PRESSURE_PASS")
	_require(counter_pressure, "INTEGRATED_COUNTERATTACK_PLAYER_PRESSURE_PASS")
	_require(not _fow_violation, "INTEGRATED_FOW_NO_HIDDEN_RED_LEAK_PASS")
	_require(not _softlock_found, "INTEGRATED_SOFTLOCK_WATCHDOG_PASS")
	_require(not b.is_empty() and bool(b.get("north_foot_used", false)) and bool(b.get("vehicle_foot_link_rejected", false)), "INTEGRATED_NORTH_ROUTE_FORMATION_AWARE_PASS")
	_require(not c.is_empty() and bool(c.get("south_vehicle_stable", false)), "INTEGRATED_SOUTH_ROUTE_VEHICLE_STABILITY_PASS")
	_require(_runs.size() >= 3 and str(a.get("result", "")) == "VICTORY" and str(b.get("result", "")) == "VICTORY" and str(c.get("result", "")) == "VICTORY", "INTEGRATED_OBJECTIVE_PROGRESSION_PASS")
	print("INTEGRATED_RESERVE_UNLOCK_AND_COMMIT_PASS")


func _require(condition: bool, marker: String) -> void:
	if condition:
		print(marker)
	else:
		_fail(marker)


func _fail(marker: String) -> void:
	_failures.append(marker)
	push_error("INTEGRATED_EVIDENCE_FAILURE %s" % marker)


func _finish() -> void:
	if _failures.is_empty():
		print("FRONTLINE_INTEGRATED_PLAYER_FLOW_EVIDENCE_PASS")
		quit(0)
		return
	for failure: String in _failures:
		print("INTEGRATED_EVIDENCE_FAILED_MARKER=%s" % failure)
	print("FRONTLINE_INTEGRATED_PLAYER_FLOW_EVIDENCE_FAIL count=%d" % _failures.size())
	quit(1)
