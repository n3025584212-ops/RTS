class_name BattleObjective
extends Node2D

signal state_changed(state: String, progress: float)
signal captured
signal ownership_changed(owner_value: String, previous_owner: String)
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

var control_owner: String = OWNER_NEUTRAL
var state: String = "NEUTRAL"
var progress: float = 0.0
var contested: bool = false
var capturing_faction: String = ""

var _tracked_formations: Array[BattleFormation] = []
var _capture_blocked: bool = false

func _ready() -> void:
	control_owner = initial_owner
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

func get_control_owner() -> String:
	return control_owner

func is_contested() -> bool:
	return contested

func force_owner_for_test(new_owner: String) -> void:
	if new_owner != OWNER_NEUTRAL and new_owner != OWNER_PLAYER and new_owner != OWNER_AI:
		push_error("Invalid objective owner: %s" % new_owner)
		return
	var previous_owner: String = control_owner
	control_owner = new_owner
	contested = false
	capturing_faction = ""
	progress = 0.0
	_refresh_state()
	if previous_owner != control_owner:
		ownership_changed.emit(control_owner, previous_owner)
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

	if _capture_blocked or active_faction.is_empty() or active_owner == control_owner:
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
	var previous_owner: String = control_owner
	control_owner = new_owner
	capturing_faction = ""
	progress = 0.0
	contested = false
	_refresh_state()
	ownership_changed.emit(control_owner, previous_owner)
	capture_completed.emit(control_owner, previous_owner)
	if emit_legacy_captured_signal:
		captured.emit()
	print("FRONTLINE_OBJECTIVE_CAPTURED objective=%s owner=%s previous=%s" % [objective_id, control_owner, previous_owner])
	queue_redraw()

func _has_capture_presence(faction: String) -> bool:
	for formation: BattleFormation in _tracked_formations:
		if formation == null or not is_instance_valid(formation):
			continue
		if not formation.is_alive or formation.faction != faction:
			continue
		# Dormant reinforcement nodes exist in the formal roster but are not battlefield
		# capture/contest presence until the existing Enemy AI activates them.
		if formation.process_mode == Node.PROCESS_MODE_DISABLED or not formation.visible:
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
	elif control_owner == OWNER_PLAYER:
		# Keep CAPTURED as the stable PLAYER-owned state so the already-frozen RED AI
		# objective-loss interface continues to receive the same semantic signal.
		next_state = "CAPTURED"
	elif control_owner == OWNER_AI:
		next_state = "AI_CONTROLLED"
	else:
		next_state = "NEUTRAL"

	var changed: bool = next_state != state
	state = next_state
	if emit_signal and (changed or state == "CAPTURING"):
		state_changed.emit(state, progress)
	queue_redraw()

func _draw() -> void:
	var fill: Color = Color(0.69, 0.69, 0.69, 0.055)
	var edge: Color = Color(0.69, 0.69, 0.69, 0.48)
	if control_owner == OWNER_PLAYER:
		fill = Color(0.30, 0.55, 1.0, 0.075)
		edge = Color("4d8cff")
	elif control_owner == OWNER_AI:
		fill = Color(1.0, 0.30, 0.30, 0.065)
		edge = Color("ff4d4d")

	if contested:
		fill = Color(1.0, 0.78, 0.34, 0.13)
		edge = Color("ffc857")

	# Stable capture footprints remain subdued; capture/contest makes the full area legible.
	draw_circle(Vector2.ZERO, capture_radius, fill)
	var boundary_alpha: float = 0.92 if contested or progress > 0.0 else 0.36
	for index: int in range(24):
		if not contested and index % 2 == 1:
			continue
		var a0: float = TAU * float(index) / 24.0
		var a1: float = a0 + TAU / 36.0
		draw_arc(Vector2.ZERO, capture_radius, a0, a1, 5, Color(edge, boundary_alpha), 2.5 if contested else 1.6)
	if not capturing_faction.is_empty() and progress > 0.0:
		var capture_color: Color = Color("4d8cff") if capturing_faction == "BLUE" else Color("ff4d4d")
		draw_arc(Vector2.ZERO, 45.0, -PI / 2.0, -PI / 2.0 + TAU * progress, 48, capture_color, 7.0)
	if contested:
		for offset: float in [-24.0, -8.0, 8.0, 24.0]:
			draw_line(Vector2(offset - 12.0, -34.0), Vector2(offset + 18.0, 34.0), Color(1.0, 0.78, 0.34, 0.36), 2.0)

	# Central is the tactical hinge; Industrial is the stronger decisive square.
	var decisive: bool = objective_id == "INDUSTRIAL_OBJECTIVE"
	if decisive:
		draw_rect(Rect2(-27.0, -27.0, 54.0, 54.0), Color(edge, 0.17), true)
		draw_rect(Rect2(-27.0, -27.0, 54.0, 54.0), edge, false, 3.0)
		draw_line(Vector2(-13.0, 10.0), Vector2(-13.0, -9.0), Color.WHITE, 3.0)
		draw_line(Vector2(-13.0, -9.0), Vector2(0.0, -2.0), Color.WHITE, 3.0)
		draw_line(Vector2(0.0, -2.0), Vector2(13.0, -10.0), Color.WHITE, 3.0)
		draw_line(Vector2(13.0, -10.0), Vector2(13.0, 10.0), Color.WHITE, 3.0)
	else:
		draw_circle(Vector2.ZERO, 25.0, Color(edge, 0.14))
		draw_arc(Vector2.ZERO, 25.0, 0.0, TAU, 32, edge, 3.0)
		draw_line(Vector2(-14.0, -6.0), Vector2(14.0, -6.0), Color.WHITE, 3.0)
		draw_line(Vector2(-14.0, 6.0), Vector2(14.0, 6.0), Color.WHITE, 3.0)
		draw_line(Vector2(-9.0, -10.0), Vector2(-9.0, 10.0), Color.WHITE, 2.0)
		draw_line(Vector2(9.0, -10.0), Vector2(9.0, 10.0), Color.WHITE, 2.0)

	if player_capture_locked:
		draw_rect(Rect2(12.0, -36.0, 24.0, 22.0), Color(0.16, 0.19, 0.21, 0.95), true)
		draw_arc(Vector2(24.0, -36.0), 8.0, PI, TAU, 12, Color(0.72, 0.76, 0.78), 2.0)
		draw_string(ThemeDB.fallback_font, Vector2(-58.0, 64.0), "LOCKED", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 13, Color(0.68, 0.72, 0.74))

	var title: String = "INDUSTRIAL OBJECTIVE" if decisive else "CENTRAL BRIDGEHEAD"
	var role: String = "FINAL / DECISIVE" if decisive else "INTERMEDIATE / TACTICAL HINGE"
	var state_text: String = "CONTESTED" if contested else "%s CONTROL" % control_owner
	draw_string(ThemeDB.fallback_font, Vector2(-92.0, -64.0), title, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 15, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(-92.0, -47.0), "%s  ·  %s" % [role, state_text], HORIZONTAL_ALIGNMENT_LEFT, -1.0, 11, edge.lightened(0.18))
	if progress > 0.0:
		draw_string(ThemeDB.fallback_font, Vector2(-30.0, 6.0), "%d%%" % int(round(progress * 100.0)), HORIZONTAL_ALIGNMENT_LEFT, -1.0, 16, Color.WHITE)
