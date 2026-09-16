# Phase 2 Party Formation + 1-4-Player Group Entry Acceptance Record

**Date:** 16 September 2026
**Status:** ACCEPTED
**Starting local-main baseline:** `304ab0535d4de7e77313b7e0aef8d3b7bd899449`
**Accepted gameplay checkpoint:** `726299322fb31689e5e321878f287cccfcb07d81`
**Canonical roadmap after closeout:** Roadmap v1.38

## Accepted scope

This gate exposes the already group-capable dungeon-session architecture through
a real Base-side party flow without introducing parallel persistent party state.

Accepted party behaviour:

- 1-4 players;
- party creation and same-server invitation;
- invite acceptance;
- creator leadership;
- leader kick / member leave;
- deterministic leader transfer;
- readiness for multi-member entry;
- stale readiness reset on membership changes;
- stale readiness reset when selected dungeon changes;
- solo entry without unnecessary readiness;
- Temple and Abandoned Mine selection/entry;
- final server-side member validation before handoff.

## Authority result

`PartyService` is temporary Base-local authority. It does not persist membership
into Profile/DataStore/MemoryStore and does not become a second
DungeonSessionService.

`PartyEntryCoordinator` validates members and hands the final player array into
the existing TeleportCoordinator / DungeonSession path. Once a run is admitted,
existing dungeon membership/reconnect/revive/completion/reward/return authority
continues unchanged.

## Studio compatibility fixes accepted with the gate

Roblox Studio Local Server synthetic players use negative UserIds. The accepted
ProfileLeaseService change keeps positive UserIds mandatory outside Studio but
permits negative synthetic ids under `RunService:IsStudio()`, with regression
coverage for claim / renew / release.

Roblox Studio CoreGui failures prevented reliable manual race/class clicking for
local test clients. A Studio-only `PlayerN` harness submits Human -> Fighter via
the existing `IdentitySelectionRequest` remote. `IdentityService` remains the
authoritative validator/mutator.

## Automated evidence before Studio

The feature runner / recovery runners completed the applicable automated gates,
including:

- approved design/spec and implementation plan present;
- PartyService static contract;
- PartyEntryCoordinator static contract;
- party remote contract;
- Studio identity harness contract;
- Studio negative-UserId profile-lease regression contract;
- `git diff --check`;
- fresh Base, Dungeon, published Base and published Dungeon Rojo builds.

## Project-owner Studio evidence

The project owner reported that all requested multiplayer tests worked.

- [x] `[Profile Lease Tests] PASS`.
- [x] Player1-Player4 reached authoritative identity `Complete`.
- [x] Player 1 created a party.
- [x] Players 2, 3 and 4 were invited and accepted.
- [x] Party displayed the correct 4/4 membership.
- [x] Start before everyone Ready was rejected.
- [x] All four members could become Ready.
- [x] Kicking a member updated clients and cleared readiness.
- [x] After rebuild, leader leave transferred leadership to the
      longest-standing remaining member.
- [x] Rebuilt/ready party produced the expected Temple Studio entry proof.
- [x] Rebuilt/ready party produced the expected Abandoned Mine Studio entry proof.
- [x] No new red DungeonMMO runtime errors were reported.

Roblox CoreGui / ChatScript CreatorType errors observed during local-server setup
were external Studio CoreScript failures and are not recorded as DungeonMMO
runtime regressions.

## Qualification

Studio uses the dedicated party-entry proof path rather than a real published
reserved-server cross-Place teleport. This gate therefore accepts the new party
formation/readiness/server-validation/handoff integration while preserving a
future published TEST group-teleport check for release confidence.

## Safety result

- No Roblox place was published.
- No PROD path was enabled.
- No Robux was spent.
- No monetisation setting was changed.
- Live paid revives remain disabled.
- The separate art worktree was not touched.
- No destructive Git operation was used.

## Next selected gate

One targetable rare Skill Book acquisition path, designed first and implemented
through existing server-authoritative loot/reward/inventory/skill-book systems.
