"""Assemble the real-mesh Frostfang walk-v3 QA renders into a GIF.

This is an unapproved animation preview, not a Roblox animation export.
Pillow is used only to combine existing Blender-rendered source images.
"""

from pathlib import Path

from PIL import Image, ImageDraw


ROOT = (
    Path.home() / "Documents" / "Roblox" /
    "DungeonMMO_CanineRig_QA" / "Frostfang_20260923" /
    "GroundedWalkTrial_20260923" / "WalkV3" / "preview" / "full"
)
FRAMES = tuple(range(1, 73, 2)) + (72,)
FRAME_DURATION_MS = 83
OUTPUT = ROOT.parent / "Frostfang_WalkV3_Review_UNAPPROVED.gif"


def render_path(view, frame):
    """Locate the saved source-mesh preview frame by its exact name.

    Args:
        view (str): Original Blender camera label.
        frame (int): One-based animation frame.

    Returns:
        Path: Existing PNG preview path.

    Raises:
        FileNotFoundError: If the full render set is incomplete.
    """
    destination = ROOT / f"Frostfang_WalkV3_{view}_{frame:03d}.png"
    if not destination.is_file():
        raise FileNotFoundError(destination)
    return destination


def load_rgb(path):
    """Open and detach one Blender-rendered RGB source image.

    Args:
        path (Path): Existing source-mesh PNG.

    Returns:
        Image.Image: Standalone RGB image.
    """
    with Image.open(path) as source:
        return source.convert("RGB")


def make_frame(frame):
    """Place synchronized side and three-quarter rendered wolf views.

    Args:
        frame (int): Blender animation frame to display.

    Returns:
        Image.Image: Quantized two-camera GIF frame.
    """
    side = load_rgb(render_path("side", frame))
    oblique = load_rgb(render_path("three_quarter", frame))
    combined = Image.new(
        "RGB", (side.width + oblique.width, side.height),
        (28, 28, 28),
    )
    combined.paste(side, (0, 0))
    combined.paste(oblique, (side.width, 0))
    draw = ImageDraw.Draw(combined)
    draw.text(
        (10, 8), "FROSTFANG / WALK V3 / UNAPPROVED QA",
        fill=(235, 235, 235),
    )
    return combined.quantize(colors=128)


def save_gif(frames):
    """Write and reopen the editable experimental two-view GIF.

    Args:
        frames (list[Image.Image]): Ordered synchronized review frames.

    Returns:
        tuple: Output filename, byte size and verified frame count.
    """
    first, *remaining = frames
    first.save(
        OUTPUT,
        save_all=True,
        append_images=remaining,
        duration=FRAME_DURATION_MS,
        loop=0,
        optimize=True,
        disposal=2,
    )
    with Image.open(OUTPUT) as verified:
        count = verified.n_frames
    return str(OUTPUT), OUTPUT.stat().st_size, count


def main():
    """Compile independent source-mesh animation frames for visual QA.

    Args:
        None.

    Returns:
        None: Saves one locally viewable, unapproved motion preview.
    """
    frames = [make_frame(frame) for frame in FRAMES]
    destination, size, verified_count = save_gif(frames)
    if verified_count != len(FRAMES):
        raise RuntimeError(
            f"Expected {len(FRAMES)} frames, found {verified_count}"
        )
    print("WALK_V3_GIF_SAVED", destination, size, verified_count)


if __name__ == "__main__":
    main()
