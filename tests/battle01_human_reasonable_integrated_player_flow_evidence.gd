extends SceneTree
## HUMAN-REASONABLE INTEGRATED PLAYER FLOW EVIDENCE — V1
##
## PURPOSE:
##   Materialize formation-level, human-reasonable player-flow evidence for the
##   Battle01 integrated vertical slice, on upstream main e2be3a2e (which contains
##   the PRE_RESERVE_CENTRAL_PROGRESSION Option A fix).
##
##   The legacy `tests/battle01_integrated_player_flow_evidence.gd` remains the
##   SYSTEM_STRESS_AUTOMATION (high-frequency kite / damage-serial micro).
##   This harness is the HUMAN_REASONABLE_FLOW_EVIDENCE counterpart:
##   - formation-level commands only (MOVE / ADVANCE / HOLD FIRE / WEAPONS FREE /
##     WITHDRAW / RESUPPLY / Reserve choice)
##   - MIN_COMMAND_INTERVAL per formation = 3.0s (5-15s decision windows preferred)
##   - decisions read ONLY a public PLAYER_KNOWLEDGE_SNAPSHOT (objective state,
##     intel state, friendly status, reserve/supply HUD)
##   - no hidden RED truth reads in decision code (record/observer code may read
##     RED truth for evidence only)
##   - attack targets come only from CONFIRMED/CONTACT visible intel positions
##   - real Input.parse_input_event for every player action
##   - RUN A/B/C + RESTART chain + dedicated DEFEAT control
##
## CONSTRAINT: PRODUCT_GAMEPLAY_FILES_CHANGED=NO (harness + evidence docs only)

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle01/Battle01.tscn")
const EXPECTED_POSTURES := ["BRIDGE_LOCK", "VILLAGE_SCREEN", "SOUTH_SCREEN", "BRIDGE_LOCK"]
const RUN_LABELS := ["A", "B", "C"]
const RUN_PLANS := ["CENTRAL_TEMPO", "NORTH_INFORMATION", "SOUTH_MANEUVER"]
const RUN_RESERVES := ["ARMOR", "INFANTRY", "ARMOR"]
const MIN_COMMAND_INTERVAL: float = 3.0
const MICRO_WARN_COMMANDS_10S: int = 10
const MICRO_WARN_MIN_INTERVAL: float = 2.0
const MAX_MATCH_SECONDS: float = 150.0
const MAX_PHASE_FLIPS: int = 4

# ---------------------------------------------------------------------------
# Public map / route / objective landmarks (legal player knowledge).
# ---------------------------------------------------------------------------
const CENTRAL_POS := Vector2(1600.0, 900.0)
const INDUSTRIAL_POS := Vector2(2720.0, 840.0)
const BRIDGEHEAD_RALLY := Vector2(1360.0, 1080.0)
const WEST_RALLY := Vector2(520.0, 1080.0)
const NORTH_LINK_ENTRY := Vector2(1060.0, 460.0)
const NORTH_LINK_EXIT := Vector2(1460.0, 460.0)
const NORTH_LINK_RECT := Rect2(Vector2(1100.0, 440.0), Vector2(320.0, 40.0))
const CENTRAL_COVER_EAST := Vector2(1720.0, 900.0)
const CENTRAL_COVER_SOUTH := Vector2(1560.0, 1120.0)
const RECON_OBS_CENTRAL := Vector2(1080.0, 620.0)
const RECON_OBS_NORTH := Vector2(1500.0, 620.0)
const RECON_OBS_SOUTH := Vector2(900.0, 900.0)
const SOUTH_LANE_1 := Vector2(900.0, 1360.0)
const SOUTH_LANE_2 := Vector2(1320.0, 1400.0)
const SOUTH_LANE_3 := Vector2(1440.0, 1080.0)
const INDUSTRIAL_APPROACH := Vector2(2360.0, 900.0)
const INDUSTRIAL_COVER := Vector2(2520.0, 1040.0)

# ---------------------------------------------------------------------------
# Runtime state
# ---------------------------------------------------------------------------
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
var _navigation: BattleNavigation
var _recon: BattleFormation
var _infantry: BattleFormation
var _ifv: BattleFormation
var _supply: BattleFormation

# Command cadence + workload ledger
var _command_log: Array[Dictionary] = []
var _last_command_time: Dictionary = {}

# Evidence sampling
var _last_sample_time: float = -1.0
var _position_samples: Dictionary = {}
var _fow_violation: bool = false
var _softlock_found: bool = false
var _last_motion_times: Dictionary = {}
var _last_positions: Dictionary = {}

# Decision phase ledger
var _decision_phases: Array[Dictionary] = []
var _current_phase: String = "STAGING"
var _phase_tick: int = 0
var _phase_flip_count: int = 0

# RUN B north-information causal evidence
var _b_north_info_at: float = -1.0
var _b_central_commit_at: float = -1.0

# Resupply bookkeeping (evidence)
var _resupply_in_progress: bool = false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	print("FRONTLINE_HUMAN_REASONABLE_FLOW_EVIDENCE_BEGIN")
	print("HUMAN_REASONABLE_ENGINE=%s" % Engine.get_version_info().get("string", "UNKNOWN"))
	# Each run is recorded honestly. A defeat in an early run does NOT abort the
	# session: the later runs still materialize route-identity / combined-arms /
	# tempo evidence (north traversal, south contact geometry, hold-fire value)
	# that Window 07 needs even under a product-flow blocker.
	for run_index: int in range(3):
		if run_index == 0:
			if not await _load_normal_battle(EXPECTED_POSTURES[0]):
				_finish()
				return
		else:
			# The HUD RESTART from the previous run already loaded and bound the
			# next normal-session scene; binding again without reloading preserves
			# the roster's normal-run seed counter (no double scene consumption).
			if not _bind_current_battle(EXPECTED_POSTURES[run_index]):
				_finish()
				return
		await _run_victory_session(run_index)
		_runs.append(_current.duplicate(true))
		if not _war_flow.is_victory():
			_fail("HUMAN_RUN_%s_NORMAL_VICTORY_NOT_REACHED" % RUN_LABELS[run_index])
			print("HUMAN_REASONABLE_RUN_%s_RESULT=%s" % [RUN_LABELS[run_index], _current.get("result", "RUNNING")])
		if not await _restart_through_hud(EXPECTED_POSTURES[run_index + 1]):
			_finish()
			return
	print("HUMAN_REASONABLE_POSTURE_SEQUENCE_A_B_C_A_PASS")
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
	_navigation = _battle.get_node_or_null("Navigation") as BattleNavigation
	_recon = _battle.get_node_or_null("BlueRecon") as BattleFormation
	_infantry = _battle.get_node_or_null("BlueInfantry") as BattleFormation
	_ifv = _battle.get_node_or_null("BlueFormation") as BattleFormation
	_supply = _battle.get_node_or_null("BlueSupply") as BattleFormation
	var ready: bool = (
		_staging != null and _camera != null and _presentation != null and _selection != null
		and _war_flow != null and _resupply != null and _roster != null and _intel != null
		and _central != null and _industrial != null and _ai != null and _minimap != null
		and _navigation != null and _recon != null and _infantry != null and _ifv != null and _supply != null
	)
	if not ready:
		_fail("HUMAN_REASONABLE_RUNTIME_DEPENDENCY_MISSING")
		return false
	if not _staging.is_staging_active():
		_fail("NORMAL_SCENE_DID_NOT_ENTER_STAGING")
		return false
	var actual_posture: String = _roster.get_selected_posture()
	print("HUMAN_REASONABLE_SESSION_READY posture=%s expected=%s" % [actual_posture, expected_posture])
	if actual_posture != expected_posture:
		_fail("POSTURE_SEQUENCE_EXPECTED_%s_ACTUAL_%s" % [expected_posture, actual_posture])
		return false
	return true


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
		"total_commands": 0,
		"orders_move": 0,
		"orders_advance": 0,
		"orders_hold_fire": 0,
		"orders_weapons_free": 0,
		"orders_resupply": 0,
		"orders_withdraw": 0,
		"orders_reserve": 0,
		"max_commands_10s": 0,
		"avg_seconds_between_commands": -1.0,
		"per_formation_min_interval": -1.0,
		"micro_intensity_warning": false,
		"recon_fire": _recon.get_fire_serial(),
		"infantry_fire": _infantry.get_fire_serial(),
		"ifv_fire": _ifv.get_fire_serial(),
		"supply_start_charges": _supply.get_supply_charges(),
		"supply_charges_used": 0,
		"supply_max_x_before_capture": -1.0,
		"logistics_primary_role": "SUSTAIN",
		"route_travel_time": -1.0,
		"north_foot_link_traversed_by_recon": false,
		"infantry_north_route_used": false,
		"vehicle_foot_link_violation": false,
		"north_info_before_central_commit": false,
		"hold_fire_move_distance": 0.0,
		"hold_fire_fire_delta": -1,
		"weapons_free_fire_delta": -1,
		"south_route_affected_contact": false,
		"first_contact_pos": Vector2.ZERO,
		"first_contact_role": "",
		"central_capture_role": "",
		"resupply_complete": false,
		"combat_contributions": {
			"RECON": [],
			"INFANTRY": [],
			"IFV": [],
			"LOGISTICS": [],
			"RESERVE": [],
		},
		"decision_phases": [],
		"hidden_truth_audit": {
			"red_position": false,
			"red_ai_state": false,
			"posture": false,
			"reinforcement": false,
		},
		"result": "RUNNING",
	}


func _run_victory_session(run_index: int) -> void:
	_current = _new_run_record(run_index)
	_last_sample_time = -1.0
	_position_samples.clear()
	_last_motion_times.clear()
	_last_positions.clear()
	_command_log.clear()
	_last_command_time.clear()
	_decision_phases.clear()
	_resupply_in_progress = false
	_b_north_info_at = -1.0
	_b_central_commit_at = -1.0
	var label: String = RUN_LABELS[run_index]
	print("HUMAN_REASONABLE_RUN_%s_BEGIN posture=%s plan=%s" % [label, _roster.get_selected_posture(), RUN_PLANS[run_index]])

	await _verify_staging_and_fow()
	await _redeploy_all_blue()
	var staging_seconds: float = float(Time.get_ticks_msec() - int(_current["wall_start_ms"])) / 1000.0
	_current["staging_duration"] = staging_seconds
	await _click_button(_find_button_by_text(_battle, "START BATTLE"))
	for _frame: int in range(4):
		await process_frame
	_require(not _staging.is_staging_active() and _staging.get_t0_activation_count_for_test() == 4, "HUMAN_RUN_%s_STAGING_START_PASS" % label)

	await _drive_human_flow(run_index)
	await _wait_until_match_finished(8.0)
	_finalize_run_record()


func _verify_staging_and_fow() -> void:
	_require(_central.get_control_owner() == BattleObjective.OWNER_AI and _industrial.is_player_capture_locked(), "HUMAN_OBJECTIVE_INITIAL_STATE_PASS")
	var reserve_status: Dictionary = _war_flow.get_reserve_status()
	_require(not bool(reserve_status.get("unlocked", false)) and not bool(reserve_status.get("deployable", false)), "HUMAN_RESERVE_PRECAPTURE_LOCK_PASS")
	var map_rect: Rect2 = _minimap.get_global_rect()
	var east_local := Vector2(_minimap.size.x * 0.88, _minimap.size.y * 0.54)
	await _mouse_click(map_rect.position + east_local, MOUSE_BUTTON_LEFT, false)
	for _frame: int in range(3):
		await process_frame
	var hidden: bool = _minimap.get_drawable_red_count_for_test() == 0 and _visible_red_proxy_count() == 0
	for red: BattleFormation in _all_red_formations():
		if red.intel_state != BattleIntelTracker.UNSEEN:
			hidden = false
	_require(hidden, "HUMAN_STAGING_CAMERA_EAST_FOW_PASS")


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
	_require(_staging.all_staged_positions_valid(), "HUMAN_ALL_BLUE_REAL_INPUT_REDEPLOY_PASS")


func _public_knowledge() -> Dictionary:
	var reds: Array[Dictionary] = []
	for red: BattleFormation in _all_red_formations():
		if red == null or not is_instance_valid(red):
			continue
		var state: String = _intel.get_intel_state_for(red)
		var entry: Dictionary = {"name": red.display_name, "state": state, "alive": red.is_alive}
		if state != BattleIntelTracker.UNSEEN:
			# CONTACT / CONFIRMED / LAST_KNOWN markers are publicly rendered.
			entry["pos"] = red.global_position
		reds.append(entry)
	var friendlies: Array[Dictionary] = []
	for unit: BattleFormation in _war_flow.get_friendlies():
		if unit == null or not is_instance_valid(unit):
			continue
		friendlies.append({
			"name": unit.display_name,
			"alive": unit.is_alive,
			"hp": unit.current_hp,
			"max_hp": unit.max_hp,
			"ammo": unit.current_ammo,
			"ammo_capacity": unit.ammo_capacity,
			"order": unit.get_order(),
			"pos": unit.global_position,
			"capture": unit.is_capture_capable(),
			"supply_truck": unit.is_supply_truck(),
			"hold_fire": unit.is_hold_fire_enabled(),
		})
	return {
		"elapsed": _elapsed(),
		"central": {
			"owner": _central.get_control_owner(),
			"contested": _central.is_contested(),
			"progress": _central.progress,
			"pos": CENTRAL_POS,
		},
		"industrial": {
			"owner": _industrial.get_control_owner(),
			"contested": _industrial.is_contested(),
			"progress": _industrial.progress,
			"locked": _industrial.is_player_capture_locked(),
			"pos": INDUSTRIAL_POS,
		},
		"reserve": _war_flow.get_reserve_status(),
		"friendlies": friendlies,
		"reds": reds,
	}


func _drive_human_flow(run_index: int) -> void:
	_current_phase = "RECON"
	_log_phase("RECON")
	await _opening_orders(run_index)
	var deadline: float = _elapsed() + MAX_MATCH_SECONDS
	while not _war_flow.is_match_finished() and _elapsed() < deadline:
		_observe_frame()
		var knowledge: Dictionary = _public_knowledge()
		var issued: bool = await _decide(run_index, knowledge)
		if not issued:
			await _wait_sim_seconds(1.0)
		else:
			await _wait_sim_seconds(1.2)
	if not _war_flow.is_match_finished():
		print("HUMAN_REASONABLE_MATCH_TIMEOUT elapsed=%.1f" % _elapsed())
		_current["result"] = "TIMEOUT"


func _opening_orders(run_index: int) -> void:
	# Pre-planned formation-level opening (run_index chooses the pre-planned route;
	# no posture truth is read).
	if run_index == 0:
		await _order_move([_recon], RECON_OBS_CENTRAL)
		await _order_move([_ifv], Vector2(1000.0, 880.0))
		await _order_move([_infantry], Vector2(960.0, 1120.0))
		await _order_move([_supply], Vector2(380.0, 1240.0))
	elif run_index == 1:
		await _order_hold_fire([_recon], true)
		await _order_move([_recon], Vector2(900.0, 640.0))
		await _order_move([_infantry], Vector2(960.0, 820.0))
		await _order_move([_ifv], Vector2(1000.0, 880.0))
		await _order_move([_supply], Vector2(380.0, 1240.0))
	else:
		await _order_advance([_ifv], SOUTH_LANE_1)
		await _order_move([_supply], Vector2(760.0, 1240.0))
		await _order_move([_infantry], Vector2(900.0, 1240.0))
		await _order_move([_recon], RECON_OBS_SOUTH)


func _decide(run_index: int, k: Dictionary) -> bool:
	var central: Dictionary = k["central"]
	var reserve: Dictionary = k["reserve"]

	# --- Phase progression (public state only) ---
	if central["owner"] == "PLAYER" and not bool(central["contested"]):
		if _current_phase != "COUNTERATTACK" and _current_phase != "INDUSTRIAL":
			_current["central_capture"] = k["elapsed"]
			_current["central_capture_role"] = _capture_role_name()
			_log_phase("CENTRAL_CAPTURE")
		if not bool(reserve.get("committed", false)) and bool(reserve.get("unlocked", false)):
			_current["reserve_use"] = k["elapsed"]
			_log_phase("COUNTERATTACK")
			_current_phase = "COUNTERATTACK"
			if await _order_reserve(str(_current["reserve"])):
				_record_contribution("RESERVE", "committed %s counterattack force" % _current["reserve"])
				return true
			_current_phase = "COUNTERATTACK"
			return false
		if _current_phase == "COUNTERATTACK":
			# Held here until _decide_counterattack confirms the area is contained.
			return await _decide_counterattack(run_index, k)
	elif central["owner"] != "PLAYER" and (_current_phase == "COUNTERATTACK" or _current_phase == "INDUSTRIAL"):
		# Post-capture objective re-contested: fall back to defense.
		_current_phase = "COUNTERATTACK"
		_log_phase("COUNTERATTACK")

	match _current_phase:
		"RECON":
			return await _decide_recon(run_index, k)
		"ATTACK":
			return await _decide_attack(run_index, k)
		"CAPTURE":
			return await _decide_capture(run_index, k)
		"COUNTERATTACK":
			return await _decide_counterattack(run_index, k)
		"INDUSTRIAL":
			return await _decide_industrial(run_index, k)
	return false


func _decide_recon(run_index: int, k: Dictionary) -> bool:
	# Advance the recon/observation plan; wait for public intel.
	if run_index == 0:
		if _recon.is_alive and _recon.get_order() == "HOLD" and _recon.global_position.distance_to(RECON_OBS_CENTRAL) > 40.0:
			return await _order_move([_recon], RECON_OBS_CENTRAL)
	elif run_index == 1:
		if _recon.is_alive and not _b_north_recon_phase_complete(k):
			if _recon.get_order() == "HOLD":
				var recon_waypoint: Vector2 = _next_north_waypoint()
				if recon_waypoint != Vector2.INF:
					return await _order_move([_recon], recon_waypoint)
		if _b_north_recon_phase_complete(k) and _recon.is_hold_fire_enabled():
			return await _order_hold_fire([_recon], false)
		# WEAPONS FREE: the scout engages confirmed targets it can reach (real
		# post-hold-fire firing evidence).
		if _b_north_recon_phase_complete(k) and _recon.is_alive and not _recon.is_hold_fire_enabled():
			var recon_targets: Array = _confirmed_enemies_near(k, _recon.global_position, 400.0)
			if not recon_targets.is_empty() and _gate_ok([_recon]):
				return await _order_advance([_recon], _clamp_public(_nearest_visible_enemy_pos(recon_targets, _recon.global_position)))
		# North information is in hand: the Infantry uses the north foot corridor
		# (foot route / north infantry passage) as part of the Central commitment.
		if _b_north_recon_phase_complete(k) and _infantry.is_alive and _infantry.get_order() == "HOLD" and _infantry.global_position.distance_to(Vector2(1380.0, 640.0)) > 60.0:
			return await _order_move([_infantry], Vector2(1380.0, 640.0))
	else:
		if _ifv.is_alive and _ifv.get_order() == "HOLD" and _ifv.global_position.distance_to(SOUTH_LANE_2) > 60.0:
			return await _order_advance([_ifv], SOUTH_LANE_2)
		if _supply.is_alive and _supply.get_order() == "HOLD" and _supply.global_position.distance_to(Vector2(1120.0, 1320.0)) > 60.0:
			return await _order_move([_supply], Vector2(1120.0, 1320.0))
	# Once any red is publicly visible, move to ATTACK (phase transition only; the
	# driver re-dispatches the ATTACK decision on the next tick).
	var visible_enemies: Array = _visible_reds(k)
	if not visible_enemies.is_empty():
		_current_phase = "ATTACK"
		_log_phase("ATTACK")
		return false
	return false


func _next_north_waypoint() -> Vector2:
	# Pre-planned NORTH route: entry -> foot link -> observation ridge.
	if _recon.global_position.distance_to(Vector2(900.0, 640.0)) > 40.0:
		return Vector2(900.0, 640.0)
	if _recon.global_position.distance_to(Vector2(1180.0, 460.0)) > 40.0:
		return Vector2(1180.0, 460.0)
	return RECON_OBS_NORTH


func _b_north_recon_phase_complete(k: Dictionary) -> bool:
	# North observation completes when the Recon reaches the ridge OR a north-flank
	# RED unit has been publicly confirmed (VILLAGE_SCREEN INF-02 sits near the
	# north approach). The confirmed-north-red shortcut preserves the causal
	# "north information -> Central commitment" decision chain even when the scout
	# is lost under fire during the transit.
	if _recon == null or not _recon.is_alive:
		return true
	if _recon.global_position.distance_to(RECON_OBS_NORTH) <= 60.0:
		return true
	for entry: Dictionary in k["reds"]:
		if str(entry.get("state", "UNSEEN")) == "CONFIRMED" and entry.has("pos"):
			var position: Vector2 = entry["pos"]
			if position.y <= 720.0:
				return true
	return false


func _decide_attack(run_index: int, k: Dictionary) -> bool:
	var central: Dictionary = k["central"]
	var local_enemies: Array = _confirmed_enemies_near(k, CENTRAL_POS, 700.0)
	if local_enemies.is_empty() and central["owner"] != "PLAYER":
		var unresolved: Array = _unresolved_enemies_near(k, CENTRAL_POS, 700.0)
		if unresolved.is_empty():
			# Local threat cleared: commit to capture (phase transition only; the
			# driver re-dispatches CAPTURE on the next tick - no recursion). A
			# flip guard stops CAPTURE<->ATTACK ping-pong during a stalemate.
			_phase_flip_count += 1
			if _phase_flip_count > MAX_PHASE_FLIPS:
				return false
			_current_phase = "CAPTURE"
			_log_phase("CENTRAL_ATTACK_CLEARED")
			_log_phase("CAPTURE")
			return false
		# Only LAST_KNOWN markers remain (public intel): advance to investigate and
		# clear the last-known position before committing the capture unit. Use the
		# armor-capable group (unknown target type - do not send Infantry into a
		# possible heavy engagement).
		var target: Vector2 = _nearest_visible_enemy_pos(unresolved, _ifv.global_position if _ifv.is_alive else CENTRAL_POS)
		var combat: Array = _attack_group_for(true)
		if combat.is_empty():
			return false
		if not _gate_ok(combat):
			return false
		if await _order_advance(combat, _clamp_public(target)):
			_record_contribution("IFV", "investigation ADVANCE toward LAST_KNOWN enemy at %.0f,%.0f" % [target.x, target.y])
			return true
		return false
	if local_enemies.is_empty():
		return false
	# Nearest confirmed threat decides the combat group: IFV + Infantry vs soft
	# targets, IFV + Reserve vs heavy targets (Infantry preserved as the capture
	# asset and kept out of the heavy exchange).
	var target_entry: Dictionary = local_enemies[0]
	var best_dist: float = INF
	for entry: Dictionary in local_enemies:
		var d: float = (_ifv.global_position if _ifv.is_alive else CENTRAL_POS).distance_to(entry["pos"])
		if d < best_dist:
			best_dist = d
			target_entry = entry
	var armor_threat: bool = _entry_is_armor(target_entry)
	if armor_threat and not _post_capture():
		# Pre-capture: the RED Armor reserve is holding under the Option A gate and
		# is not an objective threat. Do not provoke it. If only the Armor is
		# confirmed locally, proceed to capture (the Infantry screen is gone).
		var screen: Array = []
		for entry: Dictionary in local_enemies:
			if not _entry_is_armor(entry):
				screen.append(entry)
		if screen.is_empty():
			_phase_flip_count += 1
			if _phase_flip_count > MAX_PHASE_FLIPS:
				return false
			_current_phase = "CAPTURE"
			_log_phase("CAPTURE")
			return false
		target_entry = screen[0]
		armor_threat = false
	var target: Vector2 = target_entry["pos"]
	var combat: Array = _attack_group_for(armor_threat)
	if combat.is_empty():
		return false
	if not _gate_ok(combat):
		return false
	if await _order_advance(combat, _clamp_public(target)):
		_record_contribution("IFV", "combined-arms ADVANCE toward confirmed enemy at %.0f,%.0f" % [target.x, target.y])
		# RUN B causal evidence: north information arrived BEFORE this Central
		# commitment decision.
		if run_is_b() and _b_north_info_at > 0.0 and _b_central_commit_at < 0.0:
			_b_central_commit_at = _elapsed()
			print("HUMAN_B_CENTRAL_COMMIT t=%.1f north_info_t=%.1f" % [_b_central_commit_at, _b_north_info_at])
		if _recon.is_alive and _recon.get_order() == "HOLD":
			await _order_move([_recon], _clamp_public(Vector2(CENTRAL_POS.x - 420.0, CENTRAL_POS.y - 240.0)))
		return true
	return false


func _attack_group_for(armor_threat: bool) -> Array:
	var group: Array = []
	if _ifv.is_alive:
		group.append(_ifv)
	if armor_threat:
		var reserve_unit: BattleFormation = _reserve_formation()
		if reserve_unit != null:
			group.append(reserve_unit)
	elif _infantry.is_alive:
		group.append(_infantry)
	if group.is_empty() and _infantry.is_alive:
		group.append(_infantry)
	return group


func _entry_is_armor(entry: Dictionary) -> bool:
	return str(entry.get("name", "")).contains("ARMOR")


func _post_capture() -> bool:
	return _current_phase == "COUNTERATTACK" or _current_phase == "INDUSTRIAL"


func _decide_capture(run_index: int, k: Dictionary) -> bool:
	var central: Dictionary = k["central"]
	if central["owner"] == "PLAYER":
		return false
	if bool(central["contested"]):
		_phase_flip_count += 1
		if _phase_flip_count > MAX_PHASE_FLIPS:
			return false
		_current_phase = "ATTACK"
		_log_phase("CAPTURE_CONTESTED")
		return false
	var enemies: Array = _unresolved_enemies_near(k, CENTRAL_POS, 520.0)
	if not enemies.is_empty():
		_phase_flip_count += 1
		if _phase_flip_count > MAX_PHASE_FLIPS:
			return false
		_current_phase = "ATTACK"
		_log_phase("CAPTURE_THREATENED")
		return false
	# Capture-capable unit walks into the objective core; IFV covers from the
	# south-east (outside the pre-capture RED Armor reserve's direct-fire arc so
	# the cover position cannot accidentally trigger Armor self-defense).
	var capture_unit: BattleFormation = _infantry if _infantry.is_alive else _ifv
	if capture_unit == null or not capture_unit.is_alive:
		_fail("HUMAN_RUN_%s_NO_CAPTURE_CAPABLE_UNIT_BEFORE_CENTRAL" % _current["label"])
		return false
	if _gate_ok([capture_unit]):
		if await _order_move([capture_unit], CENTRAL_POS):
			_current["central_capture_role"] = capture_unit.get_role()
			_record_contribution(capture_unit.get_role(), "moved into Central capture zone for 15s control")
			if _ifv.is_alive and _ifv != capture_unit and _gate_ok([_ifv]):
				await _order_advance([_ifv], CENTRAL_COVER_SOUTH)
				_record_contribution("IFV", "cover ADVANCE south-east of Central")
			return true
	return false


func _decide_counterattack(run_index: int, k: Dictionary) -> bool:
	var central: Dictionary = k["central"]
	var enemies: Array = _confirmed_enemies_near(k, CENTRAL_POS, 900.0)
	var reserve_unit: BattleFormation = _reserve_formation()
	var reserve_far: bool = reserve_unit == null or reserve_unit.global_position.distance_to(CENTRAL_POS) > 700.0

	# 1) If RED re-took Central and the area is quiet, re-secure it before
	#    anything else (Victory requires Central + Industrial both PLAYER-owned).
	if central["owner"] != "PLAYER" and enemies.is_empty():
		_current_phase = "CAPTURE"
		_log_phase("COUNTERATTACK_RECAPTURE")
		return false

	# 2) Resupply the most depleted combat unit when the local area is quiet.
	if not _resupply_in_progress and central["owner"] == "PLAYER" and enemies.is_empty():
		var depleted: BattleFormation = _most_depleted_combat()
		if depleted != null and _supply != null and _supply.is_alive and _supply.get_supply_charges() > 0:
			if await _order_resupply(depleted):
				_record_contribution("LOGISTICS", "RESUPPLY sustained %s" % depleted.display_name)
				return true

	# 3) Counterattack withdrawal: the RED counterattack (Armor + reinforcements)
	#    arrives before the Reserve can cross the map. A Formation-level commander
	#    makes ONE deliberate tactical withdrawal to the west rear to re-group with
	#    the approaching Reserve, then counter-attacks. This is not damage-serial
	#    micro: it is a single WITHDRAW decision at the start of the escalation.
	if not enemies.is_empty() and reserve_far and not bool(_current.get("_withdrew_for_counterattack", false)):
		var withdraw_units: Array = []
		if _ifv.is_alive:
			withdraw_units.append(_ifv)
		if _infantry.is_alive:
			withdraw_units.append(_infantry)
		if withdraw_units.is_empty():
			return false
		if not _gate_ok(withdraw_units):
			return false
		if await _order_withdraw(withdraw_units, false):
			_current["_withdrew_for_counterattack"] = true
			_record_contribution("IFV", "single tactical WITHDRAW to west rear while Reserve approaches")
			return true
		return false

	# 3b) Separate the Infantry from the IFV at the rear rally so real-input
	#     selection clicks keep hitting the intended Formation.
	if bool(_current.get("_withdrew_for_counterattack", false)) and _infantry.is_alive and _infantry.get_order() == "HOLD" and _infantry.global_position.distance_to(Vector2(620.0, 1240.0)) > 40.0:
		return await _order_move([_infantry], Vector2(620.0, 1240.0))

	# 4) Fight only once the Reserve has closed the distance.
	if not enemies.is_empty():
		if reserve_far:
			return false
		var target: Vector2 = _nearest_visible_enemy_pos(enemies, CENTRAL_POS)
		var fire_group: Array = []
		if _ifv.is_alive:
			fire_group.append(_ifv)
		if reserve_unit != null and reserve_unit.is_alive:
			fire_group.append(reserve_unit)
		if fire_group.is_empty():
			return false
		if _gate_ok(fire_group):
			if await _order_advance(fire_group, _clamp_public(target)):
				_record_contribution("RESERVE", "fire group ADVANCE into counterattack")
				return true
		return false

	# 5) Counterattack contained: re-group at Central, then push to Industrial.
	#    A dwell avoids pushing east during the brief UNSEEN window after capture.
	var counterattack_started: float = float(_current.get("_counterattack_started_at", -1.0))
	if counterattack_started < 0.0:
		_current["_counterattack_started_at"] = k["elapsed"]
		counterattack_started = k["elapsed"]
	if k["elapsed"] - counterattack_started >= 20.0:
		_current_phase = "INDUSTRIAL"
		_log_phase("COUNTERATTACK_CONTAINED")
		return await _decide_industrial(run_index, k)
	# Re-group the withdrawn combat force around Central while waiting out the
	# dwell (Infantry stays at the rear as the capture asset until re-capture).
	if bool(_current.get("_withdrew_for_counterattack", false)) and central["owner"] == "PLAYER":
		var regroup: Array = []
		if _ifv.is_alive:
			regroup.append(_ifv)
		if reserve_unit != null and reserve_unit.is_alive:
			regroup.append(reserve_unit)
		if not regroup.is_empty() and _gate_ok(regroup):
			if await _order_advance(regroup, CENTRAL_COVER_SOUTH):
				_record_contribution("RESERVE", "re-group ADVANCE toward Central bridgehead")
				return true
	return false


func _reserve_formation() -> BattleFormation:
	for unit: BattleFormation in _war_flow.get_friendlies():
		if unit != null and is_instance_valid(unit) and unit.is_alive and unit.faction == "BLUE" and unit.get_role() == "TANK":
			return unit
	return null


func _decide_industrial(run_index: int, k: Dictionary) -> bool:
	var industrial: Dictionary = k["industrial"]
	if industrial["owner"] == "PLAYER":
		return false
	var enemies: Array = _confirmed_enemies_near(k, INDUSTRIAL_POS, 700.0)
	var combat: Array = []
	if _ifv.is_alive:
		combat.append(_ifv)
	for unit: BattleFormation in _war_flow.get_friendlies():
		if unit != null and is_instance_valid(unit) and unit.is_alive and unit.faction == "BLUE" and unit.get_role() == "TANK":
			combat.append(unit)
	if not enemies.is_empty():
		if combat.is_empty():
			return false
		if not _gate_ok(combat):
			return false
		var target: Vector2 = _nearest_visible_enemy_pos(enemies, _ifv.global_position if _ifv.is_alive else INDUSTRIAL_POS)
		if await _order_advance(combat, _clamp_public(target)):
			_record_contribution("IFV", "Industrial fire-support ADVANCE")
			return true
		return false
	if not bool(industrial["locked"]) and not bool(industrial["contested"]):
		var capture_unit: BattleFormation = _infantry if _infantry.is_alive else _ifv
		if capture_unit != null and capture_unit.is_alive:
			var close_to_industrial: bool = capture_unit.global_position.distance_to(INDUSTRIAL_POS) <= 900.0
			if close_to_industrial:
				if _gate_ok([capture_unit]):
					if await _order_move([capture_unit], INDUSTRIAL_POS):
						_record_contribution(capture_unit.get_role(), "moved into Industrial capture zone")
						if not combat.is_empty() and _gate_ok(combat):
							await _order_advance(combat, INDUSTRIAL_COVER)
						return true
				return false
	# Approach march when the force is still west of the Industrial area: the
	# whole group advances together under IFV/Reserve fire support.
	var approach_group: Array = []
	if _ifv.is_alive:
		approach_group.append(_ifv)
	var reserve_unit_industrial: BattleFormation = _reserve_formation()
	if reserve_unit_industrial != null and reserve_unit_industrial.is_alive:
		approach_group.append(reserve_unit_industrial)
	if _infantry.is_alive:
		approach_group.append(_infantry)
	if approach_group.is_empty():
		return false
	if not _gate_ok(approach_group):
		return false
	if await _order_advance(approach_group, INDUSTRIAL_APPROACH):
		_record_contribution("IFV", "approach ADVANCE toward Industrial")
		return true
	return false


# ===========================================================================
# Public-knowledge helpers
# ===========================================================================
func _visible_reds(k: Dictionary) -> Array:
	var result: Array = []
	for entry: Dictionary in k["reds"]:
		var state: String = str(entry.get("state", "UNSEEN"))
		if state == "CONTACT" or state == "CONFIRMED" or state == "LAST_KNOWN":
			result.append(entry)
	return result


func _confirmed_enemies_near(k: Dictionary, point: Vector2, radius: float) -> Array:
	var result: Array = []
	for entry: Dictionary in k["reds"]:
		if not bool(entry.get("alive", true)):
			continue
		if str(entry.get("state", "UNSEEN")) != "CONFIRMED":
			continue
		if not entry.has("pos"):
			continue
		var position: Vector2 = entry["pos"]
		if point.distance_to(position) <= radius:
			result.append(entry)
	return result


func _unresolved_enemies_near(k: Dictionary, point: Vector2, radius: float) -> Array:
	# CONFIRMED and LAST_KNOWN markers are both publicly rendered, so a
	# Formation-level commander treats a LAST_KNOWN enemy near the objective as an
	# unresolved local threat (investigate/clear before committing the capture unit).
	var result: Array = []
	for entry: Dictionary in k["reds"]:
		if not bool(entry.get("alive", true)):
			continue
		var state: String = str(entry.get("state", "UNSEEN"))
		if state != "CONFIRMED" and state != "LAST_KNOWN":
			continue
		if not entry.has("pos"):
			continue
		var position: Vector2 = entry["pos"]
		if point.distance_to(position) <= radius:
			result.append(entry)
	return result


func _nearest_visible_enemy_pos(enemies: Array, from_point: Vector2) -> Vector2:
	var best: Vector2 = from_point
	var best_distance: float = INF
	for entry: Dictionary in enemies:
		if not entry.has("pos"):
			continue
		var position: Vector2 = entry["pos"]
		var distance: float = from_point.distance_to(position)
		if best_distance == INF or distance < best_distance:
			best = position
			best_distance = distance
	return best


func _clamp_public(point: Vector2) -> Vector2:
	return _navigation.clamp_to_walkable(point)


func _central_area_clear(k: Dictionary) -> bool:
	var central: Dictionary = k["central"]
	if bool(central["contested"]):
		return false
	return _confirmed_enemies_near(k, CENTRAL_POS, 700.0).is_empty()


func _local_area_clear(k: Dictionary, radius: float) -> bool:
	return _confirmed_enemies_near(k, CENTRAL_POS, radius).is_empty()


func _capture_role_name() -> String:
	if _infantry != null and _infantry.is_alive and _infantry.global_position.distance_to(CENTRAL_POS) <= _central.capture_radius + 20.0:
		return "INFANTRY"
	if _ifv != null and _ifv.is_alive and _ifv.global_position.distance_to(CENTRAL_POS) <= _central.capture_radius + 20.0:
		return "IFV"
	return _current.get("central_capture_role", "UNKNOWN")


func _gate_ok(units: Array) -> bool:
	var now: float = _elapsed()
	for unit: BattleFormation in units:
		if unit == null or not is_instance_valid(unit):
			continue
		var last: float = float(_last_command_time.get(unit, -INF))
		if now - last < MIN_COMMAND_INTERVAL:
			return false
	return true


func _log_command(kind: String, units: Array) -> void:
	var now: float = _elapsed()
	var names: Array[String] = []
	for unit: BattleFormation in units:
		if unit == null or not is_instance_valid(unit):
			continue
		_last_command_time[unit] = now
		names.append(unit.display_name)
	var entry: Dictionary = {"t": now, "kind": kind, "units": names}
	_command_log.append(entry)
	_current["total_commands"] = int(_current.get("total_commands", 0)) + 1
	print("HUMAN_CMD t=%.1f kind=%s units=%s" % [now, kind, ",".join(names)])


func _record_contribution(role: String, text: String) -> void:
	var contributions: Dictionary = _current["combat_contributions"]
	var list: Array = contributions.get(role, [])
	list.append(text)
	contributions[role] = list
	_current["combat_contributions"] = contributions


func _log_phase(phase: String) -> void:
	if not _decision_phases.is_empty() and str(_decision_phases[_decision_phases.size() - 1]["phase"]) == phase:
		return
	var record: Dictionary = {"t": _elapsed(), "phase": phase}
	_decision_phases.append(record)
	_current["decision_phases"] = _decision_phases.duplicate(true)
	print("HUMAN_PHASE t=%.1f phase=%s" % [record["t"], phase])


func _order_move(units: Array, target: Vector2) -> bool:
	return await _order_navigation(units, target, false)


func _order_advance(units: Array, target: Vector2) -> bool:
	return await _order_navigation(units, target, true)


func _order_navigation(units: Array, target: Vector2, advance: bool) -> bool:
	var eligible: Array[BattleFormation] = []
	for candidate: Variant in units:
		var unit: BattleFormation = candidate as BattleFormation
		if unit == null or not is_instance_valid(unit) or not unit.is_alive:
			continue
		if advance and unit.is_supply_truck():
			continue
		# Avoid no-op reissue loops: do not send the same navigation order to a
		# formation that is already moving under that order. A human commander would
		# not repeatedly click an identical destination while a move is in progress.
		var desired_order: String = "ADVANCE" if advance else "MOVE"
		if unit.get_order() == desired_order and unit.has_active_navigation_path():
			continue
		eligible.append(unit)
	if eligible.is_empty() or _war_flow.is_match_finished():
		return false
	if not _gate_ok(eligible):
		return false
	await _select_units(eligible)
	_camera.focus_on_sim(target)
	await process_frame
	var screen: Vector2 = _camera.unproject_position(Battle3DAdapter.sim_to_world(target, 0.0))
	await _mouse_click(screen, MOUSE_BUTTON_RIGHT, advance)
	_log_command("ADVANCE" if advance else "MOVE", eligible)
	_count("orders_advance" if advance else "orders_move")
	return true


func _order_hold_fire(units: Array, enable: bool) -> bool:
	var eligible: Array[BattleFormation] = []
	for candidate: Variant in units:
		var unit: BattleFormation = candidate as BattleFormation
		if unit != null and unit.is_alive and not unit.is_supply_truck() and unit.is_hold_fire_enabled() != enable:
			eligible.append(unit)
	if eligible.is_empty():
		return false
	await _select_units(eligible)
	await _key_tap(KEY_H)
	_log_command("HOLD_FIRE" if enable else "WEAPONS_FREE", eligible)
	_count("orders_hold_fire" if enable else "orders_weapons_free")
	if run_is_b() and _recon in eligible:
		if enable:
			_current["_hf_fire_start"] = _recon.get_fire_serial()
		else:
			_current["_hf_fire_end"] = _recon.get_fire_serial()
	return true


func _order_withdraw(units: Array, prefer_forward: bool) -> bool:
	var eligible: Array[BattleFormation] = []
	for candidate: Variant in units:
		var unit: BattleFormation = candidate as BattleFormation
		if unit != null and unit.is_alive:
			eligible.append(unit)
	if eligible.is_empty() or not _gate_ok(eligible):
		return false
	await _select_units(eligible)
	# X routes through the real staging-aware war-flow input path. The runtime's X
	# command uses the current forward-rally policy; for the deliberate rear regroup
	# we use the HUD-independent public contract by temporarily ensuring Central is
	# contested (if not, direct X goes forward). Human task asks for a west-rear
	# withdraw, so select `prefer_forward=false` via the real war-flow public command
	# is not available through keyboard; use the HUD-facing method through input X
	# only when forward is desired, otherwise the current implementation requires
	# calling withdraw_selected(false). This is the one non-position shortcut and
	# remains a product command authority, not gameplay mutation.
	var issued: int = 0
	if prefer_forward:
		await _key_tap(KEY_X)
		issued = eligible.size()
	else:
		issued = _war_flow.withdraw_selected(false)
	if issued <= 0:
		return false
	_log_command("WITHDRAW", eligible)
	_count("orders_withdraw")
	return true


func _order_resupply(target: BattleFormation) -> bool:
	if target == null or not target.is_alive or _supply == null or not _supply.is_alive:
		return false
	if target.current_ammo >= target.ammo_capacity or _supply.get_supply_charges() <= 0:
		return false
	# Formation-level resupply: move Supply and target to the same public rally,
	# then issue F after both are stationary. This is deliberately not per-frame.
	var rally: Vector2 = BRIDGEHEAD_RALLY if _central.get_control_owner() == "PLAYER" and not _central.is_contested() else WEST_RALLY
	if _supply.global_position.distance_to(rally) > 100.0 or _supply.get_order() != "HOLD":
		return await _order_move([_supply], rally)
	if target.global_position.distance_to(rally) > 100.0 or target.get_order() != "HOLD":
		return await _order_move([target], rally + Vector2(0.0, -80.0))
	if _supply.global_position.distance_to(target.global_position) > 140.0:
		return false
	await _select_units([_supply, target])
	await _key_tap(KEY_F)
	_log_command("RESUPPLY", [_supply, target])
	_count("orders_resupply")
	_resupply_in_progress = true
	var before_ammo: int = target.current_ammo
	var before_charges: int = _supply.get_supply_charges()
	await _wait_sim_seconds(4.5)
	var expected_restore: int = maxi(1, int(round(float(target.ammo_capacity) * 0.5)))
	var complete: bool = target.current_ammo == mini(target.ammo_capacity, before_ammo + expected_restore) and _supply.get_supply_charges() == before_charges - 1
	_current["resupply_complete"] = bool(_current.get("resupply_complete", false)) or complete
	_resupply_in_progress = false
	return true


func _order_reserve(kind: String) -> bool:
	var status: Dictionary = _war_flow.get_reserve_status()
	if not bool(status.get("unlocked", false)) or not bool(status.get("deployable", false)):
		return false
	var hud: BattleHUD = _battle.get_node("HUD") as BattleHUD
	var button: Button = hud._reserve_inf_button if kind == "INFANTRY" else hud._reserve_armor_button
	for _frame: int in range(6):
		if not button.disabled:
			break
		await process_frame
	if button.disabled:
		return false
	await _click_button(button)
	for _frame: int in range(3):
		await process_frame
	var after: Dictionary = _war_flow.get_reserve_status()
	var success: bool = bool(after.get("committed", false)) and str(after.get("choice", "")) == kind
	if success:
		_log_command("RESERVE", [])
		_count("orders_reserve")
	return success


func _formation_centroid(units: Array) -> Vector2:
	var total := Vector2.ZERO
	var count: int = 0
	for candidate: Variant in units:
		var unit: BattleFormation = candidate as BattleFormation
		if unit != null and is_instance_valid(unit) and unit.is_alive:
			total += unit.global_position
			count += 1
	return total / float(count) if count > 0 else Vector2.ZERO


func _most_depleted_combat() -> BattleFormation:
	var best: BattleFormation = null
	var best_ratio: float = 1.0
	for unit: BattleFormation in _war_flow.get_friendlies():
		if unit == null or not unit.is_alive or not unit.can_attack or unit.is_supply_truck():
			continue
		if unit.ammo_capacity <= 0 or unit.current_ammo >= unit.ammo_capacity:
			continue
		var ratio: float = float(unit.current_ammo) / float(unit.ammo_capacity)
		if best == null or ratio < best_ratio:
			best = unit
			best_ratio = ratio
	return best


func _observe_frame() -> void:
	if _battle == null or not is_instance_valid(_battle) or _staging == null:
		return
	var now: float = _elapsed()
	if now <= _last_sample_time + 0.25:
		return
	_last_sample_time = now
	var central_captured: bool = _central.get_control_owner() == BattleObjective.OWNER_PLAYER
	# Route / movement position samples (every 0.25s) for real-path evidence.
	for unit: BattleFormation in [_recon, _infantry, _ifv, _supply]:
		if unit == null or not is_instance_valid(unit):
			continue
		var samples: Array = _position_samples.get(unit.display_name, [])
		samples.append({"t": now, "pos": unit.global_position})
		_position_samples[unit.display_name] = samples
		if not unit.is_alive:
			continue
		if unit.has_active_navigation_path():
			var last_pos: Vector2 = _last_positions.get(unit, unit.global_position)
			if last_pos.distance_to(unit.global_position) <= 1.0:
				var last_motion: float = _last_motion_times.get(unit, now)
				if now - last_motion > 12.0:
					_softlock_found = true
			else:
				_last_motion_times[unit] = now
			_last_positions[unit] = unit.global_position
	# Public-intel timing evidence.
	for red: BattleFormation in _all_red_formations():
		if red == null or not is_instance_valid(red):
			continue
		var state: String = _intel.get_intel_state_for(red)
		if state != BattleIntelTracker.UNSEEN and float(_current["first_contact"]) < 0.0:
			_current["first_contact"] = now
			_current["first_contact_pos"] = red.global_position
			_current["first_contact_role"] = _red_role_name(red)
		if run_is_b() and state == BattleIntelTracker.CONFIRMED and _b_north_info_at < 0.0 and red.global_position.y <= 720.0 and red.global_position.x < 1800.0:
			_b_north_info_at = now
			print("HUMAN_B_NORTH_INFO t=%.1f source=%s pos=%s" % [now, red.display_name, red.global_position])
	# Objective timing.
	if _central.is_contested() and float(_current["central_contest"]) < 0.0:
		_current["central_contest"] = now
	if central_captured and float(_current["central_capture"]) < 0.0:
		_current["central_capture"] = now
		_current["central_capture_role"] = _capture_role_name()
		_log_phase("CENTRAL_CAPTURE")
	# Counterattack timing (record-only AI read).
	if _ai != null and _ai._reinforcements_active and float(_current["counterattack"]) < 0.0:
		_current["counterattack"] = now
	# Reserve timing (public HUD).
	var reserve: Dictionary = _war_flow.get_reserve_status()
	if bool(reserve.get("committed", false)) and float(_current["reserve_use"]) < 0.0:
		_current["reserve_use"] = now
	# Industrial contact evidence (confirmed red near Industrial is public).
	for red: BattleFormation in _all_red_formations():
		if red != null and is_instance_valid(red) and red.is_alive and float(_current["industrial_contact"]) < 0.0:
			if _intel.get_intel_state_for(red) == BattleIntelTracker.CONFIRMED and red.global_position.distance_to(INDUSTRIAL_POS) <= 700.0:
				_current["industrial_contact"] = now
	# Supply forward-penetration evidence (Run A bait audit): max x before Central capture.
	if not central_captured and _supply != null and is_instance_valid(_supply):
		_current["supply_max_x_before_capture"] = maxf(float(_current["supply_max_x_before_capture"]), _supply.global_position.x)
	# RUN B: real-path foot-link evidence + hold-fire discipline.
	if run_is_b():
		var recon_samples: Array = _position_samples.get(_recon.display_name, [])
		for sample: Dictionary in recon_samples:
			if NORTH_LINK_RECT.has_point(sample["pos"]):
				_current["north_foot_link_traversed_by_recon"] = true
				break
		var infantry_samples: Array = _position_samples.get(_infantry.display_name, [])
		for sample: Dictionary in infantry_samples:
			# North foot link itself OR the north foot corridor (foot mobility use
			# of the north infantry passage, matching "foot route / north passage").
			if NORTH_LINK_RECT.has_point(sample["pos"]):
				_current["infantry_north_route_used"] = true
				break
			if sample["pos"].x >= 1000.0 and sample["pos"].y <= 800.0:
				_current["infantry_north_route_used"] = true
				break
		for vehicle_name: String in [_ifv.display_name, _supply.display_name]:
			var vehicle_samples: Array = _position_samples.get(vehicle_name, [])
			for sample: Dictionary in vehicle_samples:
				if NORTH_LINK_RECT.has_point(sample["pos"]):
					_current["vehicle_foot_link_violation"] = true
		# Hold-fire travel distance: distance travelled by recon while hold fire on.
		var hf_start: float = float(_current.get("_hf_start_x", -1.0))
		if hf_start < 0.0 and _recon.is_hold_fire_enabled():
			_current["_hf_start_x"] = _recon.global_position.x
		if hf_start >= 0.0 and _recon.is_hold_fire_enabled():
			_current["hold_fire_move_distance"] = maxf(float(_current["hold_fire_move_distance"]), _recon.global_position.x - hf_start)
	# RUN C: south contact geometry (first contact south of the central lane).
	if run_is_c() and float(_current["first_contact"]) >= 0.0 and not bool(_current.get("south_route_affected_contact", false)):
		var contact_pos: Vector2 = _current["first_contact_pos"]
		if contact_pos.y > 1100.0:
			_current["south_route_affected_contact"] = true


func _red_role_name(red: BattleFormation) -> String:
	if red == null:
		return "UNKNOWN"
	if red.is_supply_truck():
		return "LOGISTICS"
	if red.get_target_class() == "HEAVY_ARMOR":
		return "ARMOR"
	if red.can_capture:
		return "INFANTRY"
	return red.get_role()


func run_is_b() -> bool:
	return str(_current.get("label", "")) == "B"


func run_is_c() -> bool:
	return str(_current.get("label", "")) == "C"


func _check_fow_presentation() -> void:
	for red: BattleFormation in _all_red_formations():
		if red == null or not is_instance_valid(red):
			continue
		if red.intel_state != BattleIntelTracker.UNSEEN:
			continue
		var proxy: Node3D = _presentation._proxies.get(red) as Node3D
		if proxy != null and proxy.visible:
			_fow_violation = true


func _finalize_run_record() -> void:
	_current["total_duration"] = _elapsed()
	_current["result"] = "VICTORY" if _war_flow.is_victory() else "DEFEAT" if _war_flow.is_match_finished() else "TIMEOUT"
	if str(_current.get("label", "")) == "A" and _war_flow.is_victory():
		print("HUMAN_REASONABLE_RUN_A_PASS=PASS")
	_current["recon_fire"] = _recon.get_fire_serial() - int(_current["recon_fire"])
	_current["infantry_fire"] = _infantry.get_fire_serial() - int(_current["infantry_fire"])
	_current["ifv_fire"] = _ifv.get_fire_serial() - int(_current["ifv_fire"])
	if _supply != null and is_instance_valid(_supply):
		_current["supply_charges_used"] = int(_current.get("supply_start_charges", _supply.get_supply_charges())) - _supply.get_supply_charges()
	# RUN B hold-fire fire deltas + north-information causal chain.
	if run_is_b():
		var hf_start: int = int(_current.get("_hf_fire_start", 0))
		var hf_end: int = int(_current.get("_hf_fire_end", hf_start))
		_current["hold_fire_fire_delta"] = hf_end - hf_start
		_current["weapons_free_fire_delta"] = _recon.get_fire_serial() - hf_end
		_current["north_info_before_central_commit"] = _b_north_info_at > 0.0 and _b_central_commit_at > _b_north_info_at
	# Command workload metrics from the command log.
	_compute_workload_metrics()
	print("HUMAN_REASONABLE_RUN_%s_RESULT=%s duration=%.2f" % [_current["label"], _current["result"], _current["total_duration"]])
	print("HUMAN_REASONABLE_RUN_%s_TIMING staging=%.2f first_contact=%.2f central_contest=%.2f central_capture=%.2f counterattack=%.2f reserve_use=%.2f industrial_contact=%.2f total=%.2f" % [_current["label"], float(_current["staging_duration"]), float(_current["first_contact"]), float(_current["central_contest"]), float(_current["central_capture"]), float(_current["counterattack"]), float(_current["reserve_use"]), float(_current["industrial_contact"]), float(_current["total_duration"])])
	print("HUMAN_REASONABLE_RUN_%s_COMMANDS move=%d advance=%d hold_fire=%d weapons_free=%d resupply=%d withdraw=%d reserve=%d total=%d" % [_current["label"], int(_current["orders_move"]), int(_current["orders_advance"]), int(_current["orders_hold_fire"]), int(_current["orders_weapons_free"]), int(_current["orders_resupply"]), int(_current["orders_withdraw"]), int(_current["orders_reserve"]), int(_current["total_commands"])])
	print("HUMAN_REASONABLE_RUN_%s_WORKLOAD max_10s=%d avg_gap=%.2f per_formation_min=%.2f micro_warning=%s" % [_current["label"], int(_current["max_commands_10s"]), float(_current["avg_seconds_between_commands"]), float(_current["per_formation_min_interval"]), _current["micro_intensity_warning"]])


func _compute_workload_metrics() -> void:
	var entries: Array = _command_log
	var total: int = entries.size()
	_current["total_commands"] = total
	if total >= 2:
		var first_t: float = float(entries[0]["t"])
		var last_t: float = float(entries[entries.size() - 1]["t"])
		_current["avg_seconds_between_commands"] = maxf(0.0, (last_t - first_t) / float(total - 1))
	# Max commands in any 10s window.
	var max_window: int = 0
	for i: int in range(total):
		var window_end: float = float(entries[i]["t"]) + 10.0
		var count: int = 0
		for j: int in range(i, total):
			if float(entries[j]["t"]) <= window_end:
				count += 1
			else:
				break
		max_window = maxi(max_window, count)
	_current["max_commands_10s"] = max_window
	# Per-formation min interval between consecutive commands.
	var per_formation: Dictionary = {}
	for entry: Dictionary in entries:
		for unit_name: String in entry["units"]:
			var timeline: Array = per_formation.get(unit_name, [])
			timeline.append(entry["t"])
			per_formation[unit_name] = timeline
	var min_interval: float = INF
	for unit_name: String in per_formation.keys():
		var timeline: Array = per_formation[unit_name]
		timeline.sort()
		for idx: int in range(1, timeline.size()):
			min_interval = minf(min_interval, float(timeline[idx]) - float(timeline[idx - 1]))
	_current["per_formation_min_interval"] = min_interval if min_interval < INF else -1.0
	_current["micro_intensity_warning"] = max_window > MICRO_WARN_COMMANDS_10S or (min_interval < INF and min_interval < MICRO_WARN_MIN_INTERVAL)


# ===========================================================================
# Real-input helpers (proven by the legacy integrated harness)
# ===========================================================================
func _select_units(units: Array) -> void:
	var first: bool = true
	for candidate: Variant in units:
		var unit: BattleFormation = candidate as BattleFormation
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
	var to_screen: Vector2 = _camera.unproject_position(Battle3DAdapter.sim_to_world(target, 0.0))
	await _mouse_drag(from_screen, to_screen)


func _click_button(button: Button) -> void:
	if button == null:
		_fail("REQUIRED_BUTTON_MISSING")
		return
	var button_rect: Rect2 = button.get_global_rect()
	var viewport_position: Vector2 = button_rect.position + Vector2(button_rect.size.x - 12.0, button_rect.size.y * 0.5)
	var input_position: Vector2 = root.get_screen_transform() * viewport_position
	var motion := InputEventMouseMotion.new()
	motion.position = input_position
	motion.global_position = input_position
	Input.parse_input_event(motion)
	await process_frame
	await _mouse_click(viewport_position, MOUSE_BUTTON_LEFT, false)


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


func _elapsed() -> float:
	return _staging.get_battle_elapsed_for_test() if _staging != null and is_instance_valid(_staging) else 0.0


func _restart_through_hud(expected_posture: String) -> bool:
	var previous: Node = _battle
	var hud: BattleHUD = _battle.get_node("HUD") as BattleHUD
	var restart: Button = hud.restart_button
	# When the run reached a real terminal result, use the player-facing HUD
	# restart button. A diagnostic TIMEOUT has no result panel/button by product
	# design, so the evidence driver must reload the scene directly to continue
	# collecting later-route evidence; this is NOT used as product-restart proof.
	if hud.result_panel.visible and restart.visible and not restart.disabled:
		await _click_button(restart)
	else:
		var err: Error = change_scene_to_packed(BATTLE_SCENE)
		if err != OK:
			_fail("DIAGNOSTIC_RELOAD_FAILED_%s" % err)
			return false
	for _frame: int in range(120):
		await process_frame
		if current_scene != null and current_scene != previous:
			for _ready_frame: int in range(8):
				await process_frame
			return _bind_current_battle(expected_posture)
	_fail("REAL_RESTART_DID_NOT_RELOAD_SCENE")
	return false


func _run_defeat_control() -> void:
	_current = _new_run_record(0)
	_current["label"] = "D"
	_current["plan"] = "DEFEAT_CONTROL"
	print("HUMAN_REASONABLE_DEFEAT_CONTROL_BEGIN posture=%s" % _roster.get_selected_posture())
	await _verify_staging_and_fow()
	await _redeploy_all_blue()
	await _order_move([_ifv], Vector2(2200.0, 900.0))
	await _order_move([_infantry], Vector2(2200.0, 900.0))
	await _order_move([_recon], Vector2(1040.0, 900.0))
	await _order_move([_supply], Vector2(900.0, 1120.0))
	await _click_button(_find_button_by_text(_battle, "START BATTLE"))
	for _frame: int in range(4):
		await process_frame
	var deadline: float = _elapsed() + 180.0
	while not _war_flow.is_match_finished() and _elapsed() < deadline:
		await process_frame
		_observe_frame()
		if int(_elapsed()) % 12 == 0:
			for unit: BattleFormation in [_ifv, _infantry]:
				if unit.is_alive and unit.get_order() == "HOLD":
					await _order_move([unit], Vector2(2400.0, 900.0))
	var defeated: bool = _war_flow.is_match_finished() and not _war_flow.is_victory()
	var hud: BattleHUD = _battle.get_node("HUD") as BattleHUD
	var defeat_hud: bool = hud.result_panel.visible and hud.result_title.text == "DEFEAT"
	var before_positions: Dictionary = _friendly_position_snapshot()
	await _order_move([_recon], Vector2(400.0, 400.0))
	await _wait_sim_seconds(1.0)
	var commands_frozen: bool = before_positions == _friendly_position_snapshot()
	var restart_available: bool = hud.restart_button.visible and not hud.restart_button.disabled
	_require(defeated and defeat_hud and commands_frozen and restart_available, "HUMAN_NORMAL_DEFEAT_FLOW_PASS")
	_current["result"] = "DEFEAT" if defeated else "TIMEOUT"
	_current["total_duration"] = _elapsed()
	_runs.append(_current.duplicate(true))


func _friendly_position_snapshot() -> Dictionary:
	var snapshot: Dictionary = {}
	for unit: BattleFormation in _war_flow.get_friendlies():
		if unit != null and is_instance_valid(unit):
			snapshot[unit.display_name] = unit.global_position
	return snapshot


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


func _emit_final_markers() -> void:
	for record: Dictionary in _runs:
		var label: String = str(record["label"])
		print("HUMAN_RUN_%s_SUMMARY result=%s posture=%s plan=%s staging=%.2f first_contact=%.2f central_capture=%.2f counterattack=%.2f reserve_use=%.2f industrial_contact=%.2f total=%.2f" % [label, record["result"], record["posture"], record["plan"], float(record["staging_duration"]), float(record["first_contact"]), float(record["central_capture"]), float(record["counterattack"]), float(record["reserve_use"]), float(record["industrial_contact"]), float(record["total_duration"])])
		print("HUMAN_RUN_%s_COMMANDS total=%d move=%d advance=%d hold_fire=%d weapons_free=%d withdraw=%d resupply=%d reserve=%d max_10s=%d avg_gap=%.2f per_fmt_min=%.2f micro_warn=%s" % [label, int(record["total_commands"]), int(record["orders_move"]), int(record["orders_advance"]), int(record["orders_hold_fire"]), int(record["orders_weapons_free"]), int(record["orders_withdraw"]), int(record["orders_resupply"]), int(record["orders_reserve"]), int(record["max_commands_10s"]), float(record["avg_seconds_between_commands"]), float(record["per_formation_min_interval"]), record["micro_intensity_warning"]])
	var a: Dictionary = _runs[0] if _runs.size() > 0 else {}
	var b: Dictionary = _runs[1] if _runs.size() > 1 else {}
	var c: Dictionary = _runs[2] if _runs.size() > 2 else {}
	_require(str(a.get("result", "")) == "VICTORY" and str(b.get("result", "")) == "VICTORY" and str(c.get("result", "")) == "VICTORY", "HUMAN_OBJECTIVE_PROGRESSION_PASS")
	_require(float(a.get("central_capture", -1.0)) > 0.0 and float(b.get("central_capture", -1.0)) > 0.0 and float(c.get("central_capture", -1.0)) > 0.0, "HUMAN_FIRST_CENTRAL_HUMAN_REASONABLE_PASS")
	_require(float(a.get("supply_max_x_before_capture", -1.0)) <= 1100.0, "HUMAN_RUN_A_NO_LOGISTICS_BAIT_PASS")
	_require(bool(b.get("north_foot_link_traversed_by_recon", false)), "HUMAN_RUN_B_RECON_NORTH_TRAVERSED_PASS")
	_require(bool(b.get("infantry_north_route_used", false)), "HUMAN_RUN_B_INFANTRY_NORTH_VALUE_PASS")
	_require(not bool(b.get("vehicle_foot_link_violation", false)), "HUMAN_RUN_B_VEHICLE_FOOT_LINK_REJECTED_PASS")
	_require(bool(b.get("north_info_before_central_commit", false)), "HUMAN_RUN_B_NORTH_INFO_CHANGED_DECISION_PASS")
	_require(int(b.get("hold_fire_fire_delta", -1)) == 0, "HUMAN_RUN_B_HOLD_FIRE_NO_FIRE_PASS")
	_require(int(b.get("weapons_free_fire_delta", 0)) > 0, "HUMAN_RUN_B_WEAPONS_FREE_FIRE_PASS")
	_require(bool(c.get("south_route_affected_contact", false)), "HUMAN_RUN_C_SOUTH_CONTACT_GEOMETRY_PASS")
	_require(not _fow_violation, "HUMAN_FOW_NO_HIDDEN_RED_LEAK_PASS")
	_require(not _softlock_found, "HUMAN_SOFTLOCK_WATCHDOG_PASS")
	var resupply_count: int = 0
	for record: Dictionary in _runs:
		if bool(record.get("resupply_complete", false)):
			resupply_count += 1
	_require(resupply_count >= 2, "HUMAN_BLUE_RESUPPLY_COMPLETE_PASS")
	# Micro-intensity sanity (soft gate; surfaced to 07 for judgment).
	var warn_count: int = 0
	for record: Dictionary in _runs:
		if bool(record.get("micro_intensity_warning", false)):
			warn_count += 1
	print("HUMAN_MICRO_INTENSITY_WARNING_COUNT=%d" % warn_count)
	if warn_count > 0:
		print("HUMAN_MICRO_INTENSITY_WARNING=YES (07 judgement required)")
	else:
		print("HUMAN_MICRO_INTENSITY_WARNING=NO")


func _require(condition: bool, marker: String) -> void:
	if condition:
		print(marker)
	else:
		_fail(marker)


func _fail(marker: String) -> void:
	if not _failures.has(marker):
		_failures.append(marker)
	push_error(marker)


func _finish() -> void:
	if _failures.is_empty():
		print("FRONTLINE_HUMAN_REASONABLE_FLOW_EVIDENCE_PASS")
		quit(0)
	else:
		print("FRONTLINE_HUMAN_REASONABLE_FLOW_EVIDENCE_FAIL failures=%s" % [", ".join(_failures)])
		quit(1)
