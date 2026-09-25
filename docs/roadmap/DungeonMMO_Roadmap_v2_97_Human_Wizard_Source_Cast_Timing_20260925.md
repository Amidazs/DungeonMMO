# DungeonMMO Roadmap v2.97 — Human Wizard Source Cast Timing

Date: 25 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v2.96](
DungeonMMO_Roadmap_v2_96_Human_Wizard_Source_Cast_Authority_20260925.md).

## Status

**GREEN — final source magic hit/cool timing and shot acceleration are now
planned server-side without consuming shots early. Final reuse remains
deliberately fail-closed.**

Acceptance:
[Human Wizard source cast timing v2.97](
../testing/c4-human-wizard-source-cast-timing-v2-97-20260925.md).

## Pinned source behaviour

The pinned Chronicle 4 source confirms this cast order:

1. scale authored `hitTime` with final M.Atk.Spd;
2. scale authored `coolTime` with the same M.Atk.Spd;
3. when Spiritshot or Blessed Spiritshot is charged, multiply both by 70%;
4. apply the 500 ms minimum to `hitTime` only;
5. set the interrupt window to half of final hit time;
6. calculate reuse separately from authored `reuseDelay`, the final
   `MAGICAL_SKILL_REUSE` multiplier and M.Atk.Spd.

The existing source runtime helpers now cover the missing cool/reuse arithmetic.

## New timing planner

`C4SourceCastTimingService` combines:

- the exact server-owned cast contract;
- the authenticated source stat boundary;
- final `MAGICAL_ATTACK_SPEED`;
- read-only source shot charge state;
- pinned source hit/cool timing rules.

The service never consumes a shot. It only snapshots the current charge state.

### Rank-six Ember Bolt

At M.Atk.Spd 333 and no shot:

- authored hit time: **4000 ms**;
- final hit time: **4000 ms**;
- interrupt window: **2000 ms**;
- authored reuse: **6000 ms**;
- neutral/unmodified reuse diagnostic: **6000 ms**.

With Spiritshot or Blessed Spiritshot charged:

- final hit time: **2800 ms**;
- interrupt window: **1400 ms**;
- the charge remains present after planning.

### Frost Lance cool-time proof

`EmberweaverFrostLance` rank 2 resolves source Ice Bolt rank 6.

At M.Atk.Spd 333 with Spiritshot:

- authored hit time: **3100 ms**;
- final hit time: **2170 ms**;
- interrupt window: **1085 ms**;
- authored cool time: **200 ms**;
- final cool time: **140 ms**.

The 500 ms hit-time floor is correctly not applied to cool time.

## Reuse remains fail-closed

The source reuse formula is now represented exactly:

`floor(floor(authoredReuse * reuseMultiplier) * 333 / attackSpeed)`.

However, the authenticated source stat candidate does not yet expose the final
`MAGICAL_SKILL_REUSE` multiplier.

Human Wizard source skill 164, Quick Recovery, is already recorded as a passive
source modifier, so assuming a multiplier of 1 would silently ignore an owned
class passive.

Therefore the timing planner returns:

- `FinalReuseDelayReady=false`;
- blocker: `OriginalSkillReuseRateNotIntegrated`;
- only an explicitly labelled unmodified reuse diagnostic.

This keeps live cooldown scheduling closed rather than guessing.

## Fresh verification

Accepted candidate:

`3c2984a0c30034a3a71ba36fe709a12d6a3f34f6`.

Fresh results:

- `git diff --check`: PASS;
- Base Rojo build: PASS;
- Dungeon Rojo build: PASS;
- source runtime rules: **19 assertions PASS**;
- source cast contract: **11 assertions PASS**;
- split-MP resource lifecycle: **12 assertions PASS**;
- source timing planner: **14 assertions PASS**;
- source combat calculation: **43 assertions PASS**;
- Human Wizard source-cast focused runner: **5/5 PASS**.

## Safety boundary

v2.97 does **not**:

- consume source shot charges during timing planning;
- invent a final reuse multiplier;
- start a live cast timer;
- start a live cooldown;
- apply source spell damage;
- expose source cast authority to clients;
- enable source combat by default;
- implement companion/servitor rows.

## Next implementation

Close the reuse blocker from actual owned source passives.

The next slice should:

1. add neutral `MAGICAL_SKILL_REUSE=1` to the source stat calculator input;
2. let the existing owned-passive pipeline apply Human Wizard Quick Recovery
   rank 1/2 at its exact source values;
3. expose the resulting multiplier through the authenticated source stat
   candidate;
4. update the timing planner to calculate final reuse only when that multiplier
   is present and valid;
5. prove rank 1 and rank 2 reuse values from the owned creative
   `EmberweaverQuickWeave`;
6. retain fail-closed behaviour for missing/corrupted reuse state.

Only after final reuse is source-ready should a real cast scheduler be built.

No `main` merge, Roblox publish, production DataStore mutation or animation
work.
