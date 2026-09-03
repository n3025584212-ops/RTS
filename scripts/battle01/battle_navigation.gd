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

var _service: NavigationService = NavigationService.new()

func _ready() -> void:
	var profiles: Array[StringName] = [&"FOOT", &"VEHICLE"]
	_service.configure(
		MAP_SIZE,
		CELL_SIZE,
		profiles,
		Callable(self, "_is_blocked_for_profile"),
		NEAREST_SEARCH_RADIUS
	)
	queue_redraw()
	print("FRONTLINE_NAVIGATION_GRID_READY cells=%d foot_blocked=%d vehicle_blocked=%d mobility_profiles=2 core_service=YES" % [
		GRID_SIZE.x * GRID_SIZE.y,
		_service.get_blocked_count(&"FOOT"),
		_service.get_blocked_count(&"VEHICLE"),
	])
	print("FRONTLINE_NORTH_FOOT_LINK_READY entry=%s exit=%s" % [BattleRouteTerrain.NORTH_FOOT_LINK_ENTRY, BattleRouteTerrain.NORTH_FOOT_LINK_EXIT])

func find_path(from_world: Vector2, to_world: Vector2) -> PackedVector2Array:
	return find_path_for_mobility(from_world, to_world, _resolve_mobility_for_origin(from_world))

func find_path_for_formation(formation: Node2D, to_world: Vector2) -> PackedVector2Array:
	if formation == null or not is_instance_valid(formation):
		return PackedVector2Array()
	return find_path_for_mobility(formation.global_position, to_world, mobility_for_formation(formation))

func find_path_for_mobility(from_world: Vector2, to_world: Vector2, mobility: String) -> PackedVector2Array:
	return _service.find_path(from_world, to_world, _profile_for_mobility(mobility))

func mobility_for_formation(formation: Node) -> String:
	if formation == null or not is_instance_valid(formation) or not formation.has_method("get_role"):
		return BattleRouteTerrain.MOBILITY_VEHICLE
	return BattleRouteTerrain.mobility_for_role(str(formation.call("get_role")))

func clamp_to_walkable(world_point: Vector2) -> Vector2:
	return clamp_to_walkable_for_mobility(world_point, BattleRouteTerrain.MOBILITY_VEHICLE)

func clamp_to_walkable_for_mobility(world_point: Vector2, mobility: String) -> Vector2:
	return _service.clamp_to_walkable(world_point, _profile_for_mobility(mobility))

func is_world_walkable(world_point: Vector2) -> bool:
	return is_world_walkable_for_mobility(world_point, BattleRouteTerrain.MOBILITY_VEHICLE)

func is_world_walkable_for_mobility(world_point: Vector2, mobility: String) -> bool:
	return _service.is_world_walkable(world_point, _profile_for_mobility(mobility))

func get_named_route(route_name: StringName) -> PackedVector2Array:
	return get_named_route_for_mobility(route_name, BattleRouteTerrain.MOBILITY_VEHICLE)

func get_named_route_for_mobility(route_name: StringName, mobility: String) -> PackedVector2Array:
	match route_name:
		&"central": return _get_route_via(CENTRAL_ROUTE_GUIDES, mobility)
		&"north": return _get_route_via(NORTH_ROUTE_GUIDES, mobility)
		&"south": return _get_route_via(SOUTH_ROUTE_GUIDES, mobility)
	return PackedVector2Array()

func get_path_length(path: PackedVector2Array) -> float:
	return _service.get_path_length(path)

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
	for index: int in range(1, guides.size()):
		var segment: PackedVector2Array = find_path_for_mobility(guides[index - 1], guides[index], mobility)
		if segment.is_empty():
			return PackedVector2Array()
		var start_index: int = 1 if not result.is_empty() else 0
		for segment_index: int in range(start_index, segment.size()):
			result.append(segment[segment_index])
	return result

func _is_blocked_for_profile(world_point: Vector2, profile: StringName) -> bool:
	if _is_hard_blocked_position(world_point):
		return true
	return profile == &"VEHICLE" and BattleRouteTerrain.is_vehicle_clearance_blocked(world_point)

func _is_hard_blocked_position(world_point: Vector2) -> bool:
	if BattleRouteTerrain.RIVER_RECT.has_point(world_point) and not BattleRouteTerrain.BRIDGE_RECT.has_point(world_point):
		return true
	return BattleRouteTerrain.is_hard_blocked(world_point)

func _profile_for_mobility(mobility: String) -> StringName:
	return &"FOOT" if mobility == BattleRouteTerrain.MOBILITY_FOOT else &"VEHICLE"

func _resolve_mobility_for_origin(from_world: Vector2) -> String:
	# Legacy compatibility only. New Core callers must bind mobility explicitly.
	var matches: Array[Node2D] = []
	_collect_formations_at(get_parent(), from_world, matches)
	if matches.is_empty():
		return BattleRouteTerrain.MOBILITY_VEHICLE
	for formation: Node2D in matches:
		if mobility_for_formation(formation) == BattleRouteTerrain.MOBILITY_VEHICLE:
			return BattleRouteTerrain.MOBILITY_VEHICLE
	return BattleRouteTerrain.MOBILITY_FOOT

func _collect_formations_at(node: Node, world_point: Vector2, result: Array[Node2D]) -> void:
	if node == null:
		return
	if node is Node2D and node.has_method("get_role"):
		var candidate: Node2D = node as Node2D
		if candidate.global_position.distance_to(world_point) <= FORMATION_ORIGIN_TOLERANCE:
			result.append(candidate)
	for child: Node in node.get_children():
		_collect_formations_at(child, world_point, result)

func _draw() -> void:
	# Battle01-specific debug rendering remains in this scenario adapter.
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
