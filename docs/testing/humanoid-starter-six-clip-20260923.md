# Humanoid starter pack — isolated Studio authoring and replay acceptance

Date: 23 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Game: **unpublished Place1, `PlaceId == 0`, test-only R15 model**.
Current separate gameplay roadmap during closeout: v2.04. This
animation checkpoint does **not** change the gameplay roadmap,
production game, published Roblox assets, combat damage, or main.

## Source, target and compatibility

The old `DMMO_Astra_Guardian_Test` was not present in the connected
Place1. Rather than modify the source guardian or the separate open
production test sessions, the GitHub setup was extended to build a
new `Workspace.DMMO_Humanoid_Starter_Test` using Roblox's built-in
R15 HumanoidDescription when the original marked guardian is absent.
Its new default mesh was recolored for legible previews; practice
sword, two daggers, bow, string and arrow are test-only connected
props. All are separate from the game and from any original rig.

The current Roblox R15 generator returns 15
`AnimationConstraint` body joints rather than 15 legacy
`Motor6D` body joints. First module load correctly failed its
old motor-only guard; the **source-controlled generator was
updated in GitHub** to accept both connected R15 joint types.
The unchanged practice-weapon grips use their own uniquely named
`Motor6D` joints, excluded from the keyframe hierarchy.

## Authored and structurally verified on the actual rig

The six independent editable 60-Hz `KeyframeSequence` instances
were generated **inside Studio** under the new mannequin. The
source-controlled QA checked every sample, loop flag and event count:

| Clip | Duration | Keyframes | Loops | Timeline events |
| --- | ---: | ---: | --- | --- |
| Idle | 2.0 s | 121 | Yes | 0 |
| Walk | 1.0 s | 61 | Yes | 0 |
| Run | 0.7 s | 43 | Yes | 0 |
| Sword | 1.2 s | 73 | No | 1 `Impact` |
| Daggers | 1.2 s | 73 | No | 2 `Impact` |
| Bow | 1.5 s | 91 | No | 1 `ArrowRelease` |

Edit-mode Animator playback was tested: walking and running
changed actual left/right foot and hand positions. The three
attack clips loaded and each emitted the intended event count
during normal-speed edit playback.

## Real Play-button replay

An isolated, unpublished Studio Play run replayed Idle (2 loops),
Walk (2 loops), Run (2 loops), Sword, Daggers and Bow through
the rig's actual Humanoid.Animator. Per-action console records
reported zero locomotion events, one sword impact, two distinct
dagger impacts and one bow release. The first run passed all
**six individual action assertions** but failed a final outdated
QA-only check that expected the original guardian to exist.
That was corrected directly in GitHub and the installed
test-only replay script was replaced.

A second real Play-button run completed with
`DMMO_HUMANOID_REPLAY_COMPLETE`, all six expected action
records and `DMMO_HumanoidStarterQA=PLAYBACK_MARKERS_CHECKED`.
No second-run humanoid starter script errors were present in
the inspected server log.

After capturing previews, Play was stopped. The assistant
returned to unpublished Edit mode, stopped the temporary
animation track, and **disabled** the test-only replay Script.
All six editable sequences remained in
`Workspace.DMMO_Humanoid_Starter_Test`.

## Real-play visuals

The assistant captured **12 separate real Studio Play viewport
frames per action** using the exact isolated Studio session.
All 72 frames were saved in the local QA folder; six full-loop
GIFs were assembled with the recorded durations and each
reopened with the expected 12 frames. This is actual R15
Animator playback on Roblox's default mannequin, not Blender
rendering, a static storyboard, or a published asset.

Local output root:

`C:\\Users\\Remko\\Documents\\Roblox\\DungeonMMO_Humanoid_Starter_QA_20260923\\Play`

Each `<Clip>` subfolder contains
`DMMO_Humanoid_<Clip>_UNAPPROVED.gif`,
12 corresponding JPEG frames and `capture_manifest.json`.
The parent contains `humanoid_starter_preview_manifest.json`.
The independent GitHub capture and GIF-building tools are in
`tools/animation/humanoid/starter/qa/`.

## Open quality / integration gates

- The test mannequin is deliberately blocky and generic, not
  a finished Human/Elf/Dwarf/Orc character. The actual recorded
  Walk/Run show alternating leg movement, but foot contact,
  root translation matching the player's controller and exact
  heel/toe roll remain **unverified** for a polished in-game gait.
- The simple connected practice sword, daggers and bow are
  recognizable timing aids, **not final weapon art**. Bowstring
  alignment, arrow alignment, shot direction and dagger/sword
  body intersections need user visual assessment on a final
  weighted humanoid. The Bow preview's simple prop can appear
  narrow from the attack camera; do not call it final archery.
- Event markers have no server-authoritative damage or projectile
  implementation. Idle/run/walk blends with live locomotion and
  equipment-driven animation selection remain to integrate later.
- No actual Roblox animation asset ID was uploaded/published;
  no production place/DataStore/main branch was modified.
  The six editable sequences currently live in the open
  unpublished Studio Edit session. The GitHub generator plus
  independent local GIFs are the reproducible durable source;
  an independent **local place-file backup is not verified**.
  Do not claim a saved/published Roblox animation library.
