"""Try a supported canine weight shift on the separately skinned WalkV11.

A small torso drop adds bend to the nearly straight front legs while
unchanged world-space paw IK targets keep their existing stance anchors.
This is not an accepted gait or an in-game animation.
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
SOURCE = ROOT / "WalkV11_ShoulderSkin" / (
    "Frostfang_WalkV11_UNAPPROVED.blend"
)
OUTPUT = ROOT / "WalkV12_WeightShift"
DESTINATION = OUTPUT / "Frostfang_WalkV12_UNAPPROVED.blend"
END_FRAME = 72
WALK_START = 17
WALK_END = 65
CYCLE_FRAMES = 24
BODY_DROP = 0.014
BOB_HEIGHT = 0.002
CHEST_PITCH = 0.65


def smoothstep(value: float) -> float:
    """Ease motion in and out without sharp starting velocities.

    Args:
        value (float): Current normalized transition progress.

    Returns:
        float: Cubic eased progress in the unit interval.
    """
    t = max(0.0, min(1.0, value))
    return t * t * (3.0 - 2.0 * t)


def walk_strength(frame: int) -> float:
    """Preserve both saved neutral poses around the walking window.

    Args:
        frame (int): Animation frame from one to 72.

    Returns:
        float: Walking weight between zero and one.
    """
    entry = smoothstep((frame - 9) / (WALK_START - 9))
    exit_weight = 1.0 - smoothstep(
        (frame - WALK_END) / (END_FRAME - WALK_END)
    )
    return entry * exit_weight


def add_weight_transfer(rig, scene):
    """Lower the body into its feet and key subdued walk-cycle loading.

    Args:
        rig (bpy.types.Object): Existing weighted IK-controlled wolf.
        scene (bpy.types.Scene): Existing 24 FPS walk timeline.

    Returns:
        dict: Per-frame root height changes for reproducible QA.
    """
    records = {}
    chest = rig.pose.bones["DEF_spine.008"]
    chest.rotation_mode = "XYZ"
    for frame in range(1, END_FRAME + 1):
        scene.frame_set(frame)
        phase = (
            2.0 * math.pi * (frame - WALK_START) / CYCLE_FRAMES
        )
        strength = walk_strength(frame)
        baseline = rig.location.copy()
        drop = strength * (
            -BODY_DROP +
            BOB_HEIGHT * (1.0 - math.cos(2.0 * phase)) / 2.0
        )
        rig.location = (baseline.x, baseline.y, baseline.z + drop)
        rig.keyframe_insert(data_path="location", frame=frame)
        chest.rotation_euler.x = math.radians(
            CHEST_PITCH * math.sin(2.0 * phase) * strength
        )
        chest.keyframe_insert(
            data_path="rotation_euler", frame=frame
        )
        records[frame] = round(drop, 6)
    scene.frame_set(1)
    return records


def main():
    """Save a distinct weight-shift experiment and source-safe manifest.

    Args:
        None.

    Returns:
        None: Writes one new editable rig without publishing anything.
    """
    if not SOURCE.is_file():
        raise FileNotFoundError(str(SOURCE))
    OUTPUT.mkdir(parents=True, exist_ok=True)
    if DESTINATION.exists():
        raise FileExistsError("WalkV12 already exists")
    bpy.ops.wm.open_mainfile(filepath=str(SOURCE))
    scene = bpy.context.scene
    if (scene.frame_start, scene.frame_end) != (1, END_FRAME):
        raise RuntimeError("Unexpected source animation timeline")
    rig = bpy.data.objects["Frostfang_Canine_CompactRig"]
    records = add_weight_transfer(rig, scene)
    bpy.ops.wm.save_as_mainfile(filepath=str(DESTINATION))
    report = {
        "source": str(SOURCE),
        "output": str(DESTINATION),
        "body_drop_source_units": BODY_DROP,
        "bob_source_units": BOB_HEIGHT,
        "chest_pitch_degrees": CHEST_PITCH,
        "frame_root_offsets": records,
        "status": "UNAPPROVED: actual weighted toe and multiview QA pending",
        "warnings": [
            "Existing four-beat paw IK goals and hindleg skin are unchanged.",
            "Hind-right stance and source anatomy remain unverified.",
            "This candidate is not a baked Roblox Animator clip.",
        ],
    }
    (OUTPUT / "walk_v12_manifest.json").write_text(
        json.dumps(report, indent=2), encoding="utf-8"
    )
    print("WALK_V12_SAVED", DESTINATION, flush=True)


if __name__ == "__main__":
    main()
