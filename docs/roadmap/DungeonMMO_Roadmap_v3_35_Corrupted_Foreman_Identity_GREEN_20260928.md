# DungeonMMO Roadmap v3.35
## Corrupted Foreman bestiary identity GREEN
**Date:** 28 September 2026

This checkpoint closes the Abandoned Mine boss identity audit required by
v3.34 before any Mine-boss Adventure is authored.

## Corrected released identity

The released Mine boss remains:

- BossId: `CorruptedForeman`;
- display name: **Corrupted Foreman**;
- BestiaryCreatureId: `corrupted_foreman`.

The Temple boss remains independently:

- BossId: `MarauderCaptain`;
- BestiaryCreatureId: `marauder_captain`.

The two bosses no longer share Bestiary progress.

## Bestiary definition

`corrupted_foreman` now has its own Bestiary entry with independent
milestones:

- first kill -> `foreman_defeated`;
- third kill -> `foreman_studied`.

Captain milestones remain unchanged and Foreman progress cannot rewrite them.

## Executor/runtime fix

The boss executor now reapplies the released boss-specific Bestiary identity
after reward scaling. This is important because the Mine Foreman reuses the
shared Captain combat skeleton/factory path while needing its own quest and
Bestiary identity.

Tests also require every released boss identity used by the executor to be
explicit rather than falling back to a generic Captain identity.

## Fresh acceptance

Validated source head:

`55e69f7050fe5c4f4ee406c75d235466fb0f22a3`

Fresh checks:

- `git diff --check`: PASS;
- fresh Dungeon Rojo build: PASS;
- full unpublished Play boot: PASS;
- focused identity package:
  `VERIFIED_MINE_FOREMAN_IDENTITY_FOCUS_PASS 5`.

Focused coverage includes:

- Bestiary definitions;
- Bestiary service separation;
- Bestiary/reputation reward integration;
- Mine Foreman factory/runtime identity;
- Dungeon encounter executor boss override.

## What is GREEN

- distinct Corrupted Foreman Bestiary identity;
- distinct Marauder Captain Bestiary identity;
- independent Bestiary kill counts and milestones;
- boss-specific identity survives executor reward scaling;
- released Mine boss is safe to use as a trusted Adventure target.

## Next development gate

Add a level-paced optional **Corrupted Foreman** Adventure using the existing
trusted `EnemyDefeat` boundary.

Keep it optional so it does not block the existing story chain. Continue using
only released Depth-1 content; Depths 2-4 remain release-disabled.
