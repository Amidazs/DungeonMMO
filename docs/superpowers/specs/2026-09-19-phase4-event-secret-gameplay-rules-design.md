# Phase 4 Event and Secret Gameplay Rules
Status: implementation candidate under the user's autonomous step-2 instruction.
Baseline: cb29a7c; preserve uncommitted step-1 evidence.
This is a bounded extension of existing issuance, encounter and reward authority,
with a written contract because scheduling, discovery and reward validation interact.

## Intent and decisions
Provide repeatable server event windows and a discoverable optional side route,
without enabling production content or requiring final art.
Use existing service boundaries and session InstanceState; no profile schema change.
User requested visual playtests as well as backend tests and checkpoint reporting.

Server-only rules: opt-in hourly 20-minute windows, Temple at minute 00 and Mine at
minute 30 UTC. Both scheduling and secret-route defaults are disabled unless their
server settings are enabled, independently of the unchanged dungeon release lock.
These are candidate proof timings, not a live-operations commitment.
Explicit start/end server overrides retain precedence and invalid overrides fail
closed rather than reverting to a recurring window. Snapshot the selected window
at entry; reconnect never reschedules an existing session.
Opt-in secret routes use the existing deterministic per-session roll (5% proof
default, server override retained). Eligibility reserves a side-room encounter;
actual discovery requires an active connected member to reach that room's server
trigger after preceding encounters are resolved. Check distance to the trigger's
bounds, not client-reported coordinates. Persist discovery in InstanceState.
The existing direct-successor skip remains valid and gives no boss reward.

Keep existing boss XP/gold and depth scaling. Configure each optional boss as an
explicit 2% Arc Slash book source, matching ordinary boss proof tuning. Books remain
personal, cross-class receivable, tradable and duplicate-eligible. No exclusive item
or reward rebalance. Use RewardService history for replay/save/reload protection.
Ensure optional boss reward identities differ from the final boss and each other;
current Captain-derived EnemyId is shared, so prove this defect RED before fixing.

## Alternatives
A live admin scheduler or dynamic post-entry encounter insertion would add authority
and recovery complexity without improving this proof. Reuse server attributes and
entry-frozen optional plans. Discovery records entry into the eligible side route;
it does not reroll or insert a new encounter after entry.

## Validation
Test schedule boundaries, opt-in/rollout rejection, malformed settings, dungeon
separation and frozen sessions. Test discovery membership, life state, distance,
order, eligibility, replay, persisted reload and failed writes.
Test named boss drop configuration and distinct encounter reward transactions
through actual executor/factory/EncounterService/RewardService paths.
Run all four Rojo builds, parse, Base/Dungeon Studio regressions and stress.
Visually test normal Base/Dungeon and TEMP-only optional rooms with real movement,
boss HUD/combat, discovery and completion/rewards. Record debug assistance explicitly.
Do not interpret fixture success as authored physical-content release acceptance.
