# DungeonMMO — six humanoid starter animations

Status (23 September 2026): **six authored R15 animation definitions in
GitHub; Studio authoring and visual acceptance still pending.** The
unpublished Studio test place and its original guardian were not open
when this set was prepared. Do not claim that editable KeyframeSequences
were already built inside Studio, that the motion looked good in
playback, or that animation assets have been published.

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
  `Equip(name)`, and `Stop()` controls. Requires the existing 15
  R15 body `Motor6D` names and a `Humanoid.Animator`.
- [HumanoidStarter_TestRigSetup.luau](HumanoidStarter_TestRigSetup.luau):
  creates a **new** `DMMO_Humanoid_Starter_Test` by cloning the
  original marked R15 guardian, removes the cloned hammer/scripts,
  anchors only the new root, and attaches hideable practice sword,
  dual daggers, bow and arrow to the appropriate hands. Does not
  mutate the original guardian or its saved animation sequences.
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

1. Verify `game.PlaceId == 0`, Studio edit mode, and
   `Workspace.DMMO_Astra_Guardian_Test` has the original
   `DMMO_TestOnly` marker and a connected R15 Humanoid/Animator.
   **Never aim these scripts at the production DungeonMMO place.**
2. Execute `HumanoidStarter_TestRigSetup.luau` once in the Studio
   command bar. Preserve the existing test rig if already present.
3. Add a `ModuleScript` named
   `DMMO_Humanoid_Starter_Generator` under
   `Workspace.DMMO_Humanoid_Starter_Test`. Install the exact GitHub
   generator source as the ModuleScript's `Source` property.
4. Execute `HumanoidStarter_QA.luau` in edit mode. It calls
   `BuildAll()`, saves six editable `KeyframeSequence` children
   beneath the cloned R15 rig, and inspects their marker/keyframe
   counts. Do **not** rerun `BuildAll()` on the same rig:
   `Build(name)` refuses to overwrite existing same-named clips.
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
