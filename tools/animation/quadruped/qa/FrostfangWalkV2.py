"""Build an isolated Frostfang walk with per-leg planted paw targets.

The Blender file is an editable authoring trial. The original wolf,
saved Studio places, facial topology, and gameplay remain untouched.
Actual skinned toe movement is audited by a separate script.
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
OUTPUT = ROOT / "GroundedWalkTrial_20260923" / "WalkV2"
FPS = 24
FINAL_FRAME = 72
WALK_START = 17
WALK_FINISH = 65
CYCLE_FRAMES = 24
STRIDE = 0.07
LIFT = 0.035
STANCE_FRACTION = 0.67
GROUND_Z = 0.02618
LEGS = (
    ("FrontLeft", "DEF_front_shin.L", "DEF_front_foot.L",
     "DEF_front_toe.L", 0.00),
    ("HindRight", "DEF_shin.R", "DEF_foot.R",
     "DEF_toe.R", 0.25),
    ("FrontRight", "DEF_front_shin.R", "DEF_front_foot.R",
     "DEF_front_toe.R", 0.50),
    ("HindLeft", "DEF_shin.L", "DEF_foot.L",
     "DEF_toe.L", 0.75),
)


def smoothstep(value):
    """Ease normalized progress while safely handling out-of-range input.

    Args:
        value (float): Progress to ease.

    Returns:
        float: Clamped cubic easing value.
    """
    fraction = max(0.0, min(1.0, value))
    return fraction * fraction * (3.0 - 2.0 * fraction)


def interpolate(first, last, amount):
    """Linearly blend two vectors with a bounded interpolation amount.

    Args:
        first (Vector): Original vector.
        last (Vector): Destination vector.
        amount (float): Fraction of progress.

    Returns:
        Vector: Interpolated vector.
    """
    return first.lerp(last, smoothstep(amount))


def make_target(rig, label, lower_name, foot_name):
    """Attach a non-stretching, two-bone IK target to one limb.

    Args:
        rig (bpy.types.Object): Existing weighted Frostfang armature.
        label (str): Unique identifier for the leg.
        lower_name (str): Exact shin or lower-hind bone.
        foot_name (str): Exact ankle/paw bone.

    Returns:
        tuple: Independent IK target and its measured world-space rest.
    """
    lower = rig.pose.bones[lower_name]
    foot = rig.pose.bones[foot_name]
    original = rig.matrix_world @ foot.head
    target = bpy.data.objects.new("DMMO_WalkV2_" + label, None)
    bpy.context.scene.collection.objects.link(target)
    target.empty_display_type = "SPHERE"
    target.empty_display_size = 0.024
    target.location = original
    ik = lower.constraints.new("IK")
    ik.name = "DMMO_WalkV2_IK"
    ik.target = target
    ik.chain_count = 2
    ik.use_stretch = False
    ik.iterations = 120
    return target, original.copy()


def prepare_rig():
    """Open the independent source and create four paw-target controls.

    Args:
        None.

    Returns:
        tuple: Rig, scene and independently measured leg records.
    """
    bpy.ops.wm.open_mainfile(filepath=str(SOURCE))
    rig = bpy.data.objects["Frostfang_Canine_CompactRig"]
    rig.animation_data_clear()
    for bone in rig.pose.bones:
        bone.rotation_mode = "QUATERNION"
        bone.rotation_quaternion = (1.0, 0.0, 0.0, 0.0)
        bone.location = (0.0, 0.0, 0.0)
        for constraint in list(bone.constraints):
            bone.constraints.remove(constraint)
    legs = []
    for label, lower, foot, toe, offset in LEGS:
        target, original = make_target(rig, label, lower, foot)
        legs.append({
            "label": label,
            "toe_group": toe,
            "offset": offset,
            "target": target,
            "rest": original,
        })
    scene = bpy.context.scene
    scene.render.fps = FPS
    scene.frame_start = 1
    scene.frame_end = FINAL_FRAME
    return rig, scene, legs


def gait_position(frame, offset, rest):
    """Find a planted stance position or an elevated swing trajectory.

    Args:
        frame (int): Frame relative to the start of the walking interval.
        offset (float): Leg phase offset in gait cycles.
        rest (Vector): Original ankle target in world coordinates.

    Returns:
        tuple: World-space paw target and whether this leg is in stance.
    """
    absolute_phase = frame / CYCLE_FRAMES + offset
    cycle_index = math.floor(absolute_phase)
    phase = absolute_phase - cycle_index
    contact_y = rest.y - STRIDE * cycle_index
    position = rest.copy()
    if phase < STANCE_FRACTION:
        position.y = contact_y
        return position, True
    swing = (phase - STANCE_FRACTION) / (1.0 - STANCE_FRACTION)
    position.y = contact_y - STRIDE * smoothstep(swing)
    position.z += LIFT * math.sin(math.pi * swing)
    return position, False


def pose_frame(frame, rig, legs, start_location):
    """Key root progression and independently planted ankle targets.

    Args:
        frame (int): Current one-based animation frame.
        rig (bpy.types.Object): Experimental armature.
        legs (list): Measured per-leg target records.
        start_location (Vector): Unmodified root location.

    Returns:
        dict: Root distance and stance designation per leg.
    """
    distance = -STRIDE * max(
        0.0, min(2.0, (frame - WALK_START) / CYCLE_FRAMES)
    )
    rig.location = start_location + Vector((0.0, distance, -GROUND_Z))
    rig.keyframe_insert(data_path="location", frame=frame)
    stance = {}
    for leg in legs:
        if frame < WALK_START:
            gait, planted = gait_position(
                0, leg["offset"], leg["rest"]
            )
            destination = interpolate(
                leg["rest"], gait,
                (frame - 8) / (WALK_START - 8)
            )
        elif frame < WALK_FINISH:
            destination, planted = gait_position(
                frame - WALK_START, leg["offset"], leg["rest"]
            )
        else:
            gait, planted = gait_position(
                WALK_FINISH - WALK_START, leg["offset"], leg["rest"]
            )
            idle = leg["rest"] + Vector((0.0, -2.0 * STRIDE, 0.0))
            destination = interpolate(
                gait, idle, (frame - WALK_FINISH) /
                (FINAL_FRAME - WALK_FINISH)
            )
        leg["target"].location = destination
        leg["target"].keyframe_insert(
            data_path="location", frame=frame
        )
        stance[leg["label"]] = bool(
            WALK_START <= frame < WALK_FINISH and planted
        )
    return {"root_distance": round(distance, 6), "stance": stance}


def build_walk(rig, scene, legs):
    """Key an editable approach, two gait periods and stop transition.

    Args:
        rig (bpy.types.Object): Experimental canine armature.
        scene (bpy.types.Scene): Current animation timeline.
        legs (list): Four measured independent paw controls.

    Returns:
        dict: Per-frame support classification for mesh QA.
    """
    root_start = rig.location.copy()
    record = {}
    for frame in range(1, FINAL_FRAME + 1):
        scene.frame_set(frame)
        record[frame] = pose_frame(frame, rig, legs, root_start)
    scene.frame_set(1)
    return record


def save_results(rig, scene, legs, record):
    """Save the new trial and its gait metadata as separate files.

    Args:
        rig (bpy.types.Object): Experimental skinned rig.
        scene (bpy.types.Scene): Animated source scene.
        legs (list): Four paw target records.
        record (dict): Frame-indexed support and root positions.

    Returns:
        None: Writes Blender and JSON checkpoints outside production.
    """
    OUTPUT.mkdir(parents=True, exist_ok=True)
    blend_path = OUTPUT / "Frostfang_WalkV2_IK_UNAPPROVED.blend"
    metadata = {
        "status": "IK TARGET TRIAL; actual mesh grounding unverified",
        "source": str(SOURCE),
        "frames": FINAL_FRAME,
        "fps": FPS,
        "stride_source_units": STRIDE,
        "stance_fraction": STANCE_FRACTION,
        "ground_offset_source_units": GROUND_Z,
        "legs": [
            {
                "label": leg["label"],
                "toe_group": leg["toe_group"],
                "offset": leg["offset"],
            } for leg in legs
        ],
        "frame_status": record,
        "limitations": [
            "Skin-weight and hind-leg anatomy require independent QA.",
            "Jaw is still a closed single-mesh muzzle.",
            "No Studio Animator playback or user approval.",
        ],
    }
    bpy.ops.wm.save_as_mainfile(filepath=str(blend_path))
    (OUTPUT / "walk_v2_manifest.json").write_text(
        json.dumps(metadata, indent=2), encoding="utf-8"
    )
    print("WALK_V2_SAVED", blend_path, flush=True)


def main():
    """Produce a separate reversible four-leg locomotion experiment.

    Args:
        None.

    Returns:
        None: Creates an editable test and frame-by-frame QA metadata.
    """
    rig, scene, legs = prepare_rig()
    record = build_walk(rig, scene, legs)
    save_results(rig, scene, legs, record)


if __name__ == "__main__":
    main()
