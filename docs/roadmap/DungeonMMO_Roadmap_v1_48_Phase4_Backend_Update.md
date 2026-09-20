# DungeonMMO Roadmap v1.48 — Phase 4 backend milestone update

**Date:** 20 September 2026  
**Status:** Versioned supplement to the canonical long-form `DungeonMMO_Roadmap_v1_47.docx`. Historical v1.47 content is preserved.  
**Active phase:** Phase 4 — Content Alpha (backend-first).  
**Source branch:** `wip/phase-4-test-hud-integration-v1`.  
**Verified GitHub and Windows worktree checkpoint:** `cfb35d0c98c8701ec34388be8dad4ce72a57e3f9`.  
**Pre-higher-depth-optional rollback tag:** `phase4-before-depth-optional-physical-20260920` at `924bcbe15802bcafe56c938564f2210dc28f466c`.

This update supersedes earlier *next-step* notes about adding Depth 2–4 optional placeholder side rooms. It does not change the accepted historical record or imply that the integration branch has been merged to main or published to Roblox.

## 20 September 2026 — local higher-depth party milestone update

The planned party-lifecycle work in Section 3 has now passed its
**local backend and assisted Studio multiplayer** acceptance subset:
two- and four-client Temple/Mine Depth2/4 runs with a shared frozen
Event/Secret plan; concurrent entry without duplicate bosses; one real
Studio-client disconnect during Event or Secret; continued progress
and completion by the remaining one or three members; and member-level
completion reward replay protection. The stricter completion test initially
correctly rejected fresh Depth2 profiles missing Depth1; the fixture now
grants only disposable prior clears through the existing progression
service. Service-level automatic revive and all-member wipe/checkpoint
tests passed 392 assertions across Temple/Mine Depth2/4 and 1/2/4
members. The focused optional suite passed 19/19, the broad backend
matrix 30/30, and all four local Rojo compositions built.

These are **not** live same-account rejoin/new reserved-server tests,
unassisted whole-party combat or an in-Play full-party wipe. All existing
release switches remain off. The next backend task is to extend the
server-owned dynamic Event/Secret catalogue, insertion policy and reward
rules using the already accepted generic dungeon machinery. Preserve
actual network rejoin, physical party wipe, cloud TEST approval and
authored art as independent future gates.

Full receipts:
`docs/testing/phase4-higher-depth-multiplayer-lifecycle-2026-09-20.md`.
Original pre-checkpoint source:
`cfb35d0c98c8701ec34388be8dad4ce72a57e3f9`.
No original historical v1.47 long-form DOCX was overwritten.

## 1. Completed backend and local gameplay milestones

**Progressive dungeon depth:** Temple and Abandoned Mine retain 3, 4, 5 and 6 required encounters at Depths 1–4. The final difficulty retains its distinct final boss and its earlier-depth bosses in miniboss positions. Two separate dungeon ladders, persistent unlocks, ordered encounters, interrupted-miniboss recovery and exactly-once completion rewards passed the existing 454-assertion local integration test.

**Optional Event/Secret rules:** The existing server-issued eligibility system selects Event and Secret independently for a frozen run. The Event appears after Room 1 only if eligible at entry. The Secret appears after the penultimate required room (Depth 1: Room 2; Depth 2: Room 3; Depth 3: Room 4; Depth 4: Room 5), remains skippable and can be revisited before completion. Entry-time eligibility persists when the external event window later closes. The earlier hard-coded Room 2 Secret gate bug and the Mine-only gate-registration omission were reproduced and corrected.

**Higher-depth placeholder physical routes:** Explicitly opted-in, unpublished Studio Temple/Mine Depth 2–4 layouts now contain separate walkable Event and Secret rooms, bridges, gates, unique checkpoints, triggers and boss-spawn anchors. The shared gate controller targets the selected depth and keeps the unused Depth 1 bridges sealed. Required rooms and the non-optional routes remain intact.

**Physical Play-mode acceptance:** Six *independent* local Studio runs passed: Temple and Mine at Depths 2, 3 and 4. Each used physical walking movement into and out of both side rooms, activated the expected bosses through server-owned triggers and completed the dungeon. Each depth had 6, 7 or 8 total encounters when both optional bosses were issued, respectively. A separate seventh Mine Depth 4 run bypassed Secret, returned to clear it and then completed the still-pending final boss, using a test-only final-spawn deferral.

**Regression evidence:** Higher-depth geometry checks passed 139 assertions; optional-boss focused tests passed 18/18 suites; the broad gameplay backend matrix passed 30/30 suites; the original optional-disabled Temple Depth 2 four-room route passed; four local Rojo build compositions succeeded. The user separately confirmed manual solo completion of both optional bosses; that report is distinct from the automated physical tests.

**Source of truth:** `docs/testing/phase4-depth2-4-optional-physical-playtest-2026-09-20.md`, `docs/testing/phase4-depth1-4-progression-integration-2026-09-20.md`, and `docs/testing/phase4-optional-depth-events-and-side-gates-2026-09-20.md`.

## 2. What is accepted, and what is not

**Locally accepted for the backend phase:** Optional-room geometry alignment and traversal, encounter ordering, frozen eligibility, server-owned gates, standalone optional boss spawning, higher-depth miniboss lineage, saved-session reconstruction tests, and local replay protection for boss/completion rewards.

**Limits:** Automated walking fixtures used assisted enemy defeats and elevated temporary player health; they do not prove normal-health solo or party balance through every required room. Session-service recreation with an in-memory adapter does not prove a real same-account Roblox network reconnect or a new reserved-server handoff. Depth 2–4 physical content is opted into local, unpublished Studio places only. No live high-depth content release, cloud acceptance, PROD publish, Robux change, real player DataStore modification or final authored art is implied.

**Guardrails retained:** Reuse accepted systems and placeholders. Do not reset or rewrite existing HUD, combat, party, Dungeon/Starting Base or historical roadmap work. Keep higher-depth and optional rollout flags disabled outside disposable tests. Develop code through GitHub first; run local builds and playtests in the existing Windows worktree. Preserve the pre-change rollback tag, accepted documentation and independently verified checkpoints.

## 3. Higher-depth party lifecycle — local acceptance and remaining gates

**Goal (local milestone accepted; external acceptance outstanding):** Extend existing multiplayer, disconnect, checkpoint and reward protections across fully integrated optional Depth 2–4 routes without creating a second encounter or event system. The local subset was completed in the dated evidence above; any actual same-account network rejoin or in-Play full-party wipe remains unverified.

1. **Admission and authoritative selection.** Prove 1-, 2- and 4-player session admission for selected Temple/Mine Depth 2 and Depth 4 cases. Confirm all members share one frozen run plan, difficulty, eligible Event/Secret selections, checkpoint and room state. Test Event-only, Secret-only, both selected and neither selected without rerolling on re-entry.
2. **Concurrent boss entry.** In Play mode, have two members approach the same Event/Secret trigger at nearly the same time. Assert exactly one server-owned boss encounter starts, a second touch cannot duplicate its spawn, the unrelated side gate remains correctly sealed, and skipping Secret never bypasses a required room.
3. **Disconnect, wipe and recovery.** Exercise one member disconnecting during Event and Secret while another remains, including a later party-member return to that still-live local session. Preserve the surviving party's progress and fail-closed eligibility. Simulate a full service/controller restart using disposable persisted storage, including a deferred Secret and an interrupted higher-depth miniboss; verify a single, retryable encounter and unchanged checkpoint. Keep true cross-server same-account reconnect as a separate cloud acceptance gate.
4. **Rewards and completion.** Verify per-member exactly-once optional boss and final completion rewards despite simultaneous touches, repeated clear notifications, disconnect/return and replayed completion requests. Verify that an ineligible player or a run without an issued boss cannot obtain its reward.
5. **Playable regression.** Re-run focused optional/difficulty/backend tests and at least one physical multiplayer route per dungeon at a higher depth. Preserve the six single-player walking receipts and the optional-disabled baseline rather than silently counting them as multiplayer proof.

**Exit evidence:** A dedicated dated test report with exact run IDs/log markers, expected vs actual session/encounter state, member-level reward receipts, all PASS/FAIL cases and unchanged rollout flags. Record a failing case accurately and fix the smallest responsible module before claiming milestone completion.

## 4. Subsequent backend and release sequence

**Next backend milestone:** Extend dynamic dungeon event variety and secret-boss insertion points through the existing server-owned issuance, catalog and encounter plan. Allow future event bosses and secrets without changing authored required-room chains; define eligibility windows, spawn/room slot capabilities, independent rewards, per-run frequency and recovery semantics, then test all combinations with disposable Studio runs.

**Later, when authorized:** Real same-account network reconnect and TEST cloud release verification; genuinely unassisted end-to-end party combat at representative depths; player-facing navigation/UX; authored environment modelling, meshes, animations, audio and final performance/low-end-device testing. None of these tasks should block the current backend-first workflow or be marked complete from the synthetic fixtures.

## 5. Operational handoff

Read `docs/ai/CURRENT_STATE.md`, `docs/ai/HANDOFF.md`, `docs/ai/TEST_MATRIX.md`, this v1.48 update and the three linked test reports before further code changes. Start with a read-only `git status`, current branch/HEAD and source-test inventory; apply the REUSE → VARIANT → NEW ASSET principle only if visual assets become necessary. Work in `wip/phase-4-test-hud-integration-v1`; do not force-push, merge, publish or change player profiles as a side effect of local acceptance tests. Update the test matrix and this roadmap only after verified evidence.
