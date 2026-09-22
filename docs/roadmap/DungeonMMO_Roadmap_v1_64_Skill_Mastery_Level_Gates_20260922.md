# DungeonMMO roadmap v1.64 — earned skill mastery and level gates

Date: 22 September 2026
Feature branch: `wip/phase-4-test-hud-integration-v1`
Focused level/mastery head: `bf93f07`
Latest taunt-proficiency fix head: `e0e2f39`

## Implemented and locally focused-tested

- [x] New rankable basic abilities for all four existing base
  classes, using approved server combat executors. Unknown
  rank-1 skills are hidden before level 8; ranks 2 and 3
  require levels 14 and 20 plus earned proficiency.
- [x] First class advancement now needs level 20, two
  class-specific core skills with purchased max rank
  **and** full earned proficiency, followed by its original
  dungeon-clear trial. All checks run server-side at start
  and again on claim.
- [x] New Fighter/Ranger specialist abilities stay hidden
  until their earned advanced class, level 24 and required
  basic/core-skill mastery; rank 2/3 require levels
  28/32 and the relevant earned rank proficiency.
- [x] Playable level cap extended to 40 with a post-20
  progression curve while preserving the old 1–20
  XP milestones and per-level AP/SP entitlement.
- [x] Existing damage/heal/ward/control dungeon contribution
  bridge still grants bounded proficiency. Effective
  zero-damage taunt now grants meaningful, encounter-capped
  mastery for the actual Taunt/Vanguard Challenge used;
  inactive members and ineffective taunts cannot farm it.
- [x] Focused local test receipts: **62 skill-mastery**
  assertions, **44 extended-level** assertions, **5/5**
  directly affected existing contracts, and **7 taunt
  proficiency** assertions. The latest Dungeon
  composition built successfully.

[Focused acceptance and boundaries](../testing/dungeon-skill-mastery-lineage-style-2026-09-22.md)

## Mechanics reference and important distinctions

Inspired by Lineage II C4's level-bracket training and earned
class progression, with WoW-style readable party roles.
These are original names, level thresholds, proficiency
values and quest objectives, not an exact recreation
of either game's rules or content.

**The current implementation is an initial connected skill
ladder, not a complete multi-race C4-sized skill catalogue.**
Unknown skills are hidden until eligible; known skills can
remain visible for transparency, while purchase and
server combat use are restricted independently. Existing
completed character histories are not silently reset.

## Next development — new functionality, not old dungeon retests

1. Add several more **usable base skills/passives** in each
   existing class, staged by level, and connect them to
   a small number of class-specific advanced branches.
   Reuse existing damage, healing, control and movement
   executors; do not create inert skill definitions.
2. Extend specialist rank/mastery and cross-class restrictions
   consistently to existing Mage and Rogue advanced skills;
   add actual new Mage specialist abilities rather than only
   advanced class names. Preserve legitimate previously
   learned skills and plan profile migration if new gates
   require a compatibility policy.
3. Expose a compact **locked / next requirement / available**
   trainer and class quest interface. Current snapshots
   hide unknown locked abilities; provide requirement
   previews in the appropriate character progression view
   without granting access or leaking other class catalogues.
4. Tune the real combat frequency, support-control proficiency
   pace, skill-point costs and level-20-to-40 XP curve in
   one targeted gameplay milestone. Do not rerun the complete
   dungeon wipe, boss, revive and party matrix for data-only
   skill catalogue edits.
5. Published TEST cross-place/cloud and same-account
   reconnect still require separate approval and acceptance.

All source and documentation edits occur in GitHub.
No Roblox publishing, `main` merge, force-push or
production DataStore/purchase mutation occurred.
