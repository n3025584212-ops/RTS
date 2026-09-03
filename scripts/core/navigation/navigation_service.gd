class_name NavigationService
extends RefCounted

var map_size: Vector2 = Vector2.ZERO
var cell_size: Vector2 = Vector2.ONE
var grid_size: Vector2i = Vector2i.ONE
var nearest_search_radius: int = 12

var _grids: Dictionary = {}
var _blocked_cells: Dictionary = {}

func configure(
	map_size_value: Vector2,
	cell_size_value: Vector2,
	profiles: Array[StringName],
	blocked_query: Callable,
	nearest_radius_value: int = 12
) -> void:
	map_size = map_size_value
	cell_size = Vector2(maxf(1.0, cell_size_value.x), maxf(1.0, cell_size_value.y))
	grid_size = Vector2i(
		maxi(1, int(ceil(map_size.x / cell_size.x))),
		maxi(1, int(ceil(map_size.y / cell_size.y)))
	)
	nearest_search_radius = maxi(1, nearest_radius_value)
	_grids.clear()
	_blocked_cells.clear()

	for profile: StringName in profiles:
		var grid := AStarGrid2D.new()
		grid.region = Rect2i(Vector2i.ZERO, grid_size)
		grid.cell_size = cell_size
		grid.offset = cell_size * 0.5
		grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
		grid.update()
		var blocked: Dictionary = {}
		for y: int in range(grid_size.y):
			for x: int in range(grid_size.x):
				var id := Vector2i(x, y)
				var world_point: Vector2 = grid.get_point_position(id)
				if blocked_query.is_valid() and bool(blocked_query.call(world_point, profile)):
					blocked[id] = true
					grid.set_point_solid(id, true)
		_grids[profile] = grid
		_blocked_cells[profile] = blocked

func has_profile(profile: StringName) -> bool:
	return _grids.has(profile)

func find_path(from_world: Vector2, to_world: Vector2, profile: StringName) -> PackedVector2Array:
	if not _grids.has(profile):
		return PackedVector2Array()
	var grid: AStarGrid2D = _grids[profile] as AStarGrid2D
	var from_id: Vector2i = _nearest_walkable_id(_world_to_id(from_world), profile)
	var to_id: Vector2i = _nearest_walkable_id(_world_to_id(to_world), profile)
	if not _is_walkable_id(from_id, profile) or not _is_walkable_id(to_id, profile):
		return PackedVector2Array()
	return grid.get_point_path(from_id, to_id)

func clamp_to_walkable(world_point: Vector2, profile: StringName) -> Vector2:
	if not _grids.has(profile):
		return world_point
	var id: Vector2i = _nearest_walkable_id(_world_to_id(world_point), profile)
	if not _is_walkable_id(id, profile):
		return world_point
	return (_grids[profile] as AStarGrid2D).get_point_position(id)

func is_world_walkable(world_point: Vector2, profile: StringName) -> bool:
	return _is_walkable_id(_world_to_id(world_point), profile)

func get_path_length(path: PackedVector2Array) -> float:
	var total: float = 0.0
	for index: int in range(1, path.size()):
		total += path[index - 1].distance_to(path[index])
	return total

func get_blocked_count(profile: StringName) -> int:
	if not _blocked_cells.has(profile):
		return 0
	return (_blocked_cells[profile] as Dictionary).size()

func _world_to_id(world_point: Vector2) -> Vector2i:
	var clamped := Vector2(
		clampf(world_point.x, 0.0, maxf(0.0, map_size.x - 0.001)),
		clampf(world_point.y, 0.0, maxf(0.0, map_size.y - 0.001))
	)
	return Vector2i(int(floor(clamped.x / cell_size.x)), int(floor(clamped.y / cell_size.y)))

func _nearest_walkable_id(origin: Vector2i, profile: StringName) -> Vector2i:
	if _is_walkable_id(origin, profile):
		return origin
	for radius: int in range(1, nearest_search_radius + 1):
		for y: int in range(origin.y - radius, origin.y + radius + 1):
			for x: int in range(origin.x - radius, origin.x + radius + 1):
				if abs(x - origin.x) != radius and abs(y - origin.y) != radius:
					continue
				var candidate := Vector2i(x, y)
				if _is_walkable_id(candidate, profile):
					return candidate
	return origin

func _is_walkable_id(id: Vector2i, profile: StringName) -> bool:
	if not _grids.has(profile):
		return false
	if id.x < 0 or id.y < 0 or id.x >= grid_size.x or id.y >= grid_size.y:
		return false
	var blocked: Dictionary = _blocked_cells.get(profile, {}) as Dictionary
	return not blocked.has(id)
