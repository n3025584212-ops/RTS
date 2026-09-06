extends QualityTestVFXV1

func _add_smoke(p: Vector3) -> void:
	var particles := GPUParticles3D.new()
	particles.name = "QualitySmoke"
	particles.amount = 64
	particles.lifetime = 7.0
	particles.preprocess = 4.5
	particles.local_coords = false
	particles.position = p
	var process := ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	process.emission_sphere_radius = 0.75
	process.direction = Vector3(0.05,1.0,-0.03)
	process.spread = 25.0
	process.initial_velocity_min = 0.28
	process.initial_velocity_max = 0.75
	process.gravity = Vector3(0.0,0.08,0.0)
	process.scale_min = 0.55
	process.scale_max = 1.9
	process.color = Color(1,1,1,1)
	particles.process_material = process
	var quad := QuadMesh.new()
	quad.size = Vector2(2.6,2.6)
	var material := StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(0.16,0.16,0.15,0.62)
	material.albedo_texture = _soft_disc_texture(96,false)
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	quad.material = material
	particles.draw_pass_1 = quad
	add_child(particles)
	smoke_emitters += 1


func _add_fire(p: Vector3) -> void:
	var particles := GPUParticles3D.new()
	particles.name = "QualityFire"
	particles.amount = 40
	particles.lifetime = 1.25
	particles.preprocess = 1.0
	particles.local_coords = false
	particles.position = p
	var process := ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	process.emission_sphere_radius = 0.30
	process.direction = Vector3(0.0,1.0,0.0)
	process.spread = 32.0
	process.initial_velocity_min = 0.35
	process.initial_velocity_max = 1.2
	process.gravity = Vector3(0.0,-0.16,0.0)
	process.scale_min = 0.16
	process.scale_max = 0.52
	process.color = Color(1,1,1,1)
	particles.process_material = process
	var quad := QuadMesh.new()
	quad.size = Vector2(0.75,1.05)
	var material := StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_texture = _soft_disc_texture(64,true)
	material.emission_enabled = true
	material.emission = Color(1.0,0.16,0.025)
	material.emission_energy_multiplier = 2.5
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	quad.material = material
	particles.draw_pass_1 = quad
	add_child(particles)
	fire_emitters += 1


func _soft_disc_texture(size: int, fire: bool) -> ImageTexture:
	var image := Image.create(size,size,false,Image.FORMAT_RGBA8)
	var center := Vector2(float(size-1)*0.5,float(size-1)*0.5)
	var radius := float(size)*0.5
	for y: int in range(size):
		for x: int in range(size):
			var d := Vector2(float(x),float(y)).distance_to(center) / radius
			var alpha := clampf(1.0 - smoothstep(0.42,1.0,d),0.0,1.0)
			if fire:
				var core := clampf(1.0 - d,0.0,1.0)
				image.set_pixel(x,y,Color(1.0,0.16 + core * 0.52,0.02,alpha))
			else:
				var shade := 0.78 + 0.16 * sin(float(x+y) * 0.18)
				image.set_pixel(x,y,Color(shade,shade,shade,alpha * 0.48))
	return ImageTexture.create_from_image(image)
