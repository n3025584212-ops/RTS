extends Node2D

signal selection_changed(selected: bool)
signal order_changed(order_name: String)

@export var move_speed: float = 260.0
@export var selection_radius: float = 34.0

var is_selected: bool = false
var current_order: String = "HOLD"
var _move_target: Vector2
var _has_move_target: bool = false

func _ready() -> void:
	_move_target = global_position
	queue_redraw()

func _process(delta: float) -> void:
	if not _has_move_target:
		return
	var offset := _move_target - global_position
	if offset.length() <= 4.0:
		global_position = _move_target
		_has_move_target = false
		_set_order("HOLD")
		return
	global_position += offset.normalized() * minf(move_speed * delta, offset.length())

func contains_world_point(world_point: Vector2) -> bool:
	return global_position.distance_to(world_point) <= selection_radius

func set_selected(value: bool) -> void:
	if is_selected == value:
		return
	is_selected = value
	queue_redraw()
	selection_changed.emit(is_selected)

func issue_move(world_target: Vector2) -> void:
	_move_target = world_target
	_has_move_target = true
	_set_order("MOVE")
	queue_redraw()

func stop() -> void:
	_has_move_target = false
	_move_target = global_position
	_set_order("HOLD")

func get_order() -> String:
	return current_order

func _set_order(value: String) -> void:
	if current_order == value:
		return
	current_order = value
	order_changed.emit(current_order)

func _draw() -> void:
	# Formation body
	draw_circle(Vector2.ZERO, 26.0, Color(0.12, 0.55, 0.92))
	draw_circle(Vector2.ZERO, 18.0, Color(0.05, 0.18, 0.32))
	# Formation direction mark
	draw_line(Vector2(-10.0, 0.0), Vector2(10.0, 0.0), Color.WHITE, 3.0)
	draw_line(Vector2(0.0, -10.0), Vector2(0.0, 10.0), Color.WHITE, 3.0)
	if is_selected:
		draw_arc(Vector2.ZERO, 38.0, 0.0, TAU, 48, Color(0.35, 0.95, 1.0), 3.0)
	if _has_move_target:
		draw_line(Vector2.ZERO, to_local(_move_target), Color(0.35, 0.95, 1.0, 0.65), 2.0)
