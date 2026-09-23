# DungeonMMO backend roadmap v2.02 — level-30 initial launch scope

Date: 23 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Supersedes the [v2.01 first-transfer real-combat roadmap](
DungeonMMO_Roadmap_v2_01_Real_Original_Combat_20260923.md)
**for class/skill launch scope only**. The separate character, wolf
and quadruped animation roadmaps remain independently current.

## Agreed release target, not yet a deployed level cap

**The initial game targets progression from level 1 through level 30.**
Do not build level-32/36+ first-transfer skills just to satisfy the
initial release. Save the next brackets, later class transfers,
dungeons and higher-level progression for future updates.

This is a **scope decision, not a claim that the runtime level cap is
already enforced**. Existing legacy playtests, profiles and skill
definitions go above level 30. Put a server-authoritative, tested
level-30 XP/level-up cap and higher-tier trainer visibility rules in
place only as a deliberate, migration-safe release implementation.
Do not truncate existing test or player save data on load.

**The launch skill requirement is C4's complete class-appropriate
catalogue available by level 30**, not two representative skills per
career. Reference both starter and selected first-transfer lists,
including offensive, ranged, defensive, support, passive, toggle,
utility and general skills as applicable to each source class. An
individual original rank purchase must not silently become a single
binary toggle. Cover each source unlock bracket and the cumulative
rank choices available by the cap. Independently author DungeonMMO
names, quest dialogue, visual icons, effects, numbers, descriptions
and game-specific expression. Preserve the design coverage and
player choices without copying source artwork, skill text, NPCs,
monsters or exact proprietary implementations.

Reference period: historical **Lineage II Chronicle 4**, not Classic,
Interlude or High Five. Sources for the first two specific branches:
- https://l2hub.info/c4/classes/rogue
- https://l2hub.info/c4/classes/elven_scout
- C4 official changes:
  https://legacy-lineage2.com/news/chronicle4_04.html

## Executed source coverage audit — not gameplay parity

The audited C4 first-transfer brackets for Human Rogue / Elven Scout
are **level 20, level 24 and level 28**; their next source bracket is
level 32, so it is outside this proposed initial release.

| Source branch | Level 20 individual rank rows | Level 24 | Level 28 | Cumulative through level 30 |
|---|---:|---:|---:|---:|
| Human Rogue → authored Ashenblade | 20 | 19 | 20 | **59** |
| Elven Scout → authored Greenward Scout | 26 | 25 | 26 | **77** |

These values count **historical individual rank entries across the
three unlock brackets**, including common/general ranks; they are
not 59 or 77 different skill buttons and are not 59/77 currently
implemented DungeonMMO ranks. The distinct abilities and multiple
ranks of each skill must each be reconciled, including shared
Fighter and general skill systems. The repo's older
`C4ScoutSkillInventory` marks many functional *legacy Ranger/Rogue*
analogues, which **do not** count as purchasable original Ashenblade
or Greenward Scout skills. The two newer class skill definitions
have independently validated level-20/24/28 progress and
rank-one live combat but **do not prove source-rank parity**.

New source-controlled
`src/ReplicatedStorage/Core/Shared/C4Level30LaunchCoverage.luau`
audits all 18 first-transfer branch identities and exposes the
actual source rank-count coverage and authored current-class
skill IDs. It deliberately returns
`ExactSourceRankCoverageCertified = false`,
`LaunchSkillCatalogueReady = false` for every branch.
Only Human Rogue / Elven Scout currently have source inventories
counted across the complete intended launch bracket range;
the other 16 branches need full historical source audits.
The earlier Human Warrior / Knight source notes cover
level 20 **only**, not their full launch catalogue.

Focused unpublished local Base Rojo build: **PASS**.
`scripts/studio/c4_level30_launch_coverage_focus.luau`:
**PASS, 22 assertions**. Confirmed source bracket rank counts,
two actual original authored skill IDs per existing career,
all 18 distinct first-transfer paths, no level-32
source rows counted and no falsely certified class. This
is an **inventory test**, not a new real combat or
full rank purchase/playthrough test.

## New class/skill implementation order

1. **Finish launch-level source-to-authored coverage for the two
   existing playable careers.** For each level-20/24/28 source
   family and rank entry, classify: implemented in the
   correctly authorized *shared starter/general* catalogue,
   implemented as a genuine original class skill, awaiting
   a separately authored DungeonMMO ability/passive,
   or requiring a carefully justified gameplay adaptation.
   Specifically fill the current missing first-transfer
   bow and dagger mastery, both weapon attacks/ranks,
   light armour, critical effects, movement and avoidance,
   class utility, and the Elf's healing, defense, threat
   management and status recovery. Keep noncombat utility
   and shared common crafting from bypassing the one-crafting-
   profession restriction. Measure actual source-rank
   coverage rather than the count of existing skill icons.
2. **Accept each finished original class at cap 30:** personal
   unlock level, selected class/race, previous purchased
   rank and *earned proficiency*, owned equipment, trainer
   visibility, SP price/deduction, persistence, real passive
   calculation/toggle or live client-cast combat effect,
   wrong-class/unpurchased/replay denial and loadout.
   Rank-two Ashenblade Opening/Greenward Renewal still
   need genuine live cast acceptance, not only definition
   and purchase checks.
3. **Then build the other first-transfer careers through
   level 30**, with separately named DungeonMMO careers,
   quests and distinct class-appropriate complete rank
   catalogues. Start with Human Warrior and Knight
   (source level-20 inventories already exist, upper
   launch brackets still need auditing), alongside Human
   Wizard and Cleric so tank, melee, damage magic and
   healing archetypes are developed. Continue Elf Knight,
   Wizard and Oracle, then Dark Elf, Orc and Dwarf
   branches in the source registry; where a new race
   is not yet playable, implement its identity, race
   validation, trainers, skill authority and quest
   systems before claiming it is ready.
4. Add the actual release cap, natural level-1→30
   progression, appropriate unlock visibility and
   save migration only after existing above-cap
   testing and profiles can be preserved safely.
   Release readiness requires an uninterrupted real
   Base → Dungeon → Base quest, source loot, mentor
   advancement, class abilities and save/reconnect
   journey for each advertised playable branch.
   Publishing Roblox places or modifying production
   DataStores still requires explicit user approval.

## Scope and project safeguards

Source first-transfer branches in the historical five-race
registry: **18**. First-transfer career identities with
accepted real level-20 mentor awards and two implemented
skills each: **2/18**. Class catalogues confirmed
complete through level 30: **0/18**. No additional classes
or entire skill catalogues are claimed implemented by
this scope or audit change.

Keep hub-and-instanced-dungeon architecture,
all-party difficulty unlock gating, animal-only skinning,
closest-before-damage/highest-threat/taunt aggro,
one gathering plus one crafting profession per
character and an economy requiring player trading.
All permanent scripts/docs must be edited in GitHub,
not via Desktop Commander. Do not publish to Roblox,
merge into `main` or overwrite production saves yet.
