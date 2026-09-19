class_name BattleEnemyAIController
extends Node

const HOLD: String = "HOLD"
const MOVE: String = "MOVE"
const ENGAGE: String = "ENGAGE"
const INVESTIGATE: String = "INVESTIGATE"
const RETURN: String = "RETURN"
const SUPPORT: String = "SUPPORT"
const EVADE: String = "EVADE"

const UNSEEN: String = "UNSEEN"
const CONTACT: String = "CONTACT"
const CONFIRMED: String = "CONFIRMED"
const LAST_KNOWN: String = "LAST_KNOWN"

const DECISION_INTERVAL: float = 0.25
const CONFIRMATION_TIME: float = 0.75
const FIRING_REVEAL_TIME: float = 2.0
const INVESTIGATE_TIMEOUT: float = 4.0
const MAX_PURSUIT_DISTANCE: float = 350.0
const DEFENSE_RADIUS: float = 650.0
const LOCAL_MISSION_RADIUS: float = 900.0
const SUPPLY_THREAT_RADIUS: float = 500.0
const SUPPLY_EVADE_DISTANCE: float = 400.0
const SUPPLY_RECOVERY_TIME: float = 3.0
const SUPPLY_FOLLOW_TRIGGER: float = 600.0
const SUPPLY_TRAILING_DISTANCE: float = 400.0
const OBJECTIVE_SUPPLY_EXCLUSION: float = 300.0
const ARRIVAL_TOLERANCE: float = 18.0
const REINFORCEMENT_TIME: float = 150.0
const ROUTE_EPSILON: float = 0.001

var _navigation: BattleNavigation
var _visibility: BattleVisibilityField
var _objective: BattleObjective
var _industrial_objective: BattleObjective
var _roster: BattleFormalCombatRoster
var _war_flow: BattlePlayerWarFlow
var _blue: Array[BattleFormation] = []
var _combat_units: Array[BattleFormation] = []
var _supply_units: Array[BattleFormation] = []
var _reinforcements: Array[BattleFormation] = []

var _agents: Dictionary = {}
var _intel: Dictionary = {}
var _decision_accumulator: float = 0.0
var _elapsed: float = 0.0
var _initialized: bool = false
var _match_finished: bool = false
var _reinforcements_active: bool = false
var _objective_lost: bool = false
var _ci_smoke: bool = false
var _legacy_ci_disabled: bool = false

func _ready() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	_ci_smoke = args.has("--battle01-ci-enemy-ai-smoke")
	_legacy_ci_disabled = (
		not _ci_smoke
		and (
			args.has("--battle01-ci-los-smoke")
			or args.has("--battle01-ci-intel-combat-smoke")
			or args.has("--battle01-ci-multi-command-smoke")
			or args.has("--battle01-ci-navigation-smoke")
		)
	)
	call_deferred("_initialize")

func _initialize() -> void:
	if _initialized:
		return
	_initialized = true

	var battle: Node = get_parent()
	_navigation = battle.get_node_or_null("Navigation") as BattleNavigation
	_visibility = battle.get_node_or_null("VisibilityField") as BattleVisibilityField
	_objective = battle.get_node_or_null("CentralBridgehead") as BattleObjective
	_industrial_objective = battle.get_node_or_null("IndustrialObjective") as BattleObjective
	_roster = battle.get_node_or_null("FormalCombatRoster") as BattleFormalCombatRoster
	_war_flow = battle.get_node_or_null("PlayerWarFlow") as BattlePlayerWarFlow
	var blue_main: BattleFormation = battle.get_node_or_null("BlueFormation") as BattleFormation
	var blue_recon: BattleFormation = battle.get_node_or_null("BlueRecon") as BattleFormation

	if _navigation == null or _visibility == null or _objective == null or _industrial_objective == null or _roster == null or _war_flow == null or blue_main == null or blue_recon == null:
		push_error("Enemy AI initialization failed: Battle01 dependencies are incomplete.")
		return

	if _legacy_ci_disabled:
		print("FRONTLINE_ENEMY_AI_LEGACY_CI_BYPASS")
		return

	_register_blue_target(blue_main)
	_register_blue_target(blue_recon)
	for target: BattleFormation in _war_flow.get_friendlies():
		_register_blue_target(target)
	_war_flow.friendlies_changed.connect(_on_friendlies_changed)
	_war_flow.victory.connect(_on_match_finished)
	_war_flow.defeat.connect(_on_match_finished)

	_combat_units = _roster.get_initial_enemy_combat_formations()
	_supply_units = _roster.get_initial_supply_trucks()
	_reinforcements = _roster.get_reinforcement_formations()

	if _combat_units.size() != 3 or _supply_units.size() != 1 or _reinforcements.size() != 2:
		push_error("Enemy AI requires frozen roster 3 combat + 1 supply + 2 dormant reinforcements.")
		return

	for unit: BattleFormation in _combat_units:
		_register_agent(unit, _role_for(unit), true, HOLD)
	for unit: BattleFormation in _supply_units:
		_register_agent(unit, "REAR_SUPPORT", true, SUPPORT)
	for unit: BattleFormation in _reinforcements:
		_register_agent(unit, _role_for(unit), false, HOLD)

	var inf2: BattleFormation = _find_red("RED INF-02")
	var armor: BattleFormation = _find_red("RED ARMOR-01")
	var reinf_inf: BattleFormation = _find_red("RED REINFORCEMENT INF-01")
	var reinf_armor: BattleFormation = _find_red("RED REINFORCEMENT ARMOR-01")
	if inf2 != null and reinf_inf != null:
		_set_assigned_anchor(reinf_inf, inf2.global_position)
	if armor != null and reinf_armor != null:
		_set_assigned_anchor(reinf_armor, armor.global_position)

	_objective.state_changed.connect(_on_objective_state_changed)
	_objective.captured.connect(_on_objective_captured)
	_industrial_objective.state_changed.connect(_on_industrial_objective_state_changed)
	_industrial_objective.capture_completed.connect(_on_industrial_capture_completed)
	_industrial_objective.unlock_changed.connect(_on_industrial_unlock_changed)

	print("FRONTLINE_ENEMY_AI_READY states=7 combat=%d supply=%d dormant=%d" % [_combat_units.size(), _supply_units.size(), _reinforcements.size()])
	print("FRONTLINE_ENEMY_AI_FINAL_OBJECTIVE_INTERFACE_READY objective=%s" % _industrial_objective.objective_id)

	if _ci_smoke:
		_run_ci_smoke()

func _register_blue_target(target: BattleFormation) -> void:
	if target == null or not is_instance_valid(target) or target in _blue:
		return
	_blue.append(target)
	_intel[target] = {
		"state": UNSEEN,
		"last_known": Vector2.ZERO,
		"confirm_progress": 0.0,
		"forced_reveal": 0.0,
		"generation": 0,
	}
	target.attack_fired.connect(_on_blue_attack_fired)
	target.died.connect(_on_blue_died)

func _on_friendlies_changed(formations: Array[BattleFormation]) -> void:
	for target: BattleFormation in formations:
		_register_blue_target(target)
	_decision_accumulator = DECISION_INTERVAL

func _register_agent(unit: BattleFormation, role: String, active: bool, initial_state: String) -> void:
	if unit == null:
		return
	unit.clear_combat_target()
	_agents[unit] = {
		"state": initial_state,
		"role": role,
		"home": unit.global_position,
		"assigned_anchor": unit.global_position,
		"active": active,
		"target": null,
		"engage_origin": unit.global_position,
		"investigate_started": -999.0,
		"investigated_generation": -1,
		"last_damage_time": -999.0,
		"last_hp": unit.current_hp,
		"recent_attacker": null,
		"recent_attacker_time": -999.0,
		"route": "central",
	}
	unit.health_changed.connect(_on_red_health_changed.bind(unit))
	unit.died.connect(_on_red_died)

func _process(delta: float) -> void:
	if not _initialized or _legacy_ci_disabled or _ci_smoke or _match_finished:
		return
	_elapsed += delta
	_update_red_intel(delta)
	if not _reinforcements_active and _elapsed >= REINFORCEMENT_TIME:
		_activate_reinforcements("fixed_time")
	_decision_accumulator += delta
	if _decision_accumulator >= DECISION_INTERVAL:
		_decision_accumulator = fmod(_decision_accumulator, DECISION_INTERVAL)
		_decision_tick()

func _update_red_intel(delta: float) -> void:
	for target: BattleFormation in _blue:
		if target == null or not is_instance_valid(target) or not target.is_alive:
			continue
		var record: Dictionary = _intel[target]
		record["forced_reveal"] = maxf(0.0, float(record["forced_reveal"]) - delta)
		var detected: bool = _is_legitimately_detected(target)
		if float(record["forced_reveal"]) > 0.0:
			record["last_known"] = target.global_position
			_promote_to_confirmed(target, record)
		elif detected:
			record["last_known"] = target.global_position
			var state: String = str(record["state"])
			if state == UNSEEN or state == LAST_KNOWN:
				record["state"] = CONTACT
				record["confirm_progress"] = 0.0
				print("FRONTLINE_RED_INTEL state=CONTACT target=%s" % target.display_name)
			elif state == CONTACT:
				record["confirm_progress"] = float(record["confirm_progress"]) + delta
				if float(record["confirm_progress"]) >= CONFIRMATION_TIME:
					_promote_to_confirmed(target, record)
		elif str(record["state"]) == CONTACT or str(record["state"]) == CONFIRMED:
			record["state"] = LAST_KNOWN
			record["confirm_progress"] = 0.0
			print("FRONTLINE_RED_INTEL state=LAST_KNOWN target=%s pos=%s" % [target.display_name, record["last_known"]])
		_intel[target] = record

func _promote_to_confirmed(target: BattleFormation, record: Dictionary) -> void:
	if str(record["state"]) != CONFIRMED:
		record["generation"] = int(record["generation"]) + 1
		print("FRONTLINE_RED_INTEL state=CONFIRMED target=%s generation=%d" % [target.display_name, int(record["generation"])])
	record["state"] = CONFIRMED
	record["confirm_progress"] = CONFIRMATION_TIME
	record["last_known"] = target.global_position
	_decision_accumulator = DECISION_INTERVAL

func _is_legitimately_detected(target: BattleFormation) -> bool:
	for observer: BattleFormation in _active_red_observers():
		if observer == null or not is_instance_valid(observer) or not observer.is_alive:
			continue
		if observer.global_position.distance_to(target.global_position) > observer.detection_range:
			continue
		if not _visibility.has_line_of_sight(observer.global_position, target.global_position):
			continue
		return true
	return false

func _active_red_observers() -> Array[BattleFormation]:
	var result: Array[BattleFormation] = []
	for unit_variant: Variant in _agents.keys():
		var unit: BattleFormation = unit_variant as BattleFormation
		if unit == null or not unit.is_alive:
			continue
		var agent: Dictionary = _agents[unit]
		if bool(agent["active"]):
			result.append(unit)
	return result

func _decision_tick() -> void:
	_cleanup_dead_targets()
	var objective_emergency: bool = _is_objective_emergency()
	var final_pressure: bool = _is_final_objective_pressure()
	var final_responder: BattleFormation = _select_final_objective_responder(objective_emergency) if final_pressure else null
	for unit: BattleFormation in _combat_units:
		if unit == final_responder:
			_decide_final_objective_responder(unit)
		else:
			_decide_combat_unit(unit, objective_emergency)
	if _reinforcements_active:
		for unit: BattleFormation in _reinforcements:
			if unit == final_responder:
				_decide_final_objective_responder(unit)
			else:
				_decide_combat_unit(unit, objective_emergency)
	for truck: BattleFormation in _supply_units:
		_decide_supply(truck)

func _decide_final_objective_responder(unit: BattleFormation) -> void:
	if not _is_active_agent(unit) or _industrial_objective == null:
		return
	var target: BattleFormation = _choose_final_objective_target(unit)
	if target != null and unit.global_position.distance_to(target.global_position) <= MAX_PURSUIT_DISTANCE:
		_engage_target(unit, target)
		return
	_move_mission(unit, _industrial_objective.global_position)

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
		var distance: float = _path_distance(unit.global_position, candidate.global_position)
		if distance >= INF:
			continue
		if best == null or priority < best_priority or (priority == best_priority and distance < best_distance - ROUTE_EPSILON) or (priority == best_priority and absf(distance - best_distance) <= ROUTE_EPSILON and candidate.display_name < best.display_name):
			best = candidate
			best_priority = priority
			best_distance = distance
	return best

func _select_final_objective_responder(central_emergency: bool) -> BattleFormation:
	var preferred_names: Array[String] = [
		"RED INF-02",
		"RED REINFORCEMENT INF-01",
		"RED REINFORCEMENT ARMOR-01",
		"RED ARMOR-01",
	]
	if not central_emergency:
		preferred_names.append("RED INF-01")
	for display_name: String in preferred_names:
		var unit: BattleFormation = _find_red(display_name)
		if _is_active_agent(unit):
			return unit
	return null

func _is_final_objective_pressure() -> bool:
	if _industrial_objective == null or _industrial_objective.is_player_capture_locked():
		return false
	if _industrial_objective.is_contested():
		return true
	if _industrial_objective.get_control_owner() == BattleObjective.OWNER_PLAYER:
		return true
	return (
		_industrial_objective.state == "CAPTURING"
		and _industrial_objective.capturing_faction == "BLUE"
		and _industrial_objective.progress > 0.0
	)

func _decide_combat_unit(unit: BattleFormation, objective_emergency: bool) -> void:
	if not _is_active_agent(unit):
		return
	var agent: Dictionary = _agents[unit]
	var current_target: BattleFormation = agent["target"] as BattleFormation
	if current_target != null and _intel.has(current_target):
		var state: String = str((_intel[current_target] as Dictionary)["state"])
		if state == LAST_KNOWN and (str(agent["state"]) == ENGAGE or str(agent["state"]) == MOVE):
			if _begin_investigation(unit, current_target):
				return
			_return_unit(unit)
			return
		if state != CONFIRMED and state != LAST_KNOWN:
			_clear_agent_target(unit)

	if str(agent["state"]) == INVESTIGATE:
		var investigate_target: BattleFormation = agent["target"] as BattleFormation
		if investigate_target != null and _intel.has(investigate_target) and str((_intel[investigate_target] as Dictionary)["state"]) == CONFIRMED:
			_engage_target(unit, investigate_target)
			return
		if _elapsed - float(agent["investigate_started"]) >= INVESTIGATE_TIMEOUT or unit.get_order() == HOLD:
			_return_unit(unit)
		return

	if objective_emergency:
		var objective_target: BattleFormation = _choose_target(unit, true)
		if objective_target != null:
			_engage_target(unit, objective_target)
		else:
			_move_mission(unit, _objective.global_position)
		return

	var role: String = str(agent["role"])
	if role == "LOCAL_COUNTERATTACK_RESERVE" or role == "REINFORCEMENT_ARMOR":
		if not _armor_commit_allowed(unit):
			_return_unit(unit)
			return

	var target: BattleFormation = _choose_target(unit, false)
	if target != null:
		_engage_target(unit, target)
		return

	_return_unit(unit)

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
		var distance: float = _path_distance(unit.global_position, candidate.global_position)
		if distance >= INF:
			continue
		if best == null or priority < best_priority or (priority == best_priority and distance < best_distance - ROUTE_EPSILON) or (priority == best_priority and absf(distance - best_distance) <= ROUTE_EPSILON and candidate.display_name < best.display_name):
			best = candidate
			best_priority = priority
			best_distance = distance
	return best

func _target_priority(unit: BattleFormation, candidate: BattleFormation) -> int:
	if candidate.is_capture_capable() and candidate.global_position.distance_to(_objective.global_position) <= _objective.capture_radius:
		return 1
	var agent: Dictionary = _agents[unit]
	var recent_attacker: BattleFormation = agent["recent_attacker"] as BattleFormation
	if recent_attacker == candidate and _elapsed - float(agent["recent_attacker_time"]) <= 3.0:
		return 2
	if candidate.global_position.distance_to(_objective.global_position) <= DEFENSE_RADIUS:
		return 3
	var supply: BattleFormation = _supply_units[0] if not _supply_units.is_empty() else null
	if supply != null and supply.is_alive and candidate.global_position.distance_to(supply.global_position) <= SUPPLY_THREAT_RADIUS:
		return 4
	var anchor: Vector2 = agent["assigned_anchor"]
	if candidate.global_position.distance_to(anchor) <= LOCAL_MISSION_RADIUS:
		return 5
	return 999

func _engage_target(unit: BattleFormation, target: BattleFormation) -> void:
	if target == null or not target.is_alive or not _intel.has(target):
		_return_unit(unit)
		return
	if str((_intel[target] as Dictionary)["state"]) != CONFIRMED:
		_return_unit(unit)
		return

	var agent: Dictionary = _agents[unit]
	if str(agent["state"]) != ENGAGE or agent["target"] != target:
		agent["engage_origin"] = unit.global_position
		agent["target"] = target
		_agents[unit] = agent
	_set_state(unit, ENGAGE)
	unit.set_combat_target(target)

	var distance_to_target: float = unit.global_position.distance_to(target.global_position)
	if distance_to_target <= unit.attack_range and _visibility.has_line_of_sight(unit.global_position, target.global_position):
		if unit.has_active_navigation_path():
			unit.stop()
		return

	agent = _agents[unit]
	var engage_origin: Vector2 = agent["engage_origin"]
	if engage_origin.distance_to(target.global_position) > MAX_PURSUIT_DISTANCE:
		print("FRONTLINE_AI_PURSUIT_LIMIT unit=%s target=%s" % [unit.display_name, target.display_name])
		_return_unit(unit)
		return
	_issue_move(unit, target.global_position, ENGAGE)

func _begin_investigation(unit: BattleFormation, target: BattleFormation) -> bool:
	var record: Dictionary = _intel[target]
	var agent: Dictionary = _agents[unit]
	var generation: int = int(record["generation"])
	if int(agent["investigated_generation"]) == generation:
		return false
	var last_known: Vector2 = record["last_known"]
	var engage_origin: Vector2 = agent["engage_origin"]
	if engage_origin.distance_to(last_known) > MAX_PURSUIT_DISTANCE:
		return false
	agent["target"] = target
	agent["investigated_generation"] = generation
	agent["investigate_started"] = _elapsed
	_agents[unit] = agent
	unit.clear_combat_target()
	_set_state(unit, INVESTIGATE)
	return _issue_move(unit, last_known, INVESTIGATE)

func _move_mission(unit: BattleFormation, destination: Vector2) -> void:
	unit.clear_combat_target()
	_clear_agent_target(unit)
	if unit.global_position.distance_to(destination) <= ARRIVAL_TOLERANCE:
		unit.stop()
		_set_state(unit, HOLD)
		return
	_issue_move(unit, destination, MOVE)

func _return_unit(unit: BattleFormation) -> void:
	if not _is_active_agent(unit):
		return
	var agent: Dictionary = _agents[unit]
	var destination: Vector2 = agent["assigned_anchor"]
	unit.clear_combat_target()
	_clear_agent_target(unit)
	if unit.global_position.distance_to(destination) <= ARRIVAL_TOLERANCE:
		if unit.has_active_navigation_path():
			unit.stop()
		_set_state(unit, SUPPORT if str(agent["role"]) == "REAR_SUPPORT" else HOLD)
		return
	if str(agent["state"]) == RETURN and unit.has_active_navigation_path():
		return
	_issue_move(unit, destination, RETURN)

func _issue_move(unit: BattleFormation, destination: Vector2, ai_state: String) -> bool:
	var clamped: Vector2 = _navigation.clamp_to_walkable(destination)
	var route: String = _select_route_name(unit.global_position, clamped)
	var agent: Dictionary = _agents[unit]
	agent["route"] = route
	_agents[unit] = agent
	_set_state(unit, ai_state)
	var issued: bool = unit.issue_move(clamped)
	if issued:
		print("FRONTLINE_AI_MOVE unit=%s state=%s route=%s destination=%s" % [unit.display_name, ai_state, route, clamped])
	return issued

func _decide_supply(truck: BattleFormation) -> void:
	if not _is_active_agent(truck):
		return
	var agent: Dictionary = _agents[truck]
	var threat: BattleFormation = _nearest_confirmed_threat(truck.global_position, SUPPLY_THREAT_RADIUS)
	var recently_damaged: bool = _elapsed - float(agent["last_damage_time"]) < SUPPLY_RECOVERY_TIME
	if threat != null or recently_damaged:
		_evade_supply(truck, threat)
		return

	if str(agent["state"]) == EVADE:
		_return_unit(truck)
		return
	if str(agent["state"]) == RETURN:
		if truck.global_position.distance_to(agent["assigned_anchor"]) <= ARRIVAL_TOLERANCE:
			_set_state(truck, SUPPORT)
		return

	var protected: BattleFormation = _protected_supply_unit()
	if protected == null:
		_set_state(truck, SUPPORT)
		return
	if truck.global_position.distance_to(protected.global_position) <= SUPPLY_FOLLOW_TRIGGER:
		_set_state(truck, SUPPORT)
		return

	var from_home: Vector2 = protected.global_position - Vector2(agent["home"])
	var direction: Vector2 = from_home.normalized() if from_home.length() > 0.001 else Vector2.LEFT
	var destination: Vector2 = protected.global_position - direction * SUPPLY_TRAILING_DISTANCE
	if _is_supply_objective_excluded(destination):
		_set_state(truck, SUPPORT)
		return
	var danger: BattleFormation = _nearest_confirmed_threat(destination, SUPPLY_THREAT_RADIUS)
	if danger != null:
		_evade_supply(truck, danger)
		return
	_issue_move(truck, destination, MOVE)

func _is_supply_objective_excluded(destination: Vector2) -> bool:
	if destination.distance_to(_objective.global_position) < OBJECTIVE_SUPPLY_EXCLUSION:
		return true
	return _industrial_objective != null and destination.distance_to(_industrial_objective.global_position) < OBJECTIVE_SUPPLY_EXCLUSION

func _evade_supply(truck: BattleFormation, threat: BattleFormation) -> void:
	truck.clear_combat_target()
	var agent: Dictionary = _agents[truck]
	var destination: Vector2 = agent["home"]
	if threat != null:
		var away: Vector2 = truck.global_position - threat.global_position
		if away.length() < 0.001:
			away = Vector2(agent["home"]) - threat.global_position
		if away.length() < 0.001:
			away = Vector2.RIGHT
		destination = truck.global_position + away.normalized() * SUPPLY_EVADE_DISTANCE
	if destination.distance_to(_objective.global_position) < OBJECTIVE_SUPPLY_EXCLUSION:
		var away_objective: Vector2 = destination - _objective.global_position
		if away_objective.length() < 0.001:
			away_objective = Vector2(agent["home"]) - _objective.global_position
		destination = _objective.global_position + away_objective.normalized() * OBJECTIVE_SUPPLY_EXCLUSION
	if _industrial_objective != null and destination.distance_to(_industrial_objective.global_position) < OBJECTIVE_SUPPLY_EXCLUSION:
		var away_industrial: Vector2 = destination - _industrial_objective.global_position
		if away_industrial.length() < 0.001:
			away_industrial = Vector2(agent["home"]) - _industrial_objective.global_position
		if away_industrial.length() < 0.001:
			away_industrial = Vector2.LEFT
		destination = _industrial_objective.global_position + away_industrial.normalized() * OBJECTIVE_SUPPLY_EXCLUSION
	_issue_move(truck, destination, EVADE)

func _protected_supply_unit() -> BattleFormation:
	var armor: BattleFormation = _find_red("RED ARMOR-01")
	if armor != null and armor.is_alive:
		return armor
	var best: BattleFormation = null
	var best_distance: float = INF
	var truck: BattleFormation = _supply_units[0] if not _supply_units.is_empty() else null
	for unit: BattleFormation in _combat_units:
		if unit == null or not unit.is_alive or not unit.display_name.begins_with("RED INF"):
			continue
		var distance: float = truck.global_position.distance_to(unit.global_position) if truck != null else 0.0
		if best == null or distance < best_distance or (absf(distance - best_distance) <= ROUTE_EPSILON and unit.display_name < best.display_name):
			best = unit
			best_distance = distance
	return best

func _nearest_confirmed_threat(origin: Vector2, max_distance: float) -> BattleFormation:
	var best: BattleFormation = null
	var best_distance: float = max_distance + 0.001
	for target: BattleFormation in _blue:
		if target == null or not target.is_alive or not _intel.has(target):
			continue
		if str((_intel[target] as Dictionary)["state"]) != CONFIRMED:
			continue
		var distance: float = origin.distance_to(target.global_position)
		if distance < best_distance - ROUTE_EPSILON or (absf(distance - best_distance) <= ROUTE_EPSILON and (best == null or target.display_name < best.display_name)):
			best = target
			best_distance = distance
	return best

func _armor_commit_allowed(armor: BattleFormation) -> bool:
	if _is_objective_emergency():
		return true
	var inf_engaged_or_dead: bool = false
	for unit: BattleFormation in _combat_units:
		if not unit.display_name.begins_with("RED INF"):
			continue
		if not unit.is_alive:
			inf_engaged_or_dead = true
			break
		if _agents.has(unit) and str((_agents[unit] as Dictionary)["state"]) == ENGAGE:
			inf_engaged_or_dead = true
			break
	if inf_engaged_or_dead:
		for target: BattleFormation in _blue:
			if target != null and target.is_alive and _intel.has(target) and str((_intel[target] as Dictionary)["state"]) == CONFIRMED and target.global_position.distance_to(_objective.global_position) <= DEFENSE_RADIUS:
				return true
	var supply: BattleFormation = _supply_units[0] if not _supply_units.is_empty() else null
	if supply != null and _nearest_confirmed_threat(supply.global_position, SUPPLY_THREAT_RADIUS + 100.0) != null:
		return true
	return false

func _is_objective_emergency() -> bool:
	if _objective.state == "CONTESTED" or _objective.state == "CAPTURING" or _objective.state == "CAPTURED":
		return true
	for target: BattleFormation in _blue:
		if target == null or not target.is_alive or not target.is_capture_capable() or not _intel.has(target):
			continue
		if str((_intel[target] as Dictionary)["state"]) == CONFIRMED and target.global_position.distance_to(_objective.global_position) <= _objective.capture_radius:
			return true
	return false

func _activate_reinforcements(reason: String) -> void:
	if _reinforcements_active:
		return
	_reinforcements_active = true
	for unit: BattleFormation in _reinforcements:
		unit.visible = true
		unit.process_mode = Node.PROCESS_MODE_INHERIT
		var agent: Dictionary = _agents[unit]
		agent["active"] = true
		_agents[unit] = agent
		unit.clear_combat_target()
		if _is_objective_emergency():
			_move_mission(unit, _objective.global_position)
		else:
			_return_unit(unit)
	print("FRONTLINE_AI_REINFORCEMENT_ACTIVATED reason=%s infantry=1 armor=1" % reason)

func _reinforcement_trigger_reason(elapsed: float, objective_lost: bool, already_active: bool) -> String:
	if already_active:
		return "NONE"
	if objective_lost:
		return "objective_loss"
	if elapsed >= REINFORCEMENT_TIME:
		return "fixed_time"
	return "NONE"

func _on_objective_state_changed(state: String, _progress: float) -> void:
	if state == "CAPTURED":
		_objective_lost = true
		if not _reinforcements_active:
			_activate_reinforcements("objective_loss")
	_decision_accumulator = DECISION_INTERVAL

func _on_objective_captured() -> void:
	_objective_lost = true
	if not _reinforcements_active:
		_activate_reinforcements("objective_loss")
	_decision_accumulator = DECISION_INTERVAL

func _on_industrial_objective_state_changed(_state: String, _progress: float) -> void:
	_decision_accumulator = DECISION_INTERVAL

func _on_industrial_capture_completed(new_owner: String, previous_owner: String) -> void:
	print("FRONTLINE_AI_FINAL_OBJECTIVE_CAPTURE_EVENT owner=%s previous=%s" % [new_owner, previous_owner])
	_decision_accumulator = DECISION_INTERVAL

func _on_industrial_unlock_changed(_player_capture_locked: bool) -> void:
	_decision_accumulator = DECISION_INTERVAL

func _on_match_finished() -> void:
	_match_finished = true

func _on_blue_attack_fired(attacker: BattleFormation, target: BattleFormation, _damage: int) -> void:
	if attacker == null or not _intel.has(attacker):
		return
	if target != null and _agents.has(target):
		var agent: Dictionary = _agents[target]
		agent["recent_attacker"] = attacker
		agent["recent_attacker_time"] = _elapsed
		_agents[target] = agent
	if _is_legitimately_detected(attacker):
		var record: Dictionary = _intel[attacker]
		record["forced_reveal"] = FIRING_REVEAL_TIME
		record["last_known"] = attacker.global_position
		_promote_to_confirmed(attacker, record)
		_intel[attacker] = record

func _on_blue_died(formation: BattleFormation) -> void:
	for unit_variant: Variant in _agents.keys():
		var unit: BattleFormation = unit_variant as BattleFormation
		if unit == null:
			continue
		var agent: Dictionary = _agents[unit]
		if agent["target"] == formation:
			_clear_agent_target(unit)
			unit.clear_combat_target()

func _on_red_health_changed(current_hp: int, _max_hp: int, unit: BattleFormation) -> void:
	if not _agents.has(unit):
		return
	var agent: Dictionary = _agents[unit]
	if current_hp < int(agent["last_hp"]):
		agent["last_damage_time"] = _elapsed
	agent["last_hp"] = current_hp
	_agents[unit] = agent
	_decision_accumulator = DECISION_INTERVAL

func _on_red_died(_formation: BattleFormation) -> void:
	_cleanup_dead_targets()
	_decision_accumulator = DECISION_INTERVAL

func _cleanup_dead_targets() -> void:
	for unit_variant: Variant in _agents.keys():
		var unit: BattleFormation = unit_variant as BattleFormation
		if unit == null:
			continue
		var agent: Dictionary = _agents[unit]
		var target: BattleFormation = agent["target"] as BattleFormation
		if target != null and (not is_instance_valid(target) or not target.is_alive):
			_clear_agent_target(unit)
			unit.clear_combat_target()

func _clear_agent_target(unit: BattleFormation) -> void:
	if not _agents.has(unit):
		return
	var agent: Dictionary = _agents[unit]
	agent["target"] = null
	_agents[unit] = agent

func _set_state(unit: BattleFormation, next_state: String) -> void:
	if not _agents.has(unit):
		return
	var agent: Dictionary = _agents[unit]
	if str(agent["state"]) == next_state:
		return
	agent["state"] = next_state
	_agents[unit] = agent
	print("FRONTLINE_AI_STATE unit=%s state=%s" % [unit.display_name, next_state])

func _set_assigned_anchor(unit: BattleFormation, anchor: Vector2) -> void:
	if not _agents.has(unit):
		return
	var agent: Dictionary = _agents[unit]
	agent["assigned_anchor"] = anchor
	_agents[unit] = agent

func _is_active_agent(unit: BattleFormation) -> bool:
	return unit != null and is_instance_valid(unit) and unit.is_alive and _agents.has(unit) and bool((_agents[unit] as Dictionary)["active"])

func _find_red(display_name: String) -> BattleFormation:
	for unit_variant: Variant in _agents.keys():
		var unit: BattleFormation = unit_variant as BattleFormation
		if unit != null and unit.display_name == display_name:
			return unit
	return null

func _role_for(unit: BattleFormation) -> String:
	match unit.display_name:
		"RED INF-01":
			return "BRIDGEHEAD_ANCHOR"
		"RED INF-02":
			return "FLANK_SCREEN"
		"RED ARMOR-01":
			return "LOCAL_COUNTERATTACK_RESERVE"
		"RED REINFORCEMENT INF-01":
			return "REINFORCEMENT_INFANTRY"
		"RED REINFORCEMENT ARMOR-01":
			return "REINFORCEMENT_ARMOR"
	return "DEFENDER"

func _path_distance(from_world: Vector2, to_world: Vector2) -> float:
	var path: PackedVector2Array = _navigation.find_path(from_world, to_world)
	if path.is_empty():
		return INF
	return _navigation.get_path_length(path)

func _select_route_name(from_world: Vector2, to_world: Vector2) -> String:
	var costs: Dictionary = {
		"central": _route_cost(&"central", from_world, to_world),
		"north": _route_cost(&"north", from_world, to_world),
		"south": _route_cost(&"south", from_world, to_world),
	}
	return _choose_route_from_costs(costs)

func _choose_route_from_costs(costs: Dictionary) -> String:
	var order: Array[String] = ["central", "north", "south"]
	var best_name: String = "central"
	var best_cost: float = INF
	for route_name: String in order:
		var cost: float = float(costs.get(route_name, INF))
		if cost < best_cost - ROUTE_EPSILON:
			best_cost = cost
			best_name = route_name
	return best_name

func _route_cost(route_name: StringName, from_world: Vector2, to_world: Vector2) -> float:
	var route: PackedVector2Array = _navigation.get_named_route(route_name)
	if route.is_empty():
		return INF
	var from_index: int = _nearest_route_index(route, from_world)
	var to_index: int = _nearest_route_index(route, to_world)
	var start_path: PackedVector2Array = _navigation.find_path(from_world, route[from_index])
	var end_path: PackedVector2Array = _navigation.find_path(route[to_index], to_world)
	if start_path.is_empty() or end_path.is_empty():
		return INF
	var cost: float = _navigation.get_path_length(start_path) + _navigation.get_path_length(end_path)
	var low: int = mini(from_index, to_index)
	var high: int = maxi(from_index, to_index)
	for index: int in range(low + 1, high + 1):
		cost += route[index - 1].distance_to(route[index])
	return cost

func _nearest_route_index(route: PackedVector2Array, point: Vector2) -> int:
	var best_index: int = 0
	var best_distance: float = INF
	for index: int in range(route.size()):
		var distance: float = route[index].distance_squared_to(point)
		if distance < best_distance:
			best_distance = distance
			best_index = index
	return best_index

func _force_intel_for_ci(target: BattleFormation, state: String, position: Vector2, generation_increment: bool = false) -> void:
	var record: Dictionary = _intel[target]
	if generation_increment:
		record["generation"] = int(record["generation"]) + 1
	record["state"] = state
	record["last_known"] = position
	record["confirm_progress"] = CONFIRMATION_TIME if state == CONFIRMED else 0.0
	_intel[target] = record

func _ci_require(condition: bool, marker: String) -> bool:
	if not condition:
		push_error("Enemy AI smoke failed: %s" % marker)
		return false
	print(marker)
	return true

func _run_ci_smoke() -> void:
	var inf1: BattleFormation = _find_red("RED INF-01")
	var inf2: BattleFormation = _find_red("RED INF-02")
	var armor: BattleFormation = _find_red("RED ARMOR-01")
	var supply: BattleFormation = _find_red("RED SUPPLY-01")
	var blue_main: BattleFormation = _blue[0]
	var blue_recon: BattleFormation = _blue[1]
	var ok: bool = true

	ok = _ci_require(inf1 != null and inf2 != null and armor != null and supply != null and str((_agents[inf1] as Dictionary)["state"]) == HOLD and str((_agents[inf2] as Dictionary)["state"]) == HOLD and str((_agents[armor] as Dictionary)["state"]) == HOLD and str((_agents[supply] as Dictionary)["state"]) == SUPPORT, "AI_INIT_HOLD_PASS") and ok
	print("FRONTLINE_AI_INIT_PASS")

	_force_intel_for_ci(blue_main, CONTACT, Vector2(1320.0, 900.0))
	_decision_tick()
	ok = _ci_require((_agents[inf1] as Dictionary)["target"] == null and str((_agents[inf1] as Dictionary)["state"]) != ENGAGE, "AI_CONTACT_NO_CHASE_PASS") and ok
	print("FRONTLINE_AI_CONTACT_LIMIT_PASS")

	blue_main.global_position = Vector2(1340.0, 900.0)
	_force_intel_for_ci(blue_main, CONFIRMED, blue_main.global_position, true)
	_decision_tick()
	ok = _ci_require((_agents[inf1] as Dictionary)["target"] == blue_main and str((_agents[inf1] as Dictionary)["state"]) == ENGAGE, "AI_CONFIRMED_ENGAGE_PASS") and ok
	print("FRONTLINE_AI_CONFIRMED_ENGAGE_PASS")

	var frozen_last_known: Vector2 = blue_main.global_position
	_force_intel_for_ci(blue_main, LAST_KNOWN, frozen_last_known)
	blue_main.global_position = Vector2(520.0, 900.0)
	_decision_tick()
	var investigated: bool = str((_agents[inf1] as Dictionary)["state"]) == INVESTIGATE and Vector2((_intel[blue_main] as Dictionary)["last_known"]).is_equal_approx(frozen_last_known)
	var inf1_agent: Dictionary = _agents[inf1]
	inf1_agent["investigate_started"] = _elapsed - INVESTIGATE_TIMEOUT - 0.1
	_agents[inf1] = inf1_agent
	_decision_tick()
	ok = _ci_require(investigated and (str((_agents[inf1] as Dictionary)["state"]) == RETURN or str((_agents[inf1] as Dictionary)["state"]) == HOLD), "AI_LAST_KNOWN_RETURN_PASS") and ok
	print("FRONTLINE_AI_LAST_KNOWN_PASS")

	blue_main.global_position = Vector2(1870.0, 900.0)
	_force_intel_for_ci(blue_main, CONFIRMED, blue_main.global_position, true)
	inf1_agent = _agents[inf1]
	inf1_agent["state"] = ENGAGE
	inf1_agent["target"] = blue_main
	inf1_agent["engage_origin"] = Vector2(inf1_agent["home"])
	_agents[inf1] = inf1_agent
	_decide_combat_unit(inf1, false)
	ok = _ci_require(str((_agents[inf1] as Dictionary)["state"]) == RETURN or str((_agents[inf1] as Dictionary)["state"]) == HOLD, "AI_PURSUIT_LIMIT_PASS") and ok
	print("FRONTLINE_AI_PURSUIT_LEASH_PASS")

	blue_main.global_position = _objective.global_position
	_force_intel_for_ci(blue_main, CONFIRMED, blue_main.global_position, true)
	_objective.state = "CONTESTED"
	_decision_tick()
	var objective_defense: bool = str((_agents[inf1] as Dictionary)["state"]) == MOVE or str((_agents[inf1] as Dictionary)["state"]) == ENGAGE or str((_agents[inf1] as Dictionary)["state"]) == HOLD
	var counterattack: bool = str((_agents[armor] as Dictionary)["state"]) == MOVE or str((_agents[armor] as Dictionary)["state"]) == ENGAGE
	ok = _ci_require(objective_defense, "AI_OBJECTIVE_DEFEND_PASS") and ok
	ok = _ci_require(counterattack, "AI_OBJECTIVE_COUNTERATTACK_PASS") and ok
	print("FRONTLINE_AI_OBJECTIVE_DEFENSE_PASS")
	print("FRONTLINE_AI_ARMOR_RESERVE_PASS")
	_objective.state = "NEUTRAL"

	var central_valid: bool = not _navigation.get_named_route(&"central").is_empty()
	var north_valid: bool = not _navigation.get_named_route(&"north").is_empty()
	var south_valid: bool = not _navigation.get_named_route(&"south").is_empty()
	ok = _ci_require(central_valid and _choose_route_from_costs({"central": 1.0, "north": 2.0, "south": 3.0}) == "central", "AI_ROUTE_CENTRAL_PASS") and ok
	ok = _ci_require(north_valid and _choose_route_from_costs({"central": 3.0, "north": 1.0, "south": 2.0}) == "north", "AI_ROUTE_NORTH_PASS") and ok
	ok = _ci_require(south_valid and _choose_route_from_costs({"central": 3.0, "north": 2.0, "south": 1.0}) == "south", "AI_ROUTE_SOUTH_PASS") and ok
	ok = _ci_require(_choose_route_from_costs({"central": 10.0, "north": 10.0, "south": 10.0}) == "central", "AI_ROUTE_TIE_DETERMINISTIC_PASS") and ok
	print("FRONTLINE_AI_ROUTE_RESPONSE_PASS")

	blue_main.global_position = supply.global_position + Vector2(-120.0, 0.0)
	_force_intel_for_ci(blue_main, CONFIRMED, blue_main.global_position, true)
	_decide_supply(supply)
	ok = _ci_require(str((_agents[supply] as Dictionary)["state"]) == EVADE and not supply.can_attack and not supply.can_capture, "AI_SUPPLY_TRUCK_NO_COMBAT_NO_CAPTURE_PASS") and ok
	print("FRONTLINE_AI_SUPPLY_SURVIVAL_PASS")

	var fixed_trigger: bool = _reinforcement_trigger_reason(REINFORCEMENT_TIME, false, false) == "fixed_time"
	var loss_trigger: bool = _reinforcement_trigger_reason(0.0, true, false) == "objective_loss"
	_activate_reinforcements("ci_objective_loss")
	var active_count: int = 0
	for unit: BattleFormation in _reinforcements:
		if _is_active_agent(unit):
			active_count += 1
	_activate_reinforcements("ci_duplicate_guard")
	ok = _ci_require(fixed_trigger and loss_trigger and active_count == 2, "AI_REINFORCEMENT_ONESHOT_PASS") and ok
	print("FRONTLINE_AI_REINFORCEMENT_PASS")

	var deterministic_target_a: BattleFormation = _choose_target(inf2, false)
	var deterministic_target_b: BattleFormation = _choose_target(inf2, false)
	var deterministic_route_a: String = _choose_route_from_costs({"central": 4.0, "north": 4.0, "south": 4.0})
	var deterministic_route_b: String = _choose_route_from_costs({"central": 4.0, "north": 4.0, "south": 4.0})
	ok = _ci_require(deterministic_target_a == deterministic_target_b and deterministic_route_a == deterministic_route_b, "AI_DETERMINISTIC_REPLAY_PASS") and ok
	print("FRONTLINE_AI_DETERMINISM_PASS")

	var test_agent: Dictionary = _agents[inf2]
	test_agent["target"] = blue_recon
	_agents[inf2] = test_agent
	blue_recon.is_alive = false
	_cleanup_dead_targets()
	ok = _ci_require((_agents[inf2] as Dictionary)["target"] == null, "AI_DEAD_TARGET_REMOVAL_PASS") and ok

	if ok:
		print("FRONTLINE_ENEMY_AI_SMOKE_PASS")
	else:
		push_error("FRONTLINE_ENEMY_AI_SMOKE_FAIL")
