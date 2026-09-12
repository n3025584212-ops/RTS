extends Node3D
## Authored LODs share the exact LOD0 material resources and world-space pivot.
const ROOT := "res://assets/visual_slice/industrial_workshop/"
var lod_roots: Array[Node3D] = []
var forced_lod := -1

func _ready() -> void:
	var materials_by_name: Dictionary = {}
	for level in range(3):
		var instance := (load(ROOT+"repair_workshop_lod%d.glb" % level) as PackedScene).instantiate() as Node3D
		instance.name = "LOD%d" % level
		add_child(instance)
		lod_roots.append(instance)
		for node in instance.find_children("*", "MeshInstance3D", true, false):
			var mesh := node as MeshInstance3D
			mesh.gi_mode = GeometryInstance3D.GI_MODE_STATIC
			mesh.visibility_range_begin = [0.0,45.0,100.0][level]
			mesh.visibility_range_end = [45.0,100.0,0.0][level]
			mesh.visibility_range_begin_margin = 3.0
			mesh.visibility_range_end_margin = 3.0
			for surface_index in range(mesh.mesh.get_surface_count()):
				var material := mesh.get_active_material(surface_index) as StandardMaterial3D
				assert(material != null, "Workshop material import failed")
				var key := material.resource_name
				if not materials_by_name.has(key):
					var shared := material.duplicate() as StandardMaterial3D
					shared.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
					materials_by_name[key] = shared
				mesh.set_surface_override_material(surface_index, materials_by_name[key])
	set_lod_override(forced_lod)

func set_lod_override(level: int) -> void:
	forced_lod = level
	for index in range(lod_roots.size()):
		lod_roots[index].visible = level < 0 or index == level
		for node in lod_roots[index].find_children("*", "MeshInstance3D", true, false):
			var mesh := node as MeshInstance3D
			mesh.visibility_range_begin = [0.0,45.0,100.0][index] if level < 0 else 0.0
			mesh.visibility_range_end = [45.0,100.0,0.0][index] if level < 0 else 0.0
