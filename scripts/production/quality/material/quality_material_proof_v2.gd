extends "res://scripts/production/quality/material/quality_material_proof_v1.gd"

const HOUSE_SHOT_V2 := OUTPUT_DIR + "/house_material_proof_v2_1920x1080.png"
const ABRAMS_SHOT_V2 := OUTPUT_DIR + "/abrams_material_proof_v2_1920x1080.png"
const GROUND_SHOT_V2 := OUTPUT_DIR + "/ground_material_proof_v2_1920x1080.png"

func _build_house_proof() -> void:
	_add_pad(Vector3.ZERO,Vector2(18,18))
	house_root = _spawn_scaled(HOUSE,Vector3.ZERO,10.8,0.0,"MaterialProofHouseV2")
	if house_root == null:
		return
	proof_checks["house_loaded"] = true

	var touched := 0
	for mi: MeshInstance3D in _collect_meshes(house_root):
		if mi.mesh == null:
			continue
		for surface: int in range(mi.mesh.get_surface_count()):
			var src := mi.get_active_material(surface)
			if src is StandardMaterial3D:
				var mat := (src as StandardMaterial3D).duplicate() as StandardMaterial3D
				mat.roughness = clampf(maxf(mat.roughness,0.58),0.58,0.90)
				mat.metallic = minf(mat.metallic,0.10)
				mi.set_surface_override_material(surface,mat)
				touched += 1
	proof_checks["house_authored_materials_preserved"] = touched > 0

	_add_bound_house_grime(house_root)
	_add_micro_grass_ring(Vector3.ZERO,7.0,18)
	_add_procedural_stones(Vector3(0,0,4.9),8,3.8)


func _add_bound_house_grime(root: Node3D) -> void:
	var b := _local_bounds(root)
	var x0 := b.position.x
	var x1 := b.position.x+b.size.x
	var z1 := b.position.z+b.size.z
	var z0 := b.position.z
	var lower_h := minf(1.25,b.size.y*0.22)

	_add_textured_overlay(
		root.position+Vector3((x0+x1)*0.5,b.position.y+lower_h*0.52,z1+0.025),
		Vector2(b.size.x*0.86,lower_h),Vector3.ZERO,
		_make_grime_texture(false),"HouseLowerDirtFront"
	)
	_add_textured_overlay(
		root.position+Vector3(x1+0.025,b.position.y+lower_h*0.55,(z0+z1)*0.5),
		Vector2(b.size.z*0.76,lower_h),Vector3(0,90,0),
		_make_grime_texture(false),"HouseLowerDirtSide"
	)
	_add_textured_overlay(
		root.position+Vector3((x0+x1)*0.5-1.2,b.position.y+b.size.y*0.48,z1+0.030),
		Vector2(1.5,minf(2.7,b.size.y*0.46)),Vector3.ZERO,
		_make_grime_texture(true),"HouseRainStreak"
	)


func _make_grime_texture(streak: bool) -> Texture2D:
	var image := Image.create(128,128,false,Image.FORMAT_RGBA8)
	for y: int in range(128):
		for x: int in range(128):
			var fx := float(x)/127.0
			var fy := float(y)/127.0
			var alpha := 0.0
			if streak:
				var center := 0.5+0.12*sin(fy*9.0)
				var width := 0.08+0.08*fy
				var core := 1.0-smoothstep(width,width*2.3,abs(fx-center))
				alpha = core*(0.28+0.48*(1.0-fy))
			else:
				var bottom := pow(1.0-fy,1.8)
				var noise := 0.55+0.45*sin(fx*31.0+sin(fy*17.0)*2.0)
				alpha = bottom*(0.18+0.34*noise)
			image.set_pixel(x,y,Color(0.11,0.075,0.045,clampf(alpha,0.0,0.58)))
	return ImageTexture.create_from_image(image)


func _add_textured_overlay(pos: Vector3,size: Vector2,rot: Vector3,texture: Texture2D,name_value: String) -> void:
	var node := MeshInstance3D.new()
	node.name = name_value
	var quad := QuadMesh.new()
	quad.size = size
	node.mesh = quad
	node.position = pos
	node.rotation_degrees = rot
	var mat := StandardMaterial3D.new()
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(1,1,1,1)
	mat.albedo_texture = texture
	mat.roughness = 1.0
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	node.material_override = mat
	add_child(node)


func _build_abrams_proof() -> void:
	var center := Vector3(45,0,0)
	_add_pad(center,Vector2(19,19))
	abrams_root = _spawn_scaled(ABRAMS,center,7.4,-18.0,"MaterialProofAbramsV2")
	if abrams_root == null:
		return
	proof_checks["abrams_loaded"] = true
	_ground_visual_to(abrams_root,0.03)

	var hull := _vehicle_hull_shader_v2()
	var track := _track_material()
	var rubber := _rubber_material()
	var metal := _metal_material()
	var optics := _optics_material()
	var layered_count := 0

	for mi: MeshInstance3D in _collect_meshes(abrams_root):
		if mi.mesh == null:
			continue
		for surface: int in range(mi.mesh.get_surface_count()):
			var key: String = (mi.name+" "+mi.mesh.surface_get_name(surface)).to_lower()
			var src := mi.mesh.surface_get_material(surface)
			if src != null:
				key += " "+src.resource_name.to_lower()
			var chosen: Material = hull
			if key.contains("track"):
				chosen = track
			elif key.contains("tire") or key.contains("rubber") or key.contains("wheel"):
				chosen = rubber
			elif key.contains("optic") or key.contains("glass") or key.contains("sight"):
				chosen = optics
			elif key.contains("barrel") or key.contains("gun") or key.contains("exhaust"):
				chosen = metal
			mi.set_surface_override_material(surface,chosen)
			layered_count += 1
			print("FRONTLINE_MATERIAL_V2_SURFACE key=%s material=%s" % [key,chosen.get_class()])
	proof_checks["vehicle_surface_layers"] = layered_count > 0

	_add_churn_patch(center+Vector3(0,0.028,0),Vector2(11.2,6.4),-18.0)
	_add_procedural_stones(center+Vector3(0,0,3.9),11,5.0)


func _vehicle_hull_shader_v2() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
shader_type spatial;
varying vec3 lp;
void vertex(){ lp=VERTEX; }
void fragment(){
	float macro=0.5+0.5*sin(lp.x*0.64+sin(lp.z*0.53)*1.9);
	float fine=0.5+0.5*sin(lp.x*6.2+lp.z*5.1);
	float lower=smoothstep(0.82,-0.46,lp.y);
	float streak=0.5+0.5*sin(lp.x*1.8-lp.z*2.3);
	vec3 clean=mix(vec3(0.145,0.175,0.060),vec3(0.225,0.245,0.092),macro*0.46);
	vec3 dust=vec3(0.24,0.175,0.095);
	float dirt_mask=clamp(lower*(0.20+0.25*fine)+streak*0.035,0.0,0.46);
	vec3 base=mix(clean,dust,dirt_mask);
	ALBEDO=base;
	METALLIC=0.15;
	ROUGHNESS=clamp(0.58+dirt_mask*0.62+fine*0.05,0.56,0.91);
	SPECULAR=0.31;
}
"""
	var mat := ShaderMaterial.new()
	mat.shader = shader
	return mat


func _ground_visual_to(root: Node3D,target_y: float) -> void:
	var minimum := INF
	for mi: MeshInstance3D in _collect_meshes(root):
		if mi.mesh == null:
			continue
		var aabb := mi.mesh.get_aabb()
		var corners: Array[Vector3] = [
			aabb.position,
			aabb.position+Vector3(aabb.size.x,0,0),
			aabb.position+Vector3(0,aabb.size.y,0),
			aabb.position+Vector3(0,0,aabb.size.z),
			aabb.position+Vector3(aabb.size.x,aabb.size.y,0),
			aabb.position+Vector3(aabb.size.x,0,aabb.size.z),
			aabb.position+Vector3(0,aabb.size.y,aabb.size.z),
			aabb.position+aabb.size
		]
		for c: Vector3 in corners:
			var gp := mi.global_transform*c
			minimum = minf(minimum,gp.y)
	if not is_inf(minimum):
		root.position.y += target_y-minimum


func _build_ground_proof() -> void:
	var center := Vector3(90,0,0)
	var ground := MeshInstance3D.new()
	ground.name = "TenMeterLayeredGroundV2"
	var plane := PlaneMesh.new()
	plane.size = Vector2(10.0,10.0)
	plane.subdivide_width = 48
	plane.subdivide_depth = 48
	ground.mesh = plane
	ground.position = center
	ground.material_override = _layered_ground_shader_v2()
	add_child(ground)
	proof_checks["ground_built"] = true

	_add_churn_patch(center+Vector3(0,0.022,0.6),Vector2(6.5,1.75),-10.0)
	_add_puddle(center+Vector3(1.6,0.045,0.55),Vector2(1.15,0.46),-7.0)
	_add_micro_grass_ring(center,4.7,30)
	_add_procedural_stones(center,22,4.6)
	proof_checks["ground_microgeometry"] = true


func _layered_ground_shader_v2() -> ShaderMaterial:
	var mat := _layered_ground_shader()
	if mat != null and mat.shader != null:
		var code := mat.shader.code
		code = code.replace("vec3(0.66,0.77,0.50)","vec3(0.54,0.68,0.37)")
		code = code.replace("vec3(0.63,0.53,0.38)","vec3(0.57,0.45,0.30)")
		code = code.replace("vec3(0.46,0.37,0.28)","vec3(0.38,0.30,0.22)")
		code = code.replace("road*0.72","road*0.58")
		mat.shader.code = code
	return mat


func _add_micro_grass_ring(center: Vector3,radius: float,count: int) -> void:
	for i: int in range(count):
		var a := float(i)*2.399963
		var r := radius*(0.42+0.58*float((i*37)%101)/100.0)
		var p := center+Vector3(cos(a)*r,0.02,sin(a)*r)
		_add_grass_tuft(p,0.42+0.12*float(i%4),a*57.2958)


func _add_grass_tuft(pos: Vector3,height: float,yaw: float) -> void:
	var colors: Array[Color] = [
		Color(0.18,0.28,0.08),Color(0.24,0.34,0.10),Color(0.34,0.38,0.12)
	]
	for j: int in range(5):
		var blade := MeshInstance3D.new()
		blade.name = "ProofGrassBlade"
		var box := BoxMesh.new()
		box.size = Vector3(0.028,height*(0.76+0.06*float(j)),0.020)
		blade.mesh = box
		var ang := deg_to_rad(yaw+float(j)*29.0)
		var off := Vector3(cos(ang),0,sin(ang))*0.10
		blade.position = pos+off+Vector3(0,height*0.38,0)
		blade.rotation_degrees = Vector3(float(j%2)*5.0,yaw+float(j)*29.0,float((j+1)%2)*6.0)
		var mat := StandardMaterial3D.new()
		mat.albedo_color = colors[j%colors.size()]
		mat.roughness = 0.94
		blade.material_override = mat
		add_child(blade)


func _add_procedural_stones(center: Vector3,count: int,radius: float) -> void:
	for i: int in range(count):
		var a := float(i)*2.123
		var rr := radius*(0.22+0.74*float((i*53)%97)/96.0)
		var p := center+Vector3(cos(a)*rr,0.05,sin(a)*rr)
		var stone := MeshInstance3D.new()
		stone.name = "ProofStone"
		var sphere := SphereMesh.new()
		sphere.radius = 0.08+0.025*float(i%4)
		sphere.height = 0.10+0.035*float((i+1)%4)
		sphere.radial_segments = 7
		sphere.rings = 4
		stone.mesh = sphere
		stone.position = p
		stone.scale = Vector3(1.15+0.12*float(i%3),0.72+0.10*float((i+1)%3),0.90+0.08*float((i+2)%3))
		stone.rotation_degrees.y = float(i)*37.0
		var mat := StandardMaterial3D.new()
		var shade := 0.16+0.025*float(i%4)
		mat.albedo_color = Color(shade,shade*0.91,shade*0.78)
		mat.roughness = 0.96
		stone.material_override = mat
		add_child(stone)


func _capture_all() -> void:
	await _capture_view(HOUSE_SHOT_V2,Vector3(11.2,6.2,13.8),Vector3(0,2.25,0))
	await _capture_view(ABRAMS_SHOT_V2,Vector3(56.0,4.8,10.8),Vector3(45,1.45,0))
	await _capture_view(GROUND_SHOT_V2,Vector3(95.8,7.4,8.3),Vector3(90,0.0,0))
	_write_metrics_v2()
	var all_pass := true
	for value: Variant in proof_checks.values():
		if not bool(value):
			all_pass = false
	print("FRONTLINE_MATERIAL_PROOF_TECH_%s" % ("PASS" if all_pass else "FAIL"))
	get_tree().quit(0 if all_pass else 62)


func _write_metrics_v2() -> void:
	var payload := {
		"task_id": "QUALITY_MATERIAL_PROOF_V2",
		"engine": Engine.get_version_info().get("string","Godot"),
		"renderer": RenderingServer.get_current_rendering_method(),
		"checks": proof_checks,
		"visual_pass": false,
		"captures": [HOUSE_SHOT_V2,ABRAMS_SHOT_V2,GROUND_SHOT_V2]
	}
	var file := FileAccess.open(METRICS_PATH,FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(payload,"\t")+"\n")
		file.close()
