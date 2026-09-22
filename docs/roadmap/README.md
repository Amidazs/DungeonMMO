# Canonical Roadmap

**Latest working backend increment: v1.71 —
real Ranger/Rogue control progression.**
[Working roadmap v1.71](DungeonMMO_Roadmap_v1_71_Ranger_Rogue_Control_20260922.md)
and [focused acceptance](../testing/c4-ranger-rogue-control-skills-2026-09-22.md).
Briar Volley hits and slows two physical targets;
Disrupting Cut actually staggers. Both have three
5/10/15 level-gated ranks, 40/110 earned mastery
requirements and class/trainer/weapon authority.
Unpublished live-client effect, 41 focused content,
46 production service purchase/persistence and 45
corrected Rogue trainer assertions passed. The C4
source-volume manifest is still incomplete, real
saved-character trainer GUI remains untested, and
the separate Phase2A auto-test failure remains open.
Do not merge to `main` or publish merely because
this focused backend slice passed.


**C4 client-effects focus (22 September 2026):**
[Focused Studio Play acceptance](../testing/c4-new-skill-live-client-2026-09-22.md)
verifies Dawn Ward, Cinder Bolt, Archer Draw and Vital Blow
through a real client hotbar and server combat effects.
Temporary profiles/snapshots were used, so real trainer
UI and saved-profile interactions are still pending. Two
unrelated automatic Dungeon-test failures are not accepted.
C4 quantitative skill-rank gaps remain open. Continue
GitHub-first backend work without repeating old dungeon
wipe/aggro/revive/play-again tests.


**Latest v1.70 — all four current class families now have
C4-inspired level, skill-rank and earned-proficiency gates.**
[Roadmap v1.70](DungeonMMO_Roadmap_v1_70_All_Four_C4_Class_Families_20260922.md)
and [focused acceptance](../testing/c4-all-four-class-families-2026-09-22.md).
Fighter, Mage, Ranger and Rogue gained new actual
role-appropriate combat/mastery content. Every current
race-specific advanced class has progression-gated
trainer skills; Mage gained two advanced skills and
Rogue specialist skills require genuine prior mastery.
The 74-assertion four-family contract passed, and
Base/Dungeon Rojo builds passed after the main changes.
The final metadata-only Rogue mastery change passed
the same focused contract and Base build at `687e27c`.
**Do not claim exact C4 completeness:** 13/16 measured
Fighter/Mage source rank brackets still mismatch; Ranger/
Rogue rank-volume reference mapping and real-client new
skill impacts remain pending. No old dungeon recovery
matrix was rerun.


**Latest v1.69 — two real early Mage skills and honest unlock UI.**
[Roadmap v1.69](DungeonMMO_Roadmap_v1_69_Mage_Starter_Unlock_Visibility_20260922.md)
and [focused evidence](../testing/c4-mage-starter-ward-bolt-trainer-2026-09-22.md).
Dawn Ward and Cinder Bolt now offer server-owned rank 1/2/3 at
levels 1/7/14 and require mastery 35/100 for upgrades. The
player's actual skill menu hides abilities absent from their
authoritative unlocked snapshot; the trainer disables higher
ranks and explains level/mastery requirements. One Base build,
39 focused assertions and one read-only rank count audit ran.
**13/16 mapped C4 level brackets still mismatch**; do not
claim full rank parity or completed in-client visual verification.


**Latest v1.68 — two more C4-style rank families with real HP/heal effects.**
[Roadmap v1.68](DungeonMMO_Roadmap_v1_68_Vitality_Restoration_Ranks_20260922.md)
and [focused test report](../testing/c4-vitality-restoration-rank-effects-2026-09-22.md).
Fighter Stalwart Training and Mage Restorative Training each
have six SP/level-gated passive ranks with live authoritative
max-HP or heal-multiplier effects. A Base build and
64 new + 64 affected existing passive assertions passed
at `3be5de3`. The C4 count audit still shows 13/16
mapped brackets mismatched, including a Human Fighter
level-10 **overcount**. No numerical C4 parity or
normal-client combat-balance claim; do not rerun the old
dungeon wipe/aggro/revive matrix for these passives.


**Latest v1.67 — C4-style class passives with actual damage effects.**
[Roadmap](DungeonMMO_Roadmap_v1_67_C4_Passive_Ranks_20260922.md)
and [focused acceptance](../testing/c4-passive-rank-effects-2026-09-22.md).
Six rank- and level-gated Fighter Iron Discipline and
Mage Arcane Discipline passives now modify authoritative
physical/magical damage multipliers, respectively.
One Base build and 64 focused assertions passed at
`08710c1`. The source-mapped audit still reports
16/16 C4 brackets short; do not claim parity. Next
work is genuine early skill/utility/crafting content,
not a repeat of old dungeon recovery tests.


**Latest active C4 skill-volume increment: v1.66.**
[Updated content roadmap](DungeonMMO_Roadmap_v1_66_C4_Early_Rank_Content_20260922.md)
and [focused acceptance](../testing/c4-early-fighter-mage-skill-ranks-2026-09-22.md).
Two Fighter nine-rank combat families at level 5/10/15,
one Mage six-rank heal at level 7/14, and per-skill
mastery/profile migration were implemented and locally
focused-tested. C4's mapped reference-volume requirement
is **NOT complete: 16/16 verified brackets remain short**.
Next: real passive/utility/craft families and remaining
mapped rank offerings, not another dungeon recovery suite.


**Latest active requirement (v1.65): Chronicle 4 skill-RANK
volume per corresponding class and level, not just a few
additional active skills.**
[Skill-volume roadmap](DungeonMMO_Roadmap_v1_65_C4_Skill_Volume_20260922.md)
and [source-backed parity specification](
../design/C4_Skill_Count_Parity_20260922.md).
The first 16 verified Human/Elf Fighter/Mystic early-level
brackets all show real authored-rank gaps, so C4 skill-volume
parity is **NOT COMPLETE**. Fighter-style new basic rank
milestones now begin 5/10/15 and Mystic-style 7/14/20,
with focused level/mastery acceptance. Expand real,
reachable active/passive/utility families and rank
schedules; never pad quotas with inert catalogue entries.


**Latest active work: v1.64 — earned skill mastery, level-bracket training
and prerequisite-gated class advancement.**
[Roadmap v1.64](DungeonMMO_Roadmap_v1_64_Skill_Mastery_Level_Gates_20260922.md)
and [focused local evidence](../testing/dungeon-skill-mastery-lineage-style-2026-09-22.md).
New basic abilities at levels 8/14/20, level-20 trials requiring
two fully mastered class skills, level-24/28/32 specialist skill
ranks and an extended level-40 cap now have local focused
tests. The taunt-proficiency integration was corrected and
tested separately. This is a *first connected progression
ladder*, not a complete Lineage II C4 skill catalogue.
Do not rerun old dungeon wipe/aggro/revive regressions
for isolated skill-data edits.


**Latest v1.63: race-specific advanced classes and playable-skill
foundations (Lineage II / WoW-inspired structure, original content).**
[Roadmap v1.63](DungeonMMO_Roadmap_v1_63_Class_Progression_Role_Skills_20260922.md)
and [focused skill/class acceptance](../testing/dungeon-class-progression-expansion-2026-09-22.md).
Four new Fighter/Ranger advancement paths, level-gated
trials, four specialist active abilities and trainers
were added. Server skill use requires the persisted
active advanced class. One Base and one Dungeon build;
66 class, 40 quest and 60 advanced ability assertions
passed (skills tested in the Dungeon composition at
`b017fbc`). A full real-client combat impact and
the quest/trainer UI remain next **new feature** work;
no repeated dungeon wipe/aggro/revive matrix was run.


**Latest v1.62 — new story quest backend content, NOT another
dungeon recovery-test cycle.**
[Roadmap v1.62](DungeonMMO_Roadmap_v1_62_Story_Quest_Backend_20260922.md)
and [focused acceptance](../testing/story-quest-backend-slice-2026-09-22.md).
Two one-time cross-class Temple → Mine story quests, one bound
relic and server-authoritative atomic Gold/item claims were
implemented with Base quest remotes. One Base build and 40
QuestService assertions passed at `89d8e7e`; there was no
full Dungeon regression. A visible quest board and targeted
real-client remote interaction are **still pending**.


**Consolidated active backend backlog (22 September 2026):**
[Gap audit and stop-retesting plan](DungeonMMO_Consolidated_Backend_Audit_20260922.md).
This is the practical NEXT-WORK list across dungeon, progression,
professions, world boss/raid, guild/PvP, quests/economy and
release gates. It does not overwrite historical canonical
`DungeonMMO_Roadmap_v1_47.docx` or reclassify older local
passes as published acceptance. Finish only the missing
ordinary-combat dungeon integration, then move to new
progression/content systems; do not repeat all accepted
wipe/aggro/revive fixtures after unrelated edits.


**Latest v1.61: all-member higher-difficulty unlock,
spectator combat exclusion and party Play again.**
[Roadmap](DungeonMMO_Roadmap_v1_61_Party_Unlock_Spectator_Replay_20260922.md)
and [unpublished Studio acceptance](../testing/dungeon-party-unlock-spectator-replay-2026-09-22.md).
Every member must independently unlock the selected dungeon
depth; Base, new-run transport and replay enforce it.
Six builds, 23 coordinator checks, 28 replay checks,
Dungeon backend 30/30, real two-client spectator and replay
fixtures passed at `c6925c0`. Base UI now identifies
the locked member; all six builds and the focused Base
party regression passed at `b6fe3be`. A real same-account
published reserved-server reconnect is still outstanding.


**v1.60 same-server reconnect is now locally verified.**
[Updated v1.60 roadmap](DungeonMMO_Roadmap_v1_60_Same_Server_Reconnect_20260922.md)
and [same-head Studio acceptance](../testing/dungeon-same-server-reconnect-local-acceptance-2026-09-22.md).
At gameplay source `87a19ba`, all six Rojo builds, the
30-assertion simulated same-user reconnect contract, Dungeon
backend 30/30, death/revive 46, focused threat 51, Base
professions 14/14, actual-client failed-run UI and real
four-client Room1 recovery passed. A real Roblox same-account
network return to the original published reserved server
remains unverified. No place publish or main merge.


**v1.60 same-server reconnect is staged in GitHub, not yet
locally tested.** [Roadmap](DungeonMMO_Roadmap_v1_60_Same_Server_Reconnect_20260922.md)
and [pending acceptance report](../testing/dungeon-same-server-reconnect-stage-2026-09-22.md).
Remote Desktop reported no online device, so no Rojo
build or Studio regression was run for the new source
head. The accepted v1.59 physical multiplayer tests
belong to earlier gameplay code. Initial handoff still
requires a nonce; returning members require an
already-bound server, persisted disconnect and a
separate profile writer lease. Published same-account
network reconnect and routing remain unverified.


**Latest GitHub roadmap supplement: v1.59 — physical
four-player SecretArena boss, Depth4 mini-boss and live
boss peer-disconnect recovery.** See
[v1.59](DungeonMMO_Roadmap_v1_59_Secret_Depth4_Disconnect_20260921.md)
and [local acceptance evidence](../testing/dungeon-secret-depth4-disconnect-recovery-2026-09-21.md).
All three unpublished Studio multiplayer fixtures passed.
The higher-depth terminal wipe service regression passed
392 assertions. Same-account published rejoin, full normal
combat/boss rewards and reserved-server replay remain
outstanding. No `main` merge or place publish.


**Latest GitHub progress: v1.58 — real four-client Room1,
Room3 boss and optional EventArena wipe/re-entry; replay
party voting verified (21 September 2026).**
[Roadmap v1.58](DungeonMMO_Roadmap_v1_58_Four_Party_Boss_Replay_20260921.md)
and [local evidence](../testing/dungeon-four-client-room-boss-event-replay-2026-09-21.md).
A physical partial-kill wipe did not duplicate any
of four players' monster rewards. A repeated Failed
state broadcast was fixed so party replay votes remain
visible. Secret/higher-depth bosses, actual published
cross-place replay and cloud persistence remain pending.
No place publish or `main` merge.


**Latest GitHub roadmap supplement: v1.57 — physical Room1
wipe/re-entry and Play again.** Read
[v1.57](DungeonMMO_Roadmap_v1_57_Room_Reset_Play_Again_20260921.md)
and [local proof](../testing/dungeon-room-reset-play-again-2026-09-21.md).
The unpublished one-client physical Room1 test verified old
enemy retirement and newly spawned full-health enemies after a
genuine player death and checkpoint revive. Both terminal
end-screen replay buttons passed real-client UI Play; replay
party-consent contract passed 17 assertions. Published
reserved-server Play again and multi-client boss-room recovery
remain pending. No place published or main merged.


**Latest GitHub roadmap supplement: v1.56 (terminal dungeon wipe,
Base return and fresh-run retry, 21 September 2026).**
Read [the v1.56 backend roadmap](DungeonMMO_Roadmap_v1_56_Terminal_Wipe_Base_Retry_20260921.md)
and [local test evidence](../testing/dungeon-terminal-wipe-return-fresh-run-2026-09-21.md).
Failed dungeon sessions remain terminal, their connected members can
return to Base, and the existing Base entry creates a fresh session
rather than reopening the failed run. Legitimate paid revives follow
the actual committed purchase ordering; repeated and late callbacks
cannot respawn a failed run. Six Rojo builds, Dungeon backend
30/30, integrated paid-retry service and real failed-run UI Play
passed. **In-place room/encounter health/spawn reset and complete
party checkpoint retry are not yet implemented**. No Roblox
publish or main merge occurred.


**Latest GitHub roadmap progress supplement: v1.55 (real
four-client combat, world-boss support and threat-only full-wipe
cleanup, 21 September 2026).**
Read [v1.55 combat and wipe progress](DungeonMMO_Roadmap_v1_55_Combat_Threat_Wipe_20260921.md)
and [the real multiplayer test receipt](../testing/four-player-full-wipe-threat-reset-2026-09-21.md).
All six local Rojo compositions, 51 focused threat assertions,
30/30 Dungeon backend and 14/14 Base profession regressions
passed at `739e747`. Real four-client, two-enemy gameplay proved
actual player departure and all-dead threat cleanup; genuine
world-boss aggro and support passed on the **correct isolated
world-boss composition**. This is threat-only cleanup, not enemy
health/spawn or full session restart. No main merge, place
publish or production DataStore change was made.


**Earlier roadmap supplement: v1.53 (Leatherworking / Enchanting staged, 21 September 2026).**
Read [the v1.53 pending-verification roadmap](DungeonMMO_Roadmap_v1_53_Professions_Pending_Verification.md)
and [the staged verification plan](../testing/profession-leatherworking-enchanting-pending-verification-2026-09-21.md).
GitHub now contains Skinning, Leatherworking and Enchanting progression,
items, recipes, placeholder Base acquisition/stations, a multi-profession
equipment chain, migration/contract/dependency tests and a per-player
server craft-request guard. **These v1.53 changes are not locally accepted
yet** because the authorized Windows desktop is offline. No new Studio
PASS counts, Rojo build results or cloud release are claimed. The accepted
v1.52 results remain the latest verified checkpoint. No Remote Desktop,
local pull, TEST/PROD publish, real player DataStore mutation, force-push
or main merge occurred for v1.53 staging.

**Earlier roadmap supplement: v1.52 (non-boss Event variations and cross-profession backend, 20 September 2026).**
Read [the v1.52 backend roadmap](DungeonMMO_Roadmap_v1_52_Event_Variations_And_Professions.md)
and [the dated local Studio test report](../testing/phase4-nonboss-event-profession-chain-2026-09-20.md).
The existing, separately gated after-Room2 Event room can now host
an opted-in four-enemy Ambush or eight-enemy Surge in Temple/Mine:
one server-frozen pack, not an additional boss, second scheduler,
staggered wave or cave-in. Both variations passed assisted physical
walking and two-/four-client mid-Event disconnect/replay-proof
completion tests. New deterministic matrix: 144 assertions;
25/25 focused optional suites, 30/30 broad backend suites,
four local Rojo builds, original optional-enabled and
optional-disabled Temple Depth2 physical regressions PASS.

**Next major backend work has begun:** the existing Blacksmithing
and Alchemy services now have a bidirectional material chain,
`iron_bar` → Alchemy `forging_flux` → Blacksmithing
`runic_ironbound_gloves`. New items and recipes use the
existing atomic crafting/inventory/profile pipeline.
46 new cross-profession assertions and 7/7 profession
regressions passed in both local Base and Dungeon builds.
Leatherworking, Enchanting, real station/minigame authority
and larger raid/guild backend work are not yet complete.
All new Event release/placeholder flags remain OFF by default;
this checkpoint did not publish Roblox places, change real
player DataStores, create finished art or overwrite the
historical canonical v1.47 Word roadmap. v1.48–v1.51 remain
historical supplements.

**Latest ChatGPT-authored roadmap update: v1.51 (late Event physical and multiplayer acceptance, 20 September 2026).**
Read [the v1.51 late Event acceptance roadmap](DungeonMMO_Roadmap_v1_51_Late_Event_Physical_Acceptance.md)
and [its verified physical/multiplayer test report](../testing/phase4-late-event-physical-multiplayer-2026-09-20.md).
The after-Room2 Event now has its own **replaceable, walkable,
independently gated TEMP Studio side room** in Temple and Mine
at Depth2–4, with dedicated trigger, checkpoint and boss spawn.
The old after-Room1 Event/Secret routes are preserved. Room2
must be cleared before the late gate opens; unselected Event
gates remain closed. Local tests: 85 physical/gate assertions;
24/24 optional-focused and 30/30 broader backend suites; four
Rojo builds; assisted Temple Depth2/Mine Depth4 late-Event walking
playtests; two-client Temple and four-client Mine actual Studio
disconnect/recovery and replay-proof party completion tests;
original optional-enabled and optional-disabled Temple Depth2
routes all PASS. The new after-Room2 path is **not published**:
its server/workspace opt-ins and higher-depth release flags
remain OFF in source. No real player DataStore, authored art
or canonical v1.47 Word roadmap was modified. Earlier v1.48,
v1.49 and v1.50 updates remain available as historical
checkpoints; v1.51 supersedes v1.50's now-outdated statement
that the late route has no physical placeholder.

**Latest ChatGPT-authored roadmap update: v1.50 (configurable optional Event placement, 20 September 2026).**
Read [the v1.50 optional Event placement roadmap](DungeonMMO_Roadmap_v1_50_Optional_Event_Placement.md)
and [its verified local test report](../testing/phase4-optional-event-placement-templates-2026-09-20.md).
The accepted after-Room1 Event and before-Final Secret routes remain
the defaults. An independent server-only, default-OFF opt-in now
issues a run-frozen `EventAfterRoom2` template at Depth2–4, with its
own `EventArenaLate` slot/encounter identity, per-run Event/Secret
frequency caps, room-slot conflict rejection and fail-closed physical
readiness. **The late room and its bridge/gate are not yet registered
or physically playable.** The new backend template is not a published
event, a cave-in effect or an additional mob-pack mechanic.
Local tests: 274 template assertions, 23/23 optional-focused suites,
30/30 broader gameplay backend suites, four Rojo builds, original
Temple Depth2 assisted physical route and previous alternate-boss
Temple Depth2 assisted physical route with reward replay all PASS.
Release switches remain OFF, and no cloud place or player DataStore
was modified. The historical v1.47 Word roadmap and v1.48/v1.49
supplements remain intact.

**Latest ChatGPT-authored roadmap update: v1.49 (dynamic optional boss variants, 20 September 2026).**
Read [the v1.49 dynamic optional boss roadmap update](DungeonMMO_Roadmap_v1_49_Phase4_Dynamic_Optional_Variants.md)
and its [verified multiplayer/physical test report](../testing/phase4-dynamic-optional-boss-variants-2026-09-20.md).
Two server-issued Event/Secret variants per Temple/Mine dungeon are
now supported behind a new independent server-only opt-in, using
already implemented boss factories as placeholders. Their identities
are frozen per run; the previous two hard-coded Secret identities
were generalized in the existing discovery service, and reused
optional/miniboss factories now earn separate encounter-scoped rewards.
A 2,205-assertion variant matrix, 232 discovery assertions, 80 distinct
reward assertions, 22/22 focused suites, 30/30 broader backend suites,
two assisted alternate-boss physical routes, one variant-disabled
baseline and a 4-client Mine Depth4 alternate party run all passed
locally. No TEST/PROD publish, DataStore change, authored art,
released depth or historical canonical DOCX modification occurred.

**20 September higher-depth multiplayer lifecycle checkpoint (after v1.48):**
Two- and four-client local Temple/Mine Depth2/4 runs passed shared
frozen optional-boss plans, one boss for concurrent Event/Secret
trigger entry, actual member disconnect during either boss, survival
of the other 1/3 players and dungeon completion. Strict Temple
Depth2 2→1 and Mine Depth4 4→3 reruns verified persisted per-member
completion and exactly-once reward replay. Disposable earlier-depth
profile clears were required by the existing progression service;
the real save barrier was not weakened. New service-level 1/2/4-member
party-wipe/auto-revive tests: 392 assertions; 19/19 optional-focused,
30/30 broad backend suites and four local Rojo builds PASS. These
tests do **not** prove real same-account network rejoin, new reserved
server recreation or unassisted party combat. Existing Depth2–4 and
optional release locks remain OFF. Full dated evidence:
`docs/testing/phase4-higher-depth-multiplayer-lifecycle-2026-09-20.md`.
The ChatGPT-authored v1.48 roadmap supplement records the new status;
historical canonical v1.47 DOCX is preserved.

**Historical v1.48 Phase 4 backend supplement (20 September 2026).**
Read [the v1.48 Phase 4 backend roadmap update](DungeonMMO_Roadmap_v1_48_Phase4_Backend_Update.md)
for completed higher-depth optional physical playtesting, precise
local-vs-cloud acceptance boundaries, and the former next milestone, multiplayer lifecycle at Depth 2–4,
which is now accepted locally as recorded above. This is a *versioned supplement*,
not a replacement for the retained historical long-form
`DungeonMMO_Roadmap_v1_47.docx`. The v1.48 supplement was authored in ChatGPT and the historical
long-form Word roadmap remains preserved.

**Current engineering checkpoint:** Integration branch
`wip/phase-4-test-hud-integration-v1`; pre-roadmap-update accepted
physical-playtest commit `cfb35d0c98c8701ec34388be8dad4ce72a57e3f9`.
The v1.48 update does not imply a merge to main, production release,
Roblox publish or real user DataStore mutation.

**20 September Depth2–4 optional physical checkpoint (after v1.47):**
GitHub-first edits added separate, opt-in TEMP Event/Secret side rooms,
bridges, physical gates and unique anchors to Temple and Mine Depth2,
Depth3 and Depth4. All six independent local Studio Play-mode routes
passed actual walking traversal into/out of both optional rooms,
server encounter activation/spawn identity and final dungeon
completion with assisted combat (6/7/8 encounters by difficulty).
A seventh Mine Depth4 run physically skipped Secret, returned to
clear it and then defeated Final, using a TEMP-only final-spawn hold.
New structural test: 139 assertions; optional focused suites 18/18;
broad backend matrix 30/30. The original optional-disabled Temple
Depth2 four-room route passed and all four local Rojo compositions
built. High-depth release flags, authored models, Roblox cloud places,
user DataStores and the canonical DOCX remain untouched. Evidence:
`docs/testing/phase4-depth2-4-optional-physical-playtest-2026-09-20.md`.

**20 September depth-specific optional event backend checkpoint
(after v1.47):** Existing Temple/Mine Event/Secret encounter definitions
were validated across Depth1–4 and all independent eligibility
combinations, including expired global event windows preserving a
previously eligible saved run. Two issues were reproduced RED and fixed:
Secret side gates now use the preceding required room from the frozen
plan (rather than opening at Room2 for all depths), and Mine placeholder
side entrances are now synchronized by the existing server gate
controller. Local Studio: 712/116/32 assertions in new depth, timed-event
and gate suites; 17/17 optional suites; 30/30 broader backend suites;
assisted Temple and Mine Depth1 physical optional routes PASS. All four
local Rojo compositions built. Depth2–4 optional physical side arenas
and bridge routes are **not** registered or playable from this change,
and high-depth release flags remain OFF. No TEST/PROD cloud, player
DataStore, authored art or canonical DOCX modification. Evidence:
`docs/testing/phase4-optional-depth-events-and-side-gates-2026-09-20.md`.

**20 September four-depth integration checkpoint (after v1.47):**
Both Temple and Abandoned Mine Depth1–4 ladders passed a new
454-assertion profile/session/encounter integration test, including
3/4/5/6 required rooms, Depth4 returning miniboss identities,
ordered unlocks, interrupted miniboss checkpoints, and actual
CompletionService one-time rewards. Five focused Studio suites,
30/30 broad backend suites, four local Rojo builds, Base Play mode,
and a fresh assisted Temple Depth2 physical route passed. The
previous six separate Temple/Mine Depth2–4 physical tests retain
their dated evidence; an attempted all-six-in-one Studio runner
stopped after its first case and was removed. Higher-depth release
locks remain unchanged, with injected readiness used only inside
test storage. No production-code, authored model, Roblox cloud,
DataStore, main branch or canonical DOCX change. See
`docs/testing/phase4-depth1-4-progression-integration-2026-09-20.md`.

**20 September full session-recovery checkpoint (after v1.47):**
The existing session/encounter backend has passed a new 42-assertion
persisted two-member recovery regression and all 15 local optional
focused suites. A fresh assisted physical Temple Secret backtracking
fixture also passed. The test constructs new session, controller and
reward services over a shared in-memory store; it is not a genuine
same-account Roblox reconnect or cloud server restart. No production
gameplay, model, DataStore, TEST/PROD place or original roadmap DOCX
was changed. The user separately confirms a successful manual solo
optional-boss playtest. See
`docs/testing/phase4-optional-full-session-recovery-2026-09-20.md`.

**20 September consecutive optional-combat follow-up (after v1.47):**
Two local two-client Temple tests passed ordinary-health Event -> Secret
combat with regular client attack requests. In the second run the server
confirmed Dodge and a slotted healing skill, restoring ~32 party HP
before Secret; final-room progression passed with test assistance.
This does not supersede the failed injured-solo attempt, and
required-room/final-boss manual combat, true rejoin and cloud
verification remain open. See
`docs/testing/phase4-optional-boss-consecutive-skill-defense-2026-09-20.md`.

**20 September normal-combat follow-up (after v1.47):** Local
GitHub-first normal-combat fixtures independently defeated Temple
Event and Secret bosses with real client attacks and normal player HP.
The consecutive attempt FAILED: the solo survivor entered Secret
injured after Event and died before defeating Secret. In a separate
healthy two-client run, Secret was defeated and the final route
completed (other rooms assisted). Both isolated boss wins are accepted
as local evidence; combined unassisted gameplay, legitimate recovery,
manual navigation and true same-account rejoin are not accepted.
See `docs/testing/phase4-optional-boss-normal-combat-playtest-2026-09-20.md`.
Cloud verification and art remain deferred.

The canonical long-form roadmap stored here is:

`DungeonMMO_Roadmap_v1_47.docx`

Version: **1.47**
Last updated: **20 September 2026**

SHA-256:

`f5ebe50872510067a671a67d7844d521adc512e6683322b8a99f37c811d13abf`

**Current phase: Phase 4 Content Alpha remains ACTIVE.** Phases 2 and 3 remain accepted. The 19 September Event/Secret backend milestone is complete historically and is not a reason to repeat the closed backend work.

**20 September local backend follow-up (after v1.47):** Normal/Event start
and optional Secret-skip persistence failures now roll back in-memory
progression so players can retry without bypassing a required encounter.
Focused Studio tests, all five local Rojo compositions, assisted Temple
placeholder backtracking, normal Dungeon Play mode, and a two-client
session-disconnect fixture passed. The local two-client optional-boss fight has since passed: one Event
boss despite simultaneous entry, a real mid-Event disconnect with the
other player continuing, isolated interrupted-boss state recovery,
Event reward replay protection and Secret/final boss completion.
Same-account network rejoin is still unproven. Evidence:
`docs/testing/phase4-optional-boss-two-client-playtest-2026-09-20.md`
and `docs/testing/phase4-optional-boss-lifecycle-hardening-2026-09-20.md`.
This is a working engineering update, not a new canonical DOCX version
or cloud release. Finished models and cloud verification remain deferred.

**20 September TEST evidence and scope:** The published TEST Lobby race/class flow worked after repairing seven semantic environment anchors and restoring the TEST profile DataStore, and the player entered/cleared normal TEST Temple rooms. One observed Secret objective stated that the secret route was not unlocked for that run; the visible branches are **EventArena after Room 1** and **SecretArena after Room 2**, not two guaranteed Secret rooms. A distinct Base-origin eligibility source correction was made; it must be verified on a *new cloud session*, not assumed to change old persisted runs.

On the combined integration branch `wip/phase-4-test-hud-integration-v1`, source `52222db` supports eligible Secret backtracking before dungeon completion; `f6d6401` adds **server-controlled placeholder side-entry gates** so Event opens after Room 1 and Secret after Room 2 only when that run is eligible. Local physical/regression and TEST-style composition tests passed. Final authored room art, normal-player unassisted optional boss fights and real multiplayer/recovery acceptance remain open.

**TEST Temple publish status is UNVERIFIED:** The latest gated-placeholder Publish As attempt on 20 September targeted the existing TEST Dungeon place `117293035754309` but Roblox Scripts publishing/version-history calls returned HTTP 429 rate limits. A publish timing marker and local tests do not prove that this newest gate/script version is playable in Roblox. Before any repeat publish, inspect the current TEST Temple Version History and join a genuinely fresh TEST Dungeon server; avoid rapid retries, preserve a current cloud rollback, and never overwrite the authored Lobby `134132328219009`, PROD or player DataStores.

Detailed evidence: `docs/testing/phase4-test-temple-optional-entrance-gates-2026-09-20.md`, `docs/testing/phase4-deferred-secret-backtracking-2026-09-20.md` and `docs/testing/phase4-test-lobby-optional-boss-origin-fix-2026-09-20.md`. Historical 19 September release-lock and unpublished-status entries below describe their **dated source checkpoints**, not the current TEST-only integration or uncertain 20 September publish attempt. The definitive updated status, next actions and restart brief are in v1.47 Sections 10 and Appendix J.

Historical note: Roadmap v1.45 added the four-step Event/Secret Boss **isolated backend**
checkpoint: recovery and reward replay, Mine live integration, four distinct
server-owned two-phase boss attack patterns, and fresh Base/Dungeon Studio
regressions. Gameplay source was validated at `3700dba`; the final regular
Base/Dungeon and static validation ran at `c86a904`.

See `docs/testing/phase4-optional-boss-four-backend-steps-closeout-2026-09-19.md`
for the exact source/log evidence and outstanding network-reconnect, authored
physical-arena, unassisted combat, and multiplayer release gates. Optional boss
rollout remains disabled in both dungeons; **no merge to main or game publish**
is implied by this roadmap update. The v1.45 DOCX passed zip/structure checks;
a visual PDF/page-render review is still pending after the Word export stalled.

Version 1.43 formally closes **Phase 3 - Systems Alpha** and opens
**Phase 4 - Content Alpha**.

The accepted Phase 3 gameplay release checkpoint is:

`84662948127eb1a37c9f184c6abbafe6f2daddb6`

That checkpoint was pushed to the Phase 3 feature branch and to `main`, then
verified against the GitHub server `main` ref before the documentation
closeout.

Published TEST environment:

- Universe: `10765241947`
- Starting Base: `134132328219009`
- Dungeon: `117293035754309`

The Dungeon and Starting Base both reached Roblox Studio
`PublishSuccessful` during the Phase 3 release. No PROD publish or Robux
action occurred.

Phase 3 accepts the Quest/Secondary-Class Advancement foundation,
Damage/Tank/Support Contribution, Blueprint/Recipe Knowledge,
Bestiary/Reputation, Rogue fourth-archetype breadth, deterministic Dungeon
modifiers, Guild/Hall, limited Market, DEV/TEST Race Change migration and the
economy/audit/stress hardening boundary. Progression catch-up and Transmog are
explicitly deferred.

Roadmap v1.43 opened Phase 4 with Starting Base presentation as the first
default gate. On 18 September 2026 the project owner explicitly parked modelling
and presentation work and moved Phase 4 through backend-only Dungeon gates.

The **Progressive Dungeon Depth + Difficulty** foundation is locally green at
`1230e6c`: schema v13 progression, 3/4/5/6 logical depths, authoritative
solo/party/session routing, fail-closed higher depths, combat/reward scaling and
completion unlock integration all passed the local acceptance matrix.

The follow-on **Generic Dungeon Encounter Runtime** is locally green at
`5ba9f4d`. The live Depth1 runtime now uses generic sequencer authority with
stable encounter checkpoints and reconnect state. The backend supports
Combat/MiniBoss/Boss/FinalBoss plus future EventBoss/SecretBoss insertion from
server-owned conditions. Unbound optional content fails closed, no Event/Secret
boss content is enabled, and Depth2-Depth4 remain fail closed.

The next **Encounter Execution / Spawn Registry** gate is locally green at
`fe1856e`. Encounter descriptors now select stable CombatPack/Boss executors;
combat packs resolve through server-owned catalogue data; boss-family content
resolves through stable BossId -> factory registration; live DungeonRuntime no
longer chooses concrete Marauder/Captain/Foreman factories. Transactional
startup cleans partial spawns and returns the generic sequence to Pending on
failure. Boss duplicate claims are scoped by session + encounter ID, which
supports multiple miniboss/boss/event/secret encounters in a single future run.
Temple and forced Abandoned Mine live execution proofs passed. Depth2-Depth4
remain fail closed, and no Event/Secret boss content is enabled.

The follow-on **Multi-Depth Physical Room-Binding Runtime** is locally green at
`1aa81b5`. Physical room-slot metadata, triggers, spawn anchors, barriers and
checkpoints are now resolved generically from layout data; live progression no
longer branches on fixed Room1/Room2/Boss cases. Real Temple compatibility and
forced Abandoned Mine + event/rare compatibility each passed 23/23 assertions.
Both current dungeons explicitly reject unimplemented Depth2-Depth4 physical
layouts, so higher depths remain fail closed while the runtime is ready for
future authored room sets and later Event/Secret boss bindings.

The follow-on **Dungeon Runtime Content Readiness Registry** is locally green at
`2e2420b`. Static layout/pack/boss/executor/factory registrations now live in
one shared catalogue usable by both Base and Dungeon. The old `RuntimeReady`
boolean is removed: `RuntimeReleaseEnabled` is only a rollout switch, while
`DungeonRuntimeContentReadiness` computes content completeness and final
readiness. Base progression entry and TeleportCoordinator use the computed
result, so incomplete content is rejected before server reservation. Current
Depth1 is complete+enabled+ready; Depth2-Depth4 remain
incomplete+release-disabled+not-ready with explicit diagnostics.

The follow-on **Generic Enemy Archetype + Heterogeneous Combat Pack Registry**
is locally green at `464bd44`. CombatPack execution is no longer
Marauder-specific: ordered pack entries resolve stable enemy archetypes and
server-owned factory IDs, while Deep Echoes / Crystal Bloom bonuses target
explicit entries. Current Temple/Mine Depth1 counts and naming remain
compatible. A synthetic 2-Marauder + 1-Elite pack proves mixed-factory
execution and rollback without enabling Elite as production content.

The follow-on **Authoritative Runtime Layout Selection + Environment
Activation** gate is locally green at `ccd289b`. Runtime startup now preserves
the selected DifficultyId and resolves its LayoutId before environment setup.
Encounter triggers and exit barriers are activated from registered layout data,
not hard-coded Temple/Mine arrays. A synthetic four-slot layout proves arbitrary
slot-count activation while current Depth1 boot/admission remains compatible.

The follow-on **Binding-Owned Spawn Groups + Exit Barriers** gate is locally
green at `cfbf2ea`. Combat-capable physical bindings now carry their own
enemy-spawn groups, while exit-barrier progression uses physical binding
anchors. Generic encounter spawning and recovery no longer require Temple/Mine
room-ID translation maps, so future Room4+ combat slots can be registered
without editing dungeon-specific adapter maps.

The follow-on **Selected-Layout Environment Contract** gate is locally green at
`405dde5`. Runtime environment resolution now derives exact room anchors and
combat spawn groups from the selected physical layout. A synthetic Room4
contract resolves through the real EnvironmentAnchorResolver, removing the
remaining static Depth1 contract dependency from production bootstrap/router
resolution.

The follow-on **Studio Difficulty / Session Parity** gate is locally green at
`d9297f8`. Studio-created dungeon sessions now preserve the difficulty already
selected by runtime/environment routing through session creation,
DungeonInstanceDirector and Studio routing data. This closes the final
demonstrated generic higher-depth framework mismatch before deliberate
Depth2-Depth4 content registration.

The follow-on **Depth2 Backend Combat + Boss Content** gate is locally green at
`b525235`. Both current dungeons now have registered Depth2 combat packs and
distinct Depth2 boss identities/factories. Depth2 readiness now fails only
because its physical layout is deliberately absent; the release switch remains
disabled. No higher-depth room geometry or anchors were authored.

The follow-on **Depth3 Backend Combat + Boss Content** gate is locally green at
`092bd99`. Both current dungeons now have registered Depth3 combat packs at
4/5/6/7 base counts plus distinct Depth3 boss identities/factories. Depth2 and
Depth3 readiness now fail only on their deliberately absent physical layouts;
both release switches remain disabled. The Depth3 boss IDs are available for
the locked Depth4 miniboss chain.

The follow-on **Depth4 Final-Difficulty Backend Content** gate is locally green
at `8bcb58b`. Both current dungeons now have complete backend content across
Depth1-Depth4. Depth4 preserves the locked six-encounter sequence: combat,
Depth1 miniboss, combat, Depth2 miniboss, Depth3 miniboss, then a new true final
boss. Depth2-Depth4 readiness now fails only on deliberately absent physical
layouts; all release switches remain disabled.

The following early Phase 4 evidence records remain historical; the latest
isolated optional-boss candidate has been committed and pushed to its feature
branch, but **has not been merged to main or published to Roblox**. Earlier
backend gates had separate local acceptance at the checkpoints listed below:

- `docs/testing/phase4-progressive-dungeon-depth-backend-acceptance-record.md`;
- `docs/testing/phase4-generic-dungeon-encounter-runtime-acceptance-record.md`;
- `docs/testing/phase4-encounter-execution-registry-acceptance-record.md`;
- `docs/testing/phase4-multi-depth-room-runtime-acceptance-record.md`;
- `docs/testing/phase4-runtime-content-readiness-acceptance-record.md`;
- `docs/testing/phase4-enemy-archetype-combat-pack-acceptance-record.md`;
- `docs/testing/phase4-runtime-layout-selection-acceptance-record.md`;
- `docs/testing/phase4-environment-binding-runtime-acceptance-record.md`;
- `docs/testing/phase4-layout-environment-contract-acceptance-record.md`;
- `docs/testing/phase4-studio-difficulty-parity-acceptance-record.md`;
- `docs/testing/phase4-depth2-content-acceptance-record.md`;
- `docs/testing/phase4-depth3-content-acceptance-record.md`;
- `docs/testing/phase4-depth4-content-acceptance-record.md`.

`docs/ai/CURRENT_STATE.md` is the fast engineering-status layer. It does not
replace this roadmap's LOCKED/WORKING/LATER/OPEN design decisions.

When the roadmap is deliberately revised, add the new canonical DOCX, update
its version/hash here, refresh `CURRENT_STATE.md`, and preserve an acceptance
or handoff record for the superseded engineering boundary.


The Phase 4 UI/HUD overhaul has a locally tested working candidate on
wip/phase-4-ui-overhaul-v1 (baseline ff2baa0). Shared dark-fantasy styling,
combat HUD/hotbar, refreshed core windows and entrance-/service-bound
dungeon/market windows are implemented. Parse, four builds, Base and
repeat Dungeon regressions passed. Visual/live interaction acceptance
remains OPEN; no push, merge or publish occurred.
Evidence: docs/testing/phase4-ui-hud-overhaul-candidate-acceptance-record.md.
The canonical roadmap DOCX remains v1.43 pending explicit revision.
