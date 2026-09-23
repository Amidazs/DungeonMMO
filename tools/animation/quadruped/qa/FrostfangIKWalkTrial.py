"""Author a reversible paw-target IK trial on the existing Frostfang rig.

This is a Blender-only gait study, not an approved Roblox animation.
The source Blend, jaw topology and existing Studio files are unchanged.
"""

import json
import math
from pathlib import Path

import bpy
from mathutils import Vector


ROOT = (
    Path.home() / "Documents" / "Roblox" /
    "DungeonMMO_CanineRig_QA" / "Frostfang_20260923"
)
SOURCE = ROOT / "Frostfang_Canine_ExperimentalMaster_JawV3.blend"
OUTPUT = ROOT / "GroundedWalkTrial_20260923"
FPS = 24
FRAMES = 72
CYCLE_FRAMES = 24
STRIDE = 0.09
STEP_HEIGHT = 0.045
BODY_TRAVEL = 0.06
LEGS = (
    ("FrontLeft", "DEF_front_shin.L", "DEF_front_foot.L", 0.00),
    ("HindRight", "DEF_shin.R", "DEF_foot.R", 0.25),
    ("FrontRight", "DEF_front_shin.R", "DEF_front_foot.R", 0.50),
    ("HindLeft", "DEF_shin.L", "DEF_foot.L", 0.75),
)


def smoothstep(value):
    """Return a cubic ease between zero and one.

    Args:
        value (float): An arbitrary progress value.

    Returns:
        float: Smooth progress clamped to the unit interval.
    """
    fraction = max(0.0, min(1.0, value))
    return fraction * fraction * (3.0 - 2.0 * fraction)


def create_target(rig, label, lower_name, foot_name):
    """Create a world-space target at a measured rest ankle location.

    Args:
        rig (bpy.types.Object): The experimental Frostfang armature.
        label (str): Unique leg identifier.
        lower_name (str): The measured lower-leg bone name.
        foot_name (str): The measured paw bone name.

    Returns:
        tuple: Target empty and its immutable initial world position.
    """
    lower = rig.pose.bones[lower_name]
    foot = rig.pose.bones[foot_name]
    rest_position = rig.matrix_world @ foot.head
    target = bpy.data.objects.new("DMMO_IK_" + label, None)
    bpy.context.scene.collection.objects.link(target)
    target.location = rest_position
    target.empty_display_type = "SPHERE"
    target.empty_display_size = 0.025
    constraint = lower.constraints.new("IK")
    constraint.name = "DMMO_Experimental_PawTarget"
    constraint.target = target
    constraint.chain_count = 2
    constraint.use_stretch = False
    constraint.iterations = 100
    return target, rest_position.copy()


def envelope(frame):
    """Ease an isolated two-cycle walk in and out of a neutral stance.

    Args:
        frame (int): Current Blender frame.

    Returns:
        float: Locomotion strength at the requested frame.
    """
    if frame <= 8:
        return 0.0
    if frame < 16:
        return smoothstep((frame - 8) / 8.0)
    if frame <= 56:
        return 1.0
    if frame < 65:
        return 1.0 - smoothstep((frame - 56) / 9.0)
    return 0.0


def foot_offset(frame, offset):
    """Return horizontal stance travel and vertical swing displacement.

    Args:
        frame (int): Current Blender frame.
        offset (float): Leg-specific fraction of a gait period.

    Returns:
        tuple: Local lengthwise and vertical displacement in Blender units.
    """
    phase = ((frame - 16) / CYCLE_FRAMES + offset) % 1.0
    if phase < 0.72:
        progress = phase / 0.72
        return (-STRIDE * progress, 0.0)
    progress = (phase - 0.72) / 0.28
    return (
        -STRIDE + STRIDE * smoothstep(progress),
        STEP_HEIGHT * math.sin(math.pi * progress),
    )


def prepare_scene():
    """Open the untouched source and attach four two-bone IK targets.

    Args:
        None.

    Returns:
        tuple: Source rig, mesh, scene and measured target records.
    """
    bpy.ops.wm.open_mainfile(filepath=str(SOURCE))
    rig = bpy.data.objects["Frostfang_Canine_CompactRig"]
    mesh = bpy.data.objects["Frostfang_Canine_ExperimentalMesh"]
    scene = bpy.context.scene
    rig.animation_data_clear()
    for bone in rig.pose.bones:
        bone.rotation_mode = "QUATERNION"
        bone.rotation_quaternion = (1.0, 0.0, 0.0, 0.0)
        bone.location = (0.0, 0.0, 0.0)
        bone.scale = (1.0, 1.0, 1.0)
        bone.constraints.clear()
    records = [
        (name, phase, *create_target(rig, name, shin, foot))
        for name, shin, foot, phase in LEGS
    ]
    scene.render.fps = FPS
    scene.frame_start = 1
    scene.frame_end = FRAMES
    return rig, mesh, scene, records


def author_walk(rig, scene, records):
    """Key target trajectories while keeping stance targets world fixed.

    Args:
        rig (bpy.types.Object): The isolated experimental armature.
        scene (bpy.types.Scene): Current Blender scene.
        records (list): Per-leg target, phase and rest position tuples.

    Returns:
        None: Writes editable target and armature keyframes.
    """
    base_location = rig.location.copy()
    positions = {name: position for name, _, _, position in records}
    for frame in range(1, FRAMES + 1):
        scene.frame_set(frame)
        strength = envelope(frame)
        progress = max(0.0, min(1.0, (frame - 16) / 40.0))
        rig.location = base_location + Vector((
            0.0, BODY_TRAVEL * strength * progress, 0.0
        ))
        rig.keyframe_insert(data_path="location", frame=frame)
        for name, phase, target, rest in records:
            along, height = foot_offset(frame, phase)
            target.location = rest + Vector((
                0.0,
                strength * along + rig.location.y - base_location.y,
                strength * height,
            ))
            # A stance target must not inherit the moving body's offset.
            if height == 0.0 and strength == 1.0:
                target.location.y = rest.y + along
            target.keyframe_insert(data_path="location", frame=frame)
    scene.frame_set(1)


def measure_targets(scene, records):
    """Report target movement separately during swing and stance frames.

    Args:
        scene (bpy.types.Scene): Scene containing keyed target empties.
        records (list): Named, measured IK target records.

    Returns:
        dict: Diagnostic target ranges and first/last rest error.
    """
    report = {}
    for name, _, target, rest in records:
        values = []
        for frame in range(1, FRAMES + 1):
            scene.frame_set(frame)
            values.append(target.location.copy())
        report[name] = {
            "rest_error_first": round((values[0] - rest).length, 6),
            "rest_error_last": round((values[-1] - rest).length, 6),
            "vertical_range": round(
                max(value.z for value in values) -
                min(value.z for value in values), 6
            ),
            "longitudinal_range": round(
                max(value.y for value in values) -
                min(value.y for value in values), 6
            ),
        }
    scene.frame_set(1)
    return report


def main():
    """Save a new Blender-only IK trial and diagnostics without publishing.

    Args:
        None.

    Returns:
        None: Produces a separate editable Blend and JSON report.
    """
    OUTPUT.mkdir(parents=True, exist_ok=True)
    rig, mesh, scene, records = prepare_scene()
    author_walk(rig, scene, records)
    report = {
        "status": "EXPERIMENTAL: targets only; mesh paw contact unverified",
        "source": str(SOURCE),
        "fps": FPS,
        "frames": FRAMES,
        "ik_targets": measure_targets(scene, records),
        "limitations": [
            "The source hindleg asymmetry has not been repaired.",
            "The source mouth topology does not genuinely open.",
            "Target stability does not prove paw-mesh grounding.",
            "No Roblox Studio Animator playback has been performed.",
        ],
    }
    destination = OUTPUT / "Frostfang_IKWalk_TARGET_QA.blend"
    bpy.ops.wm.save_as_mainfile(filepath=str(destination))
    (OUTPUT / "target_audit.json").write_text(
        json.dumps(report, indent=2), encoding="utf-8"
    )
    print("IK_TRIAL_SAVED", destination, json.dumps(report))


if __name__ == "__main__":
    main()
