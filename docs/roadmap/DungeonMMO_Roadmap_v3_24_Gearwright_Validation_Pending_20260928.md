# DungeonMMO Roadmap v3.24 — Gearwright Validation Pending

Date: 28 September 2026.  
Branch: `wip/phase-4-test-hud-integration-v1`.  
Previous:
[Roadmap v3.23](
DungeonMMO_Roadmap_v3_23_Dwarf_Profession_Model_Accepted_20260928.md).

## Status

**BACKEND IMPLEMENTATION CANDIDATE — Studio and unpublished Play validation
remain pending.**

Do **not** call this checkpoint GREEN yet.

The latest fully accepted gameplay checkpoint remains **v3.21 Ashspeaker
GREEN**. This v3.24 candidate implements the first Dwarf branch, Artisan /
**Gearwright**, against the pinned C4 source while keeping Dwarf character
creation disabled.

Current code checkpoint before this documentation update:
`d7614a50180d72bcce4c711e700ea64eac9f37b9`.

## Pinned source audit

Pinned C4 commit:
`07f8536384e799f128d44198dd7ab23519660eea`.

Exact audited launch rows:

- Dwarven Fighter, source class **53**:
  **15 rows / 9 families** through level 30;
- Artisan, source class **56**:
  **50 rows / 14 families** through level 30;
- Artisan source brackets:
  **16 / 15 / 19** rows at levels **20 / 24 / 28**.

The 14 Artisan families are:

- Summon Mechanic Golem;
- Bandage;
- Stun Attack;
- Vital Force;
- Weight Limit;
- Create Item;
- Blunt Mastery;
- Boost HP;
- Fast HP Recovery;
- Polearm Mastery;
- Light Armor Mastery;
- Heavy Armor Mastery;
- Wild Sweep;
- Crystallize.

The source map has zero intended Artisan rank-schedule gaps.

## Exact Gearwright stats

The class-56 level-30 source template is:

- STR **39** / DEX **29** / CON **45**;
- INT **20** / WIT **10** / MEN **27**;
- **1161 HP / 327 MP / 921 CP** at level 30.

Dwarven Fighter inheritance is registered separately rather than being
flattened into Artisan.

## Creative Gearwright implementation

Independent DungeonMMO class identity: **Gearwright**.

The creative Gearwright families are:

- Clockwork Golem;
- Field Bandage;
- Hammer Shock;
- Restorative Discipline;
- Pack Training;
- Blueprint Training;
- Blunt Training;
- Fortitude;
- Recovery;
- Polearm Training;
- Light Armor Training;
- Heavy Armor Training;
- Wild Sweep;
- Crystallize.

Gearwright is registered as a first-transfer career with its own trainer
schedule. The Dwarf race exists in backend definitions but remains
`CreationEnabled = false`.

## Runtime integration

The candidate reuses shared source authorities rather than introducing
Dwarf-only combat forks.

Implemented source routes include:

- Hammer Shock -> exact source Stun Attack physical/stun route;
- Wild Sweep -> exact target-area polearm route with source radius;
- Field Bandage -> shared exact bleed-negate authority;
- Clockwork Golem -> shared source companion lifecycle;
- Dwarven Fighter active and passive inheritance through authenticated
  `DwarvenFighter` source scope;
- all reviewed Gearwright passive ranks through the existing owned-passive,
  unified-stat and resource boundaries.

The focused service regressions have been expanded to execute these Gearwright
routes when run in Studio.

## Accepted Dwarf profession rule implemented

The profession authority now preserves:

- Dwarven Fighter: **1 gathering + 1 crafting**;
- Gearwright: **1 gathering + 2 crafting**;
- forged class identity alone cannot grant the second crafting slot;
- a third crafting profession remains rejected;
- a second gathering profession remains rejected.

Legacy ordinary characters keep the old persisted `Gathering` +
`Creation` shape. An authenticated Gearwright may additionally own
`Creation2`.

Profile migration, ProfessionService, recipe knowledge and recipe
authorization all use the same server-owned class-aware capacity rule.

## Dwarven Blueprint implementation

Original Create Item rank 1 remains the Dwarven Fighter foundation.

Artisan Create Item ranks 2 and 3 map to Gearwright Blueprint Training ranks
1 and 2. Blueprint authorization requires:

- a genuinely awarded Gearwright;
- the required character level;
- the required Gearwright Blueprint Training rank;
- inherited Dwarf Workshop Craft;
- inherited Dwarf Blueprint Foundation;
- the recipe's profession to be one of the character's actually selected
  crafting professions.

Initial specialist, tradeable outputs are:

- **Gearwright Field Repair Kit** — Blacksmithing / blueprint rank 1;
- **Gearwright Runic Mechanism** — Enchanting / blueprint rank 2.

These are specialist economy components, not blanket stronger replacements for
ordinary profession gear.

## First-transfer quest blueprint

A DungeonMMO-named Gearwright transfer blueprint is registered at levels
18 -> 20 using the original three-smith-test structure, including the
10 + 2 mine trophies and a recovered stolen forge component.

Its physical NPC/enemy/world bindings remain deliberately
`NotImplemented`; this checkpoint does not claim authored Dwarf quest-world
content.

## Aggregate source position

With Dwarven Fighter + Artisan registered, expected tracked source coverage is:

- **23 source paths**;
- **1370 learning rows**;
- **170 unique source skill IDs**;
- **170 source skills / 648 unique rank-effect pairs**;
- **17 / 18 first-transfer source inventories audited**;
- **17 / 18 first-transfer rank schedules mapped**.

Only **Dwarf Scavenger** remains outside the first-transfer source audit.

## Prepared focused validation

Prepared runner:
`scripts/studio/c4_dwarf_artisan_backend_focus.luau`.

It runs the Dwarf audit/progression/profession tests plus the shared source-link,
passive, stat, physical-cast, self-effect and companion regressions.

Expected final marker after a real successful Studio execution:
`VERIFIED_GEARWRIGHT_BACKEND_FOCUS_PASS`.

## Validation completed in this session

Completed:

- fresh Base Rojo build: **PASS**;
- fresh Dungeon Rojo build: **PASS**;
- `git diff --check`: **PASS**;
- worktree clean except the two pre-existing quadruped Python
  `__pycache__` folders.

Not completed because the Roblox Studio integration is not exposed in this
session:

- focused Studio runner execution;
- broader Studio regression;
- genuine unpublished Gearwright Play rehearsal;
- CreatorError inspection from that Play run.

Therefore **Gearwright is not GREEN yet**.

## Exact next action

Do not start Scavenger yet.

When Studio access is available:

1. run `c4_dwarf_artisan_backend_focus.luau`;
2. resolve any genuine regression in GitHub;
3. run the broader backend regression package;
4. perform a fresh unpublished Play rehearsal covering source cutover,
   inherited Dwarf skills, Hammer Shock, Wild Sweep, Bandage, Clockwork Golem,
   two crafting slots and blueprint authority;
5. verify clean rollback and zero project CreatorErrors;
6. only then mark Gearwright GREEN and proceed to Scavenger / Spoil-Sweep.

No `main` merge, Roblox publish, production DataStore mutation or Scavenger
implementation is part of v3.24.
