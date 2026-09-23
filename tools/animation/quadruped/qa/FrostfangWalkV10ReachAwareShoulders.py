"""Author separate canine shoulder motion with measured foreleg reach limits.

This diagnostic uses the existing V8 skin, four-beat paw targets and
weight-isolated tail. It must pass actual-mesh and visual QA before use.
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
OUTPUT = ROOT / "WalkV10_ReachAwareShoulders"
OUTPUT_NAME = "Frostfang_WalkV10_UNAPPROVED.blend"
END_FRAME = 72
WALK_START = 17
WALK_END = 65
CYCLE_FRAMES = 24
STANCE_FRACTION = 0.67
SHOULDER_MAX_DEGREES = 3.4
ELBOW_MAX_DEGREES = 172.0
ELBOW_BASELINE_MARGIN = 0.7
SCALING = (1.0, 0.8, 0.6, 0.4, 0.2, 0.0)
LEGS = (
    ("L", 0.0),
    ("R", 0.5),
)


def smoothstep(value: float) -> float:
    """Bound an interval and ease its endpoints to zero velocity.

    Args:
        value (float): Unbounded phase interval progress.

    Returns:
        float: Eased value in the closed unit interval.
    """
    t = max(0.0, min(1.0, value))
    return t * t * (3.0 - 2.0 * t)


def envelope(frame: int) -> float:
    """Fade shoulder gait into and out of its independent idle poses.

    Args:
        frame (int): One-based test animation frame.

    Returns:
        float: Gait influence between zero and one.
    """
    start = smoothstep((frame - 9) / (WALK_START - 9))
    stop = 1.0 - smoothstep(
        (frame - WALK_END) / (END_FRAME - WALK_END)
    )
    return start * stop


def shoulder_pitch(phase: float) -> float:
    """Shift a shoulder backward in stance and forward in swing.

    Args:
        phase (float): Absolute leg phase in four-beat gait cycles.

    Returns:
        float: Rest-relative pitch in degrees, with smooth endpoints.
    """
    p = phase % 1.0
    if p < STANCE_FRACTION:
        progress = smoothstep(p / STANCE_FRACTION)
        return SHOULDER_MAX_DEGREES * (1.0 - 2.0 * progress)
    progress = smoothstep(
        (p - STANCE_FRACTION) / (1.0 - STANCE_FRACTION)
    )
    return SHOULDER_MAX_DEGREES * (-1.0 + 2.0 * progress)


def elbow_angle(rig, side: str) -> float:
    """Measure actual constrained foreleg joint angle for this pose.

    Args:
        rig (bpy.types.Object): Evaluated weighted source armature.
        side (str): Actual Blender suffix, L or R.

    Returns:
        float: Interior elbow angle in degrees.
    """
    shoulder = rig.pose.bones["DEF_front_thigh." + side]
    elbow = rig.pose.bones["DEF_front_shin." + side]
    paw = rig.pose.bones["DEF_front_foot." + side]
    first = (rig.matrix_world @ shoulder.head)
    middle = (rig.matrix_world @ elbow.head)
    last = (rig.matrix_world @ paw.head)
    a = first - middle
    b = last - middle
    if min(a.length, b.length) < 1e-6:
        raise RuntimeError("Zero-length evaluated foreleg")
    return math.degrees(a.angle(b))


def update_shoulder(rig, side: str, angle: float):
    """Evaluate an explicit local shoulder rotation against its IK leg.

    Args:
        rig (bpy.types.Object): Existing four-legged source armature.
        side (str): Left/right anatomical Blender bone suffix.
        angle (float): Rest-relative local X pitch in degrees.

    Returns:
        float: Resulting evaluated elbow angle in degrees.
    """
    bone = rig.pose.bones["DEF_shoulder." + side]
    bone.rotation_mode = "XYZ"
    bone.rotation_euler = (math.radians(angle), 0.0, 0.0)
    bpy.context.view_layer.update()
    return elbow_angle(rig, side)


def author_shoulders(rig, scene, frame: int):
    """Apply as much smooth shoulder glide as foreleg reach permits.

    Args:
        rig (bpy.types.Object): Current isolated animation armature.
        scene (bpy.types.Scene): Active 72-frame Blender test timeline.
        frame (int): Current animation frame.

    Returns:
        dict: Actual shoulder angles and measured elbow angles.
    """
    scene.frame_set(frame)
    strength = envelope(frame)
    result = {}
    for side, offset in LEGS:
        baseline = update_shoulder(rig, side, 0.0)
        limit = min(
            ELBOW_MAX_DEGREES, baseline + ELBOW_BASELINE_MARGIN
        )
        target = shoulder_pitch(
            (frame - WALK_START) / CYCLE_FRAMES + offset
        ) * strength
        chosen = 0.0
        final_angle = baseline
        for scale in SCALING:
            proposed = target * scale
            measured = update_shoulder(rig, side, proposed)
            if measured <= limit:
                chosen = proposed
                final_angle = measured
                break
        bone = rig.pose.bones["DEF_shoulder." + side]
        bone.keyframe_insert(
            data_path="rotation_euler", frame=frame
        )
        result[side] = {
            "pitch": round(chosen, 5),
            "elbow": round(final_angle, 5),
            "baseline_elbow": round(baseline, 5),
        }
    return result


def add_body_motion(rig, frame: int):
    """Add subdued torso weight shift without moving the root off ground.

    Args:
        rig (bpy.types.Object): Source weighted wolf rig.
        frame (int): One-based animation frame.

    Returns:
        None: Keys small chest roll while preserving original paw targets.
    """
    phase = 2.0 * math.pi * (frame - WALK_START) / CYCLE_FRAMES
    bone = rig.pose.bones["DEF_spine.008"]
    bone.rotation_mode = "XYZ"
    bone.rotation_euler = (
        math.radians(0.32 * math.sin(2 * phase) * envelope(frame)),
        0.0,
        math.radians(0.18 * math.sin(phase) * envelope(frame)),
    )
    bone.keyframe_insert(data_path="rotation_euler", frame=frame)


def build_walk(rig, scene):
    """Key four-beat shoulder support and record evaluated reach each frame.

    Args:
        rig (bpy.types.Object): Separate saved-copy canine skeleton.
        scene (bpy.types.Scene): Existing unchanged WalkV8 timeline.

    Returns:
        dict: Per-frame shoulder rotations and elbow comparisons.
    """
    if (scene.frame_start, scene.frame_end) != (1, END_FRAME):
        raise RuntimeError("WalkV8 timeline differs from expected QA rig")
    report = {}
    for frame in range(1, END_FRAME + 1):
        scene.frame_set(frame)
        add_body_motion(rig, frame)
        report[frame] = author_shoulders(rig, scene, frame)
    scene.frame_set(1)
    return report


def main():
    """Produce a new reversible reach-limited quadruped walking trial.

    Args:
        None.

    Returns:
        None: Saves an editable Blend plus recorded per-frame elbow QA.
    """
    if not SOURCE.is_file():
        raise FileNotFoundError(str(SOURCE))
    OUTPUT.mkdir(parents=True, exist_ok=True)
    destination = OUTPUT / OUTPUT_NAME
    if destination.exists():
        raise FileExistsError("WalkV10 already saved: " + str(destination))
    bpy.ops.wm.open_mainfile(filepath=str(SOURCE))
    rig = bpy.data.objects["Frostfang_Canine_CompactRig"]
    scene = bpy.context.scene
    records = build_walk(rig, scene)
    bpy.ops.wm.save_as_mainfile(filepath=str(destination))
    report = {
        "source": str(SOURCE),
        "output": str(destination),
        "shoulder_limit_degrees": SHOULDER_MAX_DEGREES,
        "elbow_max_degrees": ELBOW_MAX_DEGREES,
        "frames": records,
        "status": "UNAPPROVED: evaluated-toe and multiview visual QA pending",
        "warnings": [
            "Zero direct shoulder weights limit upper-fur movement.",
            "Original hind-right stance remains an open problem.",
            "IK authoring controls are not baked Roblox Animator keys.",
        ],
    }
    (OUTPUT / "walk_v10_manifest.json").write_text(
        json.dumps(report, indent=2), encoding="utf-8"
    )
    print("WALK_V10_SAVED", destination, flush=True)


if __name__ == "__main__":
    main()
