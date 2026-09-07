extends "res://scripts/production/quality/quality_test_world_v16_1.gd"

func _build_ground() -> void:
	super._build_ground()
	_add_background_landscape()


func _add_background_landscape() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var nx := 61
	var nz := 31
	var x_min := -185.0
	var x_max := 185.0
	var z_near := -91.5
	var z_far := -255.0
	var dx := (x_max-x_min)/float(nx-1)
	var dz := (z_far-z_near)/float(nz-1)

	for zi: int in range(nz-1):
		for xi: int in range(nx-1):
			var x0 := x_min+float(xi)*dx
			var x1 := x0+dx
			var z0 := z_near+float(zi)*dz
			var z1 := z0+dz
			var p00 := Vector3(x0,_background_height(x0,z0),z0)
			var p10 := Vector3(x1,_background_height(x1,z0),z0)
			var p01 := Vector3(x0,_background_height(x0,z1),z1)
			var p11 := Vector3(x1,_background_height(x1,z1),z1)
			_add_background_vertex(st,p00,x_min,x_max,z_near,z_far)
			_add_background_vertex(st,p10,x_min,x_max,z_near,z_far)
			_add_background_vertex(st,p01,x_min,x_max,z_near,z_far)
			_add_background_vertex(st,p10,x_min,x_max,z_near,z_far)
			_add_background_vertex(st,p11,x_min,x_max,z_near,z_far)
			_add_background_vertex(st,p01,x_min,x_max,z_near,z_far)

	var bg := MeshInstance3D.new()
	bg.name = "V16BackgroundLandscape"
	bg.mesh = st.commit()
	bg.material_override = _background_material()
	bg.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	add_child(bg)


func _background_height(x: float,z: float) -> float:
	var t := clampf((-z-91.5)/163.5,0.0,1.0)
	var seam := _terrain_height(clampf(x,TERRAIN_X_MIN,TERRAIN_X_MAX),-91.5)
	var hills := 3.0+7.0*pow(t,1.15)
	hills += 2.6*sin(x*0.027+z*0.013)
	hills += 1.8*cos(x*0.016-z*0.021)
	var center_ridge := 3.2*exp(-pow((x-18.0)/72.0,2.0))*smoothstep(0.18,0.72,t)
	return lerpf(seam,hills+center_ridge,smoothstep(0.0,0.42,t))


func _background_vertex(st: SurfaceTool,p: Vector3,x_min: float,x_max: float,z_near: float,z_far: float) -> void:
	var e := 1.0
	var dx := _background_height(p.x+e,p.z)-_background_height(p.x-e,p.z)
	var dz := _background_height(p.x,p.z+e)-_background_height(p.x,p.z-e)
	st.set_normal(Vector3(-dx/(2.0*e),1.0,-dz/(2.0*e)).normalized())
	st.set_uv(Vector2((p.x-x_min)/(x_max-x_min),(p.z-z_near)/(z_far-z_near)))
	st.add_vertex(p)


func _background_material() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
shader_type spatial;
uniform sampler2D grass_diff : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D dirt_diff : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
varying vec3 wp;
void vertex(){ wp=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz; }
void fragment(){
	vec2 uv=UV*19.0;
	vec3 grass=texture(grass_diff,uv).rgb*vec3(0.44,0.55,0.32);
	vec3 dirt=texture(dirt_diff,uv*0.73).rgb*vec3(0.48,0.40,0.28);
	float patch=0.42+0.28*sin(wp.x*0.034+sin(wp.z*0.021)*2.0);
	ALBEDO=mix(grass,dirt,clamp(patch*0.28,0.05,0.34));
	ROUGHNESS=0.94;
	SPECULAR=0.20;
}
"""
	var mat := ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("grass_diff",load("res://assets/golden_scene/pbr/leafy_grass_diff_1k.png"))
	mat.set_shader_parameter("dirt_diff",load("res://assets/golden_scene/pbr/dirt_aerial_03_diff_1k.png"))
	return mat


func _build_buildings() -> void:
	super._build_buildings()

	var house_a := get_node_or_null("V16HouseA") as Node3D
	var house_b := get_node_or_null("V16HouseB") as Node3D
	var house_c := get_node_or_null("V16DamagedHouse") as Node3D
	var house_d := get_node_or_null("V16RearHouse") as Node3D
	var house_e := get_node_or_null("V16RearHouseB") as Node3D
	var church := get_node_or_null("V16ChurchLandmark") as Node3D

	if house_a != null:
		_apply_house_finish(house_a,Color(0.84,0.70,0.58),false)
	if house_b != null:
		_apply_house_finish(house_b,Color(0.72,0.66,0.55),false)
	if house_c != null:
		_apply_house_finish(house_c,Color(0.54,0.43,0.34),true)
	if house_d != null:
		_apply_house_finish(house_d,Color(0.75,0.62,0.52),false)
	if house_e != null:
		_apply_house_finish(house_e,Color(0.66,0.59,0.50),false)
	if church != null:
		_apply_church_finish(church)


func _apply_house_finish(root: Node3D,tint: Color,damaged: bool) -> void:
	var wall := _pbr(
		"brick_wall_005",Vector3(2.4,2.4,2.4),
		tint,0.88
	)
	var plaster := _pbr(
		"t_concrete_wall_002",Vector3(2.8,2.8,2.8),
		Color(tint.r*0.92,tint.g*0.92,tint.b*0.88),0.90
	)
	var roof := _pbr(
		"asphalt_02",Vector3(3.0,3.0,3.0),
		Color(0.15,0.135,0.115),0.93
	)
	var trim := StandardMaterial3D.new()
	trim.albedo_color = Color(0.095,0.075,0.055)
	trim.roughness = 0.82

	var meshes: Array[MeshInstance3D] = []
	if root is MeshInstance3D:
		meshes.append(root as MeshInstance3D)
	for item: Node in root.find_children("*","MeshInstance3D",true,false):
		var mi := item as MeshInstance3D
		if mi != null:
			meshes.append(mi)

	for mi: MeshInstance3D in meshes:
		if mi.mesh == null:
			continue
		for surface: int in range(mi.mesh.get_surface_count()):
			var key: String = (mi.name+" "+mi.mesh.surface_get_name(surface)).to_lower()
			var src := mi.mesh.surface_get_material(surface)
			if src != null:
				key += " "+src.resource_name.to_lower()
			var chosen: Material = wall
			if key.contains("roof") or key.contains("tile") or key.contains("shingle"):
				chosen = roof
			elif key.contains("window") or key.contains("door") or key.contains("frame") or key.contains("trim"):
				chosen = trim
			elif key.contains("plaster") or key.contains("stucco") or key.contains("concrete"):
				chosen = plaster
			mi.set_surface_override_material(surface,chosen)

	if damaged:
		_add_building_soot(root.position+Vector3(-0.8,2.4,-2.6),root.rotation_degrees.y,Vector2(2.6,2.0))
		_add_building_soot(root.position+Vector3(1.7,3.1,1.8),root.rotation_degrees.y+180.0,Vector2(1.7,1.3))


func _apply_church_finish(root: Node3D) -> void:
	var wall := _pbr(
		"t_concrete_wall_002",Vector3(2.5,2.5,2.5),
		Color(0.55,0.53,0.47),0.91
	)
	var roof := _pbr(
		"asphalt_02",Vector3(2.7,2.7,2.7),
		Color(0.12,0.13,0.12),0.93
	)
	var dark := StandardMaterial3D.new()
	dark.albedo_color = Color(0.08,0.075,0.065)
	dark.roughness = 0.85

	for item: Node in root.find_children("*","MeshInstance3D",true,false):
		var mi := item as MeshInstance3D
		if mi == null or mi.mesh == null:
			continue
		for surface: int in range(mi.mesh.get_surface_count()):
			var key: String = (mi.name+" "+mi.mesh.surface_get_name(surface)).to_lower()
			var chosen: Material = wall
			if key.contains("roof") or key.contains("spire"):
				chosen = roof
			elif key.contains("window") or key.contains("door"):
				chosen = dark
			mi.set_surface_override_material(surface,chosen)


func _add_building_soot(position_value: Vector3,yaw: float,size: Vector2) -> void:
	var scar := MeshInstance3D.new()
	scar.name = "V16BuildingSoot"
	var quad := QuadMesh.new()
	quad.size = size
	scar.mesh = quad
	scar.position = position_value
	scar.rotation_degrees.y = yaw
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.055,0.046,0.040,0.55)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.roughness = 0.99
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	scar.material_override = mat
	add_child(scar)


func _build_trees() -> void:
	super._build_trees()

	var background_trees: Array = [
		[Vector3(-72,0,-70),14.0,11.0],
		[Vector3(-57,0,-76),15.0,48.0],
		[Vector3(-40,0,-81),13.8,86.0],
		[Vector3(-22,0,-84),15.2,126.0],
		[Vector3(-3,0,-86),14.2,166.0],
		[Vector3(17,0,-84),15.0,205.0],
		[Vector3(36,0,-81),14.0,245.0],
		[Vector3(55,0,-76),15.4,286.0],
		[Vector3(72,0,-68),14.2,327.0],
		[Vector3(86,0,-55),13.8,29.0],
		[Vector3(-88,0,-55),13.6,71.0]
	]
	for i: int in range(background_trees.size()):
		var d: Array = background_trees[i]
		var p: Vector3 = d[0]
		p.y = _terrain_height(clampf(p.x,TERRAIN_X_MIN,TERRAIN_X_MAX),clampf(p.z,TERRAIN_Z_MIN,TERRAIN_Z_MAX))
		_add_asset(TREE_HERO,p,d[1],d[2],"V16BackgroundTree_%02d" % i)
		tree_count += 1
