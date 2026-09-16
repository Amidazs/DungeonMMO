# Phase 2 Second Modular Dungeon + Rare-State/Event Acceptance Record

**Date:** 16 September 2026
**Status:** ACCEPTED
**Starting baseline:** `60fc0dfd9954e2d580157a580da2425e2b71dd70`
**Accepted gameplay checkpoint:** `d361348ec045873eed0fd992ceb04bfee908b06a`
**Canonical roadmap after closeout:** Roadmap v1.37

## Accepted scope

The gate proves a genuinely different second dungeon while reusing the
established server-authoritative dungeon architecture.

Accepted functional dungeon:
- Abandoned Mine;
- Entry Shaft;
- Room 1: Ore Gallery or Rooted Cavern;
- Room 2: Winch Chamber or Flooded Cut;
- Foreman's Vault;
- Corrupted Foreman functional boss presentation.

Accepted run variation:
- deterministic handcrafted module choices;
- immutable run-scoped `InstanceState`;
- `CrystalBloom` rare state;
- `DeepEchoes` time-limited event state;
- no reroll on reconnect/reconstruction;
- normal completion remains valid.

## Automated pre-Studio evidence

The implementation runner completed:
- automated RED-baseline contract proof;
- focused static second-dungeon contract verification;
- `git diff --check`;
- `base.project.json` build;
- `default.project.json` build;
- `published-base.project.json` build;
- `published-dungeon.project.json` build.

These checks were completed before the Studio gameplay gate was presented.

## Project-owner Studio evidence

The project owner reported that all requested tests worked as expected.

### Normal Abandoned Mine run

- [x] New focused test families print PASS.
- [x] Player spawns in the synthetic Abandoned Mine, not Temple.
- [x] `[Second Dungeon State]` prints two module IDs.
- [x] Room 1 has 2 enemies.
- [x] Room 2 has 3 enemies.
- [x] Boss is Corrupted Foreman.
- [x] Completion works.
- [x] Studio Return-to-Base simulation works.

### Forced Crystal Bloom + Deep Echoes run

- [x] Output reports `Rare=CrystalBloom`.
- [x] Output reports `Event=DeepEchoes`.
- [x] Purple Deep Echo markers appear in Room 1.
- [x] Cyan Crystal Bloom markers appear in Room 2.
- [x] Room 1 has 3 enemies.
- [x] Room 2 has 4 enemies.
- [x] Corrupted Foreman works.
- [x] Completion works.
- [x] No new red runtime errors are reported.

## Authority and persistence result

`DungeonSessionService.InstanceState` is run-scoped authority. It is
single-assignment and reused on reconnect/reconstruction.

The gate does not add a parallel profile-save path or schema bump. Existing
Profile, Inventory, Equipment, Professions, handoff, completion and reward
services remain authoritative.

## Safety result

- No Roblox place was published.
- No PROD path was enabled.
- No Robux was spent.
- No monetisation setting was changed.
- Live paid revives remain disabled.
- The separate art worktree was not touched.
- Final authored Abandoned Mine art remains later environment work.

## Deferred items

- final authored Mine environment;
- final rare/event balance;
- broader event cadence/reward tuning;
- wider Temple resource presentation polish;
- live legacy migration proof before any real-player migration-sensitive
  release.

## Next selected gate

Real party formation + 1-4-player group entry, reusing the existing
DungeonSessionService/TeleportCoordinator/reconnect/completion architecture.
