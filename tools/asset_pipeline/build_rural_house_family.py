#!/usr/bin/env python3
"""FRONTLINE Asset Pipeline V1 prototype.

Blender Python script that creates a deterministic rural masonry house family.
It is intentionally additive: it never edits existing repository assets.

Run with Blender:
  blender --background --python tools/asset_pipeline/build_rural_house_family.py -- \
    --output-dir assets/generated/asset_pipeline_v1/rural_house
"""
from __future__ import annotations

import argparse
import math
import os
import sys
from pathlib import Path

import bpy
from mathutils import Vector

BUILD_ID = "FRONTLINE_ASSET_PIPELINE_V1_RURAL_HOUSE"


def parse_args() -> argparse.Namespace:
    argv = sys.argv
    argv = argv[argv.index("--") + 1 :] if "--" in argv else []
    parser = argparse.ArgumentParser()
    parser.add_argument("--output-dir", required=True)
    parser.add_argument("--seed", type=int, default=4711)
    return parser.parse_args(argv)


def reset_scene() -> None:
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    for datablocks in (bpy.data.meshes, bpy.data.curves, bpy.data.materials):
        # Materials are rebuilt below; remove only unused datablocks.
        for block in list(datablocks):
            if block.users == 0:
                datablocks.remove(block)


def mat(name: str, color: tuple[float, float, float, float], roughness: float = 0.75, metallic: float = 0.0):
    m = bpy.data.materials.get(name) or bpy.data.materials.new(name=name)
    m.diffuse_color = color
    m.use_nodes = True
    bsdf = m.node_tree.nodes.get("Principled BSDF")
    bsdf.inputs["Base Color"].default_value = color
    bsdf.inputs["Roughness"].default_value = roughness
    bsdf.inputs["Metallic"].default_value = metallic
    return m


def apply_bevel(obj: bpy.types.Object, width: float, segments: int = 2) -> None:
    mod = obj.modifiers.new(name="TECH_BEVEL", type="BEVEL")
    mod.width = width
    mod.segments = segments
    mod.limit_method = "ANGLE"
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.modifier_apply(modifier=mod.name)


def cube(name: str, size: tuple[float, float, float], loc: tuple[float, float, float], material=None, bevel: float = 0.0):
    bpy.ops.mesh.primitive_cube_add(location=loc)
    obj = bpy.context.active_object
    obj.name = name
    obj.dimensions = size
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    if bevel > 0:
        apply_bevel(obj, bevel)
    if material:
        obj.data.materials.append(material)
    return obj


def make_roof(name: str, width: float, depth: float, eave_y: float, z: float, pitch_deg: float, material):
    # Two pitched slabs rather than one block, giving readable eaves and ridge silhouette.
    pitch = math.radians(pitch_deg)
    half_span = depth * 0.5
    slope_len = half_span / math.cos(pitch)
    rise = math.tan(pitch) * half_span
    thickness = 0.22
    parts = []
    for side in (-1, 1):
        slab = cube(
            f"{name}_{'N' if side < 0 else 'S'}",
            (width + 0.6, slope_len + 0.35, thickness),
            (0.0, side * half_span * 0.5, z + rise * 0.5),
            material,
            bevel=0.035,
        )
        slab.rotation_euler.x = side * pitch
        bpy.ops.object.transform_apply(location=False, rotation=False, scale=False)
        parts.append(slab)
    ridge = cube(f"{name}_RIDGE", (width + 0.72, 0.16, 0.16), (0, 0, z + rise), material, bevel=0.03)
    parts.append(ridge)
    return parts


def opening_frame(prefix: str, x: float, y: float, z: float, width: float, height: float, on_front: bool, trim_mat, glass_mat):
    depth = 0.18
    t = 0.11
    if on_front:
        cube(prefix + "_GLASS", (width - 2*t, depth*0.4, height - 2*t), (x, y, z), glass_mat, bevel=0.015)
        cube(prefix + "_L", (t, depth, height), (x - width/2 + t/2, y, z), trim_mat, bevel=0.015)
        cube(prefix + "_R", (t, depth, height), (x + width/2 - t/2, y, z), trim_mat, bevel=0.015)
        cube(prefix + "_T", (width, depth, t), (x, y, z + height/2 - t/2), trim_mat, bevel=0.015)
        cube(prefix + "_B", (width, depth, t), (x, y, z - height/2 + t/2), trim_mat, bevel=0.015)
        cube(prefix + "_M", (t*0.8, depth*1.05, height-2*t), (x, y-0.005, z), trim_mat, bevel=0.01)
    else:
        cube(prefix + "_GLASS", (depth*0.4, width - 2*t, height - 2*t), (x, y, z), glass_mat, bevel=0.015)
        cube(prefix + "_L", (depth, t, height), (x, y - width/2 + t/2, z), trim_mat, bevel=0.015)
        cube(prefix + "_R", (depth, t, height), (x, y + width/2 - t/2, z), trim_mat, bevel=0.015)
        cube(prefix + "_T", (depth, width, t), (x, y, z + height/2 - t/2), trim_mat, bevel=0.015)
        cube(prefix + "_B", (depth, width, t), (x, y, z - height/2 + t/2), trim_mat, bevel=0.015)


def build_house(variant: str, damage: bool = False, lod: int = 0):
    root = bpy.data.objects.new(f"RURAL_HOUSE_{variant}_{'DAMAGED' if damage else 'INTACT'}_LOD{lod}", None)
    bpy.context.scene.collection.objects.link(root)

    plaster = mat("MAT_PLASTER_WARM", (0.48, 0.42, 0.33, 1.0), 0.82)
    brick = mat("MAT_BRICK_EXPOSED", (0.34, 0.17, 0.095, 1.0), 0.88)
    roof_mat = mat("MAT_ROOF_DARK_TILE", (0.14, 0.105, 0.08, 1.0), 0.72)
    timber = mat("MAT_TIMBER_DARK", (0.12, 0.075, 0.045, 1.0), 0.83)
    stone = mat("MAT_FOUNDATION_STONE", (0.28, 0.27, 0.24, 1.0), 0.91)
    trim = mat("MAT_WINDOW_TRIM", (0.15, 0.14, 0.12, 1.0), 0.65)
    glass = mat("MAT_WINDOW_GLASS", (0.08, 0.12, 0.13, 1.0), 0.18, 0.05)
    metal = mat("MAT_METAL_DARK", (0.12, 0.13, 0.13, 1.0), 0.48, 0.6)

    width, depth = (10.8, 7.2) if variant == "A" else (9.4, 8.0)
    wall_h = 5.4 if variant == "A" else 4.9
    wall_t = 0.34

    # Stone foundation band and four structural walls. Separate wall objects make later
    # damaged derivatives easy and preserve meaningful material/LOD boundaries.
    foundation = cube("FOUNDATION", (width+0.15, depth+0.15, 0.7), (0,0,0.35), stone, bevel=0.06)
    foundation.parent = root

    # Avoid a single sealed box: use wall slabs so windows/doors read as real recesses.
    front_z = 0.7 + wall_h/2
    walls = []
    # front broken into bays around openings
    front_y = -depth/2 + wall_t/2
    back_y = depth/2 - wall_t/2
    left_x = -width/2 + wall_t/2
    right_x = width/2 - wall_t/2

    # bay widths, deterministic architectural rhythm
    bay_specs = [(-4.35, 1.55), (-2.4, 1.15), (0.0, 2.65), (2.65, 1.3), (4.4, 1.5)] if variant == "A" else [(-3.65, 1.25), (-1.8, 1.25), (0.25, 1.55), (2.25, 1.2), (3.8, 1.2)]
    for i, (cx, bw) in enumerate(bay_specs):
        wall = cube(f"WALL_FRONT_BAY_{i:02d}", (bw, wall_t, wall_h), (cx, front_y, front_z), plaster, bevel=0.035 if lod == 0 else 0.0)
        wall.parent = root
        walls.append(wall)

    # rear and side walls; damaged version removes/shortens one corner later
    back = cube("WALL_REAR", (width, wall_t, wall_h), (0, back_y, front_z), plaster, bevel=0.035 if lod == 0 else 0.0)
    left = cube("WALL_LEFT", (wall_t, depth-2*wall_t, wall_h), (left_x, 0, front_z), plaster, bevel=0.035 if lod == 0 else 0.0)
    right = cube("WALL_RIGHT", (wall_t, depth-2*wall_t, wall_h), (right_x, 0, front_z), plaster, bevel=0.035 if lod == 0 else 0.0)
    for w in (back,left,right):
        w.parent = root
        walls.append(w)

    # Upper floor belt and sill/cornice break large planar walls.
    if lod <= 1:
        for y in (front_y-0.06, back_y+0.06):
            belt = cube("CORNICE", (width+0.12, 0.12, 0.14), (0,y,3.35), stone, bevel=0.025)
            belt.parent = root

    # Windows/door are authored as recessed assemblies rather than textures.
    if lod <= 1:
        win_positions = [(-3.5, 2.35), (1.0, 2.35), (3.5, 2.35), (-3.5, 4.45), (-0.8, 4.45), (2.6, 4.45)]
        for idx, (x,z) in enumerate(win_positions):
            opening_frame(f"WINDOW_F_{idx:02d}", x, front_y-0.19, z, 1.25, 1.45, True, trim, glass)
        # Rear rhythm differs so the asset is not merely mirrored.
        for idx, x in enumerate((-3.1, -0.6, 2.25)):
            opening_frame(f"WINDOW_R_{idx:02d}", x, back_y+0.19, 2.6 + (idx%2)*1.65, 1.15, 1.35, True, trim, glass)
        # Entry vestibule and real door slab
        door = cube("ENTRY_DOOR", (1.25, 0.16, 2.25), (-0.85, front_y-0.20, 1.82), timber, bevel=0.035)
        door.parent = root
        lintel = cube("ENTRY_LINTEL", (1.65, 0.30, 0.22), (-0.85, front_y-0.16, 3.02), stone, bevel=0.035)
        lintel.parent = root

    roof_parts = make_roof("ROOF", width, depth, front_y, 0.7 + wall_h + 0.08, 38 if variant == "A" else 34, roof_mat)
    for p in roof_parts: p.parent = root

    if lod == 0:
        # Chimney, gutters and downspout add the kind of silhouette detail missing from
        # the old Godot primitive houses.
        chim = cube("CHIMNEY", (0.75,0.68,2.1), (2.8,0.65,wall_h+2.0), brick, bevel=0.045)
        chim.parent = root
        gutter_f = cube("GUTTER_FRONT", (width+0.55,0.12,0.12), (0,-depth/2-0.18,wall_h+0.86), metal, bevel=0.025)
        gutter_f.parent = root
        spout = cube("DOWNSPOUT", (0.10,0.10,wall_h-0.15), (width/2+0.08,-depth/2-0.18,wall_h/2+0.65), metal, bevel=0.02)
        spout.parent = root
        # Timber yard awning / rear service lean-to.
        awning = cube("SERVICE_AWNING", (3.3,2.5,0.18), (-2.65, depth/2+1.15,2.75), roof_mat, bevel=0.025)
        awning.rotation_euler.x = math.radians(-9)
        awning.parent = root
        for px in (-4.05,-1.25):
            post = cube("AWNING_POST", (0.16,0.16,2.55), (px,depth/2+2.1,1.55), timber, bevel=0.02)
            post.parent = root

    if damage:
        # Deliberate structural damage, not random missing cubes: collapse one upper-front
        # corner, expose brick core and broken joists, then add a fractured parapet mass.
        # Remove upper-right front bay and substitute a lower broken section.
        for obj in list(root.children):
            if obj.name.startswith("WALL_FRONT_BAY_04"):
                bpy.data.objects.remove(obj, do_unlink=True)
        broken = cube("WALL_FRONT_BAY_04_BROKEN", (1.5,wall_t,2.75), (4.4,front_y,2.075), plaster, bevel=0.025)
        broken.parent = root
        core = cube("EXPOSED_BRICK_CORE", (0.22,0.08,2.35), (3.62,front_y-0.08,4.48), brick, bevel=0.015)
        core.rotation_euler.y = math.radians(-7)
        core.parent = root
        if lod == 0:
            for i in range(5):
                beam = cube(f"BROKEN_JOIST_{i:02d}", (1.9 + 0.22*i,0.16,0.14), (3.45,front_y-0.45,3.55+0.24*i), timber, bevel=0.02)
                beam.rotation_euler.z = math.radians(-13 + i*4)
                beam.parent = root
            # chunky masonry fragments concentrated below the damaged bay
            for i in range(18):
                angle = i * 2.399963
                radius = 0.45 + (i % 6) * 0.23
                frag = cube(f"RUBBLE_{i:02d}", (0.22+0.06*(i%3),0.14+0.05*(i%4),0.26+0.04*(i%5)), (3.9+math.cos(angle)*radius, front_y-0.55+math.sin(angle)*radius*0.35, 0.78+0.05*(i%5)), brick if i%3 else stone, bevel=0.025)
                frag.rotation_euler = (0.2*(i%3), 0.37*i, 0.11*(i%4))
                frag.parent = root

    # parent unattached window/detail objects to root
    for obj in list(bpy.context.scene.objects):
        if obj is root or obj.parent is not None:
            continue
        if obj.name.startswith(("WINDOW_", "ENTRY_", "FOUNDATION", "WALL_", "ROOF_", "CORNICE", "CHIMNEY", "GUTTER", "DOWNSPOUT", "SERVICE_", "AWNING_", "BROKEN_", "EXPOSED_", "RUBBLE_")):
            obj.parent = root

    # LOD2 is silhouette-first: remove all small detail and keep only massing.
    if lod >= 2:
        for obj in list(root.children):
            if not obj.name.startswith(("FOUNDATION", "WALL_", "ROOF_")):
                bpy.data.objects.remove(obj, do_unlink=True)

    return root


def export_root(root: bpy.types.Object, path: Path) -> None:
    bpy.ops.object.select_all(action="DESELECT")
    root.select_set(True)
    for child in root.children_recursive:
        child.select_set(True)
    bpy.context.view_layer.objects.active = root
    path.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.export_scene.gltf(
        filepath=str(path),
        export_format="GLB",
        use_selection=True,
        export_apply=True,
        export_yup=True,
        export_materials="EXPORT",
    )


def mesh_stats(root: bpy.types.Object) -> tuple[int,int]:
    verts = tris = 0
    depsgraph = bpy.context.evaluated_depsgraph_get()
    for obj in root.children_recursive:
        if obj.type != "MESH":
            continue
        evaluated = obj.evaluated_get(depsgraph)
        mesh = evaluated.to_mesh()
        verts += len(mesh.vertices)
        mesh.calc_loop_triangles()
        tris += len(mesh.loop_triangles)
        evaluated.to_mesh_clear()
    return verts, tris


def main() -> int:
    args = parse_args()
    out_dir = Path(args.output_dir)
    out_dir.mkdir(parents=True, exist_ok=True)
    reset_scene()

    specs = [
        ("A", False, 0, "rural_house_a_intact_lod0.glb"),
        ("A", True, 0, "rural_house_a_damaged_lod0.glb"),
        ("A", False, 1, "rural_house_a_intact_lod1.glb"),
        ("A", False, 2, "rural_house_a_intact_lod2.glb"),
        ("B", False, 0, "rural_house_b_intact_lod0.glb"),
    ]

    rows = []
    for variant, damage, lod, filename in specs:
        reset_scene()
        root = build_house(variant, damage, lod)
        verts, tris = mesh_stats(root)
        export_root(root, out_dir / filename)
        rows.append((filename, verts, tris, variant, damage, lod))
        print(f"ASSET_PIPELINE_EXPORT file={filename} verts={verts} tris={tris}")

    manifest = out_dir / "GENERATED_MANIFEST.tsv"
    manifest.write_text(
        "file\tvertices\ttriangles\tvariant\tdamaged\tlod\tbuild_id\n" +
        "\n".join(f"{f}\t{v}\t{t}\t{va}\t{int(d)}\t{l}\t{BUILD_ID}" for f,v,t,va,d,l in rows) + "\n",
        encoding="utf-8",
    )
    print(f"{BUILD_ID}_PASS outputs={len(rows)} manifest={manifest}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
