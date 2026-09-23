# DungeonMMO backend roadmap v2.01 — real first-transfer combat

Date: 23 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Supersedes [v2.00 first-transfer skill roadmap](
DungeonMMO_Roadmap_v2_00_First_Transfer_Skills_20260923.md)
as the latest *class backend* status. The independently maintained
humanoid/quadruped art and animation roadmaps are not superseded.
[Executed two-client acceptance](
../testing/original-first-transfer-real-combat-v2-01-20260923.md).

## Completed in this increment

- [x] New disposable unpublished two-client real Dungeon combat test
  enters an actual active instanced first combat room containing
  physically registered enemy models. Source and current class
  prerequisites are prepared only in disposable test characters
  to isolate their **actual client-originating combat**.
- [x] Genuine Human Ashenblade `SkillRequest` for
  **Ashenblade Opening**, with a real equipped dagger and
  owned ability, applies actual server combat damage to
  the room enemy. Enemy Humanoid health decreases; real
  stamina is consumed and server cooldown begins.
- [x] The same real client cannot cast the dagger-only
  ability effectively while holding a sword: the enemy
  suffers no damage and no ability cooldown starts.
  Re-equipping a dagger restores earned combat access.
- [x] A genuinely client-originating **Greenward Renewal**
  cast heals its Elf owner, consumes real mana and starts
  its cooldown, without a substantial extra heal to
  the other real party member.
- [x] Removing the purchased Greenward ability in an
  isolated test profile denies the client's attempted
  heal and cannot start its cooldown. Restoring the
  purchased ability and authoritatively reseeding
  combat permits the real client cast.
- [x] Final full two-client Studio test **PASS**;
  real melee, real owner-only heal, wrong-weapon
  denial and unpurchased-heal denial all recorded.
  The test permits small ordinary Humanoid regeneration
  instead of misidentifying it as a skill heal.
- [x] Only source-controlled test and roadmap updates
  were made in GitHub. Local Desktop Commander only
  pulled the branch, built disposable Rojo places
  and launched/observed unpublished Studio playtests.
  No Roblox publish, production DataStore mutation
  or `main` merge.

## Current first-transfer progression status

**2/18** planned original first-transfer careers have
earned physical level-20 class awards and **two
implemented trainable class abilities each**.
Their new level-24 abilities have actual rank-one
client-caused combat and negative eligibility
acceptance. The rank-two stronger ability effects
and purchase/save gates were independently verified
through focused server tests, not rank-two
client combat. **0/18** entire advanced-class skill
catalogues are feature-complete or accepted through
an uninterrupted Base → Dungeon → Base
gameplay journey.

## Next backend acceptance and implementation

1. Run authentic **rank-two client combat** for
   Ashenblade Opening and Greenward Renewal,
   including rank-one versus rank-two effect
   measurement at the proper level, mastery, and
   purchased-rank gates, as well as actual UI hotbar
   invocation and genuine combat enemy-facing checks.
2. Continue independently named DungeonMMO
   skill catalogue for Ashenblade and Greenward
   Scout through levels 32 and 36: add actual
   class-specific weapon, defensive and utility
   effects with paid ranks and precursor proficiency,
   then validate genuine trainer UI requests,
   purchased combat loadout, cooldown and real
   client casts. Do not silently import legacy
   Rogue/Ranger abilities or protected game text.
3. Complete the **uninterrupted** all-player-owned
   Base → Dungeon → Base journey, actual ten/four
   appropriate player-controlled kills, full
   item proofs, class awards, saved equipment,
   authentic real-place transport/lease recovery,
   wipes and disconnect/rejoin. An unpublished
   local Studio simulation is **not** a real
   Roblox cross-place acceptance; get approval
   before publishing or using production DataStores.
4. Implement the remaining independently authored
   first-transfer class identities, progression
   quests and trainers, then second/third transfers.
   Models, meshes, rigs and animations remain
   their own independently maintained workstream.

Keep one gathering and one crafting profession
per character, hub-and-instanced-dungeon design,
all-party difficulty unlocking, closest-before-
damage/highest-threat aggro with taunt-generated
threat, animal-only skinning and player trading.
Permanent code/document edits must remain in
GitHub, not via Desktop Commander.
