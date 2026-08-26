class_name BattleSelectionController
extends Node2D

signal selection_changed(formations: Array[BattleFormation])
signal move_order_issued(formations: Array[BattleFormation], target: Vector2)
signal advance_order_issued(formations: Array[BattleFormation], target: Vector2)
signal hold_fire_changed(formations: Array[BattleFormation], enabled: bool)

const ADVANCE_DECISION_INTERVAL: float = 0.15
const DISTANCE_TIE_EPSILON: float = 0.01

@export var drag_threshold: float = 12.0
@export var group_spacing: float = 70.0

var _formations: Array[BattleFormation] = []
var _selected: Array[BattleFormation] = []
var _dragging: bool = false
var _drag_start: Vector2 = Vector2.ZERO
var _drag_current: Vector2 = Vector2.ZERO

var _advance_intents: Dictionary = {}
var _known_red_targets: Array[BattleFormation] = []
var _advance_accumulator: float = 0.0
var _intel: BattleIntelTracker
var _visibility: BattleVisibilityField
var _war_flow: BattlePlayerWarFlow
var _hud: BattleHUD
var _resupply_controller: BattleResupplyController
var _context_bound: bool = false

func configure(formations: Array[BattleFormation]) -> void:
	_formations.clear()
	_selected.clear()
	_advance_intents.clear()
	_known_red_targets.clear()
	_bind_battle_context()
	for formation: BattleFormation in formations:
		register_formation(formation)
	_clear_selection(false)
	queue_redraw()

func _bind_battle_context() -> void:
	if _context_bound:
		return
	var battle: Node = get_parent()
	if battle == null:
		return
	_intel = battle.get_node_or_null("IntelTracker") as BattleIntelTracker
	_visibility = battle.get_node_or_null("VisibilityField") as BattleVisibilityField
	_war_flow = battle.get_node_or_null("PlayerWarFlow") as BattlePlayerWarFlow
	_hud = battle.get_node_or_null("HUD") as BattleHUD
	_resupply_controller = battle.get_node_or_null("ResupplyController") as BattleResupplyController
	if _intel != null and not _intel.intel_record_changed.is_connected(_on_intel_record_changed):
		_intel.intel_record_changed.connect(_on_intel_record_changed)
	if _war_flow != null and not _war_flow.friendlies_changed.is_connected(_on_friendlies_changed):
		_war_flow.friendlies_changed.connect(_on_friendlies_changed)
	_context_bound = true

func register_formation(formation: BattleFormation) -> void:
	if formation == null or not is_instance_valid(formation):
		return
	if formation in _formations:
		return
	_formations.append(formation)
	var order_callback: Callable = _on_registered_order_changed.bind(formation)
	if not formation.order_changed.is_connected(order_callback):
		formation.order_changed.connect(order_callback)

func _process(delta: float) -> void:
	if _advance_intents.is_empty():
		return
	_advance_accumulator += delta
	if _advance_accumulator < ADVANCE_DECISION_INTERVAL:
		return
	_advance_accumulator = fmod(_advance_accumulator, ADVANCE_DECISION_INTERVAL)
	_update_advance_targets()

func handle_input(event: InputEvent, world_point: Vector2) -> bool:
	if event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.pressed and not key_event.echo and key_event.keycode == KEY_H:
			return toggle_hold_fire_selected() >= 0
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_RIGHT and mouse_event.shift_pressed:
			issue_advance(world_point)
			return true
		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			if mouse_event.pressed:
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
	_prune_selection()
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
		# Plain player MOVE is movement-only. Clear any player-side target that may
		# have been inherited from legacy primary-IFV auto-target wiring or ADVANCE.
		formation.clear_combat_target()
		var lateral: float = (float(i) - float(count - 1) * 0.5) * actual_spacing
		if formation.issue_move(world_target + Vector2(0.0, lateral)):
			issued_count += 1
	if issued_count > 0:
		move_order_issued.emit(_selected, world_target)
	return issued_count

func issue_advance(world_target: Vector2, spacing: float = -1.0) -> int:
	_prune_selection()
	var combat: Array[BattleFormation] = []
	var logistics_skipped: int = 0
	for formation: BattleFormation in _selected:
		if _can_receive_advance(formation):
			combat.append(formation)
		elif formation != null and is_instance_valid(formation) and formation.is_alive and formation.is_supply_truck():
			logistics_skipped += 1
	if combat.is_empty():
		if logistics_skipped > 0:
			_show_feedback("LOGISTICS CANNOT ADVANCE", "INFO")
		return 0

	var actual_spacing: float = group_spacing if spacing < 0.0 else spacing
	var issued: Array[BattleFormation] = []
	for i: int in range(combat.size()):
		var formation: BattleFormation = combat[i]
		if _resupply_controller != null:
			_resupply_controller.cancel_active_for_direct_order(formation, "Direct ADVANCE override")
		formation.clear_combat_target()
		var lateral: float = (float(i) - float(combat.size() - 1) * 0.5) * actual_spacing
		var destination: Vector2 = world_target + Vector2(0.0, lateral)
		if formation.issue_advance(destination):
			_advance_intents[formation] = destination
			issued.append(formation)
	if not issued.is_empty():
		advance_order_issued.emit(issued, world_target)
		var suffix: String = " · LOGISTICS CANNOT ADVANCE" if logistics_skipped > 0 else ""
		_show_feedback("ADVANCE · %d FORMATION%s%s" % [issued.size(), "S" if issued.size() != 1 else "", suffix], "INFO")
	return issued.size()

func toggle_hold_fire_selected() -> int:
	_prune_selection()
	var combat: Array[BattleFormation] = []
	for formation: BattleFormation in _selected:
		if formation != null and is_instance_valid(formation) and formation.is_alive and formation.can_attack:
			combat.append(formation)
	if combat.is_empty():
		if not _selected.is_empty():
			_show_feedback("HOLD FIRE UNAVAILABLE · LOGISTICS", "INFO")
		return 0
	var enable: bool = false
	for formation: BattleFormation in combat:
		if not formation.is_hold_fire_enabled():
			enable = true
			break
	for formation: BattleFormation in combat:
		formation.set_hold_fire_enabled(enable)
	hold_fire_changed.emit(combat, enable)
	_show_feedback(("HOLD FIRE" if enable else "WEAPONS FREE") + " · %d FORMATION%s" % [combat.size(), "S" if combat.size() != 1 else ""], "TACTICAL" if enable else "INFO")
	_refresh_selected_hud_status()
	return combat.size()

func force_advance_decision_for_test() -> void:
	_update_advance_targets()

func is_advancing(formation: BattleFormation) -> bool:
	return formation != null and _advance_intents.has(formation) and formation.get_order() == "ADVANCE"

func get_advance_destination_for_test(formation: BattleFormation) -> Vector2:
	return Vector2(_advance_intents.get(formation, Vector2.ZERO))

func get_known_red_target_count_for_test() -> int:
	_prune_known_red_targets()
	return _known_red_targets.size()

func _update_advance_targets() -> void:
	if _intel == null or _visibility == null:
		return
	var formations: Array = _advance_intents.keys()
	for value: Variant in formations:
		var formation: BattleFormation = value as BattleFormation
		if formation == null or not is_instance_valid(formation) or not formation.is_alive or formation.get_order() != "ADVANCE":
			_advance_intents.erase(value)
			continue
		if formation.is_hold_fire_enabled():
			formation.clear_combat_target()
			continue
		var target: BattleFormation = _choose_advance_target(formation)
		if target == null:
			formation.clear_combat_target()
		else:
			formation.set_combat_target(target)

func _choose_advance_target(formation: BattleFormation) -> BattleFormation:
	var best: BattleFormation = null
	var best_distance: float = INF
	_prune_known_red_targets()
	for target: BattleFormation in _known_red_targets:
		# The intel gate deliberately occurs before target position is read. ADVANCE
		# therefore cannot use physical RED state while the player record is hidden,
		# CONTACT-only, or LAST_KNOWN.
		if _intel.get_intel_state_for(target) != BattleIntelTracker.CONFIRMED:
			continue
		if target == null or not is_instance_valid(target) or not target.is_alive or target.faction != "RED":
			continue
		var distance: float = formation.global_position.distance_to(target.global_position)
		if distance > formation.attack_range:
			continue
		if not _visibility.has_line_of_sight(formation.global_position, target.global_position):
			continue
		if best == null or distance < best_distance - DISTANCE_TIE_EPSILON or (absf(distance - best_distance) <= DISTANCE_TIE_EPSILON and target.display_name < best.display_name):
			best = target
			best_distance = distance
	return best

func _on_intel_record_changed(target: BattleFormation, _state: String, _last_known: Vector2) -> void:
	if target == null or not is_instance_valid(target) or target.faction != "RED":
		return
	if target not in _known_red_targets:
		_known_red_targets.append(target)

func _on_registered_order_changed(order_name: String, formation: BattleFormation) -> void:
	if formation == null or not is_instance_valid(formation):
		return
	if order_name != "ADVANCE" and _advance_intents.has(formation):
		_advance_intents.erase(formation)
		formation.clear_combat_target()
	_refresh_selected_hud_status()

func _on_friendlies_changed(formations: Array[BattleFormation]) -> void:
	for formation: BattleFormation in formations:
		register_formation(formation)

func _refresh_selected_hud_status() -> void:
	if _hud == null:
		return
	_prune_selection()
	var held: Array[BattleFormation] = []
	for formation: BattleFormation in _selected:
		if formation != null and is_instance_valid(formation) and formation.is_hold_fire_enabled():
			held.append(formation)
	if held.is_empty():
		return
	var order_name: String = held[0].get_order()
	var mixed: bool = false
	for formation: BattleFormation in held:
		if formation.get_order() != order_name:
			mixed = true
			break
	var order_text: String = "MIXED" if mixed else order_name
	_hud.show_command_feedback("HOLD FIRE ACTIVE · %d FORMATION%s · %s" % [held.size(), "S" if held.size() != 1 else "", order_text], "INFO")

func _show_feedback(message: String, level: String) -> void:
	if _hud != null:
		_hud.show_command_feedback(message, level)

func _can_receive_advance(formation: BattleFormation) -> bool:
	return (
		formation != null
		and is_instance_valid(formation)
		and formation.is_alive
		and formation.faction == "BLUE"
		and formation.can_attack
		and not formation.is_supply_truck()
	)

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

func _prune_known_red_targets() -> void:
	for i: int in range(_known_red_targets.size() - 1, -1, -1):
		var target: BattleFormation = _known_red_targets[i]
		if target == null or not is_instance_valid(target):
			_known_red_targets.remove_at(i)

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
	_refresh_selected_hud_status()

func _draw() -> void:
	if not _dragging or _drag_start.distance_to(_drag_current) < drag_threshold:
		return
	var rect: Rect2 = _make_rect(_drag_start, _drag_current)
	draw_rect(rect, Color(0.20, 0.78, 1.0, 0.10), true)
	draw_rect(rect, Color(0.35, 0.92, 1.0, 0.90), false, 2.0)