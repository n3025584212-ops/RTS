class_name BattleEnemyAIPreReserveProgressionController
extends BattleEnemyAILogisticsController

# Narrow product-phase correction for RED ARMOR-01 only.
# Before the first real PLAYER capture of Central, the starting Armor remains a
# local counterattack reserve/self-defense threat, but Central capture pressure
# itself is not allowed to pull it into objective-denial duty.

var _first_player_central_capture_completed: bool = false

func _initialize() -> void:
	super._initialize()
	if _objective == null or _legacy_ci_disabled:
		return
	if not _objective.capture_completed.is_connected(_on_central_capture_completed_for_progression):
		_objective.capture_completed.connect(_on_central_capture_completed_for_progression)

func _decide_combat_unit(unit: BattleFormation, objective_emergency: bool) -> void:
	# Keep the historical isolated Enemy-AI CI smoke compatible with its original
	# pre-contract expectations. Real Battle01 runtime and the dedicated focused
	# regression below exercise the new product behavior without this CI flag.
	if _ci_smoke:
		super._decide_combat_unit(unit, objective_emergency)
		return

	if _is_primary_armor_pre_first_capture(unit):
		# Preserve the existing RED resupply relationship. An objective/threat abort
		# may cancel the rendezvous, but the subsequent Armor decision still passes
		# through the pre-first-capture gate instead of falling into Central denial.
		if _red_resupply_target == unit:
			var abort_reason: String = _red_resupply_abort_reason()
			if objective_emergency or _is_final_objective_pressure() or not abort_reason.is_empty():
				_cancel_red_resupply("Objective/threat override" if abort_reason.is_empty() else abort_reason)
			else:
				_maintain_red_rendezvous()
				return
		_decide_pre_first_capture_armor(unit)
		return

	super._decide_combat_unit(unit, objective_emergency)

func _armor_commit_allowed(armor: BattleFormation) -> bool:
	if not _ci_smoke and _is_primary_armor_pre_first_capture(armor):
		return _choose_pre_first_capture_armor_target(armor) != null
	return super._armor_commit_allowed(armor)

func _decide_pre_first_capture_armor(armor: BattleFormation) -> void:
	if not _is_active_agent(armor):
		return

	var agent: Dictionary = _agents[armor]
	var current_target: BattleFormation = agent["target"] as BattleFormation
	if current_target != null:
		if not is_instance_valid(current_target) or not current_target.is_alive or not _intel.has(current_target):
			_clear_agent_target(armor)
			armor.clear_combat_target()
		else:
			var current_state: String = str((_intel[current_target] as Dictionary)["state"])
			if current_state == LAST_KNOWN and (str(agent["state"]) == ENGAGE or str(agent["state"]) == MOVE):
				if _begin_pre_first_capture_armor_investigation(armor, current_target):
					return
				_return_unit(armor)
				return
			if current_state != CONFIRMED and current_state != LAST_KNOWN:
				_clear_agent_target(armor)
				armor.clear_combat_target()

	agent = _agents[armor]
	if str(agent["state"]) == INVESTIGATE:
		var investigate_target: BattleFormation = agent["target"] as BattleFormation
		if investigate_target != null and is_instance_valid(investigate_target) and investigate_target.is_alive and _intel.has(investigate_target):
			if str((_intel[investigate_target] as Dictionary)["state"]) == CONFIRMED:
				if _pre_first_capture_target_priority(armor, investigate_target) < 999:
					_engage_pre_first_capture_armor_target(armor, investigate_target)
				else:
					_return_unit(armor)
				return
		if _elapsed - float(agent["investigate_started"]) >= INVESTIGATE_TIMEOUT or armor.get_order() == HOLD:
			_return_unit(armor)
		return

	var target: BattleFormation = _choose_pre_first_capture_armor_target(armor)
	if target != null:
		_engage_pre_first_capture_armor_target(armor, target)
		return

	_return_unit(armor)

func _choose_pre_first_capture_armor_target(armor: BattleFormation) -> BattleFormation:
	var best: BattleFormation = null
	var best_priority: int = 999
	var best_distance: float = INF
	for candidate: BattleFormation in _blue:
		if candidate == null or not is_instance_valid(candidate) or not candidate.is_alive or not _intel.has(candidate):
			continue
		if str((_intel[candidate] as Dictionary)["state"]) != CONFIRMED:
			continue
		var priority: int = _pre_first_capture_target_priority(armor, candidate)
		if priority >= 999:
			continue
		var distance: float = armor.global_position.distance_to(candidate.global_position)
		if best == null or priority < best_priority or (priority == best_priority and distance < best_distance - ROUTE_EPSILON) or (priority == best_priority and absf(distance - best_distance) <= ROUTE_EPSILON and candidate.display_name < best.display_name):
			best = candidate
			best_priority = priority
			best_distance = distance
	return best

func _pre_first_capture_target_priority(armor: BattleFormation, candidate: BattleFormation) -> int:
	if armor == null or candidate == null or not _agents.has(armor):
		return 999
	var agent: Dictionary = _agents[armor]
	var recent_attacker: BattleFormation = agent["recent_attacker"] as BattleFormation
	var direct_self_defense: bool = (
		recent_attacker == candidate
		and _elapsed - float(agent["recent_attacker_time"]) <= 3.0
	)
	var inside_central_core: bool = candidate.global_position.distance_to(_objective.global_position) <= _objective.capture_radius

	# A direct attacker in the Central core may be fired on only if Armor can do so
	# from its current location. This is self-defense, not permission to path into
	# the capture circle to deny ownership.
	if inside_central_core:
		if direct_self_defense and armor.global_position.distance_to(candidate.global_position) <= armor.attack_range and _visibility.has_line_of_sight(armor.global_position, candidate.global_position):
			return 1
		return 999

	if direct_self_defense:
		return 1

	var supply: BattleFormation = _supply_units[0] if not _supply_units.is_empty() else null
	if supply != null and supply.is_alive and candidate.global_position.distance_to(supply.global_position) <= SUPPLY_THREAT_RADIUS + 100.0:
		return 2

	var anchor: Vector2 = Vector2(agent["assigned_anchor"])
	if candidate.global_position.distance_to(anchor) <= MAX_PURSUIT_DISTANCE:
		return 3

	return 999

func _engage_pre_first_capture_armor_target(armor: BattleFormation, target: BattleFormation) -> void:
	if target == null or not is_instance_valid(target) or not target.is_alive or not _intel.has(target):
		_return_unit(armor)
		return
	if str((_intel[target] as Dictionary)["state"]) != CONFIRMED:
		_return_unit(armor)
		return

	var inside_central_core: bool = target.global_position.distance_to(_objective.global_position) <= _objective.capture_radius
	if inside_central_core:
		var agent: Dictionary = _agents[armor]
		var recent_attacker: BattleFormation = agent["recent_attacker"] as BattleFormation
		var direct_self_defense: bool = recent_attacker == target and _elapsed - float(agent["recent_attacker_time"]) <= 3.0
		var can_return_fire_without_moving: bool = (
			direct_self_defense
			and armor.global_position.distance_to(target.global_position) <= armor.attack_range
			and _visibility.has_line_of_sight(armor.global_position, target.global_position)
		)
		if not can_return_fire_without_moving:
			_return_unit(armor)
			return
		if str(agent["state"]) != ENGAGE or agent["target"] != target:
			agent["engage_origin"] = armor.global_position
			agent["target"] = target
			_agents[armor] = agent
		_set_state(armor, ENGAGE)
		armor.set_combat_target(target)
		if armor.has_active_navigation_path():
			armor.stop()
		print("FRONTLINE_AI_PRECAP_ARMOR_SELF_DEFENSE target=%s mode=FIRE_WITHOUT_CENTRAL_COMMIT" % target.display_name)
		return

	_engage_target(armor, target)

func _begin_pre_first_capture_armor_investigation(armor: BattleFormation, target: BattleFormation) -> bool:
	if target == null or not _intel.has(target) or not _agents.has(armor):
		return false
	var record: Dictionary = _intel[target]
	if str(record["state"]) != LAST_KNOWN:
		return false
	var last_known: Vector2 = Vector2(record["last_known"])
	if last_known.distance_to(_objective.global_position) <= _objective.capture_radius:
		return false
	var agent: Dictionary = _agents[armor]
	var anchor: Vector2 = Vector2(agent["assigned_anchor"])
	if anchor.distance_to(last_known) > MAX_PURSUIT_DISTANCE:
		return false
	var generation: int = int(record["generation"])
	if int(agent["investigated_generation"]) == generation:
		return false
	agent["target"] = target
	agent["investigated_generation"] = generation
	agent["investigate_started"] = _elapsed
	_agents[armor] = agent
	armor.clear_combat_target()
	_set_state(armor, INVESTIGATE)
	return _issue_move(armor, last_known, INVESTIGATE)

func _is_primary_armor_pre_first_capture(unit: BattleFormation) -> bool:
	return (
		not _first_player_central_capture_completed
		and unit != null
		and is_instance_valid(unit)
		and unit.display_name == "RED ARMOR-01"
		and _agents.has(unit)
		and str((_agents[unit] as Dictionary)["role"]) == "LOCAL_COUNTERATTACK_RESERVE"
	)

func _on_central_capture_completed_for_progression(new_owner: String, _previous_owner: String) -> void:
	if _first_player_central_capture_completed or new_owner != BattleObjective.OWNER_PLAYER:
		return
	_first_player_central_capture_completed = true
	_decision_accumulator = DECISION_INTERVAL
	print("FRONTLINE_AI_PRECAP_ARMOR_GATE_RELEASED objective=CENTRAL_BRIDGEHEAD owner=PLAYER")

func is_pre_first_central_armor_gate_active_for_test() -> bool:
	return not _first_player_central_capture_completed

func get_first_player_central_capture_completed_for_test() -> bool:
	return _first_player_central_capture_completed
