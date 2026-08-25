class_name BattleResupplyController
extends Node

const ARRIVAL_TOLERANCE: float = 18.0
const FEEDBACK_INTERVAL: float = 0.25

var _battle: Node
var _navigation: BattleNavigation
var _selection: BattleSelectionController
var _flow: BattlePlayerWarFlow
var _hud: BattleHUD

var _active: bool = false
var _phase: String = "IDLE"
var _target: BattleFormation
var _truck: BattleFormation
var _rendezvous: Vector2 = Vector2.ZERO
var _rendezvous_name: String = ""
var _target_ammo_before: int = 0
var _charge_before: int = 0
var _status_message: String = "RESUPPLY READY"
var _feedback_accumulator: float = 0.0
var _initialized: bool = false

func _ready() -> void:
	process_priority = 20
	call_deferred("_initialize")

func _initialize() -> void:
	if _initialized:
		return
	_initialized = true
	_battle = get_parent()
	_navigation = _battle.get_node("Navigation") as BattleNavigation
	_selection = _battle.get_node("SelectionController") as BattleSelectionController
	_flow = _battle.get_node("PlayerWarFlow") as BattlePlayerWarFlow
	_hud = _battle.get_node("HUD") as BattleHUD
	_selection.move_order_issued.connect(_on_direct_move_order_issued)
	_flow.victory.connect(_on_match_finished)
	_flow.defeat.connect(_on_match_finished)
	print("FRONTLINE_RESUPPLY_CONTROLLER_READY")

func _input(event: InputEvent) -> void:
	if not _initialized or _flow == null or _flow.is_match_finished():
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var key_event := event as InputEventKey
		if key_event.keycode == KEY_F:
			start_resupply_selected()
			get_viewport().set_input_as_handled()
			return
		if key_event.keycode == KEY_X and _active:
			var selected: Array[BattleFormation] = _selection.get_selected()
			if _selection_involves_active_resupply(selected):
				_cancel_for_direct_order("Direct WITHDRAW override", selected)

func _process(delta: float) -> void:
	if not _initialized or not _active:
		return
	if _flow == null or _flow.is_match_finished():
		_cancel_resupply("Match ended", true)
		return
	if _target == null or not is_instance_valid(_target) or not _target.is_alive:
		_cancel_resupply("Target destroyed", true)
		return
	if _truck == null or not is_instance_valid(_truck) or not _truck.is_alive:
		_cancel_resupply("No available Supply — Logistics destroyed", true)
		return

	if _phase == "MOVING":
		_update_rendezvous_movement()
	elif _phase == "TRANSFERRING":
		_target.clear_combat_target()
		_observe_transfer_result()

	_feedback_accumulator += delta
	if _feedback_accumulator >= FEEDBACK_INTERVAL:
		_feedback_accumulator = 0.0
		_refresh_hud()

func force_update_for_test(delta: float) -> void:
	_process(delta)

func start_resupply_selected() -> bool:
	if _flow == null or _flow.is_match_finished():
		return false
	var selected: Array[BattleFormation] = _selection.get_selected()
	if selected.size() != 1:
		return _reject("Select exactly one depleted BLUE Formation, then RESUPPLY")
	return start_resupply(selected[0])

func start_resupply(target: BattleFormation) -> bool:
	var rejection: String = _target_rejection_reason(target)
	if not rejection.is_empty():
		return _reject(rejection)

	var truck: BattleFormation = _find_blue_supply()
	if truck == null:
		return _reject("No available Supply / no charges")

	var rendezvous: Dictionary = _choose_rendezvous(target, truck)
	if rendezvous.is_empty():
		return _reject("No legal reachable Supply rendezvous")

	if _active:
		_cancel_resupply("New RESUPPLY intent", true)

	_target = target
	_truck = truck
	_rendezvous = rendezvous["point"] as Vector2
	_rendezvous_name = str(rendezvous["name"])
	_target_ammo_before = target.current_ammo
	_charge_before = truck.get_supply_charges()
	_active = true
	_phase = "MOVING"
	_status_message = "RESUPPLY MOVING → %s" % _rendezvous_name.replace("_", " ")
	_feedback_accumulator = FEEDBACK_INTERVAL

	_target.clear_combat_target()
	if not _issue_resupply_move(_target, _rendezvous):
		_cancel_resupply("Target cannot reach rendezvous", true)
		return false
	if not _issue_resupply_move(_truck, _rendezvous):
		_cancel_resupply("Supply cannot reach rendezvous", true)
		return false

	print("FRONTLINE_RESUPPLY_INTENT target=%s supplier=%s rendezvous=%s point=%s" % [
		_target.display_name,
		_truck.display_name,
		_rendezvous_name,
		_rendezvous,
	])
	_refresh_hud(true)
	return true

func cancel_active_for_direct_order(formation: BattleFormation, reason: String = "Direct player override") -> void:
	if not _active or formation == null:
		return
	if formation == _target or formation == _truck:
		var direct: Array[BattleFormation] = [formation]
		_cancel_for_direct_order(reason, direct)

func is_resupply_active() -> bool:
	return _active

func get_resupply_phase() -> String:
	return _phase

func get_resupply_target() -> BattleFormation:
	return _target

func get_resupply_truck() -> BattleFormation:
	return _truck

func get_rendezvous_name() -> String:
	return _rendezvous_name

func get_rendezvous_position() -> Vector2:
	return _rendezvous

func _target_rejection_reason(target: BattleFormation) -> String:
	if target == null or not is_instance_valid(target):
		return "No RESUPPLY target selected"
	if not target.is_alive:
		return "Target destroyed"
	if target.faction != "BLUE":
		return "RESUPPLY target must be BLUE"
	if target.is_supply_truck():
		return "Logistics cannot RESUPPLY itself"
	if target.ammo_capacity <= 0:
		return "Target has no ammunition capacity"
	if target.current_ammo >= target.ammo_capacity:
		return "Target ammunition already full"
	return ""

func _find_blue_supply() -> BattleFormation:
	for formation: BattleFormation in _flow.get_friendlies():
		if formation == null or not is_instance_valid(formation):
			continue
		if formation.faction != "BLUE" or not formation.is_alive or not formation.is_supply_truck():
			continue
		if formation.get_supply_charges() <= 0:
			continue
		return formation
	return null

func _choose_rendezvous(target: BattleFormation, truck: BattleFormation) -> Dictionary:
	var candidates: Array[Dictionary] = []
	var west: Dictionary = _rally_candidate("WEST_REAR_RALLY", BattlePlayerWarFlow.WEST_REAR_RALLY, target, truck)
	if not west.is_empty():
		candidates.append(west)
	if _flow.is_forward_rally_active():
		var forward: Dictionary = _rally_candidate("BRIDGEHEAD_FORWARD_RALLY", BattlePlayerWarFlow.BRIDGEHEAD_FORWARD_RALLY, target, truck)
		if not forward.is_empty():
			candidates.append(forward)
	if candidates.is_empty():
		return {}
	candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var score_a: float = float(a["score"])
		var score_b: float = float(b["score"])
		if absf(score_a - score_b) > 0.001:
			return score_a < score_b
		return str(a["name"]) < str(b["name"])
	)
	return candidates[0]

func _rally_candidate(name_value: String, raw_point: Vector2, target: BattleFormation, truck: BattleFormation) -> Dictionary:
	var point: Vector2 = _navigation.clamp_to_walkable(raw_point)
	var target_path: PackedVector2Array = _navigation.find_path(target.global_position, point)
	var truck_path: PackedVector2Array = _navigation.find_path(truck.global_position, point)
	if target_path.is_empty() and target.global_position.distance_to(point) > ARRIVAL_TOLERANCE:
		return {}
	if truck_path.is_empty() and truck.global_position.distance_to(point) > ARRIVAL_TOLERANCE:
		return {}
	var target_cost: float = 0.0 if target_path.is_empty() else _navigation.get_path_length(target_path)
	var truck_cost: float = 0.0 if truck_path.is_empty() else _navigation.get_path_length(truck_path)
	return {"name": name_value, "point": point, "score": target_cost + truck_cost}

func _issue_resupply_move(formation: BattleFormation, destination: Vector2) -> bool:
	if formation.global_position.distance_to(destination) <= ARRIVAL_TOLERANCE:
		formation.stop()
		return true
	if not formation.issue_move(destination):
		return false
	formation._set_order("RESUPPLY")
	return true

func _update_rendezvous_movement() -> void:
	_target.clear_combat_target()
	var target_arrived: bool = _target.global_position.distance_to(_rendezvous) <= ARRIVAL_TOLERANCE
	var truck_arrived: bool = _truck.global_position.distance_to(_rendezvous) <= ARRIVAL_TOLERANCE

	if not target_arrived and _target.get_order() != "RESUPPLY":
		_cancel_resupply("Direct target order override", false)
		return
	if not truck_arrived and _truck.get_order() != "RESUPPLY":
		_cancel_resupply("Direct Logistics order override", false)
		return

	if target_arrived and _target.has_active_navigation_path():
		_target.stop()
	if truck_arrived and _truck.has_active_navigation_path():
		_truck.stop()

	if target_arrived and truck_arrived:
		_begin_transfer()
		return
	if target_arrived or truck_arrived:
		_status_message = "RESUPPLY WAITING AT %s" % _rendezvous_name.replace("_", " ")
	else:
		_status_message = "RESUPPLY MOVING → %s" % _rendezvous_name.replace("_", " ")

func _begin_transfer() -> void:
	_target.stop()
	_truck.stop()
	_target_ammo_before = _target.current_ammo
	_charge_before = _truck.get_supply_charges()
	if not _flow.start_supply(_truck, _target):
		_cancel_resupply("Transfer could not start", true)
		return
	_phase = "TRANSFERRING"
	_status_message = "RESUPPLY TRANSFERRING — 4.0s vulnerable"
	print("FRONTLINE_RESUPPLY_RENDEZVOUS_ARRIVED target=%s supplier=%s rendezvous=%s" % [_target.display_name, _truck.display_name, _rendezvous_name])
	print("FRONTLINE_RESUPPLY_TRANSFER_BEGIN target=%s charges=%d" % [_target.display_name, _charge_before])
	_refresh_hud(true)

func _observe_transfer_result() -> void:
	if _flow.is_supply_active():
		_status_message = "RESUPPLY TRANSFERRING %.1f/4.0s" % _flow.get_supply_progress()
		return
	var completed: bool = (
		_truck != null
		and is_instance_valid(_truck)
		and _target != null
		and is_instance_valid(_target)
		and _truck.get_supply_charges() < _charge_before
		and _target.current_ammo > _target_ammo_before
	)
	if completed:
		var target_name: String = _target.display_name
		var ammo_now: int = _target.current_ammo
		var charges_now: int = _truck.get_supply_charges()
		_status_message = "RESUPPLY COMPLETE — %s AMMO %d/%d" % [target_name, ammo_now, _target.ammo_capacity]
		print("FRONTLINE_RESUPPLY_COMPLETE target=%s ammo=%d/%d charges=%d" % [target_name, ammo_now, _target.ammo_capacity, charges_now])
		_clear_intent()
		_refresh_hud(true)
	else:
		_cancel_resupply("Transfer interrupted", false)

func _on_direct_move_order_issued(formations: Array[BattleFormation], _destination: Vector2) -> void:
	if not _active or not _selection_involves_active_resupply(formations):
		return
	_cancel_for_direct_order("Direct MOVE override", formations)

func _selection_involves_active_resupply(formations: Array[BattleFormation]) -> bool:
	for formation: BattleFormation in formations:
		if formation == _target or formation == _truck:
			return true
	return false

func _cancel_for_direct_order(reason: String, direct_formations: Array[BattleFormation]) -> void:
	_cancel_resupply_internal(reason, direct_formations, true)

func _cancel_resupply(reason: String, stop_automation: bool) -> void:
	var direct_formations: Array[BattleFormation] = []
	_cancel_resupply_internal(reason, direct_formations, stop_automation)

func _cancel_resupply_internal(reason: String, direct_formations: Array[BattleFormation], stop_automation: bool) -> void:
	if not _active:
		return
	var target_name: String = _target.display_name if _target != null and is_instance_valid(_target) else "NONE"
	var truck_name: String = _truck.display_name if _truck != null and is_instance_valid(_truck) else "NONE"
	if _phase == "TRANSFERRING" and _flow != null and _flow.is_supply_active():
		_flow._cancel_supply(reason)
	if stop_automation:
		if _target != null and is_instance_valid(_target) and _target.is_alive and _target not in direct_formations:
			_target.stop()
		if _truck != null and is_instance_valid(_truck) and _truck.is_alive and _truck not in direct_formations:
			_truck.stop()
	_status_message = "RESUPPLY CANCELLED — %s" % reason
	print("FRONTLINE_RESUPPLY_CANCELLED target=%s supplier=%s reason=%s" % [target_name, truck_name, reason])
	_clear_intent()
	_refresh_hud(true)

func _clear_intent() -> void:
	_active = false
	_phase = "IDLE"
	_target = null
	_truck = null
	_rendezvous = Vector2.ZERO
	_rendezvous_name = ""
	_target_ammo_before = 0
	_charge_before = 0
	_feedback_accumulator = 0.0

func _reject(reason: String) -> bool:
	_status_message = "RESUPPLY INVALID — %s" % reason
	print("FRONTLINE_RESUPPLY_REJECTED reason=%s" % reason)
	_refresh_hud(true)
	return false

func _refresh_hud(force_feedback: bool = false) -> void:
	if _hud == null:
		return
	var charges: int = 0
	var max_charges: int = 2
	if _truck != null and is_instance_valid(_truck):
		charges = _truck.get_supply_charges()
		max_charges = maxi(1, _truck.supply_capacity)
	else:
		var available: BattleFormation = _find_blue_supply() if _flow != null else null
		if available != null:
			charges = available.get_supply_charges()
			max_charges = maxi(1, available.supply_capacity)
	var progress: float = _flow.get_supply_progress() if _flow != null and _phase == "TRANSFERRING" else 0.0
	_hud.set_supply_status(charges, max_charges, progress, _phase == "TRANSFERRING", _status_message)
	if force_feedback or _active:
		_hud.show_command_feedback(_status_message, "INFO" if "INVALID" not in _status_message and "CANCELLED" not in _status_message else "TACTICAL")

func _on_match_finished() -> void:
	if _active:
		_cancel_resupply("Match ended", true)
