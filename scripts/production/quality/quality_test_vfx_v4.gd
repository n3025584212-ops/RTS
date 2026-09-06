extends "res://scripts/production/quality/quality_test_vfx_v3.gd"

func _add_smoke(p: Vector3) -> void:
	var particles := GPUParticles3D.new()
	particles.name = "QualitySmoke"
	particles.amount = 44
	particles.lifetime = 6.0
	particles.preprocess = 3.6
	particles.local_coords = false
	particles.position = p
	var process := ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	process.emission_sphere_radius = 0.70
	process.direction = Vector3(0.22,1.0,-0.05)
	process.spread = 22.0
	process.initial_velocity_min = 0.30
	process.initial_velocity_max = 0.78
	process.gravity = Vector3(0.0,0.05,0.0)
	process.scale_min = 0.50
	process.scale_max = 1.60
	process.color = Color(1,1,1,1)
	particles.process_material = process
	var quad := QuadMesh.new()
	quad.size = Vector2(2.4,2.4)
	var material := StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(0.20,0.195,0.185,0.46)
	material.albedo_texture = _soft_disc_texture(96,false)
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	quad.material = material
	particles.draw_pass_1 = quad
	add_child(particles)
	smoke_emitters += 1
