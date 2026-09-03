class_name PrototypeBCommandBattle
extends Node2D

const TASK_HOLD: int = -1
const SECTOR_RIDGE: int = 0
const SECTOR_CROSSING: int = 1
const SECTOR_RELAY: int = 2
const SECTOR_COUNT: int = 3
const BLUE_COUNT: int = 5
const RED_COUNT: int = 3
const RESERVE_INDEX: int = 4
const MAP_WIDTH: float = 1240.0
const MAP_HEIGHT: float = 900.0
const FORMATION_SPEED: float = 112.0
const RED_FORMATION_SPEED: float = 96.0
const RESERVE_STABLE_RETURN_SECONDS: float = 8.0
const OUTCOME_CHECK_START: float = 82.0
const PHASE_SECONDS: float = 14.0
const MOBILITY_GROUND: StringName = &"GROUND"

const SECTOR_NAMES: Array[String] = ["RIDGE", "CROSSING", "RELAY"]
const SECTOR_POSITIONS: Array[Vector2] = [
	Vector2(270.0, 355.0),
	Vector2(610.0, 320.0),
	Vector2(950.0, 370.0),
]
const BLUE_STAGING_POSITIONS: Array[Vector2] = [
	Vector2(235.0, 720.0),
	Vector2(440.0, 730.0),
	Vector2(650.0, 735.0),
	Vector2(855.0, 730.0),
	Vector2(1060.0, 760.0),
]
const RED_STAGING_POSITIONS: Array[Vector2] = [
	Vector2(250.0, 185.0),
	Vector2(610.0, 175.0),
	Vector2(970.0, 185.0),
]
const PRESSURE_PROFILES: Array = [
	[1.55, 1.00, 0.75],
	[0.85, 1.85, 1.00],
	[1.00, 1.20, 1.90],
	[1.55, 1.45, 0.95],
	[0.95, 1.70, 1.60],
	[1.40, 1.30, 1.45],
]
const ENEMY_PHASE_TASKS: Array = [
	[SECTOR_RIDGE, SECTOR_RIDGE, SECTOR_CROSSING],
	[SECTOR_CROSSING, SECTOR_CROSSING, SECTOR_RELAY],
	[SECTOR_RELAY, SECTOR_RELAY, SECTOR_CROSSING],
	[SECTOR_RIDGE, SECTOR_CROSSING, SECTOR_RIDGE],
	[SECTOR_CROSSING, SECTOR_RELAY, SECTOR_RELAY],
	[SECTOR_RIDGE, SECTOR_CROSSING, SECTOR_RELAY],
]
const PHASE_NAMES: Array[String] = [
	"Enemy pressure building on RIDGE",
	"Enemy shifts weight toward CROSSING",
	"Enemy probes RELAY in strength",
	"Enemy counter-pushes RIDGE and CROSSING",
	"Enemy stretches pressure across CROSSING and RELAY",
	"Enemy broad-front pressure",
]

var navigation: NavigationService
var command_service: TaskCommandService
var blue_agents: Array[FormationAgent2D] = []
var red_agents: Array[FormationAgent2D] = []
var blue_meta: Array[Dictionary] = []
var red_meta: Array[Dictionary] = []

var sector_pressure: Array[float] = [1.55, 1.00, 0.75]
var sector_control: Array[float] = [0.0, 0.0, 0.0]
var sector_intel: Array[float] = [0.42, 0.35, 0.28]
var selected_formation: int = 0
var elapsed: float = 0.0
var decision_count: int = 0
var reserve_stable_time: float = 0.0
var phase_index: int = 0
var previous_phase_index: int = -1
var battle_state: String = "RUNNING"
var command_event: String = "Initial tasks are active. Read the battlefield before moving the reserve."
var enemy_event: String = "Enemy activity is developing across three objectives."
var core_command_count: int = 0

var blue_ammo_accumulator: Array[float] = []
var blue_damage_accumulator: Array[float] = []
var blue_health_recovery_accumulator: Array[float] = []
var blue_ammo_recovery_accumulator: Array[float] = []
var red_ammo_accumulator: Array[float] = []
var red_damage_accumulator: Array[float] = []

var situation_label: Label
var selected_label: Label
var formation_status_label: Label
var sector_status_label: Label
var event_label: Label
var outcome_label: Label
var task_buttons: Array[Button] = []
var hold_button: Button

func _ready() -> void:
	_configure_core_runtime()
	_spawn_forces()
	_issue_initial_commands()
	_build_ui()
	_update_ui()
	queue_redraw()
	print("FRONTLINE_PROTOTYPE_B_CORE_CONSUMER_READY blue=%d red=%d sectors=%d shared_task_service=YES" % [blue_agents.size(), red_agents.size(), SECTOR_COUNT])
	print("FRONTLINE_PROTOTYPE_B_ENEMY_COMMAND_PATH task_service=YES")

func _process(delta: float) -> void:
	if battle_state != "RUNNING":
		_update_ui()
		queue_redraw()
		return

	elapsed += delta
	_update_enemy_activity()
	_recompute_sector_pressure()
	_update_intel(delta)
	_update_blue_recovery(delta)
	_update_sector_battle(delta)
	_update_reserve_recovery(delta)
	_check_outcome()
	_update_ui()
	queue_redraw()

func _configure_core_runtime() -> void:
	navigation = NavigationService.new()
	var profiles: Array[StringName] = [MOBILITY_GROUND]
	var blocked_query := func(_world_point: Vector2, _profile: StringName) -> bool:
		return false
	navigation.configure(Vector2(MAP_WIDTH, MAP_HEIGHT), Vector2(40.0, 40.0), profiles, blocked_query, 8)

	command_service = TaskCommandService.new()
	command_service.name = "TaskCommandService"
	add_child(command_service)
	command_service.command_issued.connect(_on_core_command_issued)

func _spawn_forces() -> void:
	blue_agents.clear()
	red_agents.clear()
	blue_meta.clear()
	red_meta.clear()
	blue_ammo_accumulator.clear()
	blue_damage_accumulator.clear()
	blue_health_recovery_accumulator.clear()
	blue_ammo_recovery_accumulator.clear()
	red_ammo_accumulator.clear()
	red_damage_accumulator.clear()

	var blue_names: Array[String] = ["ALPHA", "BRAVO", "CHARLIE", "DELTA", "ECHO"]
	var initial_sectors: Array[int] = [SECTOR_RIDGE, SECTOR_CROSSING, SECTOR_RELAY, SECTOR_CROSSING, TASK_HOLD]
	for index: int in range(BLUE_COUNT):
		var agent := FormationAgent2D.new()
		agent.name = "Blue%s" % blue_names[index]
		add_child(agent)
		agent.configure(
			StringName(blue_names[index]),
			blue_names[index],
			&"BLUE",
			BLUE_STAGING_POSITIONS[index],
			FORMATION_SPEED,
			100,
			100,
			MOBILITY_GROUND
		)
		agent.set_navigation_service(navigation)
		blue_agents.append(agent)
		blue_meta.append({
			"assigned_sector": initial_sectors[index],
			"reserve": index == RESERVE_INDEX,
			"committed": index != RESERVE_INDEX,
			"auto_withdraw": false,
			"manual_recover": false,
			"returning_reserve": false,
		})
		blue_ammo_accumulator.append(0.0)
		blue_damage_accumulator.append(0.0)
		blue_health_recovery_accumulator.append(0.0)
		blue_ammo_recovery_accumulator.append(0.0)

	for index: int in range(RED_COUNT):
		var agent := FormationAgent2D.new()
		var display_name := "RED-%d" % (index + 1)
		agent.name = display_name
		add_child(agent)
		agent.configure(
			StringName(display_name),
			display_name,
			&"RED",
			RED_STAGING_POSITIONS[index],
			RED_FORMATION_SPEED,
			100,
			100,
			MOBILITY_GROUND
		)
		agent.set_navigation_service(navigation)
		red_agents.append(agent)
		red_meta.append({"assigned_sector": TASK_HOLD})
		red_ammo_accumulator.append(0.0)
		red_damage_accumulator.append(0.0)

func _issue_initial_commands() -> void:
	for index: int in range(BLUE_COUNT - 1):
		_issue_blue_sector_task(index, int(blue_meta[index]["assigned_sector"]), false)
	command_service.cancel([blue_agents[RESERVE_INDEX]])
	_apply_enemy_phase(0, true)
	previous_phase_index = 0

func _issue_blue_sector_task(index: int, sector: int, is_retask: bool) -> int:
	if index < 0 or index >= blue_agents.size() or sector < 0 or sector >= SECTOR_COUNT:
		return 0
	var task := FormationTask.assign_to(_blue_target_for(index, sector), StringName(SECTOR_NAMES[sector]), 5)
	return command_service.retask([blue_agents[index]], task) if is_retask else command_service.assign([blue_agents[index]], task)

func _issue_red_sector_task(index: int, sector: int, is_retask: bool) -> int:
	if index < 0 or index >= red_agents.size() or sector < 0 or sector >= SECTOR_COUNT:
		return 0
	var task := FormationTask.assign_to(_red_target_for(index, sector), StringName(SECTOR_NAMES[sector]), 4)
	return command_service.retask([red_agents[index]], task) if is_retask else command_service.assign([red_agents[index]], task)

func _update_enemy_activity() -> void:
	var next_phase: int = int(elapsed / PHASE_SECONDS) % PRESSURE_PROFILES.size()
	if next_phase != phase_index:
		phase_index = next_phase
	if phase_index != previous_phase_index:
		_apply_enemy_phase(phase_index, false)
		previous_phase_index = phase_index

func _apply_enemy_phase(next_phase: int, initial: bool) -> void:
	phase_index = clampi(next_phase, 0, ENEMY_PHASE_TASKS.size() - 1)
	var phase_tasks: Array = ENEMY_PHASE_TASKS[phase_index]
	for index: int in range(red_agents.size()):
		var sector := int(phase_tasks[index])
		var meta: Dictionary = red_meta[index]
		meta["assigned_sector"] = sector
		red_meta[index] = meta
		_issue_red_sector_task(index, sector, not initial)
	enemy_event = PHASE_NAMES[phase_index]

func _recompute_sector_pressure() -> void:
	var profile: Array = PRESSURE_PROFILES[phase_index]
	for sector: int in range(SECTOR_COUNT):
		sector_pressure[sector] = 0.34 + float(profile[sector]) * 0.34

	for index: int in range(red_agents.size()):
		var agent := red_agents[index]
		if not agent.state.is_alive:
			continue
		var sector := int(red_meta[index]["assigned_sector"])
		if sector < 0 or sector >= SECTOR_COUNT:
			continue
		if agent.state.position.distance_to(_red_target_for(index, sector)) <= 92.0:
			sector_pressure[sector] += 0.62 * _state_power(agent.state)

func _update_intel(delta: float) -> void:
	for sector: int in range(SECTOR_COUNT):
		var friendly_near := false
		for agent: FormationAgent2D in blue_agents:
			if agent.state.is_alive and agent.state.position.distance_to(SECTOR_POSITIONS[sector]) <= 165.0:
				friendly_near = true
				break
		if friendly_near:
			sector_intel[sector] = clampf(sector_intel[sector] + delta * 0.060, 0.15, 1.0)
		else:
			sector_intel[sector] = clampf(sector_intel[sector] - delta * 0.018, 0.15, 1.0)

func _update_blue_recovery(delta: float) -> void:
	for index: int in range(blue_agents.size()):
		var agent := blue_agents[index]
		var state := agent.state
		if not state.is_alive:
			continue
		var meta: Dictionary = blue_meta[index]
		var auto_withdraw := bool(meta["auto_withdraw"])
		var assigned_sector := int(meta["assigned_sector"])

		if not auto_withdraw and assigned_sector != TASK_HOLD and (state.current_hp <= 43 or state.current_ammo <= 14):
			meta["auto_withdraw"] = true
			meta["manual_recover"] = false
			meta["returning_reserve"] = false
			blue_meta[index] = meta
			command_service.retask([agent], FormationTask.move_to(BLUE_STAGING_POSITIONS[index], 100))
			command_event = "%s is autonomously falling back to recover; its assigned sector remains in force." % state.display_name
			auto_withdraw = true

		if auto_withdraw:
			if state.position.distance_to(BLUE_STAGING_POSITIONS[index]) <= 18.0:
				_recover_blue_state(index, delta, 6.0, 9.5)
				if state.current_hp >= 72 and state.current_ammo >= 72:
					meta = blue_meta[index]
					meta["auto_withdraw"] = false
					blue_meta[index] = meta
					if int(meta["assigned_sector"]) != TASK_HOLD:
						_issue_blue_sector_task(index, int(meta["assigned_sector"]), true)
						command_event = "%s has recovered and is autonomously resuming %s." % [state.display_name, SECTOR_NAMES[int(meta["assigned_sector"])] ]
					else:
						command_service.cancel([agent])
			continue

		if bool(meta["manual_recover"]) or bool(meta["returning_reserve"]):
			if state.position.distance_to(BLUE_STAGING_POSITIONS[index]) <= 18.0:
				command_service.cancel([agent])
				meta["manual_recover"] = false
				meta["returning_reserve"] = false
				blue_meta[index] = meta
				_recover_blue_state(index, delta, 2.4, 5.5)
			continue

		if assigned_sector == TASK_HOLD:
			_recover_blue_state(index, delta, 2.4, 5.5)

func _recover_blue_state(index: int, delta: float, health_rate: float, ammo_rate: float) -> void:
	var state := blue_agents[index].state
	blue_health_recovery_accumulator[index] += delta * health_rate
	blue_ammo_recovery_accumulator[index] += delta * ammo_rate
	var health_points := int(floor(blue_health_recovery_accumulator[index]))
	var ammo_points := int(floor(blue_ammo_recovery_accumulator[index]))
	if health_points > 0:
		state.restore_health(health_points)
		blue_health_recovery_accumulator[index] -= float(health_points)
	if ammo_points > 0:
		state.restore_ammo(ammo_points)
		blue_ammo_recovery_accumulator[index] -= float(ammo_points)

func _update_sector_battle(delta: float) -> void:
	var friendly_power: Array[float] = [0.0, 0.0, 0.0]
	var blue_present: Array = [[], [], []]
	var red_present: Array = [[], [], []]

	for index: int in range(blue_agents.size()):
		var meta: Dictionary = blue_meta[index]
		if bool(meta["auto_withdraw"]):
			continue
		var sector := int(meta["assigned_sector"])
		if sector == TASK_HOLD:
			continue
		var agent := blue_agents[index]
		if not agent.state.is_alive or agent.state.position.distance_to(_blue_target_for(index, sector)) > 68.0:
			continue
		friendly_power[sector] += _state_power(agent.state)
		blue_present[sector].append(index)

	for index: int in range(red_agents.size()):
		var sector := int(red_meta[index]["assigned_sector"])
		var agent := red_agents[index]
		if sector < 0 or not agent.state.is_alive:
			continue
		if agent.state.position.distance_to(_red_target_for(index, sector)) <= 92.0:
			red_present[sector].append(index)

	for sector: int in range(SECTOR_COUNT):
		var balance := friendly_power[sector] - sector_pressure[sector]
		if balance >= 0.0:
			sector_control[sector] = clampf(sector_control[sector] + delta * (3.0 + balance * 5.5), -100.0, 100.0)
		else:
			sector_control[sector] = clampf(sector_control[sector] + delta * balance * 6.5, -100.0, 100.0)

		var friendly_indices: Array = blue_present[sector]
		if not friendly_indices.is_empty():
			var pressure_share := sector_pressure[sector] / float(friendly_indices.size())
			for formation_index_value: Variant in friendly_indices:
				var formation_index := int(formation_index_value)
				_apply_blue_attrition(formation_index, pressure_share, delta)

		var enemy_indices: Array = red_present[sector]
		if not enemy_indices.is_empty() and friendly_power[sector] > 0.0:
			var friendly_share := friendly_power[sector] / float(enemy_indices.size())
			for enemy_index_value: Variant in enemy_indices:
				_apply_red_attrition(int(enemy_index_value), friendly_share, delta)

func _apply_blue_attrition(index: int, pressure_share: float, delta: float) -> void:
	var state := blue_agents[index].state
	if not state.is_alive:
		return
	blue_ammo_accumulator[index] += delta * (1.0 + pressure_share * 0.9)
	var ammo_points := int(floor(blue_ammo_accumulator[index]))
	if ammo_points > 0:
		var spend := mini(ammo_points, state.current_ammo)
		if spend > 0:
			state.spend_ammo(spend)
		blue_ammo_accumulator[index] -= float(ammo_points)

	if pressure_share > 0.95:
		blue_damage_accumulator[index] += delta * (pressure_share - 0.75) * 1.35
		var damage_points := int(floor(blue_damage_accumulator[index]))
		if damage_points > 0:
			var allowed_damage := maxi(0, state.current_hp - 34)
			state.apply_damage(mini(damage_points, allowed_damage))
			blue_damage_accumulator[index] -= float(damage_points)

func _apply_red_attrition(index: int, friendly_share: float, delta: float) -> void:
	var state := red_agents[index].state
	if not state.is_alive:
		return
	red_ammo_accumulator[index] += delta * (0.45 + friendly_share * 0.7)
	var ammo_points := int(floor(red_ammo_accumulator[index]))
	if ammo_points > 0:
		var spend := mini(ammo_points, state.current_ammo)
		if spend > 0:
			state.spend_ammo(spend)
		red_ammo_accumulator[index] -= float(ammo_points)

	if friendly_share > 0.55:
		red_damage_accumulator[index] += delta * (friendly_share - 0.45) * 0.65
		var damage_points := int(floor(red_damage_accumulator[index]))
		if damage_points > 0:
			state.apply_damage(damage_points)
			red_damage_accumulator[index] -= float(damage_points)

func _update_reserve_recovery(delta: float) -> void:
	var meta: Dictionary = blue_meta[RESERVE_INDEX]
	if not bool(meta["committed"]):
		reserve_stable_time = 0.0
		return
	if bool(meta["auto_withdraw"]):
		reserve_stable_time = 0.0
		return
	var sector := int(meta["assigned_sector"])
	if sector == TASK_HOLD:
		return
	var balance := _friendly_power_in_sector(sector) - sector_pressure[sector]
	if sector_control[sector] >= 38.0 and balance >= 0.18:
		reserve_stable_time += delta
	else:
		reserve_stable_time = 0.0
	if reserve_stable_time >= RESERVE_STABLE_RETURN_SECONDS:
		meta["assigned_sector"] = TASK_HOLD
		meta["committed"] = false
		meta["auto_withdraw"] = false
		meta["returning_reserve"] = true
		blue_meta[RESERVE_INDEX] = meta
		command_service.retask([blue_agents[RESERVE_INDEX]], FormationTask.move_to(BLUE_STAGING_POSITIONS[RESERVE_INDEX], 20))
		reserve_stable_time = 0.0
		command_event = "ECHO has stabilized %s and is autonomously returning to reserve." % SECTOR_NAMES[sector]

func _friendly_power_in_sector(sector: int) -> float:
	var total := 0.0
	for index: int in range(blue_agents.size()):
		var meta: Dictionary = blue_meta[index]
		if bool(meta["auto_withdraw"]) or int(meta["assigned_sector"]) != sector:
			continue
		var agent := blue_agents[index]
		if agent.state.is_alive and agent.state.position.distance_to(_blue_target_for(index, sector)) <= 68.0:
			total += _state_power(agent.state)
	return total

func _state_power(state: FormationState) -> float:
	if state == null or not state.is_alive:
		return 0.0
	var hp_ratio := float(state.current_hp) / float(state.max_hp)
	var ammo_ratio := 0.0 if state.ammo_capacity <= 0 else float(state.current_ammo) / float(state.ammo_capacity)
	return hp_ratio * lerpf(0.55, 1.0, ammo_ratio)

func _blue_target_for(index: int, sector: int) -> Vector2:
	var offsets: Array[Vector2] = [
		Vector2(-34.0, 36.0),
		Vector2(-28.0, 42.0),
		Vector2(30.0, 34.0),
		Vector2(34.0, 64.0),
		Vector2(0.0, 86.0),
	]
	return SECTOR_POSITIONS[sector] + offsets[index]

func _red_target_for(index: int, sector: int) -> Vector2:
	var offsets: Array[Vector2] = [Vector2(-52.0, -52.0), Vector2(0.0, -72.0), Vector2(52.0, -52.0)]
	return SECTOR_POSITIONS[sector] + offsets[index]

func _assign_selected_task(task: int) -> void:
	if battle_state != "RUNNING":
		return
	var agent := blue_agents[selected_formation]
	var meta: Dictionary = blue_meta[selected_formation]
	var is_reserve := bool(meta["reserve"])
	var committed := bool(meta["committed"])
	if is_reserve and committed:
		command_event = "ECHO is already committed. Stabilize its current sector before it returns to reserve."
		return
	if is_reserve and task == TASK_HOLD:
		command_event = "ECHO remains uncommitted and available."
		return

	var previous_task := int(meta["assigned_sector"])
	if previous_task == task and not bool(meta["auto_withdraw"]):
		return

	var accepted := 0
	if task == TASK_HOLD:
		accepted = command_service.retask([agent], FormationTask.move_to(BLUE_STAGING_POSITIONS[selected_formation], 5))
		if accepted > 0:
			meta["assigned_sector"] = TASK_HOLD
			meta["auto_withdraw"] = false
			meta["manual_recover"] = true
			meta["returning_reserve"] = false
	else:
		var core_task := FormationTask.assign_to(_blue_target_for(selected_formation, task), StringName(SECTOR_NAMES[task]), 5)
		accepted = command_service.assign([agent], core_task) if previous_task == TASK_HOLD else command_service.retask([agent], core_task)
		if accepted > 0:
			meta["assigned_sector"] = task
			meta["auto_withdraw"] = false
			meta["manual_recover"] = false
			meta["returning_reserve"] = false
			if is_reserve:
				meta["committed"] = true
				reserve_stable_time = 0.0

	if accepted <= 0:
		command_event = "%s could not accept the requested task." % agent.state.display_name
		return

	blue_meta[selected_formation] = meta
	decision_count += 1
	if is_reserve:
		command_event = "ECHO committed to %s. It now executes through the common Core task contract." % _task_name(task)
	elif task == TASK_HOLD:
		command_event = "%s released from %s and returning to recover." % [agent.state.display_name, _task_name(previous_task)]
	else:
		command_event = "%s retasked from %s to %s. Local movement remains Core-autonomous." % [agent.state.display_name, _task_name(previous_task), _task_name(task)]

func _select_formation(index: int) -> void:
	selected_formation = clampi(index, 0, blue_agents.size() - 1)
	_update_ui()

func _task_name(task: int) -> String:
	return "HOLD" if task == TASK_HOLD else SECTOR_NAMES[task]

func _pressure_readout(sector: int) -> String:
	var intel := sector_intel[sector]
	var pressure := sector_pressure[sector]
	if intel < 0.38:
		return "CONTACT UNCERTAIN"
	var band := "LOW"
	if pressure >= 1.65:
		band = "HIGH"
	elif pressure >= 1.20:
		band = "MEDIUM"
	return "%s (EST.)" % band if intel < 0.72 else "%s %.2f" % [band, pressure]

func _check_outcome() -> void:
	if sector_control.min() <= -96.0:
		_set_battle_state("DEFEAT", "A sector collapsed before the force could recover.")
		return
	var exhausted := 0
	for agent: FormationAgent2D in blue_agents:
		if not agent.state.is_alive or agent.state.current_hp <= 36:
			exhausted += 1
	if exhausted >= 3:
		_set_battle_state("DEFEAT", "Too much combat power became ineffective at the same time.")
		return
	if elapsed >= OUTCOME_CHECK_START:
		var control_sum := sector_control[0] + sector_control[1] + sector_control[2]
		if control_sum >= 95.0 and sector_control.min() > -25.0:
			_set_battle_state("VICTORY", "The force has retained initiative across all three objectives.")

func _set_battle_state(next_state: String, message: String) -> void:
	battle_state = next_state
	command_event = message
	for agent: FormationAgent2D in blue_agents:
		agent.set_process(false)
	for agent: FormationAgent2D in red_agents:
		agent.set_process(false)

func _restart() -> void:
	get_tree().reload_current_scene()

func _on_core_command_issued(_operation: StringName, _formations: Array, _task: FormationTask, _accepted_count: int) -> void:
	core_command_count += 1

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	var top_panel := ColorRect.new()
	top_panel.color = Color(0.035, 0.050, 0.060, 0.95)
	top_panel.position = Vector2(18.0, 16.0)
	top_panel.size = Vector2(1188.0, 132.0)
	layer.add_child(top_panel)

	var top_box := VBoxContainer.new()
	top_box.position = Vector2(15.0, 10.0)
	top_box.size = Vector2(1155.0, 112.0)
	top_panel.add_child(top_box)

	var title := Label.new()
	title.text = "PROTOTYPE B — REPRESENTATIVE COMMAND BATTLE / RTS CORE V1"
	title.add_theme_font_size_override("font_size", 20)
	top_box.add_child(title)

	var rule := Label.new()
	rule.text = "Read changing contacts → assign/retask formations → Core executes locally → commit or preserve ECHO reserve → respond to enemy retasking. BLUE and RED use the same task-command path."
	rule.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	top_box.add_child(rule)

	situation_label = Label.new()
	situation_label.add_theme_font_size_override("font_size", 17)
	top_box.add_child(situation_label)

	var side_panel := ColorRect.new()
	side_panel.color = Color(0.050, 0.062, 0.075, 0.98)
	side_panel.position = Vector2(MAP_WIDTH, 0.0)
	side_panel.size = Vector2(360.0, 900.0)
	layer.add_child(side_panel)

	var side_box := VBoxContainer.new()
	side_box.position = Vector2(14.0, 18.0)
	side_box.size = Vector2(332.0, 864.0)
	side_box.add_theme_constant_override("separation", 7)
	side_panel.add_child(side_box)

	var select_header := Label.new()
	select_header.text = "SELECT FORMATION"
	select_header.add_theme_font_size_override("font_size", 17)
	side_box.add_child(select_header)

	var select_grid := GridContainer.new()
	select_grid.columns = 3
	side_box.add_child(select_grid)
	for index: int in range(blue_agents.size()):
		var button := Button.new()
		button.text = blue_agents[index].state.display_name
		button.custom_minimum_size = Vector2(100.0, 38.0)
		button.pressed.connect(_select_formation.bind(index))
		select_grid.add_child(button)

	selected_label = Label.new()
	selected_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	side_box.add_child(selected_label)

	var task_header := Label.new()
	task_header.text = "ASSIGN / RETASK"
	task_header.add_theme_font_size_override("font_size", 17)
	side_box.add_child(task_header)

	task_buttons.clear()
	for sector: int in range(SECTOR_COUNT):
		var task_button := Button.new()
		task_button.text = "TASK: %s" % SECTOR_NAMES[sector]
		task_button.custom_minimum_size = Vector2(0.0, 38.0)
		task_button.pressed.connect(_assign_selected_task.bind(sector))
		task_buttons.append(task_button)
		side_box.add_child(task_button)

	hold_button = Button.new()
	hold_button.text = "HOLD / RECOVER"
	hold_button.custom_minimum_size = Vector2(0.0, 38.0)
	hold_button.pressed.connect(_assign_selected_task.bind(TASK_HOLD))
	side_box.add_child(hold_button)

	sector_status_label = Label.new()
	sector_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sector_status_label.custom_minimum_size = Vector2(0.0, 124.0)
	side_box.add_child(sector_status_label)

	formation_status_label = Label.new()
	formation_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	formation_status_label.custom_minimum_size = Vector2(0.0, 170.0)
	side_box.add_child(formation_status_label)

	event_label = Label.new()
	event_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	event_label.custom_minimum_size = Vector2(0.0, 92.0)
	side_box.add_child(event_label)

	outcome_label = Label.new()
	outcome_label.add_theme_font_size_override("font_size", 18)
	outcome_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	side_box.add_child(outcome_label)

	var restart_button := Button.new()
	restart_button.text = "RESTART CORE BATTLE"
	restart_button.custom_minimum_size = Vector2(0.0, 42.0)
	restart_button.pressed.connect(_restart)
	side_box.add_child(restart_button)

func _update_ui() -> void:
	if situation_label == null or blue_agents.is_empty():
		return
	var phase_remaining := PHASE_SECONDS - fmod(elapsed, PHASE_SECONDS)
	situation_label.text = "T+%03ds  |  %s  |  next pressure shift ~%.0fs  |  player decisions %d" % [int(elapsed), PHASE_NAMES[phase_index], phase_remaining, decision_count]

	var selected_agent := blue_agents[selected_formation]
	var selected_meta: Dictionary = blue_meta[selected_formation]
	selected_label.text = "Selected %s — assigned %s — Core %s" % [selected_agent.state.display_name, _task_name(int(selected_meta["assigned_sector"])), selected_agent.state.execution_state]
	var selected_is_reserve := bool(selected_meta["reserve"])
	for sector: int in range(task_buttons.size()):
		task_buttons[sector].text = ("COMMIT ECHO: %s" if selected_is_reserve else "TASK: %s") % SECTOR_NAMES[sector]
	hold_button.disabled = selected_is_reserve and bool(selected_meta["committed"])

	var sector_lines: Array[String] = []
	for sector: int in range(SECTOR_COUNT):
		sector_lines.append("%s  contact %s  intel %d%%  control %+d" % [SECTOR_NAMES[sector], _pressure_readout(sector), int(sector_intel[sector] * 100.0), int(sector_control[sector])])
	sector_status_label.text = "BATTLEFIELD\n" + "\n".join(sector_lines)

	var formation_lines: Array[String] = []
	for index: int in range(blue_agents.size()):
		var agent := blue_agents[index]
		var meta: Dictionary = blue_meta[index]
		var reserve_tag := " [RESERVE]" if index == RESERVE_INDEX and not bool(meta["committed"]) else ""
		var fallback_tag := " AUTO-FALLBACK" if bool(meta["auto_withdraw"]) else ""
		formation_lines.append("%s%s  %s  H%02d A%02d%s" % [agent.state.display_name, reserve_tag, _task_name(int(meta["assigned_sector"])), agent.state.current_hp, agent.state.current_ammo, fallback_tag])
	formation_status_label.text = "FORMATIONS\n" + "\n".join(formation_lines)

	event_label.text = "ENEMY: %s\nCOMMAND: %s" % [enemy_event, command_event]
	outcome_label.text = "BATTLE STATE: %s" % battle_state

func _draw() -> void:
	draw_rect(Rect2(0.0, 0.0, MAP_WIDTH, MAP_HEIGHT), Color(0.075, 0.095, 0.095), true)
	draw_rect(Rect2(55.0, 165.0, 1130.0, 650.0), Color(0.165, 0.195, 0.165), true)

	for sector: int in range(SECTOR_COUNT):
		var pos := SECTOR_POSITIONS[sector]
		var pressure_radius := 42.0 + sector_pressure[sector] * 18.0
		var intel_alpha := lerpf(0.20, 0.55, sector_intel[sector])
		draw_circle(pos, pressure_radius, Color(0.44, 0.09, 0.08, intel_alpha))
		draw_arc(pos, pressure_radius, 0.0, TAU, 48, Color(0.94, 0.30, 0.24, 0.45 + sector_intel[sector] * 0.45), 4.0)
		var control_normalized := clampf((sector_control[sector] + 100.0) / 200.0, 0.0, 1.0)
		draw_rect(Rect2(pos.x - 92.0, pos.y + 112.0, 184.0, 12.0), Color(0.12, 0.13, 0.13), true)
		draw_rect(Rect2(pos.x - 92.0, pos.y + 112.0, 184.0 * control_normalized, 12.0), Color(0.25, 0.66, 0.88), true)

	for index: int in range(blue_agents.size()):
		var agent := blue_agents[index]
		var meta: Dictionary = blue_meta[index]
		var color := Color(0.20, 0.70, 0.95)
		if index == 1:
			color = Color(0.28, 0.58, 0.96)
		elif index == 2:
			color = Color(0.30, 0.82, 0.76)
		elif index == 3:
			color = Color(0.44, 0.66, 0.96)
		elif index == RESERVE_INDEX:
			color = Color(0.96, 0.77, 0.20) if not bool(meta["committed"]) else Color(0.34, 0.86, 0.62)
		if bool(meta["auto_withdraw"]):
			color = color.darkened(0.38)
		draw_circle(agent.state.position, 20.0, color)
		draw_arc(agent.state.position, 27.0, 0.0, TAU, 32, Color.WHITE if index == selected_formation else Color(0.08, 0.12, 0.14), 3.0)

	for index: int in range(red_agents.size()):
		var agent := red_agents[index]
		if not agent.state.is_alive:
			continue
		var sector := int(red_meta[index]["assigned_sector"])
		var visibility := sector_intel[sector] if sector >= 0 else 0.2
		if visibility < 0.30:
			continue
		var red_color := Color(0.86, 0.23, 0.18, lerpf(0.28, 0.88, visibility))
		draw_rect(Rect2(agent.state.position - Vector2(11.0, 11.0), Vector2(22.0, 22.0)), red_color, true)

func debug_select_formation(index: int) -> void:
	_select_formation(index)

func debug_assign_task(task: int) -> void:
	_assign_selected_task(task)

func debug_force_enemy_phase(next_phase: int) -> void:
	_apply_enemy_phase(next_phase, false)
	previous_phase_index = phase_index
	_recompute_sector_pressure()

func debug_snapshot() -> Dictionary:
	var red_tasks: Array[int] = []
	for meta: Dictionary in red_meta:
		red_tasks.append(int(meta["assigned_sector"]))
	return {
		"formation_count": blue_agents.size(),
		"enemy_formation_count": red_agents.size(),
		"sector_count": SECTOR_COUNT,
		"decision_count": decision_count,
		"reserve_committed": bool(blue_meta[RESERVE_INDEX]["committed"]),
		"reserve_task": int(blue_meta[RESERVE_INDEX]["assigned_sector"]),
		"alpha_task": int(blue_meta[0]["assigned_sector"]),
		"charlie_task": int(blue_meta[2]["assigned_sector"]),
		"battle_state": battle_state,
		"phase_index": phase_index,
		"red_tasks": red_tasks,
		"core_consumer": _core_runtime_valid(),
		"shared_task_command_service": command_service != null,
		"command_revision": command_service.get_command_revision() if command_service != null else -1,
		"core_command_count": core_command_count,
		"enemy_command_path": "TASK_COMMAND_SERVICE",
	}

func debug_get_blue_agent(index: int) -> FormationAgent2D:
	return blue_agents[index] if index >= 0 and index < blue_agents.size() else null

func debug_get_red_agent(index: int) -> FormationAgent2D:
	return red_agents[index] if index >= 0 and index < red_agents.size() else null

func debug_get_command_service() -> TaskCommandService:
	return command_service

func _core_runtime_valid() -> bool:
	if navigation == null or command_service == null or blue_agents.size() != BLUE_COUNT or red_agents.size() != RED_COUNT:
		return false
	for agent: FormationAgent2D in blue_agents:
		if agent == null or agent.state == null or agent.autonomy == null:
			return false
	for agent: FormationAgent2D in red_agents:
		if agent == null or agent.state == null or agent.autonomy == null:
			return false
	return true
