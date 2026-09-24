# Warden genuine client lethal quest combat — v2.37

Date: 24 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`; executed commit `1e9178838b045923c24ebd600cc3bb63b10e7767`.
Disposable Studio log:
`%TEMP%\\DungeonMMO_v239_warden_client_lethal\\full_client.log`.
It ends with `[Greenward Live]
VERIFIED_TWO_CLIENT_WORLD_PROOFS_PASS`.

## Specific difference from v2.36

The previous successful v2.36 live quest fixture required
each real player's first client attack to reduce an actual
physical enemy Humanoid's HP, **then** invoked a trusted
server-only finishing strike to shorten the test. That prior
result remains correctly documented as server-assisted.

In v2.37, `strike_and_finish` and the separate test-only
DamageService finishing helper have been replaced by
`request_real_attack` and `strike_until_dead`. The client
actually sends its ordinary `CombatInputActions.request_attack()`
action on each attempt. The server fixture does **not** call
`DamageService.apply_damage` or otherwise proxy lethal damage.
The test fails if the real physical source monster does not
reach zero HP after bounded actual client attack requests.

## Exact checks behind the observed PASS

Two genuinely connected Play clients are admitted into the
same active Dungeon instance with disposable *different*
original Elven Knight quest stages. Existing
`C4QuestEncounterSpawns` creates and registers two
Rootbound Marauders and one Thornbound Colossus under the
real instanced encounter.

The first player attacks one Rootbound Marauder to zero
actual Humanoid HP, which awards exactly one owner-bound
`verdant_patrol_report`. The other, at quest stage five,
depletes the registered Thornbound Colossus's real HP
through its own normal attacks and receives exactly one
`verdant_guardian_seal`. Separate inventory checks
exclude cross-owner loot. The scripted runner only emits
`VERIFIED_TWO_CLIENT_WORLD_PROOFS_PASS` after both
health/loot assertions and StudioTestService return PASS.
The fresh unpublished Dungeon Rojo build also passed.

This result establishes two real-client *lethal* source
kills rather than only a successful hit before a simulated
server death. It does not establish all three sequential
stage-three reports, natural stage transitions, physical
NPC handoff in the *same* saved journey, persistent
inter-place DataStore rejoin, natural Captain AI
bleed, exact original C4 combat balance or release
readiness.
