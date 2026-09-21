# DungeonMMO Roadmap v1.53 — Leatherworking / Enchanting staged

**Date:** 21 September 2026  
**Status:** Four local builds and Studio deterministic suites PASS; **live profession station acceptance pending**  
**Branch:** `wip/phase-4-test-hud-integration-v1`

This supplement follows the accepted v1.52 Event-variation /
Blacksmithing-Alchemy checkpoint. The work was first staged in GitHub
while the desktop was offline; local verification has now resumed. The
physical profession station gate is still pending. The historical
canonical `DungeonMMO_Roadmap_v1_47.docx` is unchanged.

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
