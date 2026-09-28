# Dwarf world infrastructure acceptance — v3.26
**Date:** 28 September 2026

## Scope

This acceptance validates the world infrastructure for Gearwright and
Deepclaimer quests: Base actors, transfer actors, Dungeon quest-monster
spawning, quest-ledger registration and same-owner Spoil proof.

Dwarf creation remains disabled, so this is not evidence of a normal-player
end-to-end Dwarf playthrough.

## Source checkpoint

Validated branch:
`wip/phase-4-test-hud-integration-v1`

World-spawn implementation head:
`268a3930fb67449a81ae76ce2b389d160abe7236`

Fresh builds:

- `base.project.json` — PASS
- `default.project.json` — PASS
- `git diff --check` — PASS

## Fresh Base Play

The fresh v5 Base run reached:

- `[Base Environment] Ready in Synthetic mode.`
- `[Base Runtime] Profile lifecycle and TestDungeon entry ready.`

No `DuplicateAnchor` error remained after isolating the Dwarf hub contract
fixture.

Physical Dwarf actor result:

`VERIFIED_DWARF_BASE_RUNTIME_ACTORS_V5_PASS`

Observed:

- Dwarf quest actors: **8**
- Dwarf transfer mentors: **2**
- Dwarf class trainers: **2**
- maximum quest-actor distance from Dwarf hub: approximately **19.88 studs**
- maximum mentor/trainer distance from Dwarf hub: approximately **31.72 studs**

Focused source-controlled contracts:

- Original Quest NPC Binding — **46 assertions PASS**
- First Transfer Mentor Binding — **21 assertions PASS**
- Dwarf Quest Hub Contract — **5 assertions PASS**

These include the fail-closed rule that Dwarf actors do not fall back to the
generic Base player spawn if the Dwarf hub is absent.

## Fresh Dungeon Play

The v6 Dungeon build ran the real source-pack and quest-ledger tests during
Play.

Results:

- `[C4 Source Pack] PASS: 61 assertions`
- `[C4 Quest Combat Ledger] PASS: 114 assertions`
- `VERIFIED_DWARF_WORLD_V6_BACKEND_PASS 25`

The source-pack coverage physically exercises:

- Tunnel Gnawer — Gearwright step 2
- Tunnel Gnawer Chief — Gearwright step 3
- Ashclan Forge Thief — Gearwright step 7
- Honeyback Bear — Deepclaimer step 4
- Tunnel Tarantula — Deepclaimer step 6

Each model carries the real encounter/enemy identity, enters the existing room
lifecycle, and registers against the exact quest branch/step.

For Dwarf temporary rigs, no unreviewed HP values were added. The quest pack
inherits the current room seed enemy's authoritative MaxHealth when a Dwarf
challenge lacks a dedicated reviewed template.

## Deepclaimer Spoil proof

The server ledger verifies Spoil from model state, not from a client payload.

Accepted quest proof requires:

- the exact dead physical model;
- `C4SalvageOwnerUserId` equal to the quest owner;
- source skill ID **254** or **302**;
- salvage not already claimed.

Regression coverage rejects:

- no Spoil mark;
- another player's mark;
- invented source skill ID;
- already-claimed salvage.

## Regression discovered and corrected

An auto-running Dwarf hub contract test was temporarily creating tagged
synthetic Base anchors during normal Base Play, causing the real resolver to
return `DuplicateAnchor`.

The fixture was converted to a focused ModuleScript, moved to an isolated
ServerStorage root during execution, and supplied explicit local candidates to
the resolver. Production duplicate detection remains strict.

## Remaining non-claims

This checkpoint does not claim:

- Dwarf creation is enabled;
- a normal fresh player completed Q417/Q418 end-to-end;
- unique final Dwarf quest-monster art/AI is complete;
- Spoil Festival has a reviewed studs conversion;
- production salvage casting is enabled;
- anything was published to production.
