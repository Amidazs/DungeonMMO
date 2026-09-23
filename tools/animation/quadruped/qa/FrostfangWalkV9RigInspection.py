"""Inspect Frostfang's actual shoulder hierarchy before canine gait editing."""

import json
from pathlib import Path

import bpy


ROOT = (
    Path.home() / "Documents" / "Roblox" /
    "DungeonMMO_CanineRig_QA" / "Frostfang_20260923" /
    "GroundedWalkTrial_20260923"
)
SOURCE = ROOT / "WalkV8_ForelegTail" / "Frostfang_WalkV8_UNAPPROVED.blend"
RIG_NAME = "Frostfang_Canine_CompactRig"
MESH_NAME = "Frostfang_Canine_ExperimentalMesh"


def describe_bone(rig, bone, mesh):
    """Collect actual rest connections and skin influences for one bone.

    Args:
        rig (bpy.types.Object): Existing weighted Frostfang armature.
        bone (bpy.types.Bone): One deform or control bone.
        mesh (bpy.types.Object): Existing skinned wolf mesh.

    Returns:
        dict: Parent, position, axis and weighted vertex statistics.
    """
    group = mesh.vertex_groups.get(bone.name)
    vertices = 0
    if group is not None:
        vertices = sum(
            any(
                item.group == group.index and item.weight >= 0.1
                for item in vertex.groups
            )
            for vertex in mesh.data.vertices
        )
    return {
        "name": bone.name,
        "parent": bone.parent.name if bone.parent else None,
        "connected": bone.use_connect,
        "head": tuple(round(n, 5) for n in bone.head_local),
        "tail": tuple(round(n, 5) for n in bone.tail_local),
        "length": round(bone.length, 5),
        "weighted_vertices": vertices,
        "children": [child.name for child in bone.children],
    }


def inspect_scene():
    """Report the original leg hierarchy, shoulder candidates and gait.

    Args:
        None.

    Returns:
        dict: Actual source rig and WalkV8 animation metadata.
    """
    bpy.ops.wm.open_mainfile(filepath=str(SOURCE))
    rig = bpy.data.objects[RIG_NAME]
    mesh = bpy.data.objects[MESH_NAME]
    chosen = [
        bone for bone in rig.data.bones
        if (
            "front" in bone.name.lower()
            or "spine" in bone.name.lower()
            or "shoulder" in bone.name.lower()
            or "scap" in bone.name.lower()
            or "thigh" in bone.name.lower()
        )
    ]
    scene = bpy.context.scene
    actions = []
    for name in ("DEF_front_thigh.L", "DEF_front_thigh.R"):
        bone = rig.pose.bones[name]
        actions.append({
            "name": name,
            "constraints": [
                {
                    "type": constraint.type,
                    "name": constraint.name,
                    "influence": constraint.influence,
                }
                for constraint in bone.constraints
            ],
            "rotation_mode": bone.rotation_mode,
        })
    return {
        "source": str(SOURCE),
        "frame_range": [scene.frame_start, scene.frame_end],
        "fps": scene.render.fps,
        "bones": [describe_bone(rig, bone, mesh) for bone in chosen],
        "front_poses": actions,
        "armature_animation": bool(
            rig.animation_data and rig.animation_data.action
        ),
    }


def main():
    """Print a read-only source anatomy report before editing any pose.

    Args:
        None.

    Returns:
        None: Logs measured bone hierarchy to the QA terminal.
    """
    print("FROSTFANG_V9_RIG", json.dumps(inspect_scene()), flush=True)


if __name__ == "__main__":
    main()
