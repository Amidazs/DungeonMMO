"""Audit deformed Frostfang toe geometry during the walk-v7 trial.

Stance is assessed from evaluated vertex positions, not IK target motion.
A numeric check does not replace a multiview animal-anatomy inspection.
"""

import json
from pathlib import Path

import bpy


ROOT = (
    Path.home() / "Documents" / "Roblox" /
    "DungeonMMO_CanineRig_QA" / "Frostfang_20260923" /
    "GroundedWalkTrial_20260923" / "WalkV7_Foreleg"
)
SOURCE = ROOT / "Frostfang_WalkV7_Foreleg_UNAPPROVED.blend"
GROUP_NAMES = {
    "FrontLeft": "DEF_front_toe.L",
    "FrontRight": "DEF_front_toe.R",
    "HindLeft": "DEF_toe.L",
    "HindRight": "DEF_toe.R",
}


def toe_vertices(mesh, group_name):
    """Find vertices strongly influenced by one foot's toe group.

    Args:
        mesh (bpy.types.Object): Weighted original wolf mesh.
        group_name (str): Name of the independent toe group.

    Returns:
        list[int]: Original vertex indices belonging to that paw.
    """
    group = mesh.vertex_groups.get(group_name)
    if group is None:
        raise ValueError("Missing toe group: " + group_name)
    return [
        vertex.index
        for vertex in mesh.data.vertices
        if any(
            item.group == group.index and item.weight >= 0.25
            for item in vertex.groups
        )
    ]


def evaluate_frame(mesh, groups):
    """Measure actual evaluated paw height and horizontal centroids.

    Args:
        mesh (bpy.types.Object): Source mesh with armature deformation.
        groups (dict): Selected original vertex indices for each paw.

    Returns:
        dict: Minimum Z and mean X/Y for each paw.
    """
    graph = bpy.context.evaluated_depsgraph_get()
    evaluated = mesh.evaluated_get(graph)
    generated = evaluated.to_mesh()
    try:
        matrix = evaluated.matrix_world
        result = {}
        for name, indices in groups.items():
            coordinates = [
                matrix @ generated.vertices[index].co
                for index in indices
            ]
            result[name] = {
                "min_z": round(min(p.z for p in coordinates), 6),
                "mean_x": round(
                    sum(p.x for p in coordinates) / len(coordinates), 6
                ),
                "mean_y": round(
                    sum(p.y for p in coordinates) / len(coordinates), 6
                ),
            }
        return result
    finally:
        evaluated.to_mesh_clear()


def group_stance_intervals(manifest, leg_name):
    """Find consecutive frames where one leg is designated planted.

    Args:
        manifest (dict): Authored trial frame classification.
        leg_name (str): Unique leg identifier.

    Returns:
        list[list[int]]: Continuous stance-frame intervals.
    """
    intervals = []
    current = []
    for frame_text, details in manifest["frame_status"].items():
        frame = int(frame_text)
        if details["stance"].get(leg_name):
            current.append(frame)
        elif current:
            intervals.append(current)
            current = []
    if current:
        intervals.append(current)
    return intervals


def summarize_stance(samples, intervals, name):
    """Measure toe drift and floor deviation inside planted intervals.

    Args:
        samples (dict): Evaluated paw positions for each animation frame.
        intervals (list): Consecutive planted frame sequences.
        name (str): Name of the paw to measure.

    Returns:
        list[dict]: Horizontal drift and foot heights for each interval.
    """
    summary = []
    for frames in intervals:
        paw_samples = [samples[frame][name] for frame in frames]
        ys = [p["mean_y"] for p in paw_samples]
        heights = [p["min_z"] for p in paw_samples]
        summary.append({
            "first_frame": frames[0],
            "last_frame": frames[-1],
            "horizontal_drift": round(max(ys) - min(ys), 6),
            "lowest_z": round(min(heights), 6),
            "highest_z": round(max(heights), 6),
        })
    return summary


def main():
    """Save independent paw-mesh audit and provisional gait assessment.

    Args:
        None.

    Returns:
        None: Writes all sampled values and stance errors as JSON.
    """
    bpy.ops.wm.open_mainfile(filepath=str(SOURCE))
    mesh = bpy.data.objects["Frostfang_Canine_ExperimentalMesh"]
    scene = bpy.context.scene
    manifest = json.loads(
        (ROOT.parent / "WalkV3" / "walk_v3_manifest.json").read_text(
            encoding="utf-8"
        )
    )
    groups = {
        name: toe_vertices(mesh, group)
        for name, group in GROUP_NAMES.items()
    }
    samples = {}
    for frame in range(scene.frame_start, scene.frame_end + 1):
        scene.frame_set(frame)
        samples[frame] = evaluate_frame(mesh, groups)
    stance = {
        name: summarize_stance(
            samples, group_stance_intervals(manifest, name), name
        ) for name in groups
    }
    maxima = {
        "largest_stance_drift": round(
            max(
                interval["horizontal_drift"]
                for series in stance.values() for interval in series
            ), 6
        ),
        "largest_stance_height": round(
            max(
                abs(interval["highest_z"])
                for series in stance.values() for interval in series
            ), 6
        ),
        "lowest_stance_height": round(
            min(
                interval["lowest_z"]
                for series in stance.values() for interval in series
            ), 6
        ),
    }
    report = {
        "status": "UNAPPROVED: numeric actual-mesh evaluation",
        "paw_vertex_counts": {
            name: len(indices) for name, indices in groups.items()
        },
        "stance_intervals": stance,
        "summary": maxima,
        "samples": samples,
    }
    destination = ROOT / "walk_v7_actual_mesh_audit.json"
    destination.write_text(
        json.dumps(report, indent=2), encoding="utf-8"
    )
    print("WALK_V7_MESH_SUMMARY", json.dumps(maxima), flush=True)
    print("WALK_V7_STANCE", json.dumps(stance), flush=True)
    print("WALK_V7_AUDIT_SAVED", destination, flush=True)


if __name__ == "__main__":
    main()
