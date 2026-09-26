# Human Wizard level-30 backend v3.08 — GREEN evidence

Date: 26 September 2026

## Result

**GREEN for the Human Wizard / Emberweaver level-30 backend skill catalogue.**

Human Wizard now resolves **93/93 source learning rows** through level 30 with
no Human Wizard explicit gaps. Companion source families 1111, 1126, 1127 and
1225 are mapped to independently named DungeonMMO skills and are available
through server-owned cast/companion authority.

## Focused Studio acceptance

The following source-cast suites were executed individually in the unpublished
Dungeon Studio place to avoid the previous single-request runner timeout:

1. C4OwnedPassiveSourceResolverTest
2. C4UnifiedStatReferenceTest
3. C4ResourceMigrationBoundaryTest
4. C4SkillRuntimeRulesTest
5. C4SourceCastContractServiceTest
6. C4SourceCastResourceServiceTest
7. C4SourceCastTimingServiceTest
8. C4SourceCastSchedulerServiceTest
9. C4SourceDirectMagicCastServiceTest
10. C4SourcePeriodicMagicCastServiceTest
11. C4SourceCompanionServiceTest
12. C4SourceCompanionCastServiceTest
13. C4SourceCastRuntimeCompositionTest
14. C4HumanWizardStagedCastIntegrationTest
15. C4SourceCombatCalculationServiceTest
16. C4SourceCombatExecutorTest
17. C4NpcElementalVulnerabilityServiceTest
18. C4DungeonSourceCastRuntimeTest

Result: **18/18 PASS**.

## Expanded backend regression

The expanded Human Wizard backend set was then run suite-by-suite across Core,
Combat and Dungeon tests.

Result: **39/39 PASS**.

Important focused outputs included:

- `[Human Wizard Foundation] PASS: 199 assertions`
- `[C4 Companion Service] PASS: 9 assertions`
- `[C4 Companion Cast] PASS: 6 assertions`
- `[C4 Cast Runtime Composition] ... 3 assertions ...`

Two stale aggregate tests were found during the first expanded pass. They still
expected the pre-companion source-link totals of 528 candidates / 41 gaps.
After updating those assertions to the actual post-companion inventory,
**569 total / 547 candidates / 22 explicit gaps**, the complete 39-suite pass
was rerun and was green.

## Genuine Play rehearsal

An unpublished Dungeon Play server was started with a real connected player.
The production companion service was instantiated with deterministic test
inventory/source-plan providers while retaining the service's real default
Workspace model factory and replication path.

Observed server result:

- summon succeeded;
- source NPC ID: **12006**;
- creative role: **Mana**;
- initial source reagent count: **3**;
- Servitor Heal: HP **35 -> 100**;
- Servitor Recharge: MP **20 -> 61**.

A separate client-side check confirmed the companion Model, Humanoid,
HumanoidRootPart, source NPC ID and role had replicated.

Final server cleanup returned `cleared=true` and `active=false`, followed by
a clean Play stop.

## Scope note

The skill catalogue and companion lifecycle are complete through level 30.
The summon Model remains an intentional backend placeholder with
`C4SourceNpcStatsPending=true`; final companion art and reviewed source NPC
combat templates/AI are separate creature-content work and were not invented
for this skill gate.

No main merge, publish or production save mutation was performed.
