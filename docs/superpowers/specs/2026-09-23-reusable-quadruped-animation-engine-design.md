# Reusable quadruped animation engine — proposed design

Date: 2026-09-23
Status: DESIGN APPROVED by the owner on 2026-09-23. Implementation and validation pending.
Repository branch: wip/phase-4-test-hud-integration-v1.
Source area: tools/animation/quadruped/engine/.
Development assets: C:/Users/Remko/Documents/Roblox/DungeonMMO_Quadruped_AnimationEngine/.

## Intent and boundary

Deliver a persistent tool with which the owner can create poses, change gait
parameters, combine body-region motion, save/reload editable definitions and
export animations without requesting another generated script. Frostfang
TailSkinV3_Tip is the first experimental subject; a separately saved
modified-proportion copy is the second compatibility fixture.

Use the current development branch for source/documentation through GitHub.
Keep binaries and QA assets in the explicitly requested sibling directory
above; interpret the more general "under the existing project" instruction
as the DungeonMMO project family, with source retained in its repository.
Do not touch production compositions, humanoid tools, original wolf files,
or gameplay. No asset/place publishing, main merge or production integration.

## Reconciled discovery

The initial local checkout is main at 83d6711 with unrelated untracked files.
The current development worktree is DungeonMMO_Phase4_HUD_Integration_v1,
branch wip/phase-4-test-hud-integration-v1, inspected at 6bac63f with clean
status and diff check. Its roadmap index and GitHub identify v1.90 as the
current backend supplement, alongside separate humanoid/quadruped pipelines.
Older supplied Phase4/Depth4 and local v1.54 instructions are historical;
even development continuity-file introductions still reference v1.77.
Before source implementation, append a scoped reconciliation to CURRENT_STATE,
HANDOFF and TEST_MATRIX without rewriting historical acceptance records.
Backend work is independent of this engine.

Existing humanoid work is a rig-specific R15 generator plus separately stored
control poses, not a general quadruped editor. Existing QuadrupedMotionCore
and QuadrupedRigAudit are foundations only; reuse compatible mathematics
after tests, not their fixed 17-role assumptions as a universal schema.

Fresh read-only Blender 5.0.1 audit of the actual requested V3 file succeeded:
one compact armature, 33 bones, one mesh, 80,974 vertices and 161,948 polygons.
The deform root is DEF_spine.004; this source does not have the extra Root
used by earlier sectioned export candidates. Full tail order is
DEF_spine.003 -> DEF_spine.002 -> DEF_spine.001 -> DEF_spine.
Hind-foot lengths differ (approximately 0.161078 versus 0.168585 source units).
Measure all rest matrices rather than mirror one side.

Prior reports identify tail stretching, shoulder skin problems, asymmetric
hind anatomy and a closed muzzle. V3 has not passed actual Studio import.
Existing earlier Studio imports cannot certify its changed weights.
These are rig limitations, not defects this engine may silently conceal.

## Approaches considered

1. Recommended: Blender add-on authoring plus separate Luau runtime and
   Studio import/QA bridge. Reuses the actual source skeleton, editable
   Actions, native timeline and measured IK; keeps runtime Blender-free.
2. Studio-only plugin: convenient native editing, but requires recreating
   mature multi-joint authoring and calibration on an already unverified
   import, and cannot validate source skinning before that import.
3. Standalone custom 3D editor: fully tailored UI, but adds a renderer,
   file bridge and another rest-space implementation without helping
   Frostfang acceptance.

Choose option 1. The installed add-on panel is the finished authoring
interface, not a command-line script the owner must rewrite.

## Component A: profile and adapter

Versioned JSON rig profiles contain profile/family IDs, source skeleton
fingerprint, explicit coordinate convention and units, root/pelvis roles,
ordered spine/neck/head/tail groups, optional jaw/additional groups and
four individually configured limb chains. Bone mappings are exact names
or unambiguous hierarchy paths, resolved once by the adapter.

Calibration captures parent/rest transforms, measured joint positions,
segment lengths, limb bend planes, contact offsets and neutral paw
orientation. Each limb specifies front/hind anatomy, joint swing/twist
limits, IK enable/weight, preferred bend and end-effector/contact role.
Variable chain lengths are supported; canine hocks are not reduced to
a mirrored front-leg elbow. Unsupported or degenerate chains fail with
specific diagnostics rather than guessed rotations.

Blender, Roblox Bone and Motor6D adapters have separate transform conversion
implementations. Shared contracts describe anatomical samples; they never
assume Bone.Transform and Motor6D.Transform are interchangeable.
A Motor6D synthetic fixture verifies that adapter separately. Frostfang
approval applies only to its actual skinned Bone route.

## Component B: authoring and motion

Separate modules own schema validation, rig calibration, gait timing,
foot targets, constrained limb solving, body layers, pose composition,
baking, persistence and UI. Core numeric sampling is deterministic and
testable without Blender.

A definition stores normalized stride/lift/body amplitudes, cadence,
per-leg phase offsets and contact fractions; independently editable
head/neck/spine/tail/jaw channels; named pose layers; duration, looping,
markers and root-motion convention. All resolved output records the
profile and definition versions.

Speed, stride and cadence are linked explicitly: in automatic cadence mode,
speed / stride determines cycle frequency. Manual cadence mode displays
the implied travel speed and any inconsistency; three independent sliders
must not silently produce unavoidable sliding.

Stance targets are anchored in world space while the root moves. Swing
targets follow continuous lift/advance curves with explicit touchdown and
liftoff timing. Paw orientation uses the calibrated contact frame, not
fixed Euler offsets. Per-limb constrained IK respects measured lengths,
anatomical bend preferences and joint limits; unreachable targets report
residual error. Ground sampling is an authoring service with a flat-plane
default and optional scene surface query. Grounded body sway/weight shift
is followed by a leg solve.

Scrubbing reconstructs contact state deterministically from the timeline,
not from the prior preview frame. Loop endpoints and translating-root
cycles must retain phase/contact continuity.

Pose presets store rest-relative local translation/quaternion channels
using profile roles and masks. Arbitrary bone controls remain available,
with profile-specific poses labeled when they cannot be proportionally
retargeted. Layer composition order is documented and stable:
base motion, masked pose/body layers, ground/contact IK, evaluated bake.

## Interface and persistence

Blender sidebar: creature/profile selection and validation; animation/preset
selection; named parameters; independent body groups and limb IK controls;
bone selection/transform controls; save/load pose; save/load animation;
generate/rebuild; bake/export; reset neutral. Native playback, pause,
timeline scrub, FPS/speed and loop range are surfaced or linked clearly.

Rig profiles, animation definitions, pose presets and runtime config live
in separate versioned JSON files. Save uses atomic replacement and explicit
overwrite behavior. Unknown versions, nonfinite numbers, duplicate mappings,
invalid quaternion data and missing required bones fail before scene edits.
A failed operation restores the pre-operation rig and action state.
Reset restores captured neutral transforms and disables engine-owned preview
constraints without deleting the owner's existing animation data.

Generate makes a named editable action on a working copy. Baking samples
evaluated deformation bones into a separate FK action, removing dependency
on Blender-only authoring controls for the exported result. Preserve
procedural definitions as well as editable baked keys; editing baked keys
does not silently change the original generator definition.

## Export and Roblox playback

Create a sectioned export copy as required by Studio mesh limits while
preserving source appearance, topology, skin weights and deformation
hierarchy. Export FBX plus a manifest recording coordinate conversion,
source hashes, bind transforms and bone mapping. Blender round-trip
validation precedes Studio verification but does not replace it.

Studio bridge imports baked animation and retains editable native
KeyframeSequence data when supported by the actual imported hierarchy.
Verify pose paths and evaluated transforms against the Blender reference.
Do not equate successful file export with native Animator playback.

Native temporary sequence registration may support unpublished local
previews; verify availability in the actual Studio context. These session
identifiers are not persistent production animation IDs. Local saved QA
places retain sequences and recreate preview registration. Future published
runtime use needs separately authorized animation asset IDs.

An independent Luau controller accepts an Animator, clip resolver and
runtime configuration. States include Idle, Walk, Run, Turn, Attack, Hit,
Death and registered custom states; absent clips return descriptive errors,
not an invented successful animation. Implement fades, priorities, looping,
speed changes, stop/reset/dispose and death interruption rules.

Masked head/tail tracks omit locomotion joints and use deliberate priorities.
True additive composition is a separate explicit adapter-owned mode or is
baked; do not claim native track blending is universally additive.
Avoid simultaneous Animator and procedural writes to the same joint.
Runtime ground adaptation is optional and separately tested; baked
authoring contact is the initial grounded-movement implementation.
Animation events never grant damage, rewards or gameplay authority.

## Verification and acceptance

Write failing tests before each new behavior. Run adapter, numeric motion,
persistence, Blender integration and Roblox playback suites independently.

Numeric/schema tests: invalid/missing mappings, multiple chain sizes,
rotated coordinate frames, asymmetric measured lengths, joint limits,
unreachable targets, repeatable scrubbing, loop continuity, root-compensated
contact, parameter sensitivity, pose composition and save/reload/edit.

Blender integration: original file hashes unchanged; evaluated bone and
mesh motion; every tail segment including terminal bone; neutral reset;
failed-operation restoration; independent limb enable/disable; procedural
versus baked matrices within documented tolerances. Preserve inherited
deformation failures in the report.

Second fixture: separately copy the wolf, deliberately change proportions,
recalibrate a second profile and regenerate the SAME definition. Check
targets, lengths and visible motion; no claim of all-species compatibility.

Studio: isolated unpublished QA place, confirm latest V3 mesh/skeleton/
weights and material appearance, validate adapter paths, native clip
loading, speed/pause/scrub, idle-walk-idle fades, head/tail layering,
custom state routing and neutral reset. Inspect continuous side/front/
rear/three-quarter playback and retain actual capture clips.

Final owner workflow demonstration: using only installed UI controls,
create a new named custom pose, save/reload/edit it, combine it with a
modified walk or idle, save/reload the animation and export/replay it.
Source scripts invoked behind UI operators are acceptable; hand-writing
new code during this demonstration is not.

Track every requested deliverable as PASS, FAIL or BLOCKED with exact
artifact path, source revision, commands and evidence. Engine functionality
and rig visual acceptance have separate statuses. Never describe the
overall request as complete with Studio or the UI-only demonstration pending.

## Real import boundary

The existing roadmap explicitly records numeric mesh IDs after an earlier
"Upload to Roblox" unchecked import. The user now forbids all Roblox asset
publishing. Inspect a genuinely local-only route before importing V3; do
not repeat a path known to create inventory assets and call it unpublished.
If local V3 import cannot be achieved without upload, record that exact
blocker, continue independent engine work and request a narrowly scoped
choice before any asset-creating import. This is distinct from place publish.

## Implementation sequence after design review

1. Reconcile continuity; prepare isolated development assets and source area.
2. Profile/schema and measured adapters with tests; local-only import probe.
3. Reusable constrained IK, deterministic gait and editable body/pose layers.
4. Persistent Blender UI, JSON round trips, Actions, baking and export.
5. Roblox adapters, native import bridge and independent runtime controller.
6. Generate all four demonstrations and second-profile fixture.
7. Execute UI-only creation workflow, continuous multi-angle Studio QA,
   publish accurate limitations and update the quadruped roadmap.

Do not pause for approval after each component once implementation is
authorized. Continue independent components when a rig/import issue blocks
one validation path. No implementation is claimed by this proposed design.

## References

- docs/roadmap/DungeonMMO_Quadruped_Animation_Pipeline_20260923.md
- docs/roadmap/DungeonMMO_Humanoid_Animation_Pipeline_20260922.md
- docs/roadmap/DungeonMMO_Roadmap_v1_90_C4_Explicit_First_Transfer_Choice_20260923.md
- https://create.roblox.com/docs/reference/engine/classes/KeyframeSequence
- https://create.roblox.com/docs/reference/engine/classes/KeyframeSequenceProvider

