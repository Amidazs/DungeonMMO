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
