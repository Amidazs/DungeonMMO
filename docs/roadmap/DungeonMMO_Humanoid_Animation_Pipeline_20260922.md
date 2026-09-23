# DungeonMMO — reusable humanoid animation production pipeline

Date: 22 September 2026  
Status: **proof of concept demonstrated in isolated, unpublished Roblox Studio `Place1`; production animation quality and DungeonMMO integration remain OPEN.**  
Working roadmap: [index](README.md) and [v1.76 backend status](DungeonMMO_Roadmap_v1_76_C4_Recovery_20260922.md).

## Canonical generator location (GitHub and local DungeonMMO project)

Astra's **original, unmodified** overhead-strike generator is now kept
in the repository, **not only in Downloads**:

- [Generator ModuleScript source](../../tools/animation/humanoid/AstraCrushingStrike_Generator.luau):
  `tools/animation/humanoid/AstraCrushingStrike_Generator.luau`.
- [Original control poses](../../tools/animation/humanoid/AstraCrushingStrike_Controls.json):
  `tools/animation/humanoid/AstraCrushingStrike_Controls.json`.
- [Setup and verification instructions](../../tools/animation/humanoid/README.md):
  `tools/animation/humanoid/README.md`.

After the active development worktree is brought up to date, the
corresponding local folder is
`C:\Users\Remko\Documents\Roblox\DungeonMMO_Phase4_HUD_Integration_v1\tools\animation\humanoid\`.
**Both** the Luau source and the original 10-pose JSON are required:
the generator reads those poses from the Studio ModuleScript's string
`Controls` attribute. Merely moving the source file without that
attribute would make the generator unusable. These `tools/` files
are development-only, not part of the Rojo `src/` gameplay builds.
The assistant should install/preview them in an unpublished isolated
Studio test place; no manual Blender or keyframe work is required of
the user. Do not treat the generator's existence as an accepted
production animation, a rig migration, or permission to publish.

## Additional isolated R15 motion proof: overhead lasso

A separate humanoid mannequin was cloned from the unpublished
`Place1` guardian without changing either hammer attack. The
[test-only lasso generator](../../tools/animation/humanoid/lasso/LassoOverhead_Generator.luau)
builds three editable R15 KeyframeSequences: a 0.6-second raise,
a 1.5-second overhead looping swing, and a 0.6-second lower.
The [separate visual replay](../../tools/animation/humanoid/lasso/LassoOverhead_Replay.server.lua)
draws a continuous rotating rope loop, tether and knot above the
character; this is **procedural test geometry, not a physically
simulated rope, a lasso throw, or a server-side grab**.
[Setup and reproduction instructions](../../tools/animation/humanoid/lasso/README.md)
are stored with the generator in the project; no manual Blender,
keyframe editing or user scripting is required.

The clips loaded and played in isolated Studio, and 16 front/side
frames across a full revolution were captured from actual playback.
The final mannequin art and arm/body performance still require
user visual approval before reuse. No live DungeonMMO source,
combat effects, physics rope, published place or animation asset
was changed. The preview and review materials remain in the
connected PC's `Downloads\DMMO_Lasso_Preview\` directory.

## Goal and responsibilities

Create readable, physically convincing normal-monster, mini-boss and
boss animations inspired by the combat *presentation* of Iron Soul:
Dungeon and Dungeon Quest: Reborn while keeping DungeonMMO's creatures,
attack designs, animation assets and combat implementation original.
**The user must not need to learn Blender, hand-place keyframes or rig
characters manually.** ChatGPT/Astra prepare, author, preview, test and
revise the assets using an isolated Studio test place. The user reviews
the visible result before an attack is accepted.

Use an existing **properly connected and skinned humanoid rig** for
humanoid assets; retain skeleton hierarchy, rest pose, bone/Motor6D
names, proportions and skin weights when making another animation.
For a new humanoid appearance, fit/skin its mesh to an approved
compatible master rig rather than constructing a fresh arbitrary
skeleton for every enemy. Test weapon attachments and motion on
the actual target rig. Do not assume the humanoid procedure works for
wolves, birds, harpies or other anatomies without separate rig-family
proofs.

## What the prototype actually established

- An isolated R15 guardian mannequin with a hammer attached to
  `RightHand` via `GuardianHammerGrip` was created in unpublished
  `Place1`. Arm motion was verified to carry the hammer.
- Astra authored a **separate, original 2.4-second overhead hammer
  strike** on the supplied rig, with wind-up, hold, downswing, an
  `Impact` animation marker and recovery. The resulting
  `DMMO_Astra_CrushingStrike_v1` sequence has 145 keyframes.
  Astra's Studio playback/pose-reset evidence was inspected; the
  inherited hammer/upper-arm overlap in the ready stance is **not**
  resolved in the supplied rig.
- ChatGPT authored a second, distinct **2.1-second side-to-side hammer
  sweep** as `DMMO_Astra_SweepingStrike_v1` (127 keyframes), using the
  same connected R15 joint chain and planted-foot pose generator.
  The first arc crossed the guardian's face; the impact pose was
  revised after front/side real-playback inspection.
  A normal-speed Studio test observed one `Impact` marker,
  maximum sampled foot drift below 0.001 studs, zero sampled grip
  positional error and return to the initial stance. The separate
  Play-button replay finished with one marker event, and Studio's
  Edit-mode joint and animation-constraint transforms reset to neutral.
  The existing overhead animation remained intact.
- Both are **animation-authoring proofs, not accepted production
  boss animations**: the mannequin remains blocky, the original
  hammer rest-pose overlap is unresolved, the sweep still needs a
  more convincing full-body performance, no authoritative damage
  or hitbox integration was done, and the attacks were not published.
  Numerical contact/drift checks alone cannot establish visual
  quality. Do not label either attack Iron Soul/Dungeon Quest
  Reborn quality, production ready or creature-family portable.

## Repeatable no-manual-animation workflow

1. **Choose and audit a master rig.** Start from an existing R15
   humanoid or an approved custom humanoid rig, with complete
   connected body joints, appropriate skinning/weighting and an
   Animator. Check the neutral stance, feet/floor alignment, hand
   and weapon attachment, orientation and joint limits. Keep a
   separate backup. A blocky mannequin is fine for proving tools,
   not for final quality approval.
2. **Define a specific move before animating.** Record its intended
   range/direction, readable telegraph, target facing/rotation-lock,
   wind-up, short commitment/hold, acceleration, contact frame,
   follow-through, recovery and intended block/parry/dodge response.
   Use physical/anatomical reference for weight transfer; use the
   reference games for encounter readability, not copied assets or
   identical attacks. Start with a clear horizontal cleave,
   overhead strike or thrust, not a generic "attack" prompt.
3. **Author directly on the supplied rig.** Provide Astra the
   existing model path, exact stable joints and weapon grip, its
   rest pose and an explicit request to create **one new**
   non-looping `KeyframeSequence`, not a regenerated mesh, video
   or preset animation. ChatGPT may instead programmatically author
   body poses/keyframes (e.g. a 60-Hz baked R15 sequence) and use
   Studio's animator to preview them. Keep all original actions
   intact. Use body-wide hip/torso/shoulder/arm follow-through,
   grounded leg/foot placement, controlled interpolation and a
   visually meaningful recovery. Do not simply rotate the wrist
   or move the entire model as an unarticulated object.
4. **Add semantic timeline events.** Put a named `Impact` marker
   at the actual visible contact frame; optionally add
   `Telegraph`, `Commit`, `TrailStart`, `TrailEnd` and
   `Recover` where useful. An animation marker by itself does
   **not** apply damage, validate targets or grant combat authority.
5. **Inspect actual Roblox Studio playback, not just pose data.**
   Play at normal speed and sample **front, side and gameplay
   angles** from wind-up through recovery. Inspect full motion as
   well as individual frames: planted feet, natural knee/elbow
   bends, centre-of-mass shift, shoulder/hip motion, readable
   weapon path, clipping through the torso/head/floor, correct
   hand/weapon attachment, no snapping, and natural return to idle.
   Fix the specific bad phase and replay the entire move.
6. **Run targeted technical checks.** Confirm the original rig
   and other animation clips are unchanged; sequence loads on
   its target Animator; it does not loop; its duration and marker
   count are expected; impact fires once per playback; feet and
   weapon grip remain within agreed tolerances; and Edit mode
   returns every `Motor6D`/`AnimationConstraint` to its neutral
   transform after the preview. Include an isolated Play-button
   replay. Avoid rerunning unrelated backend/dungeon suites.
7. **Preserve and review the result.** Save an editable
   `KeyframeSequence` backup, the pose-generation source/controls,
   a real-playback front/side GIF or clip, and a concise QA record
   specifying the tested model and unresolved limitations. Keep
   these files out of the live game until user visual approval;
   publishing an animation asset or Roblox place needs separate
   authorisation. The user's job is only to review the visual
   preview and identify what still looks wrong.

**Astra prompt template:** "In the unpublished Studio test place,
animate only `Workspace.<ApprovedHumanoidRig>` with one bespoke
`<AttackName>` on its existing skeleton. Preserve its mesh, rig,
rest pose, skin weights, other clips and weapon grip. Make a readable
telegraph, full-body weight shift, fast committed strike at the
specified direction/range, exact `Impact` marker and grounded
recovery. Save a separate editable non-looping KeyframeSequence.
Play it in Studio from front, side and gameplay angles; correct
clipping, floating, foot sliding and unnatural joints, then verify
one marker event and neutral Edit-mode reset. Give me a visual
preview and a backup; do not publish or modify DungeonMMO." 

## Content rollout and acceptance gates

| Scope | Authored animation set | Completion criteria |
| --- | --- | --- |
| Standard humanoid enemy | Idle/combat stance, locomotion transitions, one or two short directional attacks, hit reaction and death. | Readable and distinct movements on the **finished** skinned humanoid, believable contact/feet, normal combat transitions, correct target-facing and server-authoritative hit timing. |
| Mini-boss | Shared basic set plus a distinct heavier strike, one or two telegraphed specials, interrupt/stagger and recovery as relevant. | Different silhouettes and warning cues for each move; arc/circle/line hazard agrees with the weapon or body; tested block/parry/dodge windows. |
| Full boss | Bespoke multi-stage attacks, charges/leaps/cleaves/slams as anatomically appropriate, phase-transition poses, stagger/death and arena-cue synchronisation. | Each move is visually reviewed from player camera; per-attack commit, hitbox geometry, warning, server validation, recovery and multi-player timing are accepted in its own encounter. |

**Next work:** Retarget the tested authoring procedure from the blocky
mannequin to one visually complete, correctly weighted humanoid
guardian, fix the hammer ready-pose overlap, refine one basic cleave
and one boss attack until the user accepts actual in-game motion,
then establish a reusable humanoid animation/action naming and QA
contract. After that, separately prove compatible **quadruped,
bird and winged-humanoid** master rigs; do not extrapolate from
R15 to creature rigs. These are art/animation milestones, not proof
that the existing Phase 4 backend or full C4 catalogue is finished.

## Isolation and repository policy

Animation experiments stay in an unpublished **test place**.
Code/docs and roadmap changes go directly through GitHub.
Use the connected desktop only for live/visual Studio checks and
asset import/export as necessary; do not rewrite the DungeonMMO
repository via Remote Desktop Commander. Do not publish, merge
`main` or alter production assets/DataStores without approval.


## Six-clip humanoid starter library — 23 September 2026

**Current checkpoint: authoring source committed in GitHub;
new six-clip Studio generation, real motion playback, visual review,
and Roblox asset publishing have NOT occurred.** Existing original
guardian/lasso clips remain unchanged. The latest separate backend
roadmap on this branch is v1.99; do not silently replace its class
development requirements with animation progress.

The user paused Frostfang/quadruped animation after repeated
unnatural shuffling and selected humanoids as the active animation
family. A new, isolated R15 starter library was authored directly
in GitHub at
`tools/animation/humanoid/starter/` using the already demonstrated
native Studio `KeyframeSequence` approach. It reuses the existing
R15 Motor6D hierarchy and source guardian clone contract, not a new
mesh, arbitrary skeleton or downloaded preset.

The authored set comprises: neutral **Idle** (2.0 s loop),
**Walk** (1.0 s loop), **Run** (0.7 s loop), **Sword** (1.2 s
single-sword right-hand strike, `Impact` 0.6 s),
**Daggers** (1.2 s alternating two-hand strikes,
`Impact` 0.45 s and 0.85 s), and **Bow** (1.5 s
raise/draw/release/recover, `ArrowRelease` 1.05 s).
All are authored as independently named 60-Hz editable
`KeyframeSequence` clip definitions. The library requires actual
Studio execution of its source-controlled generator on the
isolated unpublished test mannequin to instantiate the six
sequences; do **not** report them as already created animation assets
on the PC. Test-only weapon parts are connected to the appropriate
hands for future visual playback; gameplay hitboxes, projectile
spawning, damage and publishing are not enabled.

The six new authoring/test sources and reproduction instructions are
documented in [the humanoid starter README](
../../tools/animation/humanoid/starter/README.md).
The isolated test-rig setup clones
`Workspace.DMMO_Astra_Guardian_Test` to
`Workspace.DMMO_Humanoid_Starter_Test`, removing only the
clone's original hammer and attack scripts. The six-clip QA
authoring script checks separate editable clips, exact sample
counts, declared loop flags and event counts; the separate replay
is intended to exercise the real Animator and animation events
with front/side/player-camera visual review.

**Studio environment verification:** At the time of the authoring
work, no `RobloxStudioBeta` process was running, the dedicated
local Studio bridge on loopback port 8765 was unreachable, and no
saved isolated `Place1` test file was found in the inspected
project/temporary paths. Therefore no claim of live animation
generation, clip-load acceptance, visual quality, neutral
reset, marker emission or correct weapon grip alignment can be
made. The scripts and roadmap were edited in GitHub; the local
desktop was inspected for testing access only.

**Next acceptance gate:** Reopen the original *unpublished*
R15 guardian test place; connect the existing Studio bridge;
use the new starter setup and generator to create the six
editable sequences on the cloned mannequin, then replay
every motion at natural speed and capture actual front/side/player
camera previews. Correct visible foot sliding, phase/stride timing,
hand/weapon grip intersections and bow/arrow geometry before
treating any clip as usable game art. Check and retain all original
humanoid generator files. Keep all clips out of production game
code and do not publish until the user separately approves them.


## Six-clip R15 starter acceptance checkpoint — 23 September 2026

**Current status: six native editable test-clips built on an isolated
unpublished R15 mannequin; 6/6 structural checks and 6/6 real
Play-button playback/event checks PASSED. Visual approval, live
movement/combat integration, local .rbxlx backup and publication
remain OPEN.** The current independently updated backend roadmap
is [v2.04](DungeonMMO_Roadmap_v2_04_Expanded_Combat_Ironvow_Foundation_20260923.md).
This animation checkpoint does not replace or modify the backend
progression/class roadmap or its separate acceptance evidence.

After the user opened Studio, the original `Place1` was confirmed
unpublished (`PlaceId == 0`). The previous Astra guardian was
not actually present. The source-controlled starter setup therefore
created a **separate Roblox built-in R15 test mannequin** instead
of silently modifying a guardian or the other open DungeonMMO
test sessions. The built-in Roblox R15 had the current 15 connected
`AnimationConstraint` body joints, not legacy `Motor6D` bodies:
the GitHub authoring generator was fixed to support both types
before any successful sequence creation.

The six actual `KeyframeSequence` clips built under
`Workspace.DMMO_Humanoid_Starter_Test` were Idle, Walk, Run,
Sword, Daggers and Bow. The deterministic 60-Hz keys, exact
durations/loop flags and 0/0/0/1/2/1 named event counts passed
structural QA. Edit-mode real Animator playback observed moving
body parts and expected attack markers; a separate Play-button
test replayed the full set and passed with
`DMMO_HumanoidStarterQA=PLAYBACK_MARKERS_CHECKED`.
A first replay completed all individual actions but an outdated
test-only final guardian-presence assertion failed; this was
corrected on GitHub, and the final uninterrupted Studio replay
and its six action logs passed.

A source-controlled QA helper captured 12 genuine clean
Play-mode Studio viewport frames per clip and built six
verified full-loop preview GIFs in
`C:\\Users\\Remko\\Documents\\Roblox\\DungeonMMO_Humanoid_Starter_QA_20260923\\Play\\<Clip>\\DMMO_Humanoid_<Clip>_UNAPPROVED.gif`.
The [actual Studio closeout record](
../testing/humanoid-starter-six-clip-20260923.md)
contains the complete six-sequence timeline, playback and
capture evidence; the [starter README](
../../tools/animation/humanoid/starter/README.md)
documents how to reproduce this exact test without modifying
existing production scripts.

**User quality review remains required.** The recorded demo
uses generic blocky R15 art; in-place walk/run have not been
approved for final foot planting on playable race meshes. Sword,
dagger and bow props are intentionally simple; their visible
alignment/occlusion, bowstring/arrow trajectory, weapon-ready
stance, combat timing against actual target dummies and
idle/locomotion blending still require refinement on the final
rig. A correct `Impact` or `ArrowRelease` animation marker
is not authoritative damage/projectile logic.

The assistant stopped Play, disabled the temporary replay Script,
reset the idle pose and verified that all six editable clips
remained in unpublished Edit mode. No animation was published,
no original guardian or production game was replaced, and no
Studio local place-file backup was verified. **Next:** user reviews
the six real Studio GIFs; refine specific gait/weapon defects
on the same isolated test mannequin, then save an independently
versioned unpublished local animation/place backup before any
approved integration.
