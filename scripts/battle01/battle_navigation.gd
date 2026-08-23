class_name BattleNavigation
extends Node2D

const MAP_SIZE := Vector2(3200.0, 1800.0)
const CELL_SIZE := Vector2(40.0, 40.0)
const GRID_SIZE := Vector2i(80, 45)
const NEAREST_SEARCH_RADIUS: int = 12

const RIVER_RECT := Rect2(Vector2(1480.0, 0.0), Vector2(240.0, 1800.0))
const BRIDGE_RECT := Rect2(Vector2(1440.0, 780.0), Vector2(320.0, 240.0))

const STATIC_BLOCKERS: Array[Rect2] = [
	# North Village building blocks. Streets between them remain connected.
	Rect2(Vector2(1120.0, 240.0), Vector2(220.0, 160.0)),
	Rect2(Vector2(1360.0, 260.0), Vector2(120.0, 180.0)),
	Rect2(Vector2(1120.0, 470.0), Vector2(260.0, 140.0)),
	Rect2(Vector2(1760.0, 260.0), Vector2(140.0, 160.0)),
	Rect2(Vector2(1760.0, 460.0), Vector2(160.0, 140.0)),
	# Existing central terrain blocker used by LOS.
	Rect2(Vector2(1120.0, 820.0), Vector2(160.0, 160.0)),
	# South corridor edges/earthworks: corridor stays open but requires a real detour.
	Rect2(Vector2(960.0, 1120.0), Vector2(320.0, 160.0)),
	Rect2(Vector2(1900.0, 1120.0), Vector2(320.0, 160.0)),
	# Industrial Area obstacle blocks with connected service lanes.
	Rect2(Vector2(2480.0, 560.0), Vector2(200.0, 200.0)),
	Rect2(Vector2(2760.0, 560.0), Vector2(200.0, 200.0)),
	Rect2(Vector2(2480.0, 900.0), Vector2(200.0, 160.0)),
	Rect2(Vector2(2760.0, 980.0), Vector2(180.0, 240.0)),
]

const CENTRAL_ROUTE_GUIDES: Array[Vector2] = [
	Vector2(520.0, 900.0),
	Vector2(1040.0, 900.0),
	Vector2(1400.0, 900.0),
	Vector2(1840.0, 900.0),
	Vector2(2360.0, 900.0),
]
const NORTH_ROUTE_GUIDES: Array[Vector2] = [
	Vector2(520.0, 900.0),
	Vector2(900.0, 640.0),
	Vector2(1060.0, 620.0),
	Vector2(1420.0, 700.0),
	Vector2(1600.0, 900.0),
	Vector2(1880.0, 700.0),
	Vector2(2200.0, 620.0),
	Vector2(2360.0, 700.0),
]
const SOUTH_ROUTE_GUIDES: Array[Vector2] = [
	Vector2(520.0, 900.0),
	Vector2(900.0, 1360.0),
	Vector2(1320.0, 1400.0),
	Vector2(1440.0, 1080.0),
	Vector2(1600.0, 900.0),
	Vector2(1760.0, 1080.0),
	Vector2(2200.0, 1400.0),
	Vector2(2360.0, 1320.0),
]

var _grid: AStarGrid2D = AStarGrid2D.new()
var _solid_cells: Dictionary = {}

func _ready() -> void:
	_grid.region = Rect2i(Vector2i.ZERO, GRID_SIZE)
	_grid.cell_size = CELL_SIZE
	_grid.offset = CELL_SIZE * 0.5
	_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	_grid.update()

	for y: int in range(GRID_SIZE.y):
		for x: int in range(GRID_SIZE.x):
			var id := Vector2i(x, y)
			var world_point: Vector2 = _grid.get_point_position(id)
			if _is_blocked_position(world_point):
				_solid_cells[id] = true
				_grid.set_point_solid(id, true)

	queue_redraw()
	print("FRONTLINE_NAVIGATION_GRID_READY cells=%d blocked=%d" % [GRID_SIZE.x * GRID_SIZE.y, _solid_cells.size()])

func find_path(from_world: Vector2, to_world: Vector2) -> PackedVector2Array:
	var from_id: Vector2i = _nearest_walkable_id(_world_to_id(from_world))
	var to_id: Vector2i = _nearest_walkable_id(_world_to_id(to_world))
	if not _is_walkable_id(from_id) or not _is_walkable_id(to_id):
		return PackedVector2Array()
	return _grid.get_point_path(from_id, to_id)

func clamp_to_walkable(world_point: Vector2) -> Vector2:
	var id: Vector2i = _nearest_walkable_id(_world_to_id(world_point))
	if not _is_walkable_id(id):
		return world_point
	return _grid.get_point_position(id)

func is_world_walkable(world_point: Vector2) -> bool:
	return _is_walkable_id(_world_to_id(world_point))

func get_named_route(route_name: StringName) -> PackedVector2Array:
	match route_name:
		&"central":
			return _get_route_via(CENTRAL_ROUTE_GUIDES)
		&"north":
			return _get_route_via(NORTH_ROUTE_GUIDES)
		&"south":
			return _get_route_via(SOUTH_ROUTE_GUIDES)
	return PackedVector2Array()

func get_path_length(path: PackedVector2Array) -> float:
	var total: float = 0.0
	for i: int in range(1, path.size()):
		total += path[i - 1].distance_to(path[i])
	return total

func path_crosses_bridge(path: PackedVector2Array) -> bool:
	for point: Vector2 in path:
		if BRIDGE_RECT.has_point(point):
			return true
	return false

func path_crosses_river_outside_bridge(path: PackedVector2Array) -> bool:
	for point: Vector2 in path:
		if RIVER_RECT.has_point(point) and not BRIDGE_RECT.has_point(point):
			return true
	return false

func _get_route_via(guides: Array[Vector2]) -> PackedVector2Array:
	var result := PackedVector2Array()
	if guides.size() < 2:
		return result
	for i: int in range(1, guides.size()):
		var segment: PackedVector2Array = find_path(guides[i - 1], guides[i])
		if segment.is_empty():
			return PackedVector2Array()
		var start_index: int = 1 if not result.is_empty() else 0
		for j: int in range(start_index, segment.size()):
			result.append(segment[j])
	return result

func _world_to_id(world_point: Vector2) -> Vector2i:
	var clamped := Vector2(
		clampf(world_point.x, 0.0, MAP_SIZE.x - 0.001),
		clampf(world_point.y, 0.0, MAP_SIZE.y - 0.001)
	)
	return Vector2i(int(floor(clamped.x / CELL_SIZE.x)), int(floor(clamped.y / CELL_SIZE.y)))

func _nearest_walkable_id(origin: Vector2i) -> Vector2i:
	if _is_walkable_id(origin):
		return origin
	for radius: int in range(1, NEAREST_SEARCH_RADIUS + 1):
		for y: int in range(origin.y - radius, origin.y + radius + 1):
			for x: int in range(origin.x - radius, origin.x + radius + 1):
				if abs(x - origin.x) != radius and abs(y - origin.y) != radius:
					continue
				var candidate := Vector2i(x, y)
				if _is_walkable_id(candidate):
					return candidate
	return origin

func _is_walkable_id(id: Vector2i) -> bool:
	return (
		id.x >= 0
		and id.y >= 0
		and id.x < GRID_SIZE.x
		and id.y < GRID_SIZE.y
		and not _solid_cells.has(id)
	)

func _is_blocked_position(world_point: Vector2) -> bool:
	if RIVER_RECT.has_point(world_point) and not BRIDGE_RECT.has_point(world_point):
		return true
	for blocker: Rect2 in STATIC_BLOCKERS:
		if blocker.has_point(world_point):
			return true
	return false

func _draw() -> void:
	# Navigation debug/blockout only; not formal art.
	draw_rect(RIVER_RECT, Color(0.08, 0.35, 0.58, 0.22), false, 3.0)
	draw_rect(BRIDGE_RECT, Color(0.92, 0.74, 0.24, 0.70), false, 3.0)
	for blocker: Rect2 in STATIC_BLOCKERS:
		draw_rect(blocker, Color(0.72, 0.30, 0.18, 0.14), true)
		draw_rect(blocker, Color(0.82, 0.42, 0.24, 0.48), false, 2.0)
	draw_polyline(PackedVector2Array(CENTRAL_ROUTE_GUIDES), Color(0.92, 0.82, 0.44, 0.25), 2.0)
	draw_polyline(PackedVector2Array(NORTH_ROUTE_GUIDES), Color(0.48, 0.78, 0.82, 0.20), 2.0)
	draw_polyline(PackedVector2Array(SOUTH_ROUTE_GUIDES), Color(0.54, 0.82, 0.52, 0.20), 2.0)
