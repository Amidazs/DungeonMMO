"""Test visible moving canine shoulders on a separate WalkV10 mesh copy.

This script gives a small, smoothly tapered part of existing upper-chest
weights to the corresponding shoulder bone. It never edits original art.
"""

import json
from pathlib import Path

import bpy


ROOT = (
    Path.home() / "Documents" / "Roblox" /
    "DungeonMMO_CanineRig_QA" / "Frostfang_20260923" /
    "GroundedWalkTrial_20260923"
)
SOURCE = ROOT / "WalkV10_ReachAwareShoulders" / (
    "Frostfang_WalkV10_UNAPPROVED.blend"
)
OUTPUT = ROOT / "WalkV11_ShoulderSkin"
DESTINATION = OUTPUT / "Frostfang_WalkV11_UNAPPROVED.blend"
CHEST_GROUP = "DEF_spine.008"
SHOULDERS = (
    ("L", (0.086, -0.36, 0.70)),
    ("R", (-0.148, -0.36, 0.70)),
)
SIDE_DIVIDER_X = -0.031
RADIUS = (0.155, 0.21, 0.21)
MAX_TRANSFER = 0.18
MIN_WEIGHT = 0.006


def smoothstep(value: float) -> float:
    """Return smooth compact support for local anatomical weighting.

    Args:
        value (float): Normalized distance from the shoulder center.

    Returns:
        float: Weight multiplier between zero and one.
    """
    t = max(0.0, min(1.0, value))
    return t * t * (3.0 - 2.0 * t)


def weight_at(vertex, group_id: int) -> float:
    """Read one current weighted skin influence, returning zero if absent.

    Args:
        vertex (bpy.types.MeshVertex): Original mesh vertex.
        group_id (int): Existing deform group index.

    Returns:
        float: Current strength of the skinning influence.
    """
    return next(
        (
            item.weight for item in vertex.groups
            if item.group == group_id
        ),
        0.0,
    )


def shoulder_falloff(vertex, center: tuple[float, float, float]) -> float:
    """Measure a small ellipsoidal shoulder region in rest-mesh space.

    Args:
        vertex (bpy.types.MeshVertex): Actual Frostfang vertex.
        center (tuple[float, float, float]): Measured shoulder region.

    Returns:
        float: Smooth factor constrained to the intended upper shoulder.
    """
    distances = [
        (coord - origin) / radius
        for coord, origin, radius in zip(
            vertex.co, center, RADIUS
        )
    ]
    distance = sum(value * value for value in distances) ** 0.5
    return 1.0 - smoothstep(distance)


def reweight_side(mesh, side: str, center: tuple):
    """Transfer some existing chest weight to an independently moving scapula.

    Args:
        mesh (bpy.types.Object): Separate weighted source mesh copy.
        side (str): Left or right leg suffix.
        center (tuple): Rest-space upper shoulder center.

    Returns:
        dict: Number of actually changed mesh vertices and total transfer.
    """
    chest = mesh.vertex_groups[CHEST_GROUP]
    shoulder = mesh.vertex_groups["DEF_shoulder." + side]
    changed = 0
    transferred = 0.0
    for vertex in mesh.data.vertices:
        if side == "L" and vertex.co.x <= SIDE_DIVIDER_X:
            continue
        if side == "R" and vertex.co.x >= SIDE_DIVIDER_X:
            continue
        factor = shoulder_falloff(vertex, center)
        if factor <= 0.0:
            continue
        old = weight_at(vertex, chest.index)
        if old < 0.05:
            continue
        shoulder_weight = weight_at(vertex, shoulder.index)
        if shoulder_weight <= 0 and len(vertex.groups) >= 4:
            continue
        amount = min(
            MAX_TRANSFER * factor, old * 0.40
        )
        if amount < MIN_WEIGHT:
            continue
        chest.add([vertex.index], old - amount, "REPLACE")
        shoulder.add(
            [vertex.index], shoulder_weight + amount, "REPLACE"
        )
        changed += 1
        transferred += amount
    return {
        "selected_vertices": changed,
        "total_weight_transferred": round(transferred, 6),
    }


def verify_influences(mesh):
    """Enforce four influences on every vertex after local skin transfer.

    Args:
        mesh (bpy.types.Object): Independently modified wolf mesh.

    Returns:
        dict: Counts of shoulder-assigned and excess-influence vertices.
    """
    shoulder_ids = {
        mesh.vertex_groups["DEF_shoulder." + side].index
        for side, _ in SHOULDERS
    }
    over_budget = 0
    assigned = 0
    for vertex in mesh.data.vertices:
        influences = [
            item for item in vertex.groups if item.weight > 0.00001
        ]
        over_budget += len(influences) > 4
        assigned += any(
            item.group in shoulder_ids for item in influences
        )
    if over_budget:
        raise RuntimeError(
            "Experimental shoulder skin exceeds four influences"
        )
    return {
        "shoulder_weighted_vertices": assigned,
        "over_four_influences": over_budget,
    }


def main():
    """Save separately weighted shoulder rig and reproducible QA counts.

    Args:
        None.

    Returns:
        None: Writes an unapproved Blender copy without changing source.
    """
    if not SOURCE.is_file():
        raise FileNotFoundError(str(SOURCE))
    OUTPUT.mkdir(parents=True, exist_ok=True)
    if DESTINATION.exists():
        raise FileExistsError(str(DESTINATION))
    bpy.ops.wm.open_mainfile(filepath=str(SOURCE))
    mesh = bpy.data.objects["Frostfang_Canine_ExperimentalMesh"]
    scene = bpy.context.scene
    scene.frame_set(1)
    changed = {
        side: reweight_side(mesh, side, center)
        for side, center in SHOULDERS
    }
    if any(item["selected_vertices"] < 25 for item in changed.values()):
        raise RuntimeError(
            "Too few suitable fur vertices: no Blender file saved"
        )
    changed.update(verify_influences(mesh))
    mesh.data.update()
    bpy.ops.wm.save_as_mainfile(filepath=str(DESTINATION))
    report = {
        "source": str(SOURCE),
        "output": str(DESTINATION),
        "changes": changed,
        "status": "UNAPPROVED: shoulder mesh and paw motion QA required",
        "warning": (
            "These are experimental anatomical weights; inspect actual "
            "mesh folds and seams in motion before accepting the rig."
        ),
    }
    (OUTPUT / "walk_v11_manifest.json").write_text(
        json.dumps(report, indent=2), encoding="utf-8"
    )
    print("WALK_V11_SHOULDER_SKIN", json.dumps(report), flush=True)


if __name__ == "__main__":
    main()
