extends "res://scripts/production/reference_region_01.gd"
## Alignment layer: keeps the authored meander while making its z=36 crossing
## coincide with the Reference Region bridge center at x=-25.

func _river_x(z: float) -> float:
	return -49.27067 + sin(z * 0.0105) * 42.0 + sin(z * 0.027 + 1.1) * 10.0
