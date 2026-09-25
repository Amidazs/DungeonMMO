# DungeonMMO Roadmap v2.87 — C4 Live Periodic Status

Date: 25 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v2.86](
DungeonMMO_Roadmap_v2_86_C4_Periodic_Status_Source_20260925.md).

## Goal

Take the exact source periodic-status calculation accepted in v2.86 and wire
it into the disabled live source executor without allowing the older creative
damage-over-time values to run alongside it.

## Source behaviour retained

The reviewed C4 source plans remain:

- Wayfinder Wound -> source skill 96 Bleed rank 1:
  - DEBUFF;
  - save versus CON;
  - effect power 100;
  - 13 damage;
  - four ticks;
  - five seconds per tick;
  - nonlethal periodic damage.
- Mystic Poison Curse -> source skill 1168 Curse: Poison rank 1:
  - DEBUFF;
  - magical;
  - save versus MEN;
  - effect power 70;
  - 8 damage;
  - ten ticks;
  - three seconds per tick;
  - nonlethal periodic damage.

The source effect-success roll remains private server state. Magical DEBUFF
casts use the existing private Spiritshot/Blessed Spiritshot authority.

## Implementation

`C4SourceCombatExecutor` now owns source periodic status scheduling for NPC
targets.

A successful source DEBUFF cast:

1. creates no fake direct damage;
2. records a generation keyed by target + reviewed source skill;
3. schedules the exact reviewed tick interval;
4. revalidates the source executor/player/NPC boundary at every delayed tick;
5. caps each tick so periodic damage cannot reduce the NPC below one HP;
6. emits the same trusted NPC damage observer used by direct C4 damage;
7. preserves source skill, creative skill and original cast sequence evidence.

Reapplying the same reviewed source skill replaces the prior generation, so
stale delayed callbacks cannot stack or continue damaging the refreshed target.

A resisted DEBUFF schedules nothing.

## Dispatch integration

The combat dispatch adapter now intercepts the original creative delivery
families before generic damage routing:

- `Skill + WayfinderWound` -> source DEBUFF;
- `MagicSkill + MysticPoisonCurse` -> source DEBUFF.

This matters because the existing creative definitions contain temporary
direct-damage and periodic values. Source mode returns zero direct damage from
the cast, so the legacy post-hit `RogueBleedService` and
`PoisonStatusService` application gates never start.

Any already-scheduled legacy `StatusPhysical` or `StatusMagic` tick that
reaches `DamageService` after source cutover is handled and suppressed rather
than falling back to the old formula.

`DamageService` reports a successful zero-damage source DEBUFF as STATUS
APPLIED instead of a rejected damage event.

The shared combat callback now awards progression damage for C4 periodic ticks
while preserving the existing contribution, quest and threat observer path.

## Activation blockers

Periodic status is no longer a source-dispatch blocker.

The remaining player-to-NPC activation blocker is now:

- `RangerArea`.

Production dispatch therefore remains OFF.

## Fresh acceptance

Candidate:

`9a6855ac431e14bc75219f48520316e326b4eb7d`.

Fresh unpublished Rojo:

- Base: PASS;
- Dungeon: PASS;
- git diff validation: PASS.

Focused Studio:

- Base: **21/21 PASS**;
- Dungeon: **24/24 PASS**;
- source periodic reference: **14 assertions PASS**;
- source combat calculation: **40 assertions PASS**;
- live executor: **22 assertions PASS**;
- damage-family audit: **25 assertions PASS**, blockers=1;
- dispatch adapter: **19 assertions PASS**;
- Dungeon damage dispatch integration: **2 assertions PASS**;
- Dungeon resource cutover: **7 assertions PASS**.

## Safety boundary

The live source executor, source calculation provider, resource cutover and
dispatch adapter all remain OFF by default.

No main merge, Roblox publish, production persistence or animation project
mutation is part of this milestone.

## Next backend implementation

Resolve the final `RangerArea` player-to-NPC activation blocker by mapping
the current Ranger area delivery to a reviewed C4 source skill/damage contract.

Do not guess an equivalent. Review the pinned C4 catalogue first, preserve
original DungeonMMO player-facing naming, and keep multi-target scheduling
server-owned.
