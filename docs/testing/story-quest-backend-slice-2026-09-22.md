# Story quest backend slice — focused local acceptance

Date: 22 September 2026  
Gameplay/test source: `89d8e7e9bbf7234a9a73cbff72f19f1be945dcc0`  
Branch: `wip/phase-4-test-hud-integration-v1`

## Why this work was started

The consolidated audit identified existing independent normal-client
boss wins and an assisted two-client shared DungeonClear / individual
completion-reward test. They do **not** demonstrate a complete
four-player, unassisted run; repeating each old wipe/aggro/Revive
suite would not add new content. The remaining all-normal-input
party journey is retained as one later integration/release case,
not a prerequisite for writing additional character progression.

Relevant existing fixtures:
`scripts/studio/phase4_temple_full_normal_boss_fight.luau`,
`phase4_mine_full_normal_boss_fight.luau` and
`phase4_dungeon_multiclient_shared_completion.luau`.
Prior normal optional-boss evidence:
`docs/testing/phase4-optional-boss-normal-combat-playtest-2026-09-20.md`.

## New backend content

- `WorldrootRelic`: all currently implemented race/class combinations
  may start a one-time Temple clear quest. Claiming a trusted
  completion awards 25 Gold and one bound, nontradable
  `worldroot_relic` inventory item.
- `MineEchoes`: requires that the **same character** completed the
  first quest, then a separate Abandoned Mine clear after activation.
  Claiming awards 50 Gold and five Iron Ore.
- The existing trusted `CompletionService` DungeonClear event
  progresses these objectives; clients cannot supply arbitrary
  quest progress, inventory quantities, Gold or completion receipts.
- `QuestService:claim_reward` completes the quest and awards
  server-defined Gold/items in **one** existing profile mutation.
  Repeated claims and repeated starts are denied, and completion
  and rewards survive a profile save/reload without extra payment.
  Class-advancement quests cannot be claimed through this
  adventure-reward method.
- `BaseQuestRuntime` adds server-validated
  `QuestActionRequest` Start, Claim and Snapshot actions.
  Only a loaded player with no pending dungeon teleport can
  request actions for their own character; action identifiers
  must resolve to a registered Adventure definition.
  Results and snapshots are returned via dedicated remotes.

This is a **backend content increment**. It does not introduce a
finished NPC quest board, quest journal UI, new dungeon art, a
special-item crafting recipe, or a new class advancement path.
The reward and prerequisite quest definitions are reusable by a
future quest board without rebuilding QuestService.

## Focused acceptance only

The existing QuestService regression was extended rather than
adding a parallel quest framework. A clean Windows worktree was
fast-forwarded to the GitHub source; `rojo build base.project.json`
succeeded. One unpublished Studio focused runner,
`scripts/studio/story_quest_backend_tests.luau`, passed
**40 assertions** and printed
`[Story Quest Focus] RESULT passed=1 total=1 failed=0`.

The assertions cover advancement compatibility, first-quest
prerequisite enforcement, unrelated clear rejection, early
claim refusal, configured Gold/item grants, repeated claim denial,
second quest ordering and reward, independent character state,
profile save/reload and exactly-once reward retention.
No six-project build sweep, Dungeon/backend matrix, wipe or
aggro replay was run for this isolated quest change.

**Remaining targeted acceptance:** the new Base quest remotes
and a future visible quest board still need a real-client
interaction test. A complete unassisted multi-person dungeon run,
real network reconnect and published TEST/cloud persistence
remain separate gates; none were claimed here.

All source/document edits occurred directly in GitHub.
Remote Desktop performed only a clean fast-forward, one local
Base Rojo build and one focused unpublished Studio runner.
No `main` merge, force-push, Roblox publish, Robux operation
or production DataStore mutation.
