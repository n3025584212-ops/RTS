extends "res://scripts/production/quality/quality_test_world_v9.gd"

const RESIDENTIAL_BLOCK := "res://assets/golden_scene/quality_v10/residential_block.glb"

func _preflight() -> void:
	super._preflight()
	if not ResourceLoader.exists(RESIDENTIAL_BLOCK):
		push_error("QUALITY_TEST_REQUIRED_ASSET_MISSING path=%s" % RESIDENTIAL_BLOCK)


func _build_environment() -> void:
	super._build_environment()
	var env_node := get_node_or_null("QualityEnvironment") as WorldEnvironment
	if env_node != null and env_node.environment != null:
		var env := env_node.environment
		env.background_color = Color(0.55,0.61,0.62)
		env.background_energy_multiplier = 1.0
		env.fog_light_color = Color(0.56,0.60,0.59)
		env.fog_light_energy = 0.62
		env.fog_density = 0.00335
		env.fog_height_density = 0.010
		env.adjustment_contrast = 1.06
		env.adjustment_saturation = 0.88


func _build_buildings() -> void:
	var placements: Array = [
		[HOUSE_0,Vector3(14,0,-14),9.5,8.0,"VillageHouseA",Color(0.80,0.78,0.73),Vector2(7.0,6.0)],
		[HOUSE_1,Vector3(25,0,-1),9.9,-11.0,"VillageHouseB",Color(0.78,0.77,0.72),Vector2(7.2,6.2)],
		[HOUSE_2,Vector3(16,0,13),9.6,6.0,"DamagedVillageHouse",Color(0.52,0.44,0.36),Vector2(7.0,6.0)],
		[HOUSE_3,Vector3(31,0,15),9.2,-4.0,"RearVillageHouse",Color(0.76,0.75,0.71),Vector2(6.8,5.8)]
	]
	for d: Array in placements:
		var node := _add_grounded_building(
			d[0],d[1],d[2],d[3],d[4],d[6],Color(0.28,0.25,0.21)
		)
		if node != null:
			_tint_surfaces(node,d[5])

	var church := _add_grounded_building(
		CHURCH,Vector3(42,0,-13),17.5,12.0,
		"VillageChurchLandmark",Vector2(11.0,8.0),Color(0.29,0.27,0.23)
	)
	if church != null:
		_apply_landmark_materials(church)

	var block := _add_grounded_building(
		RESIDENTIAL_BLOCK,Vector3(52,0,-29),20.0,-5.0,
		"RearResidentialBlock",Vector2(14.0,8.0),Color(0.27,0.26,0.23)
	)
	if block != null:
		_preserve_pbr_roughness(block)

	building_count = 6
	_build_yard_boundaries()


func _apply_landmark_materials(root: Node3D) -> void:
	var wall := _pbr(
		"t_concrete_wall_002",Vector3(3.0,3.0,3.0),
		Color(0.70,0.69,0.64),0.86
	)
	var roof := _pbr(
		"asphalt_02",Vector3(3.0,3.0,3.0),
		Color(0.18,0.19,0.18),0.90
	)
	var trim := StandardMaterial3D.new()
	trim.albedo_color = Color(0.12,0.13,0.12)
	trim.roughness = 0.78

	for item: Node in root.find_children("*","MeshInstance3D",true,false):
		var mi := item as MeshInstance3D
		if mi == null or mi.mesh == null:
			continue
		for surface: int in range(mi.mesh.get_surface_count()):
			var key: String = (mi.name+" "+mi.mesh.surface_get_name(surface)).to_lower()
			var src := mi.mesh.surface_get_material(surface)
			if src != null:
				key += " "+src.resource_name.to_lower()
			var chosen: Material = wall
			if key.contains("roof") or key.contains("tile") or key.contains("shingle"):
				chosen = roof
			elif key.contains("window") or key.contains("door") or key.contains("glass") or key.contains("trim"):
				chosen = trim
			mi.set_surface_override_material(surface,chosen)


func _preserve_pbr_roughness(root: Node3D) -> void:
	for item: Node in root.find_children("*","MeshInstance3D",true,false):
		var mi := item as MeshInstance3D
		if mi == null or mi.mesh == null:
			continue
		for surface: int in range(mi.mesh.get_surface_count()):
			var source := mi.get_active_material(surface)
			if source is StandardMaterial3D:
				var mat := source.duplicate() as StandardMaterial3D
				mat.roughness = maxf(mat.roughness,0.58)
				mi.set_surface_override_material(surface,mat)


func _build_vehicles() -> void:
	var p_mbt := Vector3(-8,0,12)
	p_mbt.y = _terrain_height(p_mbt.x,p_mbt.z) + 0.15
	var mbt := _add_asset(MBT,p_mbt,7.0,-58.0,"HeroAbrams")
	if mbt != null:
		_apply_vehicle_materials(mbt,Color(0.29,0.33,0.16),Color(0.15,0.18,0.09))

	var p_ifv := Vector3(-11,0,3)
	p_ifv.y = _terrain_height(p_ifv.x,p_ifv.z) + 0.13
	var ifv := _add_asset(IFV,p_ifv,5.7,-34.0,"SupportIFV")
	if ifv != null:
		_apply_vehicle_materials(ifv,Color(0.31,0.34,0.18),Color(0.17,0.20,0.10))

	var p_wreck := Vector3(10,0,2)
	p_wreck.y = _terrain_height(p_wreck.x,p_wreck.z) + 0.10
	var wreck := _add_asset(IFV,p_wreck,5.1,35.0,"BurnedIFV")
	if wreck != null:
		wreck.rotation_degrees.z = -6.0
		_override_material(wreck,_wreck_material())
	vehicle_count = 3


func _apply_vehicle_materials(root: Node3D, olive: Color, dark_olive: Color) -> void:
	var hull := _vehicle_camo_material(olive,dark_olive)
	var track := StandardMaterial3D.new()
	track.albedo_color = Color(0.055,0.060,0.050)
	track.metallic = 0.28
	track.roughness = 0.84
	var metal := StandardMaterial3D.new()
	metal.albedo_color = Color(0.11,0.12,0.10)
	metal.metallic = 0.46
	metal.roughness = 0.68

	for item: Node in root.find_children("*","MeshInstance3D",true,false):
		var mi := item as MeshInstance3D
		if mi == null or mi.mesh == null:
			continue
		for surface: int in range(mi.mesh.get_surface_count()):
			var key: String = (mi.name+" "+mi.mesh.surface_get_name(surface)).to_lower()
			var src := mi.mesh.surface_get_material(surface)
			if src != null:
				key += " "+src.resource_name.to_lower()
			var chosen: Material = hull
			if key.contains("track") or key.contains("wheel") or key.contains("tire") or key.contains("rubber"):
				chosen = track
			elif key.contains("gun") or key.contains("barrel") or key.contains("exhaust"):
				chosen = metal
			mi.set_surface_override_material(surface,chosen)


func _vehicle_camo_material(a: Color,b: Color) -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
shader_type spatial;
varying vec3 lp;
uniform vec3 color_a : source_color;
uniform vec3 color_b : source_color;
void vertex(){ lp=VERTEX; }
void fragment(){
	float n=sin(lp.x*1.37+lp.z*0.61)+sin(lp.z*1.83-lp.x*0.47);
	float mask=smoothstep(-0.22,0.35,n);
	ALBEDO=mix(color_a,color_b,mask*0.42);
	METALLIC=0.18;
	ROUGHNESS=0.73;
	SPECULAR=0.34;
}
"""
	var mat := ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("color_a",Vector3(a.r,a.g,a.b))
	mat.set_shader_parameter("color_b",Vector3(b.r,b.g,b.b))
	return mat
