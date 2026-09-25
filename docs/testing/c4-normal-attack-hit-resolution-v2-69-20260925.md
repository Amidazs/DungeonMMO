# C4 Normal Attack Hit Resolution v2.69 — Acceptance Record

Date: 25 September 2026.  
Branch: `wip/phase-4-test-hud-integration-v1`.

## Status

**IMPLEMENTED / LOCAL BUILD PASS / STUDIO FOCUSED EXECUTION PENDING**

Do not describe v2.69 as GREEN until the focused Base and Dungeon Studio runner
has passed on the current candidate.

## Candidate

`6c45baec295194ec1fc83535c1c35c92f57c629d`.

## GitHub-first change set

Permanent source and runner changes were made directly in GitHub.

Implemented:

- exact C4 hit-condition multiplication and final 27.5%–98% caps;
- exact 0–999 normal-attack hit roll comparison;
- authenticated source Accuracy/Evasion lookup;
- private server-owned random roll;
- explicit neutral runtime condition multiplier pending positional/night
  integration;
- focused formula and provider regression coverage;
- focused runner extended through v2.69.

No permanent source or documentation edit was made through Desktop Commander.

## Local verification

The authorised Phase 4 HUD worktree was checked before fast-forward.

Tracked changes: none.  
Staged changes: none.

Unrelated untracked files left untouched:

- `tools/animation/quadruped/engine/quadruped_blender/__pycache__/`;
- `tools/animation/quadruped/engine/quadruped_core/__pycache__/`.

Fast-forwarded local worktree to:

`6c45baec295194ec1fc83535c1c35c92f57c629d`.

Fresh unpublished Rojo builds:

- Base: PASS;
- Dungeon: PASS.

Build outputs:

- `%TEMP%\DungeonMMO_v269_Base.rbxl`;
- `%TEMP%\DungeonMMO_v269_Dungeon.rbxl`.

## Studio gate still required

Run `scripts/studio/c4_v255_v258_resource_focus.luau` in the fresh Base and
Dungeon disposable builds.

Expected runner label:

`[C4 v2.55-v2.69 Focus]`.

The runner now includes `C4CombatFormulaReferenceTest` and
`C4SourceCombatCalculationServiceTest`.

Do not record assertion totals until the current Studio run actually emits
them.

## Safety boundary

The source-combat provider remains OFF by default.

Normal hit resolution is source-only:

- no HP change;
- no MP change;
- no CP change;
- no cooldown;
- no threat;
- no status application;
- no publish;
- no production persistence.

PDAM skills are not incorrectly routed through ordinary `calcHitMiss`; the
reviewed C4 `SkillPdam` path remains separate.
