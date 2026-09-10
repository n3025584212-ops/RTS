extends "res://scripts/production/full_battlefield_production_v2_lod_v8.gd"
## V9 visual-structure candidate.
## Near remains inherited and untouched. This pass only replaces the repetitive
## MID/FAR backdrop: regular copied houses become irregular hamlets, the uniform
## distant forest becomes separated woodland masses with sightline gaps, and the
## fixed 45 m industrial rhythm becomes an asymmetric campaign skyline.

const V9_ASSET := "res://assets/visual_slice/"
const V9_CITY := "res://assets/golden_scene/city_real/"
const V9_BUDGET = preload("res://scripts/production/battlefield_visual_budget.gd")

func _ready() -> void:
	super._ready()
	print("FRONTLINE_FULL_BATTLEFIELD_V2_LOD_V9_READY background=clustered_hamlets forest=broken_masses horizon=asymmetric near=preserved")

func create_background() -> void:
	# Replace the inherited 19-house quasi-grid with separated secondary hamlets.
	# V8 later authors the main town front; this layer exists only to create depth.
	var hamlets: Array[Dictionary] = [
		{"file": V9_ASSET + "house_intact.glb", "x": -158.0, "z": -132.0, "yaw": 31.0, "scale": .86, "shadow": false},
		{"file": V9_ASSET + "house_damaged.glb", "x": -129.0, "z": -153.0, "yaw": -18.0, "scale": .91, "shadow": true},
		{"file": V9_CITY + "ordinary_house_textured.glb", "x": -171.0, "z": -181.0, "yaw": 47.0, "scale": .97, "shadow": false},
		{"file": V9_ASSET + "house_intact.glb", "x": -115.0, "z": -207.0, "yaw": 8.0, "scale": .78, "shadow": false},
		{"file": V9_ASSET + "house_damaged.glb", "x": -76.0, "z": -128.0, "yaw": -34.0, "scale": .82, "shadow": true},
		{"file": V9_CITY + "ordinary_house_textured.glb", "x": -63.0, "z": -151.0, "yaw": 16.0, "scale": .90, "shadow": false},
		{"file": V9_ASSET + "house_damaged.glb", "x": 88.0, "z": -132.0, "yaw": 27.0, "scale": .85, "shadow": true},
		{"file": V9_CITY + "ordinary_house_textured.glb", "x": 119.0, "z": -148.0, "yaw": -29.0, "scale": .96, "shadow": false},
		{"file": V9_ASSET + "house_intact.glb", "x": 153.0, "z": -159.0, "yaw": 42.0, "scale": .80, "shadow": false},
		{"file": V9_ASSET + "house_damaged.glb", "x": 187.0, "z": -184.0, "yaw": -11.0, "scale": .88, "shadow": false},
		{"file": V9_CITY + "ordinary_house_textured.glb", "x": 111.0, "z": -211.0, "yaw": 33.0, "scale": .91, "shadow": false},
		{"file": V9_ASSET + "house_intact.glb", "x": 204.0, "z": -226.0, "yaw": -38.0, "scale": .76, "shadow": false}
	]
	for i in range(hamlets.size()):
		var spec: Dictionary = hamlets[i]
		var x: float = spec["x"]
		var z: float = spec["z"]
		var house := spawn(spec["file"], Vector3(x, height_at(x, z), z), spec["scale"], spec["yaw"], true)
		house.name = "MID_BackgroundHamletV9_%02d" % i
		V9_BUDGET.apply_mid(house, spec["shadow"])

	# Keep real tree meshes, but organize them into edge groves rather than a
	# symmetric curtain. An independent RNG prevents this pass from perturbing Near.
	var grove_rng := RandomNumberGenerator.new()
	grove_rng.seed = 913227
	var grove_centers: Array[Vector2] = [
		Vector2(-208.0, -156.0), Vector2(-126.0, -244.0),
		Vector2(135.0, -178.0), Vector2(232.0, -252.0)
	]
	for i in range(60):
		var center: Vector2 = grove_centers[i % grove_centers.size()]
		var x := center.x + grove_rng.randf_range(-30.0, 30.0)
		var z := center.y + grove_rng.randf_range(-34.0, 34.0)
		# Preserve an open visual corridor from the Near anchor through the bridge.
		if x > 2.0 and x < 76.0 and z > -225.0 and z < -115.0:
			x += 70.0
		var tree_file := V9_ASSET + "fir_sapling_medium_" + str(i % 3) + ".glb"
		var tree := spawn(tree_file, Vector3(x, height_at(x, z), z), grove_rng.randf_range(.90, 1.85), grove_rng.randf() * 360.0)
		V9_BUDGET.apply_mid(tree, false)

	create_distant_forest()

func create_distant_forest() -> void:
	var file := V9_ASSET + "impostors/manifest.json"
	if not FileAccess.file_exists(file):
		return
	var records: Array = JSON.parse_string(FileAccess.get_file_as_string(file))
	var forest_rng := RandomNumberGenerator.new()
	forest_rng.seed = 440219
	# Separated woodland masses leave visible fields, settlement edges and a
	# strategic bridge corridor. Instance targets remain in the original class.
	var masses: Array[Dictionary] = [
		{"center": Vector2(-270.0, -505.0), "extent": Vector2(88.0, 145.0)},
		{"center": Vector2(-190.0, -315.0), "extent": Vector2(64.0, 96.0)},
		{"center": Vector2(-35.0, -535.0), "extent": Vector2(104.0, 118.0)},
		{"center": Vector2(150.0, -330.0), "extent": Vector2(72.0, 102.0)},
		{"center": Vector2(282.0, -505.0), "extent": Vector2(78.0, 138.0)}
	]
	for variant in range(records.size()):
		var record: Dictionary = records[variant]
		var mat := StandardMaterial3D.new()
		mat.albedo_texture = load(record["file"])
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
		mat.alpha_scissor_threshold = .10
		mat.cull_mode = BaseMaterial3D.CULL_DISABLED
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.billboard_mode = BaseMaterial3D.BILLBOARD_FIXED_Y
		mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
		var quad := QuadMesh.new()
		quad.size = Vector2.ONE * float(record["size"])
		quad.material = mat
		var mm := MultiMesh.new()
		mm.transform_format = MultiMesh.TRANSFORM_3D
		mm.mesh = quad
		var transforms: Array[Transform3D] = []
		var attempts := 520 if variant < 6 else 2100
		for i in range(attempts):
			var mass: Dictionary = masses[(i + variant * 2) % masses.size()]
			var center: Vector2 = mass["center"]
			var extent: Vector2 = mass["extent"]
			var x := center.x + forest_rng.randf_range(-extent.x, extent.x)
			var z := center.y + forest_rng.randf_range(-extent.y, extent.y)
			if z > -115.0 and z < -82.0:
				continue
			if x > -12.0 and x < 82.0 and z > -280.0 and z < -105.0:
				continue
			if noise.get_noise_2d(x * .8, z * .8) < -.20:
				continue
			var s := forest_rng.randf_range(1.1, 2.0)
			if variant >= 6:
				s *= 1.7
			transforms.append(Transform3D(Basis.IDENTITY.scaled(Vector3.ONE * s), Vector3(x, height_at(x, z) + float(record["center_y"]) * s, z)))
		mm.instance_count = transforms.size()
		for i in range(transforms.size()):
			mm.set_instance_transform(i, transforms[i])
		var inst := MultiMeshInstance3D.new()
		inst.name = "FAR_WoodlandMassV9_%02d" % variant
		inst.multimesh = mm
		inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(inst)
		V9_BUDGET.apply_far_always_visible(inst)

func create_mid_continuous_town() -> void:
	super.create_mid_continuous_town()
	# The source church imports with weak/unbound materials. Rebind it to the same
	# authored roof/stone language used by the approved local scene.
	var church := get_node_or_null("MID_ChurchSquareLandmarkV8")
	if church == null:
		return
	for child: Node in church.find_children("*", "MeshInstance3D", true, false):
		var mi := child as MeshInstance3D
		for i in range(mi.mesh.get_surface_count()):
			var source_mat := mi.get_active_material(i)
			var key: String = source_mat.resource_name.to_lower() if source_mat != null else ""
			mi.set_surface_override_material(i, mats["roof"] if "roof" in key else mats["stone"])

func create_mid_flank_landscape() -> void:
	var field_dry := surface("dirt_aerial_03", Color(.68, .59, .42), .35)
	var field_green := surface("leafy_grass", Color(.48, .56, .32), .42)
	var fields: Array[Dictionary] = [
		{"center": Vector2(-151.0, 49.0), "size": Vector2(102.0, 64.0), "yaw": 5.0, "mat": field_dry},
		{"center": Vector2(143.0, 43.0), "size": Vector2(82.0, 58.0), "yaw": -7.0, "mat": field_green},
		{"center": Vector2(-180.0, -34.0), "size": Vector2(73.0, 39.0), "yaw": -11.0, "mat": field_green},
		{"center": Vector2(182.0, -28.0), "size": Vector2(64.0, 42.0), "yaw": 14.0, "mat": field_dry},
		{"center": Vector2(-118.0, -71.0), "size": Vector2(58.0, 27.0), "yaw": 9.0, "mat": field_dry},
		{"center": Vector2(115.0, -61.0), "size": Vector2(68.0, 31.0), "yaw": -16.0, "mat": field_green}
	]
	for i in range(fields.size()):
		var spec: Dictionary = fields[i]
		var patch := create_field_plane(spec["center"], spec["size"], spec["mat"])
		patch.name = "MID_IrregularFieldV9_%02d" % i
		patch.rotation_degrees.y = spec["yaw"]

	var edge_trees: Array[Vector2] = [
		Vector2(-215, 78), Vector2(-184, 68), Vector2(-149, 57), Vector2(-121, 40),
		Vector2(-210, -54), Vector2(-166, -61), Vector2(-132, -83),
		Vector2(102, 82), Vector2(136, 67), Vector2(177, 55), Vector2(211, 35),
		Vector2(157, -50), Vector2(196, -68), Vector2(228, -91),
		Vector2(87, -72), Vector2(-86, -84)
	]
	var edge_rng := RandomNumberGenerator.new()
	edge_rng.seed = 771305
	for p in edge_trees:
		var tree := spawn(V9_ASSET + "island_tree_01_0.glb", Vector3(p.x, height_at(p.x, p.y), p.y), edge_rng.randf_range(.92, 1.28), edge_rng.randf() * 360.0)
		V9_BUDGET.apply_mid(tree, false)
		mid_trees += 1

func create_far_campaign_horizon() -> void:
	var concrete := simple(Color(.38, .36, .31), .86)
	var brick := simple(Color(.36, .28, .22), .88)
	var roof := simple(Color(.20, .19, .17), .90)
	var masses: Array[Dictionary] = [
		{"x": -278.0, "z": -438.0, "size": Vector3(48, 11, 31), "yaw": 7.0, "mat": concrete},
		{"x": -218.0, "z": -474.0, "size": Vector3(26, 19, 23), "yaw": -9.0, "mat": brick},
		{"x": -164.0, "z": -416.0, "size": Vector3(39, 13, 27), "yaw": 13.0, "mat": concrete},
		{"x": -64.0, "z": -486.0, "size": Vector3(53, 15, 29), "yaw": -6.0, "mat": brick},
		{"x": 12.0, "z": -449.0, "size": Vector3(25, 23, 20), "yaw": 4.0, "mat": concrete},
		{"x": 119.0, "z": -424.0, "size": Vector3(45, 12, 34), "yaw": -12.0, "mat": brick},
		{"x": 192.0, "z": -472.0, "size": Vector3(31, 18, 25), "yaw": 9.0, "mat": concrete},
		{"x": 265.0, "z": -431.0, "size": Vector3(51, 10, 37), "yaw": -5.0, "mat": brick}
	]
	for i in range(masses.size()):
		var spec: Dictionary = masses[i]
		var x: float = spec["x"]
		var z: float = spec["z"]
		var size3: Vector3 = spec["size"]
		var body := block(Vector3(x, height_at(x, z) + size3.y * .5, z), size3, "stone")
		body.name = "FAR_AsymmetricCampaignMassV9_%02d" % i
		body.rotation_degrees.y = spec["yaw"]
		body.material_override = spec["mat"]
		V9_BUDGET.apply_far_always_visible(body)
		var cap := block(Vector3(x, height_at(x, z) + size3.y + 1.25, z), Vector3(size3.x * .62, 2.5, size3.z * .66), "roof")
		cap.rotation_degrees.y = spec["yaw"]
		cap.material_override = roof
		V9_BUDGET.apply_far_always_visible(cap)
		far_buildings += 1

	for spec in [Vector2(-232.0, -455.0), Vector2(-34.0, -510.0), Vector2(214.0, -451.0)]:
		var stack_mesh := CylinderMesh.new()
		stack_mesh.top_radius = 1.7
		stack_mesh.bottom_radius = 2.1
		stack_mesh.height = 38.0
		stack_mesh.radial_segments = 8
		var stack := add_mesh(stack_mesh, mats["stone"], Vector3(spec.x, height_at(spec.x, spec.y) + 19.0, spec.y))
		V9_BUDGET.apply_far_always_visible(stack)
