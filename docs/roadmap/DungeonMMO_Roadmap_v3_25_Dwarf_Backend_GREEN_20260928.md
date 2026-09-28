# DungeonMMO Roadmap v3.25
## Dwarf first-transfer backend GREEN — world binding pending
**Date:** 28 September 2026

This checkpoint closes the level-30 source/backend catalogue for both Dwarf
first transfers without claiming that Dwarf is ready for fresh character
creation or fully world-bound gameplay.

## Accepted Dwarf class model

- Dwarven Fighter remains the common Dwarf starter authority.
- **Gearwright** is the independent DungeonMMO career backed by C4 Artisan
  class 56.
- **Deepclaimer** is the independent DungeonMMO career backed by C4 Scavenger
  class 54.
- Gearwright profession capacity is **1 gathering + 2 crafting**.
- Deepclaimer profession capacity is **2 gathering + 1 crafting**.
- A copied class label cannot unlock either extra profession slot. The matching
  persisted first-transfer quest proof and mentor receipt are required.

## Source catalogue closure

The tracked launch catalogue now contains:

- **24 source paths**
- **1419 source learning rows**
- **171 unique source skill IDs**
- **18/18 first-transfer source inventories audited**
- **18/18 first-transfer rank schedules mapped**

Dwarf source details:

- Dwarven Fighter: **15 starter rows**
- Artisan / Gearwright: **50 rows** at 20/24/28 = **16 / 15 / 19**
- Scavenger / Deepclaimer: **49 rows** at 20/24/28 = **15 / 15 / 19**
- Gearwright level-30 source resources: **1161 HP / 327 MP / 921 CP**
- Deepclaimer level-30 source resources: **1197 HP / 327 MP / 834 CP**

The Scavenger bracket distribution was corrected during real Studio
validation. The 49-row total never changed; the earlier 14/12/23 summary was
a counting error and the pinned class-54 rows prove 15/15/19.

## Transfer quests

Both Dwarf transfer blueprints use the pinned C4 start-level exception:

- Q418-shaped Gearwright trial starts at **level 19**, transfers at 20.
- Q417-shaped Deepclaimer trial starts at **level 19**, transfers at 20.
- Deepclaimer's bear/tarantula proof requires server-verified Spoil ownership;
  an ordinary kill cannot satisfy those steps.
- Gearwright and Deepclaimer proof milestones survive profile
  sanitize/save/reload and feed the same one-use mentor award authority as the
  previously accepted first transfers.

## Spoil / Sweep authority

Deepclaimer now has a separate server-owned secondary salvage system rather
than replacing normal loot or gathering professions.

- Spoil binds a living enemy to one owner.
- Another player cannot steal the mark.
- Sweep requires the marked enemy to be dead and the claiming player to own
  the mark.
- One corpse can be Swept once.
- Inventory failure releases the claim lock rather than consuming the corpse.
- Specialist salvage is tradeable and separate from normal Mining/Skinning/
  Herbalism output.
- Spoiled, unclaimed dungeon corpses use the existing post-loot harvest
  boundary and remain visible for **45 seconds** instead of normal 0.15-second
  retirement.
- Already-Swept or ordinary unspoiled enemies do not gain that extended
  retention.

Spoil Festival retains exact source skill metadata, including source radius
**200**, but the live Roblox area resolver is deliberately still unbound.
No source-unit-to-stud conversion has been guessed.

## Studio acceptance

Fresh Rojo validation place built from the branch and executed in genuine
Studio Play.

Accepted markers:

- `VERIFIED_DWARF_BACKEND_FOCUS_PASS 25`
- `VERIFIED_DWARF_CORPSE_RETENTION_PASS`
- `VERIFIED_DWARF_LIVE_SPOIL_SWEEP_LIFECYCLE_PASS`

The combined backend package passed all 25 focused suites. The live Workspace
rehearsal then proved:

1. living NPC receives player-owned Spoil,
2. NPC dies,
3. actual `DungeonEnemyCleanup` normal-loot boundary retires it without
   hiding/destroying the spoiled corpse,
4. Sweep grants exactly one specialist salvage item,
5. replayed Sweep is rejected and grants nothing.

During validation, three test/data-accounting issues were corrected rather
than masking them:

- Gearwright source audit totals were updated for the newly added Scavenger
  path.
- Dwarf profession fixtures were given the complete persisted quest shape
  required by migration (`Count` and `AppliedEvents`).
- Scavenger's correct source bracket distribution was fixed to 15/15/19.

## What is GREEN

The following are accepted backend/runtime contracts:

- both Dwarf first-transfer identities and one-use mentor awards;
- exact source rows, mappings and source resource templates through level 30;
- Dwarven Fighter passive/active inheritance into both careers;
- class trainer authority;
- class-specific profession capacities and save/reload behavior;
- Gearwright Q418-shaped proof progression;
- Deepclaimer Q417-shaped Spoil-dependent proof progression;
- server-owned Spoil/Sweep ownership, claim and reward semantics;
- spoiled corpse retention through the actual dungeon cleanup boundary.

## What is deliberately not GREEN yet

- Fresh Dwarf character creation remains disabled.
- Dwarf village NPCs and Q417/Q418 world actors are not bound.
- The Dwarf transfer quests are not yet playable end-to-end by walking through
  the world.
- Spoil Festival has no production Roblox area resolver yet.
- The source salvage cast bridge remains disabled by default.
- Final Dwarf animations, VFX, UI prompts and trainer presentation are content
  work, not implied by this backend checkpoint.
- No production publish or main-branch merge is part of this checkpoint.

## Next development gate

With all 18 launch first-transfer source inventories and rank schedules now
mapped, stop extending the level-30 class catalogue.

Proceed in this order:

1. **Dwarf world binding** — bind the Gearwright and Deepclaimer mentors,
   ordered quest actors/targets and safe salvage interaction presentation.
2. **Spoil Festival spatial review** — choose one explicit reviewed
   source-unit-to-stud conversion and bind the server-only area resolver.
3. **Professions/economy content** — recipes, gatherables, blueprint use,
   trading pressure and profession-specific progression, while preserving
   1G+1C / 1G+2C / 2G+1C authority.
4. **Quest/content expansion** through the launch level range.
5. Continue the larger roadmap afterward: guild/raid systems and then
   PvP/castle systems.

Do not return to inventing additional level-30 class branches unless a source
audit finds an actual missing C4 path.
