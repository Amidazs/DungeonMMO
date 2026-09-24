# DungeonMMO backend v2.31 — Elven Knight common item creation

Date: 24 September 2026. Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v2.30](DungeonMMO_Roadmap_v2_30_Elven_Knight_Defensive_Utility_20260924.md).

The original Elven Knight has separate source common-creation ranks
at 20 and 28. A purchase requires an earned Greenward Warden,
starter recipe reading/common creation, the actual player's one
chosen creation profession and the matching original rank tier.

Eight registered real recipes (two per Blacksmithing, Leatherworking,
Alchemy and Enchanting career) consume owned materials and provide
server-validated output and profession XP. The Elven Knight's new
material-crafted blunt weapon and D-grade heavy armour have exclusive
race, class and (for D-grade) paid expertise equipment gates.
Neither the class award nor trainer grants materials automatically.

The ProfessionService preparation, snapshot and commit checks now
reject the Warden recipes when class, rank, level or chosen creation
profession is missing. One gathering and one crafting choice are
unchanged. The focused isolated Warden fixture includes two real
Blacksmithing crafts and a D-armor craft, and cross-class and
wrong-career denials, but Studio execution remains OPEN.

**Elven Knight source rank schedule: 55/56 mapped, missing only
Bleed Recovery at level 24.** The current RogueBleedService operates
on NPCs, not a real server-owned player bleed; a fake player status
attribute or a cosmetic cleanse would not count as a functional
source rank. Real player bleed application, verified Warden cure
and hostile/client Play must be implemented before completion.

Full exact C4 combat formulas, authentic saved Base/Dungeon/rejoin,
physical advancement quest enemy encounters and full class release
acceptance remain OPEN. No main merge, Roblox publish, production
DataStore mutation or unrelated animation-worktree edits.
