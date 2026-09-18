# Phase 4 Progressive Dungeon Depth + Difficulty - Design

**Date:** 18 September 2026
**Phase:** Phase 4 - Content Alpha, backend-only gate
**Status:** Implemented / local green; awaiting project-owner closeout
**Baseline:** `a3c2625cfc53dbb1c2bb8d6ce17f5f3749809fa9`
**Implementation checkpoint:** `1230e6c`

## 1. Purpose

Add an Iron-Soul-style dungeon difficulty model where a higher difficulty is a
**deeper run**, not merely the same rooms with larger numbers.

The system must support:

- more rooms/encounters at each successive depth;
- stronger enemies as depth increases;
- different reward bands by depth;
- a new boss at each ordinary depth;
- the final depth reusing the previous depth bosses as minibosses;
- one new true final boss at the end of the final depth;
- existing rotating dungeon modifiers as an independent axis.

This gate is backend only. It does not create meshes, rooms, terrain, VFX,
animations, UI art or authored environment content.

## 2. Locked terminology

Player-facing language may later change, but backend IDs are stable.

Prototype difficulty IDs:

- `Depth1`
- `Depth2`
- `Depth3`
- `Depth4`

`Depth1` is the current easiest/currently playable dungeon structure.

A difficulty definition owns:

- `Id`;
- `Order`;
- `DisplayName`;
- `RuntimeReady`;
- `RequiredPreviousDifficultyId`;
- `EncounterSequence`;
- enemy health/damage tuning;
- monster reward tuning;
- completion reward tuning.

An encounter descriptor owns:

- stable logical `Id`;
- logical `RoomSlotId`;
- `Kind`: `Combat`, `MiniBoss`, `Boss` or `FinalBoss`;
- optional `PackId`;
- optional `BossId`;
- optional context tuning.

Physical room geometry is not part of the difficulty definition.

## 3. Progressive depth shape

The initial backend ladder for every accepted dungeon proves this shape:

| Difficulty | Logical encounters | Final encounter |
| --- | ---: | --- |
| Depth1 | 3 | Boss 1 |
| Depth2 | 4 | Boss 2 |
| Depth3 | 5 | Boss 3 |
| Depth4 | 6 | New final Boss 4 |

The exact encounter pacing remains dungeon-authored. A dungeon does not have to
alternate combat/miniboss rooms mechanically.

For the prototype final-depth contract, the six encounters are:

1. ordinary combat;
2. Boss 1 reused as a miniboss;
3. ordinary combat;
4. Boss 2 reused as a miniboss;
5. Boss 3 reused as a miniboss;
6. new Boss 4 as the true final boss.

This is the architectural proof of the user's requested rule:

> bosses from previous difficulties return as minibosses in the final
> difficulty of that dungeon.

## 4. Boss reuse contract

Do not create duplicate boss classes such as
`MarauderCaptainHard`, `MarauderCaptainMini` or
`MarauderCaptainDepth4`.

A boss keeps one stable `BossId` and one implementation/factory.

The encounter context determines its role:

- `Boss`;
- `MiniBoss`;
- `FinalBoss`.

A miniboss context may apply data-driven tuning such as:

- reduced health relative to its original final-boss form;
- reduced reward multiplier;
- fewer phases/mechanics later when bosses become more complex.

This gate only establishes the context/tuning contract. It does not invent
future boss mechanics.

Future-depth boss IDs may use neutral stable internal IDs until final lore/display
names are authored.

## 5. Difficulty and modifier composition

Dungeon difficulty and the Phase 3 modifier system are separate.

A run identity is conceptually:

`DungeonId + DifficultyId + ModifierId + SessionId`

Examples:

- Temple / Depth1 / Fortified;
- Temple / Depth3 / RichDeposits;
- Mine / Depth4 / Bounty.

Rules:

- difficulty never replaces or rerolls the modifier;
- modifier selection remains deterministic/server-owned;
- reconnect reads the stored difficulty and stored modifier;
- Fortified health multiplies with difficulty health tuning;
- Bounty Gold multiplies after the depth's monster-reward tuning;
- Rich Deposits remains gathering-only;
- no client supplies authoritative tuning values.

## 6. Prototype scaling

Prototype values are data, not final balance.

The first backend pass uses monotonic values similar to:

| Depth | Enemy HP | Enemy damage | Monster reward | Completion Gold |
| --- | ---: | ---: | ---: | ---: |
| 1 | 1.00x | 1.00x | 1.00x | 1.00x |
| 2 | 1.25x | 1.10x | 1.15x | 1.20x |
| 3 | 1.55x | 1.20x | 1.30x | 1.45x |
| 4 | 1.90x | 1.35x | 1.50x | 1.75x |

Scaling must be resolved once from server-owned definitions.

Ordinary monster HP:

`base health * difficulty health * modifier health`

Outgoing enemy damage:

`base damage * difficulty damage`

Monster XP/Gold base values may be scaled by difficulty before Bounty applies.

Completion Gold is scaled by difficulty. Difficulty-specific loot tables are
supported by the data contract but do not require new loot content in this gate.

## 7. Persistent unlock progression

The existing legacy `DungeonProgress` field is preserved untouched.

Add a new profile field:

`DungeonDifficultyProgress`

Prototype shape:

```luau
DungeonDifficultyProgress = {
    Version = 1,
    Dungeons = {
        TestDungeon = {
            Completed = {
                Depth1 = true,
            },
            HighestClearedOrder = 1,
        },
    },
}
```

Rules:

- schema increments from v12 to v13;
- migration preserves legacy `DungeonProgress` exactly;
- new depth state is sanitized independently;
- Depth1 is unlocked by default;
- DepthN unlocks after successful completion of DepthN-1;
- clear recording is naturally idempotent: completion membership is a boolean;
- a failed/abandoned run never unlocks the next depth;
- only completion-eligible recipients receive the clear;
- no catch-up or retroactive invented depth clears.

## 8. Entry authority

Difficulty selection is server-owned Base state.

Solo:

- legacy string-only dungeon requests continue to mean `Depth1`;
- the server may also accept a structured request containing
  `DungeonId` and `DifficultyId`;
- the server validates the selected player's unlock.

Party:

- party state adds `SelectedDifficultyId`;
- selecting another dungeon resets difficulty to that dungeon's default;
- selecting a different difficulty clears party readiness;
- only the leader may change dungeon/difficulty;
- every member must have the selected difficulty unlocked;
- one locked member blocks the entire party entry;
- Studio party proof preserves the selected difficulty.

No client can bypass unlocks by sending a higher difficulty ID directly.

## 9. Runtime-ready fail-closed rule

Backend definitions for Depth2-Depth4 are created now.

However, no player may enter a depth whose required physical/runtime content is
not implemented.

Each depth has `RuntimeReady`.

Initial state:

- Depth1: `RuntimeReady = true`;
- Depth2: `false`;
- Depth3: `false`;
- Depth4: `false`.

Unlock state and runtime readiness are different concepts.

A player can have Depth2 logically unlocked after clearing Depth1 while entry
still returns `DifficultyContentNotReady`.

Later content work flips `RuntimeReady` only after the necessary room anchors,
boss factories and encounter runtime exist and pass acceptance.

## 10. Session and teleport persistence

`DungeonSessionService` persists the selected difficulty once.

Session state includes:

```luau
Difficulty = {
    Id = "Depth1",
    Order = 1,
    Version = 1,
}
```

Rules:

- omitted difficulty safely defaults to Depth1 for backward compatibility;
- unknown difficulty is rejected;
- reconnect cannot reroll/change difficulty;
- member reconnect index retains enough routing metadata;
- TeleportData carries only routing IDs:
  `SessionId`, `DungeonId`, `DifficultyId`;
- no reward values/scaling values are sent as authority in TeleportData.

## 11. Immutable instance/run plan

`DungeonInstanceDirector` adds the difficulty to immutable instance state.

The state records:

- `DifficultyId`;
- `DifficultyOrder`;
- frozen/logically copied encounter sequence;
- existing module/rare/event state.

This makes a run reconstructable from authoritative session state.

The current Depth1 Temple/Mine runtime remains backward compatible.

Depth2-Depth4 logical plans are testable before physical rooms exist.

## 12. Enemy scaling hooks

Ordinary Marauders and bosses receive a server-owned
`DungeonDamageMultiplier` attribute.

Combat controllers use:

`base attack damage * DungeonDamageMultiplier`

Default/missing attribute is exactly `1` so training enemies and accepted
Depth1 behaviour do not change.

Boss factories also accept health/damage/role context instead of hardcoding
difficulty variants into separate boss implementations.

## 13. Reward composition

Difficulty reward tuning is resolved in the Dungeon runtime before dispatch.

Monster rewards:

1. start from dungeon/base monster reward;
2. apply depth monster-reward multiplier;
3. pass the result to RewardService;
4. RewardService still applies Bounty if present.

Completion rewards:

1. choose ordinary/rare/event completion definition as today;
2. apply depth completion-Gold multiplier;
3. use a difficulty-specific loot table only when explicitly configured.

Existing transaction IDs and replay/idempotency remain unchanged.

## 14. Completion integration

After a session is already authoritative `Complete` and the personal completion
reward applies successfully, completion records the
`DungeonId + DifficultyId` clear for that player before the existing save
barrier completes.

Retry behaviour must be safe:

- reward replay stays exactly-once;
- difficulty completion replay stays idempotent;
- save failure retries do not increment/mint anything.

Existing quest and guild completion bridges remain backward compatible.

## 15. Backward compatibility

Depth1 must preserve current gameplay.

Existing callers that do not supply a difficulty:

- create Depth1 sessions;
- teleport to Depth1;
- receive current Depth1 tuning;
- retain existing modifier behaviour;
- receive current completion/monster rewards.

No new modelling/art is required for Depth1 acceptance.

## 16. Non-goals

This backend gate does not include:

- modelling or meshes;
- additional physical rooms;
- new boss models/animations/VFX/audio;
- final difficulty names;
- final balance;
- final loot catalogue;
- matchmaking;
- raid/world-boss/siege work;
- Transmog;
- catch-up;
- procedural dungeon geometry;
- new player-facing difficulty UI beyond preserving backend-compatible payloads.

## 17. Testing and acceptance

Required RED -> GREEN coverage:

1. difficulty definition shape/order/room counts;
2. final-depth previous-boss-as-miniboss contract;
3. schema v13 migration and legacy DungeonProgress preservation;
4. unlock progression/idempotency;
5. party difficulty selection/readiness invalidation;
6. all-party-member unlock validation;
7. session difficulty persistence/reconnect;
8. TeleportData difficulty routing;
9. immutable instance plan carries difficulty;
10. health/damage scaling defaults and composition;
11. reward scaling + Bounty composition;
12. completion records depth clear exactly once;
13. existing Depth1 modifier/session/completion regressions;
14. all four Rojo builds.

No manual modelling/visual test is part of this gate.

A Studio runtime gate is required only if the source changes alter live Depth1
behaviour beyond the intended default-1.0 hooks.

## 18. Exit definition

This backend gate is complete when:

- both accepted dungeons expose ordered Depth1-Depth4 definitions;
- Depth1/2/3/4 have 3/4/5/6 logical encounters respectively;
- each successive depth has monotonic server-owned scaling;
- final depth references prior bosses as minibosses and a new final boss;
- persistent unlock progression is schema-safe;
- solo/party/session/teleport contracts carry and validate difficulty;
- modifiers compose independently;
- higher unbuilt depths fail closed;
- existing Depth1 behaviour/regressions remain green;
- the four Rojo project compositions build cleanly;
- no art/modelling work was performed.
