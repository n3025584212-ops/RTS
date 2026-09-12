extends "res://scripts/production/golden/golden_vfx_v23.gd"

# V24 corrects the V23 still-frame review: the single fireball is retained,
# but radial ejecta is made asymmetric and persistent fire is reduced to a
# compact flame source under smoke instead of a row of orange quads.


func _add_explosion(base: Vector3, scale_value: float) -> void:
	if _real_explosion_materials.is_empty():
		super._add_explosion(base, scale_value)
		return
	base.y = _world.height_at(base.x, base.z) + 1.05

	var fireball := MeshInstance3D.new()
	fireball.name = "V24HEFireball"
	var quad := QuadMesh.new()
	quad.size = Vector2(scale_value * 2.25, scale_value * 1.95)
	fireball.mesh = quad
	fireball.position = base + Vector3(0.0, scale_value * 0.18, 0.0)
	fireball.material_override = _real_explosion_materials[4 % _real_explosion_materials.size()]
	add_child(fireball)

	var directions: Array[Vector3] = [
		Vector3(-0.76, 0.82, 0.18),
		Vector3(0.42, 1.02, -0.62),
		Vector3(0.84, 0.54, 0.30),
		Vector3(-0.28, 0.70, -0.78)
	]
	for i: int in range(directions.size()):
		var start := base + Vector3(0.0, 0.30, 0.0)
		var finish := start + directions[i].normalized() * scale_value * (0.92 + float(i) * 0.12)
		_add_segment(start, finish, 0.022 * scale_value, _v23_spark_material, "V24BlastEjecta")

	var light := OmniLight3D.new()
	light.name = "V24ExplosionLight"
	light.position = base + Vector3(0, 0.42, 0)
	light.light_color = Color(1.0, 0.30, 0.04)
	light.light_energy = 3.0 * scale_value
	light.omni_range = 9.4 * scale_value
	light.shadow_enabled = false
	add_child(light)

	_add_v24_blast_smoke(base, scale_value)
	explosion_count += 1


func _add_v24_blast_smoke(base: Vector3, scale_value: float) -> void:
	if _real_smoke_materials.is_empty():
		return
	var offsets: Array[Vector3] = [
		Vector3(-0.28, 0.74, 0.10),
		Vector3(0.18, 1.12, -0.14),
		Vector3(0.08, 1.55, 0.18)
	]
	for i: int in range(offsets.size()):
		var puff := MeshInstance3D.new()
		puff.name = "V24BlastSmoke"
		var quad := QuadMesh.new()
		quad.size = Vector2(scale_value * (1.35 + float(i) * 0.30), scale_value * (1.12 + float(i) * 0.28))
		puff.mesh = quad
		puff.position = base + offsets[i] * scale_value
		puff.material_override = _real_smoke_materials[(i + 1) % _real_smoke_materials.size()]
		add_child(puff)


func _add_fire(base: Vector3, scale_value: float) -> void:
	base.y = _world.height_at(base.x, base.z)
	if not _real_explosion_materials.is_empty():
		var flame := MeshInstance3D.new()
		flame.name = "V24BattleFire"
		var quad := QuadMesh.new()
		quad.size = Vector2(0.95 * scale_value, 1.45 * scale_value)
		flame.mesh = quad
		flame.position = base + Vector3(0, 0.72 * scale_value, 0)
		flame.material_override = _real_explosion_materials[1 % _real_explosion_materials.size()]
		add_child(flame)
	else:
		var flame_fallback := MeshInstance3D.new()
		flame_fallback.name = "V24BattleFireFallback"
		var fallback_quad := QuadMesh.new()
		fallback_quad.size = Vector2(0.72 * scale_value, 1.25 * scale_value)
		flame_fallback.mesh = fallback_quad
		flame_fallback.position = base + Vector3(0, 0.65 * scale_value, 0)
		flame_fallback.material_override = _fire_material
		add_child(flame_fallback)

	var light := OmniLight3D.new()
	light.name = "V24FireLight"
	light.position = base + Vector3(0, 0.85, 0)
	light.light_color = Color(1.0, 0.30, 0.055)
	light.light_energy = 1.35 * scale_value
	light.omni_range = 5.6 * scale_value
	light.shadow_enabled = false
	add_child(light)

	if not _real_smoke_materials.is_empty():
		for i: int in range(3):
			var puff := MeshInstance3D.new()
			puff.name = "V24FireSmoke"
			var smoke_quad := QuadMesh.new()
			smoke_quad.size = Vector2(scale_value * (1.18 + float(i) * 0.32), scale_value * (1.00 + float(i) * 0.28))
			puff.mesh = smoke_quad
			puff.position = base + Vector3(
				sin(float(i) * 1.8) * 0.22 * scale_value,
				1.05 + float(i) * 0.72 * scale_value,
				cos(float(i) * 1.5) * 0.18 * scale_value
			)
			puff.material_override = _real_smoke_materials[i % _real_smoke_materials.size()]
			add_child(puff)
	fire_count += 1
