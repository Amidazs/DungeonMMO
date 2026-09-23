# DungeonMMO backend roadmap v2.00 — first-transfer skill progression

Date: 23 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Continues [v1.99 first-transfer awards](
DungeonMMO_Roadmap_v1_99_Original_First_Transfers_20260923.md).
Actual [v2.00 test evidence](
../testing/c4-original-first-transfer-v2-00-20260923.md).
The independently maintained humanoid/quadruped art/animation
roadmaps remain separate, current and unaffected.

## Completed and accepted this increment

- [x] Implement original **Ashenblade Opening** (Human Fighter
  → Ashenblade): first rank at level 24, requiring purchased
  starter `FighterDaggerStrike` rank 3 and 80 earned
  proficiency. A second rank at level 28 requires 80
  earned use proficiency in Opening. Server-determined
  stamina/cooldown and actual dagger melee hit damage
  increase from 20 to 27 across the two ranks. A
  non-dagger weapon cannot execute the ability.
- [x] Implement original **Greenward Renewal** (Elf Fighter
  → Greenward Scout): first rank at level 24, requiring
  purchased starter `ElvenFighterRenewal` rank 1 and
  30 earned use proficiency. A second rank at level 28
  requires 80 earned use proficiency in Renewal. Real
  server-owned self-heal base effect increases 35 → 52;
  mana/cooldown and owner/rank gating stay authoritative.
- [x] Keep all class skills locked until the correctly
  awarded level-20 first-transfer identity and saved
  mentor receipt are present; neither selecting a quest
  nor finishing it auto-awards a skill. The real
  matching physical trainer offers the class's abilities
  only once level and prior proficiency gates permit.
- [x] Actual Base and Dungeon temporary Rojo builds pass.
- [x] New first-transfer focused server test suite
  **2/2 PASS**: 93 class, skill, migration, save/reload
  and combat-runtime assertions plus 8 adjacent quest
  migration checks. The first runtime fixture correctly
  caught and then fixed a test-only dirty-profile
  handoff violation; its final execution is green.
- [x] Actual unpublished **two-client Base** playtest PASS
  for both original physical class mentors and both
  real advanced training stations. Each client's genuine
  station prompt opened its corresponding real skill
  catalogue/window. The live client request for the
  new level-24 skill was accepted only while at the
  correct nearby trainer with available SP, a valid
  personally earned class, level 24 and mastered starter
  prerequisite. Out-of-range, foreign trainer ID and
  exhausted earned SP requests all failed; only the
  correct owner received the purchased rank. The
  test client sent the actual training remote after
  verifying the UI; it did not click the UI button.
- [x] All permanent code, tests, source docs and this
  roadmap changed in GitHub. Remote desktop used only
  for local pulls, temporary unpublished Rojo builds
  and Studio tests. No `main` merge or Roblox publish.

## Next backend work in development order

1. **Actual playable combat casts for the two new skills.**
   Live client-caused Ashenblade Opening hit against a real
   instanced monster using a real equipped dagger; observe
   authoritative target health decrease, threat and ability
   stamina/cooldown. Live client-caused Greenward Renewal
   cast with reduced player health; observe actual owner
   heal, mana/cooldown, no cross-owner healing, and deny
   unearned/unpurchased/unequipped/wrong-race requests.
   The v2.00 static rank-effect and runtime authorization
   suite is not equivalent to a successful live cast.
2. **Expand both first-transfer skill catalogues beyond
   two abilities each**, with independently named/
   expressed DungeonMMO abilities, implemented effects,
   class/race/weapon/level/earned-proficiency gates and
   full trainer purchase/loadout/test acceptance at
   each level bracket. Do not wholesale unlock the
   old legacy Rogue/Ranger tree or import another
   game's proprietary assets, dialogue or class text.
3. Finish actual in-game trainer Learn-button activation
   acceptance; test concurrent duplicate rank purchases,
   low-SP race/mentor cases, race/gear switching,
   persistence under failed save and disconnect/rejoin.
4. Complete uninterrupted real Base → Dungeon → Base
   quest and transfer journey with all ten/four genuinely
   client-controlled qualifying monster defeats,
   actual personal loot, final NPC turn-ins, a natural
   level-20 trainer visit, real cross-place lease/save
   handoff and repeat/wipe/reconnect acceptance. The
   existing unpublished local Studio tests seed some
   earlier source completions and skill proficiency
   to isolate later stages. Don't publish or modify
   production DataStores without the user's approval.
5. Build the remaining independently named Human/Elf
   Fighter/Mystic and additional-race original first
   transfers, their actual source quests, unique
   class identities, training gates and combat effects.
   Later advancement tiers follow those foundations.
6. Final independently authored monster/NPC designs,
   meshes, encounter presentation and non-copied story
   dialogue belong in the separate art/animation
   roadmap once the backend is accepted.

## Exact status and preserved rules

**2/18** planned first-transfer class identities now have a
real physical level-20 class award and **two implemented
trainable class abilities each**. **0/18** have an accepted
feature-complete first-transfer skill catalogue or
uninterrupted live cross-place quest and advancement.
Source quests remain accepted separately, not as a single
full-journey test.

Retain hub-based instanced dungeons, one gathering plus
one crafting profession per character, trading economy,
all-party-member difficulty unlocks, closest-before-damage/
highest-threat aggro, taunt-generated threat and
animal-only skinning. No source/doc editing through
Remote Desktop Commander, Roblox publishing or merge
to `main` without explicit approval.
