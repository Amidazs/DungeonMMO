# Starting Base + Temple Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn the current LobbyScene town and Temple dungeon candidates into the canonical testable Base -> Temple -> rewards -> Base loop without coupling accepted gameplay systems to either environment's current geometry.

**Architecture:** Gameplay resolves semantic environment anchors through one shared contract. Studio supports three explicit modes: `Synthetic` for automated regression builds, `Candidate` for the current LobbyScene/Temple visual files, and `Authored` for future environments that carry saved tagged anchors. Base and Dungeon adapters consume resolved anchors; accepted profile, progression, Equipment, combat, checkpoint, encounter, completion and teleport services remain authoritative and unchanged except where they currently read hard-coded environment positions.

**Tech Stack:** Roblox Luau, Rojo 7.7.0-rc.1 via repository `rokit.toml`, Roblox Studio, CollectionService tags, Windows PowerShell 5.1, Git/GitHub.

**Spec:** `docs/superpowers/specs/2026-09-14-starting-base-temple-integration-design.md`

## Global Constraints

- Start only from canonical main `08d071136ebbdeb0f02649f360d767e17f8c439e`.
- Do not reset, clean, force-push, rewrite history, discard unrelated work, or touch `C:\Users\Remko\Documents\Roblox\DungeonMMO_Art`.
- Do not publish Roblox places, enable PROD, spend Robux, or enable monetisation in this gate.
- Validation builds are timestamped TEMP outputs only; never overwrite `DungeonMMO.rbxl`.
- LobbyScene and Temple are current **candidate test environments**, not permanent geometry contracts.
- Gameplay code may depend on semantic anchor IDs, never on current GLB node names, Temple hierarchy names, or scattered world coordinates.
- Candidate-specific landmark names/offsets are isolated to candidate profile modules/tools only.
- Non-Studio runtime must never silently create Synthetic or Candidate anchors. It requires `Authored` anchors and fails closed when the environment contract is invalid.
- Preserve schema v5 and all accepted Human/Elf, Fighter/Mage/Ranger, Equipment/run-lock, progression/loadout/proficiency, revive/completion and teleport contracts.
- Keep Mining/Blacksmithing, Herbalism/Alchemy, bank persistence, party-forming UX, rare states/events, second production dungeon, Dwarf/Orc selectable races, secondary classes and final presentation out of this gate.
- Current candidate fingerprints for traceability only; do **not** commit the binary files into the gameplay branch in this gate:
  - Lobby GLB: `LobbyScene_001_V3_1_P11_SurfaceArchitecture(1).glb`, SHA-256 `F624C96AF9F67BB374FE36752331A26B59C4C7E7AA8B228223AE4C04919E981B`, 40,984,352 bytes.
  - Temple place: `Temple.rbxl`, SHA-256 `A3039361882632E857228411A0F36BBA9086A22A37080FA2034CE2B25921BB32`, 13,622,440 bytes.

---

## File structure and ownership

### New shared environment contract

- Create `src/ReplicatedStorage/Core/Shared/EnvironmentAnchorDefinitions.luau`
  - Owns tag/attribute names, environment IDs and required/optional semantic anchor IDs.
- Create `src/ServerScriptService/Core/Environment/EnvironmentAnchorResolver.luau`
  - Resolves tagged BaseParts, rejects missing/duplicate/invalid anchors and returns deterministic grouped anchors.
- Create `src/ServerScriptService/Core/Environment/EnvironmentRuntimeMode.luau`
  - Resolves `Synthetic`, `Candidate` or `Authored`; forces `Authored` outside Studio.
- Create `src/ServerScriptService/Core/Environment/EnvironmentAnchorFactory.luau`
  - Creates invisible semantic anchor parts for Studio-only Synthetic/Candidate bootstrap without giving gameplay authority to decorative geometry.

### Current candidate profiles / fixtures

- Create `src/ServerScriptService/Base/BaseCandidateAnchorProfile.luau`
  - Contains only current LobbyScene landmark selectors plus local offsets/roles.
- Create `src/ServerScriptService/Base/BaseSyntheticEnvironment.luau`
  - Minimal Base anchor fixture for automated Studio regression builds.
- Create `src/ServerScriptService/Dungeon/TempleCandidateAnchorProfile.luau`
  - Contains only current Temple candidate anchor CFrames/landmark selectors after calibration.
- Create `src/ServerScriptService/Dungeon/TempleSyntheticEnvironment.luau`
  - Minimal floor/trigger/barrier/anchor fixture for automated Dungeon regressions.
- Create `tools/environment/Stage-EnvironmentCandidates.ps1`
  - Validates candidate SHA-256 fingerprints and stages local copies for visual testing without adding them to Git.
- Create `docs/testing/phase2-environment-candidate-manifest.md`
  - Records exact candidate filenames, hashes and role, explicitly stating they are replaceable test candidates.

### Base integration

- Replace `src/ServerScriptService/Base/BaseBuilder.server.luau` with `src/ServerScriptService/Base/BaseEnvironmentBootstrap.server.luau`.
- Create `src/ServerScriptService/Base/BaseEnvironmentAdapter.luau`.
- Modify `src/ServerScriptService/Base/BaseRuntime.server.luau` only for semantic spawn/arrival placement; keep admission/session/teleport authority unchanged.
- Modify `src/StarterPlayerScripts/Base/BaseUi.client.luau` to bind Dungeon Board / Temple Portal prompts through tags/attributes rather than a permanent global-only entry surface.
- Modify `src/StarterPlayerScripts/Base/ProgressionTrainer.client.luau` to discover trainer prompts through semantic tagged anchors rather than `Workspace.BasePrototype`.
- Modify `src/StarterPlayerScripts/Base/EquipmentPanel.client.luau` to discover the Equipment service anchor rather than `Workspace.BasePrototype/EquipmentManager`.

### Temple integration

- Replace `src/ServerScriptService/Dungeon/DungeonBuilder.server.luau` with `src/ServerScriptService/Dungeon/DungeonEnvironmentBootstrap.server.luau`.
- Create `src/ServerScriptService/Dungeon/TempleEnvironmentAdapter.luau`.
- Modify `src/ServerScriptService/Dungeon/DungeonRuntime.server.luau` to consume Temple adapter CFrames/trigger parts instead of greybox names and hard-coded positions.
- Modify `src/ReplicatedStorage/Core/Shared/DungeonDefinitions.luau` to remove environment-position ownership from `MarauderCaptain.SpawnPosition`; counts/rewards/sequence stay data-driven.

### Tests

- Create `src/ServerScriptService/Core/Tests/EnvironmentAnchorResolverTest.server.luau`.
- Create `src/ServerScriptService/Core/Tests/EnvironmentRuntimeModeTest.server.luau`.
- Create `src/ServerScriptService/Base/Tests/BaseEnvironmentContractTest.server.luau`.
- Replace `src/ServerScriptService/Dungeon/Tests/DungeonBuilderContractTest.server.luau` with semantic Temple contract assertions.
- Create `src/ServerScriptService/Dungeon/Tests/TempleEnvironmentAdapterTest.server.luau`.
- Update any test that explicitly expects `DungeonDefinitions.TEST_DUNGEON.MarauderCaptain.SpawnPosition`.

---

### Task 1: Establish the safe feature worktree and record the approved design

**Files:**
- Create locally in branch: `docs/superpowers/specs/2026-09-14-starting-base-temple-integration-design.md`
- Create locally in branch: `docs/superpowers/plans/2026-09-14-starting-base-temple-integration-implementation.md`
- Create: `docs/testing/phase2-environment-candidate-manifest.md`

**Interfaces:**
- Consumes: canonical main `08d071136ebbdeb0f02649f360d767e17f8c439e`.
- Produces: isolated branch `wip/phase-2-starting-base-temple-integration` and an auditable candidate manifest.

- [ ] **Step 1: Verify the primary repository is at the exact accepted baseline and clean**

Run in Windows PowerShell 5.1:

```powershell
$Repo = "C:\Users\Remko\Documents\Roblox\DungeonMMO"
$Expected = "08d071136ebbdeb0f02649f360d767e17f8c439e"

git -C $Repo fetch origin
if ((git -C $Repo branch --show-current).Trim() -ne "main") { throw "Primary repo must be on main." }
if ((git -C $Repo rev-parse HEAD).Trim() -ne $Expected) { throw "Unexpected main baseline." }
if ((git -C $Repo rev-parse origin/main).Trim() -ne $Expected) { throw "origin/main does not match accepted baseline." }
if ((git -C $Repo status --porcelain).Count -ne 0) { throw "Primary main worktree is not clean." }
```

Expected: no exception; local main and origin/main both equal `08d0711...`.

- [ ] **Step 2: Create a dedicated worktree without touching the art worktree**

```powershell
$Repo = "C:\Users\Remko\Documents\Roblox\DungeonMMO"
$Worktree = "C:\Users\Remko\Documents\Roblox\DungeonMMO_Phase2_BaseTemple"
$Branch = "wip/phase-2-starting-base-temple-integration"
$Expected = "08d071136ebbdeb0f02649f360d767e17f8c439e"

if (Test-Path $Worktree) { throw "Target worktree already exists; inspect rather than deleting it." }
git -C $Repo worktree add -b $Branch $Worktree $Expected
```

Expected: new worktree at the exact baseline.

- [ ] **Step 3: Copy the already-approved spec and this plan into the worktree**

Use the exact approved artifacts from this conversation. Do not rewrite their requirements during copying. Verify:

```powershell
git -C $Worktree diff --check
```

Expected: no whitespace errors.

- [ ] **Step 4: Record candidate asset fingerprints, not the binaries**

`docs/testing/phase2-environment-candidate-manifest.md` must state:

```markdown
# Phase 2 Environment Candidate Manifest

These files are replaceable visual test candidates. Gameplay code must not rely
on their binary identity, hierarchy, or fixed coordinates.

- Base candidate: LobbyScene_001_V3_1_P11_SurfaceArchitecture(1).glb
  - SHA-256: F624C96AF9F67BB374FE36752331A26B59C4C7E7AA8B228223AE4C04919E981B
  - Size: 40,984,352 bytes
- Dungeon candidate: Temple.rbxl
  - SHA-256: A3039361882632E857228411A0F36BBA9086A22A37080FA2034CE2B25921BB32
  - Size: 13,622,440 bytes

Integration authority comes from DungeonMMOEnvironmentAnchor semantic anchors,
not from these filenames or hashes. A later Lobby/Temple revision may replace
either candidate by supplying the same anchor contract.
```

- [ ] **Step 5: Commit the design/plan/manifest checkpoint**

```powershell
git -C $Worktree add docs/superpowers/specs docs/superpowers/plans docs/testing/phase2-environment-candidate-manifest.md
git -C $Worktree diff --cached --check
git -C $Worktree commit -m "design: lock base temple integration gate"
```

Expected: one documentation-only branch commit; `main` unchanged.

---

### Task 2: Add the semantic environment-anchor contract and resolver

**Files:**
- Create: `src/ReplicatedStorage/Core/Shared/EnvironmentAnchorDefinitions.luau`
- Create: `src/ServerScriptService/Core/Environment/EnvironmentAnchorResolver.luau`
- Create: `src/ServerScriptService/Core/Tests/EnvironmentAnchorResolverTest.server.luau`

**Interfaces:**
- Produces: `EnvironmentAnchorDefinitions.TAG`, attribute-name constants, `BASE`, `TEMPLE` contracts.
- Produces: `EnvironmentAnchorResolver.resolve(root, contract, tagged_instances?) -> result`.
- Result shape on success: `{ok=true, by_id={[string]: BasePart}, groups={[string]: {BasePart}}}`.
- Failure shape: `{ok=false, reason=string, anchor_id=string?}`.

- [ ] **Step 1: Write RED tests for exact anchors, duplicates, missing anchors and deterministic groups**

The test constructs temporary Parts under a Folder and supplies them directly to the resolver so it does not depend on global CollectionService state. Cover at least:

```luau
local result = EnvironmentAnchorResolver.resolve(root, {
    EnvironmentId = "Temple",
    Required = {"Temple.EntrySpawn", "Temple.Room1.Trigger"},
    Groups = {
        {Name = "Room1EnemySpawns", Prefix = "Temple.Room1.EnemySpawn.", MinCount = 2},
    },
}, tagged)

check(result.ok == true, "valid anchors must resolve")
check(#result.groups.Room1EnemySpawns == 2, "spawn group must resolve")
check(
    result.groups.Room1EnemySpawns[1]:GetAttribute("AnchorId")
        == "Temple.Room1.EnemySpawn.01",
    "groups must sort by AnchorId"
)
```

Also assert failure reasons exactly:
- `MissingAnchor`
- `DuplicateAnchor`
- `InvalidAnchorInstance`
- `WrongEnvironment`
- `InsufficientAnchorGroup`

- [ ] **Step 2: Run the test to confirm RED**

Build Dungeon to a TEMP file and open in Studio, or use the existing project test workflow. Expected failure: module missing.

- [ ] **Step 3: Implement the shared definitions**

The definitions must contain these exact IDs:

```luau
EnvironmentAnchorDefinitions.TAG = "DungeonMMOEnvironmentAnchor"
EnvironmentAnchorDefinitions.ENVIRONMENT_ATTRIBUTE = "EnvironmentId"
EnvironmentAnchorDefinitions.ANCHOR_ATTRIBUTE = "AnchorId"
EnvironmentAnchorDefinitions.ROLE_ATTRIBUTE = "AnchorRole"
EnvironmentAnchorDefinitions.VERSION_ATTRIBUTE = "AnchorVersion"
```

`BASE.Required` contains all approved Base anchors. `TEMPLE.Required` contains entry/checkpoint/trigger/captain/completion/return anchors. Temple enemy spawns are groups with prefixes `Temple.Room1.EnemySpawn.` and `Temple.Room2.EnemySpawn.`.

- [ ] **Step 4: Implement the resolver**

Rules:
- only BaseParts are valid anchors;
- every candidate must be a descendant of the supplied `root`;
- `EnvironmentId` must equal the contract ID;
- exact `AnchorId` values are unique;
- groups sort lexicographically by `AnchorId`;
- no fallback CFrame is synthesized in the resolver.

- [ ] **Step 5: Re-run resolver tests and existing Core tests**

Expected: new resolver tests PASS and no prior Core failures.

- [ ] **Step 6: Commit**

```powershell
git -C $Worktree add src/ReplicatedStorage/Core/Shared/EnvironmentAnchorDefinitions.luau src/ServerScriptService/Core/Environment src/ServerScriptService/Core/Tests/EnvironmentAnchorResolverTest.server.luau
git -C $Worktree diff --cached --check
git -C $Worktree commit -m "feat: add semantic environment anchor contract"
```

---

### Task 3: Add explicit runtime modes and safe Studio-only anchor factories

**Files:**
- Create: `src/ServerScriptService/Core/Environment/EnvironmentRuntimeMode.luau`
- Create: `src/ServerScriptService/Core/Environment/EnvironmentAnchorFactory.luau`
- Create: `src/ServerScriptService/Core/Tests/EnvironmentRuntimeModeTest.server.luau`

**Interfaces:**
- Produces: `EnvironmentRuntimeMode.resolve(is_studio, requested_mode) -> "Synthetic" | "Candidate" | "Authored"` or error result.
- Produces: `EnvironmentAnchorFactory.create(parent, environment_id, anchor_id, cframe, size?, role?) -> BasePart`.

- [ ] **Step 1: Write RED mode tests**

Required decisions:

```luau
check(resolve(true, nil) == "Synthetic", "Studio default is Synthetic")
check(resolve(true, "Candidate") == "Candidate", "Studio may use Candidate")
check(resolve(true, "Authored") == "Authored", "Studio may inspect authored anchors")
check(resolve(false, "Authored") == "Authored", "non-Studio accepts Authored")
check(resolve(false, "Candidate") == nil, "non-Studio rejects Candidate")
check(resolve(false, "Synthetic") == nil, "non-Studio rejects Synthetic")
```

The returned failure reason for the last two is `EnvironmentModeNotPublishSafe`.

- [ ] **Step 2: Run tests to verify RED**

Expected: missing modules.

- [ ] **Step 3: Implement runtime mode and anchor factory**

Factory-created anchors are:
- anchored;
- transparent;
- `CanCollide=false`, `CanTouch=false`, `CanQuery=true` by default;
- tagged with `DungeonMMOEnvironmentAnchor`;
- assigned the four semantic attributes;
- parented beneath one generated `DungeonMMOEnvironmentAnchors` Folder.

- [ ] **Step 4: Run tests GREEN and commit**

```powershell
git -C $Worktree add src/ServerScriptService/Core/Environment src/ServerScriptService/Core/Tests/EnvironmentRuntimeModeTest.server.luau
git -C $Worktree diff --cached --check
git -C $Worktree commit -m "feat: add safe environment runtime modes"
```

---

### Task 4: Replace the Base greybox builder with semantic Base integration

**Files:**
- Delete: `src/ServerScriptService/Base/BaseBuilder.server.luau`
- Create: `src/ServerScriptService/Base/BaseEnvironmentBootstrap.server.luau`
- Create: `src/ServerScriptService/Base/BaseEnvironmentAdapter.luau`
- Create: `src/ServerScriptService/Base/BaseSyntheticEnvironment.luau`
- Create: `src/ServerScriptService/Base/BaseCandidateAnchorProfile.luau`
- Create: `src/ServerScriptService/Base/Tests/BaseEnvironmentContractTest.server.luau`

**Interfaces:**
- `BaseEnvironmentAdapter.resolve(workspace) -> {ok, anchors, ...}`.
- `BaseEnvironmentAdapter.get(id) -> BasePart`.
- `BaseEnvironmentAdapter.place_character(character, destination)` where destination is `"Spawn"` or `"ArrivalFromTemple"`.
- Bootstrap owns prompt/label creation on semantic anchors; it does not create combat/progression authority.

- [ ] **Step 1: Write RED Base contract test**

Verify a Synthetic Base bootstrap produces exactly one required semantic anchor for every Base ID and no `Workspace.BasePrototype` dependency.

Key assertions:

```luau
check(Workspace:FindFirstChild("BasePrototype") == nil,
    "legacy BasePrototype must not be the environment contract")
check(adapter:get("Base.PlayerSpawn") ~= nil, "Base.PlayerSpawn required")
check(adapter:get("Base.TemplePortal") ~= nil, "Base.TemplePortal required")
check(adapter:get("Base.Trainer.Fighter") ~= nil, "Fighter trainer required")
check(adapter:get("Base.Trainer.Mage") ~= nil, "Mage trainer required")
check(adapter:get("Base.Trainer.Ranger") ~= nil, "Ranger trainer required")
```

- [ ] **Step 2: Run RED**

Expected: missing adapter/bootstrap modules or legacy builder still present.

- [ ] **Step 3: Implement the Synthetic Base fixture**

Synthetic mode may use a simple flat test floor and semantic anchor Parts. This geometry exists only to keep automated Studio regressions executable. It is not used in Candidate mode and cannot run outside Studio.

- [ ] **Step 4: Implement the Candidate Base profile as adapter-only data**

For the current LobbyScene candidate, use landmark selectors that already exist in the GLB where practical, including:
- `Anchor_FastTravel_Central_Tree_Market`
- `Anchor_FastTravel_Human_Gate`
- `Anchor_FastTravel_Dwarf_Surface_Mine`
- `Anchor_FastTravel_Orc_Farm`
- `Blacksmith_Forge`
- `HumanBarracks_01`
- `Central market circular cobbled plaza`
- one selected current portal structure.

The profile may contain local offsets from those landmarks, but no other gameplay module may read these selectors or offsets.

- [ ] **Step 5: Implement Base bootstrap interaction binding**

Server-created prompts keep accepted interaction names where useful:
- trainer anchors get `TrainerId` and `ProgressionTrainerPrompt`;
- Equipment anchor gets `EquipmentManagerPrompt`;
- Dungeon Board gets `DungeonBoardPrompt`;
- Temple Portal gets `DungeonEntryPrompt` and `DungeonId="TestDungeon"`;
- placeholders are clearly labelled but have no persistence/economy behaviour.

- [ ] **Step 6: Run Base contract and regression tests GREEN**

Expected: Base anchor contract PASS; existing identity/progression/equipment tests remain green.

- [ ] **Step 7: Commit**

```powershell
git -C $Worktree add -A src/ServerScriptService/Base
git -C $Worktree diff --cached --check
git -C $Worktree commit -m "feat: integrate base through semantic anchors"
```

---

### Task 5: Decouple Base clients and return placement from `BasePrototype`

**Files:**
- Modify: `src/StarterPlayerScripts/Base/BaseUi.client.luau`
- Modify: `src/StarterPlayerScripts/Base/ProgressionTrainer.client.luau`
- Modify: `src/StarterPlayerScripts/Base/EquipmentPanel.client.luau`
- Modify: `src/ServerScriptService/Base/BaseRuntime.server.luau`
- Create: `src/ReplicatedStorage/Core/Shared/EnvironmentAnchorClient.luau`

**Interfaces:**
- `EnvironmentAnchorClient.find(environment_id, anchor_id) -> BasePart?` using CollectionService tag + attributes.
- Existing RemoteEvents remain unchanged.

- [ ] **Step 1: Add a small client-side anchor lookup helper**

The helper does not create anchors and does not decide authority. It only resolves a unique tagged BasePart for UI/prompt discovery.

- [ ] **Step 2: Refactor trainer discovery**

Remove `Workspace:WaitForChild("BasePrototype")`. Discover the three trainer semantic anchors; connect their existing `ProgressionTrainerPrompt` and preserve `TrainerId` server-catalogue behavior.

- [ ] **Step 3: Refactor Equipment prompt discovery**

Remove `BasePrototype/EquipmentManager` lookup. Resolve `Base.Service.Equipment`, then connect `EquipmentManagerPrompt` exactly as before.

- [ ] **Step 4: Make Base entry UI contextual**

Keep `DungeonEntryRequest` unchanged. The Dungeon Board prompt opens the panel; the Temple Portal prompt calls the same local `request_entry()` function used by the panel's Enter button. All three paths ultimately send only:

```luau
entry_request:FireServer("TestDungeon")
```

The server remains the admission/teleport authority.

- [ ] **Step 5: Add semantic player placement in BaseRuntime**

After profile/handoff admission succeeds and a character exists:
- normal Base load -> `Base.PlayerSpawn`;
- validated return handoff -> `Base.ArrivalFromTemple`.

Use `Model:PivotTo(anchor.CFrame + CFrame.new(0, 3, 0))`. Do not move a character until profile/return-handoff validation has succeeded.

- [ ] **Step 6: Build Base and run Base Studio regression**

```powershell
$Stamp = Get-Date -Format "yyyyMMdd_HHmmss"
rojo build base.project.json -o "$env:TEMP\DungeonMMO_BaseTemple_Base_$Stamp.rbxl"
```

Expected: build succeeds. In Synthetic Studio run, trainer/equipment/entry interactions still work.

- [ ] **Step 7: Commit**

```powershell
git -C $Worktree add src/StarterPlayerScripts/Base src/ServerScriptService/Base/BaseRuntime.server.luau src/ReplicatedStorage/Core/Shared/EnvironmentAnchorClient.luau
git -C $Worktree diff --cached --check
git -C $Worktree commit -m "refactor: bind base clients to environment anchors"
```

---

### Task 6: Replace the Dungeon greybox builder with Temple semantic integration

**Files:**
- Delete: `src/ServerScriptService/Dungeon/DungeonBuilder.server.luau`
- Create: `src/ServerScriptService/Dungeon/DungeonEnvironmentBootstrap.server.luau`
- Create: `src/ServerScriptService/Dungeon/TempleEnvironmentAdapter.luau`
- Create: `src/ServerScriptService/Dungeon/TempleSyntheticEnvironment.luau`
- Create: `src/ServerScriptService/Dungeon/TempleCandidateAnchorProfile.luau`
- Replace: `src/ServerScriptService/Dungeon/Tests/DungeonBuilderContractTest.server.luau`
- Create: `src/ServerScriptService/Dungeon/Tests/TempleEnvironmentAdapterTest.server.luau`

**Interfaces:**
- `TempleEnvironmentAdapter.resolve(workspace) -> adapter`.
- Adapter methods:
  - `get(id) -> BasePart`
  - `get_group(name) -> {BasePart}`
  - `checkpoint_cframe(id) -> CFrame`
  - `enemy_spawn_cframes(room_id) -> {CFrame}`
  - `captain_spawn_cframe() -> CFrame`
  - `set_exit_open(room_id, open)`; no-op when optional barrier is absent.

- [ ] **Step 1: Write RED semantic Temple contract tests**

Required exact anchors:
- `Temple.EntrySpawn`
- `Temple.Room1.Checkpoint`
- `Temple.Room1.Trigger`
- `Temple.Room2.Checkpoint`
- `Temple.Room2.Trigger`
- `Temple.Room3.Checkpoint`
- `Temple.Room3.Trigger`
- `Temple.Room3.CaptainSpawn`
- `Temple.CompletionPosition`
- `Temple.ReturnToBase`

Required groups:
- Room 1 enemy spawns: count >= current `CombatRoom1.MarauderCount` (2)
- Room 2 enemy spawns: count >= current `CombatRoom2.MarauderCount` (3)

Optional:
- `Temple.Room1.ExitBarrier`
- `Temple.Room2.ExitBarrier`

- [ ] **Step 2: Implement Synthetic Temple fixture**

Create only enough floor, triggers, barriers and semantic anchors to run existing automated Dungeon regressions. Preserve Entrance -> Room1 -> Room2 -> Room3 order. Do not reproduce final art.

- [ ] **Step 3: Implement Candidate Temple profile**

Candidate mode is calibrated to the current `Temple.rbxl`. All world CFrames or current Temple hierarchy selectors live only in this profile. The adapter never exposes how those positions were derived.

The profile must map the current visual stages:
- Room 1: root/cavern;
- Room 2: ruined temple;
- Room 3: altar/sanctum.

- [ ] **Step 4: Implement adapter and optional barrier behavior**

If a barrier anchor is present, `set_exit_open` changes its collision/transparency. If absent, progression remains authoritative and the method returns success without creating a hidden hard-coded gate.

- [ ] **Step 5: Replace legacy builder contract test**

Remove tests for `DungeonRuntime`, `DungeonSpawn`, `Room1StartTrigger` etc. Assert semantic anchors and adapter methods instead. Keep the historical invariant that there is no separate checkpoint/completion room requirement.

- [ ] **Step 6: Run Temple adapter/contract tests GREEN**

Expected: Synthetic Temple resolves all anchors and groups, barriers toggle, and invalid/missing Candidate contracts fail loudly.

- [ ] **Step 7: Commit**

```powershell
git -C $Worktree add -A src/ServerScriptService/Dungeon
git -C $Worktree diff --cached --check
git -C $Worktree commit -m "feat: add temple environment adapter"
```

---

### Task 7: Remove environment positions from Dungeon gameplay runtime

**Files:**
- Modify: `src/ServerScriptService/Dungeon/DungeonRuntime.server.luau`
- Modify: `src/ReplicatedStorage/Core/Shared/DungeonDefinitions.luau`
- Modify tests that explicitly inspect `MarauderCaptain.SpawnPosition`.

**Interfaces:**
- Consumes: `TempleEnvironmentAdapter` from Task 6.
- Preserves: `CheckpointService`, `EncounterService`, `CompletionService`, `ReturnPortalService`, `DungeonDeathService`, `DungeonSessionService`, reward/progression services.

- [ ] **Step 1: Write RED assertions proving runtime no longer owns map coordinates**

Add/extend a focused test that verifies `DungeonDefinitions.TEST_DUNGEON.MarauderCaptain.SpawnPosition == nil` and that the Temple adapter provides the Captain CFrame.

- [ ] **Step 2: Refactor runtime initialization**

Replace:

```luau
Workspace:WaitForChild("DungeonRuntime")
FindFirstChild("DungeonSpawn", true)
FindFirstChild("Room1StartTrigger", true)
...
```

with one adapter resolution:

```luau
local environment = TempleEnvironmentAdapter.resolve(Workspace)
assert(environment.ok, "Temple environment invalid: " .. tostring(environment.reason))
```

Store only semantic anchor references returned by the adapter.

- [ ] **Step 3: Register checkpoints from semantic anchors**

Use:
- `Entrance` -> `Temple.EntrySpawn`
- `Room1Start` -> `Temple.Room1.Checkpoint`
- `Room2Start` -> `Temple.Room2.Checkpoint`
- `BossRoomStart` -> `Temple.Room3.Checkpoint`

Keep existing sequence numbers 0/1/2/3 and current `CheckpointService` logic.

- [ ] **Step 4: Spawn ordinary Marauders from anchor CFrames**

Change the local helper to accept `CFrame`, not `Vector3`:

```luau
local function spawn_marauder(
    encounter_id: string,
    enemy_id: string,
    spawn_cframe: CFrame,
    spawn_index: number
): Model
```

Room 1 uses the first `MarauderCount` entries from the sorted Room 1 anchor group. Room 2 does the same for Room 2. Adapter validation rejects too few anchors before the encounter can start.

- [ ] **Step 5: Spawn the Captain from `Temple.Room3.CaptainSpawn`**

Replace `CFrame.new(DungeonDefinitions.TEST_DUNGEON.MarauderCaptain.SpawnPosition)` with `environment:captain_spawn_cframe()`.

Delete the `SpawnPosition` field from `DungeonDefinitions`. Keep MaxHealth/reward data there.

- [ ] **Step 6: Bind encounter triggers and barriers through adapter objects**

Room 1, Room 2 and Room 3 use semantic trigger Parts. Existing touched-player validation remains unchanged. On clear call `environment:set_exit_open("Room1", true)` / `Room2` instead of manipulating legacy greybox gates directly.

- [ ] **Step 7: Preserve completion and return authority**

Do not make `Temple.CompletionPosition` or `Temple.ReturnToBase` award rewards. Captain death remains the completion authority. The anchors are presentation/placement points only; `CompletionService` commits rewards and `ReturnPortalService` owns return eligibility/timing.

- [ ] **Step 8: Run Dungeon regression families and build**

```powershell
$Stamp = Get-Date -Format "yyyyMMdd_HHmmss"
rojo build default.project.json -o "$env:TEMP\DungeonMMO_BaseTemple_Dungeon_$Stamp.rbxl"
```

Expected: build succeeds; existing checkpoint/revive/reward/completion tests stay green; semantic Temple tests pass.

- [ ] **Step 9: Commit**

```powershell
git -C $Worktree add src/ServerScriptService/Dungeon/DungeonRuntime.server.luau src/ReplicatedStorage/Core/Shared/DungeonDefinitions.luau src/ServerScriptService/Dungeon/Tests src/ServerScriptService/Core/Tests
git -C $Worktree diff --cached --check
git -C $Worktree commit -m "refactor: drive dungeon runtime from temple anchors"
```

---

### Task 8: Add candidate staging and calibration tooling for the current LobbyScene and Temple

**Files:**
- Create: `tools/environment/Stage-EnvironmentCandidates.ps1`
- Modify: `BaseCandidateAnchorProfile.luau` after calibration.
- Modify: `TempleCandidateAnchorProfile.luau` after calibration.
- Create: `tools/environment/Print-EnvironmentAnchorDiagnostics.ps1` if useful for deterministic evidence capture.

**Interfaces:**
- Tool accepts `-LobbyGlb` and `-TemplePlace` paths.
- It validates exact current fingerprints, copies files only to a TEMP integration folder, and never invokes `git add` or publishes Roblox assets.

- [ ] **Step 1: Implement Windows PowerShell 5.1 staging script**

Required behavior:

```powershell
param(
    [Parameter(Mandatory=$true)][string]$LobbyGlb,
    [Parameter(Mandatory=$true)][string]$TemplePlace
)

$ExpectedLobby = "F624C96AF9F67BB374FE36752331A26B59C4C7E7AA8B228223AE4C04919E981B"
$ExpectedTemple = "A3039361882632E857228411A0F36BBA9086A22A37080FA2034CE2B25921BB32"
```

The script refuses mismatched files, creates `%TEMP%\DungeonMMO_EnvironmentCandidates_<timestamp>`, copies both assets there, prints their paths, and performs no repository mutation.

- [ ] **Step 2: Add Candidate-mode diagnostics**

When `Workspace:SetAttribute("DungeonMMOEnvironmentMode", "Candidate")` is set in Studio:
- Base bootstrap must print one line per resolved Base anchor and a final count.
- Dungeon bootstrap must print one line per resolved Temple anchor/group and a final count.
- Any missing landmark/profile entry is an error, not a Synthetic fallback.

- [ ] **Step 3: Calibrate the current LobbyScene profile**

Use the current imported LobbyScene only to choose sensible test positions. Prefer existing landmarks rather than absolute world CFrames. Verify:
- Player spawn is safe and walkable;
- arrival point is near the shared central area;
- selected Temple portal is reachable;
- trainers are not inside props/walls;
- Equipment is near a sensible service/forge location;
- Dungeon Board is visible near the portal/social route;
- placeholder Bank/Travel/Blacksmithing/Alchemy/Training anchors are accessible.

Record any offsets only in `BaseCandidateAnchorProfile.luau`.

- [ ] **Step 4: Calibrate the current Temple profile**

Open the supplied `Temple.rbxl`, run Candidate mode, and verify each semantic anchor is physically in the intended stage. Record current CFrames/selectors only in `TempleCandidateAnchorProfile.luau`.

Enemy spawns must have valid floor beneath them and enough separation for current Marauder collision. Checkpoint anchors must not overlap walls, roots, altar geometry or closed barriers.

- [ ] **Step 5: Prove future-replacement isolation**

Run a source search:

```powershell
$Forbidden = @(
    "Anchor_FastTravel_Central_Tree_Market",
    "Blacksmith_Forge",
    "HumanBarracks_01",
    "DungeonMMO_ThreeRoom"
)
foreach ($Needle in $Forbidden) {
    git -C $Worktree grep -n -- $Needle -- src |
        Where-Object { $_ -notmatch "CandidateAnchorProfile" } |
        ForEach-Object { throw "Candidate landmark leaked outside profile: $_" }
}
```

Expected: no candidate landmark names outside candidate profile files.

- [ ] **Step 6: Commit tooling/profile calibration**

```powershell
git -C $Worktree add tools/environment src/ServerScriptService/Base/BaseCandidateAnchorProfile.luau src/ServerScriptService/Dungeon/TempleCandidateAnchorProfile.luau
git -C $Worktree diff --cached --check
git -C $Worktree commit -m "test: calibrate lobby and temple candidate anchors"
```

---

### Task 9: Run complete automated regression and prepare the visual candidate build

**Files:**
- No production file should change unless a regression exposes a real defect.
- Update `docs/testing/phase2-environment-candidate-manifest.md` with build/test evidence only after commands actually pass.

**Interfaces:**
- Produces: fresh Base/Dungeon TEMP build paths plus a clean candidate branch ready for visual Studio evidence.

- [ ] **Step 1: Verify branch/change boundary and whitespace**

```powershell
git -C $Worktree status --short
git -C $Worktree diff --check
git -C $Worktree log --oneline --decorate -8
```

Expected: only intended gate changes; no art-worktree paths or binary candidate files.

- [ ] **Step 2: Build Base and Dungeon from the candidate branch**

```powershell
Set-Location $Worktree
$Stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$BaseOut = "$env:TEMP\DungeonMMO_BaseTemple_Base_$Stamp.rbxl"
$DungeonOut = "$env:TEMP\DungeonMMO_BaseTemple_Dungeon_$Stamp.rbxl"
rojo build base.project.json -o $BaseOut
if ($LASTEXITCODE -ne 0) { throw "Base Rojo build failed." }
rojo build default.project.json -o $DungeonOut
if ($LASTEXITCODE -ne 0) { throw "Dungeon Rojo build failed." }
Write-Host $BaseOut
Write-Host $DungeonOut
```

Expected: both builds exit 0.

- [ ] **Step 3: Run Synthetic Studio regression first**

Open the TEMP Base and Dungeon builds and collect automated output. Required new PASS families:
- Environment Anchor Resolver
- Environment Runtime Mode
- Base Environment Contract
- Temple Environment Adapter / Contract

Required existing families: no new red failures in Core/Base/Dungeon/Combat tests.

- [ ] **Step 4: Only after Synthetic is green, stage current visual candidates**

Use `Stage-EnvironmentCandidates.ps1`. Do not modify or publish the originals.

- [ ] **Step 5: Commit only test-evidence text if necessary**

No acceptance claim yet. Visual/runtime acceptance is still pending.

---

### Task 10: Project-owner Studio acceptance using the actual LobbyScene and Temple candidates

**Files:**
- No source changes unless a defect is discovered.

**Interfaces:**
- This is the first required project-owner visual gate.

- [ ] **Step 1: Base Candidate test**

Open/import the current LobbyScene into a Studio place, sync the Base project from the feature worktree, then set:

```luau
Workspace:SetAttribute("DungeonMMOEnvironmentMode", "Candidate")
```

Restart Play so bootstrap reads Candidate mode.

Confirm:
- no Synthetic floor/base shell appears;
- player spawns safely in LobbyScene;
- Temple portal and Dungeon Board are reachable;
- Fighter/Mage/Ranger trainer prompts open the correct server-authoritative catalogues;
- Equipment prompt opens accepted equipment UI;
- placeholder Bank/Travel/Blacksmithing/Alchemy anchors are physically sensible but do not pretend those systems exist;
- no red environment-contract/runtime errors.

- [ ] **Step 2: Temple Candidate test**

Open the supplied `Temple.rbxl`, sync the Dungeon project, set Candidate mode before Play, and use the existing Studio class override as required for the chosen test class.

Confirm:
- character begins at Temple entry safely;
- Room 1 root/cavern trigger starts correct encounter;
- Room 1 clear advances checkpoint/unlocks progression;
- Room 2 ruined-temple encounter behaves correctly;
- Room 2 clear advances checkpoint;
- Room 3 altar/sanctum starts the Captain;
- death/free-revive returns to the correct semantic checkpoint;
- Captain death commits normal completion rewards;
- Return to Base flow remains available/simulated correctly in Studio;
- no enemies spawn in walls/floor/void;
- no red runtime errors.

- [ ] **Step 3: Full class acceptance**

Run one complete Temple clear with one accepted class. Then spot-test the other two:
- Fighter: sword/shield Block/parry/Dodge + starter skills;
- Mage: Spirit Orb/Wind Strike/Ward/Heal and movement commitment;
- Ranger: Longbow Normal/Precision/Full Draw, no Block, Dodge, at least one Ranger skill.

- [ ] **Step 4: Future-change sanity check**

Temporarily move one Synthetic/Candidate anchor (not decorative geometry) and verify gameplay follows the anchor. Restore it afterward. This proves the runtime consumes semantic anchors rather than the old world coordinates.

- [ ] **Step 5: Obtain explicit acceptance**

Acceptance sentence:

> I spawn in our real town, prepare my character, enter our real Temple dungeon, fight through it using the class systems we've already built, get rewarded, return to the town, and everything I earned and equipped is still correct.

Do not merge before the project owner accepts this gate.

---

### Task 11: Acceptance commit, merge and continuity close-out

**Files:**
- Modify after acceptance: `docs/ai/CURRENT_STATE.md`
- Modify after acceptance: `docs/ai/HANDOFF.md`
- Modify after acceptance: `docs/ai/TEST_MATRIX.md`
- Update the external Roadmap only after the gameplay checkpoint exists, so it records the exact real SHA.

**Interfaces:**
- Produces: accepted gameplay commit/branch, fast-forwarded `main`, documentation closeout, updated roadmap baseline.

- [ ] **Step 1: Final verification before commit**

Fresh evidence required in the same closeout run:
- `git diff --check` clean;
- Base and Dungeon Rojo builds exit 0;
- Synthetic automated test output green;
- project-owner Candidate Studio acceptance recorded;
- feature branch based on `08d0711...` with no unrelated/art changes.

- [ ] **Step 2: Commit accepted gameplay/content integration**

Stage only the reviewed implementation boundary and run:

```powershell
git diff --cached --check
git commit -m "feat: integrate starting base and temple candidates"
```

Record the resulting gameplay SHA.

- [ ] **Step 3: Push feature branch**

```powershell
git push -u origin wip/phase-2-starting-base-temple-integration
```

Verify remote branch SHA equals local feature SHA.

- [ ] **Step 4: Fast-forward `main` only**

In the clean primary main worktree:

```powershell
git fetch origin
git merge --ff-only wip/phase-2-starting-base-temple-integration
```

Rebuild Base and Dungeon from main before push. Then push main and independently verify GitHub main SHA.

- [ ] **Step 5: Write continuity close-out with exact evidence**

Update `CURRENT_STATE.md`, `HANDOFF.md` and `TEST_MATRIX.md` to state exactly what was observed. Preserve all older evidence qualifications. Explicitly state that LobbyScene/Temple remain replaceable Candidate environments behind semantic anchors and are not final production art contracts.

- [ ] **Step 6: Commit/push docs close-out and update Roadmap**

Create a docs-only commit after gameplay merge. Generate the next Roadmap revision with the actual gameplay and docs SHAs, then verify local main, origin/main and GitHub main are identical and ahead/behind is 0/0.

- [ ] **Step 7: Do not delete the feature worktree/branch automatically**

Preserve it until the user explicitly approves cleanup.

---

## Plan self-review

### Spec coverage

- Semantic replaceability of Lobby/Temple: Tasks 2, 3, 4, 6, 8.
- Current LobbyScene as Base candidate: Tasks 4, 5, 8, 10.
- Current Temple as three-stage dungeon candidate: Tasks 6, 7, 8, 10.
- Existing Base admission/teleport authority preserved: Task 5.
- Existing Dungeon checkpoint/encounter/reward/completion/return authority preserved: Task 7.
- Missing/duplicate anchor failure: Task 2.
- Synthetic automated regression support without production fallback: Tasks 3, 4, 6, 9.
- Fighter/Mage/Ranger regressions: Tasks 9, 10.
- No professions/party/rare-state/final-art scope creep: Global Constraints.
- Future environment replacement: Candidate profile isolation check in Task 8 plus semantic anchor sanity test in Task 10.
- Git/publish/PROD/art-worktree safety: Tasks 1 and 11 plus Global Constraints.

### Placeholder scan

No placeholder markers or vague implementation steps remain. Candidate calibration is an explicit test task with fixed semantic outputs and does not leak its values into gameplay code.

### Type/interface consistency

- Anchor resolver always returns BasePart-backed semantic anchors.
- Base and Temple adapters consume the same anchor-definition/resolver contract.
- Dungeon spawn methods use `CFrame` consistently.
- Existing checkpoint IDs (`Entrance`, `Room1Start`, `Room2Start`, `BossRoomStart`) remain unchanged, preserving persistent/recovery semantics.
- Existing dungeon ID remains `TestDungeon` in this gate, avoiding unnecessary session/persistence migrations while the Temple candidate is being proven.

## Execution recommendation

Use **inline execution in this session** with the plan applied task-by-task in one isolated worktree. The assistant should continue autonomously through Tasks 1-9 and stop only at Task 10 for the actual LobbyScene/Temple Studio visual/runtime acceptance, matching the user's established preference.
