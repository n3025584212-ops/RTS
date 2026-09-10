extends "res://scripts/production/full_battlefield_town_probe_b.gd"
## Probe C keeps the proven V7 asymmetric town and original V7 house asset mix,
## then restores only the four authored parcel walls. Rubble remains excluded.
## This isolates the wall layer from the 145-fragment destruction MultiMesh.

const PROBE_C_BUDGET = preload("res://scripts/production/battlefield_visual_budget.gd")

func _ready() -> void:
	super._ready()
	add_probe_c_wall(Vector3(-56.0, height_at(-56.0, -190.0) + .45, -190.0), Vector3(17.0, .90, .55), -10.0)
	add_probe_c_wall(Vector3(111.0, height_at(111.0, -202.0) + .45, -202.0), Vector3(20.0, .90, .55), 24.0)
	add_probe_c_wall(Vector3(145.0, height_at(145.0, -219.0) + .45, -219.0), Vector3(15.0, .90, .55), -33.0)
	add_probe_c_wall(Vector3(-20.0, height_at(-20.0, -214.0) + .45, -214.0), Vector3(13.0, .90, .55), 42.0)
	print("FRONTLINE_TOWN_PROBE_C_READY layout=authored_asymmetric assets=v7_original walls=4 rubble=none")

func add_probe_c_wall(position3: Vector3, size3: Vector3, yaw: float) -> void:
	var wall := block(position3, size3, "stone")
	wall.rotation_degrees.y = yaw
	PROBE_C_BUDGET.apply_mid(wall, false)
