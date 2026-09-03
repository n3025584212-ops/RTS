class_name TaskCommandService
extends Node

const OP_ASSIGN: StringName = &"ASSIGN"
const OP_RETASK: StringName = &"RETASK"
const OP_CANCEL: StringName = &"CANCEL"

signal command_issued(operation: StringName, formations: Array, task: FormationTask, accepted_count: int)
signal task_issued(formations: Array, task: FormationTask, accepted_count: int)
signal task_rejected(formation: Node, task: FormationTask)

var _last_tasks: Dictionary = {}
var _command_revision: int = 0
var _last_operation: StringName = &""

func assign(formations: Array, task: FormationTask) -> int:
	return _issue_command(OP_ASSIGN, formations, task)

func assign_task(formations: Array, task: FormationTask) -> int:
	# Compatibility alias retained for the first migration batch. Commander-facing
	# code should use assign/retask/cancel so command intent stays explicit.
	return assign(formations, task)

func retask(formations: Array, replacement_task: FormationTask) -> int:
	return _issue_command(OP_RETASK, formations, replacement_task)

func cancel(formations: Array, priority: int = 0) -> int:
	# Cancelling a task returns the formation to an explicit HOLD task through the
	# same Core command service; no HUD or scenario authority participates.
	return _issue_command(OP_CANCEL, formations, FormationTask.hold(priority))

func hold(formations: Array, priority: int = 0) -> int:
	return assign(formations, FormationTask.hold(priority))

func move(formations: Array, target: Vector2, priority: int = 0) -> int:
	return assign(formations, FormationTask.move_to(target, priority))

func assign_area(formations: Array, target: Vector2, target_id: StringName = &"", priority: int = 0) -> int:
	return assign(formations, FormationTask.assign_to(target, target_id, priority))

func _issue_command(operation: StringName, formations: Array, task: FormationTask) -> int:
	if task == null or not task.is_valid():
		return 0
	var accepted_count: int = 0
	for value: Variant in formations:
		var formation: Node = value as Node
		if formation == null or not is_instance_valid(formation) or not formation.has_method("set_formation_task"):
			continue
		var task_copy: FormationTask = task.duplicate_task()
		var accepted: bool = bool(formation.call("set_formation_task", task_copy))
		if accepted:
			accepted_count += 1
			_last_tasks[formation.get_instance_id()] = task_copy
		else:
			task_rejected.emit(formation, task_copy)
	_command_revision += 1
	_last_operation = operation
	command_issued.emit(operation, formations, task, accepted_count)
	# Preserve the original task-level signal for migration compatibility.
	task_issued.emit(formations, task, accepted_count)
	return accepted_count

func get_last_task(formation: Node) -> FormationTask:
	if formation == null:
		return null
	var task: FormationTask = _last_tasks.get(formation.get_instance_id()) as FormationTask
	return task.duplicate_task() if task != null else null

func get_command_revision() -> int:
	return _command_revision

func get_last_operation() -> StringName:
	return _last_operation
