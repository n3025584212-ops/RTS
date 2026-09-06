extends "res://scripts/production/quality/quality_test_world_v5.gd"

const FENCE_SIMPLE := "res://assets/golden_scene/nature/034_fence_simple.glb"
const FENCE_PLANKS := "res://assets/golden_scene/nature/032_fence_planks.glb"
const FENCE_GATE := "res://assets/golden_scene/nature/031_fence_gate.glb"

func _preflight() -> void:
	super._preflight()
	for path: String in [FENCE_SIMPLE,FENCE_PLANKS,FENCE_GATE]:
		if not ResourceLoader.exists(path):
			push_error("QUALITY_TEST_REQUIRED_ASSET_MISSING path=%s" % path)


func _build_environment() -> void:
	super._build_environment()
	var env_node := get_node_or_null("QualityEnvironment") as WorldEnvironment
	if env_node != null and env_node.environment != null:
		var env := env_node.environment
		env.background_mode = Environment.BG_COLOR
		env.background_color = Color(0.43,0.49,0.50)
		env.background_energy_multiplier = 0.82
		env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
		env.ambient_light_energy = 0.50
		env.reflected_light_source = Environment.REFLECTION_SOURCE_SKY
		env.fog_density = 0.0031
		env.fog_height_density = 0.009
		env.fog_aerial_perspective = 0.46
		env.adjustment_contrast = 1.07
		env.adjustment_saturation = 0.86
	var sun := get_node_or_null("QualityKeySun") as DirectionalLight3D
	if sun != null:
		sun.light_energy = 1.20


func _build_ground() -> void:
	super._build_ground()
	var track_left: Array[Vector3] = [
		Vector3(-20,0,31),Vector3(-14,0,24),Vector3(-10,0,18),Vector3(-7,0,13)
	]
	var track_right: Array[Vector3] = [
		Vector3(-19.2,0,31.6),Vector3(-13.2,0,24.6),Vector3(-9.2,0,18.6),Vector3(-6.2,0,13.6)
	]
	_add_road_ribbon(track_left,0.42,"grass_path_3",Color(0.31,0.25,0.18),"LeftTrack",0.083)
	_add_road_ribbon(track_right,0.42,"grass_path_3",Color(0.31,0.25,0.18),"RightTrack",0.084)
	_add_scorch_patch(Vector3(10,0,2),8.0,18.0)
	_add_scorch_patch(Vector3(19,0,9),6.5,-8.0)
	_add_scorch_patch(Vector3(-1,0,8),4.2,5.0)


func _build_buildings() -> void:
	var placements: Array = [
		[HOUSE_0,Vector3(17,0,-13),10.1,8.0,"FamilyHouseA",Color(0.82,0.80,0.76)],
		[HOUSE_1,Vector3(27,0,-3),10.7,-12.0,"FamilyHouseB",Color(0.80,0.79,0.75)],
		[HOUSE_2,Vector3(19,0,9),10.3,7.0,"DamagedFamilyHouse",Color(0.54,0.46,0.38)],
		[HOUSE_3,Vector3(9,0,19),9.9,-7.0,"FamilyHouseD",Color(0.82,0.80,0.76)]
	]
	for d: Array in placements:
		var p: Vector3 = d[1]
		p.y = _terrain_height(p.x,p.z) + 0.08
		var node := _add_asset(d[0],p,d[2],d[3],d[4])
		if node != null:
			_tint_surfaces(node,d[5])
	building_count = placements.size()
	_build_yard_boundaries()


func _build_yard_boundaries() -> void:
	var fence_mat := StandardMaterial3D.new()
	fence_mat.albedo_color = Color(0.24,0.17,0.105)
	fence_mat.roughness = 0.94
	var placements: Array = [
		[FENCE_SIMPLE,Vector3(13,0,-9),2.8,7.0],
		[FENCE_PLANKS,Vector3(10,0,-7),3.0,7.0],
		[FENCE_GATE,Vector3(22,0,-7),3.0,83.0],
		[FENCE_SIMPLE,Vector3(31,0,2),2.8,-10.0],
		[FENCE_PLANKS,Vector3(30,0,6),3.0,82.0],
		[FENCE_SIMPLE,Vector3(13,0,13),2.8,6.0],
		[FENCE_PLANKS,Vector3(8,0,14),3.0,6.0],
		[FENCE_GATE,Vector3(7,0,22),3.0,84.0]
	]
	for i: int in range(placements.size()):
		var d: Array = placements[i]
		var p: Vector3 = d[1]
		p.y = _terrain_height(p.x,p.z) + 0.05
		var fence := _add_asset(d[0],p,d[2],d[3],"YardFence_%02d" % i)
		if fence != null:
			_override_material(fence,fence_mat)


func _build_vehicles() -> void:
	var p_mbt := Vector3(-8,0,12)
	p_mbt.y = _terrain_height(p_mbt.x,p_mbt.z) + 0.15
	var mbt := _add_asset(MBT,p_mbt,7.0,-60.0,"HeroAbrams")
	if mbt != null:
		_override_material(mbt,_vehicle_material(Color(0.34,0.37,0.20),0.27))

	var p_ifv := Vector3(0,0,17)
	p_ifv.y = _terrain_height(p_ifv.x,p_ifv.z) + 0.13
	var ifv := _add_asset(IFV,p_ifv,5.7,-45.0,"SupportIFV")
	if ifv != null:
		_override_material(ifv,_vehicle_material(Color(0.38,0.40,0.22),0.18))

	var p_wreck := Vector3(10,0,2)
	p_wreck.y = _terrain_height(p_wreck.x,p_wreck.z) + 0.10
	var wreck := _add_asset(IFV,p_wreck,5.1,35.0,"BurnedIFV")
	if wreck != null:
		wreck.rotation_degrees.z = -6.0
		_override_material(wreck,_wreck_material())
	vehicle_count = 3


func _build_camera() -> void:
	camera = Camera3D.new()
	camera.name = "QualityCamera"
	camera.fov = 40.0
	camera.position = Vector3(-25.0,21.5,31.5)
	add_child(camera)
	camera.look_at(Vector3(10.0,-0.8,2.0),Vector3.UP)
	camera.current = true


func _add_scorch_patch(p: Vector3, size: float, yaw: float) -> void:
	var node := MeshInstance3D.new()
	node.name = "BattleScorch"
	var plane := PlaneMesh.new()
	plane.size = Vector2(size,size*0.72)
	node.mesh = plane
	p.y = _terrain_height(p.x,p.z) + 0.091
	node.position = p
	node.rotation_degrees.y = yaw
	var shader := Shader.new()
	shader.code = """
shader_type spatial;
render_mode blend_mix, depth_prepass_alpha, cull_back;
uniform sampler2D mud_tex : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
void fragment(){
	vec2 q=(UV-vec2(0.5))*2.0;
	float r=length(q*vec2(0.82,1.0));
	float mask=1.0-smoothstep(0.46,1.0,r);
	float breakup=texture(mud_tex,UV*3.0).r;
	ALBEDO=mix(vec3(0.065,0.052,0.040),texture(mud_tex,UV*3.0).rgb*0.34,0.24);
	ROUGHNESS=0.97;
	ALPHA=mask*(0.52+breakup*0.28);
}
"""
	var mat := ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("mud_tex",load("res://assets/golden_scene/pbr/aerial_mud_1_diff_1k.png"))
	node.material_override = mat
	add_child(node)
