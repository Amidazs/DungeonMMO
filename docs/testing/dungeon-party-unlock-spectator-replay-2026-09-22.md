# Dungeon party unlock, spectator combat and replay acceptance

Date: 22 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Latest gameplay source with the Base UI status fix:
`b6fe3be03a6e1a9046114c2e4744353d7fccbd9a`
Last full multiplayer/backend suite gameplay source:
`c6925c0f28deb64b734175fdd96dac84d87e74da`

## Player rule: every member must unlock the selected difficulty

A party can start a higher difficulty only when **every** selected
character has earned the prerequisite clear for **that specific dungeon**.
The party leader's unlock does not grant entry to other members.

Three server-side entry paths are checked:

1. Base PartyEntryCoordinator validates every present and ready member
   through the existing profile-backed
   `DungeonDifficultyProgressionService.validate_entry` callback.
   Rejection includes the offending member's UserId and name.
2. TeleportCoordinator revalidates every member's profile-backed unlock
   immediately before reserving a server, including direct or alternate
   coordinator callers. A locked member blocks the entire group with
   no reservation, session creation, profile handoff or teleport.
3. Play again creates a **new** run, not an exemption. The Dungeon
   runtime passes the same per-member progression validator to
   DungeonReplayService; the latter checks every connected player
   before accepting a vote or simulated/published launch. A newly
   locked or unavailable member clears prior replay votes and returns
   a named failure. The actual transport performs another check
   just before reserving.

The Base entry UI now reports the name or UserId of the member
lacking the selected unlock. The Dungeon replay UI presents the
offending UserId and requested difficulty. Selecting a difficulty
alone does not bypass these gates.

Focused server-side regressions:

- Four-player Base party: member 4 locked for Depth2 blocks all,
  followed by four unlocked members entering. A locked leader
  also blocks everyone.
- Depth3 requires every member's own Depth2 clear; completing
  Depth1 alone is insufficient. Temple unlocks do not carry
  to Abandoned Mine.
- TeleportCoordinator independently rejects a locked fourth
  member, locked leader or missing unlock record **before**
  ReserveServerAsync. Focused coordinator tests pass 23 assertions.
- ReplayService blocks either a locked member or locked leader;
  after unlocking, both party members must still vote. The
  focused replay suite passes 28 assertions.

## Spectator combat and genuine client recovery

The Dungeon runtime marks newly admitted members combat-ineligible
until their persisted mode and connection state are validated.
Death, spectator transitions and automatic revive update that
server-owned permission and the existing character participant flag.
Character recreation cannot turn a Spectating member Active.

The combat server rejects basic attacks, skills, defensive actions
and still-pending attack/skill sequences from non-Active dungeon
members. The damage authority rejects delayed hits from such
members, so those hits cannot grant damage contributions.
Dungeon enemy targeting rejects nonparticipant spectator characters.

The **two-real-client unpublished Studio fixture** executed
`scripts/studio/dungeon_spectator_combat_live.luau`. A player
used their free revive, died again, entered Spectating mode,
and received a fresh test-created character. The member remained
spectating and combat-ineligible; authenticated attack, skill
and defense requests were rejected. The damage probe dealt zero
spectator damage while a still-Active peer's damage succeeded.
The fixture printed `VERIFIED_MULTIPLAYER_PASS`.

This is not a genuine network reconnect to a published reserved
server, and does not by itself establish all boss reward rules.

## Play again / UI regression and test sequence

The initial two-client replay test intermittently failed:
the real server accepted the final party vote, but the client
could lose the terminal replay state when a late revive-state
snapshot arrived. Subsequent diagnostics confirmed a real
server replay result with both clients consenting. The Dungeon
UI was corrected to preserve Play again / ReplayWaiting /
ReplaySimulated presentation against stale revive snapshots;
the fixture now checks eventual client state after both votes.

At gameplay source `c6925c0`, six Rojo compositions built and
the following independent unpublished Studio gates all passed:

- Base all-party higher-difficulty entry fixture.
- Teleport coordinator: **23 assertions**.
- Dungeon Play again service: **28 assertions**.
- Dungeon backend matrix: **30/30**.
- Two real clients using the actual Play again remote:
  `VERIFIED_MULTIPLAYER_PASS`.
- Two real clients verifying spectator combat exclusion:
  `VERIFIED_MULTIPLAYER_PASS`.

The earlier four-client physical Room1 wipe/re-entry test
also passed at gameplay source `e7ee1bf`, after the new
combat gate was introduced.

At final gameplay source `b6fe3be`, which additionally
makes the Base UI identify the locked member, all six
Rojo compositions **rebuilt** and the focused Base
all-party unlock regression **passed**. The full two-client
replay and spectator fixtures were not rerun on this
UI-only commit; their acceptance belongs to `c6925c0`.
The feature worktree was clean and `git diff --check`
passed. All source/docs changes were authored in GitHub.

## Remaining release boundaries

- A genuine same-account disconnect/rejoin into a published
  reserved server with verified platform join routing,
  reacquired profile lease and spectator combat restriction.
- Full ordinary combat, secret/mini-boss reward and progression
  durability across an actual network reconnect.
- Published TEST higher-depth completion, fresh-instance replay,
  real cross-place travel and cloud persistence.

No `main` merge, force-push, Roblox place publishing,
paid purchase or production DataStore change was performed.
