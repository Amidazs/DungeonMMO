## 26 September 2026 — CURRENT v3.01 big Wizard validation pending

[Roadmap](
../roadmap/DungeonMMO_Roadmap_v3_01_Human_Wizard_Targeted_Cast_Batch_20260926.md);
[pending validation](
../testing/c4-human-wizard-targeted-cast-batch-v3-01-pending-20260926.md).
Human Wizard v3.01 is now a larger **validation-pending**
backend batch. The staged server runtime covers three pure targeted direct
spells (Ember Bolt, Flame Burst and Focused Bolt) plus targeted Venom Hex
poison. Non-elemental C4 MDAM now resolves neutrally, exact cast/effect ranges
flow through contract -> timing -> scheduler -> bridge, and hit-time range
revalidation happens before launch MP/shot/effect execution. A real
cross-service staged integration test and source-cast runtime composition test
were added. Tomorrow's prepared runners are **14 cast-focused suites** and a
**32-suite big backend pass** spanning progression, source data, stats,
resources, scheduler, damage dispatch, ManaService and contribution/quest
bookkeeping. No local/Studio tests were run tonight; v2.99 remains the last
fully green baseline.

Primary tomorrow runner:
`scripts/studio/c4_human_wizard_big_backend_focus.luau` (**32 suites**).
Secondary cast runner:
`scripts/studio/c4_human_wizard_source_cast_focus.luau` (**14 suites**).

## 26 September 2026 — CURRENT v3.00 direct MDAM bridge pending validation

[Roadmap](
../roadmap/DungeonMMO_Roadmap_v3_00_Human_Wizard_Direct_MDAM_Bridge_20260926.md);
[pending validation](
../testing/c4-human-wizard-direct-mdam-bridge-v3-00-pending-20260926.md).
Human Wizard v3.00 direct-MDAM handoff is now implemented in
GitHub but deliberately **not marked green yet** because local/Studio access is
off tonight. The new bridge is default-off, accepts only
`EmberweaverEmberBolt`, binds one reviewed NPC at cast start, revalidates that
same target before launch-time MP, then hands the scheduler payload to the
existing source executor. Shot consumption remains owned by the existing source
calculation layer, so the bridge cannot double-consume it. Dungeon runtime now
composes the source cast services and clears cast/scheduler/shot state on player
departure. The Human Wizard focused runner has been expanded to **11 suites**.
Tomorrow's first task is fresh diff/build/Studio validation; v2.99 remains the
latest fully validated point until that passes.

When local/Studio access returns, run the 11-suite
`c4_human_wizard_source_cast_focus.luau` before any live player rehearsal.

## 25 September 2026 — CURRENT v2.99 Human Wizard source scheduler

[Roadmap](
../roadmap/DungeonMMO_Roadmap_v2_99_Human_Wizard_Source_Cast_Scheduler_20260925.md);
[evidence](
../testing/c4-human-wizard-source-cast-scheduler-v2-99-20260925.md).
Human Wizard source casts now have a private server-owned
scheduler that bridges exact timing/reuse to the existing split-MP launch
boundary. It records interrupt/hit/finalizer/reuse deadlines, rejects early or
replayed launches, preserves reuse after cancellation, blocks overlap, and
clears stale authority receipts exactly once. A successful deadline commit is
marked `ReadyForSourceEffectExecution=true` while still
`LiveDamageIntegrated=false` and `ShotStateConsumed=false`. Fresh scheduler
**15 PASS**, full Human Wizard source-cast runner **9/9 PASS**, Base/Dungeon
builds and diff check PASS. Next gate: one disabled-by-default direct-MDAM
scheduler-to-source-executor handoff with exact one-use magical shot
consumption at hit time.

Use `c4_human_wizard_source_cast_focus.luau` for the complete nine-suite
Human Wizard cast/scheduler dependency chain.

## 25 September 2026 — CURRENT v2.98 Human Wizard source reuse

[Roadmap](
../roadmap/DungeonMMO_Roadmap_v2_98_Human_Wizard_Source_Reuse_20260925.md);
[evidence](
../testing/c4-human-wizard-source-reuse-v2-98-20260925.md).
Human Wizard final source reuse now flows through the
actually-owned passive pipeline. `EmberweaverQuickWeave` rank 1/2 resolves
Quick Recovery 164:1/2, producing exact magical reuse multipliers **0.8/0.75**
in the authenticated source stat candidate. Rank-6 Ember Bolt at M.Atk.Spd 333
therefore resolves **6000 ms** neutral, **4800 ms** with rank 1 and **4500 ms**
with rank 2; zero source mastery makes that reuse final, while nonzero mastery
still fails closed. Human Wizard is now included in unified/resource
**10-path** coverage. Fresh owned-passive **8 PASS**, unified stats **42 PASS**,
resource boundary **52 PASS**, runtime rules **19 PASS**, cast contract **11
PASS**, split-MP **12 PASS**, timing **17 PASS**, source combat **43 PASS**,
focused runner **8/8 PASS**, Base/Dungeon builds PASS. Next: private
server-owned cast scheduler; no live damage or shot consumption yet.

Use `c4_human_wizard_source_cast_focus.luau` for the complete eight-suite
Human Wizard cast/reuse dependency chain.

## 25 September 2026 — CURRENT v2.97 Human Wizard source timing

[Roadmap](
../roadmap/DungeonMMO_Roadmap_v2_97_Human_Wizard_Source_Cast_Timing_20260925.md);
[evidence](
../testing/c4-human-wizard-source-cast-timing-v2-97-20260925.md).
Human Wizard source timing now uses authenticated final
M.Atk.Spd and read-only Spiritshot/Blessed Spiritshot state. Rank-6 Ember Bolt
is 4000 ms / 2000 ms interrupt uncharged and 2800 ms / 1400 ms with either
magic shot; Frost Lance proves 200 ms authored cool time becomes 140 ms with
Spiritshot and does not inherit the hit-time 500 ms floor. Source reuse
arithmetic is implemented, but final reuse deliberately remains blocked by
`OriginalSkillReuseRateNotIntegrated` rather than ignoring Quick Recovery.
Fresh runtime-rules **19 PASS**, cast-contract **11 PASS**, split-MP **12
PASS**, timing **14 PASS**, source-combat **43 PASS**, combined runner **5/5
PASS**, Base/Dungeon builds PASS. Next integrate actual owned
`MAGICAL_SKILL_REUSE` into the authenticated source stat candidate.

Use `c4_human_wizard_source_cast_focus.luau` for later timing/reuse changes.

## 25 September 2026 — CURRENT v2.96 Human Wizard source cast authority

[Roadmap](
../roadmap/DungeonMMO_Roadmap_v2_96_Human_Wizard_Source_Cast_Authority_20260925.md);
[evidence](
../testing/c4-human-wizard-source-cast-authority-v2-96-20260925.md).
Human Wizard cast authority now preserves exact source
`mpInitialConsume`, `mpConsume`, hit/reuse metadata and ranges from the
server-owned purchased rank. The new split-MP lifecycle requires active source
resource cutover, checks the full source cost before start, spends only the
initial charge at cast start, leaves it spent on interruption, revalidates
class/rank authority, and spends the launch charge only on commit. Rank-6
Ember Bolt proves **6 + 21 = 27 MP** with exact **4000 ms** authored hit time
and **6000 ms** reuse metadata. Fresh cast-contract **11 assertions PASS**,
resource lifecycle **12 PASS**, source combat **43 PASS**, focused runner
**3/3 PASS**, Base/Dungeon builds PASS. Live damage/timer/cooldown remain
disabled; next add final cast-time/reuse planning using source M.Atk.Spd and
charged shot state.

Use `c4_human_wizard_source_cast_focus.luau` for subsequent cast-authority
changes; avoid repeating unrelated combat-cutover rehearsals.

## 25 September 2026 — CURRENT v2.95 Human Wizard source combat

[Roadmap](
../roadmap/DungeonMMO_Roadmap_v2_95_Human_Wizard_Source_Combat_20260925.md);
[evidence](
../testing/c4-human-wizard-source-combat-v2-95-20260925.md).
Human Wizard exact source integration is now green through the disabled C4
combat calculator. Exact tracked coverage is **10 paths / 569 learning rows /
95 source skill IDs / 362 required source effect rank pairs**. Emberweaver
rank-6 `EmberweaverEmberBolt` resolves authenticated source skill **1220:6**
(power 38, magic level 30, FIRE) through the accepted MDAM formula.
Human Wizard remains **74/93 non-companion rows mapped** with **19 companion
rows intentionally unresolved**. Fresh source-combat **43 assertions PASS**,
skill-tree **586 PASS**, source-effects **579 PASS**, primary-stats **147
PASS**, creative link audit **569/528/41/0**, authenticated preview **649
PASS**, and the combined focused runner **6/6 PASS**. This is still
`live=false`: next add exact server-owned source MP/cast/reuse authority
before exposing live Emberweaver direct spells.

Use the focused source-combat runner for later Human Wizard source changes;
do not rerun unrelated cutover rehearsals unless their contracts change.

## 25 September 2026 — CURRENT v2.94 Human Wizard foundation

[Roadmap](
../roadmap/DungeonMMO_Roadmap_v2_94_Human_Wizard_Foundation_20260925.md);
[evidence](
../testing/c4-human-wizard-foundation-v2-94-20260925.md).
Fresh unpublished Base focus passes **3/3**:
`C4HumanWizardFoundationTest` **166 assertions**,
`C4HumanWizardQuestTransactionTest` **22 assertions**, and
`C4Level30LaunchCoverageTest` **37 assertions**. Base and Dungeon Rojo
builds also pass. The accepted contract is creative Emberweaver
selection/quest/level-20 mentor award/trainer plus **74/93** exact training
schedule rows. The remaining **19** companion-dependent rows are intentionally
unmapped and are not counted as implemented effects. No release parity is
claimed.

## 25 September 2026 — CURRENT v2.93 Human Wizard source audit

[Roadmap](
../roadmap/DungeonMMO_Roadmap_v2_93_Human_Wizard_Source_Audit_20260925.md);
[evidence](
../testing/c4-human-wizard-level30-source-audit-v2-93-20260925.md).
Human Wizard's C4 first-transfer source inventory is now independently
audited through the level-30 launch cap: **93 rank rows** at
20/25/28/30. The class remains unimplemented and **0/93 mapped**; this is not
a playable-class claim. The launch aggregate is now **6/18 source-audited,
5/18 trainer-mapped, 0/18 release-certified**. Fresh acceptance also corrected
a stale Human Knight audit error: its launch-cap source total is **54**, not
55; the older inventory incorrectly duplicated bow defence at level 28 even
though the next source rank is beyond the level-30 cap. Focused source audit
**37 assertions PASS**, Base/Dungeon Rojo PASS. Next: creative Human Wizard
career/quest/trainer and real source-family effects, including a
server-authoritative summon design before any summon rows can count.

## 24 September 2026 — CURRENT v2.23 Warrior final six skill ranks

[Latest roadmap](
../roadmap/DungeonMMO_Roadmap_v2_23_Warrior_Level30_Rank_Mapping_20260924.md)
and [exact executed focused/real-client evidence](
../testing/ironvow-final-utilities-v2-23-20260924.md).
Warrior `IronvowCriticalStance` ranks 20/24/28
(MP activation/upkeep and real NPC critical HP),
level24 `IronvowAccuracyStance` (MP toggle and
server-owned NPC accuracy), level24
`IronvowFieldRecovery` (paid owner-only actual HP
regeneration) and level28 `IronvowEnduranceSurge`
(13 MP, nonstacking 10% MaxHealth plus single
10% restoration) are now individually learned
skills with actual server effects. Fresh disposable
Base/Dungeon Rojo PASS at `efa2f0e1`;
Quest/Award/Foundation **31/198/160 PASS**,
strict source audit **27 PASS**. Real client
critical/accuracy toggle Play PASS on earlier
utility increments. Current real recovery Play
`0.740.0.7400927_20260924T125548Z_Studio_C9E7D_last.log`
PASS: max-health cap, rank revocation, forged
class and dead-player denial. Two earlier recovery
Play failures resulted from a **detached test
avatar** (player.Character.Parent=nil); a diagnostic
confirmed this and test-only world spawning repaired
the fixture. DO NOT delete production's parent/owner
check. Current real client surge Play
`0.740.0.7400927_20260924T125726Z_Studio_65402_last.log`
PASS: 13 MP, MaxHealth 108->118.8, one 11.88
owner HP restoration, full 100-damage hostile
melee still applies, immediate re-cast cannot
stack/reheal/extend expiry, copied Fighter and
rank-revocation cleanup denied. Ten-minute
expiry timestamp tested, not real full-duration wait.
Current separate strict rank audit 27 PASS in
`0.740.0.7400927_20260924T125831Z_Studio_50C82_last.log`.
Warrior **62/62 training rank schedules mapped**;
Knight 55/55; Human Rogue 59/59; Elf Scout
77/77. **0/18 first-transfer careers fully
C4-mechanic/economy/cross-place/release certified**,
14 original advancement source inventories and
original level1–19 starter class skills remain.
Provisional Roblox C4 formula adaptations,
natural saved quest-to-dungeon-to-rejoin journey,
multiple-client buff/gear/stun exploits and boss/
world-boss shield-block chip remain OPEN.
Prior actual Marauder/Captain shield block fix
does not certify every hostile encounter.
Next prioritize genuine full-session owner and
adversarial multiple-NPC/client tests, then next
historical first-transfer skill inventory.
Permanent source/roadmap edits via GitHub, remote
desktop only safe fast-forward/disposable
unpublished builds and tests. No `main` merge,
Roblox publish, production DataStore mutation or
parallel animation project edits.

## 24 September 2026 — CURRENT v2.20 earned Warrior common creation

[Latest roadmap](
../roadmap/DungeonMMO_Roadmap_v2_20_Warrior_Common_Craft_20260924.md)
and [actual source service proof](
../testing/ironvow-common-crafting-v2-20-20260924.md).
Warrior two distinct source common creation ranks
20/28 bought at the real earned-class trainer;
starter recipe-reading/basic creation prerequisites,
ONE gathering/ONE creation profession. Eight material-
backed real server recipes for four careers; focused
Blacksmithing rank1 crafted real two-handed halberd,
rank2 crafted owned D-grade Warrior body item. Actual
real server material spend and output/reload PASS.
After preparing high-rank craft, revoking that rank
before commit causes atomic denial with NO materials
lost and NO output duplication. Base/Dungeon fresh
unpublished Rojo PASS. Quest/Award/Foundation
**31/182/131 assertions PASS**, source rank audit
**27 PASS**. Warrior **56/62 source rank rows mapped,
6 utility rows remain**: CriticalStance 3 at20/24/28,
HealthRecovery 1 at24, AccuracyStance 1 at24,
EnduranceSurge 1 at28. Knight **55/55 scheduled**,
all **0/18 first-transfer release-certified**.
The three other Warrior creation career registrations
and authority require separate full craft transaction
tests; original C4 automatically learned common creation
versus DungeonMMO one-career purchased analogue
remains explicit. True client UI/gather, C4 formula,
natural cross-place save and boss/world-boss
Block stacking require tests; v2.12 Marauder/Captain
block-chip proof must NOT be broadened to those paths.
Avoid rerunning unchanged green suites. GitHub for
all permanent edits; desktop only safe fast-forward
and targeted unpublished tests. No `main` merge,
Roblox publish, production DataStores or animation edits.

## 24 September 2026 — CURRENT v2.19 genuine Warrior D-grade equipment

[Latest roadmap](
../roadmap/DungeonMMO_Roadmap_v2_19_Warrior_Equipment_20260924.md)
and [focused test evidence](
../testing/ironvow-equipment-expertise-v2-19-20260924.md).
Earned `IronvowEquipmentExpertise` is a separately paid
source level20 passive. Registered functional prototype
D-grade Warrior-only heavy body armour needs genuinely
awarded owner, bought licence, correct level and actual
inventory. Real server equip initially rejects without
rank, then equips after purchase and changes max HP
+20. Copied class, wrong/underlevel gear denied;
test ProfileService save/reload preserves both. Two
disposable Rojo builds PASS; actual Quest/Award/
Foundation **31/144/125** and source audit **27**
assertions PASS. Warrior **54/62 source rank schedules
mapped, 8 utility rows remain**: common creation 2,
critical stance 3, health recovery 1, accuracy stance
1, endurance surge 1. Knight 55/55 scheduled;
0/18 careers release-certified; original C4 stat/
economy formulas, natural full client cross-place
quest/rejoin, all boss/world-boss shield-stack security
and other 14 first-transfer inventories still OPEN.
Avoid retesting unchanged green suites; continue
utilities. Permanent scripts/docs GitHub only;
desktop for safe fast-forward and targeted disposable
unpublished Studio. No main merge, publish, production
DataStores or parallel animation project edits.

## 24 September 2026 — CURRENT v2.18 Warrior source blunt control

[Latest full roadmap](
../roadmap/DungeonMMO_Roadmap_v2_18_Warrior_Stonebreaker_20260924.md)
and [executed true client proof](
../testing/ironvow-stonebreaker-v2-18-20260924.md).
Earned first-transfer Ironvow now separately buys nine
`IronvowStonebreaker` ranks 20/24/28, original blunt-
only target, MP and source skill power. Actual client
slot-one request (not only a scripted attacker)
spent 30 MP, damaged genuine spawned Dungeon NPC for
21.3888 HP, applied real server 1.1sec shock, and
rejected immediate cooldown repeat, actual sword and
unawarded Fighter. Quest/Award/Foundation **31/137/119
PASS**, strict C4 level30 audit **27 PASS**, Base and
Dungeon unpublished disposable Rojo PASS. Warrior
**53/62 mapped**, **9 utility source rows remain**;
Knight **55/55 mapped**, all first-transfer classes
**0/18 release certified**. CombatService only avoids
refreshing an already dazed target for the new
blunt-control ability; competing two-client re-stun
is not live tested. Its 1.1s stun and 0.3× source power
Roblox damage conversion are NOT C4 native formulas.
The successful real client used a disposable internally
valid quest/skill fixture, not natural saved multi-place
progression. Next: Warrior EquipmentExpertise (1),
CommonItemCreation (2), CriticalStance (3),
HealthRecovery (1), AccuracyStance (1), EnduranceSurge
(1). Then remaining 14 C4 first transfers and
starter 1–19. Existing v2.12 Marauder/Captain HP
chip/guard break fixes do not certify boss/world-boss
pipelines. Avoid repetitive already-green test runs,
reserve desktop calls for targeted unpublished play.
All permanent changes via GitHub, no main merge,
publish, production saves or animation worktree edits.

## 24 September 2026 — latest v2.17 source-ranked Warrior area skill

[Current roadmap](
../roadmap/DungeonMMO_Roadmap_v2_17_Warrior_Crescent_Sweep_20260924.md)
and [executed Studio evidence](
../testing/ironvow-crescent-sweep-v2-17-20260924.md).
Personally earned Ironvow receives independently paid
`IronvowCrescentSweep`, 9 source rank rows at 20/24/28,
true equipped polearm + polearm mastery prerequisites.
Each rank retains real C4 90..191 source power and
22..30 MP cost; actual DamageService Roblox HP formula
uses explicitly **provisional** 0.15× adapter. Source
combat area skill has a separate twenty-NPC cap (not the
regular polearm five/ten-target sweep), preserved across
all swing samples. Two ranks' actual twenty of twenty-two
real NPC Humanoid HP tests **46 PASS**. Quest, paid ranks,
saved reload and forged-class Foundation **31/118/96
PASS**; independent source audit **27 PASS**. Base and
Dungeon disposable Rojo builds PASS. Warrior **44/62**
original training rows mapped, **18 remain**; Knight
**55/55 mapped** but source mechanics and launch
still NOT certified. Area fixture used a scripted server
attacker, not real user skill input/MP spending.
Next: true nine-rank blunt-only stun family with sourced
Power/MP, actual target stun and no refresh while dazed,
then nine utility source rows. Do not repeat already
green suites unless changing their dependencies.
Previous genuine Marauder/Captain stacked shield Block
chip damage fix remains, boss/world-boss paths pending.
No `main` merge, Roblox publish, production saves
or separate animation changes. Edit sources/docs on GitHub;
desktop only for targeted unpublished test builds/logs.

## 24 September 2026 — current Warrior v2.16 polearm, verified anti-stack

[Latest class roadmap](
../roadmap/DungeonMMO_Roadmap_v2_16_Warrior_Polearm_20260924.md)
and [exact focused/live Studio evidence](
../testing/ironvow-polearm-mastery-v2-16-20260924.md).
Source-verified Human Warrior Polearm Mastery ranks
20/24/28/28, P.Atk 4.5/7.3/8.9/10.7 and +5 source
hit targets implemented via new original
`IronvowPolearmTraining`, registered two-handed
`ironroot_training_halberd`, server-authenticated
rank/weapon/class, separate 7-stud multi-target
hitbox and 5/10 single-swing target cap. No copied
rank, sword/blunt/dagger/empty equipment or raw
Fighter may obtain source polearm attack bonus
or extra targets. `EquipmentService` refuses
BOTH shield→polearm and polearm→shield, preserving
anti-invulnerability. Latest focused real Warrior
quest/award/foundation 31/99/73 PASS on source
`a4512b956a28c6fe983361e33137225a98eb6819`;
12-NPC actual world-health capped sweep 26 assertions
PASS, genuine spawned player→NPC health 110
untrained vs 111.07 rank4 PASS, strict level30
source audit 27 PASS. Fresh disposable Base and
Dungeon Rojo PASS. Current Warrior **35/62**
historical training rows mapped, **27 missing**;
Knight **55/55** source schedules mapped, but
source conversion to Roblox P.Atk currently
provisional, full source-effect/economy parity,
natural saved client, multiple-party and boss/
world-boss exploit tests remain unverified;
**0/18** first-transfer careers release certified.
Four source-inventoried class branches, 14 unaudited
branches and base skills 1–19 still pending.
Desktop Commander reports 87% monthly usage;
preserve remaining credits, use GitHub directly
for scripts/docs and focused unpublished Studio
only when necessary. Do not merge main, publish
Roblox, use production saves or alter humanoid/
quadruped animation worktrees.

## 24 September 2026 — latest v2.15 Warrior Sword/Blunt verification

[Current v2.15 roadmap](
../roadmap/DungeonMMO_Roadmap_v2_15_Warrior_Sword_Blunt_20260924.md)
and [exact test record](
../testing/ironvow-sword-blunt-mastery-v2-15-20260924.md).
Stable saved `IronvowBladeTraining` now grants its earned,
purchased rank bonus to real server-equipped Sword **or**
Blunt; dagger, bow, empty slot and forged Fighter do not
receive it. Genuine Warrior trainer and quest/source ranks
20/24/28/28 retained. Fresh disposable Base/Dungeon
Rojo PASS. Warrior Quest/Award/Foundation 31/81/60
assertions PASS. Unpublished Dungeon Play on real NPC HP:
both Sword and Blunt 100-base hits 110 untrained to
115.6 at rank4; all tests and forged-denial marker PASS.
Fresh strict C4 level30 audit 27 PASS; Warrior **31/62**
training rows mapped, **31 missing**; Knight **55/55**
rank schedules mapped, neither release certified and
full original C4 balance/stat/formula parity NOT verified.
All 14 other original first-transfer source catalogues,
starter 1–19, natural full Base→Dungeon→Base saved
acceptance and broad boss/worldboss anti-block exploit
audit remain outstanding. C4 source trained ranks are
not equivalent to a green game-wide release. Earlier
v2.12 Marauder/Captain real blocked HP chip proof
remains current but not evidence for other enemy dispatch.
No `main` merge, Roblox publish, production saves or
parallel humanoid/quadruped changes. Permanent work via
GitHub, disposable builds/Studio only via desktop.

## 24 September — current backend v2.14, Knight common craft and anti-duplication

[Latest roadmap](
../roadmap/DungeonMMO_Roadmap_v2_14_Knight_Common_Craft_C4_20260924.md)
and [exact executed proof](
../testing/knight-common-crafting-v2-14-20260924.md).
Duplicate Knight common crafting skill/recipe/server-rule implementations
discovered on GitHub were consolidated into the **single**
`OathguardCommonItemCreation` skill before validation. Its
level20/28 source-tier ranks, one selected creation career,
source-first-transfer owner and material-backed eight real
recipes across four distinct professions are server-authoritative.
Blacksmith tier1 makes a real blunt mace; tier2 makes real D-grade
body armour. A prepared rank2 recipe cannot finish after that
rank is revoked: actual input/output counts remain unchanged.
Disposable Base and Dungeon Rojo builds PASS; focused Knight
quest/foundation **247/112 assertions PASS**, level-30 audit
**27 assertions PASS**. Knight **55/55 C4 source training
ranks mapped, 0 missing**, but full original C4 effect/economy,
automatic Common Item Creation source learning and math
parity are **not certified**. Warrior **27/62**, 35 missing,
other 14 first-transfer class source audits outstanding,
**0/18** careers release certified. Prior v2.12 real HP
Marauder/Captain stacked-block exploit fixes remain in source:
genuine blocked hits spend stamina and chip real HP, guard
break takes ordinary unblocked HP. Other boss/world-boss
pipelines, real world-recipe UI, natural saved cross-place
and live multiplayer exploit regressions still OPEN.
No `main` merge, Roblox publishing or production saves.
Permanent edits through GitHub, desktop only for
fast-forward pull, disposable builds, unpublished Studio
playtesting/logs; animation worktrees remain untouched.

## 24 September 2026 — current v2.12 Knight security and C4 defence

[Current roadmap](
../roadmap/DungeonMMO_Roadmap_v2_12_Knight_Defense_Exploit_Bow_20260924.md)
and [exact executed evidence](
../testing/knight-block-fortress-bow-anti-exploit-v2-12-20260924.md).
Verified and fixed a real zero-HP shield-block exploit:
Marauder and Captain attack controllers previously sent
only Hit to DamageService, making sustained Blocked and
GuardBroken outcomes HP-immune even with defence buffs.
Server-authored blocked hostile melee/bow now deals
45% post-mitigation chip subject to 20% incoming HP floor
before a *separate* ward, guard break does ordinary
unblocked damage, block start needs 20 server stamina,
and block-release spam cannot reset 0.65s parry rearm.
Genuine client Knight + purchased shield rank2/Majesty
took 41.13 real HP three times from 100-base blocked hits,
then 91.4 HP on guard break; zero-stamina reblock denied.
Separate earned C4 Knight Ultimate Defence analogue
`OathguardLastBastion` costs MP19 and immobilizes caster
for actual 30s, protects physical+magic with explicit
provisional 35% Roblox conversion; with shield, Majesty,
Ultimate and server-trusted block, actual HP damage
**25.38** from 100, not near-zero. Client Dodge while
rooted and premature recast denied. Test waited full
30s and verified unanchoring and restored normal damage.
Focused Base Knight Quest/Foundation 89/89 PASS and
live full Dungeon Bastion PASS after fixing an initial
Luau parse error on the source branch.

Re-audited original C4 Knight class page: source has
*two* bow-defence ranks at 24 and 28, earlier source
inventory omitted rank2. Corrected total from 54 to 55.
Distinct earned/purchased `OathguardArrowWard` rank1/2
MP22/28 and source bow attributes -16/-19. Genuine
client/full-Dungeon HP bow tests PASS: 100-base injected
server-authored EnemyBow hit causes 84/81 real HP;
blocked bow causes 37.8/36.45 HP; regular melee/magic
100. Focused Knight quest/foundation 96/95 assertions
PASS, launch rank audit currently **48/55 mapped,
7 missing**: equipment expertise1, common item creation2,
true sword AND blunt mastery4. Warrior **27/62**,
35 missing. Original bow attribute-to-HP reduction
16/19%, buff timing and Fortress numeric conversion
are *provisional Roblox adaptations*; no exact C4
combat formula/balance certification, no real ranged
NPC bow projectile playtest, no end-to-end saved journey
or party-member owner-isolation proof. Other real boss/
world-boss attack pipelines need block-outcome audit.
No `main` merge, Roblox publish or production saves;
permanent edits directly in GitHub, desktop only for
fast-forward pull/disposable build/unpublished Studio.
Separate animation sessions and worktrees untouched.

## 24 September — current Knight C4 mechanical parity v2.11

[Latest roadmap](
../roadmap/DungeonMMO_Roadmap_v2_11_C4_Knight_Majesty_20260924.md)
and [fresh exact test evidence](
../testing/oathguard-c4-majesty-v2-11-20260924.md).
Previous v2.10 seven-rank Knight life drain remains implemented
and real-client hit/heal validated. v2.11 corrected the separate
C4 Knight Majesty analogue `OathguardSteadfastStance` from
v2.09 adapted 10%/10-second/14-stamina guard to recorded
+7% physical defence, -2 Evasion, 10 MP, approximately
five-minute timed buff. Old v2.09 live test results are
historical, not accepted for current source. Fresh disposable
Base and Dungeon builds PASS; Knight Quest/Foundation
**87 + 84 assertions PASS**; real-client Dungeon Play
**PASS** at `fbbfb8bf7d8938648d426bd1fefea5785e421f84`:
100-base hostile physical melee/area damage = **93 HP**
while active, magic/ordinary player melee = 100, forced
expiry returns 100; cost and evasion metadata verified,
premature recast does not extend expiry. The 300-second
expiration was checked as an issued timestamp and end
via **test-forced expiry**, not actual five-minute wait.
+7% C4 P.Def and -2 Evasion *stat* are currently approximated
in Roblox as 7 percentage points of physical damage mitigation
and 2 percentage points of dodge chance penalty, not
identical source damage/evasion mathematics. Nine Knight
source rows, 35 Warrior rows and other 14 class catalogues
remain; no fully C4-balanced or fully releasable class.
A first attempted focused test failed `IdentityIncomplete`
because it invalidly persisted level19 on an awarded level20
Knight; fixed the test to use detached clone, and focused
suite subsequently PASSED. Avoid repeating broad suites.
Next: separate true immobile dual physical/magic Ultimate
Defence, rather than treating Majesty as equivalent; then
equipment/crafting/sword-blunt/bow and original starter
catalogues. Permanent changes in GitHub; desktop only
disposable fast-forward builds, Play and logs; leave user's
other humanoid Studio session and animation work intact.
No publish, main merge or production save mutation.

## 24 September 2026 — v2.10 source-checked Knight life drain

Current [v2.10 C4 fidelity roadmap](
../roadmap/DungeonMMO_Roadmap_v2_10_C4_Skill_Fidelity_Knight_Drain_20260924.md)
and [executed evidence](
../testing/oathguard-umbral-siphon-v2-10-20260924.md).
GitHub branch `wip/phase-4-test-hud-integration-v1` now contains
`OathguardUmbralSiphon`: seven independently purchased
Human Knight ranks with C4 reference power/MP values and real
post-hit 20% owner lifesteal. The separate existing
`OathguardMendingOath` remains an owner-only *healing* spell.
Fresh disposable Base/Dungeon Rojo PASS; focused Quest/Foundation
**88/84** assertions PASS; rank inventory **27 PASS**; actual
client-originated Dungeon Play rank one NPC **20 damage →
4 HP owned heal**, rank seven NPC **31 → 6.2 HP owned heal**,
both spend rank-specific mana and forged Fighter cannot cast.
No natural uninterrupted saved quest-to-Dungeon journey was
proven. Historical mapping now Knight **45/54** (9 missing),
Warrior **27/62** (35 missing), Scouts 59/59 and 77/77;
**0/18** full level-30 first-transfer classes release-certified.
Critically, all earlier `mapped` counts measure purchasable
*rank rows*, not authentic equivalent mechanics or original
balance. Existing Knight stance, self-heal, shield, resistance
and shield-control effects still have documented C4 function/
cost/stat differences; reconcile individually before marking
full source parity. Do not merge main, publish Roblox, mutate
production DataStores or change the one-gathering/one-crafting
profession rule. Permanent edits in GitHub only; desktop
reserved for pulls, disposable builds and unpublished playtests.

## 24 September 2026 — v2.09 verified Knight timed defence

[Current class roadmap](../roadmap/DungeonMMO_Roadmap_v2_09_Knight_Steadfast_Stance_20260924.md)
and [exact playtest evidence](
../testing/oathguard-steadfast-stance-v2-09-20260924.md).
On branch `wip/phase-4-test-hud-integration-v1`,
level-20 earned-only Oathguard Steadfast Stance requires
purchased basic Fighter armour rank 3 and the actual Knight
trainer. Authenticated client Play consumes 14 stamina,
applies ten seconds of server PhysicalGuard reducing
100-base physical enemy melee/area damage to 90 actual
player HP, with a 24-second cooldown. Enemy magic, ordinary
player attacks and expired buff still deal 100; an immediate
recast did not extend expiry and a forged Fighter is denied.
Fresh Base/Dungeon Rojo PASS, original Knight quest/foundation
70/67 assertions PASS, rank audit 27 PASS, independent Play
`VERIFIED_PLAY_MODE_PASS`. Source Knight **38/54 mapped**,
**16 missing**, Warrior **27/62 mapped**, **35 missing**;
**0/18** branches fully level-30 release certified.
Earlier v2.08 Knight client healing 30/44 HP and 8-rank
rune protection 95.2 damage from 100 also PASS.
Earlier physical Base first-hold MISS recurred, but the
bounded genuine client retry completed real NPC, owner item,
mentor and client trainer flows; production first-try prompt
reliability is not fixed or certified. Natural saved
progression, live other-player isolation and cross-place
acceptance remain open. Permanent source/docs in GitHub
only; desktop for disposable builds/Studio and logs.
No `main` merge, Roblox place publish or production save.

24 September live verification addendum: both disposable Rojo builds
PASS. Studio Knight quest/foundation 66/62 assertions PASS and
level-30 launch audit 27 PASS. New unpublished full-Dungeon Play
`scripts/studio/c4_oathguard_shield_damage_live.luau` verified actual
player HP: 100 base becomes 99.2 damage with one purchased shield rank,
98.4 with two, and 98.4 for hostile area; magic, PvP, unequipped,
wrong-slot and forged-class cases remain at 100. The test uses
synthetic but internally validated earned-class/purchased-rank and
registered OffHand equipment snapshots, NOT natural client purchase
or quest/gear UI. Exact Studio log:
`0.740.0.7400927_20260924T082450Z_Studio_B7727_last.log`.
A separate newly executed two-client physical Base quest test FAILED:
client saw and held the enabled four-stud Captain Rowan prompt, but
server Triggered never fired. Exact server Studio log:
`0.740.0.7400927_20260924T081936Z_Studio_ECDA7_last.log`.
Diagnose prompt transport before rerunning complete NPC route;
then verify genuine client heal/magic/equip, other-player isolation,
profile rejoin and cross-place journey. Existing v2.07 historic Base
PASS does not override the new physical prompt failure.
[Evidence](../testing/oathguard-shield-mastery-github-candidate-v2-08-20260924.md).
No main merge, Roblox publish, production DataStore or paid action.

## 24 September 2026 — v2.08 Knight shield focused and actual player HP PASS

- [x] GitHub source adds personally earned Oathguard shield mastery
  at levels 20 and 28 with shield-dependent 0.8% physical damage
  reduction per bought rank (maximum 1.6%), correct career
  trainer and strict incomplete 37/54 launch-rank audit.
- [x] Source-owned test fixtures now assert genuine profile
  purchase, forged owner rejection, equipment isolation,
  runtime mitigation and rank count; these tests are **staged**.
- [ ] Focused Knight quest/foundation and level-30 audit
  suites have **not executed** for this code candidate.
- [ ] No disposable Base/Dungeon Rojo builds for v2.08.
- [ ] Genuine client-controlled physical shield damage,
  wrong gear/class/PvP/magic isolation, Knight personal
  self-heal and enemy spell protection still require
  unpublished local Studio evidence. Keep v2.07 acceptance
  receipts historical, not a pass for new source changes.
- [ ] 17 Knight and 35 Warrior source rank entries
  remain unmapped; **0/18** careers certified for launch.
[Candidate checklist](
../testing/oathguard-shield-mastery-github-candidate-v2-08-20260924.md).

## 23 September 2026 — approved quadruped engine work in progress

Owner approved reusable quadruped design, GitHub source/docs commits on
wip/phase-4-test-hud-integration-v1, and native continuous execution.
Latest backend roadmap is v1.90; older introductory backend snapshots below
are historical. No backend acceptance changes are inferred here.
Engine source is isolated under tools/animation/quadruped/engine/.
See its EXECUTION.md and the 2026-09-23 design/plan under docs/superpowers/.
Current evidence: read-only V3 Blender skeleton inventory only; implementation
and actual V3 Studio playback remain pending. Original rigs and production
compositions remain untouched. No asset/place publishing authorized.

# DungeonMMO Test and Acceptance Matrix

## 22 September 2026 — C4 v1.77 poison status focus

- [x] Source-level seven Human Mystic curse, both Mystic
  poison cures and Elf-only Scout self-cure: **20** focused
  trainer/race/class/effect assertions PASS.
- [x] Actual source implementation audit: Human Fighter
  37/39, Elf Fighter 41/43, Human Mystic 38/44,
  Elf Mystic 35/42: **49** assertions PASS.
- [x] Scout source audit: Human Rogue 81/99,
  Elven Scout 108/129: **1,080** assertions PASS.
- [x] Strict overall audit: Base=151/168, Scouts=189/228,
  seven unmapped original source class inventories,
  zero of nine first-transfer paths complete and
  `Completed=false`: **seven** assertions PASS.
- [x] Base and Dungeon TEMP Rojo compositions built
  without changing the canonical release place.
- [x] Unpublished real Play client sent all THREE
  skills through genuine client hotbar input. Poison
  impact damaged TrainingDummy, three timed server
  ticks dealt four HP each, and both full-health
  client cures removed real poison without later damage.
  `VERIFIED_PLAY_MODE_PASS`.
- [ ] 56 missing source ranks across the six currently
  inventoried classes; seven other original first-
  transfer class inventories unenumerated/unimplemented.
- [ ] Authored normal NPC/boss poison application,
  real saved-player trainer/quest UI, multiplayer
  support and final milestone-wide regression OPEN.
  Existing unrelated Phase2A paid-revive auto-test
  failure remains unresolved.

[Full test receipts](../testing/c4-poison-status-v1-77-2026-09-22.md).
The updated separate humanoid animation roadmap remains
untouched. GitHub-only edits; remote only TEMP tests.


## 22 September 2026 — previous v1.76 C4 conditional recovery focus

- [x] Human Fighter sitting level-5 rank; Human Scout
  sitting level-24/32 ranks; both Scout races' level-36
  running rank: **42** race/class/level/effect assertions PASS.
- [x] Source-volume inventory after recovery: Scout **1079**
  assertions PASS (Human 81/99; Elf 107/129), basic-class
  **55** assertions PASS (Human Fighter 37/39,
  Elf Fighter 41/43, Human Mystic 36/44,
  Elf Mystic 34/42).
- [x] Strict overall completion audit **7** assertions PASS:
  Base=148/168, Scouts=188/228, 0/9 original
  first-transfer classes fully complete,
  seven unenumerated; `Completed=false`.
- [x] Both disposable unpublished Base and Dungeon Rojo
  builds PASS. Independent live Studio player sat in an
  actual Seat and a purchased Human Fighter rank
  increased real server Heartbeat Stamina recovery
  after an identical Stamina spend:
  `REAL_SEATED_STAMINA_PASS`.
- [ ] Real client moving Stamina recovery check, 60
  remaining ranks across the six currently mapped
  source classes and seven entirely missing original
  first-transfer career catalogues still OPEN.
- [ ] Saved-player original C4 class-transfer/quest/GUI,
  multiplayer gameplay and one release regression
  remain unverified. Separate Phase2A paid-revive
  automated failure remains open.

[Current test ledger](../testing/c4-conditional-recovery-v1-76-2026-09-22.md).
All code/tests/docs changed in GitHub only; remote
only clean pull, TEMP builds, unpublished Studio tests.


## 22 September 2026 — previous C4 healing and active-status focus

- [x] Mystic Battle Heal: **28** assertions; genuine server
  healing with earned prerequisite and all three source ranks.
- [x] Scout purchased passive standing/running dodge:
  **286** assertions; functional source inventory **1,073**.
- [x] Timed Scout active evasion and Elf self-guard:
  **24** source/race/level/status-lifetime assertions.
- [x] Strict first-tier and total C4 source audits:
  **57** + **7** assertions; Base 147/168, Scouts 184/228,
  class paths 0/9 complete; overall `Completed=false`.
- [x] Unpublished real Play client: **18** authenticated
  hotbar skills with true NPC/ally effects and both newly
  registered server combat statuses. No normal persisted-
  player purchase or published multiplayer claim.
- [x] Legacy Fighter trainer regression test fixed for
  expanding C4 catalogue: **13** focused assertions PASS.
- [ ] **65** sourced rank entries missing across currently
  inventoried six source classes. Seven other original C4
  first-transfer class inventories not yet built.
- [ ] Complete class quests, persistent-player purchase/GUI,
  remaining crafting/world/status systems and final regression.
  Existing separate Phase2A paid-revive failure stays open.

[Current receipts](../testing/c4-source-catalogue-v1-75-2026-09-22.md).
All code/docs via GitHub; only TEMP local builds/Studio tests
through the remote machine. No main merge or publish.


## 22 September 2026 — v1.75 Scout evasion and Mystic healing

- [x] Scout standing/running chance/race/class/level
  passives 286 assertions PASS; Human source ranks 77/99,
  Elf ranks 104/129, source-audit 1070 assertions PASS.
- [x] Battle Heal 3 source ranks, legitimate MageHeal
  server effects/prerequisites: 28 assertions PASS.
- [x] Human Life Drain 2 source ranks, Human-only class
  gate, real NPC-hit heal fraction: 11 assertions PASS.
- [x] New actual production SkillProgressionService
  trainer purchases, earned rank thresholds, foreign-race
  denial and profile save/release/reload in isolated
  memory: 37 assertions PASS.
- [x] Latest first-tier base-source audit 57 assertions:
  Human Fighter 36/39, Elf Fighter 41/43,
  Human Mage 36/44, Elf Mage 34/42.
- [x] Unified C4 completion audit 7 assertions:
  base 147/168, two mapped Scout source classes
  181/228, original first-transfer classes 0/9
  fully complete, seven class inventories not mapped.
  Overall `Completed=false` is CORRECT.
- [x] Both unpublished Base and Dungeon Rojo builds
  succeeded and real Dungeon Studio client passed
  16 actual hotbar combat effects including Battle
  Heal and Life Drain.
- [ ] Deterministic end-to-end actual enemy-melee evasion
  roll, real saved-player trainer GUI, real multiplayer
  party healer and one full milestone-wide regression.
- [ ] 68 missing source rank entries in six inventoried
  classes and entire separate skill catalogues for
  seven other C4 first-transfer paths remain OPEN.

[Focused receipts](../testing/c4-scout-evasion-base-healing-2026-09-22.md).
All project changes through GitHub; remote only for
clean pull, TEMP builds, unpublished tests and logs.


## 22 September 2026 — v1.74 C4 strict coverage and source gaps

- [x] 152 sourced four-class base rank assertions PASS;
  corrected Elf Fighter level-15 source bracket contains 15.
- [x] Base Fighter bow/dagger 88, Mage wind/heal 52,
  Fighter physical/armour 72 focused assertions PASS
  during prior backend increments.
- [x] New Mage robe casting/mana/basic-speed 38; novice
  level-one/expiry/foreign-class 36; real isolated
  trainer purchase/save/reload 32; source first-transfer
  branch enumeration 44 focused Studio assertions PASS.
- [x] Latest source-to-actual-effect audit 63 assertions PASS:
  Human Fighter 36/39; Elf Fighter 41/43; Human Mystic
  31/44; Elf Mystic 31/42. Combined currently mapped Scout
  source ranks Human Rogue 75/99 and Elf Scout 102/129.
- [x] Unified strict source coverage audit 7 assertions PASS:
  base=139/168, Scout=177/228, nine original first-transfer
  class paths, 0 fully complete and seven not yet mapped.
  `Completed=false` is CORRECT, not permission to publish.
- [x] Unpublished Base and Dungeon Rojo builds after new
  Mystic casting-speed and novice defense changes.
- [ ] Exact remaining source families (80 ranks in six
  enumerated classes), plus separate source catalogues and
  all real skills for seven missing first-transfer careers.
- [ ] New real client skill timing/novice defense, actual
  persisted-character trainer GUI/ordinary physical input,
  cloud multiplayer and one milestone-wide regression.
  The unrelated Phase2A paid-revive auto-test remains open.

[Full source ledger and focused receipts](../testing/c4-base-first-transfer-coverage-2026-09-22.md).
GitHub-only edits; local machine only for TEMP builds/tests.


## 22 September 2026 — v1.73 C4 Scout catalogue focus

- [x] Source-accurate C4 Human Rogue (99) and Elven Scout
  (129) level-20/24/28/32/36 rank inventory; 1066 focused
  source/implementation assertions PASS. Functional analogue
  ranks: Human 75/99, Elf 102/129. Remaining family counts
  are printed by the source-audit test and preserved in
  `audit(race_id).MissingFamilies`.
- [x] Race/level/class/purchased-rank/passive-stat tests:
  254 focused Base Studio assertions PASS, including actual
  Human +0.08 per-rank critical power, +0.02 race-specific
  critical chance, and level-28 Scout movement +6%, plus Human
  level-36 attack-rate +6% in actual server timings.
- [x] Real SkillProgressionService rank purchase, foreign-race
  rejection and isolated saved-profile release/reload:
  38 focused assertions PASS.
- [x] Unpublished Dungeon Play client eight existing real
  skill effects, earned light-armour physical mitigation,
  actual movement-speed change after an authenticated
  client combat input and actual server critical-hit
  damage after purchased Human ranks:
  `VERIFIED_PLAY_MODE_PASS`.
- [ ] HUMAN 24 and ELF 27 source rank entries remain
  **unimplemented** in the first-transfer inventory.
  Historic Fighter/Mage rank-volume gaps, later class
  transfers, accurate effect tuning and all other C4
  classes are NOT marked complete.
- [ ] Actual saved-character trainer GUI, normal physical
  keyboard input, published/cloud multiplayer and
  overall regression acceptance are still pending.
  Separate Phase2A paid-revive auto-test remains open.

[Detailed focused record](../testing/c4-scout-source-catalogue-2026-09-22.md).
All source/docs edits via GitHub; only local TEMP build/tests
through Remote Desktop. No old dungeon lifecycle suites rerun.


## 22 September 2026 — C4 Rogue bleed v1.72

- [x] Rogue level-24/32 `LaceratingCut` two
  actual-effect ranks, full Vital Blow and
  Disrupting Cut purchased/use-earned prerequisites,
  class/weapon/trainer restrictions: 19 focused
  Studio assertions PASS.
- [x] Production SkillProgressionService with
  isolated in-memory profiles: 20 assertions PASS
  for denied early/prerequisite purchases, lvl24
  rank one, lvl32/mastery120 rank two, max rank,
  and saved/reloaded purchased rank.
- [x] Unpublished Dungeon real client Play:
  authenticated hotbar accepted Lacerating Cut,
  hit a tagged NPC, caused three later 3-HP
  server bleed ticks, then expired without a
  fourth tick. The previous two-target slow
  and both stagger cases remained PASS.
  `VERIFIED_PLAY_MODE_PASS`.
- [x] TEMP Base/Dungeon Rojo compositions.
- [ ] Actual production-profile trainer GUI,
  physical keyboard input and published/cloud
  multiplayer not yet verified; Play character
  and client skill snapshot used temporary
  isolated fixtures.
- [ ] Correct C4 dagger-only Bleed equipment
  contract; temporary sword is not source parity.
- [ ] Full C4 catalogue/rank-count parity:
  Fighter/Mage historic 13/16 mismatches,
  Ranger/Rogue owned-career reference ranks
  still not mapped.
- [ ] Separate Phase2A paid-revive auto-test
  failure remains unresolved. No general
  Dungeon regression acceptance claimed.

[Evidence](../testing/c4-rogue-bleed-2026-09-22.md).
No unrelated dungeon lifecycle suite repeat.


## 22 September 2026 — real Ranger/Rogue control skills

- [x] New focused Base Studio test initially RED on
  missing BriarVolley progression definition.
- [x] Backend `f927f0d`: 41 class/trainer/weapon,
  rank-level and meaningful control-effect assertions
  PASS; Rojo Base build PASS.
- [x] Unpublished Dungeon client test at fixture
  `19cfeb5`: one BriarVolley hit/slowed **two**
  separate tagged training targets; DisruptingCut
  damaged and staggered the real target.
  `VERIFIED_PLAY_MODE_PASS`. Only temporary
  class/equipment/loadout and UI state was seeded.
- [x] Real isolated SkillProgressionService purchase/
  reload test at `3fe8b70`: 46 assertions PASS for
  5/10/15 level bands, earned proficiency 40/110,
  class isolation, rank caps and profile durability.
- [x] Rogue catalogue's obsolete claim of five
  visible skills for an unearned Duelist corrected:
  45 focused assertions PASS; all five only after
  legitimate advanced class/level/prerequisites.
- [ ] Source-verified Ranger/Rogue C4 reference
  rank manifest and fuller class-effect catalogue.
- [ ] Real saved-player trainer GUI and ordinary
  physical keyboard gameplay, full balance/cloud
  acceptance. Separate Phase2A paid-revive
  automatic test failure remains unresolved.

Proof: `docs/testing/c4-ranger-rogue-control-skills-2026-09-22.md`.
No unrelated Dungeon wipe/aggro/revive/replay rerun
or general Dungeon regression acceptance.


## 22 September 2026 — targeted real-client C4 actions/effects

- [x] Unpublished Rojo Dungeon composition at `755fab0`
  built successfully; GitHub-only fixture at `c944ddd`
  ran with `StudioTestService:ExecutePlayModeAsync`.
- [x] DawnWard applied real server ward and spent 12 mana;
  CinderBolt damaged real tagged dummy and spent 10 mana;
  ArcherDraw (Longbow) and RogueVitalBlow (rear-positioned
  sword) damaged the dummy via the actual client hotbar
  input module. `VERIFIED_PLAY_MODE_PASS` observed.
- [x] Real SkillsMenu displayed a trained rank and hid a
  foreign-class row from **synthetic test snapshots**.
- [ ] Real saved-profile trainer/purchase and physical
  keyboard/mouse input, rear-versus-front damage comparison,
  real-client balance and cloud multiplayer not yet tested.
- [ ] Unrelated auto-run `Phase2AFailurePathTest` and
  `RogueDefinitionsTest` emitted failures: separate focused
  investigations before claiming general regression green.
- [ ] Fighter/Mage 13/16 rank-volume gaps and reference
  coverage for Ranger/Rogue remain open.

Receipt: `docs/testing/c4-new-skill-live-client-2026-09-22.md`.
No old Dungeon wipe/aggro/revive/replay matrix rerun.


## 22 September 2026 — four-family skill rank/mastery focus

- [x] `02154e8`: Fighter/Mage/Ranger/Rogue
  level-bracket, skill-rank, earned proficiency,
  trial and specialist visibility test **74 assertions
  PASS**; affected class advancement **66** and
  existing Fighter/Ranger advanced skill **60** passed.
- [x] `d1ca4fa`: Base and Dungeon Rojo builds;
  same 74-assertion four-family test passed. Read-only
  Fighter/Mage rank-volume audit still reports
  **13/16 mismatched**, no claim of parity.
- [x] `687e27c`: Final Rogue full-nine-rank
  requirement: Base build and same 74 assertions PASS.
- [x] One real-client Mage projectile/ward and Ranger/Rogue
  new-skill impact/UI check: Play fixture c944ddd PASS.
  UI snapshot and class state were synthetic; real profile
  trainer transaction and physical input remain separate.
- [ ] Map Ranger/Rogue source-rank counts and fill
  remaining mechanics genuinely, not dummy ranks.
- [ ] Published cross-place/cloud acceptance remains
  a separate approval-gated release task.

Evidence:
`docs/testing/c4-all-four-class-families-2026-09-22.md`.
No full dungeon reset/aggro/revive/backend rerun.


## 22 September 2026 — v1.69 focused Mage rank and visibility

- [x] `e6033e0`: one Base Rojo build plus 39 focused
  `c4_starter_mage_skill_tests.luau` assertions PASS.
  Learned ranks, 1/7/14 level gates, 35/100 mastery,
  two real ward/damage rank effects, class restriction,
  snapshot/trainer hiding and profile reload checked.
- [x] One read-only source-rank audit: 13/16 mapped C4
  brackets still mismatch and 14 unmapped older ranks.
- [ ] New Mage skill-menu/trainer GUI and actual normal
  client Ward/Bolt effects need *one* targeted live
  client test; service assertions alone do not prove it.

Receipt:
`docs/testing/c4-mage-starter-ward-bolt-trainer-2026-09-22.md`.
No old dungeon wipe/aggro/revive suite was rerun.


## 22 September 2026 — targeted vitality/restoration passives

- [x] `3be5de3`: Base Rojo build and **64 focused
  StalwartTraining/RestorativeTraining assertions**.
  Hidden pre-level offers, forged early purchases,
  six actual server HP/healing stat increases,
  level bracket transition, rank cap, class
  isolation and profile save/reload passed.
- [x] The first test run correctly rejected learning
  because the new passives were absent from the
  class-authoritative teachable lists; GitHub
  fix followed by a single focused rerun passed.
- [x] Same source: **64 existing damage-passive
  assertions** passed after refactoring their
  shared class-safe purchased-rank resolver.
- [x] Read-only C4 reference audit: **16 mapped,
  13 mismatched, 14 unmapped skill-rank occurrences**.
  Human Fighter level 10 has one extra authored
  rank; no parity claim.
- [ ] One future actual normal-client HP/heal
  integration and broader C4 rank-content mapping
  remain; do not substitute old dungeon regressions.

Receipt:
`docs/testing/c4-vitality-restoration-rank-effects-2026-09-22.md`.


## 22 September 2026 — focused rank-passive acceptance

- [x] `08710c1`: one Base Rojo build, one
  `c4_passive_rank_effects_tests.luau` Studio run:
  **64 assertions PASS**. Unknown skills remain
  hidden below rank-one level; six passive ranks
  require the correct level/SP and increase an
  independently measured server physical/magic
  multiplier; wrong-class bonus is zero and
  ranks persist after save/reload.
- [x] Read-only C4 audit: 16 brackets measured,
  16 short; 14 older skill-rank families remain
  unmapped across the four audited class/race
  cases. **C4 parity is not accepted.**
- [ ] One targeted normal-client passive combat
  impact test later; this fixture checks the
  authoritative multiplier but does not prove
  player-facing balance.

Receipt:
`docs/testing/c4-passive-rank-effects-2026-09-22.md`.
Do not rerun the entire dungeon/backend suite
for an isolated new passive content increment.


## 22 September 2026 — v1.66 focused rank-content acceptance

- [x] `d812a73`: Base Rojo build; nine-rank Fighter
  skill progression test **133 assertions PASS**,
  including a production ProfileMigration cap fix.
- [x] `cdecfc7`: Base build; Mage six-rank actual
  healing/proficiency and save/reload **37 assertions PASS**.
- [x] `cdecfc7`: five directly affected pre-existing
  skill/class/quest/trainer contract tests **5/5 PASS**.
- [x] `cdecfc7`: C4 read-only source-volume report
  checked **16/16** mapped brackets; **16 STILL MISS
  parity**. Explicit Fighter 5/10/15 counts 7 each,
  Mage 7/14 counts 4 each, no source fabrication.
- [ ] A targeted normal-client rank-nine strike and
  rank-six healing impact check is future *new-feature*
  acceptance; these tests alone don't prove live balance.

No old Dungeon wipe, boss, Play Again or world-boss
matrix rerun. Receipt:
`docs/testing/c4-early-fighter-mage-skill-ranks-2026-09-22.md`.


## 22 September 2026 — focused C4 rank-density baseline

- [x] `29d117a`: one Base Rojo build and affected
  `skill_mastery_gates_tests.luau` PASS after
  aligning Fighter-style 5/10/15 and Mage
  7/14/20 new basic rank milestones.
- [x] Read-only `c4_skill_volume_audit.luau`
  executed. Initial 16 source-backed Human/Elf
  Fighter/Mystic early-level rows: **16 mismatched**,
  **14 race/class occurrences of unmapped legacy skills
  (7 distinct skill families)** across
  those four race/class audits. This is a working
  gap report, NOT a passing volume-parity test.
- [ ] Source count mapping for other class branches,
  levels and races; genuine active/passive/utility
  rank effects and source-equivalent skill volume.
  Do not mark v1.65 accepted until real content
  makes relevant source rows match.

Source targets and count-method limitations:
`docs/design/C4_Skill_Count_Parity_20260922.md`.
No dungeon wipe/aggro/revive/Play Again tests were
repeated for this content/audit change.


## 22 September 2026 — earned skill mastery / level gates

- [x] `bf93f07`: focused `skill_mastery_gates_tests.luau`
  passed **62 assertions**, covering hidden/new
  level-bracket basic skills in all four classes,
  earned full-mastery trial requirements, specialist
  level/class/prerequisite checks and combat-use denial
  after a required skill rank is lost.
- [x] `bf93f07`: focused `extended_level_contract_tests.luau`
  passed **44 assertions**, covering reachable level
  24/28/32, level 40 cap, old early XP, AP/SP and
  DEV-only level commands.
- [x] `bf93f07`: directly affected existing quest
  definitions, Rogue class advancement, trainer,
  progression snapshot and skill progression
  contracts passed **5/5** in unpublished Studio.
- [x] `e0e2f39`: one clean Dungeon Rojo build plus
  `dungeon_taunt_mastery_tests.luau` passed
  **7 assertions** on zero-damage taunt proficiency,
  active member eligibility, anti-farm encounter
  cap and new-encounter earning.
- [ ] ONE real-input tank/ranger/mage/rogue basic
  skill progression balance check remains; do
  not rerun old room-reset/aggro/revive suite.
- [ ] Full specialist class catalogue, visible
  locked requirement previews and published
  cloud/cross-place acceptance remain separate.

[Focused acceptance](docs/testing/dungeon-skill-mastery-lineage-style-2026-09-22.md).


## 22 September 2026 — focused class and ability acceptance

- [x] `e73f9ef`: Base build, **66 class advancement**
  and **40 story quest** assertions passed in
  unpublished Studio. Four new race-specific
  Fighter/Ranger quest paths tested at level 20,
  wrong-dungeon rejection, duplicate claims,
  role labels and save/reload.
- [x] `ffc20d1`: Base build and **60 skill**
  assertions passed after fixing an invalid
  test profile fixture to include a genuine
  CompletedByRace record; ProfileMigration
  correctly rejected the incomplete history.
- [x] `b017fbc`: Dungeon build and same **60 skill**
  assertions passed for all four new ranked
  skills, trainers, class-exclusive execution
  authorization, weapon requirements and
  duplicate purchase rejection.
- [ ] Targeted real-client skill impact and
  playable advancement/trainer board remains
  outstanding. Focus on NEW feature acceptance,
  not another room/wipe/aggro/Play Again loop.

Receipt:
`docs/testing/dungeon-class-progression-expansion-2026-09-22.md`.


## 22 September 2026 — new story quest focused test

- [x] `89d8e7e`: Base Rojo build and one focused
  `story_quest_backend_tests.luau` Studio runner:
  **40 QuestService assertions PASS**. Covers same-user
  Temple -> Mine prerequisite, unrelated DungeonClear,
  one-time Gold/relic/ore claims, duplicate denial,
  independent characters, profile save/reload and
  class-advancement isolation.
- [ ] A single targeted real Base client quest-board
  Start -> legitimate dungeon clear -> Claim flow is
  still pending; this increment is backend-only.
- [ ] Published TEST reserved-server/cloud continuity
  remains separate and requires approval.

No old aggro/wipe/revive/30-suite Dungeon matrix reruns
were necessary for this isolated new quest-content change.
Receipt:
`docs/testing/story-quest-backend-slice-2026-09-22.md`.


## 22 September 2026 — all-member difficulty gate / spectator / replay PASS

Accepted gameplay source `c6925c0`: six Rojo builds, focused
four-player Base party unlock test, TeleportCoordinator
**23 assertions**, DungeonReplayService **28 assertions**,
Dungeon backend **30/30**, real two-client spectator combat
and two-client Play again UI fixtures passed in unpublished
Studio. The four-client physical room wipe/re-entry also
passed earlier after the combat gate was introduced.
At final gameplay source `b6fe3be` (Base entry UI
identifies the locked party member), all six compositions
rebuilt and the Base party unlock test passed again.

**Player rule:** For Depth2+, every single selected character
must personally have completed the previous depth in the
selected dungeon. Base validates each party member and the
TeleportCoordinator rechecks all before server reservation.
Neither a leader's unlock nor another dungeon's clear grants
access. A locked party member blocks everyone, including
during Play again, and the failure identifies the member.
Replay invalidates previous votes when an unlock fails.

**Combat rule:** Spectating, dead and disconnected players
cannot attack, cast, defend, deal delayed damage, contribute
damage or be targeted as active dungeon participants.
Creating a new character cannot reset the server-owned
spectator mode; live two-client Studio verified the exclusion
and that the still-Active peer could damage targets.

**UI regression:** A late revive snapshot previously
interfered with visible Play again after two accepted
client votes. The UI now preserves terminal replay state.
Two genuine Studio clients demonstrated the waiting and
successful replay screens at the same gameplay head.

**Boundaries:** No genuine same-account network reconnect
into a published reserved server, real cross-place routing,
durable cloud replay, or full ordinary boss-reward reattempt
was established by the local fixtures. A published TEST
experiment still requires separate user approval.

[Acceptance evidence](docs/testing/dungeon-party-unlock-spectator-replay-2026-09-22.md).
[Roadmap v1.61](docs/roadmap/DungeonMMO_Roadmap_v1_61_Party_Unlock_Spectator_Replay_20260922.md).
All source/docs edits GitHub-only; remote access was used
for read-only diagnostics, clean pulls, local builds/tests.
No publish, `main` merge, force-push or production cloud mutation.


## 22 September 2026 — same-server reconnect local testing PASSED

Tested gameplay/test source:
`87a19ba6ac112f8fd3850d01f271538067286d72`.
Desktop Commander reconnected, and the clean feature worktree was
fast-forwarded to the GitHub reconnect implementation. The six
Rojo compositions built and `git diff --check` passed.
The focused production-service simulated same-UserId return suite
passed **30 assertions**; Dungeon backend **30/30** including
DungeonDeathService **46 assertions**; real-client failed-return UI
Play passed; focused ThreatService **51 assertions**; Base professions
**14/14**; and a real four-client physical Room1 wipe/re-entry
fixture passed, all at the **same** tested gameplay source.

**Boundary:** this proves the local reconnect contract and
non-regression, not a genuine Roblox account disconnecting and
network-rejoining its original reserved server. The existing
admission requires valid platform join routing; a direct return
without platform TeleportData fails closed. Published TEST
same-account routing, lease reacquisition, spectator combat exclusion
and persisted rewards remain outstanding and need separate
publishing approval.

The earlier "Studio OFFLINE" note below is historical and
superseded for local testing, not for the real-network gate.
Receipt:
`docs/testing/dungeon-same-server-reconnect-local-acceptance-2026-09-22.md`.
Updated roadmap:
`docs/roadmap/DungeonMMO_Roadmap_v1_60_Same_Server_Reconnect_20260922.md`.
All source/docs edits GitHub-only; no `main` merge, publish,
force-push or production data operation.


## 22 September 2026 — same-server reconnect source STAGED, Studio OFFLINE

Latest implementation/test source:
`7d684f583020df64e2591a00acef14c90f35ecb1`.
The previously proven multiplayer gameplay head is the
older v1.59 increment. Do **not** carry its six-build or
30/30 PASS labels forward to this new reconnect source.

A real previously connected, now-disconnected Roblox
member can pass a narrowly gated nonce-free **same active
server** readmission check after their initial handoff
nonce has been consumed. All initial Base-to-Dungeon
handoffs still need a nonce, and the normal profile load
must independently reacquire the profile writer lease.
Abandoned, connected duplicate, unrecorded departure,
foreign-server and terminal-run access is rejected.

On admission the server now re-sends the player's actual
revive state; the new client also requests a snapshot
after wiring event listeners. This prevents a returning
spectator from being presented with a refunded free revive
solely because a new Character loaded. A new service
regression covers authenticated same-UserId simulated
readmission, prior room checkpoint, spectator/free-revive
state, second party member and exclusive profile lease.

**CURRENT BLOCKER:** Remote Desktop Commander reported
no connected devices on 22 September. No Rojo builds,
Studio tests or Luau parse check were completed for
this source head. The new regression is written but
**NOT EXECUTED**. The user's existing backend
v1.59 accepted tests remain evidence only for the
earlier head. GitHub showed no CI checks on the new
source commit.

**NEXT once online:** fast-forward a clean worktree;
run all six Rojo builds, 30/30 Dungeon backend,
`scripts/studio/dungeon_reconnect_admission_tests.luau`,
and death/UI regressions, then a temporary same-user
admission simulation. Genuine same-account cross-network
return still needs a published TEST reserved-server
experiment and confirmed platform TeleportData routing
after separate approval; **do not** bypass missing
routing with an untrusted client-supplied session ID.
Check combat exclusion for returning Spectating members.

Report:
`docs/testing/dungeon-same-server-reconnect-stage-2026-09-22.md`.
Roadmap:
`docs/roadmap/DungeonMMO_Roadmap_v1_60_Same_Server_Reconnect_20260922.md`.
All code and document edits in GitHub only. No publish,
main merge, force-push, paid product or production cloud
data operation.


## 21 September 2026 — four-client secret / Depth4 / boss disconnect

Focused test head:
`9a63c6d25ac45cd67c9a4c5a684fa4c5a26adb24`.

- [x] Four real Studio players: physical SecretArena boss
  wipe; prior Room1, EventArena, Room2 stay cleared;
  four checkpoint free revives and one new full-health
  boss after physical re-entry.
- [x] Depth4 six-encounter placeholder plan: physical
  Room2 previous-depth mini-boss wipe and recovery.
  Room1 stays Cleared; Room2 returns Pending; later
  Room3 stays Pending; one full-health boss respawns.
- [x] Peer disconnect during live Room3 boss; actual
  PlayerRemoving persists `Connected=false`. Three
  survivors later wipe/revive, while the departed
  player's free revive remains unused. Prior clears
  and checkpoint remain stable.
- [x] Repaired outdated higher-depth regression for
  one-shot terminal Failure notification: **392
  assertions** pass across two dungeons, two depths
  and three party sizes.
- [x] Six local Rojo builds, Dungeon backend 30/30,
  death/revive 41 assertions at latest gameplay head.
- [ ] Actual same-account reconnect and cross-place
  checkpoint resume; Studio leave alone does not
  establish this.
- [ ] Ordinary player-attack boss kill/reward retry,
  higher-depth completion and new-run replay.
- [ ] Published TEST reserved-server/cloud continuity
  requires explicit separate approval.

Receipt:
`docs/testing/dungeon-secret-depth4-disconnect-recovery-2026-09-21.md`.


## 21 September 2026 — four-client physical recovery and replay

Latest tested gameplay head:
`a5c0637888f8400703d07290f790a24d3b8406bf`.

- [x] Four real Studio clients: Temple Room1 full wipe and
  four automatic checkpoint revives.
- [x] Partial-kill wipe: all four received original monster
  reward; repeated same transaction did not duplicate
  Gold, XP, Level or bestiary kill count for anyone.
- [x] Four-client Room3 boss: old injured boss retired,
  cleared rooms preserved and exactly one fresh full-health
  boss spawns after checkpoint re-entry.
- [x] Four-client optional event boss: equivalent physical
  wipe/re-entry with Temple event enabled only in the
  disposable test DataModel; production gate stays locked.
- [x] Two authenticated clients through real PlayAgain remote:
  first sees party wait, second vote produces simulated
  replay UI on both.
- [x] `DungeonDeathService:tick` announces terminal Failed
  exactly once, so it cannot overwrite ReplayWaiting.
- [x] Six Rojo builds, Dungeon backend **30/30**,
  death/revive **41 assertions** at latest gameplay head.
- [x] Focused threat 51, Base professions 14/14 and
  paid retry 15 at preceding fix head.
- [ ] Secret boss, higher depths and disconnect during
  physical full-party wipe/re-entry.
- [ ] Real published reserved-server replay, actual normal
  boss-reward combat through wipe and cloud continuity;
  publishing and cloud data remain deferred.

Evidence:
`docs/testing/dungeon-four-client-room-boss-event-replay-2026-09-21.md`.


## 21 September 2026 — actual Room1 wipe/re-entry Play PASS

At source `acb628fb99202a94f7f4cec781a15ec7f5614760`,
the real unpublished one-client Dungeon runtime entered authored
Temple Room1, observed a test-injured enemy, handled the player's
genuine death and free revive, removed old encounter models,
returned the new character near the current checkpoint, and
physically re-entered Room1 to spawn **new full-health enemies**.
Fixture `scripts/studio/dungeon_room_wipe_reentry_live.luau`
printed `VERIFIED_PLAY_MODE_PASS`.

The terminal Complete/Failed UI now presents Play again and Return
to Base. At `c1d7f83`, real-client UI Play proved both button
states, six Rojo builds passed and Dungeon backend 30/30 plus
ReplayService's **17 assertions** passed. At `341c84d`,
the one-shot recoverable wipe contract passed **40 assertions**
and Dungeon backend remained 30/30. The replay service's
actual new-place teleport remains untested in unpublished
Studio, where it is intentionally simulated; completed runs
cannot replay until completion rewards are committed. All-party
consent resets after a failed launch; automatic completed-run
return is suppressed during replay launch.

**NEXT:** genuine two-/four-client physical dungeon wipe and
boss/optional encounter recovery; actual replay button-to-server
multi-client Play, persisted reward idempotence through a physical
partial-kill wipe, and later published TEST/cloud verification
with separate approval. Do not conflate the physical one-client
room reset with these outstanding gates.

Evidence:
`docs/testing/dungeon-room-reset-play-again-2026-09-21.md`.
Roadmap:
`docs/roadmap/DungeonMMO_Roadmap_v1_57_Room_Reset_Play_Again_20260921.md`.
No Roblox publish, `main` merge or force-push. Source/docs
edited in GitHub; desktop limited to pull/build/unpublished tests.


## 21 September 2026 — recoverable room reset and Play again

Candidate gameplay/test head:
`341c84da73b9c1246414a51e171cc363d4e71c1b`.
The live dungeon death callback now resets an **uncleared active
encounter** once when all living party members fall but an
automatic free revive is still pending. The executor destroys
old enemy handles, releases boss spawn guards and rolls the
current encounter to Pending while preserving prior clears and
the room-start checkpoint. Free-reviving players respawn at that
checkpoint, then the authored room can spawn fresh enemies
with full health and fresh threat on re-entry. Already paid
monster lives retain their transaction IDs; no extra revive
or reward receipt is created by the rollback.

Completed runs with committed rewards and fully failed runs
now expose **Play again** alongside Return to Base. The
authoritative replay service requires affirmative consent from
all currently connected party members before requesting a new
reserved session with the same dungeon, difficulty and original
Base destination. A failed launch clears previous votes.
Unpublished Studio simulates actual cross-server travel.

Six Rojo builds; Dungeon backend **30/30**, replay contract
**17 assertions**, paid-retry regression and real-client terminal
UI `COMPLETION_BUTTON_PASS` / `WIPE_BUTTON_PASS` all passed at
`c1d7f83`. After one-shot wipe test additions, the same-head
`341c84d` Dungeon death suite passed **40 assertions** and the
backend matrix remained **30/30**.

**Outstanding:** a complete real-client physical dungeon
room fight -> death -> rebuilt enemies -> checkpoint re-entry
playtest; actual published reserved-place Play again and
cross-server/cloud rewards. These were NOT verified by the
local service/UI tests. No place published or main merged.
Receipt:
`docs/testing/dungeon-room-reset-play-again-2026-09-21.md`.


## 21 September 2026 — failed dungeon return and fresh retry

Verified gameplay head:
`8899fad6923628e86a8946fc9ce4c365bc738902`.

- [x] Server rejects late or duplicate paid-respawn callbacks,
  absent members and disconnected players after the run fails;
  real grant ordering (`PaidReviveCount` + `Active` first)
  is preserved.
- [x] Connected failed-run members can return to Base without
  reopening the terminal session or using active-run abandonment.
- [x] New session retry has a new SessionId, Entrance checkpoint
  and unused free revive while the predecessor stays `Failed`.
- [x] Real client shows failed-run return control:
  `VERIFIED_PLAY_MODE_PASS`.
- [x] Six local Rojo builds; Dungeon backend **30/30**;
  DungeonDeathService **33 assertions**; ReturnPortalService
  **15 assertions**; integrated paid-retry service **15 assertions**;
  fresh-session contract PASS.
- [ ] Actual in-place encounter reset restoring enemy health/spawn,
  party checkpoint respawn and reward-safe room re-entry.
- [ ] Published TEST cross-place Base return and fresh run Play,
  cloud reconnect and production rollout remain deferred.

Receipt:
`docs/testing/dungeon-terminal-wipe-return-fresh-run-2026-09-21.md`.


## 21 September 2026 — real wipe/disconnect acceptance

Verified head:
`739e747d88d93ff00ed30497e9473edd17b037f4`.

- [x] Four genuine Studio clients; two real enemy controllers;
  effective healing/Taunt threat, role changes and two isolated ledgers.
- [x] Genuine DPS PlayerRemoving clears enemy A and B ledgers:
  `REAL_DISCONNECT_CLEANUP_PASS`.
- [x] Remaining tank and observer genuinely die on their owning
  clients; healer is already dead; both enemies lose candidates
  and clear threat after a three-second no-target grace:
  `REAL_FULL_WIPE_THREAT_RESET_PASS`,
  `VERIFIED_FOUR_CLIENT_PASS`.
- [x] Six Rojo compositions PASS.
- [x] ThreatService **51 assertions PASS**.
- [x] Dungeon backend **30/30 PASS**.
- [x] Base professions **14/14 PASS**.
- [x] Correct isolated world-boss composition: real two-client
  aggro and real peer MageHeal/Ward/Mend support fixtures both
  `VERIFIED_MULTIPLAYER_PASS`.
- [ ] Full session/checkpoint wipe/retry with enemy HP/spawn
  restoration and reward idempotence. Current cleanup is
  **threat-only**, not a complete encounter reset.
- [ ] Published TEST, real cloud/cross-server reconnect and PROD
  remain deferred.

Receipt:
`docs/testing/four-player-full-wipe-threat-reset-2026-09-21.md`.


## 21 September 2026 — eligible support-threat follow-up

Source head: `b569435c9eb3cd4971eec06ca1baeeb4f17f4a09`.

- [x] Stale threat belonging only to an ineligible player cannot
  activate support aggro. Eligible damage restores valid engagement.
- [x] Six fresh Rojo builds and `git diff --check` PASS.
- [x] Focused unpublished Studio threat contract: **51 assertions PASS**.
- [x] Real two-client normal-enemy support fixture:
  `VERIFIED_MULTIPLAYER_PASS`.
- [x] Real two-client normal-enemy aggro fixture:
  `VERIFIED_MULTIPLAYER_PASS`.
- [ ] Fresh isolated world-boss aggro regression: attempted, but
  the outer Studio process exceeded 110 seconds. Earlier passing
  world-boss result belongs to an older head.
- [ ] Real world-boss healing/Ward, four real players and
  multi-enemy room/wipe/disconnect acceptance.

Receipt:
`docs/testing/combat-support-eligible-threat-followup-2026-09-21.md`.


## 21 September 2026 — support threat follow-on (LOCAL VERIFIED)

Tested head:
`df33735b10010b8aed8e7acc5193970b8f4cc9b1`.

- [x] Effective MageHeal/HoT, positive Mend pulses and absorbed
  ArcaneWard add server-owned threat at a provisional 0.5 multiplier.
- [x] Idle enemies do not gain free support threat. Caster and
  recipient must both be in the engaged enemy's eligible target set.
- [x] PlayerRemoving removes disconnected users from all threat
  ledgers/candidate snapshots; enemy reset clears both tables.
- [x] ThreatService focused Studio contract: **48 assertions PASS**,
  including simulated 4-person roles, 2 engaged enemies, Taunt,
  equal-threat tie, wipe/reset and disconnect cleanup.
- [x] All six Rojo compositions built; `git diff --check` passed.
- [x] Base professions **14/14** and Dungeon gameplay **30/30** PASS.
- [x] Existing real two-client normal Marauder and isolated world-boss
  aggro fixtures both `VERIFIED_MULTIPLAYER_PASS`.
- [x] Separate genuine two-client Marauder support fixture:
  real client MageHeal effective peer healing; real client
  ArcaneWard application; a **server-injected** incoming hit through
  production DamageService/WardService absorption generated threat.
  `VERIFIED_MULTIPLAYER_PASS`.
- [x] Follow-on genuine two-client Marauder fixture at
  `04c3f1e`: client MageHeal and ArcaneWard; actual NPC attack
  absorbed by the client-cast Ward; actual Fighter Mend pulses
  generated support threat. `VERIFIED_MULTIPLAYER_PASS`.
- [ ] Recheck these genuine support-skill interactions in the
  isolated weekly world-boss encounter.
- [ ] Real 4-client tank/DPS/support aggro, multi-enemy room behavior,
  full-party wipe/reset and live controller-level disconnect.
- [ ] Genuine healing/Ward in isolated world-boss session.
- [ ] Published TEST travel, cross-server reconnect, cloud
  persistence and production enablement remain deferred.

Receipt:
`docs/testing/combat-support-threat-candidate-2026-09-21.md`.

## Earlier 21 September local aggro/Taunt gate (historical)



- [x] Shared per-enemy ThreatService: nearest fallback before positive
  threat; highest eligible threat afterwards; distance tie-break only.
- [x] Actual applied health damage generates threat for the exact
  hostile target; threat is isolated between enemies.
- [x] Zero-damage Fighter Taunt is learnable/rankable, server-targeted
  and adds configured threat without fake damage/contribution.
- [x] ThreatService focused contract: **14 assertions PASS**.
- [x] Real two-client normal Marauder aggro:
  nearest → first damage → higher damage → real Taunt →
  ThreatDrop suppression → threat reacquire:
  `VERIFIED_MULTIPLAYER_PASS`.
- [x] Real two-client world-boss aggro:
  nearest → first damage → threat beats distance → higher damage →
  real Taunt: `VERIFIED_MULTIPLAYER_PASS`.
- [x] Real client Taunt logged `SKILL ACCEPT Taunt`,
  authoritative hit confirmation and `THREAT TAUNT` for both normal
  Marauder and guardian.
- [x] Dead highest-threat member is removed from target eligibility
  for both normal enemy and world-boss controllers:
  `DEAD_TARGET_FALLBACK_PASS`.
- [x] Fighter Trainer catalogue: **12 assertions PASS**.
- [x] Same runtime source retained six Rojo builds, profile exit
  **18**, reward retry **17 Base + 17 Dungeon**, professions
  **14/14**, Dungeon backend **30/30**, one-hit lethal reward and
  existing two-client world-boss regressions.
- [ ] Genuine healing/ward threat policy and real support-skill
  multiplayer acceptance remain pending.
- [ ] Four-player aggro roles, multi-enemy room behavior, full wipe
  reset, and real controller-level disconnect tests remain pending.
- [ ] Published TEST/cloud/cross-server work remains deferred.

Runtime acceptance:
`9c744d0cfe4ecabd5b372229e446ceadc6653861`.
Death-fallback test head:
`e041bf2203c8b73b0c1c9b59aebc175a2c8cbddd`.
Receipt:
`docs/testing/combat-aggro-threat-taunt-local-2026-09-21.md`.

## Earlier 21 September local backend checkpoint (historical)

## 21 September 2026 — LOCAL-ONLY boss combat/recovery continuation

- [x] First-and-only legitimate lethal boss hit persists server-side
  contribution and earns one weekly reward, immediate duplicate zero:
  corrected real-client one-attack Play at
  `5b7edc2675fd8fc6e9b6d0908bdf263742cf88b6` PASS.
- [x] Earlier post-callback existing client-combat/two-client boss
  Play and prior target-filter, weekly-reward-retry and profile-exit
  suites passed on the earlier tested source.
- [x] Existing failed-save reward retry: Base **17 assertions** and
  Dungeon **17 assertions** passed on the earlier tested source;
  separate previously tested profile-save departure **11 assertions**.
- [ ] Expanded lethal-target bridge assertions, post-save lease-release
  failure recovery test and full latest-head regression remain
  **pending** because the desktop became unavailable.
- [ ] Genuine two-client healing or Ward skill during the encounter
  remains pending. The experimental MageHeal fixture failed and
  was reverted; server Mend now records actual positive healing
  but has no fresh dedicated client-skill acceptance.
- [ ] Four-player party/full-wipe/independent return and additional
  in-memory failure-injection regressions remain local follow-up.
- [ ] Published TEST transport, true new-server same-account reconnect
  and cloud DataStore/MemoryStore deliberately deferred at user request.

Receipt: `docs/testing/weekly-world-boss-v154-local-backend-continuation-2026-09-21.md`.

## Earlier 21 September party resilience checkpoint (historical)

## 21 September 2026 — two-client world-boss party resilience

- [x] Opt-in primitive enclosed arena provides stable
  `WorldBossArenaSpawn`; normal Base/Dungeon projects remain unchanged.
- [x] Real two-client Studio Play: both clients record independent
  guardian damage through existing combat and defeat one shared boss.
- [x] Both real contributors receive independent weekly rewards once;
  immediate duplicate claims grant zero.
- [x] Real client-owned Humanoid death replicates server-side,
  persists member `Dead`, respawns into the same session as
  `Active`, and cannot create another reward.
- [x] One real Studio client leaves after completion while the other
  remains present; contribution/reward history remains intact.
- [x] Connected full-party wipe policy: each Dead member remains
  independently recoverable without rerolling the boss/event/week.
- [x] Negative integral Studio multiplayer IDs are accepted only under
  `RunService:IsStudio()`; zero/nonfinite/malformed identities stay
  rejected. Contribution focused suite now **20 assertions PASS**.
- [x] Final source: six Rojo builds, multiplayer
  `VERIFIED_MULTIPLAYER_PASS`, lifecycle/wipe **14 assertions**,
  Base travel **18**, Base return **22**, Dungeon session **33**,
  Base professions **14/14**, Dungeon backend **30/30**.
- [ ] Same-account network reconnect on a genuine new reserved server
  is not testable through local Studio replacement clients.
- [ ] Published TEST Base → ReserveServer boss → Base, real lease
  handoff and DataStore/MemoryStore recovery remain pending.
- [ ] Genuine two-client healing/ward skill execution during the boss
  fight remains pending; support authority has focused service coverage.
- [ ] Production scheduling, final boss phases/art/balance and live
  enablement remain explicitly out of scope.

Receipt: `docs/testing/weekly-world-boss-v154-party-resilience-2026-09-21.md`.

## Earlier 21 September real-combat checkpoint (historical)

## 21 September 2026 — real world-boss combat integration

- [x] Isolated world-boss compositions include the existing full
  Combat server/client runtime and Marauder Captain AI; ordinary
  prototype ArenaBuilder remains excluded.
- [x] Admitted world-boss characters use the frozen weekly encounter
  ID so guardian targeting is session-scoped.
- [x] World-boss damage contribution requires the exact authoritative
  guardian Model and admitted player; same-name/off-encounter target
  filtering: **7 assertions PASS**.
- [x] WorldBossCombatAuthority revalidates active membership,
  encounter identity, live guardian, undefeated event and support
  target before forwarding to the existing ContributionService.
- [x] Real unpublished client Play used normal CombatService attack
  input: real guardian health loss, persisted server contribution,
  guardian AI damage to the player, unassisted client boss defeat,
  verified weekly reward once, immediate duplicate reward zero.
  `VERIFIED_PLAY_MODE_PASS`.
- [x] Real Play exposed and fixed missing-event-state nil access and
  combat-event variable shadowing. Post-defeat reward grants retry;
  earned-but-unsaved reward blocks Base return.
- [x] Final source also passed six Rojo builds, boss default-off Play,
  contribution service **14 assertions**, weekly policy/factory
  **40 + 8**, Base professions **14/14**, Dungeon backend **30/30**.
- [ ] Dedicated production place still needs authored
  `WorldBossArenaSpawn`/basic arena and actual multi-client fight.
- [ ] Party death/wipe, disconnect/rejoin, independent return,
  published Base → ReserveServer boss → Base, real lease transfer
  and cloud DataStore/MemoryStore acceptance remain pending.
- [ ] Public schedule, final boss phases/art/balance and production
  enablement remain explicitly out of scope.

Receipt:
`docs/testing/weekly-world-boss-v154-real-combat-2026-09-21.md`.

## Earlier 21 September isolated travel checkpoint (historical)

## 21 September 2026 — isolated weekly boss travel and reward hardening

- [x] Six Base/Dungeon/world-boss Rojo compositions built,
  including published-style project definitions (not cloud publish).
- [x] Default-off Base boss gateway with server-owned event window,
  physical proximity, identity and ready-party checks. Default-off
  separate destination boots without a boss or open return prompt.
- [x] Fake reserved-server transport: 18 travel assertions PASS in
  Base and 18 in Dungeon. Routing-only data, destination binding,
  party membership and ordinary-place rejection verified.
- [x] Separate world-boss place/factory contract: 5 assertions PASS;
  ordinary Dungeon admission: 10 assertions PASS.
- [x] Server-verified defeated-member Base return: 22 assertions
  PASS, including failed-teleport rollback of the per-member
  return flag; other party members' session indexes remain intact.
- [x] Fixed real ContributionService response mismatch in weekly
  payout check: 14 actual-service assertions PASS in Base and
  14 in Dungeon for no/invalid contribution, real recorded
  damage, healing and in-memory persisted recovery.
- [x] Existing local weekly policy/factory (40+8), session
  persistence (33 each Base/Dungeon on final source), Base profession 14/14,
  Dungeon backend 30/30, and real-client Base crafting material
  chain Play passed on this travel-integration branch.
- [ ] **The dedicated place still lacks playable guardian AI and
  client combat/attack contribution wiring and arena anchor.**
  No live Base → reserved boss → Base teleport has been tested.
- [ ] Published TEST two-client encounter, full network
  disconnect/rejoin, cloud DataStore/MemoryStore and production
  release have not been performed. Event flags remain off.

See
`docs/testing/weekly-world-boss-v154-isolated-travel-2026-09-21.md`
and
`docs/testing/weekly-world-boss-v154-travel-hardening-2026-09-21.md`.

## Earlier 21 September session contract (historical)

## 21 September 2026 — frozen weekly boss session contract

- [x] `DungeonSessionService` issues exactly one server-owned
  world-boss snapshot for an existing authorized session; second
  issuance cannot reroll week or party.
- [x] Defeat requires existing server-tagged matching dead guardian,
  then persists defeat into the session InstanceState.
- [x] Fresh bridge/session/weekly service sharing an in-memory
  adapter rehydrates one frozen snapshot after simulated restart.
  Entry does not reopen merely because the group reconnects.
- [x] An outsider, invited non-contributor and abandoned member
  cannot claim a reward through the session bridge.
- [x] Existing server-certified member completion eligibility is
  required, then each player receives an independent once-per-week
  profile reward. Same-UserId save/reload cannot duplicate it.
- [x] Local Studio: **30 session assertions PASS** in Base and
  **30 PASS** in Dungeon; previous weekly policy 40 in each,
  guardian factory eight; Base profession regression 14/14 and
  Dungeon gameplay 30/30 PASS; four Rojo compositions build.
- [ ] Real Base entry gateway, dedicated reserved world-boss
  destination/admission, durable cloud server-handoff verification
  and contribution proof from real boss attacks remain pending.
  Ordinary dungeon portal/gameplay remains unchanged.
- [ ] Public schedule/rollout, actual published TEST/PROD,
  real-user DataStore, final guardian AI/art and balance remain open.

Receipt: `docs/testing/weekly-world-boss-v154-session-bridge-2026-09-21.md`.

## Prior 21 September weekly milestone (historical)

## 21 September 2026 — v1.54 weekly boss foundation

- [x] No automatic schedule or public entry enabled. Trusted explicit
  entry start/end, exclusive end, maximum two-hour window and Monday
  UTC reward-week identity: **40 assertions PASS in Base and 40
  in Dungeon**, including first/second week and invalid window.
- [x] Unique local encounter ID; server-approved loaded party
  (up to four), matching tagged dead guardian and saved character
  reward receipt. An outsider, living boss, mismatched instance
  and second reward within the same week are denied.
- [x] Actual guardian prototype factory: **8 assertions PASS**.
  Distinct `AncientGuardian` identity, no ordinary monster XP/gold,
  reused captain combat rig, default-off in all standard packs.
- [x] Four Rojo compositions, existing Base profession **14/14**,
  Dungeon gameplay **30/30** regressions PASS.
- [x] Real unpublished Dungeon Play test: client physically enters
  an injected temporary gateway inside the event window; guardian
  spawns; two assisted defeats grant 100 gold exactly once to that
  Dungeon player. Markers:
  `CLIENT_WINDOW_ENTRY_PASS`,
  `FIRST_WEEKLY_REWARD_PASS`,
  `NO_WEEKLY_REWARD_FARM_PASS`,
  `VERIFIED_PLAY_MODE_PASS`.
- [ ] **Actual Base portal → reserved dungeon server, durable
  instance/session admission, configured event schedule,
  contribution checks, real cross-server/TEST DataStore recovery,
  final boss phases/art and cloud release NOT implemented.**
  The physical gateway exists only in the disposable Studio fixture.
- [ ] Provisional 100-gold reward and two-hour maximum window
  require gameplay balancing and explicit rollout decisions.

Receipt: `docs/testing/weekly-world-boss-v154-local-foundation-2026-09-21.md`. Roadmap: `docs/roadmap/DungeonMMO_Roadmap_v1_54_Weekly_World_Boss_Foundation.md`.
All code/docs authored through GitHub; no publishing, main
merge, force-push or player production DataStore test.

## Previous v1.53 local regression checkpoint (historical)

## 21 September 2026 — interrupted crafting and local recovery

- [x] Unique request tickets; old disconnected craft cannot release
  the new same-UserId request or commit after preparing before leave.
- [x] Four Rojo compositions built after the guard code update.
- [x] Focused professions Base **14/14** and Dungeon **14/14**;
  21 guard assertions and 20 same-UserId save/release/reload/
  interrupted-request retry assertions in each composition.
- [x] Genuine two-client Base Play: server pauses a craft *after
  valid preparation*, real originating client leaves, server releases
  profile, the test driver reloads its same UserId in memory, old
  handler resumes without consuming ingredients or granting an
  output; peer stays connected and distinct replacement joins.
  Parent `VERIFIED_MULTIPLAYER_PASS`, child
  `INTERRUPTED_DISCONNECT_PASS`.
- [x] Regressions after ticketing: Base full material-backed
  crafting/rapid request fixture PASS, Dungeon wolf reward/retained
  corpse/client Skinning PASS, wider Dungeon gameplay 30/30 PASS.
- [ ] **Actual same-account Roblox network reconnect, same-account
  retry on a new server, cross-server profile leases and published
  DataStore persistence remain untested**. Studio replacement
  receives a distinct UserId; test-driver same-UserId reload is
  not an authenticated network reconnect.
- [ ] Final animal combat AI/art, default wolf encounter rollout,
  published TEST/PROD and real-player DataStore gates remain open.

Full evidence and early corrected test fixture failures:
`docs/testing/profession-v153-interrupted-reconnect-local-2026-09-21.md`.

## Previous local backend tests (historical)

## 21 September 2026 — v1.53 live profession and wolf milestone

- [x] `ForestWolf` factory contract: 10 assertions; separate server
  identity/tag and Marauder isolation. Registered archetype, no
  production pack opt-in.
- [x] Four Rojo compositions, Dungeon cleanup 11 assertions,
  Dungeon broad backend 30/30 after wolf source changes.
- [x] Real disposable Temple Room1: physical encounter trigger,
  two wolf factory spawns, assisted defeat, server rewards and clear,
  retained looted wolf corpse, real client prompt/one hide and
  disabled second claim. Not proof of unassisted or balanced combat.
- [x] Real Base client twelve material-backed crafts across four
  production professions to warded leatherbound gloves, including
  authentic station checks and server inventory consumption.
- [x] Base real client repeat enchant without materials rejected;
  same-client two rapid crafts with exactly one recipe's inputs
  produced only one bar. Actual overlap inside the guard is not
  independently established by this result.
- [x] Two-user in-memory corpse contest: 9 assertions, included in
  13/13 focused suites in both newly rebuilt Base and Dungeon.
- [x] Genuine two-client Studio Base Play: distinct profiles craft
  independently, contest one shared corpse for exactly one hide
  and one client leaves without disconnecting the other.
- [ ] Same-account reconnect after interrupted live craft, session
  transfer, real cross-server save/reload, animal-specific models/AI
  and actual default-pack rollout remain NOT TESTED.
- [ ] Published cloud TEST/PROD and real-player DataStore validation
  remain NOT AUTHORIZED and NOT TESTED.

See `docs/testing/profession-v153-wolf-and-crafting-local-acceptance-2026-09-21.md` for exact fixture files, logs and failed-then-fixed
test expectations. All local artifacts are unpublished and
Studio in-memory only.

## Prior 21 September results (historical)

## 21 September 2026 — animal-only Skinning Studio validation complete

- [x] Four Rojo compositions PASS with animal-only runtime code.
- [x] Base **12/12** and Dungeon **12/12** profession suites PASS,
  including **42** eligibility and **16** corpse-runtime assertions
  in each composition (363 focused assertions per composition).
- [x] Modified DungeonEnemyCleanup test **11 assertions PASS**;
  broad Dungeon backend matrix **30/30 PASS**.
- [x] Genuine Base Play-mode client-to-server RawHideCache prompt:
  successful first hide grant, then client node disabled and no repeat.
  Previous timeout resulted from expecting a second Gather response
  despite correct client-side personal-node depletion.
- [x] Genuine Base Play-mode temporary server-authored wolf corpse:
  no prompt while living/unlooted, real client prompt grants one hide
  only after death/loot, per-corpse claim and prompt disable PASS.
- [x] Actual Base Play-mode near/far Leatherworking/Enchanting request
  routing: far is rejected; near reaches service (MissingMaterials).
- [ ] Full authored animal dungeon encounter with actual combat/reward
  and retained-corpse client Skinning is not tested or implemented.
- [ ] Material-backed client crafting through final enchanted equipment,
  two-client contested corpse/craft concurrency, disconnect/retry and
  real-player DataStore/cloud TEST remain pending.

Actual Studio was used via the supported RunScript CLI after the
separate direct MCP-client probe could not reach the Studio session.
Only the authored GitHub test files were executed in disposable,
unpublished local places. Full receipt:
`docs/testing/animal-only-corpse-skinning-studio-verified-2026-09-21.md`.

## Historical staging checkpoint — before the above tests

## 21 September 2026 — animal-only Skinning backend staged; Studio gate OPEN

- [x] GitHub-only eligibility: explicitly server-tagged and allowlisted
  Beast identity; defeated, server-looted and unclaimed corpse required.
  Marauders/bosses and arbitrary unlisted monsters remain ineligible.
- [x] Server-owned, one-time hide grant through the existing
  ProfessionService; client proximity and living-character checks.
- [x] Explicitly eligible beast corpses remain visible for a limited
  skinning window after successful encounter rewards; other dungeon
  enemies retain their old immediate cleanup.
- [x] Four Rojo compositions built locally at
  `8655c7e19bc97a9b9c803fc011e2e5a3080c47f3`; clean fast-forward
  integration worktree.
- [ ] **Studio tests still unexecuted:** the new eligibility and
  corpse-grant focused tests and modified DungeonEnemyCleanupTest,
  full profession and broad regression runners, and actual Play-mode
  creature interaction. A direct Studio MCP probe returned
  `Unable to reach Roblox Studio right now`; Codex's Studio delegate
  reported a usage limit. Do not assign a PASS count.
- [ ] Existing Base RawHideCache scripted hold timed out in the prior
  fixture; the additional diagnostic version has not been run.
  RawHideCache remains an explicit temporary material cache, *not*
  an automatically skinnable monster.
- [ ] No existing enemy is factory-registered as an animal. Future
  animal enemies must receive authorized species/family/tag only
  from their server factory and be tested through real combat/loot/
  corpse/prompt/once-only grant before full Skinning acceptance.

Receipt:
`docs/testing/animal-only-corpse-skinning-pending-studio-2026-09-21.md`.
No cloud publish, real-player DataStore change or merge into main.

## 21 September 2026 — v1.53 local verification PARTIAL

- [x] Safely fast-forward clean Windows integration worktree to staged GitHub
  source `45a9bc25a185fcdb00579e977a22dc582eefc1ec`.
- [x] Four unpublished Rojo builds: Dungeon, Base, published-style
  Dungeon and published-style Base.
- [x] Focused profession suite in disposable local Dungeon and Base:
  10/10 passed in each; Base log records 305 assertions in the ten
  suites, including 12 craft-guard assertions.
- [x] Full in-memory real-service dependency chain to
  `warded_leatherbound_gloves`, equipped-input safety, duplicate
  consumption protection and persistence, covered by focused suite.
- [x] Fresh and legacy profile-state migration tests covered by the
  focused suite; wrong/fabricated minigame identity rejected there.
- [x] Dungeon broad gameplay backend matrix: 30/30 suites passed.
- [x] Generic Base Play-mode smoke: player, Base runtime, profile
  remote and optional release locks passed.
- [x] Real unpublished Base Play-mode client RemoteEvent range smoke:
  Leatherworking `cure_raw_hide` and Enchanting
  `inscribe_warding_rune` both reject too-far requests and route nearby
  requests to the service (`MissingMaterials`).
- [ ] The live `RawHideCache` prompt hold did not emit a Gather result
  in the first GitHub-authored fixture; it timed out. The *overall*
  first fixture is FAIL. Determine whether client scripted input,
  prompt visibility/range or server gathering caused the timeout.
- [ ] **Remaining actual Base player station acceptance**: real client
  one-time RawHideCache prompt, material-backed Leatherworking/
  Enchanting crafting to final equipment, overlapping same-player
  requests, independent clients and real disconnect/retry cleanup.
- [ ] Resolve or deliberately isolate Base-only unrelated Dungeon
  autorun test errors/warnings noted in the local validation receipt.

**Do not promote v1.53 to full acceptance on deterministic-only results.**
The generic Base Play smoke did not physically exercise new profession
stations. No cloud publish, real-player DataStore run or main merge.

Evidence:
`docs/testing/profession-v153-local-validation-2026-09-21.md`.
Staged implementation plan:
`docs/testing/profession-leatherworking-enchanting-pending-verification-2026-09-21.md`.
Roadmap:
`docs/roadmap/DungeonMMO_Roadmap_v1_53_Professions_Pending_Verification.md`.

## 20 September 2026 — v1.52 combat Event variety / cross-profession backend

- [x] Independently default-OFF new combat variation
  selects exactly one frozen after-Room2 Ambush (4) or
  Surge (8), Temple/Mine Depth2–4, using the generic
  CombatPack executor, saved plan and existing timed event.
- [x] 144 variation assertions: both seeds, both dungeons,
  all higher depths, legacy defaults, one Event/one Secret,
  spawn capacity, mismatched/unknown mechanic and boss
  executor rejection, stable interrupted-run recovery.
- [x] Actual assisted physical Temple Depth2 Ambush and
  Mine Depth4 Surge runs: walk new side bridge in/out,
  correct 4/8 count, per-enemy/Secret reward replay denial,
  full dungeon completion.
- [x] Two-client Temple and four-client Mine: concurrent
  entrance starts exactly one pack, actual mid-fight Studio
  disconnect preserves survivors and checkpoint,
  detached interrupted encounter recovers Pending,
  per-member combat and completion rewards persist once.
- [x] Fresh original optional-enabled Temple Depth2 six
  encounters and optional-disabled Temple Depth2 four
  required encounters physically pass unchanged.
- [x] 25/25 optional-focused, 30/30 general backend suites,
  four local Rojo build compositions PASS.
- [x] Bidirectional Blacksmithing/Alchemy recipe chain:
  46 new assertions for real material inventory mutation,
  correct minigame, equipped-item safety, missing material/
  dupe prevention and save/reload output. 7/7 profession
  focused suites PASS independently in local Base and
  Dungeon compositions.
- [ ] New Event mechanics remain default-OFF/local only;
  truly staggered waves, cave-in, enemy AI/environment
  hazards, Leatherworking and Enchanting, real secured
  station interaction, actual user DataStore migration,
  same-account cross-server reconnect, unassisted party
  balance and cloud TEST/PROD remain unaccepted.

Evidence: docs/testing/
phase4-nonboss-event-profession-chain-2026-09-20.md.
Roadmap: docs/roadmap/
DungeonMMO_Roadmap_v1_52_Event_Variations_And_Professions.md.

## 20 September 2026 — physical after-Room2 Event v1.51

- [x] Explicit, local-only Temple and Mine Depth2/3/4
  EventArenaLate/bridge/gate plus independent trigger,
  checkpoint and boss-spawn anchors; first Event and
  Secret physical slots retained. 85 structural/gate
  assertions PASS across all six combinations.
- [x] Late-Event gate remains closed after Room1; opens
  after the *saved* Room2 clear; unselected first Event
  and old Depth1 entrances remain sealed; recovery closes
  late gate if Room2 not Cleared.
- [x] Assisted actual walking Play mode: Temple Depth2 and
  Mine Depth4 physically enter/exit late arena, trigger
  Event and Secret, and clear full six/eight encounters
  with alternate boss/transaction replay receipts.
- [x] Two-client Temple Depth2 and four-client Mine Depth4
  independent Studio multiplayer runs: concurrent late
  trigger = one boss; real PlayerRemoving mid-boss keeps
  survivors and checkpoint; detached reconstruction
  retains Rooms1/2 and resets interrupted late boss
  Pending; connected members receive distinct optional
  and completion rewards exactly once.
- [x] Original after-Room1 optional-enabled six-encounter
  Temple Depth2 walking route and fully optional-disabled
  original four-room Depth2 route pass unchanged.
- [x] Fresh 24/24 optional-focused suites, 30/30 broad
  gameplay backend suites and four local Rojo builds PASS.
- [ ] New gate/geometry and template switches remain OFF
  in ordinary source. True network same-account reconnect,
  cloud TEST/PROD publish, unassisted party combat and
  new non-boss environmental events are not accepted here.

Dated parent/child log receipts and strict limitations:
docs/testing/phase4-late-event-physical-multiplayer-2026-09-20.md.
Latest roadmap:
docs/roadmap/DungeonMMO_Roadmap_v1_51_Late_Event_Physical_Acceptance.md.

## 20 September 2026 — configurable Event placement v1.50

- [x] Legacy EventAfterRoom1/SecretBeforeFinal remain the default,
  even for old run-state snapshots without the new template field.
- [x] Independently opted-in, eligible Depth2–4 runs freeze a
  deterministic EventAfterRoom2 placement with a unique encounter
  and separate EventArenaLate physical-room identity.
- [x] 274 assertions: late Event follows two required encounters;
  invalid/unsupported templates fail closed; one Event and one Secret
  per run; duplicate optional physical slots are rejected; interrupted
  late Event reconstructs Pending without changing the saved room.
- [x] Missing, mismatched or unverified late placement is refused
  with OptionalBossContentUnavailable, not silently remapped to
  the old EventArena.
- [x] 23/23 optional-focused suites and 30/30 broad gameplay backend
  suites PASS; all four local Rojo compositions built successfully.
- [x] Fresh original Temple Depth2 Event/Secret assisted walking
  Play mode PASS; fresh alternate-boss Temple Depth2 route and two
  encounter-scoped reward replay checks PASS.
- [ ] EventArenaLate still lacks a registered physical arena,
  gate/bridge, trigger and spawn. Its synthetic planner tests are
  NOT a physical/party Play-mode acceptance for the late route.
- [ ] Environmental event types, normal-health combat, true same-user
  network reconnect and TEST/PROD cloud release remain separate.

Evidence: docs/testing/
phase4-optional-event-placement-templates-2026-09-20.md.

## 20 September 2026 — dynamic optional boss variants

- [x] Server-only opt-in OFF by default; Depth2–4 and original optional
  runtime release flags untouched; old Event/Secret selected without opt-in.
- [x] 2,205 assertions for frozen variant/eligibility combinations
  in Temple and Mine, Depth1–4; invalid saved identities fail closed,
  recovered interrupted encounter retains original variant.
- [x] 232 exact Secret discovery, replay, window-expiry and deferred
  backtrack assertions for original and alternate identities.
- [x] 80 same-factory Event/Secret/returning-miniboss independent
  reward assertions, including persisted monster-history replay.
- [x] 22/22 optional-focused, 30/30 broader backend suites and four
  local Rojo compositions PASS.
- [x] Assisted physical alternate-boss route and reward replay PASS:
  Temple Depth2 (6 encounters) and Mine Depth4 (8 encounters).
- [x] Existing variant-disabled Temple Depth2 physical route PASS.
- [x] Four-client Mine Depth4 alternate-boss Play mode PASS:
  duplicate concurrent Event spawn blocked; real mid-Event disconnect
  preserves other 3; optional and later miniboss with same factory
  earn different receipts for each survivor; final completion replay
  blocked for all three recipients.
- [ ] Dynamic variants use implemented boss placeholders, not new art,
  an arbitrary number of Event slots or a new weekly scheduler.
- [ ] True same-user network reconnect, real cloud TEST/PROD release,
  unassisted higher-depth combat and actual player DataStore writes
  remain unverified and intentionally deferred.

Logs: docs/testing/
phase4-dynamic-optional-boss-variants-2026-09-20.md.

## 20 September 2026 — higher-depth multiplayer lifecycle

- [x] Two-client Temple Depth2 and four-client Mine/Temple Depth4 shared
  run, one Event boss despite simultaneous entry, actual disconnect
  mid-Event and peer/3-member continuation to completion.
- [x] Two-client Temple Depth4 and four-client Mine Depth2 mid-Secret
  disconnection: one Secret boss, preserved checkpoint/ongoing encounter,
  remaining party continues and completes.
- [x] Strict follow-up Temple Depth2 2→1 and Mine Depth4 4→3 runs:
  persisted completion recipient sets match connected surviving members;
  a reconstructed CompletionService returns already_applied and does
  not change per-member Gold or reward history.
- [x] Fixture-only previous-depth progression bootstrap uses
  DungeonDifficultyProgressionService; real higher-depth completion
  remains blocked if a profile lacks its prior clears.
- [x] Service-level 1/2/4-member party wipe/automatic revive and
  authoritative Event checkpoint tests: 392 assertions PASS.
- [x] Fresh 19/19 optional-focused and 30/30 gameplay backend suites;
  all four local Rojo compositions build successfully.
- [ ] Actual same-account network rejoin/new reserved-server recreation,
  physical in-Play whole-party death/revive and manual unassisted
  higher-depth party combat remain distinct acceptance gates.
- [ ] Cloud TEST/PROD publish and higher-depth release flags remain
  deliberately unchanged.

Receipts: docs/testing/
phase4-higher-depth-multiplayer-lifecycle-2026-09-20.md.

## 20 September 2026 — higher-depth optional physical integration

- [x] Temple and Mine Depth2/3/4 TEMP geometry: level side bridge
  floors, open main-room wall, depth-specific checkpoint, trigger and
  boss spawn; original required rooms remain intact.
- [x] Active-depth entrance gating: 139 assertions; unused Depth1
  side bridges remain sealed while opted-in Depth2–4 routes play.
- [x] 18/18 optional-focused suites; 30/30 gameplay backend suites.
- [x] Six separate physical walking Play-mode scenarios pass both
  optional bosses and dungeon completion: Temple/Mine Depth2/3/4,
  with six/seven/eight encounters respectively.
- [x] Mine Depth4 physically bypasses Secret, backtracks to clear it,
  then completes the pending Final using TEMP-only spawn deferral.
- [x] Optional-disabled Temple Depth2 original four-room route PASS.
- [x] All four local Rojo build compositions succeed.
- [ ] Unassisted manual combat, true cross-server same-account rejoin
  and cloud release verification remain separate.
- [ ] Higher-depth production release flags remain OFF; TEMP test
  layout registration is not published.

Evidence:
docs/testing/phase4-depth2-4-optional-physical-playtest-2026-09-20.md.

## 20 September 2026 — per-depth Event/Secret integration

- [x] RED → GREEN: Secret gate prerequisite uses the actual preceding
  required room in the frozen encounter order, not always Room2.
- [x] RED → GREEN: both Temple and Mine placeholder side bridges are
  managed by the existing server-owned gate controller.
- [x] Two dungeons × four depths × four Event/Secret selection cases:
  712 assertions PASS using synthetic higher-depth slot bindings.
- [x] Per-depth saved entry-time Event-window expiry and Secret
  independence after new server-controller construction: 116 PASS.
- [x] Shared side-gate and recovery test: 32 assertions PASS.
- [x] 17/17 optional-focused suites; 30/30 gameplay-backend suites PASS.
- [x] Fresh assisted Temple/Mine Depth1 optional physical route PASS.
- [x] All four local Rojo compositions built successfully.
- [ ] Higher-depth optional physical routes and bridge geometry remain
  unregistered; the synthetic tests do not establish physical play.
- [ ] Cloud TEST verification, true same-user reconnect and PROD
  remain intentionally deferred.

Evidence: docs/testing/
phase4-optional-depth-events-and-side-gates-2026-09-20.md.

## 20 September 2026 — full depth-ladder progression

- [x] Temple/Mine Depth1–4 3/4/5/6 encounter plans, Depth4 previous
  bosses as minibosses and distinct final boss identity.
- [x] Fresh 454-assertion saved-profile/session ladder integration PASS;
  five focused Studio suites PASS.
- [x] Actual completion service commits one reward/unlock per depth;
  repeated commit does not duplicate rewards or progress.
- [x] Reconstructed Depth4 interrupted miniboss returns Pending with
  prior clear and persisted checkpoint intact.
- [x] Four local Rojo compositions, 30/30 gameplay backend suites and
  Base Play-mode regression PASS.
- [x] One fresh assisted Temple Depth2 physical route PASS; older six
  individual higher-depth Temple/Mine physical cases remain documented.
- [ ] Remaining five physical routes were NOT revalidated as fresh by
  the stopped multi-Play runner; the unsupported runner was removed.
- [ ] Unreleased Depth2–4 entry still fails actual content-readiness
  checks; no cloud/production enablement or unassisted combat acceptance.

Evidence:
docs/testing/phase4-depth1-4-progression-integration-2026-09-20.md.

## 20 September 2026 — full saved-session recovery

- [x] Fresh 15/15 focused optional-boss Studio suites PASS.
- [x] New 42-assertion two-member, multi-restart service-level
  recovery suite PASS: frozen eligibility, checkpoint, interrupted Event,
  Final and deferred Secret, physical entrance gates, idempotent reward.
- [x] Fresh assisted Temple physical backtracking regression PASS.
- [x] User reports manually defeating both optional bosses solo;
  the earlier failed automated injured-solo case is historical.
- [ ] Actual same-account Roblox network rejoin and reserved-server
  reconstruction are not proven by service-level emulation.
- [ ] Cloud TEST release verification remains intentionally deferred.

Detailed evidence:
docs/testing/phase4-optional-full-session-recovery-2026-09-20.md.

## 20 September 2026 — consecutive optional-boss gameplay

- [x] Two ordinary-health Studio players defeat Event followed by Secret
  using normal client combat, with surviving party members.
- [x] A separate two-player run confirms server-accepted Dodge and
  equipped healing skill (+32 total HP) between the two boss encounters.
- [x] The defensive/healing run defeats Secret and passes the assisted
  final-room completion check.
- [ ] Single injured survivor defeating Event then Secret remains
  unproven: the earlier no-recovery solo attempt FAILED.
- [ ] All-room unassisted combat, manual navigation, same-account rejoin
  and cloud TEST acceptance remain separate.

Receipts: docs/testing/
phase4-optional-boss-consecutive-skill-defense-2026-09-20.md.

## 20 September 2026 — optional boss normal-combat acceptance

- [x] Real client combat defeats Temple Event at ordinary player HP.
- [x] Real client combat defeats Temple Secret in a separate healthy
  two-client run with no direct boss HP manipulation.
- [x] Secret normal-combat fixture completed final dungeon progression
  with assisted prerequisite/final-room combat and reward replay checks.
- [ ] Same injured survivor beating Event then Secret without recovery:
  local attempt FAILED; player died before Secret was defeated.
- [ ] Complete ordinary-health unassisted combat across every room,
  normal healing/dodge use, manual player navigation and true rejoin.

Evidence: docs/testing/
phase4-optional-boss-normal-combat-playtest-2026-09-20.md.

## 20 September 2026 — optional boss real two-client local fixture

- [x] Two distinct local Studio clients in a shared eligible Temple run.
- [x] Simultaneous Event entry spawns one boss, not two.
- [x] Real mid-Event PlayerRemoving retains connected peer, active Event,
  checkpoint and frozen plan.
- [x] Detached interrupted-Event reconstruction returns Event Pending;
  prior Room1 stays Cleared.
- [x] Survivor clears Event then Room2, Secret boss and final boss.
- [x] Event reward replay returns already_applied; Secret reward recorded.
- [x] Fresh test re-run parent+child Studio logs report PASS.
- [ ] Actual same-account reconnect or reconstructed live server after
  interrupted boss remains untested.
- [ ] Unassisted combat/balance and any published-cloud acceptance deferred.

Evidence: docs/testing/
phase4-optional-boss-two-client-playtest-2026-09-20.md.

## 20 September 2026 — optional-boss lifecycle local follow-up

- [x] RED then GREEN: unsaved normal/Event startup must reset Pending.
- [x] RED then GREEN: unsaved Secret skip must not advance main route.
- [x] 14/14 focused Studio suites; 11 fault, 24 two-member recovery,
  28 four-way eligibility/physical-gate assertions PASS.
- [x] Five temporary Rojo build compositions succeed.
- [x] Local Temple: gate prerequisites, deferred Secret, final room PASS.
- [x] Optional rollout-locked normal Dungeon Play-mode baseline PASS.
- [x] Studio two-client disconnect: session, checkpoint and peer preserved.
- [ ] Two-client Event/Secret boss fight, reward replay and rejoin test.
- [ ] Same-account real network reconnect or cloud TEST release verification.

Detailed receipts: docs/testing/
phase4-optional-boss-lifecycle-hardening-2026-09-20.md.

## 20 September 2026 — optional gate recovery follow-up

- [x] Existing server-owned Event/Secret gates present on integration branch.
- [x] Fresh TEMP TEST Temple and Dungeon test Rojo builds completed.
- [x] Focused Studio optional tests: 13/13 suites PASS.
- [x] Entrance gate unit regression: 16 assertions PASS, including
  recovery reopen, incomplete Room2 fail-closed and restored Secret access.
- [x] Fresh TEMP physical Temple route rerun: both gates initially closed,
  Room1/Event and Room2/Secret prerequisites, Secret backtrack and final
  room completion PASS (assisted fixture). Log:
  20260920T151909Z_Studio_C434B_last.log.
- [ ] Cloud TEST Dungeon gate version verified after HTTP 429 attempt.
- [ ] Current cloud TEST Dungeon saved and version noted before republish.

Evidence: 20260920T151636Z_Studio_1BE9F_last.log and
phase4-test-temple-optional-entrance-gates-2026-09-20.md.

## 19 September 2026 — combined Phase 4 TEST Temple + restored HUD integration

**Active new worktree/branch:** DungeonMMO_Phase4_HUD_Integration_v1 /
wip/phase-4-test-hud-integration-v1. The isolated merge
43e175f4f2ad4fb3140a36a0ae99ccde49d11825 joins the backend parent
f00e581 and saved UI parent 7fa63fb; both original branches and worktrees
remain untouched. Pushed immutable source checkpoint tags:
phase4-before-hud-integration-backend-20260919 and
phase4-before-hud-integration-ui-20260919. All three documentation
conflicts retained BOTH historical branches' text.

The original framed profile/portrait, bottom-right menu, six-slot Dungeon
hotbar, contextual Inventory/Skills/Guild windows and redesigned dungeon
objective/boss/reward/revive HUD have been restored to the TEST candidate.
The Base intentionally has no Dungeon combat hotbar. Both TEST Temple and
sync-only Lobby build compositions contain their matching UI source.

**Fresh proof:** six Rojo compositions and 559 source+41 original Studio
runner Luau files compiled; 11/11 focused optional suites; Base live
regression 107 test-pass markers (four Roblox Controls Emulator plugin
errors); Dungeon live regression 221 test-pass markers and zero Creator
errors. The restored Dungeon HUD live-client test passed framed/menu/hotbar,
boss animated bar, rewards and revive with zero Creator errors. The Base
live-client test passed framed/profile/menu/expedition UI, exclusive
Inventory/Skills/Guild open and close (same Controls Emulator plugin
errors). The exact combined TEST Temple composition passed both local
published-ID simulations for Depth1 optional arenas and Depth4 physical
bindings; those runs logged a built-in Roblox ChatScript SetCore startup
error, not a game-code assertion failure. Final visual/playtest acceptance
is STILL OPEN.

**Cloud release boundary:** no TEST/PROD cloud publish or current cloud
place rollback backup has been verified. For the restored HUD release
candidate use scripts/powershell/Start-Phase4TestTempleHUDPublish.ps1 in the
integration worktree, NOT the old backend-only launcher. Before any TEST
publish, save/verify the currently published Temple Roblox place
117293035754309 and note its version history. The Lobby
134132328219009 is sync-only: never overwrite its authored map with
the standalone local Rojo sync file. No Mine place exists.

Detailed preserved evidence and remaining manual gates:
docs/testing/phase4-restored-hud-test-integration-2026-09-19.md.


## 19 September 2026 — TEMP playable physical layouts, both dungeons Depth1–4

This checkpoint supersedes the older **geometry-only** placeholder status
below; the separate editable `.rbxlx` remains geometry-only, while the
**source-generated, explicitly opted-in unpublished Studio** layouts now have
real runtime physical bindings. Temple/TestDungeon and AbandonedMine each
passed all three 4/5/6-room Depth2/3/4 physical encounter sequences, including
Depth4 three returning minibosses + final boss. Both dungeons' Depth1
Event/Secret fight, skip and on-foot optional-room traversal cases also
passed. Combat kills and high-depth player health were assisted in these
fixtures; these are not unassisted player combat/release acceptance.

- Source up to `e3b3022` passed four Rojo compositions, 549 source and
  30 Studio runner compilation checks, and all 11 focused edit-mode suites.
- Base fresh regression passed, 107 PASS markers and zero Creator errors.
  Two ordinary Dungeon regression attempts failed intermittent pre-existing
  combat-test startup deadlines despite live baseline success. Only those
  test waits were extended to 25 seconds. A fresh Dungeon regression at
  `37cef9b` passed the player and dummy assertions, 221 PASS markers, and
  zero Creator errors.
- Explicit unpublished Studio-only opt-in:
  `DungeonMMOEnvironmentMode=Synthetic`,
  `DungeonMMOPlaceholderPhysicalContentEnabled=true`,
  `DungeonMMOPlaceholderPlayableEnabled=true`; Depth1 optional physical
  slots require the separate `DungeonMMOPlaceholderOptionalPlayEnabled`
  opt-in. Runtime optional-boss eligibility/release is still separately
  locked; do not copy TEMP fixture overrides into live source.
- The shared production content catalogue still only registers Depth1;
  higher-depth `RuntimeReleaseEnabled` and both
  `OptionalBossRuntimeEnabled` values remain false. No main merge,
  production or TEST Roblox publish, or DataStore mutation occurred.
- Full log receipts, scenario IDs, code paths and remaining limits:
  `docs/testing/phase4-placeholder-playable-layouts-closeout-2026-09-19.md`.
  Final authored room geometry, ordinary combat/balance/UI, same-user
  reconnect and release acceptance remain separate gates.


## 19 September 2026 — replaceable dungeon physical placeholders available

- Editor-ready **geometry-only** Studio scene:
  `content/placeholder/DungeonMMO_PhysicalBlockouts_v1.rbxlx`.
  It includes separate Temple and Mine EventArena/SecretArena Models, walkable
  bridges, and unregistered Depth2/3/4 room/corridor previews (330 editable
  parts in 62 models). Studio static geometry verification passed.
- The source builder is
  `src/ServerScriptService/Dungeon/DungeonPlaceholderPhysicalContent.luau`;
  its opt-in synthetic Studio bootstrap can preview current Depth1 with
  placeholders while leaving both optional boss flags false and higher-depth
  physical layouts unregistered.
- **This is a replaceable blockout, NOT final authored release geometry or
  playable high-depth content.** The standalone editor scene has no runtime
  scripts and its visual anchor markers are not registered live bindings.
  Keep encounter/anchor identities when replacing with meshes/models.
- Usage/validation and limitations:
  `docs/testing/phase4-physical-placeholders-2026-09-19.md`.
  No merge to main, TEST/PROD publish or optional-boss rollout occurred.

## 19 September 2026 — remaining release gates: local proof, NOT release acceptance

The earlier four-step **backend** checkpoint below remains valid. New
TEMP-only Play-mode scripts have now additionally verified: real simulated
client leave and a separate client's arrival in Base, actual Dungeon
PlayerRemoving persisting a disconnected member while its peer/plan/checkpoint
remain active (the Studio party session uses a fixture-only override),
on-foot walking through all five synthetic Temple and Mine encounters without
per-room teleport, and one standard client basic attack reducing the live
Temple Event boss from 144 to 134 health. Boss combat and progression other
than that single attack still used explicit fixture assistance.

- Latest new fixture source: 0c2251633b70f92314abc4d0ec9d4fd50bb1dbe4.
- Evidence: docs/testing/phase4-remaining-release-gates-local-proof-2026-09-19.md.
- The departed Studio client's replacement has a **different UserId**; a true
  same-account rejoin, published cross-place transfer and production group
  admission have NOT been exercised. Real authored side rooms, an entire
  unassisted boss fight and visual/UI acceptance also remain unverified.
- Optional-boss rollout remains disabled; no main merge, TEST/PROD publish
  or production DataStore change is approved by these local fixture results.
- Next gated action: obtain explicit permission before using the isolated
  published TEST environment for same-account reconnect and cross-place tests.
  Do not mark Phase 4 release accepted on the basis of the local probes.

## Current checkpoint — 19 September 2026: four backend steps verified

The following supersedes the earlier Step 2-only status; historical evidence
remains below. **Gameplay/test source**: 3700dba7c6124e3401b615ce126d80cb7f1edb88.
**Final normal-regression/static source**: c86a90471cc3c36bbd9437ada685f4377d7e2ebe.
Branch: wip/phase-4-event-secret-policy-v1, isolated from main, UI and art.

- Recovery: event window, plan, discovery and cleared/skipped encounters survive
  session/controller reconstruction; interrupted boss returns to Pending;
  duplicate reward replay is blocked. Live Temple fixture simulated member
  disconnect/reconnect while the actual Studio player remained connected.
  **A real network leave/rejoin or cross-place handoff is NOT proven.**
- Mine: TEMP Play-mode fought-secret and skipped-secret paths both completed.
  Skipping persisted without secret discovery or secret reward.
- Four bosses have different server-authoritative two-phase attack patterns
  using existing Captain pose, telegraph, hit and defence systems. TEMP Temple
  and Mine combat fixtures passed with test-assisted positioning and defeats;
  natural battle balance and presentation are not proven.
- 11/11 focused Studio edit-mode suites passed on 3700dba. At c86a904, all
  four local Rojo compositions built; 547 Lua/Luau files parsed without error.
  Fresh unpublished Base/Dungeon Play baselines: respectively 108 and 222
  test PASS markers, zero Creator errors, and both release locks stayed false.
  Base Phase 3 stress passed (profiles=250, market=1000, replay=1000,
  guild=250, sessions=100, race_roundtrips=100).
- Evidence: docs/testing/phase4-optional-boss-four-backend-steps-closeout-2026-09-19.md.
- Canonical working roadmap is docs/roadmap/DungeonMMO_Roadmap_v1_45.docx
  (SHA-256 349d8a568856091ec2dbdadfde4b7785f608e65d2ac8f2429c838d9a86a943ac);
  roadmap index docs/roadmap/README.md. DOCX structural validation passed;
  visual page-render QA is still pending following a stalled Word export.
  TEMP-only synthetic fixtures do not imply authored side-arena acceptance.
  OptionalBossRuntimeEnabled remains false; higher-depth physical layouts
  remain unreleased. Do not merge to main or publish based on these tests.
- Next release/content gates: genuine client/network reconnect, authored
  room traversal, unassisted combat and player-facing UI, multiplayer/cross-place
  admission and final release acceptance.

## Current checkpoint - 19 September 2026 Step 2 GitHub-first backend proof

This section supersedes the Step 1 status below; its validation details remain
historical evidence, not a statement about the current source.

- Active backend branch: wip/phase-4-event-secret-policy-v1.
- Step 2 code and test source validated at ae1ab32be03fe5c2ff9874f95df49a8c56ff069a.
  The former uncommitted work was preserved and pushed at bd83446. Later
  gameplay/test changes were committed directly using the Amidazs GitHub
  connector, then fast-forwarded into the clean isolated backend worktree.
- Server-only candidate event schedule and secret discovery, independent boss
  reward identities and optional book drops are implemented. Rollout remains
  disabled for both dungeons; no physical side arenas or higher-depth physical
  layouts have been registered.
- All four local Rojo builds passed; 544 Lua/Luau source files compiled with
  zero failures at ae1ab32. A fresh TEMP local Studio RunScript session passed
  eight optional-boss EDIT-MODE suites: RunState, Schedule, SecretDiscovery,
  Policy, Flow, Factories, ReleaseLock and Reward.
- Edit-mode tests are not a live Play-mode or physical/gameplay acceptance test.
  TEMP-only physical trigger/combat/reward/reconnect checks and broad
  Base/Dungeon Play-mode regressions remain before release consideration.
- Main, UI/art worktrees, published games and production data were not changed.
- Source-controlled runner: scripts/studio/optional_boss_focused_tests.luau.
  Detailed evidence: docs/testing/phase4-optional-boss-step2-backend-checkpoint-2026-09-19.md.
- Next: complete the live/physical acceptance gate separately; then continue
  backend-only work on distinct Event/Secret boss combat behaviour. No merge
  or publish is authorised by this checkpoint.

## Current checkpoint - 19 September 2026 step 1 validation

This section supersedes older active-branch, no-push and pending-Studio notes
below. Older gate sections are historical evidence, not current release status.

- Active worktree: C:/Users/Remko/Documents/Roblox/DungeonMMO_Phase4_EventSecretPolicy_v1.
- Branch: wip/phase-4-event-secret-policy-v1.
- Validated source: cb29a7c54637e371e1041ab68009c4951b579d00.
- GitHub feature tip independently verified at the same SHA on 19 September.
- Main and GitHub main remain a3c2625cfc53dbb1c2bb8d6ce17f5f3749809fa9;
  this backend branch is not merged into main.
- v1.44 is now committed on this feature branch. Its statements about the
  uncommitted issuer/test edits and an unpushed optional-boss branch are
  superseded by this checkpoint.
- Step 1 backend regression is VERIFIED on the exact committed source.
  This is not physical-content acceptance or rollout approval.
- Fresh Dungeon Studio: issuer 34, extended instance director 23, policy 49,
  optional flow 9, factories 24, release locks 14, readiness 70 assertions PASS.
- Dungeon server captured 248 PASS markers and zero errors; live admission passed.
- Fresh Base Studio: 132 PASS markers, issuer 34, readiness 70, party difficulty
  22 and party difficulty entry 32 assertions PASS; server/client errors = zero.
- Phase 3 stress PASS in both compositions: profiles=250, market=1000,
  replay=1000, guild=250, sessions=100, race_roundtrips=100.
- 539 source Lua/Luau files parsed with zero failures; four Rojo builds PASS.
- OptionalBossRuntimeEnabled remains false for both dungeons. Depth2-Depth4
  remain physically unregistered and release-disabled.
- No gameplay source changed in this validation step. Documentation/evidence
  changes remain uncommitted; no commit, push, merge or publish was performed.
- Known diagnostics: expected audit-sink failure injection in both runs;
  source-controlled fallback-animation notice in Dungeon. Neither is a test failure.
- Evidence: docs/testing/phase4-optional-boss-step1-validation-2026-09-19.md.

### Exact next action

At the step-1 user checkpoint, report the completed backend validation.
Next ordered step is Event and Secret gameplay rules: prepare a bounded design
for actual server event schedules, secret discovery conditions and reward
configuration, reusing existing issuance/session/reward authority. Define
reconnect/idempotency tests before implementation. No concrete schedule,
secret-discovery mechanic or new reward balance is approved by this record.
Distinct enemy/boss mechanics follows as the next substantial combat gate.
Keep physical release locked and the UI/art worktrees separate.

## Historical gate record

**Current phase:** Phase 4 - Content Alpha
**Canonical roadmap:** docs/roadmap/DungeonMMO_Roadmap_v1_44.docx
**Phase 3 gameplay release:** 84662948127eb1a37c9f184c6abbafe6f2daddb6

This file records accepted evidence and current gate status. It is not a
replacement for fresh test output when claiming a new result.

## Phase 1 - Combat prototype

**Roadmap status:** ACCEPTED

Previously accepted runtime coverage includes basic attack/swept melee,
blocking, parry, Guard Break, dodge invulnerability, Shield Bash, Mend channel
and cancellation, four-Marauder pressure, death/respawn lifecycle,
controller/mobile emulation and approximately 150 ms simulated round-trip
latency diagnostics.

Presentation remains placeholder quality and is intentionally deferred.

## Phase 2A - Core Base-to-Dungeon slice

**Roadmap status:** ACCEPTED

Accepted coverage includes separate Base/Dungeon builds, central profile/save,
DEV/TEST/PROD namespaces, leases/handoff, 1-4-player session contract,
reconnect/reconstruction, monster XP/Gold, room-start checkpoints, revive and
spectating/wipe flows, Marauder Captain, immutable completion eligibility,
exactly-once rewards, save-before-return, Base/Dungeon UI, reserved-server
teleport, Base -> Dungeon -> Base persistence, timed/manual return, abandon and
deliberate TEST teleport-failure recovery.

Live paid-revive activation remains disabled.

## Phase 2B.A - Progression Foundation

**Roadmap status:** ACCEPTED
**Accepted Git checkpoint:** `24dee751b87d831abe22cd046dd3b9934c566a56`

Accepted PASS families include profile migration, Level/AP/SP entitlement,
Attribute Config/Service, Skill Progression, Loadout, Proficiency, Progression
Damage, Mend Progression, Dungeon Progression Bridge and existing Phase 1/2A
regression families.

## Phase 2B.B - Gameplay + Base Progression

**Status:** ACCEPTED
**Accepted Git checkpoint:**
`ac9546c73d3f2f57221ae71b2f1e7a6ebcd35137`

### Base combined acceptance

- [x] Level 10 Profile HUD/trainer agreement.
- [x] Attribute preview/cancel and atomic spend flow.
- [x] proficiency/rank purchase flow.
- [x] six-slot rearrangement including intentional empty gaps.
- [x] exact later-slot placement, moves, replacement and uniqueness.
- [x] no-op slot clicks without selection and selection clearing after success.
- [x] Attribute TEST respec.
- [x] Skill TEST respec preserving proficiency/knowledge.
- [x] no red runtime errors reported.

### Dungeon combined acceptance

- [x] Arc Slash integration/PASS family.
- [x] first-clear Arc Slash reward/PASS family.
- [x] automatic-free-revive/PASS family.
- [x] first death performs forced three-second free revive.
- [x] second death uses normal defeated flow.
- [x] Captain first-clear awards the bound Arc Slash Skill Book.
- [x] fresh progression snapshot reports `BookOwned=true`.
- [x] fresh progression snapshot reports `ArcSlashFirstClear=true`.
- [x] relevant Phase 1/2A/2B.A regression families remain green.
- [x] no red runtime errors reported.

### Six-slot regression cause/fix

Sparse numeric RemoteEvent arrays lost later entries after an intentional nil
gap. Shared `LoadoutSnapshot.encode` produces six dense wire entries and uses
`false` for empty slots; persistent profile/loadout state remains sparse.

## Phase 2B.C - Persistence + Published Acceptance

**Status:** ACCEPTED
**Accepted code checkpoint:**
`4a82d7486e7455f7597a777e862393c5bbb56cfb`
**Merged accepted main:**
`8be005ff1ef87712bff8fde01d313fd2569771ac`

Published TEST acceptance confirmed:

- [x] fresh Level 1 profile = 5/5/5/5/5, 0 AP/SP, Mend R1 + Shield Bash R1;
- [x] each level gain grants exactly +1 AP/+1 SP;
- [x] Strength changes basic sword damage;
- [x] Vitality changes MaxHealth;
- [x] Spirit changes Mend;
- [x] Mend/Shield Bash proficiency caps at the next threshold;
- [x] DEV/TEST proficiency mutation changes proficiency only;
- [x] trainer rank purchase persists;
- [x] first Captain clear grants exactly one bound Arc Slash book;
- [x] return to Base preserves the book;
- [x] trainer consumes the book + 3 SP atomically and learns Arc Slash;
- [x] Arc Slash auto-fills the first free slot;
- [x] Character -> Skills swaps in Base;
- [x] active Dungeon encounter rejects swap and clear window accepts it;
- [x] Arc Slash requires one-handed sword and multi-target proficiency diminishes;
- [x] Attribute/Skill respec counters and allocation cannot mint points;
- [x] first death auto-revives after approximately three seconds at checkpoint;
- [x] later death uses paid/spectator flow;
- [x] Base -> Dungeon -> Base -> leave -> rejoin preserves the complete state;
- [x] reconnect/idempotency and duplicate protection remain correct;
- [x] fresh Base/Dungeon regressions remained green with no reported red runtime errors.

### Targeted published regression close-out

- [x] only one combat HUD/runtime presentation appears;
- [x] published sword attack presentation works;
- [x] only one Captain/boss runtime spawns;
- [x] shield presentation remains visible in published play;
- [x] shield arm remains behind the shield during Block and Shield Bash;
- [x] swept-volume dodge clearance prevents the under-monster/floor
  fall-through regression.

Detailed evidence is recorded in
`docs/testing/phase2b-gate-c-acceptance-record.md`.

**Phase 2B status:** FUNCTIONALLY COMPLETE.

## Phase 2C - Race/base-class definitions and class-specific trainer catalogues

**Status:** FUNCTIONALLY COMPLETE - PHASE 2C.E RANGER ACCEPTED / MERGED / PUSHED

Phase 2C.A is accepted, merged and pushed.

Phase 2C.C - Equipment Effects + Combat Integration is accepted, merged and pushed.

## Phase 2C.A - Race + Character Identity Foundation

**Status:** ACCEPTED

**Reviewed local-green checkpoint:**

`d13c5b8f834ab9642b0fb3f629bf05f46616e543`

### Task 12 local build and Studio regression

- [x] `git diff --check` clean before full local regression.
- [x] Base full Task 12 build succeeded.
- [x] Dungeon full Task 12 build succeeded.
- [x] Phase 2C.A Race Definitions PASS - 35 assertions.
- [x] Profile Schema/Migration PASS - 43 assertions.
- [x] Phase 2C.A Profile Migration PASS - 38 assertions.
- [x] Phase 2C.A Identity Service PASS - 58 assertions.
- [x] Attribute Config PASS - 14 assertions.
- [x] Attribute Service PASS - 30 assertions.
- [x] Progression Service PASS - 9 assertions.
- [x] Phase 2B Progression Service PASS - 42 assertions.
- [x] Progression Snapshot Builder PASS - 37 assertions.
- [x] Base Progression Controller PASS - 25 assertions.
- [x] Character Combat Stats PASS - 32 assertions.
- [x] Race Presentation Service PASS - 51 assertions.
- [x] Damage Service PASS - 15 assertions.
- [x] Basic Attack Timing Rules PASS - 25 assertions.
- [x] Critical Hit Rules PASS - 10 assertions.
- [x] Shield Bash Integration PASS - 17 assertions.
- [x] Arc Slash Integration PASS - 10 assertions.
- [x] Mend Service PASS - 9 assertions.
- [x] Defensive Combat Integration PASS - 42 assertions.
- [x] Dodge Direction PASS - 45 assertions.
- [x] Dodge Swept Clearance PASS - 8 assertions.
- [x] accepted Core/Base/Dungeon/Phase 2A/Phase 2B regression families remained green.

### Local manual Base/Dungeon regression

- [x] mandatory unresolved race selection.
- [x] incomplete identity blocks gated Base/Dungeon behaviour.
- [x] Human -> Fighter.
- [x] Human baseline 5/4/6/5/5.
- [x] Human Resolve.
- [x] Human Shield Bash + Mend.
- [x] Elf -> Fighter.
- [x] Elf baseline 5/6/4/5/5.
- [x] Elven Grace.
- [x] Elf Shield Bash + Mend.
- [x] Elf ears.
- [x] Elf ears survive respawn.
- [x] race presentation remains idempotent.
- [x] sword combo.
- [x] attack buffering.
- [x] Block/parry.
- [x] Dodge.
- [x] Shield Bash.
- [x] Mend.
- [x] Arc Slash.
- [x] no red runtime exception observed.

### Task 13 published TEST safety

- [x] reviewed Task 12 local-green candidate identified.
- [x] TEST environment confirmed.
- [x] Universe ID `10765241947` confirmed.
- [x] Starting Base Place ID `134132328219009` confirmed.
- [x] Test Dungeon Place ID `117293035754309` confirmed.
- [x] live paid revives remained disabled.
- [x] no PROD profile/DataStore path used.
- [x] no Robux spend.
- [x] no Task 13 monetisation changes.

### New Elf published persistence

- [x] fresh TEST race selection.
- [x] Elf -> Fighter.
- [x] Level 1.
- [x] baseline 5/6/4/5/5.
- [x] Elven Grace.
- [x] Shield Bash + Mend.
- [x] Elf ears in Base.
- [x] Base -> published Dungeon.
- [x] Elf ears in Dungeon.
- [x] normal sword/basic attack behaviour.
- [x] Block/parry.
- [x] Dodge.
- [x] Shield Bash.
- [x] Mend.
- [x] normal Dungeon completion.
- [x] Dungeon -> Base.
- [x] Elf / Fighter preserved after return.
- [x] ears preserved after return.
- [x] leave Experience.
- [x] rejoin Starting Base.
- [x] Elf / Fighter persisted.
- [x] baseline/passive persisted.
- [x] ears persisted.
- [x] skills/progression persisted.

### New Human published persistence

- [x] TEST profile reset to a fresh identity.
- [x] Human -> Fighter.
- [x] Level 1.
- [x] baseline 5/4/6/5/5.
- [x] Human Resolve.
- [x] Shield Bash + Mend.
- [x] Base -> published Dungeon.
- [x] normal sword/basic attack behaviour.
- [x] Block/parry.
- [x] Dodge.
- [x] Shield Bash.
- [x] Mend.
- [x] normal Dungeon completion.
- [x] Dungeon -> Base.
- [x] Human / Fighter preserved after return.
- [x] leave Experience.
- [x] rejoin Starting Base.
- [x] Human / Fighter persisted.
- [x] baseline/passive persisted.
- [x] skills/progression persisted.

### Published sensitive regressions

- [x] one combat HUD/runtime presentation.
- [x] published sword presentation.
- [x] one Marauder Captain runtime.
- [x] camera/view shield visible.
- [x] shield arm remains behind shield during Block.
- [x] shield arm remains behind shield during Shield Bash.
- [x] swept Dodge does not place player under floor.
- [x] swept Dodge does not place player inside monster.
- [x] first free revive works.
- [x] second death reaches normal defeated boundary.
- [x] live paid revive remains disabled.
- [x] Return to Base remains available.
- [x] Arc Slash Skill Book awarded to Inventory.
- [x] Arc Slash learning works.
- [x] Arc Slash loadout works.
- [x] Arc Slash knowledge/loadout persists after rejoin.

### Legacy published migration qualification

- [x] automated Profile Schema/Migration coverage green.
- [x] automated Phase 2C.A Profile Migration coverage green.
- [x] automated Identity Service coverage green.
- [ ] LIVE LEGACY MIGRATION PROOF WAIVED FOR THIS PRE-PLAYER TEST GATE.

The project owner deliberately waived the live legacy-character migration proof
because there are no real players and the current TEST data is disposable
developer/test data.

A live legacy migration proof remains required before any future release that
must migrate real existing player profiles.

### Known deferred issue

- [x] Skill Book reward is correctly granted to Inventory.
- [ ] Skill Book is not listed in the Dungeon Completed reward summary.

The completion-summary display issue is explicitly deferred to the next patch
and is not being treated as a reward/persistence failure.

### Acceptance close-out

- [x] Phase 2C.A acceptance evidence record created.
- [x] explicit user acceptance received.
- [x] Phase 2C.A marked ACCEPTED.
- [x] canonical roadmap updated through external Roadmap v1.30.
- [x] acceptance documentation committed at d3685be4a507f00e0b08bf8d948a41ecfa80b47.
- [ ] merge to `main` deliberately approved/completed.

Phase 2C.A was explicitly accepted by the project owner on 9 September 2026.

## Phase 2C.B - Equipment + Trainer Architecture

**Status:** DESIGN APPROVED - RED CONTRACT PREPARATION
**Starting baseline:** `19f8c31284da80dc87cf5d44560d366e48427888`
**Formal Phase 2C.A acceptance ancestor:** `ad3685be4a507f00e0b08bf8d948a41ecfa80b47`

### Design lock

- [x] user approved Phase 2C.B architecture.
- [x] equipment slots locked: Weapon / OffHand / Helmet / Body / Gloves / Boots.
- [x] Base-only server-authoritative equipment mutation locked.
- [x] race/base-class/class restriction architecture locked.
- [x] level/attribute restrictions deferred.
- [x] unique item instances / random affixes / durability deferred.
- [x] accepted combat sword/shield visual pipeline preserved.
- [x] data-driven Fighter trainer catalogue required.
- [x] Human Fighter trainer path required.
- [x] Elf Fighter trainer path required.
- [x] functional trainer UI required.
- [x] functional six-slot equipment UI required.
- [x] Dungeon Completed Arc Slash Skill Book summary presentation fix included.
- [x] PROD/Robux/monetisation remain out of scope.
- [x] art/dungeon-environment-prototype remains isolated.

### TDD RED bootstrap

The following checks are intentionally expected to fail before production
implementation:

- [x] Equipment Slots contract RED observed.
- [x] Equipment Rules RED observed.
- [x] Phase 2C.B schema-v5 equipment migration RED observed.
- [x] Equipment Service RED observed.
- [x] Phase 2C.B remote contract RED observed.
- [x] Trainer Catalogues RED observed.
- [x] Trainer authorization transport RED observed.
- [x] Completion Reward Presentation RED observed.

Do not mark any of these green merely because Rojo builds successfully.
Actual Roblox Studio runtime output is required.

### Critical migration guard

When schema advances to v5, only pre-v4 data is legacy. Accepted schema-v4
Phase 2C.A Human/Elf profiles must retain their identity and progression and
receive an empty/sanitized Equipment table.

### Acceptance status

Phase 2C.B is NOT accepted and no implementation PASS is claimed at this
checkpoint.
### Phase 2C.B GREEN candidate gate

- [x] Equipment Slots GREEN observed.
- [x] Equipment Rules GREEN observed.
- [x] schema-v5 equipment migration GREEN observed.
- [x] Equipment Service GREEN observed.
- [x] Phase 2C.B remote contract GREEN observed.
- [x] Trainer Catalogues GREEN observed.
- [x] Trainer authority GREEN observed.
- [x] Completion Reward Presentation GREEN observed.
- [x] accepted Base/Core regression families remain GREEN.
- [x] Human Fighter six-slot equipment visual check passed.
- [x] Human TEST Elven Helmet shows RaceRestricted.
- [x] Human Fighter trainer catalogue check passed.
- [x] Elf Fighter trainer catalogue check passed.
- [x] Elf TEST Elven Helmet is eligible/equippable.
- [x] Dungeon accepted regression families remain GREEN.
- [x] Dungeon completion summary lists a newly awarded Arc Slash Skill Book.
- [x] no PROD / Robux / monetisation action occurred.
### Phase 2C.B observed GREEN evidence

Date: 9 September 2026

Base:
- new 2C.B RED families all transitioned to PASS;
- Equipment Slots PASS: 24 assertions;
- Equipment Rules PASS: 9 assertions;
- Equipment Migration PASS: 20 assertions;
- Equipment Service PASS: 38 assertions;
- Trainer Catalogues PASS: 10 assertions;
- Trainer Authority PASS;
- Remote Contract PASS;
- Completion Reward Presentation PASS: 4 assertions;
- Phase 2B / Phase 2C.A migration and identity regressions remained green;
- Human/Fighter and Elf/Fighter equipment/trainer visual checks passed;
- race-specific TEST helmet restriction behaved correctly.

Dungeon:
- accepted combat/dungeon/revive/reward/progression regression families passed;
- Marauder Captain playthrough completed;
- completion rewards committed successfully;
- return window opened normally;
- Arc Slash Skill Book appeared in the completion reward summary.

Result:
GREEN and ready for explicit Phase 2C.B acceptance.

No commit, merge, push, Roblox publish, PROD or Robux action is part of this
GREEN evidence record.
### Phase 2C.B acceptance result

- [x] Fresh Base GREEN evidence reviewed.
- [x] Fresh Dungeon GREEN evidence reviewed.
- [x] Human/Fighter equipment and Fighter Trainer functional check passed.
- [x] Human TEST Elven Helmet correctly rejected.
- [x] Elf/Fighter equipment and Fighter Trainer functional check passed.
- [x] Elf TEST Elven Helmet eligible/equippable.
- [x] Dungeon combat/revive/completion regression check passed.
- [x] Arc Slash Skill Book appeared in the Dungeon Completed reward summary.
- [x] Project owner explicitly accepted Phase 2C.B on 9 September 2026.
- [x] No PROD, Robux, monetisation or art-branch action was used for acceptance.

Result: ACCEPTED. This checkpoint may now be committed on the Phase 2C.B
feature branch. Merge and push remain separate deliberate actions.
### Phase 2C.B local merge verification

- [x] Accepted checkpoint commit verified before merge.
- [x] Local `main` and `origin/main` verified at accepted Phase 2C.A baseline.
- [x] Deliberate no-ff merge used.
- [x] Gameplay/source tree remains identical to accepted Phase 2C.B checkpoint.
- [x] Base and Dungeon rebuilt from merged local `main`.
- [x] Art worktree remains untouched.
- [x] No Roblox publish, PROD, Robux or monetisation action occurred.
- [x] Push local `main` to `origin/main` completed after explicit approval.
### Phase 2C.B remote push verification

- [x] Remote `origin/main` verified unchanged immediately before push.
- [x] Server-side `refs/heads/main` verified unchanged immediately before push.
- [x] Accepted Phase 2C.B merge pushed without force.
- [x] Server-side main verified at the Phase 2C.B merge commit.
- [x] Accepted Phase 2C.B checkpoint verified reachable from remote main.
- [x] Final continuity-doc closeout changes only CURRENT_STATE/HANDOFF/TEST_MATRIX.
- [x] Final local main, origin/main and server main verified equal.
- [x] Final origin/main...main ahead/behind verified 0/0.
- [x] No Roblox publish, PROD, Robux, monetisation or art-branch action occurred.

## Phase 2C.C - Equipment Effects + Combat Integration

**Status:** ACCEPTED - MERGED / PUSHED; MANUAL ARC SLASH + AUTOMATED RUNTIME QUALIFICATIONS RETAINED
**Starting canonical GitHub server main:**
`8587c1546aa1689b69606f860fb5c18a847de617`
**Phase 2C.B accepted checkpoint:**
`fd0d73df70b97efc4b3fb241e2fc6e5061a3ed47`

### Design lock

- [x] reuse the accepted six-slot Equipment state;
- [x] one pure server-authoritative equipment stat resolver;
- [x] representative physical-damage / MaxHealth / crit-chance proof effects;
- [x] runtime Equipment snapshot locks the gear brought into the Dungeon;
- [x] Dungeon equipment mutation remains rejected;
- [x] newly looted equipment cannot change the active runtime snapshot;
- [x] runtime Equipment, not prototype Tool presence, owns weapon tags;
- [x] Base Equipment UI receives server-computed effects/previews/deltas;
- [x] prototype sword/shield presentation may follow equipped representative items;
- [x] no duplicate DungeonSession equipment store;
- [x] deferred scope remains out of 2C.C;
- [x] art branch remains isolated;
- [x] legacy live-migration waiver remains NOT PASS.

### Test-first contract preparation

The following focused tests were authored before their corresponding production
behaviour in the isolated candidate. This environment cannot execute Roblox
Studio tests, so these are **not** being marked runtime RED/GREEN yet.

- [ ] Equipment Stat Resolver runtime GREEN observed.
- [ ] Progression Runtime Equipment runtime GREEN observed.
- [ ] Equipment Weapon Requirement runtime GREEN observed.
- [ ] Equipment Service Effects runtime GREEN observed.
- [ ] Equipment Effect Presentation runtime GREEN observed.
- [ ] Equipment Presentation Rules runtime GREEN observed.
- [ ] Dungeon Studio Equipment Bootstrap runtime GREEN observed.
- [ ] Arc Slash integration regression GREEN observed.
- [ ] accepted Character Combat Stats regression GREEN observed.
- [ ] accepted Equipment Service regression GREEN observed.
- [ ] accepted Base/Core regression families GREEN observed.
- [ ] accepted Dungeon/combat/revive/completion regression families GREEN observed.

### Build and manual evidence

- [x] `git diff --check` clean in the real feature worktree.
- [x] TEMP Base Rojo build succeeded.
- [x] TEMP Dungeon Rojo build succeeded.
- [x] Base Equipment UI functional placeholder accepted; visual overhaul deferred.
- [x] Dungeon gear-aware sword/shield presentation passed manual play.
- [ ] brought-in gear affects combat as expected.
- [ ] newly looted gear does not affect the active run.
- [ ] Human/Elf, crit, attack-rate, Mend, Shield Bash, Arc Slash, revive and
      completion regressions remain accepted.
- [x] no PROD / Robux / monetisation / art-branch action occurred.

The project owner approved the exact local Phase 2C.C commit after fresh build
and manual evidence. Arc Slash was not manually exercised because it was not
unlocked/equipped, and the authored Roblox automated runtime tests were not
separately observed GREEN. Do not rewrite either limitation as a PASS.
Push, merge and publish remain separate explicit approval gates.

### Phase 2C.C acceptance close-out

**Accepted / merged / pushed checkpoint:**
`4f13a4c3868f9f36f09b7519f5e81ec947dbc9b8`

- [x] exact implementation boundary verified at 27 files.
- [x] `git diff --check` clean before the gameplay commit.
- [x] TEMP Base Rojo build succeeded.
- [x] TEMP Dungeon Rojo build succeeded.
- [x] Base Equipment Manager showed all six representative Marauder items.
- [x] visible aggregate matched `+13% Physical Damage`, `+25 Max Health`,
  `+1% Critical Chance`.
- [x] current Equipment UI explicitly accepted as a functional placeholder.
- [x] Dungeon equipment-aware sword/shield presentation accepted in manual play.
- [x] normal requested Dungeon combat/regression flow accepted in manual play.
- [ ] Arc Slash manually exercised during the Phase 2C.C acceptance run.
- [ ] Roblox automated runtime GREEN separately captured for the new 2C.C tests.
- [x] the two unchecked evidence limitations above were explicitly accepted and
  are retained as qualifications rather than rewritten as PASS.
- [x] project-owner Phase 2C.C acceptance received.
- [x] gameplay/docs commit created at the checkpoint above.
- [x] Phase 2C.C feature branch pushed.
- [x] `main` fast-forwarded and pushed to the exact accepted checkpoint.
- [x] GitHub `main` independently confirmed at the accepted checkpoint.
- [x] no Roblox place was published.
- [x] no PROD / Robux / monetisation action occurred.
- [x] separate art worktree remained untouched.
- [x] older dirty recovery worktrees were not cleaned or modified.

Phase 2C.C is formally closed as ACCEPTED / MERGED / PUSHED with the two
explicit runtime-evidence qualifications above. Those qualifications do not
invalidate the accepted architecture or manual/build evidence, but they must
remain visible in future handoffs.

The tracked repository does not name a later Phase 2C sub-gate. The next
engineering gate must be selected from the canonical external Roadmap v1.31
before new source work; do not infer a Phase 2C.D from numbering alone.
## Phase 2C.D - Mage Base-Class + Support Foundation

**Status:** ACCEPTED - GAMEPLAY MERGED / PUSHED
**Accepted gameplay checkpoint:**
`41ac374496f01a1685b62cfd6d6237d0a7e702ec`
**Starting baseline:**
`38feb4a3c15286c56a98ab686357b7cf30f2c693`

### Locked design / implementation

- [x] Human and Elf can begin as Mage.
- [x] Apprentice Arcane Wand is the Mage starter Weapon.
- [x] persistent Equipment owns ArcaneWand authority.
- [x] Spirit Orb is the free ranged Mage basic attack.
- [x] Spirit Orb combo is normal Orb -> normal Orb -> larger AoE Orb.
- [x] projectile travel/collision/target legality/damage are server-authoritative.
- [x] Intellect drives offensive magical scaling.
- [x] Mage runtime Mana foundation implemented.
- [x] Spirit drives Max Mana / regen / heal / Ward scaling.
- [x] Wind Strike is the starter charged damage skill.
- [x] Wind Strike charge may be cancelled by Block or Dodge before resource/cooldown commit.
- [x] Wand basic attacks movement-lock the Mage during committed phases.
- [x] Wind Strike movement-locks during charge/release/recovery.
- [x] Arcane Ward uses replace-not-stack absorption before Humanoid Health.
- [x] local Ward HUD exposes current/max shield.
- [x] Mage Heal supports aimed injured ally or injured self.
- [x] Human/Elf Mage Heal delivery differs between instant/HoT portions.
- [x] Fighter Mend is self-only and costs 20 Stamina.
- [x] Marauder Captain chase speed raised to 17.5 studs/second.
- [x] normal Marauder tuning left unchanged.
- [x] Dungeon Equipment remains run-locked and non-mutable.
- [x] schema-v5 persistence reused; no profile schema bump.
- [x] no mid-run Dungeon unequip control added.
- [x] no Roblox publish / PROD / Robux / monetisation / art-branch action.

### Package / build evidence

- [x] accepted gameplay commit contains exactly 49 files.
- [x] accepted gameplay commit parent is the Phase 2C.C closeout baseline.
- [x] gameplay worktree clean at commit.
- [x] feature branch pushed to the accepted gameplay checkpoint.
- [x] GitHub `main` fast-forwarded to the exact accepted gameplay checkpoint.
- [x] GitHub `main` independently verified after merge.
- [x] fresh TEMP Base Rojo build succeeded before the approved merge.
- [x] fresh TEMP Dungeon Rojo build succeeded before the approved merge.

### Manual Dungeon gameplay acceptance

- [x] Wand presentation visible.
- [x] Spirit Orb basic projectiles fire.
- [x] Spirit Orb damages enemies.
- [x] third basic Orb is visibly larger / AoE.
- [x] Mage cannot move through committed Wand basic attack phases.
- [x] normal movement returns after the committed attack.
- [x] Wind Strike visibly charges.
- [x] Wind Strike fires and damages.
- [x] Block/Dodge can interrupt the Wind Strike charge.
- [x] Arcane Ward works.
- [x] remaining Ward amount is visible.
- [x] Mage Heal works on injured self.
- [x] faster Captain pursuit prevents effortless permanent kiting.
- [x] normal dungeon completion still succeeds.

### Runtime-evidence qualification

- [x] stale Mage identity test expectation was identified.
- [x] stale expectation was updated to Wind Strike / Ward / Heal slots 1/2/3.
- [x] Base rebuilt after the test cleanup.
- [x] Dungeon rebuilt after the test cleanup.
- [ ] fresh Roblox Studio runtime PASS for the corrected Mage identity assertion separately captured.

The unchecked item above is an explicit evidence qualification, not a known
gameplay failure. Do not rewrite it as runtime GREEN without a fresh Studio run.

The earlier Phase 2C.C manual Arc Slash and automated-runtime evidence
qualifications also remain historical qualifications.

### Acceptance result

- [x] project-owner gameplay acceptance received.
- [x] local accepted gameplay commit created.
- [x] feature branch push explicitly approved/completed.
- [x] main fast-forward explicitly approved/completed.
- [x] no Roblox publish occurred.
- [x] gameplay feature worktree/branch preserved after merge.

Result: Phase 2C.D gameplay is ACCEPTED / MERGED / PUSHED at
`41ac374496f01a1685b62cfd6d6237d0a7e702ec`.

The external Roadmap v1.33 leaves Ranger as the remaining prototype starting
archetype. Ranger is the next **design** target; no numbered Phase 2C.E source
gate is locked until that design is explicitly approved.

## Phase 2C.E - Ranger Marksman-Hunter Foundation

**Status:** ACCEPTED - GAMEPLAY MERGED / PUSHED
**Accepted gameplay checkpoint:** `6fe47a178987dc51a75212692201651eb0167326`
**Starting baseline:** `86d27228977dd6c98bd404f12086e93ad94fbe9a`

### Design / architecture lock

- [x] Human and Elf Ranger use one shared data-driven Ranger class foundation.
- [x] Apprentice Longbow is the defining two-handed starter Weapon.
- [x] Longbow reserves OffHand without changing schema-v5 Equipment shape.
- [x] Longbow cannot use Block and does not receive fallback shield presentation.
- [x] Normal / Precision (~0.45 s) / Full Draw (~0.80 s) are free server-timed basics.
- [x] draw permits reduced movement rather than rooting the Ranger.
- [x] Dodge cancels an active draw without firing.
- [x] Precision/Full Draw add damage and critical-chance reward.
- [x] Dexterity leads Ranger ranged damage scaling.
- [x] Piercing Shot costs 20 Stamina and uses diminishing multi-target penetration.
- [x] Human Ranger retains more damage through Piercing Shot penetrations.
- [x] Crippling Shot costs 20 Stamina and applies non-stacking movement slow.
- [x] Elf Ranger receives stronger/slightly longer Crippling control.
- [x] Volley costs 30 Stamina and uses ground-targeted initial impact + short pulses.
- [x] normal arrows do not consume ammunition in this foundation gate.
- [x] persistent Equipment remains weapon authority; Dungeon Equipment stays run-locked.
- [x] special arrows/quivers/poisons/traps/pets and secondary classes remain deferred.

### Automated/runtime evidence observed during acceptance

- [x] Ranger Identity Tests PASS - 30 assertions observed.
- [x] RangerDefinitionsTest PASS observed.
- [x] RangerDrawRulesTest PASS observed.
- [x] RangerSlowServiceTest PASS observed.
- [x] Ranger Marauder slow movement rules PASS observed.
- [x] Equipment reservation contract PASS observed.
- [x] accepted Core/Progression/Equipment/Combat/Dungeon regression families remained green in the captured runs.
- [x] post-hotfix Base/Dungeon retest was reported fully passing by the project owner.

### Manual Base/Dungeon acceptance

- [x] Ranger appears and completes Human/Elf identity flow.
- [x] Apprentice Longbow is granted/equipped persistently.
- [x] OffHand is reserved for the two-handed Longbow.
- [x] Normal bow release works.
- [x] Precision release works.
- [x] Full Draw release works.
- [x] movement is reduced while drawing and restored afterward.
- [x] Dodge cancels a held draw and fires no arrow.
- [x] Piercing Shot works, including multi-target penetration/falloff.
- [x] Crippling Shot works on ordinary Marauders and the Marauder Captain.
- [x] Volley works as ground-targeted area damage.
- [x] normal Marauder and Captain pursuit/combat continue functioning.
- [x] full Dungeon clear and completion rewards succeeded.
- [x] follow-up functional hotfix removes Ranger fallback shield.
- [x] follow-up functional hotfix prevents accepted Block while Longbow is equipped.
- [x] stale Ranger-as-unknown identity assertion corrected.
- [x] Mage/Ranger definition tests no longer wait for a Combat tree in Base.
- [x] no PROD / Robux / monetisation action occurred.
- [x] no Roblox place was published.
- [x] art/dungeon-environment-prototype remained isolated.

### Deferred presentation

- [ ] final Ranger bow/draw/skill animations are intentionally deferred.
- [ ] final Ranger projectile/VFX/audio polish is intentionally deferred.

These are presentation-polish follow-ups, not failures of the accepted Ranger
combat/authority architecture.

### Carry-forward qualification

The pre-player live legacy migration proof waiver remains **not a PASS** and
must be replaced by real migration evidence before a release that must support
real existing player profiles.

**Phase 2C status:** FUNCTIONALLY COMPLETE after accepted Phase 2C.A-E.

## Phase 2 - Starting Base + Temple Integration

**Status:** ACCEPTED
**Accepted integration checkpoint:**
`c7fe89ebda3c97634c97e89ad12e52ec23983ae9`

Accepted evidence includes semantic environment-anchor integration, authored
Starting Base/Temple composition, Base -> Temple -> Base flow, checkpoint and
Captain progression, save-before-return and reconnect/recovery preservation.

## Phase 2 - Profession Foundation

**Status:** ACCEPTED / MERGED / PUSHED
**Accepted gameplay checkpoint:** `ce1577990f2795bf208d7b897e645f32a4a39a4f`

### Supply-chain and persistence evidence

- [x] schema v6 profession state exists for Mining, Blacksmithing, Herbalism and
  Alchemy;
- [x] profession Level/XP migration/default contract;
- [x] Mining -> Blacksmithing complete supply chain;
- [x] Herbalism -> Alchemy complete supply chain;
- [x] Iron Bar / Ironbound Gloves crafting;
- [x] Tempering Oil crafting;
- [x] Blacksmithing Level 2 tempered-gloves gate;
- [x] Tempered Ironbound Gloves cross-profession recipe;
- [x] profession XP is explicitly separate from character XP;
- [x] authoritative Inventory presentation / category tabs;
- [x] crafting prepare is non-mutating and complete is atomic/server-owned;
- [x] Dungeon Equipment remains read-only/run-locked.

### Personal Temple gathering evidence

- [x] multiple resources exist in both Room 1 and Room 2;
- [x] floor/wall/rock raycast placement and partial embedding;
- [x] invalid placements are skipped;
- [x] resources do not collide/query as combat/navigation blockers;
- [x] each node is single-use per player per run;
- [x] another player retains their own copy of the resource;
- [x] duplicate claim rejection;
- [x] reconnect-safe claimed-node reconstruction;
- [x] provisional claim rollback when profile mutation fails;
- [x] client presentation hides claimed nodes only for the owning player.

### Final distribution refinement

- [x] v4 source contract verification PASS;
- [x] `git diff --check` PASS before Studio gate;
- [x] Base Rojo build PASS;
- [x] Dungeon Rojo build PASS;
- [x] published Base Rojo build PASS;
- [x] published Dungeon Rojo build PASS;
- [x] `[Profession Resource Distribution Tests] PASS` observed in Studio;
- [x] Room 1 resources visually distributed around the room;
- [x] Room 2 resources visually distributed around the room;
- [x] minimum same-room resolved spacing contract = 18 studs;
- [x] no new red runtime error reported during the final distribution gate;
- [ ] wider room-scale visual spread beyond the accepted 18-stud minimum is deferred presentation/environment polish and is not a gate blocker.

### Qualification

The pre-player live legacy migration waiver remains a qualification. A real live
schema-v6 migration proof is still required before releasing against real
existing profiles.

## Phase 2 - Second Modular Dungeon + Rare-State/Event Proof

**Status:** ACCEPTED
**Accepted gameplay checkpoint:** `d361348ec045873eed0fd992ceb04bfee908b06a`

The project owner reported the required Studio gameplay gate passed on
16 September 2026.

### Normal Abandoned Mine

- [x] New focused test families PASS.
- [x] Synthetic Abandoned Mine selected instead of Temple.
- [x] Two deterministic module IDs reported.
- [x] Room 1 enemy count = 2.
- [x] Room 2 enemy count = 3.
- [x] Corrupted Foreman presentation.
- [x] Completion and Studio return simulation.

### Forced Crystal Bloom + Deep Echoes

- [x] `Rare=CrystalBloom`.
- [x] `Event=DeepEchoes`.
- [x] Deep Echo presentation in Room 1.
- [x] Crystal Bloom presentation in Room 2.
- [x] Room 1 enemy count = 3.
- [x] Room 2 enemy count = 4.
- [x] Corrupted Foreman and completion remain functional.
- [x] No new red runtime errors reported.

Automated pre-Studio evidence included the RED-baseline contract proof, focused
static verification, clean `git diff --check`, and successful builds of all four
Base/Dungeon published/non-published Rojo compositions.

The current synthetic Mine is functional gameplay proof, not accepted launch
art. No Roblox publish, PROD, Robux, monetisation or art-worktree action
occurred.

## Phase 2 - Party Formation + 1-4-Player Group Entry

**Status:** ACCEPTED
**Accepted gameplay checkpoint:** `726299322fb31689e5e321878f287cccfcb07d81`

The project owner reported the required four-player Roblox Studio Local Server
gate passed on 16 September 2026.

### Multiplayer party flow

- [x] Profile Lease regression PASS with Studio negative synthetic UserIds.
- [x] Player1-Player4 reached authoritative identity Complete.
- [x] Party created by Player 1.
- [x] Players 2-4 invited and accepted.
- [x] Correct 4/4 membership shown.
- [x] Premature start blocked while not all members Ready.
- [x] All-member Ready flow worked.
- [x] Kick propagated and invalidated readiness.
- [x] Leader leave transferred authority deterministically.
- [x] Temple party entry Studio proof.
- [x] Abandoned Mine party entry Studio proof.
- [x] No new red DungeonMMO runtime errors reported.

### Test-environment compatibility

- [x] Negative local-server synthetic UserIds are permitted only in Studio.
- [x] Production positive-UserId rule remains intact.
- [x] Studio PlayerN Human/Fighter auto-identity routes through authoritative
      IdentitySelectionRequest / IdentityService rather than mutating identity
      client-side.

### Qualification

The local Studio proof does not perform a published reserved-server cross-Place
teleport. Real published TEST group teleport remains a later integration/release
check while the accepted party layer reuses the already group-capable
TeleportCoordinator / DungeonSession lower layer.

Automated evidence also included the party static contract, identity-harness
contract, profile-lease regression contract, `git diff --check`, and successful
builds of all four Base/Dungeon published/non-published Rojo compositions.

No Roblox publish, PROD, Robux, monetisation or art-worktree action occurred.

<!-- PHASE3_BLUEPRINT_RECIPE_LEARNING_ACCEPTED_20260917 -->
## Runtime acceptance Ã¢â‚¬â€ Phase 3 Blueprint / Recipe-Learning Ã¢â‚¬â€ 2026-09-17

- Base Ã¢â‚¬â€ `RecipeKnowledgeCraftingGateTest`: PASS, 12 assertions.
- Base Ã¢â‚¬â€ `RecipeKnowledgeServiceTest`: PASS, 23 assertions.
- Base Ã¢â‚¬â€ `ProfileMigrationQuestAdvancementV8Test`: PASS, 8 assertions.
- Base Ã¢â‚¬â€ identity runtime: PASS, completed `Elf / Ranger`.
- Dungeon Ã¢â‚¬â€ `RecipeKnowledgeServiceTest`: PASS, 23 assertions.
- Dungeon Ã¢â‚¬â€ `RecipeKnowledgeCraftingGateTest`: PASS, 12 assertions.
- Dungeon Ã¢â‚¬â€ `ProfileMigrationQuestAdvancementV8Test`: PASS, 8 assertions.
- Dungeon Ã¢â‚¬â€ completion/quest bridge: PASS, 8 assertions.
- Dungeon Ã¢â‚¬â€ admission: PASS, player admitted after full dungeon loop ready.

Non-blocking log debt:
- four synthetic Temple profession-resource placements are skipped because
  their resolved surface is invalid. No test or runtime admission failure
  accompanies these messages.

<!-- PHASE3_SYSTEMS_ALPHA_ACCEPTED_20260918 -->
## Phase 3 - Systems Alpha

**Status:** FORMALLY COMPLETE / ACCEPTED
**Accepted gameplay release checkpoint:** 84662948127eb1a37c9f184c6abbafe6f2daddb6
**Formal closeout date:** 18 September 2026

### Accepted architecture

- [x] Quest + first race-specific Secondary-Class Advancement foundation.
- [x] Damage/Tank/Support Contribution foundation.
- [x] Blueprint / Recipe Knowledge persistence and learning.
- [x] Bestiary + Scholars Reputation foundation.
- [x] Rogue selected/proven as the fourth prototype starting archetype.
- [x] Human Duelist / Elf Windstalker prototype advancement targets.
- [x] broader Rogue skill-tree/progression architecture.
- [x] deterministic Fortified / Rich Deposits / Bounty Dungeon modifiers.
- [x] Rich Deposits integration with reconnect-safe personal gathering.
- [x] Guild creation/membership/roles/progression/leader upgrades.
- [x] private functional Guild Hall.
- [x] limited fixed-price Market with escrow, tax and recovery.
- [x] DEV/TEST Race Change preview/apply/archive/restore.
- [x] shared economy audit events.
- [x] request-rate, stale-state, ownership/membership and replay safeguards.
- [x] shared persisted entity-adapter contract.
- [x] existing Phase 1/2 accepted gameplay architecture preserved.
- [x] catch-up deliberately deferred.
- [x] Transmog deliberately deferred.

### Final Studio evidence

- [x] Rogue Definitions - 43 assertions PASS.
- [x] Rogue Progression - 17 assertions PASS.
- [x] Rogue Advancement - 12 assertions PASS.
- [x] Class Advancement - 29 assertions PASS.
- [x] Contribution Service - 36 assertions PASS.
- [x] Contribution Damage Bridge - 9 assertions PASS.
- [x] Contribution Support Bridge - 13 assertions PASS.
- [x] Contribution real-session persistence - 10 assertions PASS.
- [x] Recipe Knowledge Service - 23 assertions PASS.
- [x] Recipe Knowledge Crafting Gate - 12 assertions PASS.
- [x] Bestiary Service - 33 assertions PASS.
- [x] Bestiary/Reputation reward integration - 25 assertions PASS.
- [x] Guild membership authority - 21 assertions PASS.
- [x] Guild Service / Guild Hall / Dungeon progression - PASS.
- [x] Market listing - 15 assertions PASS.
- [x] Market purchase recovery - 17 assertions PASS.
- [x] Market cancel/expiry - 15 assertions PASS.
- [x] Market remote contract - 6 assertions PASS.
- [x] Race Change planner - 15 assertions PASS.
- [x] Race Change migration - 13 assertions PASS.
- [x] Race Change service - 23 assertions PASS.
- [x] Race Change remote contract - 5 assertions PASS.
- [x] Economy Audit Integration - 27 assertions PASS.
- [x] Rate Limit - 8 assertions PASS.
- [x] Entity Adapter Contract - PASS.
- [x] Dungeon Modifier Definitions - 6 assertions PASS.
- [x] Profession Resource Distribution - PASS.
- [x] existing combat/progression/equipment/Bank/Travel/Dungeon regressions
      remained green in the consolidated run.

### Stress acceptance

- [x] 250 profile migration/save/reload cycles.
- [x] 1,000 market operations.
- [x] 1,000 duplicate/replay attempts.
- [x] 250 guild operations.
- [x] 100 session cycles.
- [x] 100 race-change round trips.
- [x] stress harness reported PASS.

### Release and published TEST evidence

- [x] feature branch pushed.
- [x] local main fast-forwarded to 84662948127eb1a37c9f184c6abbafe6f2daddb6.
- [x] origin/main pushed to 84662948127eb1a37c9f184c6abbafe6f2daddb6.
- [x] GitHub server main independently verified at the same SHA.
- [x] TEST Dungeon 117293035754309 published successfully.
- [x] TEST Starting Base 134132328219009 published successfully.
- [x] both Studio publish state machines reached PublishSuccessful.
- [x] no PROD publish / Robux / monetisation action.

Detailed evidence:
docs/testing/phase3-systems-alpha-acceptance-record.md.

**Next phase:** Phase 4 - Content Alpha.
**First design gate:** Starting Base launch-quality content/presentation.\n

<!-- PHASE4_PROGRESSIVE_DUNGEON_DEPTH_LOCAL_GREEN_20260918 -->
## Phase 4 - Progressive Dungeon Depth + Difficulty Backend Foundation

**Status:** LOCAL GREEN / AWAITING PROJECT-OWNER CLOSEOUT
**Implementation checkpoint:** `1230e6c`
**Baseline:** `a3c2625cfc53dbb1c2bb8d6ce17f5f3749809fa9`

### Backend contract

- [x] Temple and Abandoned Mine expose Depth1-Depth4.
- [x] Depth1/2/3/4 expose 3/4/5/6 logical encounters.
- [x] scaling increases monotonically by depth.
- [x] Depth4 reuses prior bosses as minibosses.
- [x] Depth4 ends with a new final boss.
- [x] schema v13 persists independent dungeon-depth progression.
- [x] legacy `DungeonProgress` remains independent.
- [x] Depth1 is logically unlocked by default.
- [x] sequential clears unlock the next depth idempotently.
- [x] solo and party entry validate authoritative difficulty.
- [x] all party members must own the selected unlock.
- [x] difficulty persists through session/reconnect/TeleportData.
- [x] immutable instance state carries the logical encounter plan.
- [x] Fortified composes with depth HP.
- [x] Bounty applies after depth monster-reward scaling.
- [x] completion Gold scales by depth.
- [x] completion records the depth clear before the profile save barrier.
- [x] Depth1 remains RuntimeReady.
- [x] Depth2-Depth4 remain fail-closed / RuntimeReady=false.

### Repository-wide validation

- [x] Luau parse: 467 files, 0 failures.
- [x] `git diff --check`: PASS.
- [x] Dungeon Rojo build: PASS.
- [x] Base Rojo build: PASS.
- [x] published Dungeon Rojo build: PASS.
- [x] published Base Rojo build: PASS.
- [x] source-boundary review: 44 changed files, 0 art/model/mesh/terrain/image
      files.
- [x] no `DungeonMMO_Art` merge or modification.

### Final Dungeon Studio evidence

- [x] Dungeon Difficulty Definitions: 78 assertions PASS.
- [x] Dungeon Difficulty v13 Migration: 14 assertions PASS.
- [x] Dungeon Difficulty Progression: 17 assertions PASS.
- [x] Dungeon Difficulty Session: 7 assertions PASS.
- [x] Dungeon Difficulty Instance Director: 7 assertions PASS.
- [x] Dungeon Difficulty Teleport: 7 assertions PASS.
- [x] Dungeon Difficulty Tuning: 10 assertions PASS.
- [x] Enemy Damage Multiplier Rules: 3 assertions PASS.
- [x] Dungeon Enemy Difficulty Scaling: 5 assertions PASS.
- [x] Dungeon Difficulty Completion Unlock: 9 assertions PASS.
- [x] Dungeon Modifier Definitions: 6 assertions PASS.
- [x] Teleport Coordinator: 16 assertions PASS.
- [x] Completion Service: 14 assertions PASS.
- [x] Reward Service: 27 assertions PASS.
- [x] Dungeon Session: PASS.
- [x] no project CreatorErrors reported.

### Final Base Studio evidence

- [x] Dungeon Difficulty v13 Migration: 14 assertions PASS.
- [x] Dungeon Difficulty Progression: 17 assertions PASS.
- [x] Dungeon Entry Selection Rules: 9 assertions PASS.
- [x] Party Difficulty: 22 assertions PASS.
- [x] Party Difficulty Entry: 32 assertions PASS.
- [x] Party Entry Coordinator: PASS.
- [x] Party Service: PASS.
- [x] no project CreatorErrors reported.

### Carried-forward stress regression

- [x] 250 profile cycles.
- [x] 1,000 market operations.
- [x] 1,000 duplicate/replay attempts.
- [x] 250 guild operations.
- [x] 100 session cycles.
- [x] 100 race-change round trips.
- [x] Phase 3 Systems Stress reported PASS in both final compositions.

### Release qualification

- [x] no modelling, meshes, terrain or authored-room work.
- [x] no TEST/PROD Roblox publish during this gate.
- [x] no PROD DataStore / Robux / monetisation action.
- [ ] project-owner closeout decision.
- [ ] feature-branch push, if explicitly approved.
- [ ] merge to main, if explicitly approved.
- [ ] TEST publish, if explicitly approved.

Detailed evidence:
`docs/testing/phase4-progressive-dungeon-depth-backend-acceptance-record.md`.


<!-- PHASE4_GENERIC_DUNGEON_ENCOUNTER_RUNTIME_LOCAL_GREEN_20260918 -->
## Phase 4 - Generic Dungeon Encounter Runtime

**Status:** LOCAL GREEN / AWAITING PROJECT-OWNER CLOSEOUT
**Baseline:** `1e1574c`
**Implementation checkpoint:** `5ba9f4d`

### Generic runtime contract

- [x] generic materialized encounter plan.
- [x] arbitrary ordered encounter counts.
- [x] one active encounter at a time.
- [x] Pending -> Active -> Cleared/Skipped lifecycle.
- [x] required versus optional completion semantics.
- [x] stable encounter-ID checkpoints.
- [x] persisted immutable materialized run plan.
- [x] reconnect-safe encounter lifecycle reconstruction.
- [x] Combat encounter kind.
- [x] MiniBoss encounter kind.
- [x] Boss encounter kind.
- [x] FinalBoss encounter kind.
- [x] EventBoss encounter kind.
- [x] SecretBoss encounter kind.
- [x] optional InsertBeforeId / InsertAfterId.
- [x] server-owned InstanceFlag activation.
- [x] server-owned RareState activation.
- [x] required inserted encounter cannot be bypassed.
- [x] inactive optional encounter is absent from the materialized plan.
- [x] active optional encounter remains frozen into the run across reconnect.

### Depth1 compatibility integration

- [x] existing Room1/Room2/Boss physical triggers retained.
- [x] existing CombatRoom1 EncounterService ID retained.
- [x] existing CombatRoom2 EncounterService ID retained.
- [x] existing MarauderCaptain EncounterService ID retained.
- [x] logical boss ID decoupled as Depth1Boss.
- [x] Depth1 physical room-slot bindings are explicit.
- [x] unbound activated optional encounter fails with EncounterBindingMissing.
- [x] legacy Room1Start checkpoint supported.
- [x] legacy Room2Start checkpoint supported.
- [x] legacy BossRoomStart checkpoint supported.
- [x] stable EncounterStart:CombatRoom1 checkpoint supported.
- [x] stable EncounterStart:CombatRoom2 checkpoint supported.
- [x] stable EncounterStart:Depth1Boss checkpoint supported.
- [x] live Dungeon progression authority no longer uses Room1/Room2/Boss clear
      booleans.
- [x] existing doors, rewards, Marauder/Captain/Foreman implementations remain
      compatible.

### Focused Studio evidence

- [x] Dungeon Encounter Plan: 13 assertions PASS.
- [x] Dungeon Encounter Sequencer: 22 assertions PASS.
- [x] Dungeon Encounter Runtime State: 9 assertions PASS.
- [x] Dungeon Encounter Runtime Controller: 19 assertions PASS.
- [x] Depth1 Encounter Bindings: 14 assertions PASS.
- [x] Depth1 Encounter Flow: 14 assertions PASS.
- [x] Depth1 Encounter Recovery: 11 assertions PASS.
- [x] Dungeon Recovery Rules: 18 assertions PASS.

### Real live Dungeon acceptance

Temporary validation-only harness, removed before final source checkpoint:

- [x] real Room1 trigger entered.
- [x] real Room1 enemies spawned and died through live Humanoids.
- [x] CombatRoom1 persisted Cleared.
- [x] stable Room2 checkpoint persisted.
- [x] real Room2 trigger entered.
- [x] real Room2 enemies spawned and died.
- [x] CombatRoom2 persisted Cleared.
- [x] stable Depth1Boss checkpoint persisted.
- [x] real boss trigger entered.
- [x] real Marauder Captain spawned and died.
- [x] logical Depth1Boss persisted Cleared.
- [x] generic flow reported complete.
- [x] normal completion/save barrier committed.
- [x] Generic Encounter Live Acceptance: 13 assertions PASS.
- [x] temporary inspector/driver absent from final source.

### Repository-wide validation

- [x] `git diff --check`: PASS.
- [x] repository parse: 481 Lua/Luau files, 0 failures.
- [x] Dungeon Rojo build: PASS.
- [x] Base Rojo build: PASS.
- [x] published Dungeon Rojo build: PASS.
- [x] published Base Rojo build: PASS.
- [x] source-boundary audit: 19 changed files, 0
      art/model/mesh/terrain/image files.

### Final committed Dungeon regression

- [x] Dungeon Difficulty Definitions: 78 assertions PASS.
- [x] Dungeon Difficulty v13 Migration: 14 assertions PASS.
- [x] Dungeon Difficulty Progression: 17 assertions PASS.
- [x] Dungeon Difficulty Session: 7 assertions PASS.
- [x] Dungeon Difficulty Instance Director: 7 assertions PASS.
- [x] Dungeon Difficulty Teleport: 7 assertions PASS.
- [x] Dungeon Difficulty Tuning: 10 assertions PASS.
- [x] Dungeon Enemy Difficulty Scaling: 5 assertions PASS.
- [x] Enemy Damage Multiplier Rules: 3 assertions PASS.
- [x] Dungeon Difficulty Completion Unlock: 9 assertions PASS.
- [x] Dungeon Modifier Definitions: 6 assertions PASS.
- [x] Teleport Coordinator: 16 assertions PASS.
- [x] Completion Service: 14 assertions PASS.
- [x] Reward Service: 27 assertions PASS.
- [x] Dungeon Session: PASS.
- [x] Training Dummy: 9 assertions PASS.
- [x] Phase 3 Systems Stress: PASS.
- [x] no project CreatorErrors.

### Final committed Base regression

- [x] Dungeon Difficulty v13 Migration: 14 assertions PASS.
- [x] Dungeon Difficulty Progression: 17 assertions PASS.
- [x] Dungeon Entry Selection Rules: 9 assertions PASS.
- [x] Party Difficulty: 22 assertions PASS.
- [x] Party Difficulty Entry: 32 assertions PASS.
- [x] Party Entry Coordinator: PASS.
- [x] Party Service: PASS.
- [x] Phase 3 Systems Stress: PASS.
- [x] no project CreatorErrors.

### Release qualification

- [x] Depth2-Depth4 remain RuntimeReady=false.
- [x] no Event/Secret boss content enabled.
- [x] no modelling, meshes, terrain or authored-room work.
- [x] no TEST/PROD Roblox publish during this gate.
- [x] no PROD DataStore / Robux / monetisation action.
- [ ] project-owner closeout decision.
- [ ] feature-branch push, if explicitly approved.
- [ ] merge to main, if explicitly approved.
- [ ] TEST publish, if explicitly approved.

Detailed evidence:
`docs/testing/phase4-generic-dungeon-encounter-runtime-acceptance-record.md`.


<!-- PHASE4_ENCOUNTER_EXECUTION_REGISTRY_LOCAL_GREEN_20260918 -->
## Phase 4 - Encounter Execution / Spawn Registry

**Status:** LOCAL GREEN / AWAITING PROJECT-OWNER CLOSEOUT
**Baseline:** `c6e181c`
**Implementation checkpoint:** `fe1856e`

### Execution architecture

- [x] stable executor IDs.
- [x] CombatPack executor.
- [x] Boss executor.
- [x] server-owned combat-pack spawn catalogue.
- [x] stable BossId -> factory registry.
- [x] MarauderCaptain registered.
- [x] CorruptedForeman registered.
- [x] DungeonRuntime does not select concrete enemy/boss factories.
- [x] validation occurs before generic sequence start.
- [x] failed executor rolls Active back to Pending.
- [x] downstream EncounterService failure cleans spawned content and rolls back.
- [x] partial combat-pack factory failure cleans already-created enemies.
- [x] boss factory failure releases its spawn claim.
- [x] missing boss Humanoid cleans model and releases claim.
- [x] boss duplicate claims scoped by session + stable encounter ID.
- [x] several distinct boss-family encounters can coexist in one run.
- [x] missing packs/boss IDs/factories/bindings fail closed.
- [x] unimplemented Event/Secret boss content remains disabled.

### Focused Studio evidence

- [x] Dungeon Encounter Execution Registry: 16 assertions PASS.
- [x] Dungeon Encounter Spawn Catalog: 10 assertions PASS.
- [x] Dungeon Boss Factory Registry: 8 assertions PASS.
- [x] Dungeon Encounter Execution Bootstrap: 4 assertions PASS.
- [x] Dungeon Encounter Execution Controller: 17 assertions PASS.
- [x] Dungeon Encounter Executors: 20 assertions PASS.
- [x] Boss Spawn Guard: 10 assertions PASS.
- [x] Dungeon Encounter Sequencer: 25 assertions PASS.
- [x] Dungeon Encounter Runtime Controller: 22 assertions PASS.
- [x] Depth1 Encounter Flow: 18 assertions PASS.
- [x] Depth1 Encounter Bindings: 18 assertions PASS.

### Temple live execution proof

- [x] real Room1 trigger.
- [x] StandardRoom1 spawned exactly 2 live enemies.
- [x] Room1 pack names came from catalogue.
- [x] real Room2 trigger.
- [x] StandardRoom2 spawned exactly 3 live enemies.
- [x] real boss trigger.
- [x] boss executor preserved DungeonBossRole=Boss.
- [x] compatibility runtime ID MarauderCaptain preserved.
- [x] logical Depth1Boss persisted Cleared.
- [x] completion/save barrier succeeded.
- [x] Execution Registry Live Acceptance: 15 assertions PASS.
- [x] no project CreatorErrors in validation run.

### Abandoned Mine live execution proof

Validation-only build forced DeepEchoes + CrystalBloom:

- [x] AbandonedMine selected.
- [x] DeepEchoes active.
- [x] CrystalBloom active.
- [x] Room1 spawned exactly 3 enemies (2 + event bonus 1).
- [x] Room2 spawned exactly 4 enemies (3 + rare bonus 1).
- [x] boss registry resolved CorruptedForeman.
- [x] Foreman display identity preserved.
- [x] logical Boss role preserved.
- [x] logical Depth1Boss persisted Cleared.
- [x] completion/save barrier succeeded.
- [x] Mine Execution Registry Live Acceptance: 16 assertions PASS.
- [x] all forced-selection hooks removed after validation.

### Repository-wide validation

- [x] `git diff --check`: PASS.
- [x] repository parse: 494 Lua/Luau files, 0 failures.
- [x] Dungeon Rojo build: PASS.
- [x] Base Rojo build: PASS.
- [x] published Dungeon Rojo build: PASS.
- [x] published Base Rojo build: PASS.
- [x] source-boundary audit: 26 changed code/test files.
- [x] source-boundary audit: 0 art/model/mesh/terrain/image files.

### Final committed Dungeon regression

- [x] execution-registry focused families PASS.
- [x] Dungeon Difficulty Definitions: 114 assertions PASS.
- [x] Dungeon Difficulty v13 Migration: 14 assertions PASS.
- [x] Dungeon Difficulty Progression: 17 assertions PASS.
- [x] Dungeon Difficulty Session: 7 assertions PASS.
- [x] Dungeon Difficulty Instance Director: 7 assertions PASS.
- [x] Dungeon Difficulty Teleport: 7 assertions PASS.
- [x] Dungeon Difficulty Tuning: 10 assertions PASS.
- [x] Dungeon Enemy Difficulty Scaling: 5 assertions PASS.
- [x] Enemy Damage Multiplier Rules: 3 assertions PASS.
- [x] Dungeon Difficulty Completion Unlock: 9 assertions PASS.
- [x] Dungeon Modifier Definitions: 6 assertions PASS.
- [x] Teleport Coordinator: 16 assertions PASS.
- [x] Completion Service: 14 assertions PASS.
- [x] Reward Service: 27 assertions PASS.
- [x] Dungeon Session: PASS.
- [x] repeat clean run: Training Dummy 9 assertions PASS.
- [x] Phase 3 Systems Stress: PASS.
- [x] repeat clean run: no project CreatorErrors.

### Final committed Base regression

- [x] Dungeon Difficulty v13 Migration: 14 assertions PASS.
- [x] Dungeon Difficulty Progression: 17 assertions PASS.
- [x] Dungeon Entry Selection Rules: 9 assertions PASS.
- [x] Party Difficulty: 22 assertions PASS.
- [x] Party Difficulty Entry: 32 assertions PASS.
- [x] Party Entry Coordinator: PASS.
- [x] Party Service: PASS.
- [x] Phase 3 Systems Stress: PASS.
- [x] no project CreatorErrors.

### Release qualification

- [x] Depth2-Depth4 remain RuntimeReady=false.
- [x] no Event/Secret boss content enabled.
- [x] no modelling, meshes, terrain or authored-room work.
- [x] no TEST/PROD Roblox publish during this gate.
- [x] no PROD DataStore / Robux / monetisation action.
- [ ] project-owner closeout decision.
- [ ] feature-branch push, if explicitly approved.
- [ ] merge to main, if explicitly approved.
- [ ] TEST publish, if explicitly approved.

Detailed evidence:
`docs/testing/phase4-encounter-execution-registry-acceptance-record.md`.


<!-- PHASE4_MULTI_DEPTH_ROOM_RUNTIME_LOCAL_GREEN_20260918 -->
## Phase 4 - Multi-Depth Physical Room-Binding Runtime

**Status:** LOCAL GREEN / AWAITING PROJECT-OWNER RELEASE CLOSEOUT
**Baseline:** `2deb540`
**Implementation checkpoint:** `1aa81b5`

### Runtime architecture

- [x] physical room-slot metadata is data-driven.
- [x] logical encounters bind to room slots generically.
- [x] trigger anchors resolve from binding data.
- [x] enemy spawn anchors resolve from binding data.
- [x] boss spawn anchors are binding-specific.
- [x] exit barriers resolve from binding data.
- [x] stable encounter checkpoints resolve from binding data.
- [x] live progression no longer branches on fixed Room1/Room2/Boss clears.
- [x] legacy Depth1 checkpoint aliases remain recoverable.
- [x] existing Depth1 Temple behaviour remains compatible.
- [x] existing Depth1 Abandoned Mine behaviour remains compatible.
### Permanent fail-closed coverage

- [x] Temple Depth2 physical layout rejected as unregistered.
- [x] Temple Depth3 physical layout rejected as unregistered.
- [x] Temple Depth4 physical layout rejected as unregistered.
- [x] Abandoned Mine Depth2 physical layout rejected as unregistered.
- [x] Abandoned Mine Depth3 physical layout rejected as unregistered.
- [x] Abandoned Mine Depth4 physical layout rejected as unregistered.
- [x] Dungeon Encounter Bindings: 30 assertions PASS.

### Temple real-trigger compatibility

- [x] temporary acceptance harness used only for validation.
- [x] three resolved Depth1 slots.
- [x] real Room1 trigger.
- [x] Room1 spawned exactly 2 enemies.
- [x] real Room2 trigger.
- [x] Room2 spawned exactly 3 enemies.
- [x] real boss trigger.
- [x] compatibility boss ID `MarauderCaptain` preserved.
- [x] stable checkpoints advanced correctly.
- [x] final completion/save barrier succeeded.
- [x] generic flow completed.
- [x] 23/23 assertions PASS.
- [x] temporary harness removed after validation.
### Abandoned Mine compatibility

Validation-only selection forced `AbandonedMine + DeepEchoes + CrystalBloom`.

- [x] Mine-specific anchors resolved through layout data.
- [x] Room1 spawned exactly 3 enemies.
- [x] Room2 spawned exactly 4 enemies.
- [x] Room3 used `Mine.Room3.ForemanSpawn`.
- [x] boss registry produced `Corrupted Foreman`.
- [x] stable checkpoints advanced correctly.
- [x] final completion/save barrier succeeded.
- [x] generic flow completed.
- [x] 23/23 assertions PASS.
- [x] all forced-selection/acceptance hooks removed afterward.

### Final committed static/build gate

- [x] `git diff --check`: PASS.
- [x] repository Luau parse: 501 files, 0 failures.
- [x] Dungeon Rojo build: PASS.
- [x] Base Rojo build: PASS.
- [x] published Dungeon Rojo build: PASS.
- [x] published Base Rojo build: PASS.
- [x] source-boundary audit: 12 changed code/test files from `2deb540`.
- [x] source-boundary audit: 0 art/model/mesh/terrain/image files.
### Final committed Dungeon regression

- [x] Dungeon Encounter Bindings: 30 assertions PASS.
- [x] Dungeon Encounter Flow: 24 assertions PASS.
- [x] Dungeon Encounter Recovery: 10 assertions PASS.
- [x] Dungeon Encounter Execution Bootstrap: 4 assertions PASS.
- [x] Dungeon Encounter Executors: 21 assertions PASS.
- [x] Dungeon Encounter Execution Controller: 17 assertions PASS.
- [x] Dungeon Encounter Runtime Controller: 22 assertions PASS.
- [x] Dungeon Difficulty Definitions: 114 assertions PASS.
- [x] Dungeon Difficulty v13 Migration: 14 assertions PASS.
- [x] Dungeon Difficulty Progression: 17 assertions PASS.
- [x] Dungeon Difficulty Session: 7 assertions PASS.
- [x] Dungeon Difficulty Instance Director: 7 assertions PASS.
- [x] Dungeon Difficulty Teleport: 7 assertions PASS.
- [x] Dungeon Difficulty Tuning: 10 assertions PASS.
- [x] Dungeon Enemy Difficulty Scaling: 5 assertions PASS.
- [x] Enemy Damage Multiplier Rules: 3 assertions PASS.
- [x] Dungeon Difficulty Completion Unlock: 9 assertions PASS.
- [x] Training Dummy: 9 assertions PASS.
- [x] Combat Target Rules: 9 assertions PASS.
- [x] Phase 3 Systems Stress: PASS.
- [x] live player admission succeeded.
- [x] no project CreatorErrors.
### Final committed Base regression

- [x] Dungeon Difficulty v13 Migration: 14 assertions PASS.
- [x] Dungeon Difficulty Progression: 17 assertions PASS.
- [x] Dungeon Entry Selection Rules: 9 assertions PASS.
- [x] Party Difficulty: 22 assertions PASS.
- [x] Party Difficulty Entry: 32 assertions PASS.
- [x] Party Entry Coordinator: PASS.
- [x] Party Service: PASS.
- [x] Phase 3 Systems Stress: PASS.
- [x] no project CreatorErrors.

### Release qualification

- [x] Depth2-Depth4 remain `RuntimeReady=false`.
- [x] no Event/Secret boss content enabled.
- [x] no modelling, meshes, terrain or authored-room work.
- [x] no TEST/PROD Roblox publish during this gate.
- [x] no PROD DataStore / Robux / monetisation action.
- [ ] feature-branch push, if explicitly approved.
- [ ] merge to main, if explicitly approved.
- [ ] TEST publish, if explicitly approved.

Detailed evidence:
`docs/testing/phase4-multi-depth-room-runtime-acceptance-record.md`.


<!-- PHASE4_RUNTIME_CONTENT_READINESS_LOCAL_GREEN_20260918 -->
## Phase 4 - Dungeon Runtime Content Readiness Registry

**Status:** LOCAL GREEN / AWAITING PROJECT-OWNER RELEASE CLOSEOUT
**Baseline:** `a942f6d`
**RED checkpoint:** `34b2a29`
**Implementation checkpoint:** `2e2420b`

### Test-first contract

- [x] permanent readiness test authored before implementation.
- [x] RED observed in Studio because
      `DungeonRuntimeContentReadiness` was missing.
- [x] no unrelated failure was required to establish RED.

### Readiness architecture

- [x] shared `DungeonRuntimeContentCatalog`.
- [x] shared `DungeonRuntimeContentReadiness`.
- [x] physical layout metadata has one shared static source.
- [x] combat-pack metadata has one shared static source.
- [x] boss-content metadata has one shared static source.
- [x] implemented executor IDs are declared centrally.
- [x] implemented boss-factory IDs are declared centrally.
- [x] Dungeon layout wrapper consumes the shared catalogue.
- [x] Dungeon spawn catalogue consumes the shared catalogue.
- [x] old `RuntimeReady` property removed.
- [x] explicit switch renamed to `RuntimeReleaseEnabled`.
- [x] analyser computes `ContentComplete`.
- [x] analyser computes `ReleaseEnabled`.
- [x] analyser computes final `Ready`.
- [x] analyser returns machine-readable readiness issues.
- [x] progression entry uses computed readiness.
- [x] TeleportCoordinator uses computed readiness.
- [x] not-ready content blocks before server reservation.
- [x] Dungeon bootstrap cross-checks actual executor/factory registrations.

### Current difficulty readiness

For both TestDungeon and AbandonedMine:

- [x] Depth1 content complete.
- [x] Depth1 release enabled.
- [x] Depth1 ready.
- [x] Depth1 has no readiness issues.
- [x] Depth2 content incomplete and release disabled.
- [x] Depth3 content incomplete and release disabled.
- [x] Depth4 content incomplete and release disabled.
- [x] higher depths report missing physical layout.
- [x] higher depths report missing encounter content.
- [x] Depth2-Depth4 remain fail closed.

### Focused Studio evidence

Base:

- [x] Runtime Content Readiness: 64 assertions PASS.
- [x] Difficulty Definitions: 114 assertions PASS.
- [x] Difficulty Progression: 19 assertions PASS.
- [x] Teleport Coordinator: 19 assertions PASS.

Dungeon:

- [x] Runtime Content Readiness: 64 assertions PASS.
- [x] Encounter Bindings: 30 assertions PASS.
- [x] Encounter Spawn Catalog: 10 assertions PASS.
- [x] Encounter Executors: 21 assertions PASS.
- [x] Boss Factory Registry: 8 assertions PASS.
- [x] Encounter Execution Bootstrap: 4 assertions PASS.
- [x] Training Dummy: 9 assertions PASS.
- [x] Combat Target Rules: 9 assertions PASS.
- [x] Phase 3 Systems Stress: PASS.
### Final committed static/build acceptance

- [x] clean committed implementation checkpoint `2e2420b`.
- [x] `git diff --check`: PASS.
- [x] repository Luau parse: 504 files, 0 failures.
- [x] Dungeon Rojo build: PASS.
- [x] Base Rojo build: PASS.
- [x] published Dungeon Rojo build: PASS.
- [x] published Base Rojo build: PASS.

### Final committed Base regression

- [x] Runtime Content Readiness: 64 assertions PASS.
- [x] Difficulty Definitions: 114 assertions PASS.
- [x] Difficulty Progression: 19 assertions PASS.
- [x] Teleport Coordinator: 19 assertions PASS.
- [x] Dungeon Entry Selection Rules: 9 assertions PASS.
- [x] Party Difficulty: 22 assertions PASS.
- [x] Party Difficulty Entry: 32 assertions PASS.
- [x] Party Entry Coordinator: PASS.
- [x] Party Service: PASS.
- [x] Phase 3 Systems Stress: PASS.
- [x] no project CreatorErrors observed.
### Final committed Dungeon regression

- [x] Runtime Content Readiness: 64 assertions PASS.
- [x] Encounter Bindings: 30 assertions PASS.
- [x] Encounter Spawn Catalog: 10 assertions PASS.
- [x] Encounter Executors: 21 assertions PASS.
- [x] Boss Factory Registry: 8 assertions PASS.
- [x] Encounter Execution Bootstrap: 4 assertions PASS.
- [x] Difficulty Definitions: 114 assertions PASS.
- [x] Difficulty Progression: 19 assertions PASS.
- [x] Training Dummy: 9 assertions PASS.
- [x] Combat Target Rules: 9 assertions PASS.
- [x] Phase 3 Systems Stress: PASS.
- [x] live player admission succeeded.
- [x] no project CreatorErrors observed.

### Release qualification

- [x] Depth2-Depth4 remain release-disabled/content-incomplete.
- [x] no Event/Secret boss content enabled.
- [x] no modelling, meshes, terrain or authored-room work.
- [x] source-boundary audit: 13 source/test files.
- [x] source-boundary audit: 0 art/model/mesh/terrain/image files.
- [x] no TEST/PROD Roblox publish during this gate.
- [x] no PROD DataStore / Robux / monetisation action.
- [ ] feature-branch push, if explicitly approved.
- [ ] merge to main, if explicitly approved.
- [ ] TEST publish, if explicitly approved.

Detailed evidence:
`docs/testing/phase4-runtime-content-readiness-acceptance-record.md`.


<!-- PHASE4_ENEMY_ARCHETYPE_COMBAT_PACK_LOCAL_GREEN_20260918 -->
## Phase 4 - Generic Enemy Archetype + Heterogeneous Combat Pack Registry

**Status:** LOCAL GREEN / AWAITING PROJECT-OWNER RELEASE CLOSEOUT
**Baseline:** `5298699`
**RED checkpoint:** `ad56735`
**Implementation checkpoint:** `464bd44`

### Test-first contract

- [x] enemy-factory registry test authored before implementation.
- [x] heterogeneous CombatPack executor test authored before implementation.
- [x] Studio RED observed because `DungeonEnemyFactoryRegistry` was missing.
- [x] Studio RED observed because `CombatPackEncounterExecutor` was missing.
- [x] no unrelated failure was required to establish RED.

### Generic enemy architecture

- [x] shared enemy archetype definitions.
- [x] stable enemy FactoryId values.
- [x] server-owned `DungeonEnemyFactoryRegistry`.
- [x] production Marauder factory registered through stable FactoryId.
- [x] CombatPack entries are ordered and typed.
- [x] CombatPack execution no longer assumes Marauders.
- [x] generic `CombatPackEncounterExecutor`.
- [x] old `MarauderPackEncounterExecutor` removed.
- [x] per-entry naming preserved.
- [x] per-entry spawn-index ranges preserved.
- [x] per-archetype reward definitions preserved.
- [x] difficulty health/damage/reward scaling applies across archetypes.
- [x] partial mixed-pack failure cleans all prior spawns.
- [x] Deep Echoes bonus targets an explicit EntryId.
- [x] Crystal Bloom bonus targets an explicit EntryId.
- [x] readiness validates pack entry structure.
- [x] readiness validates enemy archetype registration.
- [x] readiness validates implemented enemy factories.
- [x] readiness validates pack bonus targets.
- [x] no new production enemy archetype enabled.

### Depth1 compatibility

- [x] Temple Room1 count remains 2.
- [x] Temple Room2 count remains 3.
- [x] Mine Room1 normal count remains 2.
- [x] Mine Deep Echoes Room1 count remains 3.
- [x] Mine Room2 normal count remains 3.
- [x] Mine Crystal Bloom Room2 count remains 4.
### Heterogeneous synthetic proof

- [x] synthetic pack contains two Marauder enemies.
- [x] synthetic pack contains one Elite enemy.
- [x] distinct injected factories are selected by archetype.
- [x] deterministic entry/factory order.
- [x] per-entry names verified.
- [x] per-entry spawn-index ranges verified.
- [x] per-archetype scaled rewards verified.
- [x] mixed-archetype combat scaling verified.
- [x] synthetic Elite factory failure cleans Marauder spawns.
- [x] missing enemy factory fails closed.
- [x] unknown pack fails closed.
- [x] synthetic Elite is test-only, not production content.

### Focused GREEN evidence

- [x] Enemy Factory Registry: 8 assertions PASS.
- [x] Combat Pack Encounter Executor: 15 assertions PASS.
- [x] Encounter Spawn Catalog: 15 assertions PASS.
- [x] Encounter Executors: 21 assertions PASS.
- [x] Encounter Execution Bootstrap: 4 assertions PASS.
- [x] Runtime Content Readiness: 64 assertions PASS.
- [x] Combat Target Rules repeat: 9 assertions PASS.
### Final committed static/build acceptance

- [x] clean committed implementation checkpoint `464bd44`.
- [x] `git diff --check`: PASS.
- [x] repository Luau parse: 507 files, 0 failures.
- [x] Dungeon Rojo build: PASS.
- [x] Base Rojo build: PASS.
- [x] published Dungeon Rojo build: PASS.
- [x] published Base Rojo build: PASS.
- [x] added implementation source lines meet 79-character limit.

### Final committed Base regression

- [x] Runtime Content Readiness: 64 assertions PASS.
- [x] Difficulty Definitions: 114 assertions PASS.
- [x] Difficulty Progression: 19 assertions PASS.
- [x] Teleport Coordinator: 19 assertions PASS.
- [x] Dungeon Entry Selection Rules: 9 assertions PASS.
- [x] Party Difficulty: 22 assertions PASS.
- [x] Party Difficulty Entry: 32 assertions PASS.
- [x] Party Entry Coordinator: PASS.
- [x] Party Service: PASS.
- [x] Phase 3 Systems Stress: PASS.
- [x] no project CreatorErrors observed.
### Final committed Dungeon regression

- [x] Enemy Factory Registry: 8 assertions PASS.
- [x] Combat Pack Encounter Executor: 15 assertions PASS.
- [x] Encounter Spawn Catalog: 15 assertions PASS.
- [x] Encounter Executors: 21 assertions PASS.
- [x] Encounter Execution Bootstrap: 4 assertions PASS.
- [x] Encounter Bindings: 30 assertions PASS.
- [x] Runtime Content Readiness: 64 assertions PASS.
- [x] Training Dummy: 9 assertions PASS.
- [x] Combat Target Rules: 9 assertions PASS on clean repeat.
- [x] Phase 3 Systems Stress: PASS.
- [x] live player admission succeeded.
- [x] no project CreatorErrors observed on clean repeat.

### Release qualification

- [x] no new production enemy archetype enabled.
- [x] Depth2-Depth4 remain release-disabled/content-incomplete.
- [x] no Event/Secret boss content enabled.
- [x] no modelling, meshes, terrain or authored-room work.
- [x] source-boundary audit: 11 source/test files.
- [x] source-boundary audit: 0 art/model/mesh/terrain/image files.
- [x] no TEST/PROD Roblox publish during this gate.
- [x] no PROD DataStore / Robux / monetisation action.
- [ ] feature-branch push, if explicitly approved.
- [ ] merge to main, if explicitly approved.
- [ ] TEST publish, if explicitly approved.

Detailed evidence:
`docs/testing/phase4-enemy-archetype-combat-pack-acceptance-record.md`.


<!-- PHASE4_RUNTIME_LAYOUT_SELECTION_LOCAL_GREEN_20260918 -->
## Phase 4 - Runtime Layout Selection + Environment Activation

**Status:** LOCAL GREEN / AWAITING PROJECT-OWNER RELEASE CLOSEOUT
**Baseline:** `0177b17`
**RED checkpoint:** `5ab0b4e`
**Implementation checkpoint:** `ccd289b`

### Test-first contract

- [x] RED captured before implementation.
- [x] missing `resolve_selection` failed as expected.
- [x] missing layout-activation module failed as expected.

### Runtime selection

- [x] Studio default difficulty resolves.
- [x] explicit Studio Depth1 resolves.
- [x] unregistered selected layout fails closed.
- [x] unknown difficulty fails closed.
- [x] production preserves TeleportData DifficultyId.
- [x] Runtime Selection: 7 assertions PASS.
### Environment activation

- [x] physical slots declare explicit ExitBarrierAnchor.
- [x] arbitrary four-slot trigger activation works.
- [x] arbitrary three-barrier activation works.
- [x] missing trigger fails closed.
- [x] missing barrier fails closed.
- [x] Environment Layout Activation: 12 assertions PASS.
- [x] bootstrap contains no Temple/Mine trigger arrays.
- [x] readiness requires a physical barrier anchor when a logical
      ExitBarrierRoomId exists.

### Final committed static/build acceptance

- [x] clean committed checkpoint `ccd289b`.
- [x] `git diff --check`: PASS.
- [x] repository Luau parse: 510 files, 0 failures.
- [x] Dungeon Rojo build: PASS.
- [x] Base Rojo build: PASS.
- [x] published Dungeon Rojo build: PASS.
- [x] published Base Rojo build: PASS.
### Final committed Base regression

- [x] Runtime Content Readiness: 64 assertions PASS.
- [x] Difficulty Definitions: 114 assertions PASS.
- [x] Difficulty Progression: 19 assertions PASS.
- [x] Teleport Coordinator: 19 assertions PASS.
- [x] Dungeon Entry Selection Rules: 9 assertions PASS.
- [x] Party Difficulty: 22 assertions PASS.
- [x] Party Difficulty Entry: 32 assertions PASS.
- [x] Party Entry Coordinator: PASS.
- [x] Party Service: PASS.
- [x] Phase 3 Systems Stress: PASS.
- [x] no project CreatorErrors observed.

### Final committed Dungeon regression

- [x] Runtime Selection: 7 assertions PASS.
- [x] Environment Layout Activation: 12 assertions PASS.
- [x] Encounter Bindings: 30 assertions PASS.
- [x] Encounter Executors: 21 assertions PASS.
- [x] Encounter Execution Bootstrap: 4 assertions PASS.
- [x] Runtime Content Readiness: 64 assertions PASS.
- [x] Training Dummy: 9 assertions PASS.
- [x] Combat Target Rules: 9 assertions PASS.
- [x] Phase 3 Systems Stress: PASS.
- [x] live player admission succeeded.
- [x] Roblox Controls Emulator plugin errors classified as external.

### Release qualification

- [x] Depth2-Depth4 remain release-disabled/content-incomplete.
- [x] no physical higher-depth rooms or anchors added.
- [x] no Event/Secret boss content enabled.
- [x] source-boundary audit: 7 source/test files.
- [x] source-boundary audit: 0 art/model/mesh/terrain/image files.
- [x] no TEST/PROD publish during this gate.
- [x] no PROD DataStore / Robux / monetisation action.
- [ ] feature-branch push, if explicitly approved.
- [ ] merge to main, if explicitly approved.

Detailed evidence:
`docs/testing/phase4-runtime-layout-selection-acceptance-record.md`.


<!-- PHASE4_ENVIRONMENT_BINDING_RUNTIME_LOCAL_GREEN_20260918 -->
## Phase 4 - Environment Binding Runtime

**Status:** LOCAL GREEN / AWAITING PROJECT-OWNER RELEASE CLOSEOUT
**Baseline:** `caf56c5`
**RED checkpoint:** `5bcd281`
**Implementation checkpoint:** `cfbf2ea`

### Test-first contract

- [x] RED captured before implementation.
- [x] missing DungeonEncounterEnvironmentRuntime failed as expected.
- [x] get_group-only combat environment failed before migration.
- [x] missing binding-owned spawn groups failed before migration.

### Physical binding contract

- [x] combat-capable slots declare EnemySpawnGroup.
- [x] bindings expose EnemySpawnGroup.
- [x] bindings expose ExitBarrierAnchor.
- [x] readiness rejects CombatPack bindings without EnemySpawnGroup.
- [x] current Temple/Mine Depth1 binding compatibility preserved.
- [x] Dungeon Encounter Bindings: 34 assertions PASS.
### Generic combat spawning

- [x] CombatPackEncounterExecutor requires binding.EnemySpawnGroup.
- [x] executor uses environment:get_group(...).
- [x] ordered group BaseParts are converted to CFrames.
- [x] missing/empty resolved spawn groups fail closed.
- [x] mixed-pack factory/reward/scaling behavior preserved.
- [x] Combat Pack Encounter Executor: 15 assertions PASS.
- [x] Encounter Executors: 21 assertions PASS.
- [x] Encounter Execution Bootstrap: 4 assertions PASS.

### Generic exit barriers

- [x] DungeonEncounterEnvironmentRuntime exists.
- [x] arbitrary binding-owned physical barrier opens.
- [x] arbitrary binding-owned physical barrier closes.
- [x] slots without barriers are safe no-ops.
- [x] missing declared barriers fail closed.
- [x] invalid environment adapters fail closed.
- [x] Dungeon Encounter Environment Runtime: 8 assertions PASS.
- [x] DungeonRuntime clear path uses ExitBarrierAnchor.
- [x] DungeonRuntime recovery path uses ExitBarrierAnchor.
### Final committed static/build acceptance

- [x] clean committed checkpoint `cfbf2ea`.
- [x] `git diff --check`: PASS.
- [x] repository Luau parse: 512 files, 0 failures.
- [x] Dungeon Rojo build: PASS.
- [x] Base Rojo build: PASS.
- [x] published Dungeon Rojo build: PASS.
- [x] published Base Rojo build: PASS.

### Final committed Base regression

- [x] Runtime Content Readiness: 64 assertions PASS.
- [x] Difficulty Definitions: 114 assertions PASS.
- [x] Difficulty Progression: 19 assertions PASS.
- [x] Teleport Coordinator: 19 assertions PASS.
- [x] Dungeon Entry Selection Rules: 9 assertions PASS.
- [x] Party Difficulty: 22 assertions PASS.
- [x] Party Difficulty Entry: 32 assertions PASS.
- [x] Party Entry Coordinator: PASS.
- [x] Party Service: PASS.
- [x] Phase 3 Systems Stress: PASS.
- [x] no project CreatorErrors observed.
### Final committed Dungeon regression

- [x] Dungeon Encounter Bindings: 34 assertions PASS.
- [x] Dungeon Encounter Environment Runtime: 8 assertions PASS.
- [x] Combat Pack Encounter Executor: 15 assertions PASS.
- [x] Dungeon Encounter Executors: 21 assertions PASS.
- [x] Dungeon Encounter Execution Bootstrap: 4 assertions PASS.
- [x] Runtime Content Readiness: 64 assertions PASS.
- [x] Training Dummy: 9 assertions PASS.
- [x] Combat Target Rules: 9 assertions PASS.
- [x] Phase 3 Systems Stress: PASS.
- [x] live player admission succeeded.
- [x] no project CreatorErrors observed.

### Release qualification

- [x] Depth2-Depth4 remain release-disabled/content-incomplete.
- [x] no physical higher-depth rooms or anchors added.
- [x] no new enemy/boss content enabled.
- [x] no Event/Secret boss content enabled.
- [x] source-boundary audit: 11 source/test files.
- [x] source-boundary audit: 0 art/model/mesh/terrain/image files.
- [x] no TEST/PROD publish during this gate.
- [x] no PROD DataStore / Robux / monetisation action.
- [ ] feature-branch push, if explicitly approved.
- [ ] merge to main, if explicitly approved.

Detailed evidence:
`docs/testing/phase4-environment-binding-runtime-acceptance-record.md`.


<!-- PHASE4_LAYOUT_ENVIRONMENT_CONTRACT_LOCAL_GREEN_20260918 -->
## Phase 4 - Layout-Derived Environment Contract

**Status:** LOCAL GREEN / AWAITING PROJECT-OWNER RELEASE CLOSEOUT
**Baseline:** `87a88c1`
**RED checkpoint:** `1729151`
**Implementation checkpoint:** `405dde5`

### Test-first contract

- [x] RED captured before implementation.
- [x] missing DungeonLayoutEnvironmentContract failed as expected.

### Selected-layout contract

- [x] runtime base contracts contain only environment-wide anchors.
- [x] current combat slots own EnemySpawnGroup.
- [x] current combat slots own EnemySpawnPrefix.
- [x] current combat slots own EnemySpawnMinCount.
- [x] readiness validates complete combat group metadata.
- [x] selected layout contributes entrance/trigger/checkpoint anchors.
- [x] selected layout contributes exit-barrier anchors.
- [x] selected layout contributes boss-spawn anchors.
- [x] selected layout contributes combat spawn-group definitions.
### Synthetic Room4 proof

- [x] Room4 exact anchors are generated by contract builder.
- [x] Room4 enemy group name/prefix/minimum are generated from slot metadata.
- [x] real EnvironmentAnchorResolver exposes Room4 exact anchors.
- [x] real EnvironmentAnchorResolver exposes Room4 enemy group.
- [x] insufficient Room4 group anchors fail closed.
- [x] incomplete Room4 combat group metadata fails closed.
- [x] Dungeon Layout Environment Contract: 14 assertions PASS.

### Production integration

- [x] DungeonEnvironmentBootstrap uses selected-layout runtime contract.
- [x] DungeonEnvironmentRouter rebuilds the selected-layout runtime contract.
- [x] Temple adapter accepts optional explicit contract.
- [x] Mine adapter accepts optional explicit contract.
- [x] legacy adapter default contracts remain available.
- [x] production bootstrap/router do not use static full Depth1 contracts.
### Final committed static/build acceptance

- [x] clean committed checkpoint `405dde5`.
- [x] `git diff --check`: PASS.
- [x] repository Luau parse: 514 files, 0 failures.
- [x] Dungeon Rojo build: PASS.
- [x] Base Rojo build: PASS.
- [x] published Dungeon Rojo build: PASS.
- [x] published Base Rojo build: PASS.

### Final committed Base regression

- [x] Runtime Content Readiness: 64 assertions PASS.
- [x] Difficulty Definitions: 114 assertions PASS.
- [x] Difficulty Progression: 19 assertions PASS.
- [x] Teleport Coordinator: 19 assertions PASS.
- [x] Dungeon Entry Selection Rules: 9 assertions PASS.
- [x] Party Difficulty: 22 assertions PASS.
- [x] Party Difficulty Entry: 32 assertions PASS.
- [x] Party Entry Coordinator: PASS.
- [x] Party Service: PASS.
- [x] Phase 3 Systems Stress: PASS.
### Final committed Dungeon regression

- [x] clean-repeat Layout Environment Contract: 14 assertions PASS.
- [x] Dungeon Encounter Bindings: 34 assertions PASS.
- [x] Combat Pack Encounter Executor: 15 assertions PASS.
- [x] Phase2A Failure Path: 24 assertions PASS.
- [x] Teleport Coordinator: 19 assertions PASS.
- [x] Dungeon Difficulty Teleport: 7 assertions PASS.
- [x] Dungeon Difficulty Progression: 19 assertions PASS.
- [x] Runtime Content Readiness: 64 assertions PASS.
- [x] Training Dummy: 9 assertions PASS.
- [x] clean-repeat Combat Target Rules: 9 assertions PASS.
- [x] Phase 3 Systems Stress: PASS.
- [x] live player admission succeeded.
- [x] Roblox Controls Emulator plugin errors classified as external.

### Release qualification

- [x] Depth2-Depth4 remain release-disabled/content-incomplete.
- [x] no higher-depth layout registered.
- [x] no Room4+ authored content added.
- [x] no new enemy/boss content enabled.
- [x] no Event/Secret boss content enabled.
- [x] source-boundary audit: 9 source/test files.
- [x] source-boundary audit: 0 art/model/mesh/terrain/image files.
- [x] no TEST/PROD publish during this gate.
- [x] no PROD DataStore / Robux / monetisation action.
- [ ] feature-branch push, if explicitly approved.
- [ ] merge to main, if explicitly approved.

Detailed evidence:
`docs/testing/phase4-layout-environment-contract-acceptance-record.md`.


<!-- PHASE4_STUDIO_DIFFICULTY_PARITY_LOCAL_GREEN_20260918 -->
## Phase 4 - Studio Difficulty / Session Parity

**Status:** LOCAL GREEN / AWAITING PROJECT-OWNER RELEASE CLOSEOUT
**Baseline:** `5fb3491`
**RED checkpoint:** `efc6a47`
**Implementation checkpoint:** `d9297f8`

### Test-first contract

- [x] RED captured before implementation.
- [x] explicit Studio Depth2 failed to reach session creation.

### Studio parity contract

- [x] StudioSessionFactory accepts optional DifficultyId.
- [x] session creation receives selected DifficultyId.
- [x] DungeonInstanceDirector receives selected DifficultyId.
- [x] Studio routing data preserves DifficultyId.
- [x] reused Studio sessions prefer authoritative session difficulty.
- [x] omitted Studio difficulty still defaults through normal definitions.
- [x] DungeonRuntime passes environment-resolved DifficultyId.
- [x] production TeleportCoordinator routing unchanged.
- [x] Studio Session Factory: 7 assertions PASS.
### Final committed static/build acceptance

- [x] clean committed checkpoint `d9297f8`.
- [x] `git diff --check`: PASS.
- [x] repository Luau parse: 514 files, 0 failures.
- [x] Dungeon Rojo build: PASS.
- [x] Base Rojo build: PASS.
- [x] published Dungeon Rojo build: PASS.
- [x] published Base Rojo build: PASS.

### Final committed Base regression

- [x] Runtime Content Readiness: 64 assertions PASS.
- [x] Difficulty Definitions: 114 assertions PASS.
- [x] Difficulty Progression: 19 assertions PASS.
- [x] Teleport Coordinator: 19 assertions PASS.
- [x] Dungeon Entry Selection Rules: 9 assertions PASS.
- [x] Party Difficulty: 22 assertions PASS.
- [x] Party Difficulty Entry: 32 assertions PASS.
- [x] Party Entry Coordinator: PASS.
- [x] Party Service: PASS.
- [x] Phase 3 Systems Stress: PASS.
### Final committed Dungeon regression

- [x] clean-repeat Studio Session Factory: 7 assertions PASS.
- [x] Dungeon Layout Environment Contract: 14 assertions PASS.
- [x] Dungeon Encounter Bindings: 34 assertions PASS.
- [x] Combat Pack Encounter Executor: 15 assertions PASS.
- [x] Phase2A Failure Path: 24 assertions PASS.
- [x] Teleport Coordinator: 19 assertions PASS.
- [x] Dungeon Difficulty Teleport: 7 assertions PASS.
- [x] Dungeon Difficulty Progression: 19 assertions PASS.
- [x] Runtime Content Readiness: 64 assertions PASS.
- [x] clean-repeat Training Dummy: 9 assertions PASS.
- [x] clean-repeat Combat Target Rules: 9 assertions PASS.
- [x] Phase 3 Systems Stress: PASS.
- [x] live player admission succeeded.

### Release qualification

- [x] Depth2-Depth4 remain release-disabled/content-incomplete.
- [x] no higher-depth layout registered.
- [x] no new enemy/boss content enabled.
- [x] no Event/Secret boss content enabled.
- [x] source-boundary audit: 3 source/test files.
- [x] source-boundary audit: 0 art/model/mesh/terrain/image files.
- [x] no TEST/PROD publish during this gate.
- [x] no PROD DataStore / Robux / monetisation action.
- [ ] feature-branch push, if explicitly approved.
- [ ] merge to main, if explicitly approved.

Detailed evidence:
`docs/testing/phase4-studio-difficulty-parity-acceptance-record.md`.


<!-- PHASE4_DEPTH2_CONTENT_LOCAL_GREEN_20260918 -->
## Phase 4 - Depth2 Backend Combat + Boss Content

**Status:** LOCAL GREEN / AWAITING PROJECT-OWNER RELEASE CLOSEOUT
**Baseline:** `468cf76`
**RED checkpoint:** `dad8990`
**Implementation checkpoint:** `b525235`

### Test-first content contract

- [x] RED captured before implementation.
- [x] missing Depth2 combat packs failed as expected.
- [x] missing TempleDepth2BossFactory failed as expected.
- [x] Depth2 readiness reported missing encounter content before implementation.

### Depth2 combat content

- [x] TestDungeon Depth2Room1 registered with 3 Marauders.
- [x] TestDungeon Depth2Room2 registered with 4 Marauders.
- [x] TestDungeon Depth2Room3 registered with 5 Marauders.
- [x] AbandonedMine Depth2Room1 registered with 3 Marauders.
- [x] AbandonedMine Depth2Room2 registered with 4 Marauders.
- [x] AbandonedMine Depth2Room3 registered with 5 Marauders.
- [x] Mine Deep Echoes adds one Depth2 Room1 Marauder.
- [x] Mine Crystal Bloom adds one Depth2 Room2 Marauder.
- [x] Depth2 Content: 32 assertions PASS.
### Depth2 boss content

- [x] TempleDepth2Boss registered.
- [x] TempleDepth2Boss display identity: Temple Warden.
- [x] AbandonedMineDepth2Boss registered.
- [x] AbandonedMineDepth2Boss display identity: Deep Overseer.
- [x] both factories registered in execution bootstrap.
- [x] both bosses retain accepted Captain controller tag/behavior.
- [x] Depth2 Boss Factory: 8 assertions PASS.
- [x] Encounter Spawn Catalog: 17 assertions PASS.
- [x] Encounter Execution Bootstrap: 4 assertions PASS.

### Readiness boundary

- [x] Depth2 remains Ready = false for both current dungeons.
- [x] Depth2 remains ReleaseEnabled = false.
- [x] Depth2 no longer reports EncounterContentNotRegistered.
- [x] Depth2 reports exactly one issue: DungeonLayoutNotRegistered.
- [x] no Depth2 physical layout registered.
- [x] Depth3-Depth4 remain content-incomplete.
- [x] Runtime Content Readiness: 66 assertions PASS.
### Final committed static/build acceptance

- [x] clean committed checkpoint `b525235`.
- [x] `git diff --check`: PASS.
- [x] repository Luau parse: 518 files, 0 failures.
- [x] Dungeon Rojo build: PASS.
- [x] Base Rojo build: PASS.
- [x] published Dungeon Rojo build: PASS.
- [x] published Base Rojo build: PASS.

### Final committed Base regression

- [x] Runtime Content Readiness: 66 assertions PASS.
- [x] Difficulty Definitions: 114 assertions PASS.
- [x] Difficulty Progression: 19 assertions PASS.
- [x] Teleport Coordinator: 19 assertions PASS.
- [x] Dungeon Entry Selection Rules: 9 assertions PASS.
- [x] Party Difficulty: 22 assertions PASS.
- [x] Party Difficulty Entry: 32 assertions PASS.
- [x] Party Entry Coordinator: PASS.
- [x] Party Service: PASS.
- [x] Phase 3 Systems Stress: PASS.
### Final committed Dungeon regression

- [x] Depth2 Content: 32 assertions PASS.
- [x] Depth2 Boss Factory: 8 assertions PASS.
- [x] Encounter Spawn Catalog: 17 assertions PASS.
- [x] Encounter Execution Bootstrap: 4 assertions PASS.
- [x] Studio Session Factory: 7 assertions PASS.
- [x] Layout Environment Contract: 14 assertions PASS.
- [x] Dungeon Encounter Bindings: 34 assertions PASS.
- [x] Combat Pack Encounter Executor: 15 assertions PASS.
- [x] Phase2A Failure Path: 24 assertions PASS.
- [x] Teleport Coordinator: 19 assertions PASS.
- [x] Dungeon Difficulty Teleport: 7 assertions PASS.
- [x] Dungeon Difficulty Progression: 19 assertions PASS.
- [x] Runtime Content Readiness: 66 assertions PASS.
- [x] Training Dummy: 9 assertions PASS.
- [x] Combat Target Rules: 9 assertions PASS.
- [x] Phase 3 Systems Stress: PASS.
- [x] live player admission succeeded.

### Release qualification

- [x] Depth2 remains release-disabled.
- [x] Depth2 remains physically unregistered.
- [x] Depth3-Depth4 remain content-incomplete and release-disabled.
- [x] no Event/Secret boss content enabled.
- [x] source-boundary audit: 8 source/test files.
- [x] source-boundary audit: 0 art/model/mesh/terrain/image files.
- [x] no TEST/PROD publish during this gate.
- [x] no PROD DataStore / Robux / monetisation action.
- [ ] feature-branch push, if explicitly approved.
- [ ] merge to main, if explicitly approved.

Detailed evidence:
`docs/testing/phase4-depth2-content-acceptance-record.md`.


<!-- PHASE4_DEPTH3_CONTENT_LOCAL_GREEN_20260918 -->
## Phase 4 - Depth3 Backend Combat + Boss Content

**Status:** LOCAL GREEN / AWAITING PROJECT-OWNER RELEASE CLOSEOUT
**Baseline:** `3d978af`
**RED checkpoint:** `b205914`
**Implementation checkpoint:** `092bd99`

### Test-first content contract

- [x] RED captured before implementation.
- [x] missing Depth3 combat packs failed as expected.
- [x] missing TempleDepth3BossFactory failed as expected.
- [x] Depth3 readiness reported missing encounter content before implementation.

### Depth3 combat content

- [x] TestDungeon Depth3Room1 registered with 4 Marauders.
- [x] TestDungeon Depth3Room2 registered with 5 Marauders.
- [x] TestDungeon Depth3Room3 registered with 6 Marauders.
- [x] TestDungeon Depth3Room4 registered with 7 Marauders.
- [x] AbandonedMine Depth3Room1 registered with 4 Marauders.
- [x] AbandonedMine Depth3Room2 registered with 5 Marauders.
- [x] AbandonedMine Depth3Room3 registered with 6 Marauders.
- [x] AbandonedMine Depth3Room4 registered with 7 Marauders.
- [x] Mine Deep Echoes adds one Depth3 Room1 Marauder.
- [x] Mine Crystal Bloom adds one Depth3 Room2 Marauder.
- [x] Depth3 Content: 36 assertions PASS.
### Depth3 boss content

- [x] TempleDepth3Boss registered.
- [x] TempleDepth3Boss display identity: Relic Guardian.
- [x] AbandonedMineDepth3Boss registered.
- [x] AbandonedMineDepth3Boss display identity: Hollow Taskmaster.
- [x] both factories registered in execution bootstrap.
- [x] both bosses retain accepted Captain controller tag/behavior.
- [x] Depth3 Boss Factory: 8 assertions PASS.
- [x] Encounter Spawn Catalog: 19 assertions PASS.
- [x] Encounter Execution Bootstrap: 4 assertions PASS.

### Readiness boundary

- [x] Depth2 and Depth3 remain Ready = false.
- [x] Depth2 and Depth3 remain ReleaseEnabled = false.
- [x] Depth3 no longer reports EncounterContentNotRegistered.
- [x] Depth2/Depth3 each report exactly one issue: DungeonLayoutNotRegistered.
- [x] no Depth2/Depth3 physical layout registered.
- [x] Depth4 remains content-incomplete.
- [x] Runtime Content Readiness: 68 assertions PASS.
### Final committed static/build acceptance

- [x] clean committed checkpoint `092bd99`.
- [x] `git diff --check`: PASS.
- [x] repository Luau parse: 522 files, 0 failures.
- [x] Dungeon Rojo build: PASS.
- [x] Base Rojo build: PASS.
- [x] published Dungeon Rojo build: PASS.
- [x] published Base Rojo build: PASS.

### Final committed Base regression

- [x] Runtime Content Readiness: 68 assertions PASS.
- [x] Difficulty Definitions: 114 assertions PASS.
- [x] Difficulty Progression: 19 assertions PASS.
- [x] Teleport Coordinator: 19 assertions PASS.
- [x] Dungeon Entry Selection Rules: 9 assertions PASS.
- [x] Party Difficulty: 22 assertions PASS.
- [x] Party Difficulty Entry: 32 assertions PASS.
- [x] Party Entry Coordinator: PASS.
- [x] Party Service: PASS.
- [x] Phase 3 Systems Stress: PASS.
### Final committed Dungeon regression

- [x] Depth3 Content: 36 assertions PASS.
- [x] Depth3 Boss Factory: 8 assertions PASS.
- [x] Depth2 Content: 32 assertions PASS.
- [x] Depth2 Boss Factory: 8 assertions PASS.
- [x] Encounter Spawn Catalog: 19 assertions PASS.
- [x] Encounter Execution Bootstrap: 4 assertions PASS.
- [x] Studio Session Factory: 7 assertions PASS.
- [x] Layout Environment Contract: 14 assertions PASS.
- [x] Dungeon Encounter Bindings: 34 assertions PASS.
- [x] Combat Pack Encounter Executor: 15 assertions PASS.
- [x] Phase2A Failure Path: 24 assertions PASS.
- [x] Teleport Coordinator: 19 assertions PASS.
- [x] Dungeon Difficulty Teleport: 7 assertions PASS.
- [x] Dungeon Difficulty Progression: 19 assertions PASS.
- [x] Runtime Content Readiness: 68 assertions PASS.
- [x] Training Dummy: 9 assertions PASS.
- [x] Combat Target Rules: 9 assertions PASS.
- [x] Phase 3 Systems Stress: PASS.
- [x] live player admission succeeded.

### Release qualification

- [x] Depth3 remains release-disabled.
- [x] Depth3 remains physically unregistered.
- [x] Depth2 remains release-disabled and physically unregistered.
- [x] Depth4 remains content-incomplete and release-disabled.
- [x] no Event/Secret boss content enabled.
- [x] source-boundary audit: 8 source/test files.
- [x] source-boundary audit: 0 art/model/mesh/terrain/image files.
- [x] no TEST/PROD publish during this gate.
- [x] no PROD DataStore / Robux / monetisation action.
- [ ] feature-branch push, if explicitly approved.
- [ ] merge to main, if explicitly approved.

Detailed evidence:
`docs/testing/phase4-depth3-content-acceptance-record.md`.


<!-- PHASE4_DEPTH4_CONTENT_LOCAL_GREEN_20260918 -->
## Phase 4 - Depth4 Final-Difficulty Backend Content

**Status:** LOCAL GREEN / AWAITING PROJECT-OWNER RELEASE CLOSEOUT
**Baseline:** `230f7f5`
**RED checkpoint:** `8c3b8c2`
**Implementation checkpoint:** `8bcb58b`

### Test-first content contract

- [x] RED captured before implementation.
- [x] missing Depth4 combat pack failed as expected.
- [x] missing TempleDepth4BossFactory failed as expected.
- [x] Depth4 readiness reported missing encounter content before implementation.

### Depth4 combat content

- [x] TestDungeon Depth4Room1 registered with 5 Marauders.
- [x] TestDungeon Depth4Room3 registered with 7 Marauders.
- [x] AbandonedMine Depth4Room1 registered with 5 Marauders.
- [x] AbandonedMine Depth4Room3 registered with 7 Marauders.
- [x] Mine Deep Echoes adds one Depth4 Room1 Marauder.
- [x] Mine Crystal Bloom adds one Depth4 Room3 Marauder.
- [x] Depth4 Content: 38 assertions PASS.
### Locked miniboss chain

- [x] Depth4 keeps six logical encounters.
- [x] Room2 reuses DifficultyBossIds[1] as MiniBoss.
- [x] Room4 reuses DifficultyBossIds[2] as MiniBoss.
- [x] Room5 reuses DifficultyBossIds[3] as MiniBoss.
- [x] Room6 uses DifficultyBossIds[4] as FinalBoss.
- [x] no replacement miniboss factories introduced.

### Depth4 final-boss content

- [x] TempleDepth4Boss registered.
- [x] TempleDepth4Boss display identity: Sanctum Ascendant.
- [x] AbandonedMineDepth4Boss registered.
- [x] AbandonedMineDepth4Boss display identity: Buried Tyrant.
- [x] both factories registered in execution bootstrap.
- [x] both final bosses preserve BossRole = FinalBoss.
- [x] both retain accepted Captain controller behavior/tag.
- [x] Depth4 Boss Factory: 10 assertions PASS.
- [x] Encounter Spawn Catalog: 20 assertions PASS.
- [x] Encounter Executors: 21 assertions PASS.
- [x] Encounter Execution Bootstrap: 4 assertions PASS.
### Readiness boundary

- [x] Depth2, Depth3 and Depth4 remain Ready = false.
- [x] Depth2, Depth3 and Depth4 remain ReleaseEnabled = false.
- [x] no higher depth reports EncounterContentNotRegistered.
- [x] Depth2/Depth3/Depth4 each report exactly one issue:
  DungeonLayoutNotRegistered.
- [x] all Depth1-Depth4 encounter content is registered.
- [x] no Depth2/Depth3/Depth4 physical layout registered.
- [x] Runtime Content Readiness: 70 assertions PASS.

### Final committed static/build acceptance

- [x] clean committed checkpoint `8bcb58b`.
- [x] `git diff --check`: PASS.
- [x] repository Luau parse: 526 files, 0 failures.
- [x] Dungeon Rojo build: PASS.
- [x] Base Rojo build: PASS.
- [x] published Dungeon Rojo build: PASS.
- [x] published Base Rojo build: PASS.
### Final committed Base regression

- [x] verified PlayServer/PlayClient run.
- [x] Runtime Content Readiness: 70 assertions PASS.
- [x] Difficulty Definitions: 114 assertions PASS.
- [x] Difficulty Progression: 19 assertions PASS.
- [x] Teleport Coordinator: 19 assertions PASS.
- [x] Dungeon Entry Selection Rules: 9 assertions PASS.
- [x] Party Difficulty: 22 assertions PASS.
- [x] Party Difficulty Entry: 32 assertions PASS.
- [x] Party Entry Coordinator: PASS.
- [x] Party Service: PASS.
- [x] Phase 3 Systems Stress: PASS.

### Final committed Dungeon regression

- [x] verified PlayServer/PlayClient run.
- [x] Depth4 Content: 38 assertions PASS.
- [x] Depth4 Boss Factory: 10 assertions PASS.
- [x] Depth3 Content: 36 assertions PASS.
- [x] Depth3 Boss Factory: 8 assertions PASS.
- [x] Depth2 Content: 32 assertions PASS.
- [x] Depth2 Boss Factory: 8 assertions PASS.
- [x] Encounter Spawn Catalog: 20 assertions PASS.
- [x] Encounter Executors: 21 assertions PASS.
- [x] Encounter Execution Bootstrap: 4 assertions PASS.
- [x] Layout Environment Contract: 14 assertions PASS.
- [x] Dungeon Encounter Bindings: 34 assertions PASS.
- [x] Combat Pack Encounter Executor: 15 assertions PASS.
- [x] Phase2A Failure Path: 24 assertions PASS.
- [x] Dungeon Difficulty Teleport: 7 assertions PASS.
- [x] Dungeon Difficulty Progression: 19 assertions PASS.
- [x] Runtime Content Readiness: 70 assertions PASS.
- [x] Training Dummy: 9 assertions PASS.
- [x] Combat Target Rules: 9 assertions PASS.
- [x] Phase 3 Systems Stress: PASS.
- [x] live player admission succeeded.
### Release qualification

- [x] Depth2-Depth4 remain release-disabled.
- [x] Depth2-Depth4 remain physically unregistered.
- [x] all Depth1-Depth4 backend encounter content registered.
- [x] no Event/Secret boss content enabled.
- [x] source-boundary audit: 10 source/test files.
- [x] source-boundary audit: 0 art/model/mesh/terrain/image files.
- [x] no TEST/PROD publish during this gate.
- [x] no PROD DataStore / Robux / monetisation action.
- [ ] feature-branch push, if explicitly approved.
- [ ] merge to main, if explicitly approved.

Detailed evidence:
`docs/testing/phase4-depth4-content-acceptance-record.md`.

### Optional Boss candidate: 19 September 2026
- [x] Policy: 49 assertions PASS in Dungeon Studio.
- [x] Optional Secret flow: 9 assertions PASS.
- [x] Four boss factories: 24 assertions PASS.
- [x] Release locks: 14 assertions PASS.
- [x] 537 Luau parse; four Rojo builds PASS.
- [x] Base/Dungeon gameplay regression suites PASS.
- [ ] Optional physical boss arenas and event/secret unlock issuers remain unimplemented.
- [ ] Commit/push/merge/publish not performed.

### Optional-boss code-only backend closeout

- [x] Run-state issuer: 28 offline Luau assertions PASS.
- [x] Instance director: 10 additional rollout-lock checks authored.
- [x] All four final candidate Rojo builds and git diff check PASS.
- [ ] Extended director/run-state Studio tests not rerun.
- [ ] Physical arenas and full gameplay acceptance not started.
- [ ] Production release remains disabled.\r\n\r\n
## UI/HUD candidate - 19 September 2026

- [x] 531 Lua/Luau files parsed and git diff whitespace check clean.
- [x] Four Rojo builds pass.
- [x] Base Studio regression and Phase 3 stress pass.
- [x] Dungeon repeat: Training Dummy 9/9, Combat Target Rules 9/9,
  Phase 3 stress, player admission, zero project errors.
- [x] No art/model/mesh/terrain/image files changed.
- [ ] Player-facing desktop/mobile viewport visual acceptance.
- [ ] Contextual prompts, modal close, party entry and boss HUD manually
  exercised by player before release.
- [ ] Feature branch merge / publish only with explicit approval.

Evidence: docs/testing/phase4-ui-hud-overhaul-candidate-acceptance-record.md.


## 23 September 2026 — Frostfang V16 foreleg refinement review candidate

The owner requested focused foreleg refinement, preserving the existing wolf
and engine. Source checkpoint `33fa88f` includes the final solver fixes;
subsequent changes document and verify the same candidate. Work remains on
`wip/phase-4-test-hud-integration-v1` in the HUD integration worktree.
Independent backend roadmap work (now v2.05) is not changed by this result.

Detailed evidence, settings, reproduction and local output paths:
[`REFINEMENT.md`](../../tools/animation/quadruped/engine/REFINEMENT.md).
Current review output: `ForelegRefinement_20260923_E` under the existing
Frostfang/GroundedWalkTrial QA folder. Editable Blend plus complete
10.375-second side/foreleg MP4s and looping side/close-up/four-view GIFs.

- Consistent foreleg bend plane, continuous shoulder articulation, independent
  front/rear parameters, calibrated paw soles, two seconds idle, four cycles,
  and balanced return. No replacement mesh or rest-bone edits.
- 15 unit tests PASS; actual Blender repeated generation has zero sampled
  matrix difference and rejects invalid settings without clearing actions.
- Full mesh audit: front elbows 139.6–165 degrees; max forepaw target error
  1.35e-7; planted toe surface drift below 0.000899 source units overall.
- Localized shoulder weight smoothing reduces worst identical-edge stretch
  2.609 -> 2.427. Geometry/rest fingerprint unchanged. Skin defects remain.
- The doubled-stride F comparison is rejected for sharper rear-knee motion.
  Keep E's supported stride as the review candidate.

No visual acceptance, complete anatomical repair, or actual Frostfang Roblox
Animator validation is claimed. Rear asymmetry, residual fur/skin deformation,
tail under-fur tearing and closed muzzle remain. No production, main merge or
Roblox publish occurred. Next action: review E's actual motion before choosing
further anatomy/skin work; preserve V16 and E for comparison.
