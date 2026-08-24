class_name BattleObjective
extends Node2D

signal state_changed(state: String, progress: float)
signal captured
signal ownership_changed(owner: String, previous_owner: String)
signal contest_changed(contested: bool)
signal capture_completed(new_owner: String, previous_owner: String)
signal unlock_changed(player_capture_locked: bool)

const OWNER_NEUTRAL: String = "NEUTRAL"
const OWNER_PLAYER: String = "PLAYER"
const OWNER_AI: String = "AI"

@export var objective_id: String = "OBJECTIVE"
@export var capture_radius: float = 150.0
@export var capture_time: float = 15.0
@export_enum("NEUTRAL", "PLAYER", "AI") var initial_owner: String = OWNER_AI
@export var player_capture_locked: bool = false
@export var emit_legacy_captured_signal: bool = false

var owner: String = OWNER_NEUTRAL
var state: String = "NEUTRAL"
var progress: float = 0.0
var contested: bool = false
var capturing_faction: String = ""

var _tracked_formations: Array[BattleFormation] = []
var _capture_blocked: bool = false

func _ready() -> void:
	owner = initial_owner
	_refresh_state(false)
	queue_redraw()
	state_changed.emit(state, progress)

func set_tracked_formation(formation: BattleFormation) -> void:
	_tracked_formations.clear()
	add_tracked_formation(formation)

func set_tracked_formations(formations: Array[BattleFormation]) -> void:
	_tracked_formations.clear()
	for formation: BattleFormation in formations:
		add_tracked_formation(formation)

func add_tracked_formation(formation: BattleFormation) -> void:
	if formation == null or not is_instance_valid(formation):
		return
	if formation not in _tracked_formations:
		_tracked_formations.append(formation)

func set_capture_blocked(blocked: bool) -> void:
	# Compatibility hook for older Battle01 callers/tests. Formal objectives normally
	# leave this false and derive contest/capture pressure from actual formations.
	_capture_blocked = blocked
	if blocked:
		_reset_capture_progress()
	_refresh_state()

func unlock_player_capture() -> void:
	if not player_capture_locked:
		return
	player_capture_locked = false
	unlock_changed.emit(false)
	_refresh_state()
	queue_redraw()

func is_player_capture_locked() -> bool:
	return player_capture_locked

func get_owner() -> String:
	return owner

func is_contested() -> bool:
	return contested

func force_owner_for_test(new_owner: String) -> void:
	if new_owner != OWNER_NEUTRAL and new_owner != OWNER_PLAYER and new_owner != OWNER_AI:
		push_error("Invalid objective owner: %s" % new_owner)
		return
	var previous_owner: String = owner
	owner = new_owner
	contested = false
	capturing_faction = ""
	progress = 0.0
	_refresh_state()
	if previous_owner != owner:
		ownership_changed.emit(owner, previous_owner)
	queue_redraw()

func _process(delta: float) -> void:
	_prune_tracked_formations()
	var player_present: bool = _has_capture_presence("BLUE") and not player_capture_locked
	var ai_present: bool = _has_capture_presence("RED")

	var next_contested: bool = player_present and ai_present
	if next_contested:
		_set_contested(true)
		_reset_capture_progress()
		_refresh_state()
		return

	_set_contested(false)

	var active_faction: String = ""
	var active_owner: String = OWNER_NEUTRAL
	if player_present:
		active_faction = "BLUE"
		active_owner = OWNER_PLAYER
	elif ai_present:
		active_faction = "RED"
		active_owner = OWNER_AI

	if _capture_blocked or active_faction.is_empty() or active_owner == owner:
		_reset_capture_progress()
		_refresh_state()
		return

	if capturing_faction != active_faction:
		capturing_faction = active_faction
		progress = 0.0

	progress = minf(1.0, progress + delta / maxf(0.001, capture_time))
	_refresh_state()
	queue_redraw()
	if progress >= 1.0:
		_complete_capture(active_owner)

func _complete_capture(new_owner: String) -> void:
	var previous_owner: String = owner
	owner = new_owner
	capturing_faction = ""
	progress = 0.0
	contested = false
	_refresh_state()
	ownership_changed.emit(owner, previous_owner)
	capture_completed.emit(owner, previous_owner)
	if emit_legacy_captured_signal:
		captured.emit()
	print("FRONTLINE_OBJECTIVE_CAPTURED objective=%s owner=%s previous=%s" % [objective_id, owner, previous_owner])
	queue_redraw()

func _has_capture_presence(faction: String) -> bool:
	for formation: BattleFormation in _tracked_formations:
		if formation == null or not is_instance_valid(formation):
			continue
		if not formation.is_alive or formation.faction != faction:
			continue
		if not formation.is_capture_capable():
			continue
		if global_position.distance_to(formation.global_position) <= capture_radius:
			return true
	return false

func _prune_tracked_formations() -> void:
	for index: int in range(_tracked_formations.size() - 1, -1, -1):
		var formation: BattleFormation = _tracked_formations[index]
		if formation == null or not is_instance_valid(formation):
			_tracked_formations.remove_at(index)

func _set_contested(value: bool) -> void:
	if contested == value:
		return
	contested = value
	contest_changed.emit(contested)

func _reset_capture_progress() -> void:
	if progress == 0.0 and capturing_faction.is_empty():
		return
	progress = 0.0
	capturing_faction = ""

func _refresh_state(emit_signal: bool = true) -> void:
	var next_state: String
	if contested:
		next_state = "CONTESTED"
	elif not capturing_faction.is_empty() and progress > 0.0:
		next_state = "CAPTURING"
	elif owner == OWNER_PLAYER:
		# Keep CAPTURED as the stable PLAYER-owned state so the already-frozen RED AI
		# objective-loss interface continues to receive the same semantic signal.
		next_state = "CAPTURED"
	elif owner == OWNER_AI:
		next_state = "AI_CONTROLLED"
	else:
		next_state = "NEUTRAL"

	var changed: bool = next_state != state
	state = next_state
	if emit_signal and (changed or state == "CAPTURING"):
		state_changed.emit(state, progress)
	queue_redraw()

func _draw() -> void:
	var fill: Color = Color(0.85, 0.67, 0.18, 0.14)
	var edge: Color = Color(0.95, 0.80, 0.28, 0.90)
	if owner == OWNER_PLAYER:
		fill = Color(0.10, 0.45, 0.82, 0.22)
		edge = Color(0.30, 0.80, 1.0, 1.0)
	elif owner == OWNER_AI:
		fill = Color(0.72, 0.16, 0.12, 0.18)
		edge = Color(0.95, 0.30, 0.22, 0.95)

	if contested:
		fill = Color(0.85, 0.50, 0.10, 0.22)
		edge = Color(1.0, 0.72, 0.20, 1.0)

	draw_circle(Vector2.ZERO, capture_radius, fill)
	draw_arc(Vector2.ZERO, capture_radius, 0.0, TAU, 96, edge, 5.0)
	if not capturing_faction.is_empty() and progress > 0.0:
		draw_arc(Vector2.ZERO, capture_radius - 12.0, -PI / 2.0, -PI / 2.0 + TAU * progress, 64, Color.WHITE, 7.0)

	var lock_text: String = " LOCKED" if player_capture_locked else ""
	var contest_text: String = " CONTESTED" if contested else ""
	var label: String = "%s [%s]%s%s" % [objective_id, owner, lock_text, contest_text]
	draw_string(ThemeDB.fallback_font, Vector2(-120.0, -capture_radius - 18.0), label, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 15, Color.WHITE)
