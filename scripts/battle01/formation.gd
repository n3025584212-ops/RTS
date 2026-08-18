class_name BattleFormation
extends Node2D

signal selection_changed(selected: bool)
signal order_changed(order_name: String)
signal health_changed(current_hp: int, max_hp_value: int)
signal attack_fired(attacker: BattleFormation, target: BattleFormation, damage: int)
signal died(formation: BattleFormation)

@export var display_name: String = "FORMATION"
@export var faction: String = "BLUE"
@export var selectable: bool = true
@export var move_speed: float = 260.0
@export var selection_radius: float = 34.0
@export var max_hp: int = 100
@export var attack_damage: int = 20
@export var attack_range: float = 240.0
@export var fire_interval: float = 0.6
@export var body_color: Color = Color(0.12, 0.55, 0.92)

var is_selected: bool = false
var is_alive: bool = true
var current_order: String = "HOLD"
var current_hp: int = 0
var _move_target: Vector2
var _has_move_target: bool = false
var _combat_target: BattleFormation
var _fire_cooldown: float = 0.0

func _ready() -> void:
	current_hp = max_hp
	_move_target = global_position
	health_changed.emit(current_hp, max_hp)
	queue_redraw()

func _process(delta: float) -> void:
	if not is_alive:
		return
	_fire_cooldown = maxf(0.0, _fire_cooldown - delta)
	_update_combat()
	_update_movement(delta)

func contains_world_point(world_point: Vector2) -> bool:
	return is_alive and selectable and global_position.distance_to(world_point) <= selection_radius

func set_selected(value: bool) -> void:
	if not selectable or not is_alive:
		value = false
	if is_selected == value:
		return
	is_selected = value
	queue_redraw()
	selection_changed.emit(is_selected)

func issue_move(world_target: Vector2) -> void:
	if not is_alive:
		return
	_move_target = world_target
	_has_move_target = true
	_set_order("MOVE")
	queue_redraw()

func stop() -> void:
	_has_move_target = false
	_move_target = global_position
	_set_order("HOLD")
	queue_redraw()

func set_combat_target(target: BattleFormation) -> void:
	if target == self:
		return
	_combat_target = target

func clear_combat_target() -> void:
	_combat_target = null

func take_damage(amount: int) -> void:
	if not is_alive or amount <= 0:
		return
	current_hp = maxi(0, current_hp - amount)
	health_changed.emit(current_hp, max_hp)
	queue_redraw()
	if current_hp <= 0:
		_die()

func get_order() -> String:
	return current_order

func _update_movement(delta: float) -> void:
	if not _has_move_target:
		return
	var offset: Vector2 = _move_target - global_position
	if offset.length() <= 4.0:
		global_position = _move_target
		_has_move_target = false
		_set_order("HOLD")
		queue_redraw()
		return
	global_position += offset.normalized() * minf(move_speed * delta, offset.length())
	queue_redraw()

func _update_combat() -> void:
	if _combat_target == null:
		return
	if not is_instance_valid(_combat_target) or not _combat_target.is_alive:
		_combat_target = null
		return
	if global_position.distance_to(_combat_target.global_position) > attack_range:
		return
	if _fire_cooldown > 0.0:
		return
	_fire_cooldown = fire_interval
	attack_fired.emit(self, _combat_target, attack_damage)
	_combat_target.take_damage(attack_damage)

func _die() -> void:
	if not is_alive:
		return
	is_alive = false
	_has_move_target = false
	_combat_target = null
	if is_selected:
		is_selected = false
		selection_changed.emit(false)
	_set_order("DESTROYED")
	queue_redraw()
	died.emit(self)

func _set_order(value: String) -> void:
	if current_order == value:
		return
	current_order = value
	order_changed.emit(current_order)

func _draw() -> void:
	if not is_alive:
		draw_circle(Vector2.ZERO, 26.0, Color(0.12, 0.12, 0.12))
		draw_line(Vector2(-18.0, -18.0), Vector2(18.0, 18.0), Color(0.8, 0.2, 0.2), 5.0)
		draw_line(Vector2(18.0, -18.0), Vector2(-18.0, 18.0), Color(0.8, 0.2, 0.2), 5.0)
		return

	draw_circle(Vector2.ZERO, 26.0, body_color)
	draw_circle(Vector2.ZERO, 18.0, body_color.darkened(0.55))
	draw_line(Vector2(-10.0, 0.0), Vector2(10.0, 0.0), Color.WHITE, 3.0)
	draw_line(Vector2(0.0, -10.0), Vector2(0.0, 10.0), Color.WHITE, 3.0)

	var hp_ratio: float = float(current_hp) / float(maxi(1, max_hp))
	draw_rect(Rect2(-30.0, -44.0, 60.0, 6.0), Color(0.08, 0.08, 0.08, 0.9))
	draw_rect(Rect2(-30.0, -44.0, 60.0 * hp_ratio, 6.0), Color(0.25, 0.9, 0.35, 0.95))

	if is_selected:
		draw_arc(Vector2.ZERO, 38.0, 0.0, TAU, 48, Color(0.35, 0.95, 1.0), 3.0)
	if _has_move_target:
		draw_line(Vector2.ZERO, to_local(_move_target), Color(0.35, 0.95, 1.0, 0.65), 2.0)
