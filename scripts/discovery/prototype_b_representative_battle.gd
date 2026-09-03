class_name PrototypeBRepresentativeBattle
extends PrototypeBCommandBattle

const ENEMY_COMMANDER_MODE: String = "STATE_DRIVEN"
const RED_RESERVE_INDEX: int = 2
const ENEMY_DECISION_INTERVAL: float = 4.0
const RED_RESERVE_RETASK_LOCK: float = 10.0
const RED_MANEUVER_RETASK_LOCK: float = 12.0
const RED_RESERVE_COMMIT_SCORE: float = 0.75
const SUPPORT_MAX_CHARGES: int = 2
const SUPPORT_COOLDOWN_SECONDS: float = 18.0
const SUPPORT_DURATION_SECONDS: float = 8.0
const SUPPORT_DAMAGE_PER_PULSE: int = 2
const SUPPORT_PULSE_SECONDS: float = 1.0
const SUPPORT_PRESSURE_MULTIPLIER: float = 0.62
const TREND_SAMPLE_SECONDS: float = 2.0

var enemy_decision_clock: float = 0.0
var red_last_order_elapsed: Array[float] = [0.0, 0.0, 0.0]
var red_reserve_committed: bool = false
var enemy_focus_sector: int = SECTOR_CROSSING

var support_charges: int = SUPPORT_MAX_CHARGES
var support_cooldown: float = 0.0
var support_active_sector: int = TASK_HOLD
var support_remaining: float = 0.0
var support_pulse_accumulator: float = 0.0

var trend_sample_clock: float = TREND_SAMPLE_SECONDS
var last_control_sample: Array[float] = [0.0, 0.0, 0.0]
var sector_trends: Array[String] = ["CONTESTED", "CONTESTED", "CONTESTED"]

var support_status_label: Label
var support_buttons: Array[Button] = []

func _ready() -> void:
	super._ready()
	print("FRONTLINE_PROTOTYPE_B_REPRESENTATIVE_BATTLE_READY enemy_commander=STATE_DRIVEN support=LIMITED trends=YES")

func _issue_initial_commands() -> void:
	for index: int in range(BLUE_COUNT - 1):
		_issue_blue_sector_task(index, int(blue_meta[index]["assigned_sector"]), false)
	command_service.cancel([blue_agents[RESERVE_INDEX]])

	# RED begins with two committed formations and one genuine uncommitted reserve.
	# The third formation is no longer moved by a timer profile; the commander
	# commits it only when the live battlefield creates a reason to do so.
	_set_red_assignment(0, SECTOR_RIDGE, false)
	_set_red_assignment(1, SECTOR_RELAY, false)
	var reserve_meta: Dictionary = red_meta[RED_RESERVE_INDEX]
	reserve_meta["assigned_sector"] = TASK_HOLD
	red_meta[RED_RESERVE_INDEX] = reserve_meta
	command_service.cancel([red_agents[RED_RESERVE_INDEX]])
	red_reserve_committed = false
	enemy_focus_sector = SECTOR_CROSSING
	enemy_event = "RED holds RIDGE and RELAY while keeping one formation uncommitted behind the line."
	previous_phase_index = phase_index

func _update_enemy_activity() -> void:
	var delta: float = get_process_delta_time()
	_update_support_state(delta)
	_update_sector_trends(delta)

	for index: int in range(red_last_order_elapsed.size()):
		red_last_order_elapsed[index] += delta

	enemy_decision_clock -= delta
	if enemy_decision_clock <= 0.0:
		_enemy_reassess()
		enemy_decision_clock = ENEMY_DECISION_INTERVAL

func _enemy_reassess() -> void:
	var scores: Array[float] = []
	for sector: int in range(SECTOR_COUNT):
		scores.append(_enemy_sector_score(sector))

	var best_sector: int = 0
	for sector: int in range(1, SECTOR_COUNT):
		if scores[sector] > scores[best_sector]:
			best_sector = sector
	enemy_focus_sector = best_sector

	var best_blue_power := _friendly_power_in_sector(best_sector)
	var best_red_power := _red_power_in_sector(best_sector)
	var reason := "probing a weakly covered sector"
	if best_blue_power > best_red_power + 0.20 or sector_control[best_sector] > 18.0:
		reason = "countering BLUE concentration"

	if not red_reserve_committed:
		if scores[best_sector] >= RED_RESERVE_COMMIT_SCORE:
			_set_red_assignment(RED_RESERVE_INDEX, best_sector, false)
			red_reserve_committed = true
			red_last_order_elapsed[RED_RESERVE_INDEX] = 0.0
			enemy_event = "RED reserve committed to %s, %s." % [SECTOR_NAMES[best_sector], reason]
		else:
			enemy_event = "RED reserve remains uncommitted; current focus is %s." % SECTOR_NAMES[best_sector]
	else:
		var current_reserve_sector := int(red_meta[RED_RESERVE_INDEX]["assigned_sector"])
		if current_reserve_sector != TASK_HOLD and current_reserve_sector != best_sector and red_last_order_elapsed[RED_RESERVE_INDEX] >= RED_RESERVE_RETASK_LOCK:
			var current_score := scores[current_reserve_sector]
			if scores[best_sector] >= current_score + 0.35:
				_set_red_assignment(RED_RESERVE_INDEX, best_sector, true)
				red_last_order_elapsed[RED_RESERVE_INDEX] = 0.0
				enemy_event = "RED reserve re-tasked from %s to %s as the balance changed." % [SECTOR_NAMES[current_reserve_sector], SECTOR_NAMES[best_sector]]

	# RED-2 is the maneuver element. It may shift between demands, but only after
	# staying committed long enough for the player's earlier allocation to matter.
	var maneuver_index := 1
	var maneuver_sector := int(red_meta[maneuver_index]["assigned_sector"])
	if maneuver_sector != TASK_HOLD and maneuver_sector != best_sector and red_last_order_elapsed[maneuver_index] >= RED_MANEUVER_RETASK_LOCK:
		if scores[best_sector] >= scores[maneuver_sector] + 0.70:
			_set_red_assignment(maneuver_index, best_sector, true)
			red_last_order_elapsed[maneuver_index] = 0.0
			enemy_event = "RED maneuver element shifted from %s to %s; BLUE coverage is being tested." % [SECTOR_NAMES[maneuver_sector], SECTOR_NAMES[best_sector]]

func _enemy_sector_score(sector: int) -> float:
	var blue_power := _friendly_power_in_sector(sector)
	var red_power := _red_power_in_sector(sector)
	var blue_control := maxf(0.0, sector_control[sector]) / 100.0
	var red_control := maxf(0.0, -sector_control[sector]) / 100.0
	var counter_need := maxf(0.0, blue_power - red_power) * 1.35 + blue_control * 1.15
	var exploit_opportunity := maxf(0.0, 0.85 - blue_power) * 0.65 + red_control * 0.45
	var uncovered_bonus := 0.18 if red_power <= 0.05 else 0.0
	return counter_need + exploit_opportunity + uncovered_bonus

func _red_power_in_sector(sector: int) -> float:
	var total := 0.0
	for index: int in range(red_agents.size()):
		if int(red_meta[index]["assigned_sector"]) != sector:
			continue
		var state := red_agents[index].state
		if not state.is_alive:
			continue
		var distance := state.position.distance_to(_red_target_for(index, sector))
		if distance <= 110.0:
			total += _state_power(state)
		elif distance <= 280.0:
			total += _state_power(state) * 0.35
	return total

func _set_red_assignment(index: int, sector: int, is_retask: bool) -> int:
	if index < 0 or index >= red_agents.size() or sector < 0 or sector >= SECTOR_COUNT:
		return 0
	var meta: Dictionary = red_meta[index]
	meta["assigned_sector"] = sector
	red_meta[index] = meta
	return _issue_red_sector_task(index, sector, is_retask)

func _recompute_sector_pressure() -> void:
	for sector: int in range(SECTOR_COUNT):
		sector_pressure[sector] = 0.38

	for index: int in range(red_agents.size()):
		var state := red_agents[index].state
		if not state.is_alive:
			continue
		var sector := int(red_meta[index]["assigned_sector"])
		if sector < 0 or sector >= SECTOR_COUNT:
			continue
		var distance := state.position.distance_to(_red_target_for(index, sector))
		var contribution := 0.08
		if distance <= 110.0:
			contribution = 0.82
		elif distance <= 280.0:
			contribution = 0.30
		sector_pressure[sector] += contribution * _state_power(state)

	if enemy_focus_sector >= 0 and enemy_focus_sector < SECTOR_COUNT:
		sector_pressure[enemy_focus_sector] += 0.12

	if support_active_sector >= 0 and support_active_sector < SECTOR_COUNT and support_remaining > 0.0:
		sector_pressure[support_active_sector] *= SUPPORT_PRESSURE_MULTIPLIER

func _update_intel(delta: float) -> void:
	super._update_intel(delta)
	if support_active_sector >= 0 and support_active_sector < SECTOR_COUNT and support_remaining > 0.0:
		sector_intel[support_active_sector] = maxf(sector_intel[support_active_sector], 0.92)

func _use_support(sector: int) -> bool:
	if battle_state != "RUNNING" or sector < 0 or sector >= SECTOR_COUNT:
		return false
	if support_charges <= 0 or support_cooldown > 0.0 or support_active_sector != TASK_HOLD:
		return false

	support_charges -= 1
	support_cooldown = SUPPORT_COOLDOWN_SECONDS
	support_active_sector = sector
	support_remaining = SUPPORT_DURATION_SECONDS
	support_pulse_accumulator = 0.0
	sector_intel[sector] = maxf(sector_intel[sector], 0.92)
	decision_count += 1
	command_event = "Commander fires committed to %s for %.0fs. %d mission(s) remain." % [SECTOR_NAMES[sector], SUPPORT_DURATION_SECONDS, support_charges]
	return true

func _update_support_state(delta: float) -> void:
	if support_cooldown > 0.0:
		support_cooldown = maxf(0.0, support_cooldown - delta)
	if support_active_sector == TASK_HOLD or support_remaining <= 0.0:
		return

	support_remaining = maxf(0.0, support_remaining - delta)
	support_pulse_accumulator += delta
	while support_pulse_accumulator >= SUPPORT_PULSE_SECONDS:
		support_pulse_accumulator -= SUPPORT_PULSE_SECONDS
		_apply_support_pulse(support_active_sector)

	if support_remaining <= 0.0:
		command_event = "Commander fires on %s ended. Remaining missions must be held for a later decision." % SECTOR_NAMES[support_active_sector]
		support_active_sector = TASK_HOLD
		support_pulse_accumulator = 0.0

func _apply_support_pulse(sector: int) -> void:
	sector_intel[sector] = maxf(sector_intel[sector], 0.92)
	for index: int in range(red_agents.size()):
		var state := red_agents[index].state
		if not state.is_alive or int(red_meta[index]["assigned_sector"]) != sector:
			continue
		if state.position.distance_to(SECTOR_POSITIONS[sector]) > 230.0:
			continue
		state.apply_damage(SUPPORT_DAMAGE_PER_PULSE)
		state.spend_ammo(1)

func _update_sector_trends(delta: float) -> void:
	trend_sample_clock -= delta
	if trend_sample_clock > 0.0:
		return
	_sample_sector_trends()
	trend_sample_clock = TREND_SAMPLE_SECONDS

func _sample_sector_trends() -> void:
	for sector: int in range(SECTOR_COUNT):
		var change := sector_control[sector] - last_control_sample[sector]
		var friendly := _friendly_power_in_sector(sector)
		var pressure := sector_pressure[sector]
		var trend := "CONTESTED"
		if change >= 6.0:
			trend = "GAINING"
		elif change <= -6.0:
			trend = "LOSING"
		elif pressure >= friendly + 0.35:
			trend = "UNDER PRESSURE"
		elif friendly >= pressure + 0.35:
			trend = "ADVANTAGE"
		sector_trends[sector] = trend
		last_control_sample[sector] = sector_control[sector]

func _build_ui() -> void:
	super._build_ui()
	var layer := CanvasLayer.new()
	layer.layer = 3
	add_child(layer)

	var panel := ColorRect.new()
	panel.color = Color(0.035, 0.045, 0.055, 0.96)
	panel.position = Vector2(MAP_WIDTH + 8.0, 714.0)
	panel.size = Vector2(344.0, 174.0)
	layer.add_child(panel)

	var box := VBoxContainer.new()
	box.position = Vector2(10.0, 8.0)
	box.size = Vector2(324.0, 156.0)
	box.add_theme_constant_override("separation", 5)
	panel.add_child(box)

	var header := Label.new()
	header.text = "COMMANDER SUPPORT — LIMITED"
	header.add_theme_font_size_override("font_size", 16)
	box.add_child(header)

	support_status_label = Label.new()
	support_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(support_status_label)

	var grid := GridContainer.new()
	grid.columns = 3
	box.add_child(grid)
	support_buttons.clear()
	for sector: int in range(SECTOR_COUNT):
		var button := Button.new()
		button.text = "FIRES %s" % SECTOR_NAMES[sector]
		button.custom_minimum_size = Vector2(102.0, 40.0)
		button.pressed.connect(_use_support.bind(sector))
		support_buttons.append(button)
		grid.add_child(button)

func _update_ui() -> void:
	super._update_ui()
	if situation_label == null:
		return

	var focus_name := SECTOR_NAMES[enemy_focus_sector] if enemy_focus_sector >= 0 and enemy_focus_sector < SECTOR_COUNT else "UNKNOWN"
	situation_label.text = "T+%03ds  |  RED focus %s  |  reserve %s  |  fires %d/%d  |  player decisions %d" % [int(elapsed), focus_name, "COMMITTED" if red_reserve_committed else "UNCOMMITTED", support_charges, SUPPORT_MAX_CHARGES, decision_count]

	var sector_lines: Array[String] = []
	for sector: int in range(SECTOR_COUNT):
		sector_lines.append("%s  %s  | contact %s | intel %d%% | control %+d" % [SECTOR_NAMES[sector], sector_trends[sector], _pressure_readout(sector), int(sector_intel[sector] * 100.0), int(sector_control[sector])])
	sector_status_label.text = "BATTLEFIELD TREND\n" + "\n".join(sector_lines)

	if support_status_label != null:
		var active_text := "none"
		if support_active_sector >= 0 and support_active_sector < SECTOR_COUNT:
			active_text = "%s %.1fs" % [SECTOR_NAMES[support_active_sector], support_remaining]
		support_status_label.text = "Missions %d/%d | cooldown %.0fs | active %s\nCommit now for suppression + contact certainty, or preserve the mission for a later shift." % [support_charges, SUPPORT_MAX_CHARGES, support_cooldown, active_text]
		for button: Button in support_buttons:
			button.disabled = battle_state != "RUNNING" or support_charges <= 0 or support_cooldown > 0.0 or support_active_sector != TASK_HOLD

func _draw() -> void:
	super._draw()
	if enemy_focus_sector >= 0 and enemy_focus_sector < SECTOR_COUNT:
		draw_arc(SECTOR_POSITIONS[enemy_focus_sector], 104.0, 0.0, TAU, 48, Color(0.95, 0.34, 0.18, 0.78), 3.0)
	if support_active_sector >= 0 and support_active_sector < SECTOR_COUNT and support_remaining > 0.0:
		draw_arc(SECTOR_POSITIONS[support_active_sector], 132.0, 0.0, TAU, 48, Color(0.95, 0.82, 0.30, 0.92), 5.0)

func debug_force_enemy_reassess() -> void:
	for index: int in range(red_last_order_elapsed.size()):
		red_last_order_elapsed[index] = maxf(red_last_order_elapsed[index], RED_MANEUVER_RETASK_LOCK + 1.0)
	_enemy_reassess()
	_recompute_sector_pressure()

func debug_use_support(sector: int) -> bool:
	return _use_support(sector)

func debug_force_support_tick(delta: float) -> void:
	_update_support_state(delta)
	_recompute_sector_pressure()

func debug_force_trend_sample() -> void:
	_sample_sector_trends()

func debug_representative_snapshot() -> Dictionary:
	var snapshot := debug_snapshot()
	var red_tasks: Array[int] = []
	for meta: Dictionary in red_meta:
		red_tasks.append(int(meta["assigned_sector"]))
	snapshot.merge({
		"enemy_commander_mode": ENEMY_COMMANDER_MODE,
		"enemy_focus_sector": enemy_focus_sector,
		"red_reserve_committed": red_reserve_committed,
		"red_tasks": red_tasks,
		"support_charges": support_charges,
		"support_cooldown": support_cooldown,
		"support_active_sector": support_active_sector,
		"support_remaining": support_remaining,
		"sector_trends": sector_trends.duplicate(),
	}, true)
	return snapshot
