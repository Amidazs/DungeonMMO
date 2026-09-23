"""Inspect Frostfang tail bone weight distribution and bend-related tearing."""

import json
import math
from collections import defaultdict
from pathlib import Path

import bpy
from mathutils import Vector


ROOT = (
    Path.home() / "Documents" / "Roblox" /
    "DungeonMMO_CanineRig_QA" / "Frostfang_20260923"
)
SOURCE = (
    ROOT / "RigFunctionQA_20260923" / "TailRepairV3_Tip" /
    "Frostfang_TailSkinV3_Tip_UNAPPROVED.blend"
)
TAIL_BONES = (
    "DEF_spine.004", "DEF_spine.003", "DEF_spine.002",
    "DEF_spine.001", "DEF_spine",
)


def weight_statistics(mesh):
    """Summarize source vertices assigned to tail-chain skinning groups.

    Args:
        mesh (bpy.types.Object): Unmodified original skinned mesh.

    Returns:
        dict: Counts, weight ranges and longitudinal group distributions.
    """
    results = {}
    for name in TAIL_BONES:
        group = mesh.vertex_groups.get(name)
        if group is None:
            continue
        assigned = [
            (vertex.co.y, vertex.co.z, item.weight)
            for vertex in mesh.data.vertices
            for item in vertex.groups
            if item.group == group.index and item.weight > 0.10
        ]
        results[name] = {
            "vertices": len(assigned),
            "min_y": round(min((v[0] for v in assigned), default=0), 4),
            "max_y": round(max((v[0] for v in assigned), default=0), 4),
            "min_z": round(min((v[1] for v in assigned), default=0), 4),
            "max_z": round(max((v[1] for v in assigned), default=0), 4),
            "mean_weight": round(
                sum(v[2] for v in assigned) / len(assigned), 4
            ) if assigned else 0.0,
        }
    return results


def mesh_world_positions(mesh):
    """Collect evaluated mesh positions using the current armature pose.

    Args:
        mesh (bpy.types.Object): Mesh bound to the experimental armature.

    Returns:
        list[Vector]: Evaluated vertex positions in world space.
    """
    evaluated = mesh.evaluated_get(
        bpy.context.evaluated_depsgraph_get()
    )
    result = evaluated.to_mesh()
    try:
        return [
            evaluated.matrix_world @ vertex.co
            for vertex in result.vertices
        ]
    finally:
        evaluated.to_mesh_clear()


def tail_edge_distortion(mesh, rest, posed):
    """Measure maximum edge stretching limited to tail-shaped geometry.

    Args:
        mesh (bpy.types.Object): Actual source triangulated geometry.
        rest (list[Vector]): Neutral evaluated vertices.
        posed (list[Vector]): Corresponding tested-pose vertices.

    Returns:
        dict: Edge distortion quantiles and severe-edge locations.
    """
    stretched = []
    for edge in mesh.data.edges:
        start, end = edge.vertices
        if min(rest[start].y, rest[end].y) < 0.35:
            continue
        original = (rest[start] - rest[end]).length
        if original < 0.000001:
            continue
        ratio = (posed[start] - posed[end]).length / original
        if ratio > 1.25:
            midpoint = (rest[start] + rest[end]) / 2.0
            stretched.append((ratio, midpoint.y, midpoint.z))
    stretched.sort(reverse=True)
    return {
        "edges_stretched_125_percent": len(stretched),
        "edges_stretched_150_percent": sum(
            ratio > 1.5 for ratio, _, _ in stretched
        ),
        "edges_stretched_200_percent": sum(
            ratio > 2.0 for ratio, _, _ in stretched
        ),
        "worst": [
            {"ratio": round(ratio, 4), "y": round(y, 4),
             "z": round(z, 4)}
            for ratio, y, z in stretched[:10]
        ],
    }


def compare_bend(mesh, rig):
    """Check actual weighted tail edge distortion for each joint pitch.

    Args:
        mesh (bpy.types.Object): Source skinned wolf mesh.
        rig (bpy.types.Object): Source compact deform armature.

    Returns:
        dict: 6/12-degree bend distortion metrics by joint.
    """
    rest = mesh_world_positions(mesh)
    reports = {}
    for name in TAIL_BONES[1:4]:
        bone = rig.pose.bones[name]
        for angle in (6, 12):
            bone.rotation_mode = "XYZ"
            bone.rotation_euler.x = math.radians(angle)
            posed = mesh_world_positions(mesh)
            reports[f"{name}_{angle}deg"] = tail_edge_distortion(
                mesh, rest, posed
            )
            bone.rotation_euler.x = 0.0
    return reports


def main():
    """Print a read-only tail topology and skinning failure report.

    Args:
        None.

    Returns:
        None: Emits counts without writing back to source.
    """
    bpy.ops.wm.open_mainfile(filepath=str(SOURCE))
    mesh = bpy.data.objects["Frostfang_Canine_ExperimentalMesh"]
    rig = bpy.data.objects["Frostfang_Canine_CompactRig"]
    report = {
        "skin_groups": weight_statistics(mesh),
        "pitch_bend": compare_bend(mesh, rig),
    }
    print("TAIL_SOURCE_AUDIT", json.dumps(report), flush=True)


if __name__ == "__main__":
    main()
