# Phase 2 Bank / Storage Design

**Date:** 16 September 2026
**Status:** APPROVED
**Roadmap:** DungeonMMO Roadmap v1.39
**Starting gameplay baseline:** local `main` `5e3a5b3067e73b7ba62d01a413181431dbc0efb3`
**Remote baseline:** `origin/main` `60fc0dfd9954e2d580157a580da2425e2b71dd70`

## Goal

Add the first persistent, server-authoritative Bank / Storage service to the Starting Base. The bank is an account-wide 40-slot item vault that lets the currently selected character deposit and withdraw transferable items without duplication, loss, client authority, binding bypass, equipment bypass, or Dungeon access.

## Player-facing rules

- The bank is account-wide rather than character-owned.
- Initial capacity is 40 slots.
- A stackable item stack occupies one bank slot regardless of quantity.
- Each non-stackable item occupies one slot.
- Adding quantity to an existing stack consumes no extra slot.
- Partial stack deposits and withdrawals are supported.
- Transfers are all-or-nothing. A request that would exceed capacity does not partially transfer.
- Only transferable items may enter the shared bank.
- `Bound == true` or `Tradeable == false` makes an item non-bankable.
- Items without an explicit transfer restriction are bankable.
- Equipment, materials, crafted items and ordinary tradable Skill Books are eligible when their definition does not forbid transfer.
- Character-bound/permanently bound items remain in character inventory.
- Equipped copies cannot be deposited. Spare copies of the same item may be deposited.
- Gold is not banked in this gate.
- Character Inventory remains unlimited in this gate.
- Bank access is Base-only through a physical Bank/Storage interaction.
- Bank contents cannot be used directly by Dungeon gameplay, crafting, Skill Book learning, or Equipment. The item must first be withdrawn to character Inventory.
- No Deposit All, Withdraw All, mass transfer, auction house, player trading, guild bank or bank expansion purchase is added in this gate.

## Persistent model

Profile schema advances from v6 to v7.

`Account` gains:

```luau
Bank = {
    Version = 1,
    Items = {},
}
```

Bank capacity is configuration, not saved capacity:

```luau
BankConfig.CAPACITY = 40
```

This allows a later capacity increase without rewriting every profile.

`Account.Bank` is intentionally outside `Characters.SlotN`. Future characters on the same account therefore see the same vault. Binding rules prevent the shared bank from turning character-bound items into cross-character items.

Existing v6 profiles migrate to v7 with an empty Bank. Existing Level, XP, Gold, Identity, Progression, Professions, Inventory, Equipment, DungeonProgress and RewardHistory are preserved.

The migration sanitizes Bank data:
- unknown items are discarded;
- non-positive/invalid quantities are discarded;
- non-bankable items are discarded;
- stackable duplicate rows are merged;
- non-stackable items remain one item per slot;
- entries beyond configured capacity are discarded deterministically;
- the bank version is normalized to `1`.

## Shared configuration and transfer rules

Create `BankConfig.luau` with:
- `VERSION = 1`
- `CAPACITY = 40`
- `ACCESS_DISTANCE = 18`

Create `ItemTransferRules.luau` as the single shared interpretation of transferability.

For Bank:
- unknown item -> `UnknownItem`
- `Bound == true` -> `ItemNotBankable`
- `Tradeable == false` -> `ItemNotBankable`
- otherwise -> allowed

This module is intentionally small so later player trading, market or guild-bank work can reuse the same binding semantics instead of independently interpreting item definitions.

## BankService

Create a focused `BankService` under Core Services.

Responsibilities:
- build a sanitized Bank snapshot;
- calculate used/remaining slots;
- deposit one item ID and quantity;
- withdraw one item ID and quantity;
- enforce Base-only mutation context;
- enforce identity completeness;
- enforce transfer eligibility;
- enforce equipped-copy protection;
- enforce exact capacity atomically.

The service does not own physical distance checks or UI.

### Deposit transaction

Within one `ProfileService:mutate` working copy:

1. Resolve selected character and `Account.Bank`.
2. Validate item and positive integer quantity.
3. Validate item is bankable.
4. Count character-owned quantity.
5. Count how many copies of that ItemId are currently referenced by Equipment.
6. Require requested quantity <= owned minus equipped count.
7. Calculate required additional Bank slots before removing anything.
8. Reject `BankFull` if the whole request does not fit.
9. Remove the exact quantity from character Inventory.
10. Add it to Bank Items using the same stack/non-stack semantics as Inventory.

Any failure aborts the mutation and leaves both sides unchanged.

### Withdraw transaction

Within one `ProfileService:mutate` working copy:

1. Resolve selected character and Bank.
2. Validate item and quantity.
3. Confirm Bank owns enough.
4. Remove exact quantity from Bank.
5. Add exact quantity to character Inventory.

Inventory has no capacity limit in this gate, so no Inventory-capacity branch exists.

### Equipped-copy rule

Equipment does not remove the underlying Inventory item. Therefore the available deposit quantity is:

`Inventory quantity - number of equipped slots containing the ItemId`.

Example:
- Own one Marauder Sword; it is equipped -> deposit 1 rejects `ItemEquipped`.
- Own two Marauder Swords; one is equipped -> deposit 1 succeeds; deposit 2 rejects `ItemEquipped`.

## Snapshot contract

Bank snapshot is server-built and returns:

```luau
{
    ok = true,
    Capacity = 40,
    UsedSlots = number,
    RemainingSlots = number,
    Inventory = {
        {
            ItemId = string,
            Name = string,
            Quantity = number,
            AvailableQuantity = number,
            EquippedQuantity = number,
            Kind = string,
            Category = string,
            Rarity = string,
            Stackable = boolean,
            Bankable = boolean,
            Reason = string?,
        },
    },
    Items = {
        {
            ItemId = string,
            Name = string,
            Quantity = number,
            Kind = string,
            Category = string,
            Rarity = string,
            Stackable = boolean,
        },
    },
}
```

Rows are presentation-sorted by category, rarity, then name. Sorting does not rewrite persistent Bank order.

## Runtime composition

`RuntimeServices.new(place_kind)` creates `BankService` with the same `ProfileService` instance already used by Inventory, Equipment, Professions and Progression.

`BankService` is available in both runtime compositions so tests can prove Dungeon mutation rejection, but the Dungeon Place exposes no bank UI/remotes.

No second DataStore, lock or Bank-specific persistence service is introduced. The existing single-writer profile lease and ProfileService mutation/save lifecycle remain authoritative.

## Base physical access

The existing semantic bank placeholder becomes the real semantic anchor:

`Base.Service.Bank`

The selector/physical candidate location remains unchanged. Only the semantic gameplay identity changes.

`BaseEnvironmentBootstrap`:
- resolves the bank anchor;
- creates `BankPrompt`;
- prompt text is `Open` / `Bank`;
- label becomes `BANK`;
- Travel remains a placeholder.

Server action authorization requires:
- Base context;
- loaded profile;
- complete character identity;
- no dungeon teleport/handoff pending;
- a live player character with HumanoidRootPart;
- HumanoidRootPart within 18 studs of `Base.Service.Bank`.

The ProximityPrompt is convenience, not authorization. Every snapshot/deposit/withdraw request independently performs the server distance check.

## Remotes

Add:
- `BankSnapshotRequest`
- `BankSnapshot`
- `BankDepositRequest`
- `BankWithdrawRequest`
- `BankActionResult`

Client supplies only ItemId and Quantity for mutation requests.

The server determines:
- current ownership;
- equipped quantity;
- transfer eligibility;
- capacity;
- physical access;
- resulting state.

The client never predicts a successful transfer.

## Base runtime integration

Create a focused `BankRuntime.luau` under Base rather than putting all Bank logic inside the already-large `BaseRuntime.server.luau`.

`BankRuntime.attach(...)` receives:
- BankService;
- ProfileService;
- resolved Base environment;
- Remotes folder;
- callback to refresh existing profile/inventory presentation;
- callback that reports whether dungeon teleport is pending.

It wires the Bank remotes, performs physical/access validation, calls BankService, sends authoritative results, and refreshes Bank/profile snapshots after successful mutation.

`BaseRuntime.server.luau` only:
- obtains `runtime.BankService`;
- requires BankRuntime;
- attaches it after the Base environment/profile presentation callbacks exist.

## Studio validation kit

Studio Base testing adds only test inventory needed to prove the Bank interaction:
- Iron Ore x25
- tradable `arc_slash_book` x1
- legacy bound `arc_slash_book_bound` x1

The existing Studio equipment kit remains unchanged.

This grant is `RunService:IsStudio()` only. It is not a production reward or persistent content path.

## Bank UI

Create `BankPanel.client.luau` as a separate Base client.

Functional layout:
- two-pane window;
- Inventory left;
- Bank right;
- `Used / 40` capacity;
- selected item details;
- numeric quantity box;
- Deposit button;
- Withdraw button;
- close button;
- status/error text.

Opening:
- `BankPrompt` requests a server Bank snapshot.
- UI becomes usable only after a successful authoritative snapshot.

Transfer:
- selecting an Inventory row sets Deposit mode;
- selecting a Bank row sets Withdraw mode;
- quantity is clamped client-side for convenience, but server validation is final;
- after a successful server action the UI re-renders from the returned/refreshed authoritative snapshot.

Distance:
- while visible, the client closes the panel if it moves outside the configured Bank distance.
- server distance validation remains mandatory even if the client fails to close.

No final art styling is required.

## Stable rejection reasons

At minimum:
- `BaseOnlyAction`
- `ProfileNotLoaded`
- `IdentityIncomplete`
- `UnknownItem`
- `InvalidQuantity`
- `ItemNotOwned`
- `ItemNotBankable`
- `ItemEquipped`
- `BankFull`
- `TooFarFromBank`
- `CharacterUnavailable`
- `TeleportPending`
- `ProfileMutationFailed`

## Other systems

### Crafting
Crafting reads character Inventory only. Bank materials are not auto-consumed.

### Skill learning
SkillProgressionService reads character Inventory only. Banked Skill Books must be withdrawn first.

### Equipment
EquipmentService reads character Inventory only. Banked equipment must be withdrawn first.

### Dungeon
Bank has no Dungeon access/remotes. Existing run-brought Inventory/Equipment rules remain unchanged.

### Gold
Gold remains character-owned and is outside this gate.

## Persistence and concurrency

Bank is saved as part of the existing account profile.

The existing profile lease remains the only single-writer lock.

Deposit/withdraw use one profile mutation each, so Bank and character Inventory cannot be committed independently.

Normal:
- autosave;
- leave/release;
- save-before-dungeon-handoff;
- return/reload

all carry Bank state because it is part of the same profile.

## Automated acceptance

Tests must prove:

1. Profile schema is v7 and new profiles contain Account.Bank.
2. v6 migration creates an empty Bank without changing existing character state.
3. Bank migration sanitizes malformed/non-bankable/over-capacity data.
4. Capacity is exactly 40.
5. Access distance is exactly 18 studs.
6. Stack deposit consumes one slot.
7. Depositing more into an existing stack consumes no new slot.
8. Partial stack deposit and withdrawal work.
9. Non-stackable items consume one slot each.
10. Exact-full 40-slot Bank is valid.
11. A request that needs more slots than remain fails atomically.
12. Bound/non-tradable item deposit rejects.
13. Ordinary item definitions without explicit transfer restriction are bankable.
14. Equipped-only copy deposit rejects.
15. Spare copy deposit succeeds.
16. Unknown item and invalid quantity reject.
17. Withdrawal cannot exceed Bank ownership.
18. Dungeon-context Bank mutation rejects BaseOnlyAction.
19. Raw profile proof with Slot1 and synthetic Slot2 demonstrates that Bank remains one Account.Bank while either character inventory can be the transfer endpoint.
20. Failed mutation cannot duplicate or lose items.
21. Bank snapshot sorting does not mutate persistent Bank order.
22. Bank remote objects exist.
23. Bank semantic environment anchor exists in synthetic/candidate definitions.
24. BankPrompt is created in Base bootstrap.
25. Existing Inventory, Equipment, Profession, Skill Book, progression, party and dungeon contracts remain buildable.

## Studio gameplay acceptance

Only after automated/build verification is green, the project owner performs the interaction proof:

1. Open the fresh Base build.
2. Complete/select identity if required.
3. Walk to the physical Bank and trigger `Open Bank`.
4. Confirm two-pane Inventory/Bank UI and `0 / 40` (or current used count).
5. Deposit part of the Studio Iron Ore stack and confirm Inventory/Bank quantities update.
6. Deposit the tradable Arc Slash Skill Book.
7. Attempt to deposit the bound Arc Slash Skill Book and confirm rejection.
8. Equip the only copy of a test equipment item and confirm depositing that equipped-only copy is rejected.
9. If a spare copy is available, confirm the spare can be deposited.
10. Withdraw part of the Iron Ore stack.
11. Walk beyond Bank range and confirm the UI closes.
12. Reopen Bank and confirm the authoritative contents remain.
13. Confirm no new red DungeonMMO runtime errors.

Persistence/save-load is additionally proven automatically at service/profile-adapter level because an unpublished Studio server uses the in-memory profile adapter.

## Deferred scope

- Gold banking
- inventory bag limits
- Bank upgrades/expansions
- Robux Bank capacity
- crafting directly from Bank
- learning/equipping directly from Bank
- mass transfer buttons
- item instance/random-stat architecture
- player trading
- auction house/player market
- guild bank
- Travel services
- final Bank art/NPC
- final UI art/audio

## Safety

- Work from an isolated gameplay worktree.
- No destructive Git.
- No push.
- No Roblox publish.
- No PROD DataStore.
- No Robux/monetization changes.
- Art worktree remains untouched.
- Build outputs go to TEMP.
- Do not overwrite root `DungeonMMO.rbxl`.
