"""Try a longer, lower-clearance four-beat canine walk on a V13 copy.

The phase and support timing follow canine walk research, not a bouncing
trot. All original meshes, earlier experiments and Studio places remain.
"""

import json
import math
from pathlib import Path

import bpy
from mathutils import Vector


ROOT = (
    Path.home() / "Documents" / "Roblox" /
    "DungeonMMO_CanineRig_QA" / "Frostfang_20260923" /
    "GroundedWalkTrial_20260923"
)
SOURCE = ROOT / "WalkV13_ScapularGlide" / (
    "Frostfang_WalkV13_UNAPPROVED.blend"
)
OUTPUT = ROOT / "WalkV15_SupportedStride"
DESTINATION = OUTPUT / "Frostfang_WalkV15_UNAPPROVED.blend"
FINAL_FRAME = 72
WALK_START = 17
WALK_STOP = 65
CYCLE_FRAMES = 24
OLD_STRIDE = 0.07
NEW_STRIDE = 0.100
STANCE = 0.67
PAW_CLEARANCE = 0.012
EXTRA_BODY_DROP = 0.040
PHASES = (
    ("FrontLeft", 0.0),
    ("HindRight", 0.25),
    ("FrontRight", 0.5),
    ("HindLeft", 0.75),
)


def smoothstep(value: float) -> float:
    """Bound and ease a transition to zero speed at its endpoints.

    Args:
        value (float): Normalized transition progress.

    Returns:
        float: Cubic eased fraction from zero through one.
    """
    x = max(0.0, min(1.0, value))
    return x * x * (3.0 - 2.0 * x)


def stride_progress(frame: int) -> float:
    """Return total stride cycles completed in the walking interval.

    Args:
        frame (int): Current one-based animation frame.

    Returns:
        float: Clamped continuous cycle progress from zero to two.
    """
    return max(
        0.0, min(2.0, (frame - WALK_START) / CYCLE_FRAMES)
    )


def paw_destination(rest: Vector, frame: int, offset: float):
    """Provide world-locked stance and low-clearance airborne swing.

    Args:
        rest (Vector): Measured idle ankle target position.
        frame (int): Active full-timeline animation frame.
        offset (float): Canine limb phase in the four-beat sequence.

    Returns:
        tuple[Vector, bool]: World paw goal and actual stance flag.
    """
    phase = stride_progress(frame) + offset
    cycle = math.floor(phase)
    within = phase - cycle
    goal = rest.copy()
    goal.y -= NEW_STRIDE * cycle
    if within < STANCE:
        return goal, True
    swing = (within - STANCE) / (1.0 - STANCE)
    goal.y -= NEW_STRIDE * smoothstep(swing)
    goal.z += PAW_CLEARANCE * math.sin(math.pi * swing) ** 2
    return goal, False


def set_idle(frame: int, rest: Vector, offset: float):
    """Ease initial and final paw goals to neutral support positions.

    Args:
        frame (int): One-based animation frame outside the walk.
        rest (Vector): Source frame-one ankle target.
        offset (float): Unique footfall phase offset.

    Returns:
        Vector: Target that smoothly approaches or leaves a walk.
    """
    if frame < WALK_START:
        incoming, _ = paw_destination(rest, WALK_START, offset)
        return rest.lerp(
            incoming, smoothstep((frame - 9) / 8.0)
        )
    final_goal, _ = paw_destination(
        rest, WALK_STOP - 1, offset
    )
    final_idle = rest.copy()
    final_idle.y -= 2.0 * NEW_STRIDE
    return final_goal.lerp(
        final_idle, smoothstep(
            (frame - WALK_STOP) / (FINAL_FRAME - WALK_STOP)
        )
    )


def walk_envelope(frame: int) -> float:
    """Return a smooth support transition from and back to neutral rest.

    Args:
        frame (int): One-based animation frame.

    Returns:
        float: Clamped walking influence from zero through one.
    """
    entering = smoothstep((frame - 9) / (WALK_START - 9))
    leaving = 1.0 - smoothstep(
        (frame - WALK_STOP) / (FINAL_FRAME - WALK_STOP)
    )
    return entering * leaving


def author_root_motion(rig, scene):
    """Match torso translation to the longer, world-planted stride.

    Args:
        rig (bpy.types.Object): Source V13 animated armature object.
        scene (bpy.types.Scene): Source 72-frame Blender gait.

    Returns:
        None: Replaces only copied armature translation animation.
    """
    for frame in range(1, FINAL_FRAME + 1):
        scene.frame_set(frame)
        distance = stride_progress(frame)
        rig.location.y -= (NEW_STRIDE - OLD_STRIDE) * distance
        rig.location.z -= EXTRA_BODY_DROP * walk_envelope(frame)
        rig.keyframe_insert(data_path="location", frame=frame)


def author_paws(scene):
    """Key four separate original IK controls with lower swing clearance.

    Args:
        scene (bpy.types.Scene): Source scene with four ankle empties.

    Returns:
        dict: Authored stance flags for independent mesh auditing.
    """
    scene.frame_set(1)
    records = {}
    for label, offset in PHASES:
        target = bpy.data.objects.get("DMMO_WalkV3_" + label)
        if target is None:
            raise RuntimeError("Original ankle target missing: " + label)
        rest = target.location.copy()
        records[label] = {}
        for frame in range(1, FINAL_FRAME + 1):
            scene.frame_set(frame)
            if WALK_START <= frame < WALK_STOP:
                goal, planted = paw_destination(rest, frame, offset)
            else:
                goal = set_idle(frame, rest, offset)
                planted = False
            target.location = goal
            target.keyframe_insert(
                data_path="location", frame=frame
            )
            records[label][str(frame)] = planted
    scene.frame_set(1)
    return records


def main():
    """Save a separate natural-stride candidate and exact gait metadata.

    Args:
        None.

    Returns:
        None: Writes experimental Blender and JSON files outside gameplay.
    """
    if not SOURCE.is_file():
        raise FileNotFoundError(str(SOURCE))
    OUTPUT.mkdir(parents=True, exist_ok=True)
    if DESTINATION.exists():
        raise FileExistsError("WalkV15 already exists: " + str(DESTINATION))
    bpy.ops.wm.open_mainfile(filepath=str(SOURCE))
    scene = bpy.context.scene
    if (scene.frame_start, scene.frame_end) != (1, FINAL_FRAME):
        raise RuntimeError("The V13 timeline no longer matches the trial")
    rig = bpy.data.objects["Frostfang_Canine_CompactRig"]
    author_root_motion(rig, scene)
    stance = author_paws(scene)
    bpy.ops.wm.save_as_mainfile(filepath=str(DESTINATION))
    report = {
        "source": str(SOURCE),
        "output": str(DESTINATION),
        "stride_source_units": NEW_STRIDE,
        "paw_clearance_source_units": PAW_CLEARANCE,
        "extra_body_drop_source_units": EXTRA_BODY_DROP,
        "stance_fraction": STANCE,
        "paw_stance": stance,
        "status": "UNAPPROVED: examine actual mesh and elbow reach",
        "warnings": [
            "Original constrained world paw orientation remains.",
            "Paw digits and pad roll are not physically modelled.",
            "IK authoring is not a Roblox Animator animation.",
        ],
    }
    (OUTPUT / "walk_v15_manifest.json").write_text(
        json.dumps(report, indent=2), encoding="utf-8"
    )
    print("WALK_V15_SAVED", DESTINATION, flush=True)


if __name__ == "__main__":
    main()
