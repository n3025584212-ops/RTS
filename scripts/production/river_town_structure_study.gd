extends "res://scripts/production/river_town_visual_slice.gd"
## Rejected visual study, deliberately kept separate from the production scene.
## Inherit the unchanged surroundings; substitute only the studied house.

func spawn(file: String, position3: Vector3, scale3: float = 1.0, yaw: float = 0.0, architecture: bool = false) -> Node3D:
	var resource := file
	if file == "res://scenes/production/RiverTownHeroHouseHF.tscn":
		resource = "res://scenes/production/RiverTownHeroHouseStructureStudy.tscn"
	return super.spawn(resource, position3, scale3, yaw, architecture)

func _ready() -> void:
	super._ready()
	# An archived trial must not replace the main production preview.
	if capture_view == "reference":
		capture_view = "study_reference"
	elif capture_view == "side":
		camera.position = Vector3(7.0,8.0,1.0)
		camera.look_at(Vector3(-10.0,4.2,4.0))
		camera.fov = 54.0
