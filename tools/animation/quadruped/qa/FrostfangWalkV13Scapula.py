"""Use the lowered canine torso to permit more visible shoulder glide.

An isolated V12 copy gets larger scapular movement only where both
front elbows retain a measured, safe bend. Existing paw targets stay put.
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
SOURCE = ROOT / "WalkV12_WeightShift" / (
    "Frostfang_WalkV12_UNAPPROVED.blend"
)
OUTPUT = ROOT / "WalkV13_ScapularGlide"
DESTINATION = OUTPUT / "Frostfang_WalkV13_UNAPPROVED.blend"
END_FRAME = 72
WALK_START = 17
WALK_END = 65
STANCE_FRACTION = 0.67
CYCLE_FRAMES = 24
SHOULDER_SWING = 5.5
MAX_ELBOW = 170.0
MAX_EXTRA_STRAIGHTENING = 2.0
SCALES = tuple(i / 20.0 for i in range(20, -1, -1))
LEGS = (("L", 0.0), ("R", 0.5))


def smoothstep(value: float) -> float:
    """Ease stride phase without instantaneous shoulder velocity jumps.

    Args:
        value (float): Unbounded normalized interval progress.

    Returns:
        float: Cubic, bounded interpolation.
    """
    t = max(0.0, min(1.0, value))
    return t * t * (3.0 - 2.0 * t)


def gait_weight(frame: int) -> float:
    """Fade shoulders to neutral before and after the walking interval.

    Args:
        frame (int): One-based test animation frame.

    Returns:
        float: Gait influence from zero through one.
    """
    first = smoothstep((frame - 9) / (WALK_START - 9))
    last = 1.0 - smoothstep(
        (frame - WALK_END) / (END_FRAME - WALK_END)
    )
    return first * last


def scapular_target(phase: float) -> float:
    """Sweep each shoulder backward in support and forward in flight.

    Args:
        phase (float): Leg phase in four-beat stride cycles.

    Returns:
        float: Smooth rest-relative scapular pitch, in degrees.
    """
    p = phase % 1.0
    if p < STANCE_FRACTION:
        t = smoothstep(p / STANCE_FRACTION)
        return SHOULDER_SWING * (1.0 - 2.0 * t)
    t = smoothstep(
        (p - STANCE_FRACTION) / (1.0 - STANCE_FRACTION)
    )
    return SHOULDER_SWING * (-1.0 + 2.0 * t)


def elbow_angle(rig, side: str) -> float:
    """Measure constrained elbow bend from actual Blender joint centers.

    Args:
        rig (bpy.types.Object): Weighted source armature.
        side (str): L or R leg suffix.

    Returns:
        float: Interior front elbow angle in degrees.
    """
    upper = rig.pose.bones["DEF_front_thigh." + side]
    lower = rig.pose.bones["DEF_front_shin." + side]
    foot = rig.pose.bones["DEF_front_foot." + side]
    shoulder = rig.matrix_world @ upper.head
    elbow = rig.matrix_world @ lower.head
    ankle = rig.matrix_world @ foot.head
    return math.degrees(
        (shoulder - elbow).angle(ankle - elbow)
    )


def test_shoulder(rig, side: str, angle: float) -> float:
    """Try shoulder articulation and measure the resulting IK leg reach.

    Args:
        rig (bpy.types.Object): Existing animated source rig.
        side (str): Left/right Blender bone suffix.
        angle (float): Local X shoulder pose angle in degrees.

    Returns:
        float: Actual elbow bend with the source paw target unchanged.
    """
    bone = rig.pose.bones["DEF_shoulder." + side]
    bone.rotation_mode = "XYZ"
    bone.rotation_euler = (math.radians(angle), 0.0, 0.0)
    bpy.context.view_layer.update()
    return elbow_angle(rig, side)


def author_frame(rig, scene, frame: int):
    """Key reach-limited scapular rotation for both front limbs.

    Args:
        rig (bpy.types.Object): Original-look isolated canine rig.
        scene (bpy.types.Scene): Saved gait and IK source.
        frame (int): One-based editable keyframe.

    Returns:
        dict: Actual shoulder pitches and measured elbow angles.
    """
    scene.frame_set(frame)
    results = {}
    for side, offset in LEGS:
        baseline = test_shoulder(rig, side, 0.0)
        limit = min(
            MAX_ELBOW, baseline + MAX_EXTRA_STRAIGHTENING
        )
        target = scapular_target(
            (frame - WALK_START) / CYCLE_FRAMES + offset
        ) * gait_weight(frame)
        selected = 0.0
        final_elbow = baseline
        for scale in SCALES:
            angle = target * scale
            measured = test_shoulder(rig, side, angle)
            if measured <= limit:
                selected = angle
                final_elbow = measured
                break
        bone = rig.pose.bones["DEF_shoulder." + side]
        bone.keyframe_insert(
            data_path="rotation_euler", frame=frame
        )
        results[side] = {
            "shoulder_pitch": round(selected, 6),
            "elbow": round(final_elbow, 6),
        }
    return results


def main():
    """Save an independently testable, more visible canine shoulder gait.

    Args:
        None.

    Returns:
        None: Writes a new Blend and measured per-frame shoulder report.
    """
    if not SOURCE.is_file():
        raise FileNotFoundError(str(SOURCE))
    OUTPUT.mkdir(parents=True, exist_ok=True)
    if DESTINATION.exists():
        raise FileExistsError(str(DESTINATION))
    bpy.ops.wm.open_mainfile(filepath=str(SOURCE))
    rig = bpy.data.objects["Frostfang_Canine_CompactRig"]
    scene = bpy.context.scene
    if (scene.frame_start, scene.frame_end) != (1, END_FRAME):
        raise RuntimeError("Unexpected source gait frame range")
    frames = {
        frame: author_frame(rig, scene, frame)
        for frame in range(1, END_FRAME + 1)
    }
    scene.frame_set(1)
    bpy.ops.wm.save_as_mainfile(filepath=str(DESTINATION))
    report = {
        "source": str(SOURCE),
        "output": str(DESTINATION),
        "max_requested_shoulder_degrees": SHOULDER_SWING,
        "elbow_limit_degrees": MAX_ELBOW,
        "frames": frames,
        "status": "UNAPPROVED: real-paw and visible-fur QA required",
    }
    (OUTPUT / "walk_v13_manifest.json").write_text(
        json.dumps(report, indent=2), encoding="utf-8"
    )
    print("WALK_V13_SAVED", DESTINATION, flush=True)


if __name__ == "__main__":
    main()
