class_name RiverTownArmorPlatoon
extends Node3D

## Gate D2 (MULTI_FORMATION_SELECTION).
## Owns input for the armour platoon in the River Town mother scene: single-click
## select, drag-box multi select with an on-screen marquee, and
## formation-preserving group orders. Per-vehicle input is disabled via
## RiverTownArmoredUnit.input_enabled so exactly one owner handles the mouse.
## Selection and movement call the same validated BattleFormation chain the
## vehicles already use; this node adds no parallel movement code. The marquee is
## standard RTS operator feedback, not a debug overlay.

const DRAG_THRESHOLD_PX := 8.0
const CLICK_TOLERANCE_PX := 30.0
## Hull is 6.4 m wide (13.0 m long, long axis Z). The platoon spawns at a 6.0 m
## frontage and the declared order pitch is 8.0 m, so a group order both keeps
## the formation's shape and opens it out to a readable spacing instead of
## interpenetrating armour.
const GROUP_SPACING_WORLD := 8.0
## Spawn line abreast: X offsets (world) and the shared Z row. The first entry
## is the Gate B foreground Abrams position and is not moved.
const PLATOON_LINE_X: Array[float] = [2.5, 8.5, 14.5, 20.5]
const PLATOON_LINE_Z := 7.0

var units: Array[RiverTownArmoredUnit] = []
var camera: Camera3D
var marquee_layer: CanvasLayer
var marquee: Control
var marquee_rect := Rect2()
var marquee_active := false
var drag_start := Vector2.ZERO

func register_unit(unit: RiverTownArmoredUnit) -> void:
	units.append(unit)
	unit.input_enabled = false

func _ready() -> void:
	camera = get_viewport().get_camera_3d()
	marquee_layer = CanvasLayer.new()
	marquee_layer.name = "GateD2MarqueeLayer"
	add_child(marquee_layer)
	marquee = Control.new()
	marquee.name = "GateD2Marquee"
	marquee.set_anchors_preset(Control.PRESET_FULL_RECT)
	marquee.mouse_filter = Control.MOUSE_FILTER_IGNORE
	marquee.draw.connect(_on_marquee_draw)
	marquee_layer.add_child(marquee)
	set_process_unhandled_input(true)

func _on_marquee_draw() -> void:
	if marquee_active:
		marquee.draw_rect(marquee_rect, Color(0.3, 0.9, 1.0, 0.10), true)
		marquee.draw_rect(marquee_rect, Color(0.3, 0.9, 1.0, 0.85), false, 2.0)

func _unhandled_input(event: InputEvent) -> void:
	if camera == null or units.is_empty():
		return
	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.button_index == MOUSE_BUTTON_LEFT:
			if mouse.pressed:
				drag_start = mouse.position
				marquee_active = false
				marquee_rect = Rect2()
				marquee.queue_redraw()
			else:
				_finish_left(mouse.position)
			get_viewport().set_input_as_handled()
		elif mouse.button_index == MOUSE_BUTTON_RIGHT and mouse.pressed:
			_group_order(mouse.position)
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion:
		var motion := event as InputEventMouseMotion
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			if not marquee_active and drag_start.distance_to(motion.position) >= DRAG_THRESHOLD_PX:
				marquee_active = true
			if marquee_active:
				marquee_rect = Rect2(drag_start, motion.position - drag_start).abs()
				marquee.queue_redraw()
				get_viewport().set_input_as_handled()

func _finish_left(pos: Vector2) -> void:
	if marquee_active:
		marquee_active = false
		marquee.queue_redraw()
		_box_select(marquee_rect)
	else:
		_click_select(pos)

func _click_select(pos: Vector2) -> void:
	var best := -1
	var best_distance := CLICK_TOLERANCE_PX
	for index in range(units.size()):
		var screen := _unit_screen_position(units[index])
		if screen == Vector2.INF:
			continue
		var distance := screen.distance_to(pos)
		if distance <= best_distance:
			best_distance = distance
			best = index
	for index in range(units.size()):
		units[index].formation.set_selected(index == best)
	print("FRONTLINE_GATE_D2_CLICK_SELECT selected=%d" % best)

func _box_select(rect: Rect2) -> void:
	var count := 0
	for index in range(units.size()):
		var screen := _unit_screen_position(units[index])
		var inside := screen != Vector2.INF and rect.has_point(screen)
		units[index].formation.set_selected(inside)
		if inside:
			count += 1
	print("FRONTLINE_GATE_D2_BOX_SELECT selected=%d" % count)

func _spread_axis(base: Vector3) -> Vector3:
	# Lateral axis perpendicular to the camera->destination line so a group
	# order reads as a line across the screen (standard RTS behaviour).
	var to_base := base - camera.global_position
	var flat := Vector3(to_base.x, 0.0, to_base.z)
	if flat.length_squared() < 0.25:
		return Vector3(1.0, 0.0, 0.0)
	var perpendicular := Vector3(flat.z, 0.0, -flat.x)
	return perpendicular.normalized()

## Formation-preserving group order: units are sorted along the lateral axis and
## re-slotted in that order, so a line abreast advances as a line abreast instead
## of each unit running to the slot its array index happens to hold (which crosses
## paths and scrambles the formation). Slot pitch is the larger of the declared
## spacing and the formation's current mean gap, so a bunched group opens out and
## an already-spread group keeps its frontage. Returns unit -> destination so the
## caller keeps the platoon's own unit order.
func _formation_destinations(base: Vector3, selected: Array[RiverTownArmoredUnit]) -> Dictionary:
	var result := {}
	if selected.is_empty():
		return result
	var right := _spread_axis(base)
	var ordered: Array[RiverTownArmoredUnit] = selected.duplicate()
	ordered.sort_custom(func(a: RiverTownArmoredUnit, b: RiverTownArmoredUnit) -> bool:
		return _lateral(a, base, right) < _lateral(b, base, right))
	var lowest := _lateral(ordered[0], base, right)
	var highest := _lateral(ordered[ordered.size() - 1], base, right)
	var mean_gap := 0.0 if ordered.size() < 2 else (highest - lowest) / float(ordered.size() - 1)
	var pitch := maxf(GROUP_SPACING_WORLD, mean_gap)
	var centre := (highest + lowest) * 0.5
	for index in range(ordered.size()):
		var slot := centre + (float(index) - float(ordered.size() - 1) * 0.5) * pitch
		result[ordered[index]] = base + right * slot
	return result

func _lateral(unit: RiverTownArmoredUnit, base: Vector3, right: Vector3) -> float:
	var position3 := unit.get_tank_position()
	return (Vector3(position3.x - base.x, 0.0, position3.z - base.z)).dot(right)

func _group_order(pos: Vector2) -> void:
	var selected := _selected_units()
	if selected.is_empty():
		return
	var ground: Variant = _ground_point_under(pos)
	if ground == null:
		return
	var base := ground as Vector3
	var destinations := _formation_destinations(base, selected)
	for unit in selected:
		if destinations.has(unit):
			_bind_destination(unit, destinations[unit])
	print("FRONTLINE_GATE_D2_GROUP_ORDER count=%d base=%s" % [selected.size(), str(base)])

## Routes a destination through the unit's validated issue_move chain, snapping
## the order point to the terrain height at that spot.
func _bind_destination(unit: RiverTownArmoredUnit, destination: Vector3) -> void:
	var ground_y: float = float(_scene_root().call("height_at", destination.x, destination.z))
	unit.issue_move_to(Vector3(destination.x, ground_y, destination.z))

func demo_click_select(index: int) -> bool:
	if index < 0 or index >= units.size():
		print("FRONTLINE_GATE_D2_CLICK_SELECT_REJECTED index_out_of_range index=%d" % index)
		return false
	marquee_active = false
	marquee_rect = Rect2()
	marquee.queue_redraw()
	var pos := _unit_screen_position(units[index])
	if pos == Vector2.INF:
		print("FRONTLINE_GATE_D2_CLICK_SELECT_REJECTED off_screen index=%d" % index)
		return false
	_click_select(pos)
	return true

## Evidence entry point for the drag-box path, phase 1: builds the marquee
## rectangle the drag sweeps over the requested units and shows it, exactly as
## `_unhandled_input` does while the left button is held. No selection is
## applied yet — that is the release phase's job, as in the mouse path.
func demo_drag_begin(indices: Array) -> Rect2:
	var rect := Rect2()
	var first := true
	for index in indices:
		var pos := _unit_screen_position(units[index])
		if pos == Vector2.INF:
			continue
		if first:
			rect = Rect2(pos, Vector2.ZERO)
			first = false
		else:
			rect = rect.expand(pos)
	rect = rect.grow(24.0)
	marquee_active = true
	marquee_rect = rect
	marquee.queue_redraw()
	print("FRONTLINE_GATE_D2_DRAG_BEGIN rect=%s swept=%d selected_before=%d" % [
		str(rect), indices.size(), _selected_units().size()])
	return rect

## Evidence entry point for the drag-box path, phase 2: hides the marquee and
## runs the same `_box_select` the mouse release runs.
func demo_drag_release() -> int:
	var rect := marquee_rect
	marquee_active = false
	marquee.queue_redraw()
	_box_select(rect)
	var count := _selected_units().size()
	print("FRONTLINE_GATE_D2_DRAG_RELEASE rect=%s selected=%d" % [str(rect), count])
	return count

func is_marquee_active() -> bool:
	return marquee_active

func demo_group_move(base_destination: Vector3) -> void:
	var selected := _selected_units()
	var destinations := _formation_destinations(base_destination, selected)
	for unit in selected:
		if destinations.has(unit):
			_bind_destination(unit, destinations[unit])
	print("FRONTLINE_GATE_D2_DEMO_GROUP_MOVE count=%d base=%s dests=%s" % [
		selected.size(), str(base_destination), str(destinations.values())])

func selected_count() -> int:
	return _selected_units().size()

func get_unit_count() -> int:
	return units.size()

func get_selected_start_positions() -> Dictionary:
	var result := {}
	for unit in _selected_units():
		result[str(unit.name)] = unit.get_tank_position()
	return result

func get_unit_by_name(unit_name: String) -> RiverTownArmoredUnit:
	for unit in units:
		if str(unit.name) == unit_name:
			return unit
	return null

func _selected_units() -> Array[RiverTownArmoredUnit]:
	var result: Array[RiverTownArmoredUnit] = []
	for unit in units:
		if unit.formation != null and unit.formation.is_selected and unit.formation.is_alive:
			result.append(unit)
	return result

func _unit_screen_position(unit: RiverTownArmoredUnit) -> Vector2:
	if camera == null or unit.tank == null:
		return Vector2.INF
	if not camera.is_position_in_frustum(unit.tank.global_position + Vector3(0.0, 1.2, 0.0)):
		return Vector2.INF
	return camera.unproject_position(unit.tank.global_position + Vector3(0.0, 1.2, 0.0))

func _ground_point_under(pos: Vector2):
	if camera == null or units.is_empty():
		return null
	var reference := units[0].get_tank_position()
	var origin := camera.project_ray_origin(pos)
	var direction := camera.project_ray_normal(pos)
	if absf(direction.y) < 0.0001:
		return null
	var t := (reference.y - origin.y) / direction.y
	if t <= 0.0:
		return null
	return origin + direction * t

func _scene_root() -> Node3D:
	if units.is_empty():
		return null
	return units[0].scene_root
