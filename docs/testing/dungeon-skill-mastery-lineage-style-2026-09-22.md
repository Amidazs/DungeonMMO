# DungeonMMO skill mastery, advancement and taunt XP — focused acceptance

Date: 22 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Original level/mastery gameplay/test source:
`bf93f0796b90f7e9401482764714f888c8dc0a51`
Latest focused taunt/mastery source:
`e0e2f39323831ca81e4eb6d79d65a5b1d783fd14`

## New earned progression, not another dungeon regression cycle

This is an original DungeonMMO implementation informed by the class
skill-training structure requested from Lineage II C4. It does not
copy its names, exact numbers, quest text, assets or implementation.

- Every base class has one additional real, executable basic skill:
  Fighter Guard Breaker, Mage Aether Bolt, Ranger Tracker Shot,
  Rogue Viper Strike. Their rank-1/2/3 level milestones are
  8/14/20. Existing starter and class skills remain in place.
- Newly unknown basic skills are hidden from trainer and
  progression snapshots before the appropriate level.
  Trainer and service-level purchase paths also reject early
  learning/ranking; hiding an icon is not the security boundary.
- At level 20, the first class-advancement trial requires two
  existing *earned* core skills to have both purchased rank 3 and
  the relevant proficiency threshold. Fighter requires Shield Bash
  and Mend, Mage Wind Strike and Arcane Ward, Ranger Piercing Shot
  and Crippling Shot, and Rogue Quick Strike and Backstab.
  The already-existing dungeon-clear objective remains necessary.
  Start AND claim recheck the authoritative profile so respeccing
  out of required mastery before claiming prevents advancement.
- Four existing Fighter/Ranger specialist abilities require the
  correct earned advanced class, character level 24 for rank 1,
  rank 3 and earned proficiency on their basic prerequisite
  skills. Their later ranks require levels 28 and 32.
  Their profile-backed acquisition and combat-use gates both
  check those requirements; the trainer and unknown-skill journal
  do not expose skills before eligibility.
- The previous level-20 cap made levels 24/28/32 unreachable.
  The progression level cap is now 40 with an extended
  post-20 XP/point curve. The earlier level-1-to-20 XP thresholds
  are deliberately preserved and tested.

## Zero-damage tank mastery bug closed

The final inspection of ProficiencyService and actual combat-to-
progression call sites found that successful zero-damage Taunt and
Vanguard Challenge produced real server-owned threat but no skill
proficiency. Consequently a player could use these skills normally
and still never earn the proficiency required for their later ranks.

The combat server now sends **one** meaningful control-proficiency
award through the existing DungeonProgressionBridge after the
authoritative taunt is successfully applied to a confirmed NPC.
The bridge's active-encounter/member eligibility and per-encounter
100-point skill cap still apply. Damage and reward contributions
remain zero for the taunt; it is not rewarded for client button
presses, a miss, a disconnected/spectating player or arbitrary
client-provided skill IDs.

The new focused in-memory integration fixture uses the real
ProfileService, ProficiencyService and DungeonProgressionBridge;
it verifies no grant on an ineffective taunt, five proficiency
points for an effective taunt, no spectator/disconnected grant,
the per-encounter cap and normal earning in a new encounter.
This validates the service/bridge contract. A real-client
long-duration proficiency grind and balance of cooldown/XP
are still separate playable-content checks.

## Test receipts — only directly affected components

At `bf93f07`, an unpublished Base/Dungeon composition
build and focused Studio runners passed:

- `skill_mastery_gates_tests.luau`: **62 assertions**, including
  all four basic classes, trainer visibility, rank-level gates,
  fully mastered trial prerequisites, loss-of-mastery checks,
  and advanced skill learn/use eligibility.
- `extended_level_contract_tests.luau`: **44 assertions**,
  including reachable level 40, preserved early XP milestones,
  awarded AP/SP, cap behavior and DEV-only level commands.
- `skill_mastery_affected_contracts.luau`: **5/5** directly
  affected existing quest, Rogue class advancement, trainer,
  progression snapshot and skill-progression contracts passed.

At `e0e2f39`, the latest Dungeon Rojo composition built
and `dungeon_taunt_mastery_tests.luau` passed **7 assertions**.
The local feature worktree was clean; `git diff --check`
passed. The original level/mastery tests were not repeated
merely because of the localized taunt-proficiency fix.

## Remaining boundaries

- Proficiency is earned through genuine server-confirmed dungeon
  damage, support/control and healing. No general open-world
  skill grind, final rate tuning or full class skill catalogue
  is claimed from this first increment.
- First mastery/advancement is implemented for existing Human/Elf
  base classes. Mage-specialist active skills, fuller Rogue
  and other specialization-specific dependencies, passive
  branches and a finished player-visible trainer/quest board
  remain separate **new content** work.
- Live ordinary client damage/taunt balance, a published
  reserved-server journey and cloud persistence remain
  separately scoped acceptance, not reasons to rerun every
  dungeon wipe/aggro/revive fixture now.

All code, tests and documentation were edited through GitHub.
Remote Desktop was used only for a clean fast-forward, a focused
Rojo build and unpublished Studio tests. No Roblox place
was published, no `main` merge/force-push was made, and
no production player profile, purchase or cloud receipt was changed.
