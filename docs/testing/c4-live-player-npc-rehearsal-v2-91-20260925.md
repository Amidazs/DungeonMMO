# C4 Live Player-to-NPC Rehearsal v2.91 — Acceptance

Date: 25 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.

## Result

**GREEN — real source-mode player-to-NPC combat and rollback passed.**

## Candidate

`e457d1d4231e97f716b2f963a7ca9acc170aa94e`.

## Fresh build/focused evidence

- Base Rojo: PASS;
- Dungeon Rojo: PASS;
- git diff validation: PASS;
- Base focused Studio: **24/24 PASS**;
- Dungeon focused Studio: **27/27 PASS**.

## Live preparation evidence

One real Studio Play player was admitted to the unpublished Dungeon.

Source-boundary diagnostics reported:

`ok=true prerequisites=true source_candidate=true level=1 class=Mage blockers=0`.

Atomic enable reported:

`enabled=true dispatch=true resource_cutover=true max_health=98`.

A real reviewed Room1 Marauder was used:

- archetype: Marauder;
- pre-hit HP: 48;
- rehearsal target flag: server-only Studio diagnostic.

## Source attack evidence

The Play client invoked the existing
`CombatInputActions.begin_attack()` action.

Server evidence:

`#1 ATTACK ACCEPT Slash1`.

Source dispatch evidence:

`#1 DAMAGE APPLIED Slash1 2.6HP -> Room1_Marauder_1 (C4 source)`.

Exact observed source damage:

approximately `2.56666565`.

NPC HP after the hit:

approximately `45.43333435`.

Existing bookkeeping evidence:

`[C4 Combat Rehearsal Observer] ... contribution=true threat=2.5666656494140625 lethal=false`.

Quest observer evidence:

`[C4 Quest Rehearsal Observer] ... invoked=true accepted=false`.

The quest observer correctly rejected credit because the ordinary Room1
Marauder is not a registered quest monster. Invocation proves the source hit
still reaches the real quest-observer path.

## Rollback evidence

The same runtime bridge invoked the real coordinator disable.

Evidence before reset:

- source-hit NPC HP: approximately 45.43333435.

After rollback:

- coordinator: false;
- dispatch: false;
- calculation: false;
- resources: false;
- executor: false;
- player resource-cutover attribute: false;
- player MaxHealth restored to approximately 113.4.

## Existing-model attack evidence

The NPC was reset to 48 HP solely for the comparison strike.

The same existing client combat input was used again.

Server evidence:

`#2 ATTACK ACCEPT Slash1`.

Existing-model damage evidence:

`#2 DAMAGE APPLIED Slash1 10.0HP -> Room1_Marauder_1`.

Final NPC HP:

`38`.

No `(C4 source)` marker was present after rollback. This proves the
reversible dispatch returned to the current combat model rather than leaving a
partial source state.

Contribution/threat and quest-observer invocation remained present after
rollback.

## Safety boundary

No default activation, production spatial mapping, client cutover authority,
Roblox publish, production persistence, `main` merge or animation change
occurred.
