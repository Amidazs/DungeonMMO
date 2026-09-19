# Phase 4 TEST Temple placeholder publishing preflight — 19 September 2026

**Status: local candidate validated. NOT PUBLISHED to Roblox.**

Universe 10765241947; existing TEST Temple/Dungeon place 117293035754309; existing TEST Lobby place 134132328219009. No Mine place was created. Branch: wip/phase-4-event-secret-policy-v1.

## Progress and rollback safety

All previous work remains in the GitHub commit history. The source-only pre-release checkpoint f3cf77981c6dbae7767109370feaf540502e52a3 is additionally preserved at the pushed tag phase4-pre-test-placeholder-release-20260919. **The Git tag does not back up the currently published Roblox place, its authored geometry or its DataStores.** A separate authenticated Studio Save to File backup of the existing cloud TEST Dungeon, and its Roblox Version History version ID, remain necessary before publishing.

No main merge, force-push, cloud place publish, cloud rollback verification, paid revive enablement, PROD DataStore mutation or unrelated place modification was performed in this preflight.

## Release candidate and local proofs

The TEST-only placeholder source registers Temple Depth1 (3 normal rooms plus Event and Secret side arenas) and Depth2, 3 and 4 (4, 5 and 6 rooms). Depth1 Event/Secret practice eligibility is always server-issued in the exact allowlisted TEST Dungeon; Depth2–4 deliberately do not inherit optional-boss eligibility. The Mine is not enabled or redirected. All other places fail closed.

The full Temple place candidate is built from test-temple-publish.project.json. Its TEST environment attribute and exclusion of Tests scripts passed inspection. A Creator callback-destroyed error occurred during shutdown of that static inspector *after its assertions passed*; do not call that static run zero-error.

The sync-only TEST Lobby project is test-lobby-sync.project.json. Its standalone local build intentionally omits cloud DungeonMMOEnvironment and DungeonMMODungeonPlaceId attributes: they must be preserved on the **existing cloud lobby**, not overwritten with this local build. A separate lobby sync inspection passed Base/Core module and no-test-script checks.

Crucially, the exact full TEST Temple candidate (not only the development build) passed both disposable unpublished Studio place-ID simulations:

- Depth1: EventArena, SecretArena and bridges/anchors existed; a real local Studio player spawned into an active session and both optional encounters were eligible. Marker: [Phase4 TEST Depth1] VERIFIED_PUBLISHED_STYLE_PASS (22:11 UTC Studio run, 19 September).
- Depth4: Temple Depth1–4 catalogue/ready registration, six physical room checkpoints/triggers and matching spawn anchors, server event/secret schedule and player spawn passed, without the earlier OptionalBossContentUnavailable startup failure. Marker: [Phase4 TEST Publish] VERIFIED_DEPTH4_PUBLISHED_STYLE_PASS (22:12 UTC Studio run, 19 September).
- 11/11 focused optional-boss edit-mode suites passed; four Rojo compositions built; 551 source files and 41 Studio runners compiled, zero failures. The preflight local Git worktree was clean. Latest tested candidate source commit before this documentation: 091a3241f3d0361be4bb7a77a558c5a548c3b406.
- Previous Temple/Mine optional fight/skip/walk, higher-depth assisted run, combat, reward, multiplayer, revive and UI evidence remains in docs/testing/phase4-placeholder-playable-layouts-closeout-2026-09-19.md and docs/testing/phase4-independent-gameplay-qa-2026-09-19.md. Assisted progression tests are NOT normal player victory or a published cross-server validation. Scripted normal-health Mine boss trials failed (Mine not in this release).

## Cloud handoff: DO NOT skip rollback backup

In authenticated Studio first open the CURRENT CLOUD Dungeon place 117293035754309 and save a dated local backup using File > Save to File. Record the current Roblox version ID in Creator Dashboard Version History:
https://create.roblox.com/dashboard/creations/experiences/10765241947/places/117293035754309/version-history

After confirming the backup exists and belongs to that exact published place, prepare/open the candidate using scripts/powershell/Start-Phase4TestTemplePublish.ps1. In the local candidate use File > Publish to Roblox As, choose experience 10765241947, existing Dungeon place 117293035754309 and Overwrite; verify the destination place ID and Studio PublishSuccessful. Do NOT choose Starting Base 134132328219009, create a new place, publish to PROD, or use the geometry-only blockout scene as the game place.

Then open the CURRENT CLOUD Starting Base 134132328219009 in authenticated Studio and use Rojo with test-lobby-sync.project.json to sync code into that existing cloud place without overwriting its authored map or cloud attributes. Check DungeonMMOEnvironment=TEST and DungeonMMODungeonPlaceId=117293035754309 before publishing the existing cloud Base. Dungeon must be published first. Verify the full lobby-to-Temple teleport and difficulty selection, event/secret routes and reward state in Roblox TEST.

No safe connected GUI/authorized authenticated publish control was available in the assistant session; **none of those cloud handoff actions has been confirmed completed**. Do not claim the candidate is published or that the cloud rollback was saved without direct Roblox version-history/Studio evidence. Once completed record the TEST published Roblox version IDs and live tests in this document.
