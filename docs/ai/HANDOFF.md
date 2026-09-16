# DungeonMMO Development Handoff

**Date:** 16 September 2026
**Active workstream:** Phase 2 - Vertical Slice
**Canonical roadmap:** DungeonMMO Roadmap v1.38
**Party Formation + 1-4-Player Group Entry:** ACCEPTED

## Accepted gameplay checkpoints

- Starting Base + Temple integration:
  `c7fe89ebda3c97634c97e89ad12e52ec23983ae9`
- Profession Foundation:
  `ce1577990f2795bf208d7b897e645f32a4a39a4f`
- Second Dungeon / Rare-State / Event:
  `d361348ec045873eed0fd992ceb04bfee908b06a`
- Previous local-main docs closeout:
  `304ab0535d4de7e77313b7e0aef8d3b7bd899449`
- Party Formation / Group Entry:
  `726299322fb31689e5e321878f287cccfcb07d81`

The approved local-merge closeout fast-forwards local `main` to the party
documentation closeout commit after merged-result verification. It deliberately
does not push `origin/main`.

## Accepted party contract

`PartyService` is temporary Base-server authority. It supports 1-4 members,
creator leadership, invite/accept, leader kick, member leave, deterministic
leader transfer, dissolution on empty, readiness and selected-dungeon state.

Multi-member entry requires all members Ready. Membership changes and dungeon
selection changes invalidate readiness. Solo entry remains available without a
Ready requirement.

`PartyEntryCoordinator` validates the final member set and passes it into the
existing `TeleportCoordinator` / `DungeonSessionService` architecture. Once a
run is admitted, DungeonSession membership is authoritative and temporary party
state does not become persistent run/profile state.

Temple and Abandoned Mine are both supported.

## Studio acceptance

The project owner completed the required four-player Studio Local Server gate and
reported every requested check worked:

- Profile Lease regression PASS;
- Player1-Player4 identity auto-harness reached authoritative Complete;
- create + invite/accept to 4/4;
- not-ready start rejection;
- all-member Ready flow;
- kick updates and readiness reset;
- leader leave -> longest-standing member leadership transfer;
- Temple party entry Studio proof;
- Abandoned Mine party entry Studio proof;
- no new red DungeonMMO runtime errors.

Roblox CoreGui/ChatScript CreatorType errors encountered during the gate were
Studio CoreScript failures, not DungeonMMO runtime errors. The test-only identity
harness and negative synthetic-UserId lease allowance remain Studio-gated.

## Qualification

The Studio party-entry proof does not itself perform a published reserved-server
cross-Place teleport. The accepted lower-layer TeleportCoordinator /
DungeonSession contracts already support player arrays; real published group
teleport can be rechecked in a later published TEST/release gate.

## Safety

- Primary repo: `C:\Users\Remko\Documents\Roblox\DungeonMMO`
- Party feature worktree:
  `C:\Users\Remko\Documents\Roblox\DungeonMMO_PartyEntry_v1`
- Feature branch:
  `wip/phase-2-party-entry-v1`
- Environment: TEST
- No Roblox publish occurred.
- Live paid revives remain disabled.
- No PROD / Robux / monetisation action is authorized.
- `art/dungeon-environment-prototype` remains isolated.

## Exact next action

Design the **targetable rare Skill Book acquisition proof** before source work.

Reuse current server-authoritative loot/reward/inventory/skill-learning systems.
Keep the first proof narrow: one deliberate target path for one specific rare
book. Do not turn it into a broad loot-table, market or economy rewrite.

Bank/storage, Travel, public matchmaking, guild-party breadth and final UI/art
polish remain later scope.
