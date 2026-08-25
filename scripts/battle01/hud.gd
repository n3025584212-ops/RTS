class_name BattleHUD
extends CanvasLayer

signal restart_requested

const MINIMAP_SCRIPT: Script = preload("res://scripts/battle01/battle_minimap.gd")

@onready var task_label: Label = $Root/TopLeft/Task
@onready var selected_label: Label = $Root/TopLeft/Selected
@onready var order_label: Label = $Root/TopLeft/Order
@onready var blue_health_label: Label = $Root/TopLeft/BlueHealth
@onready var enemy_health_label: Label = $Root/TopLeft/EnemyHealth
@onready var intel_label: Label = $Root/TopLeft/Intel
@onready var objective_label: Label = $Root/TopLeft/Objective
@onready var controls_label: Label = $Root/TopLeft/Controls
@onready var result_panel: PanelContainer = $Root/VictoryPanel
@onready var result_title: Label = $Root/VictoryPanel/VBox/Victory
@onready var result_message: Label = $Root/VictoryPanel/VBox/Message
@onready var restart_button: Button = $Root/VictoryPanel/VBox/Restart

var _force_status_label: Label
var _supply_status_label: Label
var _reserve_status_label: Label
var _rally_status_label: Label
var _mission_line: Label
var _central_state: Label
var _central_progress: ProgressBar
var _industrial_state: Label
var _industrial_progress: ProgressBar
var _selection_header: Label
var _selection_cards: VBoxContainer
var _formation_detail: Label
var _command_feedback: Label
var _supply_title: Label
var _supply_progress: ProgressBar
var _reserve_badge: Label
var _reserve_inf_button: Button
var _reserve_inf_status: Label
var _reserve_armor_button: Button
var _reserve_armor_status: Label
var _reserve_dependency: Label
var _intel_summary: Label
var _enemy_hp_bar: ProgressBar
var _enemy_hp_text: Label
var _rally_summary: Label
var _alerts: VBoxContainer
var _debug_container: Control
var _minimap: BattleMinimap
var _result_icon: TextureRect

var _selected_formations: Array[BattleFormation] = []
var _known_friendlies: Array[BattleFormation] = []
var _intel_state: String = "UNSEEN"
var _enemy_hp: int = 0
var _enemy_max_hp: int = 0
var _enemy_alive: bool = true
var _central_owner: String = "AI"
var _central_contested: bool = false
var _industrial_owner: String = "AI"
var _industrial_contested: bool = false
var _industrial_locked: bool = true
var _reserve_unlocked: bool = false
var _reserve_committed: bool = false
var _reserve_choice: String = ""
var _last_supply_message: String = ""
var _last_order_text: String = ""
var _alert_records: Array[Dictionary] = []
var _alert_serial: int = 0
var _initialized: bool = false
var _refresh_accumulator: float = 0.0

func _ready() -> void:
	restart_button.pressed.connect(_on_restart_pressed)
	result_panel.visible = false
	_debug_container = $Root/TopLeft
	_debug_container.visible = false
	_create_runtime_status_labels()
	_build_player_hud()
	_style_result_panel()
	set_selection_summary([])
	set_order_summary([])
	set_friendly_health(0, 0, 0, 0)
	set_enemy_health(0, 0, true)
	set_intel_state("UNSEEN", Vector2.ZERO)
	set_objectives("AI", false, 0.0, "AI", false, 0.0, true)
	set_supply_status(0, 0, 0.0, false, "Ready")
	set_reserve_status(false, false, "")
	set_rally_status(false)
	_initialized = true

func _process(delta: float) -> void:
	_refresh_accumulator += delta
	if _refresh_accumulator >= 0.20:
		_refresh_accumulator = 0.0
		_refresh_intel_summary()
		_refresh_alerts(delta + 0.20)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F10:
		_debug_container.visible = not _debug_container.visible
		push_alert("INFO", "DEBUG OVERLAY %s" % ("ON" if _debug_container.visible else "OFF"), "debug")

func _build_player_hud() -> void:
	var root: Control = $Root
	# --- TOP CENTER: mission strip (P0-01 top band) ---
	var mission_panel := _panel("MissionBattleState", root)
	_set_rect(mission_panel, 18.0, 16.0, 820.0, 108.0)
	var mission_v := _vbox(mission_panel, 14)
	mission_v.add_child(_section_caption("OPERATION IRON CROSSING  /  BATTLE STATE"))
	_mission_line = _label("SECURE CENTRAL BRIDGEHEAD", Battle01UIStyle.FS_MISSION, Battle01UIStyle.TEXT_MAIN)
	mission_v.add_child(_mission_line)
	var chips := HBoxContainer.new()
	chips.add_theme_constant_override("separation", 12)
	mission_v.add_child(chips)
	var central_chip := _objective_chip(chips, "CENTRAL  ·  INTERMEDIATE", Battle01UIStyle.ICON_OBJECTIVE_BRIDGE)
	_central_state = central_chip["state"] as Label
	_central_progress = central_chip["progress"] as ProgressBar
	var industrial_chip := _objective_chip(chips, "INDUSTRIAL  ·  FINAL", Battle01UIStyle.ICON_OBJECTIVE_INDUSTRIAL)
	_industrial_state = industrial_chip["state"] as Label
	_industrial_progress = industrial_chip["progress"] as ProgressBar

	# --- TOP RIGHT: enemy intel (FOW legal, icon + summary + strength bar) ---
	var intel_panel := _panel("EnemyIntel", root)
	_set_right_rect(intel_panel, 350.0, 16.0, 332.0, 128.0)
	var intel_v := _vbox(intel_panel, 14)
	intel_v.add_child(_section_caption("ENEMY INTEL  /  FOW LEGAL"))
	var intel_head := HBoxContainer.new()
	intel_head.add_theme_constant_override("separation", 8)
	intel_v.add_child(intel_head)
	intel_head.add_child(_icon_rect(Battle01UIStyle.ICON_INTEL, 20))
	_intel_summary = _label("NO ENEMY CONTACT", Battle01UIStyle.FS_MEDIUM, Battle01UIStyle.TEXT_MAIN)
	_intel_summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_intel_summary.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	intel_head.add_child(_intel_summary)
	var strength_row := HBoxContainer.new()
	strength_row.add_theme_constant_override("separation", 8)
	intel_v.add_child(strength_row)
	strength_row.add_child(_label("RED INF-01", Battle01UIStyle.FS_CAPTION, Battle01UIStyle.AI_RED))
	_enemy_hp_bar = _progress(strength_row, Battle01UIStyle.AI_RED)
	_enemy_hp_bar.custom_minimum_size = Vector2(0.0, 8.0)
	_enemy_hp_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_enemy_hp_text = _label("HIDDEN", Battle01UIStyle.FS_CAPTION, Battle01UIStyle.TEXT_MUTED)
	strength_row.add_child(_enemy_hp_text)

	# --- LEFT COLUMN: reserve commitment (P0-02 decision layer) ---
	var reserve_panel := _panel("Reserve", root)
	_set_rect(reserve_panel, 18.0, 140.0, 300.0, 272.0)
	var reserve_v := _vbox(reserve_panel, 14)
	reserve_v.add_child(_section_caption("RESERVE  /  ONE CHOICE ONLY"))
	_reserve_badge = _label("1 COMMITMENT  ·  LOCKED", Battle01UIStyle.FS_BODY, Color(0.62, 0.67, 0.70))
	reserve_v.add_child(_reserve_badge)
	var infantry_row := _reserve_button(reserve_v, Battle01UIStyle.ICON_RESERVE_INFANTRY, "INFANTRY", "LOCKED")
	_reserve_inf_button = infantry_row["button"] as Button
	_reserve_inf_status = infantry_row["status"] as Label
	_reserve_inf_button.pressed.connect(_on_reserve_chosen.bind("INFANTRY"))
	var armor_row := _reserve_button(reserve_v, Battle01UIStyle.ICON_RESERVE_ARMOR, "ARMOR", "LOCKED")
	_reserve_armor_button = armor_row["button"] as Button
	_reserve_armor_status = armor_row["status"] as Label
	_reserve_armor_button.pressed.connect(_on_reserve_chosen.bind("ARMOR"))
	_reserve_dependency = _label("SECURE CENTRAL BRIDGEHEAD", Battle01UIStyle.FS_CAPTION, Battle01UIStyle.TEXT_MUTED)
	_reserve_dependency.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reserve_v.add_child(_reserve_dependency)

	# --- LEFT COLUMN: rally network ---
	var rally_panel := _panel("RallyState", root)
	_set_rect(rally_panel, 18.0, 428.0, 300.0, 100.0)
	var rally_v := _vbox(rally_panel, 12)
	rally_v.add_child(_section_caption("RALLY NETWORK"))
	var west_row := HBoxContainer.new()
	west_row.add_theme_constant_override("separation", 8)
	rally_v.add_child(west_row)
	west_row.add_child(_icon_rect(Battle01UIStyle.ICON_RALLY_WEST, 16))
	west_row.add_child(_label("WEST REAR  ACTIVE", Battle01UIStyle.FS_SMALL, Battle01UIStyle.TEXT_MAIN))
	var forward_row := HBoxContainer.new()
	forward_row.add_theme_constant_override("separation", 8)
	rally_v.add_child(forward_row)
	forward_row.add_child(_icon_rect(Battle01UIStyle.ICON_RALLY_FORWARD, 16))
	_rally_summary = _label("BRIDGEHEAD  INACTIVE", Battle01UIStyle.FS_SMALL, Battle01UIStyle.TEXT_MAIN)
	forward_row.add_child(_rally_summary)

	# --- BOTTOM LEFT: selection cards (P0-01 unit info panel) ---
	var selection_panel := _panel("SelectionSummary", root)
	_set_bottom_rect(selection_panel, 18.0, 218.0, 640.0, 200.0)
	var selection_v := _vbox(selection_panel, 14)
	_selection_header = _label("NO FORMATION SELECTED", Battle01UIStyle.FS_BODY, Battle01UIStyle.TEXT_MUTED)
	selection_v.add_child(_selection_header)
	_selection_cards = VBoxContainer.new()
	_selection_cards.add_theme_constant_override("separation", 4)
	selection_v.add_child(_selection_cards)
	_formation_detail = _label("Select a BLUE Formation for exact HP, ammo and order.", Battle01UIStyle.FS_CAPTION, Battle01UIStyle.TEXT_MUTED)
	selection_v.add_child(_formation_detail)

	# --- BOTTOM CENTER: command area (P0-03 icon command language) ---
	var command_panel := _panel("CommandArea", root)
	_set_bottom_rect(command_panel, 672.0, 218.0, 360.0, 200.0)
	var command_v := _vbox(command_panel, 14)
	command_v.add_child(_section_caption("COMMAND"))
	var commands := HBoxContainer.new()
	commands.add_theme_constant_override("separation", 8)
	command_v.add_child(commands)
	_command_chip(commands, Battle01UIStyle.ICON_COMMAND_MOVE, "MOVE  ·  RMB", Battle01UIStyle.MOVE_GREEN)
	_command_chip(commands, Battle01UIStyle.ICON_COMMAND_SUPPLY, "SUPPLY  ·  F", Battle01UIStyle.SUPPLY_CYAN)
	_command_chip(commands, Battle01UIStyle.ICON_COMMAND_WITHDRAW, "WITHDRAW  ·  X", Battle01UIStyle.WITHDRAW_AMBER)
	_command_feedback = _label("AWAITING ORDERS", Battle01UIStyle.FS_MEDIUM, Battle01UIStyle.TEXT_MUTED)
	_command_feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	command_v.add_child(_command_feedback)
	var supply_head := HBoxContainer.new()
	supply_head.add_theme_constant_override("separation", 8)
	command_v.add_child(supply_head)
	supply_head.add_child(_icon_rect(Battle01UIStyle.ICON_STATUS_SUPPLY, 16))
	_supply_title = _label("AMMO SUPPLY  0/2  ·  READY", Battle01UIStyle.FS_SMALL, Battle01UIStyle.SUPPLY_CYAN)
	supply_head.add_child(_supply_title)
	_supply_progress = _progress(command_v, Battle01UIStyle.SUPPLY_CYAN)

	# --- RIGHT COLUMN: alert stream (icon prefixed) ---
	var alert_panel := _panel("Alerts", root)
	_set_right_rect(alert_panel, 350.0, 152.0, 332.0, 286.0)
	var alert_v := _vbox(alert_panel, 12)
	alert_v.add_child(_section_caption("BATTLE ALERTS"))
	_alerts = VBoxContainer.new()
	_alerts.add_theme_constant_override("separation", 5)
	alert_v.add_child(_alerts)

	# --- BOTTOM RIGHT: minimap (P0-01 tactical overview) ---
	var minimap_panel := _panel("TacticalOverview", root)
	_set_bottom_right_rect(minimap_panel, 350.0, 218.0, 332.0, 200.0)
	var map_v := _vbox(minimap_panel, 10)
	map_v.add_child(_section_caption("TACTICAL OVERVIEW  ·  CLICK TO NAVIGATE"))
	_minimap = MINIMAP_SCRIPT.new() as BattleMinimap
	_minimap.custom_minimum_size = Vector2(304.0, 160.0)
	_minimap.size_flags_vertical = Control.SIZE_EXPAND_FILL
	map_v.add_child(_minimap)
	_minimap.call_deferred("configure", get_parent())

func _style_result_panel() -> void:
	result_panel.set_anchors_preset(Control.PRESET_CENTER)
	result_panel.offset_left = -260.0
	result_panel.offset_top = -160.0
	result_panel.offset_right = 260.0
	result_panel.offset_bottom = 160.0
	result_panel.add_theme_stylebox_override("panel", Battle01UIStyle.style(Color(0.018, 0.040, 0.055, 0.98), Battle01UIStyle.PLAYER_BLUE, 3.0, 14.0))
	result_title.add_theme_color_override("font_color", Battle01UIStyle.TEXT_MAIN)
	result_title.add_theme_font_size_override("font_size", Battle01UIStyle.FS_BANNER)
	result_message.add_theme_color_override("font_color", Battle01UIStyle.TEXT_MUTED)
	result_message.add_theme_font_size_override("font_size", Battle01UIStyle.FS_TITLE)
	restart_button.add_theme_stylebox_override("normal", Battle01UIStyle.style(Color(0.08, 0.20, 0.30), Battle01UIStyle.PLAYER_BLUE, 2.0, 7.0))
	restart_button.add_theme_color_override("font_color", Battle01UIStyle.TEXT_MAIN)
	restart_button.text = "RESTART BATTLE01"
	_result_icon = _icon_rect(Battle01UIStyle.ICON_MISSION, 44)
	_result_icon.name = "ResultIcon"
	var vbox: VBoxContainer = result_panel.get_node("VBox") as VBoxContainer
	vbox.add_child(_result_icon)
	vbox.move_child(_result_icon, 0)

func _create_runtime_status_labels() -> void:
	var container: VBoxContainer = $Root/TopLeft
	_force_status_label = Label.new()
	_force_status_label.name = "ForceStatus"
	container.add_child(_force_status_label)
	_supply_status_label = Label.new()
	_supply_status_label.name = "SupplyStatus"
	container.add_child(_supply_status_label)
	_reserve_status_label = Label.new()
	_reserve_status_label.name = "ReserveStatus"
	container.add_child(_reserve_status_label)
	_rally_status_label = Label.new()
	_rally_status_label.name = "RallyStatus"
	container.add_child(_rally_status_label)

func set_selection_summary(formations: Array[BattleFormation]) -> void:
	_selected_formations = formations.duplicate()
	for child: Node in _selection_cards.get_children():
		child.queue_free()
	if formations.is_empty():
		selected_label.text = "Selected Formations: NONE"
		_selection_header.text = "NO FORMATION SELECTED"
		_formation_detail.text = "Select a BLUE Formation for exact HP, ammo and order."
		return
	_selection_header.text = "%d FORMATION%s SELECTED" % [formations.size(), "S" if formations.size() != 1 else ""]
	var debug_summaries := PackedStringArray()
	for formation: BattleFormation in formations:
		if formation == null or not is_instance_valid(formation):
			continue
		debug_summaries.append(_formation_debug_summary(formation))
		var row := HBoxContainer.new()
		row.custom_minimum_size = Vector2(0.0, 30.0)
		row.add_theme_constant_override("separation", 8)
		row.add_child(_icon_rect(_role_icon_name(formation.get_role()), 22))
		var callsign := _label(_short_callsign(formation.display_name), Battle01UIStyle.FS_SMALL, Battle01UIStyle.TEXT_MAIN)
		callsign.custom_minimum_size = Vector2(128.0, 0.0)
		row.add_child(callsign)
		var hp_ratio: float = float(formation.current_hp) / float(maxi(1, formation.max_hp))
		var hp_bar := _mini_progress(row, Battle01UIStyle.hp_color(hp_ratio))
		hp_bar.custom_minimum_size = Vector2(78.0, 8.0)
		var hp_text := _label("HP %d/%d" % [formation.current_hp, formation.max_hp], Battle01UIStyle.FS_CAPTION, Battle01UIStyle.hp_color(hp_ratio))
		hp_text.custom_minimum_size = Vector2(64.0, 0.0)
		row.add_child(hp_text)
		var ammo_text: String = "CHG %d/%d" % [formation.get_supply_charges(), formation.supply_capacity] if formation.is_supply_truck() else "AMMO %d/%d" % [formation.current_ammo, formation.ammo_capacity]
		var ammo := _label(ammo_text, Battle01UIStyle.FS_CAPTION, _ammo_color(formation))
		ammo.custom_minimum_size = Vector2(92.0, 0.0)
		row.add_child(ammo)
		row.add_child(_label(formation.get_order(), Battle01UIStyle.FS_SMALL, _order_color(formation.get_order())))
		_selection_cards.add_child(row)
	selected_label.text = "Selected: %s" % " | ".join(debug_summaries)
	if formations.size() == 1:
		var formation: BattleFormation = formations[0]
		_formation_detail.text = "%s  ·  %s  ·  %s" % [formation.display_name, formation.definition.display_name if formation.definition != null else formation.get_role(), _critical_state(formation)]
	else:
		_formation_detail.text = "Group orders preserve spacing; critical states remain individual."

func set_order_summary(formations: Array[BattleFormation]) -> void:
	if formations.is_empty():
		order_label.text = "Current Orders: --"
		return
	var orders := PackedStringArray()
	var order_counts: Dictionary = {}
	for formation: BattleFormation in formations:
		if formation != null and is_instance_valid(formation):
			orders.append("%s=%s" % [formation.display_name, formation.get_order()])
			order_counts[formation.get_order()] = int(order_counts.get(formation.get_order(), 0)) + 1
	order_label.text = "Current Orders: %s" % " | ".join(orders)
	var display: String
	if order_counts.size() == 1:
		var only_order: String = str(order_counts.keys()[0])
		display = "%s  ·  %d FORMATION%s" % [only_order, formations.size(), "S" if formations.size() != 1 else ""]
	else:
		display = "MIXED ORDERS  ·  %d FORMATIONS" % formations.size()
	if display != _last_order_text:
		_last_order_text = display
		_command_feedback.text = display
	set_selection_summary(formations)

func set_force_status(formations: Array[BattleFormation]) -> void:
	_known_friendlies = formations.duplicate()
	if _force_status_label == null:
		return
	var values := PackedStringArray()
	for formation: BattleFormation in formations:
		if formation == null or not is_instance_valid(formation):
			continue
		values.append(_formation_debug_summary(formation))
		var status_key: String = "formation_%s" % formation.get_instance_id()
		if not formation.is_alive:
			push_alert("CRITICAL", "%s DESTROYED" % formation.display_name, status_key)
		elif formation.ammo_capacity > 0 and formation.current_ammo <= int(floor(float(formation.ammo_capacity) * 0.25)):
			push_alert("TACTICAL", "%s  ·  %s" % [formation.display_name, "AMMO EMPTY" if formation.current_ammo == 0 else "LOW AMMO"], status_key)
	_force_status_label.text = "BLUE FORCE: %s" % " | ".join(values)

func set_supply_status(charges: int, max_charges: int, progress_seconds: float, active: bool, message: String) -> void:
	if _supply_status_label != null:
		_supply_status_label.text = "SUPPLY %d/%d — %.1f/4.0s — %s" % [charges, max_charges, progress_seconds, message]
	var concise_state: String = "READY"
	if active: concise_state = "TRANSFER ACTIVE"
	elif charges == 0 and max_charges > 0: concise_state = "EMPTY"
	elif "COMPLETE" in message: concise_state = "COMPLETE"
	elif "INTERRUPTED" in message: concise_state = "INTERRUPTED"
	elif "INVALID" in message: concise_state = "INVALID"
	_supply_title.text = "AMMO SUPPLY  %d/%d  ·  %s" % [charges, max_charges, concise_state]
	_supply_title.add_theme_color_override("font_color", Battle01UIStyle.AI_RED if charges == 0 else Battle01UIStyle.SUPPLY_CYAN)
	_supply_progress.value = clampf(progress_seconds / 4.0 * 100.0, 0.0, 100.0)
	_supply_progress.visible = active
	if _initialized and message != _last_supply_message:
		if "INTERRUPTED" in message or "INVALID" in message:
			push_alert("TACTICAL", message, "supply")
		elif "COMPLETE" in message:
			push_alert("INFO", message.replace("SUPPLY COMPLETE — ", "AMMO TRANSFER COMPLETE  ·  "), "supply")
		elif charges == 0 and max_charges > 0:
			push_alert("TACTICAL", "SUPPLY EMPTY  ·  NO AMMO CHARGES", "supply_empty")
	_last_supply_message = message

func set_reserve_status(unlocked: bool, committed: bool, choice: String) -> void:
	if _reserve_status_label != null:
		_reserve_status_label.text = "RESERVE unlocked=%s committed=%s choice=%s" % [unlocked, committed, choice]
	var was_unlocked: bool = _reserve_unlocked
	var was_committed: bool = _reserve_committed
	_reserve_unlocked = unlocked
	_reserve_committed = committed
	_reserve_choice = choice
	var locked_color := Color(0.62, 0.67, 0.70)
	if committed:
		_reserve_badge.text = "COMMITMENT SPENT"
		_reserve_badge.add_theme_color_override("font_color", Battle01UIStyle.PLAYER_BLUE)
		_reserve_inf_button.disabled = true
		_reserve_armor_button.disabled = true
		_reserve_inf_status.text = "COMMITTED" if choice == "INFANTRY" else "UNAVAILABLE"
		_reserve_armor_status.text = "COMMITTED" if choice == "ARMOR" else "UNAVAILABLE"
		_reserve_inf_status.add_theme_color_override("font_color", Battle01UIStyle.PLAYER_BLUE if choice == "INFANTRY" else locked_color)
		_reserve_armor_status.add_theme_color_override("font_color", Battle01UIStyle.PLAYER_BLUE if choice == "ARMOR" else locked_color)
		_reserve_dependency.text = "OTHER CHOICE  ·  OPPORTUNITY SPENT"
	elif unlocked:
		_reserve_badge.text = "1 COMMITMENT  ·  CHOOSE ONE"
		_reserve_badge.add_theme_color_override("font_color", Battle01UIStyle.WITHDRAW_AMBER)
		_reserve_inf_button.disabled = false
		_reserve_armor_button.disabled = false
		_reserve_inf_status.text = "AVAILABLE  ·  COMMIT"
		_reserve_armor_status.text = "AVAILABLE  ·  COMMIT"
		_reserve_inf_status.add_theme_color_override("font_color", Battle01UIStyle.TEXT_MAIN)
		_reserve_armor_status.add_theme_color_override("font_color", Battle01UIStyle.TEXT_MAIN)
		_reserve_dependency.text = "ONE CHOICE ONLY  ·  NO REFUND"
	else:
		_reserve_badge.text = "1 COMMITMENT  ·  LOCKED"
		_reserve_badge.add_theme_color_override("font_color", locked_color)
		_reserve_inf_button.disabled = true
		_reserve_armor_button.disabled = true
		_reserve_inf_status.text = "LOCKED"
		_reserve_armor_status.text = "LOCKED"
		_reserve_inf_status.add_theme_color_override("font_color", locked_color)
		_reserve_armor_status.add_theme_color_override("font_color", locked_color)
		_reserve_dependency.text = "SECURE CENTRAL BRIDGEHEAD"
	if _initialized and unlocked and not was_unlocked:
		push_alert("TACTICAL", "RESERVE UNLOCKED  ·  CHOOSE ONE", "reserve")
	if _initialized and committed and not was_committed:
		push_alert("TACTICAL", "RESERVE COMMITTED  ·  %s  ·  WEST REAR" % choice, "reserve")

func set_objectives(central_owner: String, central_is_contested: bool, central_capture_progress: float, industrial_owner: String, industrial_is_contested: bool, industrial_capture_progress: float, industrial_is_locked: bool) -> void:
	var previous_central_owner: String = _central_owner
	var previous_central_contested: bool = _central_contested
	var previous_industrial_contested: bool = _industrial_contested
	var previous_locked: bool = _industrial_locked
	_central_owner = central_owner
	_central_contested = central_is_contested
	_industrial_owner = industrial_owner
	_industrial_contested = industrial_is_contested
	_industrial_locked = industrial_is_locked
	_central_state.text = _objective_state_text(central_owner, central_is_contested, false, central_capture_progress).replace("UNLOCKED", "ACTIVE")
	_central_state.add_theme_color_override("font_color", _objective_color(central_owner, central_is_contested, false))
	_central_progress.value = central_capture_progress * 100.0
	_central_progress.visible = central_capture_progress > 0.0
	_industrial_state.text = _objective_state_text(industrial_owner, industrial_is_contested, industrial_is_locked, industrial_capture_progress)
	_industrial_state.add_theme_color_override("font_color", _objective_color(industrial_owner, industrial_is_contested, industrial_is_locked))
	_industrial_progress.value = industrial_capture_progress * 100.0
	_industrial_progress.visible = industrial_capture_progress > 0.0
	objective_label.text = "OBJECTIVES Central=%s contested=%s %.0f%% Industrial=%s contested=%s locked=%s %.0f%%" % [central_owner, central_is_contested, central_capture_progress * 100.0, industrial_owner, industrial_is_contested, industrial_is_locked, industrial_capture_progress * 100.0]
	_mission_line.text = "SECURE CENTRAL BRIDGEHEAD" if industrial_is_locked else "INDUSTRIAL CONTESTED  ·  HOLD CENTRAL" if industrial_is_contested else "SECURE INDUSTRIAL  ·  HOLD CENTRAL"
	if _initialized:
		if central_is_contested and not previous_central_contested:
			push_alert("TACTICAL", "CENTRAL BRIDGEHEAD CONTESTED", "central_contested")
		if industrial_is_contested and not previous_industrial_contested:
			push_alert("CRITICAL", "INDUSTRIAL OBJECTIVE CONTESTED", "industrial_contested")
		if central_owner == BattleObjective.OWNER_PLAYER and previous_central_owner != BattleObjective.OWNER_PLAYER:
			push_alert("TACTICAL", "CENTRAL SECURED", "central_captured")
		if previous_locked and not industrial_is_locked:
			push_alert("TACTICAL", "FINAL OBJECTIVE UNLOCKED  ·  INDUSTRIAL", "industrial_unlocked")

func set_rally_status(forward_active: bool) -> void:
	if _rally_status_label != null:
		_rally_status_label.text = "RALLY WEST=ACTIVE FORWARD=%s" % forward_active
	var was_active: bool = _rally_summary != null and "BRIDGEHEAD  ACTIVE" in _rally_summary.text
	_rally_summary.text = "BRIDGEHEAD  %s" % ("ACTIVE" if forward_active else "INACTIVE")
	_rally_summary.add_theme_color_override("font_color", Battle01UIStyle.SUPPLY_CYAN if forward_active else Battle01UIStyle.TEXT_MAIN)
	if _initialized and forward_active != was_active:
		push_alert("TACTICAL", "BRIDGEHEAD FORWARD RALLY  ·  %s" % ("ACTIVE" if forward_active else "INACTIVE"), "forward_rally")

func set_friendly_health(ifv_hp: int, ifv_max_hp: int, recon_hp: int, recon_max_hp: int) -> void:
	blue_health_label.text = "Friendly Core: IFV %d/%d | RECON %d/%d" % [ifv_hp, ifv_max_hp, recon_hp, recon_max_hp]

func set_enemy_health(current_hp: int, max_hp: int, alive: bool) -> void:
	_enemy_hp = current_hp
	_enemy_max_hp = max_hp
	_enemy_alive = alive
	_refresh_enemy_health()

func set_intel_state(next_state: String, _last_known_position: Vector2) -> void:
	var previous: String = _intel_state
	_intel_state = next_state
	intel_label.text = "Enemy Intel: %s" % next_state.replace("_", " ")
	_refresh_enemy_health()
	_refresh_intel_summary()
	if _initialized and previous != next_state:
		if next_state == "CONTACT": push_alert("TACTICAL", "CONTACT  ·  IDENTITY UNKNOWN", "intel_primary")
		elif next_state == "CONFIRMED": push_alert("TACTICAL", "CONFIRMED  ·  RED FORMATION", "intel_primary")
		elif next_state == "LAST_KNOWN": push_alert("INFO", "CONTACT LOST  ·  LAST KNOWN FROZEN", "intel_primary")

func _refresh_enemy_health() -> void:
	if _enemy_hp_bar == null:
		return
	if not _enemy_alive and _intel_state == "CONFIRMED":
		enemy_health_label.text = "RED INF-01: DESTROYED"
		_enemy_hp_bar.value = 0
		_enemy_hp_text.text = "DESTROYED"
		_enemy_hp_text.add_theme_color_override("font_color", Battle01UIStyle.CRITICAL)
	elif _intel_state == "CONFIRMED":
		enemy_health_label.text = "RED INF-01 HP: %d / %d" % [_enemy_hp, _enemy_max_hp]
		_enemy_hp_bar.value = float(_enemy_hp) / float(maxi(1, _enemy_max_hp)) * 100.0
		_enemy_hp_text.text = "%d/%d" % [_enemy_hp, _enemy_max_hp]
		_enemy_hp_text.add_theme_color_override("font_color", Battle01UIStyle.TEXT_MAIN)
	else:
		enemy_health_label.text = "Enemy Strength: HIDDEN"
		_enemy_hp_bar.value = 0
		_enemy_hp_text.text = "HIDDEN"
		_enemy_hp_text.add_theme_color_override("font_color", Battle01UIStyle.TEXT_MUTED)
	_enemy_hp_bar.visible = _intel_state == "CONFIRMED"

func _refresh_intel_summary() -> void:
	if _intel_summary == null:
		return
	var rows := PackedStringArray()
	var battle: Node = get_parent()
	if battle != null:
		for child: Node in battle.get_children():
			if not child is BattleFormation:
				continue
			var formation := child as BattleFormation
			if formation.faction != "RED" or not formation.is_alive or not formation.visible:
				continue
			if formation.intel_state == BattleIntelTracker.CONTACT:
				rows.append("CONTACT  ·  IDENTITY UNKNOWN")
			elif formation.intel_state == BattleIntelTracker.CONFIRMED:
				rows.append("%s  ·  %s" % [_short_callsign(formation.display_name), _role_code(formation)])
			elif formation.intel_state == BattleIntelTracker.LAST_KNOWN:
				rows.append("LAST KNOWN  ·  STALE / STATIC")
	if rows.is_empty():
		_intel_summary.text = "NO ENEMY CONTACT"
		_intel_summary.add_theme_color_override("font_color", Battle01UIStyle.TEXT_MUTED)
	else:
		_intel_summary.text = "\n".join(rows.slice(0, 3))
		_intel_summary.add_theme_color_override("font_color", Battle01UIStyle.AI_RED if _intel_state == BattleIntelTracker.CONFIRMED else Battle01UIStyle.WITHDRAW_AMBER)

func set_objective(state: String, progress: float) -> void:
	objective_label.text = "Central Bridgehead: %s %d%%" % [state, int(round(progress * 100.0))]

func show_command_feedback(message: String, level: String = "INFO") -> void:
	_command_feedback.text = message
	push_alert(level, message, "command")

func push_alert(level: String, message: String, key: String = "") -> void:
	if _alerts == null or message.is_empty():
		return
	var semantic_key: String = key if not key.is_empty() else message
	var alert_color := _alert_color(level)
	for record: Dictionary in _alert_records:
		if str(record.get("key", "")) == semantic_key:
			record["time"] = 7.0 if level == "CRITICAL" else 4.5
			(record["label"] as Label).text = message
			(record["label"] as Label).add_theme_color_override("font_color", alert_color)
			return
	_alert_serial += 1
	var row := PanelContainer.new()
	row.name = "Alert%d" % _alert_serial
	row.custom_minimum_size = Vector2(0.0, 34.0)
	row.add_theme_stylebox_override("panel", Battle01UIStyle.style(Color(alert_color, 0.10), Color(alert_color, 0.55), 1.0, 4.0))
	var inner := HBoxContainer.new()
	inner.add_theme_constant_override("separation", 6)
	row.add_child(inner)
	inner.add_child(_icon_rect(_alert_icon_name(level), 16))
	var label := _label(message, Battle01UIStyle.FS_SMALL, alert_color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inner.add_child(label)
	_alerts.add_child(row)
	_alert_records.append({"key": semantic_key, "level": level, "time": 7.0 if level == "CRITICAL" else 4.5, "row": row, "label": label})
	while _alert_records.size() > 4:
		_remove_alert_at(0)

func _refresh_alerts(delta: float) -> void:
	for index: int in range(_alert_records.size() - 1, -1, -1):
		var record: Dictionary = _alert_records[index]
		record["time"] = float(record["time"]) - delta
		_alert_records[index] = record
		if float(record["time"]) <= 0.0:
			_remove_alert_at(index)

func _remove_alert_at(index: int) -> void:
	if index < 0 or index >= _alert_records.size(): return
	var row: PanelContainer = _alert_records[index]["row"] as PanelContainer
	if row != null: row.queue_free()
	_alert_records.remove_at(index)

func show_victory() -> void:
	result_panel.visible = true
	result_panel.add_theme_stylebox_override("panel", Battle01UIStyle.style(Color(0.018, 0.040, 0.055, 0.98), Battle01UIStyle.PLAYER_BLUE, 3.0, 14.0))
	result_title.text = "VICTORY"
	result_title.add_theme_color_override("font_color", Battle01UIStyle.PLAYER_BLUE.lightened(0.22))
	_result_icon.texture = Battle01UIStyle.icon(Battle01UIStyle.ICON_VICTORY)
	result_message.text = "CENTRAL HELD  ·  INDUSTRIAL HELD\nMission complete. Decisive ground secured."
	_mission_line.text = "MISSION COMPLETE  ·  BOTH OBJECTIVES HELD"
	push_alert("CRITICAL", "VICTORY", "terminal")

func show_defeat() -> void:
	result_panel.visible = true
	result_panel.add_theme_stylebox_override("panel", Battle01UIStyle.style(Color(0.055, 0.025, 0.030, 0.98), Battle01UIStyle.AI_RED, 3.0, 14.0))
	result_title.text = "DEFEAT"
	result_title.add_theme_color_override("font_color", Battle01UIStyle.AI_RED.lightened(0.12))
	_result_icon.texture = Battle01UIStyle.icon(Battle01UIStyle.ICON_DEFEAT)
	result_message.text = "COMBAT / CAPTURE POWER IRRECOVERABLE\nNo legal reserve remains."
	_mission_line.text = "MISSION FAILED  ·  COMBAT POWER IRRECOVERABLE"
	push_alert("CRITICAL", "DEFEAT", "terminal")

func _on_reserve_chosen(kind: String) -> void:
	var war_flow := get_parent().get_node_or_null("PlayerWarFlow") as BattlePlayerWarFlow
	if war_flow != null: war_flow.deploy_reserve(kind)

func _on_restart_pressed() -> void:
	restart_requested.emit()

func _formation_debug_summary(formation: BattleFormation) -> String:
	if not formation.is_alive: return "%s DESTROYED" % formation.display_name
	if formation.is_supply_truck(): return "%s HP %d/%d SUP %d/%d" % [formation.display_name, formation.current_hp, formation.max_hp, formation.get_supply_charges(), formation.supply_capacity]
	return "%s HP %d/%d AMMO %d/%d" % [formation.display_name, formation.current_hp, formation.max_hp, formation.current_ammo, formation.ammo_capacity]

func _role_code(formation: BattleFormation) -> String:
	match formation.get_role():
		"RECON": return "RCN"
		"INFANTRY": return "INF"
		"IFV": return "IFV"
		"TANK", "ARMOR": return "ARM"
		"LOGISTICS": return "LOG"
	return "FRM"

func _role_icon_name(role: String) -> String:
	match role:
		"RECON": return Battle01UIStyle.ICON_ROLE_RECON
		"INFANTRY": return Battle01UIStyle.ICON_ROLE_INFANTRY
		"IFV": return Battle01UIStyle.ICON_ROLE_IFV
		"TANK", "ARMOR": return Battle01UIStyle.ICON_ROLE_ARMOR
		"LOGISTICS": return Battle01UIStyle.ICON_ROLE_LOGISTICS
	return Battle01UIStyle.ICON_MISSION

func _short_callsign(value: String) -> String:
	return value.replace("BLUE ", "").replace("RED ", "")

func _critical_state(formation: BattleFormation) -> String:
	if not formation.is_alive: return "DESTROYED"
	if formation.is_supply_truck(): return "AMMO SUPPLY  ·  CHARGES %d/%d" % [formation.get_supply_charges(), formation.supply_capacity]
	if formation.current_ammo == 0: return "AMMO EMPTY"
	if formation.current_ammo <= int(floor(float(formation.ammo_capacity) * 0.25)): return "LOW AMMO"
	return "COMBAT READY"

func _hp_color(formation: BattleFormation) -> Color:
	var ratio: float = float(formation.current_hp) / float(maxi(1, formation.max_hp))
	return Battle01UIStyle.hp_color(ratio)

func _ammo_color(formation: BattleFormation) -> Color:
	if formation.is_supply_truck(): return Battle01UIStyle.AI_RED if formation.get_supply_charges() == 0 else Battle01UIStyle.SUPPLY_CYAN
	return Battle01UIStyle.AI_RED if formation.current_ammo == 0 else Battle01UIStyle.WITHDRAW_AMBER if formation.current_ammo <= int(floor(float(formation.ammo_capacity) * 0.25)) else Battle01UIStyle.TEXT_MAIN

func _order_color(order: String) -> Color:
	return Battle01UIStyle.order_color(order)

func _objective_state_text(owner: String, contested: bool, locked: bool, capture_progress: float) -> String:
	if contested: return "%s CONTROL  ·  CONTESTED" % owner
	if locked: return "%s CONTROL  ·  LOCKED" % owner
	if capture_progress > 0.0: return "%s CONTROL  ·  CAPTURING %d%%" % [owner, int(round(capture_progress * 100.0))]
	return "%s CONTROL  ·  UNLOCKED" % owner

func _objective_color(owner: String, contested: bool, locked: bool) -> Color:
	return Battle01UIStyle.objective_color(owner, contested, locked)

func _alert_icon_name(level: String) -> String:
	if level == "CRITICAL": return Battle01UIStyle.ICON_ALERT_CRITICAL
	if level == "TACTICAL": return Battle01UIStyle.ICON_ALERT_TACTICAL
	return Battle01UIStyle.ICON_ALERT_INFO

func _alert_color(level: String) -> Color:
	if level == "CRITICAL": return Battle01UIStyle.CRITICAL
	if level == "TACTICAL": return Battle01UIStyle.WITHDRAW_AMBER
	return Battle01UIStyle.INFO_BLUE

func _icon_rect(icon_name: String, size: float) -> TextureRect:
	var rect := TextureRect.new()
	rect.custom_minimum_size = Vector2(size, size)
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.texture = Battle01UIStyle.icon(icon_name)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return rect

func _section_caption(value: String) -> Label:
	return _label(value, Battle01UIStyle.FS_CAPTION, Battle01UIStyle.TEXT_MUTED)

func _objective_chip(parent: Control, heading: String, icon_name: String) -> Dictionary:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(382.0, 46.0)
	panel.add_theme_stylebox_override("panel", Battle01UIStyle.chip_style())
	parent.add_child(panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 6)
	panel.add_child(margin)
	var outer := VBoxContainer.new()
	outer.add_theme_constant_override("separation", 2)
	margin.add_child(outer)
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 8)
	outer.add_child(head)
	head.add_child(_icon_rect(icon_name, 20))
	head.add_child(_label(heading, Battle01UIStyle.FS_CAPTION, Battle01UIStyle.TEXT_MUTED))
	var state := _label("AI CONTROL", Battle01UIStyle.FS_SMALL, Battle01UIStyle.AI_RED)
	outer.add_child(state)
	var bar := _progress(outer, Battle01UIStyle.AI_RED)
	bar.visible = false
	return {"state": state, "progress": bar}

func _command_chip(parent: Control, icon_name: String, caption: String, color: Color) -> void:
	var chip := PanelContainer.new()
	chip.custom_minimum_size = Vector2(108.0, 54.0)
	chip.add_theme_stylebox_override("panel", Battle01UIStyle.style(Color(color, 0.08), Color(color, 0.55), 1.0, 5.0))
	parent.add_child(chip)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 2)
	chip.add_child(box)
	var center := CenterContainer.new()
	center.add_child(_icon_rect(icon_name, 26))
	box.add_child(center)
	var cap := _label(caption, Battle01UIStyle.FS_CAPTION, color)
	cap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(cap)

func _reserve_button(parent: Control, icon_name: String, title: String, subtitle: String) -> Dictionary:
	var holder := Control.new()
	holder.custom_minimum_size = Vector2(0.0, 58.0)
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(holder)
	var button := Button.new()
	button.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	button.flat = true
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.add_theme_stylebox_override("normal", Battle01UIStyle.chip_style())
	button.add_theme_stylebox_override("hover", Battle01UIStyle.style(Color(0.07, 0.16, 0.22, 0.95), Battle01UIStyle.PLAYER_BLUE, 1.5, Battle01UIStyle.CHIP_RADIUS))
	button.add_theme_stylebox_override("pressed", Battle01UIStyle.style(Color(0.05, 0.12, 0.16, 0.95), Battle01UIStyle.PLAYER_BLUE, 1.5, Battle01UIStyle.CHIP_RADIUS))
	button.add_theme_stylebox_override("disabled", Battle01UIStyle.style(Color(0.030, 0.05, 0.06, 0.92), Color(0.13, 0.17, 0.19), 1.0, Battle01UIStyle.CHIP_RADIUS))
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	holder.add_child(button)
	var content := HBoxContainer.new()
	content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_theme_constant_override("separation", 10)
	holder.add_child(content)
	content.add_child(_icon_rect(icon_name, 30))
	var text_box := VBoxContainer.new()
	text_box.add_theme_constant_override("separation", 1)
	text_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	content.add_child(text_box)
	text_box.add_child(_label(title, Battle01UIStyle.FS_BODY, Battle01UIStyle.TEXT_MAIN))
	var status := _label(subtitle, Battle01UIStyle.FS_CAPTION, Battle01UIStyle.TEXT_MUTED)
	text_box.add_child(status)
	return {"button": button, "status": status}

func _panel(node_name: String, parent: Control) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.name = node_name
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", Battle01UIStyle.panel_style())
	parent.add_child(panel)
	return panel

func _vbox(parent: Control, margin: int) -> VBoxContainer:
	var margin_container := MarginContainer.new()
	margin_container.add_theme_constant_override("margin_left", margin)
	margin_container.add_theme_constant_override("margin_top", margin - 3)
	margin_container.add_theme_constant_override("margin_right", margin)
	margin_container.add_theme_constant_override("margin_bottom", margin - 3)
	parent.add_child(margin_container)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 5)
	margin_container.add_child(box)
	return box

func _label(value: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label

func _progress(parent: Control, color: Color) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.custom_minimum_size = Vector2(0.0, 5.0)
	bar.show_percentage = false
	bar.min_value = 0.0
	bar.max_value = 100.0
	bar.add_theme_stylebox_override("background", Battle01UIStyle.style(Color(0.02, 0.04, 0.05, 0.9), Color(0.12, 0.20, 0.24, 0.8), 1.0, 2.0))
	bar.add_theme_stylebox_override("fill", Battle01UIStyle.style(Color(color, 0.88), color, 0.0, 2.0))
	parent.add_child(bar)
	return bar

func _mini_progress(parent: Control, color: Color) -> ProgressBar:
	var bar := _progress(parent, color)
	bar.show_percentage = false
	bar.min_value = 0.0
	bar.max_value = 100.0
	return bar

func _style(fill: Color, border: Color, width: float, radius: float) -> StyleBoxFlat:
	return Battle01UIStyle.style(fill, border, width, radius)

func _set_rect(control: Control, left: float, top: float, width: float, height: float) -> void:
	control.position = Vector2(left, top)
	control.size = Vector2(width, height)

func _set_right_rect(control: Control, right_margin: float, top: float, width: float, height: float) -> void:
	control.anchor_left = 1.0
	control.anchor_right = 1.0
	control.offset_left = -right_margin
	control.offset_right = -right_margin + width
	control.offset_top = top
	control.offset_bottom = top + height

func _set_bottom_rect(control: Control, left: float, bottom_margin: float, width: float, height: float) -> void:
	control.anchor_top = 1.0
	control.anchor_bottom = 1.0
	control.offset_left = left
	control.offset_right = left + width
	control.offset_top = -bottom_margin
	control.offset_bottom = -bottom_margin + height

func _set_bottom_right_rect(control: Control, right_margin: float, bottom_margin: float, width: float, height: float) -> void:
	control.anchor_left = 1.0
	control.anchor_right = 1.0
	control.anchor_top = 1.0
	control.anchor_bottom = 1.0
	control.offset_left = -right_margin
	control.offset_right = -right_margin + width
	control.offset_top = -bottom_margin
	control.offset_bottom = -bottom_margin + height