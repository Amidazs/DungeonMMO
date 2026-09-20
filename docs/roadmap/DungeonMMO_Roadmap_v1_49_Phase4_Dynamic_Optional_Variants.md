# DungeonMMO Roadmap v1.49 — dynamic optional encounters

**Date:** 20 September 2026

**Status:** New ChatGPT-authored, GitHub-backed Phase 4 milestone supplement.
The canonical long-form `DungeonMMO_Roadmap_v1_47.docx` and the historical
v1.48 backend supplement are retained unchanged. This update does not
mean the integration branch was merged to main or any Roblox place
was published.

## Completed: backend optional encounter variety

The existing Temple/Mine Event and Secret boss system now accepts one
of two server-authoritative boss identities per optional kind, without
a second event scheduler, duplicated dungeon planner or new physical
arena. Optional boss eligibility and the selected boss variant are
frozen at run creation and retained in the materialized run plan.
Event/Secret selection remains independent; Event appears after Room1,
Secret appears before the selected depth's final required room and can
be skipped/backtracked. A saved expired Event remains the same chosen
boss upon controller reconstruction; an unknown saved unlock fails
closed.

The new option `DungeonMMOOptionalBossVariantsEnabled` is read
from **ServerScriptService only**, defaults OFF, and never overrides
`OptionalBossRuntimeEnabled` or Depth2–4 `RuntimeReleaseEnabled`.
Existing boss factories are reused as placeholders for the alternate
Temple/Mine Event/Secret variants. Authored boss art, audio and
production release are separate future work.

**Critical integration fixes accepted:** The existing Secret-discovery
authority was extended to validate the exact saved and dungeon-scoped
alternate unlock rather than recognizing only two legacy boss IDs.
The shared boss executor now gives Event, Secret, returning miniboss
and FinalBoss encounters separate encounter-scoped monster reward IDs.
The original Depth1 Boss reward identity remains unchanged for saved
player compatibility.

## Verified acceptance and evidence

- 2,205 dynamic plan/selection/reconstruction assertions across
  Temple/Mine, Depth1–4, independent Event/Secret eligibility and all
  four deterministic variant combinations.
- 232 original/alternate Secret discovery assertions across both
  dungeons and all four depths, including idempotence and backtracking.
- 80 same-factory optional/miniboss reward assertions including
  four persisted and replay-resistant receipts per dungeon.
- Final 22/22 optional focused Studio suites and 30/30 wider gameplay
  backend suites PASS; four local Rojo compositions built.
- TEMP, assisted physical alternate Event+Secret route PASS:
  Temple Depth2 (six encounters) and Mine Depth4 (eight encounters).
  Separate normal variant-disabled Temple Depth2 physical route PASS.
- Four-real-client TEMP Mine Depth4 alternate-boss playtest PASS:
  simultaneous Event entry spawns one boss, one player disconnects
  during Event, three complete all required and optional encounters,
  separate same-factory optional/miniboss rewards reach each survivor,
  and member-level completion replay grants nothing twice.

Full logs, historical RED findings, design constraints and source
receipts: `docs/testing/phase4-dynamic-optional-boss-variants-2026-09-20.md`.
Changes and tests were authored in GitHub first, then fast-forward
pulled into the existing local Windows integration worktree for
unpublished Studio testing. No cloud TEST/PROD publish, real player
DataStore or authored art was modified.

## Recommended next backend work

Extend the accepted *configurable encounter-catalogue interface* to
support more distinct event templates and explicitly authorized
insertion points. Preserve a per-run frequency cap, stable unique
encounter/physical-slot IDs, independent reward transactions and
reconnect-safe trigger snapshots; test each template against the
existing Depth1–4 route before opting it into any live place.

Before claiming real release acceptance, independently prove
same-account network rejoin/new reserved-server recreation and
unassisted multiplayer combat and balance in the appropriate TEST
environment **only when authorized**. Neither has been proven by
the local placeholder fixtures. Art/model refinement can remain
deferred while backend rules and regression coverage are developed.

## Handoff

Read `docs/ai/CURRENT_STATE.md`, `docs/ai/HANDOFF.md`,
`docs/ai/TEST_MATRIX.md`, the v1.48 roadmap supplement and this
v1.49 update before continuing. Do not repeat accepted backend systems,
reset historical checkpoints or silently enable optional/high-depth
release flags. Keep code changes GitHub-first and test with local
unpublished Rojo/Studio places until instructed otherwise.
