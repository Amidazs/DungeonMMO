# Phase 4 independent gameplay QA — 19 September 2026

Branch: `wip/phase-4-event-secret-policy-v1`
Gameplay source under test: `8846b4d25c18b01a83835c9b5605dcf84def27d1`
Additional TEMP Studio test-only scripts: `67c498a` through `8f73730`.
Final full build/normal baseline source: `8f737308ba3bcfdfe338cb849c068d29d3e44bea`.
**Status: local independent QA completed for the scenarios below, not full
human/production release acceptance.**

All runs used **unpublished local TEMP Studio places** with PlaceId=0 and
GameId=0. TEMP fixtures changed only their loaded Studio DataModel, where
needed to materialize an otherwise disabled optional encounter or force a
Studio party. This was not a merge, TEST/PROD publish, release-flag change,
production DataStore change or real Roblox account reconnect.

## Verified backend and progression tests

`scripts/studio/phase4_gameplay_backend_matrix.luau` ran thirty source
assertion suites in a TEMP Studio **edit-mode** place: attack and defence
timings/rules, damage, dodge direction/priority/clearance, stamina, melee
hit processing, optional boss phases, difficulty definitions/progression,
session persistence, scaling, XP/gold/loot reward service and rare book
rules, completion presentation, recovery, depth unlock/commit behaviour,
free revive and death service, encounter flow, completion/reward transaction,
physical encounter bindings, and admission. **30/30 passed** on
`ce70bf0`, log `20260919T204533Z_Studio_8702B_last.log`.
The first edit-mode attempt was 30/31: the Play-only
`DefensiveCombatIntegrationTest` requires a live TrainingMarauder and
therefore cannot run in a stopped edit-mode DataModel; it was explicitly
excluded from the edit-mode matrix and retained in ordinary live regression.
Do not claim that the failed first matrix passed.

Existing Play-mode physical suites were verified from source
`e3b3022`: Temple and Mine Depth2, Depth3 and Depth4 each completed the
respective 4, 5 and 6 encounter sequence, including the three earlier
bosses returning as Depth4 minibosses. Both dungeons also passed Event/Secret
boss fought and skipped routes and traversed both placeholder side-room
bridges on foot. **Enemy defeats and (for higher depths) player survival
were assisted in those progression tests**. Prior full log receipts and
exact fixture names:
`docs/testing/phase4-placeholder-playable-layouts-closeout-2026-09-19.md`.

## Normal-health Event boss combat

`scripts/studio/phase4_temple_full_normal_boss_fight.luau` used a
**real client** invoking existing CombatInputActions.request_attack against
a live Temple Event boss. The player's health was not boosted and the
Event boss's health was not directly edited. The boss was defeated from
144 HP while the player survived at approximately 16/113 HP, and
the actual Event boss encounter state became Cleared.
Log `20260919T204727Z_Studio_BFE4A_last.log`:
`REAL_CLIENT_BOSS_CLEAR_PASS`. **The fixture still debug-defeated the
Room1 prerequisite and staged the player near the Event boss; this is
a boss-only normal-attack victory, NOT a fully unassisted dungeon run.**

The comparable Mine Event boss run with normal health and attack-only
inputs **failed**: player died while boss had about 15 HP left.
Log `20260919T205108Z_Studio_277D9_last.log`.
A first dodge-enhanced run failed, and a second exited at an inherited
70-second fixture timeout without a conclusive combat result. The runner
timeout and repeated-dodge scheduling were corrected. Final dodge-enhanced
normal-health Mine run again **failed**: player died at 0 HP while boss
remained at ~99.5/120 HP, after 15 accepted attack requests and five
client dodge requests.
Log `20260919T210448Z_Studio_17CFE_last.log`.
This is evidence that this scripted solo attack/dodge pattern did not
win; it does **not** establish that the boss is impossible, that every
defence was accepted/effective, or that a human player cannot win.
Do not silently nerf boss combat based solely on this bot result.

## Multiplayer and individual rewards

`scripts/studio/phase4_dungeon_multiclient_shared_completion.luau` ran a
real two-client local Studio session (distinct synthetic UserIds -1, -2).
A **TEMP-only source override** admitted both clients to the same
authoritative Dungeon session. One leader entered all three Depth1
physical triggers and the server checked the second player shared each
active/cleared encounter. Enemies were test-defeated and leader survival
was boosted **to isolate party/reward wiring**. After completion both
connected Active members appeared in the recipient set and both had
separate `CompletionRewardSummary` entries with `ok=true`.
Server log `20260919T205811Z_Studio_65E43_last.log` has
`SHARED_RUN_COMPLETE_PASS` and `INDIVIDUAL_REWARDS_PASS -1,-2`;
the controlling Studio log `20260919T205804Z_Studio_F0D21_last.log`
has `VERIFIED_MULTIPLAYER_PASS`.
An initial evidence-reader checked only the controller log, mistakenly
reported insufficient proof, and was corrected by examining both logs.
This fixture does **not** verify production party matching or 2-player
normal combat. The previously verified live PlayerRemoving and peer-state
persistence tests remain in
`docs/testing/phase4-remaining-release-gates-local-proof-2026-09-19.md`.

## Actual live death and automatic free revive

`scripts/studio/phase4_dungeon_live_auto_revive.luau` directly killed
the **real player Humanoid** in a fresh TEMP Dungeon Play session, then
observed the real session service consume the free revive and enter
Reviving. A new character appeared, member Mode returned to Active and
the checkpoint was preserved. A second actual Humanoid death did not
auto-grant another free revive. Result:
`FIRST_DEATH_CONSUMED_FREE_REVIVE_PASS`,
`CHARACTER_REPLACED_AT_CHECKPOINT_PASS`,
`SECOND_DEATH_NO_FREE_REVIVE_PASS`.
Log `20260919T210020Z_Studio_FEB10_last.log`.
This test deliberately inflicted death to test recovery; it is not
evidence of normal enemy damage balance or a real purchase.

## Live client UI state rendering

`scripts/studio/phase4_dungeon_live_ui_probe.luau` exercised the actual
client DungeonUi using synthetic state **packets sent through the normal
server-to-client dungeon remotes**. It verified boss name, objective,
a 30/60 half-filled boss health bar, completion screen and multiline
gold/loot text, and an enabled free-revive button. First attempt failed
because the test searched for the exact label text despite multiline
completion text; corrected test passed:
`BOSS_WIDGET_PASS`, `COMPLETION_REWARD_WIDGET_PASS`,
`REVIVE_WIDGET_PASS`, `LIVE_CLIENT_UI_STATE_PASS`.
Log `20260919T205531Z_Studio_5B71D_last.log`.
Synthetic packets prove client rendering, not that every real gameplay
transition/purchase displays correctly or that the UI feels usable.

## Final unpublished project regression

Final source `8f73730`: Rojo builds
`default.project.json`, `base.project.json`,
`published-dungeon.project.json`, `published-base.project.json`
all passed. `luau-compile --null`: 549 source files plus 37
Studio runner files compiled, zero failures; git diff --check clean.
Fresh ordinary Base Play regression: 107 test-pass markers,
zero Creator errors,
`20260919T210614Z_Studio_9FD4D_last.log`.
Fresh ordinary Dungeon Play baseline: 221 test-pass markers,
zero Creator errors,
`20260919T210649Z_Studio_9647F_last.log`.
The earlier focused 11/11 optional boss edit-mode suite and previous
physical layout acceptance remain documented in the placeholder
closeout linked above.

## What must still be tested with the project owner or a separate environment

1. **Hands-on combat:** complete Temple and Mine, all four depths, from
   normal entrance at ordinary player stats and gear, without debug kills,
   boosted health or position staging. Especially assess the Mine Event
   boss, its attack telegraphs and whether timing block/dodge/parry is
   learnable, fair and satisfying. Automated Mine solo bot trials failed.
2. **Actual finished geometry and player UX:** once models/meshes replace
   placeholders, check physical navigation, sight lines, collision,
   boss effects, camera, keyboard/controller/touch controls, mobile
   readability, UI messages and reward feedback. Visual quality and
   fight enjoyment need human judgment.
3. **Real party gameplay:** actual players using normal group admission,
   cooperative fights, contribution, individual rewards, player death
   during a fight and late join/disconnect. The two-client local fixture
   forced grouping and test-killed enemies.
4. **TEST-environment-only network gates** (if desired): genuine same
   Roblox account leave/rejoin and cross-place persistence/rewards,
   matchmaking/teleport and any paid revive flow. These cannot be
   established by unpublished synthetic Studio IDs; explicit owner
   approval is needed before any separate TEST publish.
5. **Release acceptance after art replacement:** full regression on
   actual authored content, multiplayer performance, session/reward
   persistence and review of all feature/physical-layout gates before
   enabling optional bosses or higher depths.

The Temple/Mine optional-boss rollout flags remain false in project
source; higher-depth production physical layouts remain unregistered
and difficulty release flags false. Do not merge this isolated branch to
`main`, publish to Roblox, change production data or enable unreleased
content based on these tests.
