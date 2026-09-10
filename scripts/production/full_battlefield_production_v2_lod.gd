extends "res://scripts/production/river_town_hero_shot_v2.gd"
## Full-battlefield composition grown outward from the current Hero Shot V2.
## Near: exact local-fidelity scene, untouched.
## Mid: real battlefield assets with bounded visibility and reduced shadow cost.
## Far: silhouette/density layer with no realtime shadow or GI cost.

const FULL_OUT := "res://artifacts/full_battlefield_v2_lod"
const VISUAL_BUDGET = preload("res://scripts/production/battlefield_visual_budget.gd")
const CITY_REAL := "res://assets/golden_scene/city_real/"
const VEHICLES := "res://assets/golden_scene/vehicles/"

var mid_units := 0
var mid_buildings := 0
var far_buildings := 0
var mid_trees := 0

func _ready() -> void:
	# This creates the exact current local Hero Shot V2 first: terrain, 99k grass,
	# authored urban ruin, authored Abrams, rubble, ruts, puddles, bridge and atmosphere.
	super._ready()

	create_mid_operational_roads()
	create_mid_bridgehead_force()
	create_mid_continuous_town()
	create_mid_flank_landscape()
	create_far_campaign_horizon()

	# Oblique acceptance framing: local-fidelity foreground remains large and readable,
	# while the bridge, continuous town and campaign horizon stay in the same viewport.
	camera.position = Vector3(75.0, 20.0, 45.0)
	camera.look_at(Vector3(0.0, 2.0, -115.0))
	camera.fov = 52.0
	camera.near = 0.25
	camera.far = 1250.0
	camera.current = true

	print("FRONTLINE_FULL_BATTLEFIELD_V2_LOD_READY renderer=", RenderingServer.get_current_rendering_method(),
		" adapter=", RenderingServer.get_video_adapter_name(),
		" near=hero_v2_exact mid_units=", mid_units,
		" mid_buildings=", mid_buildings,
		" far_buildings=", far_buildings,
		" mid_trees=", mid_trees,
		" grass=", grass_instance_count)

func create_road_strip(a: Vector2, b: Vector2, width: float, material: Material) -> MeshInstance3D:
	var direction := (b - a).normalized()
	var side := Vector2(-direction.y, direction.x)
	var length := a.distance_to(b)
	var steps := maxi(4, int(length / 3.5))
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(steps):
		var t0 := float(i) / float(steps)
		var t1 := float(i + 1) / float(steps)
		var c0 := a.lerp(b, t0)
		var c1 := a.lerp(b, t1)
		var l0 := c0 + side * width * .5
		var r0 := c0 - side * width * .5
		var l1 := c1 + side * width * .5
		var r1 := c1 - side * width * .5
		for p in [l0, r0, r1, l0, r1, l1]:
			st.set_uv(p * .075)
			st.add_vertex(Vector3(p.x, height_at(p.x, p.y) + .055, p.y))
	st.generate_normals()
	st.generate_tangents()
	var road := MeshInstance3D.new()
	road.mesh = st.commit()
	road.material_override = material
	road.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(road)
	VISUAL_BUDGET.apply_mid(road, false)
	return road

func create_mid_operational_roads() -> void:
	# The near physical rut system remains unchanged. These are only its mid-distance continuations.
	var road_mat := surface("dirt_aerial_03", Color(.42, .34, .22), .48)
	road_mat.roughness = .82
	create_road_strip(Vector2(5, 35), Vector2(29, -67), 6.2, road_mat)
	create_road_strip(Vector2(35, -132), Vector2(43, -160), 7.2, road_mat)
	create_road_strip(Vector2(43, -160), Vector2(143, -220), 6.6, road_mat)
	create_road_strip(Vector2(43, -160), Vector2(-92, -232), 5.8, road_mat)

func spawn_mid_vehicle(file: String, x: float, z: float, yaw: float, scale3: float = 1.0, shadow: bool = false) -> Node3D:
	var vehicle := spawn(file, Vector3(x, height_at(x, z) + .035, z), scale3, yaw)
	VISUAL_BUDGET.apply_mid(vehicle, shadow)
	mid_units += 1
	return vehicle

func create_mid_bridgehead_force() -> void:
	# Deliberately small: one exact Hero Abrams already anchors the foreground.
	# Mid vehicles communicate force density without duplicating Hero-level material cost.
	for spec in [
		Vector4(-36, 42, 168, .92), Vector4(38, 38, 174, .94),
		Vector4(-62, 18, 171, .90), Vector4(67, 13, 177, .90),
		Vector4(28, -48, 179, .88), Vector4(35, -72, 180, .86)
	]:
		var s: Vector4 = spec
		spawn_mid_vehicle(ASSET + "abrams.glb", s.x, s.y, s.z, s.w, s.y > 30.0)
	for spec in [
		Vector4(-48, 28, 172, .74), Vector4(51, 24, 176, .74),
		Vector4(24, -57, 180, .72), Vector4(42, -82, 180, .72)
	]:
		var s: Vector4 = spec
		spawn_mid_vehicle(VEHICLES + "ifv.glb", s.x, s.y, s.z, s.w, false)

func spawn_mid_house(file: String, x: float, z: float, yaw: float, scale3: float, shadow: bool) -> Node3D:
	var house := spawn(file, Vector3(x, height_at(x, z), z), scale3, yaw, true)
	VISUAL_BUDGET.apply_mid(house, shadow)
	mid_buildings += 1
	return house

func create_mid_continuous_town() -> void:
	# The exact Hero V2 ruin remains the near architectural quality anchor.
	# Beyond the river, a compact real-asset town creates continuous mass without
	# repeating the full Hero ruin nine times (the V2 timeout failure mode).
	var houses: Array[String] = [ASSET + "house_damaged.glb", ASSET + "house_intact.glb"]
	for row in range(3):
		for col in range(7):
			if col == 3:
				continue
			var x := -70.0 + col * 28.0 + rng.randf_range(-2.2, 2.2)
			var z := -164.0 - row * 30.0 + rng.randf_range(-2.0, 2.0)
			spawn_mid_house(houses[(row + col) % 2], x, z, rng.randf_range(-9.0, 9.0), rng.randf_range(.82, .98), row == 0 and col % 2 == 0)

	var church := spawn(CITY_REAL + "church_landmark.glb", Vector3(136, height_at(136, -230), -230), 1.32, -4)
	VISUAL_BUDGET.apply_mid(church, true)
	mid_buildings += 1

	# Cheap rubble reads as a destroyed urban front but uses one MultiMesh.
	var rubble_mesh := fragment_mesh(771)
	var rubble_mat := surface("plastered_wall_02", Color(.46, .43, .38), .55)
	var transforms: Array[Transform3D] = []
	var rr := RandomNumberGenerator.new()
	rr.seed = 55891
	for i in range(180):
		var x := rr.randf_range(-86, 170)
		var z := rr.randf_range(-235, -150)
		var size3 := Vector3(rr.randf_range(.12, .42), rr.randf_range(.08, .24), rr.randf_range(.14, .48))
		transforms.append(Transform3D(Basis.from_euler(Vector3(rr.randf_range(-.4, .4), rr.randf() * TAU, rr.randf_range(-.3, .3))).scaled(size3), Vector3(x, height_at(x, z) + .05, z)))
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = rubble_mesh
	mm.instance_count = transforms.size()
	for i in range(transforms.size()):
		mm.set_instance_transform(i, transforms[i])
	var rubble := MultiMeshInstance3D.new()
	rubble.name = "MID_UrbanRubble"
	rubble.multimesh = mm
	rubble.material_override = rubble_mat
	add_child(rubble)
	VISUAL_BUDGET.apply_mid(rubble, false)

func create_field_plane(center: Vector2, size2: Vector2, material: Material) -> MeshInstance3D:
	var plane := PlaneMesh.new()
	plane.size = size2
	var node := add_mesh(plane, material, Vector3(center.x, height_at(center.x, center.y) + .035, center.y))
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	VISUAL_BUDGET.apply_mid(node, false)
	return node

func create_mid_flank_landscape() -> void:
	var field_dry := surface("dirt_aerial_03", Color(.68, .59, .42), .35)
	var field_green := surface("leafy_grass", Color(.48, .56, .32), .42)
	create_field_plane(Vector2(-145, 45), Vector2(100, 70), field_dry)
	create_field_plane(Vector2(143, 42), Vector2(98, 72), field_green)
	create_field_plane(Vector2(-168, -34), Vector2(90, 45), field_green)
	create_field_plane(Vector2(173, -33), Vector2(86, 48), field_dry)

	# Sparse real trees in mid distance; the inherited background already supplies
	# low-cost forest mass, so do not create another thousands-instance forest.
	for p in [
		Vector2(-205, 88), Vector2(-184, 74), Vector2(-162, 63), Vector2(-137, 55),
		Vector2(112, 86), Vector2(137, 72), Vector2(164, 60), Vector2(190, 49),
		Vector2(-214, -58), Vector2(-181, -65), Vector2(182, -61), Vector2(214, -72)
	]:
		var tree := spawn(ASSET + "island_tree_01_0.glb", Vector3(p.x, height_at(p.x, p.y), p.y), rng.randf_range(.95, 1.25), rng.randf() * 360.0)
		VISUAL_BUDGET.apply_mid(tree, false)
		mid_trees += 1

func create_far_campaign_horizon() -> void:
	# Far layer exists for campaign scale only. It uses very cheap silhouette masses,
	# no realtime shadows, no GI, no new reflection probe and no extra volumetric fog.
	var concrete := simple(Color(.33, .34, .32), .86)
	var roof := simple(Color(.20, .19, .17), .90)
	for i in range(12):
		var x := -245.0 + i * 45.0
		var z := -390.0 - float(i % 3) * 18.0
		var body := block(Vector3(x, height_at(x, z) + 7.0, z), Vector3(30, 14, 24), "stone")
		body.material_override = concrete
		VISUAL_BUDGET.apply_far_always_visible(body)
		var top := block(Vector3(x, height_at(x, z) + 15.0, z), Vector3(19, 3.0, 17), "roof")
		top.material_override = roof
		VISUAL_BUDGET.apply_far_always_visible(top)
		far_buildings += 1
	for x in [-190.0, -65.0, 78.0, 205.0]:
		var z := -440.0
		var stack_mesh := CylinderMesh.new()
		stack_mesh.top_radius = 1.8
		stack_mesh.bottom_radius = 1.8
		stack_mesh.height = 44.0
		stack_mesh.radial_segments = 8
		var stack := add_mesh(stack_mesh, mats["stone"], Vector3(x, height_at(x, z) + 22.0, z))
		VISUAL_BUDGET.apply_far_always_visible(stack)

func capture() -> void:
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(FULL_OUT)
	var image := get_viewport().get_texture().get_image()
	var path := FULL_OUT + "/full_battlefield_v2_lod_actual_1920x1080.png"
	var err := image.save_png(path)
	var report := {
		"captured_at_utc": Time.get_datetime_string_from_system(true),
		"engine": Engine.get_version_info(),
		"renderer": RenderingServer.get_current_rendering_method(),
		"gpu": RenderingServer.get_video_adapter_name(),
		"width": image.get_width(),
		"height": image.get_height(),
		"save_error": err,
		"camera_position": str(camera.position),
		"camera_rotation": str(camera.rotation_degrees),
		"fov": camera.fov,
		"capture_frame": capture_frame,
		"internal_3d_render_scale": get_viewport().scaling_3d_scale,
		"msaa_3d": get_viewport().msaa_3d,
		"post_capture_image_editing": false,
		"gameplay_changes": false,
		"near_quality_source": "RiverTownHeroShotV2 exact inherited composition",
		"near_terrain_spacing_m": .16,
		"road_detail_spacing_m": .08,
		"grass_instances": grass_instance_count,
		"mid_units": mid_units,
		"mid_buildings": mid_buildings,
		"far_buildings": far_buildings,
		"mid_trees": mid_trees,
		"lod_policy": "near exact / mid bounded real assets / far no realtime shadow or GI",
		"draw_calls": Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
		"rendered_primitives": Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME),
		"visual_acceptance": "NOT_CLAIMED"
	}
	FileAccess.open(FULL_OUT + "/runtime_metrics.json", FileAccess.WRITE).store_string(JSON.stringify(report, "\t"))
	print("FRONTLINE_FULL_BATTLEFIELD_V2_LOD_CAPTURED ", path, " ", image.get_size(), " renderer=", report.renderer)
	get_tree().quit(err)
