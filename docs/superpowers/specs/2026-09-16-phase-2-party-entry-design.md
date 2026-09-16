# Phase 2 Party Formation + 1–4 Player Group Entry Design

**Date:** 16 September 2026
**Status:** APPROVED
**Starting local-main baseline:** `304ab0535d4de7e77313b7e0aef8d3b7bd899449`

## Goal

Add the first real party-formation and group-entry layer to the Starting Base without creating a second persistence, teleport or dungeon-session architecture.

The proof must allow one to four players in the same Base server to form a party, select either accepted dungeon, ready as a group and hand the exact ordered membership to the existing `TeleportCoordinator:start_dungeon(players, dungeonId, placeId)` path.

## Scope lock

This gate includes:

- Base-local parties of 1–4 players;
- create, invite, accept/decline, ready/unready, leave and leader kick;
- deterministic leader transfer when the leader leaves;
- leader-owned dungeon selection;
- Temple and Abandoned Mine selection;
- server-side all-member validation before group entry;
- functional Base party UI;
- Studio multiplayer proof plus automated handoff tests.

This gate deliberately excludes:

- cross-server party persistence;
- Profile/DataStore party state;
- public matchmaking;
- guild-party systems;
- cross-server social discovery;
- published Roblox changes without a separate approval;
- final party UI art/polish.

## Authority model

### Base party state

`PartyService` owns all live party state in Base server memory. The client only sends requests. No client can directly set party membership, leadership, readiness or selected dungeon.

A party contains:

- `PartyId`;
- `LeaderUserId`;
- `SelectedDungeonId`;
- ordered members with `UserId`, display metadata, `Ready` and immutable `JoinOrder`.

A player can belong to at most one party. Party state is not written to a profile and is intentionally lost if that Base server disappears.

### Dungeon state

Party authority ends at successful dungeon entry. The accepted `DungeonSessionService` becomes authoritative for the run's member set, handoff, reconnect, revives, completion eligibility, rewards and return-to-Base flow.

No new persistent party/session record is introduced.

## Party lifecycle

### Creation

Any loaded Base player may create a party if they are not already in one. The creator becomes leader and the party defaults to Temple (`TestDungeon`).

### Invites

Only the leader may invite another loaded player in the same Base server.

Invites:

- expire after 30 seconds;
- are addressed to one target player;
- allow at most one actionable incoming invite per target;
- cannot invite the inviter;
- cannot invite a player already in a party;
- cannot be issued when the party already has four members.

Accepting an invite adds the target at the end of the ordered member list. Declining or expiry removes only the invite.

### Membership changes

Any membership change clears readiness for all remaining members. Changing the selected dungeon also clears readiness. These rules prevent a party from entering with stale consent after either its composition or destination changed.

Ordinary members may leave. The leader may kick ordinary members.

If the leader leaves, leadership passes to the remaining member with the lowest `JoinOrder` (the longest-standing member). Outstanding invites for the old leadership state are cancelled.

If the final member leaves, the party is destroyed.

## Readiness and entry

A one-player party does not require readiness. Existing solo dungeon entry remains valid.

For two to four members:

- only the leader may start group entry;
- every current member must be Ready;
- the selected dungeon comes from server-owned party state;
- a direct solo `DungeonEntryRequest` from a member of a multi-member party is rejected with `PartyEntryRequired`.

Before entry, the server revalidates every member:

- the player still exists in the current Base server;
- their profile is loaded;
- their identity is complete;
- they are not already pending teleport;
- they do not have a recoverable/active dungeon session that must take precedence;
- the final member count remains within the selected dungeon's 1–4 contract.

If any member fails validation, the group stays in Base and the result identifies the failing member. Nobody is silently omitted from the run.

## Entry bridge

`PartyEntryCoordinator` is a thin adapter between `PartyService` and the accepted `TeleportCoordinator`.

It:

1. asks `PartyService` for the authoritative ready entry snapshot;
2. resolves every member UserId to a live Player;
3. validates every member through Base-owned callbacks;
4. obtains the configured Dungeon Place ID;
5. calls the existing `TeleportCoordinator:start_dungeon` with the complete ordered Player array and selected dungeon ID.

The coordinator owns no party persistence and does not duplicate reservation, session creation, instance-state, save/handoff or teleport logic.

### Studio proof boundary

Roblox Studio cannot prove a real cross-place reserved-server teleport using this local candidate without publishing it. For a multi-member Studio party, the bridge therefore returns `StudioPartyEntryProof` after all authoritative party/member validation and before the external teleport call.

The proof includes the exact ordered member list and selected dungeon. Automated tests separately verify that the non-Studio path forwards that same complete list to `TeleportCoordinator`.

Published cross-place multiplayer teleport remains a later explicit publish/test gate, not something this implementation may perform autonomously.

## Base runtime integration

`PartyRuntime` owns transport and Base-server orchestration:

- listens to `PartyActionRequest`;
- emits `PartySnapshot` and `PartyActionResult`;
- broadcasts snapshots after state changes;
- expires invites periodically;
- removes departing players from party state;
- invokes `PartyEntryCoordinator` for `StartEntry`.

`BaseRuntime.server.luau` supplies existing authoritative dependencies and validation callbacks. It does not create another `RuntimeServices` instance.

New remotes:

- `PartyActionRequest`;
- `PartySnapshot`;
- `PartyActionResult`.

Existing `DungeonEntryRequest` / `DungeonEntryResult` remain the solo entry/result channel.

## Functional UI

The Base Dungeon Board becomes the functional party/entry surface.

It shows:

- Temple / Abandoned Mine selection;
- Create Party when solo;
- incoming invite Accept / Decline;
- current leader and ordered members;
- Ready state;
- leader-only invite and kick controls;
- Leave Party;
- leader-only group Start Entry;
- solo entry when no multi-member party exists.

The UI consumes server snapshots. It does not infer authority from local button state.

This is functional prototype presentation only; final art, responsive layout and controller/mobile polish are later work.

## Error handling

Party mutations return stable reason strings such as:

- `AlreadyInParty`;
- `NotInParty`;
- `LeaderOnly`;
- `PartyFull`;
- `InviteAlreadyPending`;
- `InviteMissing`;
- `InviteExpired`;
- `TargetAlreadyInParty`;
- `PartyNotReady`;
- `PartyEntryRequired`;
- `PartyMemberMissing`;
- `ProfileNotReady`;
- `IdentityIncomplete`;
- `TeleportAlreadyPending`;
- `ActiveDungeonSession`.

No failure path drops only the invalid member and teleports the remainder.

## Testing

### Automated Studio test families

`[Party Service Tests]` covers lifecycle, invites, readiness reset, max size, authority, leader transfer and expiry.

`[Party Entry Coordinator Tests]` covers missing/invalid-member rejection, exact 2/3/4 member forwarding, both accepted dungeon IDs, coordinator failure propagation and Studio proof behavior.

`[Party Remote Contract Tests]` verifies the three transport remotes exist.

Existing `TeleportCoordinatorTest` remains the accepted lower-level group session/handoff coverage.

### User Studio multiplayer gate

Open the generated Base candidate and run a local server with four players. Verify:

- focused party test families print PASS;
- party create/invite/accept works to 4/4;
- entry is blocked until all multi-member party members are Ready;
- membership change clears readiness;
- kick and leave update all clients;
- leader leave transfers leadership to the longest-standing remaining member;
- Temple Start Entry prints one Studio proof with the complete party list and `Dungeon=TestDungeon`;
- Abandoned Mine Start Entry prints one Studio proof with the complete party list and `Dungeon=AbandonedMine`;
- no new red runtime errors appear.

## Safety

- TEST/local development only;
- no Roblox publish;
- no PROD path;
- no Robux/monetisation change;
- no destructive Git;
- no direct development on `main`;
- separate art worktree remains untouched;
- second-dungeon worktree remains untouched.
