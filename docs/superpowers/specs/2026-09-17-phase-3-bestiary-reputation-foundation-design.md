# Phase 3 Bestiary + Reputation Foundation â€” Design

**Date:** 17 September 2026  
**Phase:** Phase 3 â€” Systems Alpha  
**Status:** Approved architecture; written-spec review required before implementation planning  
**Canonical local-main baseline:** `02c6acec90c12adb1cebb8a2f03f0d1fce982113`  
**Remote note:** `origin/main` intentionally remains `60fc0dfd9954e2d580157a580da2425e2b71dd70` until explicitly pushed.

## 1. Purpose

Add a small, persistent, server-authoritative Bestiary + Reputation foundation
that turns already-valid combat outcomes into long-term knowledge progress.

This gate proves two connected roadmap systems:

1. repeated valid monster defeats can unlock persistent bestiary discoveries;
2. defined bestiary milestones can award one-time faction reputation.

The first proof uses the existing Marauder family and one faction, **Scholars**.
The foundation must be reusable by future enemies, observations, research
actions, secrets, quests, reputation rewards and blueprint acquisition without
creating a second combat, reward or persistence authority.

## 2. Scope

### In scope

- profile schema v10 migration;
- persistent per-character Bestiary state;
- persistent per-character Reputation state;
- data-driven bestiary creature definitions;
- data-driven reputation faction definitions;
- Marauder and Marauder Captain proof entries;
- kill-count milestones;
- one-time Scholars reputation awarded by defined milestones;
- authoritative integration with the existing monster-reward transaction;
- replay/idempotency protection through the existing monster transaction
  boundary;
- reconnect/save/migration proof;
- service-level snapshots suitable for later UI consumers;
- automated Base and Dungeon regression coverage;
- TEMP-only Rojo validation builds.

### Out of scope

- bestiary UI or codex presentation;
- reputation NPCs, vendors or reputation shops;
- reputation ranks/titles with gameplay effects;
- mutually exclusive factions;
- market, auction house or player trading;
- transmog implementation;
- mounts;
- bestiary-derived combat bonuses;
- weakness/damage modifiers;
- exposing exact loot-table percentages to players;
- research minigames or world-interaction observations;
- quest/reputation reward catalogues;
- blueprint drop wiring;
- final reputation values or balance;
- guild reputation;
- raid/world-boss group-loot changes;
- art, VFX or Starting Base presentation work.

## 3. Design principles

1. **No second kill authority.** Bestiary progress is produced only from an
   already-authoritative monster reward/defeat transaction.
2. **Atomic progression.** XP/Gold reward history, bestiary kill progress,
   newly unlocked milestones and their reputation awards commit in the same
   profile mutation whenever practical.
3. **Exactly once.** Replaying an already-recorded monster transaction must not
   increment bestiary kills or reputation.
4. **No combat power.** Bestiary and reputation in this gate are knowledge and
   progression metadata only.
5. **Data-driven content.** New creatures and factions are definitions, not
   copied service logic.
6. **Migration-safe.** Existing schema-v9 profiles gain empty/default v10
   Bestiary and Reputation state without changing accepted progression,
   inventory, crafting, quest, class-advancement or recipe knowledge.
7. **Future-compatible, not speculative.** v1 stores enough structure for later
   observations/research and rewards, but implements only kill-driven progress.

## 4. Persistent data model

Advance the profile schema from **v9 to v10**.

Character state gains:

```luau
Bestiary = {
    Version = 1,
    Entries = {
        -- populated lazily
        -- ["marauder"] = {
        --     Kills = 0,
        --     Milestones = {
        --         ["first_defeat"] = true,
        --     },
        -- },
    },
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

Rules:

- Bestiary and Reputation belong to the character, not the account.
- Creature entries are created lazily on first valid progress.
- `Kills` is a non-negative integer.
- `Milestones` is boolean membership keyed by stable milestone ID.
- reputation points are non-negative integers in this foundation.
- unknown/invalid creature and faction IDs fail closed.
- migrations sanitize malformed tables rather than trusting stored client-like
  shape.
- no derived UI labels or display strings are persisted.

## 5. Definitions

### 5.1 Bestiary definitions

Add a shared `BestiaryDefinitions` module. Each creature definition has a stable
ID, optional family/category metadata, and ordered milestone definitions.

Initial proof configuration:

```luau
marauder = {
    DisplayName = "Marauder",
    Milestones = {
        {
            Id = "first_defeat",
            RequiredKills = 1,
            Reputation = {FactionId = "Scholars", Points = 5},
        },
        {
            Id = "field_notes",
            RequiredKills = 5,
            Reputation = {FactionId = "Scholars", Points = 10},
        },
        {
            Id = "dossier_complete",
            RequiredKills = 15,
            Reputation = {FactionId = "Scholars", Points = 20},
        },
    },
},

marauder_captain = {
    DisplayName = "Marauder Captain",
    Milestones = {
        {
            Id = "captain_defeated",
            RequiredKills = 1,
            Reputation = {FactionId = "Scholars", Points = 15},
        },
        {
            Id = "captain_studied",
            RequiredKills = 3,
            Reputation = {FactionId = "Scholars", Points = 25},
        },
    },
},
```

These point values and thresholds are **prototype proof values**, not final
economy balance.

Milestone definitions describe unlock conditions/reward metadata. They do not
directly mutate profiles.

### 5.2 Reputation definitions

Add a shared `ReputationDefinitions` module.

v1 contains only:

```luau
Scholars = {
    DisplayName = "Scholars",
},
```

No rank thresholds, vendors, mutually exclusive relationships or gameplay
modifiers are introduced in this gate.

## 6. Service architecture

### 6.1 BestiaryService

Responsibilities:

- validate Bestiary definitions;
- apply one valid kill to a character Bestiary state;
- determine which milestones become newly satisfied;
- never re-unlock an already-owned milestone;
- return a deterministic result describing:
  - creature ID;
  - new kill count;
  - newly unlocked milestone IDs;
  - milestone reward payloads;
- expose a read-only character snapshot for tests/future presentation.

Important boundary:

`BestiaryService` does **not** decide whether a monster really died and does not
accept client-authoritative kill claims.

Prefer a pure/static character-mutation helper for the atomic RewardService path,
with an instance wrapper only where useful for read-only snapshots or future
server-owned progress sources.

### 6.2 ReputationService

Responsibilities:

- validate faction IDs;
- apply a validated integer point delta to character Reputation state;
- expose read-only faction/all-faction snapshots;
- reject malformed, negative or non-integer award requests in this foundation.

The service does not implement shops, ranks or player-facing reward redemption.

### 6.3 RuntimeServices

Compose Bestiary/Reputation services through the existing shared runtime
composition. Do not create Base-only or Dungeon-only persistence.

## 7. Authoritative event flow

The existing monster reward/defeat transaction remains the producer.

Required order inside the existing authoritative mutation boundary:

1. receive the existing validated monster reward transaction;
2. reject/replay-return if that transaction already exists in
   `RewardHistory.Monster`;
3. apply the already-accepted monster XP/Gold/reward-history mutation;
4. map the authoritative monster/content identity to a stable Bestiary creature
   ID;
5. apply one Bestiary kill;
6. collect newly unlocked milestones;
7. apply only those milestones' configured Reputation awards;
8. commit the profile mutation;
9. return ordinary monster reward information plus optional bestiary/reputation
   metadata for diagnostics.

The implementation must use the repository's actual existing RewardService
transaction key and monster identity seam discovered during implementation
preflight. The design deliberately does not invent a parallel event ID.

If an enemy has no Bestiary definition, normal monster rewards continue and
Bestiary simply records no progress. Missing bestiary content must never break
ordinary combat rewards.

## 8. Atomicity and failure behaviour

- A duplicate monster transaction produces no additional kill count, milestone
  or reputation.
- A newly reached milestone and its reputation award are one logical operation.
- A malformed bestiary/reputation definition fails validation in tests/build
  rather than partially awarding live data.
- If a configured reputation reward references an unknown faction, the
  definition is invalid and the gate fails closed during validation.
- An undefined creature is a normal no-bestiary case, not a reward failure.
- Bestiary/Reputation mutation must not manufacture inventory, Gold, XP, SP,
  profession XP or recipes.
- No client RemoteEvent may directly set kill counts, milestone membership or
  reputation points.

## 9. Migration

`ProfileMigration` advances existing v9 profiles to v10.

Migration requirements:

- preserve every accepted v9 field;
- add `Bestiary.Version = 1` and an empty `Entries` table if absent;
- add `Reputation.Version = 1` and a valid `Factions.Scholars.Points` value;
- preserve valid existing future-shaped Bestiary/Reputation values if migration
  tests deliberately supply them;
- sanitize invalid negative/non-integer counters;
- migration is idempotent;
- nil/old profiles still converge to current schema;
- historical migration tests must distinguish historical fixture version from
  current resulting schema, avoiding the v8/v9 regression seen in the previous
  gate.

## 10. Consumer proof and acceptance scenarios

Automated proof must cover at least:

### Definitions

- Marauder and Marauder Captain definitions validate;
- kill thresholds are positive ascending integers;
- milestone IDs are unique within one creature;
- configured Reputation rewards reference valid factions;
- invalid definitions fail closed.

### Bestiary

- first Marauder kill creates entry and unlocks `first_defeat`;
- kills 2-4 increase count without duplicating the first milestone;
- kill 5 unlocks `field_notes` exactly once;
- kill 15 unlocks `dossier_complete` exactly once;
- Marauder Captain tracks independently;
- undefined creatures do not create state.

### Reputation

- initial Scholars reputation is zero;
- first Marauder milestone awards +5 exactly once;
- five-kill milestone produces total +15 from Marauder milestones;
- fifteen-kill milestone produces total +35 from Marauder milestones;
- Captain milestones stack independently;
- direct invalid/negative/fractional awards reject.

### Transaction integration

- one valid monster reward increments Bestiary once;
- replaying the same authoritative monster transaction does not increment kills
  or Reputation;
- ordinary XP/Gold reward behaviour remains unchanged;
- an undefined Bestiary creature still receives normal existing rewards;
- newly unlocked Bestiary milestone + Reputation commit atomically with the
  monster transaction.

### Persistence/migration

- v9 -> v10 migration;
- reconnect/reload retains Bestiary kills, milestones and reputation;
- repeated migration is idempotent;
- fresh profiles do not share Bestiary/Reputation tables.

### Regression

Existing accepted test families for profile migration, RewardService,
ContributionService, Quest/Class Advancement, Recipe Knowledge,
Professions/Crafting, Inventory/Bank, Identity/Equipment and Dungeon completion
remain green.

## 11. Studio/manual acceptance

This gate is backend-first. Manual testing should be minimal.

Request fresh Studio evidence only after automated tests and all four Rojo builds
pass.

Required Base evidence:

- no new red runtime/module-load errors;
- ordinary identity/profile lifecycle still reaches ready/complete state;
- relevant Bestiary/Reputation test families report PASS.

Required Dungeon evidence:

- no new red runtime/module-load errors;
- normal dungeon runtime reaches admission;
- killing supported Marauders/Captain does not disrupt normal XP/Gold,
  completion or return flow;
- relevant Bestiary/Reputation integration tests report PASS.

No visual bestiary/reputation UI is required for acceptance.

## 12. Expected implementation boundary

Likely new files:

- `src/ReplicatedStorage/Core/Shared/BestiaryDefinitions.luau`
- `src/ReplicatedStorage/Core/Shared/ReputationDefinitions.luau`
- `src/ServerScriptService/Core/Services/BestiaryService.luau`
- `src/ServerScriptService/Core/Services/ReputationService.luau`
- focused Bestiary/Reputation definition/service/integration/migration tests.

Likely modified files:

- `ProfileSchema.luau`
- `ProfileMigration.luau`
- `RuntimeServices.luau`
- the existing authoritative monster reward service/path;
- any content definition required only to expose a stable creature identity;
- historical migration tests whose *current resulting schema* expectation must
  advance to v10.

Do not modify combat ownership, enemy AI, client hit authority, inventory
authority, quest authority, recipe-learning authority or art systems unless the
preflight proves a tiny compatibility change is genuinely required.

## 13. Git/worktree safety

Implementation begins only from local main:

`02c6acec90c12adb1cebb8a2f03f0d1fce982113`

The implementation runner must:

- verify exact local-main baseline and clean tracked state;
- leave intentionally stale `origin/main` untouched;
- create a dedicated external feature worktree/branch;
- never reset hard, clean, force-push or rewrite history;
- never touch `DungeonMMO_Art`;
- use RED -> GREEN tests;
- run `git diff --check`;
- parse/validate Luau before requesting Studio evidence;
- build Base, Dungeon and both published project variants to timestamped TEMP;
- create a feature checkpoint only after automated validation;
- stop before merge, push or publish.

## 14. Exit gate

The Bestiary + Reputation Foundation is ready for project-owner runtime
acceptance when:

1. schema-v10 migration tests are green;
2. Bestiary definition/service tests are green;
3. Reputation definition/service tests are green;
4. authoritative monster-transaction integration is replay-safe;
5. accepted regressions remain green;
6. all four Rojo projects build;
7. fresh Base and Dungeon Studio outputs contain no new blocking errors;
8. normal dungeon reward/completion behaviour remains intact.

Acceptance of this gate does **not** imply the game has a finished bestiary,
finished reputation economy, reputation UI, blueprint acquisition sources,
market or guild reputation.
