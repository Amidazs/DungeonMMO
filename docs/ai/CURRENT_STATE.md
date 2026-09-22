# DungeonMMO Current Engineering State

## 22 September 2026 — story quest backend slice locally PASS

Gameplay/test source `89d8e7e`: first two one-time
cross-class Adventure quests, sequential Temple -> Mine
prerequisites, one bound Worldroot relic and usable ore/Gold
rewards, persisted one-time claims through existing
QuestService/ProfileService/InventoryService. Base now
accepts authenticated adventure Start/Claim/Snapshot remotes,
but a real-client quest board and NPC interaction are not
implemented.

**Focused evidence only:** one clean Base Rojo build and
40 QuestService assertions passed in unpublished Studio.
This is not published or final game content, nor evidence
of unassisted four-player dungeon combat. Historical local
dungeon acceptance is retained rather than rerun.
[Roadmap v1.62](docs/roadmap/DungeonMMO_Roadmap_v1_62_Story_Quest_Backend_20260922.md).
[Acceptance](docs/testing/story-quest-backend-slice-2026-09-22.md).


## 22 September 2026 — all-member difficulty gate / spectator / replay PASS

Accepted gameplay source `c6925c0`: six Rojo builds, focused
four-player Base party unlock test, TeleportCoordinator
**23 assertions**, DungeonReplayService **28 assertions**,
Dungeon backend **30/30**, real two-client spectator combat
and two-client Play again UI fixtures passed in unpublished
Studio. The four-client physical room wipe/re-entry also
passed earlier after the combat gate was introduced.
At final gameplay source `b6fe3be` (Base entry UI
identifies the locked party member), all six compositions
rebuilt and the Base party unlock test passed again.

**Player rule:** For Depth2+, every single selected character
must personally have completed the previous depth in the
selected dungeon. Base validates each party member and the
TeleportCoordinator rechecks all before server reservation.
Neither a leader's unlock nor another dungeon's clear grants
access. A locked party member blocks everyone, including
during Play again, and the failure identifies the member.
Replay invalidates previous votes when an unlock fails.

**Combat rule:** Spectating, dead and disconnected players
cannot attack, cast, defend, deal delayed damage, contribute
damage or be targeted as active dungeon participants.
Creating a new character cannot reset the server-owned
spectator mode; live two-client Studio verified the exclusion
and that the still-Active peer could damage targets.

**UI regression:** A late revive snapshot previously
interfered with visible Play again after two accepted
client votes. The UI now preserves terminal replay state.
Two genuine Studio clients demonstrated the waiting and
successful replay screens at the same gameplay head.

**Boundaries:** No genuine same-account network reconnect
into a published reserved server, real cross-place routing,
durable cloud replay, or full ordinary boss-reward reattempt
was established by the local fixtures. A published TEST
experiment still requires separate user approval.

[Acceptance evidence](docs/testing/dungeon-party-unlock-spectator-replay-2026-09-22.md).
[Roadmap v1.61](docs/roadmap/DungeonMMO_Roadmap_v1_61_Party_Unlock_Spectator_Replay_20260922.md).
All source/docs edits GitHub-only; remote access was used
for read-only diagnostics, clean pulls, local builds/tests.
No publish, `main` merge, force-push or production cloud mutation.


## 22 September 2026 — same-server reconnect local testing PASSED

Tested gameplay/test source:
`87a19ba6ac112f8fd3850d01f271538067286d72`.
Desktop Commander reconnected, and the clean feature worktree was
fast-forwarded to the GitHub reconnect implementation. The six
Rojo compositions built and `git diff --check` passed.
The focused production-service simulated same-UserId return suite
passed **30 assertions**; Dungeon backend **30/30** including
DungeonDeathService **46 assertions**; real-client failed-return UI
Play passed; focused ThreatService **51 assertions**; Base professions
**14/14**; and a real four-client physical Room1 wipe/re-entry
fixture passed, all at the **same** tested gameplay source.

**Boundary:** this proves the local reconnect contract and
non-regression, not a genuine Roblox account disconnecting and
network-rejoining its original reserved server. The existing
admission requires valid platform join routing; a direct return
without platform TeleportData fails closed. Published TEST
same-account routing, lease reacquisition, spectator combat exclusion
and persisted rewards remain outstanding and need separate
publishing approval.

The earlier "Studio OFFLINE" note below is historical and
superseded for local testing, not for the real-network gate.
Receipt:
`docs/testing/dungeon-same-server-reconnect-local-acceptance-2026-09-22.md`.
Updated roadmap:
`docs/roadmap/DungeonMMO_Roadmap_v1_60_Same_Server_Reconnect_20260922.md`.
All source/docs edits GitHub-only; no `main` merge, publish,
force-push or production data operation.


## 22 September 2026 — same-server reconnect source STAGED, Studio OFFLINE

Latest implementation/test source:
`7d684f583020df64e2591a00acef14c90f35ecb1`.
The previously proven multiplayer gameplay head is the
older v1.59 increment. Do **not** carry its six-build or
30/30 PASS labels forward to this new reconnect source.

A real previously connected, now-disconnected Roblox
member can pass a narrowly gated nonce-free **same active
server** readmission check after their initial handoff
nonce has been consumed. All initial Base-to-Dungeon
handoffs still need a nonce, and the normal profile load
must independently reacquire the profile writer lease.
Abandoned, connected duplicate, unrecorded departure,
foreign-server and terminal-run access is rejected.

On admission the server now re-sends the player's actual
revive state; the new client also requests a snapshot
after wiring event listeners. This prevents a returning
spectator from being presented with a refunded free revive
solely because a new Character loaded. A new service
regression covers authenticated same-UserId simulated
readmission, prior room checkpoint, spectator/free-revive
state, second party member and exclusive profile lease.

**CURRENT BLOCKER:** Remote Desktop Commander reported
no connected devices on 22 September. No Rojo builds,
Studio tests or Luau parse check were completed for
this source head. The new regression is written but
**NOT EXECUTED**. The user's existing backend
v1.59 accepted tests remain evidence only for the
earlier head. GitHub showed no CI checks on the new
source commit.

**NEXT once online:** fast-forward a clean worktree;
run all six Rojo builds, 30/30 Dungeon backend,
`scripts/studio/dungeon_reconnect_admission_tests.luau`,
and death/UI regressions, then a temporary same-user
admission simulation. Genuine same-account cross-network
return still needs a published TEST reserved-server
experiment and confirmed platform TeleportData routing
after separate approval; **do not** bypass missing
routing with an untrusted client-supplied session ID.
Check combat exclusion for returning Spectating members.

Report:
`docs/testing/dungeon-same-server-reconnect-stage-2026-09-22.md`.
Roadmap:
`docs/roadmap/DungeonMMO_Roadmap_v1_60_Same_Server_Reconnect_20260922.md`.
All code and document edits in GitHub only. No publish,
main merge, force-push, paid product or production cloud
data operation.


## 21 September 2026 — Four-client secret/Depth4/disconnect acceptance

GitHub feature head with latest focused verification:
`9a63c6d25ac45cd67c9a4c5a684fa4c5a26adb24`.

Real unpublished four-client physical Studio Play passed
Temple SecretArena optional-boss and Depth4 Room2
mini-boss recovery: previously cleared encounters stayed
cleared, four checkpoint auto revives succeeded, retired
bosses were replaced by new full-health models and
later rooms remained Pending. Only disposable Studio
test places unlocked the optional event/secret content;
production release settings are unchanged.

Real peer disconnection during an active Room3 boss
left three players fighting. Their later collective
wipe/revive preserved the absent member's unused
free revive, earlier room clears and boss checkpoint,
and permitted a single fresh full-health boss.

Previously stale higher-depth service expectation was
corrected for one-shot Failed broadcasting and passed
392 assertions across 12 dungeon/depth/party cases.
Six Rojo builds; backend matrix 30/30; death/revive
41 assertions. A real same-account reconnect and
published cross-place continuity remain unverified.

Evidence:
`docs/testing/dungeon-secret-depth4-disconnect-recovery-2026-09-21.md`.
Roadmap v1.59:
`docs/roadmap/DungeonMMO_Roadmap_v1_59_Secret_Depth4_Disconnect_20260921.md`.


## 21 September 2026 — real four-party encounter replay locally VERIFIED

Locally verified gameplay head: `a5c0637888f8400703d07290f790a24d3b8406bf`.
Four live Studio clients recovered after an interrupted physical
Temple Room1 fight, with four checkpoint revives and a fresh
full-health room; repeat killing a previously rewarded monster
did not increase any player's Gold, XP, Level or bestiary count.
Four-client Room3 boss and TEMP-enabled optional EventArena
boss each respawned as one new full-health boss after wipe,
without undoing cleared prerequisites.

Fixed repeated terminal Failed broadcasts in
`DungeonDeathService:tick` which had hidden ReplayWaiting.
Real two-client server-owned Play again voting now displays
Waiting for party to the first participant and simulated
replay to both when all have consented. The source passed
six Rojo builds, Dungeon backend 30/30 and death/revive
41 assertions; earlier focused threat 51, Base professions
14/14 and paid retry 15 remain passed.

Outstanding: secret/higher-depth boss wipe/re-entry,
real disconnected-party recovery, normal-client boss
loot through wipe, actual cross-place reserved replay
and cloud persistence. The latter need separate approval.

Receipt:
`docs/testing/dungeon-four-client-room-boss-event-replay-2026-09-21.md`.
Roadmap v1.58:
`docs/roadmap/DungeonMMO_Roadmap_v1_58_Four_Party_Boss_Replay_20260921.md`.


## 21 September 2026 — actual Room1 wipe/re-entry Play PASS

At source `acb628fb99202a94f7f4cec781a15ec7f5614760`,
the real unpublished one-client Dungeon runtime entered authored
Temple Room1, observed a test-injured enemy, handled the player's
genuine death and free revive, removed old encounter models,
returned the new character near the current checkpoint, and
physically re-entered Room1 to spawn **new full-health enemies**.
Fixture `scripts/studio/dungeon_room_wipe_reentry_live.luau`
printed `VERIFIED_PLAY_MODE_PASS`.

The terminal Complete/Failed UI now presents Play again and Return
to Base. At `c1d7f83`, real-client UI Play proved both button
states, six Rojo builds passed and Dungeon backend 30/30 plus
ReplayService's **17 assertions** passed. At `341c84d`,
the one-shot recoverable wipe contract passed **40 assertions**
and Dungeon backend remained 30/30. The replay service's
actual new-place teleport remains untested in unpublished
Studio, where it is intentionally simulated; completed runs
cannot replay until completion rewards are committed. All-party
consent resets after a failed launch; automatic completed-run
return is suppressed during replay launch.

**NEXT:** genuine two-/four-client physical dungeon wipe and
boss/optional encounter recovery; actual replay button-to-server
multi-client Play, persisted reward idempotence through a physical
partial-kill wipe, and later published TEST/cloud verification
with separate approval. Do not conflate the physical one-client
room reset with these outstanding gates.

Evidence:
`docs/testing/dungeon-room-reset-play-again-2026-09-21.md`.
Roadmap:
`docs/roadmap/DungeonMMO_Roadmap_v1_57_Room_Reset_Play_Again_20260921.md`.
No Roblox publish, `main` merge or force-push. Source/docs
edited in GitHub; desktop limited to pull/build/unpublished tests.


## 21 September 2026 — recoverable room reset and Play again

Candidate gameplay/test head:
`341c84da73b9c1246414a51e171cc363d4e71c1b`.
The live dungeon death callback now resets an **uncleared active
encounter** once when all living party members fall but an
automatic free revive is still pending. The executor destroys
old enemy handles, releases boss spawn guards and rolls the
current encounter to Pending while preserving prior clears and
the room-start checkpoint. Free-reviving players respawn at that
checkpoint, then the authored room can spawn fresh enemies
with full health and fresh threat on re-entry. Already paid
monster lives retain their transaction IDs; no extra revive
or reward receipt is created by the rollback.

Completed runs with committed rewards and fully failed runs
now expose **Play again** alongside Return to Base. The
authoritative replay service requires affirmative consent from
all currently connected party members before requesting a new
reserved session with the same dungeon, difficulty and original
Base destination. A failed launch clears previous votes.
Unpublished Studio simulates actual cross-server travel.

Six Rojo builds; Dungeon backend **30/30**, replay contract
**17 assertions**, paid-retry regression and real-client terminal
UI `COMPLETION_BUTTON_PASS` / `WIPE_BUTTON_PASS` all passed at
`c1d7f83`. After one-shot wipe test additions, the same-head
`341c84d` Dungeon death suite passed **40 assertions** and the
backend matrix remained **30/30**.

**Outstanding:** a complete real-client physical dungeon
room fight -> death -> rebuilt enemies -> checkpoint re-entry
playtest; actual published reserved-place Play again and
cross-server/cloud rewards. These were NOT verified by the
local service/UI tests. No place published or main merged.
Receipt:
`docs/testing/dungeon-room-reset-play-again-2026-09-21.md`.


## 21 September 2026 — terminal wipe -> Base -> fresh retry VERIFIED

Latest tested gameplay source:
`8899fad6923628e86a8946fc9ce4c365bc738902`.
After the existing revive-decision deadline, a `Failed` dungeon
remains terminal. Connected members can now take the Return-to-Base
route without calling `abandon_member` on an already-failed session;
the real Dungeon UI exposes a failed-run return button (Studio
`VERIFIED_PLAY_MODE_PASS`). A new run started from Base must
create a new session ID, entrance checkpoint and free-revive state;
the old failed run and its reward identity are preserved.

The paid-revive callback was hardened against duplicate, late,
disconnected and failed-session spawns. It respects the actual
purchase-service order: the grant commits `PaidReviveCount` and
sets member mode `Active` before the spawn callback. A dedicated
integrated test covers the real purchase/session/death/return service
chain and passed **15 assertions**.

At that head: six Rojo builds; Dungeon backend **30/30** (including
DungeonDeathService **33 assertions**); failed-run return contract
**15 assertions**; fresh-session contract PASS; integrated paid retry
**15 assertions**; real failed-run UI Play PASS. All edits went to
GitHub; desktop used only for clean pulls/builds/unpublished tests.

**This is the safe terminal-failure -> Base -> new-run path, NOT
an in-place dungeon-room wipe/restart.** Current no-target cleanup
still resets threat only; restoring active encounter HP/spawn,
checkpoint-wide party respawn and reward-safe room re-entry remain
the next local backend milestone. Published TEST/cloud travel,
production purchases and main merge remain deferred.

Receipt:
`docs/testing/dungeon-terminal-wipe-return-fresh-run-2026-09-21.md`.
Roadmap:
`docs/roadmap/DungeonMMO_Roadmap_v1_56_Terminal_Wipe_Base_Retry_20260921.md`.


## 21 September 2026 — real four-client wipe threat reset VERIFIED

Latest gameplay source/test head:
`739e747d88d93ff00ed30497e9473edd17b037f4`.
Real four-client unpublished Dungeon Play proved independent aggro
from two actual Marauders, effective MageHeal threat, Fighter Taunt
retake, dead-healer fallback, genuine DPS departure cleanup and
**all remaining clients dead**. After three seconds with no
eligible target, both previously engaged controllers cleared
their threat ledgers; server log:
`REAL_FULL_WIPE_THREAT_RESET_PASS`, overall
`VERIFIED_FOUR_CLIENT_PASS`.

Same-head six Rojo builds and focused ThreatService 51, Dungeon
backend 30/30 and Base professions 14/14 PASS. Correct isolated
`world-boss.project.json` real two-client guardian aggro and
guardian MageHeal/Ward/Mend fixtures both
`VERIFIED_MULTIPLAYER_PASS`, superseding the older incorrect-
composition timeout. This resets **threat only**, not enemy HP,
spawn locations, weekly admission, rewards or full dungeon
session/checkpoint state. Full session wipe/retry, true reconnect,
cloud and published TEST remain pending.

Only GitHub source/docs edits and unpublished local tests were used.
No publish, main merge or production data mutation. Receipt:
`docs/testing/four-player-full-wipe-threat-reset-2026-09-21.md`.
Roadmap supplement:
`docs/roadmap/DungeonMMO_Roadmap_v1_55_Combat_Threat_Wipe_20260921.md`.


## 21 September 2026 — eligible-threat support follow-up

Current tested candidate: `b569435c9eb3cd4971eec06ca1baeeb4f17f4a09`.
An enemy receives support threat only if it already has positive
threat from a currently eligible target candidate. Stale threat
from an absent/dead former target alone no longer activates healing
aggro. Its support caster and recipient must also be eligible.

All six compositions built; the focused Studio threat contract
passed **51 assertions** (including the new absent-leader guard).
Real two-client ordinary Marauder support and ordinary aggro
fixtures both printed `VERIFIED_MULTIPLAYER_PASS` at this head.

The isolated world-boss aggro rerun was attempted but its Studio
process exceeded the **110-second outer timeout**; do not report
a current-head pass or interpret the timeout as a combat failure.
The earlier successful world-boss run remains historical evidence
from its earlier commit. World-boss aggro and actual world-boss
support need clean current-head Play. Only the orphan children
belonging to the timed-out temporary test were terminated.

All source/doc edits were GitHub-only. No Roblox publish,
main merge or cloud data mutation. Receipt:
`docs/testing/combat-support-eligible-threat-followup-2026-09-21.md`.


## 21 September 2026 — support threat and four-role contract LOCALLY VERIFIED

Latest tested source/test head:
`df33735b10010b8aed8e7acc5193970b8f4cc9b1`.
The shared ThreatService now credits 0.5 provisional threat per
*effective* MageHeal/HoT, positive Mend pulse and absorbed ArcaneWard
point. Both caster and healed/protected target must be in the enemy's
latest eligible target set, and that enemy must already hold threat;
idle nearby enemies do not receive free healing aggro. Player departure
clears their per-enemy threat and candidacy, and enemy wipe/reset clears
both the threat ledger and current eligible candidate snapshot.

Local Studio at that head: six Rojo builds; ThreatService 48 assertions,
including server-side **simulated** four-player tank/DPS/healer,
independent enemy, Taunt, disconnect and wipe contracts;
Base professions 14/14; Dungeon backend 30/30; real two-client normal
Marauder and isolated world-boss aggro PASS. A separate genuine
two-client normal Marauder fixture passed client MageHeal on an injured
Fighter, real client ArcaneWard application and a test-injected server
DamageService hit absorbed by Ward, with positive support threat:
`VERIFIED_MULTIPLAYER_PASS`.

**Follow-on real-client acceptance:** at fixture head
`04c3f1eb5087d34e49ef4cb7bd38b731de9fd610`, genuine client
MageHeal and ArcaneWard succeeded against an ordinary Marauder,
an actual NPC melee attack was absorbed by the client's Ward,
and client-driven Fighter Mend produced positive effective-heal
threat. The live fixture printed
`REAL_PEER_HEAL_THREAT_PASS`,
`REAL_NPC_WARD_ABSORB_THREAT_PASS`,
`REAL_FIGHTER_MEND_THREAT_PASS` and
`VERIFIED_MULTIPLAYER_PASS`. This supersedes the earlier
test-injected Ward-only support fixture.

**Remaining boundaries:** four-player aggro still has only simulated
server-side policy coverage, not four real clients. Real multi-enemy
room combat, full-party wipe/controller reset, controller-level
disconnect and actual healing/Ward in the isolated world-boss
session remain pending. The 0.5 support multiplier is provisional.
No Roblox place publish, TEST cloud run, main merge, production
DataStore access or force-push was performed. Source/test/docs
changes were made through GitHub only.

Receipt: `docs/testing/combat-support-threat-candidate-2026-09-21.md`.

## 21 September 2026 — local aggro/threat and Fighter Taunt verified

Normal enemies and the world-boss Captain controller now share a
server-authoritative per-enemy threat ledger. Before an eligible player
has positive threat, the nearest eligible player is targeted. Once
threat exists, the highest-threat eligible player is targeted; distance
only breaks equal-threat ties. Actual server-applied health damage adds
threat to the exact enemy hit.

A real zero-damage Fighter `Taunt` is now learnable from the Fighter
Trainer. It uses normal server skill/cooldown/stamina/melee target
validation, then moves the player above that enemy's current threat
leader using server-owned `TAUNT_BONUS_THREAT`. It does not fabricate
damage or contribution. Rogue ThreatDrop and existing respawn aggro
suppression remove a player from target eligibility temporarily.

Local two-client Play proved the policy against both an ordinary
Training Marauder and the isolated world boss. The accepted normal
enemy run covered nearest fallback, first-damage takeover,
higher-damage takeover, actual client Taunt, ThreatDrop suppression and
highest-threat reacquisition. The world-boss run proved the same
nearest/damage/higher-threat/Taunt sequence. Additional test-only
reruns proved that a dead highest-threat player immediately falls out
of the target set in both controllers.

Runtime acceptance head:
`9c744d0cfe4ecabd5b372229e446ceadc6653861`.
All six Rojo compositions built there. Threat contract 14 assertions,
Fighter Trainer 12, profile-exit recovery 18, reward retry 17 each
Base/Dungeon, Base professions 14/14 and Dungeon backend 30/30 all
passed. One-hit lethal boss and existing two-client boss regressions
also remained green. Death-fallback test-only head:
`e041bf2203c8b73b0c1c9b59aebc175a2c8cbddd`.

Next local combat work: define and verify healing/ward threat, then
four-player tank/DPS/support aggro, multi-enemy room isolation,
wipe/reset threat cleanup and disconnect candidate removal. Publishing,
real cross-server reconnect and cloud persistence remain deferred.

Receipt:
`docs/testing/combat-aggro-threat-taunt-local-2026-09-21.md`.

## Earlier 21 September local backend checkpoint (historical)

## 21 September 2026 — v1.54 LOCAL backend, publish deferred

At user request, continue backend-only work through GitHub and run
only unpublished Studio/in-memory tests. No TEST or production place
is to be published as part of this milestone.

The world-boss combat pipeline now passes the server-observed lethal
hit from DamageService to the contribution bridge. The scoped
authority credits the *actual first killing blow* after guardian
health reaches zero while still requiring the exact boss model,
admitted player, matching encounter identity and undefeated frozen
session. Unpublished one-attack Studio Play at
`5b7edc2675fd8fc6e9b6d0908bdf263742cf88b6`
passed real client lethal contribution, guardian defeat, weekly
reward once and duplicate reward zero. Earlier acceptance after
the combat change also passed the original real-client combat and
two-client party Play, plus existing target-filter/reward-retry/
profile-exit tests on source
`6252baa5bfea0694c3dd18d3c81caae19cc890a1`.

Existing local retry tests verified that a simulated failed profile
save retains the dirty weekly receipt and retry persists only one
award (17 assertions each Base and Dungeon). A departure-save
helper test verified that two failed saves leave the profile lease
owned until successful persistence (11 assertions).

Additional GitHub-only changes add exact-target lethal bridge
assertions and fix the distinct case where profile saving succeeded
but its subsequent lease release failed after local cache removal.
The updated exit test now covers this latter case. The desktop
connection became unavailable before latest-head verification; do
not claim those additional assertions or builds have passed.

Mend now records only positive server-applied healing through the
contribution bridge. An attempted genuine two-client Mage Heal
fixture failed due to unreliable injured-target state in the
test environment and was reverted to restore the accepted combat
baseline. Actual two-client skill-based healing/ward support remains
an open local test gate.

Next: reconnect authorized desktop; safely fast-forward; run all
six Rojo builds, the one-hit/two-client fixtures, updated lethal
filter and profile-exit contracts, weekly reward retry and existing
profession/Dungeon regressions. Then continue local support skills,
four-member party/wipe/return and offline persistence contracts.
Published travel, same-account true cross-server reconnect and cloud
storage tests remain deliberately deferred.

Receipt: `docs/testing/weekly-world-boss-v154-local-backend-continuation-2026-09-21.md`.

## Earlier 21 September party checkpoint (historical)

## 21 September 2026 — v1.54 two-client party resilience locally verified

The isolated weekly world-boss backend now has a local two-client
acceptance path. Two genuine Studio clients damage one shared guardian
through the existing CombatService/DamageService path, both persist
their own contribution and both receive independent once-per-week
rewards after the shared kill. Immediate duplicate claims pay zero.

A new `WorldBossMemberLifecycle` owns encounter character
attributes, Active/Dead member mode, replicated Humanoid death and
safe delayed respawn into the same frozen encounter. The accepted
multiplayer fixture kills one real client-owned Humanoid, observes
the server `Died` signal, persists that member as Dead, automatically
respawns them into the same session as Active and verifies no second
weekly payout. The first client then leaves the real Studio network
while the other remains present; stored contribution and reward state
remain intact.

The current prototype wipe policy is also explicit: connected dead
members are independently respawnable and a wipe does not reroll or
clear the event/boss/week snapshot. `WorldBossArenaLayout` provides
an opt-in primitive enclosed arena with a stable
`WorldBossArenaSpawn`; normal Base/Dungeon compositions are not
changed by that prototype.

Roblox Studio multiplayer clients use negative UserIds, which exposed
another test-environment mismatch. ContributionService and
DungeonContributionBridge now accept negative integral IDs only while
`RunService:IsStudio()`; live player IDs remain positive-only.
Zero/nonfinite/malformed IDs and contribution events remain denied.

Final local acceptance at source
`e83e4fae522582ec98bfc9cf4938ffdca9aa810b`: six Rojo builds;
multiplayer Play `VERIFIED_MULTIPLAYER_PASS`; lifecycle/wipe
14 assertions; contribution 20; Base travel 18; Base return 22;
Dungeon world-boss session 33; Base professions 14/14; Dungeon
backend 30/30.

Same-account network reconnect remains explicitly unverified because
Studio cannot prove the exact same Roblox account reconnecting across
a new reserved server. Published TEST Base → ReserveServer boss →
Base, real lease handoff and TEST DataStore/MemoryStore recovery are
the next release gate. Two-client real healing/ward skill execution
also remains pending. Event flags remain off and no cloud publish,
production DataStore write, force-push or main merge occurred.

Roadmap: `docs/roadmap/DungeonMMO_Roadmap_v1_54_Weekly_World_Boss_Foundation.md`.
Receipt: `docs/testing/weekly-world-boss-v154-party-resilience-2026-09-21.md`.

## Earlier 21 September real-combat checkpoint (historical)

## 21 September 2026 — v1.54 real guardian combat locally verified

The isolated world-boss place now reuses the existing full combat
server/client runtime and the existing Marauder Captain AI controller.
The ordinary prototype ArenaBuilder remains excluded. On boss
admission, characters receive the frozen weekly encounter ID so the
guardian targets only that encounter's participants.

World-boss contribution is now scoped to the exact active guardian
and active admitted party. The combat bridge filters unrelated or
same-name targets, and WorldBossCombatAuthority revalidates live
membership, encounter identity, undefeated weekly state and support
targets before forwarding any contribution to the existing
ContributionService.

A real unpublished Studio client used the normal CombatService attack
RemoteEvent to damage the guardian. The same normal DamageService
callback persisted contribution, the guardian AI damaged the player,
the player defeated the guardian without direct health injection, and
the verified weekly reward paid exactly once. Markers:
`REAL_CLIENT_HIT_PASS`, `SERVER_CONTRIBUTION_PASS`,
`GUARDIAN_ATTACK_PASS`, `REAL_CLIENT_BOSS_DEFEAT_PASS`,
`WEEKLY_REWARD_ONCE_PASS`, `VERIFIED_PLAY_MODE_PASS`.

That Play test exposed and fixed two real runtime bugs: a nil access
when stored weekly event state was absent/malformed, and a local
`event` variable that shadowed the incoming combat event and caused
genuine hits to be rejected. The runtime also retries post-defeat
reward grants and blocks Base return while an earned qualifying
reward is still unsaved.

Final source head
`7605c811bb9f9a13ce2fb56f6b68a76f8c63ae89` passed six Rojo
builds, seven damage-filter assertions, default-off boss-place Play,
14 contribution-service assertions, weekly policy/factory 40+8,
Base professions 14/14 and Dungeon gameplay 30/30.

This is still **not** the complete published game journey. The real
dedicated place needs an authored WorldBossArenaSpawn/basic arena.
The accepted combat fixture manually creates its disposable session
and guardian, so Base entry, Roblox ReserveServer travel, real lease
handoff, Base return and cloud DataStore/MemoryStore recovery were
not exercised in one networked flow. Multi-client boss combat,
party wipe/death and disconnect/rejoin remain pending. Event flags
stay off. No cloud publish, main merge, force-push or production
player DataStore write occurred.

Receipt:
`docs/testing/weekly-world-boss-v154-real-combat-2026-09-21.md`.

## Earlier 21 September world-boss travel checkpoint (historical)

## 21 September 2026 — v1.54 isolated world-boss travel and return

A separate default-off Base boss gateway, new reserved-server travel
coordinator path, dedicated world-boss-only Rojo place, stored-session
arrival checks and per-member Base return path are on the active GitHub
branch. Ordinary Dungeon rejects boss-session routing. The dedicated
world-boss place remains disabled without explicit server enablement,
reservation and an authored arena anchor. The normal Temple portal
and existing dungeons remain unchanged.

Unpublished Studio verified six Rojo compositions, 18 reserved-travel
assertions each in Base and Dungeon, 22 Base return assertions,
10 ordinary-Dungeon admission assertions and five isolated boss
destination assertions. A dedicated-place default-off Play check
passed. Previously accepted session/profession/gameplay regression
suites still passed, including real Base material-chain Play.

**Fixed a critical reward-contract bug:** the actual server
ContributionService returns Damage/Tank/Support at the top level,
not in a nested snapshot field. The isolated boss runtime now uses
WorldBossContributionRules; 14 real-service assertions passed in
both Base and Dungeon. Failed Base return teleports roll back
WorldBossReturnPending, allowing the member to reconnect to the
boss. The first validated boss session is bound before yielding
profile/lease operations to prevent competing-party admission.

This is source and local Studio contract acceptance, **not** a
real Base → published reserved boss → Base Play acceptance.
The boss place still lacks its authored arena, connected player
combat/guardian attack and live contribution recording pipeline,
published TEST transfer, cross-server profile/lease recovery,
multi-client boss fight and production enablement. Do not claim
these as complete or enable the event. No public publish, main
merge, force-push or production player DataStore change occurred.

Roadmap:
`docs/roadmap/DungeonMMO_Roadmap_v1_54_Weekly_World_Boss_Foundation.md`.
Receipts:
`docs/testing/weekly-world-boss-v154-isolated-travel-2026-09-21.md`,
`docs/testing/weekly-world-boss-v154-travel-hardening-2026-09-21.md`.

## Earlier 21 September world-boss session checkpoint (historical)

## 21 September 2026 — weekly world-boss session bridge locally verified

A default-off `WeeklyWorldBossSessionBridge` is now composed in
Base/Dungeon shared RuntimeServices. It freezes the server-issued
weekly event/party into the **existing** DungeonSessionService
InstanceState, stores only a verified guardian defeat and rehydrates
the same window and group from the session adapter after a local
service restart. Reward delivery checks existing session membership,
non-abandonment and server-certified contribution; an invited
non-contributor gets no payout. A saved profile's once-per-week
receipt prevents repeat payout after same-UserId in-memory reload.
Stored windows are revalidated without reopening entry after close.

Four Rojo compositions passed, the original 40 weekly policy
assertions passed in Base/Dungeon, the guardian factory passed eight
assertions, and the new **30-assertion** session contract passed
in Base and Dungeon. Existing professions 14/14 and Dungeon
backend 30/30 also passed at the latest source commit.

This is NOT a normal Base portal or a completed reserved-server
boss route. Session restart used a shared Studio in-memory adapter;
no cross-server live MemoryStore or DataStore claims can be made.
Normal dungeon runtime, normal portal and public event schedule
were not changed or enabled. Source and documentation changes
remain GitHub-only; no publish or main merge.

Receipt: `docs/testing/weekly-world-boss-v154-session-bridge-2026-09-21.md`.

## Earlier 21 September weekly milestone (historical)

## 21 September 2026 — v1.54 weekly world-boss local foundation

The active GitHub branch now includes a default-off weekly world-boss
calendar, server-only instance admission and persistent per-character
reward gate in the existing Base/Dungeon RuntimeServices. Each event
uses an explicit server window, Monday UTC week identity and an
exclusive entry cutoff. The prototype `AncientGuardian` factory
reuses the accepted captain combat rig but has its own
instance-specific tag/identity and no ordinary monster rewards.
The provisional weekly gold is 100 per character; no finished
guardian content or live event time has been scheduled.

Four Rojo compositions, 40 window/reward assertions in each of
Base/Dungeon, eight guardian-factory assertions, 14/14 existing Base
profession suites and 30/30 Dungeon backend suites passed.
A real client entered through a **disposable injected physical
ProximityPrompt** while the explicit event window was open, spawned
a guardian using the registered server factory, and completed two
separate assisted encounters. Only the first kill paid weekly gold
into the actual Dungeon Studio profile. The physical runner printed
`VERIFIED_PLAY_MODE_PASS`; the dedicated factory runner also
passed after correcting its test to check the proper
`DungeonRewardGoldMin/Max` attribute names.

**Do not treat the fixture as an enabled normal-game event.**
The gateway, temporary arena and prompt are not production assets;
there is no Base portal, published weekly event schedule, reserved
server, durable world-boss instance/session snapshot, contribution
eligibility or real DataStore/cloud handoff yet. A weekly reward
receipt persists through the existing profile adapter; the local
instance registry itself does not. No source/docs were edited
locally and no cloud publish/main merge occurred.

Roadmap: `docs/roadmap/DungeonMMO_Roadmap_v1_54_Weekly_World_Boss_Foundation.md`.
Receipt: `docs/testing/weekly-world-boss-v154-local-foundation-2026-09-21.md`.

## Earlier 21 September v1.53 progress (historical)

## 21 September 2026 — craft disconnect protection and local recovery verified

The active GitHub branch includes ticketed per-user craft locks.
Each request checks ticket ownership and original Player instance
after server preparation before committing any inventory mutation.
PlayerRemoving invalidates the departing user's ticket; a stale
completion cannot release a subsequent same-UserId request.

All four Rojo builds passed. Both rebuilt Base/Dungeon focused
profession runners passed **14/14** (guard: 21 assertions; same-UserId
in-memory recovery: 20 assertions each). A genuine two-client Base
Play fixture paused an actual client's craft, disconnected the
client, observed release, loaded the **same UserId from the local
in-memory adapter** and resumed the abandoned handler without
losing ore or granting a duplicate bar. The other real Studio client
remained connected. Studio admitted a distinct replacement test
account, not the original account. The corrected fixture uses a
disposable shared ModuleScript instead of a test-only global.
Base material-backed crafting, the opt-in Dungeon wolf encounter
and broad Dungeon backend matrix (30/30) were rerun and passed
after the guard modification.

Real same-account Roblox network reconnect, cross-server lease/
DataStore recovery and published TEST/PROD remain NOT tested.
No source or documentation changes were made via Remote Desktop;
no publish, real-user DataStore mutation or merge into main.

Receipt: `docs/testing/profession-v153-interrupted-reconnect-local-2026-09-21.md`.

## Earlier 21 September progress (historical)

## 21 September 2026 — opt-in Dungeon wolf and full client crafting locally verified

Latest source/fixture commit after the live tests:
`b3ce809d258ecfddcbc4077a80ff14ea3a67d826`.
A distinct `ForestWolf` server factory and `Wolf` enemy archetype
are registered but not inserted into any default dungeon combat pack.
Its combat-rig animal silhouette is a temporary backend placeholder.
The disposable Temple Room1 fixture opted in two wolves and passed
the real encounter activation, assisted enemy defeat, normal reward/
clear, retained looted corpse and one-hide real-client Skinning path.
Ordinary Marauders and bosses remain unskinnable.

A real Base client crafted the full material-backed profession chain
to `warded_leatherbound_gloves` with station checks and authoritative
inventory changes; a no-material repeat and a two-request burst were
rejected/limited to one output. A real two-client Base Play fixture
passed independent crafts, a one-hide contested shared corpse and
a peer disconnect while the other player stayed connected. The
additional two-user in-memory contest passed in both Base/Dungeon
focused suites (13/13 each after the updated sources were rebuilt).
The Dungeon regression matrix stayed 30/30.

Do NOT infer true same-account reconnect or in-flight request retry,
cross-server DataStore persistence, unassisted wolf combat, dedicated
wolf AI, approved animal models, or a public deployment. These remain
open release gates. All source/docs were edited via GitHub; local
Studio tested disposable unpublished in-memory places only.

Receipt: `docs/testing/profession-v153-wolf-and-crafting-local-acceptance-2026-09-21.md`.

## Earlier 21 September checkpoints (historical)

## 21 September 2026 — animal-only Skinning verified in local Studio

Four Rojo compositions and both 12-suite focused profession runners
passed (363 focused assertions in each). The 42-assertion species
eligibility, 16-assertion corpse runtime and 11-assertion Dungeon
cleanup tests passed; the broad Dungeon backend matrix passed 30/30.
Two real Base Play fixtures passed: an actual client RawHideCache grant
followed by authoritative prompt depletion, and a temporary
server-created, dead/looted wolf corpse granting precisely one hide
through the actual server profession runtime. Base live near/far
Leatherworking/Enchanting routing also passed. The earlier hide-cache
fixture timed out only because its second attempted activation expected
another result after the prompt was already correctly disabled.

These runs used Roblox Studio's CLI RunScript on unpublished local
places when a separate direct MCP client still could not attach to the
active Studio proxy; the test outcomes are from actual Studio, not
in-memory-only simulation. Source, test and documentation edits remain
GitHub-only. Source code, authored animal factories and cloud places
were not published or merged to main. Actual authored animal dungeon
combat/reward/skin, material-backed live crafting, multiplayer races,
disconnect/retry and real-user DataStore validation remain open.

Latest receipt:
`docs/testing/animal-only-corpse-skinning-studio-verified-2026-09-21.md`.

## Historical staging checkpoint — before the above tests

## 21 September 2026 — animal-only Skinning backend implementation; Studio pending

After v1.53's partially passing profession tests, the active branch gained
a default-deny, server-owned animal Skinning policy. Only an explicitly
tagged, allowlisted Beast corpse is eligible, after death and successful
server loot. The shared ProfessionService grants hide exactly once with
a per-corpse claim and server range check. DungeonEnemyCleanup preserves
only such eligible animal corpses briefly; all existing Marauders and
bosses keep the legacy cleanup path. RawHideCache is still a non-monster
temporary material source. No animal enemy factory has been registered.

All changes (including tests and this handoff) were written to GitHub,
then safely fast-forwarded to the clean Windows integration worktree.
All four Rojo compositions built at
`8655c7e19bc97a9b9c803fc011e2e5a3080c47f3`; **new Studio tests
have not run**. The direct Studio MCP discovery attempt could not reach
Studio, and the delegated Codex route hit a usage limit. The earlier
Base RawHideCache simulated-input timeout is still unresolved. Do not
promote Skinning or the whole v1.53 profession increment to accepted.

Details and pending exact test gates:
`docs/testing/animal-only-corpse-skinning-pending-studio-2026-09-21.md`.
No cloud publish, real-player DataStore run or main merge occurred.

## 21 September 2026 — v1.53 tested locally; live profession acceptance pending

GitHub-first staged source at `45a9bc25a185fcdb00579e977a22dc582eefc1ec`
was safely fast-forwarded to the clean Windows integration worktree.
Four Rojo compositions built; the new ten-suite profession runner
passed in both unpublished local Dungeon and Base Studio Edit places
(Base: 305 assertions), Dungeon general backend matrix passed 30/30,
and the generic Base Play smoke passed. Deterministic full five-profession
chain, migration, material protection, station range and pure request
guard are included in the focused suites.

A new disposable real Base client/server fixture was authored **in
GitHub**, fast-forward pulled and run in Studio Play mode. Actual client
craft requests were rejected when far from Leatherworking/Enchanting
stations and routed to crafting service when near (then rejected for
missing materials). The same fixture **failed** at a scripted
RawHideCache ProximityPrompt hold: no Gather result within 15 seconds.
The live hide claim, material-backed full craft chain, duplicate
requests, independent players and disconnect/retry are not accepted.

Source/testing receipt:
`docs/testing/profession-v153-local-validation-2026-09-21.md`.
Roadmap:
`docs/roadmap/DungeonMMO_Roadmap_v1_53_Professions_Pending_Verification.md`.
All source and document changes are made in GitHub, not via Remote
Desktop. No cloud publish, real-player DataStore validation, main merge
or force-push occurred.

## 21 September 2026 — initial GitHub-only v1.53 staging (historical)

While the authorized Windows desktop is offline, source work continued
**in GitHub only** from accepted v1.52. Skinning, Leatherworking and
Enchanting are staged on the existing profession framework. Fresh
profiles initialize all three; migration still sanitizes every profession
through ProfessionDefinitions.order(). The Base profession runtime now
has a server-claimed RawHideCache placeholder plus distinct temporary
Leatherworking and Enchanting station roots derived from existing Base
anchors.

The staged dependency chain reaches warded_leatherbound_gloves through
Skinning hide, Alchemy oil/flux/essence, Blacksmithing bars,
Leatherworking cured leather/base gloves and Enchanting rune/final
equipment. No second inventory, crafting or profile service was created.

ProfessionRuntime's Base craft RemoteEvent still takes only recipe_id.
Station/distance authority remains server-side. A new per-player
craft-request guard rejects overlapping requests and is released after
completion/error/PlayerRemoving; different players are independent.
The client still cannot submit a minigame success payload into this
RemoteEvent; the current foundation success result remains server-created.

New/extended GitHub tests cover all seven definitions, station recipe
ordering, legacy-profile migration, full multi-profession atomic
dependency/save-reload behavior, equipped-input and wrong-minigame
rejection, station distance and request-lock semantics. The focused
profession runner includes these tests.

**Do not report these tests as passing yet.** No Remote Desktop/local
pull/Rojo/Studio run occurred after v1.52 because the desktop is offline.
Latest verified acceptance remains v1.52. Tomorrow follow:
docs/testing/profession-leatherworking-enchanting-pending-verification-2026-09-21.md.
Roadmap:
docs/roadmap/DungeonMMO_Roadmap_v1_53_Professions_Pending_Verification.md.

## 20 September 2026 — v1.52 Event combat variations and first broader profession backend

The existing, server-frozen after-Room2 late Event slot now accepts
one **non-boss** CombatPack instead of its previous boss where a
disposable run explicitly enables the independent
ServerScriptService DungeonMMOOptionalEventCombatEnabled switch.
A deterministic saved Ambush (4 enemies) or Surge (8 enemies)
is supported in both Temple and Mine Depth2–4; the late
placeholder has eight dedicated spawn anchors. A shared
Event/Secret frequency cap, verified placement, timed window,
physical gate, checkpoint, generic executor and per-enemy
idempotent reward service are reused. No additional Event,
wave scheduler or environmental hazard was added. Old early/
late optional bosses stay the defaults with new switches OFF.

Fresh final 144 variation assertions, 25/25 optional-focused
and 30/30 broad backend suites, four Rojo compositions PASS.
Temple Depth2 Ambush (4) and Mine Depth4 Surge (8) assisted
physical walking runs, actual two-/four-client concurrent
pack trigger, mid-Event real Studio client disconnect, recovery
and replay-proof completion PASS. The old optional-enabled
after-Room1 and optional-disabled Temple Depth2 physical
routes also passed.

Broader backend milestone started: a bidirectional material
recipe chain uses existing Mining, Blacksmithing, Herbalism,
Alchemy, inventory, station catalogue, minigame contract and
atomic profile mutation: iron bar → forging flux →
runic ironbound gloves. 46 new atomic crafting/reload
assertions and 7/7 profession suites passed in both local
Dungeon and Base compositions. This is not completion
of Leatherworking, Enchanting or secure live station/minigame
interactions. No cloud publish, actual player DataStore,
authored art or main merge occurred.

Latest ChatGPT-authored roadmap:
docs/roadmap/DungeonMMO_Roadmap_v1_52_Event_Variations_And_Professions.md.
Test report:
docs/testing/phase4-nonboss-event-profession-chain-2026-09-20.md.
Historical canonical v1.47 DOCX is unchanged.

## 20 September 2026 — v1.51 after-Room2 late Event is physically playable in unpublished Studio

GitHub-first implementation registered a distinct EventArenaLate side
room/bridge/gate, depth-specific trigger, checkpoint and boss spawn in
the replaceable Temple and Mine Depth2/3/4 Studio blockouts. The
independent Workspace DungeonMMOPlaceholderLateEventPlayEnabled
and ServerScriptService DungeonMMOOptionalBossTemplatesEnabled
opt-ins remain OFF in ordinary source; higher-depth and original
optional release switches are unchanged. One Event and one Secret
maximum per run. The existing server-owned gate controller opens
the selected late entrance only after required Room2 is Cleared,
leaving the original early Event and Depth1 bridges sealed. A
reconstructed encounter retains the late boss, slot, checkpoint
and stable encounter-scoped reward identity.

Fresh local acceptance: 85 physical/gate assertions across both
dungeons and Depth2–4, 24/24 optional-focused suites, 30/30
broader gameplay backend suites, four local Rojo builds PASS.
Actual assisted Humanoid:MoveTo physical runs traversed the late
side bridge and completed Temple Depth2 (six encounters) and
Mine Depth4 (eight encounters). Independent two-client Temple
Depth2 and four-client Mine Depth4 Studio runs verified one
boss under concurrent approach, real mid-late-Event client
disconnection, surviving party progression, restored Pending
late Event without resetting Rooms1/2, distinct reused-boss
rewards and replay-proof per-member completion. The old
after-Room1 optional-enabled and fully optional-disabled
Temple Depth2 walking routes passed unchanged.

Detailed receipts and previous one-line fixture test correction:
docs/testing/phase4-late-event-physical-multiplayer-2026-09-20.md.
Latest ChatGPT-authored roadmap:
docs/roadmap/DungeonMMO_Roadmap_v1_51_Late_Event_Physical_Acceptance.md.
The unmodified canonical v1.47 DOCX, v1.48–v1.50 supplements,
real player DataStores, PROD/TEST cloud place and authored models
remain preserved. Real same-account network reconnect and
unassisted whole-party combat are unverified.

## 20 September 2026 — configurable optional Event placement v1.50

GitHub-first code added one authoritative optional placement catalogue,
with unchanged default EventAfterRoom1 and SecretBeforeFinal and an
opt-in EventAfterRoom2 template for Temple/Mine Depth2–4. Issuance
saves the selected Event template once per eligible run; the new
ServerScriptService DungeonMMOOptionalBossTemplatesEnabled flag is
OFF by default and independent of the boss-variant, original optional
and high-depth release switches. Late Event has a distinct
EventArenaLate physical slot and stable encounter/reward identity.
The existing policy now enforces no more than one Event and one Secret
per run, rejects slot conflicts, and requires matching explicitly
verified placement metadata for the late slot. That late arena,
bridge and gate do NOT exist in registered physical content yet:
late selection fails closed as OptionalBossContentUnavailable;
do not present it as physically playable. Existing layout/default
variant routes are unchanged.

New template tests passed 274 assertions; 23/23 optional-focused,
30/30 broad backend suites and four local Rojo builds passed. Fresh
original Temple Depth2 six-encounter assisted physical Play mode PASS;
fresh alternate Event/Secret Temple Depth2 six-encounter assisted
physical Play mode and each reward replay PASS. Its initial fixture
retry failed at RunScript:66 because the TEMP seed-override search
expected the old issuance signature; the fixture was updated through
GitHub and the fresh rerun passed. Report:
docs/testing/phase4-optional-event-placement-templates-2026-09-20.md.
Roadmap update:
docs/roadmap/DungeonMMO_Roadmap_v1_50_Optional_Event_Placement.md.
No TEST/PROD publish, DataStore, authored geometry, main merge or
user account work was performed.

## 20 September 2026 — dynamic optional Event/Secret variants ACCEPTED locally

New server-only DungeonMMOOptionalBossVariantsEnabled (default false)
enables a deterministic, run-frozen choice of one of two registered
implemented boss placeholders per optional kind in Temple/Mine.
The existing Event window, Secret probability, session save, plan
insertion, optional gate and dungeon release locks are unchanged.
The Secret discovery service now validates the saved dungeon-scoped
variant identity instead of only legacy boss IDs. BossEncounterExecutor
uses encounter-scoped DungeonEnemyId for EventBoss/SecretBoss/
MiniBoss/FinalBoss, preventing reused factories in a single run from
sharing reward receipts; legacy Depth1 Boss identity is unchanged.

GitHub-first tests: 2,205 dynamic selection/reconstruction assertions,
232 original/alternate Secret discovery assertions, 80 reward
identity/replay assertions, 22/22 optional-focused suites and 30/30
broad backend suites PASS; four local Rojo compositions built.
TEMP assisted Temple Depth2 and Mine Depth4 physical alternate-boss
routes and the variant-disabled Temple Depth2 route PASS.
Four-client Mine Depth4 alternate Event/Secret Play mode PASS:
one Event boss on concurrent approach, one real member disconnects
during Event, three finish the run, each receives independent rewards
for an alternate boss and its returning miniboss appearance, and
per-member final completion replay remains blocked.
Full logs, prior failed tests, fixes and caveats:
docs/testing/phase4-dynamic-optional-boss-variants-2026-09-20.md.
Roadmap: docs/roadmap/
DungeonMMO_Roadmap_v1_49_Phase4_Dynamic_Optional_Variants.md.
No cloud publish, DataStore mutation, meshes or PROD change.

## 20 September 2026 — higher-depth optional multiplayer lifecycle checkpoint

GitHub-first, disposable local Studio Play-mode fixtures passed Temple and
Mine Depth2/4 two- and four-client shared party runs. Two clients entering
Event or Secret spawn one boss. Real Studio PlayerRemoving during Event
or Secret preserves the surviving 1/3 members, frozen plan, checkpoint and
ongoing encounter; the survivors complete their higher-depth route.
The actual per-member completion save/replay check passed for a 2→1
Temple Depth2 Event disconnect and a 4→3 Mine Depth4 Secret disconnect.
The strict test initially exposed proper DifficultyProgressionFailed
protection on newly created higher-depth profiles; the fixture now gives
disposable members prior depth clears through the normal progression
service rather than disabling the completion barrier. Service-level
1/2/4-member optional boss wipe/automatic revive tests passed 392
assertions across both dungeons and Depth2/4; 19/19 optional focused
and 30/30 broader gameplay backend suites plus all four local Rojo builds
passed. Report: docs/testing/
phase4-higher-depth-multiplayer-lifecycle-2026-09-20.md.
True same-account network rejoin/new reserved-server restart, in-Play
whole-party wipe and cloud release remain unverified; higher-depth and
optional release flags remain OFF, with no real player DataStores touched.

## 20 September 2026 — roadmap v1.48 supplement (ChatGPT-authored)

The repository roadmap index now points to
`docs/roadmap/DungeonMMO_Roadmap_v1_48_Phase4_Backend_Update.md`.
It records the accepted six Depth2–4 Temple/Mine assisted walking routes,
one Mine Depth4 deferred Secret backtrack, and the next backend milestone:
1/2/4-member optional encounter lifecycle, concurrent trigger protection,
disconnect/wipe/checkpoint recovery and per-member one-time rewards.
The historical canonical long-form `DungeonMMO_Roadmap_v1_47.docx`
is preserved; the v1.48 update is a separate versioned supplement.
Cloud TEST acceptance, real same-account cross-server rejoin, unassisted
all-room combat, authored art and PROD remain independent future gates.
No Roblox publish or DataStore change was performed by this roadmap update.

## 20 September 2026 — Depth2–4 optional physical playtest complete

TEMP-only higher-depth Temple and Mine blockouts now provide real
walkable, gated Event/Secret side rooms attached to Room1 and the
selected depth's penultimate required room. Higher-depth optional
layout registration is restricted to the explicitly opted-in,
unpublished local Studio placeholder; release switches remain OFF.
The shared entrance-gate controller targets the active depth's bridge
and keeps unused Depth1 bridges sealed. GitHub-first source/test changes
were fast-forward pulled into the existing Windows integration worktree.
Both dungeons × Depth2/3/4 passed six independent assisted walking
Play-mode routes (6/7/8 encounters respectively), including actual side
bridge traversal, boss trigger/spawn identities and final completion.
A seventh Mine Depth4 Play-mode run physically bypassed Secret, returned,
cleared the deferred boss and then completed Final using a TEMP-only
final-spawn deferral. Structural regression: 139 assertions; 18/18
optional-focused suites and 30/30 backend matrix PASS. Original
optional-disabled Temple Depth2 four-room Play mode PASS; all four
local Rojo compositions built. Detailed dated logs and caveats:
docs/testing/phase4-depth2-4-optional-physical-playtest-2026-09-20.md.
No published Roblox cloud place, PROD, player DataStore, meshes or
canonical roadmap DOCX were changed.

## 20 September 2026 — depth-specific optional events and shared side gates

GitHub-first continuation on wip/phase-4-test-hud-integration-v1.
Reproduced and fixed two defects: the Secret entrance had a hard-coded
Room2 prerequisite (wrong for Depth2–4), and Mine placeholder Event/
Secret gates were never synchronized because the controller recognized
only Temple. Gate prerequisites now come from the frozen encounter
binding order; both named synthetic dungeon roots use the same controller.
Synthetic backend tests cover two dungeons × four depths × all four
Event/Secret eligibility combinations and timed-event snapshot recovery.
Fresh Studio: 712 depth/eligibility, 116 expiry/recovery, 32 gate
assertions and 17/17 focused suites PASS. Assisted Temple and Mine
Depth1 optional route fixtures PASS; 30/30 backend suites and four
local Rojo compositions PASS. Evidence:
docs/testing/phase4-optional-depth-events-and-side-gates-2026-09-20.md.
Depth2–4 optional physical side-room layouts are NOT registered or
playtested and their release switches remain unchanged. No cloud publish,
DataStore, authored mesh or PROD changes.

## 20 September 2026 — four-depth progression backend verification

On the existing integration branch, a GitHub-first test-only update
validated both Temple and Mine Depth1–4 ladders with 454 assertions and
five focused Studio suites PASS. Tests cover 3/4/5/6 ordered rooms,
Depth4 returning miniboss identities, persistent sequential unlocks,
checkpoint/miniboss recovery, one-time completion rewards and separate
dungeon progression. Four Rojo builds, the 30/30 backend matrix and
Base Play-mode regression passed. One fresh assisted Temple Depth2
physical-route fixture passed; the other five higher-depth physical
routes retain their documented 19 September individual passes.
Actual high-depth entry remains release-locked: the test uses an
injected readiness provider ONLY for logical unlock simulation.
No production runtime or cloud/DataStore state was changed. See
docs/testing/phase4-depth1-4-progression-integration-2026-09-20.md.

## 20 September 2026 — full optional-session recovery regression

A GitHub-first test-only continuation added comprehensive two-member
persisted-session reconstruction over the existing recovery controller,
session service, optional barrier flow and reward service. A fresh TEMP
Dungeon Rojo build and Studio focused suite passed 15/15 modules;
DungeonOptionalFullSessionRecoveryTest passed 42 assertions. The
assisted physical Temple Secret-backtracking route passed again.
Server reconstruction was emulated with new service/controller instances
and shared in-memory persistence; this is NOT a same-account Roblox network
rejoin or a cloud deployment. No production source or DataStores changed.
See docs/testing/phase4-optional-full-session-recovery-2026-09-20.md.
The user also reported successfully soloing both optional bosses
manually; the earlier failed automated injured-solo fixture remains
a separate historical result.

## 20 September 2026 — consecutive optional combat and real recovery verified

Two real Studio clients defeated Event and then Secret using normal client
attacks and ordinary character HP in a single temporary Temple run.
A second two-client run additionally verified server-accepted Dodge and
an equipped healing skill restoring approximately 32 HP between fights;
Secret and assisted final-room progression completed afterward.
The earlier injured single-survivor solo attempt remains a failure:
this is co-op acceptance, not solo balancing acceptance. New fixture
scripts: phase4_event_secret_consecutive_coop_combat.luau and
phase4_optional_boss_skill_defense_coop_combat.luau. Full parent/child
logs, limitations and receipts:
docs/testing/phase4-optional-boss-consecutive-skill-defense-2026-09-20.md.
No published experience, PROD, DataStore or models were changed.

## 20 September 2026 — normal optional-boss combat evidence

Two separate local two-client Studio fixtures defeated TempleEventBoss
and TempleSecretBoss using real client attack inputs at ordinary character
health; optional boss HP was never directly changed by the test harness.
The combined back-to-back solo-survivor attempt FAILED: after beating
Event with 34/113 HP remaining, the player died against Secret at
56.7/120 HP. A separate two-client Secret fight PASSED with a healthy
party (survivor 70.6/113 HP). The test driver positioned combatants and
assisted prerequisite rooms/final boss. Continue testing legitimate
healing/defense/party play before accepting the consecutive encounter
route. Evidence: docs/testing/
phase4-optional-boss-normal-combat-playtest-2026-09-20.md.
No cloud publish or player DataStore changes occurred.

## 20 September 2026 — real local Studio two-client optional-boss pass

On integration source c571552, two simulated Studio clients were admitted
into the same eligible Temple optional-boss run. A second player entering
Event did not duplicate its boss; one client disconnected mid-fight while
the peer retained the run, checkpoint and Active boss. The peer then
cleared Event, Room2, Secret and the final boss; reward replay was
idempotent. A detached sequencer verified interrupted Event would
reconstruct as Pending without replaying Room1. Two fresh local runs
passed, including 20260920T161203Z_Studio_B6E09_last.log and
child 20260920T161212Z_Studio_F969B_last.log. Details:
docs/testing/phase4-optional-boss-two-client-playtest-2026-09-20.md.
Still not proven: same-account network rejoin/new-server recovery and
normal unassisted combat. No published place or DataStore modified.

## 20 September 2026 — optional-boss lifecycle local hardening

On wip/phase-4-test-hud-integration-v1, a failed persisted normal/Event
encounter start now rolls back to Pending; a failed persisted optional
Secret skip restores the saved pre-skip sequence snapshot. Both defects
were reproduced with RED Studio tests before the fixes. Fresh local
Studio focused tests: 14/14 suites PASS (11 failure-recovery, 24
two-member recovery, 28 optional gate assertions). Five Rojo builds,
assisted physical Temple Secret-backtrack/final-completion Play mode,
normal Dungeon baseline, and a two-client real PlayerRemoving
disconnect fixture all PASS. Evidence:
docs/testing/phase4-optional-boss-lifecycle-hardening-2026-09-20.md.
The two-client fixture did not run optional combat or same-user rejoin.
Phase 4 remains ACTIVE; no cloud publish, DataStore update or art work.

## 20 September 2026 — TEST Temple optional gate recovery verification

Active integration branch: wip/phase-4-test-hud-integration-v1. Optional
entrance gate runtime/placeholder implementation is already committed at
f6d6401; roadmap v1.47 is committed at 1083c01. Fresh TEMP TEST Temple
and Dungeon test-composition Rojo builds succeeded. Focused Studio tests:
13/13 suites PASS; entrance gate tests: 16 assertions PASS after adding
three persisted-state recovery/resynchronization checks. Studio log:
20260920T151636Z_Studio_1BE9F_last.log. Fresh TEMP Temple physical
backtracking also passed in 20260920T151909Z_Studio_C434B_last.log:
both gates started closed, Room1 opened Event, Room2 opened Secret,
backtracked Secret cleared and final Room3 completed (assisted fixture).
The TEST cloud gate version is UNVERIFIED after an HTTP 429 script commit
attempt; no new cloud publish or DataStore mutation occurred. Before a new
publish, confirm and back up existing TEST Dungeon 117293035754309 and
verify fresh cloud gameplay. Next backend work remains Phase 4 Content Alpha.

## 19 September 2026 — combined Phase 4 TEST Temple + restored HUD integration

**Active new worktree/branch:** DungeonMMO_Phase4_HUD_Integration_v1 /
wip/phase-4-test-hud-integration-v1. The isolated merge
43e175f4f2ad4fb3140a36a0ae99ccde49d11825 joins the backend parent
f00e581 and saved UI parent 7fa63fb; both original branches and worktrees
remain untouched. Pushed immutable source checkpoint tags:
phase4-before-hud-integration-backend-20260919 and
phase4-before-hud-integration-ui-20260919. All three documentation
conflicts retained BOTH historical branches' text.

The original framed profile/portrait, bottom-right menu, six-slot Dungeon
hotbar, contextual Inventory/Skills/Guild windows and redesigned dungeon
objective/boss/reward/revive HUD have been restored to the TEST candidate.
The Base intentionally has no Dungeon combat hotbar. Both TEST Temple and
sync-only Lobby build compositions contain their matching UI source.

**Fresh proof:** six Rojo compositions and 559 source+41 original Studio
runner Luau files compiled; 11/11 focused optional suites; Base live
regression 107 test-pass markers (four Roblox Controls Emulator plugin
errors); Dungeon live regression 221 test-pass markers and zero Creator
errors. The restored Dungeon HUD live-client test passed framed/menu/hotbar,
boss animated bar, rewards and revive with zero Creator errors. The Base
live-client test passed framed/profile/menu/expedition UI, exclusive
Inventory/Skills/Guild open and close (same Controls Emulator plugin
errors). The exact combined TEST Temple composition passed both local
published-ID simulations for Depth1 optional arenas and Depth4 physical
bindings; those runs logged a built-in Roblox ChatScript SetCore startup
error, not a game-code assertion failure. Final visual/playtest acceptance
is STILL OPEN.

**Cloud release boundary:** no TEST/PROD cloud publish or current cloud
place rollback backup has been verified. For the restored HUD release
candidate use scripts/powershell/Start-Phase4TestTempleHUDPublish.ps1 in the
integration worktree, NOT the old backend-only launcher. Before any TEST
publish, save/verify the currently published Temple Roblox place
117293035754309 and note its version history. The Lobby
134132328219009 is sync-only: never overwrite its authored map with
the standalone local Rojo sync file. No Mine place exists.

Detailed preserved evidence and remaining manual gates:
docs/testing/phase4-restored-hud-test-integration-2026-09-19.md.


## 19 September 2026 — TEMP playable physical layouts, both dungeons Depth1–4

This checkpoint supersedes the older **geometry-only** placeholder status
below; the separate editable `.rbxlx` remains geometry-only, while the
**source-generated, explicitly opted-in unpublished Studio** layouts now have
real runtime physical bindings. Temple/TestDungeon and AbandonedMine each
passed all three 4/5/6-room Depth2/3/4 physical encounter sequences, including
Depth4 three returning minibosses + final boss. Both dungeons' Depth1
Event/Secret fight, skip and on-foot optional-room traversal cases also
passed. Combat kills and high-depth player health were assisted in these
fixtures; these are not unassisted player combat/release acceptance.

- Source up to `e3b3022` passed four Rojo compositions, 549 source and
  30 Studio runner compilation checks, and all 11 focused edit-mode suites.
- Base fresh regression passed, 107 PASS markers and zero Creator errors.
  Two ordinary Dungeon regression attempts failed intermittent pre-existing
  combat-test startup deadlines despite live baseline success. Only those
  test waits were extended to 25 seconds. A fresh Dungeon regression at
  `37cef9b` passed the player and dummy assertions, 221 PASS markers, and
  zero Creator errors.
- Explicit unpublished Studio-only opt-in:
  `DungeonMMOEnvironmentMode=Synthetic`,
  `DungeonMMOPlaceholderPhysicalContentEnabled=true`,
  `DungeonMMOPlaceholderPlayableEnabled=true`; Depth1 optional physical
  slots require the separate `DungeonMMOPlaceholderOptionalPlayEnabled`
  opt-in. Runtime optional-boss eligibility/release is still separately
  locked; do not copy TEMP fixture overrides into live source.
- The shared production content catalogue still only registers Depth1;
  higher-depth `RuntimeReleaseEnabled` and both
  `OptionalBossRuntimeEnabled` values remain false. No main merge,
  production or TEST Roblox publish, or DataStore mutation occurred.
- Full log receipts, scenario IDs, code paths and remaining limits:
  `docs/testing/phase4-placeholder-playable-layouts-closeout-2026-09-19.md`.
  Final authored room geometry, ordinary combat/balance/UI, same-user
  reconnect and release acceptance remain separate gates.


## 19 September 2026 — replaceable dungeon physical placeholders available

- Editor-ready **geometry-only** Studio scene:
  `content/placeholder/DungeonMMO_PhysicalBlockouts_v1.rbxlx`.
  It includes separate Temple and Mine EventArena/SecretArena Models, walkable
  bridges, and unregistered Depth2/3/4 room/corridor previews (330 editable
  parts in 62 models). Studio static geometry verification passed.
- The source builder is
  `src/ServerScriptService/Dungeon/DungeonPlaceholderPhysicalContent.luau`;
  its opt-in synthetic Studio bootstrap can preview current Depth1 with
  placeholders while leaving both optional boss flags false and higher-depth
  physical layouts unregistered.
- **This is a replaceable blockout, NOT final authored release geometry or
  playable high-depth content.** The standalone editor scene has no runtime
  scripts and its visual anchor markers are not registered live bindings.
  Keep encounter/anchor identities when replacing with meshes/models.
- Usage/validation and limitations:
  `docs/testing/phase4-physical-placeholders-2026-09-19.md`.
  No merge to main, TEST/PROD publish or optional-boss rollout occurred.

## 19 September 2026 — remaining release gates: local proof, NOT release acceptance

The earlier four-step **backend** checkpoint below remains valid. New
TEMP-only Play-mode scripts have now additionally verified: real simulated
client leave and a separate client's arrival in Base, actual Dungeon
PlayerRemoving persisting a disconnected member while its peer/plan/checkpoint
remain active (the Studio party session uses a fixture-only override),
on-foot walking through all five synthetic Temple and Mine encounters without
per-room teleport, and one standard client basic attack reducing the live
Temple Event boss from 144 to 134 health. Boss combat and progression other
than that single attack still used explicit fixture assistance.

- Latest new fixture source: 0c2251633b70f92314abc4d0ec9d4fd50bb1dbe4.
- Evidence: docs/testing/phase4-remaining-release-gates-local-proof-2026-09-19.md.
- The departed Studio client's replacement has a **different UserId**; a true
  same-account rejoin, published cross-place transfer and production group
  admission have NOT been exercised. Real authored side rooms, an entire
  unassisted boss fight and visual/UI acceptance also remain unverified.
- Optional-boss rollout remains disabled; no main merge, TEST/PROD publish
  or production DataStore change is approved by these local fixture results.
- Next gated action: obtain explicit permission before using the isolated
  published TEST environment for same-account reconnect and cross-place tests.
  Do not mark Phase 4 release accepted on the basis of the local probes.

## Current checkpoint — 19 September 2026: four backend steps verified

The following supersedes the earlier Step 2-only status; historical evidence
remains below. **Gameplay/test source**: 3700dba7c6124e3401b615ce126d80cb7f1edb88.
**Final normal-regression/static source**: c86a90471cc3c36bbd9437ada685f4377d7e2ebe.
Branch: wip/phase-4-event-secret-policy-v1, isolated from main, UI and art.

- Recovery: event window, plan, discovery and cleared/skipped encounters survive
  session/controller reconstruction; interrupted boss returns to Pending;
  duplicate reward replay is blocked. Live Temple fixture simulated member
  disconnect/reconnect while the actual Studio player remained connected.
  **A real network leave/rejoin or cross-place handoff is NOT proven.**
- Mine: TEMP Play-mode fought-secret and skipped-secret paths both completed.
  Skipping persisted without secret discovery or secret reward.
- Four bosses have different server-authoritative two-phase attack patterns
  using existing Captain pose, telegraph, hit and defence systems. TEMP Temple
  and Mine combat fixtures passed with test-assisted positioning and defeats;
  natural battle balance and presentation are not proven.
- 11/11 focused Studio edit-mode suites passed on 3700dba. At c86a904, all
  four local Rojo compositions built; 547 Lua/Luau files parsed without error.
  Fresh unpublished Base/Dungeon Play baselines: respectively 108 and 222
  test PASS markers, zero Creator errors, and both release locks stayed false.
  Base Phase 3 stress passed (profiles=250, market=1000, replay=1000,
  guild=250, sessions=100, race_roundtrips=100).
- Evidence: docs/testing/phase4-optional-boss-four-backend-steps-closeout-2026-09-19.md.
- Canonical working roadmap is docs/roadmap/DungeonMMO_Roadmap_v1_45.docx
  (SHA-256 349d8a568856091ec2dbdadfde4b7785f608e65d2ac8f2429c838d9a86a943ac);
  roadmap index docs/roadmap/README.md. DOCX structural validation passed;
  visual page-render QA is still pending following a stalled Word export.
  TEMP-only synthetic fixtures do not imply authored side-arena acceptance.
  OptionalBossRuntimeEnabled remains false; higher-depth physical layouts
  remain unreleased. Do not merge to main or publish based on these tests.
- Next release/content gates: genuine client/network reconnect, authored
  room traversal, unassisted combat and player-facing UI, multiplayer/cross-place
  admission and final release acceptance.

## Current checkpoint - 19 September 2026 Step 2 GitHub-first backend proof

This section supersedes the Step 1 status below; its validation details remain
historical evidence, not a statement about the current source.

- Active backend branch: wip/phase-4-event-secret-policy-v1.
- Step 2 code and test source validated at ae1ab32be03fe5c2ff9874f95df49a8c56ff069a.
  The former uncommitted work was preserved and pushed at bd83446. Later
  gameplay/test changes were committed directly using the Amidazs GitHub
  connector, then fast-forwarded into the clean isolated backend worktree.
- Server-only candidate event schedule and secret discovery, independent boss
  reward identities and optional book drops are implemented. Rollout remains
  disabled for both dungeons; no physical side arenas or higher-depth physical
  layouts have been registered.
- All four local Rojo builds passed; 544 Lua/Luau source files compiled with
  zero failures at ae1ab32. A fresh TEMP local Studio RunScript session passed
  eight optional-boss EDIT-MODE suites: RunState, Schedule, SecretDiscovery,
  Policy, Flow, Factories, ReleaseLock and Reward.
- Edit-mode tests are not a live Play-mode or physical/gameplay acceptance test.
  TEMP-only physical trigger/combat/reward/reconnect checks and broad
  Base/Dungeon Play-mode regressions remain before release consideration.
- Main, UI/art worktrees, published games and production data were not changed.
- Source-controlled runner: scripts/studio/optional_boss_focused_tests.luau.
  Detailed evidence: docs/testing/phase4-optional-boss-step2-backend-checkpoint-2026-09-19.md.
- Next: complete the live/physical acceptance gate separately; then continue
  backend-only work on distinct Event/Secret boss combat behaviour. No merge
  or publish is authorised by this checkpoint.

## Current checkpoint - 19 September 2026 step 1 validation

This section supersedes older active-branch, no-push and pending-Studio notes
below. Older gate sections are historical evidence, not current release status.

- Active worktree: C:/Users/Remko/Documents/Roblox/DungeonMMO_Phase4_EventSecretPolicy_v1.
- Branch: wip/phase-4-event-secret-policy-v1.
- Validated source: cb29a7c54637e371e1041ab68009c4951b579d00.
- GitHub feature tip independently verified at the same SHA on 19 September.
- Main and GitHub main remain a3c2625cfc53dbb1c2bb8d6ce17f5f3749809fa9;
  this backend branch is not merged into main.
- v1.44 is now committed on this feature branch. Its statements about the
  uncommitted issuer/test edits and an unpushed optional-boss branch are
  superseded by this checkpoint.
- Step 1 backend regression is VERIFIED on the exact committed source.
  This is not physical-content acceptance or rollout approval.
- Fresh Dungeon Studio: issuer 34, extended instance director 23, policy 49,
  optional flow 9, factories 24, release locks 14, readiness 70 assertions PASS.
- Dungeon server captured 248 PASS markers and zero errors; live admission passed.
- Fresh Base Studio: 132 PASS markers, issuer 34, readiness 70, party difficulty
  22 and party difficulty entry 32 assertions PASS; server/client errors = zero.
- Phase 3 stress PASS in both compositions: profiles=250, market=1000,
  replay=1000, guild=250, sessions=100, race_roundtrips=100.
- 539 source Lua/Luau files parsed with zero failures; four Rojo builds PASS.
- OptionalBossRuntimeEnabled remains false for both dungeons. Depth2-Depth4
  remain physically unregistered and release-disabled.
- No gameplay source changed in this validation step. Documentation/evidence
  changes remain uncommitted; no commit, push, merge or publish was performed.
- Known diagnostics: expected audit-sink failure injection in both runs;
  source-controlled fallback-animation notice in Dungeon. Neither is a test failure.
- Evidence: docs/testing/phase4-optional-boss-step1-validation-2026-09-19.md.

### Exact next action

At the step-1 user checkpoint, report the completed backend validation.
Next ordered step is Event and Secret gameplay rules: prepare a bounded design
for actual server event schedules, secret discovery conditions and reward
configuration, reusing existing issuance/session/reward authority. Define
reconnect/idempotency tests before implementation. No concrete schedule,
secret-discovery mechanic or new reward balance is approved by this record.
Distinct enemy/boss mechanics follows as the next substantial combat gate.
Keep physical release locked and the UI/art worktrees separate.

## Historical gate record

**State date:** 18 September 2026
**Canonical long-form roadmap:** docs/roadmap/DungeonMMO_Roadmap_v1_44.docx
**Current phase:** Phase 4 - Content Alpha
**Phase 2 - Vertical Slice:** FORMALLY COMPLETE / ACCEPTED
**Phase 3 - Systems Alpha:** FORMALLY COMPLETE / ACCEPTED
**Phase 3 gameplay release checkpoint:** 84662948127eb1a37c9f184c6abbafe6f2daddb6

## Canonical release boundary

Phase 3 is closed. The accepted gameplay release checkpoint was pushed to the
Phase 3 feature branch and to main, then independently verified so local main,
origin/main and the GitHub server main ref all resolved to 84662948127eb1a37c9f184c6abbafe6f2daddb6 before
the documentation closeout.

Published TEST places:

- Starting Base: 134132328219009
- Dungeon: 117293035754309
- Universe: 10765241947

The Dungeon was published first and the Starting Base second. Roblox Studio's
publish state machine reached PublishSuccessful for both places. No PROD place,
Robux purchase flow or production DataStore action was used.

## Accepted Phase 3 systems

The accepted Systems Alpha boundary now includes:

- reusable Quest/objective state and first race-specific Secondary-Class
  Advancement architecture;
- persistent, server-authoritative contribution channels for Damage, Tank and
  Support;
- schema-backed Blueprint / Recipe Knowledge and authoritative teaching-item
  consumption;
- persistent Bestiary and Scholars Reputation foundations;
- Rogue as the deliberately selected fourth prototype starting archetype;
- Human Duelist and Elf Windstalker as prototype race-specific Rogue
  advancement targets;
- broader Rogue skill-tree/progression architecture while retaining the
  accepted limited active loadout;
- deterministic Dungeon modifiers: Fortified, Rich Deposits and Bounty;
- Rich Deposits interaction with reconnect-safe personal profession gathering;
- Guild creation, membership, Leader/Officer/Member roles, Guild XP, Guild
  Gold, leader-only level upgrades and a private functional Guild Hall;
- a limited fixed-price player-market proof with escrow, tax, tradability
  checks, buy/cancel/expiry recovery and replay-safe transactions;
- DEV/TEST Race Change preview/apply with per-race advancement history,
  incompatible skill/proficiency archive, SP release and restore-on-return;
- shared economy audit events and request-rate/replay/ownership validation;
- the reusable persisted entity-adapter boundary used by shared MMO entities.

The current profile schema is v13. Schema v13 adds independent persistent
Dungeon difficulty progression while preserving legacy `DungeonProgress`.

## Final runtime and stress evidence

The final consolidated Studio regression round on 18 September 2026 included,
among other accepted families:

- Rogue Definitions: 43 assertions PASS;
- Rogue Progression: 17 assertions PASS;
- Rogue Advancement: 12 assertions PASS;
- Class Advancement: 29 assertions PASS;
- Contribution Service: 36 assertions PASS;
- Contribution Damage Bridge: 9 assertions PASS;
- Contribution Support Bridge: 13 assertions PASS;
- Contribution real-session persistence: 10 assertions PASS;
- Bestiary Service: 33 assertions PASS;
- Bestiary/Reputation reward integration: 25 assertions PASS;
- Guild membership authority: 21 assertions PASS;
- Guild Service / Guild Hall / Dungeon progression: PASS;
- Market listing, purchase recovery, cancel/expiry and remote contracts: PASS;
- Race Change planner, migration, service and remote-contract tests: PASS;
- Economy Audit Integration: 27 assertions PASS;
- Entity Adapter Contract: PASS;
- Dungeon Modifier Definitions: 6 assertions PASS;
- Profession Resource Distribution: PASS;
- existing Phase 1/2 combat, progression, equipment, Bank, Travel, Dungeon,
  reward, revive and session regressions remained green in the same run.

The Phase 3 stress harness passed:

- 250 profile cycles;
- 1,000 market operations;
- 1,000 duplicate/replay attempts;
- 250 guild operations;
- 100 session cycles;
- 100 race-change round trips.

No duplicate/lost value or invalid final profile state was accepted by the
stress gate.

Detailed closeout evidence is recorded in
docs/testing/phase3-systems-alpha-acceptance-record.md.

## Explicit Phase 3 deferrals

Two roadmap concepts were intentionally not implemented:

- **Progression catch-up** - defer until real player population/progression data
  demonstrates a need.
- **Transmog** - defer until the equipment/content catalogue is mature enough to
  justify wardrobe engineering.

These are future work, not missing Phase 3 exit criteria.

## Phase 4 backend gates

Phase 4 - Content Alpha remains active.

The user has explicitly parked Starting Base presentation, modelling, meshes and
environment-art work for now.

The **Progressive Dungeon Depth + Difficulty backend foundation** remains local
green at `1230e6c`. It provides schema v13 depth progression, authoritative
difficulty routing, 3/4/5/6 logical-depth definitions, scaling and fail-closed
Depth2-Depth4 content.

The follow-on **Generic Dungeon Encounter Runtime** gate is now
**LOCAL GREEN / AWAITING PROJECT-OWNER CLOSEOUT**.

Implementation checkpoint:

`5ba9f4d`

Accepted local engineering result:

- live Depth1 Room1 -> Room2 -> Boss progression authority is now the generic
  encounter sequencer rather than hard-coded clear booleans;
- arbitrary ordered encounter counts are supported by the generic controller;
- encounter kinds include Combat, MiniBoss, Boss, FinalBoss, EventBoss and
  SecretBoss;
- optional encounters support deterministic before/after insertion;
- Event/Secret activation is evaluated only from server-owned InstanceState;
- materialized encounter plans are persisted so reconnect cannot reroll an
  Event/Secret encounter that already exists in the run;
- required inserted encounters cannot be bypassed by later room triggers;
- stable encounter-derived checkpoints coexist with legacy Room1/Room2/Boss
  checkpoint aliases;
- existing EncounterService IDs, enemy/reward implementations, doors and
  Captain/Foreman implementations remain compatible;
- current Depth1 physical bindings fail closed if an activated optional
  encounter lacks an explicit authored room/spawn/checkpoint binding;
- no Event/Secret boss content is enabled yet;
- Depth2-Depth4 remained fail closed at this checkpoint;
- no modelling, meshes, terrain, authored rooms or environment-art work was
  performed.

The follow-on **Encounter Execution / Spawn Registry** gate is now
**LOCAL GREEN / AWAITING PROJECT-OWNER CLOSEOUT** at:

`fe1856e`

Accepted local engineering result:

- encounter descriptors select stable execution/content IDs;
- CombatPack execution resolves through a server-owned spawn catalogue;
- Boss-family execution resolves through stable BossId -> factory registration;
- MarauderCaptain and CorruptedForeman are the currently registered boss
  contents;
- DungeonRuntime no longer chooses concrete Marauder/Captain/Foreman factories;
- encounter startup is transactional across validation, generic sequence start,
  spawn and EncounterService registration;
- failed execution rolls Active back to Pending;
- downstream start rejection cleans spawned content and rolls back;
- partial combat-pack and boss-factory failures clean up safely;
- boss duplicate protection is scoped by session + stable encounter ID, allowing
  multiple miniboss/boss/event/secret encounters in one run;
- missing future packs/boss IDs/factories/bindings fail closed;
- no Event/Secret boss content is enabled yet;
- Depth2-Depth4 remained fail closed at this checkpoint;
- no modelling, meshes, terrain or authored-room work was performed.

Final local evidence includes:

- **494** Lua/Luau files parsed with 0 failures;
- clean `git diff --check`;
- all four Rojo compositions building;
- real Temple registry-driven acceptance PASS with **15 assertions**;
- forced Abandoned Mine event+rare registry acceptance PASS with
  **16 assertions**;
- final repeat committed Dungeon regression green with no project errors;
- final committed Base regression green with no project errors;
- Phase 3 stress harness still passing in both final compositions;
- source-boundary audit: **26 changed code/test files, 0
  art/model/mesh/terrain/image files**.

Prior encounter-execution gate worktree:
C:\Users\Remko\Documents\Roblox\DungeonMMO_Phase4_EncounterExecution_v1

Prior encounter-execution branch:
wip/phase-4-encounter-execution-registry-v1

Design/spec:
docs/superpowers/specs/2026-09-18-phase-4-encounter-execution-registry-design.md

Acceptance evidence:
docs/testing/phase4-encounter-execution-registry-acceptance-record.md

No push, merge or Roblox publish has been performed for this gate.

The follow-on **Multi-Depth Physical Room-Binding Runtime** gate is now
**LOCAL GREEN / AWAITING PROJECT-OWNER RELEASE CLOSEOUT** at:

`1aa81b5`

Accepted local engineering result:

- physical room metadata is data-driven through generic layout definitions;
- logical encounters bind to generic room slots, triggers, spawn anchors, exit
  barriers and stable checkpoints;
- live DungeonRuntime progression no longer branches on fixed
  Room1/Room2/Boss clear cases;
- boss placement is binding-specific rather than hard-coded to one depth;
- checkpoint recovery remains compatible with legacy Depth1 aliases;
- Temple compatibility passed 23/23 assertions through the real generic path;
- forced Abandoned Mine + DeepEchoes + CrystalBloom compatibility passed 23/23;
- both production dungeons explicitly reject unimplemented Depth2, Depth3 and
  Depth4 physical layouts;
- Depth2-Depth4 therefore remained fail closed at this checkpoint;
- future EventBoss/SecretBoss insertion remains supported by the generic
  binding contract but no such content is enabled;
- no modelling, meshes, terrain or authored-room work was performed.

Final committed acceptance from `1aa81b5` includes:

- **501** Lua/Luau files parsed with 0 failures;
- clean `git diff --check`;
- all four Rojo compositions building;
- Dungeon Encounter Bindings: **30 assertions PASS**;
- Dungeon Encounter Flow: **24 assertions PASS**;
- Dungeon Encounter Recovery: **10 assertions PASS**;
- final committed Dungeon regression green, including Phase 3 stress,
  Training Dummy, Combat Target Rules and successful player admission;
- final committed Base regression green, including party/difficulty families
  and Phase 3 stress;
- source-boundary audit from `2deb540`: **12 changed code/test files, 0
  art/model/mesh/terrain/image files**.

Prior multi-depth room-runtime worktree:
C:\Users\Remko\Documents\Roblox\DungeonMMO_Phase4_MultiDepthRoomRuntime_v1

Prior multi-depth room-runtime branch:
wip/phase-4-multidepth-room-runtime-v1

Acceptance evidence:
docs/testing/phase4-multi-depth-room-runtime-acceptance-record.md

No push, merge or Roblox publish has been performed for this gate.

The follow-on **Dungeon Runtime Content Readiness Registry** gate is now
**LOCAL GREEN / AWAITING PROJECT-OWNER RELEASE CLOSEOUT** at:

`2e2420b`

Accepted local engineering result:

- a shared runtime-content catalogue is now the single static source for
  physical layouts, combat packs, boss content, executor IDs and boss-factory
  IDs used by Base/Dungeon readiness decisions;
- the old `RuntimeReady` difficulty property has been removed;
- `RuntimeReleaseEnabled` now means only the explicit rollout switch;
- `DungeonRuntimeContentReadiness` computes `ContentComplete`,
  `ReleaseEnabled`, `Ready` and machine-readable missing-content issues;
- Base-side progression entry and TeleportCoordinator use computed readiness
  rather than reading a release switch directly;
- not-ready content is rejected before reserved-server creation;
- Dungeon execution bootstrap cross-checks shared implemented declarations
  against actual server-side executor/factory registrations;
- both current Depth1 dungeons report content complete + release enabled +
  ready;
- Depth2-Depth4 in both current dungeons report content incomplete + release
  disabled + not ready, including missing layout/content diagnostics;
- no Event/Secret boss content is enabled;
- no modelling, meshes, terrain or authored-room work was performed.

Final committed acceptance from `2e2420b` includes:

- **504** Lua/Luau files parsed with 0 failures;
- clean `git diff --check`;
- all four Rojo compositions building;
- Runtime Content Readiness: **64 assertions PASS**;
- Difficulty Definitions: **114 assertions PASS**;
- Difficulty Progression: **19 assertions PASS**;
- Teleport Coordinator: **19 assertions PASS**;
- final committed Base party/difficulty regressions green;
- final committed Dungeon binding/execution regressions green;
- Phase 3 Systems Stress green in both compositions;
- Training Dummy and Combat Target Rules green in Dungeon;
- live Dungeon Studio player admission succeeded;
- source-boundary audit: **13 source/test files, 0
  art/model/mesh/terrain/image files**.

Prior runtime-readiness worktree:
C:\Users\Remko\Documents\Roblox\DungeonMMO_Phase4_RuntimeReadiness_v1

Prior runtime-readiness branch:
wip/phase-4-runtime-content-readiness-v1

Design/spec:
docs/superpowers/specs/2026-09-18-phase-4-runtime-content-readiness-design.md

Acceptance evidence:
docs/testing/phase4-runtime-content-readiness-acceptance-record.md

No push, merge or Roblox publish has been performed for this gate.

The follow-on **Generic Enemy Archetype + Heterogeneous Combat Pack Registry**
gate is now **LOCAL GREEN / AWAITING PROJECT-OWNER RELEASE CLOSEOUT** at:

`464bd44`

Accepted local engineering result:

- `CombatPack` no longer means "spawn Marauders";
- shared combat-pack content now uses ordered typed entries;
- each entry references a stable enemy archetype;
- each enemy archetype references a stable server factory ID;
- `DungeonEnemyFactoryRegistry` owns server-only factory registration;
- `CombatPackEncounterExecutor` executes mixed-archetype packs generically;
- the old `MarauderPackEncounterExecutor` was removed;
- Deep Echoes and Crystal Bloom bonuses target explicit pack EntryIds;
- existing Temple/Mine Depth1 Marauder counts, names and spawn-index ranges are
  preserved;
- a synthetic 2-Marauder + 1-Elite pack proves heterogeneous execution without
  enabling Elite as production content;
- partial mixed-pack failures clean all previously spawned enemies;
- runtime readiness now validates pack entries, enemy archetypes, enemy
  factories and bonus-rule targets;
- no new production enemy archetype was enabled;
- Depth2-Depth4 remain release-disabled/content-incomplete;
- no modelling, meshes, terrain or authored-room work was performed.

Final committed acceptance from `464bd44` includes:

- **507** Lua/Luau files parsed with 0 failures;
- clean `git diff --check`;
- all four Rojo compositions building;
- Enemy Factory Registry: **8 assertions PASS**;
- Combat Pack Encounter Executor: **15 assertions PASS**;
- Encounter Spawn Catalog: **15 assertions PASS**;
- existing Encounter Executors: **21 assertions PASS**;
- Encounter Execution Bootstrap: **4 assertions PASS**;
- Runtime Content Readiness: **64 assertions PASS**;
- final committed Base party/difficulty regressions green;
- final committed Dungeon binding/execution regressions green;
- Phase 3 Systems Stress green in both compositions;
- Training Dummy and Combat Target Rules green in the clean Dungeon rerun;
- live Dungeon Studio player admission succeeded;
- source-boundary audit: **11 source/test files, 0
  art/model/mesh/terrain/image files**.

Prior enemy-pack-registry worktree:
C:\Users\Remko\Documents\Roblox\DungeonMMO_Phase4_EnemyPackRegistry_v1

Prior enemy-pack-registry branch:
wip/phase-4-enemy-archetype-combat-pack-v1

Design/spec:
docs/superpowers/specs/2026-09-18-phase-4-enemy-archetype-combat-pack-design.md

Acceptance evidence:
docs/testing/phase4-enemy-archetype-combat-pack-acceptance-record.md

No push, merge or Roblox publish has been performed for this gate.

The follow-on **Authoritative Runtime Layout Selection + Environment
Activation** gate is now **LOCAL GREEN / AWAITING PROJECT-OWNER RELEASE
CLOSEOUT** at:

`ccd289b`

Accepted local engineering result:

- runtime selection now resolves DungeonId + DifficultyId + LayoutId;
- production preserves DifficultyId from TeleportData;
- Studio supports an optional explicit difficulty override;
- unregistered selected layouts fail closed;
- physical slots now declare explicit exit-barrier anchors;
- environment trigger/barrier activation is generic over arbitrary layout slots;
- DungeonEnvironmentBootstrap no longer contains Temple/Mine trigger/barrier
  arrays;
- readiness rejects logical exit-barrier bindings without physical anchors;
- synthetic four-slot activation passed;
- current Temple Depth1 boot/admission behavior remains compatible;
- Depth2-Depth4 remain release-disabled/content-incomplete;
- no modelling, meshes, terrain or authored-room work was performed.

Final committed acceptance from `ccd289b` includes:

- **510** Lua/Luau files parsed with 0 failures;
- all four Rojo compositions building;
- Runtime Selection: **7 assertions PASS**;
- Environment Layout Activation: **12 assertions PASS**;
- Encounter Bindings: **30 assertions PASS**;
- Runtime Content Readiness: **64 assertions PASS**;
- final committed Base and Dungeon regressions green;
- Phase 3 Systems Stress green;
- Training Dummy and Combat Target Rules green;
- live Dungeon Studio player admission succeeded;
- source-boundary audit: **7 source/test files, 0 art/model/mesh/terrain/image
  files**.

Prior runtime-layout-selection worktree:
C:\Users\Remko\Documents\Roblox\DungeonMMO_Phase4_RuntimeLayoutSelection_v1

Prior runtime-layout-selection branch:
wip/phase-4-runtime-layout-selection-v1

Acceptance evidence:
docs/testing/phase4-runtime-layout-selection-acceptance-record.md

No push, merge or Roblox publish has been performed for this gate.

The follow-on **Binding-Owned Spawn Groups + Exit Barriers** gate is now
**LOCAL GREEN / AWAITING PROJECT-OWNER RELEASE CLOSEOUT** at:

`cfbf2ea`

Accepted local engineering result:

- combat-capable physical slots now declare EnemySpawnGroup;
- encounter bindings expose EnemySpawnGroup and ExitBarrierAnchor;
- CombatPackEncounterExecutor uses binding-owned environment groups instead of
  room-ID spawn translation;
- DungeonRuntime uses binding-owned physical barrier anchors for encounter clear
  and recovery;
- readiness rejects combat bindings without spawn groups;
- the generic runtime no longer depends on Temple/Mine GROUP_BY_ROOM or
  BARRIER_BY_ROOM maps;
- existing adapter compatibility helpers remain available for older callers;
- current Depth1 behavior remains compatible;
- Depth2-Depth4 remain release-disabled/content-incomplete;
- no modelling, meshes, terrain or authored-room work was performed.

Final committed acceptance from `cfbf2ea` includes:

- **512** Lua/Luau files parsed with 0 failures;
- all four Rojo compositions building;
- Dungeon Encounter Bindings: **34 assertions PASS**;
- Dungeon Encounter Environment Runtime: **8 assertions PASS**;
- Combat Pack Encounter Executor: **15 assertions PASS**;
- Encounter Executors: **21 assertions PASS**;
- Encounter Execution Bootstrap: **4 assertions PASS**;
- Runtime Content Readiness: **64 assertions PASS**;
- final committed Base and Dungeon regressions green;
- Phase 3 Systems Stress green;
- Training Dummy and Combat Target Rules green;
- live Dungeon Studio player admission succeeded;
- source-boundary audit: **11 source/test files, 0
  art/model/mesh/terrain/image files**.

Prior environment-binding-runtime worktree:
C:\Users\Remko\Documents\Roblox\DungeonMMO_Phase4_EnvironmentBindingRuntime_v1

Prior environment-binding-runtime branch:
wip/phase-4-environment-binding-runtime-v1

Acceptance evidence:
docs/testing/phase4-environment-binding-runtime-acceptance-record.md

No push, merge or Roblox publish has been performed for this gate.

The follow-on **Selected-Layout Environment Contract** gate is now
**LOCAL GREEN / AWAITING PROJECT-OWNER RELEASE CLOSEOUT** at:

`405dde5`

Accepted local engineering result:

- production environment resolution now derives room exact anchors from the
  selected physical layout;
- combat slots own spawn-group name, prefix and minimum anchor count;
- runtime base contracts contain only environment-wide completion/return
  anchors;
- DungeonEnvironmentBootstrap resolves the selected-layout contract;
- DungeonEnvironmentRouter rebuilds the same selected-layout contract before
  constructing the gameplay adapter;
- legacy full Temple/Mine contracts remain available for compatibility callers;
- a synthetic Room4 contract is visible to the real EnvironmentAnchorResolver;
- insufficient Room4 spawn anchors fail closed;
- current Depth1 boot/admission behavior remains compatible;
- Depth2-Depth4 remain release-disabled/content-incomplete;
- no modelling, meshes, terrain or authored-room work was performed.

Final committed acceptance from `405dde5` includes:

- **514** Lua/Luau files parsed with 0 failures;
- all four Rojo compositions building;
- Layout Environment Contract: **14 assertions PASS**;
- Encounter Bindings: **34 assertions PASS**;
- Combat Pack Encounter Executor: **15 assertions PASS**;
- Phase2A Failure Path: **24 assertions PASS**;
- Teleport Coordinator: **19 assertions PASS**;
- Dungeon Difficulty Teleport: **7 assertions PASS**;
- Dungeon Difficulty Progression: **19 assertions PASS**;
- Runtime Content Readiness: **64 assertions PASS**;
- final committed Base regression green;
- clean-repeat committed Dungeon regression green;
- Combat Target Rules clean repeat: **9 assertions PASS**;
- Phase 3 Systems Stress green;
- live Dungeon Studio player admission succeeded;
- source-boundary audit: **9 source/test files, 0
  art/model/mesh/terrain/image files**.

Prior layout-environment-contract worktree:
C:\Users\Remko\Documents\Roblox\DungeonMMO_Phase4_LayoutEnvironmentContract_v1

Prior layout-environment-contract branch:
wip/phase-4-layout-environment-contract-v1

Acceptance evidence:
docs/testing/phase4-layout-environment-contract-acceptance-record.md

No push, merge or Roblox publish has been performed for this gate.

The follow-on **Studio Difficulty / Session Parity** gate is now
**LOCAL GREEN / AWAITING PROJECT-OWNER RELEASE CLOSEOUT** at:

`d9297f8`

Accepted local engineering result:

- StudioSessionFactory accepts the selected DifficultyId;
- Studio dungeon session creation receives that DifficultyId;
- DungeonInstanceDirector materializes InstanceState for that DifficultyId;
- Studio routing data preserves DifficultyId;
- reused Studio sessions prefer authoritative session difficulty;
- DungeonRuntime passes the difficulty already resolved by environment
  bootstrap;
- omitted Studio difficulty still defaults through normal definitions to
  Depth1;
- production TeleportCoordinator routing was not changed;
- Depth2-Depth4 remain release-disabled/content-incomplete;
- no modelling, meshes, terrain or authored-room work was performed.

Final committed acceptance from `d9297f8` includes:

- **514** Lua/Luau files parsed with 0 failures;
- all four Rojo compositions building;
- Studio Session Factory: **7 assertions PASS**;
- Layout Environment Contract: **14 assertions PASS**;
- Encounter Bindings: **34 assertions PASS**;
- Combat Pack Encounter Executor: **15 assertions PASS**;
- Phase2A Failure Path: **24 assertions PASS**;
- Teleport Coordinator: **19 assertions PASS**;
- Dungeon Difficulty Teleport: **7 assertions PASS**;
- Dungeon Difficulty Progression: **19 assertions PASS**;
- Runtime Content Readiness: **64 assertions PASS**;
- final committed Base regression green;
- clean-repeat committed Dungeon regression green;
- Training Dummy clean repeat: **9 assertions PASS**;
- Combat Target Rules clean repeat: **9 assertions PASS**;
- Phase 3 Systems Stress green;
- live Dungeon Studio player admission succeeded;
- source-boundary audit: **3 source/test files, 0
  art/model/mesh/terrain/image files**.

Prior Studio-difficulty-parity worktree:
C:\Users\Remko\Documents\Roblox\DungeonMMO_Phase4_StudioDifficultyParity_v1

Prior Studio-difficulty-parity branch:
wip/phase-4-studio-difficulty-parity-v1

Acceptance evidence:
docs/testing/phase4-studio-difficulty-parity-acceptance-record.md

No push, merge or Roblox publish has been performed for this gate.

The follow-on **Depth2 Backend Combat + Boss Content** gate is now
**LOCAL GREEN / AWAITING PROJECT-OWNER RELEASE CLOSEOUT** at:

`b525235`

Accepted local engineering result:

- TestDungeon Depth2Room1/2/3 packs are registered at 3/4/5 Marauders;
- AbandonedMine Depth2Room1/2/3 packs are registered at 3/4/5 Marauders;
- Mine Depth2 Room1 retains Deep Echoes +1 behavior;
- Mine Depth2 Room2 retains Crystal Bloom +1 behavior;
- TempleDepth2Boss is registered with the Temple Warden identity;
- AbandonedMineDepth2Boss is registered with the Deep Overseer identity;
- both Depth2 bosses reuse accepted Captain/Foreman server combat behavior;
- both factories are registered in execution bootstrap;
- Depth2 readiness now has exactly one issue per dungeon:
  DungeonLayoutNotRegistered;
- Depth2 no longer reports EncounterContentNotRegistered;
- Depth2 remains release-disabled and physically unregistered;
- Depth3-Depth4 remain content-incomplete and release-disabled;
- no modelling, meshes, terrain or authored-room work was performed.

Final committed acceptance from `b525235` includes:

- **518** Lua/Luau files parsed with 0 failures;
- all four Rojo compositions building;
- Depth2 Content: **32 assertions PASS**;
- Depth2 Boss Factory: **8 assertions PASS**;
- Encounter Spawn Catalog: **17 assertions PASS**;
- Encounter Execution Bootstrap: **4 assertions PASS**;
- Runtime Content Readiness: **66 assertions PASS**;
- Studio Session Factory: **7 assertions PASS**;
- Layout Environment Contract: **14 assertions PASS**;
- Encounter Bindings: **34 assertions PASS**;
- Combat Pack Encounter Executor: **15 assertions PASS**;
- final committed Base regression green;
- final committed Dungeon regression green;
- Phase 3 Systems Stress green;
- Training Dummy and Combat Target Rules green;
- live Dungeon Studio player admission succeeded;
- source-boundary audit: **8 source/test files, 0
  art/model/mesh/terrain/image files**.

Prior Depth2-content worktree:
C:\Users\Remko\Documents\Roblox\DungeonMMO_Phase4_Depth2Content_v1

Prior Depth2-content branch:
wip/phase-4-depth2-content-v1

Acceptance evidence:
docs/testing/phase4-depth2-content-acceptance-record.md

No push, merge or Roblox publish has been performed for this gate.

The follow-on **Depth3 Backend Combat + Boss Content** gate is now
**LOCAL GREEN / AWAITING PROJECT-OWNER RELEASE CLOSEOUT** at:

`092bd99`

Accepted local engineering result:

- TestDungeon Depth3Room1/2/3/4 packs are registered at 4/5/6/7 Marauders;
- AbandonedMine Depth3Room1/2/3/4 packs are registered at 4/5/6/7 Marauders;
- Mine Depth3 Room1 retains Deep Echoes +1 behavior;
- Mine Depth3 Room2 retains Crystal Bloom +1 behavior;
- TempleDepth3Boss is registered with the Relic Guardian identity;
- AbandonedMineDepth3Boss is registered with the Hollow Taskmaster identity;
- both Depth3 bosses reuse accepted Captain/Foreman server combat behavior;
- both factories are registered in execution bootstrap;
- Depth2 and Depth3 readiness each have exactly one issue per dungeon:
  DungeonLayoutNotRegistered;
- Depth3 no longer reports EncounterContentNotRegistered;
- Depth2 and Depth3 remain release-disabled and physically unregistered;
- Depth4 remains content-incomplete and release-disabled;
- no modelling, meshes, terrain or authored-room work was performed.

Final committed acceptance from `092bd99` includes:

- **522** Lua/Luau files parsed with 0 failures;
- all four Rojo compositions building;
- Depth3 Content: **36 assertions PASS**;
- Depth3 Boss Factory: **8 assertions PASS**;
- Depth2 Content: **32 assertions PASS**;
- Depth2 Boss Factory: **8 assertions PASS**;
- Encounter Spawn Catalog: **19 assertions PASS**;
- Encounter Execution Bootstrap: **4 assertions PASS**;
- Runtime Content Readiness: **68 assertions PASS**;
- Studio Session Factory: **7 assertions PASS**;
- Layout Environment Contract: **14 assertions PASS**;
- Encounter Bindings: **34 assertions PASS**;
- Combat Pack Encounter Executor: **15 assertions PASS**;
- final committed Base regression green;
- final committed Dungeon regression green;
- Training Dummy and Combat Target Rules: **9 assertions PASS** each;
- Phase 3 Systems Stress green;
- live Dungeon Studio player admission succeeded;
- source-boundary audit: **8 source/test files, 0
  art/model/mesh/terrain/image files**.

Prior Depth3-content worktree:
C:\Users\Remko\Documents\Roblox\DungeonMMO_Phase4_Depth3Content_v1

Prior Depth3-content branch:
wip/phase-4-depth3-content-v1

Acceptance evidence:
docs/testing/phase4-depth3-content-acceptance-record.md

No push, merge or Roblox publish has been performed for this gate.

The follow-on **Depth4 Final-Difficulty Backend Content** gate is now
**LOCAL GREEN / AWAITING PROJECT-OWNER RELEASE CLOSEOUT** at:

`8bcb58b`

Accepted local engineering result:

- TestDungeon Depth4Room1/Room3 packs are registered at 5/7 Marauders;
- AbandonedMine Depth4Room1/Room3 packs are registered at 5/7 Marauders;
- Mine Depth4 Room1 retains Deep Echoes +1 behavior;
- Mine Depth4 Room3 retains Crystal Bloom +1 behavior;
- Depth4 keeps six logical encounters;
- Room2 reuses the Depth1 boss as MiniBoss;
- Room4 reuses the Depth2 boss as MiniBoss;
- Room5 reuses the Depth3 boss as MiniBoss;
- TempleDepth4Boss is registered with the Sanctum Ascendant identity;
- AbandonedMineDepth4Boss is registered with the Buried Tyrant identity;
- both final bosses preserve BossRole = FinalBoss;
- both final-boss factories reuse accepted Captain/Foreman combat behavior;
- Depth2, Depth3 and Depth4 readiness each have exactly one issue per dungeon:
  DungeonLayoutNotRegistered;
- all Depth1-Depth4 encounter content is registered;
- Depth2-Depth4 remain release-disabled and physically unregistered;
- no modelling, meshes, terrain or authored-room work was performed.

Final committed acceptance from `8bcb58b` includes:

- **526** Lua/Luau files parsed with 0 failures;
- all four Rojo compositions building;
- Depth4 Content: **38 assertions PASS**;
- Depth4 Boss Factory: **10 assertions PASS**;
- Depth3 Content: **36 assertions PASS**;
- Depth3 Boss Factory: **8 assertions PASS**;
- Depth2 Content: **32 assertions PASS**;
- Depth2 Boss Factory: **8 assertions PASS**;
- Encounter Spawn Catalog: **20 assertions PASS**;
- Encounter Executors: **21 assertions PASS**;
- Encounter Execution Bootstrap: **4 assertions PASS**;
- Runtime Content Readiness: **70 assertions PASS**;
- Layout Environment Contract: **14 assertions PASS**;
- Encounter Bindings: **34 assertions PASS**;
- Combat Pack Encounter Executor: **15 assertions PASS**;
- final committed Base regression green;
- final committed Dungeon regression green;
- Training Dummy and Combat Target Rules: **9 assertions PASS** each;
- Phase 3 Systems Stress green;
- live Dungeon Studio player admission succeeded;
- source-boundary audit: **10 source/test files, 0
  art/model/mesh/terrain/image files**.

Active worktree:
C:\Users\Remko\Documents\Roblox\DungeonMMO_Phase4_Depth4Content_v1

Active branch:
wip/phase-4-depth4-content-v1

Acceptance evidence:
docs/testing/phase4-depth4-content-acceptance-record.md

No push, merge or Roblox publish has been performed for this gate.

## Repository safety

Primary gameplay repo:

C:\Users\Remko\Documents\Roblox\DungeonMMO

Phase 3 completion worktree/branch remains preserved for history:

- worktree:
  C:\Users\Remko\Documents\Roblox\DungeonMMO_Phase3_Completion_v1
- branch: wip/phase-3-systems-alpha-completion-v1

Do not reset hard, clean, force-push, rewrite history or merge the art worktree
into gameplay. Validation builds belong in TEMP locations.

## Event/Secret Boss backend candidate (19 September 2026)

A separate backend candidate exists in DungeonMMO_Phase4_EventSecretPolicy_v1, based on ff2baa0. The four distinct optional-boss identities and their server-only event-window/secret-unlock triggers are implemented. Secret-boss direct-successor skip is persisted through the existing generic encounter controller. Dungeon Studio: policy 49, flow 9, factories 24 and release locks 14 assertions PASS; 537 Lua/Luau files parse; four Rojo builds PASS. The Base gameplay regressions also passed. Both current dungeons remain rollout-disabled, with no optional arenas; Depth2-4 physical layouts remain unregistered. This is CODE-ONLY BACKEND VERIFIED and NOT RELEASED. Authored arenas, authoritative boss-event schedule/secret-unlock issuers and physical gameplay acceptance are future gates. No push, merge, publish or UI changes. Evidence: docs/testing/phase4-optional-boss-policy-progress.md.

Backend closeout (19 September 2026): server-issued optional-boss
run-state regression passed 28 offline Luau assertions; four
Rojo builds and diff check passed. Physical arenas, event
schedules and secret-route release settings remain gated.\r\n\r\n
## UI/HUD overhaul candidate - 19 September 2026

Active UI worktree: DungeonMMO_Phase4_UIOverhaul_v1.
Branch: wip/phase-4-ui-overhaul-v1; baseline ff2baa0.
Shared styling, combat hotbar/status, dungeon HUD, contextual Expedition
and Auction windows, and refreshed Guild/core menus are implemented.
531 Luau sources parsed, four Rojo builds passed, Base and repeat Dungeon
Studio regressions passed; repeat Dungeon log has zero project errors.
Manual visual and prompt-to-window acceptance remains OPEN.
No push, merge or Roblox publish. Backend readiness gates unchanged.
Evidence: docs/testing/phase4-ui-hud-overhaul-candidate-acceptance-record.md.
