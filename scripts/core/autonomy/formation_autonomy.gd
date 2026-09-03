class_name FormationAutonomy
extends RefCounted

const ARRIVAL_TOLERANCE: float = 4.0

func plan_task(
	state: FormationState,
	task: FormationTask,
	navigation: NavigationService
) -> Dictionary:
	if state == null or task == null or navigation == null:
		return {"accepted": false, "reason": "MISSING_DEPENDENCY", "path": PackedVector2Array()}
	if not state.is_alive:
		return {"accepted": false, "reason": "FORMATION_DESTROYED", "path": PackedVector2Array()}
	if not task.is_valid():
		return {"accepted": false, "reason": "INVALID_TASK", "path": PackedVector2Array()}
	if task.task_type == FormationTask.HOLD:
		return {"accepted": true, "reason": "HOLD", "path": PackedVector2Array()}
	if not navigation.has_profile(state.mobility_profile):
		return {"accepted": false, "reason": "UNKNOWN_MOBILITY_PROFILE", "path": PackedVector2Array()}

	var clamped_target: Vector2 = navigation.clamp_to_walkable(task.target_position, state.mobility_profile)
	if state.position.distance_to(clamped_target) <= ARRIVAL_TOLERANCE:
		return {
			"accepted": true,
			"reason": "ALREADY_AT_TARGET",
			"path": PackedVector2Array([state.position]),
			"target": clamped_target,
		}
	var path: PackedVector2Array = navigation.find_path(state.position, clamped_target, state.mobility_profile)
	if path.is_empty():
		return {"accepted": false, "reason": "NO_PATH", "path": PackedVector2Array()}
	return {"accepted": true, "reason": "PATH_READY", "path": path, "target": clamped_target}

func completion_state(task: FormationTask) -> StringName:
	if task == null:
		return FormationState.EXECUTION_IDLE
	return FormationState.EXECUTION_EXECUTING if task.persistent else FormationState.EXECUTION_COMPLETE
