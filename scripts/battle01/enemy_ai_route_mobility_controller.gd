class_name BattleEnemyAIRouteMobilityController
extends BattleEnemyAILogisticsController

# Route-identity correction: all gameplay-critical navigation decisions in the live
# Enemy AI bind mobility to the Formation issuing the move. Generic Navigation
# queries remain available for geometry/tools, but are not used to infer this mover.

func _choose_final_objective_target(unit: BattleFormation) -> BattleFormation:
	var best: BattleFormation = null
	var best_priority: int = 999
	var best_distance: float = INF
	for candidate: BattleFormation in _blue:
		if candidate == null or not candidate.is_alive or not _intel.has(candidate):
			continue
		if str((_intel[candidate] as Dictionary)["state"]) != CONFIRMED:
			continue
		var priority: int = 999
		if candidate.is_capture_capable() and candidate.global_position.distance_to(_industrial_objective.global_position) <= _industrial_objective.capture_radius:
			priority = 1
		else:
			var agent: Dictionary = _agents[unit]
			var recent_attacker: BattleFormation = agent["recent_attacker"] as BattleFormation
			if recent_attacker == candidate and _elapsed - float(agent["recent_attacker_time"]) <= 3.0:
				priority = 2
			elif candidate.global_position.distance_to(_industrial_objective.global_position) <= DEFENSE_RADIUS:
				priority = 3
		if priority >= 999:
			continue
		var distance: float = _path_distance_for_unit(unit, candidate.global_position)
		if distance >= INF:
			continue
		if best == null or priority < best_priority or (priority == best_priority and distance < best_distance - ROUTE_EPSILON) or (priority == best_priority and absf(distance - best_distance) <= ROUTE_EPSILON and candidate.display_name < best.display_name):
			best = candidate
			best_priority = priority
			best_distance = distance
	return best

func _choose_target(unit: BattleFormation, objective_only: bool) -> BattleFormation:
	var best: BattleFormation = null
	var best_priority: int = 999
	var best_distance: float = INF
	for candidate: BattleFormation in _blue:
		if candidate == null or not candidate.is_alive or not _intel.has(candidate):
			continue
		var record: Dictionary = _intel[candidate]
		if str(record["state"]) != CONFIRMED:
			continue
		var priority: int = _target_priority(unit, candidate)
		if objective_only and priority != 1:
			continue
		if priority >= 999:
			continue
		var distance: float = _path_distance_for_unit(unit, candidate.global_position)
		if distance >= INF:
			continue
		if best == null or priority < best_priority or (priority == best_priority and distance < best_distance - ROUTE_EPSILON) or (priority == best_priority and absf(distance - best_distance) <= ROUTE_EPSILON and candidate.display_name < best.display_name):
			best = candidate
			best_priority = priority
			best_distance = distance
	return best

func _issue_move(unit: BattleFormation, destination: Vector2, ai_state: String) -> bool:
	var mobility: String = _navigation.mobility_for_formation(unit)
	var clamped: Vector2 = _navigation.clamp_to_walkable_for_mobility(destination, mobility)
	var route: String = _select_route_name_for_unit(unit, clamped)
	var agent: Dictionary = _agents[unit]
	agent["route"] = route
	_agents[unit] = agent
	_set_state(unit, ai_state)
	var issued: bool = unit.issue_move(clamped)
	if issued:
		print("FRONTLINE_AI_MOVE unit=%s state=%s route=%s destination=%s mobility=%s" % [unit.display_name, ai_state, route, clamped, mobility])
	return issued

func _can_reach(unit: BattleFormation, point: Vector2) -> bool:
	if unit.global_position.distance_to(point) <= ARRIVAL_TOLERANCE:
		return true
	return not _navigation.find_path_for_formation(unit, point).is_empty()

func _path_distance_for_unit(unit: BattleFormation, to_world: Vector2) -> float:
	var path: PackedVector2Array = _navigation.find_path_for_formation(unit, to_world)
	if path.is_empty():
		return INF
	return _navigation.get_path_length(path)

func _select_route_name_for_unit(unit: BattleFormation, to_world: Vector2) -> String:
	var costs: Dictionary = {
		"central": _route_cost_for_unit(&"central", unit, to_world),
		"north": _route_cost_for_unit(&"north", unit, to_world),
		"south": _route_cost_for_unit(&"south", unit, to_world),
	}
	return _choose_route_from_costs(costs)

func _route_cost_for_unit(route_name: StringName, unit: BattleFormation, to_world: Vector2) -> float:
	var mobility: String = _navigation.mobility_for_formation(unit)
	var route: PackedVector2Array = _navigation.get_named_route_for_mobility(route_name, mobility)
	if route.is_empty():
		return INF
	var from_world: Vector2 = unit.global_position
	var from_index: int = _nearest_route_index(route, from_world)
	var to_index: int = _nearest_route_index(route, to_world)
	var start_path: PackedVector2Array = _navigation.find_path_for_mobility(from_world, route[from_index], mobility)
	var end_path: PackedVector2Array = _navigation.find_path_for_mobility(route[to_index], to_world, mobility)
	if start_path.is_empty() or end_path.is_empty():
		return INF
	var cost: float = _navigation.get_path_length(start_path) + _navigation.get_path_length(end_path)
	var low: int = mini(from_index, to_index)
	var high: int = maxi(from_index, to_index)
	for index: int in range(low + 1, high + 1):
		cost += route[index - 1].distance_to(route[index])
	return cost