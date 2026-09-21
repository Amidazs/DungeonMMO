# Animal-only Skinning — local Studio verification

**Date:** 21 September 2026
**Branch:** `wip/phase-4-test-hud-integration-v1`
**Game-code build:** `8655c7e19bc97a9b9c803fc011e2e5a3080c47f3`
**Latest tested fixture commit:** `291e0f5ce7cdc99275a1e285bcfa5206eec037a8`
**Status:** Animal-only backend, simulated animal-corpse Play interaction
and temporary Base hide-cache interaction **PASS locally**. Full
production animal encounters, material-backed live crafting and
multiplayer/disconnect acceptance remain pending.

## Unpublished Roblox Studio evidence

After a direct Studio MCP invocation continued to report no reachable
Studio, the existing GitHub-authored test scripts were run unchanged
using Roblox Studio's supported `--task RunScript` command on
disposable unpublished local Base/Dungeon `.rbxlx` builds. This is
**actual Studio execution**, not a static code review; the Play
fixtures invoked `StudioTestService:ExecutePlayModeAsync` and received
their `VERIFIED_PLAY_MODE_PASS` result. No claim of a successful MCP
connection is made.

All output files below are under
`%TEMP%\DungeonMMO_animal_skinning_validation\`.

| Test | Evidence file | Observed result |
| --- | --- | --- |
| Four Rojo project compositions | terminal build receipt | 4/4 PASS |
| Base focused profession | `base_profession_cli.log` | 12/12 suites PASS; 363 assertions |
| Dungeon focused profession | `dungeon_profession.log` | 12/12 suites PASS; 363 assertions |
| Animal eligibility | each profession log | 42 assertions PASS |
| Server corpse grant/prompt | each profession log | 16 assertions PASS |
| Dungeon enemy cleanup | `dungeon_enemy_cleanup.log` | 11 assertions PASS |
| Dungeon broad gameplay matrix | `dungeon_backend_matrix.log` | 30/30 suites PASS |
| Actual Base live hide cache | `base_live_profession_depletion_cli.log` | `HIDE_CLAIM_ONCE_PASS` and `VERIFIED_PLAY_MODE_PASS` |
| Actual Base live animal corpse | `base_animal_corpse_live_cli.log` | `CLIENT_HIDE_GRANT_PASS`, `ONCE_ONLY_CORPSE_PASS`, `VERIFIED_PLAY_MODE_PASS` |

The focused suites test default-deny species and creature-family
eligibility, dead/looted requirement, server distance, invalid player
and duplicate protection, material/progression migrations, recipes and
inventory persistence. The Dungeon cleanup test proves an explicitly
registered animal corpse remains visible with combat collision disabled
and its loot-complete flag set after retirement, while a tagged Marauder
is not treated as a skinnable beast.

## What the live client/server tests actually established

The Base profession fixture sent real client craft requests while far
from and near to the independent Leatherworking and Enchanting
stations. Far requests returned `NotAtRequiredStation`, while nearby
requests reached the service and returned `MissingMaterials`.

For `Base.RawHideCache`, the actual client ProximityPrompt was visible
and enabled at distance five. Its first held activation resulted in a
server-owned `ProfessionActionResult` with `action=Gather`,
`ok=true` and `node=Base.RawHideCache`. The client's authoritative
node presentation then disabled the prompt; attempting to interact
again produced `CLIENT_NODE_DEPLETED` and no new grant.
The previous fixture's timeout was caused by expecting a second
Gather result **after the client prompt had correctly been disabled**.
The corrected versioned fixture passed. The cache is still a temporary
non-monster resource, not a skinnable creature.

The new disposable animal test created an explicit server-tagged
`forest_wolf` with `CreatureFamily=Beast` in a local unpublished Base
Play session. It did not expose a skinning prompt while alive or before
server loot completion. After death and loot completion, the actual
client triggered the generated `BeastSkinningPrompt`; the existing
server profession runtime granted exactly one `raw_hide`. The corpse
became claimed and disabled its prompt. A second client attempt on
the same corpse was unavailable. No authored animal model or live
enemy factory was installed by this test.

## Acceptance boundary

**Locally verified:** default-deny species policy, server beast corpse
authorization, one-time hide grant, temporary client prompt and
server-authoritative Base station distance. Existing Marauders,
humanoids and unlisted enemies have not been opted into Skinning.

**Not yet accepted:** a real authored animal enemy and its actual
dungeon combat → encounter rewards → retained corpse → skinning Play
sequence; a contested two-player corpse claim; material-backed,
client-driven Leatherworking → Enchanting completion; multi-player
craft-request independence; disconnect/retry; cloud TEST/PROD or
real-player DataStore migration.

The local worktree was fast-forward pulled from GitHub before testing.
All script/fixture and document edits were through the GitHub tool
only. No real-user DataStore changes, Roblox cloud publication,
force-push or merge into `main` were performed.
