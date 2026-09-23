"""Try a low-clearance canine walk with independent swing-phase paw flex.

This changes only separate paw IK targets and world-orientation reference
empties on a copied V13 animation. The original source stays untouched.
"""

import json
import math
from pathlib import Path

import bpy
from mathutils import Quaternion, Vector


ROOT = (
    Path.home() / "Documents" / "Roblox" /
    "DungeonMMO_CanineRig_QA" / "Frostfang_20260923" /
    "GroundedWalkTrial_20260923"
)
SOURCE = ROOT / "WalkV13_ScapularGlide" / (
    "Frostfang_WalkV13_UNAPPROVED.blend"
)
OUTPUT = ROOT / "WalkV16_PawPadGait"
DESTINATION = OUTPUT / "Frostfang_WalkV16_UNAPPROVED.blend"
START = 17
STOP = 65
FRAMES = 72
CYCLE = 24
STANCE = 0.67
FRONT_OLD_LIFT = 0.020
HIND_OLD_LIFT = 0.035
FRONT_NEW_LIFT = 0.012
HIND_NEW_LIFT = 0.014
SWING_PAW_FLEX_DEGREES = 7.0
PAWS = (
    ("FrontLeft", 0.0, True),
    ("HindRight", 0.25, False),
    ("FrontRight", 0.5, True),
    ("HindLeft", 0.75, False),
)


def swing_progress(frame: int, offset: float) -> float | None:
    """Return a limb's airborne phase in the established four-beat walk.

    Args:
        frame (int): One-based animation frame.
        offset (float): Normalized leg footfall phase.

    Returns:
        float | None: Swing progress or None during the support phase.
    """
    if not START <= frame < STOP:
        return None
    cycle_phase = ((frame - START) / CYCLE + offset) % 1.0
    if cycle_phase < STANCE:
        return None
    return (cycle_phase - STANCE) / (1.0 - STANCE)


def key_paw_controls(scene, label: str, offset: float, front: bool):
    """Author low swing clearance and neutral-rest world-paw curling.

    Args:
        scene (bpy.types.Scene): Separate weighted source test scene.
        label (str): Actual anatomical limb identifier.
        offset (float): Source walk phase offset.
        front (bool): Whether this is a foreleg rather than a rear leg.

    Returns:
        dict: Actual applied maximum lift and swing-foot flex settings.
    """
    target = bpy.data.objects.get("DMMO_WalkV3_" + label)
    reference = bpy.data.objects.get("DMMO_WalkV5_PawWorld_" + label)
    if target is None or reference is None:
        raise RuntimeError("Missing original paw controls: " + label)
    scene.frame_set(1)
    rest_rotation = reference.rotation_quaternion.copy()
    old_lift = FRONT_OLD_LIFT if front else HIND_OLD_LIFT
    new_lift = FRONT_NEW_LIFT if front else HIND_NEW_LIFT
    world_x = Vector((1.0, 0.0, 0.0))
    for frame in range(1, FRAMES + 1):
        scene.frame_set(frame)
        swing = swing_progress(frame, offset)
        position = target.location.copy()
        rotation = rest_rotation.copy()
        if swing is not None:
            wave = math.sin(math.pi * swing)
            old_height = (
                old_lift * wave * wave if front else old_lift * wave
            )
            position.z += new_lift * wave * wave - old_height
            curl = math.radians(
                SWING_PAW_FLEX_DEGREES * wave * wave
            )
            rotation = Quaternion(world_x, curl) @ rest_rotation
        target.location = position
        target.keyframe_insert(
            data_path="location", frame=frame
        )
        reference.rotation_quaternion = rotation
        reference.keyframe_insert(
            data_path="rotation_quaternion", frame=frame
        )
    scene.frame_set(1)
    return {
        "label": label,
        "front": front,
        "old_maximum_clearance": old_lift,
        "new_maximum_clearance": new_lift,
        "maximum_swing_foot_flex_degrees": SWING_PAW_FLEX_DEGREES,
    }


def main():
    """Save a distinct low-lift, paw-flexion test and its QA manifest.

    Args:
        None.

    Returns:
        None: Produces a new Blender trial without modifying the original.
    """
    if not SOURCE.is_file():
        raise FileNotFoundError(str(SOURCE))
    OUTPUT.mkdir(parents=True, exist_ok=True)
    if DESTINATION.exists():
        raise FileExistsError(str(DESTINATION))
    bpy.ops.wm.open_mainfile(filepath=str(SOURCE))
    scene = bpy.context.scene
    if (scene.frame_start, scene.frame_end) != (1, FRAMES):
        raise RuntimeError("Unexpected recorded canine gait duration")
    results = [
        key_paw_controls(scene, label, offset, front)
        for label, offset, front in PAWS
    ]
    bpy.ops.wm.save_as_mainfile(filepath=str(DESTINATION))
    record = {
        "source": str(SOURCE),
        "output": str(DESTINATION),
        "paw_controls": results,
        "status": "UNAPPROVED: real mesh toe contact and visual QA pending",
        "limits": [
            "Footpad mesh topology and toe weights are not repaired.",
            "Scapula and body movement are preserved from WalkV13.",
            "IK authoring controls are not baked Roblox animation.",
        ],
    }
    (OUTPUT / "walk_v16_manifest.json").write_text(
        json.dumps(record, indent=2), encoding="utf-8"
    )
    print("WALK_V16_SAVED", DESTINATION, flush=True)


if __name__ == "__main__":
    main()
