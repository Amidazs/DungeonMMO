"""Create an isolated foreleg landing experiment from Frostfang WalkV6.

Targets are shortened to avoid almost-straight IK at forepaw landing.
The existing master, WalkV6, hind targets and Studio places are untouched.
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
SOURCE = (
    ROOT / "WalkV6_Forequarter" / "Frostfang_WalkV6_UNAPPROVED.blend"
)
OUTPUT = ROOT / "WalkV7_Foreleg"
FINAL_FRAME = 72
WALK_START = 17
WALK_END = 65
CYCLE_FRAMES = 24
STANCE_FRACTION = 0.67
ORIGINAL_LIFT = 0.035
NEW_LIFT = 0.028
FOREPAW_ADVANCE = 0.015
FRONT_TARGETS = (
    ("FrontLeft", 0.0),
    ("FrontRight", 0.5),
)


def forepaw_swing(frame: int, phase_offset: float) -> float | None:
    """Return fractional swing progress when a forepaw is airborne.

    Args:
        frame (int): One-based animation frame.
        phase_offset (float): Left/right offset in full gait cycles.

    Returns:
        float | None: Swing phase, or None outside the swing.
    """
    if not WALK_START <= frame < WALK_END:
        return None
    phase = (
        (frame - WALK_START) / CYCLE_FRAMES + phase_offset
    ) % 1.0
    if phase < STANCE_FRACTION:
        return None
    return (
        phase - STANCE_FRACTION
    ) / (1.0 - STANCE_FRACTION)


def adjust_front_targets(scene):
    """Key modestly shorter-reaching forepaw goals with eased vertical lift.

    Args:
        scene (bpy.types.Scene): Existing WalkV6 test animation.

    Returns:
        dict: The exact control changes applied to each leg.
    """
    result = {}
    for label, phase_offset in FRONT_TARGETS:
        name = "DMMO_WalkV3_" + label
        target = bpy.data.objects.get(name)
        if target is None:
            raise RuntimeError("Missing original IK target: " + name)
        for frame in range(1, FINAL_FRAME + 1):
            scene.frame_set(frame)
            location = target.location.copy()
            location.y += FOREPAW_ADVANCE
            swing = forepaw_swing(frame, phase_offset)
            if swing is not None:
                wave = math.sin(math.pi * swing)
                location.z += NEW_LIFT * wave * wave
                location.z -= ORIGINAL_LIFT * wave
            target.location = location
            target.keyframe_insert(
                data_path="location", frame=frame
            )
        result[label] = {
            "world_y_advance": FOREPAW_ADVANCE,
            "swing_lift": NEW_LIFT,
            "swing_vertical_curve": "sin(pi * swing) squared",
        }
    scene.frame_set(1)
    return result


def main():
    """Save and label the new experimental test without source overwrites.

    Args:
        None.

    Returns:
        None: Writes a distinct editable Blend and audit manifest.
    """
    if not SOURCE.is_file():
        raise FileNotFoundError(str(SOURCE))
    OUTPUT.mkdir(parents=True, exist_ok=True)
    destination = OUTPUT / "Frostfang_WalkV7_Foreleg_UNAPPROVED.blend"
    if destination.exists():
        raise FileExistsError("WalkV7 already exists: " + str(destination))
    bpy.ops.wm.open_mainfile(filepath=str(SOURCE))
    scene = bpy.context.scene
    if scene.frame_start != 1 or scene.frame_end != FINAL_FRAME:
        raise RuntimeError("Unexpected original WalkV6 timeline")
    changes = adjust_front_targets(scene)
    bpy.ops.wm.save_as_mainfile(filepath=str(destination))
    report = {
        "source": str(SOURCE),
        "output": str(destination),
        "changes": changes,
        "status": "UNAPPROVED: elbow and real-toe QA still required",
        "warnings": [
            "The forepaw standing position has been moved slightly.",
            "Only front targets changed; rear IK and skin are unchanged.",
            "A smooth target trajectory does not guarantee smooth IK.",
            "This is Blender authoring, not Roblox Studio playback.",
        ],
    }
    (OUTPUT / "walk_v7_manifest.json").write_text(
        json.dumps(report, indent=2), encoding="utf-8"
    )
    print("WALK_V7_FORELEG_SAVED", destination, flush=True)


if __name__ == "__main__":
    main()
