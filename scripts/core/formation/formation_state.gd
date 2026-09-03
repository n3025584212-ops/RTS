class_name FormationState
extends RefCounted

signal position_changed(position: Vector2)
signal task_changed(task_type: StringName)
signal execution_state_changed(state: StringName)
signal health_changed(current_hp: int, max_hp: int)
signal ammo_changed(current_ammo: int, ammo_capacity: int)
signal destroyed

const TASK_HOLD: StringName = &"HOLD"
const EXECUTION_IDLE: StringName = &"IDLE"
const EXECUTION_HOLDING: StringName = &"HOLDING"
const EXECUTION_MOVING: StringName = &"MOVING"
const EXECUTION_EXECUTING: StringName = &"EXECUTING"
const EXECUTION_COMPLETE: StringName = &"COMPLETE"
const EXECUTION_DESTROYED: StringName = &"DESTROYED"

var formation_id: StringName = &""
var display_name: String = "FORMATION"
var faction_id: StringName = &"NEUTRAL"
var mobility_profile: StringName = &"DEFAULT"
var position: Vector2 = Vector2.ZERO
var move_speed: float = 100.0
var max_hp: int = 100
var current_hp: int = 100
var ammo_capacity: int = 0
var current_ammo: int = 0
var is_alive: bool = true
var current_task: StringName = TASK_HOLD
var execution_state: StringName = EXECUTION_IDLE

func configure(
	id_value: StringName,
	name_value: String,
	faction_value: StringName,
	position_value: Vector2,
	move_speed_value: float,
	max_hp_value: int,
	ammo_capacity_value: int,
	mobility_value: StringName = &"DEFAULT"
) -> FormationState:
	formation_id = id_value
	display_name = name_value
	faction_id = faction_value
	mobility_profile = mobility_value
	position = position_value
	move_speed = maxf(0.0, move_speed_value)
	max_hp = maxi(1, max_hp_value)
	current_hp = max_hp
	ammo_capacity = maxi(0, ammo_capacity_value)
	current_ammo = ammo_capacity
	is_alive = true
	current_task = TASK_HOLD
	execution_state = EXECUTION_IDLE
	return self

func set_position(value: Vector2) -> void:
	if position.is_equal_approx(value):
		return
	position = value
	position_changed.emit(position)

func assign_task(task_type: StringName) -> void:
	if current_task == task_type:
		return
	current_task = task_type
	task_changed.emit(current_task)

func set_execution_state(value: StringName) -> void:
	if execution_state == value:
		return
	execution_state = value
	execution_state_changed.emit(execution_state)

func apply_damage(amount: int) -> int:
	if not is_alive or amount <= 0:
		return 0
	var before: int = current_hp
	current_hp = maxi(0, current_hp - amount)
	var applied: int = before - current_hp
	health_changed.emit(current_hp, max_hp)
	if current_hp == 0:
		is_alive = false
		current_task = TASK_HOLD
		execution_state = EXECUTION_DESTROYED
		destroyed.emit()
	return applied

func restore_health(amount: int) -> int:
	if not is_alive or amount <= 0:
		return 0
	var before: int = current_hp
	current_hp = mini(max_hp, current_hp + amount)
	var restored: int = current_hp - before
	if restored > 0:
		health_changed.emit(current_hp, max_hp)
	return restored

func spend_ammo(amount: int = 1) -> bool:
	if not is_alive or amount <= 0 or current_ammo < amount:
		return false
	current_ammo -= amount
	ammo_changed.emit(current_ammo, ammo_capacity)
	return true

func restore_ammo(amount: int) -> int:
	if not is_alive or amount <= 0 or ammo_capacity <= 0:
		return 0
	var before: int = current_ammo
	current_ammo = mini(ammo_capacity, current_ammo + amount)
	var restored: int = current_ammo - before
	if restored > 0:
		ammo_changed.emit(current_ammo, ammo_capacity)
	return restored
