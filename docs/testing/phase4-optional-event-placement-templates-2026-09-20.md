# Phase 4 — configurable optional Event placement (local backend checkpoint)

Date: 20 September 2026. Integration branch:
`wip/phase-4-test-hud-integration-v1`.
Source before this work:
`292133cc77e42a1b4d49753d63503e0fc525384a`.

## Scope and GitHub-first implementation

The existing event-issuance, optional-boss policy, generic encounter plan,
physical binding and replay-proof reward machinery were extended without
introducing a second scheduler or changing the accepted dungeon depth
sequence. Code was authored in GitHub first and fast-forward pulled into
the existing Windows integration worktree for local unpublished Rojo/Studio
testing. No published TEST/PROD place, user DataStore, authored map/model
or main branch was changed.

A new shared, server-owned
`DungeonOptionalEncounterTemplateCatalog.luau` provides explicit, stable
placement choices per supported dungeon and difficulty:

- `EventAfterRoom1`: the accepted legacy Event route using
  `EventArena` and the unchanged boss encounter suffix.
- `EventAfterRoom2`: a new **backend-only**, Depth2–4 placement after
  the *second required encounter* (Depth4's returning miniboss Room2
  included), using a distinct `EventArenaLate` physical slot and
  `BossId .. "LateEncounter"` encounter/reward identity.
- `SecretBeforeFinal`: the accepted optional Secret placement before
  the chosen depth's final required encounter.

A separate `DungeonMMOOptionalBossTemplatesEnabled` server-only flag
defaults OFF, is independent of the existing optional-boss variant and
release switches, and selects the late Event deterministically for odd
server session seeds when the chosen difficulty supports the template.
Only a currently eligible Event receives a template ID in the
server-issued, run-frozen state. All legacy snapshots and disabled-opt-in
runs retain Event after Room1.

`DungeonOptionalBossContent` now obtains its insertion anchors and
physical slot/encounter IDs from that single catalogue. The generic
policy accepts **at most one active EventBoss and one active SecretBoss
per run**, rejects two optional encounters trying to use the same physical
room and requires an explicitly verified matching
`OptionalInsertAfterId`, `OptionalPlacementVerified=true` and a
registered boss-spawn anchor for a late placement. Unknown saved
template IDs, unsupported depth placements and missing/mismatched
physical slot capability all fail closed.

**Important release boundary:** The actual Temple and Mine layouts
do **not** register `EventArenaLate` and have no late-Event bridge/gate,
trigger or boss spawn yet. The opt-in is OFF in ordinary source. The
new template is *not a playable or released late boss*; attempts to
materialize it using the existing legacy layout are rejected with
`OptionalBossContentUnavailable`. Synthetic unit-test slot metadata
is used only to exercise the planner and recovery state contract.
No cave-in, gathering event, additional mob-pack type or generalized
environment-effect executor has been added by this milestone.

## New deterministic template tests — PASS

`DungeonOptionalEncounterTemplateTest` covers Temple and Mine at
Depth2, Depth3 and Depth4 with alternate deterministic seeds. It checks
saved placement identity; after-Room2 insertion without losing required
rooms; independent Secret-before-Final selection; no duplicate
encounter or reused physical-room IDs; one-Event/one-Secret frequency
caps; rejected missing/mismatched/unverified late physical slots;
default legacy compatibility at every depth; Depth1 late placement
rejection; invalid saved template rejection; and reconstruction of an
interrupted late Event as Pending after the global event window expires,
without resetting previously cleared rooms or changing the saved slot.

Fresh final focused Studio receipt:
`0.739.0.7390687_20260920T201131Z_Studio_3B172_last.log`.
Markers: `[Optional Encounter Template Tests] PASS: 274 assertions.`
and `[Optional Boss Studio Focus] PASS: 23 edit-mode suites.`

## Fresh unchanged-route Play-mode and broader regression — PASS

- Original Temple Depth2, both existing Event/Secret bridges and
  six-encounter assisted physical route:
  `0.739.0.7390687_20260920T200949Z_Studio_1BF02_last.log`,
  `VERIFIED_PLAY_MODE_PASS TestDungeon Depth2`.
- Previous alternate Event and Secret bosses still spawn, grant
  encounter-specific rewards and complete the six-encounter
  assisted physical Temple Depth2 route:
  `0.739.0.7390687_20260920T201406Z_Studio_ACF22_last.log`,
  `REWARD_REPLAY_PASS Event`,
  `REWARD_REPLAY_PASS Secret` and
  `VERIFIED_ALTERNATE_PLAY_PASS TestDungeon Depth2`.
- A first rerun of that unchanged alternate fixture failed before
  Play mode because it searched for the previous
  `DungeonOptionalBossRunState.issue` call signature at RunScript
  line 66. The TEMP fixture was updated in GitHub to include the new
  difficulty argument; the subsequent fresh rerun above passed.
  No production progression or reward check was disabled.
- Broad backend matrix:
  `0.739.0.7390687_20260920T201053Z_Studio_AEF32_last.log`
  records `RESULT passed=30 total=30 failed=0`.
- All four local Rojo compositions built: Dungeon, Base,
  published-style Dungeon and published-style Base. These were
  **local build outputs, not cloud publishing**.

The new late slot's synthetic planner/recovery validation is not
represented as a real walking, combat or multiplayer playtest. No
unassisted boss balance, true same-account cross-server reconnect,
cloud TEST acceptance or real user DataStore writes occurred.

## Next acceptance boundary

Before enabling the new late template outside a disposable test,
register a dedicated, walkable, physically gated `EventArenaLate`
route for each intended dungeon/depth, with its own boss-spawn,
trigger and checkpoint anchors and explicit placement metadata;
extend the existing entrance-gate owner to synchronize that entrance
with the saved ordered encounter plan. Then run fresh assisted
physical traversal, same-encounter multiplayer/disconnect, reward
replay and optional-disabled default-route regressions. New non-boss
event mechanics are a *separate future backend step* and must reuse
the accepted generic executor/condition system rather than silently
creating a parallel scheduler.
