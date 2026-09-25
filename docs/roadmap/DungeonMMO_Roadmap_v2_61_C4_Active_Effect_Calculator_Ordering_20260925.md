# DungeonMMO Roadmap v2.61 — C4 Active-Effect Calculator Ordering

Date: 25 September 2026.  
Branch: `wip/phase-4-test-hud-integration-v1`.  
Previous: [v2.60](
DungeonMMO_Roadmap_v2_60_C4_Owned_Passive_Source_Resolution_20260925.md).

## Goal

Reproduce the Chronicle 4 calculator ordering shared by permanent passives,
timed active buffs and toggles without confusing a learned skill with an
effect that is currently active.

Pinned source remains:

`Neco-spain/l2jadmins_C4-Scions-of-Destiny`  
commit `07f8536384e799f128d44198dd7ab23519660eea`.

## Source effect stacking reproduced

The original C4 effect runtime keeps named stack groups and uses only the
highest `stackOrder` effect in each group. Effects with no stack group remain
independent.

Added
`src/ReplicatedStorage/Core/Shared/C4CombinedStatEffectReference.luau`.

It:

- combines actually-owned passive functions and supplied active/toggle
  functions into one calculator queue;
- applies source order across both origins rather than applying passives and
  active effects as separate Roblox multipliers;
- supports source `add`, `sub` and `mul` operations;
- applies only the strongest currently supplied effect within a named C4 stack
  group;
- keeps effects with stack type `none` independent;
- retains source skill/rank and operation provenance;
- fails closed for unsupported operations, missing source stats or invalid
  passive/active rank types.

Two explicit neutral source bases are represented where the original effect
math requires them:

- `BOW_WPN_VULN = 1`;
- `PHYSICAL_CRITICAL_POWER_ADD = 0`.

## Unified source stat API

`C4UnifiedStatReference.get_with_source_effects(...)` now stages:

1. reviewed C4 equipment;
2. actually owned source passive ranks;
3. supplied currently-active source effects;
4. shared source calculator order;
5. deferred robe MP.

The API deliberately returns
`ActiveEffectStateAuthoritative=false`.

The ordering engine is therefore ready, but the resource boundary must not yet
remove its active-effect blocker: the current live combat services have not
all been wired to one authoritative source-effect state registry.

## Verified source examples

The focused regression covers historical effects including:

- War Cry 78: P.Atk multiplier at 0x30;
- Attack Aura 77 and Might 1068: shared `pAtk` stack group;
- Majesty 82: P.Def 0x30 plus Evasion subtraction at 0x40;
- Accuracy 256: +3 Accuracy at 0x40;
- Vicious Stance 312: flat critical-power addition at 0x40;
- Deflect Arrow 112: bow vulnerability multiplier at 0x30;
- Battle Roar 121: MaxHP multiplier at 0x30;
- Ultimate Defence 110: additive P.Def/M.Def at 0x40.

## Fresh local acceptance

Commit tested:
`0801508622a59c229af909a2d91a8769563a7b7e`.

Both unpublished disposable Rojo builds PASS.

Focused Studio results:

- Base: **8/8 PASS**;
- Dungeon: **9/9 PASS**.

Assertion counts:

- C4SkillRuntimeRulesTest: 13;
- ManaServiceTest: 13 in Dungeon;
- C4NineClassAuthenticatedSkillPreviewTest: 554;
- C4ResourceMigrationBoundaryTest: 43;
- C4CreativeItemSourceMapTest: 61;
- C4LaunchCoreGearSourceTest: 8;
- C4SixSlotPaperdollSourceTest: 11;
- C4OwnedPassiveSourceResolverTest: 7;
- C4CombinedStatEffectReferenceTest: 14.

Evidence directory:

`%TEMP%\DungeonMMO_v261_effect_order_r3`

No Roblox publication, production DataStore mutation or main merge occurred.

## Next backend implementation

Build an authoritative server-only active-source-effect state layer.

It must:

- record an effect only after its existing server combat executor accepts the
  activation;
- remove toggles on explicit deactivation and upkeep failure;
- expire timed buffs from server-owned timing, not client attributes;
- translate creative skill/rank to reviewed C4 source skill/rank;
- expose a detached snapshot for the C4 resource calculator;
- reject learned-but-inactive skills;
- make client-written attributes irrelevant to source-effect state.

Start with existing live toggles whose services already own their state, then
extend the same registry to timed source-aligned buffs.

Only when the relevant live effect paths are authoritative should the
`ActiveEffectOrderingIncomplete` blocker be removed. CP runtime remains the
final fixed blocker after that.

Permanent code and documentation remain GitHub-only. Remote Desktop Commander
is reserved for fast-forwarding, disposable builds and unpublished tests.
