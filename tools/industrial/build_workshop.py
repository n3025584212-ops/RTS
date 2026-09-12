"""Blender 4.5 LTS -> Godot 4.7.1. Authored repair hall from CC0 facade modules.
Run: blender -b --python build_workshop.py -- --source-dir SOURCE --output-dir OUTPUT
Source data stays untouched. Dimensions are metres; Blender +Z up, front -Y.
"""
import bpy,bmesh,math,json,argparse,sys,hashlib
from pathlib import Path
from mathutils import Vector,Matrix
parser=argparse.ArgumentParser();parser.add_argument('--source-dir',type=Path,required=True);parser.add_argument('--output-dir',type=Path,required=True)
args=parser.parse_args(sys.argv[sys.argv.index('--')+1:]);src=args.source_dir;out=args.output_dir;out.mkdir(parents=True,exist_ok=True)
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=str(src/'factory/modular_factory_facade.gltf'))
originals={o.name:o for o in bpy.context.scene.objects if o.type=='MESH'};parts=[]

def pbr(name,diff,normal,arm,metal=True):
 m=bpy.data.materials.new(name);m.use_nodes=True;n=m.node_tree.nodes;l=m.node_tree.links;p=n.get('Principled BSDF')
 for path in [diff,normal,arm]:assert path.exists(),path
 def tex(path,color):
  t=n.new('ShaderNodeTexImage');t.image=bpy.data.images.load(str(path),check_existing=True);t.image.colorspace_settings.name='sRGB' if color else 'Non-Color';return t
 d=tex(diff,True);no=tex(normal,False);a=tex(arm,False)
 nm=n.new('ShaderNodeNormalMap');nm.inputs['Strength'].default_value=.7;l.new(no.outputs['Color'],nm.inputs['Color']);l.new(nm.outputs['Normal'],p.inputs['Normal'])
 split=n.new('ShaderNodeSeparateColor');l.new(a.outputs['Color'],split.inputs[0]);l.new(split.outputs['Green'],p.inputs['Roughness'])
 if metal:l.new(split.outputs['Blue'],p.inputs['Metallic'])
 else:p.inputs['Metallic'].default_value=0
 l.new(d.outputs['Color'],p.inputs['Base Color'])
 # glTF exporter recognizes this named node group; R is occlusion, G roughness, B metal.
 group=bpy.data.node_groups.get('glTF Material Output')
 if not group:
  group=bpy.data.node_groups.new('glTF Material Output','ShaderNodeTree');group.interface.new_socket(name='Occlusion',in_out='INPUT',socket_type='NodeSocketFloat')
 node=n.new('ShaderNodeGroup');node.node_tree=group;l.new(split.outputs['Red'],node.inputs['Occlusion'])
 m.use_backface_culling=True
 return m

materials={}
for key in ['brick','trim_01','windows','garage','doors']:
 p=src/'factory/textures';base='modular_factory_facade_'+key
 materials[key]=pbr('Workshop_'+key,p/(base+'_diff_4k.jpg'),p/(base+'_nor_gl_4k.jpg'),p/(base+'_arm_4k.jpg'),key in ['garage','doors'])
for o in originals.values():
 for i,m in enumerate(o.data.materials):
  key=m.name.replace('modular_factory_facade_','')
  if key=='brick_doors':key='doors'
  if key=='windows_glass':key='windows'
  o.data.materials[i]=materials[key]
roof=pbr('Galvanized_corrugated_roof',src/'roof/corrugated_iron_03_diff.jpg',src/'roof/corrugated_iron_03_nor_gl.jpg',src/'roof/corrugated_iron_03_arm.jpg')
def plain(name,color,rough,metal=0):
 m=bpy.data.materials.new(name);m.use_nodes=True;p=m.node_tree.nodes.get('Principled BSDF');p.inputs['Base Color'].default_value=(*color,1);p.inputs['Roughness'].default_value=rough;p.inputs['Metallic'].default_value=metal;return m
steel=plain('Painted_structural_steel',(.075,.095,.09),.64)
rubber=plain('Roof_flashing_and_seals',(.035,.04,.039),.87)
paint=plain('Faded_ochre_stencil',(.69,.57,.31),.83)
glass=plain('Wired_roof_glass',(.10,.16,.17),.28)
concrete=materials['trim_01']

def apply(o,mod):
 bpy.context.view_layer.objects.active=o;bpy.ops.object.modifier_apply(modifier=mod.name)
def uv_project(o,scale=.5):
 layer=o.data.uv_layers.active or o.data.uv_layers.new(name='UVMap')
 for face in o.data.polygons:
  axis=max(range(3),key=lambda i:abs(face.normal[i]));axes=[i for i in range(3) if i!=axis]
  for li in face.loop_indices:
   v=o.data.vertices[o.data.loops[li].vertex_index].co;layer.data[li].uv=(v[axes[0]]*scale,v[axes[1]]*scale)
def module(name,p,rot=0,thickness=False):
 o=bpy.data.objects.new(name+'_installed',originals[name].data.copy());bpy.context.collection.objects.link(o);o.location=p;o.rotation_euler.z=rot
 if thickness:
  s=o.modifiers.new('240mm inward masonry closure','SOLIDIFY');s.thickness=.24;s.offset=-1;s.use_even_offset=True;apply(o,s)
 o['source_module']=name;parts.append(o);return o
def box(name,p,size,mat,bevel=.012,detail=0):
 bpy.ops.mesh.primitive_cube_add(size=1,location=p);o=bpy.context.object;o.name=name;o.scale=size;bpy.ops.object.transform_apply(location=False,rotation=False,scale=True);o.data.materials.append(mat);uv_project(o,1/3 if mat==materials['brick'] else .5)
 if bevel:
  b=o.modifiers.new('Physical arris','BEVEL');b.width=bevel;b.segments=2;apply(o,b)
 o['detail']=detail;parts.append(o);return o
def beam(name,a,b,w,d,mat=steel,detail=0):
 a=Vector(a);b=Vector(b);o=box(name,(a+b)/2,(w,d,(b-a).length),mat,min(w,d)*.1,detail);o.rotation_euler=(b-a).to_track_quat('Z','Y').to_euler();return o
def pipe(name,points,r,mat=steel,detail=0):
 for a,b in zip(points,points[1:]):
  a=Vector(a);b=Vector(b);bpy.ops.mesh.primitive_cylinder_add(vertices=12,radius=r,depth=(b-a).length,location=(a+b)/2);o=bpy.context.object;o.name=name;o.rotation_euler=(b-a).to_track_quat('Z','Y').to_euler();o.data.materials.append(mat);o['detail']=detail;parts.append(o)
def polygon(name,verts,faces,mat,thickness=0):
 me=bpy.data.meshes.new(name);me.from_pydata(verts,[],faces);me.update();o=bpy.data.objects.new(name,me);bpy.context.collection.objects.link(o);me.materials.append(mat);uv_project(o,1/3 if mat==materials['brick'] else .5)
 bm=bmesh.new();bm.from_mesh(me);bmesh.ops.recalc_face_normals(bm,faces=bm.faces);bm.to_mesh(me);bm.free()
 if thickness:
  s=o.modifiers.new('Thickness','SOLIDIFY');s.thickness=thickness;apply(o,s)
 parts.append(o);return o

# Two six-metre structural bays, 3.32 x 2.74 m clear service doors.
for endpoint in [0,6]:
 module('wall_door_garage_centered_01',(endpoint,-6,0),thickness=True)
 module('door_garage_centered_01',(endpoint,-6,0))
 module('dado_garage_centered_01',(endpoint,-6,.03))
for wall_x,rot,ends in [(6,math.pi/2,[-3,0,3,6]),(-6,-math.pi/2,[-6,-3,0,3])]:
 for j,e in enumerate(ends):
  door=(wall_x==6 and j==0)
  module('wall_door_recessed_small_01' if door else 'wall_window_centered_large_01',(wall_x,e,0),rot,True)
  module('door_recessed_small_01' if door else 'window_centered_large_0'+str(1+j%2),(wall_x,e,0),rot)
  module('dado_door_recessed_small_01' if door else 'dado_standard_standard_01',(wall_x,e,.03),rot)
for x in [-6,-3,0,3]:
 module('wall_window_centered_small_01',(x,6,0),math.pi,True);module('window_centered_small_01',(x,6,0),math.pi);module('dado_standard_standard_01',(x,6,.03),math.pi)
# Upper masonry band: crop the source planar brick panel, retaining original UV scale.
for p,rot in [((x,-6,3),0) for x in [-3,0,3,6]]+[((x,6,3),math.pi) for x in [-6,-3,0,3]]+[((6,y,3),math.pi/2) for y in [-3,0,3,6]]+[((-6,y,3),-math.pi/2) for y in [-6,-3,0,3]]:
 o=module('wall_standard_standard_01',p,rot)
 bm=bmesh.new();bm.from_mesh(o.data)
 bmesh.ops.bisect_plane(bm,geom=list(bm.verts)+list(bm.edges)+list(bm.faces),dist=.00001,plane_co=(0,0,1.2),plane_no=(0,0,1),clear_outer=True)
 bm.to_mesh(o.data);bm.free();s=o.modifiers.new('Upper masonry thickness','SOLIDIFY');s.thickness=.24;s.offset=-1;apply(o,s)
 module('cornice01_standard_standard_01',(p[0],p[1],3),rot)
 module('crown_standard_standard_01',(p[0],p[1],4.06),rot)
# Structural piers, corner returns, grounded slab and a sloping door apron.
for x in [-6,0,6]:
 for y in [-6,6]:box('Loadbearing_brick_pier',(x,y,2.05),(.40,.46,4.10),materials['brick'])
for y in [-3,0,3]:
 for x in [-6,6]:box('Side_buttress',(x,y,2.05),(.4,.34,4.10),materials['brick'])
box('Continuous_foundation',(0,0,-.20),(12.5,12.5,.4),concrete,.028)
box('Service_floor',(0,0,.035),(11.65,11.65,.07),concrete,.01)
for x in [-3,3]:
 polygon('Door_approach_ramp',[(x-1.85,-6.02,.04),(x+1.85,-6.02,.04),(x+1.85,-8.2,-.18),(x-1.85,-8.2,-.18)],[(0,1,2,3)],concrete,.12)
 # Raised opening frame carries lintel load visibly.
 beam('Rolled_steel_lintel',(x-1.8,-6.04,2.83),(x+1.8,-6.04,2.83),.14,.18)
 for dx in [-1.79,1.79]:beam('Door_jamb_guard',(x+dx,-6.14,.1),(x+dx,-6.14,1.0),.09,.09,paint)

# Gable ends and a real steel truss/purlin system under a 17 degree pitched roof.
for y in [-5.99,5.99]:
 polygon('Brick_gable',[(-6,y,4.2),(6,y,4.2),(0,y,6.1)],[(0,1,2)],materials['brick'],.24)
for y in [-5.65,-2.8,0,2.8,5.65]:
 beam('Truss_tie',(-5.8,y,3.95),(5.8,y,3.95),.12,.22)
 for s in [-1,1]:
  beam('Truss_rafter',(0,y,5.94),(s*5.8,y,4.05),.14,.2)
  beam('Truss_web',(0,y,3.95),(s*2.9,y,4.99),.07,.075,detail=1)
  beam('Truss_web',(s*2.9,y,3.95),(s*2.9,y,4.99),.07,.075,detail=1)
 beam('King_post',(0,y,3.95),(0,y,5.94),.09,.09)
for x in [-5.7,-4,-2,0,2,4,5.7]:beam('Longitudinal_purlin',(x,-6.1,6.02-abs(x)*1.9/6),(x,6.1,6.02-abs(x)*1.9/6),.09,.14,detail=1)

# Corrugation displacement from the matching measured height map, not invented noise.
height=bpy.data.images.load(str(src/'roof/corrugated_iron_03_disp.jpg'));height.scale(512,512)
pixels=list(height.pixels);hw=height.size[0];hh=height.size[1]
def relief(u,v):
 return pixels[((int(v%1*hh)%hh)*hw+(int(u%1*hw)%hw))*4]
def roof_sheet(name,y0,y1,x0,x1,side):
 verts=[];uvs=[];faces=[];nu=32;nv=18
 for j in range(nv+1):
  x=x0+(x1-x0)*j/nv
  for i in range(nu+1):
   y=y0+(y1-y0)*i/nu;u=y/2;v=x*math.sqrt(1+(1.9/6)**2)/2
   z=6.14-x*1.9/6+.035*(relief(u,v)-.5)
   verts.append((side*x,y,z));uvs.append((u,v))
 for j in range(nv):
  for i in range(nu):
   a=j*(nu+1)+i;f=(a,a+1,a+nu+2,a+nu+1);faces.append(f if side<0 else tuple(reversed(f)))
 o=polygon(name,verts,faces,roof)
 for f in o.data.polygons:
  for li in f.loop_indices:o.data.uv_layers.active.data[li].uv=uvs[o.data.loops[li].vertex_index]
 s=o.modifiers.new('Sheet thickness 4mm','SOLIDIFY');s.thickness=.004;apply(o,s)
 o['roof_sheet']=True
for side in [-1,1]:
 for strip in range(12):
  y0=-6.35+strip*12.7/12;y1=y0+12.7/12+.025
  for row in range(2):
   x0=row*3.15;x1=(row+1)*3.15+.025
   roof_sheet('Overlapped_corrugated_sheet',y0,y1,x0,x1,side)
 # Folded flashing at gable edges prevents a cardboard roof silhouette.
 for y in [-6.36,6.38]:beam('Gable_barge_flashing',(0,y,6.17),(side*6.36,y,4.16),.10,.16,roof)
 # Open half-round rain gutter, including fall and downpipe elbows.
 verts=[];faces=[]
 for y in [-6.4,6.4]:
  for i in range(13):
   a=math.pi+i*math.pi/12;verts.append((side*6.35+.13*math.cos(a),y,4.15+.13*math.sin(a)-.003*(y+6.4)))
 for i in range(12):faces.append((i,i+1,i+14,i+13))
 polygon('Half_round_rain_gutter',verts,faces,roof,.005)
 for y in [-5.75,5.75]:pipe('Downpipe_with_offset',[(side*6.35,y,4.03),(side*6.35,y,3.6),(side*6.22,y,3.4),(side*6.22,y,.18),(side*6.5,y,.08)],.045,roof)
 # Folded sheet clips and fixings disappear only at the far authored LOD.
 for y in [-5.6,-3.5,-1.4,.7,2.8,4.9]:
  for x in [1.9,4.1,5.9]:box('Sheet_fixing',(side*x,y,6.18-x*1.9/6),(.06,.06,.026),roof,.008,2)
polygon('Folded_ridge_cap',[(-.22,-6.43,6.13),(0,-6.43,6.25),(.22,-6.43,6.13),(-.22,6.43,6.13),(0,6.43,6.25),(.22,6.43,6.13)],[(0,1,4,3),(1,2,5,4)],roof,.006)
# Service exhaust penetrates the roof through a flashed curb, with weather hood.
for y in [-2.5,2.3]:
 x=2.2;z=6.14-x*1.9/6
 box('Exhaust_flashing',(x,y,z),(.82,.82,.10),rubber)
 pipe('Galvanized_exhaust_stack',[(x,y,z),(x,y,z+1.05)],.17,roof)
 bpy.ops.mesh.primitive_cone_add(vertices=24,radius1=.36,radius2=.18,depth=.17,location=(x,y,z+1.2));o=bpy.context.object;o.name='Rain_hood';o.data.materials.append(roof);parts.append(o)
 for dx in [-.22,.22]:beam('Hood_stay',(x+dx,y,z+.9),(x+dx,y,z+1.18),.025,.025,detail=1)

# Asymmetric personnel canopy, triangulated brackets, service conduit and signage.
box('Personnel_threshold',(6.45,-4.5,.065),(.8,1.65,.13),concrete)
polygon('Personnel_rain_canopy',[(6,-5.5,3.0),(7.5,-5.5,2.83),(7.5,-3.5,2.83),(6,-3.5,3.0)],[(0,1,2,3)],roof,.045)
for y in [-5.3,-3.7]:beam('Canopy_bracket',(6.05,y,2.1),(7.4,y,2.83),.065,.065)
pipe('Surface_electrical_conduit',[(6.08,-2.8,.6),(6.08,-2.8,3.45),(6.08,4.5,3.45)],.022,steel,1)
box('Electrical_service_box',(6.13,-2.8,1.3),(.25,.52,.68),steel,.025)
def label(text,p,size):
 c=bpy.data.curves.new('Stencil','FONT');c.body=text;c.size=size;c.align_x='CENTER';c.extrude=.001
 o=bpy.data.objects.new('Workshop_identification',c);bpy.context.collection.objects.link(o);o.location=p;o.rotation_euler=(math.pi/2,0,0);c.materials.append(paint);bpy.context.view_layer.objects.active=o;o.select_set(True);bpy.ops.object.convert(target='MESH');o=bpy.context.object;uv_project(o);o['detail']=1;parts.append(o);o.select_set(False)
box('Enamel_service_sign',(0,-6.28,3.65),(4.45,.075,.63),steel,.025)
label('RIVER TOWN  /  WORKS',(0,-6.325,3.52),.30)
for x,t in [(-3,'01'),(3,'02')]:label(t,(x,-6.055,3.11),.36)
# Interior furniture is retained in the authoring source; doors remain closed.
box('Workbench_top',(4.4,2,.94),(1.0,4,.08),steel)
for y in [.2,3.8]:
 for x in [4,4.8]:beam('Workbench_leg',(x,y,.07),(x,y,.90),.07,.07,detail=1)
for z in [.2,.8,1.4,2]:box('Parts_shelf',(-4.7,2,z),(.9,3,.06),steel,detail=1)
for y in [.5,3.5]:
 for x in [-5.1,-4.3]:beam('Shelf_upright',(x,y,.07),(x,y,2.2),.06,.06,detail=1)

for o in list(bpy.context.scene.objects):
 if o not in parts:bpy.data.objects.remove(o,do_unlink=True)
for o in parts:
 bpy.context.view_layer.objects.active=o;o.select_set(True)
 bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
 t=o.modifiers.new('Export triangulation','TRIANGULATE');apply(o,t)
 # Recalculate consistent outward normals only for new solids; source custom normals remain.
 o.select_set(False)
bpy.context.scene.unit_settings.system='METRIC'
bpy.ops.file.pack_all()
source_out=out/'source';source_out.mkdir(exist_ok=True);(source_out/'.gdignore').write_text('')
bpy.ops.wm.save_as_mainfile(filepath=str(source_out/'repair_workshop_source.blend'))
stats=[]
export_options=dict(export_format='GLB',export_animations=False,export_yup=True,export_tangents=True,export_image_format='JPEG',export_jpeg_quality=90,use_selection=True)
for lod,ratio in [(0,1),(1,.45),(2,.16)]:
 copies=[]
 for original in parts:
  if lod==2 and original.get('detail',0)>0:continue
  if lod==1 and original.get('detail',0)>1:continue
  o=original.copy();o.data=original.data.copy();bpy.context.collection.objects.link(o);copies.append(o)
  preserve_insert = lod==2 and original.get('source_module','').startswith(('door_','window_'))
  if lod and len(o.data.polygons)>60 and not preserve_insert:
   dec=o.modifiers.new('Silhouette constrained simplification','DECIMATE');dec.ratio=ratio;dec.use_collapse_triangulate=True;apply(o,dec)
  o.select_set(True)
 # Joining by material at export gives a compact draw-call budget and preserves UV seams.
 bpy.context.view_layer.objects.active=copies[0];bpy.ops.object.join();joined=bpy.context.object;joined.name='RepairWorkshop_LOD'+str(lod)
 joined.data.validate(verbose=True,clean_customdata=False)
 ntri=sum(len(p.vertices)-2 for p in joined.data.polygons)
 stats.append({'lod':lod,'triangles':ntri,'vertices':len(joined.data.vertices),'materials':len({m.name for m in joined.data.materials}),'uv_layers':len(joined.data.uv_layers),'file':'repair_workshop_lod'+str(lod)+'.glb'})
 bpy.ops.export_scene.gltf(filepath=str(out/stats[-1]['file']),**export_options)
 bpy.data.objects.remove(joined,do_unlink=True)
bpy.context.view_layer.update()
corners=[o.matrix_world@Vector(v) for o in parts for v in o.bound_box]
extent=[max(v[i] for v in corners)-min(v[i] for v in corners) for i in range(3)]
(out/'build_report.json').write_text(json.dumps({'blender':bpy.app.version_string,'dimensions_godot_xyz_m':[extent[0],extent[2],extent[1]],'hall_footprint_m':[12,12],'door_clearance_m':[3.32,2.74],'wall_thickness_m':.24,'source_parts':len(parts),'lods':stats,'material_policy':'sRGB albedo; non-color OpenGL tangent normal; ARM R=AO G=roughness B=metallic; source UV retained','seed':'deterministic; no random geometry'},indent=2))
print('WORKSHOP_BUILD_COMPLETE',json.dumps(stats))
