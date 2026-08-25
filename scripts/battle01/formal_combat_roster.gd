class_name BattleFormalCombatRoster
extends Node

const FORMATION_SCRIPT: Script = preload("res://scripts/battle01/formation.gd")
const INFANTRY_DEFINITION: FormationDefinition = preload("res://resources/formations/infantry.tres")
const ARMOR_DEFINITION: FormationDefinition = preload("res://resources/formations/tank.tres")
const SUPPLY_TRUCK_DEFINITION: FormationDefinition = preload("res://resources/formations/logistics.tres")

const POSTURE_A: String = "BRIDGE_LOCK"
const POSTURE_B: String = "VILLAGE_SCREEN"
const POSTURE_C: String = "SOUTH_SCREEN"
const REINFORCEMENT_ENTRY: Vector2 = Vector2(1380.0, 900.0)

static var _session_battle01_run_index: int = 0

# -1 means normal player session sequencing. Any non-negative value is an explicit
# editor/debug override and, like CLI/environment overrides, does not consume the
# normal replay counter.
@export var battle01_seed: int = -1

var enemy_infantry: Array[BattleFormation] = []
var enemy_armor: Array[BattleFormation] = []
var enemy_supply_trucks: Array[BattleFormation] = []
var reinforcement_infantry: Array[BattleFormation] = []
var reinforcement_armor: Array[BattleFormation] = []
var _initialized: bool = false
var _selected_seed: int = 0
var _selected_posture: String = POSTURE_A
var _posture_locked: bool = false
var _posture_deployment: Dictionary = {}
var _test_seed_forced: bool = false
var _test_seed_value: int = 0

@onready var _navigation: BattleNavigation = get_parent().get_node("Navigation") as BattleNavigation
@onready var _visibility: BattleVisibilityField = get_parent().get_node("VisibilityField") as BattleVisibilityField
@onready var _primary_infantry: BattleFormation = get_parent().get_node("RedFormation") as BattleFormation

static func reset_normal_run_sequence_for_test() -> void:
	_session_battle01_run_index = 0

static func get_normal_run_index_for_test() -> int:
	return _session_battle01_run_index

func _ready() -> void:
	var battle: Node = get_parent()
	if battle == null:
		push_error("Formal combat roster requires a Battle01 parent.")
		return
	if battle.is_node_ready():
		_initialize_roster()
	else:
		battle.ready.connect(_initialize_roster, CONNECT_ONE_SHOT)

func force_seed_for_test(seed: int) -> void:
	if _initialized:
		push_error("Battle01 posture seed cannot change after roster initialization.")
		return
	_test_seed_forced = true
	_test_seed_value = seed

func get_battle01_seed() -> int:
	return _selected_seed

func get_selected_posture() -> String:
	return _selected_posture

func is_posture_locked() -> bool:
	return _posture_locked

func get_posture_deployment() -> Dictionary:
	return _posture_deployment.duplicate(true)

func posture_for_seed(seed: int) -> String:
	var index: int = seed % 3
	if index < 0:
		index += 3
	match index:
		0:
			return POSTURE_A
		1:
			return POSTURE_B
		_:
			return POSTURE_C

func _initialize_roster() -> void:
	if _initialized:
		return
	_initialized = true

	if _primary_infantry == null:
		push_error("Formal combat roster requires existing RedFormation as RED INF-01.")
		return

	_selected_seed = _resolve_battle01_seed()
	_selected_posture = posture_for_seed(_selected_seed)
	_posture_deployment = _deployment_for_posture(_selected_posture)
	if not _validate_posture_deployment(_posture_deployment):
		return

	_primary_infantry.global_position = Vector2(_posture_deployment["RED INF-01"])
	_primary_infantry.display_name = "RED INF-01"
	_primary_infantry.set_intel_state(BattleIntelTracker.UNSEEN)
	enemy_infantry.append(_primary_infantry)

	enemy_infantry.append(_spawn_active_enemy(
		"RedInfantry2",
		"RED INF-02",
		INFANTRY_DEFINITION,
		Vector2(_posture_deployment["RED INF-02"])
	))
	enemy_armor.append(_spawn_active_enemy(
		"RedArmor1",
		"RED ARMOR-01",
		ARMOR_DEFINITION,
		Vector2(_posture_deployment["RED ARMOR-01"])
	))
	enemy_supply_trucks.append(_spawn_active_enemy(
		"RedSupplyTruck1",
		"RED SUPPLY-01",
		SUPPLY_TRUCK_DEFINITION,
		Vector2(_posture_deployment["RED SUPPLY-01"])
	))

	# Reinforcement entry/timing is not seeded. The existing Enemy AI later binds
	# activated reinforcement assignments to the selected active posture anchors.
	reinforcement_infantry.append(_spawn_dormant_reinforcement(
		"ReinforcementInfantry1",
		"RED REINFORCEMENT INF-01",
		INFANTRY_DEFINITION,
		REINFORCEMENT_ENTRY
	))
	reinforcement_armor.append(_spawn_dormant_reinforcement(
		"ReinforcementArmor1",
		"RED REINFORCEMENT ARMOR-01",
		ARMOR_DEFINITION,
		REINFORCEMENT_ENTRY
	))

	if not _validate_frozen_roster():
		return

	_posture_locked = true
	print("FRONTLINE_RED_POSTURE_SELECTED seed=%d posture=%s" % [_selected_seed, _selected_posture])
	print(
		"FRONTLINE_FORMAL_COMBAT_ROSTER_READY enemy_infantry=%d enemy_armor=%d enemy_supply_truck=%d reinforcement_infantry=%d reinforcement_armor=%d"
		% [
			enemy_infantry.size(),
			enemy_armor.size(),
			enemy_supply_trucks.size(),
			reinforcement_infantry.size(),
			reinforcement_armor.size(),
		]
	)

func _resolve_battle01_seed() -> int:
	if _test_seed_forced:
		return _test_seed_value

	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--battle01-seed="):
			var raw_cli: String = argument.trim_prefix("--battle01-seed=")
			if raw_cli.is_valid_int():
				return int(raw_cli)
			push_warning("Ignoring invalid --battle01-seed value: %s" % raw_cli)

	if OS.has_environment("BATTLE01_SEED"):
		var raw_env: String = OS.get_environment("BATTLE01_SEED")
		if raw_env.is_valid_int():
			return int(raw_env)
		push_warning("Ignoring invalid BATTLE01_SEED environment value: %s" % raw_env)

	if battle01_seed >= 0:
		return battle01_seed

	# Only a real current Battle01 scene consumes the normal-player replay counter.
	# Programmatic scene instances used by focused regression tests keep the legacy
	# deterministic seed-0 compatibility fallback unless they explicitly request a seed.
	if _is_normal_player_scene_instance():
		var run_index: int = _session_battle01_run_index
		var seed: int = run_index % 3
		_session_battle01_run_index = (run_index + 1) % 3
		print("FRONTLINE_RED_NORMAL_RUN_SEED run=%d seed=%d" % [run_index + 1, seed])
		return seed

	return 0

func _is_normal_player_scene_instance() -> bool:
	var tree: SceneTree = get_tree()
	return tree != null and tree.current_scene == get_parent()

func _deployment_for_posture(posture: String) -> Dictionary:
	match posture:
		POSTURE_B:
			return {
				"RED INF-01": Vector2(1340.0, 900.0),
				"RED INF-02": Vector2(1060.0, 660.0),
				"RED ARMOR-01": Vector2(1900.0, 1060.0),
				"RED SUPPLY-01": Vector2(2300.0, 1180.0),
			}
		POSTURE_C:
			return {
				"RED INF-01": Vector2(1380.0, 900.0),
				# Keep the authored South screen on a legal navigation-cell center so
				# RETURN terminates at the exact selected-posture home anchor.
				"RED INF-02": Vector2(1340.0, 1380.0),
				"RED ARMOR-01": Vector2(1900.0, 700.0),
				"RED SUPPLY-01": Vector2(2260.0, 1340.0),
			}
		_:
			return {
				"RED INF-01": Vector2(1380.0, 900.0),
				"RED INF-02": Vector2(1420.0, 700.0),
				"RED ARMOR-01": Vector2(1900.0, 900.0),
				"RED SUPPLY-01": Vector2(2180.0, 1060.0),
			}

func _validate_posture_deployment(deployment: Dictionary) -> bool:
	var central: BattleObjective = get_parent().get_node_or_null("CentralBridgehead") as BattleObjective
	var industrial: BattleObjective = get_parent().get_node_or_null("IndustrialObjective") as BattleObjective
	if central == null or industrial == null:
		push_error("Seeded RED posture requires both Battle01 objectives.")
		return false
	for unit_name: String in ["RED INF-01", "RED INF-02", "RED ARMOR-01", "RED SUPPLY-01"]:
		if not deployment.has(unit_name):
			push_error("Seeded RED posture missing deployment for %s." % unit_name)
			return false
		var point: Vector2 = Vector2(deployment[unit_name])
		if not _navigation.is_world_walkable(point):
			push_error("Seeded RED posture point is not walkable: %s=%s" % [unit_name, point])
			return false
		if point.distance_to(central.global_position) <= central.capture_radius:
			push_error("Seeded RED posture point illegally occupies Central objective core: %s" % unit_name)
			return false
		if point.distance_to(industrial.global_position) <= industrial.capture_radius:
			push_error("Seeded RED posture point illegally occupies Industrial objective core: %s" % unit_name)
			return false
		if _navigation.find_path(point, central.global_position).is_empty():
			push_error("Seeded RED posture point has no legal Battle01 path: %s=%s" % [unit_name, point])
			return false
	return true

func _spawn_active_enemy(
	node_name: String,
	unit_display_name: String,
	unit_definition: FormationDefinition,
	spawn_position: Vector2
) -> BattleFormation:
	var formation: BattleFormation = FORMATION_SCRIPT.new() as BattleFormation
	formation.name = node_name
	formation.definition = unit_definition
	formation.display_name = unit_display_name
	formation.faction = "RED"
	formation.selectable = false
	formation.body_color = Color(0.88, 0.18, 0.15, 1.0)
	formation.global_position = spawn_position
	get_parent().add_child(formation)
	formation.set_navigation(_navigation)
	formation.set_visibility_field(_visibility)
	formation.set_intel_state(BattleIntelTracker.UNSEEN)
	return formation

func _spawn_dormant_reinforcement(
	node_name: String,
	unit_display_name: String,
	unit_definition: FormationDefinition,
	spawn_position: Vector2
) -> BattleFormation:
	var formation: BattleFormation = _spawn_active_enemy(
		node_name,
		unit_display_name,
		unit_definition,
		spawn_position
	)
	formation.visible = false
	formation.process_mode = Node.PROCESS_MODE_DISABLED
	return formation

func _validate_frozen_roster() -> bool:
	var valid: bool = true
	valid = _validate_unit(enemy_infantry[0], INFANTRY_DEFINITION, true, true, true) and valid
	valid = _validate_unit(enemy_infantry[1], INFANTRY_DEFINITION, true, true, true) and valid
	valid = _validate_unit(enemy_armor[0], ARMOR_DEFINITION, true, false, true) and valid
	valid = _validate_unit(enemy_supply_trucks[0], SUPPLY_TRUCK_DEFINITION, false, false, false) and valid
	valid = _validate_unit(reinforcement_infantry[0], INFANTRY_DEFINITION, true, true, true) and valid
	valid = _validate_unit(reinforcement_armor[0], ARMOR_DEFINITION, true, false, true) and valid
	if not valid:
		push_error("Revised Battle01 formal combat roster validation failed.")
	return valid

func _validate_unit(
	formation: BattleFormation,
	expected_definition: FormationDefinition,
	expected_can_attack: bool,
	expected_can_capture: bool,
	expected_can_contest: bool
) -> bool:
	return (
		formation != null
		and formation.definition == expected_definition
		and formation.faction == "RED"
		and formation.can_attack == expected_can_attack
		and formation.can_capture == expected_can_capture
		and formation.can_contest == expected_can_contest
	)

func get_roster_counts() -> Dictionary:
	return {
		"enemy_infantry": enemy_infantry.size(),
		"enemy_armor": enemy_armor.size(),
		"enemy_supply_truck": enemy_supply_trucks.size(),
		"reinforcement_infantry": reinforcement_infantry.size(),
		"reinforcement_armor": reinforcement_armor.size(),
	}

func get_initial_enemy_combat_formations() -> Array[BattleFormation]:
	var result: Array[BattleFormation] = []
	result.append_array(enemy_infantry)
	result.append_array(enemy_armor)
	return result

func get_initial_supply_trucks() -> Array[BattleFormation]:
	return enemy_supply_trucks.duplicate()

func get_reinforcement_formations() -> Array[BattleFormation]:
	var result: Array[BattleFormation] = []
	result.append_array(reinforcement_infantry)
	result.append_array(reinforcement_armor)
	return result
