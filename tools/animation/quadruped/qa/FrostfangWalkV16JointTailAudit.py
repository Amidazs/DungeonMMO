"""Measure real foreleg articulation and tail skinning in WalkV16.

Diagnostic only. This reads an isolated Blender file and never saves it.
"""

import json
import math
from collections import defaultdict
from pathlib import Path

import bpy


ROOT = (
    Path.home() / "Documents" / "Roblox" /
    "DungeonMMO_CanineRig_QA" / "Frostfang_20260923" /
    "GroundedWalkTrial_20260923"
)
SOURCE = (
    ROOT / "WalkV16_PawPadGait" / "Frostfang_WalkV16_UNAPPROVED.blend"
)
FORELEGS = {
    "left": (
        "DEF_front_thigh.L", "DEF_front_shin.L", "DEF_front_foot.L"
    ),
    "right": (
        "DEF_front_thigh.R", "DEF_front_shin.R", "DEF_front_foot.R"
    ),
}
TAIL_NAMES = (
    "DEF_spine.004", "DEF_spine.003", "DEF_spine.002",
    "DEF_spine.001", "DEF_spine",
)


def joint_angle(rig, names):
    """Measure the elbow angle from current evaluated joint positions.

    Args:
        rig (bpy.types.Object): Skinned Frostfang armature.
        names (tuple[str, str, str]): Shoulder, forearm, paw bones.

    Returns:
        float: Interior elbow angle in degrees.
    """
    upper, lower, foot = (
        rig.pose.bones[name] for name in names
    )
    shoulder = rig.matrix_world @ upper.head
    elbow = rig.matrix_world @ lower.head
    ankle = rig.matrix_world @ foot.head
    a = shoulder - elbow
    b = ankle - elbow
    if a.length < 1e-7 or b.length < 1e-7:
        raise ValueError("Coincident foreleg joints")
    return math.degrees(a.angle(b))


def tail_vertex_indices(mesh):
    """Identify distinct tail-influenced vertex rings by rest position.

    Args:
        mesh (bpy.types.Object): Actual weighted Frostfang geometry.

    Returns:
        dict[str, list[int]]: Separate source-space tail-region indices.
    """
    group_ids = {
        mesh.vertex_groups[name].index for name in TAIL_NAMES
    }
    indices = []
    for vertex in mesh.data.vertices:
        tail_weight = sum(
            item.weight for item in vertex.groups
            if item.group in group_ids
        )
        if vertex.co.y > 0.35 and tail_weight >= 0.3:
            indices.append(vertex.index)
    if not indices:
        raise RuntimeError("No tail-influenced source vertices found")
    start = min(mesh.data.vertices[index].co.y for index in indices)
    end = max(mesh.data.vertices[index].co.y for index in indices)
    if end - start < 0.03:
        raise RuntimeError("Tail source span too short to classify")
    regions = {"base": [], "middle": [], "tip": []}
    for index in indices:
        ratio = (
            mesh.data.vertices[index].co.y - start
        ) / (end - start)
        region = "base" if ratio < 1 / 3 else (
            "middle" if ratio < 2 / 3 else "tip"
        )
        regions[region].append(index)
    if not all(regions.values()):
        raise RuntimeError("Tail thirds are not all represented")
    return regions


def tail_widths(mesh, regions):
    """Measure actual skinned lateral width of tail-region vertices.

    Args:
        mesh (bpy.types.Object): Animated wolf surface.
        regions (dict): Rest-geometry tail regions.

    Returns:
        dict[str, float]: X-axis extents in Blender source units.
    """
    graph = bpy.context.evaluated_depsgraph_get()
    evaluated = mesh.evaluated_get(graph)
    temporary = evaluated.to_mesh()
    try:
        matrix = evaluated.matrix_world
        return {
            label: max(
                (matrix @ temporary.vertices[index].co).x
                for index in indices
            ) - min(
                (matrix @ temporary.vertices[index].co).x
                for index in indices
            )
            for label, indices in regions.items()
        }
    finally:
        evaluated.to_mesh_clear()


def tail_weight_overlap(mesh, regions):
    """Identify hindleg and tail influences on shared tail vertices.

    Args:
        mesh (bpy.types.Object): Original weighted wolf geometry.
        regions (dict): Tail region source vertex indices.

    Returns:
        dict: Counts of tail vertices also influenced by hindleg bones.
    """
    hips = {
        group.index: group.name for group in mesh.vertex_groups
        if group.name.startswith(
            ("DEF_thigh.", "DEF_shin.", "DEF_foot.", "DEF_toe.")
        )
    }
    overlap = {}
    for label, indices in regions.items():
        matches = defaultdict(int)
        for index in indices:
            for item in mesh.data.vertices[index].groups:
                if item.group in hips and item.weight >= 0.01:
                    matches[hips[item.group]] += 1
        overlap[label] = dict(matches)
    return overlap


def joint_differences(samples):
    """Find largest between-frame elbow jumps and their frame numbers.

    Args:
        samples (dict): Side-labeled frame-angle lists.

    Returns:
        dict: Max jumps and local frame-to-frame angle traces.
    """
    output = {}
    for side, values in samples.items():
        increments = [
            (abs(values[i] - values[i - 1]), i + 1)
            for i in range(1, len(values))
        ]
        jumps = sorted(increments, reverse=True)[:8]
        output[side] = {
            "min_angle": round(min(values), 3),
            "max_angle": round(max(values), 3),
            "largest_changes": [
                {"frame": frame, "degrees": round(change, 3)}
                for change, frame in jumps
            ],
            "frame_angles": [
                round(angle, 3) for angle in values
            ],
        }
    return output


def main():
    """Audit both elbow trajectories and tail shape without source edits.

    Args:
        None.

    Returns:
        None: Prints reproducible compact QA metrics.
    """
    bpy.ops.wm.open_mainfile(filepath=str(SOURCE))
    rig = bpy.data.objects["Frostfang_Canine_CompactRig"]
    mesh = bpy.data.objects["Frostfang_Canine_ExperimentalMesh"]
    scene = bpy.context.scene
    regions = tail_vertex_indices(mesh)
    angles = {side: [] for side in FORELEGS}
    widths = {label: [] for label in regions}
    for frame in range(1, 73):
        scene.frame_set(frame)
        for side, names in FORELEGS.items():
            angles[side].append(joint_angle(rig, names))
        measured = tail_widths(mesh, regions)
        for label, width in measured.items():
            widths[label].append(width)
    report = {
        "source": str(SOURCE),
        "elbows": joint_differences(angles),
        "tail_regions": {
            label: {
                "vertices": len(regions[label]),
                "width_min": round(min(values), 6),
                "width_max": round(max(values), 6),
                "width_percent_span": round(
                    100 * (max(values) - min(values)) /
                    max(values[0], 1e-7), 3
                ),
            }
            for label, values in widths.items()
        },
        "hindleg_weight_overlap": tail_weight_overlap(mesh, regions),
    }
    print("WALK_V16_JOINT_TAIL_AUDIT", json.dumps(report), flush=True)


if __name__ == "__main__":
    main()
