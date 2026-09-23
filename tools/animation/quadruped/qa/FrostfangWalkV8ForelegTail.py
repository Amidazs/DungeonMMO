"""Smooth the remaining forepaw catch on a separate WalkV7 tail copy.

This changes only front IK targets; the isolated tail weights are kept.
The original source, V6, V7 and Roblox Studio places remain unchanged.
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
SOURCE = ROOT / "WalkV7_TailIsolation" / (
    "Frostfang_WalkV7_Tail_UNAPPROVED.blend"
)
OUTPUT = ROOT / "WalkV8_ForelegTail"
WALK_START = 17
WALK_END = 65
FINAL_FRAME = 72
CYCLE_FRAMES = 24
STANCE_FRACTION = 0.67
EXTRA_FOREPAW_ADVANCE = 0.007
LIFT_REDUCTION = 0.008
FRONT_TARGETS = (
    ("FrontLeft", 0.0),
    ("FrontRight", 0.5),
)


def swing_fraction(frame: int, offset: float) -> float | None:
    """Return swing progress for one leg during the walking interval.

    Args:
        frame (int): Current one-based frame.
        offset (float): Foreleg phase offset in full gait cycles.

    Returns:
        float | None: Swing fraction or None if the forepaw is planted.
    """
    if not WALK_START <= frame < WALK_END:
        return None
    phase = ((frame - WALK_START) / CYCLE_FRAMES + offset) % 1.0
    if phase < STANCE_FRACTION:
        return None
    return (phase - STANCE_FRACTION) / (1.0 - STANCE_FRACTION)


def retune_front_targets(scene):
    """Add a shorter, lower forepaw swing without touching rear legs.

    Args:
        scene (bpy.types.Scene): Isolated WalkV7 tail-motion scene.

    Returns:
        dict: Measured modifications for each original front IK target.
    """
    records = {}
    for label, offset in FRONT_TARGETS:
        target = bpy.data.objects.get("DMMO_WalkV3_" + label)
        if target is None:
            raise RuntimeError("Missing front IK target: " + label)
        for frame in range(1, FINAL_FRAME + 1):
            scene.frame_set(frame)
            location = target.location.copy()
            location.y += EXTRA_FOREPAW_ADVANCE
            swing = swing_fraction(frame, offset)
            if swing is not None:
                wave = math.sin(math.pi * swing)
                location.z -= LIFT_REDUCTION * wave * wave
            target.location = location
            target.keyframe_insert(
                data_path="location", frame=frame
            )
        records[label] = {
            "additional_y_advance": EXTRA_FOREPAW_ADVANCE,
            "swing_lift_reduction": LIFT_REDUCTION,
        }
    scene.frame_set(1)
    return records


def main():
    """Save a distinct, editable foreleg/tail refinement and manifest.

    Args:
        None.

    Returns:
        None: Writes new Blender experiment without overwriting old ones.
    """
    if not SOURCE.is_file():
        raise FileNotFoundError(str(SOURCE))
    OUTPUT.mkdir(parents=True, exist_ok=True)
    destination = OUTPUT / "Frostfang_WalkV8_UNAPPROVED.blend"
    if destination.exists():
        raise FileExistsError(str(destination))
    bpy.ops.wm.open_mainfile(filepath=str(SOURCE))
    scene = bpy.context.scene
    if (scene.frame_start, scene.frame_end) != (1, FINAL_FRAME):
        raise RuntimeError("Unexpected source walk timeline")
    adjustments = retune_front_targets(scene)
    bpy.ops.wm.save_as_mainfile(filepath=str(destination))
    report = {
        "source": str(SOURCE),
        "output": str(destination),
        "adjustments": adjustments,
        "status": "UNAPPROVED: audit toe drift and elbows before promotion",
        "notes": [
            "Rear-leg target animation and tail isolation are unchanged.",
            "Forepaw idle pose is offset from original JawV3 rest.",
            "No real Studio playback or game publishing occurred.",
        ],
    }
    (OUTPUT / "walk_v8_manifest.json").write_text(
        json.dumps(report, indent=2), encoding="utf-8"
    )
    print("WALK_V8_SAVED", destination, flush=True)


if __name__ == "__main__":
    main()
