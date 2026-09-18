# Phase 4 Studio Difficulty Parity - Implementation Plan

**Baseline:** `5fb3491`
**Branch:** `wip/phase-4-studio-difficulty-parity-v1`

## Task 1 - RED

Extend StudioSessionFactory tests to request Depth2 and require the selected
difficulty to reach session creation, InstanceState and routing data.

Capture RED before implementation.

## Task 2 - Factory propagation

Add optional difficulty_id to StudioSessionFactory.create_for_players.

Pass it to session creation and DungeonInstanceDirector.resolve.

Include DifficultyId in synthetic routing data, including reused sessions.

## Task 3 - Runtime integration

After environment readiness, read the authoritative
DungeonMMOResolvedDifficultyId and pass it to StudioSessionFactory.

## Task 4 - Acceptance

Run focused tests, repository parse, all four Rojo builds, Base/Dungeon
regressions and source-boundary audit.

Update continuity docs and close locally.

Do not enable higher depths, push, merge or publish.
