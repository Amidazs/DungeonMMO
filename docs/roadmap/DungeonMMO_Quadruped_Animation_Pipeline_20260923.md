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
- The parent directory contains
  `Frostfang_JawV3_StudioImport_EXPERIMENTAL_20260923.zip`
  with the JawV3 FBX/GLB, Blender file, validation
  and Studio screenshots; archive contents and CRC
  were checked. It does **not** contain a newly saved
  JawV3 `.rbxl` place.

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
`Frostfang_StudioRig_Import_QA_PreJawV3.rbxl` remains an
independent saved copy of the original QA place. The prior
`Frostfang_StudioRig_JawV3_RECOVERED_UNVERIFIED.rbxl`
recovery file is also preserved.

## JawV3 separately saved and reopened — 23 September 2026

A subsequent **ordinary Roblox Studio Save to File As**
completed successfully while the sole active Studio session
was the isolated Frostfang QA place. The user-facing saved
checkpoint is:

`C:\Users\Remko\Documents\Roblox\DungeonMMO_CanineRig_QA\Frostfang_20260923\Frostfang_StudioRig_JawV3_SAVED_QA.rbxl`

The new saved file is 354,176 bytes, has SHA-256
`6694F613B9409016A195E474076A0B3C21B8CF2D27B771F86A3156F211BE517A`,
and is byte-identical to the earlier recovered snapshot.
The earlier original and pre-JawV3 place are different
files and were not overwritten.

**Reopen verification:** Studio reopened the exact new
`Frostfang_StudioRig_JawV3_SAVED_QA.rbxl` from disk.
Because the first Studio session still had the same file
open, Roblox opened a second instance **read-only** and
displayed the expected file-in-use warning. After dismissing
the warning, the reopened place's Explorer visibly
contained both `Workspace.Frostfang_JawV3_QA` and
`Workspace.Frostfang_Roblox_SectionedRig_QA`, and the
wolf rendered in its neutral pose. The earlier decompressed
RBXL `PROP` inspection independently confirmed those
model names plus `DEF_jaw` and `DMMO_JawV3Status`
in the byte-identical saved snapshot. This verifies the
jaw-enabled QA hierarchy was preserved across Save As and
reopen. It **does not** repeat the 12-section/bone-count
audit on the reopened session, prove mouth separation or
demonstrate a natural continuous walk.

Other DungeonMMO Studio instances intermittently appeared
on the shared desktop during attempted further inspection.
Do not send unguarded screen-coordinate commands or
overwrite either original QA file while multiple sessions
are open. The new QA place is **not** a published game place
or an accepted canine master. The local JawV3 experimental
ZIP mentioned above predates this verified .rbxl and
does not include it.

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

**Safe resume:** close any duplicate *read-only* QA
Studio instance without saving, and when no other
Studio task is running, open only
`Frostfang_StudioRig_JawV3_SAVED_QA.rbxl` for
further isolated tests. Leave the original QA
place and live DungeonMMO game untouched.
Resolve Frostfang's closed-muzzle topology, hindleg
posture and shoulder weights, then author and
inspect one natural continuous idle–walk–idle
clip in Studio before passing it to Astra.


## Frostfang editable motion example — 23 September 2026

**Rig-motion demonstration only: this is NOT a natural walk,
playtested Roblox animation, approved bite, or completed
quadruped engine.** Using the existing experimental JawV3
Blender master, authored and baked a 64-frame, 16 fps,
4-second **editable Blender action** named
`DMMO_Frostfang_Motion_QA_UNAPPROVED`. It shows a short
four-leg **walk-in-place approximation**, returns to rest,
then performs a separate forepaw lift with head and jaw
movement before returning to rest.

Actual evaluated, **weighted Frostfang mesh** geometry
was rendered from synchronized three-quarter and side
cameras into a looping GIF. A six-pose contact sheet
and per-paw displacement report accompany it. This is a
Blender render of the genuine skinned rig—not generated
illustration, not Roblox Animator replay, and not an
example of production-quality locomotion.

**Preview on the authorized PC:**

`C:\Users\Remko\Documents\Roblox\DungeonMMO_CanineRig_QA\Frostfang_20260923\Frostfang_Animation_Example.gif`

All source frames, editable animation, side-by-side GIF,
pose sheet and grounding audit live under the neighboring
`MotionPreview_20260923\` folder. A compact, checked
`Frostfang_Animation_Example_QA.zip` in the parent
Frostfang folder includes the GIF, still sheet, editable
`.blend`, audit, manifest and generator. The animated
GIF opens successfully, has 28 optimized display frames
made from 32 rendered samples and plays for about 3.87
seconds. The independent test scripts are preserved in
[quadruped QA tools](
../../tools/animation/quadruped/qa/FrostfangRigMotion_QA.py).

**Explicit failures and limitations:** the walk is in
place, not root-motion locomotion; its stance paws are
NOT world-locked, visibly lift/slide during the cycle
and must be corrected using the actual mesh/leg anatomy.
An evaluated sample showed resting lowest paw vertices
near 0.026–0.030 Blender units above the test floor,
with varying sampled foot heights during the motion,
up to ~0.060 at a raised paw. The model returned to
its original sampled rest paw heights at the final
frame (measured maximum reported lowest-Z error 0).
The body/head movement is subtle. Source muzzle
topology remains closed even when the jaw-weighted
vertices move; this is **not** an acceptable bite.
The original rear-leg asymmetry and upper-shoulder skin
also remain for visual correction.

The isolated Studio JawV3 QA place is separately saved
as `Frostfang_StudioRig_JawV3_SAVED_QA.rbxl`, and
the animated Blender demonstration does NOT change
that .rbxl or the production DungeonMMO game.
Roblox imported skeleton and static deformation checks
remain separate from the unverified Studio
Animator/keyframe playback for this *new* motion.
Do not pass this test clip to Astra as an approved gait.

**Next motion quality gate:** correct the four-paw
stance support (including rest mesh/ground height),
source hindleg asymmetry and shoulder weighting; give
Frostfang an actual opening lower mouth if the original
appearance must be preserved. Then bake a compatible,
separate `idle → walk → idle` clip for the approved
skinned export and review actual Roblox Studio Animator
playback from side, front and player cameras. Preserve
the existing original, JawV3 QA place and preview files
without publishing or overwriting production assets.

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

## Isolated IK paw-target and actual-mesh audit — 23 September 2026

**Stage 1 remains OPEN; this is NOT a grounded or approved walk.**
After confirming that two Roblox Studio processes had the same saved
JawV3 QA place open, continued exclusively in Blender background mode.
Neither Studio instance nor any existing QA or production place was
modified. No assets were published or attached to live gameplay.

Source-controlled experimental scripts:

- [FrostfangIKWalkTrial.py](../../tools/animation/quadruped/qa/FrostfangIKWalkTrial.py)
  adds four individually keyed IK ankle targets and saves an independent
  72-frame, 24 FPS Blend. The initially attempted Blender API call to
  `bone.constraints.clear()` failed; the committed script now removes
  constraints individually and ran successfully in Blender 5.0.1.
- [FrostfangIKPawMeshAudit.py](../../tools/animation/quadruped/qa/FrostfangIKPawMeshAudit.py)
  evaluates actual skinned toe vertices, not only IK empties, at 11
  frames and writes an independent JSON diagnostic report.

Unpublished local outputs:

`C:\\Users\\Remko\\Documents\\Roblox\\DungeonMMO_CanineRig_QA\\Frostfang_20260923\\GroundedWalkTrial_20260923\\`

- `Frostfang_IKWalk_TARGET_QA.blend` — new editable Blender-only
  trial; it does NOT replace the earlier saved JawV3 Studio place.
- `target_audit.json` — four targets returned to their initial
  positions at frame 1 and frame 72; vertical excursion ~0.044364
  source units. Target rest return is not foot-plant approval.
- `actual_paw_mesh_audit.json` — samples 883/979 forepaw and
  827/933 hindpaw weighted toe vertices respectively. The
  fore-left sampled minimum paw height varied from ~0.0263 to
  0.0684 source units, with horizontal centroid drift; other paws
  also show height and horizontal-position changes. All four
  return to the sampled rest heights at the end. The current gait
  remains unsuitable: **do not label it world-locked/grounded**.

**Remaining blockers:** true continuous paw-mesh world contact and
root-motion coordination, corrected shoulder weights and asymmetric
hindleg anatomy, genuine independently opening lower mouth and jaw,
multiview motion review, actual Studio Animator playback, and visual
approval. Preserve the earlier source, JawV3 files, QA Studio places,
and experimental motion preview. Use current roadmap index v1.88 as
backend/class baseline; the art status is independent of that version.

## Paw-mesh/root-motion investigation and continuous preview — 23 September 2026

**Stage 1 OPEN. Preferred current experimental authoring candidate is
WalkV3, NOT an accepted canine gait, master rig or Roblox clip.**
The latest separate backend supplement on this branch is roadmap
**v1.89 (original C4 starter classes)**; no backend, character-class or
published game acceptance follows from these art-only experiments.

The first independent IK trial was saved separately and audited.
In a further WalkV2 trial the root advanced along the wolf's forward
axis, while four independent ankle-target empties used phased stance
and swing arcs. Actual weighted toe geometry, however, did not follow
the armature object's root movement consistently because the original
experimental mesh had **no parent** (although it had an Armature
modifier). This made moving-target-only metrics misleading and
produced large planted-toe sliding.

**WalkV3** corrects that isolated copy's mesh-to-armature relationship
before keying the same route; it keeps the unchanged original
`Frostfang_Canine_ExperimentalMaster_JawV3.blend` as source and
saves a separate new Blend. Its 72-frame/24-fps mesh audit reported:

- WalkV2 greatest measured planted toe horizontal-centroid drift:
  **0.048764 source units**; greatest planted toe height:
  **0.037068 source units**.
- WalkV3 greatest planted drift across all paws:
  **0.026657 source units**, still on the **hind-right**; its highest
  stance foot point was **0.013578** above test Z=0 and other
  sampled stance points reached **-0.003723** below it.
- On the full measured WalkV3 intervals, front-left drift was
  **0.004522** and the longest front-right interval **0.002176**
  source units. Hind-left remained **0.00815**; hind-right remains
  too poorly grounded to certify the gait. These are source-space
  measurements of actual weighted toe vertices, not visual approval.

**WalkV4 is a rejected, isolated contact-correction experiment.**
A naive iterative approach that nudged ankle targets toward the mesh
contact point produced worse residuals for some legs. A subsequent
finite-difference inspection confirmed **axis coupling/nonlinear
response** on the original hind-right IK chain; moving the target
downward could actually raise measured toe vertices and shift their
horizontal centroid. Do not replace WalkV3, reuse WalkV4's correction
as an engine solution, or mark the four-paw contact gate passed.
Proper anatomical hind-right rig/skin diagnosis, stable foot
orientation and measured IK response are needed before new tuning.

New source-controlled, editable QA utilities live under
`tools/animation/quadruped/qa/`:

- `FrostfangWalkV2.py`,
  `FrostfangWalkV2MeshAudit.py`;
- `FrostfangWalkV3.py`,
  `FrostfangWalkV3MeshAudit.py`,
  `FrostfangIKResponseAudit.py`;
- `FrostfangWalkV4Contact.py` (failed correction preserved for
  diagnosis, not promoted);
- `FrostfangWalkV3Preview.py`,
  `FrostfangWalkV3FullPreview.py`,
  `BuildFrostfangWalkV3Gif.py`.

Local experiments (do not publish, merge or automatically integrate):

`C:\\Users\\Remko\\Documents\\Roblox\\DungeonMMO_CanineRig_QA\\Frostfang_20260923\\GroundedWalkTrial_20260923\\`

The editable candidate and numerical audit are under `WalkV3\\`:
`Frostfang_WalkV3_IK_UNAPPROVED.blend` and
`walk_v3_actual_mesh_audit.json`. A continuous 2-camera,
Blender-rendered **real skinned mesh** preview is at:

`WalkV3\\preview\\Frostfang_WalkV3_Review_UNAPPROVED.gif`

The 1,520×510 GIF was saved and reopened: 34 optimized display frames,
2,970 ms playback, ~9.07 MB. The source sequence includes 37
synchronized side and three-quarter samples per camera, spaced at
two-frame intervals across the 72-frame Blender test; duplicate
display frames may be coalesced during GIF optimization.
Side/oblique inspection showed visible stiffness and lingering
hind-right support problems. This is **Blender output**, not an
actual Studio Animator export/playback.

**Safe next action:** refine the asymmetric rear-leg anatomy, shin
and paw/ankle orientation and associated source skin weights on a
**new** reversible copy. Validate weighted paw contact during every
stance and swing, plus spine/body mass movement, across continuous
front/side/rear views before baking editable FK clips for Roblox.
Frostfang's jaw remains closed original topology; a true opening
lower jaw and inner mouth still require separate mesh work.
Two Studio processes had the same saved JawV3 QA place open at
this checkpoint; neither existing QA place was overwritten or
controlled blindly. No Roblox assets were exported/published, and
no production DungeonMMO runtime or original GLB was altered.

## WalkV5 world-oriented paws and continuous visual QA — 23 September 2026

**Stage 1 remains OPEN; WalkV5 is now the most promising *isolated
motion experiment*, not a finished animal master or approved walk.**
The previous WalkV3, discarded WalkV4 contact-correction trial, and
all original sources remain separate and untouched.

Finite-difference testing on WalkV3 revealed that the source
hind-right ankle target is not a monotonic vertical toe control:
depending on the stance frame, lowering the IK empty can raise the
actual toe mesh and move its horizontal center. The safer experimental
change was to copy each existing foot bone's world-space **neutral
orientation** from a dedicated reference empty, while keeping the
already authored two-bone leg IK and the WalkV3 moving armature.
This was saved to a *new* Blend, not written over WalkV3.

Actual weighted-toe mesh audit (72 frames, 24 FPS) from WalkV5:

- Greatest planted toe horizontal-centroid drift across all four
  legs: **0.003708 source units**, versus **0.026657** for WalkV3.
- Hind-right stance drift: **0.003704–0.003708** during the two
  substantial recorded intervals, but minimum toe height still
  varies between ~0 and **0.007032** above the test floor.
- Front-left: **0.002251** planted drift; longest front-right
  interval: ~**0.000001**; hind-left: **0.00163**.
- These are actual deformed-toe vertex measurements, **not**
  game-scale units, physically verified floor contact, or
  evidence of natural shoulder/hock movement.

The 12 side/oblique stills and a synchronized continuous 2-camera
GIF were rendered from the actual skinned original-looking mesh.
Side and three-quarter inspection still shows a rather stiff
torso/foreleg gait; freezing the paw world orientation is a useful
**contact diagnostic**, not a proven solution for lifelike swing,
turns, uneven floors, or combat. The original muzzle is still
one closed mesh with no genuinely opening bite, and the rear-leg
anatomy and upper-shoulder fur still need correction. Do not
export this as a production Studio clip or hand it to Astra as
an approved quadruped master yet.

Files on the authorized PC:

`C:\\Users\\Remko\\Documents\\Roblox\\DungeonMMO_CanineRig_QA\\Frostfang_20260923\\GroundedWalkTrial_20260923\\WalkV5_PawOrientation\\`

- `Frostfang_WalkV5_UNAPPROVED.blend` — separate editable
  experiment with world-orientation paw reference controls.
- `walk_v5_actual_mesh_audit.json` — full evaluated toe
  geometry and recorded stance intervals.
- `preview\\Frostfang_WalkV5_Review_UNAPPROVED.gif` —
  saved/reopened **1,520×510**, 34 optimized display frames,
  **2,970 ms** playback, ~9.06 MB; derived from 37 source
  Blender samples per camera (identical frames coalesced).
- `preview\\full\\` — 74 side and three-quarter PNG source
  frames plus earlier six-frame-per-view pose checks.

Source-controlled QA scripts:
`FrostfangWalkV5PawOrientation.py`,
`FrostfangWalkV5MeshAudit.py`,
`FrostfangWalkV5Preview.py`,
`FrostfangWalkV5FullPreview.py`,
`BuildFrostfangWalkV5Gif.py` under
`tools/animation/quadruped/qa/`.

**Next gate:** add anatomically credible shifting body mass,
adaptive foot orientation during swing/stance, and hind-right
shin/hock/paw plus skin-weight corrections on a new copy. Review
motion continuously from multiple angles, then bake a stable
independent editable FK idle–walk–idle clip and demonstrate real
Roblox Studio Animator playback in a single isolated QA place.
Do not silently treat IK authoring constraints as exportable Roblox
keyframes. Jaw topology and playable bite remain separate blockers.
The GitHub backend baseline remains **v1.89** and has not been
modified by the experimental art work. No live dungeon place,
Studio QA snapshot, original GLB, or gameplay scripts were changed
or published.

## Stage 1 rig-only articulation and tail-weight repair — 23 September 2026

**Stage 1 remains OPEN. These are new isolated Blender rigging tests,
NOT gait approval or a production master.** The newest separately
maintained backend roadmap on this branch is **v1.90 — explicit C4
first-transfer choice**. Its game/class/quest state is unaffected by
any work described here. No further gait animation was promoted.

### Independent body/joint tests

The actual source-weighted JawV3 Frostfang was posed in an independent
61-frame Blender study: neutral, head yaw, neck/head pitch, tail yaw,
tail pitch, spine flex, and return to neutral. The source mesh was
rendered from side and oblique views, and actual weighted vertex
displacement was measured rather than inferred from bone rotations.

- Head yaw (~11 degrees) deformed sampled head vertices by up to
  **0.066729 source units** without independently moving paw regions.
- Neck/head pitch (~9 degrees) moved sampled head vertices by up to
  **0.056114** source units; small front-paw influence was observed
  (**0.01243** maximum) and is not accepted as perfectly isolated.
- Tail yaw (~12 degrees) moved sampled tail fur up to **0.084477**
  source units without sampled head/paw displacement.
- Spine flex (~7 degrees) moved sampled torso and head as expected,
  but also displaced the front paws: **body movement must eventually
  be coordinated with grounded leg targets**.
- Every measured anatomical region returned to its original neutral
  sampled position at the final test frame.

The tail-lift test exposed severe *real-mesh tearing*, not a missing
animation: nearby connected fur vertices had inconsistent bone
weights. Some adjacent vertices were nearly 100% weighted to
`DEF_spine.004` and the next nearly 100% to
`DEF_spine.003` or another downstream tail segment. The
last bone `DEF_spine` had **zero substantial source weights**
and could not independently flex the tail tip.

Source-controlled read-only tests:
`FrostfangRigFunctionAudit.py`,
`FrostfangTailWeightAudit.py`, and
`FrostfangTailEdgeWeights.py`.

### Non-destructive tail repair experiments

The first V1 tail-smoothing run made no changes because original
weight dictionaries accidentally mixed group names and indices.
The code was corrected in GitHub, then rerun on a fresh untouched
JawV3 copy. The corrected **V1** altered 20,413 source vertices
in the tail area; the severe six-degree bending stretch decreased
from **44.85647×** maximum to **5.23332×**. The 12-degree
test still showed visible pointed fur/folds. V1 was **not promoted**.

A wider/stronger **V2** copy was created independently from the
original JawV3 model. It altered 21,382 tail-area vertices. On
the identical first-tail-segment bend test, the observed largest
source-tail edge stretch fell from **44.85647× to 3.93866× at 6°**,
and from **88.75961× to 7.12904× at 12°**. Side/oblique actual
skinned-mesh renders show smoother movement than the unrepaired
tail, but there is **still an unnatural fold and pointed hanging
fur beneath a lifted tail**. V2 is experimental, not accepted.

A third independent **V3 terminal-tail** candidate starts from
the saved V2 copy (not the original) and gradually assigns weight
to the existing previously unused `DEF_spine` terminal bone.
It modified 4,782 terminal-region vertices. Independent
read-only structural comparison found:

- **Exactly the same skeleton and mesh topology** as the V2 base;
  the evaluated neutral shape changed by at most **0.00000008**
  source units.
- At most **four nonzero skin influences per vertex**, with zero
  vertices above that budget.
- **4,268 terminal-tail vertices** now have measurable tip-bone
  skin weight; the preceding V2 had zero.
- A controlled 6°/12° isolated terminal-bone pitch moved actual
  terminal fur up to **0.031581 / 0.063139** source units;
  the same isolated tip movement in V2 was exactly zero.
- Subsequent full-chain V3 tail-bend checks at 6°/12° recorded
  maximum local mesh-edge stretch of **3.1021× / 5.6092×** for
  the first tested tail segment, **2.6043× / 4.64×** for the
  next, and **2.3346× / 3.7004×** for the following segment.
  These remain **deformation failures for acceptance**, despite
  improved articulation and numerical results.

These QA copies are deliberately independent. Local paths:

`C:\\Users\\Remko\\Documents\\Roblox\\DungeonMMO_CanineRig_QA\\Frostfang_20260923\\RigFunctionQA_20260923\\`

- `Frostfang_RigFunction_UNAPPROVED.blend` and
  `rig_function_audit.json`: original anatomy isolation test.
- `TailRepairV1\\Frostfang_TailSkinV1_UNAPPROVED.blend` and
  `TailRepairV2\\Frostfang_TailSkinV2_UNAPPROVED.blend`:
  two separate tail smoothing candidates, with bend reports
  `tail_skin_v1_audit.json` / `tail_skin_v2_audit.json`.
- `TailRepairV3_Tip\\Frostfang_TailSkinV3_Tip_UNAPPROVED.blend`:
  current **tail articulation experiment**, including
  `tail_skin_v3_tip_audit.json`,
  `tail_skin_v3_structural_validation.json`, and
  `pose_review\\` side/oblique neutral, head, spine,
  tail-base, and independently animated tail-tip PNGs.
  `TailRepairV3_Tip\\pose_review\\
  Frostfang_TailSkinV3_Tip_Poses_UNAPPROVED.blend`
  contains the separate reversible joint test sequence.

New code and audit scripts committed to
`tools/animation/quadruped/qa/`:
`FrostfangTailSkinRepairV1.py`,
`FrostfangTailSkinRepairV2.py`,
`FrostfangTailSkinV1PoseReview.py`,
`FrostfangTailSkinV2PoseReview.py`,
`FrostfangTailTipV3.py`,
`FrostfangTailV3PoseReview.py`,
`FrostfangTailV3StructuralQA.py`,
`FrostfangTailV3BendAudit.py`.
The original source GLB and JawV3 Blender master were not overwritten;
no Roblox production place, script, asset or Studio QA snapshot was
changed or published.

### Remaining Stage 1 blockers

- **Tail:** Improve actual 3D fur continuity during tail-base,
  mid-tail and tip movement, especially the under-tail pointed fold,
  before marking tail skinning acceptable. A 12° bend currently
  produces unacceptable localized stretch. Confirm a repaired
  source is preserved through a skinned 12-section Roblox import;
  no V3 Studio import has been performed.
- **Hind legs and shoulder:** Correct measured source anatomy and
  skin-weight issues on a further separate master candidate.
  WalkV5's foot-contact statistics do not prove these are solved.
- **Mouth:** Original Frostfang muzzle is one closed geometry
  island; adding JawV3 weights did not create an opening mouth.
  Actual split lower-jaw/topology and inside-mouth work (or an
  independently approved alternative) remains necessary.
- **Final rig handoff:** After corrected tail, jaw, leg and neck
  flex pass real multi-angle mesh QA, validate the whole skinned
  candidate in an *isolated single* Studio QA instance. Only then
  pass the master to Astra for an actual reusable canine animation
  system. Do not mistake these discrete pose tests for finished
  head/tail motion during walking or a published Roblox clip.


## WalkV6 isolated forequarter motion trial — 23 September 2026

**Stage 1 still OPEN. WalkV6 is an editable Blender-only QA candidate,
not an approved natural gait or Roblox Studio animation.** The latest
backend roadmap visible when this trial began was v1.98; the art
experiment does not modify that backend track.

The user's request to try improving the engine without Astra led to
a conservative, reversible WalkV6 branch from the saved WalkV5 copy.
The new authoring script adds low-amplitude animated upper-spine pitch
(0.65 degrees), upper-spine roll (0.35 degrees), counter-moving neck
pitch (0.42 degrees), and tail yaw (1.1 degrees), with idle transition
envelopes. The existing WalkV5 four-leg IK targets, paw-world-orientation
constraints, original mesh and original skin weights were not changed.

**Actual background Blender 5.0.1 execution succeeded** and saved
`GroundedWalkTrial_20260923/WalkV6_Forequarter/
Frostfang_WalkV6_UNAPPROVED.blend` on the authorized PC. Separate
actual weighted-toe evaluation of all 72 frames reported greatest
recorded stance drift **0.003708 source units**, equal to WalkV5's
reported maximum; greatest stance height remains **0.007032 source
units** on the hind-right foot. This is *not* an improved grounding
result: hind-right contact still fails, and the very small added
upper-body movements require visual assessment before declaring even
a perceptible improvement.

The actual mesh was rendered from side and three-quarter cameras to
74 PNGs; a 1,520 x 510 looping preview GIF was saved and reopened,
with 34 optimized display frames and 2,970 ms playback. The user can
review the local result at:

`C:\\Users\\Remko\\Documents\\Roblox\\DungeonMMO_CanineRig_QA\\Frostfang_20260923\\GroundedWalkTrial_20260923\\WalkV6_Forequarter\\preview\\Frostfang_WalkV6_Review_UNAPPROVED.gif`

New GitHub development-only helpers in
`tools/animation/quadruped/qa/`:
`FrostfangWalkV6Forequarter.py`,
`FrostfangWalkV6MeshAudit.py`,
`FrostfangWalkV6FullPreview.py`, and
`BuildFrostfangWalkV6Gif.py`.
The independent `walk_v6_actual_mesh_audit.json` and Blend remain
beside the preview in the new WalkV6 QA directory.

**Limitations:** V6 primarily adds subtle body movement and does not
correct the underlying foreleg shoulder weights, hind-right paw
anatomy, tail-fur tearing or the closed lower muzzle. The full visual
result has not been accepted by the user. No Studio Animator playback,
animation export, production asset replacement or publishing occurred.
All older experimental versions, original source assets and Studio QA
places are retained.


## WalkV7/V8 foreleg landing and tail-hindleg isolation — 23 September 2026

**Stage 1 OPEN. WalkV8 is the current isolated Blender-only comparison
candidate, not an approved gait or a Roblox Studio animation.** The
latest backend roadmap visible during this art-only work was **v1.99**
(original first transfers). No backend, original QA place, live
dungeon asset, game, or user-authored rig was changed or published.

The user reported a spring-like jump of Frostfang's front elbows and
tail fur visibly expanding/contracting with rear-leg movement. A
read-only evaluated-Bone/mesh diagnosis of saved WalkV6 found:

- Fore-right elbow changed **23.163 degrees in one 24 FPS frame**,
  fore-left **16.460 degrees** at their worst measured transitions.
  At frame 29 the right foreleg's shoulder-to-ankle reach was
  **0.999690** of its two segment lengths, effectively straightening
  before abruptly bending at ground contact.
- The tail-base source region contains skin assignments crossing
  into the hind-leg chains, including `DEF_thigh.R`,
  `DEF_shin.R`, and `DEF_thigh.L`. This is evidence of a
  plausible pumping contributor, not proof that the entire
  tail shape or prior source tearing is fixed by reweighting.

**Separate experiments, no original overwrite:**

- WalkV7 shifts each front paw's IK ankle target **0.015 source units
  along world Y, toward its measured shoulder at the worst landing
  frame**, and replaces the old abrupt sine vertical lift with a
  shorter, zero-end-derivative squared-sine arc. Max measured
  between-frame elbow change fell to **10.436 degrees (left)** and
  **11.650 degrees (right)**. These remain possible visible catches
  at 24 FPS; the shifted neutral paw position needs review.
- A *separate copy* of WalkV7 removes the suspect hind-leg weights
  from just **196 tail-dominant fur vertices** (355 hind influences),
  redistributing their existing tail-chain weights while retaining
  original mesh topology, all original bones and a maximum of four
  vertex influences. The independent paired source-vs-modified
  comparison measured at most **0.000000219 source units** difference
  at frame 1. The sampled affected fur no longer moves relative to
  the armature during the tested rear-leg cycle, whereas its old
  maximum was **0.006189 source units**. This is diagnostic
  suppression of hindleg-driven bulging, **not proof of natural
  tail deformation**; it may over-stiffen that fur, and unrelated
  previously documented tail-edge tearing remains unresolved.
- WalkV8 adds a further modest 0.007 Y shift and reduces the
  foreleg swing's squared-sine lift by 0.008 source units, on an
  isolated copy retaining the V7 tail test. Worst measured elbow
  change decreased to **8.406 degrees left / 9.114 degrees right**.
  The right foreleg max measured angle was **169.037 degrees**,
  down from **177.147 degrees** on WalkV6. The left max angle is
  **170.917 degrees** and is not an improved left-extension metric.
  These are computed joint-angle results, not visual gait approval.

**Actual weighted-paw acceptance still FAILED:** The V7 and V8
72-frame evaluated-toe audits both report greatest stance horizontal
drift **0.003708 source units** and highest stance sole sample
**0.007032 source units** above the test floor, still the hind-right
leg. The improved front-elbow measurements did not make the rear
contact or original asymmetric hind-leg anatomy correct. The
altered foreleg idle paw positions also differ slightly from
original JawV3 rest and require deliberate calibration.

**Saved local QA files (experimental only):**

`C:\\Users\\Remko\\Documents\\Roblox\\DungeonMMO_CanineRig_QA\\Frostfang_20260923\\GroundedWalkTrial_20260923\\`

- `WalkV7_Foreleg/Frostfang_WalkV7_Foreleg_UNAPPROVED.blend`
  and `walk_v7_actual_mesh_audit.json`.
- `WalkV7_TailIsolation/Frostfang_WalkV7_Tail_UNAPPROVED.blend`,
  `tail_isolation_manifest.json`, `tail_shape_comparison.json`,
  and `preview/Frostfang_WalkV7_Tail_Review_UNAPPROVED.gif`.
- `WalkV8_ForelegTail/Frostfang_WalkV8_UNAPPROVED.blend`,
  `walk_v8_actual_mesh_audit.json`, and
  `preview/Frostfang_WalkV8_Review_UNAPPROVED.gif`.
  The WalkV8 preview was rendered from 74 synchronized side/oblique
  actual-skinned-mesh frames and assembled into a verified looping
  1,520 x 510 GIF (34 optimized frames, 2,970 ms). Visual review
  remains pending.

New source-controlled scripts under
`tools/animation/quadruped/qa/`:
`FrostfangWalkV6JointTailAudit.py`,
`FrostfangWalkV6ReachAudit.py`,
`FrostfangWalkV7Foreleg.py`,
`FrostfangWalkV7JointTailAudit.py`,
`FrostfangWalkV7MeshAudit.py`,
`FrostfangWalkV7TailIsolation.py`,
`FrostfangWalkV7TailCompare.py`,
`FrostfangWalkV7TailFullPreview.py`,
`BuildFrostfangWalkV7TailGif.py`,
`FrostfangWalkV8ForelegTail.py`,
`FrostfangWalkV8JointTailAudit.py`,
`FrostfangWalkV8MeshAudit.py`,
`FrostfangWalkV8FullPreview.py`, and
`BuildFrostfangWalkV8Gif.py`.

**Next:** user compares V6 with V8 GIF in motion. If the elbow
still catches, investigate the actual IK knee-plane and controlled
two-bone pole, not only foot-path smoothing. Review the over-stiffened
tail-base fur for seams and actual 3D bending. Restore correct tail
skin topology and hind-leg anatomy independently. Then re-establish
a neutral grounded idle and bake an editable non-IK clip for actual
Roblox Animator verification. Do not merge or publish this QA motion.


## WalkV9–V13: shoulder-driven canine gait experiments — 23 September 2026

**Stage 1 remains OPEN. WalkV13 is the latest isolated Blender QA
candidate, not a proven natural canine walk or a Roblox animation.**
At this checkpoint the latest separate gameplay/backend roadmap on
this branch is **v1.99**. None of these art-only experiments modify
the live DungeonMMO game, original GLB, saved Studio QA places,
production Rojo tree or published assets.

### Rig anatomy and rejected first attempt

Read-only examination of the actual WalkV8 rig found separate
`DEF_shoulder.L/R` joints parented under
`DEF_spine.008`, each parenting its own front-thigh chain.
Critically, **neither shoulder bone had direct mesh skin weights**.
A canine shoulder cannot visibly move the overlying fur simply by
rotating these unweighted pivots.

WalkV9 keyed opposite-phased shoulder sweeps, chest counter-roll and
pelvis motion on an isolated copy. **Rejected as a gait candidate**:
the front elbows approached **179.7 degrees** and the largest
measured inter-frame elbow change rose to approximately **12.4
degrees**; real weighted paw stance drift increased slightly to
**0.003772 source units**. This candidate was not promoted.

### Reach-limited, mesh-weighted shoulder and supported stance

- **V10** gates the independently keyed shoulder pitch against
  evaluated front-leg elbow reach, using a smooth four-beat stance
  and swing phase with original paw IK targets unchanged.
  Its largest recorded elbow jumps were ~**8.84 degrees (left)**
  and **9.24 degrees (right)**. This is a conservative structural
  improvement, not a visibly approved walk.
- **V11** copies V10 and assigns carefully tapered local upper-chest
  skin to the existing real shoulder bones on the *separate*
  experimental mesh: **1,169 left and 1,230 right vertices**,
  **2,399 total**, zero vertices above the four-influence budget.
  The shoulders now have actual mesh influence. This is experimental
  fur weighting and has not passed all-edge / multi-angle skin QA.
- **V12** retains the skinned shoulders and adds a **0.014
  source-unit supported torso drop**, **0.002-unit step bob** and
  subtle additional chest pitch while preserving the existing
  world-space stance target keys. The actual 72-frame mesh audit
  recorded worst designated-stance toe horizontal-centroid drift
  **0.002045 source units** and highest sampled stance toe height
  **0.003987 source units** above test Z=0. The sampled hind-right
  lowest toe points recorded zero elevation during its designated
  stance intervals, compared with up to **0.007032 units** in V8.
  This does NOT prove every mesh point is grounded or that the
  previously asymmetric hind anatomy has been repaired. Measured
  largest elbow jumps were ~**5.37 degrees left / 5.17 right**.
- **V13** uses V12's new bend/reach allowance to increase independent
  left/right scapular pitch (requested max **5.5 degrees**) while
  limiting actual elbow extension. Saved per-frame pose metadata
  recorded left shoulder approximately **-5.499 to +5.018 degrees**
  and right shoulder **-5.499 to +3.797 degrees**, with 50 frames
  over one degree on each side. The 72-frame constrained-joint
  audit reported largest elbow jumps **5.792 left / 5.634 right**,
  both smaller than V8's ~8.406 / 9.114 degrees. Worst sampled
  stance drift remained **0.002045 units**, and the largest sampled
  stance toe height **0.003987 units**. The old dog/fox rig and
  WolfFactory placeholder were not substituted.

WalkV13 is an **actual saved editable skinned Blender animation**:
`C:\\Users\\Remko\\Documents\\Roblox\\DungeonMMO_CanineRig_QA\\Frostfang_20260923\\GroundedWalkTrial_20260923\\WalkV13_ScapularGlide\\Frostfang_WalkV13_UNAPPROVED.blend`

A separate genuine weighted-mesh side/three-quarter preview was
rendered to 74 PNGs and compiled into the independently verified
1,520 × 510 animated GIF (34 optimized display frames; 2,970 ms;
9,043,745 bytes):

`C:\\Users\\Remko\\Documents\\Roblox\\DungeonMMO_CanineRig_QA\\Frostfang_20260923\\GroundedWalkTrial_20260923\\WalkV13_ScapularGlide\\preview\\Frostfang_WalkV13_Review_UNAPPROVED.gif`

New experimental GitHub scripts under
`tools/animation/quadruped/qa/` include
`FrostfangWalkV9RigInspection.py`,
`FrostfangWalkV9ShoulderGait.py`,
`FrostfangWalkV10ReachAwareShoulders.py`,
`FrostfangWalkV11ShoulderSkin.py`,
`FrostfangWalkV12WeightShift.py`,
`FrostfangWalkV13Scapula.py` and their corresponding
`JointTailAudit`, `MeshAudit`, `FullPreview` and `Gif`
QA scripts where present. The separate V9–V13 Blends are
preserved; none overwrite WalkV8 or any original master.

**Remaining visual/technical blockers:** full-speed visual assessment
of V13 may still show stiff shoulder fur, straight-looking legs,
small stride/limited body mass transfer, unnatural rear-leg posture
and the source tail's underlying skin topology. V7's local
tail-hindleg isolation experiment is retained in these copies,
but independent tail bending/tearing has not been certified.
The source muzzle remains closed and is not bite-ready.
The animated IK authoring controls are **not baked/editable
Roblox Animator FK keys**, and this new motion has **not been
imported or playtested in Roblox Studio**. Do not describe
Blender mesh-pose checks as accepted continuous in-game animation.
Next: user reviews V13 against WalkV8, then resolve any visible
canine gait defects and the source anatomy/skin limitations before
baking a separate animation and verifying actual Studio playback.


## Natural canine walk research and V14–V16 low-lift trials — 23 September 2026

**Stage 1 OPEN. None of these are a natural or accepted canine
walk, an approved master rig, or an exported Roblox animation.**
The newest separate gameplay roadmap checked for this work was
v1.99; the following experiments leave that development track intact.

### Research applied to the requested walk

- The University of Minnesota veterinary gait reference describes
  normal walking as a four-beat sequence, with support lasting longer
  than swing, generally two or three feet supporting the body, and
  coordinated head, trunk and tail movements:
  https://vanat.ahc.umn.edu/gaits/walk.html
- A canine limb function review discusses considerable contribution
  of shoulder-blade movement to forelimb reach; the existing wolf
  source required independently weighted shoulder bones in V11:
  https://pmc.ncbi.nlm.nih.gov/articles/PMC7606876/
- Dogs are digitigrade, but **digital and metacarpal/metatarsal
  pads** (not only claw/toe tips) bear ground contact. A pointed
  or hovering pad does not count as a grounded walk:
  https://pmc.ncbi.nlm.nih.gov/articles/PMC5769641/
- Normal joint motion is not a simple sinusoidal upper- and lower-
  leg hinge, and walking forelimb posture includes shoulder,
  elbow, carpal and metacarpophalangeal joint dynamics:
  https://pubmed.ncbi.nlm.nih.gov/8669773/
  https://pubmed.ncbi.nlm.nih.gov/12755302/

### Discarded unsupported longer-stride variants

**WalkV14** attempted an independent 0.105-source-unit stride,
synchronized root travel and a low 0.019-unit swing arc on the V13
mesh. **Rejected:** the right elbow extended to ~179.749° and
changed ~20.107° between consecutive 24-FPS frames. Maximum
designated-stance toe drift rose to 0.009349 source units, and
highest toe elevation to 0.026412. Both exceed V13's accepted
*numeric comparison values*; neither V13 nor V14 passed overall
visual gait acceptance.

**WalkV15** added 0.040 units of extra torso drop and reduced
stride to 0.100 and paw lift to 0.012. **Rejected as a natural
walk:** the front-right elbow still reached ~179.734° and jumped
~20.962° over one frame. The 72-frame sampled stance drift was
0.003011 and highest toe elevation 0.003987. A nicer ground
height alone does not repair an unstable foreleg IK chain.

The trials confirm that simply extending the old target stride
while moving the existing body pushes this particular source rig
into near-straight foreleg singularities. Do not promote the V14
or V15 motion to production or represent either as authentic
four-beat wolf walking.

### WalkV16 — conservative lower-lift paw-flex comparison

WalkV16 starts afresh from the intact V13 *copy* and preserves the
tested lower torso, existing shoulder skin experiment, four-beat
stance intervals and short original stride. Each swing is lowered
to a 0.012 forepaw / 0.014 hindpaw clearance target from the
original 0.020 / 0.035, and the separate paw-world-reference controls
allow at most 7° foot flexion while airborne, returning to neutral
world orientation at stance. No production source mesh or original
master has been touched.

The independent 72-frame actual-joint check measured largest
between-frame elbow changes **3.748° left / 4.053° right**, versus
V13's 5.792° / 5.634°. The sampled toe-mesh stance audit remained
**0.002045 source units** worst horizontal drift and **0.003987
source units** greatest stance elevation. This is a conservative
numerical improvement, **not proof of natural footpad loading**.
The source paws still have uncorrected sole/pad joint anatomy and
the original short walk has too little rear-to-front foot
progression to be considered convincing natural travel. Side
and three-quarter rendered snapshots were inspected; the whole
gait still shows visible front-leg rigidity and constrained
paw movement. User visual acceptance is pending.

Source-controlled experimental scripts under
`tools/animation/quadruped/qa/`:
`FrostfangWalkV14NaturalStride.py`,
`FrostfangWalkV15SupportedStride.py`,
`FrostfangWalkV16PawPad.py` and their `JointTailAudit`,
`MeshAudit`, `FullPreview` and `Gif` scripts.
All three experiments have their own local folder below
`GroundedWalkTrial_20260923`; only the V16 current
comparison has been fully rendered into a verified 1,520 × 510
34-frame animated two-view GIF:

`C:\\Users\\Remko\\Documents\\Roblox\\DungeonMMO_CanineRig_QA\\Frostfang_20260923\\GroundedWalkTrial_20260923\\WalkV16_PawPadGait\\preview\\Frostfang_WalkV16_Review_UNAPPROVED.gif`

Editable candidate:
`WalkV16_PawPadGait/Frostfang_WalkV16_UNAPPROVED.blend`.

**Important next gate:** stop tuning gait timing as if that alone can
fix the original anatomical limitations. Rebuild the experimental
front and rear limb joint positions and IK bend planes on a distinct
source copy, correctly define footpad and toe-ground contact geometry
and weight the shoulder, carpus, hock and toe joints for full
range-of-motion. Only then author a longer supported stride and
record real pad contact + continuous front/side/rear visual QA.
Retain V13 and V16 for honest before/after visual comparison. The
still-unfixed jaw and original tail under-fur tearing remain separate
issues. Do not publish, import into production or claim Roblox
Animator validation.
