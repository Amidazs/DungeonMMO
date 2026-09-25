# C4 Active-Effect Calculator Ordering v2.61 — Acceptance

Date: 25 September 2026.  
Branch: `wip/phase-4-test-hud-integration-v1`.

## Commit tested

`0801508622a59c229af909a2d91a8769563a7b7e`.

## Fresh build evidence

- Base Rojo build: PASS;
- Dungeon Rojo build: PASS.

Evidence directory:

`%TEMP%\DungeonMMO_v261_effect_order_r3`

## Focused Studio results

Base: **8/8 PASS**.  
Dungeon: **9/9 PASS**.

The new `C4CombinedStatEffectReferenceTest` passes **14 assertions**.

It verifies:

- active 0x30 functions execute before passive 0x40 functions;
- named C4 stack groups choose the highest stack order;
- Majesty applies P.Def and Evasion operations in source order;
- Accuracy toggle applies exact +3 source Accuracy;
- Vicious Stance rank 3 applies exact +64 critical-power addition;
- Deflect Arrow begins from neutral bow vulnerability 1;
- Battle Roar rank 1 applies exact +10% MaxHP;
- Ultimate Defence rank 1 adds exact +1800 P.Def and +1350 M.Def;
- the unified gear/passive/effect source snapshot remains non-live;
- duplicate active source skills fail closed;
- passive ranks cannot be supplied as active effects.

## Important boundary

This milestone certifies **source calculator ordering**, not live effect-state
authority.

`ActiveEffectStateAuthoritative=false` remains explicit, and the live
resource migration boundary still retains its active-effect blocker until the
existing server combat services report real active/toggle state into one
authoritative source-effect registry.

No place was published and no production DataStore was used.
