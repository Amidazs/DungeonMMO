# Phase 3.G Systems Hardening + Stress Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add shared economy audit instrumentation, network/authority hardening and deterministic stress tests covering Phase 3 persistence, guild, market, Race Change, rewards and session contracts.

**Architecture:** EconomyAuditService records immutable diagnostic events after authoritative mutations succeed; it never decides gameplay outcomes. Request guards use a small shared RateLimitService plus existing ownership/membership validation. A deterministic stress harness runs against InMemory adapters and deterministic clocks/RNG.

**Tech Stack:** Roblox Luau, InMemory adapters, existing services, Rojo.

**Spec:** `docs/superpowers/specs/2026-09-17-phase-3-systems-alpha-completion-design.md`

## Global Constraints

- Audit is observational, not an authority.
- No audit failure may duplicate/reverse a successful gameplay transaction.
- No client-supplied reward/value amount.
- Stress harness never calls live PROD DataStores or TeleportService.
- Final profile/entity validation after stress is mandatory.

---

### Task 1: EconomyAuditService

**Files:**
- Create: `src/ServerScriptService/Core/Services/EconomyAuditService.luau`
- Create: `src/ServerScriptService/Core/Tests/EconomyAuditServiceTest.server.luau`
- Modify: `src/ServerScriptService/Core/Services/RuntimeServices.luau`

**Interface:**

```luau
EconomyAuditService:record({
    TransactionId = string,
    Kind = string,
    UserId = number?,
    GuildId = string?,
    ListingId = string?,
    ItemId = string?,
    GoldDelta = number?,
    GuildGoldDelta = number?,
    Reason = string,
    Timestamp = number,
}): any
```

- [ ] **Step 1: RED validation/dedupe tests**
- [ ] **Step 2: immutable serializable event copy with transaction+kind dedupe**
- [ ] **Step 3: InMemory default sink; no PROD persistent audit activation**
- [ ] **Step 4: commit**

Commit:
`feat(phase3): add economy audit service`

---

### Task 2: Instrument authoritative value paths

**Files:**
- Modify: `src/ServerScriptService/Core/Services/RewardService.luau`
- Modify GuildService.
- Modify MarketService.
- Modify RaceChangeService.

**Audit kinds:**

```text
MonsterGoldReward
CompletionGoldReward
GuildDungeonReward
GuildUpgradeSpend
MarketEscrowCreate
MarketSaleBuyer
MarketSaleSeller
MarketTax
MarketCancelReturn
MarketExpiryReturn
RaceChangeApply
```

- [ ] **Step 1: RED integration tests**
- [ ] **Step 2: emit only after authoritative stage succeeds**
- [ ] **Step 3: same transaction+kind replay emits no duplicate event**
- [ ] **Step 4: audit sink failure never reruns gameplay mutation**
- [ ] **Step 5: commit**

Commit:
`feat(phase3): instrument economy audit events`

---

### Task 3: Shared rate-limit/request validation

**Files:**
- Create: `src/ServerScriptService/Core/Services/RateLimitService.luau`
- Create: `src/ServerScriptService/Core/Tests/RateLimitServiceTest.server.luau`
- Modify Guild/Market/Race Change remote handlers.

**Interface:**

```luau
RateLimitService:allow(
    user_id: number,
    action: string,
    limit: number,
    window_seconds: number
): boolean
```

Limits:
- market create/buy/cancel: 10 / 10 seconds each;
- guild management: 12 / 10 seconds;
- Race Change preview: 6 / 10 seconds;
- Race Change apply: 2 / 30 seconds.

- [ ] **Step 1: RED deterministic-clock tests**
- [ ] **Step 2: implement fixed-window limiter**
- [ ] **Step 3: reject NaN/infinity/oversized strings/invalid IDs before service calls**
- [ ] **Step 4: rate rejection makes no persistent mutation**
- [ ] **Step 5: commit**

Commit:
`feat(phase3): harden phase3 request authority`

---

### Task 4: Phase 3 stress harness

**Files:**
- Create: `src/ServerScriptService/Core/Tests/Phase3SystemsStressTest.server.luau`

**Workloads:**
- 250 profile migrate/save/reload cycles;
- 1,000 market create/buy/cancel/expiry operations;
- 1,000 duplicate reward/market replay attempts;
- 250 guild membership/role/progression operations;
- 100 party/session/teleport service-level cycles;
- 100 Human<->Elf Race Change round trips across class fixtures.

- [ ] **Step 1: deterministic InMemory fixtures only**
- [ ] **Step 2: profile workload ends at v12 valid profiles**
- [ ] **Step 3: market workload proves exact item conservation and explicit tax sink**
- [ ] **Step 4: duplicate replay workload produces zero delta after first application**
- [ ] **Step 5: guild workload proves one membership/character, one Leader/guild, nonnegative XP/Gold, level 1-5**
- [ ] **Step 6: session workload proves modifier/member/reconnect stability**
- [ ] **Step 7: Race Change round trips prove stable archive, no book manufacture and no SP entitlement increase**
- [ ] **Step 8: print exactly: `[Phase 3 Systems Stress] PASS: profiles=250 market=1000 replay=1000 guild=250 sessions=100 race_roundtrips=100`**
- [ ] **Step 9: commit**

Commit:
`test(phase3): add systems alpha stress harness`

---

### Task 5: Final automated cumulative gate

**Files:**
- No new production files.

- [ ] **Step 1: repository-wide Luau parse**
- [ ] **Step 2: `git diff --check`**
- [ ] **Step 3: exact Phase 3 path-boundary review**
- [ ] **Step 4: build Base/Dungeon/PublishedBase/PublishedDungeon**
- [ ] **Step 5: assert no catch-up module/service and no Transmog module/service**
- [ ] **Step 6: assert no PROD/Robux/product configuration changed**
- [ ] **Step 7: cumulative P3.G commit**

Commit:
`test(phase3): complete systems alpha hardening`