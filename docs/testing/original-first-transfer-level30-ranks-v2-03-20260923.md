# DungeonMMO v2.03 — first-transfer launch-rank catalogue tests

Date: 23 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Scope: existing original Human Ashenblade and Elf Greenward Scout.
Previous: [v2.02 level-30 release decision](
../roadmap/DungeonMMO_Roadmap_v2_02_Level_30_Launch_Skill_Parity_20260923.md).
No Roblox publish, production DataStore edit, `main` merge or
script/document edit through Remote Desktop Commander.

## Actually integrated in GitHub

- Both earned Fighter-based first transfers have original
  `WayfinderArrow` and `WayfinderCut` attack lines: **nine
  individually purchased ranks per line**, three each at
  levels 20/24/28. Their real server-owned projectile and dagger
  melee executors have independently increasing rank damage.
  Their authentic starter skills must be purchased and proficient
  before the new attacks become visible/trainable. Wrong weapon,
  race/class, unearned transfer receipt and trainer are denied.
- Original `WayfinderBowMastery` and `WayfinderDaggerMastery`:
  **nine** bow / **four** dagger individually purchased passive
  ranks, respectively, at the exact referenced training bands.
  Actual server melee/ranged multipliers now use those ranks.
  The passive resolver explicitly rejects any forged or stale
  unawarded Fighter identity, not just UI training requests.
- Both earned original careers can now train the already existing,
  independently authored DungeonMMO shared/general C4-inspired
  utility families through the level-30 bracket, including
  equipment, common creation, light armour, stance, movement,
  evasion, range, breath, fall and lock utility. Human-only
  critical/recovery and Elf-only renewal/poison/wound/focus
  lines remain race- and class-restricted. Legacy Ranger/Rogue
  profiles retain their old catalogues; they are not silently
  assigned a first-transfer award. Common creation remains
  locked until the character selects one genuine creation
  profession and learns its prerequisite recipe literacy.
- New `WayfinderWound` uses the real authenticated dagger-hit
  bleed executor after earned Wayfinder Cut mastery. Elf-only
  `GreenwardCalmingArrow` has **nine** individually bought
  levels-20/24/28 threat-reduction projectile ranks and
  requires the earned Wayfinder Arrow prerequisite.
- A new explicit source-to-DungeonMMO audit map checks every
  historical category at every bracket against the actual
  original class definition, original trainer entry,
  Fighter-family/earned-class restrictions and exact number
  of authored training rank rows. Its source inventories
  still distinguish rank entries from different skill buttons
  and shared starter/general abilities. **59/59** recorded
  Human Rogue and **77/77** recorded Elven Scout source-rank
  schedule entries now map to a genuinely owned class/trainer
  definition. This confirms rank availability and purchases,
  NOT full combat-effect equivalence or copyright clearance.

## Actual executed local Roblox Studio tests

1. Disposable Base and Dungeon Rojo builds **PASS**.
2. Dedicated source-rank audit Studio runner
   `c4_level30_launch_coverage_focus.luau`: **PASS,
   25 assertions** after expanding its source records.
   Both existing first transfers have complete original
   20/24/28 category-to-skill rank schedules. The next
   Human Warrior and Human Knight historical level-20,
   24 and 28 reference inventories are audited too;
   neither new career is implemented or marked playable.
3. Focused Base profile/class/skill Studio suite
   `c4_original_first_transfer_focus.luau`:
   **2/2 PASS**, including **459 original-transfer assertions**
   plus **eight** adjacent historical migration assertions.
   Through actual `SkillProgressionService` and
   `ProfileService` state, both earned careers purchased
   all mapped skill-rank families from the existing
   20/24/28 source inventory, respecting their individual
   character-level bands, skill SP and mastery gates.
   The test separately checks original first-transfer
   attacks, stronger rank-nine server combat definitions,
   purchased mastery damage multipliers, source-family
   purchases, item/crafting choice restrictions and
   save/reload. Forging the current Fighter class after
   purchase no longer applies the two original damage
   masteries.
4. A separate unpublished **two-client Base** physical
   class/skill trainer regression was rerun against the
   expanded catalogue and **PASS**, with actual Studio
   terminal marker `VERIFIED_TWO_CLIENT_FIRST_TRANSFER_PASS`.
   This continues to test the earlier genuine mentors
   and real-client trainer purchase path; the newly
   added 20+ utility families were tested by the focused
   actual server purchase suite, **not** individually
   clicked through the trainer UI in live multiplayer.
5. The previously accepted v2.01 client-caused real
   dungeon combat test covers rank-one Ashenblade Opening
   and Greenward Renewal. The new Wayfinder damage,
   advanced healing/regen, calibrated evasion and
   threat-reduction abilities have **not yet each
   been exercised in a new real-client gameplay
   cast**, nor have all passive/utility effects been
   individually proven end-to-end in the new original
   Fighter-transfer class. Those acceptance items
   remain open despite complete registered rank rows.

## Next two branch inventories, not new playable classes

C4 Human Warrior ranks: **20 at level 20, 19 at 24,
23 at 28 (62 in all)**.
C4 Human Knight ranks: **16 at level 20, 16 at 24,
22 at 28 (54 in all)**.
These are historical *skill-rank reference rows*, not
new game abilities. The source reference module and
launch audit contain their class-specific source
families, while class quest, new original class ID,
real mentor, trainer, equipment rules and actual
skills remain unimplemented. Remaining 14 source
branch reference catalogues require separate audits.

## Outstanding release acceptance

**2/18** first transfers still have actual physical
class awards, source quest paths and live original
career identities. **2/18** have all *recorded* historical
through-cap skill rank schedules mapped and successfully
server-purchased in isolated test profiles, but
**0/18** have been accepted as full class gameplay,
correct every-skill combat/effect behaviour, uninterrupted
Base → Dungeon → Base quest/mentor journey, or real
cross-place publication/persistence acceptance.
Level 30 remains the intended *release cap*;
it is not yet imposed as a live server XP/level-up limit.
