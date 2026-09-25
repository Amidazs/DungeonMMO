# DungeonMMO Roadmap v2.84 — C4 Damage Family Audit

Date: 25 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v2.83](
DungeonMMO_Roadmap_v2_83_C4_Disabled_Combat_Dispatch_20260925.md).

## Goal

Audit every current DamageService source family before any staging activation
of the disabled C4 dispatch bridge.

## Reviewed current families

Player-to-NPC families that are already source-routable:

- `Melee` -> source ordinary attack;
- `RangedPhysical` -> source ordinary attack when unranked, source PDAM when
  an authoritative purchased rank exists;
- `Skill` -> source PDAM;
- `MagicSkill` -> source MDAM.

Current player-to-NPC activation blockers:

- `RangerArea` -> current Volley has no reviewed source-area mapping yet;
- `MagicBasic` -> current Spirit Orb presentation has not yet been assigned a
  reviewed C4 damage route;
- `StatusPhysical` -> periodic physical status source execution is pending;
- `StatusMagic` -> periodic magical status source execution is pending.

Outgoing NPC families remain outside this player-to-NPC cutover:

- `EnemyMelee`;
- `EnemyArea`;
- `EnemyBow`;
- `EnemyMagic`.

They continue through current combat while this player-source dispatch remains
disabled.

## Periodic damage identity fix

Rogue bleed ticks previously reused the generic `Skill` source kind, and
player poison ticks reused `MagicSkill`.

That would have made the source adapter incorrectly treat a periodic status tick
as a fresh PDAM or MDAM cast.

They now use explicit server-owned kinds:

- `StatusPhysical`;
- `StatusMagic`.

With dispatch disabled, current gameplay damage is unchanged. With dispatch
enabled in an isolated test, both families fail closed rather than being
misclassified.

## Activation gate

`C4CombatDamageFamilyReference` is the immutable audit authority.

Production `C4CombatDispatchAdapter.set_enabled(true)` now refuses activation
while any reviewed player-to-NPC blocker remains:

`C4CombatDispatchAuditBlockingFamilies`.

This is stronger than merely documenting the gaps: an accidental server call
cannot activate mixed C4/legacy player damage while the four blockers remain.

The adapter test has a private test-only readiness provider so already accepted
routes can still be exercised without weakening the production gate.

## Fresh acceptance

Candidate:

`c5bd3b249893d448fa9710a52ff83dba4e2ad1dd`.

Fresh unpublished Rojo:

- Base: PASS;
- Dungeon: PASS;
- git diff validation: PASS.

Focused Studio:

- Base: **20/20 PASS**;
- Dungeon: **23/23 PASS**;
- damage-family audit: **24 assertions PASS**;
- dispatch adapter: **17 assertions PASS**;
- DamageService source-hook integration: **2 assertions PASS**;
- source combat calculation: **38 assertions PASS**;
- Dungeon resource cutover: **7 assertions PASS**.

Audit marker:

`FAMILY_AUDIT_PASS: 24 assertions blockers=4 activation_ready=false`.

## Safety boundary

Source dispatch remains OFF and is now additionally activation-blocked by the
family audit.

No current gameplay formula was replaced. No production source spatial mapping,
publish, production persistence mutation, `main` merge or animation edit
occurred.

## Next backend implementation

Resolve the four blockers without inventing balance data.

Recommended order:

1. periodic Bleed/Poison source execution, because exact C4 effect values and
   tick semantics are already pinned;
2. explicitly decide the current Spirit Orb damage route against reviewed C4
   normal-attack semantics;
3. audit Volley against the reviewed level-30 C4 skill catalogue and either
   map a genuine equivalent or keep it unavailable in source mode.

Only when the blocker list is empty may production dispatch activation become
possible.
