extends "res://scripts/production/golden/golden_vfx_v21.gd"

# V22 keeps the licensed V21 sprite sources but removes the "pile of orange
# bubbles" read from the first runtime capture. The still frame now uses one
# dominant HE body plus two secondary lobes and softer smoke.

func _build_materials() -> void:
	super._build_materials()
	for i: int in range(_real_smoke_materials.size()):
		var mat := _real_smoke_materials[i]
		mat.albedo_color = Color(
			0.23 + float(i) * 0.016,
			0.235 + float(i) * 0.016,
			0.23 + float(i) * 0.014,
			0.46 - float(i) * 0.025
		)


func _add_explosion(base: Vector3, scale_value: float) -> void:
	if _real_explosion_materials.is_empty():
		super._add_explosion(base, scale_value)
		return

	base.y = _world.height_at(base.x, base.z) + 1.0
	var offsets: Array[Vector3] = [
		Vector3(0.0, 0.20, 0.0),
		Vector3(-0.45, 0.42, 0.18),
		Vector3(0.52, 0.30, -0.16)
	]
	var scales: Array[float] = [1.70, 1.02, 0.92]
	var cells: Array[int] = [4, 1, 7]
	for i: int in range(3):
		var sprite := MeshInstance3D.new()
		sprite.name = "V22HEExplosion"
		var quad := QuadMesh.new()
		quad.size = Vector2(scale_value * scales[i] * 1.18, scale_value * scales[i])
		sprite.mesh = quad
		sprite.position = base + offsets[i] * scale_value
		sprite.material_override = _real_explosion_materials[cells[i] % _real_explosion_materials.size()]
		add_child(sprite)

	var light := OmniLight3D.new()
	light.name = "V22ExplosionLight"
	light.position = base + Vector3(0, 0.32, 0)
	light.light_color = Color(1.0, 0.34, 0.055)
	light.light_energy = 3.7 * scale_value
	light.omni_range = 9.5 * scale_value
	light.shadow_enabled = false
	add_child(light)

	_add_afterblast_smoke(base, scale_value * 0.72)
	explosion_count += 1


func _add_afterblast_smoke(base: Vector3, scale_value: float) -> void:
	if _real_smoke_materials.is_empty():
		return
	for i: int in range(3):
		var puff := MeshInstance3D.new()
		puff.name = "V22AfterblastSmoke"
		var quad := QuadMesh.new()
		quad.size = Vector2(
			scale_value * (1.55 + float(i) * 0.30),
			scale_value * (1.30 + float(i) * 0.24)
		)
		puff.mesh = quad
		var angle := float(i) * TAU / 3.0 + 0.42
		puff.position = base + Vector3(
			cos(angle) * scale_value * 0.58,
			0.78 + float(i) * 0.38,
			sin(angle) * scale_value * 0.58
		)
		puff.material_override = _real_smoke_materials[(i + 1) % _real_smoke_materials.size()]
		add_child(puff)


func _add_smoke_column(base: Vector3, radius: float, height: float, puffs: int) -> void:
	if _real_smoke_materials.is_empty():
		super._add_smoke_column(base, radius, height, puffs)
		return
	base.y = _world.height_at(base.x, base.z)
	var count := maxi(puffs + 2, 9)
	for i: int in range(count):
		var t := float(i) / maxf(1.0, float(count - 1))
		var puff := MeshInstance3D.new()
		puff.name = "V22BattleSmoke"
		var quad := QuadMesh.new()
		var scale_value := radius * (0.76 + t * 1.20) * (0.94 + 0.08 * sin(float(i) * 2.03))
		quad.size = Vector2(scale_value * 2.80, scale_value * 2.42)
		puff.mesh = quad
		var sway := Vector3(
			sin(float(i) * 2.27) * radius * (0.46 + t * 0.50),
			t * height,
			cos(float(i) * 1.71) * radius * (0.40 + t * 0.42)
		)
		puff.position = base + Vector3(0, 1.0, 0) + sway
		puff.material_override = _real_smoke_materials[i % _real_smoke_materials.size()]
		add_child(puff)
	smoke_column_count += 1
