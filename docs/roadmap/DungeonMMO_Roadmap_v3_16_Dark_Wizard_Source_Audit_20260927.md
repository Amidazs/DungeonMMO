# DungeonMMO Roadmap v3.16 — Dark Wizard Source Audit

Date: 27 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v3.15](
DungeonMMO_Roadmap_v3_15_Dark_Elf_Assassin_Veilblade_Checkpoint_20260927.md).

## Status

**GREEN — exact Dark Wizard level-30 source inventory audited; gameplay class
intentionally not implemented yet.**

Evidence:
[Dark Wizard v3.16 source audit](
../testing/c4-dark-wizard-source-audit-v3-16-20260927.md).

## Source identity

The next original first-transfer branch after Dark Elf Assassin is Dark Wizard:

- source race: Dark Elf;
- source base class: Dark Mage;
- source class: Dark Wizard;
- source class ID: **39**;
- source transfer level: 20;
- current creative career: **none**.

The source is pinned to C4 `skill_trees.sql` commit
`07f8536384e799f128d44198dd7ab23519660eea`.

## Exact level-30 inventory

The new `C4DarkWizardLevel30Sources` inventory records every separately
purchasable class-39 rank through level 30:

- level 20: **25** rank rows;
- level 25: **31** rank rows;
- level 30: **30** rank rows;
- total: **86** rank rows;
- distinct source skill families: **25**.

No invented level-24 or level-28 mage brackets are present.

The inventory includes the class-39 passive/utility, direct magic, poison,
sleep, corpse drain and two summoning families without treating any of them as
implemented DungeonMMO skills yet.

## Launch-audit integration

`C4Level30LaunchCoverage` now recognizes Dark Wizard as a source-audited
branch. The expected state is deliberately fail-closed:

- `SourceInventoryAuditedThroughCap = true`;
- `CurrentCareerId = nil`;
- `TrainerMappedRankEntries = 0`;
- `MissingRankScheduleEntries = 86`;
- `SourceRankScheduleMapped = false`;
- status = `SourceRanksAuditedClassUnimplemented`.

This raises the number of source-audited first-transfer branches from 11 to
**12**, while mapped trainer schedules remain **11**.

## Validation

Fresh local acceptance:

- `git diff --check`: PASS;
- Base Rojo build: PASS;
- Dungeon Rojo build: PASS;
- `C4DarkWizardSourceAuditTest`: PASS;
- `C4Level30LaunchCoverageTest`: PASS;
- focused source-audit set: **2 / 2 PASS**.

Only the pre-existing quadruped Python `__pycache__` folders remain untracked.

## Next implementation step

Create Dark Wizard as its own earned creative career rather than aliasing
Human Wizard or Elven Wizard. The next increment should establish:

1. independent creative career/trainer/advancement identity;
2. exact Dark Elf Dark Wizard primary-stat/growth template;
3. explicit 86-row class-39 category-to-creative mapping;
4. source-effect reuse only where the historical C4 skill ID/rank is actually
   shared;
5. class-39-specific summon/drain/poison behavior kept independent where its
   source rows differ;
6. focused Studio validation before any Play claim.

No `main` merge, Roblox publish, production DataStore mutation or animation
work was performed.
