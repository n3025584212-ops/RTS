extends "res://scripts/production/full_battlefield_production_v2_lod_v5.gd"
## Probe B keeps the authored V7 parcel layout and original V7 house asset mix,
## while excluding the extra walls and rubble layer. This isolates imported-house
## and material cost from the secondary destruction-detail layer.

const PROBE_ASSET := "res://assets/visual_slice/"
const PROBE_CITY_REAL := "res://assets/golden_scene/city_real/"
const PROBE_BUDGET = preload("res://scripts/production/battlefield_visual_budget.gd")

func create_mid_continuous_town() -> void:
	var parcels: Array[Dictionary] = [
		{"file": PROBE_ASSET + "house_damaged.glb", "x": -76.0, "z": -160.0, "yaw": 19.0, "scale": .86, "shadow": true},
		{"file": PROBE_CITY_REAL + "ordinary_house_textured.glb", "x": -47.0, "z": -174.0, "yaw": -24.0, "scale": .94, "shadow": false},
		{"file": PROBE_ASSET + "house_intact.glb", "x": -111.0, "z": -184.0, "yaw": 38.0, "scale": .80, "shadow": false},
		{"file": PROBE_ASSET + "hero_house_ruined.glb", "x": -72.0, "z": -205.0, "yaw": -12.0, "scale": .76, "shadow": false},
		{"file": PROBE_CITY_REAL + "ordinary_house_textured.glb", "x": -126.0, "z": -220.0, "yaw": 51.0, "scale": .88, "shadow": false},
		{"file": PROBE_ASSET + "house_damaged.glb", "x": -91.0, "z": -242.0, "yaw": 7.0, "scale": .92, "shadow": false},
		{"file": PROBE_ASSET + "house_intact.glb", "x": -31.0, "z": -164.0, "yaw": -33.0, "scale": .83, "shadow": true},
		{"file": PROBE_CITY_REAL + "ordinary_house_textured.glb", "x": -17.0, "z": -193.0, "yaw": 13.0, "scale": .98, "shadow": false},
		{"file": PROBE_ASSET + "house_damaged.glb", "x": -45.0, "z": -222.0, "yaw": 44.0, "scale": .75, "shadow": false},
		{"file": PROBE_ASSET + "house_intact.glb", "x": 2.0, "z": -235.0, "yaw": -21.0, "scale": .90, "shadow": false},
		{"file": PROBE_ASSET + "hero_house_ruined.glb", "x": 29.0, "z": -211.0, "yaw": 26.0, "scale": .72, "shadow": false},
		{"file": PROBE_CITY_REAL + "ordinary_house_textured.glb", "x": 57.0, "z": -186.0, "yaw": -36.0, "scale": .96, "shadow": true},
		{"file": PROBE_ASSET + "house_damaged.glb", "x": 80.0, "z": -164.0, "yaw": 29.0, "scale": .87, "shadow": true},
		{"file": PROBE_ASSET + "house_intact.glb", "x": 102.0, "z": -185.0, "yaw": -16.0, "scale": .81, "shadow": false},
		{"file": PROBE_CITY_REAL + "ordinary_house_textured.glb", "x": 143.0, "z": -177.0, "yaw": 37.0, "scale": .94, "shadow": false},
		{"file": PROBE_ASSET + "house_damaged.glb", "x": 159.0, "z": -207.0, "yaw": -31.0, "scale": .76, "shadow": false},
		{"file": PROBE_ASSET + "house_intact.glb", "x": 92.0, "z": -226.0, "yaw": 9.0, "scale": 1.02, "shadow": false},
		{"file": PROBE_CITY_REAL + "ordinary_house_textured.glb", "x": 137.0, "z": -249.0, "yaw": -42.0, "scale": .86, "shadow": false}
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
		house.name = "MID_ProbeB_AuthoredTown_%02d" % mid_buildings

	var church_x := 166.0
	var church_z := -238.0
	var church := spawn(PROBE_CITY_REAL + "church_landmark.glb", Vector3(church_x, height_at(church_x, church_z), church_z), 1.24, -13.0)
	church.name = "MID_ProbeB_ChurchSquareLandmark"
	PROBE_BUDGET.apply_mid(church, true)
	mid_buildings += 1

	print("FRONTLINE_TOWN_PROBE_B_READY houses=", parcels.size(), " layout=authored_asymmetric assets=v7_original extras=none")
