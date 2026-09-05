class_name GoldenWorldV20TownStreets
extends RefCounted

static func add(world: GoldenWorldV1) -> void:
	world._add_road_polyline(
		[Vector3(20,0,-16), Vector3(43,0,-15), Vector3(70,0,-14)],
		2.4, world._road_material, "V20TownStreetN"
	)
	world._add_road_polyline(
		[Vector3(20,0,2), Vector3(44,0,2), Vector3(70,0,3)],
		2.35, world._road_material, "V20TownStreetS"
	)
	world._add_road_polyline(
		[Vector3(35,0,-29), Vector3(36,0,-10), Vector3(37,0,24)],
		2.2, world._road_material, "V20TownStreetW"
	)
	world._add_road_polyline(
		[Vector3(58,0,-29), Vector3(59,0,-10), Vector3(60,0,24)],
		2.2, world._road_material, "V20TownStreetE"
	)
