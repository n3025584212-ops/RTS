class_name BattleVisibilityField
extends Node2D

signal smoke_deployed(center: Vector2, radius: float, duration: float)
signal smoke_expired

const CLEAR: String = "CLEAR"
const TERRAIN: String = "TERRAIN"
const SMOKE: String = "SMOKE"

const TERRAIN_BLOCKERS: Array[Rect2] = [
	Rect2(Vector2(1120.0, 820.0), Vector2(160.0, 160.0)),
	Rect2(Vector2(1190.0, 300.0), Vector2(190.0, 180.0)),
	Rect2(Vector2(1510.0, 310.0), Vector2(210.0, 190.0)),
]

var _smoke_centers: Array[Vector2] = []
var _smoke_radii: Array[float] = []
var _smoke_remaining: Array[float] = []

func _ready() -> void:
	queue_redraw()

func _process(delta: float) -> void:
	var changed: bool = false
	for i: int in range(_smoke_remaining.size() - 1, -1, -1):
		_smoke_remaining[i] = maxf(0.0, _smoke_remaining[i] - delta)
		if _smoke_remaining[i] <= 0.0:
			_smoke_centers.remove_at(i)
			_smoke_radii.remove_at(i)
			_smoke_remaining.remove_at(i)
			changed = true
			smoke_expired.emit()
	if changed or not _smoke_centers.is_empty():
		queue_redraw()

func deploy_smoke(center: Vector2, radius: float = 95.0, duration: float = 1.25) -> void:
	if radius <= 0.0 or duration <= 0.0:
		return
	_smoke_centers.append(center)
	_smoke_radii.append(radius)
	_smoke_remaining.append(duration)
	smoke_deployed.emit(center, radius, duration)
	queue_redraw()

func clear_smoke() -> void:
	_smoke_centers.clear()
	_smoke_radii.clear()
	_smoke_remaining.clear()
	queue_redraw()

func has_line_of_sight(from_world: Vector2, to_world: Vector2) -> bool:
	return get_block_reason(from_world, to_world) == CLEAR

func get_block_reason(from_world: Vector2, to_world: Vector2) -> String:
	for blocker: Rect2 in TERRAIN_BLOCKERS:
		if _segment_intersects_rect(from_world, to_world, blocker):
			return TERRAIN
	for i: int in range(_smoke_centers.size()):
		if _segment_intersects_circle(from_world, to_world, _smoke_centers[i], _smoke_radii[i]):
			return SMOKE
	return CLEAR

func _segment_intersects_rect(a: Vector2, b: Vector2, rect: Rect2) -> bool:
	if rect.has_point(a) or rect.has_point(b):
		return true
	var p0: Vector2 = rect.position
	var p1: Vector2 = Vector2(rect.end.x, rect.position.y)
	var p2: Vector2 = rect.end
	var p3: Vector2 = Vector2(rect.position.x, rect.end.y)
	return (
		Geometry2D.segment_intersects_segment(a, b, p0, p1) != null
		or Geometry2D.segment_intersects_segment(a, b, p1, p2) != null
		or Geometry2D.segment_intersects_segment(a, b, p2, p3) != null
		or Geometry2D.segment_intersects_segment(a, b, p3, p0) != null
	)

func _segment_intersects_circle(a: Vector2, b: Vector2, center: Vector2, radius: float) -> bool:
	var closest: Vector2 = Geometry2D.get_closest_point_to_segment(center, a, b)
	return closest.distance_to(center) <= radius

func _draw() -> void:
	for blocker: Rect2 in TERRAIN_BLOCKERS:
		draw_rect(blocker, Color(0.30, 0.25, 0.18, 0.18), true)
		draw_rect(blocker, Color(0.65, 0.56, 0.38, 0.55), false, 2.0)
	for i: int in range(_smoke_centers.size()):
		var center: Vector2 = _smoke_centers[i]
		var radius: float = _smoke_radii[i]
		draw_circle(center, radius, Color(0.72, 0.76, 0.78, 0.24))
		draw_arc(center, radius, 0.0, TAU, 48, Color(0.82, 0.86, 0.88, 0.55), 2.0)
