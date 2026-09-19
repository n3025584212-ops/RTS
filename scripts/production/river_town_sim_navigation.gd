class_name RiverTownSimNavigation
extends BattleNavigation

## Gate B (MINIMUM_ARMORED_UNIT_INTEGRATION).
## Sim-space navigation for the River Town product scene. Reuses the validated
## core NavigationService (same class exercised by core_v1_batch1_smoke) with
## River Town parameters. The greybox route/terrain tables of Battle01 are
## intentionally NOT used here; the minimum gate runs an open vehicle grid.

const RT_SIM_MAP_SIZE := Vector2(500.0, 500.0)
const RT_SIM_CELL_SIZE := Vector2(2.5, 2.5)
const RT_NEAREST_SEARCH_RADIUS := 8

func _ready() -> void:
	# Overrides the greybox configuration; base _ready is intentionally not called.
	var profiles: Array[StringName] = [&"VEHICLE"]
	_service.configure(
		RT_SIM_MAP_SIZE,
		RT_SIM_CELL_SIZE,
		profiles,
		Callable(self, "_is_blocked_for_profile"),
		RT_NEAREST_SEARCH_RADIUS
	)
	print("FRONTLINE_GATE_B_NAV_READY cells=%d vehicle_blocked=%d source=core_navigation_service" % [
		int(RT_SIM_MAP_SIZE.x / RT_SIM_CELL_SIZE.x) * int(RT_SIM_MAP_SIZE.y / RT_SIM_CELL_SIZE.y),
		_service.get_blocked_count(&"VEHICLE"),
	])

func _is_blocked_for_profile(_world_point: Vector2, _profile: StringName) -> bool:
	# Minimum gate: open vehicle grid. Terrain-obstacle binding is future work
	# beyond this gate and must not regress the River Town visual pipeline.
	return false

func _draw() -> void:
	# Greybox debug overlay intentionally suppressed in the product scene.
	pass
