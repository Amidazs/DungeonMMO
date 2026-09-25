# DungeonMMO Roadmap v2.60 — C4 Owned Passive Source Resolution

Date: 25 September 2026.  
Branch: `wip/phase-4-test-hud-integration-v1`.  
Previous: [v2.59](
DungeonMMO_Roadmap_v2_59_C4_Six_Slot_Paperdoll_Expertise_20260925.md).

## Goal

Close the next Chronicle 4 migration blocker without granting passive ranks
merely because a character is high enough level to learn them.

Only passives actually present in the authoritative saved
`Progression.Skills` state may contribute to the C4 source-stat candidate.

## GitHub implementation

Added
`src/ReplicatedStorage/Core/Shared/C4OwnedPassiveSourceResolver.luau`.

The resolver:

- verifies the real Human/Elf original class identity;
- inspects the current source class and inherited starter source class;
- considers only source rows available at the current level;
- reads real `Known=true` and `PurchasedRank` state;
- resolves the highest genuinely owned C4 rank per historical passive skill;
- never treats level eligibility as ownership;
- keeps automatic Expertise separate from purchased combat passives;
- recognizes source-mapped non-stat utility passives without sending them to
  the stat calculator;
- surfaces unsupported owned creative passives explicitly;
- surfaces saved creative ranks above the currently reviewed source mapping;
- fails closed whenever either unsupported category is present.

The authenticated resource boundary now feeds those exactly-owned source
passive ranks into `C4UnifiedStatReference.get_with_source_items` together
with the reviewed six-slot source equipment.

For a clean current character it can therefore expose an exact source
item+owned-passive stat candidate without modifying the live Humanoid,
ManaService, combat services or persistence.

## Dynamic blockers

The fixed all-class migration blockers are now:

1. active-effect ordering;
2. live CP runtime authority.

Equipment and owned-passive blockers are dynamic per character:

- invalid/unmapped/under-level equipment adds
  `OriginalEquipmentMigrationIncomplete`;
- unsupported or over-range owned passive state adds
  `OriginalOwnedPassiveMappingIncomplete`.

A clean character with reviewed equipment and owned passives now leaves only
the two fixed blockers.

## Regression coverage

Added
`C4OwnedPassiveSourceResolverTest.server.luau`.

It verifies:

- Human Fighter owned Weapon Mastery analogue rank 3 resolves to source
  skill 141 rank 3;
- owned Fighter Armor Mastery analogue rank 5 resolves to source 142 rank 5;
- first-transfer Human Knight inherits genuinely owned starter Fighter
  passives while also resolving its own source heavy-armour and shield
  masteries;
- an unmapped owned custom combat passive remains explicit and blocks parity;
- a corrupted saved creative rank beyond the reviewed source mapping fails
  closed rather than being clamped or silently granted.

`C4ResourceMigrationBoundaryTest` was extended to prove those ownership
results are part of the authenticated cutover boundary.

## Fresh local acceptance

The Phase 4 HUD worktree was fast-forwarded to
`e6925d66433dae698ef3085a49c38bd304e70466`.

Both disposable Rojo compositions rebuilt successfully.

Final focused Studio results:

- Base: **7/7 PASS**;
- Dungeon: **8/8 PASS**.

Assertion counts:

- C4SkillRuntimeRulesTest: 13;
- ManaServiceTest: 13 in Dungeon;
- C4NineClassAuthenticatedSkillPreviewTest: 554;
- C4ResourceMigrationBoundaryTest: 43;
- C4CreativeItemSourceMapTest: 61;
- C4LaunchCoreGearSourceTest: 8;
- C4SixSlotPaperdollSourceTest: 11;
- C4OwnedPassiveSourceResolverTest: 7.

The first Base automation launch stalled in Studio startup before RunScript.
After the stale automated runner exited, a clean Base-only retry completed
7/7. No production defect was involved.

Evidence directory:

`%TEMP%\DungeonMMO_v260_owned_passives`

No place publish, production DataStore mutation or main merge occurred.

## Next backend implementation

The next fixed blocker is **active-effect ordering**.

The safe path is to reproduce the C4 source operation ordering for active and
toggle effects separately from permanent passives, then define an
authoritative runtime snapshot of which source-equivalent effects are actually
active. A learned or purchased active skill must never be treated as currently
active merely because the character owns it.

After active-effect ordering, CP authority is the final coordinated blocker
before a live all-nine HP/MP/CP cutover can be considered.

Permanent scripts and documents remain GitHub-only. Remote Desktop Commander
is restricted to fast-forwarding, disposable builds and unpublished tests.
