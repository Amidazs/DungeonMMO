# DungeonMMO Roadmap v2.80 — C4 Live Skill Execution

Date: 25 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v2.79](
DungeonMMO_Roadmap_v2_79_C4_Live_Combat_Executor_20260925.md).

## Goal

Extend the disabled v2.79 live executor across the already accepted source
PDAM, MDAM and HEAL calculation families.

## Implementation

`C4SourceCombatExecutor` now exposes four live action families:

- ordinary physical attack;
- source PDAM skill;
- source MDAM skill;
- source self-HEAL skill.

PDAM and MDAM reuse the same participant/cutover gates as ordinary attacks.
Accepted player-versus-player damage is routed through C4 CP before server
Humanoid HP.

PDAM always supplies trusted spatial context to the calculation provider, so a
shielded defender can resolve source facing without accepting a client boolean.

HEAL uses the caster-only source HEAL contract already accepted by the source
provider. The executor applies the returned amount only to the authenticated
caster and clamps at server Humanoid MaxHealth.

No client can supply formula output, damage, healing, critical state, shield
state, shot state, elemental multiplier or CP absorption.

## Fresh acceptance

Candidate:

`70a93c608e862d63c97a058624951d44363fb593`.

Fresh unpublished Rojo:

- Base: PASS;
- Dungeon: PASS;
- git diff validation: PASS.

Focused Studio:

- Base: **17/17 PASS**;
- Dungeon: **19/19 PASS**;
- live executor: **13 assertions PASS**;
- source combat: **30 assertions PASS**;
- Dungeon resource cutover: **7 assertions PASS**.

The live fixture now proves:

- ordinary hit CP -> HP;
- PDAM CP -> HP;
- MDAM CP -> HP;
- HEAL -> bounded server HP;
- server spatial context for PDAM;
- all previous independent gates and rollback remain intact.

## Safety boundary

All source/live gates remain OFF by default.

There is still no production elevation conversion or production source-night
mapping. The executor is not connected to current player input/remotes or the
existing CombatService action dispatch.

Therefore this milestone validates the live application layer without changing
normal DungeonMMO gameplay.

## Integration audit and next backend implementation

A post-acceptance entry-point audit found an important dependency before the
adapter can be wired safely:

- current Dungeon combat is PvE-first;
- `CombatTargetRules` explicitly rejects player targets;
- `MeleeHitService` and projectile services currently resolve NPC Models;
- the accepted C4 source calculation provider currently authenticates
  player-source boundaries by UserId;
- Dungeon NPCs do not yet expose equivalent source-ready C4 stat boundaries.

Therefore directly wiring the live executor into current melee/projectile
dispatch would either bypass the source provider for NPCs or mix old and new
formula families. That is not an acceptable cutover.

The next backend milestone is now:

1. create a server-owned C4 NPC source-stat boundary for Dungeon enemies;
2. map creative Dungeon enemy archetypes to reviewed source stat records while
   keeping player-facing monster names original;
3. support source normal/PDAM/MDAM calculations against NPC boundaries;
4. preserve existing quest/contribution/threat callbacks;
5. only then add the reversible dispatch adapter.

PvP/castle combat remains later work. Its target-legality rules should be
introduced with the PvP/castle system rather than weakening current PvE target
rules early.
