import bpy,math
from pathlib import Path
root=Path(__file__).resolve().parents[2];out=root/'assets/visual_slice/hero_v2'
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
bpy.ops.import_scene.gltf(filepath=str(root/'assets/visual_slice/abrams.glb'))
steel=bpy.data.materials.new('V2_ExposedSteelEdges');steel.use_nodes=True;p=steel.node_tree.nodes.get('Principled BSDF');p.inputs['Base Color'].default_value=(.13,.145,.15,1);p.inputs['Metallic'].default_value=.8;p.inputs['Roughness'].default_value=.36
for o in list(bpy.context.scene.objects):
 if o.type!='MESH':continue
 bpy.context.view_layer.objects.active=o
 # Object scale must be applied before using metre-scale manufacturing bevels.
 o.select_set(True);bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
 o.data.materials.append(steel)
 mod=o.modifiers.new('Manufactured armor arris','BEVEL');mod.width=.009;mod.segments=2;mod.limit_method='ANGLE';mod.angle_limit=.55;mod.affect='EDGES';mod.material=len(o.data.materials)-1
 bpy.ops.object.modifier_apply(modifier=mod.name)
 tri=o.modifiers.new('Export triangles','TRIANGULATE');bpy.ops.object.modifier_apply(modifier=tri.name)
 o.select_set(False)
bpy.ops.object.select_all(action='SELECT')
bpy.ops.export_scene.gltf(filepath=str(out/'abrams_v2.glb'),export_format='GLB',export_yup=True,export_tangents=True)
print('ABRAMS_V2_GEOMETRY_EXPORTED')
