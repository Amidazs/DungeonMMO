# v1.54 local-only backend continuation — lethal contribution and profile recovery

**Date:** 21 September 2026  
**Branch:** `wip/phase-4-test-hud-integration-v1`  
**Scope:** GitHub-only changes; unpublished Rojo/Studio verification
where the desktop connection was available. No production or TEST
place was published, no real DataStore or MemoryStore was accessed.

## Implemented and locally proven

1. Genuine lethal-hit contribution. Previously the damage callback
   ran after the guardian Humanoid was reduced to zero, so the
   world-boss authority's live-guardian guard could reject a player's
   **first and only killing blow** as contribution. DamageService
   now passes its server-observed lethal result through the existing
   CombatService → DungeonContributionBridge. The boss authority
   allows that exact fatal damage event while continuing to require
   admitted membership, matching player encounter attributes, the
   exact guardian model in the server-bound damage filter, and a
   still-undefeated stored boss event. Ordinary post-death support
   and later damage have no such exemption.

2. Added a separate disposable single-client, single-attack fixture:
   `scripts/studio/weekly_world_boss_one_hit_live.luau`. The first
   iteration placed the character outside first-swing melee reach,
   resulting in a real timeout. The fixture was corrected to a
   verified 2.5-stud melee position and rerun. At source
   `5b7edc2675fd8fc6e9b6d0908bdf263742cf88b6`,
   unpublished Studio printed:
   `LETHAL_DAMAGE_CONTRIBUTION_PASS`,
   `REAL_CLIENT_BOSS_DEFEAT_PASS`,
   `WEEKLY_REWARD_ONCE_PASS` and `VERIFIED_PLAY_MODE_PASS`.
   The guardian was defeated using the normal client attack
   RemoteEvent; the fixture did not set its health to zero or inject
   synthetic contribution.

3. On the earlier source `6252baa5bfea0694c3dd18d3c81caae19cc890a1`,
   the existing real-client combat and two-client combat regressions
   passed despite the new damage callback signature, as did the
   then-current seven-assertion damage filter, 17-assertion weekly
   reward retry and 11-assertion profile-exit tests. The initial
   one-hit fixture failed at this source *due to positioning*; do
   not describe the whole batch as green.

4. Previously verified locally on source
   `1b2554de8ea049b8bba18888f0f7d73a1b12be5f`:
   failed profile saves retain the in-memory pending award; retry
   persists exactly one award, then a fresh same-UserId service reads
   the persisted receipt. The Base and Dungeon reward-retry runners
   each passed 17 assertions. The world-boss departure helper retained
   the lease across two transient failed profile saves and released
   it only after persistence (11 assertions). The existing genuine
   two-client Play baseline also passed on that source.

## Additional GitHub changes — pending latest-head verification

- Added focused bridge assertions that lethal metadata survives
  a correctly targeted hit and cannot bypass exact-model filtering.
- Hardened `WorldBossProfileExit.retry_pending` for a different
  failure order: the profile is already saved and its local cache
  removed, but lease release fails. A retry now explicitly releases
  the original owned lease if no loaded profile remains rather than
  calling the no-op `ProfileService:release` path.
- Added a second simulated-account contract to trigger one failed
  lease release **after a successful profile save**, check that the
  destination cannot yet claim, then retry source release and verify
  a fresh destination loads the saved reward once.
- Earlier in this local-only increment, real two-client MageHeal
  exploration exposed unreliable Studio test health replication.
  The experimental support changes to the accepted two-client
  fixture were reverted. The existing `Mend` server pulse now
  records only its actual positive healing via the contribution
  bridge, but a genuine client-skill peer-heal/ward encounter is
  **not yet accepted**.

After the successful one-hit run and prior profile-exit tests, the
remote device became unavailable. Therefore the combined latest-head
Rojo build, expanded bridge assertions, additional post-save lease
release test and regression matrix are **pending**, not reported
as passed. Continue from the current GitHub branch without resetting
accepted work.

## Local next actions (no publishing)

1. When the authorized desktop is available, fast-forward a clean
   working tree, build all six Rojo compositions and run both lethal
   Play and the two-client baseline at the exact same GitHub head.
2. Run the updated damage-filter and profile-exit contracts, weekly
   reward retry in Base and Dungeon, plus professions and Dungeon
   backend regression. Diagnose and fix any failures through GitHub.
3. Add a focused genuine client support-skill fixture with a reliably
   injured other party member; confirm effective health change and
   scoped server support contribution. Keep the existing two-client
   melee/defeat fixture unchanged until this is independently green.
4. Continue local four-player party, death/recovery, full-wipe,
   per-member return and save/lease-failure contracts using in-memory
   adapters. None of these requires cloud publishing.

Published TEST/PROD cross-place teleport, genuine same-account
new-server reconnect and cloud persistence remain **separate deferred
release gates**. Event flags remain off. All code/test/document
editing stays in GitHub; Remote Desktop, when available, is only
for clean pull, build, unpublished Play and read-only diagnostics.
