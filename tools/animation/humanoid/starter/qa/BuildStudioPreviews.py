"""Build six real-Studio-preview GIFs from captured R15 test frames.

All inputs and outputs stay in the user's local unpublished QA folder.
This utility never publishes Roblox assets or changes a game place.
"""

import json
import sys
from pathlib import Path

from PIL import Image


CLIP_DURATIONS = {
    "Idle": 2.0,
    "Walk": 1.0,
    "Run": 0.7,
    "Sword": 1.2,
    "Daggers": 1.2,
    "Bow": 1.5,
}
EXPECTED_FRAMES = 12


def load_frames(folder: Path, clip: str) -> list[Image.Image]:
    """Load the exact full-motion screenshots from a tested clip.

    Args:
        folder (Path): The named clip's local source-frame directory.
        clip (str): One of the six approved starter clip identifiers.

    Returns:
        list[Image.Image]: Optimized GIF-ready copies of Studio frames.
    """
    images = []
    for index in range(EXPECTED_FRAMES):
        image_path = folder / f"{clip}_{index:02d}.jpg"
        if not image_path.is_file():
            raise FileNotFoundError(str(image_path))
        with Image.open(image_path) as source:
            image = source.convert("RGB")
            images.append(
                image.convert(
                    "P",
                    palette=Image.Palette.ADAPTIVE,
                    colors=128,
                )
            )
    return images


def save_gif(folder: Path, clip: str) -> dict:
    """Assemble a looping preview at the recorded clip's true cadence.

    Args:
        folder (Path): Input frames and destination for the new GIF.
        clip (str): Named motion and source-timeline duration.

    Returns:
        dict: Filename, duration, size and recorded-frame provenance.
    """
    images = load_frames(folder, clip)
    filename = folder / f"DMMO_Humanoid_{clip}_UNAPPROVED.gif"
    milliseconds = round(
        1000 * CLIP_DURATIONS[clip] / EXPECTED_FRAMES
    )
    images[0].save(
        filename,
        save_all=True,
        append_images=images[1:],
        duration=milliseconds,
        loop=0,
        optimize=True,
        disposal=2,
    )
    with Image.open(filename) as output:
        if output.n_frames != EXPECTED_FRAMES:
            raise RuntimeError("Saved preview frame count does not match")
        actual_frames = output.n_frames
        actual_size = output.size
    return {
        "clip": clip,
        "file": str(filename),
        "frames": actual_frames,
        "dimensions": list(actual_size),
        "duration_seconds": CLIP_DURATIONS[clip],
        "bytes": filename.stat().st_size,
        "status": "UNAPPROVED: requires user visual inspection",
    }


def main() -> None:
    """Convert all six real Studio captures into editable review outputs.

    Args:
        None: The first CLI argument is the existing Play QA folder.

    Returns:
        None: Saves six GIFs and a summarized QA manifest.
    """
    if len(sys.argv) != 2:
        raise SystemExit("Usage: python BuildStudioPreviews.py <play-qa-dir>")
    base = Path(sys.argv[1])
    if not base.is_dir():
        raise FileNotFoundError(str(base))
    records = []
    for clip in CLIP_DURATIONS:
        record = save_gif(base / clip, clip)
        records.append(record)
        print("PREVIEW_VERIFIED", clip, record["bytes"], flush=True)
    output = base / "humanoid_starter_preview_manifest.json"
    output.write_text(
        json.dumps(records, indent=2), encoding="utf-8"
    )
    print("SIX_PREVIEWS_COMPLETE", str(output), flush=True)


if __name__ == "__main__":
    main()
