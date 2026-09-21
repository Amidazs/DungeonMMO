# v1.53 profession and opt-in wolf — local Studio acceptance receipt

**Date:** 21 September 2026
**Branch:** `wip/phase-4-test-hud-integration-v1`
**Latest tested source/fixture commit:** `b3ce809d258ecfddcbc4077a80ff14ea3a67d826`
**Status:** The opt-in wolf dungeon route and cross-profession live
crafting are locally verified. Remaining release gates are listed below.

## Source and rollout boundaries

A registered `ForestWolf` enemy factory and `Wolf` combat archetype
reuse the existing combat skeleton and temporary animal-like silhouette.
The factory explicitly marks only its own server-authored wolf as a
`forest_wolf` Beast eligible for corpse Skinning. Existing Marauder
factories, combat packs and bosses remain unchanged and unskinnable.

**No default pack includes wolves.** The dungeon Play fixture overrides
*Temple StandardRoom1 only in its disposable loaded DataModel* to
spawn two wolves through the existing CombatPack executor. Animal
meshes, independent animal AI/rewards and release-balanced encounters
have not been authored. The wolf borrows standard enemy XP/gold tuning
but deliberately omits a bogus BestiaryCreatureId.

All source, test and documentation edits were authored through GitHub.
Remote Desktop was used only for clean fast-forward pulls, Rojo builds,
Studio test execution and log inspection. Local places are unpublished
and use Studio's in-memory profiles. No cloud publish, real-player
DataStore mutation, force-push or main merge occurred.

## Evidence and observed outcomes

All local test outputs are under
`%TEMP%\DungeonMMO_wolf_validation\` unless otherwise specified.

| Validation | Evidence | Observed result |
| --- | --- | --- |
| Four Rojo compositions after wolf code | local build receipt | 4/4 PASS |
| Wolf factory registration, identity and Marauder isolation | `final_wolf_factory.log` | 10 assertions PASS |
| Existing dungeon corpse cleanup | `final_dungeon_cleanup.log` | 11 assertions PASS |
| Wider Dungeon backend | `final_general_backend.log` | 30/30 suites PASS |
| Focused professions with new wolf code | `final_profession_backend.log` | 12/12 suites PASS |
| Two-user atomic corpse contest after re-building updated sources | `two_user_rebuilt_base.log`, `two_user_rebuilt_default.log` | 13/13 focused suites each PASS; 9 two-user assertions each |
| Real Temple wolf encounter and client hide claim | `wolf_dungeon_play_v4.log` | `ENCOUNTER_LOOT_CORPSE_PASS`, `CLIENT_ONCE_ONLY_HIDE_PASS`, `VERIFIED_PLAY_MODE_PASS` |
| Real Base material-backed multi-profession crafting | `base_material_chain_burst_isolated.log` | twelve real client crafts, final `warded_leatherbound_gloves`, `MATERIAL_CHAIN_PASS` and `VERIFIED_PLAY_MODE_PASS` |
| Same-client rapid craft pair with only two iron ore | `base_material_chain_burst_isolated.log` | exactly one iron bar, no leftover ore, one success and one `MissingMaterials` rejection, `RAPID_DUPLICATE_PASS` |
| Two *real* Studio client accounts sharing a Base server | `two_client_professions_play_v1.log` and Studio child server log `0.739.0.7390687_20260921T101407Z_Studio_2A3B3_last.log` | `INDEPENDENT_CRAFT_PASS`, `CONTESTED_CORPSE_PASS`, `PEER_DISCONNECT_PASS`, parent `VERIFIED_MULTIPLAYER_PASS` |

The genuine Dungeon Play-mode fixture entered the physical Room1
trigger, spawned two wolves through the production encounter executor,
assisted their defeat by setting their Humanoid health to zero, and
observed the ordinary encounter reward and room-clear path. After
normal enemy retirement retained the looted animal corpse, a real
client triggered its Skinning prompt, received exactly one raw hide
and found the same corpse unavailable on retry.

**This proves the encounter/reward/corpse/client path, not unassisted
player combat, animal animation quality or animal combat balancing.**

The actual Base client/server chain made four iron bars, tempering oil,
cured leather, leatherbound gloves, forging flux, warding essence,
warding rune and a final pair of warded leatherbound gloves through the
original per-recipe station-checked RemoteEvent. Every intermediate
recipe consumed real in-memory ingredients. The client attempted to
supply a forged success argument; the server did not accept it as a
minigame outcome. Repeating the final enchantment without its inputs
returned `MissingMaterials`.

The first rapid-request fixture incorrectly assumed a fresh empty
inventory. The Base Studio starter kit contained extra iron ore, so
both requests succeeded legitimately; **that run failed its fixture
assertion**. A GitHub-only test correction first removed the starter
ore in its disposable in-memory account and seeded exactly two. The
re-run then recorded `success=1 rejected=1 bars=1 ore=0`, with the
second result `MissingMaterials`. This verifies no double grant
when only one recipe's ingredients exist; it does not independently
prove the requests overlapped *inside* the server guard.

The initial newly added two-user runner hung because the local
Base/Dungeon builds predated its new GitHub source file, and
`WaitForChild` could not locate it. After both compositions were
rebuilt, focused runner results were 13/13 in each. The two-user
atomic service test confirms one hide across two independently loaded
in-memory profiles in a contested claim.

The real two-client Studio fixture independently crafted one iron bar
per profile, then contested a single shared server-created wolf corpse:
total hide increase was exactly one, with exactly one successful
server grant. One Studio client then left, and the other stayed
connected. **This is a distinct-account peer-disconnect test**, not
same-account reconnect or an in-flight craft interruption test.

## Remaining v1.53/release gates

- Real same-account reconnect after disconnect or server handoff,
  including save/reload, an in-flight request-lock interruption and
  retry from the *same* player. An in-memory save/reload service test
  already exists; the new live Base chain called profile save, not a
  true cross-server DataStore round-trip.
- Final animal art and dedicated behaviour, actual live pack placement,
  species-specific combat and reward balancing, and unassisted fights.
  Wolf availability is intentionally opt-in only until those are done.
- Published TEST/PROD verification, Roblox server/session boundaries
  and real-player DataStore migration remain untested and unauthorized.

**Local backend functional acceptance:** the tested profession
crafting, server-only Skinning restrictions, wolf encounter hook and
two-client independent/contested interactions pass. Do not mark the
above deployment, persistence or asset gates as complete.
