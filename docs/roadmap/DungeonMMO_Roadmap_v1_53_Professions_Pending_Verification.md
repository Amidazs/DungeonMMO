# DungeonMMO Roadmap v1.53 — Leatherworking / Enchanting staged

**Historical profession milestone:** The newer backend roadmap is
`docs/roadmap/DungeonMMO_Roadmap_v1_54_Weekly_World_Boss_Foundation.md`.
v1.53 remains the source of truth for the earlier profession tests
and its separate cross-server/release acceptance boundaries.


**Date:** 21 September 2026  
**Status:** Local backend Play acceptance for crafting, animal-only Skinning, two-client independence and interrupted-craft recovery; **actual same-account network reconnect, cross-server persistence, final animal art/AI and release/cloud validation pending**  
**Branch:** `wip/phase-4-test-hud-integration-v1`

## Latest local recovery acceptance — 21 September 2026

The craft request guard now issues unique per-request tickets and
validates the original player instance **after preparation, before
inventory mutation**. An old craft suspended while the client leaves
cannot complete into a reloaded same-UserId profile or release the
new session's lock when it resumes.

Four Rojo compositions built successfully. The 14-suite focused
profession runners passed in Base and Dungeon, with **21 guard
assertions** and **20 same-UserId recovery assertions** in each.
A genuine disposable two-client Studio Base Play test deliberately
paused one client's server craft after preparation, disconnected that
client, waited for profile release, reloaded the same UserId using the
test server's in-memory adapter, and resumed the old request. The
reloaded character retained its two ore without an extra iron bar;
the other client remained connected, and Studio admitted a distinct
replacement test account. The parent Studio multiplayer run passed.
Full client material-backed crafting, opt-in wolf encounter/Skinning
and the wider 30-suite Dungeon matrix were rerun and passed after
the guard change.

**Remaining release gate:** Studio's replacement account is not a
network reconnect of the departed UserId. Real same-account reconnect
on a new live server, lease handoff, cross-server DataStore persistence
and retry remain unverified. Do not describe this local lifecycle
proof as production cloud/cross-server acceptance. Final animal
AI/art, default-pack rollout and published validation are also
still separate gates.

Receipt: `docs/testing/profession-v153-interrupted-reconnect-local-2026-09-21.md`.

## Earlier local milestones (historical)

## Latest local milestone — 21 September 2026

**Locally verified:** an opt-in `ForestWolf` factory and separate
`Wolf` archetype; real disposable Temple Room1 encounter/reward →
retained looted animal corpse → actual client Skinning → one raw hide.
The default dungeon packs remain Marauder-only; this test changes
Temple Room1 only inside an unpublished disposable Studio DataModel.
The current wolf is temporary combat-rig/animal-silhouette content,
not finished wolf art or dedicated animal AI.

**Locally verified:** one actual Base player completed the entire
material-backed Blacksmithing → Alchemy → Leatherworking → Enchanting
dependency chain to `warded_leatherbound_gloves` through the original
station-checked client RemoteEvents. A repeated enchant with no inputs
was rejected. Two rapid requests with just enough ore for one recipe
yielded one iron bar, one `MissingMaterials` rejection and no
double-consumption.

**Locally verified:** a two-user atomic corpse contest passed in both
Base and Dungeon (13/13 focused suites in each composition). A
separate genuine two-client Base Play-mode fixture proved independent
iron-bar crafting, exactly one total hide granted from a shared corpse
and peer survival after the other client disconnected.
The normal Dungeon backend matrix remained 30/30; wolf factory and
enemy cleanup tests remained green.

**Still pending:** same-account reconnect and in-flight
disconnect/retry, end-to-end cross-server persistence, dedicated
animal AI and final enemy models/balance, production wolf pack
placement, unassisted dungeon combat, published cloud validation and
real-player DataStore acceptance. Keep these gates open; do not
equate the disposable local Play proofs with a live release.

Detailed source and Studio receipts:
`docs/testing/profession-v153-wolf-and-crafting-local-acceptance-2026-09-21.md`.

## Historical v1.53 progress snapshots

This supplement follows the accepted v1.52 Event-variation /
Blacksmithing-Alchemy checkpoint. The work was first staged in GitHub
while the desktop was offline; local verification has now resumed. The
physical profession station gate is still pending. The historical
canonical `DungeonMMO_Roadmap_v1_47.docx` is unchanged.

## Latest local verification — 21 September 2026

The animal-only Skinning policy and the first interactive
client/server hide-grant path are **locally verified**. Four Rojo
builds, Base/Dungeon focused profession suites (12/12 each; 363
assertions each), Dungeon cleanup (11 assertions), and broad Dungeon
backend matrix (30/30) PASS. A real Base Play client gathered exactly
one raw hide from a temporary Base cache, after which the prompt
was disabled. A separate real Base Play client skinned a temporary
server-created, dead-and-looted wolf and received exactly one hide;
a second interaction on that corpse was disabled. The earlier cache
timeout was a test expectation mistake after prompt depletion,
not evidence of an unprocessed first grant.

The actual game does **not** yet include authored animal enemies,
so a genuine dungeon animal combat → loot → retained corpse → skin
flow remains pending. Also pending: actual client material-backed
Leatherworking/Enchanting completion, contested two-player corpse
claim, overlapping real crafting requests and disconnect/retry,
cloud TEST/PROD and real user DataStore migration. The Base cache
is still a non-monster temporary material source.

Full local evidence:
`docs/testing/animal-only-corpse-skinning-studio-verified-2026-09-21.md`.

## Historical v1.53 implementation checkpoint

## Implemented in GitHub

### 1. Profession coverage expanded

The shared profession system now covers:

- Mining ↔ Blacksmithing
- Herbalism ↔ Alchemy
- Skinning ↔ Leatherworking
- Enchanting as a creation profession consuming products from multiple
  other profession chains

Leatherworking and Enchanting retain the same Level/XP progression
framework, recipe catalogue, inventory authority and server-side
completion boundary already used by Blacksmithing and Alchemy.

### 2. Multi-profession dependency chain

The staged backend can produce `warded_leatherbound_gloves` through
one connected chain:

`raw_hide`
→ Leatherworking + Alchemy oil → `cured_leather`
→ Leatherworking + Blacksmithing bar → `leatherbound_gloves`
→ Alchemy/Blacksmithing reagents → `warding_essence`
→ Enchanting + Blacksmithing bar → `warding_rune`
→ Enchanting + Leatherworking gloves + Alchemy flux
→ `warded_leatherbound_gloves`.

The result intentionally requires contributions from more than one
profession instead of allowing each creation profession to be entirely
self-contained.

### 3. Placeholder acquisition/stations

A server-claimed Base `RawHideCache` supplies Skinning material until
creature harvesting is authored. Leatherworking and Enchanting use
separate temporary station roots derived from existing Base profession
anchors. These are backend placeholders, not final models or art.

### 4. Craft request authority tightened

The server-side Base crafting RemoteEvent still accepts only the recipe
identity. A client does not submit a craft-success/minigame-success
payload. The server checks the recipe's required station and player
distance before crafting.

A new per-player request guard rejects overlapping craft requests from
the same player with `CraftRequestInProgress`. The guard releases after
the request finishes or the player leaves; other players use independent
request lanes. Ingredient/output mutation remains inside
`ProfessionService` and `ProfileService`.

## 21 September local verification (partial)

The clean Windows integration worktree was safely fast-forwarded to
`45a9bc25a185fcdb00579e977a22dc582eefc1ec`. Four unpublished
Rojo compositions (Dungeon, Base and both published-style layouts) built
successfully. The existing focused profession runner passed **10/10**
in each disposable local Dungeon/Base Studio Edit place; the Base result
records **305 assertions**. The Dungeon broad gameplay matrix passed
**30/30**. The in-memory full profession chain, profile migration,
equipped-item protection, wrong-minigame rejection, save/reload,
station-range rules and isolated craft-request guard are included in
those focused passes. The existing generic Base Play-mode smoke passed
player spawn, Base runtime/profile remote and release-lock checks.

This is **not** live interaction acceptance. Base Play mode has not yet
proven an actual near/far client craft request, the one-time RawHideCache
prompt, the client-driven Leatherworking/Enchanting station chain,
rapid duplicate requests, two-player independence or real disconnect/
retry cleanup. The Base Play log also contains unrelated Dungeon-only
autorun script errors/warnings. Preserve this remaining gate and do not
claim that the entire new profession system is fully accepted yet.

The first GitHub-authored real-client Base Play fixture passed
station range/routing for both Leatherworking and Enchanting:
too-far requests were rejected and near requests reached
`ProfessionService` (which returned `MissingMaterials`). It then
**failed** at the scripted RawHideCache interaction with a 15-second
Gather-result timeout; do not treat the fixture as fully passing or
infer successful live resource claiming. Only the service-only complete
crafting chain has passed. Keep the full live profession gate pending.

Evidence: `docs/testing/profession-v153-local-validation-2026-09-21.md`.
Original staged scope and test plan:
`docs/testing/profession-leatherworking-enchanting-pending-verification-2026-09-21.md`.

## Remaining v1.53 acceptance boundary

1. Create any new reusable live test fixture through **GitHub only**;
   fast-forward pull it into the clean Windows integration worktree.
2. Run a disposable real Base Play-mode profession station/RemoteEvent
   test: too-far rejection, near-station routing, rapid same-player
   requests, independent players, hide-cache one-time claim, and real
   Leatherworking/Enchanting crafting through final equipment.
3. Verify disconnect/retry releases the lock and investigate unrelated
   Base composition's Dungeon-only autorun warnings.
4. Only after the required physical cases pass promote v1.53 from
   partial verification to locally accepted. Published TEST/PROD and
   real-player DataStore acceptance remain separate gates.

## Animal-only Skinning foundation — new backend increment, NOT accepted

A server-side positive species allowlist and explicit animal-factory tag
now restrict corpse Skinning to registered Beast creatures only.
Unregistered monsters, Marauders, humanoids and bosses cannot become
skinnable just because they die. The creature must also have been
defeated and looted on the server, and can grant hide just once to a
nearby living player using the existing profession/inventory mutation
path. The Dungeon cleanup path retains only eligible animal corpses
briefly after encounter rewards; unrelated enemy cleanup is unchanged.

Example forest-wolf/wild-boar/cave-bear identities are *future factory
IDs*, not existing live game creatures. The Base RawHideCache is still a
temporary independent non-monster resource for crafting QA; an
authored/server-registered animal encounter is not yet present.
Do not treat this feature as physically implemented end-to-end.

The new `SkinningEligibilityTest` and `CorpseSkinningRuntimeTest`,
plus an extended Dungeon enemy cleanup test, are staged. Four local
Rojo builds succeeded at
`8655c7e19bc97a9b9c803fc011e2e5a3080c47f3`, but **the new
Studio suites and actual corpse Play test have not run**: the local
Studio MCP discovery returned an unavailable-connection error and
the Codex Studio delegate reported its usage limit.

Keep v1.53 local acceptance pending until those tests and the
previously outstanding Base hide-cache prompt, full
Leatherworking/Enchanting live crafting, duplicate-request,
multiplayer and disconnect/retry checks are complete.

Evidence and exact acceptance list:
`docs/testing/animal-only-corpse-skinning-pending-studio-2026-09-21.md`.

## Remaining profession backend after this staged increment

Even if tomorrow's tests pass, the profession backend will still need
later content/acceptance work rather than being considered the whole
MMORPG crafting system:

- authored/real Skinning from creatures rather than the hide-cache
  placeholder;
- final interactive minigames rather than foundation server auto-success;
- broader recipe/blueprint catalogue and item tiers;
- balancing profession XP/material quantities;
- market/economy integration of crafted materials/equipment;
- real-user DataStore migration/cloud TEST acceptance.

After the profession interaction checkpoint, backend priority should move
to the next large MMORPG milestone rather than continuing to expand
placeholder crafting indefinitely: raid/weekly-world-boss lifecycle,
then guild/castle competition and full progression/economy integration.

## Operational constraint

All source, test-fixture and documentation edits must be made through
GitHub; Remote Desktop is for read-only inspection, safe fast-forward
pulling and local build/Studio execution only. The above verification
performed no cloud publish, real-player DataStore migration,
force-push or merge into `main`.
