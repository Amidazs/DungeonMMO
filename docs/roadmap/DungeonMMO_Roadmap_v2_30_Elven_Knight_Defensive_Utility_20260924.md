# DungeonMMO backend v2.30 — Elven Knight defensive utility

Date: 24 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v2.29](DungeonMMO_Roadmap_v2_29_Elven_Knight_Heal_Charm_Taunt_20260924.md).

## Eight more independently bought historical skill ranks

The Elven Knight's equipment expertise (level20), two shield mastery
ranks (20/28), defensive aura (20), ultimate defence (20), poison
recovery (20), bow defence (24) and attack aura (28) are now uniquely
registered under `GreenwardWarden*` IDs. Each belongs only to the
earned Elven Knight identity and its own physical trainer.

Equipment expertise enables a separate Elven Knight D-grade Body item
only after the genuine source quest, mentor receipt and paid rank.
Shield mastery mitigates actual hostile physical attacks only while a
real registered OffHand shield is equipped; the existing combat damage
cap and chip rule still apply. The new defensive/offensive statuses
reuse server-paid, nonstacking, time-limited and bounded cast services.
Ultimate defence immobilizes the player, and a worn shield plus
ultimate defence is **not** allowed to remove all incoming HP damage.

Poison Recovery removes only real server-recorded, curable poison.
Bow Ward protects against EnemyBow only; none of these passives are
free simply from a class label. Aura scope and formula translations
are provisional Roblox self-buff implementations, not proof of exact
original C4 party aura behaviour or combat-stat parity.

## Remaining rank work

The source-rank schedule audit reports **53/56** independently mapped
Elven Knight ranks, with **three** unfinished original rows:
Common Item Creation (20 and 28) and Bleed Recovery (24). The latter
cannot count as gameplay complete until real player bleeding is
supported, rather than merely changing an untrusted player attribute.
Common creation must produce real materials-backed recipes in the
character's ONE chosen crafting profession.

Focused source-rank and isolated trainer/equipment test assertions
were updated but have **not yet run inside Studio**. Previous Build
PASS is not proof of PvE/PvP balance or real-client skill effects.
Physical quest monster spawning, true dungeon owner drops, and
cross-place saved journeys are OPEN. Four other Fighter first-transfer
rank schedules remain mapped, and whole-game C4 release
acceptance is still 0/18 across original first transfers.

No main merge, Roblox publish, production DataStore mutation or
separate humanoid/quadruped animation edits. Permanent edits in GitHub.
