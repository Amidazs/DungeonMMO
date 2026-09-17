# Phase 3 Systems Alpha Completion - Design

**Date:** 17 September 2026
**Phase:** Phase 3 - Systems Alpha
**Status:** Approved in conversation; written-spec review required before implementation planning
**Accepted Bestiary/Reputation candidate:** `5dce776cce0839fd3a1e4be3f975e00e50ae58c9`
**Pre-closeout local main:** `bf22f29577dca105f91bbe7dcae09500f63d1c5b`

## 1. Purpose

Complete the remaining **meaningful Phase 3 Systems Alpha architecture** in one
controlled programme while preserving every accepted Phase 1/2 and earlier
Phase 3 contract.

The programme deliberately distinguishes between:

- systems that must be implemented now because they prove reusable MMO
  architecture;
- systems that should be deferred because there is no real testing need yet.

The final Phase 3 acceptance target is one consolidated Base + Dungeon runtime
round after all automated RED -> GREEN, syntax, build and regression checks
have passed.

## 2. Locked decisions

### 2.1 Lineage-2-inspired Rogue progression

The fourth starting archetype is **Rogue**.

Use the *structure and progression philosophy* of Lineage 2 dagger classes as
inspiration without copying names, exact skills or balance.

Base Rogue identity:

- positional damage;
- high movement/repositioning;
- evasion/avoidance;
- critical-hit interaction;
- light-armour identity;
- dagger-first long-term weapon identity;
- One-Handed Sword remains a temporary Systems Alpha compatibility weapon
  until final dagger assets/equipment are authored.

Prototype Human branch:

- working name: **Duelist**;
- emphasises positional burst, stronger single-hit critical attacks,
  gap-closing and trick/feint tools;
- final lore/class name remains changeable without altering persistence IDs.

Prototype Elf branch:

- working name: **Windstalker**;
- emphasises movement speed, evasion, rapid attacks and repeated repositioning;
- final lore/class name remains changeable without altering persistence IDs.

Stable internal IDs must not depend on display-name permanence.

### 2.2 Skill-tree breadth

Do not use a tiny MOBA-sized class kit.

Target **10-14 meaningful skill families per developed class line** across:

- active attacks;
- movement;
- defensive/evasion tools;
- utility;
- passives/masteries;
- secondary-class-specific abilities.

A Phase 3 Rogue line should prove approximately:

- 8 meaningful base Rogue skill/passive families;
- 5-7 additional secondary-class families;
- multiple purchasable ranks where the accepted SP/proficiency system supports
  them;
- the existing limited active loadout remains authoritative.

This is architecture/content proof, not final VFX/audio/balance.

### 2.3 No catch-up system in Phase 3

**Do not implement progression catch-up.**

There is no live population requiring it yet. Phase 3 must preserve profile
migration compatibility, but it must not manufacture:

- proficiency;
- Skill Books;
- secondary-class completion;
- bonus SP beyond level entitlement;
- artificial catch-up XP.

Catch-up returns to the roadmap only when real player-progression data proves a
need.

### 2.4 Guild progression

Guild progression follows a clan-style loop inspired by Lineage 2:

**play dungeons together -> earn Guild XP and Guild Gold -> leader decides when
to spend Guild Gold and perform the level upgrade.**

Rules:

- one guild membership per character;
- prototype member cap: **20**;
- roles: **Leader / Officer / Member**;
- only the **Leader** may perform a guild-level upgrade;
- qualifying dungeon completion requires at least **2 members from the same
  guild**;
- solo guild members earn no Guild XP or Guild Gold for the guild;
- the guild reward transaction is server-authoritative and idempotent;
- Guild XP is accumulated;
- Guild Gold is a separate persistent treasury and is **spent** by upgrades;
- ordinary personal Gold is not automatically taxed;
- member donation can be added later but is not required by Phase 3.

Prototype same-guild dungeon-clear rewards:

| Same-guild members in successful clear | Guild XP |
| ---: | ---: |
| 1 | 0 |
| 2 | 100 |
| 3 | 175 |
| 4 | 250 |

Guild Gold should use the same qualifying member-count concept, with prototype
values kept data-driven.

Prototype level requirements:

| Upgrade | Guild XP requirement | Guild Gold cost |
| --- | ---: | ---: |
| 1 -> 2 | 1,000 | 2,500 |
| 2 -> 3 | 3,000 | 7,500 |
| 3 -> 4 | 7,500 | 20,000 |
| 4 -> 5 | 15,000 | 50,000 |

These numbers are Systems Alpha proof values, not final economy balance.

Guild level unlocks should be non-combat in Phase 3:

- member-cap progression;
- hall feature flags;
- emblem/title capability flags;
- future-system eligibility.

Do not introduce mandatory guild combat bonuses.

### 2.5 Guild hall

Prototype one functional guild hall using existing server/session/teleport
patterns where practical.

Requirements:

- private/reserved hall access for valid guild members;
- server validates guild membership at entry;
- no second profile authority;
- no guild bank;
- no guild wars;
- no alliance system;
- placeholder functional environment is acceptable.

### 2.6 Transmog deferred

**Do not implement Transmog during this Phase 3 programme.**

Reason:

- the equipment/content catalogue is not mature enough to justify wardrobe
  engineering;
- building it now would add low-value scope.

Preserve one architectural rule only:

- item appearance must remain separable from combat/stat identity so a later
  transmog system does not require equipment persistence redesign.

The roadmap item is explicitly deferred rather than silently forgotten.

### 2.7 Limited player market

Implement a fixed-price server-authoritative market proof only.

Prototype rules:

- maximum **5 active listings per character**;
- listing duration **24 hours**;
- seller transaction tax **5%**;
- price range **1-50,000 Gold**;
- explicitly non-tradable or bound items cannot be listed;
- character-bound Skill Books, quest items and permanent-bound rewards cannot
  be listed;
- recipe/blueprint items follow their actual binding/tradability definitions;
- listing escrow removes the item from ordinary inventory while active;
- buy/cancel/expiry is atomic and replay-safe;
- seller proceeds are server-authenticated and idempotent;
- no bidding;
- no buy orders;
- no offline negotiation system;
- no cross-server economic optimisation beyond what is needed to prove safe
  persistence and transaction contracts.

### 2.8 Race Change migration proof

Phase 3 proves the **data transformation** only.

Race Change remains DEV/TEST only:

- no Robux product;
- no player-facing purchase flow;
- no PROD monetisation action.

Before application, generate a deterministic preview.

Rules:

- preserve account/character continuity;
- keep per-race advancement history;
- archive/deactivate incompatible race/class skill knowledge and proficiency;
- release refundable current SP allocation from incompatible active ranks;
- do not return consumed Skill Books or materials;
- do not manufacture new books, proficiency or advancement;
- returning to the old race may restore archived knowledge/proficiency when
  requirements remain valid;
- restored ranks still require SP reinvestment where SP was refunded;
- binding/trade eligibility is recalculated safely;
- race change never bypasses earned class advancement or permanent rewards;
- all transformations are idempotent and migration-tested.

### 2.9 Dungeon module/modifier breadth

Do not procedurally regenerate authored geometry.

Instead, prove reusable dungeon-state composition around the accepted Temple
and Abandoned Mine content.

Prototype rotating modifier pool:

- **Fortified**: +20% enemy health;
- **Rich Deposits**: +1 eligible gathering yield;
- **Bounty**: +10% monster Gold.

Rules:

- one modifier per eligible run for the Phase 3 proof;
- selection is deterministic/server-owned;
- reconnect must not reroll it;
- modifier identity persists with the dungeon session;
- all effect values are data-driven;
- no client may choose/re-roll the authoritative modifier.

Expand logical module pools and state variation without forcing new authored
room geometry.

### 2.10 Profession interaction cleanup

Close the known Temple placement debt during this programme.

The final Phase 3 acceptance should not emit the current invalid-surface skips
for:

- `Temple.RichIronVein.02`;
- `Temple.Room1.Silverleaf`;
- `Temple.AncientSilverleaf.02`;
- `Temple.Room2.IronVein`.

Fix using valid semantic placement/surface contracts. Do not move into broad art
polish.

Also prove at least one dungeon modifier/profession interaction through Rich
Deposits without replacing existing personal/reconnect-safe gathering claims.

### 2.11 Economy and audit logging

Introduce one shared diagnostic/economy audit contract for meaningful value
movement.

Record stable transaction IDs and reason/source metadata for:

- monster/completion reward Gold;
- guild treasury rewards/spend;
- market listing/cancel/sale/expiry;
- market taxes;
- relevant item escrow/value movement;
- DEV/TEST race-change migration actions.

The audit layer observes authoritative transactions; it does not become a
second source of gameplay truth.

### 2.12 Anti-exploit

All new actions are server-authoritative.

Required protections include:

- request rate limits where network requests exist;
- membership/ownership validation;
- item tradability validation;
- quantity/price bounds;
- stale-state rejection;
- duplicate transaction replay safety;
- guild-role validation;
- leader-only upgrade validation;
- race-change preview/apply consistency;
- market escrow integrity;
- no client-supplied reward amounts.

### 2.13 Phase 3 stress harness

Automated Phase 3 stress proof should target at least:

- **250** profile migration/save/reload cycles;
- **1,000** market operations across create/buy/cancel/expiry paths;
- **1,000** duplicate reward/trade replay attempts;
- **250** guild membership/role/progression operations;
- **100** party/session/teleport contract cycles or deterministic service-level
  equivalents;
- repeated race-change round trips sufficient to prove archive/restore
  idempotency.

Acceptance:

- zero unhandled errors;
- no duplicate value;
- no lost escrowed value;
- no invalid final profile shape;
- deterministic replay results;
- no unauthorized role/market/race-change action succeeds.

## 3. Remaining Phase 3 implementation gates

The programme is decomposed into independently reviewable gates.

### Gate P3.A - Bestiary/Reputation closeout

- merge accepted candidate `5dce776cce0839fd3a1e4be3f975e00e50ae58c9` into local main;
- record runtime acceptance;
- keep remote/publishing untouched.

### Gate P3.B - Rogue + broad skill-tree architecture

- add Rogue;
- Human/Elf Rogue identity differences;
- Human Duelist / Elf Windstalker secondary targets;
- approximately 8 base Rogue skill/passive families;
- 5-7 secondary families per prototype branch where practical;
- trainer/progression integration;
- no catch-up system.

### Gate P3.C - Dungeon systems breadth + profession cleanup

- deterministic modifiers;
- reusable logical module-pool/state contracts;
- Temple + Abandoned Mine compatibility;
- Rich Deposits profession interaction;
- resolve four invalid Temple resource placements.

### Gate P3.D - Guild + hall foundation

- guild creation/membership/roles;
- 20-member prototype cap;
- dungeon-earned Guild XP/Guild Gold;
- leader-only level upgrades;
- guild level persistence;
- private functional hall;
- no bank/wars/alliances/combat bonuses.

### Gate P3.E - Limited market foundation

- fixed-price listings;
- escrow;
- buy/cancel/expiry;
- binding/tradability checks;
- tax;
- replay safety;
- audit events.

### Gate P3.F - Race Change migration foundation

- preview;
- apply;
- per-race advancement history;
- incompatible skill/proficiency archive;
- SP release rules;
- restore on return;
- DEV/TEST only.

### Gate P3.G - Systems hardening

- shared economy audit;
- request validation/rate limits;
- replay/idempotency tests;
- stress/load harness;
- final migration/save/session/economy regression pass.

### Gate P3.H - Consolidated Phase 3 acceptance

Only after P3.B-P3.G pass automated gates:

- build fresh Base;
- build fresh Dungeon;
- build both published project variants for static verification;
- perform one consolidated manual Base/Dungeon Studio acceptance round;
- close Phase 3 documentation;
- stop before any push/publish unless separately approved.

## 4. Testing cadence

The user is not required to perform Studio testing between internal gates.

Each internal gate must still run:

- RED proof before production change;
- focused GREEN test;
- repository-wide Luau parse;
- `git diff --check`;
- Base and Dungeon Rojo builds whenever shared/runtime code changes;
- published project builds at major cumulative checkpoints;
- exact path-boundary review;
- regression tests for touched authority/persistence systems.

If an automated blocker proves that a manual Studio observation is necessary to
diagnose the defect, stop and ask only for that unavoidable test.

Otherwise, manual user involvement occurs only at P3.H.

## 5. Git/worktree strategy

- close accepted Bestiary/Reputation into local `main` first;
- use local-only accepted `main` as the baseline for the completion programme;
- each P3.B-P3.G gate uses an isolated worktree/branch or a single cumulative
  Phase-3-completion worktree with separate commits and strict path boundaries;
- preserve every intermediate commit;
- no hard reset;
- no clean;
- no force-push;
- no history rewrite;
- no Roblox publish;
- no PROD monetisation;
- do not touch `DungeonMMO_Art`;
- stop before remote push unless separately approved.

## 6. Explicit deferrals

The following roadmap concepts are intentionally deferred:

### Progression catch-up

Deferred until actual player population/progression data demonstrates a need.

### Transmog

Deferred until the equipment/content catalogue is mature enough for the system
to create real player value.

These are deliberate scope decisions, not forgotten requirements.

## 7. Phase 3 exit definition

Phase 3 Systems Alpha is complete when:

1. accepted Bestiary/Reputation is merged locally;
2. Rogue + broader skill-tree architecture is persistent and server-authoritative;
3. deterministic dungeon modifiers/module-state breadth works across accepted
   dungeon content;
4. profession interaction cleanup removes the known Temple invalid-surface debt;
5. guild creation/membership/progression/leader upgrades/hall are proven;
6. the fixed-price market is escrowed, validated and replay-safe;
7. Race Change migration/archive/restore contracts are proven in DEV/TEST;
8. economy/audit and anti-exploit contracts cover the new value paths;
9. stress harness meets its stated workload without duplication/loss/invalid
   profile state;
10. existing Phase 1/2 and earlier Phase 3 regressions remain green;
11. one final Base + Dungeon Studio acceptance round is green;
12. catch-up and transmog are recorded as intentional future work rather than
   blocking Phase 3.
