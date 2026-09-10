import bpy, bmesh, math, random, sys
from pathlib import Path
from mathutils import Vector
root=Path(__file__).resolve().parents[2]
if '--' not in sys.argv or len(sys.argv)<=sys.argv.index('--')+1:
 raise SystemExit('Pass the downloaded source glTF after --; see fetch_hero_v2_sources.py')
source=Path(sys.argv[sys.argv.index('--')+1]).resolve()
out=root/'assets/visual_slice/hero_v2/urban_ruin';out.mkdir(exist_ok=True)
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
bpy.ops.import_scene.gltf(filepath=str(source))
originals={o.name:o for o in bpy.context.scene.objects if o.type=='MESH'}
new=[]
def module(name,p,rotation=0,thickness=False):
 original=originals[name];o=bpy.data.objects.new(name+'_placed',original.data.copy());bpy.context.collection.objects.link(o);o.location=p;o.rotation_euler=(0,0,rotation)
 if thickness:
  bpy.context.view_layer.objects.active=o;m=o.modifiers.new('Load bearing wall thickness','SOLIDIFY');m.thickness=.42;m.offset=-1;bpy.ops.object.modifier_apply(modifier=m.name)
 new.append(o);return o
# 9 x 9 m corner tenement. Source modules retain their original 4K PBR materials.
for floor in range(2):
 z=floor*3.2
 for bay in range(3):
  x=-1.5+bay*3
  if floor==1 and bay==2:continue
  wall='wall_door_centered_large_01' if floor==0 and bay==1 else 'wall_window_centered_large_01'
  insert='door_centered_large_01' if floor==0 and bay==1 else 'window_centered_large_02'
  module(wall,(x,-4.5,z),thickness=True);module(insert,(x,-4.5,z))
  if floor==0:module('cornice_standard_standard_01',(x,-4.52,3.0))
  else:module('crown_standard_standard_01',(x,-4.5,6.2))
  module('base_standard_01',(x,-4.5,0 if floor==0 else 3.2))
 # Side wall with an entire collapsed upper corner: reveals the floor/roof system.
 for bay in range(3):
  if floor==1 and bay==0:continue
  y=-1.5+bay*3
  module('wall_window_centered_small_01',(4.5,y,z),math.pi/2,True)
  module('window_centered_small_02',(4.5,y,z),math.pi/2)
  module('cornice_standard_standard_01',(4.5,y,z+3),math.pi/2)
  if floor==1:module('crown_standard_standard_01',(4.5,y,6.2),math.pi/2)
 # Back and left enclose the volume; they are not cardboard facade planes.
 for bay in range(3):
  module('wall_window_centered_small_01',(-4.5,1.5-bay*3,z),-math.pi/2,True)
  module('window_centered_small_02',(-4.5,1.5-bay*3,z),-math.pi/2)
  module('wall_standard_standard_01',(-4.5+bay*3,4.5,z),math.pi,True)
# Roof and ruined inner structure use the same existing CC0 oak material suite.
def material(name,diff=None,color=(.25,.23,.19,1)):
 m=bpy.data.materials.new(name);m.use_nodes=True;n=m.node_tree.nodes;l=m.node_tree.links;p=n.get('Principled BSDF');p.inputs['Base Color'].default_value=color;p.inputs['Roughness'].default_value=.88
 if diff:
  t=n.new('ShaderNodeTexImage');t.image=bpy.data.images.load(str(diff),check_existing=True);l.new(t.outputs['Color'],p.inputs['Base Color'])
 return m
wood=material('Charred structural oak',root/'assets/visual_slice/surfaces/wood_planks_diff.jpg')
core=material('Broken brick wall core',root/'assets/visual_slice/surfaces/brick_wall_005_diff.jpg')
plaster=next(m for m in bpy.data.materials if m.name=='modular_urban_apartments_facade_plaster')
def uv(o):
 layer=o.data.uv_layers.active or o.data.uv_layers.new()
 for poly in o.data.polygons:
  ax=max(range(3),key=lambda k:abs(poly.normal[k]));axes=[i for i in range(3) if i!=ax]
  for li in poly.loop_indices:
   p=o.data.vertices[o.data.loops[li].vertex_index].co;layer.data[li].uv=(p[axes[0]]*.5,p[axes[1]]*.5)
def box(name,p,size,mat):
 bpy.ops.mesh.primitive_cube_add(size=1,location=p);o=bpy.context.object;o.name=name;o.scale=size;bpy.ops.object.transform_apply(location=False,rotation=False,scale=True);o.data.materials.append(mat);uv(o);m=o.modifiers.new('Broken arris','BEVEL');m.width=.016;m.segments=2;bpy.ops.object.modifier_apply(modifier=m.name);new.append(o);return o
def wall_poly(name,poly,y,depth):
 n=len(poly);verts=[(x,y+d,z) for d in [-depth/2,depth/2] for x,z in poly];faces=[tuple(range(n)),tuple(reversed(range(n,2*n)))]+[(i,i+n,(i+1)%n+n,(i+1)%n) for i in range(n)]
 me=bpy.data.meshes.new(name);me.from_pydata(verts,[],faces);me.update();o=bpy.data.objects.new(name,me);bpy.context.collection.objects.link(o);o.data.materials.append(core);uv(o);new.append(o);return o
wall_poly('Fractured front corner',[(1.5,3.2),(4.5,3.2),(4.5,3.46),(4.03,3.54),(3.91,3.91),(3.48,3.83),(3.34,4.58),(3.01,4.49),(2.81,5.21),(2.39,5.15),(2.17,5.83),(1.83,5.72),(1.72,6.2),(1.5,6.2)],-4.4,.48)
# Floor bays remain supported where masonry survives; the open bay has broken ends.
random.seed(729)
for level in [3.08,6.08]:
 for i in range(23):
  x=-4.2+i*.37
  length=8.35 if x<1.3 else random.uniform(3.1,5.9)
  box('Floorboard',(x,4.15-length/2,level),(.36,length,.13),wood)
 for i in range(9):
  x=-4.1+i
  length=8.3 if x<1.3 else random.uniform(3.5,6.0)
  box('Floor joist',(x,4.1-length/2,level-.21),(.20,length,.29),wood)
# Broken cross-room partitions, structural posts and diagonal fallen rafters.
box('Interior transverse wall',(-1.4,.5,1.5),(.20,6.9,3.0),plaster)
for a,b in [((1.6,-3.9,6.1),(4.6,-6.2,.4)),((4.3,-1,6.1),(3.3,-4.3,3.0)),((2.5,-2.0,3.0),(5.6,-5.6,.2))]:
 a=Vector(a);b=Vector(b);o=box('Fallen beam',(a+b)/2,(.19,.22,(b-a).length),wood);o.rotation_euler=(b-a).to_track_quat('Z','Y').to_euler()
# Remove the unused kit layout; only the assembled scene is exported.
for o in list(bpy.context.scene.objects):
 if o not in new:bpy.data.objects.remove(o,do_unlink=True)
for o in new:
 bpy.context.view_layer.objects.active=o
 tri=o.modifiers.new('Export triangles','TRIANGULATE');bpy.ops.object.modifier_apply(modifier=tri.name)
# Export separately to retain full source resolution without a >100 MB GLB.
bpy.ops.object.select_all(action='SELECT')
bpy.ops.export_scene.gltf(filepath=str(out/'urban_ruin.gltf'),export_format='GLTF_SEPARATE',export_texture_dir='textures',export_yup=True,export_tangents=True)
print('URBAN_RUIN_EXPORTED')
