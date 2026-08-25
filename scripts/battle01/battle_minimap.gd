class_name BattleMinimap
extends Control

const MAP_SIZE := Vector2(3200.0, 1800.0)
const BLUE := Color("4d8cff")
const RED := Color("ff4d4d")
const AMBER := Color("ffc857")
const CYAN := Color("4dd0e1")

var _battle: Node2D
var _camera: Camera2D
var _central: BattleObjective
var _industrial: BattleObjective
var _intel: BattleIntelTracker
var _war_flow: BattlePlayerWarFlow

func configure(battle: Node2D) -> void:
	_battle = battle
	_camera = battle.get_node_or_null("BattleCamera") as Camera2D
	_central = battle.get_node_or_null("CentralBridgehead") as BattleObjective
	_industrial = battle.get_node_or_null("IndustrialObjective") as BattleObjective
	_intel = battle.get_node_or_null("IntelTracker") as BattleIntelTracker
	_war_flow = battle.get_node_or_null("PlayerWarFlow") as BattlePlayerWarFlow
	mouse_filter = Control.MOUSE_FILTER_STOP
	gui_input.connect(_on_gui_input)
	queue_redraw()

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var area := Rect2(Vector2.ZERO, size)
	draw_rect(area, Color(0.025, 0.045, 0.060, 0.98), true)
	draw_rect(area, Color(0.25, 0.42, 0.54, 0.85), false, 1.5)
	if size.x <= 2.0 or size.y <= 2.0:
		return

	# Macro terrain: west rear, river/bridge, north village, south route and east industry.
	_draw_world_rect(Rect2(120.0, 560.0, 620.0, 680.0), Color(0.08, 0.24, 0.34, 0.72))
	_draw_world_rect(Rect2(1480.0, 0.0, 240.0, 1800.0), Color(0.04, 0.20, 0.31, 0.95))
	_draw_world_rect(Rect2(1460.0, 790.0, 280.0, 220.0), Color(0.43, 0.42, 0.36, 0.92))
	_draw_world_rect(Rect2(1120.0, 250.0, 760.0, 360.0), Color(0.20, 0.22, 0.19, 0.86))
	_draw_world_rect(Rect2(850.0, 1280.0, 1480.0, 220.0), Color(0.14, 0.23, 0.17, 0.86))
	_draw_world_rect(Rect2(2440.0, 520.0, 560.0, 760.0), Color(0.27, 0.22, 0.20, 0.90))
	draw_line(_to_map(Vector2(420.0, 900.0)), _to_map(Vector2(2850.0, 900.0)), Color(0.50, 0.50, 0.45, 0.75), 2.0)
	_draw_route_relation([Vector2(650.0, 900.0), Vector2(1100.0, 500.0), Vector2(1600.0, 900.0)], Color(0.45, 0.58, 0.55, 0.35))
	_draw_route_relation([Vector2(650.0, 900.0), Vector2(1150.0, 900.0), Vector2(1600.0, 900.0)], Color(0.72, 0.72, 0.62, 0.45))
	_draw_route_relation([Vector2(650.0, 1050.0), Vector2(1150.0, 1390.0), Vector2(2100.0, 1390.0), Vector2(2720.0, 840.0)], Color(0.45, 0.58, 0.55, 0.35))

	_draw_objective(_central, false)
	_draw_objective(_industrial, true)
	_draw_rallies()
	_draw_formations()
	_draw_camera_viewport()

	_draw_map_text(Vector2(10.0, 17.0), "N", Color(0.72, 0.84, 0.90), 12)
	_draw_map_text(Vector2(10.0, size.y - 8.0), "WEST REAR", Color(0.38, 0.68, 1.0), 10)
	_draw_map_text(Vector2(size.x - 64.0, size.y - 8.0), "EAST", Color(0.72, 0.84, 0.90), 10)

func _draw_formations() -> void:
	if _battle == null:
		return
	for child: Node in _battle.get_children():
		if not child is BattleFormation:
			continue
		var formation := child as BattleFormation
		if not formation.is_alive or not formation.visible or formation.process_mode == Node.PROCESS_MODE_DISABLED:
			continue
		var marker_position: Vector2 = formation.global_position
		if formation.faction == "RED":
			if formation.intel_state == BattleIntelTracker.UNSEEN:
				continue
			if formation.intel_state == BattleIntelTracker.LAST_KNOWN:
				if _intel == null:
					continue
				marker_position = _intel.get_last_known_position_for(formation)
				_draw_stale_marker(_to_map(marker_position))
				continue
			if formation.intel_state == BattleIntelTracker.CONTACT:
				_draw_contact_marker(_to_map(marker_position))
				continue
			_draw_formation_marker(_to_map(marker_position), RED, formation.get_role(), false)
		else:
			_draw_formation_marker(_to_map(marker_position), BLUE, formation.get_role(), formation.is_selected)

func _draw_formation_marker(point: Vector2, color: Color, role: String, selected: bool) -> void:
	var heavy: bool = role == "IFV" or role == "TANK" or role == "ARMOR"
	var logistics: bool = role == "LOGISTICS"
	if heavy:
		draw_rect(Rect2(point - Vector2(4.5, 3.5), Vector2(9.0, 7.0)), color, true)
	elif logistics:
		draw_colored_polygon(PackedVector2Array([point + Vector2(0.0, -5.0), point + Vector2(5.0, 3.0), point + Vector2(-5.0, 3.0)]), color)
	else:
		draw_circle(point, 4.0, color)
	if selected:
		draw_arc(point, 7.0, 0.0, TAU, 16, Color.WHITE, 1.5)

func _draw_contact_marker(point: Vector2) -> void:
	draw_arc(point, 5.5, 0.2, PI - 0.2, 10, AMBER, 1.5)
	draw_arc(point, 5.5, PI + 0.2, TAU - 0.2, 10, AMBER, 1.5)
	draw_circle(point, 1.0, AMBER)

func _draw_stale_marker(point: Vector2) -> void:
	for index: int in range(8):
		var a0: float = TAU * float(index) / 8.0
		var a1: float = a0 + TAU / 16.0
		draw_arc(point, 6.0, a0, a1, 3, Color(0.75, 0.62, 0.42, 0.78), 1.4)
	draw_line(point + Vector2(-2.0, -2.0), point + Vector2(2.0, 2.0), Color(0.75, 0.62, 0.42, 0.78), 1.0)

func _draw_objective(objective: BattleObjective, decisive: bool) -> void:
	if objective == null:
		return
	var point: Vector2 = _to_map(objective.global_position)
	var color: Color = RED
	if objective.get_control_owner() == BattleObjective.OWNER_PLAYER:
		color = BLUE
	elif objective.get_control_owner() == BattleObjective.OWNER_NEUTRAL:
		color = Color(0.69, 0.69, 0.69)
	if objective.is_contested():
		color = AMBER
	var radius: float = 8.0 if decisive else 6.0
	draw_rect(Rect2(point - Vector2(radius, radius), Vector2(radius * 2.0, radius * 2.0)), Color(color, 0.18), true)
	draw_rect(Rect2(point - Vector2(radius, radius), Vector2(radius * 2.0, radius * 2.0)), color, false, 2.0)
	if decisive:
		draw_arc(point, radius + 3.0, 0.0, TAU, 24, Color(color, 0.72), 1.0)
	if objective.is_player_capture_locked():
		draw_line(point + Vector2(-4.0, -4.0), point + Vector2(4.0, 4.0), Color(0.65, 0.70, 0.74), 2.0)
		draw_line(point + Vector2(4.0, -4.0), point + Vector2(-4.0, 4.0), Color(0.65, 0.70, 0.74), 2.0)

func _draw_rallies() -> void:
	var west: Vector2 = _to_map(BattlePlayerWarFlow.WEST_REAR_RALLY)
	draw_arc(west, 5.0, 0.0, TAU, 16, Color(BLUE, 0.6), 1.0)
	if _war_flow != null and _war_flow.is_forward_rally_active():
		var forward: Vector2 = _to_map(BattlePlayerWarFlow.BRIDGEHEAD_FORWARD_RALLY)
		draw_arc(forward, 5.0, 0.0, TAU, 16, CYAN, 1.2)

func _draw_camera_viewport() -> void:
	if _camera == null or _camera.get_viewport() == null:
		return
	var viewport_size: Vector2 = _camera.get_viewport_rect().size / _camera.zoom
	var world_rect := Rect2(_camera.get_screen_center_position() - viewport_size * 0.5, viewport_size)
	var mapped := Rect2(_to_map(world_rect.position), world_rect.size / MAP_SIZE * size)
	draw_rect(mapped, Color(0.84, 0.92, 1.0, 0.65), false, 1.0)

func _draw_world_rect(world_rect: Rect2, color: Color) -> void:
	draw_rect(Rect2(_to_map(world_rect.position), world_rect.size / MAP_SIZE * size), color, true)

func _draw_route_relation(points: Array[Vector2], color: Color) -> void:
	var mapped := PackedVector2Array()
	for point: Vector2 in points:
		mapped.append(_to_map(point))
	if mapped.size() > 1:
		draw_polyline(mapped, color, 1.0)

func _draw_map_text(point: Vector2, value: String, color: Color, font_size: int) -> void:
	draw_string(ThemeDB.fallback_font, point, value, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size, color)

func _to_map(world: Vector2) -> Vector2:
	return Vector2(world.x / MAP_SIZE.x * size.x, world.y / MAP_SIZE.y * size.y)

func _to_world(local: Vector2) -> Vector2:
	return Vector2(local.x / maxf(1.0, size.x) * MAP_SIZE.x, local.y / maxf(1.0, size.y) * MAP_SIZE.y)

func _on_gui_input(event: InputEvent) -> void:
	if _camera == null:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_camera.position = _to_world(event.position)
		accept_event()
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_camera.position = _to_world(event.position)
		accept_event()
