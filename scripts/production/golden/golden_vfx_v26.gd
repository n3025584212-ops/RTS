extends "res://scripts/production/golden/golden_vfx_v25.gd"

# V26 removes the remaining star-shaped blast language and spreads smoke over
# more than one isolated town hotspot. Bright HE stays compact; smoke and dust
# carry scale/history at tactical camera distance.


func _build_materials() -> void:
	super._build_materials()
	for i: int in range(_real_smoke_materials.size()):
		var smoke := _real_smoke_materials[i]
		var c := smoke.albedo_color
		smoke.albedo_color = Color(c.r * 0.82, c.g * 0.82, c.b * 0.80, minf(0.48, c.a + 0.08))


func build(world: GoldenWorldV1) -> void:
	super.build(world)
	_add_smoke_column(Vector3(66.0, 0, 18.0), 1.65, 12.5, 9)
	_add_smoke_column(Vector3(18.0, 0, -22.0), 1.35, 10.0, 8)


func _add_explosion(base: Vector3, scale_value: float) -> void:
	if _real_explosion_materials.is_empty():
		super._add_explosion(base, scale_value)
		return
	base.y = _world.height_at(base.x, base.z) + 0.95

	var fireball := MeshInstance3D.new()
	fireball.name = "V26CompactHE"
	var quad := QuadMesh.new()
	quad.size = Vector2(scale_value * 1.55, scale_value * 1.38)
	fireball.mesh = quad
	fireball.position = base + Vector3(0.0, scale_value * 0.12, 0.0)
	fireball.material_override = _real_explosion_materials[4 % _real_explosion_materials.size()]
	add_child(fireball)

	var light := OmniLight3D.new()
	light.name = "V26BlastLight"
	light.position = base + Vector3(0, 0.35, 0)
	light.light_color = Color(1.0, 0.28, 0.04)
	light.light_energy = 1.65 * scale_value
	light.omni_range = 6.5 * scale_value
	light.shadow_enabled = false
	add_child(light)

	# Irregular smoke/dust replaces the V24 radial ejecta star.
	var offsets: Array[Vector3] = [
		Vector3(-0.44, 0.46, 0.16),
		Vector3(0.20, 0.72, -0.31),
		Vector3(0.37, 0.98, 0.21),
		Vector3(-0.12, 1.25, -0.10)
	]
	for i: int in range(offsets.size()):
		var puff := MeshInstance3D.new()
		puff.name = "V26BlastSmoke"
		var smoke_quad := QuadMesh.new()
		smoke_quad.size = Vector2(
			scale_value * (1.10 + float(i) * 0.24),
			scale_value * (0.92 + float(i) * 0.22)
		)
		puff.mesh = smoke_quad
		puff.position = base + offsets[i] * scale_value
		puff.material_override = _real_smoke_materials[(i + 1) % _real_smoke_materials.size()]
		add_child(puff)

	explosion_count += 1
