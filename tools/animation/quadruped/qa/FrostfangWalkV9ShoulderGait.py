"""Author a canine four-beat shoulder gait on an isolated Frostfang copy.

The two shoulder joints follow opposite foreleg phases while the chest
counter-rotates. This is a Blender QA experiment, not a Roblox clip.
"""

import json
import math
from pathlib import Path

import bpy


ROOT = (
    Path.home() / "Documents" / "Roblox" /
    "DungeonMMO_CanineRig_QA" / "Frostfang_20260923" /
    "GroundedWalkTrial_20260923"
)
SOURCE = ROOT / "WalkV8_ForelegTail" / "Frostfang_WalkV8_UNAPPROVED.blend"
OUTPUT = ROOT / "WalkV9_ShoulderGait"
OUTPUT_NAME = "Frostfang_WalkV9_UNAPPROVED.blend"
FPS = 24
END_FRAME = 72
WALK_START = 17
WALK_END = 65
CYCLE_FRAMES = 24
STANCE_FRACTION = 0.67
SHOULDER_PITCH_DEGREES = 4.5
SHOULDER_ROLL_DEGREES = 0.6
CHEST_PITCH_DEGREES = 0.85
CHEST_ROLL_DEGREES = 0.55
PELVIS_ROLL_DEGREES = 0.35
SHOULDERS = (
    ("DEF_shoulder.L", 0.0, -1.0),
    ("DEF_shoulder.R", 0.5, 1.0),
)


def ease(value: float) -> float:
    """Return cubic ease with zero slope at both endpoints.

    Args:
        value (float): Unbounded fraction of an interval.

    Returns:
        float: Smooth value constrained to zero through one.
    """
    t = max(0.0, min(1.0, value))
    return t * t * (3.0 - 2.0 * t)


def gait_strength(frame: int) -> float:
    """Fade the shoulder/chest gait between intact idle sections.

    Args:
        frame (int): One-based animation frame.

    Returns:
        float: Strength of the gait between zero and one.
    """
    entering = ease((frame - 9) / (WALK_START - 9))
    leaving = 1.0 - ease((frame - WALK_END) / (END_FRAME - WALK_END))
    return entering * leaving


def shoulder_motion(phase: float) -> tuple[float, float]:
    """Model the backward stance and forward scapular swing in degrees.

    Args:
        phase (float): Fraction of one paw's four-beat stride.

    Returns:
        tuple[float, float]: Rest-relative pitch and lift modulation.
    """
    cycle = phase % 1.0
    if cycle < STANCE_FRACTION:
        progress = cycle / STANCE_FRACTION
        pitch = SHOULDER_PITCH_DEGREES * (1.0 - 2.0 * progress)
        lift = 0.0
    else:
        progress = (cycle - STANCE_FRACTION) / (1.0 - STANCE_FRACTION)
        pitch = SHOULDER_PITCH_DEGREES * (
            -1.0 + 2.0 * ease(progress)
        )
        lift = math.sin(math.pi * progress) ** 2
    return pitch, lift


def key_pose(bone, frame: int, angles: tuple[float, float, float]):
    """Insert independent editable Euler pose keys for an existing bone.

    Args:
        bone (bpy.types.PoseBone): Actual Frostfang rig bone.
        frame (int): One-based keyframe index.
        angles (tuple[float, float, float]): Local XYZ angles in degrees.

    Returns:
        None: The source rig's copy gets explicit pose keys.
    """
    bone.rotation_mode = "XYZ"
    bone.rotation_euler = tuple(math.radians(a) for a in angles)
    bone.keyframe_insert(data_path="rotation_euler", frame=frame)


def author_frame(rig, scene, frame: int):
    """Coordinate separate scapula, chest and pelvis phases.

    Args:
        rig (bpy.types.Object): Existing rig with four-leg IK constraints.
        scene (bpy.types.Scene): Its existing 72-frame walk timeline.
        frame (int): One-based keyframe index.

    Returns:
        None: Adds only shoulder and body pose channels.
    """
    scene.frame_set(frame)
    strength = gait_strength(frame)
    phase = (frame - WALK_START) / CYCLE_FRAMES
    for name, offset, side in SHOULDERS:
        pitch, lift = shoulder_motion(phase + offset)
        key_pose(
            rig.pose.bones[name], frame,
            (
                pitch * strength,
                0.0,
                SHOULDER_ROLL_DEGREES * side * lift * strength,
            ),
        )
    wave = math.sin(2.0 * math.pi * phase)
    counter_wave = math.sin(4.0 * math.pi * phase)
    key_pose(
        rig.pose.bones["DEF_spine.008"], frame,
        (
            CHEST_PITCH_DEGREES * counter_wave * strength,
            0.0,
            CHEST_ROLL_DEGREES * wave * strength,
        ),
    )
    key_pose(
        rig.pose.bones["DEF_spine.005"], frame,
        (0.0, 0.0, -PELVIS_ROLL_DEGREES * wave * strength),
    )


def author_walk(rig, scene):
    """Add independent shoulder and counter-body motion over WalkV8.

    Args:
        rig (bpy.types.Object): A new copy of the WalkV8 skinned rig.
        scene (bpy.types.Scene): Existing unchanged gait frame range.

    Returns:
        dict: Explicit settings and completion metadata for QA.
    """
    if (scene.frame_start, scene.frame_end) != (1, END_FRAME):
        raise RuntimeError("The existing WalkV8 timeline has changed")
    if scene.render.fps != FPS:
        raise RuntimeError("Expected the recorded 24 FPS WalkV8 source")
    required = [
        name for name, _, _ in SHOULDERS
    ] + ["DEF_spine.008", "DEF_spine.005"]
    for name in required:
        if rig.pose.bones.get(name) is None:
            raise RuntimeError("Missing measured rig bone: " + name)
    for frame in range(1, END_FRAME + 1):
        author_frame(rig, scene, frame)
    scene.frame_set(1)
    return {
        "fps": FPS,
        "frames": END_FRAME,
        "four_beat_foreleg_offsets": [0.0, 0.5],
        "stance_fraction": STANCE_FRACTION,
        "shoulder_pitch_degrees": SHOULDER_PITCH_DEGREES,
        "chest_pitch_degrees": CHEST_PITCH_DEGREES,
        "status": "UNAPPROVED: inspect actual skinned shoulders and paws",
    }


def main():
    """Save a separate gait, leaving all previous tests untouched.

    Args:
        None.

    Returns:
        None: Saves new editable Blender file and metadata.
    """
    if not SOURCE.is_file():
        raise FileNotFoundError(str(SOURCE))
    OUTPUT.mkdir(parents=True, exist_ok=True)
    destination = OUTPUT / OUTPUT_NAME
    if destination.exists():
        raise FileExistsError("WalkV9 already exists: " + str(destination))
    bpy.ops.wm.open_mainfile(filepath=str(SOURCE))
    scene = bpy.context.scene
    rig = bpy.data.objects["Frostfang_Canine_CompactRig"]
    report = author_walk(rig, scene)
    bpy.ops.wm.save_as_mainfile(filepath=str(destination))
    report["source"] = str(SOURCE)
    report["output"] = str(destination)
    report["limitations"] = [
        "Original shoulder bones have zero direct mesh weights.",
        "IK target and paw-world-orientation constraints are unchanged.",
        "No true mesh-grounded gait or Roblox playback is certified.",
        "Tail fur and hind-right foot require independent review.",
    ]
    (OUTPUT / "walk_v9_manifest.json").write_text(
        json.dumps(report, indent=2), encoding="utf-8"
    )
    print("WALK_V9_SAVED", destination, flush=True)


if __name__ == "__main__":
    main()
