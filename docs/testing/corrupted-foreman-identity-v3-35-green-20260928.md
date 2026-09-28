# Corrupted Foreman identity acceptance evidence — v3.35
**Date:** 28 September 2026

## Source checkpoint

Branch:
`wip/phase-4-test-hud-integration-v1`

Validated head:
`55e69f7050fe5c4f4ee406c75d235466fb0f22a3`

## Problem closed

The Abandoned Mine boss uses the distinct runtime BossId
`CorruptedForeman`, but older shared reward metadata could cause it to reuse
the Temple Captain's Bestiary identity.

That is now corrected.

Accepted Mine identity:

- BossId: `CorruptedForeman`;
- BestiaryCreatureId: `corrupted_foreman`;
- display: Corrupted Foreman.

Accepted Temple identity remains:

- BossId: `MarauderCaptain`;
- BestiaryCreatureId: `marauder_captain`.

## Bestiary separation

`BestiaryServiceTest` proves:

- Captain first/third milestones remain captain-specific;
- Foreman first/third milestones are foreman-specific;
- Foreman kills do not modify historical Captain kills.

## Runtime/executor coverage

The executor applies the released boss-specific Bestiary identity after reward
scaling. The Mine boss path therefore cannot regress to the generic Captain
identity merely because it reuses shared boss construction/scaling code.

## Fresh Studio validation

Fresh Dungeon build:
PASS.

Focused marker:

`VERIFIED_MINE_FOREMAN_IDENTITY_FOCUS_PASS 5`

Focused suites:

- BestiaryDefinitionsTest;
- BestiaryServiceTest;
- BestiaryReputationRewardIntegrationTest;
- MineForemanBestiaryIdentityTest;
- DungeonEncounterExecutorsTest.

The normal full Play boot also completed without a new runtime failure.

## Non-claims

This checkpoint does not itself add the Mine Foreman Adventure, final Foreman
art/animation, production publish or a main-branch merge.
