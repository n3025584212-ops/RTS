class_name BattleIntelTracker
extends Node2D

signal intel_state_changed(state: String, last_known_position: Vector2)

const UNSEEN: String = "UNSEEN"
const CONTACT: String = "CONTACT"
const CONFIRMED: String = "CONFIRMED"
const LAST_KNOWN: String = "LAST_KNOWN"

@export var confirmation_time: float = 0.75
@export var firing_reveal_duration: float = 2.0

var state: String = UNSEEN
var last_known_position: Vector2 = Vector2.ZERO

var _observers: Array[BattleFormation] = []
var _target: BattleFormation
var _confirmation_progress: float = 0.0
var _forced_reveal_remaining: float = 0.0

func configure(observers: Array[BattleFormation], target: BattleFormation) -> void:
	_observers = observers
	_target = target
	if _target != null:
		_target.set_intel_state(UNSEEN)
	queue_redraw()

func note_target_fired() -> void:
	if _target == null or not _target.is_alive:
		return
	_forced_reveal_remaining = firing_reveal_duration
	last_known_position = _target.global_position
	_set_state(CONFIRMED)

func _process(delta: float) -> void:
	if _target == null or not is_instance_valid(_target) or not _target.is_alive:
		return

	_forced_reveal_remaining = maxf(0.0, _forced_reveal_remaining - delta)
	var detected: bool = _forced_reveal_remaining > 0.0 or _is_detected_by_any_observer()

	if detected:
		last_known_position = _target.global_position
		if _forced_reveal_remaining > 0.0:
			_confirmation_progress = confirmation_time
			_set_state(CONFIRMED)
		elif state == UNSEEN or state == LAST_KNOWN:
			_confirmation_progress = 0.0
			_set_state(CONTACT)
		elif state == CONTACT:
			_confirmation_progress += delta
			if _confirmation_progress >= confirmation_time:
				_set_state(CONFIRMED)
	elif state == CONTACT or state == CONFIRMED:
		last_known_position = _target.global_position
		_confirmation_progress = 0.0
		_set_state(LAST_KNOWN)

func _is_detected_by_any_observer() -> bool:
	for observer: BattleFormation in _observers:
		if observer == null or not is_instance_valid(observer) or not observer.is_alive:
			continue
		if observer.global_position.distance_to(_target.global_position) <= observer.detection_range:
			return true
	return false

func _set_state(next_state: String) -> void:
	if state == next_state:
		return
	state = next_state
	if _target != null and is_instance_valid(_target):
		_target.set_intel_state(state)
	intel_state_changed.emit(state, last_known_position)
	queue_redraw()

func _draw() -> void:
	if state != LAST_KNOWN:
		return
	var marker: Vector2 = to_local(last_known_position)
	draw_circle(marker, 20.0, Color(0.95, 0.75, 0.20, 0.18))
	draw_arc(marker, 22.0, 0.0, TAU, 32, Color(0.95, 0.75, 0.20, 0.85), 3.0)
	draw_line(marker + Vector2(-12.0, -12.0), marker + Vector2(12.0, 12.0), Color(0.95, 0.75, 0.20, 0.75), 2.0)
	draw_line(marker + Vector2(12.0, -12.0), marker + Vector2(-12.0, 12.0), Color(0.95, 0.75, 0.20, 0.75), 2.0)
