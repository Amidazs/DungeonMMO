"""
Create an EDITOR-ONLY Roblox place from the Studio-generated placeholder scene.

Usage:
    python scripts/tools/build_placeholder_rbxlx.py <studio-log> <output.rbxlx>

The input must be a fresh log from
scripts/studio/phase4_placeholder_export_geometry.luau.
The exporter reads the ACTUAL Luau-built parts, so this Python tool does
not duplicate physical layout measurements. Rojo is needed for the empty
XML place template; no live Roblox API, account or publishing is involved.

The resulting scene is an editable static reference for replacing Models.
Do not publish it as a playable game: its semantic anchor attributes/tags
are intentionally not serialized. Actual runtime anchors are created by
DungeonPlaceholderPhysicalContent.luau in an explicitly opted-in Studio test.
"""

import argparse
import json
from pathlib import Path
import subprocess
import tempfile
import xml.etree.ElementTree as ET


PREFIX = "[Phase4 Geometry Export] RECORD "
END = "[Phase4 Geometry Export] PASS "


def records_from_log(path: Path) -> list[dict]:
    text = path.read_text(encoding="utf-8", errors="replace")
    if END not in text:
        raise ValueError("Studio did not report a complete geometry export")
    entries = [
        json.loads(line.split(PREFIX, 1)[1])
        for line in text.splitlines()
        if PREFIX in line
    ]
    if len(entries) < 300:
        raise ValueError(f"Expected both complete dungeon scenes; got {len(entries)}")
    seen = set()
    for entry in entries:
        path = entry["Path"]
        if path in seen:
            raise ValueError(f"Duplicate geometry path: {path}")
        seen.add(path)
    if not {"TestDungeon", "AbandonedMine"} <= seen:
        raise ValueError("Missing Temple or Mine scene")
    return entries


def add_property(parent: ET.Element, kind: str, name: str, value: object):
    ET.SubElement(parent, kind, {"name": name}).text = str(value)


def add_bool(parent: ET.Element, name: str, value: bool):
    add_property(parent, "bool", name, "true" if value else "false")


def add_vector(parent: ET.Element, kind: str, name: str, values):
    value = ET.SubElement(parent, kind, {"name": name})
    for key, component in zip(("X", "Y", "Z"), values):
        ET.SubElement(value, key).text = format(float(component), ".17g")


def part_properties(parent: ET.Element, record: dict):
    add_bool(parent, "Anchored", record["Anchored"])
    add_bool(parent, "CanCollide", record["CanCollide"])
    add_bool(parent, "CanTouch", record["CanTouch"])
    add_bool(parent, "CanQuery", record["CanQuery"])
    add_bool(parent, "CastShadow", record["CastShadow"])
    add_property(parent, "float", "Transparency",
                 format(float(record["Transparency"]), ".9g"))
    add_property(parent, "token", "Material", int(record["Material"]))
    add_vector(parent, "Vector3", "Size", record["Size"])
    add_vector(parent, "Color3", "Color", record["Color"])
    frame = ET.SubElement(parent, "CoordinateFrame", {"name": "CFrame"})
    components = record["PositionRotation"]
    if len(components) != 12:
        raise ValueError(f"Invalid CFrame for {record['Path']}")
    fields = (
        "X", "Y", "Z", "R00", "R01", "R02", "R10", "R11", "R12",
        "R20", "R21", "R22",
    )
    for key, component in zip(fields, components):
        ET.SubElement(frame, key).text = format(float(component), ".17g")


def empty_place() -> ET.ElementTree:
    with tempfile.TemporaryDirectory(prefix="DungeonMMO_PreviewRojo_") as folder:
        project = Path(folder) / "preview.project.json"
        place = Path(folder) / "empty.rbxlx"
        project.write_text(json.dumps({
            "name": "DungeonMMO_PhysicalPlaceholderPreview",
            "tree": {
                "$className": "DataModel",
                "Workspace": {"$className": "Workspace"},
            },
        }), encoding="utf-8")
        subprocess.run(
            ["rojo", "build", str(project), "-o", str(place)],
            check=True, capture_output=True, text=True,
        )
        return ET.parse(place)


def build_place(entries: list[dict]) -> ET.ElementTree:
    tree = empty_place()
    workspace = next(
        node for node in tree.getroot().iter("Item")
        if node.get("class") == "Workspace"
    )
    nodes = {"": workspace}
    for index, entry in enumerate(entries, start=10000):
        path = entry["Path"]
        kind = entry["ClassName"]
        if kind not in {"Folder", "Model", "Part"}:
            raise ValueError(f"Unexpected geometry class {kind}: {path}")
        parent_path = path.rsplit("/", 1)[0] if "/" in path else ""
        if parent_path not in nodes:
            raise ValueError(f"Child before parent: {path}")
        item = ET.SubElement(
            nodes[parent_path], "Item",
            {"class": kind, "referent": str(index)},
        )
        props = ET.SubElement(item, "Properties")
        add_property(props, "string", "Name", path.split("/")[-1])
        if kind == "Model":
            add_bool(props, "NeedsPivotMigration", False)
        elif kind == "Part":
            part_properties(props, entry)
        nodes[path] = item
    return tree


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("studio_log", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    if args.output.suffix.lower() != ".rbxlx":
        parser.error("Output must be an editor-only local .rbxlx file")
    entries = records_from_log(args.studio_log)
    tree = build_place(entries)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    tree.write(args.output, encoding="utf-8", xml_declaration=True)
    parsed = ET.parse(args.output)
    counts = {}
    for node in parsed.getroot().iter("Item"):
        kind = node.get("class")
        counts[kind] = counts.get(kind, 0) + 1
    expected_parts = sum(e["ClassName"] == "Part" for e in entries)
    if counts.get("Part") != expected_parts:
        raise ValueError("Written preview lost physical parts")
    print(f"PLACEHOLDER_RBXLX_CREATED {args.output}")
    print(f"EXPORTED_RECORDS {len(entries)} PARTS {expected_parts}")
    print(f"PLACEHOLDER_BYTES {args.output.stat().st_size}")
    print("EDITOR_PREVIEW_ONLY_NO_PUBLISH_OR_LAYOUT_REGISTRATION")


if __name__ == "__main__":
    main()
