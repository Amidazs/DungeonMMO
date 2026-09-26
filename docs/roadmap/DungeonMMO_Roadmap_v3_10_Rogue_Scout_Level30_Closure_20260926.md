# DungeonMMO Roadmap v3.10 — Rogue / Scout Level-30 Closure

Date: 26 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.

## Status

**GREEN — Human Rogue and Elven Scout source-rank gaps closed.**

Accepted backend HEAD:
`7b7ed726d0a1c694390beec1acd70c063ddcbbc7`.

## Closure

Human Rogue / Ashenblade now maps the previously unresolved source Vital Force
family through `AshenbladeVitalForce`.

Elven Scout / Greenward Scout now maps the previously unresolved source
Elemental Heal family through `GreenwardScoutElementalHeal`.

The Scout heal uses the shared source self-magic cast bridge while preserving
the original C4 self-target restriction and exact rank-by-rank heal plan.
Human Rogue Vital Force is represented as its own source family rather than
borrowing an unrelated recovery effect.

Both first-transfer rank schedules now have zero level-30 mapping gaps:

- Human Rogue: 59 / 59 source rank rows mapped;
- Elven Scout: 77 / 77 source rank rows mapped.

## Validation

Fresh validation against a newly built unpublished Dungeon place:

- `git diff --check`: PASS;
- Base Rojo build: PASS;
- Dungeon Rojo build: PASS;
- focused Edit-mode closure set: **8 / 8 PASS**;
- Play-mode critical subset: **3 / 3 PASS**;
- `C4RogueScoutLevel30ClosureTest`: PASS;
- `C4SourceSelfMagicCastServiceTest`: PASS;
- `C4NineClassAuthenticatedSkillPreviewTest`: PASS;
- `C4CreativeSkillLinkAuditTest`: PASS;
- `C4Level30LaunchCoverageTest`: PASS;
- owned-passive/resource/cast-composition regressions: PASS.

The first stale disposable Studio place still contained pre-closure test source.
A fresh uniquely named build was inspected before execution and carried the
correct 569/557/12 ten-path preview expectation and 645/12 eleven-path creative
audit expectation.

## Scope

This closes the remaining source-rank schedule gaps for the already implemented
Human Rogue and Elven Scout first-transfer branches. It does not claim all 18
C4 first-transfer careers are complete.

Next backend target: independently source-audit and implement the Elven Wizard
level-30 first-transfer tree, then continue through Elven Oracle and the
remaining Dark Elf, Orc and Dwarf first-transfer branches.

No `main` merge, Roblox publish, production DataStore mutation or animation
work.
