# Warden physical two-client quest evidence — v2.36

Date: 24 September 2026. Branch: `wip/phase-4-test-hud-integration-v1`.
All references below are **unpublished disposable** Roblox Studio
tests. Test fixture identity, level, previous drops and quest stage
are not an actual uninterrupted player's progression.

## Legacy mastery regression — 39b0674d

The legacy `SkillMasteryGatesTest` expected a new Human Fighter to
start a now-disabled automatic Vanguard class path. Production
`ClassAdvancementService` deliberately requires the original
C4 branch choice instead. The regression now asserts the new
Fighter cannot auto-start a legacy trial, independently tests the
unchanged mastery/rank/level prerequisites, and checks that a
pre-existing legacy quest can still finish without reopening new
legacy entries. The focused Base Studio log
`%TEMP%\\DungeonMMO_v236_mastery_focus\\mastery.log`
records **65 assertions PASS**, result **1/1 suites PASS**.

## Physical Base — a5567be2

`scripts/studio/c4_greenward_warden_base_physical_live.luau`
adapted the previously verified Oathguard physical two-client
driver to the independent ElvenKnight Warden branch, original
Sentinel Ilyra and Warden Caer physical quest NPCs, actual owner
report/seal inventory and original Warden mentor/trainer.
Test-only prior dungeon loot was seeded after real quest steps
one/two (not earned by earlier actual client kills in this run).
It verifies actual client ProximityPrompt holds for first NPCs,
report/seal return, level-18 mentor refusal and level-20 award,
and a production real-client SkillLearnRequest for paid
GreenwardWardenSteelTraining rank1.

An in-memory test-only ModuleScript shares the authoritative
Base runtime with the test driver, not a global variable.
Fresh Rojo Base build passed and the RunScript output
`%TEMP%\\DungeonMMO_v237_warden_base_live\\base_live.log`
reported `[Greenward Physical] VERIFIED_LIVE_BASE_PASS`;
the driver emits this marker only if all awaited physical
prompt, transaction and trainer assertions completed and
StudioTestService returned PASS.

## Physical Dungeon — b752df98

`scripts/studio/c4_greenward_warden_dungeon_two_client_live.luau`
runs two actual clients in a single active instanced room with
distinct stages (three vs five). Rootbound Marauder and
Thornbound Colossus have separate encounter ownership.
For each owner, actual client normal attack reduced the source
enemy's Humanoid HP, then the server-only test driver completed
the remaining HP through the unchanged DamageService, so real
quest contributor and one-use receipt accounting run.

The test requires stage-three owner to gain exactly one
`verdant_patrol_report` and the stage-five owner to gain one
`verdant_guardian_seal`, with neither award leaking to the
other player. The fresh disposable Dungeon Rojo build passed,
and `%TEMP%\\DungeonMMO_v238_warden_dungeon_live\\world_live.log`
reported `[Greenward Live] VERIFIED_TWO_CLIENT_WORLD_PROOFS_PASS`.

This does not prove a fully client-delivered final blow, all
three report kills, a natural Base/Dungeon transfer, a physical
mentor acting on the *same transferred* profile, or published
cross-place save/rejoin. Those gates are open.
