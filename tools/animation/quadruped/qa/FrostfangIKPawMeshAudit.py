"""Measure actual Frostfang paw geometry in the independent IK trial.

The IK target locations alone cannot establish that skinned paw vertices
are planted. Evaluate the armature-deformed mesh at selected gait frames.
"""

import json
from pathlib import Path

import bpy
from mathutils import Vector


ROOT = (
    Path.home() / "Documents" / "Roblox" /
    "DungeonMMO_CanineRig_QA" / "Frostfang_20260923" /
    "GroundedWalkTrial_20260923"
)
SOURCE = ROOT / "Frostfang_IKWalk_TARGET_QA.blend"
SAMPLE_FRAMES = (1, 16, 22, 28, 34, 40, 46, 52, 56, 65, 72)
GROUP_NAMES = {
    "FrontLeft": "DEF_front_toe.L",
    "FrontRight": "DEF_front_toe.R",
    "HindLeft": "DEF_toe.L",
    "HindRight": "DEF_toe.R",
}


def find_paw_indices(mesh, group_name):
    """Locate source vertices predominantly assigned to one toe.

    Args:
        mesh (bpy.types.Object): The source weighted wolf mesh.
        group_name (str): Exact deform group identifying one paw.

    Returns:
        list[int]: Mesh vertex indices with a positive toe influence.
    """
    group = mesh.vertex_groups.get(group_name)
    if group is None:
        raise RuntimeError("Missing paw group: " + group_name)
    return [
        vertex.index
        for vertex in mesh.data.vertices
        if any(
            influence.group == group.index and influence.weight >= 0.25
            for influence in vertex.groups
        )
    ]


def sample_paws(mesh, indices, scene):
    """Measure true evaluated mesh paw positions, not empty positions.

    Args:
        mesh (bpy.types.Object): Actual skinned wolf mesh.
        indices (dict): Source mesh vertices belonging to each paw.
        scene (bpy.types.Scene): Animated scene to evaluate.

    Returns:
        dict: Per-frame minimum paw height and horizontal centroid.
    """
    results = {}
    for frame in SAMPLE_FRAMES:
        scene.frame_set(frame)
        dependency_graph = bpy.context.evaluated_depsgraph_get()
        evaluated = mesh.evaluated_get(dependency_graph)
        generated = evaluated.to_mesh()
        try:
            matrix = evaluated.matrix_world
            values = {}
            for label, selected in indices.items():
                if not selected:
                    raise RuntimeError("No weighted vertices: " + label)
                points = [
                    matrix @ generated.vertices[index].co
                    for index in selected
                ]
                values[label] = {
                    "min_z": round(min(point.z for point in points), 6),
                    "mean_y": round(
                        sum(point.y for point in points) / len(points), 6
                    ),
                    "mean_x": round(
                        sum(point.x for point in points) / len(points), 6
                    ),
                }
            results[frame] = values
        finally:
            evaluated.to_mesh_clear()
    return results


def main():
    """Audit animated paw mesh deformation without changing the Blend.

    Args:
        None.

    Returns:
        None: Writes a separate JSON report of sampled paw positions.
    """
    bpy.ops.wm.open_mainfile(filepath=str(SOURCE))
    mesh = bpy.data.objects["Frostfang_Canine_ExperimentalMesh"]
    selected = {
        name: find_paw_indices(mesh, group)
        for name, group in GROUP_NAMES.items()
    }
    readings = sample_paws(mesh, selected, bpy.context.scene)
    report = {
        "status": "Independent actual-mesh audit; gait unapproved",
        "samples": readings,
        "toe_vertex_counts": {
            name: len(vertices) for name, vertices in selected.items()
        },
    }
    destination = ROOT / "actual_paw_mesh_audit.json"
    destination.write_text(
        json.dumps(report, indent=2), encoding="utf-8"
    )
    print("ACTUAL_PAW_MESH_AUDIT", json.dumps(report))


if __name__ == "__main__":
    main()
