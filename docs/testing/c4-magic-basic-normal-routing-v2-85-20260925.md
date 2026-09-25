# C4 Magic-Basic Normal Routing v2.85 — Acceptance

Date: 25 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.

## Result

**GREEN — MagicBasic now uses the accepted source normal-attack route.**

## Candidate

`44705dbfa92e26dc0c60fe9b54bbe5baee17ef22`.

## Evidence

- Base Rojo: PASS;
- Dungeon Rojo: PASS;
- git diff validation: PASS;
- Base focused Studio: **20/20 PASS**;
- Dungeon focused Studio: **23/23 PASS**;
- damage-family audit: **24 assertions PASS**;
- dispatch adapter: **17 assertions PASS**;
- DamageService dispatch integration: **2 assertions PASS**;
- resource cutover: **7 assertions PASS**.

Family marker:

`FAMILY_AUDIT_PASS: 24 assertions blockers=3 activation_ready=false`.

## Accepted contract

`MagicBasic` is no longer a source activation blocker.

The original Spirit Orb delivery/presentation remains intact, but source-mode
damage is calculated as an ordinary C4 attack instead of inventing a separate
magic-basic balance formula.

Production source dispatch remains blocked by RangerArea, StatusPhysical and
StatusMagic.

## Safety boundary

No source gate is active in normal bootstrap. Current DungeonMMO Spirit Orb
gameplay is unchanged while the dispatch adapter is OFF.
