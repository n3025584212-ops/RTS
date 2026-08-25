class_name BattlePlayerWarFlow
extends Node2D

signal friendlies_changed(formations: Array[BattleFormation])
signal victory
signal defeat
signal feedback_changed(message: String)

const FORMATION_SCRIPT: Script = preload("res://scripts/battle01/formation.gd")
const INFANTRY_DEFINITION: FormationDefinition = preload("res://resources/formations/infantry.tres")
const ARMOR_DEFINITION: FormationDefinition = preload("res://resources/formations/tank.tres")

const SUPPLY_RANGE: float = 140.0
const SUPPLY_DURATION: float = 4.0
const SUPPLY_RESTORE_FRACTION: float = 0.5

const WEST_REAR_RALLY: Vector2 = Vector2(520.0, 1080.0)
const WEST_REAR_ENTRY: Vector2 = Vector2(320.0, 900.0)
const BRIDGEHEAD_FORWARD_RALLY: Vector2 = Vector2(1360.0, 1080.0)

var _battle: Node2D
var _navigation: BattleNavigation
var _visibility: BattleVisibilityField
var _selection: BattleSelectionController
var _hud: BattleHUD
var _central: BattleObjective
var _industrial: BattleObjective
var _roster: BattleFormalCombatRoster
var _enemy_ai: BattleEnemyAIController

var _friendlies: Array[BattleFormation] = []
var _configured: bool = false
var _match_finished: bool = false
var _victory_result: bool = false

var _first_bridgehead_capture: bool = false
var _reserve_unlocked: bool = false
var _reserve_committed: bool = false
var _reserve_choice: String = ""
var _reserve_formation: BattleFormation
var _forward_rally_active: bool = false

var _supply_truck: BattleFormation
var _supply_target: BattleFormation
var _supply_progress: float = 0.0
var _supply_truck_damage_serial: int = 0
var _supply_target_damage_serial: int = 0
var _supply_target_fire_serial: int = 0
var _supply_feedback: String = "Ready"
var _hud_accumulator: float = 0.0

func configure(friendlies: Array[BattleFormation]) -> void:
	if _configured:
		return
	_configured = true
	_battle = get_parent() as Node2D
	_navigation = _battle.get_node("Navigation") as BattleNavigation
	_visibility = _battle.get_node("VisibilityField") as BattleVisibilityField
	_selection = _battle.get_node("SelectionController") as BattleSelectionController
	_hud = _battle.get_node("HUD") as BattleHUD
	_central = _battle.get_node("CentralBridgehead") as BattleObjective
	_industrial = _battle.get_node("IndustrialObjective") as BattleObjective
	_roster = _battle.get_node("FormalCombatRoster") as BattleFormalCombatRoster
	_enemy_ai = _battle.get_node("EnemyAIController") as BattleEnemyAIController

	_friendlies = friendlies.duplicate()
	for formation: BattleFormation in _friendlies:
		_central.add_tracked_formation(formation)
		_industrial.add_tracked_formation(formation)

	_central.capture_completed.connect(_on_central_capture_completed)
	_central.state_changed.connect(_on_objective_state_changed)
	_central.contest_changed.connect(_on_objective_contest_changed)
	_industrial.capture_completed.connect(_on_industrial_capture_completed)
	_industrial.state_changed.connect(_on_objective_state_changed)
	_industrial.contest_changed.connect(_on_objective_contest_changed)

	call_deferred("_complete_enemy_tracking")
	_update_forward_rally()
	_refresh_hud()
	queue_redraw()
	print("FRONTLINE_WAR_FLOW_READY active_blue=%d reserve_commitments=1 objectives=2" % _friendlies.size())

func _complete_enemy_tracking() -> void:
	if _roster == null:
		return
	var red_formations: Array[BattleFormation] = []
	red_formations.append_array(_roster.get_initial_enemy_combat_formations())
	red_formations.append_array(_roster.get_initial_supply_trucks())
	red_formations.append_array(_roster.get_reinforcement_formations())
	for formation: BattleFormation in red_formations:
		_central.add_tracked_formation(formation)
		_industrial.add_tracked_formation(formation)
	print("FRONTLINE_OBJECTIVE_TRACKING_READY blue=%d red=%d" % [_friendlies.size(), red_formations.size()])

func _process(delta: float) -> void:
	if not _configured:
		return
	if _supply_truck != null:
		_update_supply(delta)

	_update_forward_rally()
	if not _match_finished:
		_evaluate_match_state()

	_hud_accumulator += delta
	if _hud_accumulator >= 0.10:
		_hud_accumulator = 0.0
		_refresh_hud()

func try_supply_selected() -> bool:
	if _match_finished:
		return false
	var selected: Array[BattleFormation] = _selection.get_selected()
	if selected.size() != 2:
		return _reject_supply("Select exactly one Supply Truck and one friendly target")

	var truck: BattleFormation
	var target: BattleFormation
	for formation: BattleFormation in selected:
		if formation.is_supply_truck():
			if truck != null:
				return _reject_supply("Only one Supply Truck may be selected")
			truck = formation
		else:
			if target != null:
				return _reject_supply("Select one Supply Truck plus one target")
			target = formation

	if truck == null or target == null:
		return _reject_supply("Supply requires one Supply Truck and one non-Supply target")
	return start_supply(truck, target)

func start_supply(truck: BattleFormation, target: BattleFormation) -> bool:
	var rejection: String = _supply_rejection_reason(truck, target)
	if not rejection.is_empty():
		return _reject_supply(rejection)

	if _supply_truck != null:
		_cancel_supply("New supply order")

	truck.stop()
	target.stop()
	_supply_truck = truck
	_supply_target = target
	_supply_progress = 0.0
	_supply_truck_damage_serial = truck.get_damage_serial()
	_supply_target_damage_serial = target.get_damage_serial()
	_supply_target_fire_serial = target.get_fire_serial()
	_supply_feedback = "SUPPLY ACTIVE — hold position 4.0s"
	feedback_changed.emit(_supply_feedback)
	_hud.show_command_feedback("AMMO SUPPLY  ·  HOLD POSITION 4.0s", "INFO")
	_refresh_hud()
	queue_redraw()
	print("FRONTLINE_SUPPLY_STARTED truck=%s target=%s charges=%d" % [truck.display_name, target.display_name, truck.get_supply_charges()])
	return true

func _supply_rejection_reason(truck: BattleFormation, target: BattleFormation) -> String:
	if truck == null or target == null:
		return "Missing Supply Truck or target"
	if not truck.is_alive:
		return "Supply Truck destroyed"
	if not target.is_alive:
		return "Target destroyed"
	if truck.faction != target.faction:
		return "Target is not friendly"
	if not truck.is_supply_truck():
		return "Selected supplier is not a Supply Truck"
	if target.is_supply_truck():
		return "Supply Truck cannot supply another Supply Truck"
	if truck.get_supply_charges() <= 0:
		return "No Supply charges remaining"
	if target.ammo_capacity <= 0:
		return "Target has no ammunition capacity"
	if target.current_ammo >= target.ammo_capacity:
		return "Target ammunition already full"
	if truck.global_position.distance_to(target.global_position) > SUPPLY_RANGE:
		return "Target out of Supply range (140)"
	if truck.get_order() != "HOLD" or target.get_order() != "HOLD":
		return "Both formations must be stationary"
	return ""

func _update_supply(delta: float) -> void:
	if _supply_truck == null or _supply_target == null:
		_clear_supply_state()
		return
	if not _supply_truck.is_alive:
		_cancel_supply("Supply Truck destroyed")
		return
	if not _supply_target.is_alive:
		_cancel_supply("Supply target destroyed")
		return
	if _supply_truck.get_order() != "HOLD" or _supply_target.get_order() != "HOLD":
		_cancel_supply("Movement interrupted Supply")
		return
	if _supply_truck.global_position.distance_to(_supply_target.global_position) > SUPPLY_RANGE:
		_cancel_supply("Out of range")
		return
	if _supply_truck.get_damage_serial() != _supply_truck_damage_serial:
		_cancel_supply("Supply Truck under fire")
		return
	if _supply_target.get_damage_serial() != _supply_target_damage_serial:
		_cancel_supply("Target under fire")
		return
	if _supply_target.get_fire_serial() != _supply_target_fire_serial:
		_cancel_supply("Target fired")
		return
	if _supply_target.current_ammo >= _supply_target.ammo_capacity:
		_cancel_supply("Target ammunition full")
		return

	_supply_progress = minf(SUPPLY_DURATION, _supply_progress + delta)
	_supply_feedback = "SUPPLY %.1f / %.1fs" % [_supply_progress, SUPPLY_DURATION]
	_refresh_hud()
	queue_redraw()

	if _supply_progress >= SUPPLY_DURATION:
		var restore_amount: int = maxi(1, int(round(float(_supply_target.ammo_capacity) * SUPPLY_RESTORE_FRACTION)))
		var target_name: String = _supply_target.display_name
		var truck_name: String = _supply_truck.display_name
		var before_ammo: int = _supply_target.current_ammo
		var restored: int = _supply_target.restore_ammo(restore_amount)
		var consumed: bool = _supply_truck.consume_supply_charge()
		if not consumed:
			push_error("Supply completion reached without a valid charge.")
			_cancel_supply("Supply charge unavailable")
			return
		var remaining: int = _supply_truck.get_supply_charges()
		_supply_feedback = "SUPPLY COMPLETE — %s +%d ammo" % [target_name, restored]
		_hud.show_command_feedback("AMMO RESTORED  ·  %s +%d" % [target_name, restored], "INFO")
		print("FRONTLINE_SUPPLY_COMPLETE truck=%s target=%s ammo=%d->%d restored=%d charges=%d" % [
			truck_name,
			target_name,
			before_ammo,
			before_ammo + restored,
			restored,
			remaining,
		])
		_clear_supply_state(false)
		_refresh_hud()
		queue_redraw()

func _cancel_supply(reason: String) -> void:
	if _supply_truck != null:
		print("FRONTLINE_SUPPLY_INTERRUPTED reason=%s progress=%.2f charges=%d" % [reason, _supply_progress, _supply_truck.get_supply_charges()])
	_supply_feedback = "SUPPLY INTERRUPTED — %s" % reason
	_hud.show_command_feedback(_supply_feedback, "TACTICAL")
	_clear_supply_state(false)
	_refresh_hud()
	queue_redraw()

func _clear_supply_state(reset_feedback: bool = true) -> void:
	_supply_truck = null
	_supply_target = null
	_supply_progress = 0.0
	_supply_truck_damage_serial = 0
	_supply_target_damage_serial = 0
	_supply_target_fire_serial = 0
	if reset_feedback:
		_supply_feedback = "Ready"

func _reject_supply(reason: String) -> bool:
	_supply_feedback = "SUPPLY INVALID — %s" % reason
	feedback_changed.emit(_supply_feedback)
	_hud.show_command_feedback(_supply_feedback, "TACTICAL")
	_refresh_hud()
	print("FRONTLINE_SUPPLY_REJECTED reason=%s" % reason)
	return false

func withdraw_selected(prefer_forward: bool = true) -> int:
	if _match_finished:
		return 0
	var destination: Vector2 = WEST_REAR_RALLY
	var destination_name: String = "WEST_REAR_RALLY"
	if prefer_forward and _forward_rally_active:
		destination = BRIDGEHEAD_FORWARD_RALLY
		destination_name = "BRIDGEHEAD_FORWARD_RALLY"

	var issued: int = 0
	for formation: BattleFormation in _selection.get_selected():
		if formation != null and formation.is_alive and formation.faction == "BLUE":
			if formation.issue_withdraw(_navigation.clamp_to_walkable(destination)):
				issued += 1
	if issued > 0:
		_supply_feedback = "WITHDRAW → %s" % destination_name
		_hud.show_command_feedback("WITHDRAW  ·  %d FORMATION%s  ·  %s" % [issued, "S" if issued != 1 else "", "BRIDGEHEAD RALLY" if destination_name == "BRIDGEHEAD_FORWARD_RALLY" else "WEST REAR"], "INFO")
		print("FRONTLINE_WITHDRAW_ISSUED count=%d rally=%s" % [issued, destination_name])
	_refresh_hud()
	return issued

func deploy_reserve(kind: String) -> BattleFormation:
	if _match_finished:
		_feedback("Reserve unavailable after match end")
		return null
	if not _reserve_unlocked:
		_feedback("Reserve LOCKED — capture Central Bridgehead first")
		return null
	if _reserve_committed:
		_feedback("Reserve already COMMITTED to %s" % _reserve_choice)
		return null
	if kind != "INFANTRY" and kind != "ARMOR":
		_feedback("Invalid reserve choice")
		return null

	_reserve_committed = true
	_reserve_choice = kind

	var formation: BattleFormation = FORMATION_SCRIPT.new() as BattleFormation
	formation.name = "BlueReserveInfantry1" if kind == "INFANTRY" else "BlueReserveArmor1"
	formation.definition = INFANTRY_DEFINITION if kind == "INFANTRY" else ARMOR_DEFINITION
	formation.display_name = "BLUE RESERVE INF-01" if kind == "INFANTRY" else "BLUE RESERVE ARMOR-01"
	formation.faction = "BLUE"
	formation.selectable = true
	formation.body_color = Color(0.12, 0.55, 0.92, 1.0)
	_battle.add_child(formation)
	formation.global_position = _navigation.clamp_to_walkable(WEST_REAR_ENTRY)
	formation.set_navigation(_navigation)
	formation.set_visibility_field(_visibility)

	_reserve_formation = formation
	_friendlies.append(formation)
	_selection.register_formation(formation)
	_central.add_tracked_formation(formation)
	_industrial.add_tracked_formation(formation)
	friendlies_changed.emit(_friendlies)
	_feedback("Reserve COMMITTED — %s entering from WEST_REAR_ENTRY" % formation.display_name)
	_hud.push_alert("TACTICAL", "RESERVE ARRIVED  ·  WEST REAR", "reserve_arrival")
	print("FRONTLINE_PLAYER_RESERVE_COMMITTED choice=%s unit=%s entry=%s" % [kind, formation.display_name, formation.global_position])
	_refresh_hud()
	return formation

func get_friendlies() -> Array[BattleFormation]:
	return _friendlies.duplicate()

func get_reserve_status() -> Dictionary:
	return {
		"unlocked": _reserve_unlocked,
		"committed": _reserve_committed,
		"choice": _reserve_choice,
		"deployable": _reserve_unlocked and not _reserve_committed,
	}

func is_forward_rally_active() -> bool:
	return _forward_rally_active

func is_supply_active() -> bool:
	return _supply_truck != null

func get_supply_progress() -> float:
	return _supply_progress

func is_match_finished() -> bool:
	return _match_finished

func is_victory() -> bool:
	return _match_finished and _victory_result

func force_evaluate_match_state() -> void:
	if not _match_finished:
		_evaluate_match_state()

func _on_central_capture_completed(new_owner: String, _previous_owner: String) -> void:
	if new_owner == BattleObjective.OWNER_PLAYER and not _first_bridgehead_capture:
		_first_bridgehead_capture = true
		_reserve_unlocked = true
		_industrial.unlock_player_capture()
		print("FRONTLINE_BRIDGEHEAD_FIRST_PLAYER_CAPTURE")
		print("FRONTLINE_PLAYER_RESERVE_UNLOCKED")
		print("FRONTLINE_INDUSTRIAL_OBJECTIVE_UNLOCKED")
		_feedback("Bridgehead secured — Reserve and Industrial Objective unlocked")
		_hud.push_alert("TACTICAL", "CENTRAL SECURED  ·  RESERVE / INDUSTRIAL UNLOCKED", "bridgehead_hinge")
	_update_forward_rally()
	_evaluate_match_state()

func _on_industrial_capture_completed(_new_owner: String, _previous_owner: String) -> void:
	_evaluate_match_state()

func _on_objective_state_changed(_state: String, _progress: float) -> void:
	_update_forward_rally()
	_refresh_hud()

func _on_objective_contest_changed(_value: bool) -> void:
	_update_forward_rally()
	_evaluate_match_state()
	_refresh_hud()

func _update_forward_rally() -> void:
	var active: bool = _central.get_control_owner() == BattleObjective.OWNER_PLAYER and not _central.is_contested()
	if active == _forward_rally_active:
		return
	_forward_rally_active = active
	if _hud != null:
		_hud.push_alert("TACTICAL", "BRIDGEHEAD FORWARD RALLY  ·  %s" % ("ACTIVE" if active else "INACTIVE"), "forward_rally")
	print("FRONTLINE_FORWARD_RALLY state=%s" % ("ACTIVE" if active else "INACTIVE"))
	_refresh_hud()
	queue_redraw()

func _evaluate_match_state() -> void:
	if _match_finished:
		return
	if (
		_central.get_control_owner() == BattleObjective.OWNER_PLAYER
		and not _central.is_contested()
		and _industrial.get_control_owner() == BattleObjective.OWNER_PLAYER
		and not _industrial.is_contested()
	):
		_finish_match(true)
		return
	if _should_defeat():
		_finish_match(false)

func _should_defeat() -> bool:
	for formation: BattleFormation in _friendlies:
		if _formation_can_progress_mission(formation):
			return false
	if _reserve_unlocked and not _reserve_committed:
		return false
	return true

func _formation_can_progress_mission(formation: BattleFormation) -> bool:
	if formation == null or not is_instance_valid(formation) or not formation.is_alive:
		return false
	if formation.is_supply_truck():
		return false
	if formation.can_capture:
		return true
	if formation.can_attack and formation.current_ammo > 0:
		return true
	if formation.can_attack and _can_supply_restore(formation):
		return true
	return false

func _can_supply_restore(target: BattleFormation) -> bool:
	for formation: BattleFormation in _friendlies:
		if formation == null or not formation.is_alive or not formation.is_supply_truck():
			continue
		if formation.get_supply_charges() > 0 and target.ammo_capacity > 0 and target.current_ammo < target.ammo_capacity:
			return true
	return false

func _finish_match(player_won: bool) -> void:
	_match_finished = true
	_victory_result = player_won
	if _supply_truck != null:
		_cancel_supply("Match ended")
	for formation: BattleFormation in _friendlies:
		if formation != null and is_instance_valid(formation) and formation.is_alive:
			formation.stop()
	for formation: BattleFormation in _get_red_formations():
		if formation != null and is_instance_valid(formation) and formation.is_alive:
			formation.stop()
	if _enemy_ai != null:
		_enemy_ai.process_mode = Node.PROCESS_MODE_DISABLED

	if player_won:
		_hud.show_victory()
		print("FRONTLINE_VICTORY")
		victory.emit()
	else:
		_hud.show_defeat()
		print("FRONTLINE_DEFEAT")
		defeat.emit()
	_refresh_hud()

func _get_red_formations() -> Array[BattleFormation]:
	var result: Array[BattleFormation] = []
	if _roster == null:
		return result
	result.append_array(_roster.get_initial_enemy_combat_formations())
	result.append_array(_roster.get_initial_supply_trucks())
	result.append_array(_roster.get_reinforcement_formations())
	return result

func _refresh_hud() -> void:
	if _hud == null:
		return
	_hud.set_force_status(_friendlies)
	var supply_charges: int = 0
	var supply_max: int = 0
	for formation: BattleFormation in _friendlies:
		if formation != null and is_instance_valid(formation) and formation.is_supply_truck():
			supply_charges = formation.get_supply_charges()
			supply_max = formation.supply_capacity
			break
	_hud.set_supply_status(supply_charges, supply_max, _supply_progress, _supply_truck != null, _supply_feedback)
	_hud.set_reserve_status(_reserve_unlocked, _reserve_committed, _reserve_choice)
	_hud.set_objectives(
		_central.get_control_owner(),
		_central.is_contested(),
		_central.progress,
		_industrial.get_control_owner(),
		_industrial.is_contested(),
		_industrial.progress,
		_industrial.is_player_capture_locked()
	)
	_hud.set_rally_status(_forward_rally_active)

func _feedback(message: String) -> void:
	_supply_feedback = message
	feedback_changed.emit(message)
	_refresh_hud()

func _draw() -> void:
	_draw_rally_marker(WEST_REAR_RALLY, "WEST REAR  /  RALLY", Color("4d8cff"), Battle01UIStyle.ICON_RALLY_WEST)
	if _forward_rally_active:
		_draw_rally_marker(BRIDGEHEAD_FORWARD_RALLY, "BRIDGEHEAD RALLY  /  ACTIVE", Color("4dd0e1"), Battle01UIStyle.ICON_RALLY_FORWARD)

	if _supply_truck != null and _supply_target != null:
		var truck_point := to_local(_supply_truck.global_position)
		var target_point := to_local(_supply_target.global_position)
		draw_line(truck_point, target_point, Color("4dd0e1"), 4.0)
		draw_line(truck_point, target_point, Color(0.30, 0.82, 0.88, 0.35), 9.0)
		draw_arc(truck_point, SUPPLY_RANGE, 0.0, TAU, 64, Color(0.30, 0.82, 0.88, 0.18), 1.5)
		var truck_texture: Texture2D = Battle01UIStyle.icon(Battle01UIStyle.ICON_ROLE_LOGISTICS)
		if truck_texture != null:
			draw_texture_rect(truck_texture, Rect2(truck_point - Vector2(19.0, 19.0), Vector2(38.0, 38.0)), false, Color(0.30, 0.82, 0.88, 0.95))
		var target_texture: Texture2D = Battle01UIStyle.icon(Battle01UIStyle.ICON_COMMAND_SUPPLY)
		if target_texture != null:
			draw_texture_rect(target_texture, Rect2(target_point - Vector2(16.0, 16.0), Vector2(32.0, 32.0)), false, Color(0.30, 0.82, 0.88, 0.85))
		var midpoint: Vector2 = to_local((_supply_truck.global_position + _supply_target.global_position) * 0.5)
		var ratio: float = _supply_progress / SUPPLY_DURATION
		draw_rect(Rect2(midpoint + Vector2(-44.0, -16.0), Vector2(88.0, 11.0)), Color(0.02, 0.05, 0.06, 0.92), true)
		draw_rect(Rect2(midpoint + Vector2(-44.0, -16.0), Vector2(88.0 * ratio, 11.0)), Color("4dd0e1"), true)
		draw_rect(Rect2(midpoint + Vector2(-44.0, -16.0), Vector2(88.0, 11.0)), Color(0.30, 0.82, 0.88, 0.60), false, 1.0)
		var supply_icon: Texture2D = Battle01UIStyle.icon(Battle01UIStyle.ICON_COMMAND_SUPPLY)
		if supply_icon != null:
			draw_texture_rect(supply_icon, Rect2(midpoint + Vector2(-54.0, -22.0), Vector2(22.0, 22.0)), false, Color("4dd0e1"))
		draw_string(ThemeDB.fallback_font, midpoint + Vector2(-30.0, -21.0), "AMMO %.1f / 4.0s" % _supply_progress, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 12, Color.WHITE)

func _draw_rally_marker(world_position: Vector2, label: String, color: Color, icon_name: String) -> void:
	var marker_position := to_local(world_position)
	draw_circle(marker_position, 34.0, Color(color, 0.07))
	for index: int in range(8):
		var a0: float = TAU * float(index) / 8.0
		draw_arc(marker_position, 34.0, a0, a0 + TAU / 16.0, 4, Color(color, 0.66), 2.0)
	var texture: Texture2D = Battle01UIStyle.icon(icon_name)
	if texture != null:
		draw_texture_rect(texture, Rect2(marker_position - Vector2(22.0, 22.0), Vector2(44.0, 44.0)), false, Color(color, 0.95))
	var font := ThemeDB.fallback_font
	var font_size := 12
	var text_width: float = font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).x
	var rect := Rect2(marker_position + Vector2(-text_width * 0.5 - 7.0, -64.0), Vector2(text_width + 14.0, 20.0))
	draw_rect(rect, Color(0.025, 0.050, 0.065, 0.90), true)
	draw_rect(rect, Color(color, 0.75), false, 1.0)
	draw_string(font, rect.position + Vector2(7.0, 15.0), label, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size, Color(color, 0.95))