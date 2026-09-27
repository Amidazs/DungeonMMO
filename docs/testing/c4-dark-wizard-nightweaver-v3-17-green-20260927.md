# C4 Dark Wizard / Nightweaver v3.17 Green Acceptance

Date: 27 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Accepted code/test HEAD:
`a0f32be57fa0daed96733a0deba86fccf55c0d4d`.

## Scope

This record closes the level-30 Dark Wizard / Nightweaver backend gate. It
covers the exact class-39 source catalogue, creative mappings, source stats,
owned passives, active/support state, direct/status/utility/companion routing,
resource migration and genuine unpublished Play behavior.

No production publish, main merge, production DataStore mutation or animation
work is included.

## Catalogue result

- source class ID: 39;
- exact source rows through level 30: **86**;
- mapped source rows: **86**;
- creative/source families: **25**;
- source-map gaps: **0**;
- exact level-30 base resources: **672 HP / 482 MP / 338 CP**;
- exact Dark Elf Wizard MEN bonus: **1.45**.

Concentration is source skill 1078 and is ACTIVE, not PASSIVE. Rank two is a
1200-second target buff whose source modifier subtracts **25** from
`ATTACK_CANCEL_RATE`.

## Interruption source contract

The implemented attack-break calculation follows the pinned C4
`Formulas.calcAtkBreak` behavior:

`15 + sqrt(13 * damage) - ((MEN bonus * 100) - 100) + ATTACK_CANCEL_RATE`

The result is clamped to 1..99 and compared with a private server roll 0..99.

The runtime only evaluates damage against a pending source cast before its
reviewed interrupt deadline. The damage value comes from the trusted
post-resolution player damage path, while MEN and the attack-cancel modifier
come from the authenticated active-inclusive source-stat boundary.

A Studio-only deterministic roll provider exists solely for unpublished
rehearsals; production servers reject that hook.

## Regression evidence

Final post-fix results:

- `git diff --check`: PASS;
- Base Rojo build: PASS;
- Dungeon Rojo build: PASS;
- bridge/interruption focused set: **4 / 4 PASS**;
- full Nightweaver/backend set: **25 / 25 PASS**;
- latest Studio `FLog::CreatorError` count: **0**.

The final 25-suite set included source inventory, launch coverage, primary
stats, advancement, training, skill tree/effect data, creative source mapping,
status/vulnerability behavior, combat calculation/execution, direct/periodic/
companion/support cast services, active source state, owned passive mapping,
unified stats, resource migration, cast-runtime composition, combat formulas
and cast interruption.

## Play evidence

A fresh unpublished Dungeon build ran
`C4NightweaverLiveHarness` through StudioTestService Play mode.

Observed accepted markers:

- `INTERRUPT_PASS damage=200 cast=1`;
- `CONCENTRATION_PASS offset=-25`;
- `PROTECTED_CAST_PASS damage=858.20751953125`;
- `VENOM_REND_PASS landed=true`;
- `INTERRUPT_PLUS_CONCENTRATION_PLUS_DARK_PLUS_VENOM_PASS`;
- `VERIFIED_PLAY_MODE_PASS`.

The same deterministic interruption roll was used on ordinary incoming damage
before and after Concentration. The unprotected cast was cancelled. The
Concentration-protected cast remained pending and later launched normally.

Venom Rend used source 1224:2, MEN resistance, a 1.25 poison-vulnerability
multiplier and a 15-second duration. The accepted run landed and mutated the
reviewed NPC runtime vulnerability state.

## Defect found by Play

The first live attempt correctly interrupted Gale Bolt but left the
DirectMagic bridge's private pending receipt after the shared scheduler was
cancelled. The next cast therefore failed with
`C4DirectMagicCastAlreadyPending`.

The fix moved external interruption cancellation through the source cast
runtime composition. It now probes the cast bridges and invokes
`cancel_cast` on the bridge that owns the shared receipt. This clears the
bridge and scheduler together and retains the scheduler's existing C4 reuse
semantics.

Fresh unit regression and the complete Play rehearsal passed after that fix.

## Repository state

Expected local-only residue after acceptance:

- `tools/animation/quadruped/engine/quadruped_blender/__pycache__/`;
- `tools/animation/quadruped/engine/quadruped_core/__pycache__/`.

These pre-existing folders were not modified or cleaned.
