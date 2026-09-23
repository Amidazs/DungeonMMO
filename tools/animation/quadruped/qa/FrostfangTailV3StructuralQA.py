"""Validate the experimental tail-tip rig against its unmodified V2 base.

This read-only study checks original geometry, bone names, skin budgets,
and actual deformed tail-tip movement on the separately saved copies.
"""

import json
import math
from pathlib import Path

import bpy
from mathutils import Vector


ROOT = (
    Path.home() / "Documents" / "Roblox" /
    "DungeonMMO_CanineRig_QA" / "Frostfang_20260923" /
    "RigFunctionQA_20260923"
)
SOURCE = ROOT / "TailRepairV2" / "Frostfang_TailSkinV2_UNAPPROVED.blend"
CANDIDATE = (
    ROOT / "TailRepairV3_Tip" /
    "Frostfang_TailSkinV3_Tip_UNAPPROVED.blend"
)
MESH_NAME = "Frostfang_Canine_ExperimentalMesh"
RIG_NAME = "Frostfang_Canine_CompactRig"
TIP_NAME = "DEF_spine"


def evaluated_points(mesh):
    """Return real weighted-vertex locations in the active armature pose.

    Args:
        mesh (bpy.types.Object): Skinned source wolf model.

    Returns:
        list[Vector]: Evaluated 3D mesh vertex positions.
    """
    evaluated = mesh.evaluated_get(
        bpy.context.evaluated_depsgraph_get()
    )
    temporary = evaluated.to_mesh()
    try:
        return [
            evaluated.matrix_world @ vertex.co
            for vertex in temporary.vertices
        ]
    finally:
        evaluated.to_mesh_clear()


def snapshot(path):
    """Open an isolated candidate and gather topology and tip response.

    Args:
        path (Path): Exact saved experimental Blender source.

    Returns:
        dict: Original mesh, skin-influence, tip-response information.
    """
    bpy.ops.wm.open_mainfile(filepath=str(path))
    mesh = bpy.data.objects[MESH_NAME]
    rig = bpy.data.objects[RIG_NAME]
    tip_index = mesh.vertex_groups[TIP_NAME].index
    rest = evaluated_points(mesh)
    tip_affected = sum(
        any(
            item.group == tip_index and item.weight > 0.01
            for item in vertex.groups
        )
        for vertex in mesh.data.vertices
    )
    counts = [
        sum(item.weight > 0.00001 for item in vertex.groups)
        for vertex in mesh.data.vertices
    ]
    poses = {}
    tip = rig.pose.bones[TIP_NAME]
    tip.rotation_mode = "XYZ"
    for angle in (6, 12):
        tip.rotation_euler.x = math.radians(angle)
        moved = evaluated_points(mesh)
        terminal = [
            (moved[index] - rest[index]).length
            for index, vertex in enumerate(mesh.data.vertices)
            if vertex.co.y > 0.71 and vertex.co.z < 0.46
        ]
        poses[str(angle)] = round(max(terminal, default=0.0), 6)
        tip.rotation_euler.x = 0.0
    return {
        "path": str(path),
        "rest": rest,
        "bones": sorted(bone.name for bone in rig.data.bones),
        "vertex_count": len(mesh.data.vertices),
        "triangle_count": len(mesh.data.polygons),
        "mesh_sections": 1,
        "max_vertex_influences": max(counts),
        "vertices_over_four_influences": sum(n > 4 for n in counts),
        "tip_weighted_vertices": tip_affected,
        "terminal_max_displacement": poses,
    }


def compare_snapshots(original, modified):
    """Report exact structural matching and unchanged source rest shape.

    Args:
        original (dict): Pre-tip independent V2 mesh snapshot.
        modified (dict): New V3 weighted-tip experimental snapshot.

    Returns:
        dict: Structural match, rest vertex error, and safe test status.
    """
    if len(original["rest"]) != len(modified["rest"]):
        raise RuntimeError("Candidate lost original mesh vertices")
    errors = [
        (first - second).length
        for first, second in zip(original["rest"], modified["rest"])
    ]
    return {
        "identical_skeleton": original["bones"] == modified["bones"],
        "same_original_topology": all(
            original[key] == modified[key]
            for key in ("vertex_count", "triangle_count")
        ),
        "max_neutral_vertex_deviation": round(max(errors), 8),
        "candidate_max_vertex_influences": (
            modified["max_vertex_influences"]
        ),
        "candidate_vertices_over_four": (
            modified["vertices_over_four_influences"]
        ),
        "pre_tip_weighted_vertices": original["tip_weighted_vertices"],
        "post_tip_weighted_vertices": modified["tip_weighted_vertices"],
        "pre_tip_motion": original["terminal_max_displacement"],
        "post_tip_motion": modified["terminal_max_displacement"],
    }


def main():
    """Save independent rig-contract QA without editing either model.

    Args:
        None.

    Returns:
        None: Writes a JSON comparison of real skinned mesh experiments.
    """
    base = snapshot(SOURCE)
    current = snapshot(CANDIDATE)
    report = compare_snapshots(base, current)
    destination = (
        ROOT / "TailRepairV3_Tip" /
        "tail_skin_v3_structural_validation.json"
    )
    destination.write_text(
        json.dumps(report, indent=2), encoding="utf-8"
    )
    print("TAIL_V3_STRUCTURE", json.dumps(report), flush=True)


if __name__ == "__main__":
    main()
