# Human Wizard Exact Source Reuse v2.98 — Acceptance

Date: 25 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.

## Result

**GREEN — exact Human Wizard magical reuse now reaches the authenticated cast
timing plan through actually-owned source passive state.**

## Candidate

`764a9219463ca4512d3c047b2f33ea60a402a035`.

## Owned passive mapping

The owned-passive resolver now proves a level-30 Emberweaver that actually owns
`EmberweaverQuickWeave` rank 2 resolves source skill 164 rank 2.

Marker:

`[C4 Owned Passives] SOURCE_ONLY_PASS: 8 assertions
ownership=true inherited=true live=false`.

No level-based free ownership is introduced.

## Source stat calculator

The neutral source calculator includes:

- `MAGICAL_SKILL_REUSE=1`;
- `PHYSICAL_SKILL_REUSE=1`;
- `SKILL_MASTERY=0`.

Quick Recovery then applies its exact source multiplier:

- rank 1 -> **0.8**;
- rank 2 -> **0.75**.

A level-20 Emberweaver cannot claim rank 2.

Unified source marker:

`[C4 Unified Stats] SOURCE_ONLY_PASS: 42 assertions paths=10 live=false`.

## Authenticated resource boundary

The complete source boundary now includes Human Wizard in its ten-path vitals
coverage and proves an owned Quick Recovery rank 2 reaches:

- `SourceStatCandidate.MAGICAL_SKILL_REUSE == 0.75`;
- `SourceStatCandidate.SKILL_MASTERY == 0`;
- `CutoverPrerequisitesReady == true`;
- zero activation blockers.

Marker:

`[C4 Resource Boundary] SOURCE_ONLY_PASS: 52 assertions
paths=10 prerequisites=true live_cutover=false blockers=0`.

## Cast timing

The source timing service now consumes authenticated reuse/mastery values rather
than a neutral diagnostic assumption.

For Ember Bolt rank 6 at M.Atk.Spd 333:

- reuse 1.0 -> **6000 ms** final reuse;
- reuse 0.75 -> **4500 ms** final reuse.

At M.Atk.Spd 666 and neutral reuse:

- final reuse -> **3000 ms**.

When source mastery is zero, final reuse is ready. A synthetic nonzero mastery
value remains blocked by
`OriginalSkillMasteryRollNotIntegrated`.

Marker:

`[C4 Source Cast Timing] SOURCE_ONLY_PASS: 17 assertions
hit=true cool=true shots=peek reuse=true mastery=blocked live=false`.

## Expanded Human Wizard focus

The focused runner now includes the passive/stat/resource dependencies needed
for reuse, rather than testing only cast-local services.

Fresh combined result:

`[Human Wizard Source Cast] RESULT passed=8 total=8`.

Individual fresh suites:

- owned passives: **8**;
- unified stats: **42**;
- resource boundary: **52**;
- runtime rules: **19**;
- cast contract: **11**;
- split-MP lifecycle: **12**;
- cast timing: **17**;
- source combat: **43**.

## Stale fixture correction

The first expanded run found the older positive Heavy Armor Mastery fixture was
body-only.

Current accepted source equipment semantics correctly require matching
chest+legs unless the chest is FullArmor, so its expected +17.7 P.Def did not
apply. Diagnostic output showed expected 112.7 and actual 95.0.

The positive Heavy fixture now equips Heavy legs and the positive Light fixture
equips Light legs. The source equipment-condition implementation itself was not
changed.

The final rerun passed all eight focused suites.

## Build/static acceptance

- `git diff --check`: PASS;
- Base Rojo build: PASS;
- Dungeon Rojo build: PASS.

The only local untracked paths remain the pre-existing quadruped-animation
Python `__pycache__` directories. They were not edited or committed.

## Boundary

This gate does not schedule a live cast, consume a shot or apply source damage.
The next gate is a private server-owned cast scheduler using the now-complete
Human Wizard split-MP and final timing/reuse contracts.
