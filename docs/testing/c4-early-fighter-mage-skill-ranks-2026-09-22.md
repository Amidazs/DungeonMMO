# C4 early rank-density content — focused local acceptance

Date: 22 September 2026  
Branch: `wip/phase-4-test-hud-integration-v1`  
Fighter test and profile-migration correction: `d812a73`  
Final Mage/content and affected-contract head: `cdecfc76ff4450dc329c1612e7834b8042f9b98b`

## New gameplay content (not an old dungeon replay)

The first C4 source-count comparison found many missing *skill-rank
offerings*, not merely missing hotbar icons. The source reference
lists several training ranks in the same level bracket. This
increment adds ORIGINAL DungeonMMO skills with real effects:

- **Iron Cleave** (Fighter): a nine-rank close-range sword strike.
  Every rank increases server-applied base damage. Its ranks 1–3,
  4–6 and 7–9 become trainable at levels 5, 10 and 15.
- **Pursuit Step** (Fighter): nine ranks of a lower-damage forward
  step/strike using existing server-owned movement and melee-hit
  logic. Every rank improves actual damage; the step distance
  gives a distinct movement role. Same level brackets as above.
- **Renewing Light** (Mage): six actual healing ranks through
  the existing MageHeal authority, with a greater heal-over-time
  fraction and a different mana/cooldown profile. Ranks 1–3
  train at level 7, and ranks 4–6 at level 14. Each rank
  increases real server-applied healing.

The original Guard Breaker and Aether Bolt rank ladders, class
advancement trials and advanced-skill prerequisites remain
unchanged. Two new Fighter skills and the Mage heal are
accessible through the **existing** base-class trainer and
known-skill/loadout/profile authorities, rather than an
additional independent skill system.

## Rank cost, proficiency and persistent data

`SkillProgressionConfig` now supports a registered skill's
`RankThresholds` alongside existing tier-wide thresholds.
A source-authored long ladder need not make every older
three-rank Common skill require nine-rank proficiency.
SkillProgressionService, ProficiencyService and
ProgressionSnapshotBuilder use the same per-skill
thresholds, preserving next-rank costs and eligibility.
The normal ProficiencyService grants only eligible
server-authorized contributions.

An initial focused Fighter test uncovered
`ProfileMigration.sanitize_skill_state` still clamping all
Common-skill proficiency to the older three-rank tier cap.
This prevented rank progression past the new thresholds.
**Fixed in production** by using the per-skill maximum.
Existing three-rank skills retain their original tier caps;
completed character progression is not reset.

Unknown level-locked abilities do not appear on the
trainer/journal before their own first available level.
After unlocking a skill, ranks in the next training bracket
still require both that level and earned proficiency.
The server independently checks learning and purchasing;
this is not merely client-side hiding.

## Focused evidence and actual remaining gap

At `d812a73`, one Base Rojo build and the focused
`c4_early_fighter_ranks_tests.luau` runner passed
**133 assertions**, covering actual rank 1–9 effects,
both five/ten/fifteen brackets, level/proficiency checks,
trainer visibility and independent saved skill records.

At `cdecfc7`, one Base Rojo build and
`c4_early_mage_ranks_tests.luau` passed
**37 assertions**, including eligible proficiency grants,
rank 1–6 healing effects and save/reload without a cap
regression. The directly affected QuestDefinitions,
RogueAdvancement, TrainerCatalogues, ProgressionSnapshot
and SkillProgressionService contracts passed **5/5** on
this same source. No dungeon wipe, boss, Play Again,
world-boss or full project regression was rerun.

The C4 volume audit also ran at `cdecfc7`, reporting
**16 of 16 verified reference brackets still below
the source counts**. Actual explicit rank offerings:

| Class/race | Level | Source ranks | New authored ranks |
| --- | ---: | ---: | ---: |
| Human/Elf Fighter | 1 | 2 | 0 |
| Human/Elf Fighter | 5 | 13 | 7 |
| Human Fighter | 10 | 12 | 7 |
| Elf Fighter | 10 | 13 | 7 |
| Human/Elf Fighter | 15 | 12 | 7 |
| Human/Elf Mage | 1 | 7 | 0 |
| Human/Elf Mage | 5 | 1 | 0 |
| Human Mage | 7 | 15 | 4 |
| Elf Mage | 7 | 14 | 4 |
| Human Mage | 14 | 21 | 4 |
| Elf Mage | 14 | 20 | 4 |

The audited count includes only explicitly level-authored
ranks: four older Fighter and three older Mage skill families
have not yet had complete source-mapped rank schedules.
The current new skills have actual server combat/healing
effects; the audit remains a **content-gap report**, not
a claim that C4 counts or balance have been reproduced.

C4 source class tables:
[Human Fighter](https://l2hub.info/c4/classes/fighter),
[Elven Fighter](https://l2hub.info/c4/classes/elven_fighter),
[Human Mystic](https://l2hub.info/c4/classes/mage),
[Elven Mystic](https://l2hub.info/c4/classes/elven_mage).

## Open content and release boundaries

- Fill the remaining early class brackets with **real**
  rankable attack, bow/dagger, defensive, passive,
  healing, utility and crafting functions. Wire actual
  passive/utility effects before counting their ranks.
- Map existing four Fighter/three Mage skill families
  to verified source brackets without inventing level
  entries or corrupting existing characters' learned ranks.
- Continue Ranger/Rogue mapping only after resolving
  their shared versus separate C4 class roots. Expand
  later level-20/40 branches and race-specific rows.
- A normal-client rank-nine Fighter strike and rank-six
  Mage heal against live player/NPC targets need one
  separate new-feature playtest. The current checks prove
  server skill definitions, purchase, profiles and
  proficiency flow, not measured live combat balance.
- No Roblox publish, `main` merge, force-push,
  production profile or purchase mutation occurred.

Scripts and documents were edited directly in GitHub.
Remote Desktop was used only to pull the clean feature
branch, build one local Base composition and run these
focused unpublished Studio tests/read-only content audit.
