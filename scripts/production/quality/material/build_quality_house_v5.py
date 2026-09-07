import argparse
import math
import os
import sys
import bpy
from mathutils import Vector

def argv():
    return sys.argv[sys.argv.index("--")+1:] if "--" in sys.argv else []

ap=argparse.ArgumentParser()
ap.add_argument("--output",required=True)
ns=ap.parse_args(argv())

bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)

def mat(name,color,metallic=0.0,roughness=0.7):
    m=bpy.data.materials.get(name)
    if m is None:
        m=bpy.data.materials.new(name)
    m.diffuse_color=(*color,1.0)
    m.use_nodes=True
    bsdf=m.node_tree.nodes.get("Principled BSDF")
    if bsdf:
        bsdf.inputs["Base Color"].default_value=(*color,1.0)
        bsdf.inputs["Metallic"].default_value=metallic
        bsdf.inputs["Roughness"].default_value=roughness
    return m

BRICK=mat("house_brick",(0.42,0.20,0.12),0.0,0.78)
STUCCO=mat("house_stucco",(0.68,0.66,0.58),0.0,0.82)
ROOF=mat("house_roof",(0.16,0.12,0.10),0.0,0.86)
TRIM=mat("house_trim",(0.18,0.19,0.16),0.0,0.70)
GLASS=mat("house_glass",(0.035,0.055,0.060),0.08,0.18)
METAL=mat("house_metal",(0.16,0.16,0.15),0.55,0.48)
WOOD=mat("house_wood",(0.22,0.12,0.07),0.0,0.72)
FOUND=mat("house_foundation",(0.24,0.24,0.22),0.0,0.90)
PATCH=mat("house_patch",(0.36,0.30,0.24),0.0,0.88)

def active(o):
    bpy.ops.object.select_all(action="DESELECT")
    o.select_set(True)
    bpy.context.view_layer.objects.active=o

def bevel(o,width=0.02,segments=2,angle=0.45):
    active(o)
    bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    try:
        m=o.modifiers.new("HouseBevel","BEVEL")
        m.width=width
        m.segments=segments
        m.limit_method="ANGLE"
        m.angle_limit=angle
        if hasattr(m,"harden_normals"):
            m.harden_normals=True
        bpy.ops.object.modifier_apply(modifier=m.name)
    except Exception as exc:
        print("HOUSE_V5_BEVEL_WARN",o.name,exc)

def smart_uv(o):
    active(o)
    try:
        bpy.ops.object.mode_set(mode="EDIT")
        bpy.ops.mesh.select_all(action="SELECT")
        bpy.ops.uv.smart_project(island_margin=0.025)
        bpy.ops.object.mode_set(mode="OBJECT")
    except Exception:
        try: bpy.ops.object.mode_set(mode="OBJECT")
        except Exception: pass

def box(name,loc,dims,material,rot=(0,0,0),bev=0.025):
    bpy.ops.mesh.primitive_cube_add(size=1.0,location=loc,rotation=rot)
    o=bpy.context.object
    o.name=name
    o.dimensions=dims
    o.data.materials.append(material)
    bevel(o,bev)
    smart_uv(o)
    return o

def cyl(name,loc,radius,depth,material,axis="Z",verts=24,bev=0.01):
    rot=(0,0,0)
    if axis=="X": rot=(0,math.pi/2,0)
    elif axis=="Y": rot=(math.pi/2,0,0)
    bpy.ops.mesh.primitive_cylinder_add(vertices=verts,radius=radius,depth=depth,location=loc,rotation=rot)
    o=bpy.context.object
    o.name=name
    o.data.materials.append(material)
    bevel(o,bev,2,0.55)
    smart_uv(o)
    return o

def roof_plane(name,side):
    # side=-1 left pitch, +1 right pitch; ridge along Y
    half_x=4.55
    half_y=3.55
    eave_z=5.20
    ridge_z=7.10
    ridge_x=0.0
    outer_x=side*half_x
    verts=[
        (ridge_x,-half_y,ridge_z),(ridge_x,half_y,ridge_z),
        (outer_x,-half_y,eave_z),(outer_x,half_y,eave_z),
        (ridge_x,-half_y,ridge_z-0.12),(ridge_x,half_y,ridge_z-0.12),
        (outer_x,-half_y,eave_z-0.12),(outer_x,half_y,eave_z-0.12),
    ]
    faces=[(0,2,3,1),(4,5,7,6),(0,4,6,2),(1,3,7,5),(0,1,5,4),(2,6,7,3)]
    mesh=bpy.data.meshes.new(name+"_Mesh")
    mesh.from_pydata(verts,[],faces); mesh.update()
    o=bpy.data.objects.new(name,mesh)
    bpy.context.collection.objects.link(o)
    o.data.materials.append(ROOF)
    bevel(o,0.035)
    smart_uv(o)
    return o

# Main mass: lower brick / upper stucco as separate physical shells.
box("HouseFoundation",(0,0,0.32),(8.50,6.25,0.64),FOUND,bev=0.04)
box("HouseLowerBrick",(0,0,1.80),(8.20,6.00,2.95),BRICK,bev=0.035)
box("HouseUpperStucco",(0,0,4.20),(8.20,6.00,1.85),STUCCO,bev=0.035)

# Roof/eaves.
roof_plane("HouseRoofLeft",-1)
roof_plane("HouseRoofRight",1)
cyl("HouseRidgeCap",(0,0,7.14),0.10,7.10,ROOF,axis="Y",verts=24,bev=0.008)
for x in (-4.28,4.28):
    cyl("HouseGutter_%s"%("L" if x<0 else "R"),(x,0,5.18),0.075,6.75,METAL,axis="Y",verts=18,bev=0.006)
    cyl("HouseDownpipe_%s"%("L" if x<0 else "R"),(x,2.75,2.65),0.065,4.85,METAL,axis="Z",verts=18,bev=0.006)

# Chimney.
box("HouseChimney",(1.65,-0.55,6.55),(0.72,0.72,2.45),BRICK,bev=0.025)
box("HouseChimneyCap",(1.65,-0.55,7.82),(0.90,0.90,0.16),METAL,bev=0.025)

def front_window(name,x,z,w=1.30,h=1.45,boarded=False):
    y=3.035
    box(name+"_Recess",(x,y-0.035,z),(w+0.18,0.10,h+0.18),TRIM,bev=0.018)
    box(name+"_Glass",(x,y+0.025,z),(w,0.07,h),WOOD if boarded else GLASS,bev=0.012)
    t=0.085
    box(name+"_FrameTop",(x,y+0.075,z+h*0.5),(w+0.20,0.11,t),TRIM,bev=0.012)
    box(name+"_FrameBottom",(x,y+0.075,z-h*0.5),(w+0.20,0.11,t),TRIM,bev=0.012)
    box(name+"_FrameL",(x-w*0.5,y+0.075,z),(t,0.11,h),TRIM,bev=0.012)
    box(name+"_FrameR",(x+w*0.5,y+0.075,z),(t,0.11,h),TRIM,bev=0.012)
    box(name+"_Sill",(x,y+0.12,z-h*0.5-0.06),(w+0.35,0.24,0.10),FOUND,bev=0.018)
    if not boarded:
        box(name+"_MullionV",(x,y+0.09,z),(0.055,0.10,h-0.12),TRIM,bev=0.008)
        box(name+"_MullionH",(x,y+0.09,z),(w-0.12,0.10,0.055),TRIM,bev=0.008)
    else:
        box(name+"_BoardA",(x-0.12,y+0.12,z+0.10),(w*0.90,0.08,0.22),WOOD,rot=(0,0,math.radians(6)),bev=0.010)
        box(name+"_BoardB",(x+0.10,y+0.13,z-0.24),(w*0.88,0.08,0.20),WOOD,rot=(0,0,math.radians(-7)),bev=0.010)

def side_window(name,y,z,side=1,w=1.25,h=1.35):
    x=side*4.135
    box(name+"_Recess",(x-side*0.025,y,z),(0.10,w+0.18,h+0.18),TRIM,bev=0.018)
    box(name+"_Glass",(x+side*0.035,y,z),(0.07,w,h),GLASS,bev=0.012)
    t=0.085
    box(name+"_FrameTop",(x+side*0.075,y,z+h*0.5),(0.11,w+0.20,t),TRIM,bev=0.012)
    box(name+"_FrameBottom",(x+side*0.075,y,z-h*0.5),(0.11,w+0.20,t),TRIM,bev=0.012)
    box(name+"_FrameA",(x+side*0.075,y-w*0.5,z),(0.11,t,h),TRIM,bev=0.012)
    box(name+"_FrameB",(x+side*0.075,y+w*0.5,z),(0.11,t,h),TRIM,bev=0.012)

# Front openings.
front_window("FrontWindow_L",-2.45,2.05,1.45,1.55,False)
front_window("FrontWindow_R",2.50,2.05,1.45,1.55,True)
front_window("UpperWindow_L",-2.30,4.30,1.30,1.30,False)
front_window("UpperWindow_R",2.25,4.30,1.30,1.30,False)

# Front door with canopy.
box("FrontDoorRecess",(0.0,3.045,1.62),(1.35,0.12,2.55),TRIM,bev=0.025)
box("FrontDoor",(0.0,3.115,1.62),(1.13,0.09,2.35),WOOD,bev=0.025)
box("FrontDoorInset",(0.0,3.17,1.92),(0.72,0.05,0.88),PATCH,bev=0.018)
box("FrontDoorStep",(0.0,3.45,0.43),(1.90,0.80,0.22),FOUND,bev=0.035)
box("FrontCanopy",(0.0,3.52,3.03),(2.15,0.95,0.16),METAL,rot=(math.radians(-7),0,0),bev=0.025)
for x in (-0.82,0.82):
    cyl("FrontCanopyPost_%+.2f"%x,(x,3.42,1.72),0.045,2.60,METAL,verts=14,bev=0.004)

# Side windows.
for side in (-1,1):
    side_window("SideLower_%s"%side,-1.65,2.05,side,1.20,1.35)
    side_window("SideUpper_%s"%side,1.20,4.25,side,1.15,1.25)

# Fascia / corner trim.
for x in (-4.14,4.14):
    box("CornerTrim_%s"%x,(x,3.01,3.05),(0.18,0.16,4.65),TRIM,bev=0.015)
    box("RearCornerTrim_%s"%x,(x,-3.01,3.05),(0.18,0.16,4.65),TRIM,bev=0.015)
box("FrontFascia",(0,3.08,5.12),(8.35,0.16,0.22),TRIM,bev=0.015)
box("RearFascia",(0,-3.08,5.12),(8.35,0.16,0.22),TRIM,bev=0.015)

# Weather/damage geometry: exposed-brick patches and repairs.
box("StuccoBreakFrontA",(-3.10,3.055,4.35),(1.15,0.05,0.78),BRICK,rot=(0,0,math.radians(-4)),bev=0.008)
box("StuccoPatchFrontB",(1.22,3.065,3.80),(1.05,0.045,0.62),PATCH,rot=(0,0,math.radians(3)),bev=0.008)
box("LowerRepairFront",(-1.45,3.07,1.05),(1.40,0.05,0.48),PATCH,rot=(0,0,math.radians(-2)),bev=0.008)

# Wall fixtures.
box("ElectricalBox",(3.42,3.10,2.60),(0.38,0.18,0.55),METAL,bev=0.025)
cyl("CableConduit",(3.42,3.10,1.70),0.025,1.45,METAL,verts=12,bev=0.003)
box("HouseNumberPlate",(-0.78,3.16,2.70),(0.32,0.035,0.18),METAL,bev=0.008)

# Back service door / small window so rear is not blank.
box("RearDoor",(2.25,-3.08,1.55),(1.05,0.09,2.25),WOOD,bev=0.022)
box("RearDoorFrame",(2.25,-3.02,1.55),(1.28,0.10,2.48),TRIM,bev=0.020)
box("RearWindow",(-2.20,-3.08,2.25),(1.30,0.08,1.10),GLASS,bev=0.018)
box("RearWindowTrim",(-2.20,-3.02,2.25),(1.52,0.10,1.32),TRIM,bev=0.018)

# --- V6 roof / facade detail pass ---
roof_pitch=math.atan2(7.10-5.20,4.55)
for side in (-1,1):
    for i in range(1,11):
        t=i/11.0
        x=side*(4.55*t)
        z=7.10-(7.10-5.20)*t+0.035
        box(f"HouseRoofTileRow_{side}_{i:02d}", (x,0,z), (0.055,6.86,0.045), ROOF,
            rot=(0,-side*roof_pitch,0), bev=0.006)

# Exterior shutters on the upper front pair.
for side,x in ((-1,-2.30),(1,2.25)):
    for wing in (-1,1):
        sx=x+wing*0.82
        shutter=box(f"UpperShutter_{side}_{wing}", (sx,3.15,4.30), (0.48,0.07,1.34), WOOD,
                    rot=(0,0,math.radians(wing*2.5)), bev=0.016)
        for slat_i in range(5):
            box(f"UpperShutterSlat_{side}_{wing}_{slat_i}", (sx,3.20,3.88+slat_i*0.20),
                (0.38,0.04,0.045), TRIM, bev=0.006)

# Brick lintels and sill blocks for stronger opening depth.
for i,(x,z) in enumerate(((-2.45,2.05),(2.50,2.05),(-2.30,4.30),(2.25,4.30))):
    box(f"WindowLintel_{i}", (x,3.18,z+0.83), (1.76,0.20,0.16), FOUND, bev=0.018)

# Rain chain / service piping and exterior lamp.
cyl("HouseServicePipe",(-3.72,3.13,2.15),0.035,2.60,METAL,axis="Z",verts=12,bev=0.003)
box("HouseExteriorLamp",(0.95,3.18,2.82),(0.18,0.16,0.28),METAL,bev=0.025)
box("HouseExteriorLampGlass",(0.95,3.28,2.80),(0.12,0.06,0.15),GLASS,bev=0.014)

# Ground whole asset.
meshes=[o for o in bpy.context.scene.objects if o.type=="MESH"]
mins=[1e30,1e30,1e30]; maxs=[-1e30,-1e30,-1e30]
for o in meshes:
    for c in o.bound_box:
        p=o.matrix_world@Vector(c)
        for a in range(3):
            mins[a]=min(mins[a],p[a]); maxs[a]=max(maxs[a],p[a])
cx=(mins[0]+maxs[0])*0.5
cy=(mins[1]+maxs[1])*0.5
ground=mins[2]
for o in meshes:
    o.location.x-=cx
    o.location.y-=cy
    o.location.z-=ground

print("FRONTLINE_HOUSE_V5_BOUNDS",mins,maxs,"center",cx,cy,"ground",ground)
print("FRONTLINE_HOUSE_V5_MESH_COUNT",len(meshes))

os.makedirs(os.path.dirname(os.path.abspath(ns.output)),exist_ok=True)
bpy.ops.object.select_all(action="DESELECT")
for o in meshes: o.select_set(True)
bpy.context.view_layer.objects.active=meshes[0]
bpy.ops.export_scene.gltf(
    filepath=os.path.abspath(ns.output),
    export_format="GLB",
    use_selection=True,
    export_apply=True,
    export_cameras=False,
    export_lights=False,
    export_animations=False,
)
print("FRONTLINE_HOUSE_V5_EXPORT",ns.output)
