"""Audit motion test's mesh grounding and reversible editable action."""

from pathlib import Path
import json
import math

import bpy


ROOT = (
    Path.home() / "Documents" / "Roblox" /
    "DungeonMMO_CanineRig_QA" / "Frostfang_20260923" /
    "MotionPreview_20260923"
)
PAWS = {
    "front_left": (0.086, -0.44),
    "front_right": (-0.148, -0.44),
    "hind_left": (0.078, 0.28),
    "hind_right": (-0.23, 0.235),
}


def mesh_positions(mesh, indices):
    """Return evaluated positions for selected original mesh vertices.

    Args:
        mesh (bpy.types.Object): Mesh with animated armature modifier.
        indices (list): Fixed vertex indices from its rest geometry.

    Returns:
        list: Evaluated world-space vertex positions.
    """
    graph = bpy.context.evaluated_depsgraph_get()
    evaluated = mesh.evaluated_get(graph)
    temp = evaluated.to_mesh()
    matrix = evaluated.matrix_world
    result = [matrix @ temp.vertices[index].co for index in indices]
    evaluated.to_mesh_clear()
    return result


def main():
    """Save honest QA metrics for the in-place wolf motion demonstration.

    Args:
        None.

    Returns:
        None: Writes JSON diagnostic report without changing master files.
    """
    bpy.ops.wm.open_mainfile(
        filepath=str(ROOT / "Frostfang_Motion_QA_UNAPPROVED.blend")
    )
    mesh = bpy.data.objects["Frostfang_Canine_ExperimentalMesh"]
    rig = bpy.data.objects["Frostfang_Canine_CompactRig"]
    action = rig.animation_data.action
    assert action is not None
    assert "UNAPPROVED" in action.name
    neutral_mesh = [
        mesh.matrix_world @ vertex.co for vertex in mesh.data.vertices
    ]
    choices = {}
    for label, (x, y) in PAWS.items():
        picks = [
            vertex.index for vertex in mesh.data.vertices
            if (
                abs(neutral_mesh[vertex.index].x - x) < .08
                and abs(neutral_mesh[vertex.index].y - y) < .12
                and neutral_mesh[vertex.index].z < .12
            )
        ]
        if not picks:
            raise RuntimeError("No paw geometry found for " + label)
        choices[label] = picks
    scene = bpy.context.scene
    report = {
        "action": action.name,
        "source": str(ROOT / "Frostfang_Motion_QA_UNAPPROVED.blend"),
        "fps": scene.render.fps,
        "start": scene.frame_start,
        "end": scene.frame_end,
        "samples": {},
    }
    for frame in (1, 9, 17, 25, 33, 41, 49, 55, 63, 64):
        scene.frame_set(frame)
        paw_result = {}
        for label, indices in choices.items():
            positions = mesh_positions(mesh, indices)
            paw_result[label] = {
                "lowest_z": round(min(p.z for p in positions), 4),
                "highest_z": round(max(p.z for p in positions), 4),
                "mean_y": round(
                    sum(p.y for p in positions) / len(positions), 4
                ),
                "vertices": len(indices),
            }
        report["samples"][str(frame)] = paw_result
    first = report["samples"]["1"]
    last = report["samples"]["64"]
    report["rest_end_paw_error_max_z"] = max(
        abs(first[label]["lowest_z"] - last[label]["lowest_z"])
        for label in PAWS
    )
    report["unapproved_reason"] = (
        "Paw swing shows drift/ground-contact mismatch; no "
        "world-locked planted phase, and the source jaw is closed."
    )
    output = ROOT / "motion_qa_report.json"
    output.write_text(json.dumps(report, indent=2), encoding="utf-8")
    print("QA_ACTION", action.name)
    print("QA_FRAMES", scene.frame_start, scene.frame_end)
    print("QA_REST_END", report["rest_end_paw_error_max_z"])
    for frame, value in report["samples"].items():
        print(
            "QA_FRAME", frame,
            {label: entry["lowest_z"] for label, entry in value.items()}
        )
    print("QA_REPORT", output)


if __name__ == "__main__":
    main()
