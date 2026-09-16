# Phase 2 Profession Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the Mining + Blacksmithing and Herbalism + Alchemy Phase 2 supply chains on top of the accepted Base/Temple environment integration.

**Architecture:** Extend the existing profile schema and RuntimeServices composition with one server-authoritative ProfessionService. A ProfessionRuntime module attaches gathering/crafting interaction to accepted semantic anchors in Base and Temple; existing ProfileService/InventoryService remain the sole persistence and item mutation boundaries. One Core client UI displays station recipes and server-authoritative state.

**Tech Stack:** Roblox Luau, Rojo, existing ProfileService/InventoryService/EquipmentService, semantic environment anchors, ProximityPrompt, RemoteEvent.

**Spec:** `docs/superpowers/specs/2026-09-14-phase-2-profession-foundation-design.md`

## Global Constraints

- Baseline is `c7fe89ebda3c97634c97e89ad12e52ec23983ae9`.
- Do not infer a Phase 2D number.
- Preserve Fighter/Mage/Ranger, Equipment, run-lock, progression, persistence and Base/Temple contracts.
- All value-bearing gathering/crafting results are server-authoritative.
- No PROD, Robux, monetisation or art-worktree action.
- Every creation profession introduced has a deliberate gathering route.
- New behaviour follows RED -> GREEN tests.

---

### Task 1: Persist profession progression

**Files:**
- Modify: `src/ReplicatedStorage/Core/Shared/ProfileSchema.luau`
- Create: `src/ReplicatedStorage/Core/Shared/ProfessionDefinitions.luau`
- Modify: `src/ServerScriptService/Core/Services/ProfileMigration.luau`
- Create: `src/ServerScriptService/Core/Tests/ProfessionProfileMigrationTest.server.luau`

**Interfaces:**
- Produces: `ProfessionDefinitions.get(id)`, `ProfessionDefinitions.level_from_xp(xp)`, `ProfessionDefinitions.xp_to_next(level)`.
- Produces schema-v6 `character.Professions[profession_id] = {Level, XP}`.

- [ ] Write the migration test first for fresh profile, v5 migration, malformed state sanitization and preserved identity/equipment/inventory.
- [ ] Run Studio test and verify RED because schema v6/profession state is absent.
- [ ] Add the four definitions and XP thresholds.
- [ ] Bump ProfileSchema to v6 and add default profession states.
- [ ] Sanitize profession states during migration using server definitions.
- [ ] Run the focused migration test GREEN.

### Task 2: Define profession materials, equipment and recipes

**Files:**
- Modify: `src/ReplicatedStorage/Core/Shared/ItemDefinitions.luau`
- Create: `src/ReplicatedStorage/Core/Shared/ProfessionRecipes.luau`
- Create: `src/ServerScriptService/Core/Tests/ProfessionDefinitionContractTest.server.luau`

**Interfaces:**
- Produces: `ProfessionRecipes.get(recipe_id)`, `ProfessionRecipes.for_station(station_id)`.
- Recipes expose `Id`, `Name`, `ProfessionId`, `StationId`, `RequiredLevel`, `Inputs`, `Output`, `XP`.

- [ ] Write contract tests for all four material IDs, both glove items, four recipes and the basic/cross-profession dependency rule.
- [ ] Verify RED.
- [ ] Add item definitions and recipe catalogue.
- [ ] Verify GREEN.

### Task 3: Add atomic profession service

**Files:**
- Create: `src/ServerScriptService/Core/Services/ProfessionService.luau`
- Modify: `src/ServerScriptService/Core/Services/RuntimeServices.luau`
- Create: `src/ServerScriptService/Core/Tests/ProfessionServiceTest.server.luau`

**Interfaces:**
- `ProfessionService.new(profile_service, inventory_service)`.
- `:build_snapshot(user_id)`.
- `:gather(user_id, node_definition)`.
- `:craft(user_id, recipe_id)`.

- [ ] Test missing profile, unknown recipe, missing ingredients, wrong level, atomic failure, gather XP, level-up and cross-profession recipe.
- [ ] Verify RED.
- [ ] Implement one-transaction input/output mutation and profession XP progression.
- [ ] Register ProfessionService in RuntimeServices.
- [ ] Verify GREEN.

### Task 4: Add profession world/runtime interactions

**Files:**
- Create: `src/ServerScriptService/Core/Services/ProfessionRuntime.luau`
- Modify: `src/ReplicatedStorage/Core/Remotes.model.json`
- Modify: `src/ServerScriptService/Base/BaseRuntime.server.luau`
- Modify: `src/ServerScriptService/Dungeon/DungeonRuntime.server.luau`
- Create: `src/ServerScriptService/Core/Tests/ProfessionRuntimeRulesTest.server.luau`

**Interfaces:**
- `ProfessionRuntime.attach({context, environment, professions, remotes, players})`.
- Adds Base station prompts and Base/Temple gather nodes.
- Remotes: `ProfessionSnapshot`, `ProfessionStationOpen`, `ProfessionCraftRequest`, `ProfessionActionResult`.

- [ ] Test stable node definitions, per-player cooldown and station/proximity authorization helpers first.
- [ ] Verify RED.
- [ ] Add remotes and runtime module.
- [ ] Bind BaseRuntime and DungeonRuntime to their already-created RuntimeServices and environment adapters.
- [ ] Verify focused rules GREEN.

### Task 5: Add functional profession presentation

**Files:**
- Create: `src/StarterPlayerScripts/Core/ProfessionUi.client.luau`

**Interfaces:**
- Receives profession snapshots/open/result events.
- Sends only recipe ID craft intent.

- [ ] Implement a compact station panel with level/XP, recipes, ingredients, lock state and Craft button.
- [ ] Add compact gather/craft toast handling.
- [ ] Keep final art/VFX/audio explicitly deferred.

### Task 6: Permanently fix Candidate Portal_02 placement

**Files:**
- Create: `src/ServerScriptService/Core/Environment/CandidateAnchorPlacement.luau`
- Modify: `src/ServerScriptService/Base/BaseCandidateAnchorProfile.luau`
- Modify: `src/ServerScriptService/Base/BaseEnvironmentBootstrap.server.luau`
- Create: `src/ServerScriptService/Core/Tests/CandidateAnchorPlacementTest.server.luau`

**Interfaces:**
- `CandidateAnchorPlacement.resolve(landmark, selector) -> CFrame?`.
- Selector may use `UseBounds=true`, `HeightFraction=0.55`, plus optional `Offset`.

- [ ] Write a model-with-bad-pivot regression test proving bounds placement differs from pivot placement.
- [ ] Verify RED.
- [ ] Implement bounds-aware placement and set Base.TemplePortal Portal selectors to bounds placement.
- [ ] Verify GREEN.

### Task 7: Build/regression candidate and visual gate

**Files:**
- Update: `docs/ai/CURRENT_STATE.md`
- Update: `docs/ai/HANDOFF.md`
- Update: `docs/ai/TEST_MATRIX.md`

- [ ] Run `git diff --check`.
- [ ] Build fresh Base, Dungeon, published Base and published Dungeon TEMP `.rbxl` compositions.
- [ ] Run Base Studio and capture profession/migration/service tests plus Fighter/Mage/Ranger regressions.
- [ ] Run Dungeon Studio and capture profession/runtime plus existing dungeon regressions.
- [ ] Only then ask the project owner for visual/runtime acceptance of node placement, station UI and the gather -> craft -> equip -> Temple gather -> return persistence loop.
- [ ] Do not merge or publish without a separate explicit gate.

### Task 8: Replace the truncated inventory preview

**Files:**
- Create: `src/ReplicatedStorage/Core/Shared/InventoryPresentation.luau`
- Create: `src/StarterPlayerScripts/Core/InventoryPanel.client.luau`
- Modify: `src/StarterPlayerScripts/Core/ProfileHud.client.luau`
- Create: `src/ServerScriptService/Core/Tests/InventoryPresentationTest.server.luau`

**Interfaces:**
- `InventoryPresentation.build(entries) -> rows` aggregates display quantities without mutating persistent inventory.
- `InventoryPanel.client.luau` consumes `InventorySnapshot` and requests refresh through the existing `ProfileSnapshot` request path.

- [ ] Write the failing presentation test proving seven item types are not truncated to five and duplicate Iron Ore stacks aggregate for display.
- [ ] Verify RED against the existing five-row Profile HUD presentation.
- [ ] Add the shared presentation helper and full scrolling Inventory panel.
- [ ] Remove the obsolete five-row inventory preview from Profile HUD.
- [ ] Verify the focused presentation test GREEN and visually confirm profession outputs appear immediately after gather/craft.

### Task 9: Add the future crafting-minigame boundary

**Files:**
- Modify: `src/ReplicatedStorage/Core/Shared/ProfessionDefinitions.luau`
- Modify: `src/ServerScriptService/Core/Services/ProfessionService.luau`
- Modify: `src/ServerScriptService/Core/Services/ProfessionRuntime.luau`
- Modify: `src/ServerScriptService/Core/Tests/ProfessionDefinitionContractTest.server.luau`
- Modify: `src/ServerScriptService/Core/Tests/ProfessionServiceTest.server.luau`

**Interfaces:**
- Creation definitions expose `CraftingMinigameId`.
- `ProfessionService:prepare_craft(user_id, recipe_id)` validates without mutation and returns the required minigame identity.
- `ProfessionService:complete_craft(user_id, recipe_id, outcome)` revalidates and atomically commits only a successful server-owned outcome.
- `ProfessionService:craft(...)` remains a foundation compatibility path and internally uses the same prepare/complete boundary with an explicit server-owned auto-success outcome.

- [ ] Extend RED contract/service tests for declared minigame IDs, prepare-without-consume, failed outcome preserving materials and minigame mismatch rejection.
- [ ] Add Blacksmithing/Alchemy minigame identities.
- [ ] Split crafting into prepare and completion phases while preserving transactional ProfileService mutation.
- [ ] Route the foundation runtime through prepare -> server auto-success -> complete.
- [ ] Verify focused tests GREEN. Actual minigame mechanics remain a later approved design gate.

### Task 10: Personal single-use dungeon resources and explicit profession-XP presentation

**Files:**
- Modify: `src/ServerScriptService/Core/Services/DungeonSessionService.luau`
- Modify: `src/ServerScriptService/Core/Services/ProfessionRuntime.luau`
- Modify: `src/ServerScriptService/Dungeon/DungeonRuntime.server.luau`
- Modify: `src/StarterPlayerScripts/Core/ProfessionUi.client.luau`
- Create: `src/StarterPlayerScripts/Core/ProfessionNodePresentation.client.luau`
- Modify: `src/ServerScriptService/Core/Tests/ProfessionRuntimeRulesTest.server.luau`
- Create: `src/ServerScriptService/Core/Tests/ProfessionResourceClaimTest.server.luau`

**Interfaces:**
- `DungeonSessionService:claim_resource_node_once(session_id, user_id, node_id)` atomically owns a personal run claim.
- `DungeonSessionService:get_claimed_resource_nodes(session_id, user_id)` reconstructs depletion after reconnect.
- `DungeonSessionService:release_resource_node_claim(...)` rolls back a provisional claim when the authoritative inventory/profile mutation fails.
- `ProfessionRuntime.resolve_surface_placement(...)` creates dungeon nodes only after a real floor/wall raycast hit and embeds the prototype presentation behind the hit plane.
- Profession snapshots expose `ClaimedNodeIds`; successful gather results expose `node_id`.

- [ ] Extend focused rules tests first for multiple stable node IDs, multiple nodes per Temple room, floor/wall probes and nonzero embed depth; verify RED against the two-node cooldown implementation.
- [ ] Add a session-service test proving one member cannot gather one node twice, while another party member can gather the same node independently and reconnect reconstruction retains the first member's claim.
- [ ] Verify the new tests are RED before production changes.
- [ ] Add personal claim APIs to DungeonSessionService and pass active session access into ProfessionRuntime.
- [ ] Replace dungeon cooldown semantics with single-use personal claims; roll back a claim if profile mutation fails.
- [ ] Add client-only local hiding so one player's gather does not remove the node for party members.
- [ ] Expand Room 1 and Room 2 to multiple nodes and resolve dungeon presentation from actual floor/wall geometry; skip any node that cannot find a valid surface.
- [ ] Change all profession copy from generic `XP` to explicit profession-specific wording and `Profession XP` progress labels.
- [ ] Run focused Studio tests GREEN, `git diff --check`, and all four Rojo builds.
- [ ] Ask the project owner only for the final Temple visual gate: embedded placement, multiple nodes, personal disappearance, inventory update, and reconnect-safe depletion.

## Accepted follow-up: Temple resource distribution (2026-09-15)

- Give each Temple room a resource placement group.
- Spread each node's primary/fallback probes across distinct room quadrants/sides.
- Enforce an 18-stud minimum distance between resolved node positions in the same room.
- Keep surface raycast + partial embedding mandatory; skip nodes that cannot satisfy both surface and spacing constraints.
- Add `ProfessionResourceDistributionTest.server.luau` to protect multi-node room count, probe distribution, and minimum-spacing behavior.
