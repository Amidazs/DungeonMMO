# DungeonMMO roadmap v1.55 — combat threat and wipe cleanup

**Date:** 21 September 2026  
**Branch:** `wip/phase-4-test-hud-integration-v1`  
**Status:** LOCAL VERIFIED at gameplay source
`739e747d88d93ff00ed30497e9473edd17b037f4`;
release/publish deliberately deferred.

## Completed gameplay/backend work

- [x] One shared authoritative per-enemy threat policy: nearest
  eligible player before real threat, then highest eligible threat
  with distance only breaking ties.
- [x] Actual server-applied damage creates damage threat and
  rankable Fighter Taunt creates non-damage threat through the
  real client skill-authority/melee/cooldown path.
- [x] MageHeal, Mend and genuinely absorbed ArcaneWard generate
  support threat from effective values at a provisional 0.5 rate.
- [x] Healing an eligible ally cannot pull idle enemies, off-room
  enemies or a mob with only stale ineligible threat.
- [x] Per-enemy separation, dead-player target removal, actual
  departure cleanup and four real-client tank/DPS/healer tests
  with two independently engaged live Marauder controllers.
- [x] After three continuous seconds with no eligible target,
  previously engaged controllers clear their threat ledger and
  eligible target cache. Real four-client full-wipe proof passed.
- [x] Correct-composition isolated world-boss real two-client
  aggro, Mage Heal, Ward absorption and Fighter Mend Play.
- [x] Six Rojo builds; focused ThreatService 51, Dungeon gameplay
  30/30 and Base profession 14/14 regressions passed at
  the verified gameplay source.

Full dated proof:
[Four-player wipe and threat reset](../testing/four-player-full-wipe-threat-reset-2026-09-21.md).
See also the earlier
[four-player two-enemy gameplay proof](../testing/four-player-two-enemy-aggro-multiplayer-2026-09-21.md)
and
[isolated world-boss support proof](../testing/world-boss-aggro-support-multiplayer-2026-09-21.md).

## Next backend gates

- [ ] Full dungeon **session** wipe/retry: decide and implement
  enemy-health/spawn restoration, party respawn routing and
  checkpoint/session reset without duplicated rewards.
  The accepted three-second policy resets **threat only**.
- [ ] Real disconnect/reconnect and full session lifecycle across
  ordinary dungeons and the isolated world-boss prototype.
- [ ] Verify full four-person party authority, player deaths and
  re-entry against session admission/reward services, not just
  stand-alone training Marauders.
- [ ] Final support-threat/tank balancing from actual gameplay
  evidence; 0.5 is provisional.
- [ ] Published TEST travel, true cloud persistence/cross-server
  reconnect and production rollout await separate authorization.

No modelling, meshes, published Roblox place, main merge, PROD
DataStore writes or value-bearing changes are part of this update.
The canonical historical Word roadmap has not been overwritten;
this is the latest GitHub Markdown progress supplement.
