extends "res://scripts/production/full_battlefield_production_v2_lod_v10.gd"
## V11 town-space candidate.
## Preserve the proven V10 runtime, Near, bridge, background hamlets, woodland masses
## and FAR skyline. Only the main MID town is regrouped into four readable districts
## so the settlement reads as streets/courtyards instead of a horizontal house line.

const V11_ASSET := "res://assets/visual_slice/"
const V11_CITY := "res://assets/golden_scene/city_real/"
const V11_BUDGET = preload("res://scripts/production/battlefield_visual_budget.gd")

func _ready() -> void:
	super._ready()
	print("FRONTLINE_FULL_BATTLEFIELD_V2_LOD_V11_READY town=four_cluster_districts bridge_corridor=open near=preserved")

func create_mid_continuous_town() -> void:
	# Four separated districts with deliberate depth offsets. The bridge approach
	# remains open through x=-5..70 / z=-235..-125 instead of being plugged by a
	# central row of houses.
	var parcels: Array[Dictionary] = [
		# WEST_RIVERSIDE: compact front quarter, angled around a small yard.
		{"district": "WEST_RIVERSIDE", "file": V11_ASSET + "house_damaged.glb", "x": -92.0, "z": -151.0, "yaw": 20.0, "scale": .89, "shadow": true},
		{"district": "WEST_RIVERSIDE", "file": V11_ASSET + "house_intact.glb", "x": -126.0, "z": -174.0, "yaw": -31.0, "scale": .91, "shadow": false},
		{"district": "WEST_RIVERSIDE", "file": V11_ASSET + "house_damaged.glb", "x": -68.0, "z": -193.0, "yaw": 44.0, "scale": .80, "shadow": false},
		{"district": "WEST_RIVERSIDE", "file": V11_ASSET + "house_intact.glb", "x": -111.0, "z": -211.0, "yaw": -12.0, "scale": .84, "shadow": false},

		# WEST_REAR: damaged rear block, pulled deeper and farther left.
		{"district": "WEST_REAR", "file": V11_ASSET + "house_damaged.glb", "x": -171.0, "z": -221.0, "yaw": 36.0, "scale": .85, "shadow": false},
		{"district": "WEST_REAR", "file": V11_ASSET + "house_intact.glb", "x": -137.0, "z": -249.0, "yaw": -25.0, "scale": .78, "shadow": false},
		{"district": "WEST_REAR", "file": V11_ASSET + "house_damaged.glb", "x": -94.0, "z": -272.0, "yaw": 10.0, "scale": .89, "shadow": false},
		{"district": "WEST_REAR", "file": V11_ASSET + "house_intact.glb", "x": -178.0, "z": -286.0, "yaw": 53.0, "scale": .76, "shadow": false},

		# EAST_GATE: front-right block; all buildings stay east of the bridge corridor.
		{"district": "EAST_GATE", "file": V11_ASSET + "house_damaged.glb", "x": 88.0, "z": -154.0, "yaw": 28.0, "scale": .88, "shadow": true},
		{"district": "EAST_GATE", "file": V11_ASSET + "house_intact.glb", "x": 124.0, "z": -178.0, "yaw": -34.0, "scale": .83, "shadow": false},
		{"district": "EAST_GATE", "file": V11_ASSET + "house_damaged.glb", "x": 91.0, "z": -209.0, "yaw": 13.0, "scale": .79, "shadow": false},
		{"district": "EAST_GATE", "file": V11_ASSET + "house_intact.glb", "x": 146.0, "z": -215.0, "yaw": 41.0, "scale": .92, "shadow": true},

		# EAST_CHURCH: deeper quarter around the landmark, not another front row.
		{"district": "EAST_CHURCH", "file": V11_ASSET + "house_damaged.glb", "x": 169.0, "z": -242.0, "yaw": -29.0, "scale": .82, "shadow": false},
		{"district": "EAST_CHURCH", "file": V11_ASSET + "house_intact.glb", "x": 121.0, "z": -263.0, "yaw": 17.0, "scale": .86, "shadow": false},
		{"district": "EAST_CHURCH", "file": V11_ASSET + "house_damaged.glb", "x": 204.0, "z": -259.0, "yaw": 48.0, "scale": .77, "shadow": false},
		{"district": "EAST_CHURCH", "file": V11_ASSET + "house_intact.glb", "x": 92.0, "z": -289.0, "yaw": -43.0, "scale": .80, "shadow": false},
		{"district": "EAST_CHURCH", "file": V11_ASSET + "house_damaged.glb", "x": 153.0, "z": -304.0, "yaw": 7.0, "scale": .90, "shadow": false},
		{"district": "EAST_CHURCH", "file": V11_ASSET + "house_intact.glb", "x": 211.0, "z": -292.0, "yaw": -18.0, "scale": .78, "shadow": false}
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
		house.name = "MID_V11_%s_%02d" % [parcel["district"] as String, mid_buildings]

	# Low walls make the groupings read as real parcels/courtyards without adding
	# another asset family or disturbing the bridge sightline.
	add_v11_wall(Vector3(-107.0, height_at(-107.0, -181.0) + .34, -181.0), Vector3(25.0, .68, .48), -14.0)
	add_v11_wall(Vector3(-148.0, height_at(-148.0, -252.0) + .34, -252.0), Vector3(28.0, .68, .48), 31.0)
	add_v11_wall(Vector3(116.0, height_at(116.0, -193.0) + .34, -193.0), Vector3(23.0, .68, .48), 24.0)
	add_v11_wall(Vector3(154.0, height_at(154.0, -275.0) + .34, -275.0), Vector3(31.0, .68, .48), -21.0)
	add_v11_wall(Vector3(191.0, height_at(191.0, -282.0) + .34, -282.0), Vector3(18.0, .68, .48), 37.0)

	var church_x := 189.0
	var church_z := -321.0
	var church := spawn(V11_CITY + "church_landmark.glb", Vector3(church_x, height_at(church_x, church_z), church_z), 1.16, -11.0)
	church.name = "MID_ChurchSquareLandmarkV11"
	V11_BUDGET.apply_mid(church, true)
	mid_buildings += 1
	for child: Node in church.find_children("*", "MeshInstance3D", true, false):
		var mi := child as MeshInstance3D
		for i in range(mi.mesh.get_surface_count()):
			var source_mat := mi.get_active_material(i)
			var key: String = source_mat.resource_name.to_lower() if source_mat != null else ""
			mi.set_surface_override_material(i, mats["roof"] if "roof" in key else mats["stone"])

func add_v11_wall(position3: Vector3, size3: Vector3, yaw: float) -> void:
	var wall := block(position3, size3, "stone")
	wall.rotation_degrees.y = yaw
	V11_BUDGET.apply_mid(wall, false)
