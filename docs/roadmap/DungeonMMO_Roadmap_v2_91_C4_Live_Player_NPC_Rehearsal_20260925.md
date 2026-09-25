# DungeonMMO Roadmap v2.91 — C4 Live Player-to-NPC Rehearsal

Date: 25 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v2.90](
DungeonMMO_Roadmap_v2_90_C4_Runtime_Rehearsal_20260925.md).

## Goal

Complete the next v2.90 acceptance gate against the real unpublished Dungeon
runtime: cut over one connected player, send a genuine existing combat-input
request against a real reviewed Dungeon NPC, prove source damage and existing
combat observers remain intact, then roll back and prove the same input returns
to the existing combat model.

## Rehearsal diagnostics

The unpublished Studio bridge now exposes source-boundary diagnostics from the
actual Dungeon runtime. It remains a ServerStorage BindableFunction and is
unavailable to clients or published servers.

Before activation, the connected Studio player reported:

- source cutover prerequisites ready: true;
- source stat candidate ready: true;
- activation blockers: 0;
- level: 1;
- class: Mage.

The rehearsal again uses:

- `SourceUnitsPerStud = 1`;
- `IsNight = false`.

These are test-only inputs and are not production spatial decisions.

## Real existing combat input

The attack was sent from the Play client through the existing
`CombatInputActions.begin_attack()` path.

That path reaches the existing client controller and
`AttackRequest:FireServer()`, then the ordinary authoritative
`CombatService` request handler. No source-only test function directly
applied NPC damage.

The server accepted:

`#1 ATTACK ACCEPT Slash1`.

With the atomic C4 cutover enabled, the real Room1 reviewed Marauder then
received:

`#1 DAMAGE APPLIED Slash1 2.6HP -> Room1_Marauder_1 (C4 source)`.

Exact source-applied damage for that random source roll was approximately
2.56666565. NPC health moved from 48 to approximately 45.43333435.

## Existing combat observers

The same trusted source hit continued through the existing post-damage
bookkeeping:

- contribution accepted: true;
- threat total after the hit: approximately 2.56666565;
- quest damage observer invoked: true;
- quest result accepted: false.

The quest result is correctly false because this ordinary Room1 Marauder is not
a registered advancement-quest monster. The important acceptance result is
that the real quest observer received the trusted hit without fabricating quest
credit.

A Studio-only diagnostic marker was added for this rehearsal evidence. It does
not alter contribution or quest return semantics.

## Atomic rollback and legacy proof

The same runtime coordinator was disabled after the source hit.

Rollback evidence:

- coordinator enabled: false;
- dispatch gate: false;
- calculation gate: false;
- resource gate: false;
- executor gate: false;
- player `C4ResourceCutoverActive`: false;
- player MaxHealth restored to approximately 113.4.

The NPC was reset to 48 HP only for the comparison strike.

The exact same existing client combat-input path was then used again.

The server accepted:

`#2 ATTACK ACCEPT Slash1`.

With source dispatch disabled it applied:

`#2 DAMAGE APPLIED Slash1 10.0HP -> Room1_Marauder_1`.

There is no C4-source dispatch suffix. NPC health became 38, proving the
existing combat model resumed after rollback.

Contribution, threat and quest observer delivery also remained intact after
rollback.

## Fresh static and focused acceptance

Final source/test candidate:

`e457d1d4231e97f716b2f963a7ca9acc170aa94e`.

Fresh unpublished builds:

- Base: PASS;
- Dungeon: PASS;
- git diff validation: PASS.

Fresh focused Studio:

- Base: **24/24 PASS**;
- Dungeon: **27/27 PASS**.

No focused C4 regression was introduced by the rehearsal diagnostics.

## Safety boundary

v2.91 does **not**:

- enable source combat by default;
- choose a production Roblox-to-C4 elevation conversion;
- choose a production source-night mapping;
- expose source activation to clients;
- weaken PvE target legality;
- publish Roblox places;
- merge to `main`;
- mutate production DataStores;
- edit animation projects.

## Next backend implementation

One final bounded combat-rollout rehearsal should cover multiple simultaneous
participants before leaving cutover hardening:

1. cut over two connected Dungeon players atomically;
2. prove both receive source resources and source player-to-NPC dispatch;
3. prove threat remains per-player and highest-threat targeting still behaves;
4. disconnect or remove one participant and verify safe rollback/cleanup;
5. disable the coordinator and verify both surviving participants return to
   the existing model.

Production source elevation/night mapping should be designed explicitly rather
than guessed during that rehearsal.

After this multiplayer cutover gate, backend work can return to the larger
MMORPG roadmap: progression/quests/content, professions/economy, raids, guild
competition and PvP/castle systems rather than continuing to repeat the same
single-player combat acceptance.
