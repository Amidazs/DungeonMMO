# Phase 4: Event and Secret Boss backend candidate

## Current checkpoint - 19 September 2026 step 1 validation

This section supersedes older active-branch, no-push and pending-Studio notes
below. Older gate sections are historical evidence, not current release status.

- Active worktree: C:/Users/Remko/Documents/Roblox/DungeonMMO_Phase4_EventSecretPolicy_v1.
- Branch: wip/phase-4-event-secret-policy-v1.
- Validated source: cb29a7c54637e371e1041ab68009c4951b579d00.
- GitHub feature tip independently verified at the same SHA on 19 September.
- Main and GitHub main remain a3c2625cfc53dbb1c2bb8d6ce17f5f3749809fa9;
  this backend branch is not merged into main.
- v1.44 is now committed on this feature branch. Its statements about the
  uncommitted issuer/test edits and an unpushed optional-boss branch are
  superseded by this checkpoint.
- Step 1 backend regression is VERIFIED on the exact committed source.
  This is not physical-content acceptance or rollout approval.
- Fresh Dungeon Studio: issuer 34, extended instance director 23, policy 49,
  optional flow 9, factories 24, release locks 14, readiness 70 assertions PASS.
- Dungeon server captured 248 PASS markers and zero errors; live admission passed.
- Fresh Base Studio: 132 PASS markers, issuer 34, readiness 70, party difficulty
  22 and party difficulty entry 32 assertions PASS; server/client errors = zero.
- Phase 3 stress PASS in both compositions: profiles=250, market=1000,
  replay=1000, guild=250, sessions=100, race_roundtrips=100.
- 539 source Lua/Luau files parsed with zero failures; four Rojo builds PASS.
- OptionalBossRuntimeEnabled remains false for both dungeons. Depth2-Depth4
  remain physically unregistered and release-disabled.
- No gameplay source changed in this validation step. Documentation/evidence
  changes remain uncommitted; no commit, push, merge or publish was performed.
- Known diagnostics: expected audit-sink failure injection in both runs;
  source-controlled fallback-animation notice in Dungeon. Neither is a test failure.
- Evidence: docs/testing/phase4-optional-boss-step1-validation-2026-09-19.md.

### Exact next action

At the step-1 user checkpoint, report the completed backend validation.
Next ordered step is Event and Secret gameplay rules: prepare a bounded design
for actual server event schedules, secret discovery conditions and reward
configuration, reusing existing issuance/session/reward authority. Define
reconnect/idempotency tests before implementation. No concrete schedule,
secret-discovery mechanic or new reward balance is approved by this record.
Distinct enemy/boss mechanics follows as the next substantial combat gate.
Keep physical release locked and the UI/art worktrees separate.

## Historical candidate evidence

Date: 19 September 2026
Branch: wip/phase-4-event-secret-policy-v1
Base commit: ff2baa0
Status: CODE-ONLY BACKEND GATE VERIFIED; NOT RELEASED.

## Implemented

Four distinct optional-boss identities: Eclipse Herald and Veiled
Sentinel (Temple); Echo Ravager and Buried Archivist (Mine). Their
factories reuse accepted Captain/Foreman combat logic and models.

Depth1-Depth4 optional encounter descriptors are available for both
dungeons. Event activation requires a matching server-owned event ID,
explicit activation and an entry timestamp inside an authoritative
event window. A Secret boss requires an explicit server-owned unlock.
The existing Mine Deep Echoes modifier cannot activate the new boss.

Only activated optional encounters require physical boss-capable slots,
boss-spawn anchors and implemented boss content. Activated events are
completion-required. Secret bosses remain skippable: entering their
direct next main room persists one optional skip; unrelated triggers
and required bosses cannot be bypassed.

## Release locks

Both dungeons explicitly keep OptionalBossRuntimeEnabled = false.
A run additionally requires InstanceState.OptionalBossEnabled = true.
Neither current Depth1 layout has EventArena or SecretArena; Depth2-4
physical layouts remain unregistered and release-disabled. No authored
rooms, maps, meshes, models, art or UI were changed.

Do not turn on optional-boss rollout yet. A future gate needs authored
physical arenas/triggers/checkpoints/spawn anchors, an authoritative
boss-event schedule and secret-unlock rollout configuration, with real
physical gameplay and reward acceptance. New bosses reuse existing
visuals and attacks until bespoke content is approved.

## Validation

- 537 Lua/Luau files parsed with zero errors.
- All four Rojo compositions built successfully.
- Offline source-backed Luau: policy 49, flow 9 assertions PASS.
- Dungeon Studio Play: policy 49, secret flow 9, boss factories 24
  and release locks 14 assertions PASS.
- Dungeon baseline encounter, depth/content, execution and readiness
  regressions PASS; player admission PASS; zero project Creator errors.
- Phase 3 Systems Stress, Training Dummy and Combat Target Rules PASS.
- Base Studio Phase 3 stress and party/difficulty regressions PASS.
  Four unrelated Roblox Controls Emulator plugin startup errors were
  present in Base; no other Creator errors were found.
- Additional issuance regression: 28 assertions PASS in offline Luau.
- Instance director regression extended with 10 release-lock assertions;
  Studio rerun of the extended suite remains unverified.
- Final candidate: four Rojo compositions and diff check PASS.
- No push, merge, publish, production DataStore or Robux action.

Canonical long-form roadmap remains unchanged: physical and release
acceptance are separate future gates, not backend blockers. This
code-only gate does not authorise rollout or publishing. The UI worktree
and last accepted Depth4 backend checkpoint remain intact.
