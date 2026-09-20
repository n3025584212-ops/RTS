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
## Hull is 6.44 x 12.97 m world (long axis Z, measured from the mesh AABB). The
## declared order pitch is 8.0 m and the deployment row is deliberately wider, so
## a group order keeps the frontage it already has instead of tightening it.
const GROUP_SPACING_WORLD := 8.0
## Deployment. Entry 0 is the Gate B foreground Abrams (D1 baseline position,
## z 7.0, not moved); the other three deploy in the open ground north of the
## village road at z -12.0. Placement rules this layout satisfies:
## - the Gate D1 hostile sits at (8.5, 0.08, 3.0) with a 9.05 x 12.23 m hull
##   footprint (x 3.43..12.48, z -3.20..9.03), so a vehicle must keep its hull
##   either east of x 15.7, north of z -9.7 or south of z 15.5. The previous row
##   (x 8.5/14.5/20.5 at z 7.0) spawned a hull 58 m^2 inside the hostile;
## - the vehicle navigation grid is 500 x 500 sim units = world +-25 m, so no
##   vehicle may sit or path outside x 24 / z 24 (the previous row reached x 34
##   and the pathfinder dragged that vehicle back to the map edge).
const PLATOON_LINE_X: Array[float] = [2.5, 6.0, 14.0, 22.0]
const PLATOON_LINE_Z := -12.0

var units: Array[RiverTownArmoredUnit] = []
var camera: Camera3D
var marquee_layer: CanvasLayer
var marquee: Control
var marquee_rect := Rect2()
var marquee_active := false
var drag_start := Vector2.ZERO
var last_order_base := Vector3.ZERO

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
	# Slots are centred on the ordered point itself, not on the formation's own
	# lateral midpoint. Centring on the formation offsets the whole row by however
	# far the group sat off-centre from the click, which on a 500x500 sim nav grid
	# pushes the outer vehicles past the map edge — they then path to the boundary
	# and report HOLD short of their slot.
	for index in range(ordered.size()):
		var slot := (float(index) - float(ordered.size() - 1) * 0.5) * pitch
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
	last_order_base = base
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

func get_last_order_base() -> Vector3:
	return last_order_base

func is_marquee_active() -> bool:
	return marquee_active

## Evidence entry point for the group order that mirrors the mouse path exactly:
## the requested world destination is projected to a screen point and handed to
## `_group_order`, so the screen->ground raycast is exercised too.
func demo_group_order_at_world(base_destination: Vector3) -> bool:
	if camera == null:
		print("FRONTLINE_GATE_D2_GROUP_ORDER_REJECTED no_camera")
		return false
	if _selected_units().is_empty():
		print("FRONTLINE_GATE_D2_GROUP_ORDER_REJECTED nothing_selected")
		return false
	var screen := camera.unproject_position(base_destination)
	_group_order(screen)
	print("FRONTLINE_GATE_D2_GROUP_ORDER_AT_WORLD requested=%s screen=%s" % [
		str(base_destination), str(screen)])
	return true

## Mean lateral gap of the current deployment — what the order algorithm uses as
## its pitch floor. Printed at startup so a diagnostic never contradicts itself.
func deployment_frontage() -> float:
	if units.size() < 2:
		return 0.0
	var lowest := INF
	var highest := -INF
	for unit in units:
		var position3 := unit.get_tank_position()
		lowest = minf(lowest, position3.x)
		highest = maxf(highest, position3.x)
	return (highest - lowest) / float(units.size() - 1)

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
