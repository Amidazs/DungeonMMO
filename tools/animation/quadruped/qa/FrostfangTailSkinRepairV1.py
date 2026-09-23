"""Smooth disconnected Frostfang tail weights on a separate rig copy.

The original JawV3 master and all Studio places remain unchanged.
This is an unapproved source-mesh skinning repair, not an animation.
"""

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
SOURCE = ROOT / "Frostfang_Canine_ExperimentalMaster_JawV3.blend"
OUTPUT = ROOT / "RigFunctionQA_20260923" / "TailRepairV1"
MESH_NAME = "Frostfang_Canine_ExperimentalMesh"
RIG_NAME = "Frostfang_Canine_CompactRig"
TAIL_GROUPS = (
    "DEF_spine.004", "DEF_spine.003", "DEF_spine.002",
    "DEF_spine.001", "DEF_spine",
)
SMOOTH_PASSES = 22
NEIGHBOR_BLEND = 0.8
MIN_TAIL_INFLUENCE = 0.10
MIN_TAIL_Y = 0.405
MAX_TAIL_Z = 0.60
QUANTIZATION = 1000


def tail_weights(mesh):
    """Read every source vertex's original tail-chain influences.

    Args:
        mesh (bpy.types.Object): Actual skinned Frostfang mesh.

    Returns:
        tuple: Group indices and per-vertex tail-weight dictionaries.
    """
    indices = {
        mesh.vertex_groups[name].index: name for name in TAIL_GROUPS
    }
    weights = []
    for vertex in mesh.data.vertices:
        weights.append({
            indices[item.group]: item.weight
            for item in vertex.groups
            if item.group in indices and item.weight > 0.0
        })
    return indices, weights


def editable_vertices(mesh, original):
    """Restrict edits to rear low-lying tail fur with tail influences.

    Args:
        mesh (bpy.types.Object): Original standing canine.
        original (list[dict]): All original tail-group weights.

    Returns:
        set[int]: Source vertex indices eligible for local smoothing.
    """
    eligible = set()
    for vertex in mesh.data.vertices:
        if vertex.co.y < MIN_TAIL_Y or vertex.co.z > MAX_TAIL_Z:
            continue
        if sum(original[vertex.index].values()) >= MIN_TAIL_INFLUENCE:
            eligible.add(vertex.index)
    return eligible


def build_neighbors(mesh, eligible):
    """Create restricted graph connectivity only along actual fur edges.

    Args:
        mesh (bpy.types.Object): Original triangulated canine mesh.
        eligible (set[int]): Anatomically constrained tail vertices.

    Returns:
        dict: Vertex index to neighboring eligible source vertices.
    """
    adjacency = defaultdict(list)
    for edge in mesh.data.edges:
        first, second = edge.vertices
        if first in eligible and second in eligible:
            adjacency[first].append(second)
            adjacency[second].append(first)
    return dict(adjacency)


def diffuse_tail_weights(original, adjacency, group_indices):
    """Blend adjacent tail-group influences through the source mesh.

    Args:
        original (list[dict]): Source skin weights, never mutated.
        adjacency (dict): Actual tail-region graph neighbors.
        group_indices (dict): Existing tail group index to name mapping.

    Returns:
        dict: Smoothed per-vertex group weights in the tail region.
    """
    current = {
        index: original[index].copy() for index in adjacency
    }
    for _ in range(SMOOTH_PASSES):
        next_pass = {}
        for index, neighbors in adjacency.items():
            total = sum(original[index].values())
            if not neighbors or total <= 0.0:
                next_pass[index] = current[index].copy()
                continue
            averaged = {
                group: sum(
                    current[neighbor].get(group, 0.0)
                    for neighbor in neighbors
                ) / len(neighbors)
                for group in group_indices
            }
            mixed = {
                group: (
                    (1.0 - NEIGHBOR_BLEND) *
                    current[index].get(group, 0.0) +
                    NEIGHBOR_BLEND * averaged[group]
                )
                for group in group_indices
            }
            scale = total / max(sum(mixed.values()), 1e-12)
            next_pass[index] = {
                group: value * scale
                for group, value in mixed.items()
                if value * scale > 1e-5
            }
        current = next_pass
    return current


def preserve_influence_budget(mesh, original, smoothed):
    """Retain at most four total skin influences per edited vertex.

    Args:
        mesh (bpy.types.Object): Original weighted animal geometry.
        original (list[dict]): Unchanged original tail group values.
        smoothed (dict): New local tail-group distributions.

    Returns:
        dict: Final per-vertex tail weights with <=4 total groups.
    """
    group_set = {
        mesh.vertex_groups[name].index for name in TAIL_GROUPS
    }
    output = {}
    for index, proposal in smoothed.items():
        unchanged = {
            item.group: item.weight
            for item in mesh.data.vertices[index].groups
            if item.group not in group_set and item.weight > 0.0
        }
        total_original = sum(original[index].values())
        slots = max(0, 4 - len(unchanged))
        retained = sorted(
            proposal.items(), key=lambda item: item[1], reverse=True
        )[:slots]
        retained_total = sum(value for _, value in retained)
        if retained_total <= 0.0:
            output[index] = original[index].copy()
            continue
        output[index] = {
            group: value * total_original / retained_total
            for group, value in retained
        }
    return output


def apply_tail_weights(mesh, original, updated, group_indices):
    """Replace only altered tail-group values in weighted vertex batches.

    Args:
        mesh (bpy.types.Object): Source-preserving experimental copy.
        original (list[dict]): Unchanged original tail weights.
        updated (dict): Edited tail weights for eligible vertices.
        group_indices (dict): Existing group index to bone name mapping.

    Returns:
        dict: Counts of modified and preserved weighted vertices.
    """
    changed = [
        index for index, new_values in updated.items()
        if any(
            abs(new_values.get(group, 0.0) -
                original[index].get(group, 0.0)) > 0.0001
            for group in group_indices
        )
    ]
    buckets = defaultdict(lambda: defaultdict(list))
    for index in changed:
        for group, weight in updated[index].items():
            quantized = min(
                QUANTIZATION, max(1, round(weight * QUANTIZATION))
            )
            buckets[group][quantized].append(index)
    for group, name in group_indices.items():
        vertex_group = mesh.vertex_groups[name]
        vertex_group.remove(changed)
        for quantized, members in buckets[group].items():
            vertex_group.add(
                members, quantized / QUANTIZATION, "REPLACE"
            )
    mesh.data.update()
    return {
        "changed_vertices": len(changed),
        "eligible_vertices": len(updated),
        "unmodified_vertices": len(mesh.data.vertices) - len(changed),
    }


def evaluated_positions(mesh):
    """Measure actual weighted mesh positions under the current pose.

    Args:
        mesh (bpy.types.Object): Skinned wolf with active armature.

    Returns:
        list[Vector]: World-space deformed vertex coordinates.
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


def measure_tail_edges(mesh, rest, bent):
    """Count actual tail edges with gross deformation under bending.

    Args:
        mesh (bpy.types.Object): Source triangulated Frostfang mesh.
        rest (list[Vector]): Actual evaluated neutral vertex positions.
        bent (list[Vector]): Evaluated vertices at one tested pose.

    Returns:
        dict: Severe edge ratios with explicit sample-area constraints.
    """
    ratios = []
    for edge in mesh.data.edges:
        first, second = edge.vertices
        if min(rest[first].y, rest[second].y) < 0.35:
            continue
        length = (rest[first] - rest[second]).length
        if length < 1e-6:
            continue
        ratios.append((bent[first] - bent[second]).length / length)
    return {
        "edge_count": len(ratios),
        "stretched_over_1_5": sum(value > 1.5 for value in ratios),
        "stretched_over_2": sum(value > 2.0 for value in ratios),
        "stretched_over_4": sum(value > 4.0 for value in ratios),
        "max_ratio": round(max(ratios, default=0.0), 5),
    }


def test_tail_bend(mesh, rig, angle):
    """Evaluate source-tail distortion with a reproducible pitch test.

    Args:
        mesh (bpy.types.Object): Experimental skinned mesh.
        rig (bpy.types.Object): Measured compact canine armature.
        angle (int): Test rotation in degrees on the first tail segment.

    Returns:
        dict: Actual 3D deformation metrics at this controlled pose.
    """
    rest = evaluated_positions(mesh)
    bone = rig.pose.bones["DEF_spine.003"]
    bone.rotation_mode = "XYZ"
    bone.rotation_euler.x = math.radians(angle)
    bent = evaluated_positions(mesh)
    metrics = measure_tail_edges(mesh, rest, bent)
    bone.rotation_euler.x = 0.0
    return metrics


def main():
    """Make and audit a new tail-skin candidate without editing sources.

    Args:
        None.

    Returns:
        None: Saves separate Blender file and before/after diagnostic.
    """
    OUTPUT.mkdir(parents=True, exist_ok=True)
    bpy.ops.wm.open_mainfile(filepath=str(SOURCE))
    mesh = bpy.data.objects[MESH_NAME]
    rig = bpy.data.objects[RIG_NAME]
    before = {
        str(angle): test_tail_bend(mesh, rig, angle)
        for angle in (6, 12)
    }
    indices, original = tail_weights(mesh)
    eligible = editable_vertices(mesh, original)
    adjacent = build_neighbors(mesh, eligible)
    diffused = diffuse_tail_weights(original, adjacent, indices)
    updated = preserve_influence_budget(mesh, original, diffused)
    counts = apply_tail_weights(mesh, original, updated, indices)
    after = {
        str(angle): test_tail_bend(mesh, rig, angle)
        for angle in (6, 12)
    }
    destination = OUTPUT / "Frostfang_TailSkinV1_UNAPPROVED.blend"
    bpy.ops.wm.save_as_mainfile(filepath=str(destination))
    report = {
        "source": str(SOURCE),
        "destination": str(destination),
        "status": "UNAPPROVED isolated tail weight experiment",
        "passes": SMOOTH_PASSES,
        "vertex_counts": counts,
        "before": before,
        "after": after,
        "blockers": [
            "Source jaw is still a closed single mesh.",
            "Hind-leg and shoulder skin have not been corrected.",
            "Visual tail bend approval and Studio playback pending.",
        ],
    }
    (OUTPUT / "tail_skin_v1_audit.json").write_text(
        json.dumps(report, indent=2), encoding="utf-8"
    )
    print("TAIL_SKIN_V1", json.dumps(report), flush=True)


if __name__ == "__main__":
    main()
