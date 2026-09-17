# Phase 3 Bestiary + Reputation Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add persistent, server-authoritative bestiary knowledge and Scholars reputation driven atomically by already-valid monster reward transactions.

**Architecture:** Keep the existing monster reward transaction as the only kill/progression authority. Add data-driven bestiary/reputation definitions plus pure character mutation helpers, migrate profiles from schema v9 to v10, and integrate milestone/reputation application inside `RewardService:grant_monster_reward` after its existing persistent duplicate check. Runtime services expose read-only Bestiary/Reputation services for future consumers, but no client can submit kill counts or reputation.

**Tech Stack:** Roblox Luau (`--!strict`), Rojo, Rokit, Git worktrees, existing `ProfileService` / `ProfileMigration` / `RewardService` / `RuntimeServices`, Roblox Studio runtime tests.

**Spec:** `docs/superpowers/specs/2026-09-17-phase-3-bestiary-reputation-foundation-design.md`

## Global Constraints

- Start from exact local design checkpoint `e8245fc94a3d8dae21f2ee0d059533f0c907d8ec`.
- `origin/main` remains intentionally stale unless the project owner separately authorises a push.
- Create a dedicated external feature worktree; do not implement directly on `main`.
- Do not reset hard, clean, force-push, rewrite history, publish Roblox places, or touch `DungeonMMO_Art`.
- Preserve all accepted Phase 2 and Phase 3 Quest/Advancement, Contribution and Recipe-Knowledge behaviour.
- Advance profile schema exactly **v9 -> v10**.
- Bestiary/Reputation state is character-scoped.
- Bestiary and reputation grant **no combat power** in this gate.
- The client never submits authoritative kill counts, milestone unlocks, or reputation points.
- The existing `RewardService:grant_monster_reward(member_user_ids, monster_reward, transaction_id)` method remains the kill/reward authority and keeps its public signature.
- `monster_reward.BestiaryCreatureId` is optional and server-owned. Missing/unknown bestiary content never blocks ordinary XP/Gold rewards.
- Every production task follows RED -> verify RED -> minimal GREEN -> verify GREEN -> commit.
- Build validation files only into timestamped TEMP paths.
- Stop before merge, push or publish. Project-owner Studio evidence is the final runtime gate.

---

## File Structure

### New shared definition modules

- `src/ReplicatedStorage/Core/Shared/BestiaryDefinitions.luau`
  - Owns stable creature IDs and ordered knowledge milestones.
  - Exposes `get`, `all`, and `validate`.
- `src/ReplicatedStorage/Core/Shared/ReputationDefinitions.luau`
  - Owns faction IDs.
  - Exposes `get`, `all`, and `validate`.

### New server services

- `src/ServerScriptService/Core/Services/BestiaryService.luau`
  - Pure mutation helper for valid kill progress.
  - Read-only profile snapshot wrapper for future consumers.
- `src/ServerScriptService/Core/Services/ReputationService.luau`
  - Pure mutation helper for validated reputation points.
  - Read-only profile snapshot wrapper.

### New focused tests

- `src/ServerScriptService/Core/Tests/BestiaryDefinitionsTest.server.luau`
- `src/ServerScriptService/Core/Tests/ReputationDefinitionsTest.server.luau`
- `src/ServerScriptService/Core/Tests/ProfileMigrationBestiaryReputationV10Test.server.luau`
- `src/ServerScriptService/Core/Tests/BestiaryServiceTest.server.luau`
- `src/ServerScriptService/Core/Tests/ReputationServiceTest.server.luau`
- `src/ServerScriptService/Core/Tests/BestiaryReputationRewardIntegrationTest.server.luau`
- `src/ServerScriptService/Core/Tests/BestiaryReputationRuntimeCompositionTest.server.luau`

### Existing files to modify

- `src/ReplicatedStorage/Core/Shared/ProfileSchema.luau`
- `src/ReplicatedStorage/Core/Shared/DungeonDefinitions.luau`
- `src/ServerScriptService/Core/Services/ProfileMigration.luau`
- `src/ServerScriptService/Core/Services/RewardService.luau`
- `src/ServerScriptService/Core/Services/RuntimeServices.luau`
- Historical schema-result assertions that still hard-code current schema v9, discovered by exact search during Task 2.

---

### Task 1: Bestiary and Reputation Definition Contracts

**Files:**
- Create: `src/ReplicatedStorage/Core/Shared/BestiaryDefinitions.luau`
- Create: `src/ReplicatedStorage/Core/Shared/ReputationDefinitions.luau`
- Create: `src/ServerScriptService/Core/Tests/BestiaryDefinitionsTest.server.luau`
- Create: `src/ServerScriptService/Core/Tests/ReputationDefinitionsTest.server.luau`

**Interfaces:**
- Produces:
  - `BestiaryDefinitions.get(creature_id: string): any?`
  - `BestiaryDefinitions.all(): {[string]: any}`
  - `BestiaryDefinitions.validate(): (boolean, string?)`
  - `ReputationDefinitions.get(faction_id: string): any?`
  - `ReputationDefinitions.all(): {[string]: any}`
  - `ReputationDefinitions.validate(): (boolean, string?)`
- Consumes: no new Phase 3 service state.

- [ ] **Step 1: Write the failing Bestiary definition test**

Create `BestiaryDefinitionsTest.server.luau` with assertions equivalent to:

```luau
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")

local module = Shared:FindFirstChild("BestiaryDefinitions")
if not module then
    error("[Bestiary Definitions Tests] RED: BestiaryDefinitions is missing.")
end

local BestiaryDefinitions = require(module)
local assertions = 0

local function check(condition: boolean, message: string)
    assertions += 1
    if not condition then
        error("[Bestiary Definitions Tests] " .. message, 2)
    end
end

local valid, reason = BestiaryDefinitions.validate()
check(valid == true, reason or "Definitions must validate.")

local marauder = assert(BestiaryDefinitions.get("marauder"))
check(marauder.DisplayName == "Marauder", "Marauder display name mismatch.")
check(#marauder.Milestones == 3, "Marauder must have three proof milestones.")
check(marauder.Milestones[1].Id == "first_defeat", "First milestone mismatch.")
check(marauder.Milestones[1].RequiredKills == 1, "First threshold must be 1.")
check(marauder.Milestones[2].RequiredKills == 5, "Second threshold must be 5.")
check(marauder.Milestones[3].RequiredKills == 15, "Third threshold must be 15.")

local captain = assert(BestiaryDefinitions.get("marauder_captain"))
check(#captain.Milestones == 2, "Captain must have two proof milestones.")
check(captain.Milestones[1].RequiredKills == 1, "Captain first threshold must be 1.")
check(captain.Milestones[2].RequiredKills == 3, "Captain second threshold must be 3.")

print(string.format("[Bestiary Definitions Tests] PASS: %d assertions.", assertions))
```

- [ ] **Step 2: Write the failing Reputation definition test**

Create `ReputationDefinitionsTest.server.luau`:

```luau
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")

local module = Shared:FindFirstChild("ReputationDefinitions")
if not module then
    error("[Reputation Definitions Tests] RED: ReputationDefinitions is missing.")
end

local ReputationDefinitions = require(module)
local assertions = 0

local function check(condition: boolean, message: string)
    assertions += 1
    if not condition then
        error("[Reputation Definitions Tests] " .. message, 2)
    end
end

local valid, reason = ReputationDefinitions.validate()
check(valid == true, reason or "Definitions must validate.")

local scholars = assert(ReputationDefinitions.get("Scholars"))
check(scholars.DisplayName == "Scholars", "Scholars display name mismatch.")
check(ReputationDefinitions.get("UnknownFaction") == nil, "Unknown faction must not resolve.")

print(string.format("[Reputation Definitions Tests] PASS: %d assertions.", assertions))
```

- [ ] **Step 3: Build Base once to establish RED**

```powershell
rojo build .\base.project.json -o "$env:TEMP\DungeonMMO_BestiaryRep_RED_Definitions.rbxl"
```

Expected: build succeeds because missing modules are runtime RED tests; do not ask the project owner for Studio yet.

- [ ] **Step 4: Implement `ReputationDefinitions.luau` minimally**

```luau
--!strict
local ReputationDefinitions = {}

local DEFINITIONS = table.freeze({
    Scholars = table.freeze({
        Id = "Scholars",
        DisplayName = "Scholars",
    }),
})

function ReputationDefinitions.get(faction_id: string): any?
    return DEFINITIONS[faction_id]
end

function ReputationDefinitions.all(): {[string]: any}
    return DEFINITIONS
end

function ReputationDefinitions.validate(): (boolean, string?)
    for faction_id, definition in pairs(DEFINITIONS) do
        if type(faction_id) ~= "string" or faction_id == "" then
            return false, "InvalidFactionId"
        end
        if type(definition) ~= "table"
            or definition.Id ~= faction_id
            or type(definition.DisplayName) ~= "string"
            or definition.DisplayName == ""
        then
            return false, "InvalidFactionDefinition:" .. faction_id
        end
    end
    return true, nil
end

return table.freeze(ReputationDefinitions)
```

- [ ] **Step 5: Implement `BestiaryDefinitions.luau` minimally**

```luau
--!strict
local ReputationDefinitions = require(script.Parent:WaitForChild("ReputationDefinitions"))

local BestiaryDefinitions = {}

local DEFINITIONS = table.freeze({
    marauder = table.freeze({
        Id = "marauder",
        DisplayName = "Marauder",
        Milestones = table.freeze({
            table.freeze({
                Id = "first_defeat",
                RequiredKills = 1,
                Reputation = table.freeze({FactionId = "Scholars", Points = 5}),
            }),
            table.freeze({
                Id = "field_notes",
                RequiredKills = 5,
                Reputation = table.freeze({FactionId = "Scholars", Points = 10}),
            }),
            table.freeze({
                Id = "dossier_complete",
                RequiredKills = 15,
                Reputation = table.freeze({FactionId = "Scholars", Points = 20}),
            }),
        }),
    }),
    marauder_captain = table.freeze({
        Id = "marauder_captain",
        DisplayName = "Marauder Captain",
        Milestones = table.freeze({
            table.freeze({
                Id = "captain_defeated",
                RequiredKills = 1,
                Reputation = table.freeze({FactionId = "Scholars", Points = 15}),
            }),
            table.freeze({
                Id = "captain_studied",
                RequiredKills = 3,
                Reputation = table.freeze({FactionId = "Scholars", Points = 25}),
            }),
        }),
    }),
})

function BestiaryDefinitions.get(creature_id: string): any?
    return DEFINITIONS[creature_id]
end

function BestiaryDefinitions.all(): {[string]: any}
    return DEFINITIONS
end

function BestiaryDefinitions.validate(): (boolean, string?)
    local rep_ok, rep_reason = ReputationDefinitions.validate()
    if not rep_ok then
        return false, rep_reason
    end

    for creature_id, definition in pairs(DEFINITIONS) do
        if definition.Id ~= creature_id
            or type(definition.DisplayName) ~= "string"
            or type(definition.Milestones) ~= "table"
        then
            return false, "InvalidCreatureDefinition:" .. creature_id
        end

        local seen = {}
        local last_required = 0
        for _, milestone in ipairs(definition.Milestones) do
            if type(milestone.Id) ~= "string"
                or milestone.Id == ""
                or seen[milestone.Id]
                or type(milestone.RequiredKills) ~= "number"
                or milestone.RequiredKills % 1 ~= 0
                or milestone.RequiredKills <= last_required
            then
                return false, "InvalidMilestone:" .. creature_id
            end

            local reward = milestone.Reputation
            if type(reward) ~= "table"
                or ReputationDefinitions.get(reward.FactionId) == nil
                or type(reward.Points) ~= "number"
                or reward.Points % 1 ~= 0
                or reward.Points <= 0
            then
                return false, "InvalidMilestoneReward:" .. creature_id
            end

            seen[milestone.Id] = true
            last_required = milestone.RequiredKills
        end
    end

    return true, nil
end

return table.freeze(BestiaryDefinitions)
```

- [ ] **Step 6: Run clean Base and Dungeon builds**

```powershell
rojo build .\base.project.json -o "$env:TEMP\DungeonMMO_BestiaryRep_GREEN_Definitions_Base.rbxl"
rojo build .\default.project.json -o "$env:TEMP\DungeonMMO_BestiaryRep_GREEN_Definitions_Dungeon.rbxl"
git diff --check
```

- [ ] **Step 7: Commit Task 1**

```powershell
git add `
  src/ReplicatedStorage/Core/Shared/BestiaryDefinitions.luau `
  src/ReplicatedStorage/Core/Shared/ReputationDefinitions.luau `
  src/ServerScriptService/Core/Tests/BestiaryDefinitionsTest.server.luau `
  src/ServerScriptService/Core/Tests/ReputationDefinitionsTest.server.luau

git commit -m "feat(phase3): add bestiary reputation definitions"
```

---

### Task 2: Schema v10 and Migration

**Files:**
- Modify: `src/ReplicatedStorage/Core/Shared/ProfileSchema.luau`
- Modify: `src/ServerScriptService/Core/Services/ProfileMigration.luau`
- Create: `src/ServerScriptService/Core/Tests/ProfileMigrationBestiaryReputationV10Test.server.luau`
- Modify only as required: historical migration tests whose assertion describes the current resulting schema as v9.

**Interfaces:**
- Produces character state:
  - `character.Bestiary.Version == 1`
  - `character.Bestiary.Entries`
  - `character.Reputation.Version == 1`
  - `character.Reputation.Factions.Scholars.Points`
- Preserves all schema-v9 fields.

- [ ] **Step 1: Search before editing historical schema assertions**

```powershell
git grep -n -E "SchemaVersion.*9|schema v9|migrate to v9|VERSION.*9" -- `
  src/ServerScriptService/Core/Tests `
  src/ReplicatedStorage/Core/Shared/ProfileSchema.luau
```

Classify each hit:
- historical fixture input remains `9`;
- assertions about the current migration result become `10` or `ProfileSchema.VERSION`;
- historical prose describing the recipe-learning v9 boundary stays v9.

- [ ] **Step 2: Write the failing v9 -> v10 migration test**

Required assertions include:

```luau
check(ProfileSchema.VERSION == 10, "Current schema must be v10.")
check(migrated.SchemaVersion == 10, "v9 profile must migrate to v10.")
check(migrated.Characters.Slot1.Bestiary.Version == 1, "Bestiary version missing.")
check(next(migrated.Characters.Slot1.Bestiary.Entries) == nil, "Migration must not invent discoveries.")
check(migrated.Characters.Slot1.Reputation.Version == 1, "Reputation version missing.")
check(
    migrated.Characters.Slot1.Reputation.Factions.Scholars.Points == 0,
    "Migrated Scholars reputation must start at zero."
)
```

Also test malformed:
- `Kills = -2` -> `0`;
- `Points = 2.5` -> `0`;
- non-boolean milestone values removed;
- second migration is idempotent;
- sentinel Quest, ClassAdvancement, Professions and CraftingKnowledge fields survive unchanged.

- [ ] **Step 3: Build Base to establish RED**

```powershell
rojo build .\base.project.json -o "$env:TEMP\DungeonMMO_BestiaryRep_RED_Migration.rbxl"
```

- [ ] **Step 4: Add default v10 state in `ProfileSchema`**

Set `ProfileSchema.VERSION = 10` and add:

```luau
Bestiary = {
    Version = 1,
    Entries = {},
},
Reputation = {
    Version = 1,
    Factions = {
        Scholars = {
            Points = 0,
        },
    },
},
```

Do not alter accepted Quest, ClassAdvancement, Professions, CraftingKnowledge, Inventory, Equipment, progression, identity or reward-history defaults.

- [ ] **Step 5: Add migration/sanitization helpers**

Implement:

```luau
local function sanitize_non_negative_integer(value: any): number
    if type(value) == "number"
        and value == value
        and value >= 0
        and value < math.huge
        and value % 1 == 0
    then
        return value
    end
    return 0
end
```

Then implement `migrate_bestiary(raw)` and `migrate_reputation(raw)` exactly to:
- create version-1 tables;
- preserve valid non-negative integer counters;
- preserve only `milestone_id -> true`;
- preserve valid Scholars points;
- default malformed values to zero/empty;
- never invent milestone unlocks.

Apply both to each character before the final current `SchemaVersion` assignment.

- [ ] **Step 6: Update only stale current-schema assertions**

Prefer:

```luau
check(
    migrated.SchemaVersion == ProfileSchema.VERSION,
    "Historical profile must migrate to the current schema."
)
```

Do not alter fixture lines such as `raw.SchemaVersion = 9`.

- [ ] **Step 7: Build both projects and verify diff**

```powershell
rojo build .\base.project.json -o "$env:TEMP\DungeonMMO_BestiaryRep_GREEN_Migration_Base.rbxl"
rojo build .\default.project.json -o "$env:TEMP\DungeonMMO_BestiaryRep_GREEN_Migration_Dungeon.rbxl"
git diff --check
```

- [ ] **Step 8: Stage only migration-related files and commit**

Inspect:

```powershell
git diff --cached --name-only
```

before:

```powershell
git commit -m "feat(phase3): persist bestiary reputation state"
```

---

### Task 3: Reputation Service

**Files:**
- Create: `src/ServerScriptService/Core/Services/ReputationService.luau`
- Create: `src/ServerScriptService/Core/Tests/ReputationServiceTest.server.luau`

**Interfaces:**
- Consumes: `ReputationDefinitions`, `ProfileService`.
- Produces:
  - `ReputationService.new(profile_service: any): any`
  - `ReputationService.apply_points_to_character(character: any, faction_id: string, points: number): any`
  - `ReputationService:get_snapshot(user_id: number): any`

- [ ] **Step 1: Write RED tests**

Cover:
- +5 Scholars -> 5;
- +10 -> 15;
- unknown faction -> `UnknownFaction`;
- zero/negative/fractional/NaN/infinity -> `InvalidPoints`;
- failure leaves state unchanged;
- snapshot is a deep clone.

Core:

```luau
local first = ReputationService.apply_points_to_character(
    character,
    "Scholars",
    5
)
check(first.ok == true and first.new_points == 5, "First award must reach 5.")
```

- [ ] **Step 2: Verify RED**

Build Base; the runtime test must report missing `ReputationService`.

- [ ] **Step 3: Implement the pure helper**

```luau
function ReputationService.apply_points_to_character(
    character: any,
    faction_id: string,
    points: number
): any
    if ReputationDefinitions.get(faction_id) == nil then
        return {ok = false, reason = "UnknownFaction"}
    end

    if type(points) ~= "number"
        or points ~= points
        or points <= 0
        or points >= math.huge
        or points % 1 ~= 0
    then
        return {ok = false, reason = "InvalidPoints"}
    end

    if type(character) ~= "table"
        or type(character.Reputation) ~= "table"
        or type(character.Reputation.Factions) ~= "table"
    then
        return {ok = false, reason = "ReputationUnavailable"}
    end

    local state = character.Reputation.Factions[faction_id]
    if type(state) ~= "table" or type(state.Points) ~= "number" then
        return {ok = false, reason = "ReputationUnavailable"}
    end

    state.Points += points
    return {
        ok = true,
        faction_id = faction_id,
        points_granted = points,
        new_points = state.Points,
    }
end
```

- [ ] **Step 4: Implement read-only instance wrapper**

`get_snapshot(user_id)` calls `get_character(user_id, 1)`, returns
`{ok=false, reason="ProfileNotLoaded"}` when absent, otherwise returns a
`ProfileSchema.deep_clone(character.Reputation)` result.

- [ ] **Step 5: Build, diff-check and commit**

```powershell
rojo build .\base.project.json -o "$env:TEMP\DungeonMMO_BestiaryRep_GREEN_Reputation_Base.rbxl"
rojo build .\default.project.json -o "$env:TEMP\DungeonMMO_BestiaryRep_GREEN_Reputation_Dungeon.rbxl"
git diff --check
git add src/ServerScriptService/Core/Services/ReputationService.luau `
        src/ServerScriptService/Core/Tests/ReputationServiceTest.server.luau
git commit -m "feat(phase3): add reputation service"
```

---

### Task 4: Bestiary Service

**Files:**
- Create: `src/ServerScriptService/Core/Services/BestiaryService.luau`
- Create: `src/ServerScriptService/Core/Tests/BestiaryServiceTest.server.luau`

**Interfaces:**
- Consumes: `BestiaryDefinitions`, `ProfileService`.
- Produces:
  - `BestiaryService.new(profile_service: any): any`
  - `BestiaryService.apply_kill_to_character(character: any, creature_id: string): any`
  - `BestiaryService:get_snapshot(user_id: number): any`
- The pure helper returns milestone reward metadata but does not award reputation.

- [ ] **Step 1: Write RED milestone tests**

Prove:
- Marauder kill 1 unlocks `first_defeat`;
- kills 2-4 unlock nothing;
- kill 5 unlocks `field_notes`;
- kill 15 unlocks `dossier_complete`;
- Captain kill 1/3 unlock independently;
- undefined creature is `{ok=true, tracked=false}` and does not create state.

Core:

```luau
local first = BestiaryService.apply_kill_to_character(character, "marauder")
check(first.ok == true, "First Marauder kill must succeed.")
check(first.kill_count == 1, "First Marauder kill count must be 1.")
check(#first.newly_unlocked == 1, "First kill must unlock one milestone.")
check(first.newly_unlocked[1].id == "first_defeat", "Wrong first milestone.")
```

- [ ] **Step 2: Verify RED**

Build Base; runtime test must report missing `BestiaryService`.

- [ ] **Step 3: Implement `apply_kill_to_character`**

Required result:

```luau
{
    ok = true,
    tracked = true,
    creature_id = creature_id,
    kill_count = entry.Kills,
    newly_unlocked = {
        {
            id = milestone.Id,
            reputation = {
                faction_id = milestone.Reputation.FactionId,
                points = milestone.Reputation.Points,
            },
        },
    },
}
```

Algorithm:
1. resolve definition;
2. unknown definition -> safe tracked=false no-op;
3. require valid `character.Bestiary.Entries`;
4. lazily create `{Kills=0, Milestones={}}`;
5. increment exactly once;
6. unlock only newly satisfied ordered milestones;
7. mark them before returning;
8. return copied metadata, not mutable definition references.

- [ ] **Step 4: Implement snapshot wrapper**

Same pattern as ReputationService, returning a deep clone of `character.Bestiary`.

- [ ] **Step 5: Build, diff-check and commit**

```powershell
rojo build .\base.project.json -o "$env:TEMP\DungeonMMO_BestiaryRep_GREEN_Bestiary_Base.rbxl"
rojo build .\default.project.json -o "$env:TEMP\DungeonMMO_BestiaryRep_GREEN_Bestiary_Dungeon.rbxl"
git diff --check
git add src/ServerScriptService/Core/Services/BestiaryService.luau `
        src/ServerScriptService/Core/Tests/BestiaryServiceTest.server.luau
git commit -m "feat(phase3): add bestiary service"
```

---

### Task 5: Atomic RewardService Integration

**Files:**
- Modify: `src/ReplicatedStorage/Core/Shared/DungeonDefinitions.luau`
- Modify: `src/ServerScriptService/Core/Services/RewardService.luau`
- Create: `src/ServerScriptService/Core/Tests/BestiaryReputationRewardIntegrationTest.server.luau`
- Modify narrowly if needed: `src/ServerScriptService/Core/Tests/RewardServiceTest.server.luau`

**Interfaces:**
- Keeps:
  - `RewardService:grant_monster_reward(member_user_ids: {number}, monster_reward: any, transaction_id: string): any`
- Adds optional server-owned:
  - `monster_reward.BestiaryCreatureId: string?`
- Consumes:
  - `BestiaryService.apply_kill_to_character`
  - `ReputationService.apply_points_to_character`

- [ ] **Step 1: Extend `DungeonDefinitions.TEST_DUNGEON`**

```luau
StandardMarauderReward = table.freeze({
    XP = 10,
    GoldMin = 3,
    GoldMax = 6,
    BestiaryCreatureId = "marauder",
}),

MarauderCaptainReward = table.freeze({
    XP = 40,
    GoldMin = 15,
    GoldMax = 25,
    BestiaryCreatureId = "marauder_captain",
}),
```

Do not parse names or transaction IDs into creature identity.

- [ ] **Step 2: Write the integration RED test**

Call a real `RewardService` with:

```luau
local result = rewards:grant_monster_reward(
    {user_id},
    {
        XP = 10,
        GoldMin = 3,
        GoldMax = 3,
        BestiaryCreatureId = "marauder",
    },
    "Bestiary:session-a:marauder-1"
)
```

After first call assert:
- XP +10;
- Gold +3;
- Marauder Kills = 1;
- `first_defeat == true`;
- Scholars = 5;
- member result has bestiary/reputation diagnostics.

Replay the same transaction and assert no field changes.

Save/release/reload, create a new RewardService, replay again, and prove persistent idempotency.

Call a reward **without** `BestiaryCreatureId`; XP/Gold must apply with no bestiary/reputation state change.

- [ ] **Step 3: Verify RED**

The integration test must fail because current RewardService ignores the optional identity field.

- [ ] **Step 4: Require the services without changing constructor signature**

```luau
local BestiaryService = require(script.Parent:WaitForChild("BestiaryService"))
local ReputationService = require(script.Parent:WaitForChild("ReputationService"))
```

- [ ] **Step 5: Integrate only inside the existing duplicate-protected mutation**

After the existing persisted `already` check and existing XP/Gold application:

```luau
local bestiary_result: any = nil
local reputation_awards = {}

local creature_id = monster_reward.BestiaryCreatureId
if type(creature_id) == "string" and creature_id ~= "" then
    bestiary_result = BestiaryService.apply_kill_to_character(
        character,
        creature_id
    )

    if bestiary_result.ok ~= true then
        error(bestiary_result.reason or "BestiaryApplyFailed")
    end

    for _, milestone in ipairs(bestiary_result.newly_unlocked or {}) do
        local reward = milestone.reputation
        if type(reward) == "table" then
            local rep = ReputationService.apply_points_to_character(
                character,
                reward.faction_id,
                reward.points
            )
            if rep.ok ~= true then
                error(rep.reason or "ReputationApplyFailed")
            end

            table.insert(reputation_awards, {
                FactionId = rep.faction_id,
                PointsGranted = rep.points_granted,
                NewPoints = rep.new_points,
                MilestoneId = milestone.id,
            })
        end
    end
end
```

Store diagnostics in the existing monster history record and return equivalent member diagnostics. Existing-history replay must read stored diagnostics and must **not** call either helper again.

- [ ] **Step 6: Preserve optional compatibility**

Current reward tables without `BestiaryCreatureId` remain valid.

When present:
- non-empty string accepted;
- unknown string is safe no-op;
- present non-string value returns `InvalidMonsterReward`.

- [ ] **Step 7: Build and regression-check**

```powershell
rojo build .\base.project.json -o "$env:TEMP\DungeonMMO_BestiaryRep_GREEN_Reward_Base.rbxl"
rojo build .\default.project.json -o "$env:TEMP\DungeonMMO_BestiaryRep_GREEN_Reward_Dungeon.rbxl"
git diff --check
```

Expected later Studio lines include:

```text
[Reward Service Tests] PASS
[Bestiary Reputation Reward Integration Tests] PASS
```

- [ ] **Step 8: Commit Task 5**

```powershell
git add `
  src/ReplicatedStorage/Core/Shared/DungeonDefinitions.luau `
  src/ServerScriptService/Core/Services/RewardService.luau `
  src/ServerScriptService/Core/Tests/BestiaryReputationRewardIntegrationTest.server.luau `
  src/ServerScriptService/Core/Tests/RewardServiceTest.server.luau

git diff --cached --check
git commit -m "feat(phase3): integrate bestiary reputation rewards"
```

---

### Task 6: Runtime Composition and Automated Gate

**Files:**
- Modify: `src/ServerScriptService/Core/Services/RuntimeServices.luau`
- Create: `src/ServerScriptService/Core/Tests/BestiaryReputationRuntimeCompositionTest.server.luau`

**Interfaces:**
- Produces:
  - `runtime.BestiaryService`
  - `runtime.ReputationService`
- No client mutation remote is added.

- [ ] **Step 1: Write RED composition test**

Instantiate Base and Dungeon runtime composition and assert both services are present.

Also inspect `ReplicatedStorage.Core.Remotes` if it exists and assert these mutation remotes do not exist:
- `BestiaryKillRequest`
- `SetBestiaryProgress`
- `ReputationAwardRequest`
- `SetReputation`

- [ ] **Step 2: Verify RED**

Expected failure: Bestiary/Reputation services absent from RuntimeServices.

- [ ] **Step 3: Compose services**

Require:

```luau
local BestiaryService = require(Services:WaitForChild("BestiaryService"))
local ReputationService = require(Services:WaitForChild("ReputationService"))
```

Construct from the same `profiles` instance:

```luau
local bestiary = BestiaryService.new(profiles)
local reputation = ReputationService.new(profiles)
```

Return:

```luau
BestiaryService = bestiary,
ReputationService = reputation,
```

Preserve RecipeKnowledgeService, QuestService, ClassAdvancementService, ContributionService and every prior runtime service.

- [ ] **Step 4: Parse and diff-check source**

Run:

```powershell
git diff --check
git status --short
git diff --stat
```

Then syntax-parse every `.lua`/`.luau` under `src` with the verified Luau compiler (`luau-compile.exe --null --only-parse`), using the same SHA-verified tool flow as the previous gate.

- [ ] **Step 5: Build all four Rojo variants**

```powershell
$Stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$Out = Join-Path $env:TEMP "DungeonMMO_BestiaryReputation_$Stamp"
New-Item -ItemType Directory -Force $Out | Out-Null

rojo build .\base.project.json -o (Join-Path $Out "Base.rbxl")
rojo build .\default.project.json -o (Join-Path $Out "Dungeon.rbxl")
rojo build .\published-base.project.json -o (Join-Path $Out "PublishedBase.rbxl")
rojo build .\published-dungeon.project.json -o (Join-Path $Out "PublishedDungeon.rbxl")
```

- [ ] **Step 6: Review exact feature boundary**

```powershell
git diff e8245fc94a3d8dae21f2ee0d059533f0c907d8ec --name-only
git diff e8245fc94a3d8dae21f2ee0d059533f0c907d8ec --stat
git diff e8245fc94a3d8dae21f2ee0d059533f0c907d8ec --check
```

Reject unrelated UI, art, combat, market, guild, monetisation or environment changes.

- [ ] **Step 7: Commit Task 6**

```powershell
git add `
  src/ServerScriptService/Core/Services/RuntimeServices.luau `
  src/ServerScriptService/Core/Tests/BestiaryReputationRuntimeCompositionTest.server.luau

git commit -m "feat(phase3): compose bestiary reputation runtime"
```

---

### Task 7: Feature Checkpoint and Runtime Acceptance

**Files:**
- No production changes unless runtime evidence reveals a real defect.
- Produce TEMP builds and receipt only.
- Do not merge/push/publish.

**Interfaces:**
- Consumes Tasks 1-6.
- Produces a candidate feature checkpoint for project-owner acceptance.

- [ ] **Step 1: Verify clean feature branch**

```powershell
git status --short
git diff --check
git log --oneline --decorate -10
```

- [ ] **Step 2: Build fresh acceptance Base/Dungeon files**

```powershell
$Stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$Acceptance = Join-Path $env:TEMP "DungeonMMO_BestiaryReputation_Acceptance_$Stamp"
New-Item -ItemType Directory -Force $Acceptance | Out-Null

rojo build .\base.project.json -o (Join-Path $Acceptance "Base_BestiaryReputation.rbxl")
rojo build .\default.project.json -o (Join-Path $Acceptance "Dungeon_BestiaryReputation.rbxl")
```

- [ ] **Step 3: Project-owner Base Studio evidence**

Required green signals:
- `[Bestiary Definitions Tests] PASS`
- `[Reputation Definitions Tests] PASS`
- `[Profile Migration Bestiary Reputation V10 Tests] PASS`
- `[Bestiary Service Tests] PASS`
- `[Reputation Service Tests] PASS`
- `[Bestiary Reputation Reward Integration Tests] PASS`
- `[Bestiary Reputation Runtime Composition Tests] PASS`
- existing Recipe Knowledge tests PASS;
- existing Quest/Advancement migration PASS;
- normal Base identity/profile lifecycle completes;
- no new actual errors/stacks/module-load failures.

- [ ] **Step 4: Project-owner Dungeon Studio evidence**

Required:
- same Bestiary/Reputation tests PASS;
- RewardService regressions PASS;
- Dungeon reaches ready/admission;
- Marauder/Captain reward flow does not break XP/Gold/completion;
- no new actual errors/stacks/module-load failures.

Known Temple invalid-surface resource warnings remain non-blocking unless they cause test/runtime failure.

- [ ] **Step 5: Record the candidate checkpoint**

If branch is already fully committed, do not create an empty commit.

```powershell
git rev-parse HEAD
git rev-parse main
git rev-list --left-right --count main...HEAD
```

Write a TEMP receipt with:
- design baseline `e8245fc94a3d8dae21f2ee0d059533f0c907d8ec`;
- feature branch and HEAD;
- schema v10;
- four-build verification;
- Base/Dungeon runtime evidence;
- known non-blocking warnings;
- observed `origin/main`;
- explicit statement that nothing was merged, pushed or published.

- [ ] **Step 6: Stop for explicit acceptance**

Do not merge to local `main` until the project owner explicitly accepts runtime evidence. Do not push or publish.

---

## Plan Self-Review Result

### Spec coverage

- Persistent character Bestiary/Reputation: Task 2.
- Data-driven definitions: Task 1.
- Marauder/Captain milestones and Scholars rewards: Tasks 1 and 4.
- No combat power: global constraints.
- Exactly-once authoritative reward integration: Task 5.
- Unknown creature does not block ordinary rewards: Tasks 4 and 5.
- Migration and malformed-data sanitization: Task 2.
- Service snapshots: Tasks 3 and 4.
- Runtime composition without mutation remotes: Task 6.
- Four Rojo builds and syntax validation: Task 6.
- Fresh Base/Dungeon runtime acceptance: Task 7.
- Market/UI/vendor/guild/transmog/mount exclusions: global constraints and boundary review.

### Placeholder scan

Placeholder scan passed; all production steps and public interfaces are explicit.

### Type/interface consistency

- `BestiaryService.apply_kill_to_character` returns milestone metadata consumed by Task 5.
- `ReputationService.apply_points_to_character` returns `faction_id`, `points_granted`, and `new_points` consumed by Task 5.
- `RewardService:grant_monster_reward` retains the existing public signature.
- `BestiaryCreatureId` is optional and server-owned.
- Runtime service instances exist for read-only/future consumers; atomic mutation uses the pure helpers.
