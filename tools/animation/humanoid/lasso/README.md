# Overhead lasso — isolated R15 animation proof of concept

Status: **Studio playback demonstrated; not a finished DungeonMMO
creature or production rope system.** The rig is an intentionally
simple humanoid mannequin, not a boss-quality character.

This generator was authored after the original Astra humanoid
Crushing Strike experiment. It creates **three separate, editable
`KeyframeSequence` assets** on the same compatible R15 skeleton:
`DMMO_Lasso_Raise` (0.6 s), `DMMO_Lasso_Swing_Loop` (1.5 s,
looping), and `DMMO_Lasso_Lower` (0.6 s). The right arm rises above
the head, the shoulder/elbow/wrist and torso describe a cyclic
overhead lasso motion, and the character returns to its rest pose.
The stationary source rig's root stays anchored; this is not
walking locomotion, a lasso throw, or a grab/hitbox.

## Source files in the DungeonMMO repository

- [TestRigSetup](LassoOverhead_TestRigSetup.luau) clones the *existing*
  `Workspace.DMMO_Astra_Guardian_Test` R15 test rig to
  `Workspace.DMMO_Lasso_Character_Test`, offsets it to a separate
  location, removes the cloned hammer and previously authored attack
  scripts, and attaches a small lasso grip to `RightHand`. It does
  not change the original guardian or its attacks.
- [Generator](LassoOverhead_Generator.luau) is the editable
  `ModuleScript` source that programmatically creates all three
  animation clips and provides `Pose`, `Show`, `Reset`,
  `Build`, and `StartPreview`.
- [Replay](LassoOverhead_Replay.server.lua) is a **test-only
  Script**, generating a continuous 32-segment visible rope loop,
  11-segment tether and knot, and coordinating raise → three
  overhead revolutions → lower. It demonstrates motion but uses
  anchored rope geometry, **not physically simulated rope**.
  `LassoCaptureMode` / `LassoCaptureTime` are optional
  test-only attributes used when recording paused Studio frames.

## Reproduce without manual animation work

The assistant should use Studio integration in an **isolated,
unpublished Place1** (`PlaceId == 0`), not the active DungeonMMO
game:

1. Ensure the compatible, connected R15 test guardian exists with
   a `Humanoid.Animator` and fully connected body `Motor6D`s.
   Programmatically run the test-rig setup to create the separate
   `DMMO_Lasso_Character_Test` performer.
2. Add a `ModuleScript` named `DMMO_Lasso_Generator` beneath the
   cloned performer; set its Source to the repository generator.
   Require it and run `generator.Build()` to add the three
   `KeyframeSequence` objects under the clone.
3. Add a disabled `Script` named `DMMO_Lasso_Replay` under the
   same test clone, set its Source to the replay file and enable it.
   Press Play in Studio. Do **not** publish the place.
4. Inspect real playback from front and side. Verify that the arm
   raises, the rope stays attached to the hand, the loop rotates
   overhead, the feet stay grounded and the rig resets on Stop.
   Keep the generator and visual rope separate: the keyframes
   animate the character, while the test replay positions the rope.

The source and playback were checked with a separate test R15 clone.
The swing loop was baked at 60 Hz (91 keyframes including the
seam), with 37 keyframes each for the raise and lower transitions.
The source loop is designed to connect its first and final poses.
An actual Roblox Studio 16-frame-per-revolution front-and-side GIF
and a pose sheet are stored on the connected user's PC at
`Downloads\DMMO_Lasso_Preview\`, not in GitHub.

**Known limitations:** the blocky mannequin and its original arm
geometry are not final character art, the shoulder/hand cycle still
needs visual polish before player-facing use, and the rope is
animated scene geometry rather than a physically simulated cord.
No throw, projectile, collision, snare, damage or combat integration
has been implemented. Retarget the clips only to humanoids with
compatible joints and validate them visually before reuse. The
generator and replay intentionally refuse to operate in a published
Roblox place; they are excluded from the production `src/` tree.

See [humanoid animation production roadmap](../../../docs/roadmap/DungeonMMO_Humanoid_Animation_Pipeline_20260922.md)
for the visual-quality and combat-integration acceptance gates.
