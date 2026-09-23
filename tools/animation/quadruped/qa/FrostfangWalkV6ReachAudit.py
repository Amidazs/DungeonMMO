"""Read-only foreleg IK reach and tail-base overlap diagnostics."""

from pathlib import Path

import bpy


ROOT = (
    Path.home() / "Documents" / "Roblox" /
    "DungeonMMO_CanineRig_QA" / "Frostfang_20260923" /
    "GroundedWalkTrial_20260923"
)
SOURCE = (
    ROOT / "WalkV6_Forequarter" / "Frostfang_WalkV6_UNAPPROVED.blend"
)
FRAMES = (17, 21, 22, 28, 29, 33, 34, 40, 41, 53, 58, 65)


def foreleg_positions(rig, label, suffix):
    """Report real armature joints and associated IK target positions.

    Args:
        rig (bpy.types.Object): Existing weighted source armature.
        label (str): FrontLeft or FrontRight mapping label.
        suffix (str): Left/right Blender bone suffix.

    Returns:
        dict: Coordinates and reach ratio for inspected foreleg.
    """
    upper = rig.pose.bones["DEF_front_thigh." + suffix]
    elbow = rig.pose.bones["DEF_front_shin." + suffix]
    foot = rig.pose.bones["DEF_front_foot." + suffix]
    shoulder_pos = rig.matrix_world @ upper.head
    elbow_pos = rig.matrix_world @ elbow.head
    ankle_pos = rig.matrix_world @ foot.head
    target = bpy.data.objects["DMMO_WalkV3_" + label]
    segments = (
        (shoulder_pos - elbow_pos).length +
        (elbow_pos - ankle_pos).length
    )
    return {
        "shoulder_y": round(shoulder_pos.y, 6),
        "elbow_y": round(elbow_pos.y, 6),
        "ankle_y": round(ankle_pos.y, 6),
        "target_y": round(target.location.y, 6),
        "target_z": round(target.location.z, 6),
        "reach_fraction": round(
            (shoulder_pos - ankle_pos).length / segments, 6
        ),
    }


def main():
    """Print selected frame reach positions without changing the file.

    Args:
        None.

    Returns:
        None: Emits measured positions and stops.
    """
    bpy.ops.wm.open_mainfile(filepath=str(SOURCE))
    rig = bpy.data.objects["Frostfang_Canine_CompactRig"]
    scene = bpy.context.scene
    for frame in FRAMES:
        scene.frame_set(frame)
        print(
            "FORELEG_REACH", frame,
            "L", foreleg_positions(rig, "FrontLeft", "L"),
            "R", foreleg_positions(rig, "FrontRight", "R"),
            flush=True,
        )


if __name__ == "__main__":
    main()
