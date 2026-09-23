# Reusable Quadruped Animation Engine Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans for native execution, or superpowers:subagent-driven-development if the owner selects delegated execution. Steps use checkbox syntax for tracking.

**Goal:** Deliver an editable, reusable quadruped authoring tool and independent Roblox playback controller, demonstrated on Frostfang through actual UI use and continuous Studio playback.

**Architecture:** A Blender add-on wraps a pure Python motion/data core and a measured rig adapter. A versioned export manifest connects baked deformation-bone motion to separate Roblox Bone/Motor6D adapters and a Luau runtime controller. No production composition imports these modules.

**Tech Stack:** Python 3.12 standard-library core/tests; Blender 5.0.1 Python API and mathutils for authoring; JSON data; Luau and Roblox Studio for runtime; FBX and editable KeyframeSequence export.

**Spec:** ../specs/2026-09-23-reusable-quadruped-animation-engine-design.md (owner approved 2026-09-23).

**Status:** PLAN FOR REVIEW. Design committed at f5551898254efa57252fdf40f9bcca10ae0052b1. No engine implementation/tests claimed. Recommended execution: native in this session, because adapter/authoring/export contracts depend closely on the same measured rig.

## Global Constraints

- Source area: tools/animation/quadruped/engine/.
- Development assets: C:/Users/Remko/Documents/Roblox/DungeonMMO_Quadruped_AnimationEngine/.
- Repository branch: wip/phase-4-test-hud-integration-v1.
- No asset/place publishing, main merge or production integration.
- Do not touch production compositions, humanoid tools, original wolf files, or gameplay.
- Write failing tests before each new behavior.
- Blender round-trip validation precedes Studio verification but does not replace it.
- Never describe the overall request as complete with Studio or the UI-only demonstration pending.
- Do not pause for approval after each component once implementation is authorized.
- Keep runtime playback independent of Blender and any AI service.

## Review Focus

1. Reversed, skipped or negative timeline positions must not depend on previous preview state (Task 2).
2. Missing external textures, omitted terminal bones and ambiguous imported names must block a faithful-import claim (Tasks 1 and 5).
3. A failed generate/load/export must preserve the currently selected action, rig transforms and user files (Tasks 3 and 4).
4. An Animator and procedural layer targeting the same joints must not race or leave stale transforms after stop/death (Task 6).
5. Saving to an existing name, truncated JSON or incompatible schema must not silently destroy an editable preset (Tasks 1 and 4).

## Working directory and evidence conventions

All relative paths below are within tools/animation/quadruped/engine/, except
explicit docs/ paths. Use the current branch's existing isolated worktree for
read-only source/tests after a clean fast-forward from GitHub. Do not switch
the unrelated main checkout. Source edits and commits go through GitHub.
Check current branch SHA before each batch; fast-forward only, never force.

The requested development directory contains:
- addon/ — packaged installable add-on copied from the reviewed source revision;
- profiles/, animations/, poses/, runtime/ — editable saved data;
- working/ — independent Blender files;
- exports/ — sectioned meshes, FK animation and manifests;
- qa/ — isolated saved Studio place, JSON reports and continuous captures;
- README.md — installed build revision and launch instructions.

Use unique timestamped export/QA filenames. Validation-only rbxl builds go
to timestamped TEMP paths; a deliberate persistent QA Save As goes to qa/.
Preserve the two user-specified source Blender files and all historical QA
artifacts. Record SHA-256 before and after. Do not interpret write access
to another worktree or sibling folder as automatic sandbox permission:
request tool escalation for the specifically authorized output paths when needed.

Commands below run with engine/ as cwd. Core tests use:
`python -m unittest discover -s tests -v`.
Blender tests use:
`blender --background --python tests/blender_integration.py -- --output <timestamped-qa-directory>`.
Resolve the installed Blender executable explicitly. Tests must exit nonzero
on failure and write counts, tolerances, fixture hashes and unresolved checks.

## File map and contracts

- quadruped_core/schema.py: version/type/finite-value validation.
- quadruped_core/storage.py: JSON load and atomic save with overwrite policy.
- quadruped_core/gait.py: deterministic contact/swing targets and linked speed.
- quadruped_core/pose.py: rest-relative quaternion pose layers and masks.
- quadruped_core/ik.py: measured multi-segment constrained solver.
- quadruped_blender/adapter.py: calibration and rest/local/world conversion.
- quadruped_blender/authoring.py: working copy, evaluation and transactional generation.
- quadruped_blender/bake.py: evaluated deformation-bone FK Actions.
- quadruped_blender/export.py: sectioned mesh/FBX plus versioned manifest.
- quadruped_blender/operators.py, properties.py, panels.py, __init__.py: installed UI.
- profiles/frostfang_v3.json; presets/animations/*.json; presets/poses/*.json:
  mappings and defaults, with no Frostfang names embedded in generic modules.
- runtime/BoneAdapter.luau, MotorAdapter.luau, ClipImport.luau,
  LocalPreview.luau, Controller.luau: independently importable runtime/Studio modules.
- runtime/default.json: state-to-clip, priority, fade, loop and speed configuration.
- qa.project.json: isolated Rojo QA composition only.
- tests/test_schema_storage.py, test_gait.py, test_pose_ik.py:
  standard-library unit tests.
- tests/blender_integration.py; tests/studio/*.luau: real host integration tests.
- README.md, docs/data-format.md, docs/limitations.md: owner-facing documentation.
- docs/testing/quadruped-animation-engine-20260923.md (repository root):
  evidence ledger, including UI-only demonstration and acceptance gaps.

Data contracts use dictionaries with explicit version=1 and kind fields.
Profile: id, family, coordinateConvention, units, bones, roles, groups, limbs.
Definition: id, type, duration, fps, loop, rootMotion, parameters, layers, markers.
Pose: id, profileId or family, channels, mask.
Runtime config: states, transitions, layerPolicy.
Matrix/quaternion layouts and units must be documented and tested before export.

## Task 1: Validated profiles, persistence and measured Frostfang adapter

**Files:** schema.py, storage.py, adapter.py, profiles/frostfang_v3.json,
tests/test_schema_storage.py, tests/blender_integration.py, docs/data-format.md.
Also append scoped reconciliation to repository docs/ai/CURRENT_STATE.md,
HANDOFF.md and TEST_MATRIX.md before source changes.

**Interfaces:**
- validate(data: dict, expected_kind: str) -> dict returns validated data or raises ValueError.
- load(path: Path, expected_kind: str) -> dict; save(path: Path, data: dict, overwrite: bool=False) -> None.
- calibrate(rig, profile: dict) -> dict returns fingerprint, rest matrices,
  measured lengths/contact frames, diagnostics and resolved maps.

- [ ] Read active branch status/head/remotes/worktrees and diff check. Preserve
  the v1.90 backend and separate art roadmap. Record that older continuity
  introductions are historical, not a request to revert current work.
- [ ] Add failing validation/persistence tests before modules exist:
```python
def test_unknown_version_rejected(self):
    with self.assertRaisesRegex(ValueError, "version"):
        validate({"kind": "pose", "version": 999}, "pose")

def test_existing_file_is_not_overwritten(self):
    save(self.path, self.valid_pose)
    original = self.path.read_bytes()
    with self.assertRaises(FileExistsError):
        save(self.path, self.changed_pose)
    self.assertEqual(original, self.path.read_bytes())
```
  Fixtures use TemporaryDirectory and valid pose records from this task's
  documented format. Add malformed/truncated JSON, NaN/Infinity, quaternion
  normalization, duplicate role mappings and missing required role cases.
- [ ] Run test_schema_storage and preserve its actual RED output.
- [ ] Implement strict kind/version validation before filesystem mutation.
  Use a same-directory temporary file, flush and os.replace for authorized
  overwrite. Delete only the operation's own temporary file after failure.
- [ ] Map Frostfang from its actual 33-bone armature. Record deform root
  DEF_spine.004 and all four tail bones including terminal DEF_spine.
  Explicitly allow root/pelvis semantic aliases while prohibiting duplicate
  limb ownership. Measure both hind feet independently.
- [ ] In Blender, calibrate without changing mesh, pose or existing actions.
  Fail missing/ambiguous mappings, zero-length chains, singular transforms,
  unsupported shears and invalid parent order. Report external texture paths.
  Verify rotated rig-object transforms produce equivalent anatomical measures.
- [ ] Run GREEN unit and Blender adapter tests; review exact new files and
  source hash invariance, then commit via GitHub with evidence status.

## Task 2: Deterministic gait, pose layers and constrained IK

**Files:** gait.py, pose.py, ik.py, test_gait.py, test_pose_ik.py,
presets/animations/idle.json, walk.json, look_around.json, tail.json.

**Interfaces:**
- sample_gait(definition: dict, calibration: dict, time: float,
  ground_height: callable) -> dict of root frame and per-limb world contact targets.
- compose_pose(base: dict, layers: list[dict], calibration: dict) -> dict of local channels.
- solve_chain(rest: dict, target: tuple, settings: dict) -> dict with
  joint positions/rotations, residual, convergence and limit diagnostics.
All calls are independent of Blender global state.

- [ ] Write RED tests for stance world-lock, deterministic scrubbing,
  different stride/lift/phase settings, speed-cadence linkage and continuity:
```python
a = sample_gait(definition, calibration, 0.1, flat_ground)
b = sample_gait(definition, calibration, 0.2, flat_ground)
self.assertTrue(a["limbs"]["FrontLeft"]["planted"])
self.assertTrue(b["limbs"]["FrontLeft"]["planted"])
self.assertLess(distance(a["limbs"]["FrontLeft"]["world"],
                         b["limbs"]["FrontLeft"]["world"]), 1e-7)
sample_gait(definition, calibration, 30.0, flat_ground)
self.assertEqual(a, sample_gait(definition, calibration, 0.1, flat_ground))
```
  Define flat_ground(x,y)=0 and distance with math.dist in the test file.
  Use a fixture with FrontLeft stance spanning both sample times.
- [ ] Run RED; implement cycle-index contact reconstruction including negative
  time, stride-derived travel and a continuous swing arc. Auto cadence is
  speed/stride; manual cadence reports implied speed. Zero-speed idle has
  no division by zero. Reject impossible contact fractions.
- [ ] Add RED IK fixtures: two-segment front chain, three-segment hind chain,
  asymmetric lengths, mirrored preferred bend planes, rotated rest axes,
  nonzero paw offset, joint limits, disabled/partial IK and unreachable goals.
  Assert segment lengths stay within 1e-6 fixture units and no limit violations;
  unreachable targets must return a positive residual rather than stretch.
- [ ] Implement bounded iterative solving with preferred rest/bend constraints,
  explicit maximum iterations and convergence tolerances. Preserve paw
  contact orientation as a separate calibrated constraint. Do not fit arbitrary
  Frostfang rotations in generic code.
- [ ] Add pose mask/noncommutative layer-order tests and quaternion shortest-path
  blending, including equivalent q/-q input. Compose body channels before
  grounded leg solving. Include independent jaw when mapped.
- [ ] Run GREEN tests, compare parameter sweeps and loop seams, commit.
  Numeric success does not pass mesh deformation or visual gait.

## Task 3: Reversible Blender generation and evaluated FK baking

**Files:** authoring.py, bake.py, adapter.py, tests/blender_integration.py.

**Interfaces:**
- create_working_copy(rig, destination: Path) -> object.
- generate(rig, profile: dict, definition: dict, poses: dict) -> action.
- reset_neutral(rig) -> None.
- bake(rig, action, frame_start: int, frame_end: int) -> action.
The original action remains available and the bake has a distinct name.

- [ ] Write RED Blender tests using actual Frostfang on a copy. Capture rest
  matrices, active action, constraints and source hashes before each operation.
  Test parameter changes visibly move evaluated bones and skin vertices.
- [ ] Implement calibration-to-bone matrix conversion with Blender rest and
  parent transforms. Preview actions/constraints are engine-owned and named.
  Preserve existing unrelated constraints/actions. On exception restore
  selection, mode, frame, action, pose transforms and owned temporary objects.
- [ ] Generate idle, walk, look-around and full-tail demonstrations from the
  shared definitions. Measure terminal bone and terminal weighted vertex
  movement separately. Record inherited mesh stretch as a rig failure.
- [ ] Sample evaluated deformation matrices per frame into a separate FK action
  using the installed Blender 5 Action API. Compare evaluated source versus
  baked world matrices (translation error <=1e-5 source units; rotation error
  <=1e-4 radians), including endpoint frames and head/tail combinations.
- [ ] Reset and assert captured neutral transforms restored within 1e-6.
  Introduce a mid-generation exception and verify transactional restoration.
- [ ] Run GREEN host tests and save independent .blend demonstrations. Do not
  overwrite originals or treat a bake as proof of Roblox compatibility.
  Review and commit source/evidence.

## Task 4: Persistent authoring UI and editable save/load workflow

**Files:** properties.py, operators.py, panels.py, __init__.py, storage.py,
README.md, presets/poses/alert.json, tests/blender_integration.py.

**Interfaces:** add-on register()/unregister(); operators named
quadruped.load_profile, generate, save_pose, load_pose, save_animation,
load_animation, bake_export, reset_neutral. Operators invoke prior core
interfaces rather than reimplementing motion logic.

- [ ] Write RED tests for UI property -> definition round trip, operator
  cancellation, duplicate save names and failed load preserving current state:
```python
before = snapshot_scene()
result = bpy.ops.quadruped.load_animation(filepath=str(invalid_json))
assert result == {"CANCELLED"}
assert snapshot_scene() == before
```
  snapshot_scene captures active action identity, frame, rig transforms and
  selected profile/definition. invalid_json is a deliberately truncated
  TemporaryDirectory fixture.
- [ ] Implement profile/creature selection, animation selection and all gait
  parameters; separate head, neck, spine, tail and jaw groups; per-limb IK
  enable/weight; individual bone transform controls and pose masks.
- [ ] Expose native play/pause, frame scrub, playback speed, loop range and
  neutral reset. Save definitions and poses as versioned JSON with explicit
  overwrite confirmation. Save named Blender Actions separately.
- [ ] Install from packaged source; reopen Blender and verify registration
  persists and saved files load. No user-written scripts are required.
- [ ] Execute automated operator tests, then real UI interaction through the
  authorized desktop controls. If desktop input is unavailable, label UI
  interaction BLOCKED; operator tests are not a substitute.
- [ ] Review full intended user workflow and commit with accurate evidence.

## Task 5: Export bridge and latest-rig isolated Studio import

**Files:** export.py, runtime/ClipImport.luau, runtime/LocalPreview.luau,
qa.project.json, tests/studio/Import.spec.luau, docs/limitations.md.

**Interfaces:**
- export_bundle(rig, profile: dict, action, destination: Path) -> Path
  returns manifest path.
- ClipImport.build(rig: Model, manifest: table) -> KeyframeSequence.
- LocalPreview.register(sequence: KeyframeSequence) -> Animation.
The last API is Studio-only and never returns a production asset ID.

- [ ] Probe the available local-only Studio mesh route early, before waiting
  on all authoring tasks. Inspect importer behavior without submitting any
  asset-creating operation. Prior unchecked-upload behavior is not safe proof.
  If import requires asset creation, record the blocker and continue Tasks
  2-4/6 and existing-rig synthetic tests; request narrowly scoped authorization
  before any such operation.
- [ ] Write RED export tests for missing texture, absent terminal bone, invalid
  hierarchy, unit/axis conversion and name collisions. Matrix conversion must
  round-trip rest and animated transforms numerically.
- [ ] Create a sectioned copy preserving mesh topology/materials/weights; no
  decimation. Keep each export section within current verified Studio limits.
  Export FBX/animation and JSON manifest with hashes, versions, bind transforms,
  frame times, channel masks and root-motion convention.
- [ ] Reimport into a fresh Blender scene and compare global bounds, skeleton,
  skin influence budget and evaluated animated matrices. Never infer skin
  preservation merely from equal object counts.
- [ ] In the authorized isolated Studio instance verify PlaceId==0 and target
  hierarchy before changes. Import latest V3 only through the permitted route.
  Record actual Bone/Motor6D paths and conversions; build editable native
  sequences. Fail ambiguous/missing bones instead of skipping them.
- [ ] Test local sequence registration and native Animator playback. Save a
  persistent isolated QA place and reopen it, recreating temporary IDs.
  Document any session-only limits explicitly.
- [ ] Commit export/bridge source and actual PASS/FAIL/BLOCKED evidence.
  Do not certify V3 using the old JawV3 place.

## Task 6: Independent Roblox adapters and runtime controller

**Files:** runtime/BoneAdapter.luau, MotorAdapter.luau, Controller.luau,
runtime/default.json, tests/studio/Runtime.spec.luau.

**Interfaces:**
- adapters.new(rig: Model, profile: table): adapter with captureNeutral(),
  apply(channels), reset(), destroy().
- Controller.new(animator: Animator, resolveClip: function, config: table).
- controller:play(state, fade?), setSpeed(speed), pause(), resume(),
  seek(seconds), setLayer(name, clip, weight), clearLayer(name),
  stop(), reset(), destroy().
Invalid states/missing assets fail without stopping the currently valid track.

- [ ] Write RED native Studio tests for fades, independent loop/speed config,
  missing clips, state interruption/death rules, layers and clean disposal:
```lua
local controller = Controller.new(animator, resolveClip, config)
controller:play("Idle")
controller:play("Walk", 0.2)
controller:setSpeed(0.5)
controller:setLayer("Look", lookClip, 1)
controller:clearLayer("Look")
controller:reset()
assertNeutral(rig, capturedNeutral)
controller:destroy()
```
  Test harness resolveClip maps only local registered fixture sequences;
  assertNeutral checks every adapter-owned joint, not only root position.
- [ ] Implement Bone rest-relative transforms separately from Motor6D C0/C1
  conversion. Test each using rotated synthetic fixtures and actual imported
  Frostfang for the Bone route.
- [ ] Implement track lifecycle, fading, priorities and custom-state registry.
  Support Idle/Walk/Run/Turn/Attack/Hit/Death configuration without inventing
  unavailable demonstration clips. Stop/dispose disconnects all callbacks.
- [ ] Mask head/tail tracks to intended joints; reject conflicting procedural
  ownership. True additive behavior must be explicitly composed or baked,
  never described as a guarantee of ordinary Animator blending.
- [ ] Execute actual Play tests for idle-walk-idle, speed and pause/resume,
  layer removal, death interruption, reset and reopening the local QA place.
  Confirm runtime source imports neither Blender nor authoring modules.
- [ ] Commit source/evidence; no production runtime attachment.

## Task 7: Retargeting, UI-only demonstration and continuous visual QA

**Files:** tests/blender_integration.py, README.md, docs/limitations.md,
repository docs/testing/quadruped-animation-engine-20260923.md,
docs/roadmap/DungeonMMO_Quadruped_Animation_Pipeline_20260923.md,
docs/ai/CURRENT_STATE.md, HANDOFF.md, TEST_MATRIX.md.

**Interfaces:** consume all finished user controls and exported artifacts;
no new custom generation script is permitted for the UI-only demonstration.

- [ ] Create a separately saved copy with deliberately altered limb/body
  proportions and a second measured profile. Generate the identical saved
  definition against both; compare length-relative stride and contact
  errors. Do not claim horse/cat compatibility.
- [ ] Through visible UI only create "Frostfang_Alert_Left", save/reload,
  edit head orientation, combine with a modified idle or walk, save/reload
  the definition, bake/export and replay it. Record exact clicks and output
  paths plus continuous capture. No console scripting during this proof.
- [ ] Capture continuous side/front/rear/three-quarter views in Blender and
  actual Studio Play. Inspect mesh continuity, paw sliding, hock bending,
  body weight transfer, tail-tip contribution and loop/transition seams.
  Retain full motion, not only selected successful poses.
- [ ] Run focused core, Blender and native runtime tests at the final source
  revision. Run git diff --check. Avoid unrelated backend suite expansion
  because production compositions remain untouched.
- [ ] Produce a twelve-deliverable ledger with PASS/FAIL/BLOCKED, source SHA,
  output paths, commands/logs, numeric tolerances and visual observations.
  Treat engine behavior and rig acceptance as separate columns.
- [ ] Update continuity and quadruped roadmap with actual evidence only.
  Provide installation, usage, data format, limitations and troubleshooting.
  Review exact diff before the final authorized source/docs commit.

## Completion and blocker policy

Completion requires working persistent UI, editable/reloadable data,
independent Roblox controller, all four demonstrations, second-profile
reuse, actual isolated Studio Play and the UI-only custom creation proof.
Rig deformation failures remain explicit even when engine tests pass.

If no local-only V3 import exists under the no-asset-publish rule, finish all
independent work and deliver a concrete blocked import report. Do not
manufacture Studio evidence, upload secretly, substitute a different wolf
or mark the complete request accepted.

## Plan self-review

- Spec coverage: profile/adapters (1), motion/IK/poses (2), Blender bake (3),
  persistent editor (4), export/import (5), runtime (6), final proof/docs (7).
- Review focus cases are assigned to executable tests in their owning tasks.
- Single data/version convention and shared interface names used throughout.
- Production exclusions, original-file preservation and no-publishing rule
  remain global, including during QA.
- Native execution is recommended, not yet selected by the owner.
