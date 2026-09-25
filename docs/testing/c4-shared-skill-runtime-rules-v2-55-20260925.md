# C4 Shared Skill Runtime Rules v2.55 — Test Status

Date: 25 September 2026.  
Branch: `wip/phase-4-test-hud-integration-v1`.

## Scope

This milestone adds source-backed Chronicle 4 split-MP and instant-heal
semantics without activating the Scout's planned Elemental Heal or switching
live HP/MP/CP.

Pinned source commit:
`07f8536384e799f128d44198dd7ab23519660eea`.

## Authored deterministic coverage

`C4SkillRuntimeRulesTest.server.luau` checks the reviewed C4 source behavior:

- Elemental Heal rank 4 costs 11 initial MP + 42 launch MP = 53 total;
- 52 MP cannot begin the cast;
- 53 MP can begin and initially falls to 42;
- launch spends the remaining 42;
- source launch reduction clamps at zero;
- power 95 heals 95 uncharged, 123.5 with Spiritshot and 142.5 with
  Blessed Spiritshot;
- a 5000 ms authored magic cast at 333 M.Atk.Spd remains 5000 ms;
- either charged shot reduces that cast to 3500 ms;
- a source-authored 500 ms cast cannot fall below the 500 ms minimum.

`ManaServiceTest.server.luau` additionally checks the live-capable transaction
API without wiring it to an active skill:

- combined affordability is atomic;
- cast start spends only the initial portion;
- launch spends only the completion portion;
- an interrupted-cast fixture can retain the initial charge.

`C4NineClassAuthenticatedSkillPreviewTest.server.luau` now verifies every
planned Scout source heal rank exposes the exact source heal outputs and
split-MP certification while remaining source-only and non-castable.

## Not yet executed

No Rojo build, Studio test runner or client Play execution is claimed for
v2.55. These checks were authored through GitHub only. Earlier v2.53
500-assertion evidence does not validate these newer files.

## Deliberate non-claims

This test scope does not certify:

- live C4 MaxHP/MaxMP/CP;
- current ManaService pool size or regeneration as C4-equivalent;
- Spiritshot inventory, charge/discharge or item consumption;
- complete Heal threat/hate behavior;
- full source HP/MP regeneration;
- a live Scout trainer entry or cast executor;
- full C4 mechanical parity for any class.

Those remain coordinated all-class migration work.
