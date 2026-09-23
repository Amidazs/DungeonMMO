# DungeonMMO — quadruped animation production roadmap

Date: 23 September 2026  
Working branch: `wip/phase-4-test-hud-integration-v1`  
Status: **development-only engine foundation, not an accepted
quadruped master rig, finished animation or backend integration.**

This is an additional **art/animation** workstream. The
[humanoid animation pipeline](DungeonMMO_Humanoid_Animation_Pipeline_20260922.md)
remains separate. The [canonical roadmap index](README.md) tracks newer backend
supplements independently of this art workstream. No C4,
profession or combat-backend acceptance is inferred from
experimental animal rigging.

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

## Frostfang rigging checkpoint — experimental, 23 September 2026

**Status: first-pass import candidate; Stage 1 remains OPEN.**
The previous Meshy wolf skeleton had clustered bone pivots and
unweighted leg chains. The original GLBs were left untouched.
On the authorized PC, Blender 5.0.1/Rigify Animals.wolf was
fitted against Frostfang's actual standing geometry and four
independently measured paw locations.

A separate 33-bone compact deform skeleton was derived, with
new spatial skin weights on a copy of the original 80,974-vertex
mesh. A second skinning pass smoothed 24,121 forequarter
vertices; controlled foreleg bend testing reduced sampled
front-shoulder edge stretch above 1.4x from 1,628 to 1,266 of
31,267 evaluated edges. The tested paw retained its width
and the test poses returned to rest, but upper-foreleg fur
and the asymmetric source hindleg still need visual correction.

Rigify's full wolf control rig was separately generated after
restoring 117 metarig bone connections (823 controller/auxiliary
bones, including 197 deform bones). **It is NOT yet linked to
the compact skinned skeleton:** its spine/face bone mapping
does not align one-to-one, so attaching them blindly would
risk corrupting the rest pose and paw deformation. Astra should
receive the compact rig only after animation and import QA
passes, not assume the generated Rigify controls drive it.

An initial single-mesh GLB and FBX retained the skinned
33-bone mesh on Blender reimport, but Frostfang has 161,948
triangles; Roblox's [general modeling specifications](
https://create.roblox.com/docs/art/modeling/specifications)
limit an **individual mesh** to 20,000 triangles.
A **separate** Roblox-targeted candidate therefore preserves
all 161,948 triangles across **12 skinned mesh sections**,
maximum 13,496 triangles each, driven by one **34-bone**
skeleton (33 deform bones + non-deforming Root). Both
sectioned FBX and GLB were reimported into Blender and
verified to have 12 skinned sections, one shared rig,
no more than four weights per vertex, preserved world
bounds, and bend-responsive front-leg skin.

**Asset location on the authorized PC (not published or
merged into GitHub):**

`C:\Users\Remko\Documents\Roblox\DungeonMMO_CanineRig_QA\Frostfang_20260923\`

Important files:
`Frostfang_Canine_ExperimentalMaster.blend` — unsplit full
detail skinned working copy;
`Frostfang_Rigify_Fitted_CONNECTED.blend` — corrected wolf
template;
`Rigify_Frostfang_GeneratedControls_CONNECTED_QA.blend` —
independent generated authoring controls, not linked to mesh;
`Frostfang_Roblox_SectionedRig_QA.blend`,
`Frostfang_Roblox_SectionedRig_QA.fbx`,
`Frostfang_Roblox_SectionedRig_QA.glb` — experimental
sectioned candidates;
`sectioned_roundtrip_validation.json` — Blender-only import
checks. The parent directory also contains an
`Frostfang_20260923_EXPERIMENTAL.zip` checkpoint.

**Still NOT done:** actual Roblox Studio import/playback;
grounded continuous walk/turn; full 3D paw/fur deformation
and hindleg symmetry; mouth/jaw and tail control completion;
Astra authoring engine compatibility; visual user approval.
No live dungeon monster, gameplay script, mesh or Roblox
asset was replaced or published.

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

**Next actionable step:** import the experimental sectioned
FBX into an unpublished Studio test place. Verify that all
12 sections share one animatable rig, inspect four paws and
upper-foreleg skin under real limb motion, then fix the
remaining shoulder, hindleg and facial-control issues before
attempting one natural idle/walk cycle. Neither this mesh nor
the mathematical helper is an approved quadruped master yet.
