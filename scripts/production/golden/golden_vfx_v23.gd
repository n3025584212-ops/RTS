extends "res://scripts/production/golden/golden_vfx_v22.gd"

# V23 removes the remaining synthetic orange-cluster read in the V22 still.
# One coherent fireball, short ejecta streaks and softer afterblast smoke read
# better at RTS camera distance than a ring of overlapping explosion sprites.

var _v23_spark_material: StandardMaterial3D


func _build_materials() -> void:
	super._build_materials()
	_v23_spark_material = StandardMaterial3D.new()
	_v23_spark_material.albedo_color = Color(1.0, 0.48, 0.08)
	_v23_spark_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_v23_spark_material.emission_enabled = true
	_v23_spark_material.emission = Color(1.0, 0.22, 0.025)
	_v23_spark_material.emission_energy_multiplier = 3.2

	for i: int in range(_real_smoke_materials.size()):
		var mat := _real_smoke_materials[i]
		mat.albedo_color = Color(
			0.19 + float(i) * 0.014,
			0.195 + float(i) * 0.014,
			0.19 + float(i) * 0.012,
			0.39 - float(i) * 0.021
		)


func _add_explosion(base: Vector3, scale_value: float) -> void:
	if _real_explosion_materials.is_empty():
		super._add_explosion(base, scale_value)
		return

	base.y = _world.height_at(base.x, base.z) + 1.05

	var fireball := MeshInstance3D.new()
	fireball.name = "V23HEFireball"
	var quad := QuadMesh.new()
	quad.size = Vector2(scale_value * 2.45, scale_value * 2.12)
	fireball.mesh = quad
	fireball.position = base + Vector3(0.0, scale_value * 0.20, 0.0)
	fireball.material_override = _real_explosion_materials[4 % _real_explosion_materials.size()]
	add_child(fireball)

	# Short radial ejecta gives the still a blast direction without drawing a
	# geometric star or a long projectile wire through the battlefield.
	for i: int in range(7):
		var angle := float(i) * TAU / 7.0 + 0.19
		var start := base + Vector3(0.0, 0.34, 0.0)
		var length := scale_value * (1.25 + float(i % 3) * 0.28)
		var finish := start + Vector3(
			cos(angle) * length,
			0.25 + float(i % 2) * 0.42,
			sin(angle) * length
		)
		_add_segment(start, finish, 0.028 * scale_value, _v23_spark_material, "V23BlastEjecta")

	var light := OmniLight3D.new()
	light.name = "V23ExplosionLight"
	light.position = base + Vector3(0, 0.45, 0)
	light.light_color = Color(1.0, 0.31, 0.045)
	light.light_energy = 3.3 * scale_value
	light.omni_range = 10.0 * scale_value
	light.shadow_enabled = false
	add_child(light)

	_add_v23_afterblast_smoke(base, scale_value)
	explosion_count += 1


func _add_v23_afterblast_smoke(base: Vector3, scale_value: float) -> void:
	if _real_smoke_materials.is_empty():
		return
	for i: int in range(4):
		var puff := MeshInstance3D.new()
		puff.name = "V23AfterblastSmoke"
		var quad := QuadMesh.new()
		quad.size = Vector2(
			scale_value * (1.35 + float(i) * 0.34),
			scale_value * (1.15 + float(i) * 0.30)
		)
		puff.mesh = quad
		var angle := float(i) * TAU / 4.0 + 0.31
		puff.position = base + Vector3(
			cos(angle) * scale_value * (0.28 + float(i) * 0.10),
			0.85 + float(i) * 0.46 * scale_value,
			sin(angle) * scale_value * (0.28 + float(i) * 0.10)
		)
		puff.material_override = _real_smoke_materials[(i + 1) % _real_smoke_materials.size()]
		add_child(puff)


func _add_smoke_column(base: Vector3, radius: float, height: float, puffs: int) -> void:
	if _real_smoke_materials.is_empty():
		super._add_smoke_column(base, radius, height, puffs)
		return
	base.y = _world.height_at(base.x, base.z)
	var count := maxi(puffs + 1, 8)
	for i: int in range(count):
		var t := float(i) / maxf(1.0, float(count - 1))
		var puff := MeshInstance3D.new()
		puff.name = "V23BattleSmoke"
		var quad := QuadMesh.new()
		var scale_local := radius * (0.82 + t * 1.14) * (0.94 + 0.07 * sin(float(i) * 1.91))
		quad.size = Vector2(scale_local * 2.72, scale_local * 2.34)
		puff.mesh = quad
		var sway := Vector3(
			sin(float(i) * 2.11) * radius * (0.38 + t * 0.44),
			t * height,
			cos(float(i) * 1.63) * radius * (0.34 + t * 0.40)
		)
		puff.position = base + Vector3(0, 1.0, 0) + sway
		puff.material_override = _real_smoke_materials[i % _real_smoke_materials.size()]
		add_child(puff)
	smoke_column_count += 1
