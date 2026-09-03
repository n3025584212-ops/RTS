class_name FormationAgent2D
extends Node2D

signal task_accepted(task: FormationTask)
signal task_rejected(task: FormationTask, reason: String)
signal task_completed(task: FormationTask)

var state: FormationState = FormationState.new()
var autonomy: FormationAutonomy = FormationAutonomy.new()

var _navigation: NavigationService
var _task: FormationTask = FormationTask.hold()
var _path: PackedVector2Array = PackedVector2Array()
var _path_index: int = 0

func _ready() -> void:
	state.set_position(global_position)

func configure(
	id_value: StringName,
	name_value: String,
	faction_value: StringName,
	position_value: Vector2,
	move_speed_value: float,
	max_hp_value: int,
	ammo_capacity_value: int,
	mobility_value: StringName = &"DEFAULT"
) -> void:
	state.configure(
		id_value,
		name_value,
		faction_value,
		position_value,
		move_speed_value,
		max_hp_value,
		ammo_capacity_value,
		mobility_value
	)
	global_position = position_value

func set_navigation_service(service: NavigationService) -> void:
	_navigation = service

func set_formation_task(task: FormationTask) -> bool:
	if task == null:
		return false
	if _navigation == null and task.task_type != FormationTask.HOLD:
		task_rejected.emit(task, "NO_NAVIGATION_SERVICE")
		return false
	var plan: Dictionary = autonomy.plan_task(state, task, _navigation) if task.task_type != FormationTask.HOLD else {
		"accepted": state.is_alive,
		"reason": "HOLD" if state.is_alive else "FORMATION_DESTROYED",
		"path": PackedVector2Array(),
	}
	if not bool(plan.get("accepted", false)):
		task_rejected.emit(task, str(plan.get("reason", "REJECTED")))
		return false

	_task = task.duplicate_task()
	_path = (plan.get("path", PackedVector2Array()) as PackedVector2Array).duplicate()
	_append_exact_walkable_task_target()
	_path_index = 1 if _path.size() > 1 else 0
	state.assign_task(_task.task_type)
	if _task.task_type == FormationTask.HOLD:
		_path = PackedVector2Array()
		_path_index = 0
		state.set_execution_state(FormationState.EXECUTION_HOLDING)
	else:
		state.set_execution_state(FormationState.EXECUTION_MOVING if _path.size() > 1 else autonomy.completion_state(_task))
	task_accepted.emit(_task)
	if _path.size() <= 1 and _task.task_type != FormationTask.HOLD:
		task_completed.emit(_task)
	return true

func _append_exact_walkable_task_target() -> void:
	# AStarGrid2D returns cell-center waypoints. When the requested task target is
	# itself in a walkable cell, keep the grid path for routing but finish the last
	# short segment at the requested world position. This keeps FormationTask's
	# target contract and FormationState's completed position consistent without
	# leaking grid-cell offsets into scenario arrival logic.
	if _task.task_type == FormationTask.HOLD or _navigation == null or _path.is_empty():
		return
	if not _navigation.is_world_walkable(_task.target_position, state.mobility_profile):
		return
	var last_index: int = _path.size() - 1
	if _path[last_index].distance_to(_task.target_position) <= FormationAutonomy.ARRIVAL_TOLERANCE:
		_path[last_index] = _task.target_position
	else:
		_path.append(_task.target_position)

func clear_task() -> void:
	set_formation_task(FormationTask.hold())

func get_current_task() -> FormationTask:
	return _task.duplicate_task()

func get_navigation_path() -> PackedVector2Array:
	return _path.duplicate()

func has_active_navigation_path() -> bool:
	return _path.size() > 1 and _path_index < _path.size()

func _process(delta: float) -> void:
	force_tick_for_test(delta)

func force_tick_for_test(delta: float) -> void:
	if not state.is_alive or delta <= 0.0 or not has_active_navigation_path():
		return
	while _path_index < _path.size():
		var waypoint: Vector2 = _path[_path_index]
		var offset: Vector2 = waypoint - state.position
		if offset.length() <= FormationAutonomy.ARRIVAL_TOLERANCE:
			_set_sim_position(waypoint)
			_path_index += 1
			continue
		var step: float = minf(state.move_speed * delta, offset.length())
		_set_sim_position(state.position + offset.normalized() * step)
		return
	_finish_path()

func _finish_path() -> void:
	if not _path.is_empty():
		_set_sim_position(_path[_path.size() - 1])
	_path_index = _path.size()
	state.set_execution_state(autonomy.completion_state(_task))
	task_completed.emit(_task)

func _set_sim_position(value: Vector2) -> void:
	state.set_position(value)
	global_position = value
