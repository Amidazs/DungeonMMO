# C4 Owned Passive Source Resolution v2.60 — Acceptance

Date: 25 September 2026.  
Branch: `wip/phase-4-test-hud-integration-v1`.

## Build evidence

Commit tested:
`e6925d66433dae698ef3085a49c38bd304e70466`.

Both disposable compositions rebuilt with Rojo:

- Base: PASS;
- Dungeon: PASS.

## Focused Studio results

Base retry: **7/7 PASS**.

Dungeon: **8/8 PASS**.

The Dungeon suite includes ManaService; Base intentionally does not because
the Base composition does not contain the full Combat/Tests tree.

Assertions:

- runtime source rules — 13;
- split-MP ManaService — 13;
- authenticated nine-class skill source — 554;
- resource migration boundary — 43;
- all-current-equipment source map — 61;
- launch core source gear — 8;
- six-slot paperdoll/Expertise — 11;
- actually-owned passive source resolution — 7.

## Ownership guarantees

The new resolver demonstrates that:

- source passive ranks come from real purchased creative ranks;
- character level alone grants nothing;
- first-transfer classes retain actually owned inherited starter passives;
- one highest source rank is used per passive family;
- unmapped custom passives remain explicit blockers;
- impossible saved ranks above reviewed source coverage remain blockers.

No current authored passive percentage is layered onto the C4 source candidate
when it lacks a reviewed source mapping.

## Local runner note

An initial automated Base Studio process stalled during Studio startup and did
not create its RunScript output. A clean Base-only retry later completed all
7 tests successfully. The Dungeon run had already completed 8/8.

Evidence directory:

`%TEMP%\DungeonMMO_v260_owned_passives`

No Roblox publication or production DataStore operation occurred.
