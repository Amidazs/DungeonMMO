# Support threat: eligible engagement follow-up

Date: 21 September 2026
Feature branch: `wip/phase-4-test-hud-integration-v1`
Tested source head: `b569435c9eb3cd4971eec06ca1baeeb4f17f4a09`

## Runtime correction

The server-owned ThreatService now requires positive threat belonging
to an **eligible current target candidate** before an enemy receives
support threat. A stale entry for a dead, absent or otherwise
ineligible former target cannot activate support aggro by itself.
The caster and recipient must also both be eligible for that enemy.

The focused contract adds an otherwise-empty enemy ledger with
50 threat from an absent player. Effective support must not engage
it. A genuine new positive ledger entry from an eligible player
then permits support threat on that enemy, independently of others.

## Fresh unpublished local evidence

At exact source head `b569435c9eb3cd4971eec06ca1baeeb4f17f4a09`:

- All six Rojo compositions built successfully.
- Focused ThreatService Studio test: **51 assertions PASS**, runner
  `RESULT passed=1 total=1 failed=0`.
- Existing real two-client ordinary Marauder support fixture:
  `VERIFIED_MULTIPLAYER_PASS` (MageHeal, real NPC Ward absorption
  and Fighter Mend paths from the earlier accepted fixture).
- Existing real two-client ordinary Marauder aggro fixture:
  `VERIFIED_MULTIPLAYER_PASS`.
- `git diff --check` passed in the clean feature worktree.

The isolated world-boss aggro fixture was also attempted at this
head but its Studio process did not complete within the 110-second
outer timeout. No `VERIFIED_MULTIPLAYER_PASS` was captured from
that rerun. The test process was stopped and only its three
identified orphan Studio test children were terminated.
This is a **pending current-head boss regression**, not a demonstrated
combat failure or a fresh pass. The earlier accepted world-boss
aggro fixture applies to its earlier tested source.

## Remaining gates

Run the isolated world-boss aggro and real boss support-skill
fixtures in a clean unpublished Studio session, allowing the
fixture's own global timeout and inspecting server/client logs.
Then exercise four real players, multiple simultaneous enemies,
full-party wipe/reset and controller-level disconnection.
Do not publish, merge to main or perform cloud persistence tests
without separate approval. All source and document edits stay
in GitHub.
