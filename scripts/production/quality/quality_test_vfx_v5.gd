extends "res://scripts/production/quality/quality_test_vfx_v4.gd"

func build() -> void:
	_add_smoke(Vector3(17.0,2.2,10.0))
	_add_smoke(Vector3(34.0,2.0,-13.0))
	_add_fire(Vector3(17.0,0.55,10.0))
	_add_fire(Vector3(10.0,0.48,3.0))
	_add_dust_impact(Vector3(3.0,0.22,2.5))
	_add_muzzle_burst(Vector3(-5.2,1.15,4.5),Vector3(0.92,0.05,-0.38))
	print("FRONTLINE_QUALITY_VFX_READY smoke=%d fire=%d sparks=%d" %
		[smoke_emitters,fire_emitters,spark_emitters])


func _add_dust_impact(p: Vector3) -> void:
	var particles := GPUParticles3D.new()
	particles.name = "DesignDustImpact"
	particles.amount = 34
	particles.lifetime = 1.8
	particles.preprocess = 0.75
	particles.local_coords = false
	particles.position = p

	var process := ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	process.emission_sphere_radius = 0.38
	process.direction = Vector3(0.08,1.0,0.04)
	process.spread = 68.0
	process.initial_velocity_min = 0.45
	process.initial_velocity_max = 1.9
	process.gravity = Vector3(0.0,-0.55,0.0)
	process.scale_min = 0.18
	process.scale_max = 0.62
	process.color = Color(1,1,1,1)
	particles.process_material = process

	var quad := QuadMesh.new()
	quad.size = Vector2(0.85,0.85)
	var material := StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(0.38,0.32,0.24,0.34)
	material.albedo_texture = _soft_disc_texture(64,false)
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	quad.material = material
	particles.draw_pass_1 = quad
	add_child(particles)
	spark_emitters += 1


func _add_muzzle_burst(p: Vector3,direction: Vector3) -> void:
	var particles := GPUParticles3D.new()
	particles.name = "DesignMuzzleBurst"
	particles.amount = 14
	particles.lifetime = 0.28
	particles.preprocess = 0.18
	particles.one_shot = false
	particles.local_coords = false
	particles.position = p

	var process := ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	process.emission_sphere_radius = 0.08
	process.direction = direction.normalized()
	process.spread = 12.0
	process.initial_velocity_min = 1.4
	process.initial_velocity_max = 3.2
	process.gravity = Vector3.ZERO
	process.scale_min = 0.08
	process.scale_max = 0.22
	process.color = Color(1,1,1,1)
	particles.process_material = process

	var quad := QuadMesh.new()
	quad.size = Vector2(0.34,0.18)
	var material := StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(1.0,0.52,0.12,0.88)
	material.emission_enabled = true
	material.emission = Color(1.0,0.24,0.035)
	material.emission_energy_multiplier = 3.2
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	quad.material = material
	particles.draw_pass_1 = quad
	add_child(particles)

	var light := OmniLight3D.new()
	light.name = "DesignMuzzleLight"
	light.position = p
	light.light_color = Color(1.0,0.38,0.08)
	light.light_energy = 0.9
	light.omni_range = 3.8
	light.shadow_enabled = false
	add_child(light)
