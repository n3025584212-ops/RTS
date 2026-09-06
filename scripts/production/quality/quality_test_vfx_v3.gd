extends "res://scripts/production/quality/quality_test_vfx_v2.gd"

func _add_fire(p: Vector3) -> void:
	super._add_fire(p)
	var light := OmniLight3D.new()
	light.name = "QualityFireLight"
	light.position = p + Vector3(0.0,1.0,0.0)
	light.light_color = Color(1.0,0.34,0.08)
	light.light_energy = 1.35
	light.omni_range = 5.5
	light.shadow_enabled = false
	add_child(light)
