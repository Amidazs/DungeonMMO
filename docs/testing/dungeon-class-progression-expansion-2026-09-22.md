# New class advancement and role-skill slice — local acceptance

Date: 22 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Final focused gameplay/test source:
`b017fbce6aceb2a9ba301057a145697a471320ab`

## New gameplay rather than recycled dungeon regressions

The Lineage II / World of Warcraft reference is **structural**:
earn a class identity through a level-gated quest, then gain a
recognizable party role and specialist trainer/ability. This
is original DungeonMMO content, not imported game names, assets,
numerical tuning, quest text or proprietary implementations.

The previous Human/Elf Mage and Rogue advancement paths remain.
Four additional level-20, race-specific paths now use the
existing QuestService / ClassAdvancementService authority:

| Race / base class | Advanced class | Party role | Trial | New active ability |
| --- | --- | --- | --- | --- |
| Human Fighter | Vanguard | Tank / threat | Temple clear | Vanguard Challenge, zero damage / stronger single-target threat |
| Elf Fighter | Thornwarden | Tank / control | Temple clear | Thornwarden Bash, stagger-focused strike |
| Human Ranger | Sharpshooter | Ranged damage | Mine clear | Sharpshooter Pierce, stronger piercing projectile |
| Elf Ranger | Windrunner | Ranged damage / area control | Mine clear | Windrunner Volley, smaller-area / faster-cooldown volley |

The Fighter/Ranger quests reject level-19 characters, require
a server-issued completion event, preserve base-class identity,
cannot be claimed twice and persist per race and character.
Existing Mage/Rogue paths and race-change history retain
their previous behavior.

`BaseClassAdvancementRuntime` exposes an authenticated
Base-only Snapshot / StartTrial / ClaimTrial endpoint to
the **existing** class advancement service. Clients cannot
choose their own class, forge the completion event, bypass
profile readiness or claim from the Dungeon.

Each specialization has a distinct, race/class-restricted
trainer and rank-1/2/3 authoritative ability definition.
Server-side skill purchase and combat usability check the
currently active **advanced** class as well as the base class
and Ranger's required longbow. Simply retaining a skill
in the profile after leaving its advanced class does not
permit use. The Vanguard threat and Thornwarden stagger
use existing server-owned combat executors. Sharpshooter
and Windrunner reuse the existing projectile and area
attack authority; the client now supplies ground aim for
every `RangerVolley` skill, not only the original Volley.

## Focused acceptance, with exact boundaries

- `e73f9ef`: one Base Rojo build and **66 assertions**
  in the existing class-advancement focused regression
  passed (all new paths, wrong dungeon, level gate,
  duplicate claim, race history, save/reload).
- `e73f9ef`: the existing 40-assertion story-quest
  regression also passed after adding the two new class
  advancement quests.
- An initial focused ability fixture failed because it
  seeded an ActiveClassId without the corresponding
  CompletedByRace record. The existing ProfileMigration
  correctly stripped the invalid active class. The
  **test fixture** was corrected to seed genuine
  persisted completion history; production admission
  or migration protections were not weakened.
- `ffc20d1`: one Base build and **60 focused assertions**
  passed for the four advanced skills, trainers, ranked
  combat definitions, SP purchase, duplicate purchase
  prevention, longbow requirements and loss of advanced
  class eligibility.
- `b017fbc`: after updating the client ground-aim
  dispatch to recognize the new Ranger volley kind,
  one Dungeon composition built and the same
  **60-assertion skill contract passed** in unpublished
  Studio; `git diff --check` passed.

**Not yet accepted:** ordinary real-client firing/impact of
each new ability in live combat, class-advancement UI/NPC
interactions, final skill balance or the published
reserved-server/cloud progression journey. The focused
tests cover server data, purchasing/authorization and
combat definition compatibility, not full player-facing
combat play or final art.

Existing dungeon wipe, aggro, boss-reset and Play Again
regressions were not rerun for this new content slice.
All script and document edits were made directly in
GitHub; the remote desktop was used for clean pulls,
the two relevant Rojo compositions and focused
unpublished Studio tests only. No `main` merge, Roblox
publish, production DataStore or purchase was performed.
