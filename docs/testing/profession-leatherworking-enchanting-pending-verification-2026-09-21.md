# Profession backend — Leatherworking / Enchanting staged for verification

Date: 21 September 2026  
Branch: `wip/phase-4-test-hud-integration-v1`  
Verification state: **implemented in GitHub; local Rojo/Studio verification deliberately deferred until the authorized Windows desktop is online.**

## Scope staged in GitHub

This continuation builds on the already accepted Blacksmithing/Alchemy
cross-profession foundation. It does **not** create a second crafting
system.

### Profession definitions and persistence

The existing shared profession progression framework now includes:

- `Skinning` as a gathering profession paired to Leatherworking.
- `Leatherworking` as a creation profession with
  `LeatherworkingStitching`.
- `Enchanting` as a creation profession with
  `EnchantingImbuing`.

Fresh profiles contain Level 1 / 0 XP state for all three. Existing
profiles are still sanitized through `ProfessionDefinitions.order()`,
so missing new profession states are added without replacing existing
Mining, Blacksmithing, Herbalism or Alchemy progress. Migration tests
have been extended to assert this contract.

### Material and recipe chain

The current staged chain is:

1. Skinning supplies `raw_hide`.
2. Alchemy supplies `tempering_oil`.
3. Leatherworking combines raw hide + tempering oil into
   `cured_leather`.
4. Leatherworking combines cured leather + a Blacksmithing
   `iron_bar` into `leatherbound_gloves`.
5. Alchemy turns its existing `forging_flux` path into
   `warding_essence`.
6. Enchanting combines warding essence + an iron bar into a
   `warding_rune`.
7. Enchanting combines Leatherworking's gloves + the warding rune +
   Alchemy's forging flux into `warded_leatherbound_gloves`.

The final equipment therefore depends on **Skinning, Leatherworking,
Mining/Blacksmithing, Herbalism/Alchemy and Enchanting** through the
same InventoryService / ProfessionService transaction path.

The Base runtime has a server-claimed `Base.RawHideCache` placeholder
for Skinning until creature harvesting exists. Leatherworking and
Enchanting use distinct temporary station parts offset from the accepted
Blacksmithing and Alchemy Base anchors; no authored map/model is required
for backend testing.

## Craft-request hardening staged

The Base `ProfessionCraftRequest` RemoteEvent continues to accept only
`recipe_id`; clients do **not** supply a success result or minigame
outcome. The server remains responsible for creating the foundation
success result passed into `ProfessionService:complete_craft`.

A new per-player craft request guard prevents overlapping RemoteEvent
requests from one user entering prepare/complete simultaneously. The
guard is released on success, rejection, caught server error and
PlayerRemoving. Different players retain independent craft lanes.
The existing server-side station distance check remains mandatory before
the guard is acquired.

## New/extended tests staged

The GitHub source now contains or extends:

- `ProfessionDefinitionContractTest`: all seven professions,
  new items, new recipes, Leatherworking/Enchanting minigame IDs,
  station recipe ordering and base-class equipment compatibility.
- `ProfessionProfileMigrationTest`: legacy/malformed profiles gain
  Skinning, Leatherworking and Enchanting safely while older state is
  preserved/sanitized.
- `ProfessionLeatherEnchantingDependencyTest`: full real-service,
  in-memory chain from gathered ore/herbs/hide through Leatherworking
  and Enchanting; progression to level 2; equipped ingredient rejection;
  wrong minigame rejection; exactly-once consumption; duplicate craft
  denial; save/reload of final equipment and profession XP.
- `ProfessionCraftRequestGuardTest`: authoritative station-distance
  rejection and per-player overlapping-request guard/retry semantics.
- `profession_cross_dependency_tests.luau`: updated focused runner
  includes the new profession dependency, runtime rules and craft guard.

## Important: not accepted yet

No new PASS counts are claimed in this document. The desktop is offline,
so **none of the staged commits after v1.52 have been pulled, Rojo-built
or run in Studio yet**.

Tomorrow's first acceptance sequence should be:

1. confirm Windows worktree is clean and still at the accepted v1.52
   checkpoint;
2. fast-forward pull this GitHub branch;
3. build Dungeon, Base, published-style Dungeon and published-style Base;
4. run the focused profession suite in both Dungeon and Base builds;
5. run the broad gameplay backend matrix to catch cross-system regressions;
6. run a real Base Play-mode station test covering near/far request,
   rapid duplicate requests, Skinning gather claim, Leatherworking craft,
   Enchanting craft and disconnect/retry;
7. only after those are green, convert the roadmap/test-matrix status
   below from **pending verification** to accepted.

No TEST/PROD publish, real player DataStore change, force-push, merge or
Remote Desktop action is part of this staged checkpoint.
