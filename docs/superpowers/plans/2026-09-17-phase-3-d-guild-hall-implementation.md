# Phase 3.D Guild + Hall Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add persistent guild creation/membership/roles, clan-style dungeon-earned Guild XP/Guild Gold, leader-only upgrades, and a functional private hall.

**Architecture:** Introduce one reusable persisted-entity adapter contract for shared non-character entities. Guild records and per-character membership pointers live in dedicated shared stores; character ProfileService remains character-progression authority. Multi-record guild operations use stable transaction IDs and operation receipts so retries are idempotent.

**Tech Stack:** Roblox Luau, DataStoreService adapter boundary, existing ProfileService/DungeonSession/Completion/Travel/Teleport services, Rojo.

**Spec:** `docs/superpowers/specs/2026-09-17-phase-3-systems-alpha-completion-design.md`

## Global Constraints

- Prototype member cap: 20.
- Roles exactly: Leader, Officer, Member.
- One guild membership per character.
- Solo guild dungeon clear gives 0 Guild XP and 0 Guild Gold.
- Only Leader may level the guild.
- No personal-Gold tax.
- No guild bank, wars, alliances or combat bonuses.
- No character-profile schema bump for guild authority.

---

### Task 1: Shared entity adapter contract

**Files:**
- Create: `src/ServerScriptService/Core/Adapters/InMemoryEntityAdapter.luau`
- Create: `src/ServerScriptService/Core/Adapters/RobloxEntityAdapter.luau`
- Create: `src/ServerScriptService/Core/Tests/EntityAdapterContractTest.server.luau`

**Interfaces:**

```luau
local adapter = InMemoryEntityAdapter.new()
adapter:load(key)
adapter:update(key, function(current)
    return new_value
end)
adapter:remove(key)
```

`RobloxEntityAdapter.new(store_name)` exposes the same interface using `DataStoreService:GetDataStore(store_name)` and `UpdateAsync`.

- [ ] **Step 1: RED contract test with missing modules**
- [ ] **Step 2: implement InMemory adapter including deep-cloned load/update results**
- [ ] **Step 3: implement Roblox adapter; transform callback is pure/non-yielding**
- [ ] **Step 4: Studio defaults to InMemory unless existing TEST configuration explicitly enables TEST persistence**
- [ ] **Step 5: commit**

Commit:
`feat(phase3): add shared entity adapters`

---

### Task 2: Guild definitions and persistent entity model

**Files:**
- Create: `src/ReplicatedStorage/Core/Shared/GuildDefinitions.luau`
- Create: `src/ServerScriptService/Core/Services/GuildService.luau`
- Create: `src/ServerScriptService/Core/Tests/GuildServiceTest.server.luau`

**Interfaces:**

Guild entity:

```luau
{
    Version = 1,
    GuildId = string,
    Name = string,
    Level = 1,
    XP = 0,
    Gold = 0,
    Members = {
        [character_key] = {
            UserId = number,
            Slot = 1,
            Role = "Leader" | "Officer" | "Member",
            JoinedAt = number,
        },
    },
    History = {
        [transaction_id] = true,
    },
}
```

Membership pointer key:
`membership:<userId>:<slot>` -> `{GuildId=string}`.

- [ ] **Step 1: RED create/name/member-cap/role tests**
- [ ] **Step 2: implement name validation 3-24 characters after trim**
- [ ] **Step 3: create guild with exactly one Leader and membership pointer**
- [ ] **Step 4: duplicate create/join transaction IDs return stored result without duplication**
- [ ] **Step 5: commit**

Commit:
`feat(phase3): add persistent guild service`

---

### Task 3: Invitations and role authority

**Files:**
- Extend: `src/ServerScriptService/Core/Services/GuildService.luau`
- Create: `src/ServerScriptService/Core/Tests/GuildMembershipAuthorityTest.server.luau`

**Interfaces:**

```luau
GuildService:create_invite(actor_user_id, target_user_id, transaction_id)
GuildService:accept_invite(target_user_id, guild_id, transaction_id)
GuildService:kick(actor_user_id, target_user_id, transaction_id)
GuildService:set_role(actor_user_id, target_user_id, role, transaction_id)
GuildService:leave(user_id, transaction_id)
```

Authority:
- Leader: invite/kick/promote/demote.
- Officer: invite only.
- Member: no management.
- Leader cannot leave while members remain; transfer leadership first.
- No second Leader.

- [ ] **Step 1: RED role matrix tests**
- [ ] **Step 2: implement server-owned invitation records with expiry**
- [ ] **Step 3: enforce member cap and one-guild membership pointer**
- [ ] **Step 4: replay every operation twice and assert identical final state**
- [ ] **Step 5: commit**

Commit:
`feat(phase3): add guild membership authority`

---

### Task 4: Guild dungeon progression

**Files:**
- Create: `src/ReplicatedStorage/Core/Shared/GuildProgressionConfig.luau`
- Extend: `src/ServerScriptService/Core/Services/GuildService.luau`
- Integrate at the existing authoritative dungeon completion transaction.
- Create: `src/ServerScriptService/Core/Tests/GuildDungeonProgressionTest.server.luau`

**Interfaces:**

Guild XP:
- 1 member: 0
- 2: 100
- 3: 175
- 4: 250

Guild Gold:
- 1 member: 0
- 2: 40
- 3: 70
- 4: 100

Upgrade:
- 1->2: 1000 XP / 2500 Gold
- 2->3: 3000 XP / 7500 Gold
- 3->4: 7500 XP / 20000 Gold
- 4->5: 15000 XP / 50000 Gold

- [ ] **Step 1: RED mixed-party/same-guild/duplicate completion tests**
- [ ] **Step 2: derive same-guild successful completers from server session membership**
- [ ] **Step 3: add XP/Gold idempotently using completion transaction ID**
- [ ] **Step 4: `upgrade_guild` requires Leader, XP threshold and Guild Gold; XP remains, Gold is spent**
- [ ] **Step 5: commit**

Commit:
`feat(phase3): add guild dungeon progression`

---

### Task 5: Guild hall session/entry

**Files:**
- Create: `src/ServerScriptService/Core/Services/GuildHallService.luau`
- Extend existing Travel/Teleport configuration and Base functional UI minimally.
- Create: `src/ServerScriptService/Core/Tests/GuildHallServiceTest.server.luau`

**Interfaces:**
- `GuildHallService:create_entry(user_id)` validates membership and returns server-owned hall admission data.
- Hall admission includes GuildId/member snapshot through the existing teleport/session safety pattern.
- In Studio, use functional local proof; no final hall art.

- [ ] **Step 1: RED member/nonmember/stale-membership tests**
- [ ] **Step 2: implement membership validation at request and admission**
- [ ] **Step 3: shared GuildService remains hall authority; no duplicate profile authority**
- [ ] **Step 4: all four project builds**
- [ ] **Step 5: cumulative P3.D commit**

Commit:
`feat(phase3): complete guild hall foundation`