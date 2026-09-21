# Animal-only corpse Skinning — GitHub integration, Studio pending

Date: 21 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
GitHub source and local Rojo build: `c6af7cf080001f199e7383ef8cb4c63198e7d312`
Status: **backend implemented and four Rojo builds pass; Studio gameplay
tests for this increment have NOT been executed.**

## Behavior staged

Skinning is not enabled for every monster. The existing gathering,
inventory and profession progression services remain authoritative,
with an additional explicit server-side creature eligibility gate:

- The creature must be a server-tagged `DungeonMMOSkinnableBeast`.
- Its server-assigned family must be `Beast` **and** its species must be
  on the positive animal allowlist (`forest_wolf`, `wild_boar`,
  `cave_bear` are future example species IDs, not existing encounters).
- The Humanoid must be dead, server-owned loot complete, and this
  exact corpse not already skinned.
- A living, out-of-range or dead player cannot skin a corpse. The
  server sets a per-corpse claim before granting items through the
  existing `ProfessionService:gather` path. A failed grant releases
  the claim; a successful grant cannot be repeated.

The existing Marauder/training and boss factories were not tagged as
beasts. A model carrying an unlisted Marauder identity does not become
eligible even if it is given the Beast family and tag. No client can
choose a species, grant a resource or pass a minigame success outcome
through this new skinning path.

Only explicitly eligible beast corpses are retained by
`DungeonEnemyCleanup.retire` after the existing successful enemy
reward/clear callback. Their visuals remain available for a short
45-second skinning window, combat collisions/effects are disabled,
and the existing retirement path for other enemies retains its
0.15-second default cleanup. The beast loot-complete marker is
issued on the server *after* the successful enemy reward boundary.
The `CorpseSkinningRuntime` creates a skinning ProximityPrompt only
when a registered animal corpse is defeated and looted.

`Base.RawHideCache` is still an **explicit temporary non-monster
material cache**, not an enemy/corpse skinning entitlement. It is
retained for temporary material QA, not considered final Skinning
gameplay. No animal enemy factory or authored animal rig is in this
increment, and none of the current live enemies is automatically
skinnable. Animal factories must populate the server attributes and
apply the beast tag **after** fully constructing the model. Any future
loot flow must set the server loot-complete marker at the proper point.

## Static and local build validation

The source was authored and committed through GitHub; the authorized
Windows integration worktree was clean and safely fast-forward pulled.
The four local Rojo compositions built successfully at the above
commit: Dungeon, Base, published-style Dungeon and published-style
Base. **Rojo assembly is not Luau execution or Play-mode acceptance.**

The focused profession runner now includes
`SkinningEligibilityTest` and `CorpseSkinningRuntimeTest` alongside
the previous ten suites; the Dungeon cleanup tests now verify that
explicit animal corpses stay visible/loot-complete and tagged Marauders
are not retained. These tests are staged in GitHub but their new
assertions and overall focused suite **have not yet run in Studio**.

The direct local Studio MCP discovery attempt returned
`Unable to reach Roblox Studio right now` despite Studio processes
being open. The delegated Codex Studio test attempt also stopped at
its usage limit. Neither issue constitutes a failing or passing
gameplay test, and no test outcomes have been inferred.

## Remaining acceptance and future creature content

1. Restore the Roblox Studio MCP connection and run the existing
   versioned focused profession runner in disposable unpublished
   Dungeon and Base places. Run the Dungeon enemy cleanup focused test
   and broad regressions after the modified cleanup behavior.
2. Re-run the existing GitHub-authored `profession_base_live_requests`
   fixture, recording client PromptShown/position diagnostics. Its
   previous RawHideCache simulated hold timed out; distinguish
   unsupported scripted prompt input from real server claim failure.
3. Run a genuine server-created wolf/boar/bear test enemy through the
   real damage → death → loot/cleanup → client prompt → once-only
   hide grant path, including concurrent players and out-of-range
   requests; confirm Marauders and bosses never expose the prompt.
4. Verify material-backed Leatherworking → Enchanting crafting,
   same-player duplicate requests, multi-player independence,
   disconnect/retry and persistence in real Studio Play.
5. Only add authored animal enemies/factories and balance hide drops
   in a subsequent, explicitly tested content increment. Keep cloud
   TEST/PROD, real-user DataStore and main integration separate.

No source or documentation changes were made via Remote Desktop,
and no Roblox publish, real-player DataStore mutation, main merge
or force-push was performed.
