class_name BattlePlayerWarFlow
extends Node2D

signal friendlies_changed(formations: Array[BattleFormation])
signal victory
signal defeat
signal feedback_changed(message: String)

# Legacy constants remain for source compatibility only. M2 has no active Supply
# loop and no forward-rally progression.
const SUPPLY_RANGE: float = 140.0
const SUPPLY_DURATION: float = 4.0
const SUPPLY_RESTORE_FRACTION: float = 0.5
const WEST_REAR_RALLY: Vector2 = Vector2(520.0, 900.0)
const BRIDGEHEAD_FORWARD_RALLY: Vector2 = Vector2(1360.0, 1080.0)

# M2 tuning value. The capture footprint is 150; this larger zone prevents a
# victory while a living RED combat Formation is still close enough to counterattack.
const COMMAND_AREA_COUNTERATTACK_RADIUS: float = 420.0

var _battle: Node2D
var _navigation: BattleNavigation
var _selection: BattleSelectionController
var _hud: BattleHUD
var _command_area: BattleObjective
var _roster: BattleFormalCombatRoster

var _friendlies: Array[BattleFormation] = []
var _red_formations: Array[BattleFormation] = []
var _configured: bool = false
var _match_finished: bool = false
var _victory_result: bool = false
var _hud_accumulator: float = 0.0
var _enemy_tracking_attempts: int = 0

func configure(friendlies: Array[BattleFormation]) -> void:
	if _configured:
		return
	_configured = true
	_battle = get_parent() as Node2D
	_navigation = _battle.get_node("Navigation") as BattleNavigation
	_selection = _battle.get_node("SelectionController") as BattleSelectionController
	_hud = _battle.get_node("HUD") as BattleHUD
	_command_area = _battle.get_node("CommandArea") as BattleObjective
	_roster = _battle.get_node("FormalCombatRoster") as BattleFormalCombatRoster

	_friendlies = friendlies.duplicate()
	for formation: BattleFormation in _friendlies:
		_command_area.add_tracked_formation(formation)

	if not _command_area.state_changed.is_connected(_on_command_area_state_changed):
		_command_area.state_changed.connect(_on_command_area_state_changed)
	if not _command_area.contest_changed.is_connected(_on_command_area_contest_changed):
		_command_area.contest_changed.connect(_on_command_area_contest_changed)
	if not _command_area.capture_completed.is_connected(_on_command_area_capture_completed):
		_command_area.capture_completed.connect(_on_command_area_capture_completed)

	call_deferred("_complete_enemy_tracking")
	_refresh_hud()
	print("FRONTLINE_M2_WAR_FLOW_READY blue=%d objectives=1 supply=0 reserve_unlock=0 staging=0" % _friendlies.size())

func _complete_enemy_tracking() -> void:
	if _roster == null:
		return
	_red_formations = _roster.get_initial_enemy_combat_formations()
	if _red_formations.size() != 4 and _enemy_tracking_attempts < 4:
		_enemy_tracking_attempts += 1
		call_deferred("_complete_enemy_tracking")
		return
	for formation: BattleFormation in _red_formations:
		_command_area.add_tracked_formation(formation)
	print("FRONTLINE_M2_OBJECTIVE_TRACKING_READY blue=%d red=%d" % [_friendlies.size(), _red_formations.size()])
	_refresh_hud()

func _process(delta: float) -> void:
	if not _configured:
		return
	if not _match_finished:
		_evaluate_match_state()
	_hud_accumulator += delta
	if _hud_accumulator >= 0.10:
		_hud_accumulator = 0.0
		_refresh_hud()

func withdraw_selected(_prefer_forward: bool = true) -> int:
	if _match_finished:
		return 0
	var destination: Vector2 = _navigation.clamp_to_walkable(WEST_REAR_RALLY)
	var issued: int = 0
	for formation: BattleFormation in _selection.get_selected():
		if formation != null and is_instance_valid(formation) and formation.is_alive and formation.faction == "BLUE":
			if formation.issue_withdraw(destination):
				issued += 1
	if issued > 0:
		var message := "WITHDRAW · %d FORMATION%s · WEST REAR" % [issued, "S" if issued != 1 else ""]
		feedback_changed.emit(message)
		_hud.show_command_feedback(message, "INFO")
		print("FRONTLINE_M2_WITHDRAW_ISSUED count=%d" % issued)
	return issued

func get_friendlies() -> Array[BattleFormation]:
	return _friendlies.duplicate()

func is_match_finished() -> bool:
	return _match_finished

func is_victory() -> bool:
	return _match_finished and _victory_result

func force_evaluate_match_state() -> void:
	if not _match_finished:
		_evaluate_match_state()

func get_counterattack_radius() -> float:
	return COMMAND_AREA_COUNTERATTACK_RADIUS

func _on_command_area_state_changed(_state: String, _progress: float) -> void:
	_refresh_hud()
	_evaluate_match_state()

func _on_command_area_contest_changed(_contested: bool) -> void:
	_refresh_hud()
	_evaluate_match_state()

func _on_command_area_capture_completed(new_owner: String, previous_owner: String) -> void:
	print("FRONTLINE_M2_COMMAND_AREA_CAPTURED owner=%s previous=%s" % [new_owner, previous_owner])
	_refresh_hud()
	_evaluate_match_state()

func _evaluate_match_state() -> void:
	if _match_finished or _command_area == null:
		return
	if (
		_command_area.get_control_owner() == BattleObjective.OWNER_PLAYER
		and not _command_area.is_contested()
		and _counterattack_zone_clear()
	):
		_finish_match(true)
		return
	if _all_blue_main_combat_destroyed():
		_finish_match(false)

func _counterattack_zone_clear() -> bool:
	for formation: BattleFormation in _get_red_formations():
		if formation == null or not is_instance_valid(formation) or not formation.is_alive:
			continue
		if formation.global_position.distance_to(_command_area.global_position) <= COMMAND_AREA_COUNTERATTACK_RADIUS:
			return false
	return true

func _all_blue_main_combat_destroyed() -> bool:
	for formation: BattleFormation in _friendlies:
		if formation == null or not is_instance_valid(formation) or not formation.is_alive:
			continue
		if formation.get_role() != "RECON":
			return false
	return true

func _finish_match(player_won: bool) -> void:
	_match_finished = true
	_victory_result = player_won
	for formation: BattleFormation in _friendlies:
		if formation != null and is_instance_valid(formation) and formation.is_alive:
			formation.stop()
	for formation: BattleFormation in _get_red_formations():
		if formation != null and is_instance_valid(formation) and formation.is_alive:
			formation.stop()

	if player_won:
		_hud.show_victory()
		print("FRONTLINE_M2_VICTORY command_area=PLAYER counterattack_zone=CLEAR")
		victory.emit()
	else:
		_hud.show_defeat()
		print("FRONTLINE_M2_DEFEAT main_combat_formations=DESTROYED")
		defeat.emit()
	_refresh_hud()

func _get_red_formations() -> Array[BattleFormation]:
	if not _red_formations.is_empty():
		return _red_formations.duplicate()
	if _roster != null:
		return _roster.get_initial_enemy_combat_formations()
	return []

func _refresh_hud() -> void:
	if _hud == null or _command_area == null:
		return
	_hud.set_force_status(_friendlies)
	_hud.set_command_area(
		_command_area.get_control_owner(),
		_command_area.is_contested(),
		_command_area.progress,
		_counterattack_zone_clear()
	)

# ---------------------------------------------------------------------
# Legacy API compatibility. These methods intentionally do nothing in the active
# M2 runtime shell so inactive historical scripts can remain in the repository
# without forcing Supply, Reserve or forward-rally gameplay back into Battle01.
# ---------------------------------------------------------------------

func try_supply_selected() -> bool:
	return false

func start_supply(_truck: BattleFormation, _target: BattleFormation) -> bool:
	return false

func is_supply_active() -> bool:
	return false

func get_supply_progress() -> float:
	return 0.0

func deploy_reserve(_kind: String) -> BattleFormation:
	return null

func get_reserve_status() -> Dictionary:
	return {
		"unlocked": false,
		"committed": false,
		"choice": "",
		"deployable": false,
	}

func is_forward_rally_active() -> bool:
	return false
