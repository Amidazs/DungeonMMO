"""Measure how Frostfang IK target axes move actual planted toe mesh.

A finite-difference diagnostic only; it does not edit/save the rig.
"""

import json
from pathlib import Path

import bpy


SOURCE = (
    Path.home() / "Documents" / "Roblox" /
    "DungeonMMO_CanineRig_QA" / "Frostfang_20260923" /
    "GroundedWalkTrial_20260923" / "WalkV3" /
    "Frostfang_WalkV3_IK_UNAPPROVED.blend"
)
CASES = (
    ("HindRight", "DEF_toe.R", 17),
    ("HindRight", "DEF_toe.R", 23),
    ("HindRight", "DEF_toe.R", 26),
    ("FrontLeft", "DEF_front_toe.L", 17),
)
TEST_STEP = 0.01


def select_toe(mesh, group_name):
    """Find all vertices with substantial source toe skin weights.

    Args:
        mesh (bpy.types.Object): Actual skinned Frostfang geometry.
        group_name (str): Existing exact bone vertex group.

    Returns:
        list[int]: Vertices to measure in evaluated world space.
    """
    group = mesh.vertex_groups[group_name]
    return [
        vertex.index for vertex in mesh.data.vertices
        if any(
            influence.group == group.index and influence.weight >= 0.25
            for influence in vertex.groups
        )
    ]


def measure(mesh, indices):
    """Find current actual-world toe centroid and lowest surface.

    Args:
        mesh (bpy.types.Object): Current animated skinned source.
        indices (list[int]): Source-space toe vertex indices.

    Returns:
        dict: Evaluated horizontal center and minimum ground height.
    """
    graph = bpy.context.evaluated_depsgraph_get()
    evaluated = mesh.evaluated_get(graph)
    result = evaluated.to_mesh()
    try:
        points = [
            evaluated.matrix_world @ result.vertices[index].co
            for index in indices
        ]
        return {
            "y": sum(point.y for point in points) / len(points),
            "z": min(point.z for point in points),
        }
    finally:
        evaluated.to_mesh_clear()


def inspect_case(scene, mesh, label, group_name, frame):
    """Perturb one target in two axes without writing animation keys.

    Args:
        scene (bpy.types.Scene): Original animation scene.
        mesh (bpy.types.Object): Original animated source mesh.
        label (str): Anatomical leg name.
        group_name (str): Original toe vertex group.
        frame (int): Frame to inspect.

    Returns:
        dict: Baseline and measured toe response to each perturbation.
    """
    scene.frame_set(frame)
    target = bpy.data.objects["DMMO_WalkV3_" + label]
    original = target.location.copy()
    indices = select_toe(mesh, group_name)
    baseline = measure(mesh, indices)
    probes = {}
    for axis in ("y", "z"):
        probes[axis] = {}
        for sign in (-1, 1):
            target.location = original.copy()
            index = {"y": 1, "z": 2}[axis]
            target.location[index] += sign * TEST_STEP
            bpy.context.view_layer.update()
            probes[axis][str(sign)] = measure(mesh, indices)
    target.location = original
    bpy.context.view_layer.update()
    return {"frame": frame, "leg": label, "baseline": baseline,
            "probes": probes}


def main():
    """Print the measured IK-to-toe response without saving the file.

    Args:
        None.

    Returns:
        None: Produces a finite-difference diagnostic report.
    """
    bpy.ops.wm.open_mainfile(filepath=str(SOURCE))
    scene = bpy.context.scene
    mesh = bpy.data.objects["Frostfang_Canine_ExperimentalMesh"]
    cases = [
        inspect_case(scene, mesh, label, group, frame)
        for label, group, frame in CASES
    ]
    print("PAW_IK_DERIVATIVES", json.dumps(cases), flush=True)


if __name__ == "__main__":
    main()
