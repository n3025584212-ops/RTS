"""Blender: preserve authored asset shading while making bounded Godot GLBs."""
import bpy,sys,json,math
from pathlib import Path
root=Path(__file__).resolve().parents[2]
external=root.parent/'external'
out=root/'assets/visual_slice';out.mkdir(parents=True,exist_ok=True)
names=sys.argv[sys.argv.index('--')+1:]
for name in names:
    bpy.ops.wm.read_factory_settings(use_empty=True)
    source=external/name/('scene.gltf' if name=='abrams' else name+'_1k.gltf')
    bpy.ops.import_scene.gltf(filepath=str(source))
    meshes=[o for o in bpy.context.scene.objects if o.type=='MESH']
    print('SOURCE_OBJECTS',name,[(o.name,len(o.data.polygons),[round(v,2) for v in o.dimensions]) for o in meshes],flush=True)
    total=sum(sum(len(p.vertices)-2 for p in o.data.polygons) for o in meshes)
    budget={'abrams':270000,'island_tree_01':350000,'fir_sapling_medium':500000,'rock_moss_set_01':24000}.get(name,20000)
    for ob in meshes:
        bpy.context.view_layer.objects.active=ob
        if total>budget:
            m=ob.modifiers.new('Runtime_LOD','DECIMATE');m.ratio=budget/total
            bpy.ops.object.modifier_apply(modifier=m.name)
    for im in bpy.data.images:
        if im.size[0]>2048 or im.size[1]>2048:
            ratio=2048/max(im.size);im.scale(max(1,round(im.size[0]*ratio)),max(1,round(im.size[1]*ratio)))
    bpy.ops.export_scene.gltf(filepath=str(out/(name+'.glb')),export_format='GLB',export_animations=False,export_cameras=False,export_lights=False,export_yup=True,export_tangents=True)
    if name!='abrams':
        from mathutils import Vector,Matrix
        for i,ob in enumerate(meshes):
            # Export each complete source plant independently; never instance a display lineup.
            bpy.ops.object.select_all(action='DESELECT')
            world=ob.matrix_world.copy()
            coords=[world@v.co for v in ob.data.vertices]
            low=Vector([min(v[j] for v in coords) for j in range(3)])
            high=Vector([max(v[j] for v in coords) for j in range(3)])
            center=Vector(((low.x+high.x)/2,(low.y+high.y)/2,low.z))
            ob.parent=None;ob.matrix_world=Matrix.Identity(4)
            for v,p in zip(ob.data.vertices,coords):v.co=p-center
            ob.select_set(True);bpy.context.view_layer.objects.active=ob
            bpy.ops.export_scene.gltf(filepath=str(out/(name+'_'+str(i)+'.glb')),export_format='GLB',use_selection=True,export_animations=False,export_cameras=False,export_lights=False,export_yup=True,export_tangents=True)
    print('CONVERTED',name,'source_tris',total,flush=True)
