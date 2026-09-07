import argparse
import math
import os
import sys
import bpy
from mathutils import Vector

def argv():
    return sys.argv[sys.argv.index("--")+1:] if "--" in sys.argv else []

ap = argparse.ArgumentParser()
ap.add_argument("--output", required=True)
ns = ap.parse_args(argv())

# Clean scene.
bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)
for datablocks in (bpy.data.meshes, bpy.data.curves, bpy.data.materials):
    pass

def mat(name, color, metallic=0.0, roughness=0.7):
    m = bpy.data.materials.get(name)
    if m is None:
        m = bpy.data.materials.new(name)
    m.diffuse_color = (*color, 1.0)
    m.use_nodes = True
    bsdf = m.node_tree.nodes.get("Principled BSDF")
    if bsdf:
        bsdf.inputs["Base Color"].default_value = (*color, 1.0)
        bsdf.inputs["Metallic"].default_value = metallic
        bsdf.inputs["Roughness"].default_value = roughness
    return m

BODY = mat("body", (0.16, 0.18, 0.065), 0.04, 0.68)
SIDE = mat("Material.001", (0.14, 0.15, 0.052), 0.02, 0.74)
TRACK = mat("track", (0.10, 0.085, 0.060), 0.45, 0.66)
WHEEL = mat("wheels", (0.055, 0.055, 0.045), 0.02, 0.88)
GUN = mat("metal barrel", (0.12, 0.13, 0.055), 0.10, 0.56)
OPTIC = mat("optics", (0.020, 0.035, 0.030), 0.15, 0.22)
EXHAUST = mat("exhaust", (0.07, 0.065, 0.055), 0.55, 0.72)

def active(obj):
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj

def apply_bevel(obj, width=0.02, segments=2, angle=0.45):
    if width <= 0:
        return
    active(obj)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    try:
        mod = obj.modifiers.new("ProofBevel", "BEVEL")
        mod.width = width
        mod.segments = segments
        mod.limit_method = "ANGLE"
        mod.angle_limit = angle
        mod.profile = 0.5
        if hasattr(mod, "harden_normals"):
            mod.harden_normals = True
        bpy.ops.object.modifier_apply(modifier=mod.name)
    except Exception as exc:
        print("ABRAMS_V4_BEVEL_WARN", obj.name, exc)

def add_box(name, loc, dims, material=BODY, rot=(0.0,0.0,0.0), bevel=0.025):
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=loc, rotation=rot)
    obj = bpy.context.object
    obj.name = name
    obj.dimensions = dims
    if material:
        obj.data.materials.append(material)
    apply_bevel(obj, bevel)
    return obj

def add_cylinder(name, loc, radius, depth, material, axis="Z", verts=32, bevel=0.012):
    rot = (0.0,0.0,0.0)
    if axis == "X":
        rot = (0.0, math.pi/2.0, 0.0)
    elif axis == "Y":
        rot = (math.pi/2.0, 0.0, 0.0)
    bpy.ops.mesh.primitive_cylinder_add(vertices=verts, radius=radius, depth=depth, location=loc, rotation=rot)
    obj = bpy.context.object
    obj.name = name
    obj.data.materials.append(material)
    apply_bevel(obj, bevel, 2, 0.55)
    for p in obj.data.polygons:
        p.use_smooth = True
    return obj

def add_wedge(name, front_y, back_y, z0, zf, zb, half_front, half_back, material=BODY, bevel=0.028):
    verts = [
        (-half_front, front_y, z0), (half_front, front_y, z0),
        (-half_back, back_y, z0), (half_back, back_y, z0),
        (-half_front, front_y, zf), (half_front, front_y, zf),
        (-half_back, back_y, zb), (half_back, back_y, zb),
    ]
    faces = [
        (0,1,5,4), (2,6,7,3), (0,4,6,2), (1,3,7,5),
        (4,5,7,6), (0,2,3,1)
    ]
    mesh = bpy.data.meshes.new(name+"_Mesh")
    mesh.from_pydata(verts, [], faces)
    mesh.update()
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    obj.data.materials.append(material)
    active(obj)
    try:
        bpy.ops.object.mode_set(mode="EDIT")
        bpy.ops.mesh.select_all(action="SELECT")
        bpy.ops.uv.smart_project(island_margin=0.03)
        bpy.ops.object.mode_set(mode="OBJECT")
    except Exception:
        try:
            bpy.ops.object.mode_set(mode="OBJECT")
        except Exception:
            pass
    apply_bevel(obj, bevel)
    return obj

def add_bar(name, a, b, radius, material=BODY, verts=12):
    a = Vector(a); b = Vector(b)
    d = b-a
    length = d.length
    mid = (a+b)*0.5
    bpy.ops.mesh.primitive_cylinder_add(vertices=verts, radius=radius, depth=length, location=mid)
    obj = bpy.context.object
    obj.name = name
    obj.data.materials.append(material)
    obj.rotation_mode = "QUATERNION"
    obj.rotation_quaternion = Vector((0,0,1)).rotation_difference(d.normalized())
    apply_bevel(obj, min(radius*0.35, 0.01), 2, 0.55)
    return obj

# --- Hull mass ---
add_box("Body_LowerHull", (0.0,-0.10,0.73), (3.46,6.75,0.82), BODY, bevel=0.055)
add_wedge("Body_UpperHull", 3.72, -3.35, 1.00, 1.27, 1.58, 1.58, 1.70, BODY, 0.045)
add_wedge("Body_Glacis", 3.96, 2.55, 0.72, 1.12, 1.47, 1.50, 1.64, BODY, 0.035)
add_box("Body_RearPlate", (0,-3.55,1.18), (3.32,0.30,0.78), BODY, rot=(math.radians(-7),0,0), bevel=0.04)
add_box("Body_FrontLip", (0,3.70,0.76), (3.18,0.26,0.30), BODY, rot=(math.radians(10),0,0), bevel=0.03)

# Fender shoulders and side details.
for side in (-1,1):
    x = side*1.72
    add_box(f"Body_Fender_{side}", (x,-0.12,1.30), (0.16,6.30,0.20), BODY, bevel=0.025)
    # Side skirt segmented armor plates.
    ys = [-2.85,-2.05,-1.25,-0.45,0.35,1.15,1.95,2.75]
    for i,y in enumerate(ys):
        h = 0.72 if i not in (0,7) else 0.62
        z = 0.86 if i not in (0,7) else 0.83
        add_box(f"SideSkirt_{side}_{i:02d}", (side*1.79,y,z), (0.115,0.70,h), SIDE, bevel=0.022)

# Wheels, hubs, return rollers and track pads.
wheel_ys = [-2.55,-1.72,-0.88,0.0,0.88,1.72,2.55]
for side in (-1,1):
    xwheel = side*1.52
    for i,y in enumerate(wheel_ys):
        add_cylinder(f"Wheel_{side}_{i:02d}", (xwheel,y,0.58), 0.36, 0.18, WHEEL, axis="X", verts=32, bevel=0.010)
        add_cylinder(f"WheelHub_{side}_{i:02d}", (side*1.625,y,0.58), 0.13, 0.055, BODY, axis="X", verts=24, bevel=0.008)
    for i,y in enumerate((-1.65,0.0,1.65)):
        add_cylinder(f"Wheel_Return_{side}_{i:02d}", (xwheel,y,1.08), 0.14, 0.15, WHEEL, axis="X", verts=24, bevel=0.008)
    # Drive sprocket/idler.
    add_cylinder(f"Track_Sprocket_{side}", (xwheel,-3.03,0.60), 0.39, 0.20, TRACK, axis="X", verts=28, bevel=0.012)
    add_cylinder(f"Track_Idler_{side}", (xwheel,3.03,0.60), 0.39, 0.20, TRACK, axis="X", verts=28, bevel=0.012)
    # Individual lower/upper track shoes.
    for i in range(25):
        y = -2.95 + i*(5.90/24.0)
        add_box(f"TrackPad_Lower_{side}_{i:02d}", (side*1.67,y,0.205), (0.28,0.215,0.075), TRACK, bevel=0.006)
        add_box(f"TrackPad_Upper_{side}_{i:02d}", (side*1.67,y,1.075), (0.28,0.215,0.065), TRACK, bevel=0.006)
    # Rounded end runs.
    for end_sign, yc in ((1,2.95),(-1,-2.95)):
        for j in range(8):
            theta = -math.pi/2 + (j+0.5)*(math.pi/8.0)
            if end_sign < 0:
                theta = math.pi/2 + (j+0.5)*(math.pi/8.0)
            y = yc + 0.39*math.cos(theta)
            z = 0.60 + 0.39*math.sin(theta)
            add_box(f"TrackPad_End_{side}_{end_sign}_{j:02d}", (side*1.67,y,z), (0.28,0.20,0.07), TRACK,
                    rot=(theta,0,0), bevel=0.005)

# Front towing eyes/headlights.
for side in (-1,1):
    add_cylinder(f"Body_TowEye_{side}", (side*1.18,3.80,0.78), 0.10, 0.10, TRACK, axis="X", verts=20, bevel=0.006)
    add_box(f"Optic_Headlight_{side}", (side*1.30,3.55,1.27), (0.22,0.18,0.16), OPTIC, bevel=0.025)

# Engine deck, louvers, exhaust.
add_box("Body_EngineDeck", (0,-2.70,1.56), (2.85,1.20,0.12), BODY, bevel=0.025)
for i in range(9):
    x = -1.20 + i*0.30
    add_box(f"Exhaust_Grille_{i:02d}", (x,-2.66,1.635), (0.16,0.78,0.045), EXHAUST, bevel=0.004)
for side in (-1,1):
    add_box(f"Exhaust_Rear_{side}", (side*1.18,-3.47,1.20), (0.52,0.15,0.28), EXHAUST, bevel=0.020)

# --- Turret ---
add_cylinder("Body_TurretRing", (0,-0.38,1.60), 1.28, 0.20, BODY, axis="Z", verts=48, bevel=0.025)
add_wedge("Body_TurretShell", 1.35, -1.90, 1.60, 2.28, 2.42, 1.42, 1.50, BODY, 0.055)
add_box("Body_TurretRoof", (0,-0.55,2.39), (2.45,2.55,0.14), BODY, rot=(math.radians(-1.5),0,0), bevel=0.035)
# Cheek wedges: angled faceted armor masses.
for side in (-1,1):
    add_box(f"Body_TurretCheek_{side}", (side*0.82,1.02,2.03), (0.78,0.92,0.72), BODY,
            rot=(0,0,math.radians(side*8.0)), bevel=0.045)
    add_box(f"Body_TurretSide_{side}", (side*1.42,-0.35,2.05), (0.22,1.90,0.58), BODY,
            rot=(0,0,math.radians(side*1.5)), bevel=0.035)

# Mantlet and M256 gun.
add_box("Body_Mantlet", (0,1.42,2.06), (1.10,0.28,0.58), BODY, bevel=0.045)
add_cylinder("MetalBarrel_Base", (0,1.82,2.08), 0.17, 0.65, GUN, axis="Y", verts=32, bevel=0.012)
add_cylinder("MetalBarrel_Main", (0,3.45,2.08), 0.092, 2.65, GUN, axis="Y", verts=32, bevel=0.008)
add_cylinder("MetalBarrel_Evacuator", (0,3.05,2.08), 0.145, 0.72, GUN, axis="Y", verts=32, bevel=0.012)
add_cylinder("MetalBarrel_Muzzle", (0,4.86,2.08), 0.105, 0.22, GUN, axis="Y", verts=32, bevel=0.008)

# Bustle and basket.
add_box("Body_Bustle", (0,-1.88,2.10), (2.55,0.95,0.60), BODY, bevel=0.045)
# Bustle rack rails.
rack_z0, rack_z1, rack_y = 1.78, 2.34, -2.48
for side in (-1,1):
    x = side*1.32
    add_bar(f"Body_BustleRackSide_{side}_0", (x,-1.70,rack_z0), (x,-2.62,rack_z0), 0.025, BODY)
    add_bar(f"Body_BustleRackSide_{side}_1", (x,-1.70,rack_z1), (x,-2.62,rack_z1), 0.025, BODY)
    add_bar(f"Body_BustleRackVert_{side}", (x,-2.60,rack_z0), (x,-2.60,rack_z1), 0.025, BODY)
for x in (-1.25,-0.75,-0.25,0.25,0.75,1.25):
    add_bar(f"Body_BustleRackRear_{x:.2f}", (x,rack_y,rack_z0), (x,rack_y,rack_z1), 0.020, BODY)
add_bar("Body_BustleRackTop", (-1.32,rack_y,rack_z1), (1.32,rack_y,rack_z1), 0.025, BODY)

# Storage / ammo boxes on bustle.
for i,(x,y,z,dx,dy,dz) in enumerate([
    (-0.78,-1.94,2.52,0.55,0.48,0.32),(0.0,-1.98,2.54,0.62,0.46,0.34),
    (0.78,-1.92,2.50,0.50,0.44,0.30)
]):
    add_box(f"Body_Stowage_{i:02d}", (x,y,z), (dx,dy,dz), BODY, bevel=0.035)

# Hatches and cupolas.
for side,x in ((-1,-0.55),(1,0.55)):
    add_cylinder(f"Body_Hatch_{side}", (x,-0.36,2.51), 0.34, 0.08, BODY, axis="Z", verts=32, bevel=0.018)
    add_cylinder(f"Body_Cupola_{side}", (x,-0.36,2.60), 0.24, 0.15, BODY, axis="Z", verts=32, bevel=0.018)

# Periscopes around roof.
peris = [(-0.76,0.18),(-0.45,0.30),(0.40,0.28),(0.72,0.10),(-0.72,-0.92),(0.70,-0.88)]
for i,(x,y) in enumerate(peris):
    add_box(f"Optic_Perisope_{i:02d}", (x,y,2.61), (0.22,0.13,0.09), OPTIC, bevel=0.018)

# CITV and gunner sight.
add_cylinder("Body_CITV_Base", (-0.78,-0.76,2.62), 0.18, 0.22, BODY, axis="Z", verts=28, bevel=0.015)
add_box("Optic_CITV", (-0.78,-0.76,2.82), (0.25,0.28,0.28), OPTIC, bevel=0.025)
add_box("Body_GunnerSightHousing", (0.63,0.38,2.66), (0.42,0.48,0.34), BODY, bevel=0.035)
add_box("Optic_GunnerSight", (0.63,0.62,2.66), (0.28,0.06,0.20), OPTIC, bevel=0.012)

# Smoke launchers (6 per side).
for side in (-1,1):
    base_x = side*1.28
    for i in range(6):
        y = 0.62 - (i%3)*0.22
        z = 2.24 + (i//3)*0.20
        x = base_x + side*(i%3)*0.03
        obj = add_cylinder(f"Body_SmokeLauncher_{side}_{i:02d}", (x,y,z), 0.055, 0.32, BODY, axis="Y", verts=18, bevel=0.006)
        obj.rotation_euler.z += math.radians(side*12)
        obj.rotation_euler.x += math.radians(-12)

# CROWS / commander's weapon station.
add_cylinder("Body_CROWS_Base", (0.48,-0.72,2.69), 0.20, 0.16, BODY, axis="Z", verts=28, bevel=0.016)
add_box("Body_CROWS_Block", (0.48,-0.70,2.89), (0.34,0.36,0.28), BODY, bevel=0.035)
add_box("Optic_CROWS", (0.48,-0.50,2.91), (0.20,0.08,0.14), OPTIC, bevel=0.014)
add_cylinder("MetalBarrel_CROWS_MG", (0.48,0.05,2.98), 0.025, 0.95, GUN, axis="Y", verts=16, bevel=0.004)

# Antennas.
for side,x in ((-1,-1.08),(1,1.06)):
    add_cylinder(f"Body_AntennaBase_{side}", (x,-1.55,2.52), 0.06, 0.12, BODY, axis="Z", verts=18, bevel=0.006)
    add_bar(f"Body_Antenna_{side}", (x,-1.55,2.58), (x+side*0.08,-1.63,4.05), 0.012, BODY, verts=10)

# Turret side handrails.
for side in (-1,1):
    x = side*1.52
    add_bar(f"Body_Handrail_{side}_A", (x,-1.25,2.18), (x,0.45,2.18), 0.018, BODY, verts=10)
    add_bar(f"Body_Handrail_{side}_B", (x,-1.25,2.18), (x,-1.25,2.38), 0.018, BODY, verts=10)
    add_bar(f"Body_Handrail_{side}_C", (x,0.45,2.18), (x,0.45,2.38), 0.018, BODY, verts=10)

# Spare track links and front stowage to add fine-scale read.
for side in (-1,1):
    for i in range(3):
        add_box(f"Track_Spare_{side}_{i}", (side*(0.55+0.32*i),1.58,1.66), (0.25,0.08,0.18), TRACK, bevel=0.012)

# Tow cable approximations along hull shoulders.
for side in (-1,1):
    x = side*1.57
    pts = [(x,-2.80,1.48),(x,-1.20,1.58),(x,0.60,1.52),(x,2.45,1.42)]
    for i in range(len(pts)-1):
        add_bar(f"Track_TowCable_{side}_{i}", pts[i], pts[i+1], 0.018, TRACK, verts=10)

# Small turret fastener rows / panel cues.
for side in (-1,1):
    x = side*1.44
    for i,y in enumerate((-1.15,-0.75,-0.35,0.05,0.45)):
        add_cylinder(f"Body_TurretBolt_{side}_{i}", (x,y,2.18), 0.035, 0.035, BODY, axis="X", verts=16, bevel=0.004)

# --- V6 production-detail pass ---
# Driver hatch and forward periscopes.
add_box("Body_DriverHatch", (0.0,2.22,1.52), (0.78,0.72,0.12), BODY, rot=(math.radians(-4),0,0), bevel=0.025)
for i,x in enumerate((-0.28,0.0,0.28)):
    add_box(f"Optic_DriverPeriscope_{i}", (x,2.52,1.64), (0.18,0.12,0.10), OPTIC, bevel=0.012)

# Side-skirt hinges/fasteners and lower rubber strips.
skirt_ys = [-2.85,-2.05,-1.25,-0.45,0.35,1.15,1.95,2.75]
for side in (-1,1):
    sx=side*1.855
    for i,y in enumerate(skirt_ys):
        add_cylinder(f"Body_SkirtHinge_{side}_{i:02d}", (sx,y+0.23,1.12), 0.045, 0.06, TRACK, axis="X", verts=16, bevel=0.004)
        add_cylinder(f"Body_SkirtBolt_{side}_{i:02d}", (sx,y-0.22,0.94), 0.032, 0.055, TRACK, axis="X", verts=14, bevel=0.003)
    add_box(f"Wheel_SkirtRubber_{side}", (side*1.84,-0.05,0.47), (0.055,6.05,0.14), WHEEL, bevel=0.014)

# Suspension arms and wheel-center caps.
for side in (-1,1):
    for i,y in enumerate(wheel_ys):
        add_bar(f"Track_SuspensionArm_{side}_{i:02d}", (side*1.18,y,0.82), (side*1.48,y,0.61), 0.045, TRACK, verts=14)
        add_cylinder(f"Body_WheelCap_{side}_{i:02d}", (side*1.625,y,0.58), 0.075, 0.070, BODY, axis="X", verts=20, bevel=0.006)

# Track guide teeth on the visible lower run.
for side in (-1,1):
    for i in range(13):
        y=-2.75+i*(5.50/12.0)
        add_box(f"Track_GuideTooth_{side}_{i:02d}", (side*1.67,y,0.31), (0.12,0.11,0.15), TRACK, bevel=0.005)

# Barrel thermal sleeve bands and muzzle detail.
for i,y in enumerate((2.35,2.72,3.10,3.48,3.86,4.22)):
    add_cylinder(f"MetalBarrel_SleeveBand_{i:02d}", (0,y,2.08), 0.105, 0.045, GUN, axis="Y", verts=24, bevel=0.005)
add_cylinder("MetalBarrel_MuzzleCollar", (0,4.91,2.08), 0.125, 0.08, GUN, axis="Y", verts=28, bevel=0.006)

# Turret weld/panel seam cues.
for side in (-1,1):
    add_bar(f"Body_TurretWeldUpper_{side}", (side*1.38,-1.30,2.36), (side*1.38,0.62,2.34), 0.018, BODY, verts=12)
    add_bar(f"Body_TurretWeldLower_{side}", (side*1.43,-1.30,1.84), (side*1.43,0.58,1.92), 0.016, BODY, verts=12)

# Bustle stowage: tarp rolls, jerry cans and antenna cable boxes.
for i,x in enumerate((-0.95,-0.45,0.55,1.00)):
    add_cylinder(f"Body_TarpRoll_{i:02d}", (x,-2.28,2.42), 0.12, 0.48, BODY, axis="X", verts=18, bevel=0.010)
for i,x in enumerate((-0.72,0.72)):
    add_box(f"Body_JerryCan_{i:02d}", (x,-2.42,2.10), (0.30,0.18,0.42), BODY, bevel=0.022)
    add_box(f"Body_JerryCanHandle_{i:02d}", (x,-2.52,2.34), (0.15,0.06,0.05), TRACK, bevel=0.008)

# Small neutral identification panels (geometry, not UI).
add_box("Body_IDPanel_Left", (-1.525,-0.18,2.16), (0.035,0.42,0.20), SIDE, bevel=0.006)
add_box("Body_IDPanel_Right", (1.525,-0.18,2.16), (0.035,0.42,0.20), SIDE, bevel=0.006)

# Ground entire procedural asset at Z=0 and center XY.
meshes = [o for o in bpy.context.scene.objects if o.type=="MESH"]
mins = [1e30,1e30,1e30]
maxs = [-1e30,-1e30,-1e30]
for obj in meshes:
    for c in obj.bound_box:
        p = obj.matrix_world @ Vector(c)
        for ax in range(3):
            mins[ax] = min(mins[ax], p[ax])
            maxs[ax] = max(maxs[ax], p[ax])
cx = (mins[0]+maxs[0])*0.5
cy = (mins[1]+maxs[1])*0.5
ground = mins[2]
for obj in meshes:
    obj.location.x -= cx
    obj.location.y -= cy
    obj.location.z -= ground

print("FRONTLINE_ABRAMS_V4_BOUNDS", mins, maxs, "center", cx, cy, "ground", ground)
print("FRONTLINE_ABRAMS_V4_MESH_COUNT", len(meshes))

os.makedirs(os.path.dirname(os.path.abspath(ns.output)), exist_ok=True)
bpy.ops.object.select_all(action="DESELECT")
for obj in meshes:
    obj.select_set(True)
bpy.context.view_layer.objects.active = meshes[0]
bpy.ops.export_scene.gltf(
    filepath=os.path.abspath(ns.output),
    export_format="GLB",
    use_selection=True,
    export_apply=True,
    export_cameras=False,
    export_lights=False,
    export_animations=False,
)
print("FRONTLINE_ABRAMS_V4_EXPORT", ns.output)
