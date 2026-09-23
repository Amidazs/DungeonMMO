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

## Isolated Studio import and four-leg gate — 23 September 2026

**Stage 1 remains OPEN, despite successful import and static bone
deformation.** Imported
`Frostfang_Roblox_SectionedRig_QA.fbx` into a **new, unpublished
local Baseplate place** with Import Preview's `Upload to Roblox`
option unchecked. Studio nevertheless assigned numeric MeshIds
to the imported MeshParts; do not claim no mesh asset was created
in account inventory. No DungeonMMO game or place was published.

Actual imported `Workspace.Frostfang_Roblox_SectionedRig_QA`:
**12 skinned MeshParts**, **12 Motor6Ds**, **32 Bone instances**
(including Root), and an `AnimationController`. Studio did not
create an `Animator`, so the isolated test added one. Scale
corrected via `Model:ScaleTo(0.06)`; the resulting bounding
box is approximately 3.53 × 6.13 × 9.20 studs and its bottom
rests ~0.05 studs above the local Baseplate. The imported
sections look continuous in the saved Studio rest screenshots.

**Actual Studio bone/skin deformation check:** independent
front-left shin 30° -> paw displacement ~0.756 studs;
front-right shin 24° -> ~0.607 studs; hind-left and
hind-right shin -22° -> ~0.463 studs each. Skin visibly
followed the tested bone motions, but these are **individual
static bend poses, NOT walking animations**, and they do not
prove planted paws or good continuous gait. Both hind legs'
rest shape and shoulder fur still need visual refinement.
All test Bone.Transform values were reset to identity;
an Edit-mode audit confirmed 12 meshes, 32 bones, 12 motors,
Animator present, scale 0.06 and a missing jaw.

**Blocking facial-rig finding:** Blender's compact master has
`DEF_jaw` with **zero assigned mesh vertices**. Roblox
omitted that bone during import. Meshy Frostfang's original
80,974-vertex mesh is a **single connected, closed-mouth
geometry island**. A separately saved `JawV3` skinning
experiment added lower-muzzle weights and demonstrated small
vertex movement, but its side/face previews still show
**no convincing mouth opening**: pulling lower-muzzle fur
is not an acceptable bite. Do not promote JawV3 or pass
this wolf to Astra as a complete bite-ready master.
Proper mouth/jaw topology and inner-mouth geometry or an
alternative properly skinned canine with working jaw
are required before custom bite authoring.

**Alternative inspected and jaw-filter correction:** the local
Mesh2Motion fox GLB has a 49-bone canine rig and imported
walk/bite actions. The initial audit filtered only names
containing `jaw`/`mouth`/`lower` and mistakenly omitted
its **independently skinned `Chin` (105 vertices) and
`Chin_Tip` (16 vertices)**. A subsequent Blender jaw
QA rotated `Chin` ±28° and verified displaced chin
vertices (~0.075 source-space units) with visibly opening
mouth in side-view renders. The source fox is a simple
~1,654-triangle mesh, visually unlike Frostfang; its
existing gait and bite have **not** passed full Studio
playback. It is a promising **alternative canine
animation reference/rig**, not proof that Frostfang's
closed original muzzle has been remodeled or an approved
replacement for Frostfang's appearance.

**Persistent isolated Studio place:**
`C:\Users\Remko\Documents\Roblox\DungeonMMO_CanineRig_QA\Frostfang_20260923\Frostfang_StudioRig_Import_QA.rbxl`.
Its neighboring `studio_rest_side.png`,
`studio_left_front_flex.png`,
`studio_bend_FrontRight.png`,
`studio_bend_HindLeft.png` and
`studio_bend_HindRight.png` show the actual import and
static tests. `Frostfang_Canine_ExperimentalMaster_JawV3.blend`,
`jaw_v3_report.json` and the `jaw_v3_*.png` images
record the failed independent jaw experiment.
The earlier source GLBs and the separate Rigify controls
remain untouched; no Roblox place was published and
nothing was merged into production gameplay.

## JawV3 import follow-up — 23 September 2026

**Stage 1 remains OPEN; this is not a validated master rig.**
Continuing from the initial Studio import, a newer **independent
jaw-skinned experimental variant** was prepared from
`Frostfang_Canine_ExperimentalMaster_JawV3.blend`.
It retains the same intact source geometry across 12 skinned
sections (161,948 triangles total; <=13,496 per section), adds
lower-muzzle skin weights and exports a single shared compact
rig in separate FBX/GLB files. Blender round-trip checks
confirmed 12 sections, one 34-bone armature (including the
non-deforming Root), <=4 vertex influences and the imported
jaw `DEF_jaw` retaining ~2,453 weighted section vertices.
A controlled ±24° jaw test displaced selected vertices up to
~0.022 source-space units; **this does not show a real opening
mouth** on Frostfang's single closed muzzle.

**Local PC assets (experimental; not game-production assets):**

`C:\Users\Remko\Documents\Roblox\DungeonMMO_CanineRig_QA\Frostfang_20260923\JawV3_Import_Candidate\`

- `Frostfang_Roblox_SectionedRig_JawV3_QA.blend`
- `Frostfang_Roblox_SectionedRig_JawV3_QA.fbx`
- `Frostfang_Roblox_SectionedRig_JawV3_QA.glb`
- `sectioned_jawv3_jawv3_roundtrip_validation.json`
- `jawv3_skin_roundtrip_validation.json`
- `Studio_JawV3_Rest.png` and
  `Studio_JawV3_Bend_Xminus24.png`
- QA scripts in the parent `DungeonMMO_CanineRig_QA`
  working directory.

**Actual isolated Studio import:** With
`Upload to Roblox` unchecked, `Frostfang_JawV3_QA`
was imported *alongside* the original saved reference into
the unpublished local QA place. It has 12 MeshParts,
12 Motor6Ds, 33 imported Bone instances **including
`DEF_jaw`** (the zero-influence legacy import had only
32), and an Animator created in the isolated QA model
because Studio did not supply one. `Model:ScaleTo(0.06)`
matched the original QA wolf's size. Separate front-left
and hind-right shin articulations displaced the paw
~0.706 and ~0.529 studs, respectively, and each was
explicitly reset (recorded rest error 0). Jaw rotation
visibly affects only a small area of the lower muzzle;
**the source geometry remains closed and the bite is
not visually approved.**

The original reference was retained and
`Frostfang_StudioRig_Import_QA_PreJawV3.rbxl` was saved
as a separate copy of the earlier, independently verified
original QA place. The newer JawV3 variant was tested in
Studio's **Edit session but a new .rbxl checkpoint for it
has NOT yet been verified saved**. A second Studio session
intermittently opened on the shared Windows desktop during
Save As attempts. Those UI operations were halted rather
than risk saving or running commands against another
DungeonMMO place. The Blender/FBX/GLB and screenshot QA
artifacts above *are* saved; do not conflate them with a
saved JawV3 Roblox place.

**Still blocking handoff to Astra:** a real, separately
opening lower jaw and inner-mouth geometry; correction of
source hindleg asymmetry and shoulder fur; consistent
four-paw floor contact; continuous, editable
idle–walk–idle tested with the actual Studio animator
from multiple views; user visual approval. Static bone
motion and geometry round trips are not gait acceptance.
No production DungeonMMO place, scripts or gameplay
were changed or published. Roblox importer assigned
numeric MeshIds even with `Upload to Roblox` unchecked;
account asset creation cannot be ruled out.

**Safe resume:** first confirm only the isolated
`Frostfang_StudioRig_Import_QA.rbxl` is open, inspect its
Edit-mode `Frostfang_JawV3_QA` model, reset every Bone
Transform and save a *separately named* local .rbxl,
verifying its modified timestamp and re-opened contents.
Do not touch a different Studio session. Prioritize
correcting real muzzle topology rather than repeating
numeric `DEF_jaw` tests on closed mesh.

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

**Next actionable step:** repair or replace the source wolf's
mouth and lower jaw so an independent jaw bone opens an actual
mouth in Blender and survives Studio import. In parallel,
repair the asymmetrical hindleg/shoulder fur; then author
one reversible idle–walk–idle clip on the approved real
mesh with grounded paw contact, test continuous playback
from all sides in the isolated Studio place and obtain
user visual approval before assigning Astra the full
quadruped engine. The current model is still experimental.
