class_name Battle01UIStyle
extends RefCounted

## Shared presentation language for the reworked Battle01 visual layer.
## Source of truth: docs/BATTLE01_VISUAL_IMPLEMENTATION_SPEC_V2.md section 3
## and docs/visual_targets/battle01/*.png (reviewed as real binaries).
## This file defines presentation only. It never changes gameplay.

# --- Frozen semantic palette (V2 spec section 3) ---
const PLAYER_BLUE := Color("4d8cff")
const AI_RED := Color("ff4d4d")
const NEUTRAL := Color("b0b0b0")
const CONTESTED := Color("ffc857")
const LOCKED := Color("8f9aa3")
const MOVE_GREEN := Color("6ccb6c")
const HOLD_BLUE := Color("4d8cff")
const WITHDRAW_AMBER := Color("ffc857")
const SUPPLY_CYAN := Color("4dd0e1")
const INVALID := Color("ff5544")
const INFO_BLUE := Color("a3d4ff")
const CRITICAL := Color("ff5544")
const UNKNOWN := Color("d8b06a")
const STALE := Color("c2a878")
const DESTROYED := Color("8a9094")

# --- Panel language (dark tactical, translucent, edged) ---
const PANEL_FILL := Color(0.030, 0.055, 0.075, 0.92)
const PANEL_FILL_SOFT := Color(0.045, 0.080, 0.100, 0.86)
const CHIP_FILL := Color(0.055, 0.100, 0.125, 0.90)
const PANEL_EDGE := Color(0.24, 0.42, 0.52, 0.85)
const PANEL_EDGE_SOFT := Color(0.16, 0.30, 0.38, 0.60)
const PANEL_RADIUS := 8
const CHIP_RADIUS := 5

# --- Typography scale ---
const FS_CAPTION := 9
const FS_SMALL := 11
const FS_BODY := 12
const FS_MEDIUM := 13
const FS_TITLE := 15
const FS_HEADLINE := 19
const FS_MISSION := 21
const FS_BANNER := 42

# --- Text colors ---
const TEXT_MAIN := Color("e8f2f6")
const TEXT_MUTED := Color("93a6b0")
const TEXT_DIM := Color("6d808a")

# --- World marker language ---
const MARKER_RING_NEAR := 22.0
const MARKER_RING_MID := 26.0
const MARKER_RING_FAR := 29.0
const HP_BAR_WIDTH := 62.0
const HP_BAR_HEIGHT := 6.0

# --- Icon asset registry (assets/ui/*.svg, imported by the editor) ---
const ICON_COMMAND_MOVE := "icon_command_move"
const ICON_COMMAND_HOLD := "icon_command_hold"
const ICON_COMMAND_WITHDRAW := "icon_command_withdraw"
const ICON_COMMAND_SUPPLY := "icon_command_supply"
const ICON_COMMAND_ATTACK := "icon_command_attack"
const ICON_COMMAND_STOP := "icon_command_stop"
const ICON_ROLE_RECON := "icon_role_recon"
const ICON_ROLE_INFANTRY := "icon_role_infantry"
const ICON_ROLE_IFV := "icon_role_ifv"
const ICON_ROLE_ARMOR := "icon_role_armor"
const ICON_ROLE_LOGISTICS := "icon_role_logistics"
const ICON_OBJECTIVE_BRIDGE := "icon_objective_bridge"
const ICON_OBJECTIVE_INDUSTRIAL := "icon_objective_industrial"
const ICON_RALLY_WEST := "icon_rally_west"
const ICON_RALLY_FORWARD := "icon_rally_forward"
const ICON_STATUS_LOW_AMMO := "icon_status_low_ammo"
const ICON_STATUS_DAMAGED := "icon_status_damaged"
const ICON_STATUS_DESTROYED := "icon_status_destroyed"
const ICON_STATUS_SUPPLY := "icon_status_supply"
const ICON_RESERVE_INFANTRY := "icon_reserve_infantry"
const ICON_RESERVE_ARMOR := "icon_reserve_armor"
const ICON_INTEL := "icon_intel"
const ICON_MISSION := "icon_mission"
const ICON_VICTORY := "icon_victory"
const ICON_DEFEAT := "icon_defeat"
const ICON_ALERT_CRITICAL := "icon_alert_critical"
const ICON_ALERT_TACTICAL := "icon_alert_tactical"
const ICON_ALERT_INFO := "icon_alert_info"
const ICON_CONTACT := "icon_contact"
const ICON_LAST_KNOWN := "icon_last_known"
const ICON_CONFIRMED := "icon_confirmed"
const ICON_LOCKED := "icon_locked"

static var _icon_cache: Dictionary = {}

## Loads an icon texture with a cached lazy lookup so presentation code stays
## robust even if the import cache is cold (falls back to null, callers draw
## a programmatic fallback glyph in that case).
static func icon(icon_name: String) -> Texture2D:
	if _icon_cache.has(icon_name):
		return _icon_cache[icon_name]
	var texture: Texture2D = load("res://assets/ui/%s.svg" % icon_name)
	_icon_cache[icon_name] = texture
	return texture

static func style(fill: Color, border: Color, width: float, radius: float) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.border_color = border
	box.set_border_width_all(int(round(width)))
	box.set_corner_radius_all(int(round(radius)))
	return box

static func panel_style(edge: Color = PANEL_EDGE) -> StyleBoxFlat:
	return style(PANEL_FILL, edge, 1.0, PANEL_RADIUS)

static func chip_style(edge: Color = PANEL_EDGE_SOFT) -> StyleBoxFlat:
	return style(CHIP_FILL, edge, 1.0, CHIP_RADIUS)

static func hp_color(ratio: float) -> Color:
	if ratio > 0.55:
		return Color("6ccb6c")
	if ratio > 0.25:
		return WITHDRAW_AMBER
	return INVALID

static func objective_color(owner: String, contested: bool, locked: bool) -> Color:
	if contested:
		return CONTESTED
	if locked:
		return LOCKED
	if owner == "PLAYER":
		return PLAYER_BLUE
	if owner == "AI":
		return AI_RED
	return NEUTRAL

static func order_color(order: String) -> Color:
	match order:
		"MOVE":
			return MOVE_GREEN
		"WITHDRAW":
			return WITHDRAW_AMBER
		"DESTROYED":
			return CRITICAL
		_:
			return HOLD_BLUE