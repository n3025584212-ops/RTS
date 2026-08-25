class_name BattleIntelTracker
extends Node2D

signal intel_state_changed(state: String, last_known_position: Vector2)
signal intel_record_changed(target: BattleFormation, state: String, last_known_position: Vector2)

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
var _visibility_field: BattleVisibilityField
var _confirmation_progress: float = 0.0
var _forced_reveal_remaining: float = 0.0
var _targets: Array[BattleFormation] = []
var _records: Dictionary = {}

func configure(observers: Array[BattleFormation], target: BattleFormation, visibility_field: BattleVisibilityField = null) -> void:
	_observers = observers
	_target = target
	_visibility_field = visibility_field
	_targets.clear()
	_records.clear()
	add_targets([target])
	_sync_primary_record()
	queue_redraw()

func add_targets(targets: Array[BattleFormation]) -> void:
	for candidate: BattleFormation in targets:
		if candidate == null or not is_instance_valid(candidate) or candidate in _targets:
			continue
		_targets.append(candidate)
		_records[candidate] = {
			"state": UNSEEN,
			"last_known": Vector2.ZERO,
			"confirmation": 0.0,
			"forced_reveal": 0.0,
		}
		candidate.set_intel_state(UNSEEN)
		if not candidate.attack_fired.is_connected(_on_tracked_target_fired):
			candidate.attack_fired.connect(_on_tracked_target_fired)
	queue_redraw()

func note_target_fired(target: BattleFormation = null) -> void:
	var revealed: BattleFormation = target if target != null else _target
	if revealed == null or not revealed.is_alive:
		return
	if not _records.has(revealed):
		add_targets([revealed])
	var record: Dictionary = _records[revealed]
	record["forced_reveal"] = firing_reveal_duration
	record["last_known"] = revealed.global_position
	record["confirmation"] = confirmation_time
	_records[revealed] = record
	_set_target_state(revealed, CONFIRMED)

func _process(delta: float) -> void:
	for tracked: BattleFormation in _targets:
		if tracked == null or not is_instance_valid(tracked) or not tracked.is_alive:
			continue
		if not tracked.visible or tracked.process_mode == Node.PROCESS_MODE_DISABLED:
			continue
		var record: Dictionary = _records[tracked]
		record["forced_reveal"] = maxf(0.0, float(record["forced_reveal"]) - delta)
		var detected: bool = float(record["forced_reveal"]) > 0.0 or _is_target_detected(tracked)
		var current_state: String = str(record["state"])
		if detected:
			record["last_known"] = tracked.global_position
			if float(record["forced_reveal"]) > 0.0:
				record["confirmation"] = confirmation_time
				_records[tracked] = record
				_set_target_state(tracked, CONFIRMED)
			elif current_state == UNSEEN or current_state == LAST_KNOWN:
				record["confirmation"] = 0.0
				_records[tracked] = record
				_set_target_state(tracked, CONTACT)
			elif current_state == CONTACT:
				record["confirmation"] = float(record["confirmation"]) + delta
				_records[tracked] = record
				if float(record["confirmation"]) >= confirmation_time:
					_set_target_state(tracked, CONFIRMED)
			else:
				_records[tracked] = record
		elif current_state == CONTACT or current_state == CONFIRMED:
			record["confirmation"] = 0.0
			_records[tracked] = record
			_set_target_state(tracked, LAST_KNOWN)
		else:
			_records[tracked] = record
	_sync_primary_record()

func _is_detected_by_any_observer() -> bool:
	return _target != null and _is_target_detected(_target)

func _is_target_detected(target: BattleFormation) -> bool:
	for observer: BattleFormation in _observers:
		if observer == null or not is_instance_valid(observer) or not observer.is_alive:
			continue
		if observer.global_position.distance_to(target.global_position) > observer.detection_range:
			continue
		if _visibility_field != null and not _visibility_field.has_line_of_sight(observer.global_position, target.global_position):
			continue
		return true
	return false

func _set_state(next_state: String) -> void:
	if _target == null:
		return
	_set_target_state(_target, next_state)

func _set_target_state(target: BattleFormation, next_state: String) -> void:
	if target == null or not _records.has(target):
		return
	var record: Dictionary = _records[target]
	if str(record["state"]) == next_state:
		return
	record["state"] = next_state
	_records[target] = record
	target.set_intel_state(next_state)
	intel_record_changed.emit(target, next_state, Vector2(record["last_known"]))
	if target == _target:
		_sync_primary_record()
		intel_state_changed.emit(state, last_known_position)
	queue_redraw()

func _sync_primary_record() -> void:
	if _target == null or not _records.has(_target):
		return
	var primary: Dictionary = _records[_target]
	state = str(primary["state"])
	last_known_position = Vector2(primary["last_known"])
	_confirmation_progress = float(primary["confirmation"])
	_forced_reveal_remaining = float(primary["forced_reveal"])

func get_last_known_position_for(target: BattleFormation) -> Vector2:
	if target != null and _records.has(target):
		return Vector2((_records[target] as Dictionary)["last_known"])
	return Vector2.ZERO

func get_intel_state_for(target: BattleFormation) -> String:
	if target != null and _records.has(target):
		return str((_records[target] as Dictionary)["state"])
	return UNSEEN

func _on_tracked_target_fired(attacker: BattleFormation, _target_formation: BattleFormation, _damage: int) -> void:
	note_target_fired(attacker)

func _draw() -> void:
	for tracked: BattleFormation in _targets:
		if tracked == null or not is_instance_valid(tracked) or not _records.has(tracked):
			continue
		var record: Dictionary = _records[tracked]
		if str(record["state"]) != LAST_KNOWN:
			continue
		var marker: Vector2 = to_local(Vector2(record["last_known"]))
		draw_circle(marker, 24.0, Color(0.58, 0.48, 0.34, 0.10))
		for index: int in range(12):
			var a0: float = TAU * float(index) / 12.0
			var a1: float = a0 + TAU / 24.0
			draw_arc(marker, 25.0, a0, a1, 3, Color(0.76, 0.62, 0.42, 0.82), 2.2)
		draw_line(marker + Vector2(-8.0, 0.0), marker + Vector2(8.0, 0.0), Color(0.76, 0.62, 0.42, 0.72), 1.5)
		var texture: Texture2D = Battle01UIStyle.icon(Battle01UIStyle.ICON_LAST_KNOWN)
		if texture != null:
			draw_texture_rect(texture, Rect2(marker - Vector2(20.0, 20.0), Vector2(40.0, 40.0)), false, Color(0.80, 0.68, 0.50, 0.95))
		var font := ThemeDB.fallback_font
		var label := "LAST KNOWN"
		var font_size := 11
		var text_width: float = font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).x
		var rect := Rect2(marker + Vector2(-text_width * 0.5 - 7.0, -52.0), Vector2(text_width + 14.0, 19.0))
		draw_rect(rect, Color(0.025, 0.050, 0.065, 0.90), true)
		draw_rect(rect, Color(0.76, 0.62, 0.42, 0.80), false, 1.0)
		draw_string(font, rect.position + Vector2(7.0, 14.0), label, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size, Color(0.80, 0.68, 0.50, 0.95))