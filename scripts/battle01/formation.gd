class_name BattleFormation
extends Node2D

signal selection_changed(selected: bool)
signal order_changed(order_name: String)
signal health_changed(current_hp: int, max_hp_value: int)
signal ammo_changed(current_ammo: int, max_ammo: int)
signal attack_fired(attacker: BattleFormation, target: BattleFormation, damage: int)
signal died(formation: BattleFormation)

@export var definition: FormationDefinition
@export var display_name: String = "FORMATION"
@export var faction: String = "BLUE"
@export var selectable: bool = true
@export var selection_radius: float = 34.0
@export var body_color: Color = Color(0.12, 0.55, 0.92)

var is_selected: bool = false
var is_alive: bool = true
var current_order: String = "HOLD"
var current_hp: int = 0
var current_ammo: int = 0
var current_supply_charges: int = 0
var intel_state: String = "CONFIRMED"

var move_speed: float = 100.0
var max_hp: int = 100
var can_attack: bool = true
var attack_damage: int = 0
var attack_range: float = 0.0
var fire_interval: float = 1.0
var ammo_capacity: int = 0
var detection_range: float = 250.0
var can_capture: bool = true
var indirect_fire: bool = false
var supply_capacity: int = 0

var _move_target: Vector2
var _has_move_target: bool = false
var _move_path := PackedVector2Array()
var _path_index: int = 0
var _navigation: BattleNavigation
var _combat_target: BattleFormation
var _visibility_field: BattleVisibilityField
var _fire_cooldown: float = 0.0
var _damage_serial: int = 0
var _fire_serial: int = 0
var _visual_lod: int = 1
var _command_feedback_remaining: float = 0.0
var _shot_fx_remaining: float = 0.0
var _shot_fx_target: Vector2 = Vector2.ZERO
var _under_fire_remaining: float = 0.0
var _death_fx_remaining: float = 0.0

func _ready() -> void:
	_apply_definition()
	current_hp = max_hp
	current_ammo = ammo_capacity
	current_supply_charges = supply_capacity
	_move_target = global_position
	health_changed.emit(current_hp, max_hp)
	ammo_changed.emit(current_ammo, ammo_capacity)
	queue_redraw()

func _process(delta: float) -> void:
	_update_visual_presentation(delta)
	if not is_alive:
		return
	_fire_cooldown = maxf(0.0, _fire_cooldown - delta)
	_update_combat()
	_update_movement(delta)

func _apply_definition() -> void:
	if definition == null:
		push_warning("%s has no FormationDefinition; safe fallback stats are active." % name)
		return
	var errors: PackedStringArray = definition.validate()
	if not errors.is_empty():
		push_error("Invalid FormationDefinition %s: %s" % [definition.id, ", ".join(errors)])
	move_speed = definition.move_speed
	max_hp = definition.max_hp
	can_attack = definition.can_attack
	attack_damage = definition.attack_damage
	attack_range = definition.attack_range
	fire_interval = definition.fire_interval
	ammo_capacity = definition.ammo_capacity
	detection_range = definition.detection_range
	can_capture = definition.can_capture
	indirect_fire = definition.indirect_fire
	supply_capacity = definition.supply_capacity

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

func set_navigation(navigation: BattleNavigation) -> void:
	_navigation = navigation

func issue_move(world_target: Vector2) -> bool:
	return _issue_navigation_order(world_target, "MOVE")

func issue_withdraw(world_target: Vector2) -> bool:
	clear_combat_target()
	return _issue_navigation_order(world_target, "WITHDRAW")

func _issue_navigation_order(world_target: Vector2, order_name: String) -> bool:
	if not is_alive:
		return false
	if _navigation == null:
		push_error("%s cannot %s without BattleNavigation." % [name, order_name])
		return false
	var new_path: PackedVector2Array = _navigation.find_path(global_position, world_target)
	if new_path.is_empty():
		push_warning("%s %s rejected: no legal navigation path." % [name, order_name])
		return false
	_move_path = new_path
	_path_index = 1 if _move_path.size() > 1 else 0
	_move_target = _move_path[_move_path.size() - 1]
	_has_move_target = true
	_set_order(order_name)
	_command_feedback_remaining = 1.5
	queue_redraw()
	return true

func stop() -> void:
	_has_move_target = false
	_move_path = PackedVector2Array()
	_path_index = 0
	_move_target = global_position
	_set_order("HOLD")
	queue_redraw()

func set_combat_target(target: BattleFormation) -> void:
	if target == self:
		return
	_combat_target = target

func clear_combat_target() -> void:
	_combat_target = null

func set_visibility_field(field: BattleVisibilityField) -> void:
	_visibility_field = field

func set_intel_state(value: String) -> void:
	if intel_state == value:
		return
	intel_state = value
	queue_redraw()

func take_damage(amount: int) -> void:
	if not is_alive or amount <= 0:
		return
	_damage_serial += 1
	_under_fire_remaining = 0.65
	current_hp = maxi(0, current_hp - amount)
	health_changed.emit(current_hp, max_hp)
	queue_redraw()
	if current_hp <= 0:
		_die()

func restore_ammo(amount: int) -> int:
	if not is_alive or amount <= 0 or ammo_capacity <= 0:
		return 0
	var before: int = current_ammo
	current_ammo = mini(ammo_capacity, current_ammo + amount)
	var restored: int = current_ammo - before
	if restored > 0:
		ammo_changed.emit(current_ammo, ammo_capacity)
		queue_redraw()
	return restored

func consume_supply_charge() -> bool:
	if not is_alive or not is_supply_truck() or current_supply_charges <= 0:
		return false
	current_supply_charges -= 1
	queue_redraw()
	return true

func get_supply_charges() -> int:
	return current_supply_charges

func is_supply_truck() -> bool:
	return supply_capacity > 0 and not can_attack and not can_capture

func get_damage_serial() -> int:
	return _damage_serial

func get_fire_serial() -> int:
	return _fire_serial

func get_order() -> String:
	return current_order

func get_role() -> String:
	return definition.role if definition != null else "UNDEFINED"

func is_capture_capable() -> bool:
	return is_alive and can_capture

func has_active_navigation_path() -> bool:
	return _has_move_target and not _move_path.is_empty()

func get_navigation_path() -> PackedVector2Array:
	return _move_path.duplicate()

func _update_movement(delta: float) -> void:
	if not _has_move_target:
		return
	if _move_path.is_empty() or _path_index >= _move_path.size():
		_finish_move()
		return

	while _path_index < _move_path.size():
		var waypoint: Vector2 = _move_path[_path_index]
		var offset: Vector2 = waypoint - global_position
		if offset.length() <= 4.0:
			global_position = waypoint
			_path_index += 1
			continue
		global_position += offset.normalized() * minf(move_speed * delta, offset.length())
		queue_redraw()
		return

	_finish_move()

func _finish_move() -> void:
	if not _move_path.is_empty():
		global_position = _move_path[_move_path.size() - 1]
	_has_move_target = false
	_move_path = PackedVector2Array()
	_path_index = 0
	_move_target = global_position
	_set_order("HOLD")
	queue_redraw()

func _update_combat() -> void:
	if not can_attack or current_ammo <= 0:
		return
	if _combat_target == null:
		return
	if not is_instance_valid(_combat_target) or not _combat_target.is_alive:
		_combat_target = null
		return
	if global_position.distance_to(_combat_target.global_position) > attack_range:
		return
	if _visibility_field != null and not _visibility_field.has_line_of_sight(global_position, _combat_target.global_position):
		return
	if _fire_cooldown > 0.0:
		return
	_fire_cooldown = fire_interval
	current_ammo = maxi(0, current_ammo - 1)
	_fire_serial += 1
	_shot_fx_target = to_local(_combat_target.global_position)
	_shot_fx_remaining = 0.18 if get_role() == "TANK" else 0.12
	ammo_changed.emit(current_ammo, ammo_capacity)
	attack_fired.emit(self, _combat_target, attack_damage)
	_combat_target.take_damage(attack_damage)

func _die() -> void:
	if not is_alive:
		return
	is_alive = false
	_has_move_target = false
	_move_path = PackedVector2Array()
	_path_index = 0
	_combat_target = null
	if is_supply_truck():
		current_supply_charges = 0
	if is_selected:
		is_selected = false
		selection_changed.emit(false)
	_set_order("DESTROYED")
	_death_fx_remaining = 1.6
	queue_redraw()
	died.emit(self)

func _set_order(value: String) -> void:
	if current_order == value:
		return
	current_order = value
	order_changed.emit(current_order)

func _draw() -> void:
	var scale_factor: float = _marker_scale()
	if faction == "RED":
		if intel_state == "UNSEEN" or intel_state == "LAST_KNOWN":
			return
		if intel_state == "CONTACT":
			_draw_contact_marker(scale_factor)
			return

	if not is_alive:
		_draw_destroyed(scale_factor)
		return

	var faction_color: Color = Color("4d8cff") if faction == "BLUE" else Color("ff4d4d")
	_draw_formation_body(scale_factor, faction_color)
	_draw_role_glyph(scale_factor, Color.WHITE)

	var hp_ratio: float = float(current_hp) / float(maxi(1, max_hp))
	var damaged: bool = current_hp < max_hp
	var may_show_hp: bool = is_selected or _under_fire_remaining > 0.0 or (damaged and _visual_lod != 2)
	if faction == "RED" and intel_state != "CONFIRMED":
		may_show_hp = false
	if may_show_hp:
		_draw_hp_bar(scale_factor, hp_ratio)

	var low_ammo: bool = ammo_capacity > 0 and current_ammo <= int(floor(float(ammo_capacity) * 0.25))
	if low_ammo and (is_selected or _visual_lod != 0):
		var ammo_text: String = "EMPTY" if current_ammo == 0 else "LOW AMMO"
		draw_string(ThemeDB.fallback_font, Vector2(-30.0, 52.0) * scale_factor, ammo_text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, int(11.0 * scale_factor), Color("ffc857"))
	if is_supply_truck() and (is_selected or current_supply_charges == 0):
		draw_string(ThemeDB.fallback_font, Vector2(-34.0, 52.0) * scale_factor, "AMMO %d/%d" % [current_supply_charges, supply_capacity], HORIZONTAL_ALIGNMENT_LEFT, -1.0, int(11.0 * scale_factor), Color("4dd0e1") if current_supply_charges > 0 else Color("ff5544"))

	if is_selected:
		draw_arc(Vector2.ZERO, 40.0 * scale_factor, 0.0, TAU, 48, Color(0.65, 0.88, 1.0), 3.0 * scale_factor)
		draw_arc(Vector2.ZERO, 34.0 * scale_factor, -PI * 0.20, PI * 0.20, 12, faction_color.lightened(0.25), 4.0 * scale_factor)

	if _visual_lod == 0 and (is_selected or damaged or low_ammo):
		draw_string(ThemeDB.fallback_font, Vector2(-46.0, -52.0) * scale_factor, _abbreviated_name(), HORIZONTAL_ALIGNMENT_LEFT, -1.0, int(12.0 * scale_factor), Color.WHITE)
	elif _visual_lod == 1 and is_selected:
		draw_string(ThemeDB.fallback_font, Vector2(-46.0, -52.0) * scale_factor, _abbreviated_name(), HORIZONTAL_ALIGNMENT_LEFT, -1.0, int(12.0 * scale_factor), Color.WHITE)

	if is_selected or (_visual_lod == 1 and current_order != "HOLD"):
		_draw_order_glyph(scale_factor)
	if _is_capturing():
		draw_string(ThemeDB.fallback_font, Vector2(28.0, -28.0) * scale_factor, "CAP", HORIZONTAL_ALIGNMENT_LEFT, -1.0, int(10.0 * scale_factor), Color("ffc857"))

	_draw_command_path(scale_factor)
	_draw_combat_fx(scale_factor)

func _update_visual_presentation(delta: float) -> void:
	_command_feedback_remaining = maxf(0.0, _command_feedback_remaining - delta)
	_shot_fx_remaining = maxf(0.0, _shot_fx_remaining - delta)
	_under_fire_remaining = maxf(0.0, _under_fire_remaining - delta)
	_death_fx_remaining = maxf(0.0, _death_fx_remaining - delta)
	var camera: Camera2D = get_viewport().get_camera_2d()
	if camera != null:
		var zoom_value: float = camera.zoom.x
		var previous_lod: int = _visual_lod
		if _visual_lod == 2 and zoom_value > 0.82:
			_visual_lod = 1
		elif _visual_lod == 1:
			if zoom_value < 0.72:
				_visual_lod = 2
			elif zoom_value > 1.22:
				_visual_lod = 0
		elif _visual_lod == 0 and zoom_value < 1.10:
			_visual_lod = 1
		if previous_lod != _visual_lod:
			queue_redraw()
	if _command_feedback_remaining > 0.0 or _shot_fx_remaining > 0.0 or _under_fire_remaining > 0.0 or _death_fx_remaining > 0.0:
		queue_redraw()

func _marker_scale() -> float:
	var camera: Camera2D = get_viewport().get_camera_2d()
	if camera == null:
		return 1.0
	return clampf(1.0 / maxf(0.1, camera.zoom.x), 0.72, 1.65)

func _draw_contact_marker(scale_factor: float) -> void:
	var radius: float = 27.0 * scale_factor
	draw_circle(Vector2.ZERO, radius, Color(0.95, 0.60, 0.18, 0.09))
	draw_arc(Vector2.ZERO, radius, 0.18, PI - 0.18, 20, Color(0.95, 0.66, 0.24, 0.92), 3.0 * scale_factor)
	draw_arc(Vector2.ZERO, radius, PI + 0.18, TAU - 0.18, 20, Color(0.95, 0.66, 0.24, 0.92), 3.0 * scale_factor)
	draw_string(ThemeDB.fallback_font, Vector2(-7.0, 7.0) * scale_factor, "?", HORIZONTAL_ALIGNMENT_LEFT, -1.0, int(22.0 * scale_factor), Color(1.0, 0.82, 0.35))

func _draw_destroyed(scale_factor: float) -> void:
	var radius: float = 27.0 * scale_factor
	draw_circle(Vector2.ZERO, radius, Color(0.10, 0.11, 0.11, 0.92))
	draw_line(Vector2(-17.0, -17.0) * scale_factor, Vector2(17.0, 17.0) * scale_factor, Color(0.76, 0.18, 0.16), 4.0 * scale_factor)
	draw_line(Vector2(17.0, -17.0) * scale_factor, Vector2(-17.0, 17.0) * scale_factor, Color(0.76, 0.18, 0.16), 4.0 * scale_factor)
	if _death_fx_remaining > 0.0:
		var fade: float = clampf(_death_fx_remaining / 1.6, 0.0, 1.0)
		draw_circle(Vector2.ZERO, (42.0 + (1.0 - fade) * 24.0) * scale_factor, Color(1.0, 0.38, 0.10, fade * 0.18))
		draw_circle(Vector2(8.0, -22.0) * scale_factor, 13.0 * scale_factor, Color(0.18, 0.18, 0.17, fade * 0.55))

func _draw_formation_body(scale_factor: float, color: Color) -> void:
	var radius: float = (23.0 if _visual_lod == 0 else 26.0 if _visual_lod == 1 else 29.0) * scale_factor
	if _visual_lod == 0:
		draw_circle(Vector2.ZERO, radius, color.darkened(0.28))
		draw_circle(Vector2.ZERO, radius - 6.0 * scale_factor, color.darkened(0.58))
	else:
		draw_circle(Vector2.ZERO, radius, Color(color, 0.22))
		draw_arc(Vector2.ZERO, radius, 0.0, TAU, 32, color, (3.0 if _visual_lod == 1 else 4.5) * scale_factor)
	if faction == "RED":
		draw_rect(Rect2(Vector2(-15.0, -15.0) * scale_factor, Vector2(30.0, 30.0) * scale_factor), Color(color, 0.18), false, 2.0 * scale_factor)

func _draw_role_glyph(scale_factor: float, color: Color) -> void:
	var s: float = scale_factor
	match get_role():
		"RECON":
			draw_arc(Vector2.ZERO, 10.0 * s, PI * 0.15, PI * 0.85, 12, color, 2.2 * s)
			draw_circle(Vector2.ZERO, 3.0 * s, color)
		"INFANTRY":
			draw_circle(Vector2(0.0, -5.0) * s, 3.0 * s, color)
			draw_line(Vector2(0.0, -1.0) * s, Vector2(0.0, 9.0) * s, color, 2.4 * s)
			draw_line(Vector2(-7.0, 3.0) * s, Vector2(7.0, 3.0) * s, color, 2.0 * s)
		"IFV":
			draw_rect(Rect2(Vector2(-11.0, -7.0) * s, Vector2(22.0, 14.0) * s), color, false, 2.2 * s)
			draw_circle(Vector2.ZERO, 4.0 * s, color)
		"TANK", "ARMOR":
			draw_rect(Rect2(Vector2(-10.0, -8.0) * s, Vector2(20.0, 16.0) * s), color, false, 2.4 * s)
			draw_line(Vector2.ZERO, Vector2(14.0, 0.0) * s, color, 3.0 * s)
		"LOGISTICS":
			draw_rect(Rect2(Vector2(-10.0, -8.0) * s, Vector2(20.0, 16.0) * s), color, false, 2.2 * s)
			draw_line(Vector2(-6.0, 0.0) * s, Vector2(6.0, 0.0) * s, color, 2.0 * s)
			draw_line(Vector2.ZERO, Vector2(0.0, -5.0) * s, color, 2.0 * s)

func _draw_hp_bar(scale_factor: float, ratio: float) -> void:
	var width: float = 62.0 * scale_factor
	var origin := Vector2(-31.0, -43.0) * scale_factor
	var hp_color := Color("6ccb6c") if ratio > 0.55 else Color("ffc857") if ratio > 0.25 else Color("ff5544")
	draw_rect(Rect2(origin, Vector2(width, 6.0 * scale_factor)), Color(0.02, 0.03, 0.03, 0.92))
	draw_rect(Rect2(origin, Vector2(width * ratio, 6.0 * scale_factor)), hp_color)

func _draw_order_glyph(scale_factor: float) -> void:
	var color := Color("6ccb6c") if current_order == "MOVE" else Color("ffc857") if current_order == "WITHDRAW" else Color("4d8cff")
	var text: String = "MOV" if current_order == "MOVE" else "WD" if current_order == "WITHDRAW" else "HLD" if current_order == "HOLD" else current_order.left(3)
	draw_string(ThemeDB.fallback_font, Vector2(-15.0, 70.0) * scale_factor, text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, int(10.0 * scale_factor), color)

func _draw_command_path(scale_factor: float) -> void:
	if not _has_move_target or _path_index >= _move_path.size():
		return
	var retain_terminal: bool = is_selected and _command_feedback_remaining <= 0.0
	if _command_feedback_remaining <= 0.0 and not retain_terminal:
		return
	var color := Color("ffc857") if current_order == "WITHDRAW" else Color("6ccb6c")
	var alpha: float = 0.28 if retain_terminal else clampf(_command_feedback_remaining / 1.5, 0.25, 0.82)
	var local_path := PackedVector2Array([Vector2.ZERO])
	for index: int in range(_path_index, _move_path.size()):
		local_path.append(to_local(_move_path[index]))
	if local_path.size() >= 2 and not retain_terminal:
		if current_order == "WITHDRAW":
			_draw_dashed_path(local_path, Color(color, alpha), 11.0 * scale_factor, 2.3 * scale_factor)
		else:
			draw_polyline(local_path, Color(color, alpha), 2.3 * scale_factor)
	var destination: Vector2 = to_local(_move_target)
	draw_arc(destination, 15.0 * scale_factor, 0.0, TAU, 24, Color(color, alpha + 0.15), 2.0 * scale_factor)
	if current_order == "WITHDRAW":
		draw_line(destination + Vector2(-8.0, -4.0) * scale_factor, destination, color, 2.0 * scale_factor)
		draw_line(destination + Vector2(-8.0, 4.0) * scale_factor, destination, color, 2.0 * scale_factor)

func _draw_dashed_path(points: PackedVector2Array, color: Color, dash: float, width: float) -> void:
	for index: int in range(1, points.size()):
		var from_point: Vector2 = points[index - 1]
		var to_point: Vector2 = points[index]
		var length: float = from_point.distance_to(to_point)
		if length <= 0.001: continue
		var direction: Vector2 = (to_point - from_point) / length
		var cursor: float = 0.0
		while cursor < length:
			var end_distance: float = minf(length, cursor + dash)
			draw_line(from_point + direction * cursor, from_point + direction * end_distance, color, width)
			cursor += dash * 1.8

func _draw_combat_fx(scale_factor: float) -> void:
	if _shot_fx_remaining > 0.0:
		var ratio: float = _shot_fx_remaining / (0.18 if get_role() == "TANK" else 0.12)
		var heavy: bool = get_role() == "TANK" or get_role() == "ARMOR"
		var ifv: bool = get_role() == "IFV"
		var shot_color: Color = Color(1.0, 0.70, 0.28, ratio) if heavy else Color(1.0, 0.86, 0.42, ratio)
		var width: float = (5.0 if heavy else 3.0 if ifv else 1.5) * scale_factor
		draw_line(Vector2.ZERO, _shot_fx_target, shot_color, width)
		var direction: Vector2 = _shot_fx_target.normalized() if _shot_fx_target.length() > 0.01 else Vector2.RIGHT
		draw_circle(direction * 25.0 * scale_factor, (11.0 if heavy else 7.0 if ifv else 4.0) * scale_factor, Color(1.0, 0.48, 0.15, ratio * 0.72))
	if _under_fire_remaining > 0.0:
		var fade: float = _under_fire_remaining / 0.65
		draw_arc(Vector2.ZERO, 33.0 * scale_factor, -PI * 0.85, -PI * 0.15, 16, Color(1.0, 0.24, 0.16, fade), 3.5 * scale_factor)
		draw_circle(Vector2(17.0, 12.0) * scale_factor, 5.0 * scale_factor, Color(1.0, 0.48, 0.18, fade * 0.66))

func _is_capturing() -> bool:
	if not can_capture or get_parent() == null:
		return false
	for child: Node in get_parent().get_children():
		if child is BattleObjective:
			var objective := child as BattleObjective
			if objective.state == "CAPTURING" and global_position.distance_to(objective.global_position) <= objective.capture_radius:
				return true
	return false

func _abbreviated_name() -> String:
	return display_name.replace("BLUE ", "").replace("RED ", "")
