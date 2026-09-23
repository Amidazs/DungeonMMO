"""Encode genuine Blender-rendered Frostfang engine poses as a GIF.

Run with a regular Python installation that has Pillow installed.
Blender renders are produced by render_engine_walk_demo.py.
"""

from pathlib import Path

from PIL import Image, ImageDraw


ENGINE_ROOT = (
    Path.home() / "Documents" / "Roblox" /
    "DungeonMMO_Quadruped_AnimationEngine"
)
OUTPUT = ENGINE_ROOT / "qa" / "Frostfang_Engine_Demo"
FRAMES = tuple(range(1, 61, 3))
FRAME_DURATION_MS = 100


def load_frame(frame_number):
    """Open one authentic Blender-rendered frame of the engine clip.

    Args:
        frame_number (int): One-based animation frame in the source.

    Returns:
        Image.Image: Reduced-size indexed-color demonstration frame.
    """
    path = OUTPUT / f"Frostfang_Engine_Walk_{frame_number:03d}.png"
    if not path.exists():
        raise FileNotFoundError(path)
    with Image.open(path) as original:
        frame = original.convert("RGB")
    frame.thumbnail((368, 240))
    draw = ImageDraw.Draw(frame)
    draw.text(
        (7, 7), "FROSTFANG / ENGINE WALK / QA ONLY",
        fill=(255, 255, 255),
    )
    return frame.quantize(colors=48)


def save_preview(frames):
    """Encode and verify the real-mesh engine animation as a looped GIF.

    Args:
        frames (list[Image.Image]): Ordered Blender animation frames.

    Returns:
        tuple: Saved path, playback frame count and total duration.
    """
    path = OUTPUT / "Frostfang_Engine_Walk_QA.gif"
    frames[0].save(
        path,
        save_all=True,
        append_images=frames[1:],
        duration=FRAME_DURATION_MS,
        loop=0,
        optimize=True,
        disposal=2,
    )
    with Image.open(path) as saved:
        duration_ms = 0
        for index in range(saved.n_frames):
            saved.seek(index)
            duration_ms += saved.info.get("duration", 0)
        return path, saved.n_frames, duration_ms


def main():
    """Turn recorded engine-generated mesh renders into a reviewable GIF.

    Args:
        None.

    Returns:
        None: Writes a looped QA GIF and prints its verified metadata.
    """
    images = [load_frame(number) for number in FRAMES]
    path, count, duration_ms = save_preview(images)
    if count < 5 or duration_ms < 1000:
        raise RuntimeError("Preview has insufficient animation frames")
    print("ENGINE_GIF_SAVED", path)
    print("ENGINE_GIF_FRAMES", count)
    print("ENGINE_GIF_DURATION_MS", duration_ms)
    print("ENGINE_GIF_BYTES", path.stat().st_size)


if __name__ == "__main__":
    main()
