# Phase 3.E Limited Player Market Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a fixed-price, escrowed, server-authoritative market proof with safe buy/cancel/expiry recovery and binding/tradability enforcement.

**Architecture:** Reuse the P3.D shared entity adapter for listing entities. Seller inventory escrow and buyer/seller value mutations remain character ProfileService transactions. Multi-entity operations use durable per-character MarketHistory receipts plus listing state transitions so retries/recovery are deterministic.

**Tech Stack:** Roblox Luau, existing InventoryService/ItemDefinitions/ItemTransferRules/ProfileService, shared entity adapters, Rojo.

**Spec:** `docs/superpowers/specs/2026-09-17-phase-3-systems-alpha-completion-design.md`

## Global Constraints

- Maximum 5 active listings per character.
- 24-hour listing duration.
- 5% seller transaction tax.
- Price 1-50,000 Gold.
- No bidding/buy orders.
- Bound/non-tradable/quest/permanent-reward items reject.
- No cross-server optimisation beyond safe persisted listing/transaction proof.
- Profile schema v10 -> v11.

---

### Task 1: Market config and schema-v11 recovery state

**Files:**
- Create: `src/ReplicatedStorage/Core/Shared/MarketConfig.luau`
- Modify: `src/ReplicatedStorage/Core/Shared/ProfileSchema.luau`
- Modify: `src/ServerScriptService/Core/Services/ProfileMigration.luau`
- Create: `src/ServerScriptService/Core/Tests/ProfileMigrationMarketV11Test.server.luau`

**Interfaces:**

```luau
Market = {
    Version = 1,
    ActiveListingIds = {},
    History = {},
    Recovery = {},
}
```

- [ ] **Step 1: RED v10->v11 migration**
- [ ] **Step 2: set schema v11 and add fresh defaults**
- [ ] **Step 3: migration preserves v10 state and sanitizes malformed Market data**
- [ ] **Step 4: repeated migration idempotent**
- [ ] **Step 5: commit**

Commit:
`feat(phase3): add market profile recovery state`

---

### Task 2: Listing/escrow creation

**Files:**
- Create: `src/ServerScriptService/Core/Services/MarketService.luau`
- Create: `src/ServerScriptService/Core/Tests/MarketListingServiceTest.server.luau`
- Reuse: `ItemTransferRules.luau`, `ItemDefinitions.luau`, `InventoryService.luau`

**Listing entity:**

```luau
{
    Version = 1,
    ListingId = string,
    SellerUserId = number,
    SellerSlot = 1,
    Item = serialized_inventory_entry,
    Price = number,
    TaxRate = 0.05,
    CreatedAt = number,
    ExpiresAt = number,
    State = "Active" | "PendingSale" | "Sold" | "PendingReturn" | "Cancelled" | "Expired",
    ActiveTransactionId = string?,
}
```

- [ ] **Step 1: RED listing validation tests**
- [ ] **Step 2: validate integer price and active count**
- [ ] **Step 3: reject bound/non-tradable items using existing transfer rules**
- [ ] **Step 4: remove exact item into seller recovery receipt before creating listing entity**
- [ ] **Step 5: failed entity creation recovery returns exact item once**
- [ ] **Step 6: commit**

Commit:
`feat(phase3): add market listing escrow`

---

### Task 3: Atomic/recoverable purchase

**Files:**
- Extend: `src/ServerScriptService/Core/Services/MarketService.luau`
- Create: `src/ServerScriptService/Core/Tests/MarketPurchaseRecoveryTest.server.luau`

**Interface:**

```luau
MarketService:buy(
    buyer_user_id: number,
    listing_id: string,
    transaction_id: string
): any
```

State machine:
1. Active -> PendingSale(transaction_id)
2. buyer deducts Price and receives item once
3. seller receives `floor(Price * 0.95)` once
4. listing -> Sold

- [ ] **Step 1: RED normal/insufficient-funds/self-buy/replay tests**
- [ ] **Step 2: claim listing atomically**
- [ ] **Step 3: buyer mutation idempotent by transaction ID**
- [ ] **Step 4: seller proceeds idempotent by transaction ID**
- [ ] **Step 5: simulate interruption after every stage; replay completes with no duplicate/loss**
- [ ] **Step 6: commit**

Commit:
`feat(phase3): add recoverable market purchase`

---

### Task 4: Cancel and expiry

**Files:**
- Extend: `src/ServerScriptService/Core/Services/MarketService.luau`
- Create: `src/ServerScriptService/Core/Tests/MarketCancelExpiryTest.server.luau`

**Interfaces:**
- seller-only cancel of Active listing;
- expiry when authoritative clock >= ExpiresAt;
- both use PendingReturn -> idempotent seller item return -> terminal state.

- [ ] **Step 1: RED cancel/expiry/replay tests**
- [ ] **Step 2: implement seller ownership validation**
- [ ] **Step 3: expiry scans only explicitly supplied/indexed listing IDs, never an unbounded DataStore scan**
- [ ] **Step 4: item returned exactly once**
- [ ] **Step 5: commit**

Commit:
`feat(phase3): add market return paths`

---

### Task 5: Minimal server API and functional Base panel

**Files:**
- Modify: `src/ReplicatedStorage/Core/Remotes.model.json`
- Modify: `src/ServerScriptService/Base/BaseRuntime.server.luau`
- Create: `src/StarterPlayerScripts/Base/MarketPanel.client.luau`
- Create remote contract tests.

**Interfaces:**
Client sends intent only. Server owns seller identity, tax, expiry and listing state.

- [ ] **Step 1: RED remote-contract/request-shape tests**
- [ ] **Step 2: implement server handlers**
- [ ] **Step 3: functional non-final UI for list/create/buy/cancel**
- [ ] **Step 4: Base/Dungeon regression + all four builds**
- [ ] **Step 5: cumulative P3.E commit**

Commit:
`feat(phase3): complete limited market foundation`