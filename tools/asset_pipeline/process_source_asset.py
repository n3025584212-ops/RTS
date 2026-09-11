#!/usr/bin/env python3
"""Generic FRONTLINE Blender source-asset processor.

This is intentionally different from build_rural_house_family.py: it does not know
what a house, church, ruin, tank, or tree is. It imports an arbitrary glTF/GLB,
preserves the authored meshes/materials, normalizes the root, optionally builds a
non-destructive LOD derivative, and exports a deterministic GLB.

Examples:
  blender --background --python tools/asset_pipeline/process_source_asset.py -- \
    --input assets/visual_slice/hero_v2/urban_ruin/urban_ruin.gltf \
    --output assets/generated/asset_pipeline_v2/urban_ruin_processed.glb \
    --label urban_ruin --lod-ratio 1.0
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

import bpy

BUILD_ID = "FRONTLINE_ASSET_PIPELINE_V2_GENERIC_SOURCE"


def parse_args() -> argparse.Namespace:
    argv = sys.argv
    argv = argv[argv.index("--") + 1 :] if "--" in argv else []
    p = argparse.ArgumentParser()
    p.add_argument("--input", required=True)
    p.add_argument("--output", required=True)
    p.add_argument("--label", required=True)
    p.add_argument("--lod-ratio", type=float, default=1.0)
    return p.parse_args(argv)


def reset_scene() -> None:
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    for collection in (bpy.data.meshes, bpy.data.curves, bpy.data.materials, bpy.data.images):
        for block in list(collection):
            if block.users == 0:
                collection.remove(block)


def import_source(path: Path) -> list[bpy.types.Object]:
    before = set(bpy.context.scene.objects)
    suffix = path.suffix.lower()
    if suffix in {".glb", ".gltf"}:
        bpy.ops.import_scene.gltf(filepath=str(path))
    else:
        raise ValueError(f"Unsupported source format: {suffix}")
    imported = [obj for obj in bpy.context.scene.objects if obj not in before]
    if not imported:
        raise RuntimeError(f"No objects imported from {path}")
    return imported


def make_root(imported: list[bpy.types.Object], label: str) -> bpy.types.Object:
    root = bpy.data.objects.new(f"FRONTLINE_{label.upper()}_ROOT", None)
    bpy.context.scene.collection.objects.link(root)
    imported_set = set(imported)
    for obj in imported:
        if obj.parent not in imported_set:
            obj.parent = root
    return root


def apply_optional_lod(root: bpy.types.Object, ratio: float) -> None:
    if ratio >= 0.999:
        return
    if not 0.05 <= ratio < 1.0:
        raise ValueError("--lod-ratio must be in [0.05, 1.0]")
    for obj in root.children_recursive:
        if obj.type != "MESH" or len(obj.data.polygons) < 96:
            continue
        mod = obj.modifiers.new(name="FRONTLINE_LOD_DECIMATE", type="DECIMATE")
        mod.decimate_type = "COLLAPSE"
        mod.ratio = ratio
        mod.use_collapse_triangulate = True
        bpy.context.view_layer.objects.active = obj
        obj.select_set(True)
        try:
            bpy.ops.object.modifier_apply(modifier=mod.name)
        finally:
            obj.select_set(False)


def stats(root: bpy.types.Object) -> dict[str, int]:
    meshes = verts = tris = material_slots = 0
    deps = bpy.context.evaluated_depsgraph_get()
    for obj in root.children_recursive:
        if obj.type != "MESH":
            continue
        meshes += 1
        material_slots += len(obj.material_slots)
        evaluated = obj.evaluated_get(deps)
        mesh = evaluated.to_mesh()
        verts += len(mesh.vertices)
        mesh.calc_loop_triangles()
        tris += len(mesh.loop_triangles)
        evaluated.to_mesh_clear()
    return {
        "mesh_objects": meshes,
        "vertices": verts,
        "triangles": tris,
        "material_slots": material_slots,
    }


def export_root(root: bpy.types.Object, output: Path) -> None:
    bpy.ops.object.select_all(action="DESELECT")
    root.select_set(True)
    for child in root.children_recursive:
        child.select_set(True)
    bpy.context.view_layer.objects.active = root
    output.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.export_scene.gltf(
        filepath=str(output),
        export_format="GLB",
        use_selection=True,
        export_apply=True,
        export_yup=True,
        export_materials="EXPORT",
    )


def main() -> int:
    args = parse_args()
    src = Path(args.input).resolve()
    out = Path(args.output).resolve()
    if not src.exists():
        raise FileNotFoundError(src)

    reset_scene()
    imported = import_source(src)
    root = make_root(imported, args.label)
    apply_optional_lod(root, args.lod_ratio)
    report = stats(root)
    export_root(root, out)

    manifest = out.with_suffix(out.suffix + ".json")
    manifest.write_text(json.dumps({
        "build_id": BUILD_ID,
        "label": args.label,
        "source": str(src),
        "output": str(out),
        "lod_ratio": args.lod_ratio,
        **report,
    }, indent=2), encoding="utf-8")
    print(BUILD_ID + "_PASS " + json.dumps(report, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
