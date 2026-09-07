extends "res://scripts/production/quality/quality_test_vfx_v7.gd"

func _add_fire(p: Vector3) -> void:
	var particles := GPUParticles3D.new()
	particles.name = "V16RefinedFire"
	particles.amount = 24
	particles.lifetime = 0.92
	particles.preprocess = 0.70
	particles.local_coords = false
	particles.position = p

	var process := ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	process.emission_sphere_radius = 0.22
	process.direction = Vector3(0.0,1.0,0.0)
	process.spread = 30.0
	process.initial_velocity_min = 0.28
	process.initial_velocity_max = 0.92
	process.gravity = Vector3(0.0,-0.12,0.0)
	process.scale_min = 0.10
	process.scale_max = 0.34
	process.color = Color(1,1,1,1)
	particles.process_material = process

	var quad := QuadMesh.new()
	quad.size = Vector2(0.52,0.74)
	var material := StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_texture = _soft_disc_texture(64,true)
	material.albedo_color = Color(1.0,0.52,0.12,0.78)
	material.emission_enabled = true
	material.emission = Color(1.0,0.18,0.03)
	material.emission_energy_multiplier = 1.8
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	quad.material = material
	particles.draw_pass_1 = quad
	add_child(particles)
	fire_emitters += 1

	var light := OmniLight3D.new()
	light.name = "V16RefinedFireLight"
	light.position = p+Vector3(0,0.55,0)
	light.light_color = Color(1.0,0.33,0.07)
	light.light_energy = 0.62
	light.omni_range = 3.7
	light.shadow_enabled = false
	add_child(light)
