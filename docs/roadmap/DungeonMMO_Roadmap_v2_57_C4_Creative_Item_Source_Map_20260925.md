# DungeonMMO Roadmap v2.57 — C4 Creative Item Source Map

Date: 25 September 2026.  
Branch: `wip/phase-4-test-hud-integration-v1`.  
Previous: [v2.56](
DungeonMMO_Roadmap_v2_56_C4_Resource_Migration_Boundary_20260925.md).

## Goal

Start closing v2.56's original-inventory blocker without guessing historical
stats for every existing DungeonMMO equipment item.

The project now has nine pinned C4 source items from v2.51. v2.57 links only
the current creative equipment that has a clear reviewed counterpart to those
source records and makes every other current item fail closed.

## GitHub implementation

Added
`src/ReplicatedStorage/Core/Shared/C4CreativeItemSourceMap.luau`.

Reviewed creative links:

- `marauder_sword` -> C4 item 1 short sword;
- `greenward_training_mace` -> item 4 club;
- `apprentice_arcane_wand` -> item 6 apprentice wand;
- `scout_dagger` -> item 10 dagger;
- `apprentice_longbow` -> item 13 short bow;
- `scout_leather_vest` -> item 22 light leather shirt;
- `marauder_armor` -> item 25 heavy chest;
- `apprentice_mystic_robe` -> item 425 apprentice robe;
- `marauder_shield` -> item 102 round shield.

A reviewed link means the current item should use that original source stat
record during the future C4 migration. It does **not** mean the current
creative `CombatModifiers` equal C4 values.

`resolve_loadout(equipment)` converts Weapon/Body/OffHand only when every
equipped item has an explicit reviewed link. Mixed reviewed/unreviewed gear
fails the entire conversion. Empty equipment remains a valid naked source
loadout.

Current polearm, D-grade armour, expert armour, quest trial gear, gloves,
helmet, boots and other equipment remain intentionally unsupported until a
real source item is selected and verified for each.

## Tests authored, execution pending

Added
`C4CreativeItemSourceMapTest.server.luau`.

It verifies:

- all nine reviewed current-to-source IDs;
- source/current stat separation remains explicit;
- a reviewed sword/heavy/shield loadout converts to IDs 1/25/102;
- current polearm and D-grade armour fail closed;
- a naked loadout remains valid.

**No v2.57 Rojo or Studio execution is claimed.**

## Resource-boundary status

The v2.56 blocker
`OriginalInventoryMappingIncomplete` remains active because only nine current
equipment items are mapped and the original C4 item catalogue is not complete.

This milestone narrows that blocker without falsely declaring it closed.

## Next implementation

Continue the same source-first path:

1. extend the original item reference beyond the nine starter examples for the
   actually usable launch equipment through level 30;
2. link each current launch equipment item to one reviewed original source item
   or explicitly retain it as compatibility-only gear outside C4 parity;
3. add server-owned loadout conversion to the authenticated resource boundary;
4. then map actually owned passive ranks before active-effect/CP integration.

No main merge, Roblox publication, production DataStore mutation or
art/animation worktree changes. Permanent changes remain GitHub-only.
