# DungeonMMO Roadmap v2.85 — C4 Magic-Basic Normal Routing

Date: 25 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v2.84](
DungeonMMO_Roadmap_v2_84_C4_Damage_Family_Audit_20260925.md).

## Goal

Resolve the current `MagicBasic` activation blocker without inventing a new
Chronicle 4 damage formula.

## Decision

DungeonMMO's Spirit Orb remains an original visual/delivery presentation.

Chronicle 4 does not provide a separate ordinary "magic basic attack" formula
for this current player action. The safest source-compatible damage route is
therefore the already accepted ordinary source attack calculation rather than
creating a custom magical-basic formula.

The existing `MagicBasic` DamageService family now routes through:

`SourceNormal`.

This changes only the disabled C4 dispatch path. Current gameplay remains on
the existing Spirit Orb damage values while dispatch is OFF.

## Dispatch behaviour

When source dispatch is eventually active:

- the client still supplies no damage value or formula selection;
- Spirit Orb contact remains server-observed;
- the server adapter calls the source ordinary attack executor;
- source Accuracy/Evasion, physical attack/defence, random range, critical,
  vulnerability and shot state remain server-authoritative;
- any source denial fails closed rather than falling back to legacy damage.

## Remaining activation blockers

The immutable damage-family audit now reports three blockers:

- `RangerArea`;
- `StatusMagic`;
- `StatusPhysical`.

Production dispatch therefore remains impossible to enable.

## Fresh acceptance

Candidate:

`44705dbfa92e26dc0c60fe9b54bbe5baee17ef22`.

Fresh unpublished Rojo:

- Base: PASS;
- Dungeon: PASS;
- git diff validation: PASS.

Focused Studio:

- Base: **20/20 PASS**;
- Dungeon: **23/23 PASS**;
- damage-family audit: **24 assertions PASS** with blockers=3;
- dispatch adapter: **17 assertions PASS**;
- DamageService dispatch integration: **2 assertions PASS**;
- source combat calculation: **38 assertions PASS**;
- Dungeon resource cutover: **7 assertions PASS**.

## Safety boundary

Source dispatch remains OFF and activation-blocked.

No production spatial conversion, source-night mapping, Roblox publish,
production persistence mutation, `main` merge or animation edit occurred.

## Next backend implementation

Migrate the two periodic source status families:

1. C4 Bleed / `StatusPhysical`;
2. C4 Poison / `StatusMagic`.

This must include the source DEBUFF application path as well as tick values.
The current creative skills cannot simply be treated as PDAM/MDAM because C4
skill 96 Bleed and skill 1168 Curse:Poison are DEBUFF skills, not direct
damage skills.
