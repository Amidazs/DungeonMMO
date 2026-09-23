"""Calibrate measured Frostfang toe contact in a copied walk trial.

This source is an experimental Blender-only contact correction. It
never alters the original wolf or a published Roblox animation.
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
MANIFEST = ROOT / "WalkV3" / "walk_v3_manifest.json"
OUTPUT = ROOT / "WalkV4"
MAX_ITERATIONS = 6
CORRECTION_GAIN = 0.7
MAX_CORRECTION = 0.025
HEIGHT_TOLERANCE = 0.003
DRIFT_TOLERANCE = 0.004


def find_vertices(mesh, group_name):
    """Find original mesh vertices weighted to a particular toe.

    Args:
        mesh (bpy.types.Object): Weighted Frostfang mesh.
        group_name (str): Exact Blender toe bone group.

    Returns:
        list[int]: Source-space vertex indices for the measured toe.
    """
    group = mesh.vertex_groups.get(group_name)
    if group is None:
        raise RuntimeError("Missing toe group: " + group_name)
    return [
        vertex.index
        for vertex in mesh.data.vertices
        if any(
            influence.group == group.index and influence.weight >= 0.25
            for influence in vertex.groups
        )
    ]


def sample_mesh(mesh, selected):
    """Read evaluated toe centroids and lowest actual skinned vertices.

    Args:
        mesh (bpy.types.Object): Animated source skinned mesh.
        selected (dict): Selected original indices by leg name.

    Returns:
        dict: Current-frame horizontal centroid and minimum foot height.
    """
    graph = bpy.context.evaluated_depsgraph_get()
    evaluated = mesh.evaluated_get(graph)
    result_mesh = evaluated.to_mesh()
    try:
        matrix = evaluated.matrix_world
        measurements = {}
        for name, indices in selected.items():
            points = [
                matrix @ result_mesh.vertices[index].co
                for index in indices
            ]
            measurements[name] = {
                "y": sum(point.y for point in points) / len(points),
                "min_z": min(point.z for point in points),
            }
        return measurements
    finally:
        evaluated.to_mesh_clear()


def build_records(mesh, manifest):
    """Connect four source toe groups to their keyed Blender IK targets.

    Args:
        mesh (bpy.types.Object): Experimental Frostfang source mesh.
        manifest (dict): Walking phase and toe-mapping information.

    Returns:
        dict: Paw target objects and measured toe vertex subsets.
    """
    records = {}
    for item in manifest["legs"]:
        label = item["label"]
        target = bpy.data.objects.get("DMMO_WalkV3_" + label)
        if target is None:
            raise RuntimeError("Missing existing IK target: " + label)
        records[label] = {
            "target": target,
            "indices": find_vertices(mesh, item["toe_group"]),
            "stance_anchor": None,
        }
    return records


def target_adjustment(target, frame, y_error, z_error):
    """Apply bounded world-space corrections to one keyed paw target.

    Args:
        target (bpy.types.Object): Independent ankle target empty.
        frame (int): Current sample in the animation.
        y_error (float): Desired horizontal correction at the toe.
        z_error (float): Desired vertical correction at the toe.

    Returns:
        None: Updates this frame's editable target location key.
    """
    target.location.y += max(
        -MAX_CORRECTION,
        min(MAX_CORRECTION, y_error * CORRECTION_GAIN),
    )
    target.location.z += max(
        -MAX_CORRECTION,
        min(MAX_CORRECTION, z_error * CORRECTION_GAIN),
    )
    target.keyframe_insert(data_path="location", frame=frame)


def active_stance(manifest, frame, records):
    """Identify planted legs from the already authored gait schedule.

    Args:
        manifest (dict): Walk-v3 frame-by-frame support metadata.
        frame (int): Current frame.
        records (dict): Four independent paw control records.

    Returns:
        list[str]: Leg names in their designated contact interval.
    """
    statuses = manifest["frame_status"][str(frame)]["stance"]
    return [name for name in records if statuses[name]]


def calibrate_frame(frame, scene, mesh, records, manifest):
    """Iteratively fit planted mesh toe points to fixed world targets.

    Args:
        frame (int): One-based animation frame.
        scene (bpy.types.Scene): Active Blender animation scene.
        mesh (bpy.types.Object): Actual skinned source mesh.
        records (dict): Paw controls, vertex subsets and stance anchors.
        manifest (dict): Support metadata from the original authoring.

    Returns:
        dict: Current planted paw errors after adjustment.
    """
    scene.frame_set(frame)
    stance = active_stance(manifest, frame, records)
    selected = {
        name: record["indices"] for name, record in records.items()
    }
    if not stance:
        for record in records.values():
            record["stance_anchor"] = None
        return {}
    initial = sample_mesh(mesh, selected)
    for name, record in records.items():
        if name not in stance:
            record["stance_anchor"] = None
        elif record["stance_anchor"] is None:
            record["stance_anchor"] = initial[name]["y"]
    for _ in range(MAX_ITERATIONS):
        measured = sample_mesh(mesh, selected)
        for name in stance:
            record = records[name]
            target_adjustment(
                record["target"], frame,
                record["stance_anchor"] - measured[name]["y"],
                -measured[name]["min_z"],
            )
        bpy.context.view_layer.update()
    final = sample_mesh(mesh, selected)
    result = {}
    for name in stance:
        anchor = records[name]["stance_anchor"]
        result[name] = {
            "horizontal_error": round(
                final[name]["y"] - anchor, 6
            ),
            "floor_error": round(final[name]["min_z"], 6),
        }
    return result


def calibrate_all(scene, mesh, records, manifest):
    """Fit the four stance paw paths in chronological keyframe order.

    Args:
        scene (bpy.types.Scene): The current source animation scene.
        mesh (bpy.types.Object): The original weighted wolf geometry.
        records (dict): Per-leg target and toe group information.
        manifest (dict): Pre-existing support classification.

    Returns:
        dict: Final per-frame residual error for planted paws.
    """
    diagnostics = {}
    for frame in range(scene.frame_start, scene.frame_end + 1):
        diagnostics[frame] = calibrate_frame(
            frame, scene, mesh, records, manifest
        )
    scene.frame_set(scene.frame_start)
    return diagnostics


def main():
    """Save a separate contact-corrected Blend and residual diagnostic.

    Args:
        None.

    Returns:
        None: Produces new working files without changing the source.
    """
    OUTPUT.mkdir(parents=True, exist_ok=True)
    bpy.ops.wm.open_mainfile(filepath=str(SOURCE))
    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    mesh = bpy.data.objects["Frostfang_Canine_ExperimentalMesh"]
    records = build_records(mesh, manifest)
    diagnostics = calibrate_all(
        bpy.context.scene, mesh, records, manifest
    )
    report = {
        "status": "UNAPPROVED: frame-keyed IK mesh contact experiment",
        "horizontal_tolerance": DRIFT_TOLERANCE,
        "height_tolerance": HEIGHT_TOLERANCE,
        "residuals": diagnostics,
        "notes": [
            "Skin weights and hind-leg geometry remain unapproved.",
            "A numeric toe-height test does not prove natural anatomy.",
            "No Roblox Studio animation import or gameplay integration.",
        ],
    }
    saved = OUTPUT / "Frostfang_WalkV4_IK_UNAPPROVED.blend"
    bpy.ops.wm.save_as_mainfile(filepath=str(saved))
    (OUTPUT / "walk_v4_contact_residuals.json").write_text(
        json.dumps(report, indent=2), encoding="utf-8"
    )
    print("WALK_V4_SAVED", saved, flush=True)
    print("WALK_V4_RESIDUALS", json.dumps(diagnostics), flush=True)


if __name__ == "__main__":
    main()
