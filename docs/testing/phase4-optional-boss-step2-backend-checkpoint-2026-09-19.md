# Phase 4 Event and Secret Boss: Step 2 Backend Checkpoint

Date: 19 September 2026
Branch: wip/phase-4-event-secret-policy-v1
Validated gameplay/test source: ae1ab32be03fe5c2ff9874f95df49a8c56ff069a
Status: BACKEND CANDIDATE VERIFIED IN STUDIO EDIT MODE; NOT A GAMEPLAY RELEASE.

## GitHub-first handoff

- The previous uncommitted Step 2 work was saved and pushed intact at bd83446.
- Subsequent test, gameplay-rule and test-runner edits were committed directly
  through the Amidazs GitHub connection.
- The existing isolated Windows backend worktree was fast-forwarded to ae1ab32.
  Its status was clean at validation. Main and the UI/art worktrees were not
  merged or changed; no Roblox place was published.

## Implemented candidate

- Server-only opt-in hourly 20-minute event windows, Temple at minute 00 UTC
  and Mine at minute 30 UTC; explicit valid windows override the schedule.
- Entry-frozen deterministic secret eligibility, default proof chance 5%
  when independently enabled; existing explicit server chance is retained.
- An eligible hidden route requires an active, connected session member near
  its physical trigger after earlier encounters have resolved. The server
  persists discovery for reconnect and rejects an invalid saved next encounter
  or a skipped required predecessor.
- Each optional boss has an explicit 2% Arc Slash book drop definition and a
  unique encounter reward identity, distinct from the ordinary final boss.
  Existing reward history prevents replay after save/reload.
- The optional-secret direct-successor skip remains available without a boss
  reward. No profile schema, artwork or physical layout was changed.

## Reproducible verification

- Four Rojo compositions PASS at ae1ab32: default, base, published-dungeon
  and published-base. All builds are local files, not game publishing.
- All 544 source .lua/.luau files parsed using luau-compile --null, zero failures.
- The source-controlled Studio command-line runner is
  scripts/studio/optional_boss_focused_tests.luau. Against a TEMP local
  Dungeon .rbxl at ae1ab32, the fresh Studio log recorded PASS for all eight
  focused edit-mode suites: RunState, Schedule, SecretDiscovery, Policy, Flow,
  Factories, ReleaseLock and Reward.
- Local Studio evidence log:
  C:/Users/Remko/AppData/Local/Roblox/logs/
  0.739.0.7390687_20260919T163504Z_Studio_4F79C_last.log
  Final marker: [Optional Boss Studio Focus] PASS: 8 edit-mode suites.
- The first edit-mode runner returned a false failure after the assertions
  passed because a cloned ModuleScript did not return a value; this was
  corrected before the eight-suite rerun. The Studio process exit code alone
  is not the pass criterion; check the final log marker.

## Remaining acceptance gates

Edit-mode tests do not prove the live server/client Play environment or
physical dungeon navigation and reward UI. A separate TEMP-only live gameplay
test is still required for entry windows, discovery triggers, skip, combat,
rewards, reconnect and final completion. Run broad Base/Dungeon Play-mode
regressions again after the final gameplay wiring is exercised.

OptionalBossRuntimeEnabled remains false for Temple and Mine; both Depth1
optional side arenas are absent and higher-depth physical layouts remain
unregistered. Do not enable rollout, merge this branch into main or publish
without the distinct physical and live-play acceptance gates.

Next backend-only work after live regression: independently design and test
distinct Event/Secret boss combat behaviours while reusing the accepted
executor, encounter controller and reward authority. Physical arenas and art
remain a separate content gate.
