"""Make a reversible, experimental Frostfang animation and visual preview.

This is a rig-motion demonstration, NOT an accepted walking animation.
It poses the actual weighted mesh in Blender; no Studio edit is needed.
"""

from pathlib import Path
import json
import math

import bpy
from mathutils import Vector


ROOT = (
    Path.home() / "Documents" / "Roblox" /
    "DungeonMMO_CanineRig_QA" / "Frostfang_20260923"
)
SOURCE = ROOT / "Frostfang_Canine_ExperimentalMaster_JawV3.blend"
OUT = ROOT / "MotionPreview_20260923"
FPS = 16
TOTAL_FRAMES = 64
WALK_START = 5
WALK_END = 41
ATTACK_START = 46
ATTACK_END = 60

BODY = [
    "DEF_spine.006", "DEF_spine.007", "DEF_spine.008",
    "DEF_spine.009", "DEF_spine.010", "DEF_spine.011",
    "DEF_face", "DEF_jaw", "DEF_spine.001", "DEF_spine.002",
]
LEGS = [
    ("front_thigh", "front_shin", "front_foot", "L", 0.0),
    ("front_thigh", "front_shin", "front_foot", "R", 0.5),
    ("thigh", "shin", "foot", "L", 0.5),
    ("thigh", "shin", "foot", "R", 0.0),
]


def smoothstep(value):
    """Return smooth interpolation between zero and one.

    Args:
        value (float): Unit interval parameter.

    Returns:
        float: Smooth value clamped to the unit interval.
    """
    t = min(1.0, max(0.0, value))
    return t * t * (3 - 2 * t)


def bump(value, start, peak, end):
    """Return a smooth, bounded attack or locomotion envelope.

    Args:
        value (float): Current time.
        start (float): First influence.
        peak (float): Maximum influence.
        end (float): Final influence.

    Returns:
        float: Smooth attack envelope.
    """
    if value < start or value > end:
        return 0.0
    if value <= peak:
        return smoothstep((value - start) / (peak - start))
    return 1 - smoothstep((value - peak) / (end - peak))


def clear_pose(rig):
    """Remove all test rotations before authoring a fresh pose.

    Args:
        rig (bpy.types.Object): Experimental compact wolf armature.

    Returns:
        None: All bones return to local rest rotations.
    """
    for bone in rig.pose.bones:
        bone.rotation_mode = "XYZ"
        bone.rotation_euler = (0, 0, 0)
        bone.location = (0, 0, 0)
        bone.scale = (1, 1, 1)


def set_rot(rig, name, x=0.0, y=0.0, z=0.0):
    """Set one measured rig bone's local Euler rotation.

    Args:
        rig (bpy.types.Object): Experimental canine armature.
        name (str): Unique actual bone name on the rig.
        x (float): Local X rotation in degrees.
        y (float): Local Y rotation in degrees.
        z (float): Local Z rotation in degrees.

    Returns:
        None: Updates the actual weighted source rig pose.
    """
    bone = rig.pose.bones.get(name)
    if bone is None:
        raise RuntimeError(f"Missing measured limb or body bone: {name}")
    bone.rotation_mode = "XYZ"
    bone.rotation_euler = tuple(
        math.radians(value) for value in (x, y, z)
    )


def author_pose(rig, frame):
    """Pose the weighted mesh for one explicitly unapproved motion frame.

    Args:
        rig (bpy.types.Object): Source Frostfang compact deform rig.
        frame (int): 1-indexed frame on a 16 fps test timeline.

    Returns:
        dict: Walk/bite envelope strengths used for a QA report.
    """
    clear_pose(rig)
    walk = bump(frame, WALK_START, WALK_START + 3, WALK_END)
    if frame > WALK_END - 4:
        walk = 1 - smoothstep(
            (frame - (WALK_END - 4)) / 4
        )
    walk = max(0.0, min(1.0, walk))
    phase = (frame - WALK_START) / 16 * math.pi * 2
    for upper, lower, paw, side, offset in LEGS:
        angle = phase + offset * math.pi * 2
        fore = upper.startswith("front")
        side_phase = math.sin(angle)
        foot_swing = max(0, math.cos(angle))
        lift = foot_swing ** 2
        upper_x = (16 if fore else -14) * side_phase * walk
        lower_x = (23 if fore else -21) * lift * walk
        paw_x = -lower_x * .70 - upper_x * .15
        set_rot(rig, f"DEF_{upper}.{side}", x=upper_x)
        set_rot(rig, f"DEF_{lower}.{side}", x=lower_x)
        set_rot(rig, f"DEF_{paw}.{side}", x=paw_x)
    set_rot(
        rig, "DEF_spine.008",
        x=2.0 * math.sin(2 * phase) * walk,
        z=1.0 * math.sin(phase) * walk,
    )
    set_rot(
        rig, "DEF_spine.010",
        x=1.1 * math.sin(phase + .8) * walk,
    )
    set_rot(
        rig, "DEF_spine.001",
        z=5 * math.sin(phase + 1.1) * walk,
    )
    set_rot(
        rig, "DEF_spine.002",
        z=7 * math.sin(phase + 2.0) * walk,
    )

    # Separate animation proof: a short foreleg load and head snap.
    windup = bump(frame, ATTACK_START, ATTACK_START + 6, ATTACK_END)
    head_snap = bump(frame, ATTACK_START + 6,
                     ATTACK_START + 9, ATTACK_END)
    jaw = bump(frame, ATTACK_START + 5,
               ATTACK_START + 8, ATTACK_END - 1)
    if windup:
        set_rot(rig, "DEF_front_thigh.L", x=-13 * windup)
        set_rot(rig, "DEF_front_shin.L", x=23 * windup)
        set_rot(rig, "DEF_front_foot.L", x=-16 * windup)
        set_rot(rig, "DEF_spine.010", x=-6 * windup)
        set_rot(rig, "DEF_spine.011", x=6 * head_snap)
        set_rot(rig, "DEF_face", x=-4 * head_snap)
        set_rot(rig, "DEF_jaw", x=-24 * jaw)
    return {"walk": round(walk, 3), "attack": round(windup, 3),
            "jaw": round(jaw, 3)}


def create_action(rig, scene):
    """Bake the test pose sequence into an editable Blender action.

    Args:
        rig (bpy.types.Object): Actual Frostfang deforming skeleton.
        scene (bpy.types.Scene): Blender animation timeline.

    Returns:
        dict: Key animation statistics for the QA report.
    """
    if rig.animation_data:
        rig.animation_data_clear()
    rig.animation_data_create()
    scene.render.fps = FPS
    scene.frame_start = 1
    scene.frame_end = TOTAL_FRAMES
    reported = {}
    keyframes = [1, 5, 8, 12, 16, 20, 24, 28, 32, 36,
                 41, 45, 46, 50, 52, 55, 57, 59, 60, 64]
    for frame in keyframes:
        scene.frame_set(frame)
        reported[frame] = author_pose(rig, frame)
        for bone in rig.pose.bones:
            if bone.name in BODY or bone.name.startswith(
                ("DEF_front_", "DEF_thigh.", "DEF_shin.",
                 "DEF_foot.")
            ):
                bone.keyframe_insert(
                    data_path="rotation_euler", frame=frame
                )
    if not rig.animation_data or not rig.animation_data.action:
        raise RuntimeError("Animation was not attached to the rig")
    action = rig.animation_data.action
    action.name = "DMMO_Frostfang_Motion_QA_UNAPPROVED"
    scene.frame_set(1)
    return {
        "action": action.name,
        "keyed_frames": keyframes,
        "fps": FPS,
        "duration_seconds": TOTAL_FRAMES / FPS,
        "envelopes": reported,
    }


def add_ground():
    """Create a non-colliding floor visual outside the skinned model.

    Args:
        None.

    Returns:
        bpy.types.Object: An unanimated reference for paw clearance.
    """
    bpy.ops.mesh.primitive_plane_add(size=3)
    plane = bpy.context.object
    plane.name = "DMMO_TestOnly_GroundPlane"
    plane.scale = (1.7, 1.2, 1.0)
    plane.location = (0, 0, 0)
    mat = bpy.data.materials.new("QA_Ground_Muted")
    mat.diffuse_color = (.32, .38, .43, 1)
    plane.data.materials.append(mat)
    return plane


def add_camera(name, location, target, scale):
    """Create an orthographic model-inspection camera.

    Args:
        name (str): Named camera/view.
        location (tuple): Camera position.
        target (tuple): Aim point.
        scale (float): Orthographic viewport size.

    Returns:
        bpy.types.Object: QA view camera.
    """
    camera_data = bpy.data.cameras.new(name)
    camera = bpy.data.objects.new(name, camera_data)
    bpy.context.scene.collection.objects.link(camera)
    camera.location = location
    camera.rotation_euler = (
        Vector(target) - camera.location
    ).to_track_quat("-Z", "Y").to_euler()
    camera_data.type = "ORTHO"
    camera_data.ortho_scale = scale
    return camera


def set_render(scene):
    """Configure lightweight, deterministic Blender workbench previews.

    Args:
        scene (bpy.types.Scene): Unpublished experimental scene.

    Returns:
        None: Uses studio lighting, not online rendering.
    """
    scene.render.engine = "BLENDER_WORKBENCH"
    scene.display.shading.light = "STUDIO"
    scene.display.shading.color_type = "MATERIAL"
    scene.display.shading.show_shadows = True
    scene.render.resolution_x = 760
    scene.render.resolution_y = 530
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = "PNG"
    scene.render.film_transparent = False
    scene.camera = add_camera(
        "DMMO_QA_ThreeQuarter", (2.8, -1.85, 1.25),
        (-.06, -.04, .47), 2.45,
    )


def render_samples(scene):
    """Render actual skinned geometry into a GIF-ready sequence.

    Args:
        scene (bpy.types.Scene): Animated Frostfang scene.

    Returns:
        list: PNG filenames of sequential motion frames.
    """
    paths = []
    for frame in range(1, TOTAL_FRAMES + 1, 2):
        scene.frame_set(frame)
        filename = OUT / f"wolf_{frame:03d}.png"
        scene.render.filepath = str(filename)
        bpy.ops.render.render(write_still=True)
        paths.append(str(filename))
        print("MOTION_QA_FRAME", frame, filename, flush=True)
    return paths


def main():
    """Save editable motion and renders without changing source files.

    Args:
        None.

    Returns:
        None: Saves an unapproved .blend, manifest and image sequence.
    """
    OUT.mkdir(parents=True, exist_ok=True)
    bpy.ops.wm.open_mainfile(filepath=str(SOURCE))
    mesh = bpy.data.objects["Frostfang_Canine_ExperimentalMesh"]
    rig = bpy.data.objects["Frostfang_Canine_CompactRig"]
    rig.hide_set(False)
    rig.hide_render = True
    mesh.hide_set(False)
    mesh.hide_render = False
    scene = bpy.context.scene
    stats = create_action(rig, scene)
    add_ground()
    set_render(scene)
    blend = OUT / "Frostfang_Motion_QA_UNAPPROVED.blend"
    bpy.ops.wm.save_as_mainfile(filepath=str(blend))
    outputs = render_samples(scene)
    manifest = {
        "source": str(SOURCE),
        "blend": str(blend),
        "preview": str(OUT / "Frostfang_RigMotion_QA.gif"),
        "files": outputs,
        "animation": stats,
        "status": "UNAPPROVED motion test; NOT natural walking",
        "no_studio_gameplay_edits": True,
        "warnings": [
            "In-place limb cycle does not lock planted paws.",
            "Original lower muzzle lacks separately opening topology.",
            "Hindleg asymmetry and shoulder skin remain unresolved.",
            "Rendered in Blender, not Roblox Studio Animator.",
        ],
    }
    (OUT / "preview_manifest.json").write_text(
        json.dumps(manifest, indent=2), encoding="utf-8"
    )
    print("MOTION_QA_DONE", str(blend), len(outputs), flush=True)


if __name__ == "__main__":
    main()
