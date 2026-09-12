extends "res://scripts/production/golden/golden_vfx_v24.gd"

# V25 lets smoke/dust carry more of the battle read. The V24 geometry works,
# but the still remains too orange because three concurrent blast events and
# four persistent fires all compete at RTS camera distance.


func _build_materials() -> void:
	super._build_materials()
	for material: StandardMaterial3D in _real_explosion_materials:
		material.albedo_color = Color(1.0, 0.60, 0.30, 0.78)
		if material.emission_enabled:
			material.emission = Color(1.0, 0.16, 0.025)
			material.emission_energy_multiplier = 1.55


func _add_explosion(base: Vector3, scale_value: float) -> void:
	# Keep all authored impact locations for battlefield history, but reduce the
	# bright footprint so separate events stop merging into an orange cluster.
	super._add_explosion(base, scale_value * 0.72)


func _add_fire(base: Vector3, scale_value: float) -> void:
	# Persistent wreck fires become compact heat sources under smoke rather than
	# four equal visual focal points.
	super._add_fire(base, scale_value * 0.76)
