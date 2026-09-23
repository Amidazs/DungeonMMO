"""Give Frostfang's unused terminal tail bone a controlled skinned tip.

This uses only the separately saved TailRepairV2 experimental copy.
It does not alter the original model, gameplay, or Studio QA places.
"""

import json
import math
from collections import defaultdict
from pathlib import Path

import bpy
from mathutils import Vector


ROOT = (
    Path.home() / "Documents" / "Roblox" /
    "DungeonMMO_CanineRig_QA" / "Frostfang_20260923" /
    "RigFunctionQA_20260923"
)
SOURCE = ROOT / "TailRepairV2" / "Frostfang_TailSkinV2_UNAPPROVED.blend"
OUTPUT = ROOT / "TailRepairV3_Tip"
MESH_NAME = "Frostfang_Canine_ExperimentalMesh"
RIG_NAME = "Frostfang_Canine_CompactRig"
TAIL_GROUPS = (
    "DEF_spine.004", "DEF_spine.003", "DEF_spine.002",
    "DEF_spine.001", "DEF_spine",
)
TIP_NAME = "DEF_spine"
TIP_START_Y = 0.655
TIP_END_Y = 0.752
TIP_MAX_WEIGHT = 0.55
MAX_TIP_Z = 0.46
QUANTIZATION = 1000


def smoothstep(value):
    """Return a bounded, smooth transition between zero and one.

    Args:
        value (float): Normalized transition progress.

    Returns:
        float: Clamped cubic interpolation fraction.
    """
    amount = max(0.0, min(1.0, value))
    return amount * amount * (3.0 - 2.0 * amount)


def snapshot_weights(mesh, index):
    """Read all original joint influences for a candidate vertex.

    Args:
        mesh (bpy.types.Object): Existing V2 skinned wolf.
        index (int): Original vertex index.

    Returns:
        dict: Skinning group index to original weight.
    """
    return {
        item.group: item.weight
        for item in mesh.data.vertices[index].groups
        if item.weight > 0.00001
    }


def select_tip_vertices(mesh, groups):
    """Select actual rear terminal fur without changing belly or legs.

    Args:
        mesh (bpy.types.Object): V2 experimental source wolf.
        groups (set[int]): Exact tail deform group indices.

    Returns:
        list[int]: Source vertices eligible for tip-bone influence.
    """
    selected = []
    for vertex in mesh.data.vertices:
        if vertex.co.y < TIP_START_Y or vertex.co.z > MAX_TIP_Z:
            continue
        total = sum(
            item.weight for item in vertex.groups
            if item.group in groups
        )
        if total > 0.80:
            selected.append(vertex.index)
    return selected


def new_weights(mesh, index, tail_indices, tip_index):
    """Mix a gradually increasing terminal bone weight at one vertex.

    Args:
        mesh (bpy.types.Object): Existing V2 experimental source mesh.
        index (int): Eligible original vertex index.
        tail_indices (set[int]): Actual tail skin group indices.
        tip_index (int): Existing previously unweighted tip bone group.

    Returns:
        dict: Normalized group weights with <=4 influences.
    """
    vertex = mesh.data.vertices[index]
    previous = snapshot_weights(mesh, index)
    tail_total = sum(
        value for group, value in previous.items()
        if group in tail_indices
    )
    fraction = TIP_MAX_WEIGHT * smoothstep(
        (vertex.co.y - TIP_START_Y) /
        (TIP_END_Y - TIP_START_Y)
    )
    if fraction <= 0.00001:
        return previous
    result = {
        group: (value * (1.0 - fraction))
        if group in tail_indices else value
        for group, value in previous.items()
        if group != tip_index
    }
    result[tip_index] = tail_total * fraction
    top = sorted(
        result.items(), key=lambda entry: entry[1], reverse=True
    )[:4]
    old_sum = sum(previous.values())
    new_sum = sum(value for _, value in top)
    return {
        group: value * old_sum / new_sum
        for group, value in top if value > 0.00001
    }


def update_groups(mesh, members, changes, group_indices):
    """Apply all candidate skin weights using quantized group batches.

    Args:
        mesh (bpy.types.Object): Experimental skinned wolf copy.
        members (list[int]): Eligible selected terminal fur vertices.
        changes (dict): New final group weights by selected index.
        group_indices (set[int]): Original tail group indices.

    Returns:
        int: Number of source vertices modified in this copy.
    """
    if not members:
        raise RuntimeError("No eligible terminal tail vertices")
    buckets = defaultdict(lambda: defaultdict(list))
    for index, weights in changes.items():
        for group, value in weights.items():
            if group not in group_indices:
                continue
            scaled = min(
                QUANTIZATION, max(1, round(value * QUANTIZATION))
            )
            buckets[group][scaled].append(index)
    for group in group_indices:
        target = mesh.vertex_groups[group]
        target.remove(members)
        for scaled, indices in buckets[group].items():
            target.add(
                indices, scaled / QUANTIZATION, "REPLACE"
            )
    mesh.data.update()
    return len(members)


def evaluated_vertices(mesh):
    """Measure actual armature-deformed source vertices at current pose.

    Args:
        mesh (bpy.types.Object): Active original-looking wolf mesh.

    Returns:
        list[Vector]: Evaluated world-space vertex coordinates.
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


def terminal_displacement(mesh, rig, selected):
    """Measure independent terminal fur motion from the actual tip bone.

    Args:
        mesh (bpy.types.Object): Copy with new tip skinning weights.
        rig (bpy.types.Object): Unaltered compact bone hierarchy.
        selected (list[int]): Geometrically constrained terminal fur.

    Returns:
        dict: Actual 3D tip displacement at controlled tip rotations.
    """
    rest = evaluated_vertices(mesh)
    tip = rig.pose.bones[TIP_NAME]
    reports = {}
    for angle in (6, 12):
        tip.rotation_mode = "XYZ"
        tip.rotation_euler.x = math.radians(angle)
        posed = evaluated_vertices(mesh)
        offsets = [
            (posed[index] - rest[index]).length
            for index in selected
        ]
        reports[str(angle)] = {
            "mean_displacement": round(
                sum(offsets) / len(offsets), 6
            ),
            "max_displacement": round(max(offsets), 6),
        }
        tip.rotation_euler.x = 0.0
    return reports


def main():
    """Save an independent tip-weight repair with bone-motion proof.

    Args:
        None.

    Returns:
        None: Writes a separate editable Blend and diagnostic JSON.
    """
    OUTPUT.mkdir(parents=True, exist_ok=True)
    bpy.ops.wm.open_mainfile(filepath=str(SOURCE))
    mesh = bpy.data.objects[MESH_NAME]
    rig = bpy.data.objects[RIG_NAME]
    tail_indices = {
        mesh.vertex_groups[name].index for name in TAIL_GROUPS
    }
    tip_index = mesh.vertex_groups[TIP_NAME].index
    selected = select_tip_vertices(mesh, tail_indices)
    changes = {
        index: new_weights(mesh, index, tail_indices, tip_index)
        for index in selected
    }
    modified = update_groups(
        mesh, selected, changes, tail_indices
    )
    moved = terminal_displacement(
        mesh, rig, [
            index for index in selected
            if mesh.data.vertices[index].co.y > 0.71
        ]
    )
    saved = OUTPUT / "Frostfang_TailSkinV3_Tip_UNAPPROVED.blend"
    bpy.ops.wm.save_as_mainfile(filepath=str(saved))
    report = {
        "status": "UNAPPROVED isolated weighted tail tip",
        "source": str(SOURCE),
        "saved": str(saved),
        "modified_vertices": modified,
        "tip_bone_name": TIP_NAME,
        "independent_tip_motion": moved,
        "limitations": [
            "Visual shape and adjacent bone-bend QA remain open.",
            "Skin budget and Studio import still require validation.",
            "Jaw and hind-leg faults remain unchanged.",
        ],
    }
    (OUTPUT / "tail_skin_v3_tip_audit.json").write_text(
        json.dumps(report, indent=2), encoding="utf-8"
    )
    print("TAIL_TIP_V3", json.dumps(report), flush=True)


if __name__ == "__main__":
    main()
