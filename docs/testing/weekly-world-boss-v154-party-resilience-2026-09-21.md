# v1.54 weekly world boss — local party resilience acceptance

**Date:** 21 September 2026  
**Branch:** `wip/phase-4-test-hud-integration-v1`  
**Accepted source head:** `e83e4fae522582ec98bfc9cf4938ffdca9aa810b`  
**Status:** Two-client local combat, independent contribution/rewards,
member death/respawn, peer departure and connected-party wipe policy
are verified in unpublished Studio. Same-account network reconnect
and published cross-place travel remain pending.

## Changes in this increment

A small `WorldBossArenaLayout` now provides an explicitly opt-in
geometric prototype arena with a stable `WorldBossArenaSpawn`,
solid floor and enclosing walls. The normal Base and Dungeon places
do not receive this prototype. A finished world-boss place may replace
it with authored geometry while keeping the same anchor contract.

The real contribution pipeline was hardened for
`ExecuteMultiplayerTestAsync`: Roblox Studio test clients use
negative UserIds. `ContributionService` and
`DungeonContributionBridge` now accept negative integral IDs
**only while RunService:IsStudio()**. Live-player IDs remain
positive-only. Zero, nonfinite and malformed IDs/events remain
rejected.

`WorldBossMemberLifecycle` centralizes per-player encounter
attributes, Active/Dead session modes, real `Humanoid.Died`
tracking and same-session delayed respawn. The handler rechecks the
same connected player and stored session before respawning, so a stale
delayed callback cannot recreate a disconnected member.

The local wipe policy is now explicit: connected dead members may
respawn independently into the same frozen world-boss encounter.
A wipe does not reroll the event/week/party snapshot or create a new
weekly entitlement. This is the current backend policy for the
prototype; final gameplay balancing may change the respawn timing.

## Real two-client Studio Play

The final multiplayer fixture starts two actual Studio clients against
one guardian and uses the existing client CombatService attack path.

It verifies:

- both clients independently produce real persisted boss damage;
- both clients defeat one shared guardian;
- both contributing characters receive their own weekly reward once;
- immediate duplicate claims pay zero;
- one real client receives a client-owned Humanoid death;
- server `Humanoid.Died` persists that member as `Dead`;
- the member respawns into the **same** session and returns to
  `Active`;
- death/respawn does not create another weekly reward;
- one client can leave the network while the other remains present;
- the departed member's completed contribution remains stored;
- the surviving member cannot claim another reward.

The fixture printed `VERIFIED_MULTIPLAYER_PASS`. An earlier
diagnostic attempt exposed that mutating a network-owned test
Humanoid from the server did not reliably emit `Died`; the accepted
fixture triggers death on the owning real Studio client and validates
the replicated server death signal.

The fixture explicitly reports
`SAME_ACCOUNT_NETWORK_REJOIN_NOT_TESTED`: Studio can remove/add
test clients, but cannot prove a genuine reconnect of the exact same
Roblox account across a new reserved server.

## Final local regression receipt

Output:
`%TEMP%\DungeonMMO_WorldBoss_PartyAcceptance_Final\`.

At source head `e83e4fae522582ec98bfc9cf4938ffdca9aa810b`:

- six Rojo compositions built successfully;
- two-client world-boss Play: `VERIFIED_MULTIPLAYER_PASS`;
- member lifecycle/wipe policy: **14 assertions PASS**;
- contribution contract, including negative Studio identities:
  **20 assertions PASS**;
- Base reserved travel: **18 assertions PASS**;
- Base return/failure recovery: **22 assertions PASS**;
- durable Dungeon world-boss session: **33 assertions PASS**;
- Base profession regression: **14/14 PASS**;
- Dungeon gameplay backend regression: **30/30 PASS**.

The earlier world-boss real-combat receipt remains the proof of
single-client real guardian attack/damage/death/reward behavior.

## Remaining release gates

This is still local unpublished acceptance. No production event is
enabled. A real same-account network reconnect, published TEST
Base → ReserveServer world-boss → Base travel, profile lease handoff,
MemoryStore/DataStore persistence and cross-server reward recovery
are not verified.

Support contribution is accepted by the server authority and has
focused service coverage, but this increment does not claim a genuine
two-client healing/ward skill was executed during the guardian fight.
That remains useful multiplayer acceptance work before public release.

No cloud publish, production DataStore write, force-push or merge to
`main` was performed. Source/tests/docs were edited in GitHub;
Remote Desktop was limited to clean pulls, Rojo builds, Studio tests
and diagnostics.
