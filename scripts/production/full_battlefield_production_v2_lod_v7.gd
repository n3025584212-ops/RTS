extends "res://scripts/production/full_battlefield_production_v2_lod_v5.gd"
## Authored town-composition pass on the last proven Run #8 lineage.
## The old 3x7 row/column generator is replaced rather than decorated. Reference
## code is retained for materials, terrain, LOD and bridge quality, not spatial layout.

const TOWN_ASSET := "res://assets/visual_slice/"
const TOWN_CITY_REAL := "res://assets/golden_scene/city_real/"
const TOWN_BUDGET = preload("res://scripts/production/battlefield_visual_budget.gd")

func create_mid_continuous_town() -> void:
	# Explicit parcels: irregular frontages, setbacks, damage gaps and courtyards.
	# Keep the strategic bridge approach at x≈15..55 / z≈-145..-178 open.
	# V5 adds three exact HF town-front anchors after this inherited call returns.
	var parcels: Array[Dictionary] = [
		{"file": TOWN_ASSET + "house_damaged.glb", "x": -76.0, "z": -160.0, "yaw": 19.0, "scale": .86, "shadow": true},
		{"file": TOWN_CITY_REAL + "ordinary_house_textured.glb", "x": -47.0, "z": -174.0, "yaw": -24.0, "scale": .94, "shadow": false},
		{"file": TOWN_ASSET + "house_intact.glb", "x": -111.0, "z": -184.0, "yaw": 38.0, "scale": .80, "shadow": false},
		{"file": TOWN_ASSET + "hero_house_ruined.glb", "x": -72.0, "z": -205.0, "yaw": -12.0, "scale": .76, "shadow": false},
		{"file": TOWN_CITY_REAL + "ordinary_house_textured.glb", "x": -126.0, "z": -220.0, "yaw": 51.0, "scale": .88, "shadow": false},
		{"file": TOWN_ASSET + "house_damaged.glb", "x": -91.0, "z": -242.0, "yaw": 7.0, "scale": .92, "shadow": false},

		{"file": TOWN_ASSET + "house_intact.glb", "x": -31.0, "z": -164.0, "yaw": -33.0, "scale": .83, "shadow": true},
		{"file": TOWN_CITY_REAL + "ordinary_house_textured.glb", "x": -17.0, "z": -193.0, "yaw": 13.0, "scale": .98, "shadow": false},
		{"file": TOWN_ASSET + "house_damaged.glb", "x": -45.0, "z": -222.0, "yaw": 44.0, "scale": .75, "shadow": false},
		{"file": TOWN_ASSET + "house_intact.glb", "x": 2.0, "z": -235.0, "yaw": -21.0, "scale": .90, "shadow": false},
		{"file": TOWN_ASSET + "hero_house_ruined.glb", "x": 29.0, "z": -211.0, "yaw": 26.0, "scale": .72, "shadow": false},
		{"file": TOWN_CITY_REAL + "ordinary_house_textured.glb", "x": 57.0, "z": -186.0, "yaw": -36.0, "scale": .96, "shadow": true},

		{"file": TOWN_ASSET + "house_damaged.glb", "x": 80.0, "z": -164.0, "yaw": 29.0, "scale": .87, "shadow": true},
		{"file": TOWN_ASSET + "house_intact.glb", "x": 102.0, "z": -185.0, "yaw": -16.0, "scale": .81, "shadow": false},
		{"file": TOWN_CITY_REAL + "ordinary_house_textured.glb", "x": 143.0, "z": -177.0, "yaw": 37.0, "scale": .94, "shadow": false},
		{"file": TOWN_ASSET + "house_damaged.glb", "x": 159.0, "z": -207.0, "yaw": -31.0, "scale": .76, "shadow": false},
		{"file": TOWN_ASSET + "house_intact.glb", "x": 92.0, "z": -226.0, "yaw": 9.0, "scale": 1.02, "shadow": false},
		{"file": TOWN_CITY_REAL + "ordinary_house_textured.glb", "x": 137.0, "z": -249.0, "yaw": -42.0, "scale": .86, "shadow": false}
	]

	for parcel: Dictionary in parcels:
		var house := spawn_mid_house(
			parcel["file"] as String,
			parcel["x"] as float,
			parcel["z"] as float,
			parcel["yaw"] as float,
			parcel["scale"] as float,
			parcel["shadow"] as bool
		)
		house.name = "MID_AuthoredTown_%02d" % mid_buildings

	# Open civic square + offset landmark rather than a grid endpoint.
	var church_x := 166.0
	var church_z := -238.0
	var church := spawn(TOWN_CITY_REAL + "church_landmark.glb", Vector3(church_x, height_at(church_x, church_z), church_z), 1.24, -13.0)
	church.name = "MID_ChurchSquareLandmark"
	TOWN_BUDGET.apply_mid(church, true)
	mid_buildings += 1

	# Courtyard and garden boundaries create different parcel silhouettes without
	# paying for another large unique-asset set.
	add_town_wall(Vector3(-56.0, height_at(-56.0, -190.0) + .45, -190.0), Vector3(17.0, .90, .55), -10.0)
	add_town_wall(Vector3(111.0, height_at(111.0, -202.0) + .45, -202.0), Vector3(20.0, .90, .55), 24.0)
	add_town_wall(Vector3(145.0, height_at(145.0, -219.0) + .45, -219.0), Vector3(15.0, .90, .55), -33.0)
	add_town_wall(Vector3(-20.0, height_at(-20.0, -214.0) + .45, -214.0), Vector3(13.0, .90, .55), 42.0)

	# Damage is clustered around specific lots and one shell gap, not uniformly
	# sprinkled over a rectangle as in the rejected procedural version.
	var rubble_centers: Array[Vector2] = [
		Vector2(-72.0, -205.0), Vector2(-45.0, -222.0),
		Vector2(29.0, -211.0), Vector2(159.0, -207.0),
		Vector2(44.0, -174.0)
	]
	var rubble_mesh := fragment_mesh(771)
	var rubble_mat := surface("plastered_wall_02", Color(.46, .43, .38), .55)
	var transforms: Array[Transform3D] = []
	var rr := RandomNumberGenerator.new()
	rr.seed = 55891
	for i in range(145):
		var center: Vector2 = rubble_centers[i % rubble_centers.size()]
		var x := center.x + rr.randf_range(-9.0, 9.0)
		var z := center.y + rr.randf_range(-7.0, 7.0)
		var size3 := Vector3(rr.randf_range(.12, .46), rr.randf_range(.08, .27), rr.randf_range(.14, .52))
		var basis := Basis.from_euler(Vector3(rr.randf_range(-.45, .45), rr.randf() * TAU, rr.randf_range(-.35, .35))).scaled(size3)
		transforms.append(Transform3D(basis, Vector3(x, height_at(x, z) + .05, z)))
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = rubble_mesh
	mm.instance_count = transforms.size()
	for i in range(transforms.size()):
		mm.set_instance_transform(i, transforms[i])
	var rubble := MultiMeshInstance3D.new()
	rubble.name = "MID_AuthoredDamageClusters"
	rubble.multimesh = mm
	rubble.material_override = rubble_mat
	add_child(rubble)
	TOWN_BUDGET.apply_mid(rubble, false)

	print("FRONTLINE_TOWN_COMPOSITION_READY houses=", parcels.size(), " layout=authored_asymmetric bridge_corridor=open")

func add_town_wall(position3: Vector3, size3: Vector3, yaw: float) -> void:
	var wall := block(position3, size3, "stone")
	wall.rotation_degrees.y = yaw
	TOWN_BUDGET.apply_mid(wall, false)
