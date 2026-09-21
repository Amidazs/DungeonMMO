# Isolated world-boss combat and support acceptance

Date: 21 September 2026
Feature branch: `wip/phase-4-test-hud-integration-v1`
Tested source: `46978e87c78115212aba10628e235d9a94e48a38`

## Test-composition repair

The initial world-boss aggro attempts mistakenly ran against
`default.project.json`, the normal Dungeon place. The diagnostic
server log reported `WorldBoss is not a valid member of
ServerScriptService`; the original outer timeout was therefore a
fixture/composition error rather than evidence of broken enemy AI.
The correct unpublished local composition is `world-boss.project.json`.

The correct-composition fixture then exposed two test assumptions:
the first attacker can land a two-hit combo, requiring more than
two real challenger hits to exceed its threat; and the boss moves
during combat, so the original near/far positions become stale.
The GitHub-only fixture now permits sufficient real client hits
and re-establishes near/far geometry around the boss's live root.

## Fresh real multiplayer results

- `6e667384f95800373687130254916e4458aa525a`:
  correct world-boss composition, genuine two-client guardian
  aggro fixture: `VERIFIED_MULTIPLAYER_PASS`.
- `46978e87c78115212aba10628e235d9a94e48a38`:
  correct world-boss composition, genuine two-client guardian
  support fixture: `VERIFIED_MULTIPLAYER_PASS`.

The second fixture uses actual server-owned session admission,
two real Studio clients, client-driven Fighter Taunt and Mage
Heal/Ward skills and client-driven Fighter Mend. A genuine guardian
NPC attack (not synthetic incoming damage) is required for the
Ward absorption assertion. A test-only server threat priority
adjustment places the protected Fighter in range for this attack;
actual health damage and Ward absorption follow the real NPC
combat pipeline. The test does not establish a production balance.

All source/test/document changes were made directly in GitHub.
Remote Desktop performed only fast-forward pulls, local
builds/tests and read-only diagnostics. No Roblox place was
published, no main merge, production data mutation or cloud
persistence testing occurred.

Remaining: four real-client party roles, multiple enemies in one
room, actual player departure and full wipe/respawn reset.
