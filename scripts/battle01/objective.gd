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

static var _title_style: StyleBoxFlat

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
	var player_capture_present: bool = _has_capture_presence("BLUE") and not player_capture_locked
	var ai_capture_present: bool = _has_capture_presence("RED")
	var player_contest_present: bool = _has_contest_presence("BLUE") and not player_capture_locked
	var ai_contest_present: bool = _has_contest_presence("RED")

	var next_contested: bool = player_contest_present and ai_contest_present
	if next_contested:
		_set_contested(true)
		_reset_capture_progress()
		_refresh_state()
		return

	_set_contested(false)

	var active_faction: String = ""
	var active_owner: String = OWNER_NEUTRAL
	if player_capture_present:
		active_faction = "BLUE"
		active_owner = OWNER_PLAYER
	elif ai_capture_present:
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
		if not _formation_is_active_in_radius(formation, faction):
			continue
		if formation.is_capture_capable():
			return true
	return false

func _has_contest_presence(faction: String) -> bool:
	for formation: BattleFormation in _tracked_formations:
		if not _formation_is_active_in_radius(formation, faction):
			continue
		if formation.is_contest_capable():
			return true
	return false

func _formation_is_active_in_radius(formation: BattleFormation, faction: String) -> bool:
	if formation == null or not is_instance_valid(formation):
		return false
	if not formation.is_alive or formation.faction != faction:
		return false
	if formation.process_mode == Node.PROCESS_MODE_DISABLED or not formation.visible:
		return false
	return global_position.distance_to(formation.global_position) <= capture_radius

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

# =====================================================================
# Transitional objective presentation. Gameplay state above remains authoritative
# while Battle01 is presented through the integrated 3D runtime.
# =====================================================================

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
		draw_arc(Vector2.ZERO, 45.0, -PI / 2.0, -PI / 2.0 + TAU * progress, 48, Color(capture_color, 0.28), 11.0)
	if contested:
		for offset: float in [-24.0, -8.0, 8.0, 24.0]:
			draw_line(Vector2(offset - 12.0, -34.0), Vector2(offset + 18.0, 34.0), Color(1.0, 0.78, 0.34, 0.36), 2.0)

	var decisive: bool = objective_id == "INDUSTRIAL_OBJECTIVE"
	var glyph_size: float = 60.0 if decisive else 50.0
	var texture: Texture2D = Battle01UIStyle.icon(Battle01UIStyle.ICON_OBJECTIVE_INDUSTRIAL if decisive else Battle01UIStyle.ICON_OBJECTIVE_BRIDGE)
	if texture != null:
		draw_texture_rect(texture, Rect2(-glyph_size * 0.5, -glyph_size * 0.5, glyph_size, glyph_size), false, Color(edge, 1.0))
	else:
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
		var lock_texture: Texture2D = Battle01UIStyle.icon(Battle01UIStyle.ICON_LOCKED)
		if lock_texture != null:
			draw_texture_rect(lock_texture, Rect2(Vector2(18.0, -40.0), Vector2(26.0, 26.0)), false, Color(0.85, 0.88, 0.90, 1.0))
		else:
			draw_rect(Rect2(12.0, -36.0, 24.0, 22.0), Color(0.16, 0.19, 0.21, 0.95), true)
			draw_arc(Vector2(24.0, -36.0), 8.0, PI, TAU, 12, Color(0.72, 0.76, 0.78), 2.0)
		_draw_state_chip(Vector2(52.0, -30.0), "LOCKED", Color(0.68, 0.72, 0.74))

	var title: String = "INDUSTRIAL OBJECTIVE" if decisive else "CENTRAL BRIDGEHEAD"
	var role: String = "FINAL / DECISIVE" if decisive else "INTERMEDIATE / TACTICAL HINGE"
	var state_text: String = "CONTESTED" if contested else "%s CONTROL" % control_owner
	_draw_title_chip(title, "%s  ·  %s" % [role, state_text], edge)
	if progress > 0.0:
		_draw_progress_text(edge)

func _draw_title_chip(title: String, subtitle: String, edge: Color) -> void:
	if _title_style == null:
		_title_style = StyleBoxFlat.new()
		_title_style.bg_color = Color(0.025, 0.050, 0.065, 0.90)
		_title_style.border_color = Color(0.32, 0.50, 0.58, 0.80)
		_title_style.set_border_width_all(1)
		_title_style.set_corner_radius_all(5)
	var font := ThemeDB.fallback_font
	var title_size := 15
	var subtitle_size := 11
	var title_width: float = font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1.0, title_size).x
	var subtitle_width: float = font.get_string_size(subtitle, HORIZONTAL_ALIGNMENT_LEFT, -1.0, subtitle_size).x
	var panel_width: float = maxf(title_width, subtitle_width) + 18.0
	var rect := Rect2(Vector2(-panel_width * 0.5, -88.0), Vector2(panel_width, 40.0))
	draw_style_box(_title_style, rect)
	var title_color := Color.WHITE
	var subtitle_color := edge.lightened(0.18)
	draw_string(font, Vector2(-panel_width * 0.5 + 9.0, -62.0), title, HORIZONTAL_ALIGNMENT_LEFT, -1.0, title_size, title_color)
	draw_string(font, Vector2(-panel_width * 0.5 + 9.0, -47.0), subtitle, HORIZONTAL_ALIGNMENT_LEFT, -1.0, subtitle_size, subtitle_color)

func _draw_state_chip(position: Vector2, value: String, color: Color) -> void:
	var font := ThemeDB.fallback_font
	var font_size := 11
	var text_width: float = font.get_string_size(value, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).x
	var rect := Rect2(position, Vector2(text_width + 14.0, 20.0))
	draw_rect(rect, Color(0.02, 0.05, 0.06, 0.90), true)
	draw_rect(rect, Color(color, 0.7), false, 1.0)
	draw_string(font, rect.position + Vector2(7.0, 15.0), value, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size, color)

func _draw_progress_text(edge: Color) -> void:
	var font := ThemeDB.fallback_font
	var value: String = "%d%%" % int(round(progress * 100.0))
	var font_size := 16
	var text_width: float = font.get_string_size(value, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).x
	var color: Color = Color("4d8cff") if capturing_faction == "BLUE" else Color("ff4d4d")
	draw_rect(Rect2(Vector2(-text_width * 0.5 - 6.0, -10.0), Vector2(text_width + 12.0, 24.0)), Color(0.02, 0.05, 0.06, 0.88), true)
	draw_rect(Rect2(Vector2(-text_width * 0.5 - 6.0, -10.0), Vector2(text_width + 12.0, 24.0)), Color(color, 0.75), false, 1.5)
	draw_string(font, Vector2(-text_width * 0.5, 8.0), value, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size, color)
