# DungeonMMO Roadmap v2.83 — Disabled C4 Combat Dispatch

Date: 25 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v2.82](
DungeonMMO_Roadmap_v2_82_C4_Live_NPC_Execution_20260925.md).

## Goal

Place a reversible source-combat adapter at the existing shared damage
boundary without changing normal DungeonMMO gameplay.

## Dispatch architecture

`C4CombatDispatchAdapter` is a separate server-only gate between existing
trusted damage contexts and the disabled C4 live executor.

It starts OFF.

When OFF, `try_damage()` returns `Handled=false`. DamageService therefore
runs its existing formula, defence, ward, CP and callback path exactly as
before.

The adapter cannot be enabled unless a live executor is already bound and
explicitly enabled. This means the adapter cannot activate source combat by
itself.

When enabled, supported player-to-NPC contexts route as follows:

- `Melee` -> source ordinary attack;
- unranked `RangedPhysical` -> source ordinary attack;
- ranked `RangedPhysical` -> source PDAM;
- `Skill` -> source PDAM;
- `MagicSkill` -> source MDAM.

Skill ranks are resolved from authoritative progression state. Clients do not
supply source ranks, formulas, damage or outcomes.

Once source dispatch has accepted a context, a source denial does not fall
back to the old damage formula. It fails closed with zero damage. This avoids
mixing two balance systems in one hit.

## DamageService integration

DamageService now exposes an optional server-only source adapter hook.

The hook runs only after the existing attacker/target lifecycle checks and
before the old damage calculation. A handled source result is returned
directly; an unhandled result continues through the current implementation.

No source result is recalculated by DamageService.

## Bookkeeping preservation

The previous DamageService callback has been extracted into one
`record_applied_damage` observer.

The same observer is used by:

- current DamageService damage;
- the source NPC executor after real source HP damage.

Therefore an eventual source hit retains the existing:

- Dungeon contribution recording;
- source quest combat-ledger observation through
  `DungeonContributionBridge`;
- threat recording.

The observer receives actual applied HP damage and the server-observed lethal
flag.

## Runtime composition

Dungeon `RuntimeServices` binds its live source executor into the dispatch
adapter, but no gate is enabled.

Base does not bind a live Dungeon dispatch executor.

Production bootstrap still does not provide:

- a source units-per-stud conversion;
- a source-equivalent night provider;
- resource-cutover activation;
- source-calculation activation;
- live-executor activation;
- dispatch activation.

Normal gameplay therefore remains on the existing combat system.

## Fresh acceptance

Candidate:

`c424a2c46ebb6e2550c57cf4398725c39669774e`.

Fresh unpublished Rojo:

- Base: PASS;
- Dungeon: PASS;
- git diff validation: PASS.

Focused Studio:

- Base: **19/19 PASS**;
- Dungeon: **22/22 PASS**;
- combat dispatch adapter: **12 assertions PASS**;
- DamageService dispatch integration: **2 assertions PASS**;
- live source executor: **17 assertions PASS**;
- NPC source boundary: **13 assertions PASS**;
- source combat calculation: **38 assertions PASS**;
- Dungeon resource cutover: **7 assertions PASS**.

## Safety boundary

Source dispatch remains OFF by default.

Unsupported damage families fail closed only if source dispatch is explicitly
enabled; while disabled, the current gameplay path is untouched.

Bosses and other unmapped enemy archetypes remain source-unavailable and
cannot silently inherit a standard monster record.

No `main` merge, Roblox publish, production save mutation or animation edit
occurred.

## Next backend implementation

Audit every player-to-NPC DamageService source kind before any staging
activation.

The next milestone should classify each current damage family as one of:

1. source ordinary attack;
2. source PDAM;
3. source MDAM;
4. intentionally legacy/non-source status damage;
5. unsupported and therefore activation-blocking.

Do not choose a production Roblox-stud to C4-unit conversion until there is a
documented game-space rule for it.
