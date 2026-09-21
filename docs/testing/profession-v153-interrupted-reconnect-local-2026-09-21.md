# v1.53 craft interruption and same-account recovery — local validation

**Date:** 21 September 2026  
**Branch:** `wip/phase-4-test-hud-integration-v1`  
**Game-code protection:** `2d1c774828c4f9706d0018ce1f00652db4e45094`  
**Latest tested fixture:** `7f2827442e74418798949768de5aff4701eeddb3`  
**Status:** Disconnect-during-preparation and same-UserId
in-memory recovery PASS locally; true same-account network
reconnect/cross-server DataStore verification remains open.

## Actual server change

`ProfessionRuntime.new_craft_request_guard()` now gives every
successful request a unique ticket. `PlayerRemoving` invalidates
the departing account's request. The old request checks both ticket
ownership and exact player-instance membership **after the
potentially yielding preparation and before committing a craft**.
An old completion cannot release a new request's guard ticket, and
a disconnected client's old request cannot mutate a reloaded
same-UserId character after resuming.

Normal successful crafting still uses the same authoritative
`ProfessionService` preparation, foundation outcome, atomic
inventory/equipment mutation, and station-distance checks.
The RemoteEvent still accepts no client-created minigame success.

## Verified unpublished Studio runs

Outputs under
`%TEMP%\DungeonMMO_v153_reconnect_validation\` except where noted.

| Run | Evidence | Observed result |
| --- | --- | --- |
| Four Rojo compositions after guard code | local terminal build | 4/4 PASS |
| Focused profession suites in Base | `reconnect_fixed_base.log` | 14/14 PASS; craft guard 21 assertions; reconnect lifecycle 20 assertions |
| Focused profession suites in Dungeon | `reconnect_fixed_default.log` | 14/14 PASS; same guard and lifecycle assertions |
| Full material-backed Base client crafting after guard change | `final_base_material_chain.log` | `MATERIAL_CHAIN_PASS`, `RAPID_DUPLICATE_PASS`, `VERIFIED_PLAY_MODE_PASS` |
| Opt-in Dungeon wolf reward → looted corpse → client Skinning | `final_dungeon_wolf_encounter.log` | `ENCOUNTER_LOOT_CORPSE_PASS`, `CLIENT_ONCE_ONLY_HIDE_PASS`, `VERIFIED_PLAY_MODE_PASS` |
| Broad Dungeon gameplay regression | `final_dungeon_backend_matrix.log` | 30/30 PASS |
| Real two-client paused-craft disconnect | `live_paused_disconnect_module.log` and child Studio log `0.739.0.7390687_20260921T103419Z_Studio_0C28A_last.log` | `INDEPENDENT_CRAFT_PASS`, `CONTESTED_CORPSE_PASS`, `INTERRUPTED_DISCONNECT_PASS`, parent `VERIFIED_MULTIPLAYER_PASS` |

The 20-assertion lifecycle suite uses one persistent in-memory
profile adapter and the **same UserId**. It deliberately pauses an
old request between preparation and completion, saves/releases
the account, reloads that same UserId, resumes the old request and
verifies it cannot grant output or release the newly acquired ticket.
The reconnected session then crafts once, saves, releases and reloads
through a fresh profile-service object; exactly two ore are consumed
and exactly one bar remains. This tests same-account lifecycle
semantics but does **not** perform a new Roblox network login.

The genuine Studio multiplayer fixture paused a live craft
inside the server after valid preparation, made that actual client
leave, waited for profile release, reloaded the same UserId from
the **test server's in-memory adapter**, then resumed the stale
request. The reloaded profile retained the original two ore, had
no extra iron bar, and the other real client remained connected.
Studio then admitted a distinct replacement account. It did
**not** reconnect the original Roblox account or travel between
servers. The use of a controllable pause is a disposable test-only
injection, not a production crafting delay.

## Failed attempts retained for audit

The first new lifecycle test failed because its assertion checked
the public RemoteEvent field `item_id` against a direct
ProfessionService result, which actually uses `output_item_id`.
The assertion was corrected in GitHub, then both 14-suite
runners passed.

The first attempt to remove an old test-only `_G` bridge used
a BindableFunction to return a service table. That interface
serialized the returned table without its service metatable,
causing a test-driver method error. The GitHub fixture was then
changed to use a disposable shared ModuleScript instead, and
the final genuine two-client fixture passed. No production
server code uses that fixture's test probe.

## Remaining release boundaries

- Actual **same-account network reconnect**, handoff to another
  Roblox server, and same-player retry on a new server have
  **not** been exercised. The Studio multiplayer API creates
  distinct test account IDs when adding a replacement player.
- No published TEST/PROD place, real-user DataStore migration,
  or cross-server persistence test was performed.
- Wolf art and dedicated animal combat AI/reward tuning remain
  placeholder/inactive in normal dungeon packs.
- The current foundation auto-success outcome is server-generated;
  interactive profession-specific minigames are future gameplay
  work, not part of this acceptance claim.

All source, test and documentation edits were made through GitHub.
The Windows integration worktree received only clean fast-forward
pulls, builds, actual Studio execution and read-only log inspection.
No Roblox cloud publication, player DataStore mutation, force-push
or merge into `main` occurred.
