# DungeonMMO Roadmap v2.66 — C4 Resource Regen + Armor Sets

Date: 25 September 2026.  
Branch: `wip/phase-4-test-hud-integration-v1`.  
Previous: [v2.65](
DungeonMMO_Roadmap_v2_65_C4_Combat_Point_Runtime_20260925.md).

## Goal

Audit the remaining source assumptions before any live HP/MP/CP cutover.

The audit found two gaps that were not covered by the v2.65 acceptance:

1. C4 resource-regeneration stats were not present in the unified source stat
   candidate, so source skills modifying `REG_HP_RATE` or `REG_MP_RATE`
   could not compose correctly.
2. DungeonMMO has one visible Body slot, while C4 armor conditions and P.Def
   formulas distinguish Chest and Legs.

Both gaps are now represented and tested before live cutover work continues.

Pinned source remains:

`Neco-spain/l2jadmins_C4-Scions-of-Destiny`  
commit `07f8536384e799f128d44198dd7ab23519660eea`.

## Exact HP/MP/CP regeneration source inputs

Added `C4ResourceRegenSourceRules.luau`.

For ordinary characters it reproduces the pinned C4 calculator inputs:

- HP/CP start from `BaseHpRegen`;
- levels 1–10 add 0.5 to HP/CP;
- levels above 10 use Java integer `(level - 1) / 10`;
- MP adds `0.3 * ((level - 1) / 10)` with integer division;
- HP/CP multiply by level modifier and CON;
- MP multiplies by level modifier and MEN;
- all three use a three-second normal regeneration period;
- movement multipliers are Sitting 1.5, Standing 1.1, Walking 1,
  Running 0.7;
- default HP/MP/CP regen multipliers are 1.0.

Festival, clan-hall, siege and Mother Tree world bonuses remain explicitly
outside the DungeonMMO baseline.

`C4UnifiedStatReference` now includes:

- `REG_HP_RATE`;
- `REG_MP_RATE`;
- `REG_CP_RATE`.

This lets owned passives and active effects use their original source
calculator operations instead of failing on a missing regen stat.

Verified examples include:

- Fast HP Recovery 212 rank 1: +1.1 `REG_HP_RATE`;
- Relax 226 rank 1: +5 `REG_HP_RATE`;
- Mana Recovery 214 rank 1: x1.2 `REG_MP_RATE` only when the original
  Magic-armor condition is truly satisfied.

## Exact C4 armor conditions

Pinned `ConditionUsingItemType` was rechecked.

For Heavy, Light or Magic armor it requires:

- matching Chest; and
- either matching Legs or a matching FullArmor chest.

A chest alone does not satisfy the armor mastery condition.

Added `C4EquipmentConditionRules.luau` and both passive and combined effect
calculators now use that shared rule.

The Apprentice's Tunic source record was corrected from the creative label
`Robe` to the actual C4 armor type `Magic`.

## Creative Body -> source Chest + Legs

DungeonMMO keeps its single player-facing Body slot.

The C4 source bridge now expands each reviewed creative Body into the matching
historical Chest+Legs set:

- Scout Leather Vest / Ironroot Light Vest:
  Leather Shirt 22 + Leather Pants 29;
- Marauder Armour:
  Piece Bone Breastplate 25 + Piece Bone Gaiters 32;
- Stonewatch / Greenward / Ironroot D-grade heavy:
  Brigandine Tunic 352 + Brigandine Gaiters 2378;
- Expert Scout Leather Vest:
  Manticore Skin Shirt 395 + Manticore Skin Gaiters 417;
- Apprentice Mystic Robe:
  Apprentice's Tunic 425 + Apprentice's Stockings 461.

This is a source-stat representation. The creative item names and visible
inventory model remain unchanged.

The Manticore Skin Gaiters source P.Def uses the pinned XML operation value
**51**. The SQL metadata row lists 48, but the live stat XML is the calculator
source used for equipment P.Def.

## Exact FuncPDefMod legs semantics

`C4EquippedStatReference` now includes the original Legs contribution:

- Head deduction: 12;
- Chest deduction: 31 Fighter / 15 Mystic;
- Legs deduction: 18 Fighter / 8 Mystic;
- FullArmor chest triggers the same Legs deduction;
- Gloves: 8;
- Feet: 7;
- level modifier applies after those operations.

Magic chest and stockings 0x60 MP additions are both deferred until after
passive/active modifier stages.

The source resolver now supports a hidden source `Legs` slot and records
Chest `BodyPart` metadata for exact condition evaluation.

`C4CreativeItemSourceMap` reports
`OriginalBodyLegSemanticsIntegrated=true`, and the resource boundary requires
that condition before equipment can be considered migration-ready.

`FullOriginalPaperdollIntegrated` remains false because DungeonMMO does not
claim all historical accessory/enchantment slots. That does not affect the
reviewed current six-slot launch equipment bridge.

## Fresh local acceptance

Commit tested:

`b610d05cbe6cc950b37f3cedc06c19eb96de0d17`.

Fresh Rojo builds:

- Base: PASS;
- Dungeon: PASS.

Focused Studio:

- Base retry: **12/12 PASS**;
- Dungeon: **13/13 PASS**.

Key assertions:

- C4ResourceMigrationBoundaryTest — 47;
- C4CreativeItemSourceMapTest — 69;
- C4SixSlotPaperdollSourceTest — 14;
- C4ResourceRegenSourceTest — 17;
- C4CombatPointRuntimeTest — 18;
- C4CombinedStatEffectReferenceTest — 14;
- C4ActiveSourceEffectStateTest — 17;
- C4PersistentActiveCoverageTest — 4;
- C4NineClassAuthenticatedSkillPreviewTest — 554;
- ManaServiceTest — 13 in Dungeon.

The first automated Base process stalled during Studio startup. It was
terminated without touching the manual Studio session; a clean Base retry
completed 12/12.

Evidence directory:

`%TEMP%\DungeonMMO_v266_body_legs_focus`

No Roblox publish, production DataStore mutation or main merge occurred.

## Current boundary

For a clean reviewed character:

- equipment + exact source body/legs semantics: ready;
- equipment Expertise: ready;
- actually-owned passives: ready;
- authoritative active effects: ready;
- source HP/MP/CP regeneration calculator stats: ready;
- CP runtime capability: ready;
- migration blockers: 0.

Live resource authority remains deliberately disabled:

- `CutoverPrerequisitesReady=true`;
- `CanApplyLive=false`;
- `LiveHealthIntegrated=false`;
- `LiveManaIntegrated=false`;
- `LiveCPIntegrated=false`.

## Next backend implementation

Build the reversible, disabled-by-default live resource cutover service.

It must:

1. take final HP/MP/CP maxima only from the authenticated source boundary;
2. preserve current resource fractions when maxima change;
3. use source `REG_HP_RATE`, `REG_MP_RATE`, and `REG_CP_RATE` on the
   three-second C4 task while source mode is active;
4. leave the existing ManaService/custom Health behaviour untouched while
   source mode is off;
5. configure CP only in source mode;
6. route playable-vs-player damage through CP while NPC damage still bypasses
   CP;
7. reapply safely on respawn;
8. provide explicit disable/rollback;
9. remain disabled by default in production bootstrap;
10. pass isolated and genuine unpublished client tests before any default
    activation is considered.

Permanent scripts and documentation remain GitHub-only. Remote Desktop
Commander is restricted to fast-forwarding, disposable builds and unpublished
tests.
