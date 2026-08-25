class_name BattleRouteTerrain
extends RefCounted

const MOBILITY_FOOT: String = "FOOT"
const MOBILITY_VEHICLE: String = "VEHICLE"

const MAP_SIZE := Vector2(3200.0, 1800.0)
const RIVER_RECT := Rect2(Vector2(1480.0, 0.0), Vector2(240.0, 1800.0))
const BRIDGE_RECT := Rect2(Vector2(1440.0, 780.0), Vector2(320.0, 240.0))

const VILLAGE_BLOCKERS: Array[Rect2] = [
	Rect2(Vector2(1120.0, 240.0), Vector2(220.0, 160.0)),
	Rect2(Vector2(1360.0, 260.0), Vector2(120.0, 180.0)),
	Rect2(Vector2(1120.0, 470.0), Vector2(260.0, 140.0)),
	Rect2(Vector2(1760.0, 260.0), Vector2(140.0, 160.0)),
	Rect2(Vector2(1760.0, 460.0), Vector2(160.0, 140.0)),
]
const CENTRAL_BLOCKERS: Array[Rect2] = [
	Rect2(Vector2(1120.0, 820.0), Vector2(160.0, 160.0)),
]
const SOUTH_BLOCKERS: Array[Rect2] = [
	Rect2(Vector2(960.0, 1120.0), Vector2(320.0, 160.0)),
	Rect2(Vector2(1900.0, 1120.0), Vector2(320.0, 160.0)),
]
const INDUSTRIAL_BLOCKERS: Array[Rect2] = [
	Rect2(Vector2(2480.0, 560.0), Vector2(200.0, 200.0)),
	Rect2(Vector2(2760.0, 560.0), Vector2(200.0, 200.0)),
	Rect2(Vector2(2480.0, 900.0), Vector2(200.0, 160.0)),
	Rect2(Vector2(2760.0, 980.0), Vector2(180.0, 240.0)),
]

const NORTH_FOOT_LINK_ENTRY := Vector2(1060.0, 460.0)
const NORTH_FOOT_LINK_EXIT := Vector2(1460.0, 460.0)
const NORTH_FOOT_LINK_RECT := Rect2(Vector2(1100.0, 440.0), Vector2(320.0, 40.0))

const CENTRAL_EXPOSURE_A := Vector2(1320.0, 900.0)
const CENTRAL_EXPOSURE_B := Vector2(1880.0, 900.0)
const SOUTH_LONG_LOS_A := Vector2(900.0, 1380.0)
const SOUTH_LONG_LOS_B := Vector2(2200.0, 1380.0)
const SOUTH_REAR_STAGING := Vector2(2200.0, 1380.0)
const SOUTH_REAR_PRESSURE_TARGET := Vector2(2440.0, 1320.0)

static func get_hard_blockers() -> Array[Rect2]:
	var result: Array[Rect2] = []
	result.append_array(VILLAGE_BLOCKERS)
	result.append_array(CENTRAL_BLOCKERS)
	result.append_array(SOUTH_BLOCKERS)
	result.append_array(INDUSTRIAL_BLOCKERS)
	return result

static func is_hard_blocked(world_point: Vector2) -> bool:
	for blocker: Rect2 in get_hard_blockers():
		if blocker.has_point(world_point):
			return true
	return false

static func is_vehicle_clearance_blocked(world_point: Vector2) -> bool:
	return NORTH_FOOT_LINK_RECT.has_point(world_point)

static func mobility_for_role(role: String) -> String:
	if role == "RECON" or role == "INFANTRY":
		return MOBILITY_FOOT
	return MOBILITY_VEHICLE

static func path_uses_rect(path: PackedVector2Array, rect: Rect2) -> bool:
	for point: Vector2 in path:
		if rect.has_point(point):
			return true
	return false
