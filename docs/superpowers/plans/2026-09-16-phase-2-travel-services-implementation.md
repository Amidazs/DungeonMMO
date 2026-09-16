# Phase 2 Travel Services Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a server-authoritative hold-E Travel Gem in the Starting Base that locally moves an individual player to Market, Dwarven Area, Dungeon Portals, or Orc Area through semantic environment anchors.

**Architecture:** Travel v1 is a Base-local movement subsystem, separate from `TeleportCoordinator` and Dungeon handoffs. Shared configuration/definitions describe the four destinations, `TravelService` owns logical authorization and cooldown state, `BaseTravelRuntime` owns physical proximity/character movement, and `TravelPanel.client.luau` owns presentation. The profile remains schema v7 and Travel adds no persistence.

**Tech Stack:** Roblox Luau, Rojo, existing ProfileService/identity/session authorities, semantic environment anchors, RemoteEvents, ProximityPrompt, Windows PowerShell 5.1 validation runner.

**Spec:** `docs/superpowers/specs/2026-09-16-phase-2-travel-services-design.md`

## Global Constraints

- Start from local `main` `17b27085badf9a27cb1fcf78750e686115ab6de0`.
- `origin/main` remains `60fc0dfd9954e2d580157a580da2425e2b71dd70`.
- Work only in isolated branch/worktree `wip/phase-2-travel-services-v1`.
- The Travel Gem prompt uses `KeyboardKeyCode = E` and `HoldDuration = 1.0`.
- Server interaction distance is exactly 18 studs.
- Successful Travel cooldown is exactly 5 seconds.
- Travel is free.
- Destinations are exactly Market, Dwarven Area, Dungeon Portals, and Orc Area.
- Profile schema remains v7.
- Account Bank data and Bank behavior remain unchanged.
- Travel moves only the requesting player and does not mutate party state.
- Travel must not call `TeleportCoordinator`, `TeleportService`, profile handoff APIs, or create Dungeon sessions.
- A pending Dungeon teleport or recoverable active Dungeon session blocks Travel.
- Candidate Dwarven/Orc landmark selection must be deterministic; ambiguity or absence is an explicit environment error rather than guessed coordinates.
- No push, Roblox publish, PROD DataStore, Robux/monetization, destructive Git, or art-worktree edits.
- Build outputs go to TEMP and root `DungeonMMO.rbxl` is never overwritten.
- TDD: install failing Travel tests before production Travel files.

---

### Task 1: Isolated Travel baseline and approved design documents

**Files:**
- Create in feature worktree: `docs/superpowers/specs/2026-09-16-phase-2-travel-services-design.md`
- Create in feature worktree: `docs/superpowers/plans/2026-09-16-phase-2-travel-services-implementation.md`

**Interfaces:**
- Consumes: local main checkpoint `17b27085badf9a27cb1fcf78750e686115ab6de0`
- Produces: isolated branch `wip/phase-2-travel-services-v1` with committed design/plan baseline

- [ ] **Step 1: Verify the local source-of-truth checkpoint**

Run:

```powershell
git -C C:\Users\Remko\Documents\Roblox\DungeonMMO rev-parse main
git -C C:\Users\Remko\Documents\Roblox\DungeonMMO rev-parse origin/main
```

Expected:

```text
17b27085badf9a27cb1fcf78750e686115ab6de0
60fc0dfd9954e2d580157a580da2425e2b71dd70
```

- [ ] **Step 2: Create the isolated Travel worktree**

Run:

```powershell
git -C C:\Users\Remko\Documents\Roblox\DungeonMMO worktree add `
  C:\Users\Remko\Documents\Roblox\DungeonMMO_TravelServices_v1 `
  -b wip/phase-2-travel-services-v1 `
  17b27085badf9a27cb1fcf78750e686115ab6de0
```

Expected: worktree created on the named Travel branch.

- [ ] **Step 3: Install the approved design and this plan**

Copy the two package Markdown files to:

```text
docs/superpowers/specs/2026-09-16-phase-2-travel-services-design.md
docs/superpowers/plans/2026-09-16-phase-2-travel-services-implementation.md
```

- [ ] **Step 4: Commit the design/plan only**

Run:

```powershell
git add docs/superpowers/specs/2026-09-16-phase-2-travel-services-design.md
git add docs/superpowers/plans/2026-09-16-phase-2-travel-services-implementation.md
git diff --cached --check
git commit -m "docs: lock travel services design"
```

Expected: docs-only checkpoint, clean worktree.

- [ ] **Step 5: Build all four baseline projects**

Run `rojo build` for:

```text
base.project.json
default.project.json
published-base.project.json
published-dungeon.project.json
```

to TEMP outputs.

Expected: all four exit 0 before Travel code is introduced.

---

### Task 2: Shared Travel contracts — config, destinations, access math

**Files:**
- Create: `src/ReplicatedStorage/Core/Shared/TravelConfig.luau`
- Create: `src/ReplicatedStorage/Core/Shared/TravelDestinationDefinitions.luau`
- Create: `src/ReplicatedStorage/Core/Shared/TravelAccessRules.luau`
- Test: `src/ServerScriptService/Core/Tests/TravelConfigDefinitionsTest.server.luau`
- Test: `src/ServerScriptService/Core/Tests/TravelAccessRulesTest.server.luau`

**Interfaces:**
- Produces: `TravelConfig.HOLD_DURATION`, `ACCESS_DISTANCE`, `COOLDOWN_SECONDS`, `ARRIVAL_HEIGHT_OFFSET`, `ALREADY_THERE_DISTANCE`
- Produces: `TravelDestinationDefinitions.get(id)`, `.all()`, `.ORDER`
- Produces: `TravelAccessRules.within_service_distance(character_position, service_position)` and `.already_at_destination(character_position, destination_position)`

- [ ] **Step 1: Write the failing config/definitions test**

Create a server test that requires the modules with `FindFirstChild`, errors with `RED` when absent, then asserts:

```luau
assert(TravelConfig.HOLD_DURATION == 1)
assert(TravelConfig.ACCESS_DISTANCE == 18)
assert(TravelConfig.COOLDOWN_SECONDS == 5)
assert(TravelConfig.ARRIVAL_HEIGHT_OFFSET == 3)
assert(TravelConfig.ALREADY_THERE_DISTANCE == 10)
assert(ProfileSchema.VERSION == 7)

local expected = {
    {"Market", "Market", "Base.Travel.Market"},
    {"Dwarves", "Dwarven Area", "Base.Travel.Dwarves"},
    {"Portals", "Dungeon Portals", "Base.Travel.Portals"},
    {"Orcs", "Orc Area", "Base.Travel.Orcs"},
}

assert(#TravelDestinationDefinitions.ORDER == 4)
```

For each row, assert exact `Id`, `Name`, `AnchorId`, and `SortOrder`.

- [ ] **Step 2: Write the failing access-math test**

Assert:

```luau
assert(TravelAccessRules.within_service_distance(
    Vector3.zero,
    Vector3.new(18, 0, 0)
) == true)

assert(TravelAccessRules.within_service_distance(
    Vector3.zero,
    Vector3.new(18.01, 0, 0)
) == false)

assert(TravelAccessRules.already_at_destination(
    Vector3.zero,
    Vector3.new(10, 0, 0)
) == true)

assert(TravelAccessRules.already_at_destination(
    Vector3.zero,
    Vector3.new(10.01, 0, 0)
) == false)
```

- [ ] **Step 3: Verify RED**

Run the static RED verifier and baseline build.

Expected: RED because `TravelConfig`, `TravelDestinationDefinitions`, and `TravelAccessRules` do not exist.

- [ ] **Step 4: Implement `TravelConfig.luau`**

Use:

```luau
--!strict
local TravelConfig = {}

TravelConfig.HOLD_DURATION = 1
TravelConfig.ACCESS_DISTANCE = 18
TravelConfig.COOLDOWN_SECONDS = 5
TravelConfig.ARRIVAL_HEIGHT_OFFSET = 3
TravelConfig.ALREADY_THERE_DISTANCE = 10

return table.freeze(TravelConfig)
```

- [ ] **Step 5: Implement exact destination definitions**

Use four frozen definitions with IDs `Market`, `Dwarves`, `Portals`, `Orcs` and semantic anchors from the spec. Expose deterministic `ORDER`, `get(id)`, and `all()`.

- [ ] **Step 6: Implement `TravelAccessRules.luau`**

Use vector magnitudes against the exact config distances; do not accept client distances.

- [ ] **Step 7: Verify shared-contract GREEN**

Run the Travel static verifier. Expected: shared contracts pass while later TravelService/runtime checks remain pending.

---

### Task 3: Logical TravelService and session-only cooldown

**Files:**
- Create: `src/ServerScriptService/Core/Services/TravelService.luau`
- Modify: `src/ServerScriptService/Core/Services/RuntimeServices.luau`
- Test: `src/ServerScriptService/Core/Tests/TravelServiceTest.server.luau`

**Interfaces:**
- Consumes: `ProfileService`, context string, injected `is_teleport_pending(user_id)`, injected `has_recoverable_session(user_id)`
- Produces:
  - `TravelService.new(profile_service, context, options)`
  - `TravelService:build_snapshot(user_id, now?)`
  - `TravelService:validate_request(user_id, destination_id, now?)`
  - `TravelService:record_success(user_id, now?)`
  - `TravelService:remaining_cooldown(user_id, now?)`
  - `TravelService:clear_user(user_id)`

- [ ] **Step 1: Write TravelService RED tests**

Construct `ProfileService` with `InMemoryProfileAdapter`, load a user, and first assert incomplete identity rejects:

```luau
local result = travel:validate_request(user_id, "Market", 100)
assert(result.ok == false)
assert(result.reason == "IdentityIncomplete")
```

Mutate identity to complete, then assert:

```luau
assert(travel:validate_request(user_id, "__missing__", 100).reason == "UnknownDestination")
assert(travel:validate_request(user_id, "Market", 100).ok == true)
```

Create separate injected callbacks to assert `TeleportPending` and `ActiveDungeonSession`.

Cooldown assertions:

```luau
assert(travel:remaining_cooldown(user_id, 100) == 0)
travel:record_success(user_id, 100)
assert(travel:remaining_cooldown(user_id, 100) == 5)
assert(travel:validate_request(user_id, "Market", 104.99).reason == "TravelCooldown")
assert(travel:validate_request(user_id, "Market", 105).ok == true)
```

Rejecting an unknown destination before `record_success` must leave cooldown at zero.

Instantiate `TravelService.new(profiles, "Dungeon", ...)` and assert `BaseOnlyAction`.

- [ ] **Step 2: Verify service RED**

Expected: `TravelService` missing.

- [ ] **Step 3: Implement `TravelService`**

Constructor:

```luau
function TravelService.new(profile_service: any, context: string, options: any?): any
```

Store cooldown deadlines in a private per-user table. Never persist them.

`validate_request` order:

1. Base context.
2. loaded profile/selected character.
3. complete identity.
4. known destination.
5. injected pending-teleport check.
6. injected recoverable-session check.
7. cooldown.

Return the resolved destination definition on success.

- [ ] **Step 4: Implement authoritative snapshots**

`build_snapshot` returns:

```luau
{
    ok = true,
    CooldownRemaining = number,
    Destinations = {
        {Id = "Market", Name = "Market", Available = true},
        ...
    },
}
```

No coordinates/CFrames appear in the snapshot.

- [ ] **Step 5: Add TravelService to `RuntimeServices`**

Instantiate with the same `ProfileService`; runtime-specific pending/session callbacks are supplied by Base wiring rather than by the shared runtime constructor.

Expose `TravelService = travel`.

- [ ] **Step 6: Verify service GREEN**

Run static/service tests. Expected: cooldown, destination, identity, Base-only, pending/session logic pass.

---

### Task 4: Semantic Travel Gem and four arrival anchors

**Files:**
- Create: `src/ServerScriptService/Base/TravelCandidateLandmarkResolver.luau`
- Modify: `src/ReplicatedStorage/Core/Shared/EnvironmentAnchorDefinitions.luau`
- Modify: `src/ServerScriptService/Base/BaseCandidateAnchorProfile.luau`
- Modify: `src/ServerScriptService/Base/BaseSyntheticEnvironment.luau`
- Modify: `src/ServerScriptService/Base/BaseEnvironmentBootstrap.server.luau`
- Test: `src/ServerScriptService/Base/Tests/TravelCandidateLandmarkResolverTest.server.luau`
- Test: `src/ServerScriptService/Base/Tests/TravelEnvironmentContractTest.server.luau`

**Interfaces:**
- Produces required anchors:
  - `Base.Service.Travel`
  - `Base.Travel.Market`
  - `Base.Travel.Dwarves`
  - `Base.Travel.Portals`
  - `Base.Travel.Orcs`
- Produces `TravelCandidateLandmarkResolver.resolve(root, rule) -> {ok, instance?, reason?, matches?}`

- [ ] **Step 1: Write candidate-resolver RED tests**

Create a temporary Folder with Parts named:

```text
Anchor_FastTravel_Dwarf_Mine
Anchor_FastTravel_Orc_Farm
Central market circular cobbled plaza
Portal_02
```

Assert a Dwarf rule uniquely resolves the Dwarf fast-travel anchor and an Orc rule uniquely resolves the Orc anchor.

Add two matching Dwarf anchors and assert:

```luau
assert(result.ok == false)
assert(result.reason == "CandidateLandmarkAmbiguous")
```

Use an empty root and assert `CandidateLandmarkMissing`.

- [ ] **Step 2: Implement strict candidate resolver**

Resolver matching order:

1. exact `PreferredNames`, in order;
2. unique names containing the preferred fast-travel prefix plus any configured area fragment;
3. unique names containing configured area fragments.

If a stage yields exactly one match, return it.
If it yields multiple matches, return `CandidateLandmarkAmbiguous`.
If no stage yields a match, return `CandidateLandmarkMissing`.

Never select the first ambiguous match.

- [ ] **Step 3: Upgrade Base anchor definitions**

Replace:

```text
Base.Service.TravelPlaceholder
```

with:

```text
Base.Service.Travel
```

and add the four destination anchors to Base `Required`.

- [ ] **Step 4: Add Synthetic anchors**

Use deterministic safe Synthetic positions for the Travel Gem and four destinations. Keep Market, Dwarves, Portals, and Orcs spatially separated by more than the already-there threshold.

- [ ] **Step 5: Add Candidate entries**

Travel Gem keeps the accepted existing central fast-travel selector.

Market and Portals use stable exact selectors.

Dwarves uses preferred names including:

```text
Anchor_FastTravel_Dwarf_Mine
Anchor_FastTravel_Dwarven_Mine
```

plus strict dynamic fragments `Dwarf`, `Dwarven`, `Mine`.

Orcs uses preferred names including:

```text
Anchor_FastTravel_Orc_Farm
Anchor_FastTravel_Orcs_Farm
```

plus strict dynamic fragments `Orc`, `Orcs`, `Farm`.

Each dynamic entry contains an explicit safe `Offset` only for vertical/arrival clearance, not a guessed world coordinate.

- [ ] **Step 6: Extend candidate anchor creation**

`BaseEnvironmentBootstrap` detects entries containing `DynamicRule`, calls `TravelCandidateLandmarkResolver.resolve`, then passes the resolved landmark through existing `CandidateAnchorPlacement`.

On missing/ambiguous Dwarf or Orc landmarks, fail with:

```text
CandidateLandmarkMissing:Base.Travel.Dwarves
CandidateLandmarkAmbiguous:Base.Travel.Dwarves
CandidateLandmarkMissing:Base.Travel.Orcs
CandidateLandmarkAmbiguous:Base.Travel.Orcs
```

- [ ] **Step 7: Create the hold-E Travel Gem prompt**

Bootstrap:

```luau
local travel = resolved.by_id["Base.Service.Travel"]
local travel_prompt = ensure_prompt(
    travel,
    "TravelPrompt",
    "Travel",
    "Travel Gem"
)
travel_prompt.KeyboardKeyCode = Enum.KeyCode.E
travel_prompt.HoldDuration = TravelConfig.HOLD_DURATION
travel_prompt.MaxActivationDistance = TravelConfig.ACCESS_DISTANCE
```

Label `TRAVEL GEM`.

- [ ] **Step 8: Verify environment GREEN**

Static tests must prove all five semantic anchors, the exact hold duration/key/distance, and no `TravelPlaceholder` remains.

---

### Task 5: BaseTravelRuntime and server-authoritative movement

**Files:**
- Create: `src/ServerScriptService/Base/BaseTravelRuntime.luau`
- Modify: `src/ReplicatedStorage/Core/Remotes.model.json`
- Modify: `src/ServerScriptService/Base/BaseRuntime.server.luau`
- Test: `src/ServerScriptService/Base/Tests/BaseTravelRuntimeContractTest.server.luau`

**Interfaces:**
- Remotes:
  - `TravelSnapshotRequest`
  - `TravelSnapshot`
  - `TravelRequest`
  - `TravelActionResult`
- Produces: `BaseTravelRuntime.attach(config)`

- [ ] **Step 1: Write runtime/remote RED test**

Assert all four remotes exist and `BaseTravelRuntime` exists.

Static contract assertions require the runtime source to reference:

```text
TooFarFromTravelService
DestinationUnavailable
AlreadyAtDestination
TravelFailed
PivotTo
ARRIVAL_HEIGHT_OFFSET
```

- [ ] **Step 2: Add remotes**

Add exactly the four Travel RemoteEvents to `Remotes.model.json`.

- [ ] **Step 3: Implement `BaseTravelRuntime.attach`**

Inputs:

```luau
{
    travel = travel_service,
    profiles = profile_service,
    environment = base_environment,
    remotes = remotes,
    is_teleport_pending = function(user_id) -> boolean,
    has_recoverable_session = function(user_id) -> boolean,
}
```

Snapshot request authorization:
- root part exists;
- within 18 studs of `Base.Service.Travel`;
- then `TravelService:build_snapshot`.

Travel request:
- validate physical range;
- call `TravelService:validate_request`;
- resolve destination anchor by definition `AnchorId`;
- reject missing anchor;
- reject already-at-destination;
- recheck character/root immediately before move;
- `character:PivotTo(destination.CFrame + Vector3.new(0, ARRIVAL_HEIGHT_OFFSET, 0))`;
- only then `record_success`;
- send success and current cooldown.

- [ ] **Step 4: Integrate with BaseRuntime after session helpers exist**

Use the existing coordinator for the pending callback only:

```luau
is_teleport_pending = function(user_id: number): boolean
    return coordinator:is_pending(user_id)
end
```

Use existing session/reconnect state to produce `has_recoverable_session`.

Do not call `TeleportCoordinator` to perform local travel.

- [ ] **Step 5: Clear cooldown on player removal**

Call `travel:clear_user(player.UserId)` during Base player cleanup or from the runtime's PlayerRemoving connection.

- [ ] **Step 6: Verify runtime GREEN**

Static/runtime tests must pass and source scan must show no `TeleportService`/`start_dungeon`/`return_to_base` invocation in Travel files.

---

### Task 6: Hold-E Travel UI

**Files:**
- Create: `src/StarterPlayerScripts/Base/TravelPanel.client.luau`

**Interfaces:**
- Consumes: `Base.Service.Travel` and `TravelPrompt`
- Sends only destination string IDs through `TravelRequest`
- Never sends coordinates/CFrames

- [ ] **Step 1: Create compact Travel panel**

Create `ScreenGui` + panel with buttons in accepted order:

```text
Market
Dwarven Area
Dungeon Portals
Orc Area
```

Add status/cooldown text and close button.

- [ ] **Step 2: Open only from completed ProximityPrompt trigger**

Wait for:

```luau
EnvironmentAnchorClient.wait_for(
    "Base",
    "Base.Service.Travel",
    15
)
```

Connect `TravelPrompt.Triggered` to request the authoritative snapshot.

The client does not bind E directly; the ProximityPrompt hold requirement owns input.

- [ ] **Step 3: Send destination ID only**

Each button calls:

```luau
travel_request:FireServer(destination.Id)
```

No position, CFrame, unlock state or cooldown is sent.

- [ ] **Step 4: Handle authoritative response**

On successful Travel:
- close panel;
- clear selection/status.

On failure:
- show readable stable reason;
- keep panel only if still physically within range.

- [ ] **Step 5: Close when leaving Travel range**

While visible, periodically compare local root to Travel Gem for UX only. At >18 studs close panel. The server still rechecks independently.

- [ ] **Step 6: Verify UI contract**

Static source verifier confirms:
- all four labels;
- `Base.Service.Travel`;
- no client `CFrame` sent to server;
- no direct `UserInputService` E binding;
- no `TeleportService`.

---

### Task 7: Regression/build verification and Studio handoff

**Files:**
- Verify all Travel source/tests plus existing project.
- Build:
  - `base.project.json`
  - `default.project.json`
  - `published-base.project.json`
  - `published-dungeon.project.json`

**Interfaces:**
- Produces a fresh `Base_GREEN.rbxl` for the unavoidable Studio interaction proof.

- [ ] **Step 1: Run static Travel GREEN verifier**

Verify:
- exact config;
- schema v7;
- Bank files/contracts unchanged;
- exact four destinations;
- hold-E prompt;
- semantic anchors;
- cooldown/session/pending protections;
- runtime movement;
- remotes/UI;
- no Travel code under Dungeon;
- no Travel `TeleportService`/Dungeon handoff coupling;
- no art changes.

- [ ] **Step 2: Run `git diff --check`**

Expected: exit 0.

- [ ] **Step 3: Build all four projects to TEMP**

Expected: all four `rojo build` commands exit 0.

- [ ] **Step 4: Stop for the actual Studio interaction proof**

The project owner verifies:

```text
tap E does not open menu
hold E ~1 second opens Travel
Market lands safely
Dwarven Area lands safely
Dungeon Portals lands safely outside portal trigger
Orc Area lands safely
5-second cooldown blocks immediate repeat
successful Travel closes UI
walking >18 studs from gem closes UI
party state remains intact
no new red runtime errors
```

No gameplay commit, merge, push or publish occurs before that evidence.
