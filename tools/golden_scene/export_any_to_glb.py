import argparse
import os
import sys

import bpy


def clear_scene():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)


def import_source(path: str):
    ext = os.path.splitext(path)[1].lower()
    if ext == ".blend":
        bpy.ops.wm.open_mainfile(filepath=path)
        return
    clear_scene()
    if ext == ".fbx":
        bpy.ops.import_scene.fbx(filepath=path)
    elif ext in {".obj"}:
        # Blender 4.x operator.
        if hasattr(bpy.ops.wm, "obj_import"):
            bpy.ops.wm.obj_import(filepath=path)
        else:
            bpy.ops.import_scene.obj(filepath=path)
    elif ext in {".gltf", ".glb"}:
        bpy.ops.import_scene.gltf(filepath=path)
    else:
        raise RuntimeError(f"Unsupported source format: {ext}")


def sanitize_scene():
    # Keep visible mesh/armature hierarchy, remove cameras/lights that would
    # override Golden Scene lighting when the model is instanced in Godot.
    for obj in list(bpy.data.objects):
        if obj.type in {"CAMERA", "LIGHT"}:
            bpy.data.objects.remove(obj, do_unlink=True)

    meshes = [obj for obj in bpy.context.scene.objects if obj.type == "MESH"]
    if not meshes:
        raise RuntimeError("No mesh objects found in source asset")

    # Put the asset on the ground and centered around origin without changing
    # its proportions. This makes deterministic Godot fitting possible.
    depsgraph = bpy.context.evaluated_depsgraph_get()
    mins = [float("inf"), float("inf"), float("inf")]
    maxs = [float("-inf"), float("-inf"), float("-inf")]
    from mathutils import Vector
    for obj in meshes:
        eval_obj = obj.evaluated_get(depsgraph)
        for corner in eval_obj.bound_box:
            world = eval_obj.matrix_world @ Vector(corner)
            for axis in range(3):
                mins[axis] = min(mins[axis], world[axis])
                maxs[axis] = max(maxs[axis], world[axis])

    center_x = (mins[0] + maxs[0]) * 0.5
    center_y = (mins[1] + maxs[1]) * 0.5
    ground_z = mins[2]
    for obj in bpy.context.scene.objects:
        if obj.parent is None:
            obj.location.x -= center_x
            obj.location.y -= center_y
            obj.location.z -= ground_z


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", required=True)
    parser.add_argument("--output", required=True)
    args = parser.parse_args(sys.argv[sys.argv.index("--") + 1 :])

    source = os.path.abspath(args.source)
    output = os.path.abspath(args.output)
    os.makedirs(os.path.dirname(output), exist_ok=True)

    import_source(source)
    sanitize_scene()

    bpy.ops.export_scene.gltf(
        filepath=output,
        export_format="GLB",
        export_apply=True,
        export_yup=True,
        export_cameras=False,
        export_lights=False,
    )
    if not os.path.exists(output) or os.path.getsize(output) < 1024:
        raise RuntimeError("GLB export did not produce a usable file")
    print(f"FRONTLINE_GOLDEN_ASSET_EXPORT_OK source={source} output={output}")


if __name__ == "__main__":
    main()
