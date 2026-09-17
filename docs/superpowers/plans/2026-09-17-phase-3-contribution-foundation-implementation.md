# Phase 3 Contribution Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a server-authoritative, reconnect-safe Damage/Tank/Support contribution ledger for active dungeon sessions without changing persistent profile schema or reward behavior.

**Architecture:** `ContributionService` owns a normalized session-scoped ledger persisted through `DungeonSessionService:set_instance_state`. Existing authoritative combat/support systems emit deduplicated trusted contribution events only after successful state changes; clients never submit contribution values. Raw breakdown values are preserved alongside weighted Damage/Tank/Support totals so later balance and reward policy can change independently.

**Tech Stack:** Roblox Luau, Rojo, existing `DungeonSessionService` instance-state persistence, existing combat/healing/ward/AI services, PowerShell 5.1 packaging and verification.

**Spec:** `docs/superpowers/specs/2026-09-17-phase-3-contribution-foundation-design.md`

## Global Constraints

- Start from canonical local main `56966cf4b3dd70c20d270c5f9aafb703a64980dc`.
- `origin/main` intentionally remains `60fc0dfd9954e2d580157a580da2425e2b71dd70`.
- Use branch `wip/phase-3-contribution-foundation-v1`.
- Use worktree `C:\Users\Remko\Documents\Roblox\DungeonMMO_Phase3_ContributionFoundation_v1`.
- Do not work directly on `main`.
- Preserve all existing worktrees, especially the art worktree.
- No reset, clean, history rewrite, pull, push, publish, PROD or monetisation actions.
- No profile schema change.
- No permanent account/character contribution history.
- No contribution-based loot/reward eligibility in this gate.
- No player-facing contribution UI in this gate.
- Contribution authority remains server-side.
- TDD: RED tests must exist and fail for the intended missing behavior before production implementation is added.
- If current source differs materially from the expected accepted architecture, stop and inspect rather than guessing.

---

## File Structure

**Create**
- `src/ReplicatedStorage/Core/Shared/ContributionConfig.luau`
  - trusted event types, channel mapping and configurable weights.
- `src/ServerScriptService/Core/Services/ContributionService.luau`
  - validation, event dedupe, session membership checks, state mutation/persistence and snapshots.
- `src/ServerScriptService/Core/Tests/ContributionConfigTest.server.luau`
  - config and event/channel contract.
- `src/ServerScriptService/Core/Tests/ContributionServiceTest.server.luau`
  - ledger behavior, validation, dedupe, persistence and snapshot semantics.
- `src/ServerScriptService/Dungeon/Tests/ContributionDamageBridgeTest.server.luau`
  - authoritative applied-damage bridge.
- `src/ServerScriptService/Dungeon/Tests/ContributionSupportBridgeTest.server.luau`
  - effective healing/ward bridge.
- `src/ServerScriptService/Dungeon/Tests/ContributionReconnectPersistenceTest.server.luau`
  - session instance-state reconnect preservation.

**Modify**
- `src/ServerScriptService/Core/Services/RuntimeServices.luau`
  - compose `ContributionService` only where dungeon-session authority is available.
- `src/ServerScriptService/Core/Services/DungeonSessionService.luau`
  - only if a small helper is needed to preserve/merge contribution state without clobbering unrelated `InstanceState`.
- `src/ServerScriptService/Core/Services/DamageService.luau`
  - emit trusted `DamageDealt` only after successful authoritative damage application.
- Existing authoritative healing service selected from repository inspection, likely:
  - `src/ServerScriptService/Core/Services/MageHealService.luau`
  - emit actual effective health restored as `EffectiveHealing`.
- Existing authoritative ward/defense service selected from repository inspection, likely:
  - `src/ServerScriptService/Core/Services/WardService.luau` and/or `DefenseService.luau`
  - emit actual prevention/absorption as `EffectiveWard` or `DamageMitigated`.
- Existing dungeon runtime composition:
  - `src/ServerScriptService/Dungeon/DungeonRuntime.server.luau`
  - pass `ContributionService` into authoritative bridges.
- Existing aggro/hostile AI service only if repository inspection finds a deterministic server-owned sampling seam.
  - If no deterministic seam exists, leave `AggroHeld` supported by config/service/tests but do not wire a production timer.

---

### Task 1: Isolated worktree, spec, plan and RED contract installation

**Files:**
- Create: `docs/superpowers/specs/2026-09-17-phase-3-contribution-foundation-design.md`
- Create: `docs/superpowers/plans/2026-09-17-phase-3-contribution-foundation-implementation.md`
- Create: all seven contribution test files listed above.

**Interfaces:**
- Consumes: canonical local main `56966cf4b3dd70c20d270c5f9aafb703a64980dc`.
- Produces: RED tests that refer to the approved `ContributionConfig` and `ContributionService` APIs before those production modules exist.

- [ ] **Step 1: Create the isolated feature worktree**

Run:

```powershell
git -C C:\Users\Remko\Documents\Roblox\DungeonMMO worktree add `
  C:\Users\Remko\Documents\Roblox\DungeonMMO_Phase3_ContributionFoundation_v1 `
  -b wip/phase-3-contribution-foundation-v1 `
  56966cf4b3dd70c20d270c5f9aafb703a64980dc
```

Expected: worktree created on the named branch at the exact canonical local-main baseline.

- [ ] **Step 2: Copy the approved spec and implementation plan into the worktree**

Write the approved design to:

`docs/superpowers/specs/2026-09-17-phase-3-contribution-foundation-design.md`

Write this plan to:

`docs/superpowers/plans/2026-09-17-phase-3-contribution-foundation-implementation.md`

- [ ] **Step 3: Inspect accepted source seams before writing integration tests**

Read in full:

```text
RuntimeServices.luau
DungeonSessionService.luau
DamageService.luau
MageHealService.luau
WardService.luau
DefenseService.luau
DungeonRuntime.server.luau
```

Search for hostile/aggro authority:

```text
Aggro
Threat
CurrentTarget
TargetUserId
Marauder
Hostile
```

Record exact constructor signatures, successful-action result shapes, action/event IDs and session lookup APIs in the implementation notes.

If any named service does not exist, choose the accepted authoritative equivalent from repository search. Do not create a duplicate service.

- [ ] **Step 4: Write `ContributionConfigTest.server.luau` RED test**

Test exact definitions:

```luau
local ContributionConfig = require(Shared:WaitForChild("ContributionConfig"))

check(ContributionConfig.Version == 1, "Contribution config must be v1.")

check(
    ContributionConfig.EventTypes.DamageDealt.Channel == "Damage",
    "DamageDealt must map to Damage."
)

check(
    ContributionConfig.EventTypes.DamageMitigated.Channel == "Tank",
    "DamageMitigated must map to Tank."
)

check(
    ContributionConfig.EventTypes.AggroHeld.Channel == "Tank",
    "AggroHeld must map to Tank."
)

check(
    ContributionConfig.EventTypes.EffectiveHealing.Channel == "Support",
    "EffectiveHealing must map to Support."
)

check(
    ContributionConfig.EventTypes.EffectiveWard.Channel == "Support",
    "EffectiveWard must map to Support."
)

check(
    ContributionConfig.EventTypes.UtilitySupport.Channel == "Support",
    "UtilitySupport must map to Support."
)
```

- [ ] **Step 5: Write `ContributionServiceTest.server.luau` RED tests**

Use the accepted in-memory/fake `DungeonSessionService` pattern and prove:

```luau
local service = ContributionService.new(fake_sessions, ContributionConfig)

local applied = service:record({
    EventId = "damage-1",
    SessionId = "session-a",
    UserId = 1001,
    Type = "DamageDealt",
    Amount = 25,
})

check(applied.ok == true, "Valid damage event must apply.")

local snapshot = service:get_player_snapshot("session-a", 1001)
check(snapshot.ok == true, "Snapshot must build.")
check(snapshot.Damage == 25, "Damage channel must increment.")
check(snapshot.Tank == 0, "Damage must not affect Tank.")
check(snapshot.Support == 0, "Damage must not affect Support.")
check(snapshot.Breakdown.DamageDealt == 25, "Raw damage breakdown must increment.")
```

Add explicit cases for:
- duplicate `EventId` returns success with `already_applied = true`;
- negative amount -> `InvalidContributionEvent`;
- zero amount -> `InvalidContributionEvent`;
- NaN -> `InvalidContributionEvent`;
- infinity -> `InvalidContributionEvent`;
- unknown type -> `UnknownContributionType`;
- missing session -> `UnknownSession`;
- non-member user -> `UserNotInSession`;
- inactive/non-contribution-eligible session -> `InactiveSession`;
- mitigation increments only Tank;
- healing increments only Support;
- ward increments only Support;
- utility support increments only Support;
- `get_session_snapshot` ordering is deterministic;
- mutating a returned snapshot does not mutate persisted state.

- [ ] **Step 6: Write persistence/reconnect RED test**

Create a fake session with an existing unrelated `InstanceState` key:

```luau
InstanceState = {
    DungeonSeed = 1234,
    ExistingFlag = true,
}
```

Record contribution, re-fetch/reconstruct the service against the same session service, then assert:

```luau
check(snapshot.Damage == 25, "Reconnect must preserve contribution.")
check(
    session.InstanceState.DungeonSeed == 1234
        and session.InstanceState.ExistingFlag == true,
    "Contribution persistence must preserve unrelated instance state."
)
```

- [ ] **Step 7: Write RED authoritative bridge tests**

Damage test contract:

```luau
-- rejected validation/action
damage_service:apply(rejected_context)
check(#events == 0, "Rejected damage must emit no contribution.")

-- accepted authoritative damage
damage_service:apply(valid_context)
check(#events == 1, "Applied damage must emit one contribution event.")
check(events[1].Type == "DamageDealt", "Damage bridge type must be DamageDealt.")
check(events[1].Amount == effective_damage, "Damage bridge must use effective applied damage.")
```

Support test contract:

```luau
heal_service:heal(valid_heal)
check(events[1].Type == "EffectiveHealing")
check(events[1].Amount == actual_health_restored)

ward_service:absorb(valid_absorb)
check(events[2].Type == "EffectiveWard")
check(events[2].Amount == actual_absorbed_amount)
```

Adapt exact method names to repository inspection; preserve these semantics.

- [ ] **Step 8: Verify RED**

Build the Base/Dungeon test places or run the repository's accepted test harness with the tests installed and production modules absent.

Expected failures must be specifically due to missing:
- `ContributionConfig`;
- `ContributionService`;
- contribution bridge dependencies/hooks.

Do not accept syntax errors, missing unrelated fixtures, or stale baseline failures as valid RED.

- [ ] **Step 9: Commit the approved design/plan/RED tests**

```powershell
git add docs/superpowers src/ServerScriptService/Core/Tests src/ServerScriptService/Dungeon/Tests
git diff --cached --check
git commit -m "test: define contribution foundation"
```

---

### Task 2: Implement contribution configuration and central ledger

**Files:**
- Create: `src/ReplicatedStorage/Core/Shared/ContributionConfig.luau`
- Create: `src/ServerScriptService/Core/Services/ContributionService.luau`
- Test: `src/ServerScriptService/Core/Tests/ContributionConfigTest.server.luau`
- Test: `src/ServerScriptService/Core/Tests/ContributionServiceTest.server.luau`
- Test: `src/ServerScriptService/Dungeon/Tests/ContributionReconnectPersistenceTest.server.luau`

**Interfaces:**
- Produces:

```luau
ContributionConfig.Version: number
ContributionConfig.EventTypes: {[string]: {Channel: string, Breakdown: string, Weight: number}}

ContributionService.new(sessionService: any, config: any): any
ContributionService:record(event: any): any
ContributionService:get_player_snapshot(sessionId: string, userId: number): any
ContributionService:get_session_snapshot(sessionId: string): any
ContributionService:reset_for_test(sessionId: string): any
```

- [ ] **Step 1: Implement `ContributionConfig.luau`**

Define:

```luau
local ContributionConfig = {
    Version = 1,
    EventTypes = {
        DamageDealt = {
            Channel = "Damage",
            Breakdown = "DamageDealt",
            Weight = 1.0,
        },
        DamageMitigated = {
            Channel = "Tank",
            Breakdown = "DamageMitigated",
            Weight = 1.0,
        },
        AggroHeld = {
            Channel = "Tank",
            Breakdown = "AggroHeld",
            Weight = 1.0,
        },
        EffectiveHealing = {
            Channel = "Support",
            Breakdown = "EffectiveHealing",
            Weight = 1.0,
        },
        EffectiveWard = {
            Channel = "Support",
            Breakdown = "EffectiveWard",
            Weight = 1.0,
        },
        UtilitySupport = {
            Channel = "Support",
            Breakdown = "UtilitySupport",
            Weight = 1.0,
        },
    },
}
```

Freeze the public definition consistently with existing shared config modules.

- [ ] **Step 2: Implement contribution event validation**

Accept only:
- non-empty string `EventId`;
- non-empty string `SessionId`;
- positive integer `UserId`;
- known string `Type`;
- finite numeric `Amount > 0`.

Validation helper must reject NaN using `amount ~= amount` and infinity using `math.abs(amount) == math.huge`.

- [ ] **Step 3: Implement session/member validation**

Use the accepted `DungeonSessionService:get(sessionId)` result.

Require:
- session exists;
- session is in an active/contribution-eligible state based on the accepted session state machine;
- `UserId` is a member of the session.

Return exact reasons:
- `UnknownSession`
- `InactiveSession`
- `UserNotInSession`.

- [ ] **Step 4: Implement state normalization**

Normalize missing contribution state without overwriting unrelated `InstanceState`:

```luau
Contribution = {
    Version = 1,
    Players = {},
}
```

Per player:

```luau
{
    Damage = 0,
    Tank = 0,
    Support = 0,
    Events = {},
    Breakdown = {
        DamageDealt = 0,
        DamageMitigated = 0,
        AggroHeld = 0,
        EffectiveHealing = 0,
        EffectiveWard = 0,
        UtilitySupport = 0,
    },
}
```

- [ ] **Step 5: Implement `record`**

Algorithm:

```text
validate event
fetch session
validate active state/member
clone current InstanceState
normalize contribution/player state
if Events[EventId] then return success already_applied
increment raw breakdown by Amount
increment mapped channel by Amount * Weight
mark Events[EventId] = true
persist complete updated InstanceState via set_instance_state
return immutable/copy snapshot
```

If persistence fails, return `ContributionPersistenceFailed` and do not report success.

- [ ] **Step 6: Implement deterministic snapshots**

`get_player_snapshot` returns a deep copy containing:

```luau
{
    Damage = number,
    Tank = number,
    Support = number,
    Breakdown = {...},
}
```

`get_session_snapshot` returns players keyed by user ID string and includes a deterministic `OrderedUserIds` numeric array sorted ascending.

Do not expose internal `Events` in normal snapshots.

- [ ] **Step 7: Implement test-only reset**

`reset_for_test(sessionId)` may clear only `InstanceState.Contribution` and must preserve all unrelated instance-state keys.

Do not create a RemoteEvent for it.

- [ ] **Step 8: Run config/service/reconnect tests**

Expected:
- all Contribution config/service/persistence tests PASS;
- existing DungeonSessionService tests remain PASS.

- [ ] **Step 9: Commit central ledger**

```powershell
git add src/ReplicatedStorage/Core/Shared/ContributionConfig.luau `
        src/ServerScriptService/Core/Services/ContributionService.luau `
        src/ServerScriptService/Core/Tests/ContributionConfigTest.server.luau `
        src/ServerScriptService/Core/Tests/ContributionServiceTest.server.luau `
        src/ServerScriptService/Dungeon/Tests/ContributionReconnectPersistenceTest.server.luau
git diff --cached --check
git commit -m "feat: add session contribution ledger"
```

---

### Task 3: Compose contribution runtime and authoritative Damage bridge

**Files:**
- Modify: `src/ServerScriptService/Core/Services/RuntimeServices.luau`
- Modify: accepted authoritative damage service, expected `src/ServerScriptService/Core/Services/DamageService.luau`
- Modify: `src/ServerScriptService/Dungeon/DungeonRuntime.server.luau`
- Test: `src/ServerScriptService/Dungeon/Tests/ContributionDamageBridgeTest.server.luau`

**Interfaces:**
- Consumes: `ContributionService:record(event)`.
- Produces: one `DamageDealt` event per successful authoritative damage application associated with an active dungeon session.

- [ ] **Step 1: Add optional contribution dependency to the authoritative damage path**

Follow existing optional-service injection patterns.

Do not require ContributionService for Base/training/test callers that do not operate in a dungeon session.

- [ ] **Step 2: Build a stable damage contribution event ID**

Use existing authoritative action/validation identity plus target identity.

Preferred shape:

```text
<session-id>:Damage:<action-id>:<target-id>
```

If the accepted damage result already has a unique authoritative ID, use it directly with a contribution prefix.

Do not generate a fresh random ID inside `ContributionService`.

- [ ] **Step 3: Emit after successful damage application**

Use actual/effective applied damage from the authoritative damage result.

Do not emit when:
- action validation rejects;
- target is invalid;
- damage is zero;
- no active dungeon session/user attribution exists;
- target is a training-only/non-eligible target.

- [ ] **Step 4: Compose runtime dependency**

Instantiate `ContributionService` using the existing shared `DungeonSessionService` where appropriate and pass it to the damage service/runtime bridge.

No new client remotes.

- [ ] **Step 5: Run Damage bridge RED→GREEN test**

Verify:
- successful applied damage emits exactly one `DamageDealt`;
- rejected damage emits none;
- duplicate authoritative action ID cannot double-count;
- Damage event preserves effective amount.

- [ ] **Step 6: Run existing damage/combat suites**

At minimum:

```text
DamageServiceTest
CombatValidationServiceTest
CriticalHitRulesTest
MeleeHitServiceTest
SweptMeleeDamageTest
ArcSlashIntegrationTest
```

All must remain green.

- [ ] **Step 7: Commit Damage bridge**

```powershell
git add src/ServerScriptService/Core/Services/RuntimeServices.luau `
        src/ServerScriptService/Core/Services/DamageService.luau `
        src/ServerScriptService/Dungeon/DungeonRuntime.server.luau `
        src/ServerScriptService/Dungeon/Tests/ContributionDamageBridgeTest.server.luau
git diff --cached --check
git commit -m "feat: record dungeon damage contribution"
```

---

### Task 4: Add effective healing and ward/mitigation bridges

**Files:**
- Modify: accepted authoritative healing service discovered in Task 1.
- Modify: accepted ward/defense service discovered in Task 1.
- Test: `src/ServerScriptService/Dungeon/Tests/ContributionSupportBridgeTest.server.luau`

**Interfaces:**
- Produces:
  - `EffectiveHealing` from actual health restored.
  - `EffectiveWard` from actual ward absorption.
  - `DamageMitigated` from validated non-ward prevention where exact prevented damage exists.

- [ ] **Step 1: Extend RED support bridge tests with overheal behavior**

Test:

```luau
-- target missing 20 HP, attempted heal is 50
local healed = heal_service:heal(...)
check(healed.actual_healing == 20, "Fixture must restore exactly missing health.")
check(events[1].Amount == 20, "Contribution must use effective healing, not attempted amount.")
```

Also prove a full-health/no-effect heal emits no contribution.

- [ ] **Step 2: Emit `EffectiveHealing` after authoritative health change**

Use exact health delta:

```text
effective = afterHealth - beforeHealth
```

Only emit if `effective > 0`.

Stable event ID uses the authoritative heal/cast/action ID plus target identity.

- [ ] **Step 3: Extend RED ward/mitigation tests**

Prove:
- actual ward absorption emits `EffectiveWard`;
- attempted ward with zero absorbed amount emits nothing;
- ordinary validated mitigation emits `DamageMitigated` only if the authoritative service exposes exact prevented damage;
- the same prevention is not counted as both `EffectiveWard` and `DamageMitigated`.

- [ ] **Step 4: Implement minimal authoritative ward/mitigation bridge**

Prefer existing result values.

Do not calculate prevention from client claims or approximate animation/state duration.

If the accepted defense service does not expose exact non-ward prevented damage, wire `EffectiveWard` only and leave `DamageMitigated` supported at the ledger API/config boundary for later authoritative producers.

- [ ] **Step 5: Run support bridge tests**

Expected:
- effective healing PASS;
- overheal only counts effective delta;
- ward only counts absorbed amount;
- no-effect actions emit no contribution;
- no double attribution.

- [ ] **Step 6: Run existing healing/ward/defense suites**

At minimum:

```text
MageHealServiceTest
WardServiceTest
DefenseServiceTest
DefensiveCombatIntegrationTest
SupportTargetRulesTest
```

All must remain green.

- [ ] **Step 7: Commit support bridges**

Stage only the exact accepted service files modified plus:

`ContributionSupportBridgeTest.server.luau`

Commit:

```powershell
git commit -m "feat: record dungeon support contribution"
```

---

### Task 5: AggroHeld seam decision and implementation if deterministic

**Files:**
- Modify: existing authoritative hostile/aggro service only if a deterministic seam exists.
- Test: extend `ContributionServiceTest.server.luau` and add focused bridge test only if production bridge is wired.

**Interfaces:**
- `AggroHeld` is already accepted by `ContributionService`.
- Production bridge is conditional on a deterministic server-owned seam.

- [ ] **Step 1: Inspect current hostile target ownership**

Find the authoritative code that decides which player an eligible hostile enemy is targeting.

Document:
- target user ID source;
- update cadence;
- stable enemy/encounter identity;
- whether the update has a deterministic tick/interval identifier.

- [ ] **Step 2: Apply the design decision**

If a deterministic seam exists, emit:

```luau
{
    EventId = sessionId .. ":Aggro:" .. enemyId .. ":" .. intervalId,
    SessionId = sessionId,
    UserId = targetUserId,
    Type = "AggroHeld",
    Amount = authoritativeIntervalSeconds,
}
```

If no deterministic stable interval identity exists, **do not add a timer**. Record in the implementation notes:

`AggroHeld ledger support implemented; production bridge deferred because current hostile AI does not expose a deterministic replay-safe sampling seam.`

- [ ] **Step 3: Verify**

If wired:
- same enemy/interval replay dedupes;
- target change attributes future interval to the new player only;
- non-session targets do not record contribution.

If deferred:
- `ContributionServiceTest` still proves direct trusted `AggroHeld` accounting.

- [ ] **Step 4: Commit only if production code changed**

Commit message if wired:

```text
feat: record dungeon aggro contribution
```

No empty commit when deferred.

---

### Task 6: Full automated gate, session-integrity verification and Studio handoff

**Files:**
- All contribution files and bridges from Tasks 1–5.

**Interfaces:**
- Produces a feature branch checkpoint ready for Studio evidence.
- Does not merge, push or publish.

- [ ] **Step 1: Verify no profile schema change**

Check:

```powershell
git diff 56966cf4b3dd70c20d270c5f9aafb703a64980dc -- `
  src/ReplicatedStorage/Core/Shared/ProfileSchema.luau
```

Expected: no diff.

- [ ] **Step 2: Run contribution-focused suite**

Required PASS lines:

```text
[Contribution Config Tests] PASS
[Contribution Service Tests] PASS
[Contribution Damage Bridge Tests] PASS
[Contribution Support Bridge Tests] PASS
[Contribution Reconnect Persistence Tests] PASS
```

If Aggro bridge is wired, require its focused PASS line too.

- [ ] **Step 3: Run all existing server tests**

Use the accepted Base and Dungeon Studio-build test suites.

No existing suite may regress.

- [ ] **Step 4: Run `git diff --check`**

```powershell
git diff --check
```

Expected: exit 0.

- [ ] **Step 5: Build all four Rojo projects to TEMP**

```powershell
rojo build base.project.json -o $env:TEMP\Contribution_Base.rbxl
rojo build default.project.json -o $env:TEMP\Contribution_Dungeon.rbxl
rojo build published-base.project.json -o $env:TEMP\Contribution_PublishedBase.rbxl
rojo build published-dungeon.project.json -o $env:TEMP\Contribution_PublishedDungeon.rbxl
```

Expected: all exit 0.

- [ ] **Step 6: Verify worktree boundary**

Only approved contribution files, design/plan, tests and exact bridge files may differ from the baseline.

No art files, roadmap files, profile schema or unrelated systems may change.

- [ ] **Step 7: Create feature checkpoint commit if any implementation remains uncommitted**

Commit:

```text
feat: complete contribution foundation
```

Skip an empty commit.

- [ ] **Step 8: Stop before merge/push/publish and request Studio proof**

Studio evidence required:

1. Base test build:
   - all existing tests green;
   - Contribution Config/Service tests green.
2. Dungeon test build:
   - contribution bridge tests green;
   - all existing dungeon/combat/support tests green;
   - no new red runtime errors.
3. Controlled runtime proof:
   - validated damage increases Damage contribution;
   - effective healing increases Support contribution;
   - ward/mitigation increases the correct channel;
   - reconnect/re-fetch preserves contribution snapshot.

No UI/visual acceptance is required.

Do not merge to `main` until this evidence is accepted.
