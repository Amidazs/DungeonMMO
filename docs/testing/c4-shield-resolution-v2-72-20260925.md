# C4 Shield Resolution v2.72 — Acceptance Record

Date: 25 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.

## Status

**IMPLEMENTED / ROJO BUILD PASS / FINAL STUDIO FOCUSED EXECUTION PENDING**

Do not describe v2.72 as GREEN until the current focused Base and Dungeon
Studio runner has passed.

## Candidate

Source/test/runner candidate:

`54362bf7fd74a6b4c38c21055322f97e4fa75647`.

## Verified source contracts

The implementation follows the pinned C4 shield path:

- final shield rate × defender DEX bonus;
- bow attacker ×1.3 block rate;
- source 120-degree launch shield angle;
- strict rate > 0–99 block roll;
- reviewed shield power 79;
- reviewed shield rate 20;
- reviewed shield evasion penalty 8;
- strict default perfect-shield threshold where 96–99 succeeds;
- successful ordinary block adds shield defence power to physical P.Def;
- perfect block returns one source physical damage.

## GitHub-first implementation

Permanent source, tests, runner and documentation are edited in GitHub.

The source combat provider remains disabled by default and source-only.

Shield-facing state is not accepted from a client. The source-only service can
accept a trusted server boolean for deterministic integration; the later live
executor must derive the value from server-owned world transforms.

## Local build evidence

The authorised Phase 4 HUD worktree had no tracked or staged local changes
before fast-forward. Two unrelated quadruped Python `__pycache__` folders
remain untracked and untouched.

Fresh unpublished Rojo builds:

- Base: PASS;
- Dungeon: PASS.

Artifacts:

- `%TEMP%\DungeonMMO_v272_Base.rbxl`;
- `%TEMP%\DungeonMMO_v272_Dungeon.rbxl`.

## Final Studio gate still required

Run:

`scripts/studio/c4_v255_v258_resource_focus.luau`

against fresh unpublished Base and Dungeon compositions.

Expected runner label:

`[C4 v2.55-v2.72 Focus]`.

Relevant expected source tests include:

- `C4CombatFormulaReferenceTest`;
- `C4SourceCombatCalculationServiceTest`.

Record actual assertion totals only from the fresh Studio output.

## Safety boundary

No live source damage, Roblox publish, production persistence, `main` merge
or animation work is included in this candidate.
