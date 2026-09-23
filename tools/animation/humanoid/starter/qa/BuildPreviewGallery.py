"""Create a single offline browser gallery of six Studio-tested R15 GIFs.

The generated HTML only references GIFs in the user's existing local
unpublished QA folder. It never uploads or publishes Roblox assets.
"""

import html
import sys
from pathlib import Path


CLIPS = (
    ("Idle", "2.0 seconds · looping breathing and stance"),
    ("Walk", "1.0 second · in-place walking"),
    ("Run", "0.7 seconds · in-place running"),
    ("Sword", "1.2 seconds · one sword impact"),
    ("Daggers", "1.2 seconds · alternating dagger impacts"),
    ("Bow", "1.5 seconds · draw and arrow-release cue"),
)


def preview_card(name: str, description: str) -> str:
    """Build one labelled animation preview with its own openable GIF.

    Args:
        name (str): Exact source clip and local subdirectory name.
        description (str): Human-readable duration and motion purpose.

    Returns:
        str: One self-contained HTML card with relative local links.
    """
    safe_name = html.escape(name)
    safe_description = html.escape(description)
    relative = f"Play/{name}/DMMO_Humanoid_{name}_UNAPPROVED.gif"
    safe_relative = html.escape(relative, quote=True)
    return (
        '<article class="preview">'
        f"<h2>{safe_name}</h2>"
        f'<a href="{safe_relative}" title="Open full-size GIF">'
        f'<img src="{safe_relative}" alt="{safe_name} animation">'
        "</a>"
        f"<p>{safe_description}</p>"
        "</article>"
    )


def gallery_html() -> str:
    """Render a responsive local review page without external dependencies.

    Args:
        None.

    Returns:
        str: A complete offline HTML document for all six preview GIFs.
    """
    cards = "\n".join(
        preview_card(name, description)
        for name, description in CLIPS
    )
    return f"""<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>DungeonMMO - Humanoid Animation Review</title>
<style>
  body {{font: 16px/1.45 Segoe UI,Arial,sans-serif; margin: 0;
    padding: 1.5rem; color: #e9eef7; background: #161d29;}}
  main {{max-width: 1400px; margin: auto;}}
  h1 {{font-size: 1.8rem; margin-bottom: .35rem;}}
  .note {{color: #bdc9d8; margin-bottom: 1.5rem;}}
  .grid {{display: grid; grid-template-columns:
    repeat(auto-fit, minmax(min(100%, 390px), 1fr)); gap: 1rem;}}
  .preview {{background: #252f41; border: 1px solid #405069;
    border-radius: 12px; padding: 1rem;}}
  .preview h2 {{margin: 0 0 .7rem; font-size: 1.15rem;}}
  .preview img {{display: block; width: 100%; height: auto;
    border-radius: 6px; background: #384b5e;}}
  .preview p {{margin: .7rem 0 0; color: #d0dceb;}}
  a {{color: #aed8ff;}}
</style>
</head>
<body>
<main>
<h1>DungeonMMO - Humanoid Starter Animations</h1>
<p class="note">Six actual unpublished Roblox Studio R15 playback
previews. These are editable test animations, not approved final art.
Click a preview to see its full-size GIF. No network connection is
required to view this local page.</p>
<section class="grid">
{cards}
</section>
<p class="note">Walking and running are in-place tests. The blocky
mannequin, practice weapons, final character foot contacts and combat
integration still require visual approval. Nothing here is published
to the live Roblox game.</p>
</main>
</body>
</html>
"""


def main() -> None:
    """Verify six local GIFs and create one convenient review gallery.

    Args:
        None: The first CLI argument is the existing humanoid QA root.

    Returns:
        None: Writes one offline HTML preview in the supplied root.
    """
    if len(sys.argv) != 2:
        raise SystemExit("Usage: python BuildPreviewGallery.py <qa-root>")
    root = Path(sys.argv[1])
    for name, _ in CLIPS:
        path = root / "Play" / name
        gif = path / f"DMMO_Humanoid_{name}_UNAPPROVED.gif"
        if not gif.is_file():
            raise FileNotFoundError(str(gif))
    output = root / "HumanoidStarter_Review.html"
    output.write_text(gallery_html(), encoding="utf-8")
    print("REVIEW_GALLERY_SAVED", str(output), flush=True)


if __name__ == "__main__":
    main()
