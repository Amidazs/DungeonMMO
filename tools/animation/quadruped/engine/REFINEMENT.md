# Frostfang foreleg refinement — 23 September 2026

Review candidate, not an accepted production or Roblox animation.
Continues the existing engine and WalkV16, following the owner's latest
foreleg/gait request. The earlier suggestion to rebuild joint positions is
not performed in this pass. The original source remains untouched.

## Deliverable
Local QA folder:
`C:\Users\Remko\Documents\Roblox\DungeonMMO_CanineRig_QA\Frostfang_20260923\GroundedWalkTrial_20260923\ForelegRefinement_20260923_E`

- `Frostfang_ForelegRefinement_REVIEW.blend`: editable rig, controls and action.
- `settings.json`: independent fore/hind stride, lift, stance, joint limit,
  paw pitch; per-limb phase offsets and measured sole offsets.
- `Frostfang_FullBody_Side.gif/.mp4` and
  `Frostfang_Foreleg_Closeup.gif/.mp4`.
- `Frostfang_FourViews.gif`: synchronized side, three-quarter, front and rear.
- `audit.json`, `surface_comparison.json`, `regeneration_test.json`.
- `source/engine/`: reproducible source snapshot, including dependencies.

The 250-frame, 24 FPS editable action contains two seconds of still idle,
0.25 seconds of preparatory load transfer, four walking cycles with eased
speed ramps, settling, and final idle. Duration 10.375 seconds. GIFs sample
12 FPS and loop the whole demonstration, with a replay cut after final idle.
The H.264 videos are 700 × 480; they contain actual Blender renders.

## Changes
- Replaced the foreleg constraint's unspecified bend plane with measured
  two-bone IK and a consistent anatomical pole. No bone-length or rest-pose edits.
- Continuous 3-degree scapular sweep replaces the discrete reach-gate scales.
  Shoulder support is measured against a 165-degree extension limit.
- Quintic contact travel and eased lift, independent fore/hind settings,
  zero-travel initial load transfer, and balanced final pose.
- Kept the existing hind IK branch and world paw orientation controls.
  Restored V16's lowered body support. Sole offsets come from actual skinned paws.
- Applied localized, boundary-faded shoulder/upper-leg weight smoothing to
  10,882 vertices, at most four influences. Mesh geometry, topology, materials
  and rest skeleton are retained. Smoothing is intentionally applied once to
  a freshly opened V16 copy, not cumulatively to an edited candidate.
- Input validation happens before clearing actions; neutral calibration is
  cached so repeated motion generation is deterministic.
- Shared-pelvis support re-solves forelegs when the chest shares that ancestor.

## Actual evidence
- 15 Python unit tests PASS, including contact seams, bend direction/lengths,
  independent limb parameters, timeline integration and invalid settings.
- Fresh Blender 5.0.1 generation and every-frame mesh/joint audit.
- Repeated generation: identical records; sampled bone matrix difference 0.
  Invalid cadence/stride/etc. rejected; actual invalid-setting test preserves
  original rig/control actions.
- All 80,974 vertices and 161,948 polygons retained. Geometry/rest fingerprint
  matches V16. Original file SHA256:
  `1b20f5f490c40e96f77d69e8d04d182f2ed0a62606292a208fab572f4f9cdb0b`.
- Front elbow range approximately 139.6–165 degrees. Largest adjacent-frame
  changes 5.17 left / 5.26 right degrees at 24 FPS. V16 was 3.75 / 4.05:
  this is fuller flexion, not a claim of lower peak angular speed.
- Forepaw target residual <= 1.35e-7 Blender units. Strongly toe-weighted
  surface centroid drift during stance <= 0.000655 front and 0.000899 rear.
  Sole-height errors are approximately zero (worst absolute minimum < 6e-7).
- Rear knee maximum 170.33 left / 164.47 right. Largest adjacent-frame
  changes 6.53 / 7.08, versus V16's 16.33 / 9.14. Left standing extension
  increased with sole calibration; original rear anatomical asymmetry remains.
- Identical 26,206 forequarter edges compared through each whole timeline:
  worst stretch ratio 2.609 -> 2.427; maximum edges above 1.5× rest length
  662 -> 540. This improves but does not resolve skin deformation.
- First/final local bone matrices match within 6.86e-7.
- 625 rendered frames cover side/front/rear/three-quarter/foreleg close-up.
  GIFs reopened and duration checked (10.41 seconds); ffprobe confirms H.264,
  700 × 480, 24 FPS, 10.375 seconds.

## Rejected comparison and remaining limits
The doubled-stride F experiment was not selected: rear-right per-frame knee
change reached 15.24 degrees. It also exposed ancestor movement invalidating
forepaw targets; the engine now re-solves those after pelvis support. The
shorter E candidate remains the reviewed output. Do not promote the
`frostfang_v16_stride_review.json` test preset without new full-mesh QA.

Visible forequarter fur deformation is reduced, not eliminated. Rear-leg
asymmetry, tail/under-fur tearing, small mixed-weight toe drift and the
unconvincingly opening muzzle remain unresolved. Rest anatomy has not been
rebuilt. The selected walk remains deliberately short-strided.

No Frostfang native Roblox animation validation is claimed. The currently
connected unpublished Studio test contains the separate humanoid starter
rig, not a compatible Frostfang skinned rig. Earlier synthetic Animator
tests are not evidence for this wolf. Controlled Blender action baking and
real Frostfang native playback remain a separate unresolved engine gate.
No original assets, production place, main branch or Roblox publishing changed.

## Reproduce / adjust
Use the existing engine directory and a new output directory. Native Blender
needs `--factory-startup` so an older installed add-on cannot shadow this source.

```powershell
& 'C:\Program Files\Blender Foundation\Blender 5.0\blender.exe' --background --factory-startup --python tools/animation/quadruped/engine/tools/refine_existing_walk.py -- --settings tools/animation/quadruped/engine/profiles/frostfang_v16_refinement.json --output 'C:\path\to\a-new-QA-folder'
```

Add `render` to render an existing output. Existing blend outputs are refused
during generation. The profile uses calibrated Blender source units and
forward -Y / up +Z. Different limb strides retain stance anchors by deriving
each limb's phase from common root travel; they may therefore have different
cadences. Four complete cycles are guaranteed for the selected equal-stride
profile. Settings are JSON authoring controls, not new sidebar sliders.

Next action: review the E videos/GIFs for motion quality. Further anatomical
and fur repair, or actual Roblox playback, must retain this before/after
evidence; none of those gates is marked resolved.
