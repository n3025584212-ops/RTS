class_name BattleHUD
extends CanvasLayer

signal restart_requested

@onready var task_label: Label = $Root/TopLeft/Task
@onready var selected_label: Label = $Root/TopLeft/Selected
@onready var order_label: Label = $Root/TopLeft/Order
@onready var objective_label: Label = $Root/TopLeft/Objective
@onready var victory_panel: PanelContainer = $Root/VictoryPanel
@onready var restart_button: Button = $Root/VictoryPanel/VBox/Restart

func _ready() -> void:
	restart_button.pressed.connect(_on_restart_pressed)
	victory_panel.visible = false
	set_selected(false)
	set_order("HOLD")
	set_objective("NEUTRAL", 0.0)

func set_selected(selected: bool) -> void:
	selected_label.text = "Selected Formation: %s" % ("BLUE-01" if selected else "NONE")

func set_order(order_name: String) -> void:
	order_label.text = "Current Order: %s" % order_name

func set_objective(state: String, progress: float) -> void:
	if state == "CAPTURING":
		objective_label.text = "Central Bridgehead: CAPTURING %d%%" % int(round(progress * 100.0))
	else:
		objective_label.text = "Central Bridgehead: %s" % state

func show_victory() -> void:
	victory_panel.visible = true
	task_label.text = "MISSION COMPLETE — CENTRAL BRIDGEHEAD SECURED"

func _on_restart_pressed() -> void:
	restart_requested.emit()
