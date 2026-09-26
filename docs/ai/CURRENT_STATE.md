## 26 September 2026 — CURRENT v3.08 Human Wizard level-30 backend GREEN

[Roadmap](
../roadmap/DungeonMMO_Roadmap_v3_08_Human_Wizard_Level30_Complete_20260926.md);
[green evidence](
../testing/c4-human-wizard-level30-complete-v3-08-20260926.md).
Human Wizard / Emberweaver backend skill coverage is now **93/93 source rank
rows mapped through level 30 with 0 Human Wizard gaps**. The remaining
companion families are server-owned: Mana Companion 1111, Servitor Recharge
1126, Servitor Heal 1127 and Combat Companion 1225. Venom Cloud, Blood To Mana
and Corpse Siphon are also integrated through source calculation/execution
boundaries. Companion lifecycle preserves source NPC identity, EXP penalty,
lifetime loss and Spirit Ore consumption without inventing unreviewed source
NPC combat statistics.

Fresh unpublished Studio acceptance is **18/18 source-cast suites PASS** and
**39/39 expanded backend suites PASS**. Human Wizard foundation is **199
assertions PASS**, companion lifecycle **9 PASS**, companion cast bridge **6
PASS**, and cast runtime composition **3 PASS**. A genuine unpublished Dungeon
Play rehearsal confirmed server summon -> client replication, source NPC 12006,
initial reagent count 3, Servitor Heal 35 -> 100 HP, Servitor Recharge 20 -> 61
MP and clean owner teardown. Final companion meshes/animations and reviewed
source NPC combat templates/AI remain creature-content work rather than missing
Human Wizard skill rows.

No main merge, publish, production save mutation or animation edits.

## 26 September 2026 — CURRENT v3.07 Withering Hex implemented

[Roadmap](
../roadmap/DungeonMMO_Roadmap_v3_07_Human_Wizard_Withering_Hex_20260926.md);
[pending Studio acceptance](
../testing/c4-human-wizard-withering-hex-v3-07-pending-20260926.md).
Human Wizard Withering Hex now preserves source Curse: Weakness 1164:4:
magical WIT DEBUFF, source effect type CONFUSION, effect power 80, magic level
30, 600/1100 source ranges, PHYSICAL_ATTACK x0.8 and a 15-second duration.
The cast owns one magical shot. A landed debuff uses the existing server-owned
EnemyWeakeningService with exactly 0.20 power reduction and zero attack-rate
reduction, so supported NPC outgoing physical damage becomes 80 percent while
attack cadence remains unchanged. Marauder and Captain life cleanup explicitly
clears this weakening state.

Fresh diff check plus Base/Dungeon Rojo builds pass at core code candidate
`b2fb6ac0348501b49a2abf471874137f60599f81`. Studio focused/live
acceptance remains pending.

No main merge, publish, production save mutation or animation edits.

## 26 September 2026 — CURRENT v3.06 Scorch Mark implemented

[Roadmap](
../roadmap/DungeonMMO_Roadmap_v3_06_Human_Wizard_Scorch_Mark_20260926.md);
[pending Studio acceptance](
../testing/c4-human-wizard-scorch-mark-v3-06-pending-20260926.md).
Human Wizard Scorch Mark now preserves source Surrenders To Fire 1083:2:
magical WIT DEBUFF, effect power 80, magic level 30, 750/1250 source ranges,
FIRE_VULN x1.25 and a 15-second duration. The cast owns one magical shot.
A landed debuff is held by a reusable server-owned NPC elemental-vulnerability
authority. Source NPC data stays immutable; subsequent source calculations use
a temporary decorated boundary, so existing fire MDAM automatically reads the
1.25 vulnerability through the normal elemental formula. Weaker refreshes do
not multiply or reduce the active effect, and supported NPC life reset/death
clears old elemental state.

Fresh diff check plus Base/Dungeon Rojo builds pass at core code candidate
`29b28b0d0aaa417fc12196810c27c17ce67b5bb9`. Studio focused/live
acceptance remains pending.

No main merge, publish, production save mutation or animation edits.

## 26 September 2026 — CURRENT v3.05 Slumber Hex implemented

[Roadmap](
../roadmap/DungeonMMO_Roadmap_v3_05_Human_Wizard_Slumber_Hex_20260926.md);
[pending Studio acceptance](
../testing/c4-human-wizard-slumber-hex-v3-05-pending-20260926.md).
Human Wizard Slumber Hex now preserves source Sleep 1069:6: magical WIT
DEBUFF, effect power 80, magic level 30, 600/1100 source ranges and a
30-second duration. The cast owns one magical shot. A landed Sleep suppresses
supported NPC movement and attacks, interrupts active Marauder/Captain attack
sequences and wakes before ordinary direct source damage. Periodic NPC
Bleed/Poison ticks remain outside that wake path, matching the pinned
attackable-NPC source behavior. Local diff check plus Base/Dungeon Rojo builds
pass; Studio focused/live acceptance remains pending.

No main merge, publish, production save mutation or animation edits.

## 26 September 2026 — CURRENT v3.04 Life Siphon implemented

[Roadmap](
../roadmap/DungeonMMO_Roadmap_v3_04_Human_Wizard_Life_Siphon_20260926.md);
[pending Studio acceptance](
../testing/c4-human-wizard-life-siphon-v3-04-pending-20260926.md).
Human Wizard Life Siphon is now implemented through the staged source cast
pipeline. Creative rank 4 preserves Vampiric Touch 1147:6: DARK DRAIN power
32, 600/1100 source ranges and exact 0.4 absorbPart with absorbAbs 0. The
source calculator owns one magical shot and the live NPC executor computes
healing from actual HP removed before capping the caster at MaxHealth. Damage
still uses the normal source NPC observer path, preserving threat,
contribution and quest bookkeeping. Fresh diff check plus Base/Dungeon Rojo
builds pass at code candidate
`5291dac8eaa4497a928001e953f4ae533c73ce34`; Studio focused/live acceptance
is pending.

No main merge, publish, production save mutation or animation edits.

## 26 September 2026 — CURRENT v3.03 Ember Field implemented

[Roadmap](
../roadmap/DungeonMMO_Roadmap_v3_03_Human_Wizard_Ember_Field_20260926.md);
[pending Studio acceptance](
../testing/c4-human-wizard-ember-field-v3-03-pending-20260926.md).
Human Wizard Ember Field is now implemented through the staged source cast
pipeline. Rank 3 preserves source Flame Strike 1181:3: FIRE MDAM power 19,
magic level 30, 500/1000 cast/effect ranges and the exact 200-source-unit
TARGET_AREA radius. The source calculator snapshots one magical shot for the
whole target list and resolves target-specific magic rolls from that shared shot
state. Live area selection remains server-owned: the selected NPC is retained,
same-encounter reviewed NPCs inside caster radius are added, and nearby NPCs
from another encounter are excluded. Every damaged NPC still flows through the
existing threat/contribution/quest observer path. Fresh diff check and Base /
Dungeon Rojo builds pass at code candidate
`19173565960c2137a2f95e8699dea83e7e3bd6a3`; Studio focused/live acceptance
is pending.

No main merge, publish, production save mutation or animation edits.

## 26 September 2026 — CURRENT v3.02 Frost Lance implemented

[Roadmap](
../roadmap/DungeonMMO_Roadmap_v3_02_Human_Wizard_Frost_Lance_20260926.md);
[pending Studio acceptance](
../testing/c4-human-wizard-frost-lance-v3-02-pending-20260926.md).
Human Wizard Frost Lance is now implemented through the staged source cast
pipeline. Rank 2 preserves source Ice Bolt 1184:6: WATER MDAM power 16,
WIT-resisted effect power 60, exact 0.7 RUN_SPEED multiplier for 120 seconds,
and 600/1100 source cast/effect ranges. Player and NPC source boundaries now
expose WIT bonus for the hostile-effect formula. Damage owns the single
Spiritshot consumption and the slow roll reuses that shot state. Live NPC
damage still uses the existing contribution/threat observer path, while a
landed slow uses the shared server non-stacking NPC slow authority. Fresh Base
and Dungeon Rojo builds pass at candidate
`484363b3ffec2d911314201380fe5408ad154d40`; Studio focused/live acceptance
is still pending, so v3.01 remains the latest fully green Wizard batch.

No main merge, publish, production save mutation or animation edits.

## 26 September 2026 — CURRENT v3.01 targeted cast batch GREEN

[Roadmap](
../roadmap/DungeonMMO_Roadmap_v3_01_Human_Wizard_Targeted_Cast_Batch_20260926.md);
[green evidence](
../testing/c4-human-wizard-targeted-cast-batch-v3-01-20260926.md).
Human Wizard v3.01 is now fully GREEN. Fresh Base and Dungeon
Rojo builds pass, the cast-focused runner is **15/15 PASS**, and the expanded
big backend runner is **35/35 PASS**. The unpublished Dungeon Play rehearsal
also passes all four staged spell families: Ember Bolt, Flame Burst and Focused
Bolt deal real source-calculated NPC damage, while Venom Hex resolves source
Poison rank 3 and applied an exact 24-damage first tick in the accepted run.
Spiritshots were consumed exactly once by source calculation, contribution and
threat bookkeeping updated, and the final live log contains **0 project
CreatorErrors**. The validation also corrected a stale paid-revive test fixture
and stopped two Dungeon regression scripts from auto-running during Play. The
cast bridges remain disabled by default and ordinary client spell input is not
wired yet.

No main merge, publish, production save mutation or animation edits.

## 26 September 2026 — CURRENT v3.01 targeted cast batch staged

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

Remote Desktop Commander remains intentionally unused. No main merge, publish,
production save mutation or animation edits.

## 26 September 2026 — CURRENT v3.00 direct MDAM bridge staged

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

No Remote Desktop Commander was used. No main merge, publish, production save
mutation or animation edits.

## 25 September 2026 — CURRENT v2.99 Human Wizard source scheduler GREEN

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

No main merge, publish, production save mutation or animation edits.

## 25 September 2026 — CURRENT v2.98 Human Wizard exact source reuse GREEN

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

No main merge, publish, production save mutation or animation edits.

## 25 September 2026 — CURRENT v2.97 Human Wizard source timing GREEN

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

No main merge, publish, production save mutation or animation edits.

## 25 September 2026 — CURRENT v2.96 Human Wizard source cast authority GREEN

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

No main merge, publish, production save mutation or animation edits.

## 25 September 2026 — CURRENT v2.95 Human Wizard exact source combat GREEN

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

No main merge, publish, production save mutation or animation edits.

## 25 September 2026 — CURRENT v2.94 Human Wizard foundation GREEN

[Roadmap](
../roadmap/DungeonMMO_Roadmap_v2_94_Human_Wizard_Foundation_20260925.md);
[evidence](
../testing/c4-human-wizard-foundation-v2-94-20260925.md).
The Human Wizard branch is now partially playable in backend terms under the
creative **Emberweaver** identity: authenticated branch selection, ordered
level-18 quest transactions, bound proof items, level-20 mentor receipt,
saved Mage-family class identity and class-bound trainer are all implemented.
The generalized transfer-skill gate now requires the real mentor receipt for
Mage as well as Fighter paths. **74/93** launch-cap Wizard source rows are
mapped to 24 non-servitor training families; **19/93** companion-dependent
rows remain intentionally unmapped. Fresh Base/Dungeon builds PASS; Wizard
foundation **166 assertions**, quest/transfer **22**, level-30 audit **37**,
focused runner **3/3** all PASS. Next backend work is exact Human Wizard
source/effect integration followed by server-owned companions. No main merge,
publish, production save mutation or animation edits.

## 25 September 2026 — CURRENT v2.93 Human Wizard source audit GREEN

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

## 25 September 2026 — CURRENT v2.92 multiplayer cutover GREEN

[Latest roadmap](
../roadmap/DungeonMMO_Roadmap_v2_92_C4_Multiplayer_Cutover_Hardening_20260925.md)
and [green evidence](
../testing/c4-multiplayer-cutover-v2-92-20260925.md).
The last bounded C4 cutover-hardening gate is green. Two real unpublished
Dungeon clients both reached source damage against the same reviewed Room1 NPC,
with independent contribution/threat and correct highest-threat targeting.
Participant dispatch is explicitly scoped to server-selected resource-active
players. Withdrawing one selected player now performs full resource rollback:
that player immediately returned to the existing combat model and applied
10.0 damage while the remaining selected player continued source combat and
later landed ~2.567 source damage. Removing the final participant shut all
source gates down; re-enable plus whole-group rollback also passed. Fresh
focused Base **24/24 PASS**, Dungeon **27/27 PASS**, dispatch **20 assertions
PASS**, coordinator **11 assertions PASS**; fresh diff/build checks also pass.
Cutover hardening is closed. Current backend direction returns to progression,
advancement quests and level-30 launch content, followed by professions/economy,
guild/raid systems and PvP/castle capture. No main merge, publish, production
save mutation or animation edits.

## 25 September 2026 — CURRENT v2.91 live player-to-NPC rehearsal GREEN

[Latest roadmap](
../roadmap/DungeonMMO_Roadmap_v2_91_C4_Live_Player_NPC_Rehearsal_20260925.md)
and [green evidence](
../testing/c4-live-player-npc-rehearsal-v2-91-20260925.md).
A real unpublished Dungeon Play client used the existing
`CombatInputActions.begin_attack()` path against a reviewed Room1 Marauder
while the actual runtime coordinator was source-cut-over. The server accepted
Slash1, applied approximately **2.567 C4-source damage**, reduced NPC HP
48 -> ~45.433, preserved contribution/threat, and invoked the quest observer
without granting invalid quest credit. The same coordinator then rolled all
five source/live gates OFF, restored player MaxHealth to ~113.4, and the same
client input applied the existing-model **10.0 damage**, leaving the reset NPC
at 38 HP. Fresh focused Base **24/24 PASS**, Dungeon **27/27 PASS**. One final
bounded multiplayer cutover rehearsal remains before returning to the larger
MMORPG backend roadmap. No main merge, publish, production save mutation or
animation edits.

## 25 September 2026 — CURRENT v2.90 runtime cutover rehearsal GREEN

[Latest roadmap](
../roadmap/DungeonMMO_Roadmap_v2_90_C4_Runtime_Rehearsal_20260925.md)
and [green evidence](
../testing/c4-runtime-rehearsal-v2-90-20260925.md).
The real unpublished Dungeon runtime now exposes its exact atomic source-combat
coordinator only through a Studio-only ServerStorage bridge. Fresh final
focused runs pass **Base 24/24** and **Dungeon 27/27**. A genuine Studio Play
server with one connected player started with every source/live gate OFF,
atomically enabled resource/source/executor/dispatch together, moved the
player from current MaxHealth ~113.4 to source MaxHealth 98 with
`C4ResourceCutoverActive=true`, then atomically disabled everything and
restored MaxHealth ~113.4 with the attribute false. The rehearsal used explicit
test-only `SourceUnitsPerStud=1` and daylight; this is not a production
spatial mapping. Next: real source-mode player-to-NPC attack rehearsal through
existing combat input, including callback/threat/quest evidence and rollback.
No main merge, publish, production saves or animation edits.

## 25 September 2026 — CURRENT v2.89 atomic C4 combat cutover GREEN

[Latest roadmap](
../roadmap/DungeonMMO_Roadmap_v2_89_C4_Atomic_Combat_Cutover_20260925.md)
and [green evidence](
../testing/c4-atomic-combat-cutover-v2-89-20260925.md).
A server-only transactional cutover coordinator now sequences resource
authority, explicit player opt-in, source calculation, live executor and
DamageService dispatch as one reversible operation. Any participant or later
gate failure rolls all earlier changes back. Fresh Studio Base **22/22 PASS**,
Dungeon **25/25 PASS**, cutover coordinator **7 assertions PASS**. Normal
bootstrap still leaves every source/live gate OFF. Next: a genuine unpublished
Dungeon rehearsal using the real runtime coordinator and real Studio players,
followed by rollback verification. No main merge, publish, production saves or
animation edits.

## 25 September 2026 — CURRENT v2.88 level-30 source dispatch audit GREEN

[Latest roadmap](
../roadmap/DungeonMMO_Roadmap_v2_88_C4_Level30_Dispatch_Audit_Closure_20260925.md)
and [green evidence](
../testing/c4-level30-dispatch-audit-closure-v2-88-20260925.md).
The intended level-30 player-to-NPC C4 damage-family audit now has **zero
activation blockers**. The old generic Ranger is already legacy/not
fresh-creatable, and its level-1 creative Volley is deliberately **not** mapped
to C4 Burst Shot because pinned source skill 24 starts at magic level 44,
outside the agreed level-30 launch scope. Legacy RangerArea therefore fails
closed after source cutover instead of inventing a low-level C4 equivalent.
Fresh Studio Base **21/21 PASS**, Dungeon **24/24 PASS**, family audit **24
assertions PASS**, `blockers=0 activation_ready=true`. All live/source gates
remain OFF. Next: one reversible server-only cutover coordinator for the
independent gates. No main merge, publish, production saves or animation edits.

## 25 September 2026 — CURRENT v2.87 live C4 periodic status GREEN

[Latest roadmap](
../roadmap/DungeonMMO_Roadmap_v2_87_C4_Live_Periodic_Status_20260925.md)
and [green evidence](
../testing/c4-live-periodic-status-v2-87-20260925.md).
Exact C4 Bleed/Poison DEBUFF casts now route through the disabled source
executor and schedule server-owned nonlethal ticks. Wayfinder Wound is source
Bleed **13 x 4 @ 5s** and Mystic Poison Curse is source Poison **8 x 10 @ 3s**;
the creative placeholder direct/tick values are suppressed in source mode.
Periodic callbacks preserve contribution/quest/threat and progression evidence.
Fresh Studio Base **21/21 PASS**, Dungeon **24/24 PASS**, executor **22
assertions PASS**, dispatch **19 assertions PASS**. StatusPhysical/StatusMagic
are no longer activation blockers; only **RangerArea** remains. All source/live
gates stay OFF. Next: review and map RangerArea to an exact C4 source contract.
No main merge, publish, production saves or animation edits.

## 25 September 2026 — CURRENT v2.86 C4 periodic-status source GREEN

[Latest roadmap](
../roadmap/DungeonMMO_Roadmap_v2_86_C4_Periodic_Status_Source_20260925.md)
and [green evidence](
../testing/c4-periodic-status-source-v2-86-20260925.md).
Exact C4 Bleed and Poison periodic plans, effect-success arithmetic and
nonlethal tick semantics are now pinned. Player and NPC source boundaries carry
CON/MEN save bonuses plus Bleed/Poison vulnerability bases. Fresh Studio Base
**21/21 PASS**, Dungeon **24/24 PASS**, status source **14 assertions PASS**.
StatusPhysical and StatusMagic remain activation blockers until the DEBUFF cast
and live NPC scheduler consume these rules. Next: source DEBUFF execution and
server-owned nonlethal status scheduling. No main merge, publish, production
save mutation or animation edits.

## 25 September 2026 — CURRENT v2.85 MagicBasic source-normal routing GREEN

[Latest roadmap](
../roadmap/DungeonMMO_Roadmap_v2_85_C4_Magic_Basic_Normal_Routing_20260925.md)
and [green evidence](
../testing/c4-magic-basic-normal-routing-v2-85-20260925.md).
The original Spirit Orb delivery remains creative, but its disabled source-mode
damage now uses the accepted C4 ordinary attack route instead of inventing a
separate magic-basic formula. The activation audit is reduced from four to
three blockers: RangerArea, StatusPhysical and StatusMagic. Production dispatch
still refuses enable. Fresh Studio Base **20/20 PASS**, Dungeon **23/23 PASS**,
family audit **24 assertions PASS** and dispatch **17 assertions PASS**. Next:
exact C4 Bleed/Poison DEBUFF application plus periodic execution. No main
merge, publish, production save mutation or animation edits.

## 25 September 2026 — CURRENT v2.84 C4 damage-family audit GREEN

[Latest roadmap](
../roadmap/DungeonMMO_Roadmap_v2_84_C4_Damage_Family_Audit_20260925.md)
and [green evidence](
../testing/c4-damage-family-audit-v2-84-20260925.md).
Every current DamageService source family is now classified before staging
activation. Melee, RangedPhysical, Skill and MagicSkill have source routes;
MagicBasic, RangerArea, StatusPhysical and StatusMagic are explicit blockers.
Rogue bleed/player poison ticks now use distinct periodic-status source kinds,
so they cannot be mistaken for fresh PDAM/MDAM casts. Production dispatch now
refuses enable while any blocker remains. Fresh Studio Base **20/20 PASS**,
Dungeon **23/23 PASS**, family audit **24 assertions PASS**, dispatch **17
assertions PASS**. Next: exact source Bleed/Poison periodic execution, then
resolve Spirit Orb and Volley. No main merge, publish, production save
mutation or animation edits.

## 25 September 2026 — CURRENT v2.81 C4 NPC source boundary GREEN

[Latest roadmap](
../roadmap/DungeonMMO_Roadmap_v2_81_C4_NPC_Source_Boundary_20260925.md)
and [green evidence](
../testing/c4-npc-source-boundary-v2-81-20260925.md).
Standard creative Marauder and Wolf enemies now have pinned internal C4 NPC
source records and exact ordinary-NPC derived combat stats. Combat-pack spawns
retain server-owned `DungeonEnemyArchetypeId`; the NPC boundary service
requires a living Workspace Model and a reviewed mapping. Source normal,
PDAM and MDAM calculations now accept reviewed NPC targets, keep PvP
multipliers neutral against NPCs and apply exact C4 NPC race semantics. Fresh
Studio Base **18/18 PASS**, Dungeon **20/20 PASS**, NPC boundary **13
assertions PASS**, source combat **38 assertions PASS**; targeted combat-pack
identity **16 assertions PASS**. Next: disabled live player-to-NPC executor
while preserving threat/quest/contribution callbacks. No main merge, publish,
production save mutation or animation edits.

## 25 September 2026 — CURRENT v2.80 live C4 skill execution GREEN

[Latest roadmap](
../roadmap/DungeonMMO_Roadmap_v2_80_C4_Live_Skill_Execution_20260925.md)
and [green evidence](
../testing/c4-live-skill-execution-v2-80-20260925.md).
The disabled live source executor now applies accepted ordinary attacks, PDAM,
MDAM and self-HEAL. PvP damage routes through C4 CP before server Humanoid HP;
HEAL clamps through server MaxHealth; shielded PDAM receives trusted executor
spatial context. All gates remain OFF and no current CombatService route has
been switched. Fresh Studio Base **17/17 PASS**, Dungeon **19/19 PASS**, live
executor **13 assertions PASS**. Next: source-ready C4 NPC stat boundary, then the controlled dispatch adapter. No main merge, publish, production save mutation or
animation edits.

## 25 September 2026 — CURRENT v2.79 live C4 executor foundation GREEN

[Latest roadmap](
../roadmap/DungeonMMO_Roadmap_v2_79_C4_Live_Combat_Executor_20260925.md)
and [green evidence](
../testing/c4-live-combat-executor-v2-79-20260925.md).
A separately gated server-only live C4 normal-attack executor now exists. It
requires explicit spatial scale/night configuration, the independent source
calculation gate, global resource cutover and per-player cutover before it can
mutate anything. Hits route playable damage through CP before HP; misses do
not mutate resources. The executor is still OFF and no production spatial
mapping has been chosen. Fresh Studio Base **17/17 PASS**, Dungeon **19/19
PASS**, live executor **10 assertions PASS**. Runtime probe: Dungeon has live
resource authority but remains disabled; Base deliberately has no live
resource authority. Next extend live execution to PDAM/MDAM/HEAL. No main
merge, publish, production save mutation or animation edits.

## 25 September 2026 — CURRENT v2.78 spatial combat inputs GREEN

[Latest roadmap](
../roadmap/DungeonMMO_Roadmap_v2_78_C4_Spatial_Combat_20260925.md)
and [green evidence](
../testing/c4-spatial-combat-v2-78-20260925.md).
Reviewed C4 front/side/back, elevation and night hit-condition semantics plus
120-degree shield facing are now server-spatial inputs. Ordinary hit resolution
consumes the exact source condition multiplier and shielded PDAM no longer
accepts a raw facing boolean. Height is supplied explicitly in source
coordinate units so no Roblox-stud conversion is invented. Fresh Studio Base
**16/16 PASS**, Dungeon **18/18 PASS**, spatial reference **11 assertions
PASS**, formula **51 assertions PASS**, source combat **30 assertions PASS**.
Next: separately gated live source-combat executor. No main merge, publish,
production save mutation or animation edits.

## 25 September 2026 — CURRENT v2.77 PDAM skill criticals GREEN

[Latest roadmap](
../roadmap/DungeonMMO_Roadmap_v2_77_C4_PDAM_Criticals_20260925.md)
and [green evidence](
../testing/c4-pdam-criticals-v2-77-20260925.md).
Reviewed C4 PDAM skill-critical semantics are now integrated: authored
baseCritRate ×10 × authenticated STR bonus, strict private 0–999 roll, then
final PDAM ×2 after ordinary calcPhysDam. The current Power Strike source rank
correctly has zero skill-critical chance. Fresh Studio Base **15/15 PASS**,
Dungeon **17/17 PASS**, formula **51 assertions PASS**, source combat **30
assertions PASS**. Next close source spatial hit/shield inputs before the live
source-combat executor. No main merge, publish, production save mutation or
animation edits.

## 25 September 2026 — CURRENT v2.76 normal attack/PvP composition GREEN

[Latest roadmap](
../roadmap/DungeonMMO_Roadmap_v2_76_C4_Normal_Attack_PvP_Composition_20260925.md)
and [green evidence](
../testing/c4-normal-attack-pvp-composition-v2-76-20260925.md).
The disabled source-combat provider now composes one complete ordinary
single-target attack from hit, shield, physical critical/power, random
variance, authenticated target weapon vulnerability, player PvP modifier and
one-use Soulshot. PDAM uses PVP_PHYS_SKILL_DMG plus weapon vulnerability; MDAM
uses PVP_MAGICAL_DMG. A real Oathguard Deflect Arrow source effect proves Bow
vulnerability 0.84 rather than only neutral multipliers. Fresh Studio Base
**15/15 PASS**, Dungeon **17/17 PASS**, formula **49 assertions PASS**, source
combat **30 assertions PASS**. Next close server-owned spatial hit/shield
inputs before the live source-combat executor. No main merge, publish,
production save mutation or animation edits.

## 25 September 2026 — CURRENT v2.75 source shot authority GREEN

[Latest roadmap](
../roadmap/DungeonMMO_Roadmap_v2_75_C4_Source_Shot_Authority_20260925.md)
and [green evidence](
../testing/c4-source-shot-authority-v2-75-20260925.md).
Server-authoritative C4-equivalent combat charges now consume exact reviewed
weapon grade/count through InventoryService, keep private one-use charged state
and feed Soulshot/Spiritshot/Blessed Spiritshot effects into source PDAM, MDAM
and HEAL. Player-facing items use original DungeonMMO names. Fresh Studio Base
**15/15 PASS**, Dungeon **17/17 PASS**, launch gear **15**, shot service **11**
and source combat **25 assertions PASS**. Next audit remaining PvP/source-target
formula modifiers and close normal-attack source damage composition before the
live executor. No main merge, publish, production save mutation or animation
edits.

## 25 September 2026 — CURRENT v2.74 elemental resolution GREEN

[Latest roadmap](
../roadmap/DungeonMMO_Roadmap_v2_74_C4_Elemental_Resolution_20260925.md)
and [green evidence](
../testing/c4-elemental-resolution-v2-74-20260925.md).
Current source-ready player targets now carry all six C4 elemental
vulnerability bases and MDAM resolves the reviewed source skill element against
the authenticated final matching target stat. Wind Strike therefore consumes
final WIND_VULN rather than an invented custom multiplier. Fresh Studio Base
**14/14 PASS**, Dungeon **16/16 PASS**, formula **49 assertions PASS**, source
combat **24 assertions PASS**. Next: server-authoritative Soulshot/Spiritshot/
Blessed Spiritshot ownership and consumption. No main merge, publish,
production save mutation or animation edits.

## 25 September 2026 — CURRENT v2.73 magic failure/critical GREEN

[Latest roadmap](
../roadmap/DungeonMMO_Roadmap_v2_73_C4_Magic_Failure_Critical_20260925.md)
and [green evidence](
../testing/c4-magic-failure-critical-v2-73-20260925.md).
Final source M.Crit is now authenticated and server-rolled; the exact optional
C4 magic-failure two-roll algorithm is represented while honoring the pinned
`MagicFailures=false` default. Current-scope source M.Crit base is 8, capped
at 300/1000, and successful magic criticals feed the existing x4 MDAM branch.
Fresh focused Studio Base **14/14 PASS**, Dungeon **16/16 PASS**, formula **46
assertions PASS**, source combat **23 assertions PASS**. Next integrate source
elemental damage/vulnerability inputs. No main merge, publish, production save
mutation or animation edits.

## 25 September 2026 — CURRENT v2.72 source shield resolution GREEN

[Latest roadmap](
../roadmap/DungeonMMO_Roadmap_v2_72_C4_Shield_Resolution_20260925.md)
and [green evidence](
../testing/c4-shield-resolution-v2-72-20260925.md).
Reviewed C4 shield rate/power, DEX scaling, bow x1.3 block-rate handling,
strict server-owned block/perfect rolls and PDAM formula application are now
accepted behind the disabled source-combat gate. Shielded PDAM fails closed
unless trusted server code supplies facing eligibility; the later live executor
must derive that from authoritative world transforms. Fresh focused Studio Base
**14/14 PASS**, Dungeon **16/16 PASS**, formula **37 assertions PASS**, source
combat **21 assertions PASS**. Next: magic failure/resistance and magic
critical resolution. No main merge, publish, production save mutation or
animation edits.

## 25 September 2026 — CURRENT v2.71 physical random variance GREEN

[Latest roadmap](
../roadmap/DungeonMMO_Roadmap_v2_71_C4_Physical_Random_Variance_20260925.md)
and [green evidence](
../testing/c4-physical-random-variance-v2-71-20260925.md).
Exact C4 physical random variance is now source-authoritative behind the
disabled combat gate. All eight reviewed source weapons carry pinned rnd_dam;
unarmed attackers use 5 + floor(sqrt(level)); the server owns the inclusive
negative-to-positive roll and PDAM calculations now consume the resulting
source multiplier. Fresh Base **14/14 PASS**, Dungeon **16/16 PASS**, launch
gear **12 assertions PASS**, formula **30 assertions PASS**, source combat
**15 assertions PASS**. No live source damage is applied. Next: shield defence
success/power/perfect-shield handling. No main merge, publish, production save
mutation or animation edits.

## 25 September 2026 — CURRENT v2.70 physical critical resolution GREEN

[Latest roadmap](
../roadmap/DungeonMMO_Roadmap_v2_70_C4_Physical_Critical_Resolution_20260925.md)
and [green evidence](
../testing/c4-physical-critical-resolution-v2-70-20260925.md).
Normal physical C4 critical resolution is now source-authenticated and
server-owned behind the disabled combat gate. Final source CRITICAL_RATE is
integer-truncated and capped at 500/1000; a private 0-999 roll uses the exact
strict-greater-than source comparison. Final source stat candidates now carry
the C4 critical-power neutral bases (multiplier 1, additive 0), allowing owned
passives/active effects to compose without a second custom critical layer.
Fresh focused Studio Base **14/14 PASS**, Dungeon **16/16 PASS**, formula **26
assertions PASS**, source combat **13 assertions PASS**. PDAM skill criticals,
magic criticals and target-specific critical modifiers remain explicitly
incomplete. Next: exact source weapon random-damage variance. No main merge,
publish, production save mutation or animation edits.

## 25 September 2026 — CURRENT v2.69 normal-attack hit resolution GREEN

[Latest roadmap](
../roadmap/DungeonMMO_Roadmap_v2_69_C4_Normal_Attack_Hit_Resolution_20260925.md)
and [green evidence](
../testing/c4-normal-attack-hit-resolution-v2-69-20260925.md).
Exact C4 ordinary-attack hit resolution is now accepted behind the disabled
source-combat gate. Final authenticated source Accuracy/Evasion feed the
original delta table; source condition multiplication and 27.5%-98% caps are
implemented; the provider owns the 0-999 roll. PDAM remains separate exactly
as in the reviewed C4 SkillPdam path. Fresh unpublished Base **14/14 PASS** and
Dungeon **16/16 PASS**; formula **22 assertions PASS** and source combat **11
assertions PASS**. Runtime position/elevation/night condition mapping remains
neutral and explicit. Next implement source physical critical roll and critical
power components. No main merge, publish, production save mutation or animation
edits.

## 25 September 2026 — CURRENT v2.68 source PDAM/MDAM/HEAL calculator GREEN

[Latest roadmap](
../roadmap/DungeonMMO_Roadmap_v2_68_C4_Source_Combat_Calculation_Provider_20260925.md)
and [green evidence](
../testing/c4-source-combat-calculation-provider-v2-68-20260925.md).
After the green reversible v2.67 HP/MP/CP cutover, the next source-combat layer
is now in place: a disabled server-only provider calculates C4 PDAM, MDAM and
instant HEAL from the authenticated final source stat candidate and genuinely
owned source skill rank. Source skill power is formula input, never copied
directly into Roblox damage. Fresh Base **13/13 PASS** and Dungeon **15/15
PASS** at 0e859222. Nothing applies live damage yet; shot, hit, critical,
random weapon range, shield, magic failure, elemental and PvP inputs remain
neutral until server-authoritative. Resource cutover and combat calculation
gates both stay OFF by default. No main merge, publish, production save
mutation or animation edits.

## 25 September 2026 — CURRENT v2.67 reversible live resource cutover GREEN

[Latest roadmap](
../roadmap/DungeonMMO_Roadmap_v2_67_C4_Reversible_Resource_Cutover_20260925.md)
and [green evidence](
../testing/c4-reversible-resource-cutover-v2-67-20260925.md).
The C4 source resource stack can now be applied to real players through a
server-only gate without making it the production default. Real HP, MP and CP
switch to authenticated source maxima; fractions survive transitions; source
HP/MP/CP regeneration runs every three seconds; playable attacks consume CP
first; NPC damage bypasses CP; respawn reapplies source authority; rollback
returns to the current custom resource model. Base focused **12/12 PASS**,
Dungeon **14/14 PASS**, and genuine two-player unpublished Play passed with
both cutover markers at e2fb63d1. The feature remains OFF by default,
`CanApplyLive=false` remains a rollout guard, and nothing was published or
saved to production. Next move to a reversible disabled source physical/
magic/healing combat provider so custom damage bonuses cannot be double-stacked
over C4 source formulas.

## 25 September 2026 — CURRENT v2.66 pre-cutover source parity GREEN

[Latest roadmap](
../roadmap/DungeonMMO_Roadmap_v2_66_C4_Resource_Regen_Armor_Sets_20260925.md)
and [green evidence](
../testing/c4-resource-regen-armor-sets-v2-66-20260925.md).
Unified C4 candidates now include exact ordinary REG_HP/MP/CP calculator stats,
so owned regen passives and active effects execute in source order. The
creative six-slot inventory also reproduces C4 Chest+Legs internally: all
eight current Body items map to matching source sets, exact armor conditions
require the matching set, and FuncPDefMod includes Legs. Fresh Base **12/12
PASS** and Dungeon **13/13 PASS** at b610d05c. Clean source prerequisites are
still zero-blocker and CutoverPrerequisitesReady=true, while CanApplyLive and
all live HP/MP/CP flags remain false. Next build the reversible,
disabled-by-default resource cutover service, source three-second regen, PvP CP
routing, respawn handling and rollback. Permanent code/docs stay GitHub-only;
no main merge, publish, production save mutation or animation changes.

## 25 September 2026 — CURRENT v2.65 C4 resource prerequisites GREEN

[Latest roadmap](
../roadmap/DungeonMMO_Roadmap_v2_65_C4_Combat_Point_Runtime_20260925.md)
and [green evidence](
../testing/c4-combat-point-runtime-v2-65-20260925.md).
The final CP prerequisite is implemented: exact pinned source regen and
playable-attacker CP absorption are represented by a private server runtime,
with NPC damage bypass and certified-source-only max CP configuration. Clean
reviewed characters now report **zero migration blockers** and
`CutoverPrerequisitesReady=true`. This is readiness only:
`CanApplyLive=false` and live Health/Mana/CP integration remain false, so
current Dungeon gameplay has not been switched. Fresh Base **11/11 PASS** and
Dungeon **12/12 PASS** at 2aae5124. Next build a reversible,
disabled-by-default resource cutover service and acceptance-test enable,
updates, respawn, playable CP absorption, NPC bypass and rollback before any
default activation. Permanent edits stay GitHub-only; no main merge, publish,
production save mutation or animation edits.

## 25 September 2026 — CURRENT v2.64 active source boundary complete

[Latest roadmap](
../roadmap/DungeonMMO_Roadmap_v2_64_C4_Active_Effect_Boundary_20260925.md)
and [green evidence](
../testing/c4-active-effect-boundary-v2-64-20260925.md).
Equipment, actually-owned passives and authoritative current active/toggle
effects now compose into one C4 source stat candidate. Timed statuses expire
from private server state; unresolved effects remain blockers. Persistent
launch coverage is **21 skills / 25 ranks, 25/25 mapped**. Fresh Base 10/10
and Dungeon 11/11 focused suites are green at 1e01640f. The only remaining
fixed coordinated migration blocker is `LiveCPRuntimeUnavailable`. Next
implement CP as a server-authoritative PvP resource without making dungeon
monster damage consume CP. Live C4 resources remain disabled. Permanent edits
stay GitHub-only; no main merge/publish/prod save/animation changes.

## 25 September 2026 — CURRENT v2.62 live toggle source state GREEN

[Latest roadmap](
../roadmap/DungeonMMO_Roadmap_v2_62_C4_Authoritative_Active_Source_State_20260925.md)
and [green evidence](
../testing/c4-authoritative-active-source-state-v2-62-20260925.md).
The four existing server-owned toggle executors now maintain a private
authoritative C4 source-effect registry. Source IDs never come from clients;
the registry re-resolves real owned creative rank against the authenticated
runtime character and invalidates on deactivation/upkeep failure/respawn/
player removal. Base 9/9 and Dungeon 10/10 focused suites are green at
d379e966. Timed CombatStatusService effects and Ironvow Endurance Surge are
still outside the registry, so ActiveEffectOrderingIncomplete remains. Next
bridge those timed paths and feed the authoritative snapshot into the resource
boundary. Permanent edits remain GitHub-only; no main merge/publish/prod save.

## 25 September 2026 — CURRENT v2.61 source active-effect ordering GREEN

[Latest roadmap](
../roadmap/DungeonMMO_Roadmap_v2_61_C4_Active_Effect_Calculator_Ordering_20260925.md)
and [green evidence](
../testing/c4-active-effect-calculator-ordering-v2-61-20260925.md).
The source calculator now shares C4 operation ordering across reviewed
equipment, actually-owned passives and supplied active/toggle effects. Named
stack groups choose their strongest source stackOrder, and independent effects
remain independent. Fresh Base **8/8 PASS** and Dungeon **9/9 PASS** at
08015086. This is not yet live active-state authority:
`ActiveEffectStateAuthoritative=false` remains explicit, so the
ActiveEffectOrderingIncomplete cutover blocker stays in place. Next wire real
server-owned live toggles and timed buffs to an authoritative source-effect
state registry; learned skills alone must never count as active. CP runtime is
the remaining fixed blocker after that. Permanent code/docs stay GitHub-only;
no main merge, publish, production save mutation or animation edits.

## 25 September 2026 — CURRENT v2.60 owned passive migration source-ready

[Latest roadmap](
../roadmap/DungeonMMO_Roadmap_v2_60_C4_Owned_Passive_Source_Resolution_20260925.md)
and [green evidence](
../testing/c4-owned-passive-source-resolution-v2-60-20260925.md).
The current six-slot source equipment candidate now composes with **actually
owned**, authenticated C4 passive ranks. Starter inheritance for first-transfer
classes is included; level alone never grants a rank. Unsupported custom
passives or impossible saved ranks remain explicit dynamic blockers. Fresh
Base focus **7/7 PASS** and Dungeon **8/8 PASS** at e6925d66. Global equipment
and owned-passive mapping blockers are now closed for clean reviewed character
state. The two fixed coordinated blockers left before live C4 resources are
active-effect ordering and a live CP runtime. Next implement active/toggle
source effect ordering from authoritative runtime state, without treating
learned skills as active. Permanent code/docs stay GitHub-only; no main merge,
publish, production save mutation or animation changes.

## 25 September 2026 — CURRENT v2.59 C4 inventory migration source-ready

[Latest roadmap](
../roadmap/DungeonMMO_Roadmap_v2_59_C4_Six_Slot_Paperdoll_Expertise_20260925.md)
and [green evidence](
../testing/c4-six-slot-paperdoll-expertise-v2-59-20260925.md).
The complete current six-slot equipment model is now source-mapped: **27/27**
Equipment definitions have reviewed C4 item records. Helmet/Gloves/Boots are
no longer ignored; they convert to source Head/Gloves/Feet and participate in
exact original 0x10 item adds plus 0x20 paperdoll deductions. Original
Expertise 239 thresholds are enforced by source grade. Fresh Base 6/6 and
Dungeon 7/7 focused suites are green. The global inventory mapping blocker is
closed. Remaining coordinated live C4 resource blockers are owned passive
translation, active-effect ordering and CP runtime. Next resolve only actually
purchased/currently owned passives into highest owned C4 ranks and surface
unmapped custom passives instead of stacking their authored bonuses on C4.
No main merge, Roblox publish, production save mutation or animation edits.

## 25 September 2026 — CURRENT v2.58 local acceptance GREEN

Fresh unpublished local acceptance is now complete at
`e61eeb803bd0725aa89581a352583017d32f9fc5`. Both Base and Dungeon Rojo
builds PASS. Base focused v2.55-v2.58 source/resource runner PASS **5/5**:
C4 skill-runtime rules 13 assertions, nine-class authenticated skill preview
554, resource boundary 42, creative item map 43 and launch core gear 8.
Dungeon focused runner PASS **6/6**, adding ManaService 13 assertions. The
earlier combined runner exposed two test-harness bugs only: Base has no
Combat.Tests folder, and the expanded skill-preview fixture called a
nonexistent Runtime.get_character helper. Both were corrected in GitHub before
the final green rerun. All 18 current Weapon/Body/OffHand items remain reviewed
against pinned C4 source items; Helmet/Gloves/Boots still fail closed and the
live HP/MP/CP switch remains blocked by remaining inventory paperdoll,
owned-passive, active-effect and CP-runtime work. No publish, production saves,
main merge or animation changes.

## 25 September 2026 — CURRENT v2.58 reviewed launch core gear complete

[Latest roadmap](
../roadmap/DungeonMMO_Roadmap_v2_58_C4_Launch_Core_Gear_Source_Expansion_20260925.md)
and [focused test scope](
../testing/c4-launch-core-gear-source-v2-58-20260925.md).
All 18 current Weapon/Body/OffHand creative equipment definitions now resolve
to reviewed pinned C4 source records. Added original Trident291, NetiBow1181,
NetiDagger1182, Brigandine352 and Manticore395 exact source values. The actual
server-owned resource boundary now reports reviewed source core-loadout IDs,
while Helmet/Gloves/Boots fail closed because multi-slot source P.Def ordering
is not yet integrated. This narrows OriginalInventoryMappingIncomplete to the
remaining paperdoll slots rather than core equipment. No live HP/MP/CP switch
yet. v2.55-v2.58 new tests remain pending until the resumed local playtest pass.
Next local action: fast-forward the Phase4 HUD worktree, disposable Base/Dungeon
Rojo builds, then focused Studio tests only; avoid rerunning unrelated green
suites. No main merge/publish/production saves or animation changes.

## 25 September 2026 — CURRENT v2.57 reviewed C4 item mapping

[Latest roadmap](
../roadmap/DungeonMMO_Roadmap_v2_57_C4_Creative_Item_Source_Map_20260925.md)
and [pending test scope](
../testing/c4-creative-item-source-map-v2-57-20260925.md).
C4CreativeItemSourceMap now explicitly links nine current creative equipment
items to the nine pinned C4 source item records and rejects mixed/unreviewed
Weapon/Body/OffHand loadouts. Current custom CombatModifiers are never treated
as C4 stats. This narrows but does not close v2.56's inventory migration
blocker; polearm, D-grade/expert armour and remaining equipment still need
verified original references or compatibility-only classification. New v2.57
tests are authored but no Rojo/Studio execution is claimed; v2.56 and v2.55
new tests remain pending too. Next expand reviewed launch item coverage and
connect only fully reviewed server-owned loadouts into the resource migration
boundary, then resolve actually owned source passives and active-effect/CP
ordering. Permanent code/docs GitHub-only; no main merge, publish, production
save mutation or animation edits.

## 25 September 2026 — CURRENT v2.56 C4 resource migration boundary

[Latest roadmap](
../roadmap/DungeonMMO_Roadmap_v2_56_C4_Resource_Migration_Boundary_20260925.md)
and [pending test scope](
../testing/c4-resource-migration-boundary-v2-56-20260925.md).
A new server-authenticated C4ResourceMigrationBoundary now returns exact source
base HP/MP/CP for all nine current original Human/Elf starter and first-transfer
paths from the actual selected character, while **CanApplyLive=false**. Four
cutover blockers are explicit: full original inventory mapping, actually owned
source-passive mapping, active-effect ordering and a live CP runtime. This
prevents exact C4 base vitals from being mixed with the current custom
equipment/passive/buff model. ProgressionRuntimeState exposes the boundary;
forged first-transfer identity and level>30 still fail closed. New focused
tests are authored but **no v2.56 Rojo/Studio execution is claimed**. v2.55
split-MP/heal tests are also still pending execution. Next implement the
current-item→reviewed-source-item migration map, then owned passive resolution,
active-effect/CP ordering, and only then a coherent all-nine HP/MP/CP live
switch. No main merge, Roblox publish, production save mutation or animation
worktree edits. Permanent code/docs remain GitHub-only.

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

## 24 September 2026 — class backend v2.08, focused Studio and live HP verified

Current class backend roadmap is
`docs/roadmap/DungeonMMO_Roadmap_v2_08_Oathguard_Shield_Masteries_20260924.md`;
the roadmap index selects it over older historical status sections.
Branch `wip/phase-4-test-hud-integration-v1`.
Oathguard has newly authored 20/28 purchased shield-mastery ranks,
personally earned Knight-only, requiring a server-owned equipped
OffHand Shield for 0.8% hostile physical mitigation per rank
(maximum 1.6%). The own-class trainer, reference-rank mapping,
server passive/runtime/damage paths and focused test fixtures
were committed through GitHub. Knight historical 20/24/28 rank
schedules now candidate-map **37/54** (17 unmapped); Warrior
**27/62** (35 unmapped). **No new Studio or Rojo run** occurred
during this GitHub-only continuation. Pending v2.07 live Knight
self-heal/spell defence and new shield real-hit checks remain
open. Previous v2.07 Ironvow Base physical PASS is historical,
not an automatic pass for this candidate. Do not merge/publish
or treat any of 18 classes as level-30 release certified.

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

# DungeonMMO Current Engineering State

## 22 September 2026 — current C4 backend v1.77, PARTIAL

The latest current C4 backend roadmap is
`docs/roadmap/DungeonMMO_Roadmap_v1_77_C4_Poison_Cure_20260922.md`.
The separate recently updated humanoid animation roadmap
remains authoritative for assets and visual acceptance.

Current six source-mapped inventories: **340/396**
functional DungeonMMO analogue ranks (56 missing);
starting classes 151/168 and partial Rogue/Scout
189/228. Human Fighter 37/39, Elf Fighter 41/43,
Human Mystic 38/44, Elf Mystic 35/42, Human Rogue
81/99, Elven Scout 108/129. SEVEN original C4
first-transfer source class inventories still not mapped;
ZERO of the nine first-transfer class paths complete.

Human Mystic Poison Curse now deals actual delayed
server-owned NPC damage after a true projectile hit.
Mystic Cure Poison targets poisoned allies despite
full health; Elf Scout Poison Recovery is self-only.
Existing server DamageService handles authoritative
poison ticks and cancellation after cure/expiry.
Unpublished Play confirmed all three authentic hotbar
effects and no post-cure tick. Focused source/skill 20,
base 49, Scout 1080, strict coverage 7 assertions PASS;
both Base/Dungeon TEMP Rojo builds PASS. No actual
authored NPC attack yet applies poison in ordinary
gameplay; that is new content, not an accepted feature.

[Exact test record](../testing/c4-poison-status-v1-77-2026-09-22.md).
[Current backend roadmap](../roadmap/DungeonMMO_Roadmap_v1_77_C4_Poison_Cure_20260922.md).
Full saved-profile trainer GUI, source-equivalent class
quests, published multiplayer and broad final regression
are OPEN; separate Phase2A paid-revive auto-test remains
unresolved. No main merge, Roblox publish, PROD saves
or paid operations occurred.


## 22 September 2026 — previous v1.76 C4 source coverage PARTIAL

Six inventoried C4 source classes now have **336/396**
functional analogue rank entries, 60 missing:
Human Fighter 37/39; Elven Fighter 41/43; Human
Mystic 36/44; Elven Mystic 34/42; Human Rogue
81/99; Elven Scout 107/129. Original C4 first-transfer
paths fully complete: **0/9**. Seven independent
first-transfer class source skill inventories remain
to be created and implemented.

Purchased seated/running recovery passives now multiply
REAL StaminaService regen Heartbeat output subject
to actual seated/moving Humanoid checks and normal
resource pause/delay. Focused 42 recovery, 1079 Scout,
55 base, 7 overall strict audit assertions PASS. Actual
unpublished Play user physically sat in a TEMP Seat and
showed increased post-spend Stamina recovery with a
bought Human Fighter skill. Running resource effects
have focused runtime tests but not yet client movement
sampling. Both Base and Dungeon TEMP Rojo builds PASS.
[Current receipts](../testing/c4-conditional-recovery-v1-76-2026-09-22.md).
[Current roadmap](../roadmap/DungeonMMO_Roadmap_v1_76_C4_Recovery_20260922.md).

Strict `C4CatalogueCoverage.report().Completed=false`
remains correct. No full persisted-player class/trainer
flow, cloud publishing, general dungeon release
regression or production DataStore change was claimed.
Prior Phase2A paid-revive automated failure is separate.


## 22 September 2026 — previous C4 source-rank update (PARTIAL)

The six currently enumerated original C4 Human/Elf base and
partially mapped Scout class inventories have **331/396**
functional DungeonMMO rank analogues: Human Fighter 36/39,
Elf Fighter 41/43, Human Mystic 36/44, Elf Mystic 34/42,
Human Rogue 78/99 and Elf Scout 106/129. **65** source ranks
remain unimplemented, SEVEN further first-transfer class
inventories remain unenumerated, and **0/9** original C4
first-transfer branches have complete gameplay coverage.
The strict source audit still returns `Completed=false`.

Active melee evasion and Elf guard apply server-owned timed
statuses after authentic hotbar casts. The accepted damage
service combines purchased standing/running dodge with active
dodge only for direct enemy melee; Elf guard reduces actual
physical NPC damage. Three Mystic Battle Heal ranks deliver
real mana-funded friendly healing. Focused assertions
28/286/1073/24/57/7 and unpublished 18-effect client Play
test passed. Obsolete Fighter trainer count test was fixed
and passed 13 focused assertions.
[Evidence](../testing/c4-source-catalogue-v1-75-2026-09-22.md).
[Roadmap](../roadmap/DungeonMMO_Roadmap_v1_75_C4_Status_Heal_20260922.md).

No main merge, Roblox publish, production DataStore work,
new normal saved-player trainer GUI acceptance, or milestone-
wide dungeon regression has been claimed. Separate old
Phase2A paid-revive automated failure remains open.


## 22 September 2026 — v1.75 C4 backend increment, NOT COMPLETE

Latest source-backed six-class coverage: starting Human
Fighter 36/39, Elf Fighter 41/43, Human Mage 36/44,
Elf Mage 34/42, first-transfer Human Rogue 77/99 and
Elf Scout 104/129 functional analogue ranks. Total
328/396 mapped ranks, 68 still missing, and SEVEN
other C4 Human/Elf first-transfer classes not source
mapped or implemented. All nine first-transfer paths
are still INCOMPLETE by the strict audit.

Live server now computes bought Scout standing/running
direct-melee evasion, executes three-rank level-14
Battle Heal on a genuine friendly humanoid, and
returns 20/30% of actual hostile NPC Life Drain
projectile damage as healing to its authenticated
Human Mystic caster. No free effects on mere skill
visibility. New actual in-memory trainer save/reload
and level/rank denial tests passed (37 assertions).
Focused 286 Scout passive, 1070 Scout inventory,
28 Battle Heal, 11 Life Drain, 57 base audit,
7 overall coverage assertions PASS. Unpublished
Studio Play client 16 real hotbar skill effects PASS.
No actual random-dodge-rate live sample or normal
persisted-player trainer UI assertion was made.

[Detailed evidence](../testing/c4-scout-evasion-base-healing-2026-09-22.md).
[Current roadmap](../roadmap/DungeonMMO_Roadmap_v1_75_C4_Scout_Evasion_Mystic_20260922.md).
Both Base/Dungeon TEMP Rojo builds passed. Old
Phase2A paid-revive auto-test is still unresolved.
No main merge, publish, production DataStore or
paid operation occurred.


## 22 September 2026 — C4 base/first-transfer v1.74 PARTIAL

The new strict `C4CatalogueCoverage.report()` source audit
counts starting Human Fighter 36/39, Elf Fighter 41/43,
Human Mystic 31/44 and Elf Mystic 31/42 functional rank
analogues. Existing partial first-transfer source inventories
have Human Rogue 75/99 and Elf Scout 102/129, totalling
316/396 functional ranks from the SIX enumerated source
classes; 80 ranks remain unimplemented. Only TWO of the NINE
distinct original C4 Human/Elf first-transfer classes have
even partially mapped source skill inventories, and ZERO
of nine are complete.

New functional Mystic robe casting/mana/basic speed and
level-one novice physical protection are integrated into
authoritative runtime and server skill/NPC hit paths.
Novice defense expires at character level 20; robe effects
require real equipped robe and class-owned purchased ranks.
Base/Dungeon Rojo builds and 38 robe + 36 novice + 44
first-transfer tree + 63 base-audit + 7 overall-audit
focused Studio assertions PASS. `Completed=false` is
deliberate and verified, not a test failure.
[Exact test receipts](../testing/c4-base-first-transfer-coverage-2026-09-22.md).
[Roadmap](../roadmap/DungeonMMO_Roadmap_v1_74_C4_Base_First_Transfer_20260922.md).

Actual saved-player trainer GUI, new physical control
verification and published/cloud multiplayer remain open.
Previously observed Phase2A paid-revive auto-test failure
is separate and unresolved. No main merge, Roblox publish
or production DataStore/paid operation has occurred.


## 22 September 2026 — v1.73 Scout source inventory, PARTIAL PASS

C4 Human Rogue has 99 first-transfer rank entries and Elven
Scout 129 in source levels 20/24/28/32/36. The audited DungeonMMO
analogues now map **75/99 Human**, **102/129 Elf** to meaningful
skills, while the remaining 24/27 are still explicitly missing.
The source inventory records each unimplemented family and
its count. DO NOT call these source totals overall C4 parity:
the earlier Fighter/Mage audit had 13/16 mismatched brackets;
advanced careers and other classes remain incomplete.

New actual mechanics: human crit-power ranks at 24/32, race-specific
Human/Elf critical rate at 28/32, and shared Scout level-28 server
movement +6% when allowed to move, plus Human
level-36 attack-rate +6% with shorter actual basic-attack timing. Class/race/level/trainer gates
and saved ranks are authoritative. Focused Base Studio 254 passive,
1066 inventory, 38 trainer assertions PASS. Real unpublished
Dungeon Play client eight earlier ability effects plus real
light-armour damage mitigation, actual server Humanoid speed and
crit damage PASS. Evidence:
`docs/testing/c4-scout-source-catalogue-2026-09-22.md`.
Roadmap: `docs/roadmap/DungeonMMO_Roadmap_v1_73_Scout_Catalogue_20260922.md`.

Actual normal saved-player trainer UI, physical controls and cloud
multiplayer remain untested. The separate Phase2A paid-revive
auto-test failure has not been fixed in this focused scope.
No full Dungeon regression claim, `main` merge, publish,
production DataStore or unrelated art edit.


## 22 September 2026 — Rogue bleed v1.72 focused LOCAL PASS

New level-24/32 Rogue `LaceratingCut` requires
Vital Blow rank 9/proficiency 350 plus
Disrupting Cut rank 3/proficiency 110.
Actual server-only melee damage starts a bounded,
non-stacking three-tick NPC bleed; rank two increases
both direct and delayed damage. Expired/replaced ticks
do not continue; player/target invalidation cancels
the active effect. The live unpublished Play client
verified three delayed 3-HP ticks and no fourth tick
alongside the earlier Ranger/Rogue control effects.
Focused progression: 19 assertions PASS. Real
isolated-profile purchase/save/reload: 20 PASS.
Base and Dungeon Rojo builds passed.

C4 Rogue and Elven Scout have Bleed at levels
24/32, but C4 requires a **dagger**; DungeonMMO
currently uses a temporary one-handed sword. This
is a functional analogue, NOT exact source parity
or a completed C4 catalogue. Earlier Fighter/Mage
13/16 reference bracket mismatch and unmapped
Ranger/Rogue career volumes remain open. Separate
`Phase2AFailurePathTest` automatic paid-revive
failure was observed again; no full Dungeon suite
was accepted.

[Roadmap v1.72](../roadmap/DungeonMMO_Roadmap_v1_72_Rogue_Bleed_20260922.md).
[Focused acceptance](../testing/c4-rogue-bleed-2026-09-22.md).
No GitHub `main` merge, Roblox publish or live
profile/paid operation occurred.


## 22 September 2026 — Ranger/Rogue control skills v1.71 LOCAL PASS

At backend head `f927f0d`, two original C4-inspired
Ranger/Rogue abilities were added without changing the
accepted dungeon lifecycle. **BriarVolley** (levels 5/10/15)
hits/slows two live targets; **DisruptingCut** (5/10/15)
damages and staggers a live target. Both use owned class,
trainer, weapon, SP, level and earned mastery gates.
Focused Studio tests: 41 rank/content assertions, 46
real isolated-profile training/persistence assertions;
real-client two-target slow and stagger PASS. Corrected
the stale RogueDefinitionsTest for hidden-before-earned
advanced abilities; 45 focused assertions PASS.

This remains a partial skill catalogue: Fighter/Mage
reference brackets were historically 13/16 mismatched;
Ranger/Rogue C4 counts and later specialist ranks
remain unmapped. Live client tests seeded temporary
character/loadout state and did not verify real trainer
GUI purchase. The unrelated Phase2A paid-revive
auto-test remains open; no general Dungeon regression
or published/cloud release is claimed.

[Working roadmap v1.71](../roadmap/DungeonMMO_Roadmap_v1_71_Ranger_Rogue_Control_20260922.md).
[Focused proof](../testing/c4-ranger-rogue-control-skills-2026-09-22.md).
No `main` merge, Roblox publish, production DataStore
change or repeat of old Dungeon wipe/aggro/revive/replay
tests occurred.


## 22 September 2026 — targeted live C4 skill effects PASS

At gameplay build `755fab0`, final GitHub fixture `c944ddd`
executed in an unpublished actual Dungeon Studio Play client.
DawnWard applied a server ward and spent 12 mana; CinderBolt
hit a real TrainingDummy and spent 10 mana; Ranger ArcherDraw
and RogueVitalBlow both caused real client-triggered damage.
The real SkillsMenu filtered a temporary simulated snapshot
and displayed the selected rank. `VERIFIED_PLAY_MODE_PASS`
was observed. This **does not** prove real-profile trainer
purchase/UI, physical key presses or frontal-versus-rear
bonus balance. Details: `docs/testing/c4-new-skill-live-client-2026-09-22.md`.

Unscoped automatic Dungeon tests emitted separate
`Phase2AFailurePathTest` and `RogueDefinitionsTest` failures;
these require targeted follow-up and are not marked green.
Exact C4 rank-volume parity remains open. No published
place, production DataStore, `main` merge or unrelated
Dungeon regression was performed.


## 22 September 2026 — four-family C4-like progression backend v1.70

Latest focused gameplay source `687e27c`. All
currently supported Fighter/Mage/Ranger/Rogue families
have level/rank/mastery-gated basics, functional weapon
damage/mastery/ward/shot/rear-attack abilities and
earned advanced-class specialist skills. New Arcanist
Ember and Spellweaver Aegis use existing Mage combat
executors with correct spell-specific mana and damage
source. Rogue finishers require max nine-rank basic
Vital Blow; service/preview/trial gates remain
server-authoritative. Base build and 74 focused
assertions passed at final source; both Base/Dungeon
built at previous implementation head `d1ca4fa`.

**Boundary:** Fighter/Mage C4 count audit still reports
13/16 unmatched brackets, Ranger/Rogue source rank
parity is not yet mapped, and new real-client spell/
ability impacts are pending. Existing dungeon replay/
wipe tests deliberately not repeated.
[Roadmap v1.70](../roadmap/DungeonMMO_Roadmap_v1_70_All_Four_C4_Class_Families_20260922.md).
[Evidence](../testing/c4-all-four-class-families-2026-09-22.md).


## 22 September 2026 — v1.69 early Mage spells / skill visibility

Focused gameplay/test head `e6033e0`: two early Mage
active abilities Dawn Ward (14/21/29 protection) and
Cinder Bolt (12/18/25 magic damage) at rank levels
1/7/14 with earned proficiency 35/100 and SP gates.
The authoritative snapshot filters unknown unreached
skills; SkillsMenu now hides those rows, while the
trainer explains and disables a *known* skill's locked
next rank. Existing learned skills remain visible.

A Base Rojo build and 39 focused skill/level/visibility
assertions passed. One read-only C4 audit reports
13/16 mismatched level brackets and 14 unmapped older
rank occurrences. The UI and actual player-input hit/
protection effects require a separate focused client
test; there was no published test or dungeon regression.
[Roadmap](docs/roadmap/DungeonMMO_Roadmap_v1_69_Mage_Starter_Unlock_Visibility_20260922.md).


## 22 September 2026 — v1.68 health/healing passive rank content

Focused gameplay source `3be5de3`: Fighter
Stalwart Training and Mage Restorative Training
each have six level/SP-paid passive ranks with
real server max-HP (+30 at rank six) and
healing-multiplier (+0.072 at rank six) effects.
The same class-safe passive resolution still
supports earlier damage passives.

One Base Rojo build, **64 new + 64 existing**
focused assertions passed. Read-only C4 rank
volume audit reports **13/16 mapped brackets
still mismatched** and 14 unmapped rank
occurrences; a Human Fighter level-10 overcount
also remains. This is new gameplay content,
NOT C4 skill parity or a normal-client fight/
heal balance test. No published game changes.

[Roadmap v1.68](docs/roadmap/DungeonMMO_Roadmap_v1_68_Vitality_Restoration_Ranks_20260922.md)
and [focused acceptance](docs/testing/c4-vitality-restoration-rank-effects-2026-09-22.md).


## 22 September 2026 — v1.67 physical/magic passives focused PASS

At gameplay source `08710c1`, Fighter Iron Discipline
and Mage Arcane Discipline now have six SP-purchased
passive ranks each. Rank levels 5/10 and 7/14 produce
server-authoritative physical and magical multiplier
bonuses; a non-owning class receives no benefit.
One Base Rojo build + 64 focused assertions PASS.
C4 source-rank volume remains incomplete in all 16
mapped brackets. Live combat impact/balance and
broader source-level class rank content remain
separate. No old dungeon regression loop was run.

[Roadmap](docs/roadmap/DungeonMMO_Roadmap_v1_67_C4_Passive_Ranks_20260922.md).
[Focused acceptance](docs/testing/c4-passive-rank-effects-2026-09-22.md).


## 22 September 2026 — v1.66 C4 RANK CONTENT (STILL NOT PARITY)

Read
`docs/roadmap/DungeonMMO_Roadmap_v1_66_C4_Early_Rank_Content_20260922.md`
and
`docs/testing/c4-early-fighter-mage-skill-ranks-2026-09-22.md`.
Focused tested source `cdecfc76ff4450dc329c1612e7834b8042f9b98b`.

The user's C4 goal is **equal skill-RANK volume per mapped
class/training level**, with real combat/passive/craft effects,
not just a few new skill IDs. This increment adds:
- Fighter Iron Cleave and Pursuit Step: **nine actual combat ranks
  EACH**, three at levels 5/10/15, with own SP/proficiency
  thresholds and genuinely increasing server damage.
- Mage Renewing Light: **six actual heal ranks**, three at
  levels 7 and 14, using existing MageHeal executor.
- Per-skill proficiency thresholds in rank purchase, caps,
  snapshot and ProfileMigration. Initial focused test exposed
  old tier-only migration truncating long-rank proficiency;
  fixed in production while retaining three-rank legacy caps.

One Base Rojo build and focused 133 Fighter assertions passed
at `d812a73`. At `cdecfc7`, one Base build, 37 Mage
assertions, affected existing skill/class/quest contracts 5/5
and **read-only 16-bracket C4 gap audit** all completed.
The new measured counts are Fighter 7 authored ranks at
each 5/10/15 bracket and Mage 4 at 7/14. **All 16 mapped
source brackets STILL fall short**. Levels 1/5, legacy
rank mappings, passives and wider race/class coverage
are open. Never label this C4 parity or full class
content. The focused skill tests cover effects in
server combat definitions and profiles, not normal
player-input fight/heal balancing.

NEXT CONTENT: implement real passive/utility/crafting
effects and mapped rank families at verified C4 level
brackets; extend source mapping across corresponding
class/race paths without double-counting Ranger/Rogue.
Use data-driven authoring and keep unlocks server-owned.
Do not restart old dungeon wipes/aggro/revive/multiplayer
test loops. Real-network reconnection, published TEST
travel and cloud continuity remain separately gated.
All scripts/docs GitHub-only; remote only clean pull,
one local Base build and focused new-feature acceptance;
no Roblox publish or main merge.


## 22 September 2026 — exact C4 skill-volume goal OPEN (v1.65)

Previously completed v1.64 mastery prerequisites and
level gating do **not** satisfy the new exact number
of C4 skill ranks offered at every mapped class level.
First 16 source-verified Human/Elf Fighter/Mystic
early-level entries recorded in
`src/ReplicatedStorage/Core/Shared/C4SkillVolumeTargets.luau`.
Read-only focused Studio volume audit at `29d117a`
found **16/16 unmatched level brackets** and existing
skills without authored level-to-rank schedules.
It deliberately does not count unimplemented abilities,
unmapped old ranks or skill icons as source-equivalent
gameplay.

New basic milestones are aligned to first C4 Fighter
5/10/15 and Mystic 7/14/20 training brackets.
One Base build and focused SkillMasteryGates and C4
volume report both executed. Actual broad C4 skill
catalogue, passives, utility, multi-rank rank-effects
and post-20 class-tree mappings remain to be BUILT.
[Source-backed gap spec](
docs/design/C4_Skill_Count_Parity_20260922.md).
[Active roadmap v1.65](
docs/roadmap/DungeonMMO_Roadmap_v1_65_C4_Skill_Volume_20260922.md).


## 22 September 2026 — skill mastery ladder / level-40 cap (v1.64)

Gameplay source `bf93f07`: four additional rankable
base-class combat skills with levels 8/14/20;
class trial requires level 20 and two fully
mastered prerequisite core skills; specialist
Fighter/Ranger skill ranks unlock at 24/28/32 only
after earning the right advanced class and basic
skill mastery. Unknown locked skills remain
hidden in trainer/journal snapshots, and server
purchase/use independently validates the gates.
Post-20 XP progression and cap 40 now permit
specialist ranks without altering the old 1–20
curve.

Gameplay source `e0e2f39`: successful zero-damage
Taunt/VanguardChallenge now earns bounded control
proficiency through the authoritative dungeon
encounter bridge. Ineffective taunts or disconnected/
spectating members cannot farm mastery.

Local receipts: 62 skill mastery assertions, 44
extended-level assertions, 5/5 affected contracts
at `bf93f07`; one Dungeon Rojo build and seven
taunt mastery assertions at `e0e2f39`. This
is not a complete Mage/Rogue specialist tree
or proof of published persistence/final balance.
[Roadmap](docs/roadmap/DungeonMMO_Roadmap_v1_64_Skill_Mastery_Level_Gates_20260922.md).
[Evidence](docs/testing/dungeon-skill-mastery-lineage-style-2026-09-22.md).


## 22 September 2026 — advanced class/skill backend (v1.63)

Gameplay/test source `b017fbce6aceb2a9ba301057a145697a471320ab`.
Human Vanguard / Elf Thornwarden (tank) and Human
Sharpshooter / Elf Windrunner (ranged damage) join
the existing Mage and Rogue race-specific paths.
Their level-20 Temple/Mine trials and Base remotes
reuse current per-character progression. Four new
exclusive trainers teach four ranked, server-authoritative
combat skills with threat/stagger/piercing/area
differences. Skill use now checks the currently
active advanced class; ranger volley ground aim
dispatch is data-driven by skill kind.

Focused Base and Dungeon Rojo builds; 66 class,
40 quest and 60 advanced ability assertions passed.
Actual in-client hits and new quest/class board UI
still need targeted integration; no full Dungeon
regression or published server tests were run.

[Roadmap v1.63](docs/roadmap/DungeonMMO_Roadmap_v1_63_Class_Progression_Role_Skills_20260922.md).
[Acceptance](docs/testing/dungeon-class-progression-expansion-2026-09-22.md).


## 22 September 2026 — story quest backend slice locally PASS

Gameplay/test source `89d8e7e`: first two one-time
cross-class Adventure quests, sequential Temple -> Mine
prerequisites, one bound Worldroot relic and usable ore/Gold
rewards, persisted one-time claims through existing
QuestService/ProfileService/InventoryService. Base now
accepts authenticated adventure Start/Claim/Snapshot remotes,
but a real-client quest board and NPC interaction are not
implemented.

**Focused evidence only:** one clean Base Rojo build and
40 QuestService assertions passed in unpublished Studio.
This is not published or final game content, nor evidence
of unassisted four-player dungeon combat. Historical local
dungeon acceptance is retained rather than rerun.
[Roadmap v1.62](docs/roadmap/DungeonMMO_Roadmap_v1_62_Story_Quest_Backend_20260922.md).
[Acceptance](docs/testing/story-quest-backend-slice-2026-09-22.md).


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


## 21 September 2026 — Four-client secret/Depth4/disconnect acceptance

GitHub feature head with latest focused verification:
`9a63c6d25ac45cd67c9a4c5a684fa4c5a26adb24`.

Real unpublished four-client physical Studio Play passed
Temple SecretArena optional-boss and Depth4 Room2
mini-boss recovery: previously cleared encounters stayed
cleared, four checkpoint auto revives succeeded, retired
bosses were replaced by new full-health models and
later rooms remained Pending. Only disposable Studio
test places unlocked the optional event/secret content;
production release settings are unchanged.

Real peer disconnection during an active Room3 boss
left three players fighting. Their later collective
wipe/revive preserved the absent member's unused
free revive, earlier room clears and boss checkpoint,
and permitted a single fresh full-health boss.

Previously stale higher-depth service expectation was
corrected for one-shot Failed broadcasting and passed
392 assertions across 12 dungeon/depth/party cases.
Six Rojo builds; backend matrix 30/30; death/revive
41 assertions. A real same-account reconnect and
published cross-place continuity remain unverified.

Evidence:
`docs/testing/dungeon-secret-depth4-disconnect-recovery-2026-09-21.md`.
Roadmap v1.59:
`docs/roadmap/DungeonMMO_Roadmap_v1_59_Secret_Depth4_Disconnect_20260921.md`.


## 21 September 2026 — real four-party encounter replay locally VERIFIED

Locally verified gameplay head: `a5c0637888f8400703d07290f790a24d3b8406bf`.
Four live Studio clients recovered after an interrupted physical
Temple Room1 fight, with four checkpoint revives and a fresh
full-health room; repeat killing a previously rewarded monster
did not increase any player's Gold, XP, Level or bestiary count.
Four-client Room3 boss and TEMP-enabled optional EventArena
boss each respawned as one new full-health boss after wipe,
without undoing cleared prerequisites.

Fixed repeated terminal Failed broadcasts in
`DungeonDeathService:tick` which had hidden ReplayWaiting.
Real two-client server-owned Play again voting now displays
Waiting for party to the first participant and simulated
replay to both when all have consented. The source passed
six Rojo builds, Dungeon backend 30/30 and death/revive
41 assertions; earlier focused threat 51, Base professions
14/14 and paid retry 15 remain passed.

Outstanding: secret/higher-depth boss wipe/re-entry,
real disconnected-party recovery, normal-client boss
loot through wipe, actual cross-place reserved replay
and cloud persistence. The latter need separate approval.

Receipt:
`docs/testing/dungeon-four-client-room-boss-event-replay-2026-09-21.md`.
Roadmap v1.58:
`docs/roadmap/DungeonMMO_Roadmap_v1_58_Four_Party_Boss_Replay_20260921.md`.


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


## 21 September 2026 — terminal wipe -> Base -> fresh retry VERIFIED

Latest tested gameplay source:
`8899fad6923628e86a8946fc9ce4c365bc738902`.
After the existing revive-decision deadline, a `Failed` dungeon
remains terminal. Connected members can now take the Return-to-Base
route without calling `abandon_member` on an already-failed session;
the real Dungeon UI exposes a failed-run return button (Studio
`VERIFIED_PLAY_MODE_PASS`). A new run started from Base must
create a new session ID, entrance checkpoint and free-revive state;
the old failed run and its reward identity are preserved.

The paid-revive callback was hardened against duplicate, late,
disconnected and failed-session spawns. It respects the actual
purchase-service order: the grant commits `PaidReviveCount` and
sets member mode `Active` before the spawn callback. A dedicated
integrated test covers the real purchase/session/death/return service
chain and passed **15 assertions**.

At that head: six Rojo builds; Dungeon backend **30/30** (including
DungeonDeathService **33 assertions**); failed-run return contract
**15 assertions**; fresh-session contract PASS; integrated paid retry
**15 assertions**; real failed-run UI Play PASS. All edits went to
GitHub; desktop used only for clean pulls/builds/unpublished tests.

**This is the safe terminal-failure -> Base -> new-run path, NOT
an in-place dungeon-room wipe/restart.** Current no-target cleanup
still resets threat only; restoring active encounter HP/spawn,
checkpoint-wide party respawn and reward-safe room re-entry remain
the next local backend milestone. Published TEST/cloud travel,
production purchases and main merge remain deferred.

Receipt:
`docs/testing/dungeon-terminal-wipe-return-fresh-run-2026-09-21.md`.
Roadmap:
`docs/roadmap/DungeonMMO_Roadmap_v1_56_Terminal_Wipe_Base_Retry_20260921.md`.


## 21 September 2026 — real four-client wipe threat reset VERIFIED

Latest gameplay source/test head:
`739e747d88d93ff00ed30497e9473edd17b037f4`.
Real four-client unpublished Dungeon Play proved independent aggro
from two actual Marauders, effective MageHeal threat, Fighter Taunt
retake, dead-healer fallback, genuine DPS departure cleanup and
**all remaining clients dead**. After three seconds with no
eligible target, both previously engaged controllers cleared
their threat ledgers; server log:
`REAL_FULL_WIPE_THREAT_RESET_PASS`, overall
`VERIFIED_FOUR_CLIENT_PASS`.

Same-head six Rojo builds and focused ThreatService 51, Dungeon
backend 30/30 and Base professions 14/14 PASS. Correct isolated
`world-boss.project.json` real two-client guardian aggro and
guardian MageHeal/Ward/Mend fixtures both
`VERIFIED_MULTIPLAYER_PASS`, superseding the older incorrect-
composition timeout. This resets **threat only**, not enemy HP,
spawn locations, weekly admission, rewards or full dungeon
session/checkpoint state. Full session wipe/retry, true reconnect,
cloud and published TEST remain pending.

Only GitHub source/docs edits and unpublished local tests were used.
No publish, main merge or production data mutation. Receipt:
`docs/testing/four-player-full-wipe-threat-reset-2026-09-21.md`.
Roadmap supplement:
`docs/roadmap/DungeonMMO_Roadmap_v1_55_Combat_Threat_Wipe_20260921.md`.


## 21 September 2026 — eligible-threat support follow-up

Current tested candidate: `b569435c9eb3cd4971eec06ca1baeeb4f17f4a09`.
An enemy receives support threat only if it already has positive
threat from a currently eligible target candidate. Stale threat
from an absent/dead former target alone no longer activates healing
aggro. Its support caster and recipient must also be eligible.

All six compositions built; the focused Studio threat contract
passed **51 assertions** (including the new absent-leader guard).
Real two-client ordinary Marauder support and ordinary aggro
fixtures both printed `VERIFIED_MULTIPLAYER_PASS` at this head.

The isolated world-boss aggro rerun was attempted but its Studio
process exceeded the **110-second outer timeout**; do not report
a current-head pass or interpret the timeout as a combat failure.
The earlier successful world-boss run remains historical evidence
from its earlier commit. World-boss aggro and actual world-boss
support need clean current-head Play. Only the orphan children
belonging to the timed-out temporary test were terminated.

All source/doc edits were GitHub-only. No Roblox publish,
main merge or cloud data mutation. Receipt:
`docs/testing/combat-support-eligible-threat-followup-2026-09-21.md`.


## 21 September 2026 — support threat and four-role contract LOCALLY VERIFIED

Latest tested source/test head:
`df33735b10010b8aed8e7acc5193970b8f4cc9b1`.
The shared ThreatService now credits 0.5 provisional threat per
*effective* MageHeal/HoT, positive Mend pulse and absorbed ArcaneWard
point. Both caster and healed/protected target must be in the enemy's
latest eligible target set, and that enemy must already hold threat;
idle nearby enemies do not receive free healing aggro. Player departure
clears their per-enemy threat and candidacy, and enemy wipe/reset clears
both the threat ledger and current eligible candidate snapshot.

Local Studio at that head: six Rojo builds; ThreatService 48 assertions,
including server-side **simulated** four-player tank/DPS/healer,
independent enemy, Taunt, disconnect and wipe contracts;
Base professions 14/14; Dungeon backend 30/30; real two-client normal
Marauder and isolated world-boss aggro PASS. A separate genuine
two-client normal Marauder fixture passed client MageHeal on an injured
Fighter, real client ArcaneWard application and a test-injected server
DamageService hit absorbed by Ward, with positive support threat:
`VERIFIED_MULTIPLAYER_PASS`.

**Follow-on real-client acceptance:** at fixture head
`04c3f1eb5087d34e49ef4cb7bd38b731de9fd610`, genuine client
MageHeal and ArcaneWard succeeded against an ordinary Marauder,
an actual NPC melee attack was absorbed by the client's Ward,
and client-driven Fighter Mend produced positive effective-heal
threat. The live fixture printed
`REAL_PEER_HEAL_THREAT_PASS`,
`REAL_NPC_WARD_ABSORB_THREAT_PASS`,
`REAL_FIGHTER_MEND_THREAT_PASS` and
`VERIFIED_MULTIPLAYER_PASS`. This supersedes the earlier
test-injected Ward-only support fixture.

**Remaining boundaries:** four-player aggro still has only simulated
server-side policy coverage, not four real clients. Real multi-enemy
room combat, full-party wipe/controller reset, controller-level
disconnect and actual healing/Ward in the isolated world-boss
session remain pending. The 0.5 support multiplier is provisional.
No Roblox place publish, TEST cloud run, main merge, production
DataStore access or force-push was performed. Source/test/docs
changes were made through GitHub only.

Receipt: `docs/testing/combat-support-threat-candidate-2026-09-21.md`.

## 21 September 2026 — local aggro/threat and Fighter Taunt verified

Normal enemies and the world-boss Captain controller now share a
server-authoritative per-enemy threat ledger. Before an eligible player
has positive threat, the nearest eligible player is targeted. Once
threat exists, the highest-threat eligible player is targeted; distance
only breaks equal-threat ties. Actual server-applied health damage adds
threat to the exact enemy hit.

A real zero-damage Fighter `Taunt` is now learnable from the Fighter
Trainer. It uses normal server skill/cooldown/stamina/melee target
validation, then moves the player above that enemy's current threat
leader using server-owned `TAUNT_BONUS_THREAT`. It does not fabricate
damage or contribution. Rogue ThreatDrop and existing respawn aggro
suppression remove a player from target eligibility temporarily.

Local two-client Play proved the policy against both an ordinary
Training Marauder and the isolated world boss. The accepted normal
enemy run covered nearest fallback, first-damage takeover,
higher-damage takeover, actual client Taunt, ThreatDrop suppression and
highest-threat reacquisition. The world-boss run proved the same
nearest/damage/higher-threat/Taunt sequence. Additional test-only
reruns proved that a dead highest-threat player immediately falls out
of the target set in both controllers.

Runtime acceptance head:
`9c744d0cfe4ecabd5b372229e446ceadc6653861`.
All six Rojo compositions built there. Threat contract 14 assertions,
Fighter Trainer 12, profile-exit recovery 18, reward retry 17 each
Base/Dungeon, Base professions 14/14 and Dungeon backend 30/30 all
passed. One-hit lethal boss and existing two-client boss regressions
also remained green. Death-fallback test-only head:
`e041bf2203c8b73b0c1c9b59aebc175a2c8cbddd`.

Next local combat work: define and verify healing/ward threat, then
four-player tank/DPS/support aggro, multi-enemy room isolation,
wipe/reset threat cleanup and disconnect candidate removal. Publishing,
real cross-server reconnect and cloud persistence remain deferred.

Receipt:
`docs/testing/combat-aggro-threat-taunt-local-2026-09-21.md`.

## Earlier 21 September local backend checkpoint (historical)

## 21 September 2026 — v1.54 LOCAL backend, publish deferred

At user request, continue backend-only work through GitHub and run
only unpublished Studio/in-memory tests. No TEST or production place
is to be published as part of this milestone.

The world-boss combat pipeline now passes the server-observed lethal
hit from DamageService to the contribution bridge. The scoped
authority credits the *actual first killing blow* after guardian
health reaches zero while still requiring the exact boss model,
admitted player, matching encounter identity and undefeated frozen
session. Unpublished one-attack Studio Play at
`5b7edc2675fd8fc6e9b6d0908bdf263742cf88b6`
passed real client lethal contribution, guardian defeat, weekly
reward once and duplicate reward zero. Earlier acceptance after
the combat change also passed the original real-client combat and
two-client party Play, plus existing target-filter/reward-retry/
profile-exit tests on source
`6252baa5bfea0694c3dd18d3c81caae19cc890a1`.

Existing local retry tests verified that a simulated failed profile
save retains the dirty weekly receipt and retry persists only one
award (17 assertions each Base and Dungeon). A departure-save
helper test verified that two failed saves leave the profile lease
owned until successful persistence (11 assertions).

Additional GitHub-only changes add exact-target lethal bridge
assertions and fix the distinct case where profile saving succeeded
but its subsequent lease release failed after local cache removal.
The updated exit test now covers this latter case. The desktop
connection became unavailable before latest-head verification; do
not claim those additional assertions or builds have passed.

Mend now records only positive server-applied healing through the
contribution bridge. An attempted genuine two-client Mage Heal
fixture failed due to unreliable injured-target state in the
test environment and was reverted to restore the accepted combat
baseline. Actual two-client skill-based healing/ward support remains
an open local test gate.

Next: reconnect authorized desktop; safely fast-forward; run all
six Rojo builds, the one-hit/two-client fixtures, updated lethal
filter and profile-exit contracts, weekly reward retry and existing
profession/Dungeon regressions. Then continue local support skills,
four-member party/wipe/return and offline persistence contracts.
Published travel, same-account true cross-server reconnect and cloud
storage tests remain deliberately deferred.

Receipt: `docs/testing/weekly-world-boss-v154-local-backend-continuation-2026-09-21.md`.

## Earlier 21 September party checkpoint (historical)

## 21 September 2026 — v1.54 two-client party resilience locally verified

The isolated weekly world-boss backend now has a local two-client
acceptance path. Two genuine Studio clients damage one shared guardian
through the existing CombatService/DamageService path, both persist
their own contribution and both receive independent once-per-week
rewards after the shared kill. Immediate duplicate claims pay zero.

A new `WorldBossMemberLifecycle` owns encounter character
attributes, Active/Dead member mode, replicated Humanoid death and
safe delayed respawn into the same frozen encounter. The accepted
multiplayer fixture kills one real client-owned Humanoid, observes
the server `Died` signal, persists that member as Dead, automatically
respawns them into the same session as Active and verifies no second
weekly payout. The first client then leaves the real Studio network
while the other remains present; stored contribution and reward state
remain intact.

The current prototype wipe policy is also explicit: connected dead
members are independently respawnable and a wipe does not reroll or
clear the event/boss/week snapshot. `WorldBossArenaLayout` provides
an opt-in primitive enclosed arena with a stable
`WorldBossArenaSpawn`; normal Base/Dungeon compositions are not
changed by that prototype.

Roblox Studio multiplayer clients use negative UserIds, which exposed
another test-environment mismatch. ContributionService and
DungeonContributionBridge now accept negative integral IDs only while
`RunService:IsStudio()`; live player IDs remain positive-only.
Zero/nonfinite/malformed IDs and contribution events remain denied.

Final local acceptance at source
`e83e4fae522582ec98bfc9cf4938ffdca9aa810b`: six Rojo builds;
multiplayer Play `VERIFIED_MULTIPLAYER_PASS`; lifecycle/wipe
14 assertions; contribution 20; Base travel 18; Base return 22;
Dungeon world-boss session 33; Base professions 14/14; Dungeon
backend 30/30.

Same-account network reconnect remains explicitly unverified because
Studio cannot prove the exact same Roblox account reconnecting across
a new reserved server. Published TEST Base → ReserveServer boss →
Base, real lease handoff and TEST DataStore/MemoryStore recovery are
the next release gate. Two-client real healing/ward skill execution
also remains pending. Event flags remain off and no cloud publish,
production DataStore write, force-push or main merge occurred.

Roadmap: `docs/roadmap/DungeonMMO_Roadmap_v1_54_Weekly_World_Boss_Foundation.md`.
Receipt: `docs/testing/weekly-world-boss-v154-party-resilience-2026-09-21.md`.

## Earlier 21 September real-combat checkpoint (historical)

## 21 September 2026 — v1.54 real guardian combat locally verified

The isolated world-boss place now reuses the existing full combat
server/client runtime and the existing Marauder Captain AI controller.
The ordinary prototype ArenaBuilder remains excluded. On boss
admission, characters receive the frozen weekly encounter ID so the
guardian targets only that encounter's participants.

World-boss contribution is now scoped to the exact active guardian
and active admitted party. The combat bridge filters unrelated or
same-name targets, and WorldBossCombatAuthority revalidates live
membership, encounter identity, undefeated weekly state and support
targets before forwarding any contribution to the existing
ContributionService.

A real unpublished Studio client used the normal CombatService attack
RemoteEvent to damage the guardian. The same normal DamageService
callback persisted contribution, the guardian AI damaged the player,
the player defeated the guardian without direct health injection, and
the verified weekly reward paid exactly once. Markers:
`REAL_CLIENT_HIT_PASS`, `SERVER_CONTRIBUTION_PASS`,
`GUARDIAN_ATTACK_PASS`, `REAL_CLIENT_BOSS_DEFEAT_PASS`,
`WEEKLY_REWARD_ONCE_PASS`, `VERIFIED_PLAY_MODE_PASS`.

That Play test exposed and fixed two real runtime bugs: a nil access
when stored weekly event state was absent/malformed, and a local
`event` variable that shadowed the incoming combat event and caused
genuine hits to be rejected. The runtime also retries post-defeat
reward grants and blocks Base return while an earned qualifying
reward is still unsaved.

Final source head
`7605c811bb9f9a13ce2fb56f6b68a76f8c63ae89` passed six Rojo
builds, seven damage-filter assertions, default-off boss-place Play,
14 contribution-service assertions, weekly policy/factory 40+8,
Base professions 14/14 and Dungeon gameplay 30/30.

This is still **not** the complete published game journey. The real
dedicated place needs an authored WorldBossArenaSpawn/basic arena.
The accepted combat fixture manually creates its disposable session
and guardian, so Base entry, Roblox ReserveServer travel, real lease
handoff, Base return and cloud DataStore/MemoryStore recovery were
not exercised in one networked flow. Multi-client boss combat,
party wipe/death and disconnect/rejoin remain pending. Event flags
stay off. No cloud publish, main merge, force-push or production
player DataStore write occurred.

Receipt:
`docs/testing/weekly-world-boss-v154-real-combat-2026-09-21.md`.

## Earlier 21 September world-boss travel checkpoint (historical)

## 21 September 2026 — v1.54 isolated world-boss travel and return

A separate default-off Base boss gateway, new reserved-server travel
coordinator path, dedicated world-boss-only Rojo place, stored-session
arrival checks and per-member Base return path are on the active GitHub
branch. Ordinary Dungeon rejects boss-session routing. The dedicated
world-boss place remains disabled without explicit server enablement,
reservation and an authored arena anchor. The normal Temple portal
and existing dungeons remain unchanged.

Unpublished Studio verified six Rojo compositions, 18 reserved-travel
assertions each in Base and Dungeon, 22 Base return assertions,
10 ordinary-Dungeon admission assertions and five isolated boss
destination assertions. A dedicated-place default-off Play check
passed. Previously accepted session/profession/gameplay regression
suites still passed, including real Base material-chain Play.

**Fixed a critical reward-contract bug:** the actual server
ContributionService returns Damage/Tank/Support at the top level,
not in a nested snapshot field. The isolated boss runtime now uses
WorldBossContributionRules; 14 real-service assertions passed in
both Base and Dungeon. Failed Base return teleports roll back
WorldBossReturnPending, allowing the member to reconnect to the
boss. The first validated boss session is bound before yielding
profile/lease operations to prevent competing-party admission.

This is source and local Studio contract acceptance, **not** a
real Base → published reserved boss → Base Play acceptance.
The boss place still lacks its authored arena, connected player
combat/guardian attack and live contribution recording pipeline,
published TEST transfer, cross-server profile/lease recovery,
multi-client boss fight and production enablement. Do not claim
these as complete or enable the event. No public publish, main
merge, force-push or production player DataStore change occurred.

Roadmap:
`docs/roadmap/DungeonMMO_Roadmap_v1_54_Weekly_World_Boss_Foundation.md`.
Receipts:
`docs/testing/weekly-world-boss-v154-isolated-travel-2026-09-21.md`,
`docs/testing/weekly-world-boss-v154-travel-hardening-2026-09-21.md`.

## Earlier 21 September world-boss session checkpoint (historical)

## 21 September 2026 — weekly world-boss session bridge locally verified

A default-off `WeeklyWorldBossSessionBridge` is now composed in
Base/Dungeon shared RuntimeServices. It freezes the server-issued
weekly event/party into the **existing** DungeonSessionService
InstanceState, stores only a verified guardian defeat and rehydrates
the same window and group from the session adapter after a local
service restart. Reward delivery checks existing session membership,
non-abandonment and server-certified contribution; an invited
non-contributor gets no payout. A saved profile's once-per-week
receipt prevents repeat payout after same-UserId in-memory reload.
Stored windows are revalidated without reopening entry after close.

Four Rojo compositions passed, the original 40 weekly policy
assertions passed in Base/Dungeon, the guardian factory passed eight
assertions, and the new **30-assertion** session contract passed
in Base and Dungeon. Existing professions 14/14 and Dungeon
backend 30/30 also passed at the latest source commit.

This is NOT a normal Base portal or a completed reserved-server
boss route. Session restart used a shared Studio in-memory adapter;
no cross-server live MemoryStore or DataStore claims can be made.
Normal dungeon runtime, normal portal and public event schedule
were not changed or enabled. Source and documentation changes
remain GitHub-only; no publish or main merge.

Receipt: `docs/testing/weekly-world-boss-v154-session-bridge-2026-09-21.md`.

## Earlier 21 September weekly milestone (historical)

## 21 September 2026 — v1.54 weekly world-boss local foundation

The active GitHub branch now includes a default-off weekly world-boss
calendar, server-only instance admission and persistent per-character
reward gate in the existing Base/Dungeon RuntimeServices. Each event
uses an explicit server window, Monday UTC week identity and an
exclusive entry cutoff. The prototype `AncientGuardian` factory
reuses the accepted captain combat rig but has its own
instance-specific tag/identity and no ordinary monster rewards.
The provisional weekly gold is 100 per character; no finished
guardian content or live event time has been scheduled.

Four Rojo compositions, 40 window/reward assertions in each of
Base/Dungeon, eight guardian-factory assertions, 14/14 existing Base
profession suites and 30/30 Dungeon backend suites passed.
A real client entered through a **disposable injected physical
ProximityPrompt** while the explicit event window was open, spawned
a guardian using the registered server factory, and completed two
separate assisted encounters. Only the first kill paid weekly gold
into the actual Dungeon Studio profile. The physical runner printed
`VERIFIED_PLAY_MODE_PASS`; the dedicated factory runner also
passed after correcting its test to check the proper
`DungeonRewardGoldMin/Max` attribute names.

**Do not treat the fixture as an enabled normal-game event.**
The gateway, temporary arena and prompt are not production assets;
there is no Base portal, published weekly event schedule, reserved
server, durable world-boss instance/session snapshot, contribution
eligibility or real DataStore/cloud handoff yet. A weekly reward
receipt persists through the existing profile adapter; the local
instance registry itself does not. No source/docs were edited
locally and no cloud publish/main merge occurred.

Roadmap: `docs/roadmap/DungeonMMO_Roadmap_v1_54_Weekly_World_Boss_Foundation.md`.
Receipt: `docs/testing/weekly-world-boss-v154-local-foundation-2026-09-21.md`.

## Earlier 21 September v1.53 progress (historical)

## 21 September 2026 — craft disconnect protection and local recovery verified

The active GitHub branch includes ticketed per-user craft locks.
Each request checks ticket ownership and original Player instance
after server preparation before committing any inventory mutation.
PlayerRemoving invalidates the departing user's ticket; a stale
completion cannot release a subsequent same-UserId request.

All four Rojo builds passed. Both rebuilt Base/Dungeon focused
profession runners passed **14/14** (guard: 21 assertions; same-UserId
in-memory recovery: 20 assertions each). A genuine two-client Base
Play fixture paused an actual client's craft, disconnected the
client, observed release, loaded the **same UserId from the local
in-memory adapter** and resumed the abandoned handler without
losing ore or granting a duplicate bar. The other real Studio client
remained connected. Studio admitted a distinct replacement test
account, not the original account. The corrected fixture uses a
disposable shared ModuleScript instead of a test-only global.
Base material-backed crafting, the opt-in Dungeon wolf encounter
and broad Dungeon backend matrix (30/30) were rerun and passed
after the guard modification.

Real same-account Roblox network reconnect, cross-server lease/
DataStore recovery and published TEST/PROD remain NOT tested.
No source or documentation changes were made via Remote Desktop;
no publish, real-user DataStore mutation or merge into main.

Receipt: `docs/testing/profession-v153-interrupted-reconnect-local-2026-09-21.md`.

## Earlier 21 September progress (historical)

## 21 September 2026 — opt-in Dungeon wolf and full client crafting locally verified

Latest source/fixture commit after the live tests:
`b3ce809d258ecfddcbc4077a80ff14ea3a67d826`.
A distinct `ForestWolf` server factory and `Wolf` enemy archetype
are registered but not inserted into any default dungeon combat pack.
Its combat-rig animal silhouette is a temporary backend placeholder.
The disposable Temple Room1 fixture opted in two wolves and passed
the real encounter activation, assisted enemy defeat, normal reward/
clear, retained looted corpse and one-hide real-client Skinning path.
Ordinary Marauders and bosses remain unskinnable.

A real Base client crafted the full material-backed profession chain
to `warded_leatherbound_gloves` with station checks and authoritative
inventory changes; a no-material repeat and a two-request burst were
rejected/limited to one output. A real two-client Base Play fixture
passed independent crafts, a one-hide contested shared corpse and
a peer disconnect while the other player stayed connected. The
additional two-user in-memory contest passed in both Base/Dungeon
focused suites (13/13 each after the updated sources were rebuilt).
The Dungeon regression matrix stayed 30/30.

Do NOT infer true same-account reconnect or in-flight request retry,
cross-server DataStore persistence, unassisted wolf combat, dedicated
wolf AI, approved animal models, or a public deployment. These remain
open release gates. All source/docs were edited via GitHub; local
Studio tested disposable unpublished in-memory places only.

Receipt: `docs/testing/profession-v153-wolf-and-crafting-local-acceptance-2026-09-21.md`.

## Earlier 21 September checkpoints (historical)

## 21 September 2026 — animal-only Skinning verified in local Studio

Four Rojo compositions and both 12-suite focused profession runners
passed (363 focused assertions in each). The 42-assertion species
eligibility, 16-assertion corpse runtime and 11-assertion Dungeon
cleanup tests passed; the broad Dungeon backend matrix passed 30/30.
Two real Base Play fixtures passed: an actual client RawHideCache grant
followed by authoritative prompt depletion, and a temporary
server-created, dead/looted wolf corpse granting precisely one hide
through the actual server profession runtime. Base live near/far
Leatherworking/Enchanting routing also passed. The earlier hide-cache
fixture timed out only because its second attempted activation expected
another result after the prompt was already correctly disabled.

These runs used Roblox Studio's CLI RunScript on unpublished local
places when a separate direct MCP client still could not attach to the
active Studio proxy; the test outcomes are from actual Studio, not
in-memory-only simulation. Source, test and documentation edits remain
GitHub-only. Source code, authored animal factories and cloud places
were not published or merged to main. Actual authored animal dungeon
combat/reward/skin, material-backed live crafting, multiplayer races,
disconnect/retry and real-user DataStore validation remain open.

Latest receipt:
`docs/testing/animal-only-corpse-skinning-studio-verified-2026-09-21.md`.

## Historical staging checkpoint — before the above tests

## 21 September 2026 — animal-only Skinning backend implementation; Studio pending

After v1.53's partially passing profession tests, the active branch gained
a default-deny, server-owned animal Skinning policy. Only an explicitly
tagged, allowlisted Beast corpse is eligible, after death and successful
server loot. The shared ProfessionService grants hide exactly once with
a per-corpse claim and server range check. DungeonEnemyCleanup preserves
only such eligible animal corpses briefly; all existing Marauders and
bosses keep the legacy cleanup path. RawHideCache is still a non-monster
temporary material source. No animal enemy factory has been registered.

All changes (including tests and this handoff) were written to GitHub,
then safely fast-forwarded to the clean Windows integration worktree.
All four Rojo compositions built at
`8655c7e19bc97a9b9c803fc011e2e5a3080c47f3`; **new Studio tests
have not run**. The direct Studio MCP discovery attempt could not reach
Studio, and the delegated Codex route hit a usage limit. The earlier
Base RawHideCache simulated-input timeout is still unresolved. Do not
promote Skinning or the whole v1.53 profession increment to accepted.

Details and pending exact test gates:
`docs/testing/animal-only-corpse-skinning-pending-studio-2026-09-21.md`.
No cloud publish, real-player DataStore run or main merge occurred.

## 21 September 2026 — v1.53 tested locally; live profession acceptance pending

GitHub-first staged source at `45a9bc25a185fcdb00579e977a22dc582eefc1ec`
was safely fast-forwarded to the clean Windows integration worktree.
Four Rojo compositions built; the new ten-suite profession runner
passed in both unpublished local Dungeon and Base Studio Edit places
(Base: 305 assertions), Dungeon general backend matrix passed 30/30,
and the generic Base Play smoke passed. Deterministic full five-profession
chain, migration, material protection, station range and pure request
guard are included in the focused suites.

A new disposable real Base client/server fixture was authored **in
GitHub**, fast-forward pulled and run in Studio Play mode. Actual client
craft requests were rejected when far from Leatherworking/Enchanting
stations and routed to crafting service when near (then rejected for
missing materials). The same fixture **failed** at a scripted
RawHideCache ProximityPrompt hold: no Gather result within 15 seconds.
The live hide claim, material-backed full craft chain, duplicate
requests, independent players and disconnect/retry are not accepted.

Source/testing receipt:
`docs/testing/profession-v153-local-validation-2026-09-21.md`.
Roadmap:
`docs/roadmap/DungeonMMO_Roadmap_v1_53_Professions_Pending_Verification.md`.
All source and document changes are made in GitHub, not via Remote
Desktop. No cloud publish, real-player DataStore validation, main merge
or force-push occurred.

## 21 September 2026 — initial GitHub-only v1.53 staging (historical)

While the authorized Windows desktop is offline, source work continued
**in GitHub only** from accepted v1.52. Skinning, Leatherworking and
Enchanting are staged on the existing profession framework. Fresh
profiles initialize all three; migration still sanitizes every profession
through ProfessionDefinitions.order(). The Base profession runtime now
has a server-claimed RawHideCache placeholder plus distinct temporary
Leatherworking and Enchanting station roots derived from existing Base
anchors.

The staged dependency chain reaches warded_leatherbound_gloves through
Skinning hide, Alchemy oil/flux/essence, Blacksmithing bars,
Leatherworking cured leather/base gloves and Enchanting rune/final
equipment. No second inventory, crafting or profile service was created.

ProfessionRuntime's Base craft RemoteEvent still takes only recipe_id.
Station/distance authority remains server-side. A new per-player
craft-request guard rejects overlapping requests and is released after
completion/error/PlayerRemoving; different players are independent.
The client still cannot submit a minigame success payload into this
RemoteEvent; the current foundation success result remains server-created.

New/extended GitHub tests cover all seven definitions, station recipe
ordering, legacy-profile migration, full multi-profession atomic
dependency/save-reload behavior, equipped-input and wrong-minigame
rejection, station distance and request-lock semantics. The focused
profession runner includes these tests.

**Do not report these tests as passing yet.** No Remote Desktop/local
pull/Rojo/Studio run occurred after v1.52 because the desktop is offline.
Latest verified acceptance remains v1.52. Tomorrow follow:
docs/testing/profession-leatherworking-enchanting-pending-verification-2026-09-21.md.
Roadmap:
docs/roadmap/DungeonMMO_Roadmap_v1_53_Professions_Pending_Verification.md.

## 20 September 2026 — v1.52 Event combat variations and first broader profession backend

The existing, server-frozen after-Room2 late Event slot now accepts
one **non-boss** CombatPack instead of its previous boss where a
disposable run explicitly enables the independent
ServerScriptService DungeonMMOOptionalEventCombatEnabled switch.
A deterministic saved Ambush (4 enemies) or Surge (8 enemies)
is supported in both Temple and Mine Depth2–4; the late
placeholder has eight dedicated spawn anchors. A shared
Event/Secret frequency cap, verified placement, timed window,
physical gate, checkpoint, generic executor and per-enemy
idempotent reward service are reused. No additional Event,
wave scheduler or environmental hazard was added. Old early/
late optional bosses stay the defaults with new switches OFF.

Fresh final 144 variation assertions, 25/25 optional-focused
and 30/30 broad backend suites, four Rojo compositions PASS.
Temple Depth2 Ambush (4) and Mine Depth4 Surge (8) assisted
physical walking runs, actual two-/four-client concurrent
pack trigger, mid-Event real Studio client disconnect, recovery
and replay-proof completion PASS. The old optional-enabled
after-Room1 and optional-disabled Temple Depth2 physical
routes also passed.

Broader backend milestone started: a bidirectional material
recipe chain uses existing Mining, Blacksmithing, Herbalism,
Alchemy, inventory, station catalogue, minigame contract and
atomic profile mutation: iron bar → forging flux →
runic ironbound gloves. 46 new atomic crafting/reload
assertions and 7/7 profession suites passed in both local
Dungeon and Base compositions. This is not completion
of Leatherworking, Enchanting or secure live station/minigame
interactions. No cloud publish, actual player DataStore,
authored art or main merge occurred.

Latest ChatGPT-authored roadmap:
docs/roadmap/DungeonMMO_Roadmap_v1_52_Event_Variations_And_Professions.md.
Test report:
docs/testing/phase4-nonboss-event-profession-chain-2026-09-20.md.
Historical canonical v1.47 DOCX is unchanged.

## 20 September 2026 — v1.51 after-Room2 late Event is physically playable in unpublished Studio

GitHub-first implementation registered a distinct EventArenaLate side
room/bridge/gate, depth-specific trigger, checkpoint and boss spawn in
the replaceable Temple and Mine Depth2/3/4 Studio blockouts. The
independent Workspace DungeonMMOPlaceholderLateEventPlayEnabled
and ServerScriptService DungeonMMOOptionalBossTemplatesEnabled
opt-ins remain OFF in ordinary source; higher-depth and original
optional release switches are unchanged. One Event and one Secret
maximum per run. The existing server-owned gate controller opens
the selected late entrance only after required Room2 is Cleared,
leaving the original early Event and Depth1 bridges sealed. A
reconstructed encounter retains the late boss, slot, checkpoint
and stable encounter-scoped reward identity.

Fresh local acceptance: 85 physical/gate assertions across both
dungeons and Depth2–4, 24/24 optional-focused suites, 30/30
broader gameplay backend suites, four local Rojo builds PASS.
Actual assisted Humanoid:MoveTo physical runs traversed the late
side bridge and completed Temple Depth2 (six encounters) and
Mine Depth4 (eight encounters). Independent two-client Temple
Depth2 and four-client Mine Depth4 Studio runs verified one
boss under concurrent approach, real mid-late-Event client
disconnection, surviving party progression, restored Pending
late Event without resetting Rooms1/2, distinct reused-boss
rewards and replay-proof per-member completion. The old
after-Room1 optional-enabled and fully optional-disabled
Temple Depth2 walking routes passed unchanged.

Detailed receipts and previous one-line fixture test correction:
docs/testing/phase4-late-event-physical-multiplayer-2026-09-20.md.
Latest ChatGPT-authored roadmap:
docs/roadmap/DungeonMMO_Roadmap_v1_51_Late_Event_Physical_Acceptance.md.
The unmodified canonical v1.47 DOCX, v1.48–v1.50 supplements,
real player DataStores, PROD/TEST cloud place and authored models
remain preserved. Real same-account network reconnect and
unassisted whole-party combat are unverified.

## 20 September 2026 — configurable optional Event placement v1.50

GitHub-first code added one authoritative optional placement catalogue,
with unchanged default EventAfterRoom1 and SecretBeforeFinal and an
opt-in EventAfterRoom2 template for Temple/Mine Depth2–4. Issuance
saves the selected Event template once per eligible run; the new
ServerScriptService DungeonMMOOptionalBossTemplatesEnabled flag is
OFF by default and independent of the boss-variant, original optional
and high-depth release switches. Late Event has a distinct
EventArenaLate physical slot and stable encounter/reward identity.
The existing policy now enforces no more than one Event and one Secret
per run, rejects slot conflicts, and requires matching explicitly
verified placement metadata for the late slot. That late arena,
bridge and gate do NOT exist in registered physical content yet:
late selection fails closed as OptionalBossContentUnavailable;
do not present it as physically playable. Existing layout/default
variant routes are unchanged.

New template tests passed 274 assertions; 23/23 optional-focused,
30/30 broad backend suites and four local Rojo builds passed. Fresh
original Temple Depth2 six-encounter assisted physical Play mode PASS;
fresh alternate Event/Secret Temple Depth2 six-encounter assisted
physical Play mode and each reward replay PASS. Its initial fixture
retry failed at RunScript:66 because the TEMP seed-override search
expected the old issuance signature; the fixture was updated through
GitHub and the fresh rerun passed. Report:
docs/testing/phase4-optional-event-placement-templates-2026-09-20.md.
Roadmap update:
docs/roadmap/DungeonMMO_Roadmap_v1_50_Optional_Event_Placement.md.
No TEST/PROD publish, DataStore, authored geometry, main merge or
user account work was performed.

## 20 September 2026 — dynamic optional Event/Secret variants ACCEPTED locally

New server-only DungeonMMOOptionalBossVariantsEnabled (default false)
enables a deterministic, run-frozen choice of one of two registered
implemented boss placeholders per optional kind in Temple/Mine.
The existing Event window, Secret probability, session save, plan
insertion, optional gate and dungeon release locks are unchanged.
The Secret discovery service now validates the saved dungeon-scoped
variant identity instead of only legacy boss IDs. BossEncounterExecutor
uses encounter-scoped DungeonEnemyId for EventBoss/SecretBoss/
MiniBoss/FinalBoss, preventing reused factories in a single run from
sharing reward receipts; legacy Depth1 Boss identity is unchanged.

GitHub-first tests: 2,205 dynamic selection/reconstruction assertions,
232 original/alternate Secret discovery assertions, 80 reward
identity/replay assertions, 22/22 optional-focused suites and 30/30
broad backend suites PASS; four local Rojo compositions built.
TEMP assisted Temple Depth2 and Mine Depth4 physical alternate-boss
routes and the variant-disabled Temple Depth2 route PASS.
Four-client Mine Depth4 alternate Event/Secret Play mode PASS:
one Event boss on concurrent approach, one real member disconnects
during Event, three finish the run, each receives independent rewards
for an alternate boss and its returning miniboss appearance, and
per-member final completion replay remains blocked.
Full logs, prior failed tests, fixes and caveats:
docs/testing/phase4-dynamic-optional-boss-variants-2026-09-20.md.
Roadmap: docs/roadmap/
DungeonMMO_Roadmap_v1_49_Phase4_Dynamic_Optional_Variants.md.
No cloud publish, DataStore mutation, meshes or PROD change.

## 20 September 2026 — higher-depth optional multiplayer lifecycle checkpoint

GitHub-first, disposable local Studio Play-mode fixtures passed Temple and
Mine Depth2/4 two- and four-client shared party runs. Two clients entering
Event or Secret spawn one boss. Real Studio PlayerRemoving during Event
or Secret preserves the surviving 1/3 members, frozen plan, checkpoint and
ongoing encounter; the survivors complete their higher-depth route.
The actual per-member completion save/replay check passed for a 2→1
Temple Depth2 Event disconnect and a 4→3 Mine Depth4 Secret disconnect.
The strict test initially exposed proper DifficultyProgressionFailed
protection on newly created higher-depth profiles; the fixture now gives
disposable members prior depth clears through the normal progression
service rather than disabling the completion barrier. Service-level
1/2/4-member optional boss wipe/automatic revive tests passed 392
assertions across both dungeons and Depth2/4; 19/19 optional focused
and 30/30 broader gameplay backend suites plus all four local Rojo builds
passed. Report: docs/testing/
phase4-higher-depth-multiplayer-lifecycle-2026-09-20.md.
True same-account network rejoin/new reserved-server restart, in-Play
whole-party wipe and cloud release remain unverified; higher-depth and
optional release flags remain OFF, with no real player DataStores touched.

## 20 September 2026 — roadmap v1.48 supplement (ChatGPT-authored)

The repository roadmap index now points to
`docs/roadmap/DungeonMMO_Roadmap_v1_48_Phase4_Backend_Update.md`.
It records the accepted six Depth2–4 Temple/Mine assisted walking routes,
one Mine Depth4 deferred Secret backtrack, and the next backend milestone:
1/2/4-member optional encounter lifecycle, concurrent trigger protection,
disconnect/wipe/checkpoint recovery and per-member one-time rewards.
The historical canonical long-form `DungeonMMO_Roadmap_v1_47.docx`
is preserved; the v1.48 update is a separate versioned supplement.
Cloud TEST acceptance, real same-account cross-server rejoin, unassisted
all-room combat, authored art and PROD remain independent future gates.
No Roblox publish or DataStore change was performed by this roadmap update.

## 20 September 2026 — Depth2–4 optional physical playtest complete

TEMP-only higher-depth Temple and Mine blockouts now provide real
walkable, gated Event/Secret side rooms attached to Room1 and the
selected depth's penultimate required room. Higher-depth optional
layout registration is restricted to the explicitly opted-in,
unpublished local Studio placeholder; release switches remain OFF.
The shared entrance-gate controller targets the active depth's bridge
and keeps unused Depth1 bridges sealed. GitHub-first source/test changes
were fast-forward pulled into the existing Windows integration worktree.
Both dungeons × Depth2/3/4 passed six independent assisted walking
Play-mode routes (6/7/8 encounters respectively), including actual side
bridge traversal, boss trigger/spawn identities and final completion.
A seventh Mine Depth4 Play-mode run physically bypassed Secret, returned,
cleared the deferred boss and then completed Final using a TEMP-only
final-spawn deferral. Structural regression: 139 assertions; 18/18
optional-focused suites and 30/30 backend matrix PASS. Original
optional-disabled Temple Depth2 four-room Play mode PASS; all four
local Rojo compositions built. Detailed dated logs and caveats:
docs/testing/phase4-depth2-4-optional-physical-playtest-2026-09-20.md.
No published Roblox cloud place, PROD, player DataStore, meshes or
canonical roadmap DOCX were changed.

## 20 September 2026 — depth-specific optional events and shared side gates

GitHub-first continuation on wip/phase-4-test-hud-integration-v1.
Reproduced and fixed two defects: the Secret entrance had a hard-coded
Room2 prerequisite (wrong for Depth2–4), and Mine placeholder Event/
Secret gates were never synchronized because the controller recognized
only Temple. Gate prerequisites now come from the frozen encounter
binding order; both named synthetic dungeon roots use the same controller.
Synthetic backend tests cover two dungeons × four depths × all four
Event/Secret eligibility combinations and timed-event snapshot recovery.
Fresh Studio: 712 depth/eligibility, 116 expiry/recovery, 32 gate
assertions and 17/17 focused suites PASS. Assisted Temple and Mine
Depth1 optional route fixtures PASS; 30/30 backend suites and four
local Rojo compositions PASS. Evidence:
docs/testing/phase4-optional-depth-events-and-side-gates-2026-09-20.md.
Depth2–4 optional physical side-room layouts are NOT registered or
playtested and their release switches remain unchanged. No cloud publish,
DataStore, authored mesh or PROD changes.

## 20 September 2026 — four-depth progression backend verification

On the existing integration branch, a GitHub-first test-only update
validated both Temple and Mine Depth1–4 ladders with 454 assertions and
five focused Studio suites PASS. Tests cover 3/4/5/6 ordered rooms,
Depth4 returning miniboss identities, persistent sequential unlocks,
checkpoint/miniboss recovery, one-time completion rewards and separate
dungeon progression. Four Rojo builds, the 30/30 backend matrix and
Base Play-mode regression passed. One fresh assisted Temple Depth2
physical-route fixture passed; the other five higher-depth physical
routes retain their documented 19 September individual passes.
Actual high-depth entry remains release-locked: the test uses an
injected readiness provider ONLY for logical unlock simulation.
No production runtime or cloud/DataStore state was changed. See
docs/testing/phase4-depth1-4-progression-integration-2026-09-20.md.

## 20 September 2026 — full optional-session recovery regression

A GitHub-first test-only continuation added comprehensive two-member
persisted-session reconstruction over the existing recovery controller,
session service, optional barrier flow and reward service. A fresh TEMP
Dungeon Rojo build and Studio focused suite passed 15/15 modules;
DungeonOptionalFullSessionRecoveryTest passed 42 assertions. The
assisted physical Temple Secret-backtracking route passed again.
Server reconstruction was emulated with new service/controller instances
and shared in-memory persistence; this is NOT a same-account Roblox network
rejoin or a cloud deployment. No production source or DataStores changed.
See docs/testing/phase4-optional-full-session-recovery-2026-09-20.md.
The user also reported successfully soloing both optional bosses
manually; the earlier failed automated injured-solo fixture remains
a separate historical result.

## 20 September 2026 — consecutive optional combat and real recovery verified

Two real Studio clients defeated Event and then Secret using normal client
attacks and ordinary character HP in a single temporary Temple run.
A second two-client run additionally verified server-accepted Dodge and
an equipped healing skill restoring approximately 32 HP between fights;
Secret and assisted final-room progression completed afterward.
The earlier injured single-survivor solo attempt remains a failure:
this is co-op acceptance, not solo balancing acceptance. New fixture
scripts: phase4_event_secret_consecutive_coop_combat.luau and
phase4_optional_boss_skill_defense_coop_combat.luau. Full parent/child
logs, limitations and receipts:
docs/testing/phase4-optional-boss-consecutive-skill-defense-2026-09-20.md.
No published experience, PROD, DataStore or models were changed.

## 20 September 2026 — normal optional-boss combat evidence

Two separate local two-client Studio fixtures defeated TempleEventBoss
and TempleSecretBoss using real client attack inputs at ordinary character
health; optional boss HP was never directly changed by the test harness.
The combined back-to-back solo-survivor attempt FAILED: after beating
Event with 34/113 HP remaining, the player died against Secret at
56.7/120 HP. A separate two-client Secret fight PASSED with a healthy
party (survivor 70.6/113 HP). The test driver positioned combatants and
assisted prerequisite rooms/final boss. Continue testing legitimate
healing/defense/party play before accepting the consecutive encounter
route. Evidence: docs/testing/
phase4-optional-boss-normal-combat-playtest-2026-09-20.md.
No cloud publish or player DataStore changes occurred.

## 20 September 2026 — real local Studio two-client optional-boss pass

On integration source c571552, two simulated Studio clients were admitted
into the same eligible Temple optional-boss run. A second player entering
Event did not duplicate its boss; one client disconnected mid-fight while
the peer retained the run, checkpoint and Active boss. The peer then
cleared Event, Room2, Secret and the final boss; reward replay was
idempotent. A detached sequencer verified interrupted Event would
reconstruct as Pending without replaying Room1. Two fresh local runs
passed, including 20260920T161203Z_Studio_B6E09_last.log and
child 20260920T161212Z_Studio_F969B_last.log. Details:
docs/testing/phase4-optional-boss-two-client-playtest-2026-09-20.md.
Still not proven: same-account network rejoin/new-server recovery and
normal unassisted combat. No published place or DataStore modified.

## 20 September 2026 — optional-boss lifecycle local hardening

On wip/phase-4-test-hud-integration-v1, a failed persisted normal/Event
encounter start now rolls back to Pending; a failed persisted optional
Secret skip restores the saved pre-skip sequence snapshot. Both defects
were reproduced with RED Studio tests before the fixes. Fresh local
Studio focused tests: 14/14 suites PASS (11 failure-recovery, 24
two-member recovery, 28 optional gate assertions). Five Rojo builds,
assisted physical Temple Secret-backtrack/final-completion Play mode,
normal Dungeon baseline, and a two-client real PlayerRemoving
disconnect fixture all PASS. Evidence:
docs/testing/phase4-optional-boss-lifecycle-hardening-2026-09-20.md.
The two-client fixture did not run optional combat or same-user rejoin.
Phase 4 remains ACTIVE; no cloud publish, DataStore update or art work.

## 20 September 2026 — TEST Temple optional gate recovery verification

Active integration branch: wip/phase-4-test-hud-integration-v1. Optional
entrance gate runtime/placeholder implementation is already committed at
f6d6401; roadmap v1.47 is committed at 1083c01. Fresh TEMP TEST Temple
and Dungeon test-composition Rojo builds succeeded. Focused Studio tests:
13/13 suites PASS; entrance gate tests: 16 assertions PASS after adding
three persisted-state recovery/resynchronization checks. Studio log:
20260920T151636Z_Studio_1BE9F_last.log. Fresh TEMP Temple physical
backtracking also passed in 20260920T151909Z_Studio_C434B_last.log:
both gates started closed, Room1 opened Event, Room2 opened Secret,
backtracked Secret cleared and final Room3 completed (assisted fixture).
The TEST cloud gate version is UNVERIFIED after an HTTP 429 script commit
attempt; no new cloud publish or DataStore mutation occurred. Before a new
publish, confirm and back up existing TEST Dungeon 117293035754309 and
verify fresh cloud gameplay. Next backend work remains Phase 4 Content Alpha.

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

**State date:** 18 September 2026
**Canonical long-form roadmap:** docs/roadmap/DungeonMMO_Roadmap_v1_44.docx
**Current phase:** Phase 4 - Content Alpha
**Phase 2 - Vertical Slice:** FORMALLY COMPLETE / ACCEPTED
**Phase 3 - Systems Alpha:** FORMALLY COMPLETE / ACCEPTED
**Phase 3 gameplay release checkpoint:** 84662948127eb1a37c9f184c6abbafe6f2daddb6

## Canonical release boundary

Phase 3 is closed. The accepted gameplay release checkpoint was pushed to the
Phase 3 feature branch and to main, then independently verified so local main,
origin/main and the GitHub server main ref all resolved to 84662948127eb1a37c9f184c6abbafe6f2daddb6 before
the documentation closeout.

Published TEST places:

- Starting Base: 134132328219009
- Dungeon: 117293035754309
- Universe: 10765241947

The Dungeon was published first and the Starting Base second. Roblox Studio's
publish state machine reached PublishSuccessful for both places. No PROD place,
Robux purchase flow or production DataStore action was used.

## Accepted Phase 3 systems

The accepted Systems Alpha boundary now includes:

- reusable Quest/objective state and first race-specific Secondary-Class
  Advancement architecture;
- persistent, server-authoritative contribution channels for Damage, Tank and
  Support;
- schema-backed Blueprint / Recipe Knowledge and authoritative teaching-item
  consumption;
- persistent Bestiary and Scholars Reputation foundations;
- Rogue as the deliberately selected fourth prototype starting archetype;
- Human Duelist and Elf Windstalker as prototype race-specific Rogue
  advancement targets;
- broader Rogue skill-tree/progression architecture while retaining the
  accepted limited active loadout;
- deterministic Dungeon modifiers: Fortified, Rich Deposits and Bounty;
- Rich Deposits interaction with reconnect-safe personal profession gathering;
- Guild creation, membership, Leader/Officer/Member roles, Guild XP, Guild
  Gold, leader-only level upgrades and a private functional Guild Hall;
- a limited fixed-price player-market proof with escrow, tax, tradability
  checks, buy/cancel/expiry recovery and replay-safe transactions;
- DEV/TEST Race Change preview/apply with per-race advancement history,
  incompatible skill/proficiency archive, SP release and restore-on-return;
- shared economy audit events and request-rate/replay/ownership validation;
- the reusable persisted entity-adapter boundary used by shared MMO entities.

The current profile schema is v13. Schema v13 adds independent persistent
Dungeon difficulty progression while preserving legacy `DungeonProgress`.

## Final runtime and stress evidence

The final consolidated Studio regression round on 18 September 2026 included,
among other accepted families:

- Rogue Definitions: 43 assertions PASS;
- Rogue Progression: 17 assertions PASS;
- Rogue Advancement: 12 assertions PASS;
- Class Advancement: 29 assertions PASS;
- Contribution Service: 36 assertions PASS;
- Contribution Damage Bridge: 9 assertions PASS;
- Contribution Support Bridge: 13 assertions PASS;
- Contribution real-session persistence: 10 assertions PASS;
- Bestiary Service: 33 assertions PASS;
- Bestiary/Reputation reward integration: 25 assertions PASS;
- Guild membership authority: 21 assertions PASS;
- Guild Service / Guild Hall / Dungeon progression: PASS;
- Market listing, purchase recovery, cancel/expiry and remote contracts: PASS;
- Race Change planner, migration, service and remote-contract tests: PASS;
- Economy Audit Integration: 27 assertions PASS;
- Entity Adapter Contract: PASS;
- Dungeon Modifier Definitions: 6 assertions PASS;
- Profession Resource Distribution: PASS;
- existing Phase 1/2 combat, progression, equipment, Bank, Travel, Dungeon,
  reward, revive and session regressions remained green in the same run.

The Phase 3 stress harness passed:

- 250 profile cycles;
- 1,000 market operations;
- 1,000 duplicate/replay attempts;
- 250 guild operations;
- 100 session cycles;
- 100 race-change round trips.

No duplicate/lost value or invalid final profile state was accepted by the
stress gate.

Detailed closeout evidence is recorded in
docs/testing/phase3-systems-alpha-acceptance-record.md.

## Explicit Phase 3 deferrals

Two roadmap concepts were intentionally not implemented:

- **Progression catch-up** - defer until real player population/progression data
  demonstrates a need.
- **Transmog** - defer until the equipment/content catalogue is mature enough to
  justify wardrobe engineering.

These are future work, not missing Phase 3 exit criteria.

## Phase 4 backend gates

Phase 4 - Content Alpha remains active.

The user has explicitly parked Starting Base presentation, modelling, meshes and
environment-art work for now.

The **Progressive Dungeon Depth + Difficulty backend foundation** remains local
green at `1230e6c`. It provides schema v13 depth progression, authoritative
difficulty routing, 3/4/5/6 logical-depth definitions, scaling and fail-closed
Depth2-Depth4 content.

The follow-on **Generic Dungeon Encounter Runtime** gate is now
**LOCAL GREEN / AWAITING PROJECT-OWNER CLOSEOUT**.

Implementation checkpoint:

`5ba9f4d`

Accepted local engineering result:

- live Depth1 Room1 -> Room2 -> Boss progression authority is now the generic
  encounter sequencer rather than hard-coded clear booleans;
- arbitrary ordered encounter counts are supported by the generic controller;
- encounter kinds include Combat, MiniBoss, Boss, FinalBoss, EventBoss and
  SecretBoss;
- optional encounters support deterministic before/after insertion;
- Event/Secret activation is evaluated only from server-owned InstanceState;
- materialized encounter plans are persisted so reconnect cannot reroll an
  Event/Secret encounter that already exists in the run;
- required inserted encounters cannot be bypassed by later room triggers;
- stable encounter-derived checkpoints coexist with legacy Room1/Room2/Boss
  checkpoint aliases;
- existing EncounterService IDs, enemy/reward implementations, doors and
  Captain/Foreman implementations remain compatible;
- current Depth1 physical bindings fail closed if an activated optional
  encounter lacks an explicit authored room/spawn/checkpoint binding;
- no Event/Secret boss content is enabled yet;
- Depth2-Depth4 remained fail closed at this checkpoint;
- no modelling, meshes, terrain, authored rooms or environment-art work was
  performed.

The follow-on **Encounter Execution / Spawn Registry** gate is now
**LOCAL GREEN / AWAITING PROJECT-OWNER CLOSEOUT** at:

`fe1856e`

Accepted local engineering result:

- encounter descriptors select stable execution/content IDs;
- CombatPack execution resolves through a server-owned spawn catalogue;
- Boss-family execution resolves through stable BossId -> factory registration;
- MarauderCaptain and CorruptedForeman are the currently registered boss
  contents;
- DungeonRuntime no longer chooses concrete Marauder/Captain/Foreman factories;
- encounter startup is transactional across validation, generic sequence start,
  spawn and EncounterService registration;
- failed execution rolls Active back to Pending;
- downstream start rejection cleans spawned content and rolls back;
- partial combat-pack and boss-factory failures clean up safely;
- boss duplicate protection is scoped by session + stable encounter ID, allowing
  multiple miniboss/boss/event/secret encounters in one run;
- missing future packs/boss IDs/factories/bindings fail closed;
- no Event/Secret boss content is enabled yet;
- Depth2-Depth4 remained fail closed at this checkpoint;
- no modelling, meshes, terrain or authored-room work was performed.

Final local evidence includes:

- **494** Lua/Luau files parsed with 0 failures;
- clean `git diff --check`;
- all four Rojo compositions building;
- real Temple registry-driven acceptance PASS with **15 assertions**;
- forced Abandoned Mine event+rare registry acceptance PASS with
  **16 assertions**;
- final repeat committed Dungeon regression green with no project errors;
- final committed Base regression green with no project errors;
- Phase 3 stress harness still passing in both final compositions;
- source-boundary audit: **26 changed code/test files, 0
  art/model/mesh/terrain/image files**.

Prior encounter-execution gate worktree:
C:\Users\Remko\Documents\Roblox\DungeonMMO_Phase4_EncounterExecution_v1

Prior encounter-execution branch:
wip/phase-4-encounter-execution-registry-v1

Design/spec:
docs/superpowers/specs/2026-09-18-phase-4-encounter-execution-registry-design.md

Acceptance evidence:
docs/testing/phase4-encounter-execution-registry-acceptance-record.md

No push, merge or Roblox publish has been performed for this gate.

The follow-on **Multi-Depth Physical Room-Binding Runtime** gate is now
**LOCAL GREEN / AWAITING PROJECT-OWNER RELEASE CLOSEOUT** at:

`1aa81b5`

Accepted local engineering result:

- physical room metadata is data-driven through generic layout definitions;
- logical encounters bind to generic room slots, triggers, spawn anchors, exit
  barriers and stable checkpoints;
- live DungeonRuntime progression no longer branches on fixed
  Room1/Room2/Boss clear cases;
- boss placement is binding-specific rather than hard-coded to one depth;
- checkpoint recovery remains compatible with legacy Depth1 aliases;
- Temple compatibility passed 23/23 assertions through the real generic path;
- forced Abandoned Mine + DeepEchoes + CrystalBloom compatibility passed 23/23;
- both production dungeons explicitly reject unimplemented Depth2, Depth3 and
  Depth4 physical layouts;
- Depth2-Depth4 therefore remained fail closed at this checkpoint;
- future EventBoss/SecretBoss insertion remains supported by the generic
  binding contract but no such content is enabled;
- no modelling, meshes, terrain or authored-room work was performed.

Final committed acceptance from `1aa81b5` includes:

- **501** Lua/Luau files parsed with 0 failures;
- clean `git diff --check`;
- all four Rojo compositions building;
- Dungeon Encounter Bindings: **30 assertions PASS**;
- Dungeon Encounter Flow: **24 assertions PASS**;
- Dungeon Encounter Recovery: **10 assertions PASS**;
- final committed Dungeon regression green, including Phase 3 stress,
  Training Dummy, Combat Target Rules and successful player admission;
- final committed Base regression green, including party/difficulty families
  and Phase 3 stress;
- source-boundary audit from `2deb540`: **12 changed code/test files, 0
  art/model/mesh/terrain/image files**.

Prior multi-depth room-runtime worktree:
C:\Users\Remko\Documents\Roblox\DungeonMMO_Phase4_MultiDepthRoomRuntime_v1

Prior multi-depth room-runtime branch:
wip/phase-4-multidepth-room-runtime-v1

Acceptance evidence:
docs/testing/phase4-multi-depth-room-runtime-acceptance-record.md

No push, merge or Roblox publish has been performed for this gate.

The follow-on **Dungeon Runtime Content Readiness Registry** gate is now
**LOCAL GREEN / AWAITING PROJECT-OWNER RELEASE CLOSEOUT** at:

`2e2420b`

Accepted local engineering result:

- a shared runtime-content catalogue is now the single static source for
  physical layouts, combat packs, boss content, executor IDs and boss-factory
  IDs used by Base/Dungeon readiness decisions;
- the old `RuntimeReady` difficulty property has been removed;
- `RuntimeReleaseEnabled` now means only the explicit rollout switch;
- `DungeonRuntimeContentReadiness` computes `ContentComplete`,
  `ReleaseEnabled`, `Ready` and machine-readable missing-content issues;
- Base-side progression entry and TeleportCoordinator use computed readiness
  rather than reading a release switch directly;
- not-ready content is rejected before reserved-server creation;
- Dungeon execution bootstrap cross-checks shared implemented declarations
  against actual server-side executor/factory registrations;
- both current Depth1 dungeons report content complete + release enabled +
  ready;
- Depth2-Depth4 in both current dungeons report content incomplete + release
  disabled + not ready, including missing layout/content diagnostics;
- no Event/Secret boss content is enabled;
- no modelling, meshes, terrain or authored-room work was performed.

Final committed acceptance from `2e2420b` includes:

- **504** Lua/Luau files parsed with 0 failures;
- clean `git diff --check`;
- all four Rojo compositions building;
- Runtime Content Readiness: **64 assertions PASS**;
- Difficulty Definitions: **114 assertions PASS**;
- Difficulty Progression: **19 assertions PASS**;
- Teleport Coordinator: **19 assertions PASS**;
- final committed Base party/difficulty regressions green;
- final committed Dungeon binding/execution regressions green;
- Phase 3 Systems Stress green in both compositions;
- Training Dummy and Combat Target Rules green in Dungeon;
- live Dungeon Studio player admission succeeded;
- source-boundary audit: **13 source/test files, 0
  art/model/mesh/terrain/image files**.

Prior runtime-readiness worktree:
C:\Users\Remko\Documents\Roblox\DungeonMMO_Phase4_RuntimeReadiness_v1

Prior runtime-readiness branch:
wip/phase-4-runtime-content-readiness-v1

Design/spec:
docs/superpowers/specs/2026-09-18-phase-4-runtime-content-readiness-design.md

Acceptance evidence:
docs/testing/phase4-runtime-content-readiness-acceptance-record.md

No push, merge or Roblox publish has been performed for this gate.

The follow-on **Generic Enemy Archetype + Heterogeneous Combat Pack Registry**
gate is now **LOCAL GREEN / AWAITING PROJECT-OWNER RELEASE CLOSEOUT** at:

`464bd44`

Accepted local engineering result:

- `CombatPack` no longer means "spawn Marauders";
- shared combat-pack content now uses ordered typed entries;
- each entry references a stable enemy archetype;
- each enemy archetype references a stable server factory ID;
- `DungeonEnemyFactoryRegistry` owns server-only factory registration;
- `CombatPackEncounterExecutor` executes mixed-archetype packs generically;
- the old `MarauderPackEncounterExecutor` was removed;
- Deep Echoes and Crystal Bloom bonuses target explicit pack EntryIds;
- existing Temple/Mine Depth1 Marauder counts, names and spawn-index ranges are
  preserved;
- a synthetic 2-Marauder + 1-Elite pack proves heterogeneous execution without
  enabling Elite as production content;
- partial mixed-pack failures clean all previously spawned enemies;
- runtime readiness now validates pack entries, enemy archetypes, enemy
  factories and bonus-rule targets;
- no new production enemy archetype was enabled;
- Depth2-Depth4 remain release-disabled/content-incomplete;
- no modelling, meshes, terrain or authored-room work was performed.

Final committed acceptance from `464bd44` includes:

- **507** Lua/Luau files parsed with 0 failures;
- clean `git diff --check`;
- all four Rojo compositions building;
- Enemy Factory Registry: **8 assertions PASS**;
- Combat Pack Encounter Executor: **15 assertions PASS**;
- Encounter Spawn Catalog: **15 assertions PASS**;
- existing Encounter Executors: **21 assertions PASS**;
- Encounter Execution Bootstrap: **4 assertions PASS**;
- Runtime Content Readiness: **64 assertions PASS**;
- final committed Base party/difficulty regressions green;
- final committed Dungeon binding/execution regressions green;
- Phase 3 Systems Stress green in both compositions;
- Training Dummy and Combat Target Rules green in the clean Dungeon rerun;
- live Dungeon Studio player admission succeeded;
- source-boundary audit: **11 source/test files, 0
  art/model/mesh/terrain/image files**.

Prior enemy-pack-registry worktree:
C:\Users\Remko\Documents\Roblox\DungeonMMO_Phase4_EnemyPackRegistry_v1

Prior enemy-pack-registry branch:
wip/phase-4-enemy-archetype-combat-pack-v1

Design/spec:
docs/superpowers/specs/2026-09-18-phase-4-enemy-archetype-combat-pack-design.md

Acceptance evidence:
docs/testing/phase4-enemy-archetype-combat-pack-acceptance-record.md

No push, merge or Roblox publish has been performed for this gate.

The follow-on **Authoritative Runtime Layout Selection + Environment
Activation** gate is now **LOCAL GREEN / AWAITING PROJECT-OWNER RELEASE
CLOSEOUT** at:

`ccd289b`

Accepted local engineering result:

- runtime selection now resolves DungeonId + DifficultyId + LayoutId;
- production preserves DifficultyId from TeleportData;
- Studio supports an optional explicit difficulty override;
- unregistered selected layouts fail closed;
- physical slots now declare explicit exit-barrier anchors;
- environment trigger/barrier activation is generic over arbitrary layout slots;
- DungeonEnvironmentBootstrap no longer contains Temple/Mine trigger/barrier
  arrays;
- readiness rejects logical exit-barrier bindings without physical anchors;
- synthetic four-slot activation passed;
- current Temple Depth1 boot/admission behavior remains compatible;
- Depth2-Depth4 remain release-disabled/content-incomplete;
- no modelling, meshes, terrain or authored-room work was performed.

Final committed acceptance from `ccd289b` includes:

- **510** Lua/Luau files parsed with 0 failures;
- all four Rojo compositions building;
- Runtime Selection: **7 assertions PASS**;
- Environment Layout Activation: **12 assertions PASS**;
- Encounter Bindings: **30 assertions PASS**;
- Runtime Content Readiness: **64 assertions PASS**;
- final committed Base and Dungeon regressions green;
- Phase 3 Systems Stress green;
- Training Dummy and Combat Target Rules green;
- live Dungeon Studio player admission succeeded;
- source-boundary audit: **7 source/test files, 0 art/model/mesh/terrain/image
  files**.

Prior runtime-layout-selection worktree:
C:\Users\Remko\Documents\Roblox\DungeonMMO_Phase4_RuntimeLayoutSelection_v1

Prior runtime-layout-selection branch:
wip/phase-4-runtime-layout-selection-v1

Acceptance evidence:
docs/testing/phase4-runtime-layout-selection-acceptance-record.md

No push, merge or Roblox publish has been performed for this gate.

The follow-on **Binding-Owned Spawn Groups + Exit Barriers** gate is now
**LOCAL GREEN / AWAITING PROJECT-OWNER RELEASE CLOSEOUT** at:

`cfbf2ea`

Accepted local engineering result:

- combat-capable physical slots now declare EnemySpawnGroup;
- encounter bindings expose EnemySpawnGroup and ExitBarrierAnchor;
- CombatPackEncounterExecutor uses binding-owned environment groups instead of
  room-ID spawn translation;
- DungeonRuntime uses binding-owned physical barrier anchors for encounter clear
  and recovery;
- readiness rejects combat bindings without spawn groups;
- the generic runtime no longer depends on Temple/Mine GROUP_BY_ROOM or
  BARRIER_BY_ROOM maps;
- existing adapter compatibility helpers remain available for older callers;
- current Depth1 behavior remains compatible;
- Depth2-Depth4 remain release-disabled/content-incomplete;
- no modelling, meshes, terrain or authored-room work was performed.

Final committed acceptance from `cfbf2ea` includes:

- **512** Lua/Luau files parsed with 0 failures;
- all four Rojo compositions building;
- Dungeon Encounter Bindings: **34 assertions PASS**;
- Dungeon Encounter Environment Runtime: **8 assertions PASS**;
- Combat Pack Encounter Executor: **15 assertions PASS**;
- Encounter Executors: **21 assertions PASS**;
- Encounter Execution Bootstrap: **4 assertions PASS**;
- Runtime Content Readiness: **64 assertions PASS**;
- final committed Base and Dungeon regressions green;
- Phase 3 Systems Stress green;
- Training Dummy and Combat Target Rules green;
- live Dungeon Studio player admission succeeded;
- source-boundary audit: **11 source/test files, 0
  art/model/mesh/terrain/image files**.

Prior environment-binding-runtime worktree:
C:\Users\Remko\Documents\Roblox\DungeonMMO_Phase4_EnvironmentBindingRuntime_v1

Prior environment-binding-runtime branch:
wip/phase-4-environment-binding-runtime-v1

Acceptance evidence:
docs/testing/phase4-environment-binding-runtime-acceptance-record.md

No push, merge or Roblox publish has been performed for this gate.

The follow-on **Selected-Layout Environment Contract** gate is now
**LOCAL GREEN / AWAITING PROJECT-OWNER RELEASE CLOSEOUT** at:

`405dde5`

Accepted local engineering result:

- production environment resolution now derives room exact anchors from the
  selected physical layout;
- combat slots own spawn-group name, prefix and minimum anchor count;
- runtime base contracts contain only environment-wide completion/return
  anchors;
- DungeonEnvironmentBootstrap resolves the selected-layout contract;
- DungeonEnvironmentRouter rebuilds the same selected-layout contract before
  constructing the gameplay adapter;
- legacy full Temple/Mine contracts remain available for compatibility callers;
- a synthetic Room4 contract is visible to the real EnvironmentAnchorResolver;
- insufficient Room4 spawn anchors fail closed;
- current Depth1 boot/admission behavior remains compatible;
- Depth2-Depth4 remain release-disabled/content-incomplete;
- no modelling, meshes, terrain or authored-room work was performed.

Final committed acceptance from `405dde5` includes:

- **514** Lua/Luau files parsed with 0 failures;
- all four Rojo compositions building;
- Layout Environment Contract: **14 assertions PASS**;
- Encounter Bindings: **34 assertions PASS**;
- Combat Pack Encounter Executor: **15 assertions PASS**;
- Phase2A Failure Path: **24 assertions PASS**;
- Teleport Coordinator: **19 assertions PASS**;
- Dungeon Difficulty Teleport: **7 assertions PASS**;
- Dungeon Difficulty Progression: **19 assertions PASS**;
- Runtime Content Readiness: **64 assertions PASS**;
- final committed Base regression green;
- clean-repeat committed Dungeon regression green;
- Combat Target Rules clean repeat: **9 assertions PASS**;
- Phase 3 Systems Stress green;
- live Dungeon Studio player admission succeeded;
- source-boundary audit: **9 source/test files, 0
  art/model/mesh/terrain/image files**.

Prior layout-environment-contract worktree:
C:\Users\Remko\Documents\Roblox\DungeonMMO_Phase4_LayoutEnvironmentContract_v1

Prior layout-environment-contract branch:
wip/phase-4-layout-environment-contract-v1

Acceptance evidence:
docs/testing/phase4-layout-environment-contract-acceptance-record.md

No push, merge or Roblox publish has been performed for this gate.

The follow-on **Studio Difficulty / Session Parity** gate is now
**LOCAL GREEN / AWAITING PROJECT-OWNER RELEASE CLOSEOUT** at:

`d9297f8`

Accepted local engineering result:

- StudioSessionFactory accepts the selected DifficultyId;
- Studio dungeon session creation receives that DifficultyId;
- DungeonInstanceDirector materializes InstanceState for that DifficultyId;
- Studio routing data preserves DifficultyId;
- reused Studio sessions prefer authoritative session difficulty;
- DungeonRuntime passes the difficulty already resolved by environment
  bootstrap;
- omitted Studio difficulty still defaults through normal definitions to
  Depth1;
- production TeleportCoordinator routing was not changed;
- Depth2-Depth4 remain release-disabled/content-incomplete;
- no modelling, meshes, terrain or authored-room work was performed.

Final committed acceptance from `d9297f8` includes:

- **514** Lua/Luau files parsed with 0 failures;
- all four Rojo compositions building;
- Studio Session Factory: **7 assertions PASS**;
- Layout Environment Contract: **14 assertions PASS**;
- Encounter Bindings: **34 assertions PASS**;
- Combat Pack Encounter Executor: **15 assertions PASS**;
- Phase2A Failure Path: **24 assertions PASS**;
- Teleport Coordinator: **19 assertions PASS**;
- Dungeon Difficulty Teleport: **7 assertions PASS**;
- Dungeon Difficulty Progression: **19 assertions PASS**;
- Runtime Content Readiness: **64 assertions PASS**;
- final committed Base regression green;
- clean-repeat committed Dungeon regression green;
- Training Dummy clean repeat: **9 assertions PASS**;
- Combat Target Rules clean repeat: **9 assertions PASS**;
- Phase 3 Systems Stress green;
- live Dungeon Studio player admission succeeded;
- source-boundary audit: **3 source/test files, 0
  art/model/mesh/terrain/image files**.

Prior Studio-difficulty-parity worktree:
C:\Users\Remko\Documents\Roblox\DungeonMMO_Phase4_StudioDifficultyParity_v1

Prior Studio-difficulty-parity branch:
wip/phase-4-studio-difficulty-parity-v1

Acceptance evidence:
docs/testing/phase4-studio-difficulty-parity-acceptance-record.md

No push, merge or Roblox publish has been performed for this gate.

The follow-on **Depth2 Backend Combat + Boss Content** gate is now
**LOCAL GREEN / AWAITING PROJECT-OWNER RELEASE CLOSEOUT** at:

`b525235`

Accepted local engineering result:

- TestDungeon Depth2Room1/2/3 packs are registered at 3/4/5 Marauders;
- AbandonedMine Depth2Room1/2/3 packs are registered at 3/4/5 Marauders;
- Mine Depth2 Room1 retains Deep Echoes +1 behavior;
- Mine Depth2 Room2 retains Crystal Bloom +1 behavior;
- TempleDepth2Boss is registered with the Temple Warden identity;
- AbandonedMineDepth2Boss is registered with the Deep Overseer identity;
- both Depth2 bosses reuse accepted Captain/Foreman server combat behavior;
- both factories are registered in execution bootstrap;
- Depth2 readiness now has exactly one issue per dungeon:
  DungeonLayoutNotRegistered;
- Depth2 no longer reports EncounterContentNotRegistered;
- Depth2 remains release-disabled and physically unregistered;
- Depth3-Depth4 remain content-incomplete and release-disabled;
- no modelling, meshes, terrain or authored-room work was performed.

Final committed acceptance from `b525235` includes:

- **518** Lua/Luau files parsed with 0 failures;
- all four Rojo compositions building;
- Depth2 Content: **32 assertions PASS**;
- Depth2 Boss Factory: **8 assertions PASS**;
- Encounter Spawn Catalog: **17 assertions PASS**;
- Encounter Execution Bootstrap: **4 assertions PASS**;
- Runtime Content Readiness: **66 assertions PASS**;
- Studio Session Factory: **7 assertions PASS**;
- Layout Environment Contract: **14 assertions PASS**;
- Encounter Bindings: **34 assertions PASS**;
- Combat Pack Encounter Executor: **15 assertions PASS**;
- final committed Base regression green;
- final committed Dungeon regression green;
- Phase 3 Systems Stress green;
- Training Dummy and Combat Target Rules green;
- live Dungeon Studio player admission succeeded;
- source-boundary audit: **8 source/test files, 0
  art/model/mesh/terrain/image files**.

Prior Depth2-content worktree:
C:\Users\Remko\Documents\Roblox\DungeonMMO_Phase4_Depth2Content_v1

Prior Depth2-content branch:
wip/phase-4-depth2-content-v1

Acceptance evidence:
docs/testing/phase4-depth2-content-acceptance-record.md

No push, merge or Roblox publish has been performed for this gate.

The follow-on **Depth3 Backend Combat + Boss Content** gate is now
**LOCAL GREEN / AWAITING PROJECT-OWNER RELEASE CLOSEOUT** at:

`092bd99`

Accepted local engineering result:

- TestDungeon Depth3Room1/2/3/4 packs are registered at 4/5/6/7 Marauders;
- AbandonedMine Depth3Room1/2/3/4 packs are registered at 4/5/6/7 Marauders;
- Mine Depth3 Room1 retains Deep Echoes +1 behavior;
- Mine Depth3 Room2 retains Crystal Bloom +1 behavior;
- TempleDepth3Boss is registered with the Relic Guardian identity;
- AbandonedMineDepth3Boss is registered with the Hollow Taskmaster identity;
- both Depth3 bosses reuse accepted Captain/Foreman server combat behavior;
- both factories are registered in execution bootstrap;
- Depth2 and Depth3 readiness each have exactly one issue per dungeon:
  DungeonLayoutNotRegistered;
- Depth3 no longer reports EncounterContentNotRegistered;
- Depth2 and Depth3 remain release-disabled and physically unregistered;
- Depth4 remains content-incomplete and release-disabled;
- no modelling, meshes, terrain or authored-room work was performed.

Final committed acceptance from `092bd99` includes:

- **522** Lua/Luau files parsed with 0 failures;
- all four Rojo compositions building;
- Depth3 Content: **36 assertions PASS**;
- Depth3 Boss Factory: **8 assertions PASS**;
- Depth2 Content: **32 assertions PASS**;
- Depth2 Boss Factory: **8 assertions PASS**;
- Encounter Spawn Catalog: **19 assertions PASS**;
- Encounter Execution Bootstrap: **4 assertions PASS**;
- Runtime Content Readiness: **68 assertions PASS**;
- Studio Session Factory: **7 assertions PASS**;
- Layout Environment Contract: **14 assertions PASS**;
- Encounter Bindings: **34 assertions PASS**;
- Combat Pack Encounter Executor: **15 assertions PASS**;
- final committed Base regression green;
- final committed Dungeon regression green;
- Training Dummy and Combat Target Rules: **9 assertions PASS** each;
- Phase 3 Systems Stress green;
- live Dungeon Studio player admission succeeded;
- source-boundary audit: **8 source/test files, 0
  art/model/mesh/terrain/image files**.

Prior Depth3-content worktree:
C:\Users\Remko\Documents\Roblox\DungeonMMO_Phase4_Depth3Content_v1

Prior Depth3-content branch:
wip/phase-4-depth3-content-v1

Acceptance evidence:
docs/testing/phase4-depth3-content-acceptance-record.md

No push, merge or Roblox publish has been performed for this gate.

The follow-on **Depth4 Final-Difficulty Backend Content** gate is now
**LOCAL GREEN / AWAITING PROJECT-OWNER RELEASE CLOSEOUT** at:

`8bcb58b`

Accepted local engineering result:

- TestDungeon Depth4Room1/Room3 packs are registered at 5/7 Marauders;
- AbandonedMine Depth4Room1/Room3 packs are registered at 5/7 Marauders;
- Mine Depth4 Room1 retains Deep Echoes +1 behavior;
- Mine Depth4 Room3 retains Crystal Bloom +1 behavior;
- Depth4 keeps six logical encounters;
- Room2 reuses the Depth1 boss as MiniBoss;
- Room4 reuses the Depth2 boss as MiniBoss;
- Room5 reuses the Depth3 boss as MiniBoss;
- TempleDepth4Boss is registered with the Sanctum Ascendant identity;
- AbandonedMineDepth4Boss is registered with the Buried Tyrant identity;
- both final bosses preserve BossRole = FinalBoss;
- both final-boss factories reuse accepted Captain/Foreman combat behavior;
- Depth2, Depth3 and Depth4 readiness each have exactly one issue per dungeon:
  DungeonLayoutNotRegistered;
- all Depth1-Depth4 encounter content is registered;
- Depth2-Depth4 remain release-disabled and physically unregistered;
- no modelling, meshes, terrain or authored-room work was performed.

Final committed acceptance from `8bcb58b` includes:

- **526** Lua/Luau files parsed with 0 failures;
- all four Rojo compositions building;
- Depth4 Content: **38 assertions PASS**;
- Depth4 Boss Factory: **10 assertions PASS**;
- Depth3 Content: **36 assertions PASS**;
- Depth3 Boss Factory: **8 assertions PASS**;
- Depth2 Content: **32 assertions PASS**;
- Depth2 Boss Factory: **8 assertions PASS**;
- Encounter Spawn Catalog: **20 assertions PASS**;
- Encounter Executors: **21 assertions PASS**;
- Encounter Execution Bootstrap: **4 assertions PASS**;
- Runtime Content Readiness: **70 assertions PASS**;
- Layout Environment Contract: **14 assertions PASS**;
- Encounter Bindings: **34 assertions PASS**;
- Combat Pack Encounter Executor: **15 assertions PASS**;
- final committed Base regression green;
- final committed Dungeon regression green;
- Training Dummy and Combat Target Rules: **9 assertions PASS** each;
- Phase 3 Systems Stress green;
- live Dungeon Studio player admission succeeded;
- source-boundary audit: **10 source/test files, 0
  art/model/mesh/terrain/image files**.

Active worktree:
C:\Users\Remko\Documents\Roblox\DungeonMMO_Phase4_Depth4Content_v1

Active branch:
wip/phase-4-depth4-content-v1

Acceptance evidence:
docs/testing/phase4-depth4-content-acceptance-record.md

No push, merge or Roblox publish has been performed for this gate.

## Repository safety

Primary gameplay repo:

C:\Users\Remko\Documents\Roblox\DungeonMMO

Phase 3 completion worktree/branch remains preserved for history:

- worktree:
  C:\Users\Remko\Documents\Roblox\DungeonMMO_Phase3_Completion_v1
- branch: wip/phase-3-systems-alpha-completion-v1

Do not reset hard, clean, force-push, rewrite history or merge the art worktree
into gameplay. Validation builds belong in TEMP locations.

## Event/Secret Boss backend candidate (19 September 2026)

A separate backend candidate exists in DungeonMMO_Phase4_EventSecretPolicy_v1, based on ff2baa0. The four distinct optional-boss identities and their server-only event-window/secret-unlock triggers are implemented. Secret-boss direct-successor skip is persisted through the existing generic encounter controller. Dungeon Studio: policy 49, flow 9, factories 24 and release locks 14 assertions PASS; 537 Lua/Luau files parse; four Rojo builds PASS. The Base gameplay regressions also passed. Both current dungeons remain rollout-disabled, with no optional arenas; Depth2-4 physical layouts remain unregistered. This is CODE-ONLY BACKEND VERIFIED and NOT RELEASED. Authored arenas, authoritative boss-event schedule/secret-unlock issuers and physical gameplay acceptance are future gates. No push, merge, publish or UI changes. Evidence: docs/testing/phase4-optional-boss-policy-progress.md.

Backend closeout (19 September 2026): server-issued optional-boss
run-state regression passed 28 offline Luau assertions; four
Rojo builds and diff check passed. Physical arenas, event
schedules and secret-route release settings remain gated.\r\n\r\n
## UI/HUD overhaul candidate - 19 September 2026

Active UI worktree: DungeonMMO_Phase4_UIOverhaul_v1.
Branch: wip/phase-4-ui-overhaul-v1; baseline ff2baa0.
Shared styling, combat hotbar/status, dungeon HUD, contextual Expedition
and Auction windows, and refreshed Guild/core menus are implemented.
531 Luau sources parsed, four Rojo builds passed, Base and repeat Dungeon
Studio regressions passed; repeat Dungeon log has zero project errors.
Manual visual and prompt-to-window acceptance remains OPEN.
No push, merge or Roblox publish. Backend readiness gates unchanged.
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
