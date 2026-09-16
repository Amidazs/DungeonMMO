# Phase 2 Party Formation + Group Entry Implementation Plan

**Date:** 16 September 2026
**Approved design:** `docs/superpowers/specs/2026-09-16-phase-2-party-entry-design.md`
**Starting local-main baseline:** `304ab0535d4de7e77313b7e0aef8d3b7bd899449`

## Task 1 - Establish isolated gate and RED contracts

1. Create `wip/phase-2-party-entry-v1` in a dedicated worktree from local `main` at the exact approved baseline.
2. Prove the baseline has the accepted second-dungeon architecture and does not yet contain PartyService/party remotes.
3. Add RED-focused party service, entry bridge and remote contract tests before production implementation.
4. Keep RED proof automated; do not require project-owner interaction.

## Task 2 - Implement Base-local PartyService

1. Add `Base/PartyService.luau`.
2. Implement 1–4 membership, create/invite/accept/decline, readiness, dungeon selection, leave/kick and deterministic leadership transfer.
3. Keep invites 30-second, single-actionable-invite-per-target and server owned.
4. Reset readiness on every membership mutation and whenever the selected dungeon changes.
5. Add snapshots and authoritative `prepare_entry` output.
6. Run focused static/source contract verification.

## Task 3 - Implement PartyEntryCoordinator

1. Add `Base/PartyEntryCoordinator.luau`.
2. Resolve the full ordered member list from PartyService.
3. Validate every member before any teleport call.
4. Forward the unchanged complete Player array and selected dungeon ID to existing `TeleportCoordinator:start_dungeon`.
5. Add Studio-only validated multi-party proof without publishing or cross-place teleport.
6. Prove no invalid/missing member can be silently dropped.

## Task 4 - Wire Base runtime and remotes

1. Add `PartyActionRequest`, `PartySnapshot`, `PartyActionResult` to Core remotes.
2. Add `Base/PartyRuntime.luau` for server transport/orchestration.
3. Inject the existing BaseRuntime dependencies rather than constructing another RuntimeServices stack.
4. Reject direct solo entry for members of a 2–4 player party.
5. Preserve existing solo Temple/Mine and reconnect routing.
6. Broadcast state changes and expire invitations.

## Task 5 - Add functional party Dungeon Board UI

1. Replace the simple Base dungeon selector with one functional party/entry panel.
2. Render current party, leader, readiness and selected dungeon from PartySnapshot.
3. Provide create/invite/accept/decline/ready/leave/kick controls as authority permits.
4. Preserve solo entry for players outside multi-member parties.
5. Display stable server result reasons without pretending local button state is authoritative.

## Task 6 - Candidate verification

1. Run party static verifier.
2. Run `git diff --check`.
3. Build fresh TEMP candidates for:
   - `base.project.json`;
   - `default.project.json`;
   - `published-base.project.json`;
   - `published-dungeon.project.json`.
4. Confirm no commit, push, merge or Roblox publish occurred.

## Task 7 - Studio multiplayer acceptance gate

Project owner opens the generated Base candidate and runs a four-player local server.

Required evidence:

- focused Party Service / Party Entry Coordinator / Party Remote Contract families PASS;
- party grows to four members through invite/accept;
- readiness blocks and membership mutation clears ready state;
- leave/kick and deterministic leader transfer work;
- Temple Studio entry proof contains the complete current party and `TestDungeon`;
- Abandoned Mine Studio entry proof contains the complete current party and `AbandonedMine`;
- no new red runtime errors.

Do not claim published cross-place teleport proof from this local Studio gate. That requires a separate explicitly approved publish/test action.

## Task 8 - Closeout after evidence

After project-owner gameplay evidence:

1. update acceptance record, CURRENT_STATE, HANDOFF and TEST_MATRIX;
2. update canonical roadmap if the gate is accepted;
3. run verification-before-completion;
4. offer branch finishing choices;
5. never push/merge/publish without the corresponding explicit choice.
