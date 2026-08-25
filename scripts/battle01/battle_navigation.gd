class_name BattleNavigation
extends Node2D

const MAP_SIZE := Vector2(3200.0, 1800.0)
const CELL_SIZE := Vector2(40.0, 40.0)
const GRID_SIZE := Vector2i(80, 45)
const NEAREST_SEARCH_RADIUS: int = 12
const FORMATION_ORIGIN_TOLERANCE: float = 3.0

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

var _foot_grid: AStarGrid2D = AStarGrid2D.new()
var _vehicle_grid: AStarGrid2D = AStarGrid2D.new()
var _foot_solid_cells: Dictionary = {}
var _vehicle_solid_cells: Dictionary = {}

func _ready() -> void:
	_configure_grid(_foot_grid)
	_configure_grid(_vehicle_grid)

	for y: int in range(GRID_SIZE.y):
		for x: int in range(GRID_SIZE.x):
			var id := Vector2i(x, y)
			var world_point: Vector2 = _foot_grid.get_point_position(id)
			var hard_blocked: bool = _is_hard_blocked_position(world_point)
			if hard_blocked:
				_foot_solid_cells[id] = true
				_vehicle_solid_cells[id] = true
				_foot_grid.set_point_solid(id, true)
				_vehicle_grid.set_point_solid(id, true)
			elif BattleRouteTerrain.is_vehicle_clearance_blocked(world_point):
				_vehicle_solid_cells[id] = true
				_vehicle_grid.set_point_solid(id, true)

	queue_redraw()
	print("FRONTLINE_NAVIGATION_GRID_READY cells=%d foot_blocked=%d vehicle_blocked=%d mobility_profiles=2" % [
		GRID_SIZE.x * GRID_SIZE.y,
		_foot_solid_cells.size(),
		_vehicle_solid_cells.size(),
	])
	print("FRONTLINE_NORTH_FOOT_LINK_READY entry=%s exit=%s" % [
		BattleRouteTerrain.NORTH_FOOT_LINK_ENTRY,
		BattleRouteTerrain.NORTH_FOOT_LINK_EXIT,
	])

func _configure_grid(grid: AStarGrid2D) -> void:
	grid.region = Rect2i(Vector2i.ZERO, GRID_SIZE)
	grid.cell_size = CELL_SIZE
	grid.offset = CELL_SIZE * 0.5
	grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	grid.update()

func find_path(from_world: Vector2, to_world: Vector2) -> PackedVector2Array:
	return find_path_for_mobility(from_world, to_world, _resolve_mobility_for_origin(from_world))

func find_path_for_formation(formation: BattleFormation, to_world: Vector2) -> PackedVector2Array:
	if formation == null or not is_instance_valid(formation):
		return PackedVector2Array()
	return find_path_for_mobility(formation.global_position, to_world, mobility_for_formation(formation))

func find_path_for_mobility(from_world: Vector2, to_world: Vector2, mobility: String) -> PackedVector2Array:
	var normalized: String = _normalize_mobility(mobility)
	var grid: AStarGrid2D = _grid_for_mobility(normalized)
	var from_id: Vector2i = _nearest_walkable_id(_world_to_id(from_world), normalized)
	var to_id: Vector2i = _nearest_walkable_id(_world_to_id(to_world), normalized)
	if not _is_walkable_id(from_id, normalized) or not _is_walkable_id(to_id, normalized):
		return PackedVector2Array()
	return grid.get_point_path(from_id, to_id)

func mobility_for_formation(formation: BattleFormation) -> String:
	if formation == null or not is_instance_valid(formation):
		return BattleRouteTerrain.MOBILITY_VEHICLE
	return BattleRouteTerrain.mobility_for_role(formation.get_role())

func clamp_to_walkable(world_point: Vector2) -> Vector2:
	return clamp_to_walkable_for_mobility(world_point, BattleRouteTerrain.MOBILITY_VEHICLE)

func clamp_to_walkable_for_mobility(world_point: Vector2, mobility: String) -> Vector2:
	var normalized: String = _normalize_mobility(mobility)
	var id: Vector2i = _nearest_walkable_id(_world_to_id(world_point), normalized)
	if not _is_walkable_id(id, normalized):
		return world_point
	return _grid_for_mobility(normalized).get_point_position(id)

func is_world_walkable(world_point: Vector2) -> bool:
	return is_world_walkable_for_mobility(world_point, BattleRouteTerrain.MOBILITY_VEHICLE)

func is_world_walkable_for_mobility(world_point: Vector2, mobility: String) -> bool:
	return _is_walkable_id(_world_to_id(world_point), _normalize_mobility(mobility))

func get_named_route(route_name: StringName) -> PackedVector2Array:
	return get_named_route_for_mobility(route_name, BattleRouteTerrain.MOBILITY_VEHICLE)

func get_named_route_for_mobility(route_name: StringName, mobility: String) -> PackedVector2Array:
	match route_name:
		&"central":
			return _get_route_via(CENTRAL_ROUTE_GUIDES, mobility)
		&"north":
			return _get_route_via(NORTH_ROUTE_GUIDES, mobility)
		&"south":
			return _get_route_via(SOUTH_ROUTE_GUIDES, mobility)
	return PackedVector2Array()

func get_path_length(path: PackedVector2Array) -> float:
	var total: float = 0.0
	for i: int in range(1, path.size()):
		total += path[i - 1].distance_to(path[i])
	return total

func path_crosses_bridge(path: PackedVector2Array) -> bool:
	for point: Vector2 in path:
		if BattleRouteTerrain.BRIDGE_RECT.has_point(point):
			return true
	return false

func path_crosses_river_outside_bridge(path: PackedVector2Array) -> bool:
	for point: Vector2 in path:
		if BattleRouteTerrain.RIVER_RECT.has_point(point) and not BattleRouteTerrain.BRIDGE_RECT.has_point(point):
			return true
	return false

func path_uses_north_foot_link(path: PackedVector2Array) -> bool:
	return BattleRouteTerrain.path_uses_rect(path, BattleRouteTerrain.NORTH_FOOT_LINK_RECT)

func get_hard_blockers() -> Array[Rect2]:
	return BattleRouteTerrain.get_hard_blockers()

func get_north_foot_link_entry() -> Vector2:
	return BattleRouteTerrain.NORTH_FOOT_LINK_ENTRY

func get_north_foot_link_exit() -> Vector2:
	return BattleRouteTerrain.NORTH_FOOT_LINK_EXIT

func _get_route_via(guides: Array[Vector2], mobility: String) -> PackedVector2Array:
	var result := PackedVector2Array()
	if guides.size() < 2:
		return result
	for i: int in range(1, guides.size()):
		var segment: PackedVector2Array = find_path_for_mobility(guides[i - 1], guides[i], mobility)
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

func _nearest_walkable_id(origin: Vector2i, mobility: String) -> Vector2i:
	if _is_walkable_id(origin, mobility):
		return origin
	for radius: int in range(1, NEAREST_SEARCH_RADIUS + 1):
		for y: int in range(origin.y - radius, origin.y + radius + 1):
			for x: int in range(origin.x - radius, origin.x + radius + 1):
				if abs(x - origin.x) != radius and abs(y - origin.y) != radius:
					continue
				var candidate := Vector2i(x, y)
				if _is_walkable_id(candidate, mobility):
					return candidate
	return origin

func _is_walkable_id(id: Vector2i, mobility: String) -> bool:
	if id.x < 0 or id.y < 0 or id.x >= GRID_SIZE.x or id.y >= GRID_SIZE.y:
		return false
	var solid_cells: Dictionary = _foot_solid_cells if mobility == BattleRouteTerrain.MOBILITY_FOOT else _vehicle_solid_cells
	return not solid_cells.has(id)

func _is_hard_blocked_position(world_point: Vector2) -> bool:
	if BattleRouteTerrain.RIVER_RECT.has_point(world_point) and not BattleRouteTerrain.BRIDGE_RECT.has_point(world_point):
		return true
	return BattleRouteTerrain.is_hard_blocked(world_point)

func _grid_for_mobility(mobility: String) -> AStarGrid2D:
	return _foot_grid if mobility == BattleRouteTerrain.MOBILITY_FOOT else _vehicle_grid

func _normalize_mobility(mobility: String) -> String:
	if mobility == BattleRouteTerrain.MOBILITY_FOOT:
		return BattleRouteTerrain.MOBILITY_FOOT
	return BattleRouteTerrain.MOBILITY_VEHICLE

func _resolve_mobility_for_origin(from_world: Vector2) -> String:
	var matches: Array[BattleFormation] = []
	_collect_formations_at(get_parent(), from_world, matches)
	if matches.is_empty():
		return BattleRouteTerrain.MOBILITY_VEHICLE
	for formation: BattleFormation in matches:
		if mobility_for_formation(formation) == BattleRouteTerrain.MOBILITY_VEHICLE:
			return BattleRouteTerrain.MOBILITY_VEHICLE
	return BattleRouteTerrain.MOBILITY_FOOT

func _collect_formations_at(node: Node, world_point: Vector2, result: Array[BattleFormation]) -> void:
	if node == null:
		return
	if node is BattleFormation:
		var formation: BattleFormation = node as BattleFormation
		if is_instance_valid(formation) and formation.is_alive and formation.global_position.distance_to(world_point) <= FORMATION_ORIGIN_TOLERANCE:
			result.append(formation)
	for child: Node in node.get_children():
		_collect_formations_at(child, world_point, result)

func _draw() -> void:
	draw_rect(BattleRouteTerrain.RIVER_RECT, Color(0.08, 0.35, 0.58, 0.22), false, 3.0)
	draw_rect(BattleRouteTerrain.BRIDGE_RECT, Color(0.92, 0.74, 0.24, 0.70), false, 3.0)
	for blocker: Rect2 in BattleRouteTerrain.get_hard_blockers():
		draw_rect(blocker, Color(0.72, 0.30, 0.18, 0.14), true)
		draw_rect(blocker, Color(0.82, 0.42, 0.24, 0.48), false, 2.0)
	draw_rect(BattleRouteTerrain.NORTH_FOOT_LINK_RECT, Color(0.32, 0.82, 0.58, 0.18), true)
	draw_rect(BattleRouteTerrain.NORTH_FOOT_LINK_RECT, Color(0.32, 0.82, 0.58, 0.72), false, 2.0)
	draw_polyline(PackedVector2Array(CENTRAL_ROUTE_GUIDES), Color(0.92, 0.82, 0.44, 0.25), 2.0)
	draw_polyline(PackedVector2Array(NORTH_ROUTE_GUIDES), Color(0.48, 0.78, 0.82, 0.20), 2.0)
	draw_polyline(PackedVector2Array(SOUTH_ROUTE_GUIDES), Color(0.54, 0.82, 0.52, 0.20), 2.0)
