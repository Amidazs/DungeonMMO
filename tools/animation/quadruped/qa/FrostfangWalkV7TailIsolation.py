"""Remove suspect hindleg skin weights from tail-dominant fur on a copy.

This is a reversible diagnostic for tail pumping during the walk.
It does not replace earlier tail repairs or edit an approved asset.
"""

import json
from pathlib import Path

import bpy


ROOT = (
    Path.home() / "Documents" / "Roblox" /
    "DungeonMMO_CanineRig_QA" / "Frostfang_20260923" /
    "GroundedWalkTrial_20260923"
)
SOURCE = (
    ROOT / "WalkV7_Foreleg" /
    "Frostfang_WalkV7_Foreleg_UNAPPROVED.blend"
)
OUTPUT = ROOT / "WalkV7_TailIsolation"
TAIL_NAMES = (
    "DEF_spine.004", "DEF_spine.003", "DEF_spine.002",
    "DEF_spine.001", "DEF_spine",
)
HIND_NAMES = (
    "DEF_thigh.L", "DEF_thigh.R",
    "DEF_shin.L", "DEF_shin.R",
)
MIN_TAIL_WEIGHT = 0.6
MIN_REAR_Y = 0.40


def eligible_vertices(mesh):
    """Find tail-dominant fur vertices also weighted to rear legs.

    Args:
        mesh (bpy.types.Object): Weighted original-look wolf surface.

    Returns:
        list[dict]: Source vertex IDs, hind weights and tail weights.
    """
    tail_ids = {
        mesh.vertex_groups[name].index for name in TAIL_NAMES
    }
    hind_ids = {
        mesh.vertex_groups[name].index for name in HIND_NAMES
    }
    results = []
    for vertex in mesh.data.vertices:
        if vertex.co.y <= MIN_REAR_Y:
            continue
        weights = {
            item.group: item.weight for item in vertex.groups
            if item.weight > 0
        }
        tail = {g: w for g, w in weights.items() if g in tail_ids}
        hind = {g: w for g, w in weights.items() if g in hind_ids}
        if sum(tail.values()) < MIN_TAIL_WEIGHT or not hind:
            continue
        results.append({
            "index": vertex.index,
            "tail": tail,
            "hind": hind,
            "original_influences": len(weights),
        })
    return results


def transfer_hind_weights(mesh, selected):
    """Redistribute hindleg weights within existing tail bone groups.

    Args:
        mesh (bpy.types.Object): Separate working mesh copy.
        selected (list[dict]): Measured tail-dominant source vertices.

    Returns:
        dict: Number of affected vertices and removed hind influences.
    """
    removed = 0
    for record in selected:
        index = record["index"]
        hind_total = sum(record["hind"].values())
        tail_total = sum(record["tail"].values())
        for group_id in record["hind"]:
            mesh.vertex_groups[group_id].remove([index])
            removed += 1
        for group_id, weight in record["tail"].items():
            new_weight = weight * (tail_total + hind_total) / tail_total
            mesh.vertex_groups[group_id].add(
                [index], new_weight, "REPLACE"
            )
    mesh.data.update()
    return {
        "selected_vertices": len(selected),
        "removed_hind_influences": removed,
    }


def verify_weights(mesh, selected):
    """Confirm hind influences are gone and total vertex weights remain.

    Args:
        mesh (bpy.types.Object): Edited experimental skinned surface.
        selected (list[dict]): Original vertex weight records.

    Returns:
        dict: Maximum source-weight discrepancy and remaining defects.
    """
    hind_ids = {
        mesh.vertex_groups[name].index for name in HIND_NAMES
    }
    bad_vertices = 0
    influence_overflow = 0
    for record in selected:
        vertex = mesh.data.vertices[record["index"]]
        if any(
            item.group in hind_ids and item.weight >= 0.00001
            for item in vertex.groups
        ):
            bad_vertices += 1
        if sum(item.weight > 0 for item in vertex.groups) > 4:
            influence_overflow += 1
    if bad_vertices or influence_overflow:
        raise RuntimeError("Tail isolation failed its weight safety check")
    return {
        "remaining_hind_overlap": bad_vertices,
        "vertices_over_four_influences": influence_overflow,
    }


def main():
    """Save the separate tail isolation trial and explicit non-approval.

    Args:
        None.

    Returns:
        None: Persists a new Blend and weight audit for visual comparison.
    """
    if not SOURCE.is_file():
        raise FileNotFoundError(str(SOURCE))
    OUTPUT.mkdir(parents=True, exist_ok=True)
    destination = OUTPUT / "Frostfang_WalkV7_Tail_UNAPPROVED.blend"
    if destination.exists():
        raise FileExistsError(str(destination))
    bpy.ops.wm.open_mainfile(filepath=str(SOURCE))
    mesh = bpy.data.objects["Frostfang_Canine_ExperimentalMesh"]
    selected = eligible_vertices(mesh)
    if not selected:
        raise RuntimeError("No suspect tail-hindleg overlap found")
    counts = transfer_hind_weights(mesh, selected)
    counts.update(verify_weights(mesh, selected))
    bpy.ops.wm.save_as_mainfile(filepath=str(destination))
    report = {
        "source": str(SOURCE),
        "destination": str(destination),
        "status": "UNAPPROVED: verify shape and paw deformation visually",
        "cutoff_y": MIN_REAR_Y,
        "minimum_tail_group_weight": MIN_TAIL_WEIGHT,
        "counts": counts,
        "notes": [
            "Only tail-dominant vertices shared with rear limbs changed.",
            "All original geometry and skeleton joints are preserved.",
            "Neutral-shape and gait mesh deformation remain to audit.",
            "This is not a solution for pre-existing tail-fur tearing.",
        ],
    }
    (OUTPUT / "tail_isolation_manifest.json").write_text(
        json.dumps(report, indent=2), encoding="utf-8"
    )
    print("WALK_V7_TAIL_ISOLATION", json.dumps(report), flush=True)


if __name__ == "__main__":
    main()
