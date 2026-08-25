class_name Battle3DAdapter
extends RefCounted

const SIM_TO_WORLD_SCALE: float = 0.01
const GROUND_Y: float = 0.0
const MAP_SIM_SIZE: Vector2 = Vector2(3200.0, 1800.0)

static func sim_to_world(sim_position: Vector2, world_y: float = GROUND_Y) -> Vector3:
	return Vector3(sim_position.x * SIM_TO_WORLD_SCALE, world_y, sim_position.y * SIM_TO_WORLD_SCALE)

static func world_to_sim(world_position: Vector3) -> Vector2:
	return Vector2(world_position.x / SIM_TO_WORLD_SCALE, world_position.z / SIM_TO_WORLD_SCALE)

static func sim_length_to_world(sim_length: float) -> float:
	return sim_length * SIM_TO_WORLD_SCALE

static func clamp_sim(sim_position: Vector2) -> Vector2:
	return Vector2(
		clampf(sim_position.x, 0.0, MAP_SIM_SIZE.x),
		clampf(sim_position.y, 0.0, MAP_SIM_SIZE.y)
	)
