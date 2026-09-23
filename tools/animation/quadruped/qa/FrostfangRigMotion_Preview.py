"""Package actual Blender-rig playback into two-view GIF and key poses."""

from pathlib import Path
import json

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parent
FIRST_FRAME = 1
LAST_FRAME = 63
FRAME_STEP = 2
FRAME_DURATION_MS = 125
CROP = (77, 65, 703, 460)
PANEL_SIZE = (626, 395)
TITLE_HEIGHT = 69
BOTTOM_HEIGHT = 38
BACKGROUND = (20, 23, 27)


def label_font(size):
    """Use a bundled operating-system font, not a redistributed font.

    Args:
        size (int): Text size in pixels.

    Returns:
        ImageFont.FreeTypeFont: Local font for the preview overlay.
    """
    for path in (
        "C:/Windows/Fonts/arialbd.ttf",
        "C:/Windows/Fonts/arial.ttf",
    ):
        if Path(path).is_file():
            return ImageFont.truetype(path, size)
    return ImageFont.load_default()


def title_for_frame(frame):
    """Describe the actual phase without claiming a complete walk or bite.

    Args:
        frame (int): Current generated action frame.

    Returns:
        str: Honest QA section label.
    """
    if frame < 7:
        return "NEUTRAL REST / START"
    if frame < 42:
        return "PROVISIONAL FOUR-LEG CYCLE (IN PLACE)"
    if frame < 47:
        return "TRANSITION BACK TO REST"
    if frame <= 59:
        return "FOREPAW + HEAD / JAW MOVEMENT TEST"
    return "REST POSE"


def make_frame(frame):
    """Draw both true mesh-rendered views of the same animation frame.

    Args:
        frame (int): Odd frame number on the Blender QA action timeline.

    Returns:
        Image.Image: Two synchronized camera views and explanatory labels.
    """
    width = PANEL_SIZE[0] * 2
    height = PANEL_SIZE[1] + TITLE_HEIGHT + BOTTOM_HEIGHT
    output = Image.new("RGB", (width, height), BACKGROUND)
    front = Image.open(ROOT / f"wolf_{frame:03d}.png").convert("RGB")
    side = Image.open(ROOT / f"wolf_side_{frame:03d}.png").convert("RGB")
    output.paste(front.crop(CROP), (0, TITLE_HEIGHT))
    output.paste(side.crop(CROP), (PANEL_SIZE[0], TITLE_HEIGHT))
    draw = ImageDraw.Draw(output)
    draw.text((14, 7), "FROSTFANG  |  ACTUAL WEIGHTED-RIG QA",
              font=label_font(22), fill=(238, 243, 248))
    draw.text((14, 39), title_for_frame(frame),
              font=label_font(17), fill=(255, 196, 114))
    draw.text((PANEL_SIZE[0] + 14, 39),
              "SIDE VIEW", font=label_font(17),
              fill=(167, 213, 248))
    draw.text((14, height - 30),
              "Not a finished walk: paw grounding, shoulder & jaw still need repair.",
              font=label_font(15), fill=(239, 222, 205))
    return output


def main():
    """Write GIF, still-sheet, and a QA manifest with real file paths.

    Args:
        None.

    Returns:
        None: Creates an animated preview from the skinned action.
    """
    frames = [
        make_frame(frame)
        for frame in range(FIRST_FRAME, LAST_FRAME + 1, FRAME_STEP)
    ]
    gif = ROOT / "Frostfang_RigMotion_QA.gif"
    palette = [
        frame.quantize(colors=96, method=Image.Quantize.FASTOCTREE)
        for frame in frames
    ]
    palette[0].save(
        gif,
        save_all=True,
        append_images=palette[1:],
        loop=0,
        duration=[FRAME_DURATION_MS] * len(palette),
        optimize=True,
        disposal=2,
    )
    picks = [1, 9, 17, 29, 49, 55]
    columns = 2
    rows = 3
    sheet = Image.new(
        "RGB",
        (frames[0].width * columns, frames[0].height * rows),
        BACKGROUND,
    )
    for index, frame in enumerate(picks):
        sheet.paste(
            make_frame(frame),
            ((index % columns) * frames[0].width,
             (index // columns) * frames[0].height),
        )
    still = ROOT / "Frostfang_RigMotion_KeyPoses.png"
    sheet.save(still)
    report_path = ROOT / "preview_manifest.json"
    report = json.loads(report_path.read_text(encoding="utf-8"))
    report["actual_gif"] = str(gif)
    report["actual_pose_sheet"] = str(still)
    report["preview_frames"] = len(frames)
    report["gif_duration_seconds"] = (
        len(frames) * FRAME_DURATION_MS / 1000
    )
    report_path.write_text(
        json.dumps(report, indent=2), encoding="utf-8"
    )
    print("GIF", gif, "BYTES", gif.stat().st_size)
    print("KEYPOSES", still, "BYTES", still.stat().st_size)
    print("FRAMES", len(frames))
    with Image.open(gif) as image:
        print("GIF_OPEN_VERIFIED", image.n_frames, image.size)


if __name__ == "__main__":
    main()
