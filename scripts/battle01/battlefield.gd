extends Node2D

const MAP_SIZE := Vector2(3200.0, 1800.0)

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, MAP_SIZE), Color(0.08, 0.11, 0.10), true)
	# Friendly rear area
	draw_rect(Rect2(Vector2(120.0, 560.0), Vector2(620.0, 680.0)), Color(0.08, 0.18, 0.24), true)
	# River and bridge
	draw_rect(Rect2(Vector2(1480.0, 0.0), Vector2(240.0, MAP_SIZE.y)), Color(0.05, 0.15, 0.22), true)
	draw_rect(Rect2(Vector2(1460.0, 790.0), Vector2(280.0, 220.0)), Color(0.28, 0.27, 0.24), true)
	# North village blockout
	draw_rect(Rect2(Vector2(1120.0, 250.0), Vector2(760.0, 360.0)), Color(0.20, 0.19, 0.16), true)
	# South maneuver corridor
	draw_rect(Rect2(Vector2(850.0, 1280.0), Vector2(1480.0, 220.0)), Color(0.14, 0.16, 0.12), true)
	# Industrial objective area
	draw_rect(Rect2(Vector2(2440.0, 520.0), Vector2(560.0, 760.0)), Color(0.18, 0.16, 0.15), true)
	# Main road
	draw_line(Vector2(420.0, 900.0), Vector2(2850.0, 900.0), Color(0.30, 0.30, 0.28), 34.0)
	# Labels / landmark circles
	draw_circle(Vector2(420.0, 900.0), 90.0, Color(0.12, 0.42, 0.68, 0.28))
	draw_circle(Vector2(1600.0, 900.0), 150.0, Color(0.85, 0.67, 0.18, 0.18))
