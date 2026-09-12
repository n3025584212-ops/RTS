extends "res://scripts/production/golden/golden_units_v22.gd"

# V26 adds explicit physical battle history. Active formations alone make the
# screenshot read staged; a pair of unlabelled damaged armor hulls anchors the
# smoke/fire state to real 3D objects without changing gameplay formations.


func build(world: GoldenWorldV1) -> void:
	super.build(world)
	_add_v26_wreck(Vector3(34.0, 0, 10.5), 6.2, 28.0, "V26WreckWestTown")
	_add_v26_wreck(Vector3(55.0, 0, -16.5), 6.0, -17.0, "V26WreckEastTown")


func _add_v26_wreck(p: Vector3, target_size: float, yaw: float, node_name: String) -> void:
	if not ResourceLoader.exists(HQ_MBT_PATH):
		return
	var packed := load(HQ_MBT_PATH) as PackedScene
	if packed == null:
		return
	var wreck := packed.instantiate() as Node3D
	if wreck == null:
		return
	wreck.name = node_name
	_world.fit_instance_to_size(wreck, target_size)
	p.y = _world.height_at(p.x, p.z) + 0.04
	wreck.position = p
	wreck.rotation_degrees = Vector3(3.5, yaw, 5.0 if yaw > 0.0 else -4.0)
	_tint_authored_materials(wreck, Color(0.25, 0.22, 0.17), _hostile_vehicle_material)
	add_child(wreck)
