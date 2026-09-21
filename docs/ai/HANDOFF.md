# DungeonMMO Development Handoff

## 21 September 2026 — two-client world-boss party resilience handoff

The active branch now has a reusable `WorldBossMemberLifecycle`,
an opt-in geometric `WorldBossArenaLayout`, and verified two-client
world-boss Play. Two real Studio clients independently damage one
guardian, persist contribution and each receive their own weekly
reward once. One client then dies through its owning client Humanoid,
the server persists Dead mode, respawns that member into the same
session as Active and proves death/respawn cannot duplicate reward.
One client can then leave while the surviving peer remains active.

ContributionService and DungeonContributionBridge now accept negative
integral Roblox Studio multiplayer UserIds **only in Studio**. This
was required because ExecuteMultiplayerTestAsync clients use negative
IDs. Production/live identities remain positive-only and all malformed
IDs/events remain rejected.

Current wipe policy: connected dead members may respawn independently
into the same frozen encounter; wipe/death does not reroll event/week
or reset reward history. The arena helper is primitive geometry for
backend testing only and can be replaced by final authored art while
preserving `WorldBossArenaSpawn`.

Final accepted source:
`e83e4fae522582ec98bfc9cf4938ffdca9aa810b`.
Final local matrix: six Rojo builds; multiplayer
`VERIFIED_MULTIPLAYER_PASS`; lifecycle/wipe 14 assertions;
contribution 20; Base travel 18; Base return 22; Dungeon session 33;
Base professions 14/14; Dungeon backend 30/30.

**NEXT:** published TEST-only handoff. Configure explicit TEST Base
and world-boss place IDs, keep the event off outside the controlled
window, then prove Base → ReserveServer boss → Base using genuine
profile lease and MemoryStore/DataStore handoff. That is also where
same-account network reconnect and cross-server reward recovery must
be accepted. Separately add a real two-client healing/ward skill test
against the guardian before public release.

Roadmap: `docs/roadmap/DungeonMMO_Roadmap_v1_54_Weekly_World_Boss_Foundation.md`.
Receipt: `docs/testing/weekly-world-boss-v154-party-resilience-2026-09-21.md`.
All source/test/docs editing remains GitHub-only. Remote Desktop is
restricted to clean fast-forward pulls, Rojo builds, Studio tests and
read-only diagnostics. No cloud publish, production player DataStore,
force-push or main merge.

## Earlier 21 September real-combat handoff (historical)

## 21 September 2026 — real world-boss combat handoff

The active branch now includes the existing CombatService/client
controls and Marauder Captain AI in the isolated world-boss
composition. The world-boss runtime marks admitted characters with
the frozen weekly encounter ID and binds the shared contribution
bridge through WorldBossCombatAuthority.

Damage contribution now requires the exact active guardian Model and
an admitted player. The authority also verifies connected/non-abandoned
session membership, matching encounter attributes, a live guardian and
an undefeated weekly snapshot. Healing/ward support must target an
admitted member. Ordinary Dungeon behavior is unchanged because the
damage-target validator is optional and unset there.

A genuine unpublished Studio client used the normal attack RemoteEvent.
The guardian lost health through CombatService/DamageService, the
same hit persisted ContributionService damage, the existing guardian
AI damaged the player, and the player killed the guardian without
direct health injection. The session bridge persisted defeat, server
contribution certified completion eligibility, first weekly claim
paid 100 provisional gold and the immediate duplicate paid zero.
All final combat markers passed.

The real-client test found/fixed:
- nil indexing when weekly event state was missing/malformed;
- an `event` local shadowing the actual combat event, causing
  `InvalidWorldBossContribution` on genuine hits.

Post-kill reward delivery now retries from the runtime's existing
periodic loop. A contributor with an earned but unsaved reward is
kept in the recoverable boss session instead of being handed to Base.

Final accepted source:
`7605c811bb9f9a13ce2fb56f6b68a76f8c63ae89`.
Six Rojo builds, damage filter 7 assertions, contribution 14,
weekly 40 + factory 8, Base professions 14/14 and Dungeon backend
30/30 passed. Default-off boss-place Play also still passed.

**NEXT:** add a minimal authored WorldBossArenaSpawn/basic arena and
run actual multi-client boss combat. Test shared damage/support,
player death/wipe semantics, one member disconnecting while others
continue, reconnect after defeat, retry of unsaved reward and
independent Base return. Only after that should we configure
TEST-only real place IDs and run the first published Base →
ReserveServer boss → Base journey with real lease and cloud
persistence. Production event flags remain off.

Receipt:
`docs/testing/weekly-world-boss-v154-real-combat-2026-09-21.md`.
All source/test/docs edits remain GitHub-only. Remote Desktop was used
only for clean pulls, Rojo builds, Studio Play and diagnostics.
No cloud publish, production DataStore write, force-push or main merge.

## Earlier 21 September world-boss travel handoff (historical)

## 21 September 2026 — isolated world-boss travel handoff

On `wip/phase-4-test-hud-integration-v1`, the Base weekly entry
now has an optional independent physical gateway using the existing
DungeonBoard. Server-owned explicit UTC event settings and existing
ready-party validation guard reserved-session issuance. The
TeleportCoordinator uses the existing profile/lease handoff,
reserves the separately configured boss place and persists the
world-boss destination/party/week before transfer. An independent
world-boss Rojo place validates the stored session/member and nonce.
Normal Dungeon refuses all boss sessions.

Per-member Base return after a verified defeat uses the existing
coordinator. Its old session index is cleared only after Base
actually loads the member. If the Base teleport fails, the pending
return flag is rolled back to preserve boss reconnect. The runtime
also binds the first verified session before yielding on admission
to avoid cross-party collision in one reserved server.

The real ContributionService.get_player_snapshot returns top-level
Damage/Tank/Support. The original isolated runtime incorrectly
looked for `snapshot.snapshot`, making all actual rewards
unavailable. WorldBossContributionRules fixes that response
interpretation; 14 focused actual-service tests in Base and Dungeon
passed, including saved damage/healing and adapter-style recovery.
This does NOT mean player attacks are yet wired into the isolated
place. Ordinary dungeon/Temple and v1.53 professions remain
unchanged.

Acceptance receipts: isolated travel = six Rojo builds, Base and
Dungeon travel 18 assertions each, Base return 22, ordinary
Dungeon admission 10, destination factory 5, default-off Play,
Base professions 14/14, Dungeon gameplay 30/30 and material-chain
Play PASS. Hardening = Base and Dungeon contribution 14 assertions
each, six final Rojo builds, Base return 22, Base travel 18,
and final session regression 33 assertions in Base and Dungeon PASS.

**NEXT:** integrate the existing combat/client/controller safely
into the independent world-boss place, author a basic arena anchor,
run a real unassisted boss encounter and verify server-validated
damage/support, disconnect/reward retries and individual returns.
Only then consider explicit TEST-only place configuration and
published reserved-server networking. The boss place is
currently disabled/unplayable; no published real-place journey
or cloud MemoryStore/DataStore proof exists. Do not enable
production events or claim the whole travel milestone is released.

Roadmap:
`docs/roadmap/DungeonMMO_Roadmap_v1_54_Weekly_World_Boss_Foundation.md`.
Receipts:
`docs/testing/weekly-world-boss-v154-isolated-travel-2026-09-21.md`,
`docs/testing/weekly-world-boss-v154-travel-hardening-2026-09-21.md`.
All source/test/roadmap/handoff changes through GitHub; remote
desktop restricted to clean fast-forward pulls, unpublished
builds/Studio tests and read-only diagnostics. No cloud publish,
force-push, main merge or production DataStore write.

## Earlier 21 September session handoff (historical)

## 21 September 2026 — frozen weekly boss session handoff

The active branch contains `WeeklyWorldBossSessionBridge` and
`WeeklyWorldBossService.restore_instance`, both composed
server-side into Base/Dungeon RuntimeServices. After an **existing
server-authorized** DungeonSessionService run has InstanceState,
`issue` may store one immutable weekly boss/window/party snapshot.
A matching dead tagged guardian's defeat is written into the
same stored session state. A newly created bridge/service reading
the same map can resume the recorded state and deliver the
once-per-week reward only to a non-abandoned member whose existing
session completion eligibility was certified server-side.

Base and Dungeon session contract tests each passed **30 assertions**
in real unpublished Studio. Original weekly policy 40 each, boss
factory eight, Base professions 14/14 and Dungeon regression 30/30
passed too. Four Rojo compositions were built successfully.

**Immediate next backend:** dedicated world-boss destination/place,
server-authorized default-off Base gateway, reserved-session
handoff via existing coordinator and genuine destination admission.
Do not route an existing ordinary dungeon place to a world-boss
snapshot: the current ordinary DungeonRuntime remains unaware of
this bridge and would continue its normal encounter sequence.
Before release add validated contribution, disconnect and
pending reward semantics in the actual dedicated boss runtime.

The bridge is not hooked into normal portal gameplay.
Tests shared a Studio in-memory session adapter and profile store,
not real Roblox cross-server persistence. No cloud publish,
production DataStore, force-push or main merge took place.
All source/test/roadmap changes were via GitHub; local desktop
only fast-forward-pulled, built and tested.

Receipt: `docs/testing/weekly-world-boss-v154-session-bridge-2026-09-21.md`.

## Earlier 21 September weekly handoff (historical)

## 21 September 2026 — v1.54 weekly world-boss foundation handoff

Source at the active `wip/phase-4-test-hud-integration-v1` branch
contains `WeeklyWorldBossWindow`,
`WeeklyWorldBossService` and the default-off
`DungeonWeeklyWorldBossFactory`. Shared Base/Dungeon
`RuntimeServices` composes the weekly service but no client
RemoteEvent or normal-game entry route invokes it. A trusted
server-issued instance captures the active event window, an
approved party and a stable week ID. A matching tagged dead
guardian is required before the existing character profile can
receive the provisional 100 gold once per week; repeat kills
in another local instance pay zero. Monday 00:00 UTC is the
current calendar reset and the maximum allowed entry window
is two hours, both preliminary rules.

Studio accepted 40 policy assertions in BOTH Base/Dungeon,
eight factory assertions in Dungeon, 14/14 existing Base
profession and 30/30 Dungeon backend regressions. The
unpublished physical Play fixture used a real client prompt,
then spawned and assisted-defeated two guardians: first paid
100 gold in the loaded Dungeon profile and second paid none.
The final fixture disables incompatible autorun layout unit
tests only in its disposable DataModel; the dedicated factory
and general backend regressions were run independently.

**Next backend job:** connect server-authorized schedule/rollout,
real Base portal, existing session/teleport admission, reserved
boss place, persistent instance state and participation-based
reward eligibility without reimplementing the already accepted
dungeon/party/reward services. Test same-account network
rejoin and cloud TEST before enabling any live events.
No public entry, cloud publish, production DataStore writes,
main merge, final guardian rig or dedicated phase attacks.

Roadmap: `docs/roadmap/DungeonMMO_Roadmap_v1_54_Weekly_World_Boss_Foundation.md`.
Receipt: `docs/testing/weekly-world-boss-v154-local-foundation-2026-09-21.md`.
Keep all source, fixtures, roadmap and handoff edits through
GitHub only; Remote Desktop is restricted to a safe fast-forward
pull, unpublished Rojo/Studio runs and read-only inspection.

## Earlier 21 September v1.53 handoff (historical)

## 21 September 2026 — interrupted craft and same-UserId recovery handoff

Active source includes unique craft lock tickets and post-preparation
checks of both ticket ownership and the exact original Player.
This closes the stale-completion/new-lock-release risk on a same-UserId
rejoin within one server's runtime. The pure same-UserId lifecycle
uses a shared in-memory adapter: old request paused → release/save →
same UserId reload → old request resumes but cannot consume/award →
new request successfully crafts and persists exactly once.

Studio Base/Dungeon profession focused suites now pass **14/14**
each (21 craft-guard and 20 reconnect assertions). A real two-client
Base Play test paused server-side crafting and made the originating
client actually leave. The same UserId was reloaded **by the test
driver**, not by a new network connection. The old handler resumed
without touching the reloaded materials; an independent player
continued, and a distinct replacement account joined. Material-backed
Base crafting, wolf Dungeon encounter and the 30-suite Dungeon
regression were rerun and passed after the source fix.

Next: only if permitted by release scope, test *actual* same-account
relogin to a published TEST environment and cross-server lease/
DataStore handoff; do not use real-player production data to satisfy
the Studio test. Keep finished wolf art and dedicated animal AI as a
separate content gate. For any further source/fixture/roadmap changes,
edit **in GitHub only**, fast-forward a clean Windows worktree,
then build and run disposable unpublished Studio validation.
No production publish, force push or main merge occurred.

Receipt: `docs/testing/profession-v153-interrupted-reconnect-local-2026-09-21.md`.

## Earlier 21 September handoff (historical)

## 21 September 2026 — v1.53 latest local backend handoff

The active branch now includes an opt-in `ForestWolf` factory and
`Wolf` archetype. **No production/default packs include wolves**:
Temple Room1 was changed to a two-wolf pack only inside the
unpublished Studio Play fixture. The existing Marauder controller
rig provides temporary animal-like placeholder behaviour and
silhouette; final animal models/AI have not been authored.

The actual disposable Dungeon client/server encounter test passed:
Room1 physical trigger → two wolf spawns → assisted kills → ordinary
reward/room clear → retained looted corpse → real client Skinning →
one server-granted hide and disabled repeat. A genuine Base Play
client also crafted through all material-backed professions to
`warded_leatherbound_gloves`, including repeat/burst checks.
Two actual Studio clients independently crafted, contested one
corpse for exactly one hide and passed a peer disconnect check.
The in-memory two-user contest passed in rebuilt Base/Dungeon
focused runners (13/13 each). The broader Dungeon backend
matrix remained 30/30.

The *initial* burst fixture incorrectly assumed the Base starter
inventory lacked ore; both requests legitimately succeeded. The
corrected, source-versioned fixture cleared starter ore in a
disposable in-memory player and seeded exactly one craft's inputs:
one success/one rejection, no duplicated bar. The *initial*
two-user focused run hung on missing source in a stale Rojo build;
both rebuilds then passed. Do not report these earlier attempts
as passes.

Next backend step: same-account reconnect and interrupted
craft-request cleanup, with an explicit distinction between an
actual network disconnect and pure guard unit tests. Then decide
on release-eligible animal encounters/models only when requested.
Do not enable wolves in default packs merely to satisfy a test.
Do not claim public deployment or real-user DataStore validation.
Keep all future script, roadmap and handoff edits inside GitHub,
then clean fast-forward pull for Rojo/Studio only.

Evidence: `docs/testing/profession-v153-wolf-and-crafting-local-acceptance-2026-09-21.md`.

## Prior 21 September checkpoints (historical)

## 21 September 2026 — local animal-only Skinning test closeout

The server-only species allowlist, beast-tag requirement, defeated/
looted/corpse-once rules, temporary corpse prompt and animal-only
Dungeon cleanup have now passed actual unpublished Roblox Studio
tests. Four Rojo builds, Base/Dungeon focused professions 12/12 each
(363 assertions each), Dungeon cleanup 11 assertions and broad backend
30/30 PASS. Base Play tests proved real server grant and client
depletion at RawHideCache, as well as a server-authored test wolf
producing exactly one hide after death and loot. Existing Marauders
and unregistered enemies remain unskinnable; there are still no
authored animal factories/encounters in gameplay.

The Studio MCP bridge's direct client continued reporting an
unreachable Studio despite MCP being enabled. The official Studio
RunScript CLI successfully ran the unchanged GitHub test runners
and the StudioTestService Play-mode fixtures. Avoid asking the user
to toggle MCP merely to repeat tests already verified by this route.

Continue backend-first with a proper animal factory/content hook
only if needed, then actual combat → server loot → retained corpse →
skin interaction, a two-player contested skin claim, material-backed
Leatherworking → Enchanting client completion and craft
disconnect/retry. The local worktree must remain clean; create code,
new tests, roadmap and handoff edits **in GitHub**, then safely
fast-forward pull only for build/test. No publish, user DataStore
migration, force-push or main merge.

Receipt:
`docs/testing/animal-only-corpse-skinning-studio-verified-2026-09-21.md`.

## Historical staging checkpoint — before the above tests

## 21 September 2026 — animal-only Skinning test handoff

Latest GitHub-first branch is clean and locally fast-forwarded through
`8655c7e19bc97a9b9c803fc011e2e5a3080c47f3`. All four Rojo builds
passed. `SkinningEligibility`, `CorpseSkinningRuntime` and the shared
profession runtime now deny all unregistered and non-Beast enemies.
DungeonEnemyCleanup preserves only registered, defeated animal-like
corpses after reward processing; it never makes Marauders or bosses
skinnable. These are server logic and example future wolf/boar/bear
identities, **not a claim that animal enemies already exist**. The
temporary Base hide cache is still available separately.

The two new focused suites and expanded Dungeon cleanup suite exist in
GitHub but have **not** been executed in Studio. Direct Studio MCP
discovery returned `Unable to reach Roblox Studio right now`, and
delegated Codex Studio testing hit a usage limit. Restore the Studio
Assistant MCP-server connection, then run the versioned focused runner
in disposable Base/Dungeon, Dungeon cleanup tests, broad regression,
and a real server-authored animal corpse Play test. Re-run the Base hide
prompt diagnostic; it previously timed out and is not accepted.
Avoid editing scripts/docs via Remote Desktop: create any revisions in
GitHub, then safely fast-forward pull for local builds/Studio only.

Detailed receipt:
`docs/testing/animal-only-corpse-skinning-pending-studio-2026-09-21.md`.
No publishing, player DataStore migration, force-push or main merge.

## 21 September 2026 — local profession verification handoff

The active `wip/phase-4-test-hud-integration-v1` branch has passed
all four Rojo builds, ten focused profession suites in BOTH disposable
Dungeon/Base Studio places, 30 Dungeon backend suites and the generic
Base Play smoke. The first GitHub-authored live Base client fixture
passed actual near/far RemoteEvent routing at Leatherworking and
Enchanting but **failed** to obtain a Gather result when simulating a
RawHideCache ProximityPrompt hold. Do not promote v1.53 to full local
acceptance or assume the fault is in production gathering rather than
the test-input mechanism.

Next: diagnose the live prompt through a new Github-only test fixture
or actual client action in an unpublished disposable Studio place,
then verify one-time hide claim, live material-backed cross-profession
crafts, rapid same-player requests, independent players and disconnect/
retry. Inspect Base-only unrelated Dungeon test autorun messages.
Use `docs/testing/profession-v153-local-validation-2026-09-21.md`
for exact test results and logs. Keep edits to source, fixtures,
roadmap and documentation **on GitHub**; use Remote Desktop only for
safe fast-forward pulling, local builds, Studio execution and log reads.
No TEST/PROD publish, player DataStore acceptance, main merge or
force-push is authorized.

## 21 September 2026 — GitHub-only initial staging (historical)

The active branch contains unverified-in-Studio profession work above
the accepted v1.52 checkpoint. Do **not** rebuild these changes from
scratch. Read:
docs/roadmap/DungeonMMO_Roadmap_v1_53_Professions_Pending_Verification.md
and
docs/testing/profession-leatherworking-enchanting-pending-verification-2026-09-21.md.

Staged: Skinning/Leatherworking/Enchanting definitions and profile state,
raw-hide Base placeholder acquisition, separate temporary
Leatherworking/Enchanting station roots, cured-leather/warding material
chain, leatherbound and warded equipment, full cross-profession recipe
dependencies, migration/definition/atomic dependency tests, and a
per-player craft RemoteEvent request guard. Craft requests still require
the server-known station and distance; the RemoteEvent accepts recipe_id
only and no client-provided success outcome.

Desktop was intentionally not contacted. Tomorrow first confirm the
existing Windows worktree is clean and at v1.52, then fast-forward pull
the current branch, build all four Rojo compositions, run the focused
profession suite in Base and Dungeon, run the broad backend matrix, then
perform a Base Play-mode near/far/rapid-duplicate/disconnect crafting
interaction. Keep v1.53 status **pending** until those pass.

No cloud publish, real player DataStore migration, force-push or main
merge has been authorized.

## 20 September 2026 — v1.52 Event variation / profession backend handoff

Read docs/roadmap/
DungeonMMO_Roadmap_v1_52_Event_Variations_And_Professions.md
and docs/testing/
phase4-nonboss-event-profession-chain-2026-09-20.md.
Previous after-Room2 side room now has eight spawn anchors and
supports one independently opted-in 4-enemy Ambush or 8-enemy
Surge per run via the existing CombatPack executor. Temple/Mine
Depth2–4 supported. Saved run mechanic ID, encounter ID and
pack ID prevent rerolls or reward identity collisions.
Both normal Event-boss paths, optional Secret and original
Depth1/Depth2 default routes remain compatible. No actual
timed staggered wave, cave-in or novel enemy AI is included.

The existing two profession services also gained a two-way
Blacksmithing/Alchemy recipe dependency using two registered
items: forging_flux and runic_ironbound_gloves. No new
crafting service or new UI. New 46-assertion recipe chain
and seven service/regression suites passed in both local
Dungeon and Base places. All four Rojo builds, 25/25
optional-focused and 30/30 broad backend suites passed.
Independent assisted physical and actual party/disconnect
runs passed for both combat pack sizes; see dated receipts.

Continue backend-first with additional professions:
Leatherworking and Enchanting definitions, acquisition,
recipes, saved progression and anti-dupe/real station
interaction tests. Reuse ProfessionService/Runtime,
ProfessionDefinitions/Recipes, InventoryService and
RecipeKnowledgeService, and avoid model/presentation changes.
Only local test variants enabled new independently default-OFF
Event switches; no TEST/PROD, actual DataStore, main
merge or same-account network reconnect was performed.

## 20 September 2026 — v1.51 late Event physical/multiplayer closeout

Read the latest
docs/roadmap/DungeonMMO_Roadmap_v1_51_Late_Event_Physical_Acceptance.md
and docs/testing/
phase4-late-event-physical-multiplayer-2026-09-20.md.
The previous v1.50 backend-only EventAfterRoom2 insertion now has a
**dedicated, replaceable, physical TEMP side route** for Temple/Mine
Depth2–4. The original EventAfterRoom1 and SecretBeforeFinal
routes still work. Workspace DungeonMMOPlaceholderLateEventPlayEnabled
opts in to the placeholder geometry/layout; independent
ServerScriptService DungeonMMOOptionalBossTemplatesEnabled opts
in to server issuance. Both default OFF, alongside existing
optional/higher-depth release locks. An unissued or uncleared
late Event cannot open its gate; no production release was enabled.

Accepted local receipts: six structural dungeon/depth route
combinations, 85 physical assertions, 24/24 optional-focused
and 30/30 broad backend suites, four Rojo compositions,
assisted Temple Depth2 and Mine Depth4 actual late-bridge
walking Play-mode passes, separate two-client Temple Depth2
and four-client Mine Depth4 shared-run boss/disconnect/
checkpoint/reward lifecycle passes, plus original optional
and optional-disabled Temple Depth2 physical regressions.
True same-account cross-server rejoin, published TEST and
PROD verification, full-party unassisted combat and
finished meshes remain independent future gates.

Do not repeat the accepted fixed-side-room backend. If staying
within dungeon development, add **a genuinely new non-boss event
mechanic** through the existing encounter/executor system, with
explicit room capabilities, run frequency and recovery. Otherwise
prioritise remaining larger MMORPG backends (crafting professions,
raids/world bosses, guild competition/economy) after reading
the roadmap and accepted test matrix. Continue GitHub-first
script changes and local Studio only; no forced merges/publish.

## 20 September 2026 — v1.50 optional placement handoff

Current branch: wip/phase-4-test-hud-integration-v1. Read
docs/roadmap/DungeonMMO_Roadmap_v1_50_Optional_Event_Placement.md
and docs/testing/
phase4-optional-event-placement-templates-2026-09-20.md.
This GitHub-first checkpoint adds an independent default-OFF
DungeonMMOOptionalBossTemplatesEnabled server switch and a shared
EventAfterRoom1/EventAfterRoom2/SecretBeforeFinal catalogue.
The second Event placement is available only at Depth2–4, is saved
at run creation and uses a new EventArenaLate physical room identity.
Existing two original optional routes and selected boss variants
are unchanged. Policy enforces one Event and Secret per run,
rejects duplicate room claims and fails closed if the late slot
lacks an explicitly verified matching after-Room2 placement.

**Do not enable late placement:** No physical EventArenaLate room,
gate, bridge, trigger or spawn is registered. The new template has
only synthetic planning/recovery tests, not a walking playtest or
released boss. Before opening it, register actual replaceable
physical content and synchronize its gate using the saved plan;
validate physical traversal, concurrent party trigger/disconnect
and per-member rewards. Baseline Temple Depth2 normal/variant
routes, 274 template assertions, 23/23 focused suites, 30/30 broad
backend suites and four local Rojo compositions passed. Revisit
other MMORPG backends after this event-location capability is
accepted; do not keep remaking the completed dungeon runtime.
No cloud publish, real account DataStore or authored art changes.

## 20 September 2026 — dynamic optional variant backend closeout

Start from docs/roadmap/
DungeonMMO_Roadmap_v1_49_Phase4_Dynamic_Optional_Variants.md
and docs/testing/phase4-dynamic-optional-boss-variants-2026-09-20.md.
GitHub-first changes reuse DungeonOptionalBossRunState,
DungeonOptionalBossContent, existing boss factories/arena slots and
DungeonSecretDiscoveryService. When
DungeonMMOOptionalBossVariantsEnabled is set by the server only,
a new eligible run chooses one of two event/secret identities from
its deterministic seed and saves that choice; default is OFF.
After an initial physical Secret timeout, the legacy-only discovery
check was repaired to validate the matching saved dungeon-specific
Secret identity. A strict reward test also caught shared inherited
MarauderCaptain IDs between an alternate boss and a returning miniboss:
EventBoss/SecretBoss/MiniBoss/FinalBoss rewards are now scoped to
BossId + runtime encounter ID; Depth1 legacy Boss remains unchanged.

Final acceptance: dynamic variant matrix 2,205; discovery 232;
reward 80; focused 22/22; broader backend 30/30; all four local
Rojo compositions PASS. Temple Depth2 and Mine Depth4 alternate
physical runs, normal variant-disabled Temple Depth2 baseline and
4-client Mine Depth4 alternate multiplayer with one real disconnect,
separate reused-factory rewards and exactly-once three-member final
completion PASS. These are local Studio assisted-combat fixtures:
same-account network reconnect, new reserved-server reconstruction,
real player DataStore, cloud TEST/PROD and unassisted balance remain
outside current acceptance. Do not replace existing dungeon planner
or create a second event scheduler. Next backend step: add more
configurable event templates/explicit insertion capabilities under
the existing fail-closed authority and test each on Depth1–4.

## 20 September 2026 — higher-depth multiplayer backend closeout

Current integration branch wip/phase-4-test-hud-integration-v1.
GitHub-first two- and four-client local Studio TEMP fixtures verify shared
Temple/Mine Depth2/4 eligible runs, simultaneous Event and Secret touch
without duplicate boss spawns, real mid-Event or mid-Secret member removal,
continued party progression and member-specific reward replay protection.
The two-member Temple Depth2 and four-member Mine Depth4 strict completion
reruns passed real CompletionService persistence and idempotence for
1/3 surviving recipients. One initial stricter run failed because fresh
Studio profiles had not earned previous difficulties; fixture now awards
only disposable earlier-depth clears through the authoritative
progression service. A new Depth2/4, 1/2/4-member wipe/auto-revive
service-level suite passed 392 assertions, optional focused 19/19 and
broad backend 30/30; four local Rojo compositions built.
Read docs/testing/phase4-higher-depth-multiplayer-lifecycle-2026-09-20.md
for dated parent/child Studio logs and all caveats.
Next backend candidate: dynamic dungeon-event/secret variety using
the existing issuer, planner, boss registry and reward replay system,
without new schedulers or new art. Retain real same-account rejoin/cloud
acceptance as a separate deferred gate. No production release changes.

## 20 September 2026 — ChatGPT-authored roadmap v1.48 handoff

Read `docs/roadmap/DungeonMMO_Roadmap_v1_48_Phase4_Backend_Update.md`
after the unchanged historical v1.47 long-form roadmap. Local
Depth2–4 optional geometry and six assisted walking routes have passed.
The next backend gate is higher-depth party lifecycle across the existing
Temple/Mine Event/Secret systems: 1/2/4-member frozen shared runs, duplicate
spawn rejection on simultaneous touches, interrupted encounter/wipe/
checkpoint recovery, and exactly-once per-member boss/completion rewards.
Keep higher-depth and optional release locks OFF. Continue GitHub-first
source edits and local Studio tests, but do not assume main merge, cloud
publish, real same-account server rejoin or user DataStore acceptance.

## 20 September 2026 — six higher-depth optional physical routes

Current integration branch: wip/phase-4-test-hud-integration-v1.
GitHub-first placeholder geometry + physical layout + active-depth gate
changes add separate Event/Secret bridges to the existing TEMP Temple
and Mine Depth2/3/4 blockouts, without enabling release flags or
changing required room sequences. The tests physically walked into/out
of both side rooms and passed all six dungeon/depth combinations using
assisted enemy defeats. One more Mine Depth4 Play-mode run demonstrated
physical Secret bypass and backtracking before final completion, using
a TEMP-only final-spawn hold. Structural test: 139 PASS; focused optional
suite 18/18 PASS; broad backend matrix 30/30 PASS; optional-disabled
Temple Depth2 baseline and all four local Rojo builds PASS. Full paths
and seven Studio Play-mode log receipts:
docs/testing/phase4-depth2-4-optional-physical-playtest-2026-09-20.md.
These were automated Studio movement tests, not unassisted manual
combat or live same-account reconnect. The user previously verified
manual solo optional boss combat separately. No cloud push/publish or
player DataStore/art modification. Next: preserve accepted backend,
finish remaining Phase4 release/UX gates when requested.

## 20 September 2026 — optional depth/event backend continuation

Active integration branch: wip/phase-4-test-hud-integration-v1.
The existing generic optional encounter catalogue already defines
Event/Secret positions for Temple/Mine Depth1–4. Added focused
per-depth plan/eligibility and timed-entry expiry/recovery regressions.
RED tests exposed a hard-coded Room2 Secret gate that would open before
higher-depth prerequisites, and Mine placeholder gates that remained
closed forever. Fixed the shared gate prerequisite using frozen ordered
bindings, and enabled the existing server-owned gate lifecycle and
short blocked-entrance messaging for both named placeholder dungeons.
Fresh 17/17 Studio focused suites PASS (712 optional depth, 116 event
recovery, 32 gate assertions); assisted Temple/Mine Depth1 optional
physical routes, 30/30 broad gameplay suites and four local Rojo builds
PASS. See docs/testing/
phase4-optional-depth-events-and-side-gates-2026-09-20.md.
No Depth2–4 optional physical layout/bridge integration or higher-depth
release switch has been done. Work next on explicitly opted-in TEMP
higher-depth side-room physical layouts and route/recovery playtests,
without touching finished art, TEST/PROD cloud places or DataStores.

## 20 September 2026 — Depth1–4 integration handoff

Current branch: wip/phase-4-test-hud-integration-v1, worktree:
DungeonMMO_Phase4_HUD_Integration_v1. New GitHub-first
DungeonDepthLadderIntegrationTest (and focused Studio runner) passed
454 assertions / 5 suites on Temple+Mine Depth1–4. It uses the actual
CompletionService for persisted profile unlock and reward replay
rather than recording depth clears directly. Checks increasing 3/4/5/6
rooms, ordered miniboss lineage, recovered checkpoints and single
spawn/clear protection. 30/30 gameplay backend suites, Base Play mode
and all four local Rojo compositions passed. A fresh assisted Temple
Depth2 physical case passed; individual higher-depth Temple/Mine cases
are documented historically. One attempted multi-Play Studio runner
stopped after the first case and was removed (never count all six
as fresh). Full evidence:
docs/testing/phase4-depth1-4-progression-integration-2026-09-20.md.
Depth2–4 and optional release switches remain unchanged. Continue
using placeholders and GitHub-first edits; cloud, same-user rejoin,
PROD, player DataStores and art remain out of scope.

## 20 September 2026 — persisted session recovery follow-up

Current integration branch wip/phase-4-test-hud-integration-v1.
Added DungeonOptionalFullSessionRecoveryTest to the focused Studio
runner; 42 checks pass for interrupted Event/Final/deferred Secret,
checkpoint, two-member reconnect flags, original frozen eligibility,
optional entrance barriers and persisted reward replay protection.
15/15 focused suites and the existing assisted Temple backtracking
physical fixture passed. Evidence and exact Studio logs:
docs/testing/phase4-optional-full-session-recovery-2026-09-20.md.
There were no production runtime changes or cloud/DataStore mutations.
True same-account admission and a recreated live reserved Roblox server
still require separate acceptance; cloud verification is deferred.
The user explicitly confirmed a successful manual solo optional-boss
playtest; do not repeat that test as an outstanding gameplay blocker.

## 20 September 2026 — optional Event/Secret consecutive gameplay

The old no-healing injured-solo test remains FAILED. Do not conflate it
with two newly passing two-client cases: both players fought Event then
Secret using normal client combat without forced health changes; a
separate run used an equipped heal (+32 party HP) and server-confirmed
Dodge between those encounters, then cleared Secret and the final route.
Room1/Room2 and the final boss were assisted in these disposable local
Studio tests. All new fixtures and notes were committed on GitHub first
and pulled into the existing Windows integration worktree. See
docs/testing/phase4-optional-boss-consecutive-skill-defense-2026-09-20.md.
Next: if desired, verify solo survivability via legitimate defense/
healing, unassisted required rooms, true same-account rejoin. Cloud
verification and art remain intentionally deferred.

## 20 September 2026 — normal combat follow-up

GitHub-first source changes were fast-forward pulled for local Studio
combat fixtures. Real client attacks defeated Event independently
and Secret independently with normal player health. The same injured
surviving player died attempting Secret immediately after Event; do NOT
claim the combined sequence passed. Secret succeeded in a separate
healthy two-player run; all optional boss defeats used normal server
combat damage. Prerequisite packs and final room were assisted, and
player positioning was scripted. See docs/testing/
phase4-optional-boss-normal-combat-playtest-2026-09-20.md.
Next: legit healing/defense and consecutive optional boss survivability;
manual end-to-end and true rejoin remain separate acceptance gates.

## 20 September 2026 — two-client optional-boss gameplay tested

Current integration branch wip/phase-4-test-hud-integration-v1;
starting implementation c571552. TEMP local Studio two-client fight
passed: shared frozen eligible run; one Event boss for two simultaneous
clients; one player leaves during Active Event; peer preserves session
and checkpoint, defeats Event and Secret, blocks Event reward replay
and clears final boss. A saved-state detached sequencer validates
interrupted Event returns Pending; it does not reconnect the original
account or restart the actual live Dungeon server. Fixture:
scripts/studio/phase4_optional_boss_two_client_fight.luau.
Receipts and limits:
docs/testing/phase4-optional-boss-two-client-playtest-2026-09-20.md.
Continue backend with server-recreation/true rejoin validation when
possible, without cloud publication or any modelling work.

## 20 September 2026 — optional lifecycle continuation

Active worktree: DungeonMMO_Phase4_HUD_Integration_v1; branch:
wip/phase-4-test-hud-integration-v1. Starting checkpoint: 92b31be.
The shared encounter runtime now reverts unsaved Event/required startup
and unsaved optional Secret skip, preserving retry and normal-route
progression. New failure regression and expanded two-member/gate tests
PASS; five Rojo builds, local Temple physical backtracking, normal
Dungeon and two-client disconnect PASS. Full logs and qualifications:
docs/testing/phase4-optional-boss-lifecycle-hardening-2026-09-20.md.
Next gameplay gate: exercise Event/Secret side fights with two real
Studio clients, including interrupted boss recovery and repeat rewards;
same-account reconnection still needs separate evidence. Continue using
TEMP placeholders. Cloud verification/publishing is deliberately deferred.

## 20 September 2026 — side-gate recovery handoff

Continue on DungeonMMO_Phase4_HUD_Integration_v1,
wip/phase-4-test-hud-integration-v1. The optional Event/Secret side-bridge
gates already exist at f6d6401; roadmap v1.47 at 1083c01 documents
release status. This follow-up adds three isolated recovery assertions in
DungeonOptionalEntranceGatesTest; fresh Studio focused suite 13/13 and
all 16 gate assertions PASS. Log:
20260920T151636Z_Studio_1BE9F_last.log. Fresh TEMP physical Temple traversal and skipped-Secret backtracking
also passed in Studio log 20260920T151909Z_Studio_C434B_last.log,
including both gates initially closed, prerequisite unlocks and final
room completion. Full evidence is in
phase4-test-temple-optional-entrance-gates-2026-09-20.md.
The attempted cloud TEST Dungeon publish has unverified script/whole-place
state due to HTTP 429. Do NOT assume gates are live or retry publish
blindly. Confirm cloud version, back up existing TEST Dungeon, then verify
fresh cloud server before declaring release; preserve Lobby, PROD,
DataStores, authored branches and the existing rollback tag.

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

**Date:** 18 September 2026
**Active workstream:** Phase 4 - Content Alpha
**Canonical roadmap:** DungeonMMO Roadmap v1.44
**Phase 3 - Systems Alpha:** FORMALLY COMPLETE / ACCEPTED
**Gameplay release checkpoint:** 84662948127eb1a37c9f184c6abbafe6f2daddb6

## Where the project is now

Phase 2 and Phase 3 are closed.

The accepted Phase 3 gameplay checkpoint 84662948127eb1a37c9f184c6abbafe6f2daddb6 was:

1. pushed to wip/phase-3-systems-alpha-completion-v1;
2. fast-forwarded into local main;
3. pushed to origin/main;
4. independently verified against the GitHub server main ref.

The documentation closeout is layered on top of that accepted gameplay release.

## Published TEST environment

- Starting Base Place ID: 134132328219009
- Dungeon Place ID: 117293035754309
- Universe ID: 10765241947
- environment namespace: TEST

The Dungeon was Rojo-synced into the authenticated cloud place and published
first. Studio reported PublishSuccessful. The Starting Base was then synced and
published, and Studio again reported PublishSuccessful.

No PROD publish or Robux/monetisation action occurred.

## Accepted Phase 3 boundary

Do not recreate or replace these systems when continuing:

- Quest + race-specific Secondary-Class Advancement foundation;
- Damage/Tank/Support Contribution;
- Blueprint / Recipe Knowledge;
- Bestiary + Scholars Reputation;
- Fighter, Mage, Ranger and Rogue prototype starting archetypes;
- Rogue skill-tree breadth and Human Duelist / Elf Windstalker advancement
  targets;
- deterministic Fortified / Rich Deposits / Bounty Dungeon modifiers;
- personal reconnect-safe profession gathering and modifier interaction;
- Guild membership/progression/roles + private Guild Hall;
- limited fixed-price escrowed Market;
- DEV/TEST Race Change migration/archive/restore;
- economy audit and request/replay/ownership safeguards;
- shared persisted entity adapter.

Current profile schema: v13.

Schema v13 adds independent persistent Dungeon difficulty progression while
preserving legacy `DungeonProgress`.

## Final accepted evidence

The 18 September consolidated Studio run kept the earlier accepted combat,
progression, equipment, Dungeon, profession, Bank, Travel and reward suites
green while also passing the Phase 3 Rogue, contribution, bestiary/reputation,
guild, market, race-change, audit, modifier and entity-adapter families.

The Phase 3 stress harness passed:

profiles=250 market=1000 replay=1000 guild=250 sessions=100 race_roundtrips=100

The dedicated record is:

docs/testing/phase3-systems-alpha-acceptance-record.md

## Deliberate deferrals

- progression catch-up;
- Transmog.

Do not silently pull either back into the immediate plan. Revisit them only when
the roadmap conditions that justified deferral change.

## Phase 4 backend gate result

The earlier **Progressive Dungeon Depth + Difficulty backend foundation**
remains local green at `1230e6c`.

The follow-on **Generic Dungeon Encounter Runtime** is locally complete and
green at implementation checkpoint:

`5ba9f4d`

The accepted local proof now includes:

- generic ordered encounter-plan materialization;
- Combat, MiniBoss, Boss, FinalBoss, EventBoss and SecretBoss kinds;
- server-owned optional before/after insertion;
- required versus optional completion semantics;
- immutable persisted materialized run plans;
- reconnect-safe stable encounter-ID lifecycle state;
- legacy Room1/Room2/Boss checkpoint migration;
- stable `EncounterStart:<EncounterId>` checkpoints;
- Depth1 physical/logical compatibility bindings;
- live DungeonRuntime Room1 -> Room2 -> boss authority moved to the generic
  sequencer;
- required inserted encounters cannot be bypassed;
- activated optional encounters fail closed when physical bindings are absent;
- existing EncounterService IDs, rewards, doors and Captain/Foreman behaviour
  preserved;
- Depth2-Depth4 remain fail closed;
- Event/Secret boss content remains disabled.

The follow-on **Encounter Execution / Spawn Registry** is locally complete and
green at implementation checkpoint:

`fe1856e`

Accepted proof now also includes:

- stable CombatPack and Boss executor selection from encounter descriptors;
- server-owned combat-pack spawn catalogue;
- stable BossId -> factory registration;
- MarauderCaptain + CorruptedForeman registered as current boss content;
- DungeonRuntime concrete factory decisions removed;
- transactional startup and rollback to Pending on execution failure;
- cleanup on partial pack failure, boss factory failure and downstream
  EncounterService rejection;
- encounter-scoped boss duplicate claims, allowing several distinct boss-family
  encounters in one dungeon run;
- future boss content fails closed until its BossId/catalogue/factory/binding is
  deliberately registered;
- real Temple execution-registry acceptance: 15 assertions PASS;
- forced Abandoned Mine DeepEchoes + CrystalBloom execution-registry
  acceptance: 16 assertions PASS;
- 494 repository Lua/Luau files parsed with 0 failures;
- all four Rojo compositions build cleanly;
- final repeat committed Dungeon regression has no project errors;
- final committed Base regression has no project errors;
- Phase 3 Systems Stress remains green;
- 26 changed code/test files from `c6e181c`, 0
  art/model/mesh/terrain/image files.

Evidence:
`docs/testing/phase4-encounter-execution-registry-acceptance-record.md`

No push, merge or Roblox publish has been performed for this Phase 4 gate.

The follow-on **Multi-Depth Physical Room-Binding Runtime** is now locally
complete and green at implementation checkpoint:

`1aa81b5`

Accepted proof now also includes:

- generic physical room-slot definitions for current Dungeon layouts;
- logical encounter -> room/trigger/spawn/barrier/checkpoint binding;
- generic live progression instead of fixed Room1/Room2/Boss branches;
- binding-specific boss spawn anchors;
- legacy Depth1 checkpoint recovery compatibility;
- Temple real-trigger compatibility: 23/23 assertions PASS;
- forced Abandoned Mine DeepEchoes + CrystalBloom compatibility:
  23/23 assertions PASS;
- explicit fail-closed production binding checks for Depth2, Depth3 and Depth4
  in both current dungeons;
- 501 repository Lua/Luau files parsed with 0 failures;
- all four Rojo compositions build cleanly;
- final committed Dungeon and Base regressions green;
- Phase 3 Systems Stress remains green;
- 12 changed code/test files from `2deb540`, 0
  art/model/mesh/terrain/image files.

Evidence:
`docs/testing/phase4-multi-depth-room-runtime-acceptance-record.md`

Depth2-Depth4 remained fail closed at this checkpoint. Event/Secret boss
content remains disabled. No modelling, meshes, terrain, authored rooms or
presentation work was performed.

The follow-on **Dungeon Runtime Content Readiness Registry** is locally
complete and green at implementation checkpoint:

`2e2420b`

Accepted proof now also includes:

- shared static content catalogue for layouts, packs, bosses, executor IDs and
  boss-factory IDs;
- old `RuntimeReady` property removed;
- explicit rollout switch renamed to `RuntimeReleaseEnabled`;
- computed `ContentComplete`, `ReleaseEnabled`, `Ready` and issue list;
- Base progression entry uses computed readiness;
- TeleportCoordinator uses computed readiness before server reservation;
- Depth1 is complete+enabled+ready for both current dungeons;
- Depth2-Depth4 are incomplete+disabled+not-ready for both current dungeons;
- missing higher-depth layouts/content are reported diagnostically;
- Dungeon bootstrap verifies shared implemented executor/factory declarations
  match actual server-side registrations;
- 504 repository Lua/Luau files parsed with 0 failures;
- all four Rojo compositions build cleanly;
- final committed Base and Dungeon regressions green;
- Phase 3 Systems Stress remains green;
- 13 source/test files from `a942f6d`, 0
  art/model/mesh/terrain/image files.

Evidence:
`docs/testing/phase4-runtime-content-readiness-acceptance-record.md`

No push, merge or Roblox publish has been performed for this gate.

The follow-on **Generic Enemy Archetype + Heterogeneous Combat Pack Registry**
is locally complete and green at implementation checkpoint:

`464bd44`

Accepted proof now also includes:

- stable shared enemy archetypes;
- stable server-only enemy factory IDs;
- a dedicated `DungeonEnemyFactoryRegistry`;
- ordered heterogeneous combat-pack entries;
- generic `CombatPackEncounterExecutor`;
- old Marauder-specific combat-pack executor removed;
- Deep Echoes / Crystal Bloom pack bonuses targeting explicit EntryIds;
- exact existing Temple/Mine Depth1 pack-count compatibility;
- synthetic 2-Marauder + 1-Elite execution proof without enabling Elite as
  production content;
- mixed-pack transactional cleanup on factory failure;
- readiness validation for pack entries/archetypes/factories/bonus targets;
- 507 repository Lua/Luau files parsed with 0 failures;
- all four Rojo compositions build cleanly;
- final committed Base and clean-repeat Dungeon regressions green;
- Phase 3 Systems Stress remains green;
- Training Dummy and Combat Target Rules green;
- live Dungeon player admission succeeded;
- 11 source/test files from `5298699`, 0
  art/model/mesh/terrain/image files.

Evidence:
`docs/testing/phase4-enemy-archetype-combat-pack-acceptance-record.md`

No new production enemy archetype was enabled.
Depth2-Depth4 remain release-disabled/content-incomplete.
No push, merge or Roblox publish has been performed for this gate.

The follow-on **Authoritative Runtime Layout Selection + Environment
Activation** gate is locally complete and green at:

`ccd289b`

Accepted proof now also includes:

- authoritative DungeonId + DifficultyId + LayoutId selection;
- TeleportData difficulty preservation in production;
- optional Studio difficulty selection with default fallback;
- explicit physical exit-barrier anchors in layout metadata;
- generic arbitrary-slot trigger/barrier activation;
- no hard-coded Temple/Mine trigger/barrier arrays in environment bootstrap;
- readiness validation for missing physical barrier bindings;
- Runtime Selection: 7 assertions PASS;
- Environment Layout Activation: 12 assertions PASS;
- 510 repository Lua/Luau files parsed with 0 failures;
- all four Rojo compositions build cleanly;
- final committed Base and Dungeon regressions green;
- Phase 3 Systems Stress remains green;
- 7 source/test files from `0177b17`, 0
  art/model/mesh/terrain/image files.

Evidence:
`docs/testing/phase4-runtime-layout-selection-acceptance-record.md`

No push, merge or Roblox publish has been performed for this gate.

The follow-on **Binding-Owned Spawn Groups + Exit Barriers** gate is locally
complete and green at:

`cfbf2ea`

Accepted proof now also includes:

- combat-capable slots carry EnemySpawnGroup;
- encounter bindings carry EnemySpawnGroup and ExitBarrierAnchor;
- CombatPack execution uses binding-owned environment groups rather than
  room-ID spawn maps;
- DungeonRuntime encounter-clear and recovery barriers use physical binding
  anchors rather than room-ID barrier maps;
- readiness rejects combat bindings without spawn groups;
- Dungeon Encounter Bindings: 34 assertions PASS;
- Dungeon Encounter Environment Runtime: 8 assertions PASS;
- Combat Pack Encounter Executor: 15 assertions PASS;
- Encounter Executors: 21 assertions PASS;
- Encounter Execution Bootstrap: 4 assertions PASS;
- Runtime Content Readiness: 64 assertions PASS;
- 512 repository Lua/Luau files parsed with 0 failures;
- all four Rojo compositions build cleanly;
- final committed Base and Dungeon regressions green;
- Phase 3 Systems Stress remains green;
- 11 source/test files from `caf56c5`, 0
  art/model/mesh/terrain/image files.

Evidence:
`docs/testing/phase4-environment-binding-runtime-acceptance-record.md`

No push, merge or Roblox publish has been performed for this gate.

The follow-on **Selected-Layout Environment Contract** gate is locally complete
and green at:

`405dde5`

Accepted proof now also includes:

- production room-anchor resolution derived from the selected physical layout;
- combat spawn-group prefix/minimum metadata owned by physical slots;
- runtime base contracts reduced to environment-wide completion/return anchors;
- bootstrap and router using the same selected-layout contract builder;
- legacy adapter full-contract compatibility preserved;
- synthetic Room4 resolution through the real EnvironmentAnchorResolver:
  14 assertions PASS;
- Encounter Bindings: 34 assertions PASS;
- Runtime Content Readiness: 64 assertions PASS;
- clean-repeat Combat Target Rules: 9 assertions PASS;
- 514 repository Lua/Luau files parsed with 0 failures;
- all four Rojo compositions build cleanly;
- final committed Base regression green;
- clean-repeat committed Dungeon regression green;
- Phase 3 Systems Stress remains green;
- 9 source/test files from `87a88c1`, 0
  art/model/mesh/terrain/image files.

Evidence:
`docs/testing/phase4-layout-environment-contract-acceptance-record.md`

No push, merge or Roblox publish has been performed for this gate.

The follow-on **Studio Difficulty / Session Parity** gate is locally complete
and green at:

`d9297f8`

Accepted proof now also includes:

- explicit Studio difficulty propagation into session creation;
- explicit Studio difficulty propagation into DungeonInstanceDirector;
- Studio routing data preserving DifficultyId;
- reused Studio sessions preferring authoritative session difficulty;
- DungeonRuntime using the environment-resolved DifficultyId;
- Studio Session Factory: 7 assertions PASS;
- Layout Environment Contract: 14 assertions PASS;
- Encounter Bindings: 34 assertions PASS;
- Runtime Content Readiness: 64 assertions PASS;
- clean-repeat Training Dummy: 9 assertions PASS;
- clean-repeat Combat Target Rules: 9 assertions PASS;
- 514 repository Lua/Luau files parsed with 0 failures;
- all four Rojo compositions build cleanly;
- final committed Base regression green;
- clean-repeat committed Dungeon regression green;
- Phase 3 Systems Stress remains green;
- 3 source/test files from `5fb3491`, 0
  art/model/mesh/terrain/image files.

Evidence:
`docs/testing/phase4-studio-difficulty-parity-acceptance-record.md`

No push, merge or Roblox publish has been performed for this gate.

The follow-on **Depth2 Backend Combat + Boss Content** gate is locally complete
and green at:

`b525235`

Accepted proof now also includes:

- three registered Depth2 combat packs per current dungeon;
- 3/4/5 Marauder base counts;
- Mine Deep Echoes and Crystal Bloom Depth2 bonus preservation;
- TempleDepth2Boss / Temple Warden factory identity;
- AbandonedMineDepth2Boss / Deep Overseer factory identity;
- both Depth2 bosses retaining accepted Captain controller behavior;
- Depth2 readiness failing only on DungeonLayoutNotRegistered;
- Depth2 remaining release-disabled and physically unregistered;
- Depth2 Content: 32 assertions PASS;
- Depth2 Boss Factory: 8 assertions PASS;
- Encounter Spawn Catalog: 17 assertions PASS;
- Runtime Content Readiness: 66 assertions PASS;
- 518 repository Lua/Luau files parsed with 0 failures;
- all four Rojo compositions build cleanly;
- final committed Base and Dungeon regressions green;
- Phase 3 Systems Stress remains green;
- 8 source/test files from `468cf76`, 0
  art/model/mesh/terrain/image files.

Evidence:
`docs/testing/phase4-depth2-content-acceptance-record.md`

No push, merge or Roblox publish has been performed for this gate.

The follow-on **Depth3 Backend Combat + Boss Content** gate is locally complete
and green at:

`092bd99`

Accepted proof now also includes:

- four registered Depth3 combat packs per current dungeon;
- 4/5/6/7 Marauder base counts;
- Mine Deep Echoes and Crystal Bloom Depth3 bonus preservation;
- TempleDepth3Boss / Relic Guardian factory identity;
- AbandonedMineDepth3Boss / Hollow Taskmaster factory identity;
- both Depth3 bosses retaining accepted Captain controller behavior;
- Depth2 and Depth3 readiness failing only on DungeonLayoutNotRegistered;
- Depth3 remaining release-disabled and physically unregistered;
- Depth3 Content: 36 assertions PASS;
- Depth3 Boss Factory: 8 assertions PASS;
- Encounter Spawn Catalog: 19 assertions PASS;
- Runtime Content Readiness: 68 assertions PASS;
- 522 repository Lua/Luau files parsed with 0 failures;
- all four Rojo compositions build cleanly;
- final committed Base and Dungeon regressions green;
- Phase 3 Systems Stress remains green;
- 8 source/test files from `3d978af`, 0
  art/model/mesh/terrain/image files.

Evidence:
`docs/testing/phase4-depth3-content-acceptance-record.md`

No push, merge or Roblox publish has been performed for this gate.

The follow-on **Depth4 Final-Difficulty Backend Content** gate is locally
complete and green at:

`8bcb58b`

Accepted proof now also includes:

- two registered Depth4 combat packs per current dungeon;
- 5/7 Marauder base counts;
- Mine Deep Echoes and Crystal Bloom Depth4 bonus preservation;
- the locked Depth1 -> Depth2 -> Depth3 miniboss reuse chain;
- TempleDepth4Boss / Sanctum Ascendant final-boss identity;
- AbandonedMineDepth4Boss / Buried Tyrant final-boss identity;
- both final bosses preserving BossRole = FinalBoss;
- Depth2, Depth3 and Depth4 readiness failing only on
  DungeonLayoutNotRegistered;
- all Depth1-Depth4 encounter content registered;
- Depth2-Depth4 remaining release-disabled and physically unregistered;
- Depth4 Content: 38 assertions PASS;
- Depth4 Boss Factory: 10 assertions PASS;
- Encounter Spawn Catalog: 20 assertions PASS;
- Encounter Executors: 21 assertions PASS;
- Runtime Content Readiness: 70 assertions PASS;
- 526 repository Lua/Luau files parsed with 0 failures;
- all four Rojo compositions build cleanly;
- final committed Base and Dungeon regressions green;
- Phase 3 Systems Stress remains green;
- 10 source/test files from `230f7f5`, 0
  art/model/mesh/terrain/image files.

Evidence:
`docs/testing/phase4-depth4-content-acceptance-record.md`

No push, merge or Roblox publish has been performed for this gate.

## Exact next action

Stop at this local-green boundary until the project owner chooses the next
backend gate or release closeout. Push, merge and Roblox publish each require an
explicit instruction.

Generic higher-depth framework blockers remain cleared through
`d9297f8`; Depth2 content is complete at `b525235`, Depth3 content at
`092bd99`, and Depth4 final-difficulty content at `8bcb58b`.

Depth1-Depth4 backend encounter content is now complete for both current
dungeons. Keep Depth2-Depth4 release-disabled and do not register physical
layouts until authored rooms exist. The next backend-only dungeon gate may
cover Event/Secret boss content and insertion policy without authoring models or
rooms.

Carry forward these readiness rules:

- `RuntimeReleaseEnabled` is only the explicit rollout switch;
- production entry may use only computed `DungeonRuntimeContentReadiness`;
- Depth2-Depth4 must remain release-disabled until their complete content and
  physical bindings are deliberately implemented and accepted;
- Event/Secret boss content remains disabled until its own content/binding gate
  is approved.

No modelling, meshes, terrain, authored rooms, visual polish or difficulty UI
was performed in this gate.

## Safety and repository paths

Primary repo:

C:\Users\Remko\Documents\Roblox\DungeonMMO

Active Phase 4 Depth4-content worktree:

C:\Users\Remko\Documents\Roblox\DungeonMMO_Phase4_Depth4Content_v1

Active branch:

wip/phase-4-depth4-content-v1

Phase 3 completion worktree:

C:\Users\Remko\Documents\Roblox\DungeonMMO_Phase3_Completion_v1

Art worktree remains isolated:

C:\Users\Remko\Documents\Roblox\DungeonMMO_Art

No hard reset, clean, force-push or history rewrite. Do not use PROD DataStores
or publish PROD without a separate explicit approval.

## Event/Secret Boss backend candidate (19 September 2026)

A separate backend candidate exists in DungeonMMO_Phase4_EventSecretPolicy_v1, based on ff2baa0. The four distinct optional-boss identities and their server-only event-window/secret-unlock triggers are implemented. Secret-boss direct-successor skip is persisted through the existing generic encounter controller. Dungeon Studio: policy 49, flow 9, factories 24 and release locks 14 assertions PASS; 537 Lua/Luau files parse; four Rojo builds PASS. The Base gameplay regressions also passed. Both current dungeons remain rollout-disabled, with no optional arenas; Depth2-4 physical layouts remain unregistered. This is CODE-ONLY BACKEND VERIFIED and NOT RELEASED. Authored arenas, authoritative boss-event schedule/secret-unlock issuers and physical gameplay acceptance are future gates. No push, merge, publish or UI changes. Evidence: docs/testing/phase4-optional-boss-policy-progress.md.

Backend closeout (19 September 2026): server-issued optional-boss
run-state regression passed 28 offline Luau assertions; four
Rojo builds and diff check passed. Physical arenas, event
schedules and secret-route release settings remain gated.\r\n\r\n
## UI candidate handoff - 19 September 2026

Continue at DungeonMMO_Phase4_UIOverhaul_v1, branch
wip/phase-4-ui-overhaul-v1. Parser, four builds and Base/Dungeon Studio
regressions passed; see UI candidate acceptance record.
Before merging/publishing, visually test normal gameplay at desktop and
small viewports, player/target/hotbar spacing, Guild/Inventory/Skills close,
DungeonEntryPrompt and AuctionHousePrompt open/close/distance behaviour,
party entry and dungeon HUD with active boss/completion.
Preserve backend, physical depth locks and isolated art worktree.
No push, merge or Roblox publish has been performed.
