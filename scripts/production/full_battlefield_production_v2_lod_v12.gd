extends "res://scripts/production/full_battlefield_production_v2_lod_v11.gd"
## V12 battlefield-pressure pass.
## No left/mid/right lane allocation. The inherited V11 town, bridge, Near scene,
## woodland masses and skyline remain unchanged. Only the old symmetric bridgehead
## force generator is replaced with an irregular, terrain-driven contact belt.

func _ready() -> void:
	super._ready()
	print("FRONTLINE_FULL_BATTLEFIELD_V2_LOD_V12_READY topology=continuous_irregular_front fixed_lanes=none pressure=terrain_driven near=preserved")

func create_mid_bridgehead_force() -> void:
	# Replace the inherited quasi-symmetric deployment instead of adding on top of it.
	# Positions are intentionally nonuniform in both X and Z: local pairs form around
	# road bends, field edges and settlement cover, while the bridge axis stays open.
	# Opposed yaw families make the contact relationship readable without UI markers.
	var contacts: Array[Dictionary] = [
		# Near-side force: broken approach arc, not a horizontal rank.
		{"file": ASSET + "abrams.glb", "x": -118.0, "z": -24.0, "yaw": 171.0, "scale": .86, "shadow": false, "name": "BlueArmor_FieldEdge"},
		{"file": VEHICLES + "ifv.glb", "x": -92.0, "z": -43.0, "yaw": 166.0, "scale": .73, "shadow": false, "name": "BlueIFV_DitchApproach"},
		{"file": ASSET + "abrams.glb", "x": -48.0, "z": -12.0, "yaw": 178.0, "scale": .89, "shadow": true, "name": "BlueArmor_RoadShoulder"},
		{"file": VEHICLES + "ifv.glb", "x": -11.0, "z": -48.0, "yaw": 174.0, "scale": .72, "shadow": false, "name": "BlueIFV_RutGap"},
		{"file": ASSET + "abrams.glb", "x": 18.0, "z": -56.0, "yaw": 181.0, "scale": .87, "shadow": true, "name": "BlueArmor_BridgeApproachOffset"},
		{"file": VEHICLES + "ifv.glb", "x": 79.0, "z": -21.0, "yaw": 169.0, "scale": .74, "shadow": false, "name": "BlueIFV_FieldBreak"},
		{"file": ASSET + "abrams.glb", "x": 121.0, "z": -47.0, "yaw": 176.0, "scale": .84, "shadow": false, "name": "BlueArmor_TreeLineGap"},

		# Far-side force: staggered among settlement edges and cover. There is no
		# mirrored counterpart for each near-side vehicle and no three-corridor split.
		{"file": VEHICLES + "ifv.glb", "x": -126.0, "z": -168.0, "yaw": 9.0, "scale": .72, "shadow": false, "name": "RedIFV_WestRuinEdge"},
		{"file": ASSET + "abrams.glb", "x": -81.0, "z": -194.0, "yaw": 4.0, "scale": .85, "shadow": false, "name": "RedArmor_CourtyardGap"},
		{"file": VEHICLES + "ifv.glb", "x": -29.0, "z": -160.0, "yaw": -7.0, "scale": .71, "shadow": false, "name": "RedIFV_SettlementFront"},
		{"file": ASSET + "abrams.glb", "x": 6.0, "z": -218.0, "yaw": 12.0, "scale": .83, "shadow": false, "name": "RedArmor_DeepStreet"},
		{"file": ASSET + "abrams.glb", "x": 91.0, "z": -174.0, "yaw": -11.0, "scale": .86, "shadow": true, "name": "RedArmor_EastHouseEdge"},
		{"file": VEHICLES + "ifv.glb", "x": 139.0, "z": -211.0, "yaw": 6.0, "scale": .72, "shadow": false, "name": "RedIFV_ChurchRoadOffset"},
		{"file": ASSET + "abrams.glb", "x": 176.0, "z": -246.0, "yaw": -14.0, "scale": .82, "shadow": false, "name": "RedArmor_RearCounterweight"}
	]

	for spec: Dictionary in contacts:
		var unit := spawn_mid_vehicle(
			spec["file"] as String,
			spec["x"] as float,
			spec["z"] as float,
			spec["yaw"] as float,
			spec["scale"] as float,
			spec["shadow"] as bool
		)
		unit.name = spec["name"] as String

	print("FRONTLINE_V12_CONTACT_BELT_READY units=", contacts.size(), " fixed_lanes=0 bridge_axis=open")
