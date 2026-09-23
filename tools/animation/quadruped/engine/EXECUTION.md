# Execution ledger — 2026-09-23 reusable quadruped animation engine
Plan: docs/superpowers/plans/2026-09-23-reusable-quadruped-animation-engine-plan.md
Owner selected native execution and waived further planning approval pauses.
Baseline: acbbe2398c0db792b252f9beb3b5a2cb81c42c22; concurrent unrelated backend closeout preserved.
Ruling: Use this persistent tracked ledger instead of shell-only scratch scripts on Windows; exact evidence survives handoff.
Pre-flight: tasks 1→2→3→4 share validated dictionaries; 3→5 share evaluated FK action; 5→6 share manifest and local clips; 7 exercises all.
Task 1/2: RED core tests authored; awaiting execution.
Import: two existing local Studio instances contain earlier rigs, not proof of V3 import.
Core RED: python unittest at 519a86c failed ModuleNotFoundError quadruped_core (expected absent implementation).
Ruling: initial IK is bounded anatomical-plane CCD with explicit out-of-plane residual; no universal 3D solver claim. Blender calibration supplies actual planes and rest roll.
Core GREEN: 9/9 tests at aac7cd3; initial non-escalated TEMP write failed on sandbox permissions, rerun with approved disposable access passed unchanged.
Blender RED at 86bf3a9: missing quadruped_blender module, expected.
Local Studio EditableMesh probe: AddBone/weights/CreateMeshPartAsync succeeded, MeshId empty; actual wolf visual/native Animator validation still pending.


## 23 September 2026 — Frostfang V16 foreleg refinement review candidate

The owner requested focused foreleg refinement, preserving the existing wolf
and engine. Source checkpoint `33fa88f` includes the final solver fixes;
subsequent changes document and verify the same candidate. Work remains on
`wip/phase-4-test-hud-integration-v1` in the HUD integration worktree.
Independent backend roadmap work (now v2.05) is not changed by this result.

Detailed evidence, settings, reproduction and local output paths:
[`REFINEMENT.md`](REFINEMENT.md).
Current review output: `ForelegRefinement_20260923_E` under the existing
Frostfang/GroundedWalkTrial QA folder. Editable Blend plus complete
10.375-second side/foreleg MP4s and looping side/close-up/four-view GIFs.

- Consistent foreleg bend plane, continuous shoulder articulation, independent
  front/rear parameters, calibrated paw soles, two seconds idle, four cycles,
  and balanced return. No replacement mesh or rest-bone edits.
- 15 unit tests PASS; actual Blender repeated generation has zero sampled
  matrix difference and rejects invalid settings without clearing actions.
- Full mesh audit: front elbows 139.6–165 degrees; max forepaw target error
  1.35e-7; planted toe surface drift below 0.000899 source units overall.
- Localized shoulder weight smoothing reduces worst identical-edge stretch
  2.609 -> 2.427. Geometry/rest fingerprint unchanged. Skin defects remain.
- The doubled-stride F comparison is rejected for sharper rear-knee motion.
  Keep E's supported stride as the review candidate.

No visual acceptance, complete anatomical repair, or actual Frostfang Roblox
Animator validation is claimed. Rear asymmetry, residual fur/skin deformation,
tail under-fur tearing and closed muzzle remain. No production, main merge or
Roblox publish occurred. Next action: review E's actual motion before choosing
further anatomy/skin work; preserve V16 and E for comparison.
