"""Add restrained forequarter motion to an isolated Frostfang WalkV5 copy.

This is a diagnostic rig-motion candidate, not a grounded Roblox clip.
The original WalkV5, source meshes and Studio places are never modified.
"""

import json
import math
from pathlib import Path

import bpy
from mathutils import Quaternion


ROOT = (
    Path.home() / "Documents" / "Roblox" /
    "DungeonMMO_CanineRig_QA" / "Frostfang_20260923" /
    "GroundedWalkTrial_20260923"
)
SOURCE = ROOT / "WalkV5_PawOrientation" / (
    "Frostfang_WalkV5_UNAPPROVED.blend"
)
OUTPUT = ROOT / "WalkV6_Forequarter"
WALK_START = 17
WALK_END = 65
CYCLE_FRAMES = 24
SPINE_NAME = "DEF_spine.008"
NECK_NAME = "DEF_spine.010"
TAIL_NAME = "DEF_spine.001"


def smoothstep(value: float) -> float:
    """Return bounded easing for smooth starts and stops.

    Args:
        value (float): Input progress between zero and one.

    Returns:
        float: Cubic eased progress.
    """
    progress = max(0.0, min(1.0, value))
    return progress * progress * (3.0 - 2.0 * progress)


def motion_weight(frame: int) -> float:
    """Fade additional motions in and out without disturbing the rest.

    Args:
        frame (int): One-based animation frame.

    Returns:
        float: Animation influence between zero and one.
    """
    entering = smoothstep((frame - 9) / (WALK_START - 9))
    leaving = 1.0 - smoothstep(
        (frame - WALK_END) / (72 - WALK_END)
    )
    return entering * leaving


def key_rotation(rig, bone_name: str, angle: tuple, frame: int):
    """Key a small rest-relative bone rotation without changing weights.

    Args:
        rig (bpy.types.Object): Existing compact skinned wolf armature.
        bone_name (str): Exact inspected compact-rig bone identifier.
        angle (tuple): Euler XYZ rotation in radians.
        frame (int): Current animation frame.

    Returns:
        None: Updates only this pose bone's editable rotation keys.
    """
    bone = rig.pose.bones.get(bone_name)
    if bone is None:
        raise RuntimeError("Missing Frostfang bone: " + bone_name)
    bone.rotation_mode = "XYZ"
    bone.rotation_euler = angle
    bone.keyframe_insert(data_path="rotation_euler", frame=frame)


def author_motion(rig, scene):
    """Add low-amplitude counter-motion to WalkV5 for visual assessment.

    Args:
        rig (bpy.types.Object): The WalkV5 rig in a new unsaved copy.
        scene (bpy.types.Scene): Existing 72-frame walk timeline.

    Returns:
        dict: Recorded motion amplitudes and frames.
    """
    if scene.frame_start != 1 or scene.frame_end != 72:
        raise RuntimeError("WalkV5 timeline differs from the QA baseline")
    for bone_name in (SPINE_NAME, NECK_NAME, TAIL_NAME):
        if rig.pose.bones.get(bone_name) is None:
            raise RuntimeError("Missing source bone: " + bone_name)
    for frame in range(1, 73):
        scene.frame_set(frame)
        weight = motion_weight(frame)
        phase = 2.0 * math.pi * (frame - WALK_START) / CYCLE_FRAMES
        body_pitch = math.radians(0.65 * math.sin(2 * phase))
        shoulder_roll = math.radians(0.35 * math.sin(phase))
        neck_pitch = math.radians(-0.42 * math.sin(2 * phase))
        tail_yaw = math.radians(1.1 * math.sin(phase + 0.6))
        key_rotation(
            rig, SPINE_NAME,
            (body_pitch * weight, 0.0, shoulder_roll * weight),
            frame,
        )
        key_rotation(
            rig, NECK_NAME, (neck_pitch * weight, 0.0, 0.0), frame
        )
        key_rotation(
            rig, TAIL_NAME, (0.0, 0.0, tail_yaw * weight), frame
        )
    scene.frame_set(1)
    return {
        "spine_pitch_degrees": 0.65,
        "spine_roll_degrees": 0.35,
        "neck_counter_pitch_degrees": 0.42,
        "tail_yaw_degrees": 1.1,
        "frames": 72,
        "status": "UNAPPROVED: needs actual-toe and visual QA",
    }


def main():
    """Save a separately named trial without touching any earlier file.

    Args:
        None.

    Returns:
        None: Writes the editable Blend and an experimental manifest.
    """
    if not SOURCE.is_file():
        raise FileNotFoundError(str(SOURCE))
    OUTPUT.mkdir(parents=True, exist_ok=True)
    bpy.ops.wm.open_mainfile(filepath=str(SOURCE))
    scene = bpy.context.scene
    rig = bpy.data.objects["Frostfang_Canine_CompactRig"]
    report = author_motion(rig, scene)
    destination = OUTPUT / "Frostfang_WalkV6_UNAPPROVED.blend"
    if destination.exists():
        raise FileExistsError("Do not overwrite a previous V6 experiment")
    bpy.ops.wm.save_as_mainfile(filepath=str(destination))
    report.update({
        "source": str(SOURCE),
        "output": str(destination),
        "warning": (
            "IK toe targets are unchanged, but torso rotations may "
            "alter real toe contact. Measure evaluated mesh before approval."
        ),
    })
    (OUTPUT / "walk_v6_manifest.json").write_text(
        json.dumps(report, indent=2), encoding="utf-8"
    )
    print("WALK_V6_SAVED", destination, flush=True)


if __name__ == "__main__":
    main()
