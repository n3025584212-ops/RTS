class_name BattleObjective
extends Node2D

signal state_changed(state: String, progress: float)
signal captured

@export var capture_radius: float = 150.0
@export var capture_time: float = 3.0

var state: String = "NEUTRAL"
var progress: float = 0.0
var _tracked_formation: BattleFormation
var _capture_blocked: bool = false

func _ready() -> void:
	queue_redraw()
	state_changed.emit(state, progress)

func set_tracked_formation(formation: BattleFormation) -> void:
	_tracked_formation = formation

func set_capture_blocked(blocked: bool) -> void:
	_capture_blocked = blocked
	if not blocked and state == "CONTESTED":
		state = "NEUTRAL"
		progress = 0.0
		state_changed.emit(state, progress)
	queue_redraw()

func _process(delta: float) -> void:
	if state == "CAPTURED" or _tracked_formation == null or not _tracked_formation.is_alive:
		return

	var inside: bool = global_position.distance_to(_tracked_formation.global_position) <= capture_radius
	if inside and _capture_blocked:
		if state != "CONTESTED" or progress != 0.0:
			state = "CONTESTED"
			progress = 0.0
			state_changed.emit(state, progress)
			queue_redraw()
		return

	if inside:
		state = "CAPTURING"
		progress = minf(1.0, progress + delta / capture_time)
		state_changed.emit(state, progress)
		queue_redraw()
		if progress >= 1.0:
			state = "CAPTURED"
			state_changed.emit(state, progress)
			captured.emit()
	else:
		if progress > 0.0 or state != "NEUTRAL":
			progress = 0.0
			state = "NEUTRAL"
			state_changed.emit(state, progress)
			queue_redraw()

func _draw() -> void:
	var fill: Color = Color(0.85, 0.67, 0.18, 0.14)
	var edge: Color = Color(0.95, 0.80, 0.28, 0.9)
	if state == "CONTESTED":
		fill = Color(0.8, 0.18, 0.12, 0.18)
		edge = Color(1.0, 0.3, 0.2, 0.95)
	elif state == "CAPTURING":
		fill = Color(0.12, 0.55, 0.92, 0.18)
		edge = Color(0.35, 0.95, 1.0, 0.95)
	elif state == "CAPTURED":
		fill = Color(0.10, 0.45, 0.82, 0.28)
		edge = Color(0.30, 0.80, 1.0, 1.0)
	draw_circle(Vector2.ZERO, capture_radius, fill)
	draw_arc(Vector2.ZERO, capture_radius, 0.0, TAU, 96, edge, 5.0)
	if state == "CAPTURING":
		draw_arc(Vector2.ZERO, capture_radius - 12.0, -PI / 2.0, -PI / 2.0 + TAU * progress, 64, Color.WHITE, 7.0)
