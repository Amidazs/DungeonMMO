# DungeonMMO working roadmap v1.72 — Rogue bleeding combat

Date: 22 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`

[Focused acceptance and limits](../testing/c4-rogue-bleed-2026-09-22.md)

## Completed in this local backend gate

- [x] New **Lacerating Cut** rank 1 at level 24 and
  rank 2 at level 32 with purchased basic ranks and
  earned proficiency prerequisites.
- [x] Confirmed server-owned melee hit triggers a
  bounded, non-stacking three-tick bleed on a valid
  living NPC. Rank upgrades both initial and delayed
  damage. Old delayed callbacks cannot double-hit
  a refreshed target. Death/disconnect/encounter
  admission/target removal terminates further ticks.
- [x] Source attribution, damage/threat/contribution
  and earned-proficiency use existing authoritative
  services, with no client-owned tick or target data.
- [x] Isolated rank/visibility/weapon content test:
  **19 assertions PASS**. Isolated real trainer
  purchase and profile reload test: **20 assertions
  PASS**. Base/Dungeon Rojo builds succeeded.
- [x] Unpublished Play client: one real hotbar attack
  damaged the NPC, then **three server damage ticks**
  executed and stopped. Existing Briar Volley,
  Disrupting Cut and Thunder Shot focus also passed.
- [x] GitHub-only source, fixture and documentation
  changes; clean local pull only for TEMP builds/tests.

## Important source and implementation distinction

Chronicle 4 Rogue/Elven Scout list Bleed at level 24
and 32 and require a dagger:
https://l2hub.info/c4/classes/rogue
https://l2hub.info/c4/classes/elven_scout

The current DungeonMMO Rogue is an independent level-one
base class using a temporary **one-handed sword**, so
Lacerating Cut is a functional C4-inspired analogue
and is not an exact C4 dagger skill or source parity.
Chronicle 4's first-transfer skill page includes bow
and dagger branches together: do not copy a full
shared rank count to both current Ranger and Rogue.
Source-mapped exact per-career rank counts remain open.

## Remaining class-catalogue gates

1. Establish a source-backed **full rank-entry inventory**
   for existing Fighter/Mage and shared Rogue/Scout
   first-transfer plus advanced careers. Explicitly
   separate common skills from race/branch-specific
   skills and account for each implemented character level.
2. Implement actual missing effects and purchased rank
   values (rather than placeholder entries), including
   applicable protection, debuff removal, attack speed,
   critical power, mobility, healing and real equipment
   masteries. Support dagger-specific Rogue combat and
   backend weapon legality before claiming source-equipment
   parity; additional races/class splits require separate
   gameplay/quest design decisions.
3. Add focused real-profile trainer UI/ordinary input
   validation after integrating backend ranks. Keep the
   previously accepted dungeon lifecycle systems intact.
4. Resolve the separate Phase2A paid-revive auto-test
   failure before release and run broader regression
   **once** at a meaningful milestone closeout.
5. Leave `main`, published Roblox places, PROD
   DataStores, paid operations, unrelated worktrees
   and old dungeon wipe/aggro/revive/replay suites
   unchanged during catalogue development.

**Status:** v1.72 focused bleed feature accepted locally;
the overall C4 catalogue is **NOT complete**.
