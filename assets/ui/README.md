# DungeonMMO Reference UI Art

This folder stores the source PNGs used by the asset-backed HUD.

The artwork was cropped and cleaned from the approved DungeonMMO UI
reference image so the live Roblox interface can use painted fantasy
chrome rather than approximating the look with only `Frame`,
`UIStroke`, and `UIGradient` instances.

## Roblox assets

- Reference atlas: `rbxassetid://107368787767290`
- Clean modal shell: `rbxassetid://127588383054650`
- Clean popup shell: `rbxassetid://125369844739576`

Runtime region metadata and helper functions live in
`src/ReplicatedStorage/Core/Shared/UiArt.luau`.

## Source files

- `DungeonMMO_Reference_UI_Atlas_Clean.png` contains the reusable atlas
  used by the profile frame, quest journal/tracker, action bar, hotbar
  slots, command buttons, tabs, and dungeon card.
- `generic_window_shell.png` is a cleaned window crop with the original
  journal divider and baked content removed. It is used as a 9-sliced
  background for general modal windows.
- `popup_shell.png` removes the close-button artwork as well and is used
  for non-dismissable status overlays such as Victory and Revive.

Keep live text, bars, cooldowns, quest state, buttons, and other dynamic
content as Roblox GUI objects layered above these images.
