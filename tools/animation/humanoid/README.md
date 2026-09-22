# Humanoid animation generators (isolated development tools)

This directory is the **DungeonMMO source of truth** for Astra's
original humanoid attack generator. It replaces reliance on the
working copies saved in Downloads or an ephemeral Astra preview
directory. The generator is **not** part of a published Roblox place
or the production Rojo `src/` tree.

## Files

- [AstraCrushingStrike_Generator.luau](AstraCrushingStrike_Generator.luau):
  Astra's original, unmodified test-only ModuleScript source. It
  creates `DMMO_Astra_CrushingStrike_v1` with a 2.4-second sequence,
  a single `Impact` marker at 1.2 seconds and rest-pose reset.
- [AstraCrushingStrike_Controls.json](AstraCrushingStrike_Controls.json):
  the **10 original control poses** from the live Studio module's
  `Controls` attribute. The generator requires this attribute;
  storing only its Luau source would not reproduce the animation.
- [Animation roadmap](../../../docs/roadmap/DungeonMMO_Humanoid_Animation_Pipeline_20260922.md):
  authoring, visual review, technical QA, creature rollout and
  production acceptance criteria.

## Reproduce in an isolated unpublished Studio test place

The next animation-authoring assistant should perform these steps
using Studio integration; **the user does not need to edit rigs,
keyframes, Blender files or scripts manually**.

1. Open a **separate unpublished** Studio test place (`PlaceId == 0`)
   with the existing compatible
   `Workspace.DMMO_Astra_Guardian_Test` R15 model. Its connected
   `Motor6D` body joints, `Humanoid.Animator`, and
   `RightHand.GuardianHammerGrip` / `Guardian_Hammer.Handle` /
   `Guardian_Hammer.HammerHead` attachment must already exist.
   The script is deliberately **not** a generic rig builder or
   production animation service.
2. Add a `ModuleScript` called
   `DMMO_Astra_CrushingStrike_Preview` beneath that test model.
   Set its `Source` from
   `AstraCrushingStrike_Generator.luau`. Set the **string**
   attribute `Controls` to the JSON-array contents of
   `AstraCrushingStrike_Controls.json`. The control points are
   separate instance metadata, not an embedded Luau constant.
3. From an isolated Studio edit/play test, use
   `local generator = require(testRig.DMMO_Astra_CrushingStrike_Preview)`
   then `generator.Build()` to create the editable
   `DMMO_Astra_CrushingStrike_v1` sequence. Use
   `generator.Play()` only for test playback and call
   `generator.Reset()` after preview. `Build()` overwrites
   the **same-named test sequence**, so preserve any previously
   accepted copy before rebuilding it.
4. Inspect actual animation playback from front, side and
   player-camera views. Check body/weapon intersections, foot
   planting, one impact marker, attachment stability and neutral
   joint/constraint transforms after stop. The original test rig
   has a known inherited hammer/arm overlap at its ready pose.
5. Save a separate editable sequence and QA record when accepted.
   **Do not** insert this generator into a shipped game, merge
   `main`, publish Roblox assets or connect impact markers to
   live damage without explicit approval.

The proof of concept used an intentionally simple humanoid mannequin;
it does **not** establish production-quality monster animation,
general compatibility with other R15 meshes, or applicability to
quadrupeds, birds and harpies. The source and the recovered controls
must travel together for reproducibility.
