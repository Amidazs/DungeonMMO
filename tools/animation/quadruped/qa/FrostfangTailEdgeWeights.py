"""Identify the exact skin-weight discontinuities at worst tail edges."""

import json
import math
from pathlib import Path

import bpy
from mathutils import Vector


SOURCE = (
    Path.home() / "Documents" / "Roblox" /
    "DungeonMMO_CanineRig_QA" / "Frostfang_20260923" /
    "Frostfang_Canine_ExperimentalMaster_JawV3.blend"
)


def world_vertices(mesh):
    """Return actual evaluated mesh positions from the current rig pose.

    Args:
        mesh (bpy.types.Object): Original skinned wolf geometry.

    Returns:
        list[Vector]: Evaluated vertex positions in world coordinates.
    """
    evaluated = mesh.evaluated_get(
        bpy.context.evaluated_depsgraph_get()
    )
    copied = evaluated.to_mesh()
    try:
        return [
            evaluated.matrix_world @ vertex.co
            for vertex in copied.vertices
        ]
    finally:
        evaluated.to_mesh_clear()


def vertex_weights(mesh, index):
    """Return actual group influences at one source vertex.

    Args:
        mesh (bpy.types.Object): Original weighted wolf.
        index (int): Original source vertex index.

    Returns:
        dict: Bone names and rounded skin weights.
    """
    return {
        mesh.vertex_groups[item.group].name: round(item.weight, 4)
        for item in mesh.data.vertices[index].groups
        if item.weight > 0.00001
    }


def inspect_edges(mesh, neutral, posed):
    """Report the most distorted actual tail edges and their group weights.

    Args:
        mesh (bpy.types.Object): Original skinned wolf mesh.
        neutral (list[Vector]): Neutral evaluated vertex positions.
        posed (list[Vector]): Evaluated positions under the test bend.

    Returns:
        list[dict]: Worst affected edges including source skin groups.
    """
    worst = []
    for edge in mesh.data.edges:
        first, second = edge.vertices
        if min(neutral[first].y, neutral[second].y) < 0.35:
            continue
        length = (neutral[first] - neutral[second]).length
        if length < 0.000001:
            continue
        ratio = (posed[first] - posed[second]).length / length
        if ratio > 4:
            worst.append((ratio, first, second, length))
    worst.sort(reverse=True)
    return [
        {
            "ratio": round(ratio, 4),
            "rest_length": round(length, 7),
            "vertex_a": first,
            "vertex_b": second,
            "coords_a": tuple(round(v, 5) for v in neutral[first]),
            "coords_b": tuple(round(v, 5) for v in neutral[second]),
            "weights_a": vertex_weights(mesh, first),
            "weights_b": vertex_weights(mesh, second),
        }
        for ratio, first, second, length in worst[:15]
    ]


def main():
    """Print extreme tail-edge source weights without modifying the model.

    Args:
        None.

    Returns:
        None: Emits a reproducible source-topology diagnostic.
    """
    bpy.ops.wm.open_mainfile(filepath=str(SOURCE))
    mesh = bpy.data.objects["Frostfang_Canine_ExperimentalMesh"]
    rig = bpy.data.objects["Frostfang_Canine_CompactRig"]
    neutral = world_vertices(mesh)
    bone = rig.pose.bones["DEF_spine.003"]
    bone.rotation_mode = "XYZ"
    bone.rotation_euler.x = math.radians(6.0)
    posed = world_vertices(mesh)
    print(
        "TAIL_EDGE_WEIGHTS",
        json.dumps(inspect_edges(mesh, neutral, posed)),
        flush=True,
    )


if __name__ == "__main__":
    main()
