# Local support-threat backend candidate — 21 September 2026

Branch: `wip/phase-4-test-hud-integration-v1`

## Implemented through GitHub

The existing server-owned ThreatService now records support threat from
effective healing and effective ward absorption. CombatService wires it
to genuine MageHeal callbacks (including heal-over-time ticks), actual
ArcaneWard damage absorption, and positive Mend channel pulses.

Current provisional balancing: one threat point per two points of
actual health restored or shield damage absorbed (multiplier 0.5).
An overheal, an unabsorbed shield, and a zero-heal pulse earn no threat.
A ward cast itself creates no threat; its subsequent absorption does.

Each enemy receives support threat only when its most recent eligible
target-candidate set contains both the caster and the recipient.
Threat is still kept separately for each enemy. On enemy cleanup,
the threat table and remembered eligibility set are both discarded.
This policy is provisional; four-player and room tests are required
before it can be accepted as the final game balance.

## Test and safety status

The existing focused threat contract was extended with support
distribution, enemy isolation, invalid-value and cleanup assertions.
These tests are committed, but a fresh unpublished Studio test on the
new commit has **not yet been verified**. The prior 14-assertion
ThreatService pass and multiplayer normal/boss Taunt acceptance apply
to the earlier code only, not this support-threat candidate.

No Roblox place was published, no production player data was accessed,
and no code or documentation was edited through Remote Desktop.
Do not merge to main or enable public world-boss events as part of
this candidate.

## Next local gates

1. Run all six required Rojo compositions, focused threat contract
   and existing Base/Dungeon regressions on the current GitHub head.
2. Execute real player-to-player MageHeal, Mend and ArcaneWard support
   against an active enemy in unpublished multiplayer Studio.
3. Verify support generates threat on the relevant enemies only,
   Taunt can retake aggro, and no support contribution is fabricated.
4. Verify four-player party, multiple enemies, wipe/reset and
   disconnect removal before declaring full aggro acceptance.
