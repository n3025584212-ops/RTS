class_name BattleSelectionController
extends Node2D

signal selection_changed(formations: Array[BattleFormation])
signal move_order_issued(formations: Array[BattleFormation], target: Vector2)

@export var drag_threshold: float = 12.0
@export var group_spacing: float = 70.0

var _formations: Array[BattleFormation] = []
var _selected: Array[BattleFormation] = []
var _dragging: bool = false
var _drag_start: Vector2 = Vector2.ZERO
var _drag_current: Vector2 = Vector2.ZERO

func configure(formations: Array[BattleFormation]) -> void:
	_formations = formations
	_clear_selection(false)
	queue_redraw()

func handle_input(event: InputEvent, world_point: Vector2) -> bool:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_dragging = true
			_drag_start = world_point
			_drag_current = world_point
			queue_redraw()
			return true
		if _dragging:
			_drag_current = world_point
			var additive: bool = Input.is_key_pressed(KEY_SHIFT)
			if _drag_start.distance_to(_drag_current) >= drag_threshold:
				select_in_rect(_make_rect(_drag_start, _drag_current), additive)
			else:
				_select_at_point(world_point, additive)
			_dragging = false
			queue_redraw()
			return true
	elif event is InputEventMouseMotion and _dragging:
		_drag_current = world_point
		queue_redraw()
		return true
	return false

func select_only(formation: BattleFormation) -> void:
	_clear_selection(false)
	if _is_selectable_friendly(formation):
		_selected.append(formation)
		formation.set_selected(true)
	_emit_selection_changed()

func add_to_selection(formation: BattleFormation) -> void:
	if not _is_selectable_friendly(formation):
		return
	if formation not in _selected:
		_selected.append(formation)
		formation.set_selected(true)
	_emit_selection_changed()

func select_in_rect(rect: Rect2, additive: bool = false) -> void:
	if not additive:
		_clear_selection(false)
	for formation: BattleFormation in _formations:
		if not _is_selectable_friendly(formation):
			continue
		if rect.has_point(formation.global_position) and formation not in _selected:
			_selected.append(formation)
			formation.set_selected(true)
	_emit_selection_changed()

func clear_selection() -> void:
	_clear_selection(true)

func get_selected() -> Array[BattleFormation]:
	return _selected

func issue_move(world_target: Vector2, spacing: float = -1.0) -> int:
	_prune_selection()
	if _selected.is_empty():
		return 0
	var actual_spacing: float = group_spacing if spacing < 0.0 else spacing
	var count: int = _selected.size()
	var issued_count: int = 0
	for i: int in range(count):
		var formation: BattleFormation = _selected[i]
		var lateral: float = (float(i) - float(count - 1) * 0.5) * actual_spacing
		if formation.issue_move(world_target + Vector2(0.0, lateral)):
			issued_count += 1
	if issued_count > 0:
		move_order_issued.emit(_selected, world_target)
	return issued_count

func _select_at_point(world_point: Vector2, additive: bool) -> void:
	var picked: BattleFormation = null
	for formation: BattleFormation in _formations:
		if _is_selectable_friendly(formation) and formation.contains_world_point(world_point):
			picked = formation
			break

	if not additive:
		_clear_selection(false)
	if picked != null:
		if additive and picked in _selected:
			_selected.erase(picked)
			picked.set_selected(false)
		else:
			_selected.append(picked)
			picked.set_selected(true)
	_emit_selection_changed()

func _clear_selection(notify: bool) -> void:
	for formation: BattleFormation in _selected:
		if formation != null and is_instance_valid(formation):
			formation.set_selected(false)
	_selected.clear()
	if notify:
		_emit_selection_changed()

func _prune_selection() -> void:
	for i: int in range(_selected.size() - 1, -1, -1):
		var formation: BattleFormation = _selected[i]
		if formation == null or not is_instance_valid(formation) or not formation.is_alive:
			_selected.remove_at(i)

func _is_selectable_friendly(formation: BattleFormation) -> bool:
	return (
		formation != null
		and is_instance_valid(formation)
		and formation.is_alive
		and formation.selectable
		and formation.faction == "BLUE"
	)

func _make_rect(a: Vector2, b: Vector2) -> Rect2:
	var minimum := Vector2(minf(a.x, b.x), minf(a.y, b.y))
	var maximum := Vector2(maxf(a.x, b.x), maxf(a.y, b.y))
	return Rect2(minimum, maximum - minimum)

func _emit_selection_changed() -> void:
	_prune_selection()
	selection_changed.emit(_selected)

func _draw() -> void:
	if not _dragging or _drag_start.distance_to(_drag_current) < drag_threshold:
		return
	var rect: Rect2 = _make_rect(_drag_start, _drag_current)
	draw_rect(rect, Color(0.20, 0.78, 1.0, 0.10), true)
	draw_rect(rect, Color(0.35, 0.92, 1.0, 0.90), false, 2.0)
