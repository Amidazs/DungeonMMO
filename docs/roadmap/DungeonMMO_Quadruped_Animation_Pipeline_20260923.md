# DungeonMMO — quadruped animation production roadmap

Date: 23 September 2026  
Working branch: `wip/phase-4-test-hud-integration-v1`  
Status: **development-only engine foundation, not an accepted
quadruped master rig, finished animation or backend integration.**

This is an additional **art/animation** workstream. The
[humanoid animation pipeline](DungeonMMO_Humanoid_Animation_Pipeline_20260922.md)
remains separate. The current [v1.79 professions/economy roadmap](
DungeonMMO_Roadmap_v1_79_Exclusive_Professions_20260923.md)
remains the latest backend supplement; no C4/profession acceptance
is inferred from this animal-animation work.

## Desired result

The user should be able to request a canine, feline, horse or
unusual four-legged dungeon monster, including bespoke boss
attacks, and receive a usable in-game animation **without
personally learning Blender, rigging or placing keyframes**.
Create an original, readable, weighted combat style inspired by
Iron Soul: Dungeon and Dungeon Quest: Reborn while maintaining
DungeonMMO's own creatures, animations, warnings and combat rules.

Build one engine with rig-family adapters rather than one rig
per monster *or* a single rigid skeleton forced onto all anatomy.
Humanoid R15 keyframes cannot simply be copied to a quadruped.
A good compatible canine master may drive wolves, dogs and
foxes with proportional calibration and visual validation;
a horse, bear, cat or unusual boss needs its own limb/joint
profile and possibly a distinct master skeleton.

## Canonical project location

`tools/animation/quadruped/`:

- [Rig-independent movement mathematics](
  ../../tools/animation/quadruped/QuadrupedMotionCore.luau):
  Walk/Trot four-paw stance/swing targets and a two-bone
  knee/hock **position** solver. Does not animate a model.
- [Non-destructive master rig audit](
  ../../tools/animation/quadruped/QuadrupedRigAudit.luau):
  checks 17 mapped anatomical roles, connected joints and
  controller/Animator presence; never substitutes for a
  texture, skin-weight or moving-paw inspection.
- [Rig/engine setup and acceptance constraints](
  ../../tools/animation/quadruped/README.md).

This initial source-only foundation is **not** yet validated
against a selected imported rig in Studio. Studio was closed
during preparation. The code remains outside the production
Rojo `src/` directory. Do not publish, merge `main`, attach
to live dungeon combat, or describe it as a finished animal
animation system until the acceptance gates below pass.

## Stage 1 — approve the canine master rig [OPEN]

- [ ] Find/import a genuinely standing, properly rigged and
  **skinned** canine model into a separate unpublished Studio
  test place. Keep its original fur/face/texture and source file.
  The old welded `DungeonWolfFactory` shape is not a valid
  animation master. The previous Frostfang trials had a
  distorted forepaw, implausible leg motion and foot/floor
  mismatches; avoid reusing them without first repairing
  the original anatomy/weights.
- [ ] Inventory the actual Bone/Motor6D hierarchy, Animator,
  mesh weights, rest axes and per-leg segment lengths.
  Map independent front-left/front-right/hind-left/hind-right
  shoulder/hip, knee/hock and paw targets; include pelvis,
  spine/chest, neck/head, jaw and tail where present.
  Use the read-only rig audit, **then** inspect skin deformation
  visually. Audit PASS alone is not acceptance.
- [ ] Confirm paws rest on the floor, front paws stay correctly
  shaped while flexing, joints bend in plausible directions,
  and no body part clips the floor or floats at idle.

## Stage 2 — rig adapter and baseline movement [OPEN]

- [ ] Implement a rig-specific adapter converting normalized
  motion/IK targets to the selected actual skeleton's rest-space
  bone/joint rotations. Treat Roblox Bones and Motor6Ds
  separately; never assume interchangeable `Transform` axes.
- [ ] Implement root/chest/pelvis counter-motion and true
  world-locked stance paw placement, with swing clearance and
  a stable 60-Hz editable Roblox animation sequence.
  Validate speed/stride consistency, hip and spine balance,
  slope behavior where supported, and transitions.
- [ ] Author **idle → one normal walk → idle**, then walk
  turning and trot/run only after a convincing walk. Test
  actual Animator playback in Studio from side, front, rear,
  and player camera. Foot drift, ankle/hock limits, ground
  clearance, front-paw deformation and movement weight are
  independent acceptance criteria. Fix each failed pose and
  retest the complete motion; static plots do not count.
- [ ] Preserve the master rig/profile/authoring scripts in the
  project and independent editable animation clips with a
  real playback GIF/video and explicit unresolved issues.
  The user reviews motion quality before the gait is accepted.

## Stage 3 — creature combat animation library [OPEN]

- [ ] Normal canine: stance, walk, trot/run, directional turn,
  short bite, longer pounce/lunge, hit reaction, stagger, death.
  Define attacker facing before commitment, actual jaw
  movement and contact, grounded paw push-off/landing, recovery
  and compatible server-owned hitbox timing.
- [ ] Mini-boss: distinguishable wind-up, short basic combo,
  a heavier cleave/bite or charge and one distinctive special.
  Its visible attack arc/line/circle must match the actual
  moving head, paw, body or weapon.
- [ ] Full boss: authored multi-stage attacks and transitions,
  telegraphed charges, leaps, special arena patterns and
  recovery windows as anatomically appropriate; preserve
  target/threat logic and the separate server validation of
  damage. The engine supplies *animation*, not authority
  for attack selection, projectiles, hitboxes or damage.
- [ ] After **one approved canine master and its accepted clips**,
  prove an additional compatible canine retarget without
  destroying its appearance. Separately validate another
  quadruped anatomy; do not claim universal animal support
  from a single wolf demonstration.

## Minimum acceptance and safety gates

The character must look convincing **in continuous real
Roblox Studio playback**, not merely produce valid FBX/glTF
or a correctly named `KeyframeSequence`. Both foot contact
and the skin's deformation are important: small root drift
cannot compensate for a collapsing forepaw, inverted joints,
hopping hindquarters or a body hovering above the floor.
Every clip must restore its original rest pose, keep
existing accepted animations, remain editable, and have
per-species visual sign-off. Server-authoritative combat
timing and markers are verified **after** animation acceptance.
Use the test place and source-controlled development tools;
no publish, production rig substitution or live place changes
without explicit approval.

**Next actionable step:** select the master canine rig and
run a Studio anatomy/weighting inspection. Until that exists,
the code here is a mathematical scaffold, **not an approved
quadruped animation engine**.
