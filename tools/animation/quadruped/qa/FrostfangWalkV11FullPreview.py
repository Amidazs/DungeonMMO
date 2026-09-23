"""Render unapproved real-mesh Frostfang walk frames for visual QA.

The renderer opens a copy of the experimental Blend and saves images
only. No source animation, gameplay place or asset is published.
"""

from pathlib import Path

import bpy
from mathutils import Vector


ROOT = (
    Path.home() / "Documents" / "Roblox" /
    "DungeonMMO_CanineRig_QA" / "Frostfang_20260923" /
    "GroundedWalkTrial_20260923" / "WalkV11_ShoulderSkin"
)
SOURCE = ROOT / "Frostfang_WalkV11_UNAPPROVED.blend"
PREVIEW = ROOT / "preview" / "full"
FRAMES = tuple(range(1, 73, 2)) + (72,)


def add_camera(name, location, target):
    """Make an orthographic camera focused on the animated mesh.

    Args:
        name (str): Identifier for the review view.
        location (tuple): Camera location in source Blender coordinates.
        target (tuple): Center of the wolf's travel corridor.

    Returns:
        bpy.types.Object: New non-published preview camera.
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


def make_ground():
    """Add a disposable world-Z zero reference surface.

    Args:
        None.

    Returns:
        bpy.types.Object: Flat floor used only for render inspection.
    """
    bpy.ops.mesh.primitive_plane_add(size=3)
    ground = bpy.context.object
    ground.name = "DMMO_WalkV11_QA_Floor"
    ground.location.z = 0.0
    return ground


def configure_renderer(scene):
    """Set a lightweight material-colored Workbench preview.

    Args:
        scene (bpy.types.Scene): Isolated Blender review scene.

    Returns:
        None: Changes only in-memory render settings.
    """
    scene.render.engine = "BLENDER_WORKBENCH"
    scene.display.shading.light = "STUDIO"
    scene.display.shading.color_type = "MATERIAL"
    scene.display.shading.show_shadows = True
    scene.render.resolution_x = 760
    scene.render.resolution_y = 510
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = "PNG"
    scene.render.film_transparent = False


def hide_authoring_controls():
    """Keep rig bones and IK empties out of the model render.

    Args:
        None.

    Returns:
        None: Hides only non-mesh authoring controls from render.
    """
    for item in bpy.data.objects:
        if item.type in {"ARMATURE", "EMPTY"}:
            item.hide_render = True


def render_views(scene):
    """Save actual skinned wolf samples from side and oblique cameras.

    Args:
        scene (bpy.types.Scene): Independent review scene.

    Returns:
        list[str]: Local preview image paths.
    """
    cameras = {
        "side": add_camera(
            "DMMO_WalkV11_Side", (2.4, -0.1, 0.75),
            (-0.09, -0.13, 0.49),
        ),
        "three_quarter": add_camera(
            "DMMO_WalkV11_Oblique", (2.0, -1.7, 1.05),
            (-0.09, -0.13, 0.49),
        ),
    }
    saved = []
    for view_name, camera in cameras.items():
        scene.camera = camera
        for frame in FRAMES:
            scene.frame_set(frame)
            destination = PREVIEW / (
                f"Frostfang_WalkV11_{view_name}_{frame:03d}.png"
            )
            scene.render.filepath = str(destination)
            bpy.ops.render.render(write_still=True)
            saved.append(str(destination))
            print("WALK_V11_PREVIEW", destination, flush=True)
    return saved


def main():
    """Produce a new visual QA package without changing source files.

    Args:
        None.

    Returns:
        None: Stores a continuous render sequence of the real weighted wolf.
    """
    PREVIEW.mkdir(parents=True, exist_ok=True)
    bpy.ops.wm.open_mainfile(filepath=str(SOURCE))
    scene = bpy.context.scene
    make_ground()
    hide_authoring_controls()
    configure_renderer(scene)
    images = render_views(scene)
    print("WALK_V11_PREVIEW_COMPLETE", len(images), flush=True)


if __name__ == "__main__":
    main()
