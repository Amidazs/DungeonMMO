# DungeonMMO Roadmap v2.98 — Human Wizard Exact Source Reuse

Date: 25 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v2.97](
DungeonMMO_Roadmap_v2_97_Human_Wizard_Source_Cast_Timing_20260925.md).

## Status

**GREEN — Human Wizard final magical reuse now comes from the authenticated
owned source passive/stat pipeline rather than a neutral placeholder.**

Acceptance:
[Human Wizard exact source reuse v2.98](
../testing/c4-human-wizard-source-reuse-v2-98-20260925.md).

## Reuse stat integration

The source stat calculator now begins with the C4-neutral values:

- `MAGICAL_SKILL_REUSE = 1`;
- `PHYSICAL_SKILL_REUSE = 1`;
- `SKILL_MASTERY = 0`.

These are calculator inputs, not automatic bonuses. Actually-owned source
passives still have to be resolved and applied in normal calculator order.

## Human Wizard Quick Recovery

Creative `EmberweaverQuickWeave` is now proven through the complete ownership
pipeline:

- owned creative rank 1 -> source skill 164 rank 1 -> reuse multiplier **0.8**;
- owned creative rank 2 -> source skill 164 rank 2 -> reuse multiplier **0.75**;
- level 20 cannot borrow source rank 2;
- level 30 rank 2 reaches the authenticated
  `C4ResourceMigrationBoundary.SourceStatCandidate`.

The source candidate also carries `SKILL_MASTERY = 0` for this launch scope.

## Final reuse timing

`C4SourceCastTimingService` now reads three authenticated source stats:

- `MAGICAL_ATTACK_SPEED`;
- `MAGICAL_SKILL_REUSE`;
- `SKILL_MASTERY`.

Final reuse is calculated from the pinned source order:

`floor(floor(authoredReuse * reuseMultiplier) * 333 / magicAttackSpeed)`.

For rank-six Ember Bolt at M.Atk.Spd 333:

- neutral reuse 1.0 -> **6000 ms**;
- Quick Recovery rank 1 at 0.8 -> **4800 ms**;
- Quick Recovery rank 2 at 0.75 -> **4500 ms**.

At M.Atk.Spd 666 with neutral reuse, final reuse is **3000 ms**.

When `SKILL_MASTERY == 0`, the calculated reuse is final. A nonzero mastery
stat still fails closed behind
`OriginalSkillMasteryRollNotIntegrated` rather than guessing the mastery
result.

## Ten-path source coverage

Human Wizard is now included in the unified source-stat and resource-boundary
launch regressions.

Current source-path coverage in those tests is **10 paths**, including
Emberweaver level-30 base vitals:

- HP: **705**;
- MP: **492**;
- CP: **355**.

## Focused validation

Accepted candidate:

`764a9219463ca4512d3c047b2f33ea60a402a035`.

Fresh results:

- `git diff --check`: PASS;
- Base Rojo build: PASS;
- Dungeon Rojo build: PASS;
- owned passive source resolver: **8 assertions PASS**;
- unified source stats: **42 assertions PASS**;
- resource migration boundary: **52 assertions PASS**;
- source runtime rules: **19 assertions PASS**;
- source cast contract: **11 assertions PASS**;
- source split-MP lifecycle: **12 assertions PASS**;
- source cast timing: **17 assertions PASS**;
- source combat calculation: **43 assertions PASS**;
- Human Wizard focused runner: **8/8 PASS**.

## Regression correction discovered during the wider focused run

The expanded Human Wizard runner exposed one stale legacy test fixture.

The Heavy Armor Mastery test equipped only a Heavy chest, but the already
accepted C4 equipment-condition implementation requires either:

- matching Heavy chest and Heavy legs; or
- a FullArmor chest.

The test therefore correctly produced no mastery bonus. The fixture was fixed
to equip matching legs, and the Light Armor positive fixture was corrected the
same way. Production equipment semantics were not weakened.

## Safety boundary

v2.98 does **not**:

- roll source skill mastery;
- start a live cast scheduler;
- start live source cooldowns;
- consume shots from the timing planner;
- apply Human Wizard source spell damage from ordinary client casting;
- enable source combat by default;
- implement companion/servitor rows.

## Next implementation

The next gate is a private server-owned cast scheduler.

It should:

1. begin the already accepted split-MP transaction;
2. capture the exact timing plan and private cast receipt;
3. set a server-owned launch deadline from `FinalHitTimeMs`;
4. reject replay, overlap, rank/class/source-cutover changes and cancellation;
5. commit the launch-time MP spend only after the deadline;
6. return one immutable launch payload suitable for the existing source combat
   executor;
7. keep shot consumption and actual damage as separate later gates.

No `main` merge, Roblox publish, production DataStore mutation or animation
work.
