# C4 new-skill real-client combat focus — local acceptance

Date: 22 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Game-code composition: `755fab0` (same game source as `687e27c`)
Final focused Studio fixture: `c944ddd928385ebf78b5c6a4744b73ae9eff6a7b`
Fixture: `scripts/studio/c4_new_skill_client_live.luau`

## What was actually executed

A clean fast-forward of the GitHub branch preceded a successful Rojo
Dungeon build to a disposable unpublished `.rbxlx` file under TEMP.
Roblox Studio ran the GitHub-authored fixture through supported
`--task RunScript --localPlaceFile --runScriptFile` launch arguments.
The fixture used `StudioTestService:ExecutePlayModeAsync`, a real
Play client and the existing `CombatInputActions.request_skill_slot(1)`
path. No source or document files were edited via Desktop Commander.

Only the **disposable Studio Play server** seeded temporary
class/rank/loadout/equipment runtime state for Human Mage, Ranger and
Rogue. A temporary client event applied a representative simulated
progression snapshot to the actual `SkillsMenu` implementation.
The existing server combat services, client action module, combat
remote, skill implementations and a real tagged `TrainingDummy`
performed the actual skill effects. The test did not bypass the
existing combat request handler or directly subtract target health.

## Observed results

- Dawn Ward: real client hotbar action applied server-owned ward
  absorption. The actual mana expenditure observed at the server
  was 12, equal to its rank-one configured cost.
- Cinder Bolt: real client hotbar action fired a magic projectile and
  reduced the tagged TrainingDummy's health. The server observed an
  instantaneous mana expenditure of 10, equal to its configured cost.
- Archer Draw: Ranger client hotbar action damaged the TrainingDummy
  with the required server-owned Longbow equipped.
- Vital Blow: Rogue client hotbar action damaged the TrainingDummy
  from a rear-positioned player with a server-owned sword equipped.
- The actual SkillsMenu rendered the selected learned rank and hid
  an unowned foreign-class row for each simulated snapshot.
- The final Studio log reported
  `[C4 Client] ALL_FOUR_SKILL_EFFECTS_PASS` and
  `[C4 Client] VERIFIED_PLAY_MODE_PASS`.

Final test log (local only):
`%TEMP%\DungeonMMO_C4_ClientLive_c944ddd.log`.
The temporary Dungeon build was
`%TEMP%\DungeonMMO_C4_ClientLive_755fab0.rbxlx`.

## Scope and limits

This is a **real Play client/action/server-effect** test; it is not
a physical keyboard/mouse usability test, an actual saved-profile
skill purchase, a live trainer transaction, proof of increased rear
damage compared to a frontal strike, or TEST-cloud multiplayer
acceptance. The displayed client snapshot and per-server character
state were deliberately synthetic, and no production DataStore or
published Roblox place was touched. Actual player-profile/trainer
UI and input ergonomics remain separate future acceptance.

The unscoped automatic Dungeon scripts emitted two additional
test failures: `Phase2AFailurePathTest` (paid-revive grant) and
`RogueDefinitionsTest` (Duelist trainer branch-family count).
These were **not** considered passes and are separate focused-test
follow-ups before any wider release claim. They do not negate the
four specifically instrumented skill-effects above; no full Dungeon
regression acceptance is claimed from this run.

No old dungeon wipe, aggro, revival or replay test cycle was run
for this focused fixture. The existing C4 quantity audit remains
13/16 mismatched Fighter/Mage brackets; Ranger/Rogue reference
rank-volume mapping is still open. No `main` merge, Roblox publish,
force-push or production profile operation occurred.
