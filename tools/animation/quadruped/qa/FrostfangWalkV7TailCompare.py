"""Compare original and hindleg-isolated tail fur during WalkV7.

Reads two existing experimental Blends and writes only a JSON QA report.
"""

import json
from pathlib import Path

import bpy


ROOT = (
    Path.home() / "Documents" / "Roblox" /
    "DungeonMMO_CanineRig_QA" / "Frostfang_20260923" /
    "GroundedWalkTrial_20260923"
)
SOURCE = ROOT / "WalkV7_Foreleg" / (
    "Frostfang_WalkV7_Foreleg_UNAPPROVED.blend"
)
REPAIRED = ROOT / "WalkV7_TailIsolation" / (
    "Frostfang_WalkV7_Tail_UNAPPROVED.blend"
)
REPORT = ROOT / "WalkV7_TailIsolation" / "tail_shape_comparison.json"
FRAMES = (1, 17, 21, 25, 29, 33, 41, 45, 53, 57, 65, 72)
TAIL_NAMES = (
    "DEF_spine.004", "DEF_spine.003", "DEF_spine.002",
    "DEF_spine.001", "DEF_spine",
)
HIND_NAMES = (
    "DEF_thigh.L", "DEF_thigh.R",
    "DEF_shin.L", "DEF_shin.R",
)


def selected_vertices(mesh):
    """Select precisely the same original tail-hind skin overlap.

    Args:
        mesh (bpy.types.Object): Original Frostfang mesh.

    Returns:
        list[int]: Stable source vertex indices for paired comparison.
    """
    tail = {mesh.vertex_groups[name].index for name in TAIL_NAMES}
    hind = {mesh.vertex_groups[name].index for name in HIND_NAMES}
    indices = []
    for vertex in mesh.data.vertices:
        if vertex.co.y <= 0.40:
            continue
        tail_weight = sum(
            item.weight for item in vertex.groups if item.group in tail
        )
        has_hind = any(
            item.weight > 0 and item.group in hind
            for item in vertex.groups
        )
        if tail_weight >= 0.6 and has_hind:
            indices.append(vertex.index)
    return indices


def sampled_positions(mesh, rig, indices):
    """Read evaluated fur locations in rig-local coordinates.

    Args:
        mesh (bpy.types.Object): Animated actual surface.
        rig (bpy.types.Object): Moving master armature.
        indices (list[int]): Identical source vertex IDs in both files.

    Returns:
        list[mathutils.Vector]: Animated vertices without root translation.
    """
    graph = bpy.context.evaluated_depsgraph_get()
    evaluated = mesh.evaluated_get(graph)
    temporary = evaluated.to_mesh()
    try:
        transform = rig.matrix_world.inverted() @ evaluated.matrix_world
        return [
            transform @ temporary.vertices[index].co
            for index in indices
        ]
    finally:
        evaluated.to_mesh_clear()


def sample_blend(path, indices=None):
    """Measure matching original fur through actual animated mesh poses.

    Args:
        path (Path): Unmodified source or new isolation candidate.
        indices (list[int] | None): Fixed vertex IDs from the source.

    Returns:
        tuple: Selected indices and per-frame evaluated vertex positions.
    """
    bpy.ops.wm.open_mainfile(filepath=str(path))
    mesh = bpy.data.objects["Frostfang_Canine_ExperimentalMesh"]
    rig = bpy.data.objects["Frostfang_Canine_CompactRig"]
    if indices is None:
        indices = selected_vertices(mesh)
    scene = bpy.context.scene
    samples = {}
    for frame in FRAMES:
        scene.frame_set(frame)
        samples[frame] = sampled_positions(mesh, rig, indices)
    return indices, samples


def summarize(samples):
    """Measure displacement from the exact same model's starting pose.

    Args:
        samples (dict): Rig-local fur samples indexed by animation frame.

    Returns:
        dict: Per-frame maximum/mean motion of selected original vertices.
    """
    rest = samples[1]
    summary = {}
    for frame, positions in samples.items():
        distances = [
            (point - rest[index]).length
            for index, point in enumerate(positions)
        ]
        summary[str(frame)] = {
            "mean_displacement": round(
                sum(distances) / len(distances), 7
            ),
            "maximum_displacement": round(max(distances), 7),
        }
    return summary


def main():
    """Persist paired source-vs-isolated-fur measurements for real QA.

    Args:
        None.

    Returns:
        None: Saves report and prints compact displacement comparison.
    """
    if not SOURCE.is_file() or not REPAIRED.is_file():
        raise FileNotFoundError("Expected both original and candidate")
    indices, original = sample_blend(SOURCE)
    if len(indices) < 10:
        raise RuntimeError("Insufficient overlapping fur for comparison")
    _, fixed = sample_blend(REPAIRED, indices)
    rest_error = max(
        (original[1][i] - fixed[1][i]).length
        for i in range(len(indices))
    )
    report = {
        "selected_vertices": len(indices),
        "rest_max_source_units": round(rest_error, 9),
        "source": summarize(original),
        "isolated": summarize(fixed),
        "status": "UNAPPROVED: not a visual or Studio gait acceptance",
    }
    REPORT.write_text(json.dumps(report, indent=2), encoding="utf-8")
    print("WALK_V7_TAIL_COMPARE", json.dumps(report), flush=True)


if __name__ == "__main__":
    main()
