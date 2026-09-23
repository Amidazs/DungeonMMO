"""Test neutral world-oriented paws on a copied Frostfang v3 gait.

This is an isolated diagnostic for rear-paw pitching, not a validated
contact solver. Original skinned source and Studio places are unchanged.
"""

import json
from pathlib import Path

import bpy


ROOT = (
    Path.home() / "Documents" / "Roblox" /
    "DungeonMMO_CanineRig_QA" / "Frostfang_20260923" /
    "GroundedWalkTrial_20260923"
)
SOURCE = ROOT / "WalkV3" / "Frostfang_WalkV3_IK_UNAPPROVED.blend"
OUTPUT = ROOT / "WalkV5_PawOrientation"
FEET = (
    ("FrontLeft", "DEF_front_foot.L"),
    ("FrontRight", "DEF_front_foot.R"),
    ("HindLeft", "DEF_foot.L"),
    ("HindRight", "DEF_foot.R"),
)


def add_world_paw_rotation(rig, label, bone_name):
    """Keep an individual paw oriented as it was at neutral stance.

    Args:
        rig (bpy.types.Object): Existing experimental weighted armature.
        label (str): Unique anatomical paw identifier.
        bone_name (str): Exact animated foot bone name.

    Returns:
        dict: Constraint and reference object names for inspection.
    """
    bone = rig.pose.bones.get(bone_name)
    if bone is None:
        raise RuntimeError("Missing source paw bone: " + bone_name)
    reference = bpy.data.objects.new(
        "DMMO_WalkV5_PawWorld_" + label, None
    )
    bpy.context.scene.collection.objects.link(reference)
    reference.rotation_mode = "QUATERNION"
    reference.rotation_quaternion = (
        rig.matrix_world @ bone.matrix
    ).to_quaternion()
    reference.empty_display_type = "ARROWS"
    reference.empty_display_size = 0.02
    constraint = bone.constraints.new("COPY_ROTATION")
    constraint.name = "DMMO_WalkV5_Test_FootOrientation"
    constraint.target = reference
    constraint.owner_space = "WORLD"
    constraint.target_space = "WORLD"
    constraint.mix_mode = "REPLACE"
    return {
        "label": label,
        "bone": bone_name,
        "reference": reference.name,
        "constraint": constraint.name,
    }


def main():
    """Save an independent world-oriented-foot candidate for mesh audit.

    Args:
        None.

    Returns:
        None: Creates a new Blender file and non-acceptance manifest.
    """
    OUTPUT.mkdir(parents=True, exist_ok=True)
    bpy.ops.wm.open_mainfile(filepath=str(SOURCE))
    scene = bpy.context.scene
    scene.frame_set(1)
    rig = bpy.data.objects["Frostfang_Canine_CompactRig"]
    records = [
        add_world_paw_rotation(rig, label, bone_name)
        for label, bone_name in FEET
    ]
    scene.frame_set(1)
    blender_path = OUTPUT / "Frostfang_WalkV5_UNAPPROVED.blend"
    bpy.ops.wm.save_as_mainfile(filepath=str(blender_path))
    report = {
        "status": "UNAPPROVED: experimental paw orientation constraint",
        "input": str(SOURCE),
        "blender": str(blender_path),
        "feet": records,
        "notes": [
            "Keep the older WalkV3 as the comparison baseline.",
            "World-oriented paw may still slide or deform badly.",
            "No FK baking or Studio animation import has occurred.",
        ],
    }
    (OUTPUT / "walk_v5_manifest.json").write_text(
        json.dumps(report, indent=2), encoding="utf-8"
    )
    print("WALK_V5_SAVED", blender_path, flush=True)


if __name__ == "__main__":
    main()
