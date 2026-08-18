class_name BattleHUD
extends CanvasLayer

signal restart_requested

@onready var task_label: Label = $Root/TopLeft/Task
@onready var selected_label: Label = $Root/TopLeft/Selected
@onready var order_label: Label = $Root/TopLeft/Order
@onready var blue_health_label: Label = $Root/TopLeft/BlueHealth
@onready var enemy_health_label: Label = $Root/TopLeft/EnemyHealth
@onready var objective_label: Label = $Root/TopLeft/Objective
@onready var result_panel: PanelContainer = $Root/VictoryPanel
@onready var result_title: Label = $Root/VictoryPanel/VBox/Victory
@onready var result_message: Label = $Root/VictoryPanel/VBox/Message
@onready var restart_button: Button = $Root/VictoryPanel/VBox/Restart

func _ready() -> void:
	restart_button.pressed.connect(_on_restart_pressed)
	result_panel.visible = false
	set_selected(false)
	set_order("HOLD")
	set_blue_health(0, 0)
	set_enemy_health(0, 0, true)
	set_objective("NEUTRAL", 0.0)

func set_selected(selected: bool) -> void:
	selected_label.text = "Selected Formation: %s" % ("BLUE-01" if selected else "NONE")

func set_order(order_name: String) -> void:
	order_label.text = "Current Order: %s" % order_name

func set_blue_health(current_hp: int, max_hp: int) -> void:
	blue_health_label.text = "BLUE-01 HP: %d / %d" % [current_hp, max_hp]

func set_enemy_health(current_hp: int, max_hp: int, alive: bool) -> void:
	if alive:
		enemy_health_label.text = "RED-01 HP: %d / %d" % [current_hp, max_hp]
	else:
		enemy_health_label.text = "RED-01: DESTROYED"

func set_objective(state: String, progress: float) -> void:
	if state == "CAPTURING":
		objective_label.text = "Central Bridgehead: CAPTURING %d%%" % int(round(progress * 100.0))
	else:
		objective_label.text = "Central Bridgehead: %s" % state

func show_victory() -> void:
	result_panel.visible = true
	result_title.text = "VICTORY"
	result_message.text = "Enemy screen destroyed. Central Bridgehead secured."
	task_label.text = "MISSION COMPLETE — CENTRAL BRIDGEHEAD SECURED"

func show_defeat() -> void:
	result_panel.visible = true
	result_title.text = "DEFEAT"
	result_message.text = "BLUE-01 destroyed before securing the bridgehead."
	task_label.text = "MISSION FAILED — COMBAT POWER LOST"

func _on_restart_pressed() -> void:
	restart_requested.emit()
