# C4 v1.91 — original first-transfer quest stages and skill scope

Date: 23 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`

## Why this change was needed

The final [v1.90 acceptance](
c4-explicit-first-transfer-choice-v1-90-20260923.md)
already verified explicit first-transfer GUI and saved original class
choices (final 8/8 focused tests, one-client UI and two-client
independent selections). This v1.91 work continues **after**
that verified regression. No finished v1.90 test or old dungeon
combat/wipe acceptance was needlessly rerun.

The user explicitly requires **original Lineage 2 C4 Fighter/Mystic
starters, original branching quests AND original skills**.
The old 396/396 count reflects six previously inventoried
*DungeonMMO functional analogue* rank lists, not original C4
skill-rank parity for every class.

## Implemented and source-researched

- `C4OriginalFirstTransferQuestStages` records separate, **ordered**
  C4 source quests for the two previously mapped class paths:
  `HumanRogue` quest 403 and `ElvenScout` quest 407.
  The Rogue story follows Bezique → Neti → ten quest-weapon skeleton
  bones → Neti → Bezique → Cat's Eye Bandit with four distinct stolen
  items → Bezique; class-transfer authority must eventually involve
  Grand Master Ramos. The Elven Scout story follows Master Reisa,
  Guard Moretti, four distinct Prias letter fragments from Ol Mahum
  Patrols, Prias, an Ol Mahum Sentry's key, Prias's release,
  Moretti and Reisa; Grand Master Rains is the eventual transfer NPC.
  These reflect **original source event identities**; our hub/instanced
  dungeon game will need server-authorized equivalents, rather than
  falsely replacing each stage with a generic dungeon clear.
- Original C4 source walkthroughs used:
  [quest 403, Path to a Rogue](
  https://l2hub.info/c4/quests/403-path-to-a-rogue)
  and [quest 407, Path to an Elven Scout](
  https://l2hub.info/c4/quests/407-path-to-an-elven-scout).
  Rewards, zones and live historical NPC/monster models have not
  been imported. Current quest start design retains the previously
  agreed level-18 source gate; class award must still wait for
  level 20 and the authentic recommendation/transfer NPC.
- `C4OriginalQuestProgressRules` rejects skipping ordered stages,
  reusing event IDs, false trial-weapon evidence, bone-free skeleton
  victories, bandits without all four verified stolen items,
  non-distinct letter fragments and sentries without the real key.
  It does **not** grant a class simply because a QuestState.Ready
  flag is true.
- New `C4OriginalFirstTransferQuestService` provides an actual
  authoritative profile-backed, Base-only quest start, stage-progress
  and read-only snapshot interface. No client remote accepts quest
  event/proof data. Start and progress **fail closed** with
  `OriginalQuestWorldNotReady` unless a real server-world binding
  has been supplied. The real game has NO such binding yet: the
  service is intentionally **not** wired to a fake quest action or
  marketed as a playable NPC experience.
- The existing `ProfileMigration` now preserves and bounds the
  selected original quest's step, count, already-observed event
  IDs and only the authored original quest-proof IDs. It refuses
  mismatched quest/class identity rather than letting an old
  or wrong-race profile overwrite original class choice/skills.
- The original class selection server snapshot and closable UI
  now separately show **source quest research**, live world
  readiness, previously mapped DungeonMMO analogue skill ranks,
  and currently unimplemented C4 source skill lists. A selected
  class remains a saved choice, NOT an awarded class or skill.

## Skills work completed in this increment

`C4OriginalClassSkillCoverage` now audits **all 18 original
C4 first-transfer identities** separately from the six existing
DungeonMMO analogue lists. For Human Rogue it correctly reports
99 mapped analogue ranks, for Elven Scout 129; neither claims
exact original C4 skill-rank parity or completed source-class
trainer restrictions. All sixteen other source classes still
require their *full* rank inventories and playable skill trees.

To begin this work rather than merely carry a TODO,
`C4OriginalFirstTransferSkillSources` now contains **28
individually enumerated original C4 level-20 rank entries**:
12 Human Warrior and 16 Human Knight. Every rank is associated
with its exact source skill name, actual rank and source level,
and deliberately records `GameplayStatus="NotImplemented"`.
The original level-24/28/32/36/etc ranks, the full
Warrior/Knight catalogues and every functional spell/attack/
passive, trainer authorization and weapon effect remain pending.
This source inventory does not grant a level-20 ability.

Original C4 skill sources:
[Warrior C4 skills](https://l2hub.info/c4/classes/warrior)
and [Human Knight C4 skills](https://l2hub.info/c4/classes/knight).
Future source audits should compare the two existing Scout/Rogue
analogue lists against their actual C4 skill pages, correcting
differences instead of assuming the old 396/396 count proves exactness.

## Actual focused Studio execution

Final targeted unpublished local Base runner:
`scripts/studio/c4_original_quest_skill_scope_focus.luau`.

**5/5 passed, zero failures.** New
`C4OriginalFirstTransferQuestStagesTest`:
**117 assertions passed**. Other suites included
actual previously implemented source-class selection,
original class-level gates, all-18 coverage and
the real saved-quest/class-advancement migration regression.

The new test exercises both distinct quest stories through
a **simulated server-only world adapter** feeding the real
profile/quest service: ordered NPCs and individual monster drops,
forged/unverified and repeated-event denials, correct trial
weapon/loot proof, full staged quest readiness and save/release/
reload. It also verifies an original Fighter cannot learn
first-transfer Scout Lockpicking merely by selecting Rogue/Scout
or completing these simulated stages. Actual class IDs,
source level and old economy state remain unchanged.

**This is a server-side quest fixture, not a real NPC playtest.**
No live class quest can currently start in the world, because
original NPC/monster/quest-item bindings and the subsequent
atomic class-award/trainer integration are not ready. The
source-stage test does not claim actual quest playability or
that any of 18 C4 paths are completed.

Nine relevant Luau source/test files passed parser checks,
and disposable Base **and** Dungeon Rojo builds passed.
Later additions of the 28 rank-source entries also parsed,
rebuilt both projects and passed the final five-suite run.

The local checkout contained an unrelated untracked
quadruped engine Python `__pycache__` directory;
it was left untouched. GitHub remained the sole place
where project scripts, test fixtures, roadmap and docs
were edited. Desktop access was limited to clean tracked
fast-forward pulls, read-only checks and disposable unpublished
Studio builds/tests. No `main` merge, Roblox publish,
production DataStore change, local source rewrite or paid
operation occurred.

**v1.91: two original C4 quest backends source-authored and
focused-tested, but neither is live; 28 original first-transfer
level-20 ranks newly inventoried, none of those 28 yet
functionally implemented. Overall original C4 progression
still incomplete; first transfers fully playable: 0/18.**
