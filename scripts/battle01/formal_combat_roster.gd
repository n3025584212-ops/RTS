class_name BattleFormalCombatRoster
extends Node

const FORMATION_SCRIPT: Script = preload("res://scripts/battle01/formation.gd")
const INFANTRY_DEFINITION: FormationDefinition = preload("res://resources/formations/infantry.tres")
const ARMOR_DEFINITION: FormationDefinition = preload("res://resources/formations/tank.tres")
const SUPPLY_TRUCK_DEFINITION: FormationDefinition = preload("res://resources/formations/logistics.tres")

var enemy_infantry: Array[BattleFormation] = []
var enemy_armor: Array[BattleFormation] = []
var enemy_supply_trucks: Array[BattleFormation] = []
var reinforcement_infantry: Array[BattleFormation] = []
var reinforcement_armor: Array[BattleFormation] = []

@onready var _navigation: BattleNavigation = get_parent().get_node("Navigation") as BattleNavigation
@onready var _visibility: BattleVisibilityField = get_parent().get_node("VisibilityField") as BattleVisibilityField
@onready var _primary_infantry: BattleFormation = get_parent().get_node("RedFormation") as BattleFormation

func _ready() -> void:
	if _primary_infantry == null:
		push_error("Formal combat roster requires existing RedFormation as RED INF-01.")
		return

	# Preserve the already-verified Recon/LOS target as the first frozen enemy Infantry.
	_primary_infantry.display_name = "RED INF-01"
	_primary_infantry.set_intel_state(BattleIntelTracker.UNSEEN)
	enemy_infantry.append(_primary_infantry)

	# Restore only the frozen Battle01 enemy composition around the existing start.
	var base_position: Vector2 = _primary_infantry.global_position
	enemy_infantry.append(_spawn_active_enemy(
		"RedInfantry2",
		"RED INF-02",
		INFANTRY_DEFINITION,
		base_position + Vector2(0.0, -120.0)
	))
	enemy_armor.append(_spawn_active_enemy(
		"RedArmor1",
		"RED ARMOR-01",
		ARMOR_DEFINITION,
		base_position + Vector2(0.0, 120.0)
	))
	enemy_supply_trucks.append(_spawn_active_enemy(
		"RedSupplyTruck1",
		"RED SUPPLY-01",
		SUPPLY_TRUCK_DEFINITION,
		base_position + Vector2(120.0, 180.0)
	))

	# Frozen reinforcements are instantiated but dormant. Window 04 owns activation/AI.
	reinforcement_infantry.append(_spawn_dormant_reinforcement(
		"ReinforcementInfantry1",
		"RED REINFORCEMENT INF-01",
		INFANTRY_DEFINITION,
		base_position
	))
	reinforcement_armor.append(_spawn_dormant_reinforcement(
		"ReinforcementArmor1",
		"RED REINFORCEMENT ARMOR-01",
		ARMOR_DEFINITION,
		base_position
	))

	if not _validate_frozen_roster():
		return

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
	valid = _validate_unit(enemy_infantry[0], INFANTRY_DEFINITION, true, true) and valid
	valid = _validate_unit(enemy_infantry[1], INFANTRY_DEFINITION, true, true) and valid
	valid = _validate_unit(enemy_armor[0], ARMOR_DEFINITION, true, true) and valid
	valid = _validate_unit(enemy_supply_trucks[0], SUPPLY_TRUCK_DEFINITION, false, false) and valid
	valid = _validate_unit(reinforcement_infantry[0], INFANTRY_DEFINITION, true, true) and valid
	valid = _validate_unit(reinforcement_armor[0], ARMOR_DEFINITION, true, true) and valid
	if not valid:
		push_error("Frozen Battle01 formal combat roster validation failed.")
	return valid

func _validate_unit(
	formation: BattleFormation,
	expected_definition: FormationDefinition,
	expected_can_attack: bool,
	expected_can_capture: bool
) -> bool:
	return (
		formation != null
		and formation.definition == expected_definition
		and formation.faction == "RED"
		and formation.can_attack == expected_can_attack
		and formation.can_capture == expected_can_capture
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
