class_name BattleEnemyAILogisticsController
extends BattleEnemyAIController

const RED_SUPPLY_RANGE: float = 140.0
const RED_SUPPLY_DURATION: float = 4.0
const RED_SUPPLY_RESTORE_FRACTION: float = 0.5
const RED_LOCAL_THREAT_RADIUS: float = 500.0
const RED_TARGET_LULL_RADIUS: float = 450.0
const RED_RECENT_DAMAGE_TIME: float = 3.0
const RED_RENDEZVOUS_CLEARANCE: float = 380.0

var _red_resupply_target: BattleFormation
var _red_resupply_truck: BattleFormation
var _red_resupply_phase: String = "IDLE"
var _red_resupply_rendezvous: Vector2 = Vector2.ZERO
var _red_resupply_progress: float = 0.0
var _red_truck_damage_serial: int = 0
var _red_target_damage_serial: int = 0
var _red_target_fire_serial: int = 0
var _red_target_ammo_before: int = 0
var _red_charge_before: int = 0

func _process(delta: float) -> void:
	super._process(delta)
	if not _initialized or _legacy_ci_disabled or _ci_smoke or _match_finished:
		return
	if _red_resupply_target != null:
		_update_red_resupply(delta)

func _decide_combat_unit(unit: BattleFormation, objective_emergency: bool) -> void:
	if _red_resupply_target == unit:
		var abort_reason: String = _red_resupply_abort_reason()
		if objective_emergency or _is_final_objective_pressure() or not abort_reason.is_empty():
			_cancel_red_resupply("Objective/threat override" if abort_reason.is_empty() else abort_reason)
			super._decide_combat_unit(unit, objective_emergency)
			return
		_maintain_red_rendezvous()
		return
	super._decide_combat_unit(unit, objective_emergency)

func _decide_final_objective_responder(unit: BattleFormation) -> void:
	if _red_resupply_target == unit:
		_cancel_red_resupply("Final objective pressure")
	super._decide_final_objective_responder(unit)

func _decide_supply(truck: BattleFormation) -> void:
	if _ci_smoke:
		super._decide_supply(truck)
		return
	if not _is_active_red_agent(truck):
		return

	var supply_threat: BattleFormation = _nearest_confirmed_threat(truck.global_position, RED_LOCAL_THREAT_RADIUS)
	var recently_damaged: bool = _red_recently_damaged(truck)

	if _red_resupply_target != null:
		var abort_reason: String = _red_resupply_abort_reason()
		if not abort_reason.is_empty():
			_cancel_red_resupply(abort_reason)
			if supply_threat != null or recently_damaged:
				print("FRONTLINE_RED_RESUPPLY_EVADE_OVERRIDE reason=%s" % abort_reason)
				_evade_supply(truck, supply_threat)
			else:
				super._decide_supply(truck)
			return
		_maintain_red_rendezvous()
		return

	if supply_threat != null or recently_damaged:
		super._decide_supply(truck)
		return

	var candidate: BattleFormation = _select_red_resupply_target()
	if candidate != null and _is_red_local_lull(truck, candidate):
		if _begin_red_resupply(truck, candidate):
			return

	super._decide_supply(truck)

func force_red_resupply_decision_for_test() -> void:
	if _supply_units.is_empty():
		return
	_decide_supply(_supply_units[0])

func advance_red_resupply_for_test(delta: float) -> void:
	if _red_resupply_target == null:
		return
	if _red_resupply_phase == "MOVING":
		_maintain_red_rendezvous()
	elif _red_resupply_phase == "TRANSFERRING":
		_update_red_resupply(delta)

func cancel_red_resupply_for_test() -> void:
	if _red_resupply_target != null:
		var target: BattleFormation = _red_resupply_target
		var truck: BattleFormation = _red_resupply_truck
		_cancel_red_resupply("QA reset")
		if target != null and target.is_alive:
			target.stop()
		if truck != null and truck.is_alive:
			truck.stop()

func is_red_resupply_active() -> bool:
	return _red_resupply_target != null

func get_red_resupply_phase() -> String:
	return _red_resupply_phase

func get_red_resupply_target() -> BattleFormation:
	return _red_resupply_target

func get_red_resupply_truck() -> BattleFormation:
	return _red_resupply_truck

func get_red_resupply_progress() -> float:
	return _red_resupply_progress

func get_red_resupply_rendezvous() -> Vector2:
	return _red_resupply_rendezvous

func get_red_supply_state_for_test() -> String:
	if _supply_units.is_empty() or not _agents.has(_supply_units[0]):
		return "NONE"
	return str((_agents[_supply_units[0]] as Dictionary)["state"])

func _select_red_resupply_target() -> BattleFormation:
	var active_units: Array[BattleFormation] = []
	for unit: BattleFormation in _combat_units:
		if _is_active_red_agent(unit):
			active_units.append(unit)
	for unit: BattleFormation in _reinforcements:
		if _is_active_red_agent(unit):
			active_units.append(unit)

	var armor_candidates: Array[BattleFormation] = []
	var infantry_candidates: Array[BattleFormation] = []
	for unit: BattleFormation in active_units:
		if unit.ammo_capacity <= 0 or unit.current_ammo * 2 > unit.ammo_capacity:
			continue
		if "ARMOR" in unit.display_name:
			armor_candidates.append(unit)
		elif "INF" in unit.display_name:
			infantry_candidates.append(unit)

	if not armor_candidates.is_empty():
		return _most_depleted_stable(armor_candidates)
	if not infantry_candidates.is_empty():
		return _most_depleted_stable(infantry_candidates)
	return null

func _most_depleted_stable(candidates: Array[BattleFormation]) -> BattleFormation:
	var best: BattleFormation = null
	for candidate: BattleFormation in candidates:
		if best == null:
			best = candidate
			continue
		var left: int = candidate.current_ammo * maxi(1, best.ammo_capacity)
		var right: int = best.current_ammo * maxi(1, candidate.ammo_capacity)
		if left < right or (left == right and candidate.display_name < best.display_name):
			best = candidate
	return best

func _is_red_local_lull(truck: BattleFormation, target: BattleFormation) -> bool:
	if truck == null or target == null or not truck.is_alive or not target.is_alive:
		return false
	if truck.get_supply_charges() <= 0:
		return false
	if _is_objective_emergency() or _is_final_objective_pressure():
		return false
	if _red_recently_damaged(truck) or _red_recently_damaged(target):
		return false
	if _agents.has(truck) and str((_agents[truck] as Dictionary)["state"]) == EVADE:
		return false
	if _agents.has(target):
		var target_state: String = str((_agents[target] as Dictionary)["state"])
		if target_state == ENGAGE or target_state == INVESTIGATE:
			return false
	if _nearest_confirmed_threat(truck.global_position, RED_LOCAL_THREAT_RADIUS) != null:
		return false
	if _nearest_confirmed_threat(target.global_position, RED_TARGET_LULL_RADIUS) != null:
		return false
	var rendezvous: Vector2 = _compute_red_rendezvous(truck)
	return _can_reach(truck, rendezvous) and _can_reach(target, rendezvous)

func _begin_red_resupply(truck: BattleFormation, target: BattleFormation) -> bool:
	var rendezvous: Vector2 = _compute_red_rendezvous(truck)
	if not _can_reach(truck, rendezvous) or not _can_reach(target, rendezvous):
		return false
	_red_resupply_truck = truck
	_red_resupply_target = target
	_red_resupply_rendezvous = rendezvous
	_red_resupply_phase = "MOVING"
	_red_resupply_progress = 0.0
	_red_target_ammo_before = target.current_ammo
	_red_charge_before = truck.get_supply_charges()
	truck.clear_combat_target()
	target.clear_combat_target()
	print("FRONTLINE_RED_RESUPPLY_DECISION target=%s ammo=%d/%d supplier=%s charges=%d" % [
		target.display_name,
		target.current_ammo,
		target.ammo_capacity,
		truck.display_name,
		truck.get_supply_charges(),
	])
	print("FRONTLINE_RED_RESUPPLY_RENDEZVOUS point=%s" % rendezvous)
	_maintain_red_rendezvous()
	return true

func _compute_red_rendezvous(truck: BattleFormation) -> Vector2:
	var home: Vector2 = truck.global_position
	if _agents.has(truck):
		home = Vector2((_agents[truck] as Dictionary)["home"])
	var away: Vector2 = home - _objective.global_position
	if away.length() < 0.001:
		away = Vector2.LEFT
	var point: Vector2 = _objective.global_position + away.normalized() * RED_RENDEZVOUS_CLEARANCE
	if _industrial_objective != null and point.distance_to(_industrial_objective.global_position) < RED_RENDEZVOUS_CLEARANCE:
		var industrial_away: Vector2 = point - _industrial_objective.global_position
		if industrial_away.length() < 0.001:
			industrial_away = Vector2.LEFT
		point = _industrial_objective.global_position + industrial_away.normalized() * RED_RENDEZVOUS_CLEARANCE
	return _navigation.clamp_to_walkable(point)

func _can_reach(unit: BattleFormation, point: Vector2) -> bool:
	if unit.global_position.distance_to(point) <= ARRIVAL_TOLERANCE:
		return true
	return not _navigation.find_path(unit.global_position, point).is_empty()

func _maintain_red_rendezvous() -> void:
	if _red_resupply_target == null or _red_resupply_truck == null or _red_resupply_phase != "MOVING":
		return
	_red_resupply_target.clear_combat_target()
	_red_resupply_truck.clear_combat_target()
	var target_arrived: bool = _red_resupply_target.global_position.distance_to(_red_resupply_rendezvous) <= ARRIVAL_TOLERANCE
	var truck_arrived: bool = _red_resupply_truck.global_position.distance_to(_red_resupply_rendezvous) <= ARRIVAL_TOLERANCE

	if not target_arrived:
		_ensure_red_move(_red_resupply_target, _red_resupply_rendezvous)
	elif _red_resupply_target.has_active_navigation_path():
		_red_resupply_target.stop()
	if not truck_arrived:
		_ensure_red_move(_red_resupply_truck, _red_resupply_rendezvous)
	elif _red_resupply_truck.has_active_navigation_path():
		_red_resupply_truck.stop()

	if target_arrived and truck_arrived:
		_red_resupply_target.stop()
		_red_resupply_truck.stop()
		_set_state(_red_resupply_target, HOLD)
		_set_state(_red_resupply_truck, SUPPORT)
		_red_resupply_phase = "TRANSFERRING"
		_red_resupply_progress = 0.0
		_red_truck_damage_serial = _red_resupply_truck.get_damage_serial()
		_red_target_damage_serial = _red_resupply_target.get_damage_serial()
		_red_target_fire_serial = _red_resupply_target.get_fire_serial()
		_red_target_ammo_before = _red_resupply_target.current_ammo
		_red_charge_before = _red_resupply_truck.get_supply_charges()
		print("FRONTLINE_RED_RESUPPLY_TRANSFER_BEGIN target=%s charges=%d duration=4.0" % [_red_resupply_target.display_name, _red_charge_before])

func _ensure_red_move(unit: BattleFormation, destination: Vector2) -> void:
	var needs_order: bool = true
	if unit.has_active_navigation_path():
		var path: PackedVector2Array = unit.get_navigation_path()
		if not path.is_empty() and path[path.size() - 1].distance_to(destination) <= ARRIVAL_TOLERANCE:
			needs_order = false
	if needs_order:
		_issue_move(unit, destination, MOVE)

func _update_red_resupply(delta: float) -> void:
	if _red_resupply_phase != "TRANSFERRING":
		return
	var interrupt_reason: String = _red_transfer_interrupt_reason()
	if not interrupt_reason.is_empty():
		var truck: BattleFormation = _red_resupply_truck
		var threat: BattleFormation = _nearest_confirmed_threat(truck.global_position, RED_LOCAL_THREAT_RADIUS) if truck != null and truck.is_alive else null
		_cancel_red_resupply(interrupt_reason)
		if truck != null and truck.is_alive and threat != null:
			print("FRONTLINE_RED_RESUPPLY_EVADE_OVERRIDE reason=%s" % interrupt_reason)
			_evade_supply(truck, threat)
		return

	_red_resupply_progress = minf(RED_SUPPLY_DURATION, _red_resupply_progress + delta)
	if _red_resupply_progress < RED_SUPPLY_DURATION:
		return

	var target: BattleFormation = _red_resupply_target
	var truck: BattleFormation = _red_resupply_truck
	var target_name: String = target.display_name
	var hp_before: int = target.current_hp
	var ammo_before: int = target.current_ammo
	var restore_amount: int = maxi(1, int(round(float(target.ammo_capacity) * RED_SUPPLY_RESTORE_FRACTION)))
	var restored: int = target.restore_ammo(restore_amount)
	var consumed: bool = truck.consume_supply_charge()
	if not consumed:
		push_error("RED resupply completed without a valid Supply charge.")
		_cancel_red_resupply("Supply charge unavailable")
		return
	var remaining: int = truck.get_supply_charges()
	print("FRONTLINE_RED_RESUPPLY_COMPLETE target=%s ammo=%d->%d restored=%d hp=%d charges=%d" % [
		target_name,
		ammo_before,
		target.current_ammo,
		restored,
		hp_before,
		remaining,
	])
	_clear_red_resupply_state()
	if target.is_alive:
		_return_unit(target)
	if truck.is_alive:
		_return_unit(truck)

func _red_transfer_interrupt_reason() -> String:
	if _match_finished:
		return "Match ended"
	if _red_resupply_truck == null or not is_instance_valid(_red_resupply_truck) or not _red_resupply_truck.is_alive:
		return "Supply destroyed"
	if _red_resupply_target == null or not is_instance_valid(_red_resupply_target) or not _red_resupply_target.is_alive:
		return "Target destroyed"
	if _red_resupply_truck.get_supply_charges() <= 0:
		return "No Supply charges"
	if _is_objective_emergency() or _is_final_objective_pressure():
		return "Objective emergency"
	if _red_resupply_truck.get_damage_serial() != _red_truck_damage_serial:
		return "Supply under fire"
	if _red_resupply_target.get_damage_serial() != _red_target_damage_serial:
		return "Target under fire"
	if _red_resupply_target.get_fire_serial() != _red_target_fire_serial:
		return "Target fired"
	if _red_resupply_truck.get_order() != HOLD or _red_resupply_target.get_order() != HOLD:
		return "Movement interrupted transfer"
	if _red_resupply_truck.global_position.distance_to(_red_resupply_target.global_position) > RED_SUPPLY_RANGE:
		return "Out of Supply range"
	if _nearest_confirmed_threat(_red_resupply_truck.global_position, RED_LOCAL_THREAT_RADIUS) != null:
		return "Confirmed threat near Supply"
	if _nearest_confirmed_threat(_red_resupply_target.global_position, RED_TARGET_LULL_RADIUS) != null:
		return "Confirmed threat near target"
	return ""

func _red_resupply_abort_reason() -> String:
	if _red_resupply_truck == null or not is_instance_valid(_red_resupply_truck) or not _red_resupply_truck.is_alive:
		return "Supply destroyed"
	if _red_resupply_target == null or not is_instance_valid(_red_resupply_target) or not _red_resupply_target.is_alive:
		return "Target destroyed"
	if _red_resupply_truck.get_supply_charges() <= 0:
		return "No Supply charges"
	if _is_objective_emergency() or _is_final_objective_pressure():
		return "Objective emergency"
	if _red_recently_damaged(_red_resupply_truck) or _red_recently_damaged(_red_resupply_target):
		return "Recent damage"
	if _nearest_confirmed_threat(_red_resupply_truck.global_position, RED_LOCAL_THREAT_RADIUS) != null:
		return "Confirmed threat near Supply"
	if _nearest_confirmed_threat(_red_resupply_target.global_position, RED_TARGET_LULL_RADIUS) != null:
		return "Confirmed threat near target"
	return ""

func _red_recently_damaged(unit: BattleFormation) -> bool:
	if unit == null or not _agents.has(unit):
		return false
	return _elapsed - float((_agents[unit] as Dictionary)["last_damage_time"]) < RED_RECENT_DAMAGE_TIME

func _is_active_red_agent(unit: BattleFormation) -> bool:
	if unit == null or not is_instance_valid(unit) or not unit.is_alive or not _agents.has(unit):
		return false
	return bool((_agents[unit] as Dictionary)["active"])

func _cancel_red_resupply(reason: String) -> void:
	if _red_resupply_target == null:
		return
	var target_name: String = _red_resupply_target.display_name if is_instance_valid(_red_resupply_target) else "NONE"
	var truck_name: String = _red_resupply_truck.display_name if _red_resupply_truck != null and is_instance_valid(_red_resupply_truck) else "NONE"
	var remaining: int = _red_resupply_truck.get_supply_charges() if _red_resupply_truck != null and is_instance_valid(_red_resupply_truck) else 0
	print("FRONTLINE_RED_RESUPPLY_CANCELLED target=%s supplier=%s reason=%s progress=%.2f charges=%d" % [target_name, truck_name, reason, _red_resupply_progress, remaining])
	_clear_red_resupply_state()

func _clear_red_resupply_state() -> void:
	_red_resupply_target = null
	_red_resupply_truck = null
	_red_resupply_phase = "IDLE"
	_red_resupply_rendezvous = Vector2.ZERO
	_red_resupply_progress = 0.0
	_red_truck_damage_serial = 0
	_red_target_damage_serial = 0
	_red_target_fire_serial = 0
	_red_target_ammo_before = 0
	_red_charge_before = 0
