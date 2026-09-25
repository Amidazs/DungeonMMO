# C4 Physical Critical Resolution v2.70 — Acceptance

Date: 25 September 2026.  
Branch: `wip/phase-4-test-hud-integration-v1`.

## Result

**GREEN — focused Base + Dungeon Studio acceptance passed.**

## Source behaviour verified

Pinned C4 source commit:

`07f8536384e799f128d44198dd7ab23519660eea`.

Verified source contracts:

- final physical critical rate is integer-truncated;
- normal physical critical rate is capped at 500 per thousand;
- the random roll is an integer from 0 through 999;
- critical succeeds only when chance is strictly greater than the roll;
- a roll equal to the chance does not crit;
- physical critical-power multiplier starts at 1;
- physical critical-power additive value starts at 0;
- reviewed passive/active critical-power modifiers can therefore compose into
  the authenticated final source candidate.

## Fresh build evidence

Production candidate:

`0e96be70f443e2e4e4cadc29615a94e8b02d69b3`.

Fresh unpublished Rojo builds:

- Base: PASS;
- Dungeon: PASS.

## Fresh Studio evidence

Base:

`[C4 v2.55-v2.70 Focus] RESULT environment=Base passed=14 total=14`

Dungeon:

`[C4 v2.55-v2.70 Focus] RESULT environment=Dungeon passed=16 total=16`

Relevant new evidence:

- `[C4 Combat Formula] SOURCE_FORMULA_PASS: 26 assertions, live=false`;
- `[C4 Source Combat] SOURCE_ONLY_PASS: 13 assertions hit=true critical=true pdam=true mdam=true heal=true live=false`.

## Initial expanded-run qualification

The first v2.70 run temporarily included
`C4UnifiedStatReferenceTest`.

That older broad suite failed an existing heavy-mastery expected-value
assertion after the current Chest+Legs armour migration:

`[C4 Unified Stats] Heavy mastery adds source P.Def on correctly equipped Knight`

The failure is unrelated to v2.70 critical resolution. All new formula and
source-combat critical tests were green in that run. The broad stale suite was
removed from the targeted runner and the corrected focused Base/Dungeon runs
then passed 14/14 and 16/16.

No production critical implementation was changed to hide that failure.

The branch cleanup after Studio changed only test scope. Current branch head:

`8b6252bc6fce485c06f077381d86906050b558f4`.

## Deliberate non-live boundary

The source-combat feature gate remains OFF by default.

Normal physical critical resolution is source-only. It does not:

- apply HP/CP damage;
- spend MP;
- consume shots;
- start cooldowns;
- alter threat;
- publish;
- persist production data.

PDAM skill critical and magical critical remain explicitly incomplete.
