"""Check independent Frostfang spine, neck, head and tail articulation.

This creates a separate, reversible Blender rig-function study.
The source Meshy model, original QA blends and Studio places stay intact.
"""

import json
import math
from collections import defaultdict
from pathlib import Path

import bpy
from mathutils import Vector


ROOT = (
    Path.home() / "Documents" / "Roblox" /
    "DungeonMMO_CanineRig_QA" / "Frostfang_20260923"
)
SOURCE = ROOT / "Frostfang_Canine_ExperimentalMaster_JawV3.blend"
OUTPUT = ROOT / "RigFunctionQA_20260923"
RIG_NAME = "Frostfang_Canine_CompactRig"
MESH_NAME = "Frostfang_Canine_ExperimentalMesh"
POSES = (
    ("Rest", None, 0.0, 0.0, 1),
    ("HeadTurnLeft", "DEF_spine.011", 0.0, 11.0, 11),
    ("HeadNod", "DEF_spine.010", 9.0, 0.0, 21),
    ("TailYaw", "DEF_spine.002", 0.0, 12.0, 31),
    ("TailLift", "DEF_spine.003", 12.0, 0.0, 41),
    ("SpineFlex", "DEF_spine.006", 7.0, 0.0, 51),
    ("RestReturn", None, 0.0, 0.0, 61),
)
REGIONS = {
    "head": ("DEF_spine.011", "DEF_face", "DEF_nose"),
    "neck": ("DEF_spine.009", "DEF_spine.010"),
    "tail": ("DEF_spine.003", "DEF_spine.002", "DEF_spine.001"),
    "torso": ("DEF_spine.005", "DEF_spine.006", "DEF_spine.007"),
    "front_paws": (
        "DEF_front_foot.L", "DEF_front_foot.R",
        "DEF_front_toe.L", "DEF_front_toe.R",
    ),
    "hind_paws": (
        "DEF_foot.L", "DEF_foot.R", "DEF_toe.L", "DEF_toe.R",
    ),
}


def reset_pose(rig):
    """Set all joints back to neutral without editing source bind data.

    Args:
        rig (bpy.types.Object): Experimental weighted compact armature.

    Returns:
        None: Applies neutral local Euler pose to each actual bone.
    """
    for bone in rig.pose.bones:
        bone.rotation_mode = "XYZ"
        bone.rotation_euler = (0.0, 0.0, 0.0)
        bone.location = (0.0, 0.0, 0.0)
        bone.scale = (1.0, 1.0, 1.0)


def collect_regions(mesh):
    """Select source vertices whose strongest group matches each region.

    Args:
        mesh (bpy.types.Object): Actual skinned original-looking wolf.

    Returns:
        dict: Region labels mapped to disjoint source vertex indices.
    """
    owner_names = {
        mesh.vertex_groups.get(group).index: region
        for region, groups in REGIONS.items()
        for group in groups
        if mesh.vertex_groups.get(group) is not None
    }
    selected = defaultdict(list)
    for vertex in mesh.data.vertices:
        influences = [
            item for item in vertex.groups
            if item.group in owner_names and item.weight >= 0.15
        ]
        if influences:
            highest = max(influences, key=lambda item: item.weight)
            selected[owner_names[highest.group]].append(vertex.index)
    return dict(selected)


def sample_region_positions(mesh, regions):
    """Evaluate real deformed mesh vertex coordinates at current pose.

    Args:
        mesh (bpy.types.Object): Rig-deformed source wolf.
        regions (dict): Disjoint anatomical region vertex indices.

    Returns:
        dict: World-space coordinates sampled per anatomical region.
    """
    dependency_graph = bpy.context.evaluated_depsgraph_get()
    evaluated = mesh.evaluated_get(dependency_graph)
    evaluated_mesh = evaluated.to_mesh()
    try:
        matrix = evaluated.matrix_world
        return {
            region: [
                tuple(matrix @ evaluated_mesh.vertices[index].co)
                for index in indices
            ]
            for region, indices in regions.items()
        }
    finally:
        evaluated.to_mesh_clear()


def displacement(reference, posed):
    """Summarize skin motion of a named region without trusting bone UI.

    Args:
        reference (list): Actual evaluated vertex positions in rest.
        posed (list): Same indexed vertices after a joint is rotated.

    Returns:
        dict: Vertex count, largest and average Euclidean movement.
    """
    distances = [
        (Vector(after) - Vector(before)).length
        for before, after in zip(reference, posed)
    ]
    return {
        "vertex_count": len(distances),
        "max_displacement": round(max(distances, default=0.0), 6),
        "mean_displacement": round(
            sum(distances) / len(distances) if distances else 0.0, 6
        ),
    }


def capture_pose(scene, rig, mesh, regions, reference, entry):
    """Key one non-destructive test pose and audit actual skin movement.

    Args:
        scene (bpy.types.Scene): Isolated Blender review scene.
        rig (bpy.types.Object): Actual 33-bone skinned source rig.
        mesh (bpy.types.Object): Actual skinned source wolf.
        regions (dict): Anatomically assigned source vertex indices.
        reference (dict): Evaluated skin positions in neutral pose.
        entry (tuple): Name, bone, pitch/yaw and independent frame.

    Returns:
        dict: Identified test pose and measured regional displacements.
    """
    label, bone_name, pitch, yaw, frame = entry
    scene.frame_set(frame)
    reset_pose(rig)
    if bone_name:
        bone = rig.pose.bones.get(bone_name)
        if bone is None:
            raise RuntimeError(f"Missing source joint: {bone_name}")
        bone.rotation_euler = (
            math.radians(pitch), 0.0, math.radians(yaw)
        )
    for bone in rig.pose.bones:
        bone.keyframe_insert(data_path="rotation_euler", frame=frame)
    positions = sample_region_positions(mesh, regions)
    return {
        "label": label,
        "frame": frame,
        "bone": bone_name,
        "pitch_deg": pitch,
        "yaw_deg": yaw,
        "regions": {
            name: displacement(reference[name], positions[name])
            for name in regions
        },
    }


def add_camera(name, location, target):
    """Create a static orthographic camera for real skin review.

    Args:
        name (str): Display name for the preview camera.
        location (tuple): World camera position.
        target (tuple): Wolf chest/torso camera focus.

    Returns:
        bpy.types.Object: New render-only view camera.
    """
    data = bpy.data.cameras.new(name)
    camera = bpy.data.objects.new(name, data)
    bpy.context.scene.collection.objects.link(camera)
    camera.location = location
    camera.rotation_euler = (
        Vector(target) - camera.location
    ).to_track_quat("-Z", "Y").to_euler()
    data.type = "ORTHO"
    data.ortho_scale = 1.9
    return camera


def render_review(scene, rig):
    """Render all isolated poses from two consistent inspection angles.

    Args:
        scene (bpy.types.Scene): Isolated working copy.
        rig (bpy.types.Object): Skinned armature hidden from render.

    Returns:
        list[str]: Exact PNG paths of actual evaluated skin images.
    """
    scene.render.engine = "BLENDER_WORKBENCH"
    scene.display.shading.light = "STUDIO"
    scene.display.shading.color_type = "MATERIAL"
    scene.display.shading.show_shadows = True
    scene.render.resolution_x = 780
    scene.render.resolution_y = 530
    scene.render.image_settings.file_format = "PNG"
    rig.hide_render = True
    cameras = {
        "side": add_camera(
            "DMMO_RigFunction_Side", (2.35, -0.12, 0.85),
            (-0.08, 0.0, 0.5),
        ),
        "oblique": add_camera(
            "DMMO_RigFunction_Oblique", (2.1, -1.7, 1.1),
            (-0.08, 0.0, 0.5),
        ),
    }
    images = []
    for view_name, camera in cameras.items():
        scene.camera = camera
        for label, _, _, _, frame in POSES:
            scene.frame_set(frame)
            destination = OUTPUT / f"{view_name}_{label}.png"
            scene.render.filepath = str(destination)
            bpy.ops.render.render(write_still=True)
            images.append(str(destination))
    return images


def main():
    """Save independent anatomical pose tests and real-mesh evidence.

    Args:
        None.

    Returns:
        None: Writes a new editable Blender study, JSON and PNGs.
    """
    OUTPUT.mkdir(parents=True, exist_ok=True)
    bpy.ops.wm.open_mainfile(filepath=str(SOURCE))
    rig = bpy.data.objects[RIG_NAME]
    mesh = bpy.data.objects[MESH_NAME]
    rig.animation_data_clear()
    reset_pose(rig)
    scene = bpy.context.scene
    scene.frame_start = 1
    scene.frame_end = POSES[-1][-1]
    regions = collect_regions(mesh)
    reference = sample_region_positions(mesh, regions)
    measurements = [
        capture_pose(scene, rig, mesh, regions, reference, entry)
        for entry in POSES
    ]
    blend = OUTPUT / "Frostfang_RigFunction_UNAPPROVED.blend"
    scene.frame_set(1)
    bpy.ops.wm.save_as_mainfile(filepath=str(blend))
    images = render_review(scene, rig)
    report = {
        "status": "EXPERIMENTAL rig function, not accepted animation",
        "source": str(SOURCE),
        "blend": str(blend),
        "regional_vertex_counts": {
            name: len(indices) for name, indices in regions.items()
        },
        "poses": measurements,
        "images": images,
        "notes": [
            "Tail tip group DEF_spine has no substantial mesh weights.",
            "This does not prove a realistic animated tail or neck.",
            "JawV3 retains original closed-muzzle topology.",
            "No original Blend, Studio game or Roblox asset modified.",
        ],
    }
    (OUTPUT / "rig_function_audit.json").write_text(
        json.dumps(report, indent=2), encoding="utf-8"
    )
    print("RIG_FUNCTION_RESULT", json.dumps(report), flush=True)


if __name__ == "__main__":
    main()
