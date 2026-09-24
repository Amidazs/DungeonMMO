# v2.39 — Warden natural Captain AI and factory-rig evidence

Date: 24 September 2026. Unpublished local disposable Dungeon place.
Executed test candidate `fd7f8d0c023b32241412bf37537488e670f40816` (the natural bleed test was added
at `fd50f8b6`, and the rig focus at `fd7f8d0c`).

## Actual AI slash to purchased client Bleed Recovery

Source:
`scripts/studio/c4_greenward_warden_natural_captain_bleed_live.luau`.
Unlike the earlier trusted-callback-only test, no test script calls
DamageService or PlayerBleedStatusService.apply_from_captain.
The unchanged running Captain AI detects an appropriately
encounter-scoped, living actual Studio player and lands its own
normal CaptainSlash attack. Only then does the test disarm
future AI attacks by removing the Captain tag. The enemy model
remains alive and world-parented for the uncured tick check.

Observed in
`%TEMP%\\DungeonMMO_v244_natural_captain_bleed\\natural_bleed.log`:
`DAMAGE APPLIED CaptainSlash 24.0HP` on the real player;
`NATURAL_CAPTAIN_AI_SLASH_BLEED_PASS`;
`SKILL ACCEPT GreenwardWardenBleedRecovery`;
`MAGE_CURE APPLIED GreenwardWardenBleedRecovery`;
`REAL_CLIENT_CURE_NO_LATE_TICK_PASS`;
`ALL_REAL_CLIENT_STATUS_CHECKS_PASS` and
`VERIFIED_NATURAL_CAPTAIN_PLAY_PASS`.
The driver also checks spoofed presentation attributes fail
to mint a cure, actual owner mana decreases, no healing pulse
occurs and the server status is cleared before delayed tick
observation. The Warden profile's earned-class receipt and
purchased rank are deliberately test-prepared in disposable
server state; cross-place save/rejoin is not tested here.

## Unrelated legacy training-rig contract repair

The earlier Play log warned that the automatic training-rig
test could wait forever on `TrainingMarauder.HumanoidRootPart`;
a synthetic Dungeon layout contains a legacy named object
without the prior arena rig. We changed the *test*, not the
production MarauderFactory or shared animation/asset source.
The new physical contract calls MarauderFactory.create for
each of four configuration variants, verifies root/hull/
Motor6D/visual collision properties and destroys the
temporary Workspace fixtures in a protected cleanup path.

Focused disposable Dungeon test log:
`%TEMP%\\DungeonMMO_v245_rig_focus\\rig.log`:
`[Marauder Rig Contract Tests] PASS: four factory rigs`
and `[Marauder Rig Contract] VERIFIED_FOCUS_PASS`.
A clean factory focus does not automatically certify the
entire separate background Studio Play suite.

## Remaining limitations

Natural, uninterrupted Base-to-Dungeon-to-Base profile travel
and rejoin, physical quest item handoff across places,
exact historical C4 damage and skill formulas, party/PvP
balance and full original first-transfer release readiness
remain unverified. No publication or main merge.
