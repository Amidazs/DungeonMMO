# Greenward Warden real client bleed/cure acceptance — v2.35

Date: 24 September 2026.
GitHub candidate: `0fd05cbe7961fb2d4d1efd0daec200c41b492c9c`.
Unpublished disposable Dungeon Rojo build and Studio Play; not a
published place or persistent production profile.
Studio log: `%TEMP%\\DungeonMMO_v240_bleed_play\\bleed.log`.

## Precisely executed path

`scripts/studio/c4_greenward_warden_player_bleed_live.luau`
spawns a real client/avatar, sets a coherent Warden source quest
receipt and paid level-24 Bleed Recovery in **test-only server state**,
and uses a real registered Captain model scoped to the owner's
encounter. The driver makes a trusted hostile `DamageService`
CaptainSlash hit and explicitly invokes the server-only
`PlayerBleedStatusService.apply_from_captain` after positive HP
damage. This bypasses natural boss AI attack timing, *not* the
server's hit/status, owner, encounter, or curative authorities.

Observed in the final Studio log:
- `DAMAGE APPLIED CaptainSlash 15.0HP` on the real avatar.
- `DAMAGE APPLIED CaptainSlashBleed 3.0HP` before cure.
- `SKILL ACCEPT GreenwardWardenBleedRecovery` from real
  client hotbar input; one extra scheduled bleed tick occurred
  **before** the cure, not after it.
- `MAGE_CURE APPLIED GreenwardWardenBleedRecovery`.
- `REAL_CLIENT_CURE_NO_LATE_TICK_PASS`,
  `ALL_REAL_CLIENT_STATUS_CHECKS_PASS` and
  `VERIFIED_PLAY_MODE_PASS`.

The test asserts the copied presentation attribute alone cannot
be cured, actual owner mana decreases, `MageHealPulse` is unchanged,
the server-recorded status is gone, and a 3.5-second post-cure
`HealthChanged` observation detects no new damage/ticks.

## Failed first attempt and test correction

At `8f3ffccd`, the same initial hostile hit and live client cure
were observed, but the test **FAILED** after acceptance because
its old `humanoid.Health <= before_hp` assertion treated any
positive HP change from normal regen as an illicit cure heal.
Commit `0fd05cbe` replaced this ambiguous comparison with
a direct authoritative healing-pulse check plus post-cure health
damage listener; that corrected test **PASSED**.

## Limits and adjacent automatic tests

No natural Captain AI slash, genuine earned persistent class
progression, player-driven quest kill/drop journey, full save/rejoin
or exact original C4 balancing was shown in this test. Those
acceptance gates remain OPEN.

The broader disposable Dungeon Play also printed an unrelated
`SkillMasteryGatesTest` assertion failure
`Full skill ranks alone cannot bypass earned mastery`. That
older automatic test expects legacy custom-class trial behavior
for a Human Fighter now required to choose an original C4
first-transfer branch; it needs a scoped follow-up. No overall
automatic-suite PASS is claimed. A prior unrelated rig contract
warned about a missing TrainingMarauder CollisionBody in a
separate Play run, also not certified or hidden here.
