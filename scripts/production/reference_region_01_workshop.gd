extends "res://scripts/production/reference_region_01_aligned.gd"
## Integrates the source-backed RepairWorkshop into FRONTLINE_REFERENCE_REGION_01.
## Keeps the aligned river/bridge world intact and adds a connected industrial spur + Hero workshop.

const WORKSHOP_SCENE := "res://scenes/production/RepairWorkshop.tscn"

func _create_road_network() -> void:
	super._create_road_network()
	var industry_spur: Array[Vector3] = [
		Vector3(205.0, 0.0, 151.0),
		Vector3(217.0, 0.0, 174.0),
		Vector3(229.0, 0.0, 196.0),
		Vector3(238.0, 0.0, 211.0),
	]
	_create_polyline_road(industry_spur, 5.4, "IndustrialSpur")

func _create_storage_node() -> void:
	super._create_storage_node()
	var workshop_pos := Vector3(239.0, 0.0, 223.0)
	workshop_pos.y = _height_at(workshop_pos.x, workshop_pos.z) + 0.04
	var workshop := _spawn(WORKSHOP_SCENE, workshop_pos, 1.0, -31.0, "IndustrialRepairWorkshopHero")
	if workshop != null:
		building_count += 1

func _configure_camera() -> void:
	if capture_view == "industrial":
		camera.position = Vector3(286.0, 42.0, 274.0)
		camera.look_at(Vector3(236.0, 3.2, 216.0))
		camera.fov = 48.0
		return
	super._configure_camera()
