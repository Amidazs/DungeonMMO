# C4 Atomic Combat Cutover v2.89 — Acceptance

Date: 25 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.

## Result

**GREEN — atomic source-combat gate orchestration and rollback passed fresh
Base and Dungeon focused validation.**

## Candidate

`4dc1f2ee56814c9af3e0cf42de339c08f68c0211`.

## Evidence

- Base Rojo: PASS;
- Dungeon Rojo: PASS;
- git diff validation: PASS;
- Base focused Studio: **22/22 PASS**;
- Dungeon focused Studio: **25/25 PASS**;
- cutover coordinator: **7 assertions PASS**;
- dispatch adapter: **18 assertions PASS**;
- Dungeon dispatch integration: PASS;
- resource cutover: PASS.

## Transaction guarantees accepted

- source mode starts OFF;
- audit readiness is required;
- all gates must be OFF before transaction start;
- participant resource cutover is explicit;
- spatial conversion/night state are explicit server inputs;
- partial participant failure fully rolls back;
- late dispatch failure fully rolls back;
- successful enable reaches resource + calculation + executor + dispatch;
- disable reverses the complete transaction;
- no client authority exists.

## Safety boundary

This test uses injected authorities for transaction failure coverage. It is not
yet the genuine multiplayer Dungeon cutover rehearsal.

Normal game bootstrap still leaves source combat disabled.
