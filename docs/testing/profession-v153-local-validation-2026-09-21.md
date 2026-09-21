# Profession v1.53 local verification — partial acceptance

Date: 21 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Source tested: `45a9bc25a185fcdb00579e977a22dc582eefc1ec`
Status: **four builds and deterministic Studio suites PASS; physical
profession station/RemoteEvent acceptance remains PENDING.**

## GitHub-first and local scope

The pre-pull integration worktree was clean, behind origin by 21 commits,
and a fast-forward to the above commit succeeded. Four local unpublished
Rojo builds passed: `default.project.json`, `base.project.json`,
`published-dungeon.project.json`, `published-base.project.json`.
Disposable output files were built outside the repository under
`%TEMP%\DungeonMMO_v153_validation\`.

The exact existing versioned `scripts/studio/profession_cross_dependency_tests.luau`
runner was executed in both disposable unpublished Studio Edit places.

| Run | Studio evidence | Result |
| --- | --- | --- |
| Dungeon focused profession | `0.739.0.7390687_20260921T085123Z_Studio_7C721_last.log` | 10/10 suites, zero failed |
| Dungeon broad gameplay backend | same log | 30/30 suites, zero failed |
| Base focused profession | `0.739.0.7390687_20260921T085257Z_Studio_94DB0_last.log` | 10/10 suites, 305 assertions, zero failed |
| Base generic Play-mode smoke | same Base log | `[Phase 4 Base Live] VERIFIED_PLAY_MODE_PASS` |

The focused suites include all seven profession definitions, fresh and
legacy migration, original and extended multi-profession dependency,
equipment-input and wrong-minigame protection, exactly-once consumption,
in-memory save/reload, runtime range rules, per-player request guard,
recipe knowledge and inventory regressions. The independent
`Profession Craft Guard` test reported 12 assertions.

The Base Play smoke verified that a player spawned in the actual
simulation with the Base runtime and profile remote available and that
the optional dungeon release locks remained off. **That generic smoke
does not exercise actual Skinning prompt activation, Leatherworking or
Enchanting RemoteEvent crafting, live range enforcement, rapid duplicate
requests, independent two-player requests or disconnect/retry.** Those
are not accepted by inference from deterministic service tests.

The Base Play log also reported `DungeonOptionalDynamicSecretDiscoveryTest`
referring to an absent `ServerScriptService.Dungeon`, a separate
`DungeonOptionalBossRecoveryTest` infinite-yield warning waiting for
that child, and the expected `EconomyAuditIntegrationTest` simulated
`audit sink unavailable` warning (that suite subsequently passed its
27 assertions). These are not claimed as zero-log-error acceptance;
review the Base composition test autorun separately from the targeted
profession passes.

## First real client/server Base profession fixture — PARTIAL / FAIL

GitHub-created `scripts/studio/profession_base_live_requests.luau` at
`31e26afbb558e9985527607a40f0a7d3dc1fcbf9` was safely pulled into
the clean Windows worktree and executed unchanged on the same disposable
unpublished Base Studio place. Unlike the earlier generic Play smoke,
this fixture sends actual client `ProfessionCraftRequest:FireServer`
calls while moving the server-owned player character near and far from
each newly added station.

The Base log
`0.739.0.7390687_20260921T085257Z_Studio_94DB0_last.log` records:

- `STATION_RANGE_PASS cure_raw_hide near_reason=MissingMaterials`.
- `STATION_RANGE_PASS inscribe_warding_rune near_reason=MissingMaterials`.

At both stations, the far client request returned
`NotAtRequiredStation`, whereas the near request reached the live
craft service and failed normally on missing materials. The client also
sent a fabricated extra success argument; because materials were
missing, this **does not prove** that a material-backed craft ignores
forged success data in live Play.

The same fixture's client-side scripted ProximityPrompt hold for
`Base.RawHideCache` produced no Gather action result within 15
seconds. The fixture terminated with
`[Profession Base Live] TIMEOUT Gather result`. Treat the overall
fixture as **FAIL**, not as a completed or accepted hide-cache test.
This does not establish whether the issue is scripted input activation,
physical prompt placement, or server claim processing. Investigate the
prompt in the disposable place and rerun after a GitHub-only fixture
change, or perform a genuinely physical client activation. No repeat-
claim, full material-backed craft, overlapping requests or disconnect
checks were executed in this fixture.

## Remaining v1.53 acceptance gate

- [ ] A **fresh physical Base Play-mode profession fixture** sends real
  client `ProfessionCraftRequest` calls, checking too-far rejection and
  near-station request routing without supplying a minigame success.
- [ ] Check actual Base RawHideCache prompt one-time claim and verify
  the real client/server crafting path for Leatherworking and Enchanting
  through to final equipment (service-only chain is already covered).
- [ ] Verify rapid duplicate request, independent players and actual
  disconnect/retry cleanup over the live RemoteEvent rather than only
  the isolated pure guard.
- [ ] Investigate/limit the Base-only unrelated Dungeon test autorun
  messages before claiming a completely clean live Studio log.
- [ ] Run any needed new live fixtures on disposable local Studio places
  before promoting v1.53 to fully accepted.

All source and documentation edits remain GitHub-only. Remote Desktop
was used for safe fast-forward pulling, building, opening disposable
places, running unchanged tests and reading logs. No cloud publish,
real-player DataStore test, force-push or merge into `main` occurred.
