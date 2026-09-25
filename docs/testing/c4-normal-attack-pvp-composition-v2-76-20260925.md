# C4 Normal Attack and PvP Composition v2.76 — Acceptance

Date: 25 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.

## Result

**GREEN — fresh Base and Dungeon focused Studio acceptance passed.**

## Candidate

`2b8e74d7dd930969ccb881eae242882cca79587f`.

## Fresh local verification

- Base Rojo: PASS;
- Dungeon Rojo: PASS;
- git diff validation: PASS.

## Fresh Studio evidence

Base:

`[C4 v2.55-v2.76 Focus] RESULT environment=Base passed=15 total=15`

Dungeon:

`[C4 v2.55-v2.76 Focus] RESULT environment=Dungeon passed=17 total=17`

Relevant outputs:

- `[C4 Combat Formula] SOURCE_FORMULA_PASS: 49 assertions, live=false`;
- `[C4 Source Combat] SOURCE_ONLY_PASS: 30 assertions hit=true critical=true variance=true shield=true normal=true vuln=true pvp=true magiccrit=true magicfailure=true element=true shots=true pdam=true mdam=true heal=true live=false`;
- Dungeon `C4ResourceCutoverServiceTest`: PASS.

No focused failure was reported in the final Base or Dungeon run.

## Source behaviour verified

The successful composed normal-attack path includes:

- hit;
- shield;
- critical;
- critical power;
- weapon/unarmed random variance;
- source target weapon vulnerability;
- player PvP multiplier;
- one-use Soulshot;
- final physical formula output.

The regression uses the reviewed Deflect Arrow rank-one 0.84 Bow
vulnerability against a valid Oathguard source target.

Misses preserve a charged Soulshot. The successful hit consumes it once.

PDAM and MDAM also consume their reviewed player PvP stat families.

## Corrected test-fixture issue

The first v2.76 Base attempt failed because source Deflect Arrow was attached
to a starter Fighter test fixture. The migration boundary correctly rejected
that impossible active rank with incomplete source prerequisites.

The test was fixed by creating a legitimate Oathguard advancement fixture,
preserving the production fail-closed rule.

## Non-live boundary

The provider remains OFF by default. No live HP/CP application, publish,
production persistence, `main` merge or animation work occurred.
