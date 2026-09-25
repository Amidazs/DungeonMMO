# C4 Multiplayer Cutover v2.92 — Acceptance

Date: 25 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.

## Result

**GREEN — bounded two-player source cutover, partial withdrawal and full
rollback passed in the real unpublished Dungeon runtime.**

## Candidate

`55bd1f2154f2ba70e15b5b081bbbd390d4b4726f`.

The resource-withdrawal correction itself is included at
`b91be31033bee273225eec485be1abc032565c69`.

## Fresh static/build evidence

- `git diff --check`: PASS;
- Base Rojo build: PASS;
- Dungeon Rojo build: PASS.

The only local untracked paths were pre-existing Python `__pycache__`
directories under the quadruped animation tools. They were not edited or
committed.

## Fresh focused Studio evidence

The v2.55-v2.92 focused runner passed:

- Base: **24/24 PASS**;
- Dungeon: **27/27 PASS**;
- C4 Combat Dispatch: **20 assertions PASS**;
- C4 Combat Cutover: **11 assertions PASS**.

## Live two-client evidence

The disposable unpublished Dungeon used
`StudioTestService:ExecuteMultiplayerTestAsync(2, ...)` with two real
Studio clients.

Both connected players passed source-boundary diagnostics and were admitted to
the same atomic cutover transaction.

Both then attacked the same reviewed `Room1_Marauder_1` through the existing
client `CombatInputActions.begin_attack()` path.

Observed source hits included:

- approximately **2.946 HP** source damage with separate threat
  approximately **2.945835**;
- approximately **2.683 HP** source damage with separate threat
  approximately **2.683334**.

Both hits retained contribution delivery and invoked the quest observer without
granting invalid credit to the ordinary non-quest Marauder.

The rehearsal then used the existing server-owned threat service to establish a
deterministic threat leader and verified
`ThreatService.select_target(...)` returned that player with reason
`Threat`.

Marker:

`[C4 Multiplayer Cutover] TWO_SOURCE_PLAYERS_THREAT_PASS`.

## Participant-withdrawal bug found and fixed

The first live rehearsal exposed a real lifecycle bug.

The coordinator originally used
`C4ResourceCutoverService.remove_player()` when withdrawing one selected
participant. That method is intentionally a lightweight server-departure cleanup
and did not restore the connected player's HP/MP resource model or clear the
replicated cutover attribute.

The coordinator now uses the existing full
`disable_player()` rollback for participant withdrawal.

This preserves the distinction:

- coordinator withdrawal = return the connected participant safely to the
  current resource model;
- low-level `remove_player()` = final lightweight service cleanup during
  player teardown.

Focused coordinator coverage now requires the resource rollback path.

## Partial withdrawal evidence

After removing one of the two selected participants:

- the coordinator remained enabled;
- active participant count became one;
- the removed participant left source resource authority;
- the remaining participant stayed source-active;
- global calculation, executor and dispatch gates remained enabled.

The removed participant then used the same real client attack path and applied
**10.0 HP existing-model damage** with no `(C4 source)` marker.

Contribution, threat and quest-observer delivery remained intact.

The still-selected participant then attacked through the same client path. One
legitimate source normal-attack miss was tolerated by the bounded rehearsal,
and the next landed attack applied approximately **2.567 HP C4-source damage**.

Marker:

`[C4 Multiplayer Cutover] PARTIAL_REMOVE_FALLBACK_PASS`.

This proves the server-wide dispatch gate no longer widens source combat to
unselected players while another selected participant remains active.

## Final participant and full rollback evidence

Removing the final selected participant produced:

- coordinator disabled;
- active participant count zero;
- resource gate disabled;
- combat-calculation gate disabled;
- executor gate disabled;
- dispatch gate disabled.

The rehearsal then re-enabled both participants and exercised coordinator-wide
disable once more. Both participants returned to the existing resource model
and all source gates were off.

Markers:

- `[C4 Multiplayer Cutover] FULL_ROLLBACK_PASS`;
- `[C4 Multiplayer Cutover] VERIFIED_TWO_CLIENT_REHEARSAL_PASS`.

## Interpretation

The remaining bounded cutover-hardening gate is complete.

Source dispatch is now:

- disabled by default;
- server-authoritative;
- explicitly participant-scoped;
- reversible per participant;
- safe when one selected participant leaves while others remain;
- guaranteed to shut global source gates down when the final participant is
  removed;
- reversible for the whole selected group through the coordinator.

This closes the repeated cutover-hardening phase. Further single-player cutover
rehearsals are not required unless later source-combat changes invalidate these
contracts.

## Safety boundary

No production source activation, production elevation/night mapping, client
cutover authority, Roblox publish, production DataStore mutation, `main`
merge or animation change occurred.

## Next backend direction

Return to the broader MMORPG roadmap:

- progression, advancement quests and level-30 launch content;
- gathering/crafting professions and economy dependencies;
- guild systems and guild halls;
- raids and weekly world-boss progression;
- PvP and castle-capture systems;
- remaining dungeon/content integration.
