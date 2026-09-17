# Phase 3 Contribution Foundation — Design

**Date:** 17 September 2026
**Phase:** Phase 3 — Systems Alpha
**Status:** Design approved in principle; awaiting written-spec confirmation
**Canonical local-main baseline:** `56966cf4b3dd70c20d270c5f9aafb703a64980dc`
**Remote note:** `origin/main` intentionally remains `60fc0dfd9954e2d580157a580da2425e2b71dd70`.

## Purpose

The next Phase 3 backend gate establishes reliable, server-authoritative contribution accounting for Tank, Support, and Damage play.

The immediate goal is **measurement, not rewards**. The gate must prove that contribution can be recorded consistently across the accepted combat/support systems, persisted with the active dungeon session, survive reconnect, and be queried deterministically.

This foundation will later support:

- role-aware dungeon completion rules;
- raid and advanced-difficulty contribution checks;
- encounter tuning;
- guild and group statistics;
- anti-leech / anti-exploit validation;
- future reward logic.

No reward multiplier, loot multiplier, leaderboard, or player-facing score is introduced in this gate.

## Scope

This gate adds:

- a central `ContributionService`;
- a normalized trusted contribution-event contract;
- per-player session contribution ledgers;
- Damage, Tank, and Support channels;
- reconnect-safe persistence through existing dungeon session state;
- deterministic contribution snapshots;
- adapters/bridges from accepted server-authoritative systems;
- automated tests for dedupe, reconnect persistence, role-channel attribution, and invalid-event rejection.

This gate does **not** add:

- new profile schema fields;
- permanent account/character contribution history;
- player-facing contribution UI;
- reward scaling;
- loot eligibility based on contribution;
- fourth starting archetype;
- guilds;
- reputation;
- bestiary;
- player market;
- raids/world bosses/castles;
- PvP contribution scoring.

## Design principles

1. **Server authority only.** Clients never submit authoritative contribution values.
2. **Session-scoped.** Contribution belongs to the active dungeon/session, not to the persistent player profile.
3. **Event-driven.** Existing authoritative services emit normalized contribution events after their own validation succeeds.
4. **Central ledger.** Individual combat/support systems do not maintain independent contribution totals.
5. **Idempotent.** Every event has a stable event ID and can be replayed safely without double-counting.
6. **Reconnect-safe.** The active contribution ledger is stored in dungeon session state and survives player disconnect/reconnect.
7. **No premature reward policy.** Measurement is proven before contribution affects rewards or access.
8. **Extensible without coupling.** Future systems can add trusted event types without changing the ledger model.

## Contribution model

Each active dungeon session stores a contribution block:

```luau
InstanceState = {
    -- existing instance state...
    Contribution = {
        Version = 1,
        Players = {
            ["12345"] = {
                Damage = 0,
                Tank = 0,
                Support = 0,
                Events = {
                    ["event-id"] = true,
                },
                Breakdown = {
                    DamageDealt = 0,
                    DamageMitigated = 0,
                    AggroHeld = 0,
                    EffectiveHealing = 0,
                    EffectiveWard = 0,
                    UtilitySupport = 0,
                },
            },
        },
    },
}
```

The public API exposes normalized totals and selected breakdown values. Internal event-history detail is kept only as needed for dedupe and diagnostics.

The ledger is not a permanent profile statistic.

## Normalized event contract

Trusted server systems record events in this shape:

```luau
{
    EventId = "stable-server-owned-id",
    SessionId = "active-session-id",
    UserId = 12345,
    Type = "DamageDealt",
    Amount = 24.5,
    Metadata = {
        TargetId = "enemy-instance-id",
        SourceId = "Slash1",
    },
}
```

Required fields:

- `EventId`
- `SessionId`
- `UserId`
- `Type`
- positive finite `Amount`

`Metadata` is optional and diagnostic. It is not used as an authority signal.

Events with duplicate `EventId` for the same player's active session are idempotent no-ops.

## Contribution channels

### Damage

Damage contribution records **validated effective damage dealt** to hostile encounter targets.

Initial event type:

- `DamageDealt`

Rules:

- only damage that the accepted server damage/validation path actually applies is eligible;
- overkill beyond the target's remaining effective health does not count if the underlying damage service exposes effective damage;
- friendly/self damage does not count;
- test/training-only targets outside an active dungeon session do not count.

### Tank

Tank contribution measures validated defensive work, not merely being assigned a Tank label.

Initial event types:

- `DamageMitigated`
- `AggroHeld`

`DamageMitigated` includes damage prevented through accepted block/ward/defensive mechanics where the authoritative service can prove the prevented amount.

`AggroHeld` is time- or sample-based authoritative threat ownership against eligible hostile encounter targets. It must not be generated by a client timer.

The v1 gate does not attempt to assign a universal weighting that says one second of aggro equals a fixed amount of damage. The service stores raw breakdown values and a normalized Tank total using configurable server-side weights.

Initial configurable weights:

```luau
ContributionConfig = {
    Damage = {
        DamageDealt = 1.0,
    },
    Tank = {
        DamageMitigated = 1.0,
        AggroHeld = 1.0,
    },
    Support = {
        EffectiveHealing = 1.0,
        EffectiveWard = 1.0,
        UtilitySupport = 1.0,
    },
}
```

These defaults are placeholders for accounting equivalence only, not launch balance.

### Support

Support contribution measures effective assistance that changes combat state.

Initial event types:

- `EffectiveHealing`
- `EffectiveWard`
- `UtilitySupport`

Rules:

- healing counts only actual health restored, not attempted overheal;
- ward contribution counts effective damage absorption/prevention;
- utility support requires a trusted server event from an accepted support mechanic;
- repeated no-effect casts do not create contribution.

`UtilitySupport` is intentionally generic at the ledger boundary so future validated effects can use one contract, but v1 only wires support mechanics already present in the repository.

## `ContributionService`

Proposed location:

`src/ServerScriptService/Core/Services/ContributionService.luau`

Responsibilities:

- validate trusted contribution events;
- validate active session membership;
- reject cross-session attribution;
- deduplicate events;
- map event types to Damage/Tank/Support channels;
- apply configurable weights;
- update breakdown values;
- update channel totals;
- persist through `DungeonSessionService:set_instance_state`;
- build deterministic read-only snapshots.

Proposed API:

```luau
ContributionService.new(sessionService, config)

ContributionService:record(event)
ContributionService:get_player_snapshot(sessionId, userId)
ContributionService:get_session_snapshot(sessionId)
ContributionService:reset_for_test(sessionId)
```

`reset_for_test` is test-only and must not be exposed through runtime remotes.

Stable rejection reasons:

- `UnknownSession`
- `InactiveSession`
- `UserNotInSession`
- `InvalidContributionEvent`
- `UnknownContributionType`
- `ContributionPersistenceFailed`

Duplicate events return success with `already_applied = true`.

## Persistence and reconnect

The service uses the accepted dungeon session `InstanceState` as the persistence boundary.

Flow:

1. fetch authoritative dungeon session;
2. validate session/user/event;
3. clone or safely mutate the contribution substate;
4. apply event if its ID has not already been seen;
5. persist via `DungeonSessionService:set_instance_state`;
6. return a snapshot/result.

On reconnect, the player resumes the same session state and therefore the same contribution ledger.

No additional DataStore or MemoryStore is introduced.

## Runtime integration

`RuntimeServices` creates `ContributionService` where dungeon session authority is available.

The service is available to dungeon runtime and authoritative combat/support bridges.

There is no client RemoteEvent for arbitrary contribution submission.

A future read-only snapshot remote may be added when player-facing UI is designed, but not in this gate.

## Initial event bridges

The gate should wire only existing authoritative systems that have a clear, testable value source.

### Damage bridge

The accepted damage application path records `DamageDealt` after damage is validated/applied.

Event identity must be stable across retries. Prefer an existing attack/action/combat-validation ID combined with target identity where available.

### Defensive bridge

Existing defense/ward paths record effective prevention as `DamageMitigated` or `EffectiveWard`.

Do not estimate prevented damage on the client.

### Healing bridge

The accepted healing path records `EffectiveHealing` using the actual health delta.

### Aggro bridge

Existing hostile AI/threat authority emits `AggroHeld` from server-owned aggro ownership samples or authoritative intervals.

If the current AI layer does not yet expose a deterministic stable sampling seam, the service and raw event type are implemented but the production Aggro bridge may be deferred inside this gate rather than adding a fragile timer.

This is the only explicitly conditional bridge in v1.

## Weighting

Contribution totals are derived:

```text
Damage  = Σ(DamageDealt × configured weight)
Tank    = Σ(DamageMitigated × weight)
        + Σ(AggroHeld × weight)

Support = Σ(EffectiveHealing × weight)
        + Σ(EffectiveWard × weight)
        + Σ(UtilitySupport × weight)
```

The raw breakdown remains available so later balance work can change weighting without losing conceptual meaning.

No threshold such as "20% contribution required" is introduced now.

## Exploit and integrity rules

The service must fail closed for:

- client-originated arbitrary values;
- unknown session IDs;
- users who are not session members;
- NaN / infinity / zero / negative amounts;
- unknown event types;
- duplicate event IDs;
- cross-session replay;
- contribution after a session is no longer contribution-eligible.

Where event IDs can be generated deterministically from existing action IDs, use those IDs rather than random IDs generated at the ledger boundary.

## Testing

Automated tests must prove:

1. valid Damage event increments Damage and `DamageDealt`;
2. duplicate event ID does not double-count;
3. invalid/negative/NaN/infinite amount rejects;
4. unknown event type rejects;
5. non-member user rejects;
6. wrong session rejects;
7. Damage events do not affect Tank/Support;
8. mitigation affects Tank only;
9. effective healing affects Support only;
10. effective ward affects Support and/or Tank exactly as defined by the bridge contract, never both accidentally;
11. utility support affects Support only;
12. snapshots are deterministic and read-only copies;
13. contribution state persists through session `InstanceState`;
14. reconnect/re-fetch preserves the ledger;
15. contribution state survives unrelated session-state updates;
16. bridge tests prove only authoritative successful actions emit events;
17. failed/rejected damage/heal/defense actions emit no contribution;
18. existing combat, healing, ward, profession, dungeon, quest, travel, Bank, and party tests remain green;
19. all four Rojo projects build.

## Manual Studio acceptance

Manual Studio testing is requested only after automated/build verification.

Expected evidence:

- all existing suites remain green;
- new Contribution Service tests pass;
- new bridge/integration tests pass;
- no red DungeonMMO runtime errors;
- one controlled dungeon test can demonstrate:
  - validated player damage increases Damage contribution;
  - effective heal increases Support contribution;
  - defensive mitigation increases Tank contribution;
  - reconnect preserves the same session contribution snapshot.

No visual/UI acceptance is required.

## Worktree / Git safety

Create:

- branch: `wip/phase-3-contribution-foundation-v1`
- worktree: `C:\Users\Remko\Documents\Roblox\DungeonMMO_Phase3_ContributionFoundation_v1`

Start from canonical local main:

`56966cf4b3dd70c20d270c5f9aafb703a64980dc`

Rules:

- no direct gameplay development on `main`;
- preserve all existing worktrees;
- do not touch the art worktree;
- no reset/clean/force push/history rewrite;
- no pull/push/publish;
- build only to TEMP;
- integration only after accepted Studio evidence.

## Acceptance boundary

This gate is accepted when:

- the contribution ledger is deterministic and server-authoritative;
- Damage/Tank/Support channel accounting works;
- session-state persistence/reconnect behavior is proven;
- authoritative bridges are covered;
- duplicate/rejected actions cannot inflate contribution;
- no profile schema change is introduced;
- all existing automated/runtime suites remain green;
- all four Rojo builds pass;
- Studio evidence is clean.

Reward eligibility, player-facing scores, balance thresholds, and contribution-based loot remain later design decisions.
