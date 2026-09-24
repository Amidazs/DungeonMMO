# DungeonMMO backend v2.26 — independent Elven Knight foundation

Date: 24 September 2026. Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v2.25](DungeonMMO_Roadmap_v2_25_Elven_Knight_Source_Inventory_20260924.md).

## Implemented as source, not yet complete gameplay

The Elven Fighter can already save a level-18 `ElvenKnight` choice.
This increment registers its own `GreenwardWarden` class identity,
race-restricted `GreenwardWardenTrainer` and physical mentor
`SentinelIlyra`. It also adds distinct original-world NPCs
`SentinelIlyra` and `WardenCaer` and their first two ordered
server-authenticated Base quest steps in `VerdantOathTrial`.
They do not borrow any Human Knight or Elven Scout identity.

**Only the two Base NPC interactions are bound.** Quest stage three
requires actual original-world `RootboundMarauder` kills and distinct
owner-bound patrol report drops; stage five requires a unique
`ThornboundColossus` boss seal. Neither monster, item transaction
nor full physical return is implemented in this increment. The
existing world binder refuses stage three and the server's real
first-transfer service cannot award the class from an incomplete
quest. The registered trainer intentionally has **zero** skills
until separately purchased, actual-effects skills are implemented.
The progression class has zero teachable abilities and cannot
borrow `OathguardShieldImpact` or `GreenwardScout` skills.

`C4OriginalQuestProgressRules` now correctly requires Elf race
for **both** Elven first-transfer branches. The original Human
three/Elven two fighter branch choice remains unchanged.
Elven Knight has **56** source training rows, **0** mapped,
**0** effect/release certified. Across all 18 original C4
first transfers, five historical source inventories are
recorded, four historical training schedules mapped, and none
has full mechanical and release acceptance.

## New focused checks and pending acceptance

`C4GreenwardWardenFoundationTest` uses a deliberately limited
in-memory world fixture to test original profile saving,
race-separated choice, authenticated ordered NPC stage 1/2,
rejected spoofed evidence, closed unbuilt stage three, no
unearned transfer, no Human Knight skill leaks, empty restricted
trainer and explicit 56-missing coverage. This verifies transaction
logic only, **not physical Studio NPC Play**. A disposable Base
runner is at `scripts/studio/c4_greenward_warden_foundation_focus.luau`.
Its assertions still require execution and logging before PASS.

Next implement the distinct quest enemy instances/owner-bound
drops and completion first, then the rank-levelled Elven Knight
shield/weapon/armour/heal/taunt/defence skills with targeted actual
server-effect Play. Afterward verify natural saved level-1–30
Base/Dungeon/rejoin and the remaining Warrior detached-avatar
and boss defensive-stacking Play. Do not claim historical C4
balance from copied rank names or provisional Roblox formulas.

No main merge, Roblox publication, production DataStore access or
unrelated animation projects. Source/docs only via GitHub; desktop
reserved for safe ff pulls, disposable builds, unpublished Studio.
