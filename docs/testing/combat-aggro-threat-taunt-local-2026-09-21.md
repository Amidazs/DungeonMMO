# Local combat aggro, threat, and Fighter Taunt acceptance

**Date:** 21 September 2026  
**Branch:** `wip/phase-4-test-hud-integration-v1`  
**Accepted runtime source:** `9c744d0cfe4ecabd5b372229e446ceadc6653861`  
**Latest test-only head:** `e041bf2203c8b73b0c1c9b59aebc175a2c8cbddd`

No Roblox place was published. All source/test/document edits were made
through GitHub; Remote Desktop was used for clean pulls, local Rojo
builds, unpublished Studio tests, and diagnostics.

## Aggro policy now implemented

Each hostile NPC owns an independent server-authoritative threat
ledger.

1. If no **eligible** player has positive threat against that enemy,
   it targets the closest eligible player.
2. As soon as eligible positive threat exists, it targets the player
   with the highest threat. Distance only breaks equal-threat ties.
3. Real server-applied health damage adds threat to the exact enemy
   that received that damage.
4. A Taunt-style skill may add threat without doing health damage.
   The current Taunt moves the user above the enemy's existing threat
   leader by its configured server-owned bonus.
5. Dead, absent, encounter-ineligible, respawn-suppressed, and
   ThreatDrop-suppressed players are removed from target candidates.
6. Enemy death/reset clears that enemy's threat table. Threat on one
   enemy never changes another enemy's ledger.

The same `ThreatService` is used by ordinary Training/Dungeon
Marauders and the Captain controller reused by the world boss.

## Fighter Taunt

A real zero-damage Fighter `Taunt` now exists in the authoritative
skill definitions. It has a server-owned cooldown/cost/range and
`TAUNT_BONUS_THREAT`, deals zero health damage, and uses normal
server melee target validation before creating threat.

Taunt is a Fighter teachable skill and is offered by the Fighter
Trainer. Its threat bonus is rankable. Invalid/non-finite Taunt
threat configuration is rejected by skill-definition validation.

## Local acceptance

At runtime source `9c744d0cfe4ecabd5b372229e446ceadc6653861`:

- all six Rojo compositions built successfully;
- ThreatService focused contract: **14 assertions PASS**;
- real two-client normal-enemy aggro:
  `VERIFIED_MULTIPLAYER_PASS`;
- real two-client world-boss aggro:
  `VERIFIED_MULTIPLAYER_PASS`;
- Fighter Trainer catalogue: **12 assertions PASS**;
- profile-exit/save/lease recovery: **18 assertions PASS**;
- weekly reward retry: **17 assertions PASS** in Base and
  **17 assertions PASS** in Dungeon;
- existing Base professions: **14/14 PASS**;
- existing Dungeon gameplay backend: **30/30 PASS**.

The normal-enemy real multiplayer run proved:

- nearest-player targeting before threat;
- first real damage switches aggro to the damage dealer;
- higher accumulated real damage takes aggro;
- real client `Taunt` is accepted by CombatService, hits the
  authoritative enemy, generates threat, and causes no fake damage;
- Rogue ThreatDrop temporarily removes the current threat leader
  from target eligibility;
- when ThreatDrop expires, the highest-threat player is reacquired.

The world-boss real multiplayer run proved the same nearest → damage
threat → higher-threat switch → real zero-damage Taunt sequence
against the isolated guardian. The test uses the prototype arena so
characters cannot fall out of the encounter while the guardian moves.

The accepted combat regression also retained:

- first-and-only lethal boss hit contribution and weekly reward once;
- existing two-client shared guardian combat/rewards;
- **11** world-boss damage-target/lethal-filter assertions.

At test-only head `e041bf2203c8b73b0c1c9b59aebc175a2c8cbddd`,
both normal-enemy and world-boss two-client fixtures were rerun after
adding a real client death check. Each printed
`DEAD_TARGET_FALLBACK_PASS` and
`VERIFIED_MULTIPLAYER_PASS`, proving a dead highest-threat player
immediately falls out of the eligible target set.

## Boundaries and next local work

This is local combat acceptance, not published network acceptance.
Published TEST travel, same-account cross-server reconnect, and cloud
DataStore/MemoryStore remain intentionally deferred.

Useful remaining local combat/backend work includes:

- genuine healing/ward skill execution and an explicit support-threat
  policy;
- four-player tank/DPS/support aggro interactions;
- full-party wipe/reset and enemy threat cleanup across room resets;
- multiple enemies with separate threat tables in the same dungeon
  room;
- disconnect/reconnect candidate removal at the controller level;
- later tank-specific threat modifiers and additional threat skills.

