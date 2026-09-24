# DungeonMMO backend v2.29 — Greenward Warden heal and aggro

Date: 24 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v2.28](DungeonMMO_Roadmap_v2_28_Elven_Knight_Three_Passive_Families_20260924.md).

## New separate class skill families

`GreenwardWardenElementalHeal`: 9 separately purchased ranks at
levels 20/24/28 (3/3/3). Existing MageHealService is used for
mana-spent real self/ally healing, injured target selection,
MaxHealth cap, cooldown, owner attribution and safe 0-duration HoT.
Provisional Roblox heal values are 24..64, not proven C4 balance.

`GreenwardWardenCharm`: 9 purchased ranks (3/3/3) and
`GreenwardWardenAggression`: 6 purchased ranks at 24/28 (3/3).
Both use authenticated melee-like enemy target acquisition with
MP cost and zero HP damage. Charm reduces only the casting owner's
own NPC threat through `ThreatService.reduce_threat`. Aggression
uses `ThreatService.taunt` to exceed the current threat leader.
Only the first valid enemy is eligible for either action. Existing
server encounter/proficiency cap applies; no hit/kill reward can
be gained from a zero-damage cast. **The spell-like Charm
targeting is provisional and needs actual C4 range/aim comparison.**

Together with three previously authored passives this maps
**45/56** Elven Knight training-rank schedules. **11 remain**:
Equipment Expertise (1), Common Item Creation (2), Defence Aura
(1), Shield Mastery (2), Ultimate Defence (1), Poison Recovery
(1), Bow Defence (1), Bleed Recovery (1), Attack Aura (1).
Only four first-transfer classes have every source rank scheduled;
five original inventories are audited, and no 18-class whole-game
release acceptance is certified.

Focused in-memory Warden training source now covers all six
rank families, but has not yet run inside Studio. Builds and source
mapping alone do not prove real-client healing, threat, defensive
stacking or physical quest enemy Play. Existing direct source
numbers and Roblox translations require separate formula review.

No main merge, public place publish, production saves or separate
humanoid/quadruped animation edits. Permanent source/docs via GitHub.
