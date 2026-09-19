# Phase 4: Event and Secret Boss backend candidate

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
