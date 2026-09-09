@tool
extends Node3D
## Self-contained house material binding. Instance the accompanying .tscn anywhere;
## the mesh, real fracture detail and metre-scale finish travel with the building.
@export_range(0.0,1.0) var weathering := .72
const PBR := "res://assets/visual_slice/surfaces/"
var finishes: Array[ShaderMaterial] = []

func _ready() -> void:
	if "--geometry-proof" in OS.get_cmdline_user_args():
		var proof_material := solid(Color(.38,.38,.38))
		for child: Node in find_children("*","MeshInstance3D",true,false):
			var mi := child as MeshInstance3D
			mi.material_override = proof_material
		return
	var finish := ShaderMaterial.new()
	finish.shader = preload("res://scripts/production/visual_slice_masonry_structure_study.gdshader")
	finish.set_shader_parameter("weathering",weathering)
	finish.set_shader_parameter("plaster_color",load(PBR+"plastered_wall_02_diff.jpg"))
	finish.set_shader_parameter("plaster_normal",load(PBR+"plastered_wall_02_nor_gl.jpg"))
	finish.set_shader_parameter("brick_color",load(PBR+"brick_wall_005_diff.jpg"))
	finish.set_shader_parameter("brick_normal",load(PBR+"brick_wall_005_nor_gl.jpg"))
	var brick := finish.duplicate() as ShaderMaterial
	brick.set_shader_parameter("exposed_brick",true)
	finishes.assign([finish,brick])
	var inside := finish.duplicate() as ShaderMaterial
	inside.set_shader_parameter("interior_finish",true)
	var materials := {
		"plaster":finish,"brick":brick,
		"brick_edge":surface("brick_wall_005",Color(.62,.55,.46)),
		"roof":surface("roof_tiles_14",Color(.82,.62,.46),1.0),
		"trim":surface("plastered_wall_02",Color(.60,.59,.53),1.0),
		"wood":surface("wood_planks",Color(.46,.43,.38)),
		"interior":inside,
		"glass":solid(Color(.044,.069,.071),.21,.42),
		"metal":solid(Color(.17,.18,.17),.56,.60)
	}
	for child: Node in find_children("*","MeshInstance3D",true,false):
		var mi := child as MeshInstance3D
		mi.gi_mode=GeometryInstance3D.GI_MODE_STATIC
		for index in range(mi.mesh.get_surface_count()):
			var original := mi.mesh.surface_get_material(index)
			if original != null and materials.has(original.resource_name):
				mi.set_surface_override_material(index,materials[original.resource_name])

func solid(color: Color,roughness: float=.85,metallic: float=0.0) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color=color
	material.roughness=roughness
	material.metallic=metallic
	material.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	return material

func surface(base: String,tint: Color,uv_scale: float=1.0) -> StandardMaterial3D:
	var material := solid(tint)
	material.albedo_texture=load(PBR+base+"_diff.jpg")
	if ResourceLoader.exists(PBR+base+"_nor_gl.jpg"):
		material.normal_enabled=true
		material.normal_texture=load(PBR+base+"_nor_gl.jpg")
		material.normal_scale=.65
	if ResourceLoader.exists(PBR+base+"_rough.jpg"):
		material.roughness_texture=load(PBR+base+"_rough.jpg")
	material.uv1_scale=Vector3.ONE*uv_scale
	return material
