extends "res://scripts/production/full_battlefield_production_v2_lod_v5.gd"
## Probe A isolates spatial composition from asset/material cost.
## It keeps the authored asymmetric V7 parcel layout but uses only house assets
## already proven on the Run #8 production lineage. No extra walls or rubble are
## added in this probe.

const PROBE_ASSET := "res://assets/visual_slice/"
const PROBE_CITY_REAL := "res://assets/golden_scene/city_real/"
const PROBE_BUDGET = preload("res://scripts/production/battlefield_visual_budget.gd")

func create_mid_continuous_town() -> void:
	var parcels: Array[Dictionary] = [
		{"x": -76.0, "z": -160.0, "yaw": 19.0, "scale": .86, "shadow": true},
		{"x": -47.0, "z": -174.0, "yaw": -24.0, "scale": .94, "shadow": false},
		{"x": -111.0, "z": -184.0, "yaw": 38.0, "scale": .80, "shadow": false},
		{"x": -72.0, "z": -205.0, "yaw": -12.0, "scale": .76, "shadow": false},
		{"x": -126.0, "z": -220.0, "yaw": 51.0, "scale": .88, "shadow": false},
		{"x": -91.0, "z": -242.0, "yaw": 7.0, "scale": .92, "shadow": false},
		{"x": -31.0, "z": -164.0, "yaw": -33.0, "scale": .83, "shadow": true},
		{"x": -17.0, "z": -193.0, "yaw": 13.0, "scale": .98, "shadow": false},
		{"x": -45.0, "z": -222.0, "yaw": 44.0, "scale": .75, "shadow": false},
		{"x": 2.0, "z": -235.0, "yaw": -21.0, "scale": .90, "shadow": false},
		{"x": 29.0, "z": -211.0, "yaw": 26.0, "scale": .72, "shadow": false},
		{"x": 57.0, "z": -186.0, "yaw": -36.0, "scale": .96, "shadow": true},
		{"x": 80.0, "z": -164.0, "yaw": 29.0, "scale": .87, "shadow": true},
		{"x": 102.0, "z": -185.0, "yaw": -16.0, "scale": .81, "shadow": false},
		{"x": 143.0, "z": -177.0, "yaw": 37.0, "scale": .94, "shadow": false},
		{"x": 159.0, "z": -207.0, "yaw": -31.0, "scale": .76, "shadow": false},
		{"x": 92.0, "z": -226.0, "yaw": 9.0, "scale": 1.02, "shadow": false},
		{"x": 137.0, "z": -249.0, "yaw": -42.0, "scale": .86, "shadow": false}
	]

	for i in range(parcels.size()):
		var parcel: Dictionary = parcels[i]
		var file := PROBE_ASSET + ("house_damaged.glb" if i % 2 == 0 else "house_intact.glb")
		var house := spawn_mid_house(
			file,
			parcel["x"] as float,
			parcel["z"] as float,
			parcel["yaw"] as float,
			parcel["scale"] as float,
			parcel["shadow"] as bool
		)
		house.name = "MID_ProbeA_AuthoredTown_%02d" % mid_buildings

	var church_x := 166.0
	var church_z := -238.0
	var church := spawn(PROBE_CITY_REAL + "church_landmark.glb", Vector3(church_x, height_at(church_x, church_z), church_z), 1.24, -13.0)
	church.name = "MID_ProbeA_ChurchSquareLandmark"
	PROBE_BUDGET.apply_mid(church, true)
	mid_buildings += 1

	print("FRONTLINE_TOWN_PROBE_A_READY houses=", parcels.size(), " layout=authored_asymmetric assets=run8_proven extras=none")
