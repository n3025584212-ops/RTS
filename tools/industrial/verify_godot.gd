extends SceneTree

func _initialize() -> void:
	call_deferred("verify")

func verify() -> void:
	var reports: Array = []
	var failed := false
	for level in range(3):
		var file := "res://assets/visual_slice/industrial_workshop/repair_workshop_lod%d.glb" % level
		var scene := load(file) as PackedScene
		assert(scene != null, "GLB import failed")
		var instance := scene.instantiate() as Node3D
		root.add_child(instance)
		var surfaces := 0
		var triangles := 0
		var generated_lods := 0
		var errors: Array[String] = []
		for child in instance.find_children("*","MeshInstance3D",true,false):
			var mi := child as MeshInstance3D
			for s in range(mi.mesh.get_surface_count()):
				surfaces += 1
				var data := mi.mesh.surface_get_arrays(s)
				var positions: PackedVector3Array = data[Mesh.ARRAY_VERTEX]
				var normals: PackedVector3Array = data[Mesh.ARRAY_NORMAL]
				var uvs: PackedVector2Array = data[Mesh.ARRAY_TEX_UV]
				var tangents: PackedFloat32Array = data[Mesh.ARRAY_TANGENT]
				if positions.size()!=normals.size() or positions.size()!=uvs.size() or tangents.size()!=positions.size()*4:
					errors.append("Incomplete vertex channels")
				for p in positions:
					if not p.is_finite(): errors.append("Nonfinite position")
				var indices: PackedInt32Array = data[Mesh.ARRAY_INDEX]
				triangles += indices.size()/3
				var server_data := RenderingServer.mesh_get_surface(mi.mesh.get_rid(),s)
				generated_lods += server_data.get("lods",[]).size()
				var mat := mi.get_active_material(s) as StandardMaterial3D
				if mat == null: errors.append("Missing material")
				elif mat.resource_name.begins_with("Workshop_") or "corrugated" in mat.resource_name:
					if mat.albedo_texture==null or mat.normal_texture==null or mat.roughness_texture==null: errors.append("Missing PBR texture "+mat.resource_name)
		var report := {"lod":level,"triangles":triangles,"surfaces":surfaces,"generated_surface_lods":generated_lods,"errors":errors}
		reports.append(report)
		failed = failed or not errors.is_empty()
		instance.free()
	var document := {"engine":Engine.get_version_info(),"asset_validation":reports,"passed":not failed}
	DirAccess.make_dir_recursive_absolute("res://artifacts/industrial_workshop")
	FileAccess.open("res://artifacts/industrial_workshop/godot_import_validation.json",FileAccess.WRITE).store_string(JSON.stringify(document,"\t"))
	print("WORKSHOP_GODOT_VALIDATION ",JSON.stringify(document))
	quit(1 if failed else 0)
