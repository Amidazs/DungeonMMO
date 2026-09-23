# DungeonMMO — six humanoid starter animations

Status (23 September 2026): **six editable R15 KeyframeSequences
actually built and replayed in unpublished Roblox Studio Place1;
all six structural/marker checks and real Play-button event checks
passed.** Actual Play-mode two-view motion quality and weapon
alignment remain user-review gates. No animation assets were
published or integrated into the live game. The original guardian
was absent, so a separate built-in default R15 mannequin was
created without replacing the original.

These are source-controlled development-only files, **not** game
`src/` code or production animation IDs.

## Six starter clips

| Clip name on the test R15 rig | Duration | Loop | Purpose and marker |
| --- | ---: | --- | --- |
| `DMMO_Humanoid_Idle_v1` | 2.00 s | Yes | Neutral breathing and gentle shoulder motion. |
| `DMMO_Humanoid_Walk_v1` | 1.00 s | Yes | In-place walking with opposed arm/leg phases and knees. |
| `DMMO_Humanoid_Run_v1` | 0.70 s | Yes | Longer leg swing, quicker arm pump, forward lean. |
| `DMMO_Humanoid_Sword_v1` | 1.20 s | No | Right-hand single-sword diagonal strike; `Impact` at 0.60 s. |
| `DMMO_Humanoid_Daggers_v1` | 1.20 s | No | Alternating left/right dagger cuts; two `Impact` markers at 0.45/0.85 s, values `LeftDagger`/`RightDagger`. |
| `DMMO_Humanoid_Bow_v1` | 1.50 s | No | Raise, draw, release, recover; `ArrowRelease` at 1.05 s. |

All animations are baked as *separate* editable
`KeyframeSequence` objects at 60 frames per second when the
generator runs in an actual unpublished Roblox Studio test place.
The first three clip names are one reusable neutral set; the
attacks are separate actions, not pasted onto walk/run.
The named markers are animation timing cues only; they **never**
deal damage, create authoritative hitboxes, or spawn a gameplay
projectile.

## Development files

- [HumanoidStarter_Generator.luau](HumanoidStarter_Generator.luau):
  reusable R15 joint pose authoring, six clip definitions, individual
  `Build(name)`, `BuildAll()`, `Pose(name, time)`, `Play(name)`,
  `Equip(name)`, and `Stop()` controls. Accepts 15 connected R15
  body `Motor6D` **or** `AnimationConstraint` joints and requires a
  `Humanoid.Animator`.
- [HumanoidStarter_TestRigSetup.luau](HumanoidStarter_TestRigSetup.luau):
  creates **new** `DMMO_Humanoid_Starter_Test`. When the original
  marked R15 guardian exists it clones that source; otherwise it
  creates a fresh default Roblox R15 mannequin with connected
  `AnimationConstraint` joints. It removes default animation
  conflicts **on the clone only**, anchors the new root, adds
  readable preview colors and attaches practice weapons. Original
  guardian and saved clips are unchanged.
- [HumanoidStarter_QA.luau](HumanoidStarter_QA.luau):
  command-bar build and structural checks for six distinct editable
  sequences, exact sampled duration, loop flags and event counts.
- [HumanoidStarter_Replay.server.lua](HumanoidStarter_Replay.server.lua):
  **isolated test-only** sequential playback of all six actions and
  their event counts. Does not publish or change live game combat.

The practice weapons use simple connected Roblox Parts for animation
inspection. The bow has two visual Beam strands connected from the
left-hand bow limbs to a right-hand draw-point Attachment; the strands
follow the draw hand but are not physically simulated. They are not
production weapon models or finished bow/arrow mechanics. The arrow
prop is hidden at the release marker during the isolated preview;
no flying projectile is created.

## Assistant-run Studio authoring workflow

When the approved isolated *unpublished* Studio test place is open,
the assistant should perform this workflow using the connected Studio
integration. The user does not need to install the generator, place
keyframes, program, or learn Blender.

1. Verify `game.PlaceId == 0` and Studio edit mode. The source
   guardian is optional; if it exists it **must** be marked
   `DMMO_TestOnly` and have a connected R15 Humanoid/Animator.
   Without that source, setup creates its own built-in R15 model.
   **Never aim these scripts at the production DungeonMMO place.**
2. Execute `HumanoidStarter_TestRigSetup.luau` once in the Studio
   command bar. Preserve the existing test rig if already present.
3. Add a `ModuleScript` named
   `DMMO_Humanoid_Starter_Generator` under
   `Workspace.DMMO_Humanoid_Starter_Test`. Install the exact GitHub
   generator source as the ModuleScript's `Source` property.
4. Execute `HumanoidStarter_QA.luau` in edit mode. It builds
   missing clips only, reuses already-created ones without overwriting
   them and checks all six editable sequences, frame counts,
   durations, loops and markers. `Build(name)` still rejects
   overwriting an existing clip.
5. Install `HumanoidStarter_Replay.server.lua` as a **disabled**
   `Script` under this same clone, then enable it in an isolated
   Play test. Capture full-speed side, front and gameplay-angle
   review of idle, walk, run and all three attacks. Check each prop
   remains attached to the correct hand; right-hand arrow draws and
   is hidden on release. Check one sword event, two dagger events
   and one bow release; inspect edit-mode neutral reset after stop.
6. Save the test place and editable sequences **locally as
   unpublished QA backups only**. Update this document with
   observed issues, captured preview paths and actual Studio test
   results. Keep original guardian and live DungeonMMO game intact.

## Important locomotion limitations

This starter set is an **in-place pose generator**. The Roblox
Humanoid/controller must drive horizontal world travel in the
finished game. The first pass uses mirrored cyclic hip/knee/ankle
angles; it does **not** yet enforce planted foot contacts with
inverse kinematics, calibrate every final humanoid's leg lengths, or
claim correct heel-to-toe rollover on each skinned playable race.
Likewise, the blocky guardian is a rigging proof, not final player
art. A successful sequence build or marker check is not approval of
visual animation quality.

The first actual Studio review should identify foot sliding,
uncomfortable knee/elbow bending, weapon clipping, bowstring/arrow
alignment, attack readability and idle-to-movement transition quality.
Refine the *specific* motion on the test clone before accepting or
integrating it. Animation asset publishing and combat integration
require separate user approval.

[Humanoid animation roadmap](../../../../docs/roadmap/DungeonMMO_Humanoid_Animation_Pipeline_20260922.md)
tracks the independent visual QA and production acceptance gates.


## Actual unpublished Studio execution and GIF review

On 23 September 2026 the exact separate
`Workspace.DMMO_Humanoid_Starter_Test` mannequin was built in
unpublished Place1 and all six `KeyframeSequence` objects were
generated and verified at 60 Hz. The subsequent real Play-button
replay returned `DMMO_HUMANOID_REPLAY_COMPLETE`: Idle/Walk/Run
looped twice; Sword emitted one `Impact`, Daggers two
`Impact` markers, and Bow one `ArrowRelease` marker.
An initial QA-only final check incorrectly required the absent
original guardian; that check was fixed in GitHub and the complete
replay passed on its final run.

Six real Play-mode 12-frame animated GIFs and individual source
screenshots are saved under:

`C:\\Users\\Remko\\Documents\\Roblox\\DungeonMMO_Humanoid_Starter_QA_20260923\\Play`

For example:
`Walk/DMMO_Humanoid_Walk_UNAPPROVED.gif` and
`Bow/DMMO_Humanoid_Bow_UNAPPROVED.gif`.
Use the same `<Clip>/DMMO_Humanoid_<Clip>_UNAPPROVED.gif`
pattern for Idle, Run, Sword and Daggers. The capture scripts
and GIF builder are in [qa](qa/). The original guardian was not
present in Place1; no user scripts/models were overwritten.
The replay test Script was disabled and Studio restored to
unpublished Edit mode with six editable clips still present.

**Visual approval is still OPEN.** The built-in R15 mannequin is
simple block art; foot planting and controller movement need
final-character testing. Practice weapon shape/visibility,
bow/arrow/string alignment and attack arcs need user review.
No published Roblox animation IDs exist. A permanent local
`.rbxlx` or `.rbxm` Studio-file backup is not verified; the
GitHub generator and six local QA GIFs are durable reproduction
sources, not substitutes for an accepted, saved animation asset.

[Focused Studio validation record](
../../../../docs/testing/humanoid-starter-six-clip-20260923.md).
