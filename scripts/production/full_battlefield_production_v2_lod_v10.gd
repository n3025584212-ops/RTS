extends "res://scripts/production/full_battlefield_production_v2_lod_v9.gd"
## V10 single-fix candidate.
## Near, camera, bridge, terrain, grass, lighting, V9 woodland masses and FAR skyline
## remain inherited. Only the MID/BACKGROUND settlement assets and spacing are
## replaced so the white proxy-like buildings seen in the V9 proof cannot recur.

const V10_ASSET := "res://assets/visual_slice/"
const V10_CITY := "res://assets/golden_scene/city_real/"
const V10_BUDGET = preload("res://scripts/production/battlefield_visual_budget.gd")

func _ready() -> void:
	super._ready()
	print("FRONTLINE_FULL_BATTLEFIELD_V2_LOD_V10_READY settlement=proven_assets_only layering=staggered near=preserved")

func create_background() -> void:
	# Two secondary hamlet groups with front/back depth, using only house assets
	# already proven in the successful Probe-D render. No ordinary_house_textured.
	var hamlets: Array[Dictionary] = [
		{"file": V10_ASSET + "house_intact.glb", "x": -184.0, "z": -134.0, "yaw": 27.0, "scale": .84, "shadow": false},
		{"file": V10_ASSET + "house_damaged.glb", "x": -146.0, "z": -158.0, "yaw": -21.0, "scale": .91, "shadow": true},
		{"file": V10_ASSET + "house_intact.glb", "x": -205.0, "z": -192.0, "yaw": 43.0, "scale": .79, "shadow": false},
		{"file": V10_ASSET + "house_damaged.glb", "x": -121.0, "z": -216.0, "yaw": 9.0, "scale": .86, "shadow": false},
		{"file": V10_ASSET + "house_intact.glb", "x": -165.0, "z": -257.0, "yaw": -34.0, "scale": .76, "shadow": false},
		{"file": V10_ASSET + "house_damaged.glb", "x": 103.0, "z": -136.0, "yaw": 24.0, "scale": .86, "shadow": true},
		{"file": V10_ASSET + "house_intact.glb", "x": 151.0, "z": -166.0, "yaw": -31.0, "scale": .92, "shadow": false},
		{"file": V10_ASSET + "house_damaged.glb", "x": 202.0, "z": -197.0, "yaw": 39.0, "scale": .82, "shadow": false},
		{"file": V10_ASSET + "house_intact.glb", "x": 124.0, "z": -224.0, "yaw": 14.0, "scale": .79, "shadow": false},
		{"file": V10_ASSET + "house_damaged.glb", "x": 187.0, "z": -263.0, "yaw": -28.0, "scale": .76, "shadow": false}
	]
	for i in range(hamlets.size()):
		var spec: Dictionary = hamlets[i]
		var x: float = spec["x"]
		var z: float = spec["z"]
		var house := spawn(spec["file"], Vector3(x, height_at(x, z), z), spec["scale"], spec["yaw"], true)
		house.name = "MID_BackgroundHamletV10_%02d" % i
		V10_BUDGET.apply_mid(house, spec["shadow"])

	# Keep the V9 broken-grove idea, but bias real-tree groups around the hamlets
	# instead of forming a continuous line behind them.
	var grove_rng := RandomNumberGenerator.new()
	grove_rng.seed = 101023
	var grove_centers: Array[Vector2] = [
		Vector2(-221.0, -164.0), Vector2(-148.0, -251.0),
		Vector2(153.0, -188.0), Vector2(225.0, -270.0)
	]
	for i in range(56):
		var center: Vector2 = grove_centers[i % grove_centers.size()]
		var x := center.x + grove_rng.randf_range(-29.0, 29.0)
		var z := center.y + grove_rng.randf_range(-31.0, 31.0)
		if x > -8.0 and x < 82.0 and z > -230.0 and z < -110.0:
			x += 76.0
		var tree_file := V10_ASSET + "fir_sapling_medium_" + str(i % 3) + ".glb"
		var tree := spawn(tree_file, Vector3(x, height_at(x, z), z), grove_rng.randf_range(.90, 1.82), grove_rng.randf() * 360.0)
		V10_BUDGET.apply_mid(tree, false)

	# Inherited V9 implementation creates separated FAR woodland masses.
	create_distant_forest()

func create_mid_continuous_town() -> void:
	# Main settlement: 18 parcels, all from the already rendered visual-slice house
	# family. Depth bands and irregular setbacks prevent a horizontal parade line.
	var parcels: Array[Dictionary] = [
		{"file": V10_ASSET + "house_damaged.glb", "x": -82.0, "z": -158.0, "yaw": 18.0, "scale": .88, "shadow": true},
		{"file": V10_ASSET + "house_intact.glb", "x": -51.0, "z": -179.0, "yaw": -27.0, "scale": .92, "shadow": false},
		{"file": V10_ASSET + "house_damaged.glb", "x": -116.0, "z": -194.0, "yaw": 41.0, "scale": .81, "shadow": false},
		{"file": V10_ASSET + "house_intact.glb", "x": -72.0, "z": -217.0, "yaw": -13.0, "scale": .79, "shadow": false},
		{"file": V10_ASSET + "house_damaged.glb", "x": -134.0, "z": -235.0, "yaw": 52.0, "scale": .87, "shadow": false},
		{"file": V10_ASSET + "house_intact.glb", "x": -95.0, "z": -262.0, "yaw": 6.0, "scale": .90, "shadow": false},
		{"file": V10_ASSET + "house_damaged.glb", "x": -34.0, "z": -163.0, "yaw": -35.0, "scale": .84, "shadow": true},
		{"file": V10_ASSET + "house_intact.glb", "x": -22.0, "z": -201.0, "yaw": 16.0, "scale": .91, "shadow": false},
		{"file": V10_ASSET + "house_damaged.glb", "x": -49.0, "z": -236.0, "yaw": 45.0, "scale": .77, "shadow": false},
		{"file": V10_ASSET + "house_intact.glb", "x": 1.0, "z": -252.0, "yaw": -22.0, "scale": .86, "shadow": false},
		{"file": V10_ASSET + "house_damaged.glb", "x": 31.0, "z": -221.0, "yaw": 29.0, "scale": .74, "shadow": false},
		{"file": V10_ASSET + "house_intact.glb", "x": 62.0, "z": -194.0, "yaw": -39.0, "scale": .90, "shadow": true},
		{"file": V10_ASSET + "house_damaged.glb", "x": 84.0, "z": -163.0, "yaw": 31.0, "scale": .88, "shadow": true},
		{"file": V10_ASSET + "house_intact.glb", "x": 111.0, "z": -190.0, "yaw": -19.0, "scale": .82, "shadow": false},
		{"file": V10_ASSET + "house_damaged.glb", "x": 149.0, "z": -181.0, "yaw": 36.0, "scale": .91, "shadow": false},
		{"file": V10_ASSET + "house_intact.glb", "x": 166.0, "z": -218.0, "yaw": -33.0, "scale": .78, "shadow": false},
		{"file": V10_ASSET + "house_damaged.glb", "x": 101.0, "z": -239.0, "yaw": 11.0, "scale": .98, "shadow": false},
		{"file": V10_ASSET + "house_intact.glb", "x": 143.0, "z": -267.0, "yaw": -45.0, "scale": .84, "shadow": false}
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
		house.name = "MID_AuthoredTownV10_%02d" % mid_buildings

	var church_x := 176.0
	var church_z := -246.0
	var church := spawn(V10_CITY + "church_landmark.glb", Vector3(church_x, height_at(church_x, church_z), church_z), 1.18, -15.0)
	church.name = "MID_ChurchSquareLandmarkV10"
	V10_BUDGET.apply_mid(church, true)
	mid_buildings += 1
	# Explicit material rebind keeps the church from becoming a white beacon.
	for child: Node in church.find_children("*", "MeshInstance3D", true, false):
		var mi := child as MeshInstance3D
		for i in range(mi.mesh.get_surface_count()):
			var source_mat := mi.get_active_material(i)
			var key: String = source_mat.resource_name.to_lower() if source_mat != null else ""
			mi.set_surface_override_material(i, mats["roof"] if "roof" in key else mats["stone"])
