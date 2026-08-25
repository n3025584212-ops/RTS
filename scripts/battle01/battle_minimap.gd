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
	draw_rect(area, Color(0.020, 0.038, 0.052, 0.98), true)
	draw_rect(area, Color(0.28, 0.46, 0.58, 0.85), false, 1.5)
	if size.x <= 2.0 or size.y <= 2.0:
		return

	# Tactical grid.
	for gx: int in range(1, 8):
		var grid_x: float = size.x * float(gx) / 8.0
		draw_line(Vector2(grid_x, 0.0), Vector2(grid_x, size.y), Color(0.30, 0.42, 0.48, 0.16), 1.0)
	for gy: int in range(1, 6):
		var grid_y: float = size.y * float(gy) / 6.0
		draw_line(Vector2(0.0, grid_y), Vector2(size.x, grid_y), Color(0.30, 0.42, 0.48, 0.16), 1.0)

	# Macro terrain: west rear, river/bridge, north village, south route and east industry.
	_draw_world_rect(Rect2(120.0, 560.0, 620.0, 680.0), Color(0.10, 0.30, 0.40, 0.80))
	_draw_world_rect(Rect2(1480.0, 0.0, 240.0, 1800.0), Color(0.05, 0.26, 0.38, 0.95))
	_draw_world_rect(Rect2(1460.0, 790.0, 280.0, 220.0), Color(0.52, 0.50, 0.42, 0.95))
	_draw_world_rect(Rect2(1120.0, 250.0, 760.0, 360.0), Color(0.26, 0.28, 0.24, 0.90))
	_draw_world_rect(Rect2(850.0, 1280.0, 1480.0, 220.0), Color(0.18, 0.30, 0.22, 0.90))
	_draw_world_rect(Rect2(2440.0, 520.0, 560.0, 760.0), Color(0.34, 0.28, 0.25, 0.92))
	draw_line(_to_map(Vector2(420.0, 900.0)), _to_map(Vector2(2850.0, 900.0)), Color(0.62, 0.60, 0.52, 0.85), 2.0)
	draw_line(_to_map(Vector2(420.0, 900.0)), _to_map(Vector2(2850.0, 900.0)), Color(0.85, 0.82, 0.68, 0.40), 0.8)
	_draw_route_relation([Vector2(650.0, 900.0), Vector2(1100.0, 500.0), Vector2(1600.0, 900.0)], Color(0.45, 0.58, 0.55, 0.35))
	_draw_route_relation([Vector2(650.0, 900.0), Vector2(1150.0, 900.0), Vector2(1600.0, 900.0)], Color(0.72, 0.72, 0.62, 0.45))
	_draw_route_relation([Vector2(650.0, 1050.0), Vector2(1150.0, 1390.0), Vector2(2100.0, 1390.0), Vector2(2720.0, 840.0)], Color(0.45, 0.58, 0.55, 0.35))

	_draw_objective(_central, false)
	_draw_objective(_industrial, true)
	_draw_rallies()
	_draw_formations()
	_draw_selected_paths()
	_draw_camera_viewport()

	_draw_map_text(Vector2(8.0, 15.0), "N", Color(0.75, 0.86, 0.92), 12)
	_draw_map_text(Vector2(8.0, size.y - 8.0), "WEST REAR", Color(0.38, 0.68, 1.0), 10)
	_draw_map_text(Vector2(size.x - 60.0, size.y - 8.0), "EAST", Color(0.75, 0.86, 0.92), 10)

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
			_draw_formation_marker(_to_map(marker_position), RED, formation.get_role(), formation.is_selected)
		else:
			_draw_formation_marker(_to_map(marker_position), BLUE, formation.get_role(), formation.is_selected)

func _draw_formation_marker(point: Vector2, color: Color, role: String, selected: bool) -> void:
	var heavy: bool = role == "IFV" or role == "TANK" or role == "ARMOR"
	var logistics: bool = role == "LOGISTICS"
	if heavy:
		draw_rect(Rect2(point - Vector2(4.5, 3.5), Vector2(9.0, 7.0)), Color(color, 1.0), true)
		draw_rect(Rect2(point - Vector2(4.5, 3.5), Vector2(9.0, 7.0)), Color(color, 1.0), false, 1.0)
	elif logistics:
		draw_colored_polygon(PackedVector2Array([point + Vector2(0.0, -5.0), point + Vector2(5.0, 3.0), point + Vector2(-5.0, 3.0)]), Color(color, 1.0))
		draw_arc(point, 4.0, 0.0, TAU, 10, Color(0.30, 0.82, 0.88, 0.9), 1.0)
	else:
		draw_circle(point, 3.6, Color(color, 1.0))
		draw_circle(point, 5.6, Color(color, 0.35), false, 1.0)
	if selected:
		draw_arc(point, 8.0, 0.0, TAU, 16, Color.WHITE, 1.6)

func _draw_contact_marker(point: Vector2) -> void:
	draw_arc(point, 5.5, 0.2, PI - 0.2, 10, AMBER, 1.5)
	draw_arc(point, 5.5, PI + 0.2, TAU - 0.2, 10, AMBER, 1.5)
	draw_circle(point, 1.2, AMBER)

func _draw_stale_marker(point: Vector2) -> void:
	for index: int in range(8):
		var a0: float = TAU * float(index) / 8.0
		var a1: float = a0 + TAU / 16.0
		draw_arc(point, 6.0, a0, a1, 3, Color(0.75, 0.62, 0.42, 0.78), 1.4)
	draw_line(point + Vector2(-2.0, -2.0), point + Vector2(2.0, 2.0), Color(0.75, 0.62, 0.42, 0.78), 1.0)
	draw_circle(point, 1.2, Color(0.75, 0.62, 0.42, 0.85))

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
	draw_rect(Rect2(point - Vector2(radius + 2.0, radius + 2.0), Vector2(radius * 2.0 + 4.0, radius * 2.0 + 4.0)), Color(color, 0.16), true)
	draw_rect(Rect2(point - Vector2(radius, radius), Vector2(radius * 2.0, radius * 2.0)), Color(color, 1.0), false, 2.0)
	if decisive:
		draw_rect(Rect2(point - Vector2(radius * 0.45, radius * 0.45), Vector2(radius * 0.9, radius * 0.9)), Color(color, 1.0), true)
		draw_arc(point, radius + 4.0, 0.0, TAU, 24, Color(color, 0.72), 1.0)
	else:
		draw_circle(point, radius * 0.42, Color(color, 1.0), false, 1.6)
	if objective.is_contested():
		draw_arc(point, radius + 3.0, 0.0, TAU, 20, AMBER, 1.8)
	if objective.is_player_capture_locked():
		draw_line(point + Vector2(-4.0, -4.0), point + Vector2(4.0, 4.0), Color(0.65, 0.70, 0.74), 2.0)
		draw_line(point + Vector2(4.0, -4.0), point + Vector2(-4.0, 4.0), Color(0.65, 0.70, 0.74), 2.0)

func _draw_rallies() -> void:
	var west: Vector2 = _to_map(BattlePlayerWarFlow.WEST_REAR_RALLY)
	draw_arc(west, 5.0, 0.0, TAU, 16, Color(BLUE, 0.6), 1.0)
	draw_line(west + Vector2(0.0, -6.0), west + Vector2(0.0, 6.0), Color(BLUE, 0.85), 1.2)
	draw_line(west + Vector2(-4.0, 6.0), west + Vector2(0.0, 2.0), Color(BLUE, 0.85), 1.2)
	draw_line(west + Vector2(4.0, 6.0), west + Vector2(0.0, 2.0), Color(BLUE, 0.85), 1.2)
	if _war_flow != null and _war_flow.is_forward_rally_active():
		var forward: Vector2 = _to_map(BattlePlayerWarFlow.BRIDGEHEAD_FORWARD_RALLY)
		draw_arc(forward, 5.0, 0.0, TAU, 16, CYAN, 1.2)
		draw_line(forward + Vector2(0.0, -6.0), forward + Vector2(0.0, 6.0), Color(CYAN, 0.9), 1.2)
		draw_line(forward + Vector2(-4.0, 6.0), forward + Vector2(0.0, 2.0), Color(CYAN, 0.9), 1.2)
		draw_line(forward + Vector2(4.0, 6.0), forward + Vector2(0.0, 2.0), Color(CYAN, 0.9), 1.2)

func _draw_selected_paths() -> void:
	if _battle == null:
		return
	for child: Node in _battle.get_children():
		if not child is BattleFormation:
			continue
		var formation := child as BattleFormation
		if formation.faction != "BLUE" or not formation.is_selected or not formation.is_alive:
			continue
		if not formation.has_active_navigation_path():
			continue
		var path: PackedVector2Array = formation.get_navigation_path()
		var mapped := PackedVector2Array()
		for point: Vector2 in path:
			mapped.append(_to_map(point))
		if mapped.size() >= 2:
			draw_polyline(mapped, Color(0.42, 0.80, 0.42, 0.55), 1.2)

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