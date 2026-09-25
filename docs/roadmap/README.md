**v2.79 LIVE C4 EXECUTOR FOUNDATION GREEN:** [current roadmap](
DungeonMMO_Roadmap_v2_79_C4_Live_Combat_Executor_20260925.md)
and [green evidence](
../testing/c4-live-combat-executor-v2-79-20260925.md).
A disabled server-only live normal-attack executor now requires explicit
spatial mapping plus source calculation/resource gates and per-player cutover,
then routes playable damage through CP before HP. Fresh Studio Base **17/17
PASS**, Dungeon **19/19 PASS**, executor **10 assertions PASS**. Production
activation remains impossible until trusted spatial rules are configured.
Next: extend live execution across PDAM/MDAM/HEAL.

**v2.78 SPATIAL COMBAT INPUTS GREEN:** [current roadmap](
DungeonMMO_Roadmap_v2_78_C4_Spatial_Combat_20260925.md)
and [green evidence](
../testing/c4-spatial-combat-v2-78-20260925.md).
Reviewed C4 front/side/back, elevation/night hit conditions and shield facing
now use trusted server spatial context. Ordinary hit resolution consumes the
source condition multiplier and shielded PDAM derives facing from the same
context. Fresh Studio Base **16/16 PASS**, Dungeon **18/18 PASS**, spatial
**11 assertions PASS**, formula **51 assertions PASS**, source combat **30
assertions PASS**. Next: disabled live source-combat executor.

**v2.77 PDAM SKILL CRITICALS GREEN:** [current roadmap](
DungeonMMO_Roadmap_v2_77_C4_PDAM_Criticals_20260925.md)
and [green evidence](../testing/c4-pdam-criticals-v2-77-20260925.md).
Exact C4 SkillPdam critical-rate/STR arithmetic and post-PDAM ×2 handling are
now source-authoritative. Fresh focused Studio Base **15/15 PASS**, Dungeon
**17/17 PASS**, formula **51 assertions PASS**, source combat **30 assertions
PASS**. Next close source spatial hit/shield inputs before live combat cutover.
No main merge, publish or production saves.

**v2.76 NORMAL ATTACK / PVP COMPOSITION GREEN:** [current roadmap](
DungeonMMO_Roadmap_v2_76_C4_Normal_Attack_PvP_Composition_20260925.md)
and [green evidence](
../testing/c4-normal-attack-pvp-composition-v2-76-20260925.md).
The disabled source provider now composes ordinary player-target attacks from
hit, shield, critical/power, random variance, source weapon vulnerability,
player PvP modifier and one-use Soulshot. PDAM/MDAM now consume their matching
source PvP stat families. Fresh focused Studio Base **15/15 PASS**, Dungeon
**17/17 PASS**, formula **49 assertions PASS**, source combat **30 assertions
PASS**. Next close server-owned spatial hit/shield inputs before live cutover.
No main merge, publish or production saves.

**v2.75 C4 SOURCE SHOT AUTHORITY GREEN:** [current roadmap](
DungeonMMO_Roadmap_v2_75_C4_Source_Shot_Authority_20260925.md)
and [green evidence](
../testing/c4-source-shot-authority-v2-75-20260925.md).
Exact reviewed weapon shot grade/count now drives server-authoritative
inventory consumption and private one-use Kinetic/Mystic charge state for
source PDAM, MDAM and HEAL. Fresh Studio Base **15/15 PASS**, Dungeon **17/17
PASS**, source-shot **11 assertions PASS** and source-combat **25 assertions
PASS**. Next: PvP/source-target modifiers plus full normal-attack composition.
No main merge, publish or production saves.

**v2.74 C4 ELEMENTAL RESOLUTION GREEN:** [current roadmap](
DungeonMMO_Roadmap_v2_74_C4_Elemental_Resolution_20260925.md)
and [green evidence](
../testing/c4-elemental-resolution-v2-74-20260925.md).
Reviewed C4 source elements now resolve against authenticated final player
FIRE/WIND/WATER/EARTH/HOLY/DARK vulnerability stats before MDAM returns its
source-only result. Fresh Studio Base **14/14 PASS**, Dungeon **16/16 PASS**,
formula **49 assertions PASS**, source combat **24 assertions PASS**. Next:
server-owned shot inventory/consumption. No main merge, publish or production
saves.

**v2.73 C4 MAGIC FAILURE/CRITICAL GREEN:** [current roadmap](
DungeonMMO_Roadmap_v2_73_C4_Magic_Failure_Critical_20260925.md)
and [green evidence](
../testing/c4-magic-failure-critical-v2-73-20260925.md).
Authenticated final source M.Crit now drives a private server 0-999 roll with
the pinned 300/1000 cap; the exact optional two-roll magic-failure path is
represented while source configuration keeps MagicFailures=false. Fresh Studio
Base **14/14 PASS**, Dungeon **16/16 PASS**, formula **46 assertions PASS** and
source combat **23 assertions PASS**. Next: elemental resolution. No main
merge, publish or production saves.

**v2.72 SOURCE SHIELD RESOLUTION GREEN:** [current roadmap](
DungeonMMO_Roadmap_v2_72_C4_Shield_Resolution_20260925.md)
and [acceptance record](
../testing/c4-shield-resolution-v2-72-20260925.md).
Reviewed C4 shield rate/power now feeds exact DEX-scaled, bow-aware,
server-owned block/perfect rolls and PDAM formula application. Shielded PDAM
refuses to invent facing state; authoritative transform-derived facing remains
a requirement for the later live executor. Fresh focused Studio Base **14/14 PASS** and Dungeon **16/16 PASS**;
formula **37 assertions PASS** and source combat **21 assertions PASS**. No main
merge, publish or production saves.

**v2.71 PHYSICAL RANDOM VARIANCE GREEN:** [current roadmap](
DungeonMMO_Roadmap_v2_71_C4_Physical_Random_Variance_20260925.md)
and [green evidence](
../testing/c4-physical-random-variance-v2-71-20260925.md).
C4 physical random damage now comes only from the authenticated reviewed
source weapon rnd_dam or the original unarmed level fallback. The private
server roll uses the exact inclusive source range and PDAM source calculations
consume the resulting multiplier. Fresh unpublished Studio: Base **14/14
PASS**, Dungeon **16/16 PASS**, launch gear **12 assertions PASS**, formula
**30 assertions PASS**, source combat **15 assertions PASS**. Next: source
shield/perfect-shield handling. No main merge, publish or production saves.

**v2.70 PHYSICAL CRITICAL RESOLUTION GREEN:** [current roadmap](
DungeonMMO_Roadmap_v2_70_C4_Physical_Critical_Resolution_20260925.md)
and [green evidence](
../testing/c4-physical-critical-resolution-v2-70-20260925.md).
Ordinary C4 physical critical chance now resolves from authenticated final
source CRITICAL_RATE with integer truncation, the source 500/1000 cap and a
private 0-999 server roll. The final source candidate also carries the exact
critical-power neutral bases, multiplier 1 and additive 0, so reviewed
passive/active effects compose in the C4 calculator rather than stacking a
custom damage layer. Fresh unpublished Studio: Base **14/14 PASS**, Dungeon
**16/16 PASS**, formula **26 assertions PASS**, source combat **13 assertions
PASS**. PDAM-skill and magical critical resolution remain explicit later work.
Next: source weapon random-damage variance. No main merge, publish or
production saves.

**v2.69 NORMAL-ATTACK HIT RESOLUTION GREEN:** [current roadmap](
DungeonMMO_Roadmap_v2_69_C4_Normal_Attack_Hit_Resolution_20260925.md)
and [green evidence](
../testing/c4-normal-attack-hit-resolution-v2-69-20260925.md).
Exact C4 ordinary-attack hit chance/roll arithmetic is accepted in the pure
formula layer and disabled server-only source combat provider. Authenticated
final Accuracy/Evasion drive the original delta table; the provider owns its
0-999 roll. Source condition multipliers and final caps are implemented, while
runtime position/elevation/night mapping stays neutral and explicit. Reviewed
C4 PDAM skills remain separate from calcHitMiss. Fresh unpublished Studio:
Base **14/14 PASS**, Dungeon **16/16 PASS**, formula **22 assertions PASS**,
source combat **11 assertions PASS**. Next integrate physical critical roll and
critical-power components. No main merge, publish or production saves.

**v2.68 SOURCE COMBAT PROVIDER GREEN:** [current roadmap](
DungeonMMO_Roadmap_v2_68_C4_Source_Combat_Calculation_Provider_20260925.md)
and [acceptance evidence](
../testing/c4-source-combat-calculation-provider-v2-68-20260925.md).
Added a disabled server-only C4 combat calculation provider for authenticated
PDAM, MDAM and instant HEAL source ranks. It derives final attacker/defender
stats from the zero-blocker source boundary and resolves skill ID/rank/power
from actually owned creative skills; callers cannot inject C4 source stats or
power. Results remain source-only and do not alter HP/MP. Fresh Base **13/13
PASS** and Dungeon **15/15 PASS** at 0e859222. Next integrate authoritative
hit/crit/random/shield/magic-failure/element/shot/PvP inputs before any live
source damage executor. No main merge, publish or production saves.

**v2.67 REVERSIBLE RESOURCE CUTOVER GREEN:** [current roadmap](
DungeonMMO_Roadmap_v2_67_C4_Reversible_Resource_Cutover_20260925.md)
and [acceptance evidence](
../testing/c4-reversible-resource-cutover-v2-67-20260925.md).
The authenticated C4 HP/MP/CP candidate now has a disabled-by-default,
reversible live transport: fraction-preserving enable/refresh/rollback,
three-second source regeneration, PvP CP-before-HP routing, NPC CP bypass,
respawn reapply and global rollback. CombatService wires it into normal player
damage/lifecycle but the gate remains OFF unless server code explicitly opts a
player in. Final Base focused 12/12 PASS, Dungeon 14/14 PASS, and genuine
two-player unpublished Play emitted
`DEFAULT_OFF_FRACTION_CP_REGEN_RESPAWN_ROLLBACK_PASS` plus
`VERIFIED_PLAY_MODE_PASS`. Earlier live timeouts were a two-client Studio
admission fixture problem and were repaired test-only. No main merge, publish
or production saves.

**v2.66 LOCAL ACCEPTANCE GREEN:** [current roadmap](
DungeonMMO_Roadmap_v2_66_C4_Resource_Regen_Armor_Sets_20260925.md)
and [test evidence](
../testing/c4-resource-regen-armor-sets-v2-66-20260925.md).
A pre-cutover source audit found and closed two remaining parity gaps:
REG_HP/MP/CP calculator inputs and C4 Chest+Legs armor semantics. Every current
creative Body now expands to its reviewed historical chest+legs set while the
player-facing inventory remains six slots. C4 Heavy/Light/Magic conditions now
require matching chest+legs exactly, and regen-changing source skills compose
through the unified stat candidate. Fresh Base **12/12 PASS** and Dungeon
**13/13 PASS** at `b610d05c`. Source prerequisites remain green with zero
blockers; the live HP/MP/CP switch is still disabled. Next build the reversible
disabled-by-default resource cutover service. No main merge, publish or
production saves.

**v2.65 LOCAL ACCEPTANCE GREEN:** [current roadmap](
DungeonMMO_Roadmap_v2_65_C4_Combat_Point_Runtime_20260925.md)
and [test evidence](
../testing/c4-combat-point-runtime-v2-65-20260925.md).
Pinned C4 CP regeneration and PcStatus damage semantics are now represented in
a server-authoritative, disabled-by-default CP runtime. Max CP can only be
configured from a certified source migration boundary; playable damage uses CP
first while NPC damage bypasses it. The final `LiveCPRuntimeUnavailable`
prerequisite blocker is closed for clean characters. Base focused **11/11
PASS** and Dungeon **12/12 PASS** at `2aae5124`. All coordinated source
prerequisites are ready, but the live HP/MP/CP cutover remains explicitly
disabled. Next build the reversible, disabled-by-default coordinated resource
cutover service. No main merge, publish or production saves.

**v2.64 LOCAL ACCEPTANCE GREEN:** [current roadmap](
DungeonMMO_Roadmap_v2_64_C4_Active_Effect_Boundary_20260925.md)
and [test evidence](
../testing/c4-active-effect-boundary-v2-64-20260925.md).
Timed buffs and Endurance Surge now feed the private active C4 source registry;
unresolved live effects remain explicit blockers. All **21** current
persistent stat-effect skills / **25** launch-reachable ranks are covered
25/25 by reviewed C4 ACTIVE/TOGGLE source rows. The authenticated resource
boundary composes equipment + actually-owned passives + real active effects,
leaving only `LiveCPRuntimeUnavailable`. Fresh Base **10/10 PASS** and
Dungeon **11/11 PASS** at `1e01640f`. No live resource cutover, publish,
production save or main merge.

**v2.62 LOCAL ACCEPTANCE GREEN:** [current roadmap](
DungeonMMO_Roadmap_v2_62_C4_Authoritative_Active_Source_State_20260925.md)
and [test evidence](
../testing/c4-authoritative-active-source-state-v2-62-20260925.md).
A server-only active C4 source-effect registry now records the four existing
live toggle executors only after genuine server activation, independently
re-resolves creative rank -> source rank, and clears on deactivation, upkeep
failure, respawn and player removal. Learned skills and forged attributes do
not count as active. Fresh Base **9/9 PASS**, Dungeon **10/10 PASS** at
`d379e966`. Timed buffs remain to be bridged, so the active-effect blocker
stays in place; CP remains after that. No publish/main merge/production saves.

**v2.61 LOCAL ACCEPTANCE GREEN:** [current roadmap](
DungeonMMO_Roadmap_v2_61_C4_Active_Effect_Calculator_Ordering_20260925.md)
and [test evidence](
../testing/c4-active-effect-calculator-ordering-v2-61-20260925.md).
C4 passives, timed active buffs and toggles can now share one source calculator
queue with original operation ordering and named stack-group priority. The
unified source API exposes ordered item+passive+active snapshots but explicitly
keeps `ActiveEffectStateAuthoritative=false`; learned skills are not assumed
active. Fresh Base focused **8/8 PASS** and Dungeon **9/9 PASS** at
`0801508622a59c229af909a2d91a8769563a7b7e`. Next wire existing
server-owned live toggles/buffs into an authoritative source-effect registry.
The active-effect blocker remains until that runtime state is complete; CP is
then the final fixed blocker. No main merge, publish or production saves.

**v2.60 LOCAL ACCEPTANCE GREEN:** [current roadmap](
DungeonMMO_Roadmap_v2_60_C4_Owned_Passive_Source_Resolution_20260925.md)
and [test evidence](
../testing/c4-owned-passive-source-resolution-v2-60-20260925.md).
Actually owned creative passive ranks now resolve to one highest reviewed C4
source rank per passive family, including inherited starter passives on
first-transfer characters. Level eligibility alone grants nothing; unmapped
custom passives and over-range saved ranks fail closed. The authenticated
resource boundary composes reviewed six-slot source gear plus owned source
passives. Fresh Base focused **7/7 PASS** and Dungeon **8/8 PASS**. Only fixed
cutover blockers now remain active-effect ordering and CP runtime authority.
No main merge, publish or production saves.

**v2.59 LOCAL ACCEPTANCE GREEN:** [current roadmap](
DungeonMMO_Roadmap_v2_59_C4_Six_Slot_Paperdoll_Expertise_20260925.md)
and [test evidence](
../testing/c4-six-slot-paperdoll-expertise-v2-59-20260925.md).
All 27 current Equipment definitions now resolve to reviewed pinned C4 source
items across the complete current six-slot paperdoll. Exact Head/Chest/Gloves/
Feet 0x10/0x20 P.Def ordering is represented, and original Expertise skill 239
grade thresholds are enforced in the migration boundary. Base build + focused
6/6 PASS; Dungeon build + focused 7/7 PASS. The global inventory mapping
blocker is closed. Remaining live-cutover blockers: actually-owned passive
resolution, active-effect ordering and CP authority. No publish/production
save/main merge.

**v2.58 LOCAL ACCEPTANCE GREEN:** Both disposable Base and Dungeon
Rojo builds passed at
`e61eeb803bd0725aa89581a352583017d32f9fc5`. Focused Base v2.55-v2.58
resource/source tests passed 5/5 and Dungeon passed 6/6, including the split-MP
ManaService regression. Nine-class authenticated source preview now passes 554
assertions; resource boundary 42; creative item map 43; launch core gear 8;
runtime rules 13; ManaService 13. No place publish or production save action.
Next blockers remain Helmet/Gloves/Boots source paperdoll integration,
actually-owned passive translation, active-effect ordering and CP runtime.

**v2.58 GitHub-only, PLAYTEST NEXT:** [current roadmap](
DungeonMMO_Roadmap_v2_58_C4_Launch_Core_Gear_Source_Expansion_20260925.md)
and [test scope](
../testing/c4-launch-core-gear-source-v2-58-20260925.md).
Five more pinned C4 source items are represented: Trident 291, Neti's Bow
1181, Neti's Dagger 1182, Brigandine Tunic 352 and Manticore Skin Shirt 395.
All 18 current Weapon/Body/OffHand creative equipment items now have reviewed
source links. Helmet/Gloves/Boots explicitly fail closed because their source
paperdoll operations are not integrated yet. The authenticated resource
boundary now surfaces reviewed source core-loadout IDs without enabling live
HP/MP/CP. Pending v2.55-v2.58 focused tests should now be executed locally.
No main merge, publish or production save changes.

**v2.57 GitHub-only, STUDIO PENDING:** [current roadmap](
DungeonMMO_Roadmap_v2_57_C4_Creative_Item_Source_Map_20260925.md)
and [pending test scope](
../testing/c4-creative-item-source-map-v2-57-20260925.md).
Nine current creative equipment items now have explicit reviewed links to the
nine pinned C4 source items. Full Weapon/Body/OffHand conversion fails closed
if any equipped item is unreviewed, so current custom modifiers cannot leak
into source stat math. The inventory blocker is narrowed, not closed; polearm,
D-grade/expert gear and other current equipment still require real source
references. New tests are authored but not executed. No Remote Desktop
Commander edits, main merge, publish or production saves.

**v2.56 GitHub-only, STUDIO PENDING:** [current roadmap](
DungeonMMO_Roadmap_v2_56_C4_Resource_Migration_Boundary_20260925.md)
and [pending test scope](
../testing/c4-resource-migration-boundary-v2-56-20260925.md).
Added a fail-closed authenticated C4 resource migration boundary for all nine
current original Human/Elf paths. It exposes exact source base HP/MP/CP but
explicitly refuses live activation until original inventory mapping, actually
owned passive mapping, active-effect ordering and CP runtime authority are
integrated. ProgressionRuntimeState now exposes the boundary from server-owned
character state only; forged first-transfer ownership remains denied. New
nine-path tests are authored but not executed. No live Humanoid/ManaService
switch, main merge, publish, production saves or Remote Desktop Commander
editing.

**v2.55 GitHub-only, STUDIO PENDING:** [current roadmap](
DungeonMMO_Roadmap_v2_55_C4_Shared_Heal_And_Split_MP_Rules_20260925.md)
and [pending test scope](
../testing/c4-shared-skill-runtime-rules-v2-55-20260925.md).
Shared pinned C4 runtime rules now represent original split-MP casting
(total affordability, initial cost at cast start, ongoing cost on launch),
instant Heal power with 1.3x/1.5x Spiritshot multipliers and source magic
cast-time acceleration. ManaService has a reusable split transaction API,
but no existing skill was silently switched to it. The nine Scout heal
contracts now certify those source amount/MP semantics while remaining
SourceOnly, LiveLearnable=false, LiveCastable=false and 9 of the 22
explicit missing learning rows. Live C4 MaxHP/MaxMP/CP, regen, shot item
economy, Heal threat and the Scout trainer/executor remain OPEN. New
deterministic and ManaService regressions are authored but not executed;
v2.53's 500-assertion Studio evidence does not validate v2.55.
No Remote Desktop Commander edits, main merge, publish or production saves.

**v2.54 GitHub-only, STUDIO PENDING:** [current roadmap](
DungeonMMO_Roadmap_v2_54_Elven_Scout_C4_Heal_Migration_Plan_20260925.md).
Nine independent Elven Scout source-only self-heal contracts now preserve
the pinned C4 rank 4–12 SP/MP/power/self-target/reuse/cast fields and
original 20/24/28 learning brackets in the authenticated Scout preview.
These historical rows intentionally remain 9 of the 22 explicit
unimplemented skill rows until live C4 HP/MP/heal formula, separate
Scout trainer/rank and real executor exist. No live skills, HP, MP or
damage were changed. v2.53's 500-assertion Studio result belongs to
its earlier candidate only; v2.54 changes await testing tomorrow.
No main merge/publish/production saves.

**Current v2.53 authenticated nine-path C4 source skills:** [roadmap](DungeonMMO_Roadmap_v2_53_C4_Authenticated_Nine_Class_Skill_Source_20260925.md), [500-assertion unpublished Studio evidence](../testing/c4-authenticated-nine-class-source-skill-preview-v2-53-20260925.md). Current server-owned race/class/mentor state now gates read-only C4 original rank/power/MP/SP/target/source-effects preview across all 476 nine-path learning rows: 454 candidate creative links, 22 explicit gaps including nine Scout self-heal ranks. Both disposable Rojo builds PASS; 500 source assertions PASS. Not live skill ownership, source HP/MP/CP or final C4 gameplay balance. v2.51 46-assertion pinned sample original gear and v2.52 31-assertion original vitals source tests separately passed. No main merge/publish/production saves.

**Current v2.52 all-nine-class C4 source rollout:** [roadmap](DungeonMMO_Roadmap_v2_52_C4_Nine_Class_Authoritative_Stat_Preview_20260925.md) and [31-assertion Studio evidence](../testing/c4-nine-class-authoritative-runtime-stat-preview-v2-52-20260925.md). ProgressionRuntimeState.get_c4_source_vitals now reads nine-path original level-30 HP/MP/CP from authenticated server-owned identities and personally earned first-transfer receipts, denying copied classes and unreviewed level31. Focused unpublished Studio PASS 31; both Base/Dungeon Rojo builds PASS. This is NOT live Humanoid health/mana/CP, full equipment stats or completed C4 skill effects. v2.51 original 9-item gear sample remains source-only, 454/476 skill mapping links are candidate, 22 gaps. No main merge/publish/production saves.

**Current v2.51 nine-class C4 source equipment reference:** [roadmap](DungeonMMO_Roadmap_v2_51_C4_Nine_Class_Pinned_Item_Stats_20260925.md) · [46-assertion Studio evidence](../testing/c4-nine-class-pinned-equipment-source-v2-51-20260925.md). The unified stat snapshot now accepts nine verified historical source gear IDs with exact weapon/armour ordering, class-specific chest deductions, shield semantics and simultaneous permitted passives across all nine current original paths. Both disposable Rojo builds and 46 focused Studio source assertions PASS. This is NOT live item linkage, Humanoid HP/MP/CP, full original gear/stat or C4 skill-effect equivalence; 454/476 learning rows still have only candidate links and 22 unresolved rows. No main merge/publish/production saves.

**Current v2.50 nine-class C4 source stat calculator:** [roadmap](DungeonMMO_Roadmap_v2_50_C4_Nine_Class_Unified_Stat_Source_20260925.md) · [35-assertion Studio evidence](../testing/c4-nine-class-unified-stat-reference-v2-50-20260925.md). All four Human/Elf original starter paths and five first transfers now have one read-only, class/level-gated C4 HP/MP/CP + derived-stat + mixed weapon/armour passive reference. Both Base/Dungeon Rojo builds and focused Studio source assertions PASS. This is NOT the live HP/MP/CP, item-stat or full skill-effect migration; 454/476 source learning rows have candidate creative links, 22 are explicit gaps, and no class has certified exact C4 gameplay/balance parity. No main merge/publish/production saves.

**v2.49 C4 all-nine-class source map:** [current roadmap](DungeonMMO_Roadmap_v2_49_C4_Nine_Class_Creative_Mapping_20260924.md), [Studio evidence](../testing/c4-nine-class-creative-skill-map-and-passive-source-v2-49-20260924.md). All 476 historical level-30 learning rows classified: 454 source-to-creative candidate rank links, 22 explicit gaps, 0 broken links; 94 current numeric MP-cost differences. Fixed two previously authored Mystic debuffs absent from Mage class teaching. Shared read-only C4 passive calculator (source operation order, weapon/armour gating) passed 9 pure source assertions. **Neither candidate mapping nor a read-only formula certifies live C4 skills or balance.** Do not silently set source skill power equal to Roblox HP damage; coherent HP/MP/equipment/buff/live migration and remaining classes are OPEN. No main merge/publish/production saves.

**Current v2.48 all-class C4 effect source:** the exact
pinned C4 skill XML is now structured for all **75 source skill IDs /
272 unique learned source ranks** used by the nine original
paths through level 30. [Roadmap](
DungeonMMO_Roadmap_v2_48_C4_75_Skill_Effect_Source_20260924.md);
[evidence](../testing/c4-75-skill-effect-source-20260924.md).
This covers active costs/power/timing/targets/status and passive source
modifiers/weapon conditions. It is not yet live parity; next map every
creative DungeonMMO family to these source IDs/ranks and implement the
C4 equipment/passive calculator order before switching gameplay.

**Current v2.47 all-class C4 skill source:** all nine
implemented original paths now have an exact level<=30 learning-tree
inventory: 476 C4 rows / 75 source skill IDs including source skill
level, SP and minimum level. [Roadmap](
DungeonMMO_Roadmap_v2_47_C4_Nine_Path_Skill_Tree_Source_20260924.md);
[evidence](../testing/c4-nine-path-skill-tree-source-20260924.md).
Next resolve those 75 IDs against C4 skill XML and map the exact
power/cost/passive/status fields to the creative DungeonMMO IDs.
No live trainer/combat migration yet.

**Current v2.46 C4 formula work:** the pinned source
physical/magic damage, instant-heal, attack/cast timing, hit chance and
magic-level resistance formulas now have deterministic read-only
transcriptions and tests. [Roadmap](
DungeonMMO_Roadmap_v2_46_C4_Combat_Formula_Reference_20260924.md);
[evidence](../testing/c4-combat-formula-source-vectors-20260924.md).
This is the bridge that lets original C4 skill power remain skill power
instead of being mistaken for direct Roblox HP damage. Equipment/
passive calculator order and complete all-class skill source rows are
next; live combat remains unchanged.

**Current v2.45 C4 stat work:** a read-only C4 derived-stat
engine now sits on top of the exact nine source templates, covering
source stat bonuses, level modifier, naked P.Atk/P.Def/M.Atk/M.Def,
attack/cast/run speed, accuracy, evasion and critical-rate semantics.
[Roadmap](DungeonMMO_Roadmap_v2_45_C4_Derived_Stat_Engine_20260924.md);
[evidence](../testing/c4-derived-stat-formulas-source-20260924.md).
Equipment/mastery/buff calculator order and damage/heal/status formulas
are the next migration layer. Live Roblox stats/skills remain unchanged;
no publish/main merge/production saves.

**Current v2.44 C4 stat source:** exact C4 Scions of Destiny
class-template and HP/MP/CP growth data now exists for all nine
implemented original paths (4 starters + 5 first transfers), pinned to
C4 source commit `07f85363`. [Roadmap](
DungeonMMO_Roadmap_v2_44_C4_Exact_Nine_Class_Growth_20260924.md);
[evidence](../testing/c4-exact-nine-class-growth-source-20260924.md).
This closes the prior unsourced growth-table gap but is still read-only:
live Roblox health/mana/CP, damage, passives and skills remain on the
old custom system until the shared C4 derived-stat/formula migration is
implemented coherently. No publish/main merge/production saves.

**Current v2.43 C4 all-class stat migration (source-only):**
[source and rollout roadmap](
DungeonMMO_Roadmap_v2_43_C4_Nine_Class_Primary_Stat_Reference_20260924.md).
A source-verified six-attribute reference now covers all four
original Human/Elf Fighter/Mystic starter combinations and all five
first transfers, with a real unpublished Studio source test
PASS (77 assertions, 9 paths). The four primary baselines are
not live HP/MP/CP migration: zero level-growth tables are
C4-verified, and existing production HP, mana, stamina, damage,
skills and old saves remain unchanged. Prior v2.42 inventory
covers 13 current/legacy scopes and 1,353 class-scoped
rank occurrences, but only 32 have individually verified
C4 numerical source rows; count does not mean effect parity.
Do not report C4 balance or full classes complete.
No publish/main merge/production saves.

**Current v2.42 design decision: target historical C4 class-specific HP/MP/CP per level, STR/DEX/CON/INT/WIT/MEN and shared combat formulas BEFORE changing skill effects and costs across ALL implemented Human/Elven starters and first transfers.** [Roadmap](DungeonMMO_Roadmap_v2_42_C4_All_Classes_Stat_Baseline_20260924.md); [shared stat/skill target](../design/C4_All_Classes_Stats_And_Skills_Target_20260924.md). The existing 100-base-HP/five-attribute code and 24-row Warden-only reference are NOT full C4 parity. No live gameplay stat edits, no publish/main merge/production saves.

**All-current-classes C4 skill audit v2.42** — [roadmap](DungeonMMO_Roadmap_v2_42_All_Implemented_Class_Skill_Fidelity_20260924.md) and [13-class-scope findings](../testing/c4-all-implemented-class-skill-fidelity-20260924.md). Both Human/Elven Fighters and Mystics, five genuine first transfers, and four legacy Ranger/Rogue variants were inventoried; focused Studio reported 1,353 race/class-specific current skill-rank occurrences, only 32 with individual C4 source-number references. Full current runtime/passive definitions are inspectable per row; **NO CLASS is C4-mechanically certified**, and 1,353 is not a count of unique skills. Source and formula completion for EVERY family is outstanding. No live combat edits, public publish or main merge.

**v2.41 C4 original-mechanics fidelity AUDIT (not gameplay parity):** [roadmap](DungeonMMO_Roadmap_v2_41_C4_Skill_Effect_Parity_Audit_20260924.md), [source/runtime evidence](../testing/c4-skill-effect-source-runtime-differences-20260924.md). Current Warden and other classes use independently authored Roblox damage, threat, mana and percentage passives; first 24 documented C4 Warden heal/charm/taunt rank rows have 24/24 different numeric MP costs. The focused Studio *audit* executed, explicitly reporting NOT_CERTIFIED, while prior real-client gameplay acceptance remains separate. Exact C4 mechanics and balance need a sourced shared stat/formula layer and per-family verification; 56/56 Warden rank schedules are NOT 56/56 matching effects. No production combat number edits, publish or main merge.

**C4 mechanics audit OPEN (24 Sep): the five currently rank-scheduled level-20 first-transfer classes do NOT yet have exact verified original C4 numerical/mechanical fidelity.** [First-pass source/runtime audit](../design/C4_Skill_Effect_Fidelity_Audit_20260924.md) records concrete Warden heal/threat/passive and Human Warrior/Knight/Rogue/Scout deviations and adds a 24-row source-value reporter. Historic training rank schedules and focused gameplay PASS are not C4 formula parity. Continue shared formula/stat model before changing flat skill power into Roblox HP damage. No main merge/publish/production saves.

**Current v2.40 Warden: 52 assertions PASS for owner-private three-report save/release/reload, bound NPC report+seal consumption, real class award, first-rank purchase and final persisted rejoin across fresh ProfileService instances sharing one disposable in-memory store.** [Roadmap](DungeonMMO_Roadmap_v2_40_Warden_Disposable_Profile_Handoff_20260924.md); [evidence](../testing/greenward-warden-v2-40-profile-cache-reload-20260924.md). Previous independently executed actual client three-report, physical Base mentor/trainer and natural Captain AI bleed tests remain passed. True Roblox cross-place teleport, production save/rejoin, original C4 formula parity and remaining original classes are OPEN. No main merge/publish/production saves.

**Current v2.39 Greenward Warden: natural Captain AI Slash caused 24HP damage and genuine server bleed; actual client paid and cast Warden Bleed Recovery, clearing status without late ticks.** [Roadmap](DungeonMMO_Roadmap_v2_39_Natural_Captain_Bleed_Rig_20260924.md); [evidence](../testing/greenward-warden-v2-39-natural-captain-ai-and-rig-20260924.md). Unrelated stale Marauder rig automatic test now checks four actual factory-built temporary rigs and passes focused Studio regression. Prior three genuine client-earned reports across two rooms remain passed. Genuine uninterrupted Base/Dungeon/Base persistent save and C4 formula/release acceptance are OPEN. No main merge/publish/production saves.

**Current v2.38 Greenward Warden: genuine two-client Play now earned all THREE personal patrol reports across two original dungeon rooms and advanced the actual quest to stage 4; the other client independently earned its guardian seal.** [Roadmap](DungeonMMO_Roadmap_v2_38_Warden_Three_Reports_Owner_Gates_20260924.md); [evidence](../testing/greenward-warden-v2-38-three-reports-ledger-20260924.md). Original quest kill credit now revalidates race/base class/branch/stage before both hit and reward (58 ledger, 21 source-pack, 13 contribution assertions PASS). Ordinary pack room-one clear and high-HP test avatar were disposable helpers, not a full survival test. Cross-place save/rejoin and natural Captain AI bleed remain OPEN. No publish/main merge/production saves.

**Current v2.37 Warden: actual two-client normal combat now kills the real Rootbound Marauder and Thornbound Colossus without server test-finishing hits; each receives only their own report or guardian seal.** [Roadmap](DungeonMMO_Roadmap_v2_37_Warden_Client_Lethal_Quest_20260924.md); [test evidence](../testing/greenward-warden-v2-37-real-client-lethal-quest-20260924.md). Separate physical Base NPC, mentor and trainer Play remains passed; uninterrupted 3-report quest, natural cross-place persistence, original C4 formula parity and 18-class release remain OPEN. No publish/main merge/production saves.

**Current v2.36 Greenward Warden: isolated original-C4/legacy mastery regression PASS 65 assertions; genuine two-client physical Base NPC/mentor/trainer Play PASS and separate two-client instanced Dungeon Warden first-hit/personal report-seal Play PASS.** [Roadmap](DungeonMMO_Roadmap_v2_36_Warden_Real_Client_Quest_20260924.md); [test evidence](../testing/greenward-warden-v2-36-physical-client-quest-20260924.md). Dungeon final blows and prior Base loot were deliberately test-assisted, so full natural player kill and saved cross-place quest remain OPEN. 56/56 historical Warden rank schedules mapped, not certified exact source mechanic parity. No publish/main merge/production saves.

**Current v2.35 Greenward Warden: real client Bleed Recovery Play PASS after actual server Captain-tagged HP hit and server-owned bleed; the purchased client cure spent mana and prevented later bleed ticks.** [Roadmap](docs/roadmap/DungeonMMO_Roadmap_v2_35_Greenward_Player_Bleed_Client_Play_20260924.md); [testing evidence](../testing/greenward-warden-v2-35-player-bleed-live-20260924.md). Natural Captain AI slash, player-driven full quest/cross-place save and complete C4 balance/release acceptance remain OPEN. Source rank schedules 56/56 mapped; unrelated older SkillMasteryGatesTest emitted a failure in the full Play log, so no overall suite PASS is claimed. No main merge/publish/production saves.

**Current v2.34 Warden Studio acceptance: 56/56 Elven Knight source training ranks mapped; corrected Base/Dungeon focused tests passed (224 skill/craft, 24 quest, 32 level-30 audit, 16 physical Warden world); actual client shield+heavy-armour+guard retained 38.7 HP chip per blocked hit and 86 HP on guard-break, and zero-stamina reblock was denied.** [Roadmap](DungeonMMO_Roadmap_v2_34_Greenward_Studio_Acceptance_20260924.md); [test evidence](../testing/greenward-warden-v2-34-source-world-guard-20260924.md). Cross-race/base quest spawn denial and generic ledger suites also passed. Actual full saved quest journey, player bleed/cure Play and C4 formula parity remain OPEN. No public publish or main merge.

**Current v2.33 Elven Knight: its real instanced Dungeon quest pack now spawns separate Rootbound Marauders for stage3 and one Thornbound Colossus for stage5.** [Roadmap](docs/roadmap/DungeonMMO_Roadmap_v2_33_Elven_Knight_Physical_Quest_Enemies_20260924.md). Server loot ledger and Base quest transactions were previously authored; true end-to-end client Play remains OPEN. Source rank schedules 56/56 mapped, not full C4 formula/mechanics certification. No main merge/publish/production saves.

**Current v2.32 Warden: all 56/56 historical Elven Knight training ranks now mapped, including a genuine server-owned player bleed and self-only paid Bleed Recovery at level24.** [Roadmap](docs/roadmap/DungeonMMO_Roadmap_v2_32_Elven_Knight_Bleed_Recovery_20260924.md). Exact C4 effects/balance, source tests and real-client Captain bleed/cure Play still pending; 0/18 original first-transfer paths certified for full mechanical/release acceptance. Physical Warden quest monsters and natural cross-place saves remain OPEN. No main merge/publish/production saves.

**Current v2.31 Elven Knight: 55/56 source rank schedules mapped; the final outstanding rank is real level-24 Bleed Recovery.** Warden's two paid crafting tiers use the owner's one selected creation career and eight materials-backed recipes. [Roadmap](docs/roadmap/DungeonMMO_Roadmap_v2_31_Elven_Knight_Common_Creation_20260924.md). New focused source/craft tests remain Studio-pending; mapping does not certify real client Play or C4 formula parity. No main merge/publish/production saves.

**Current v2.30 Elven Knight: 53/56 source ranks mapped after seven new defensive/utility families; only creation 2 and bleed recovery 1 remain.** [Current roadmap](docs/roadmap/DungeonMMO_Roadmap_v2_30_Elven_Knight_Defensive_Utility_20260924.md). Rank mapping is not a live Play pass or exact C4 formula/party aura parity. Studio test runners remain pending; no public publish or main merge.

**Current v2.29 Warden active backend: 45/56 historical source-rank schedules mapped across three passives plus independently purchased heal, Charm and Aggression (11 rows remaining).** [Current roadmap](docs/roadmap/DungeonMMO_Roadmap_v2_29_Elven_Knight_Heal_Charm_Taunt_20260924.md). Existing real server heal/threat authorities are wired to the distinct Elven Knight class, but their new Studio Play regressions and genuine physical quest monsters are OPEN. Matching schedules do not establish C4 combat formula equivalence. No main merge/publish/production saves.

Focused Warden passive regression source added; Studio execution pending. [Current roadmap](docs/roadmap/DungeonMMO_Roadmap_v2_28_Elven_Knight_Three_Passive_Families_20260924.md).

**Current v2.28 Greenward Warden: 21/56 distinct Elven Knight source training-rank schedules mapped across Sword/Blunt, Heavy Armour and Magic Resistance, with real bounded server-side passive effect hooks; 35 rows remain.** [Current roadmap](docs/roadmap/DungeonMMO_Roadmap_v2_28_Elven_Knight_Three_Passive_Families_20260924.md). Independent paid trainer and class gates are registered; physical quest monsters and actual Studio skill Play remain OPEN. Source-audit assertions are written but not yet run in Studio. Four other fighter first-transfer paths retain their existing rank schedules; 0/18 original classes have full mechanics/release acceptance. No main merge/publish/production saves.

**Current class backend v2.27: Greenward Warden's full six-step quest transaction path is server-authored; physical dungeon enemy Play is still open.** [Roadmap](docs/roadmap/DungeonMMO_Roadmap_v2_27_Elven_Knight_Quest_Transactions_20260924.md). Three owner-bound patrol reports and one guardian seal now have atomic grant/turn-in rules, quest proof aggregation and combat-ledger proof IDs. The actual class-award service is covered by a new isolated full-quest transaction test, not yet Studio-executed. Elven Knight remains 0/56 trained skills; trainer is still empty. No main merge/publish/production saves.

**Current class backend v2.26: independent Greenward Warden class/mentor and first two Base quest NPC steps now authored; physical Play and full advancement remain OPEN.** [Current roadmap](docs/roadmap/DungeonMMO_Roadmap_v2_26_Elven_Knight_Quest_Foundation_20260924.md). The original Elven Knight's 56 historical level-20/24/28 rank rows remain 0 mapped. Its skill trainer intentionally offers no ability until actual effects are made; its stage-three world enemy, personally owned drops and final boss are not yet available, so the real class award fails closed. Human 3 and Elf 2 fighter branches retained; Elven Scout stays separate. New in-memory focus test and unpublished Base runner added but not executed in Studio. The v2.23 Warrior detached-avatar Play regressions are also pending. No main merge/publish/production saves/animation changes.

**Current class backend: v2.25 — Elven Knight's 56 historical level-20/24/28 C4 training rows now inventoried, 0 mapped/playable.** [Source inventory and next implementation](
docs/roadmap/DungeonMMO_Roadmap_v2_25_Elven_Knight_Source_Inventory_20260924.md). Human Fighter has three first transfers, Elven Fighter has two: four of their five rank schedules mapped, distinct Elven Knight still missing. Across all 18 first transfers, source inventories 5/18, rank schedules mapped 4/18, full mechanical/release certified 0/18. New Elf Knight audit assertions and v2.23 stored-avatar Play regressions still await Studio execution. No public publish or main merge.

**Current class-tree checkpoint: v2.24 — Human Fighter has three first-transfer choices, Elven Fighter has two; Elven Knight is the unimplemented fifth fighter path.**
[Class-tree checkpoint](docs/roadmap/DungeonMMO_Roadmap_v2_24_Human_Elven_Fighter_Path_Gap_20260924.md) records race-specific base Fighter source skills, keeps Greenward Scout distinct from the proposed Elven Knight/Warden, and does not mislabel Human Warrior as a level-1 starter. New focused coverage assertions are written but not yet Studio-executed. v2.23's stored-avatar security Play checks also remain pending.

## 24 September 2026 — v2.23 follow-up: detached-avatar precharge guard (Studio Play pending)

GitHub commit [39ba212](https://github.com/Amidazs/DungeonMMO/commit/39ba212654431c529b56309d6187e615e5fbb9b4)
tightens Warrior HP recovery and endurance surge to require the actual
owner character to be descended from Workspace. A stored or detached
Player.Character cannot regenerate or pass the surge's pre-MP-spend
activation check. The previous world-parented owner, purchased-rank,
living-Humanoid, no-stack and expiry checks remain intact.

The existing disposable recovery and genuine-client surge drivers now
exercise a temporarily ServerStorage-parented character and require
recovery denial and surge precharge denial, followed by valid restored
character acceptance. These **new test assertions have not yet been
executed in Studio**. The earlier v2.23 real-client success remains
evidence for the prior source revision only. Both Base and Dungeon
disposable Rojo builds succeeded locally after fast-forward to 39ba212;
a PowerShell quoting diagnostic also appeared in the wrapper, not in
either Rojo build. No production-place or production-save changes.

The 62/62 Warrior, 55/55 Knight, 59/59 Rogue and 77/77 Scout numbers
remain historical rank-row schedules only. Full C4 formula/effect parity,
natural persistent Base->Dungeon->Base->rejoin journey, boss/world-boss
stacking acceptance and 14 remaining source class inventories are OPEN.
No main merge, public publish or animation-project edits.

**Current DungeonMMO class backend: v2.23 — Warrior 62/62 historical level-30 training rows mapped; all six final utility rows focused-tested and actual owner HP surge/recovery Play PASS.**
[Current full roadmap](
DungeonMMO_Roadmap_v2_23_Warrior_Level30_Rank_Mapping_20260924.md)
and [exact executed test record](
../testing/ironvow-final-utilities-v2-23-20260924.md).
The personally earned Ironvow now has critical MP
stance (three ranks), MP accuracy stance, passive
HP recovery and paid active max-HP surge (one
rank each), beyond its earlier trained weapon,
control, profession and equipment skills. Fresh
disposable Base/Dungeon Rojo builds PASS.
Actual quest/trainer/in-memory save/foundation
**31/198/160 assertions PASS**, strict source
rank audit **27 PASS**. Real-client critical and
accuracy toggle damage/evasion/MP Play previously
passed. The first new recovery Play failed due
to a test-only detached Player.Character; the
test now spawns and waits for a world-parented
real owner and recovery Play PASSED, without
weakening the actual server owner/health checks.
The new client hotbar surge Play PASSED: 13 MP,
108->118.8 owner maximum HP, single 11.88 HP heal,
no immediate stack/recast, incoming hostile 100 HP
melee still applies, and revoked/copy-class
ability cleanup succeeds. Historical rank mapping:
Warrior **62/62**, Knight **55/55**, Human Rogue
**59/59**, Elf Scout **77/77**. These are *training
schedules*, not mathematically identical C4
combat mechanics, natural saved cross-place
acceptance or full release. Other **14/18** original
first-transfer source inventories and starter
levels 1–19 remain; **0/18** release-certified.
Earlier Marauder/Captain shield chip tests do not
establish every boss/world-boss damage path.
No main merge, Roblox publishing, production saves
or parallel animation edits.

**Previous DungeonMMO backend: v2.20 — Warrior common crafting and transaction denial PASS; six utility ranks were then unmapped.**
[Current roadmap](
DungeonMMO_Roadmap_v2_20_Warrior_Common_Craft_20260924.md)
and [precise executed tests](
../testing/ironvow-common-crafting-v2-20-20260924.md).
Warrior `IronvowCommonItemCreation` at original
level20/28 requires a genuinely earned class, base
recipe literacy and one selected creation career.
Eight actual material-backed recipes cover four
creation careers; source-tier Blacksmithing makes
owned 2-handed polearm and D-grade Warrior body
armour (actual equipping remains gated by its
distinct purchased equipment expertise). Server
crafting spends actual owned ingredients, saves
owned rank and still denies a second crafting
career. A previously prepared higher-rank craft
cannot complete after source rank revocation:
no materials lost or output duplicated. Source
Quest/Award/Foundation **31/182/131 PASS**,
rank audit **27 PASS** and disposable Base/
Dungeon Rojo PASS. Warrior **56/62 source
rank rows mapped**, six utility rows still
missing; Knight **55/55 scheduled**. These
are NOT complete original C4 economy/math,
natural cross-place player journey or class
release certification (**0/18**). Never
merge `main`, publish Roblox or touch
production saves/animation worktrees.

**Previous DungeonMMO backend: v2.19 — real D-grade Warrior equip tested; common crafting tiers were still unmapped.**
[Current roadmap](
DungeonMMO_Roadmap_v2_19_Warrior_Equipment_20260924.md)
and [focused actual server equip/save proof](
../testing/ironvow-equipment-expertise-v2-19-20260924.md).
The Warrior's distinct `IronvowEquipmentExpertise`
requires genuine first-transfer class, level20 and its
own paid rank; it does not create items or borrow the
Knight's gear. Actual Inventory/Equipment services
denied an owned D-grade cuirass until purchase, then
equipped it and applied +20 server max-HP; forged/
underlevel denied and test profile rank/item survived
save/reload. Fresh Base/Dungeon disposable Rojo PASS,
Quest/Award/Foundation **31/144/125 PASS** and source
audit **27 PASS**. Warrior **54/62 training ranks
mapped**, eight utility rows remain; Knight **55/55
mapped**, no original class certified for complete
C4 mechanics, exact original stat formula, natural
cross-place save or release (**0/18**).
No `main` merge, Roblox publication, production saves
or separate animation worktree changes.

**Previous DungeonMMO backend: v2.18 — true-client Warrior stun/MP/HP verified; D-grade expertise was not mapped at that checkpoint.**
[Current roadmap](
DungeonMMO_Roadmap_v2_18_Warrior_Stonebreaker_20260924.md)
and [executed real-client proof](
../testing/ironvow-stonebreaker-v2-18-20260924.md).
Distinct personally bought `IronvowStonebreaker`
level-20/24/28 blunt control preserves nine original
source power/MP rows and a true one-target melee hit
with server-owned shock. Actual unpublished client
slot-one request spent **30 MP**, hit real spawned
NPC for **21.3888 HP**, and applied **1.1 sec**
stagger; premature second cast, real equipped sword
and forged Fighter were denied. No shock refresh for
already dazed targets is implemented but **two concurrent
player stun attempts remain untested**. Quest/Award/
Foundation **31/137/119 assertions PASS**, separate
source rank audit **27 PASS**, both disposable Rojo
builds PASS. Warrior now **53/62 source training
rows mapped, 9 utility rows missing**; Knight
**55/55 schedules mapped** but neither class
is certified C4-effect-equivalent or release-ready.
Actual skill uses a bounded Roblox stun and HP adapter,
not the original C4 damage formula or stun duration.
The client Play used an internally valid disposable
earned-class fixture, not a naturally saved complete
cross-place quest. Prior Marauder/Captain held Block
chip exploit fix remains; broad boss/world-boss
stacking audit and all 14 unimplemented first-transfer
source inventories remain open. No `main` merge,
Roblox publishing, production saves or animation edits.

**Previous DungeonMMO backend: v2.17 — distinct nine-rank polearm area skill tested on 20/22 real NPC targets; 18 Warrior rows still missing at that checkpoint.**
[Current class roadmap](
DungeonMMO_Roadmap_v2_17_Warrior_Crescent_Sweep_20260924.md)
and [exact targeted Studio evidence](
../testing/ironvow-crescent-sweep-v2-17-20260924.md).
The earned Warrior `IronvowCrescentSweep` is a genuine
20/24/28 three-rank-per-band skill with its own trainer,
required real equipped polearm and learned mastery,
source power 90–191 and MP 22–30 by independently bought
rank. This is **not** the ordinary polearm melee swing.
Actual server area acquisition caps 20 enemy targets
independently of basic polearm 5/10 cap. One disposable
22-NPC world test at ranks1/9 measured 20 actual HP losses
once each, **46 assertions PASS**; Quest/Award/Foundation
**31/118/96 PASS**; source audit **27 PASS**; disposable
Base/Dungeon Rojo builds PASS. Warrior rank schedules now
**44/62 mapped**, 18 still missing; Knight **55/55
scheduled**, neither class has full historical C4 math,
natural cross-place play or release certification. Roblox
area power adapter 0.15 × historical C4 source power is
provisional, not proven source damage scaling. The area
HP fixture used a scripted attacker, not real mouse-input
or live MP spending; these remain explicit open tests.
No `main` merge, Roblox publishing, production saves
or unrelated animation work changes.

**Previous DungeonMMO backend: v2.16 — Warrior polearm mastery and physical multi-target basic swings passed, with 27 unmapped source ranks at that checkpoint.**
[Current v2.16 C4 roadmap](
DungeonMMO_Roadmap_v2_16_Warrior_Polearm_20260924.md)
and [exact executed source/runtime/Play evidence](
../testing/ironvow-polearm-mastery-v2-16-20260924.md).
Four real purchased Polearm Mastery ranks (20/24/28/28)
retain C4 source P.Atk 4.5/7.3/8.9/10.7 and +5
hit targets. Server-registered two-handed polearm uses
distinct wide melee geometry, capped at 5 untrained
or 10 earned targets across all samples; a 12-NPC
physical-world test confirms only the permitted targets
lose HP once. Actual player-owned real NPC HP goes
from **110 to 111.07** (100-base) by rank four
under the provisional source-to-Roblox stat adapter.
Actual equipment service denies shield-then-polearm
and polearm-then-shield, preserving shield-block
anti-invulnerability. Genuine Warrior Quest/Award/
Foundation **31/99/73 PASS**, both disposable Rojo
builds PASS, focused 12-NPC HP **26 PASS** and real
player/NPC Play PASS. Strict source rank audit:
Warrior **35/62 mapped, 27 missing**, Knight **55/55
mapped**, both still require original C4 formula/skill
effect equivalence, live natural saved play and broad
boss/world-boss/multiplayer exploit testing. Four of 18
original first-transfer paths source inventoried,
**0/18 release certified**. Desktop Commander reports
87% monthly usage; preserve remaining credits and
avoid repeatedly running already passing suites.
No `main` merge, public Roblox publish, production
DataStore or separate animation-worktree changes.

**Previous DungeonMMO backend: v2.15 — genuine earned Warrior sword and blunt mastery tested on real NPC HP; polearm ranks not yet mapped at that checkpoint.**
[Current class roadmap](
DungeonMMO_Roadmap_v2_15_Warrior_Sword_Blunt_20260924.md)
and [exact focused/live Studio evidence](
../testing/ironvow-sword-blunt-mastery-v2-15-20260924.md).
Corrected stable saved Ironvow `IronvowBladeTraining`
from sword-only to real registered equipped Sword or Blunt,
at four separate C4 source ranks 20/24/28/28. Genuine
class trainer/equip/forgery focused Quest/Award/Foundation
**31/81/60 assertions PASS**. Fresh disposable Base and
Dungeon Rojo PASS. Actual Dungeon player-owned physical
hit on real NPC HP increased from **110 to 115.6** at
rank four with BOTH Sword and Blunt, while unequipped,
Dagger, Bow and forged Fighter denied. Strict source
audit **27 assertions PASS**: Warrior **31/62 mapped**,
31 missing; Knight **55/55 mapped**, with both first-
transfer classes still pending complete C4 mechanical
equivalence and full release proof. `0/18` first
transfers release certified. The provisional 0.014 per-
rank Roblox attack conversion does NOT prove C4 balance.
Historical v2.12 held-shield exploit patch on Marauder/
Captain still enforces chip damage and guard break;
all boss/world-boss attack paths require separate audit.
No `main` merge, Roblox publishing or production saves.

**Previous DungeonMMO backend: v2.14 — Knight 55/55 source schedules mapped; four crafting careers passed focused service tests, not full C4 parity.**
[Current class roadmap](
DungeonMMO_Roadmap_v2_14_Knight_Common_Craft_C4_20260924.md)
and [focused Studio evidence](
../testing/knight-common-crafting-v2-14-20260924.md).
Consolidated the single earned Knight `OathguardCommonItemCreation`
rank family (20/28) after removing an accidental duplicate
skill/recipe/server-rule implementation. Genuine owner-only
ranked crafting requires one selected creation profession,
consumes server-owned ingredients and creates real inventory
items, including owned blunt mace/D-grade armour at a
Blacksmithing station. Focused quest/foundation **247/112
assertions PASS**, level-30 rank audit **27 assertions PASS**,
both disposable Rojo builds PASS. Server transaction
revalidates a rank revoked *after preparation*, refusing
the output without materials loss or item duplication;
all eight recipes across four isolated one-career profiles
passed actual server crafting tests. Knight maps **55/55**
historical skill rank rows; Warrior remains **27/62**,
35 unmapped. All other first-transfer classes still need
C4-level-30 source audit/implementation; **0/18** release
certified. C4 Common Item Creation was automatically
acquired in the original; DungeonMMO currently uses a
class trainer and one-profession selection. This and the
provisional combat-stat formulas remain documented design
differences, **not** identical C4 economy or game balance.
Previously verified shield-block exploit fix still ensures
stacked Knight defences cannot make ordinary sustained
Marauder/Captain hits do zero HP damage. Never claim
boss/world-boss or end-to-end protection until tested.
No `main` merge, Roblox publish or production DataStore use.

**Previous DungeonMMO class backend: v2.13 — Knight sword and blunt damage proof; three common/expertise rows were still unmapped at that checkpoint.**
[Current C4 class backend roadmap](
DungeonMMO_Roadmap_v2_13_Knight_Sword_Blunt_20260924.md)
and [exact focused plus live weapon damage evidence](
../testing/knight-sword-blunt-mastery-v2-13-20260924.md).
Implemented independently paid lvl20/24/28/28 Knight
`OathguardSteelAndStoneTraining` as physical damage
passive for genuinely server-equipped Sword **or** Blunt.
Added a separate registered blunt training mace item and
routed it through the actual server melee-hit executor.
A dagger using the prototype sword hitbox or missing
equipment does NOT inherit the passive. Focused Knight
Quest/Foundation **108/103 assertions PASS**, disposable
Base/Dungeon builds PASS, and actual spawned Dungeon
NPC Humanoid HP per 100-base server attack:
Sword untrained/mastered **110 → 114.8**,
Blunt untrained/mastered **110 → 114.8**,
wrong gear and forged class denied. The four rank
`0.012` Roblox multiplier per rank is provisional:
source C4 P.Atk. formula/rank effect values and final
equipped Tool animation and full player-input hit
remain unverified; never equate schedule mapping
with complete original C4 mechanical balance.

Corrected source Knight inventory **55 ranks** (including
two bow-defence ranks at 24/28), now **52/55 mapped**
with **3 historical utility ranks still missing**:
equipment expertise rank1 and common-item creation
ranks2/3. Warrior remains **27/62**, 35 missing,
and other 14 original advancement branches are
not source-complete. Previously discovered shield
zero-HP block/guard-break exploit has been fixed
and actual stacked Knight buff/block HP verified
in Marauder/Captain pipelines; remaining boss,
world-boss and full cross-place regression pending.
**0/18** first-transfer classes release-certified.
No `main` merge, Roblox publish or production save.

**Previous DungeonMMO class backend: v2.12 — real shield-block exploit and dual defence/bow protection tested; seven Knight ranks then unmapped.**
[Current C4 backend roadmap](
DungeonMMO_Roadmap_v2_12_Knight_Defense_Exploit_Bow_20260924.md)
and [actual focused and live Studio evidence](
../testing/knight-block-fortress-bow-anti-exploit-v2-12-20260924.md).

Previous real Marauder/Captain shield block yielded **zero HP**
even on GuardBroken: these server attack paths now route blocked
HP chip and guard-break hit through actual player damage.
Genuine local-client shield+Majesty held block loses **41.13 HP**
per 100-base strike, and the fourth guard-breaking hit loses
**91.4 HP**; the client cannot re-block/parry at zero stamina.
Dedicated independently paid C4 Knight Ultimate Defence
(`OathguardLastBastion`) spends MP19, anchors the caster
for an actual tested 30 seconds, protects both physical and
magic; stacked shield, Majesty, Ultimate and blocked hit still
lose **25.38 HP** on real Humanoid, not near-zero. No Dodge
bypass, delayed-expiry immunity or premature recast accepted.

A source audit found the original C4 Knight has **two**
bow-protection ranks (24/28); previous 54-rank inventory
omitted level28. Corrected to **55**, Knight source training
rows mapped **48/55**, **7** left (equipment expertise 1,
common-item creation 2, sword **and blunt** mastery 4).
Two independently bought `OathguardArrowWard` ranks
cost original MP22/28 and protect *only* authored enemy bow
damage. Actual client Play on spawned player HP PASS at
84/81 HP for 100 base enemy bow; blocked bow HP 37.8/36.45;
ordinary melee and magic remain 100. Bow defence/duration,
Ultimate and Majesty source defence-stat conversions to
Roblox are **provisional**: no complete C4 maths or balance
equivalence. There is no implemented actual hostile NPC bow
projectile yet: bow Play injected authoritative damage
source kind, not full ranged enemy simulation. Only the
Marauder and Captain real enemy blocked-hit controllers
were directly fixed; audit all boss/world-boss attack paths.

Fresh disposable Base/Dungeon Rojo builds and exact
Quest/Foundation **96/95 assertions PASS** plus dedicated
skill/stacked-block Play tests PASS. These are targeted
results, NOT a fully green global regression or natural
saved cross-place journey. Warrior maps 27/62 with 35
unmapped; other 14 original first-transfer source
inventories incomplete; **0/18** careers release-certified.
No `main` merge, Roblox publish or production save changes.

**Previous DungeonMMO class backend: v2.11 — documented source Majesty corrections and earlier genuine client playtest, superseded by v2.12 current defence checks.**
[Current Knight C4-fidelity roadmap](
DungeonMMO_Roadmap_v2_11_C4_Knight_Majesty_20260924.md)
and [exact live Studio test evidence](
../testing/oathguard-c4-majesty-v2-11-20260924.md).
Replaced previously adapted 10%/10s/14-stamina
Knight stance with documented C4 +7% physical
defence, -2 Evasion and 10 MP reference parameters.
Actual DungeonMMO server now applies an independently
expiring five-minute physical guard and evasion penalty
after a genuine client hotbar cast; real owner HP loses
93 from 100-base hostile physical melee and area hits,
100 on enemy magic/PvP-style hits and 100 again after
test-forced expiry. Fresh Base/Dungeon disposable Rojo
PASS, awarded Knight Quest/Foundation **87/84 PASS**
and exact isolated Play `VERIFIED_PLAY_MODE_PASS`.
C4 P.Def and Evasion are temporarily converted to
7 percentage-point Roblox physical mitigation and
2 percentage-point evasion chance cost, **not** the
original C4 mathematical damage/evasion formulas.
Earlier v2.09 Knight stance tests are **historical**.
Level-30 Knight rank schedules **45/54**, nine still
missing; Warrior **27/62**, 35 missing. No first-transfer
career release certified, no main merge, Roblox publish,
or production DataStore manipulation.

**Previous DungeonMMO class backend: v2.10 — verified distinct seven-rank Knight life drain and separate original C4 mechanic parity audit.**
[Current full roadmap](
DungeonMMO_Roadmap_v2_10_C4_Skill_Fidelity_Knight_Drain_20260924.md)
and [exact Studio evidence](
../testing/oathguard-umbral-siphon-v2-10-20260924.md).
Added `OathguardUmbralSiphon` as distinct *offensive dark-magic
life drain*, with **seven** separately bought C4 level-20/24/28
ranks, source power/MP per rank and **20% of actual dealt
NPC damage returned to its owner as HP**. This is not the
existing owner-only `OathguardMendingOath` healing spell.
The latest disposable Base/Dungeon Rojo builds PASS,
Knight quest/trainer **88 assertions PASS**, foundation
**84 PASS**, strict launch-rank audit **27 PASS**.
Fresh unpublished Dungeon Play confirmed the actual client
damaged a training NPC for 20 and healed its owner 4 HP
at rank one; rank seven damaged for 31 and healed 6.2 HP.
Forged-class skill use was denied. Source skill *rank
schedule* now maps Knight **45/54**, with **9 missing**,
Warrior **27/62**, with **35 missing**. **0/18** original
advancement careers are full level-30 release certified.
C4's original magic attack formula, skill timings and other
already-authored class abilities are not necessarily
gameplay-identical just because their rank schedules map:
see the explicitly audited outstanding mechanics differences
in the v2.10 roadmap. No `main` merge, publication,
production saves or remote-desktop permanent source edits.

**Previous DungeonMMO class backend: v2.09 — earned Knight timed defensive stance with focused and live-client HP verification; 16 Knight ranks then unmapped.**
[Latest class backend roadmap](
DungeonMMO_Roadmap_v2_09_Knight_Steadfast_Stance_20260924.md)
and [executed test evidence](
../testing/oathguard-steadfast-stance-v2-09-20260924.md).
An awarded Knight can separately purchase level-20
`OathguardSteadfastStance` after Fighter armour rank 3:
real server stamina cost 14, nonstacking 10% physical
self-guard for 10 seconds, 24-second cooldown.
Verified fresh Base/Dungeon disposable Rojo builds,
Knight quest and foundation **70 + 67 assertions PASS**,
strict source audit **27 PASS**, and real-client
Dungeon Play: 100-base hostile physical melee/area
hits dealt 90 HP under the active buff and 100
after expiry; enemy magic and ordinary player melee
remained at 100. A quick second cast did not extend
the buff; an unearned Fighter cannot use it. This
live Play fixture used test-only internally verified
advancement/rank snapshots, not a fully natural
persistent player journey. Knight rank-map is now
**38/54, 16 missing**; Warrior **27/62, 35 missing**.
Earlier v2.08 Knight real-client self-heal **30/44 HP**
and spell mitigation **95.2 HP from 100** also PASS.
The two-client physical Base rerun PASS used a bounded
genuine client-input retry after one initial missed
Captain Rowan hold; root cause of intermittent first
hold is not certified fixed. **0/18** original first
transfer careers are fully level-30 release certified.
No `main` merge or Roblox publish.

**Previous DungeonMMO class backend: v2.08 — focused Studio, physical quest after one input retry and real-player shield/heal/magic PASS; full release acceptance pending.**
[Latest level-30 roadmap](
DungeonMMO_Roadmap_v2_08_Oathguard_Shield_Masteries_20260924.md)
and [pending acceptance checklist](
../testing/oathguard-shield-mastery-github-candidate-v2-08-20260924.md).
Two newly registered, individually bought Knight shield ranks
at levels 20 and 28 require a genuinely earned Oathguard and
a server-registered equipped OffHand shield. Each rank gives
0.8% hostile physical melee/area damage reduction, up to 1.6%;
magic and PvP are unaffected. The actual own-career trainer,
rank inventory, runtime snapshot, DamageService and focused
test fixtures have been updated directly in GitHub. Knight
source-rank schedule mapping is now a candidate **37/54** with
**17** missing, Warrior **27/62** with **35** missing; two
source-audited Scout paths retain 59/59 and 77/77 mapped
training schedules. **At the initial GitHub-only checkpoint, no new Studio tests or
disposable Rojo builds had run**; the fresh verified results below
supersede that pending status. Prior v2.07
Ironvow Base physical PASS remains historical evidence; its
Knight healing/magic live-client effect tests are still
pending. No level-30 release certification, main merge,
Roblox publish or production DataStore operations occurred.

New 24 September focused Studio quest/foundation **66/62 PASS**,
level-30 source audit **27 PASS**, both disposable Rojo builds PASS,
and live full-Dungeon **actual player-HP shield damage PASS**:
99.2/98.4 from 100 base hostile melee at ranks one/two, 98.4
hostile area at rank two, and zero shield benefit on magic, PvP,
missing/wrong gear or forged class. This Play fixture uses an
internally valid **synthetic** Knight quest/rank/equipment snapshot,
not naturally client-purchased/equipped state. A separately executed
**two-client physical Base test FAILED** at the visible, enabled
Captain Rowan prompt: holding it did not fire server Triggered.
Pending: targeted prompt transport fix, natural class/equipment
path, live client heal/magic and cross-place save/rejoin.
[Fresh detailed evidence](../testing/oathguard-shield-mastery-github-candidate-v2-08-20260924.md).

**Previous DungeonMMO class backend: v2.07 — verified recovered Ironvow physical Base acceptance and additional Knight anti-magic and owner-healing ranks.**
[Current level-30 class/skill roadmap](
DungeonMMO_Roadmap_v2_07_Ironvow_Resume_Knight_Magic_Healing_20260924.md)
and [actually executed test record](
../testing/ironvow-resume-oathguard-magic-healing-v2-07-20260924.md).
The timed-out Ironvow physical test was
recovered; an older build genuinely failed
the physical NPC trigger. The current
unpublished two-client Base test **PASS**
was verified from its own Roblox Studio
process log, including genuine source
NPCs, personally bound four-marker and
boss-seal turn-ins, level-20 physical
career mentor and live client trainer.
Another concurrent test wrote unrelated
markers to the named output log; that
mixed output is **not** Ironvow evidence.
New original Oathguard Runic Resistance
adds eight purchased 20/24/28 ranks
with actual server EnemyMagic mitigation
(up to 4.8% for genuinely awarded Knight
profiles only). Its new Mending Oath
adds three purchased level-28 self-heal
ranks using the existing server-owned
heal executor (30/37/44 base HP).
The final unpublished Base and Dungeon
Rojo builds **PASS**, focused Knight
Quest/Foundation **2/2 PASS (56 + 56
assertions)** and current source-rank
audit **27 PASS**. The new effects have
not yet passed their own real
client-originating spell-damage and
self-heal tests. Historical first-
transfer rank-map status remains
Ashenblade **59/59**, Greenward Scout
**77/77**, Ironvow **27/62** and
Oathguard **35/54**, as training
schedules, not a complete natural
level-1–30 class, independent source
equivalence or all distinct live effects.
**4/18** careers have prior real
physical source/mentor/trainer acceptance,
**0/18** complete initial release
catalogues. Level 30 remains planned
but not yet enforced. No `main` merge,
Roblox publication, production
DataStore mutation or Desktop Commander
source edits. The separate humanoid
and quadruped animation work is intact.

**Previous DungeonMMO class backend: v2.06 — real physical Warrior/Knight class-trainer acceptance and explicit level-30 remaining ranks.**
[Latest class/skill roadmap](
DungeonMMO_Roadmap_v2_06_Original_Warrior_Knight_Physical_Acceptance_20260923.md)
and [executed Studio tests and limits](
../testing/ironvow-oathguard-physical-and-rank-audit-v2-06-20260923.md).
The intended initial release level cap stays
**30** (not yet server enforced). The original
Human Warrior → **Ironvow** and Human Knight
→ **Oathguard** careers now have real
unpublished two-client **physical Base**
quest NPC, personally owned proof-item
turn-in, level-20 mentor-award and
client skill-purchase acceptance. Knight's
prior incorrect badge and skill test IDs
were fixed and its temporary hub prompts
separated from Ironvow; both physical
runs finally **PASS**. The Base now applies
a **server-side nearby trainer check**
for *every* registered original advanced
career on trainer snapshots and both
learn/rank requests, not just the two
previously supported Scout classes.
Both Warrior and Knight separately passed
real two-client instanced Dungeon
source enemy hit and owner-specific
item-drop acceptance; their test driver
provided the lethal finishing blows.
Ironvow's earned-only fortitude and
seated stamina recovery ranks now
affect actual server HP and stamina,
persist through save/reload and cannot
be gained from a forged class identity.
The actual focused Knight tests passed
**29 + 38** and world binding **11**;
focused Warrior tests passed
**31 + 79 + 58**. Launch inventory
audit **27 assertions PASS**:
the repository's source training-row
counts are Ashenblade **59/59**,
Greenward Scout **77/77**,
Ironvow **27/62**, Oathguard **24/54**
mapped ranks at levels 20/24/28.
These numbers are *purchase schedules*,
not all C4 source effects or starter
levels 1–19 accepted. **4/18**
authentic original class-award
backends and physical Base/client
trainer paths now have dedicated
live acceptance; **0/18** have
an entire natural level-1→30
career and uninterrupted real
cross-place gameplay accepted.
No Roblox publish, production
DataStore mutation, `main` merge
or permanent code/document edits
through Desktop Commander. The
independently maintained humanoid
and quadruped animation roadmaps
remain intact.

**Previous DungeonMMO class backend: v2.05 — Ironroot original Warrior quest, personally owned monster drops and server-authorized Ironvow class transfer.**
[Latest active class roadmap](
DungeonMMO_Roadmap_v2_05_Ironroot_Quest_And_Ironvow_Transfer_20260923.md)
and [executed v2.05 acceptance / limitations](
../testing/ironvow-quest-world-class-v2-05-20260923.md).
The independently authored Human Fighter →
**Ironvow** now has a six-stage ordered
level-18 source quest, separate physical
Marshal Torren/Smith Orla hub NPCs, four
owner-bound Ridge Marauder dispatch markers,
one uniquely registered Ridgebreaker boss
and personally consumed final Oath Seal.
The server-only original level-20 transfer
service and physically separate class mentor
and trainer are registered; class and the
first actual sword skill survive profile
save/reload only with earned quest proofs
and an authentic one-use mentor receipt.
Unpublished actual **two-client Dungeon**
combat/loot tests PASS for one genuine
client hit on each physical raider and
boss, with server-authored finishing hits
granting the correct personal items.
Focused quest **31 PASS**, award/skill/save
**17 PASS**, Warrior first-skill safeguards
**34 PASS**, physical stage/boss registration
**11 PASS**, existing class compatibility
**459 + 8 PASS**, and cap inventory audit
**25 PASS**. This is **not** a complete
unassisted cross-place Warrior journey
or a passed client-held physical Base
mentor/trainer playtest. Ironvow currently
has 15 authored skill ranks versus 62
recorded Warrior first-transfer reference
rows; neither complete source-game mechanic
parity nor full level-1–30 class acceptance
is claimed. **3/18** branches have a
source/award backend, **2/18** have completed
physical class/trainer client acceptance,
and **0/18** are complete level-30
class gameplay catalogues. No Roblox
publication, production DataStore change,
`main` merge or permanent code editing
via Desktop Commander. Separate humanoid/
quadruped animation roadmaps remain intact.

**Previous DungeonMMO class backend: v2.04 — new live two-client expanded Scout combat and first locked Human Warrior skill foundation.**
[Latest class backend roadmap](
DungeonMMO_Roadmap_v2_04_Expanded_Combat_Ironvow_Foundation_20260923.md)
and [executed v2.04 Studio test record](
../testing/original-first-transfer-expanded-combat-and-ironvow-v2-04-20260923.md).
An unpublished real two-client instanced Dungeon
playtest **PASS** verified rank-nine Wayfinder
Cut/Arrow hits, genuine dagger bleed ticks
and Greenward Calming Arrow reducing its
owner's actual server threat after a damaging
hit. The expanded combat test used test-only
prior class/skill progress, not a new fully
natural level-1→30 cross-place journey.
The next Human Warrior's independently
named **Ironvow** backend now defines nine
ranks of an original sword attack, three
ranks of purchased sword mastery and three
ranks of a temporary combat buff. The
unpublished Base/Dungeon builds and focused
**33-assertion Warrior foundation** passed,
including refusal of a forged class identity,
purchased skill and passive bonus. Ironvow
is intentionally **not earnable or advertised
as a third playable class**: its independent
source quest, legitimate monster and NPC
world binder, level-20 physical mentor and
separate trainer still need implementation.
The two existing original first-transfer
careers remain **2/18** actually awarded;
recorded level-20/24/28 rank schedules are
mapped, but full starter 1–19 parity, every
skill's functional gameplay acceptance
and real uninterrupted cross-place travel
are still open. Level 30 remains the
planned, not server-enforced initial cap.
No Roblox publish, production DataStore
change, merge into `main` or permanent
source editing via Desktop Commander.
Independent humanoid/quadruped animation
roadmaps remain untouched.

**Previous DungeonMMO class backend: v2.03 — original level-30 first-transfer source rank schedules and purchase acceptance.**
[Latest active class backend roadmap](
DungeonMMO_Roadmap_v2_03_Level_30_First_Transfer_Rank_Coverage_20260923.md)
and [executed Studio acceptance / limitations](
../testing/original-first-transfer-level30-ranks-v2-03-20260923.md).
The intended initial release remains **level 30**.
Both previously implemented physical Human Rogue →
Ashenblade and Elven Scout → Greenward Scout
source/mentor class paths now offer their complete
*recorded historical level-20/24/28 rank schedules*
through genuine earned-Fighter career trainer entries:
**59/59** Human and **77/77** Elf individual source
rank entries, including shared/general skills, not
different skill icon counts. Dedicated new bow/dagger
attack/mastery lines use valid server combat/rank
effects and source prerequisites; existing audited
DungeonMMO armor, movement, recovery, critical
and utility skills are newly available only
for the correctly earned original careers, with
the crafting profession choice kept mandatory.
All mapped ranks were exercised through genuine
server ProfileService/SkillProgressionService
purchases in isolated test profiles. Base/Dungeon
local builds **PASS**, focused Base class/skill
**2/2 PASS (459 + 8 assertions)**, source-rank
audit **25 PASS**, and actual unpublished
two-client Base mentor/trainer regression **PASS**.
This is *not* every ability's live client
combat/effect acceptance, not an uninterrupted
real cross-place quest, and does not enforce
a live level-30 cap yet. The next original
Human Warrior **62** and Knight **54**
through-cap source rank inventories are now
audited, but **neither class/quest/trainer
is playable yet**. Exact status: **2/18**
genuine original level-20 career awards,
**2/18** source-rank trainer schedules
mapped/purchased, **4/18** historical
first-transfer through-cap source catalogues
audited, **0/18** full-class gameplay
acceptance. No Roblox publish, production
DataStore write, `main` merge or edits via
Desktop Commander. Separate humanoid and
quadruped animation roadmaps remain intact.

**Previous DungeonMMO class launch scope: v2.02 — initial cap at level 30 with complete historical C4-through-cap skill-rank coverage as the acceptance target.**
[Latest class/skill launch roadmap](
DungeonMMO_Roadmap_v2_02_Level_30_Launch_Skill_Parity_20260923.md).
Stop building level-32/36+ class unlocks merely for the
initial release: finish the C4 reference skill families and
individual learnable ranks available through level 30 for
every advertised original DungeonMMO class. The two
previously accepted physical level-20 class identities
currently have two independently authored trainable
abilities each; that is NOT a complete C4-equivalent
level-30 catalogue. The source-row audit records
Human Rogue **20 + 19 + 20 = 59** and Elven Scout
**26 + 25 + 26 = 77** individual historical
rank entries in the level-20/24/28 brackets,
including shared/general ranks. These are not
different skill button counts or currently
implemented ranks; current old Rogue/Ranger
legacy skill implementations must not be
misreported as original first-transfer training.
New `C4Level30LaunchCoverage` audits all 18 source
first-transfer paths, keeps all completeness
flags false and explicitly marks the remaining
16 historical through-cap inventories for review.
Its focused unpublished Base Rojo/Studio test
**PASS, 22 assertions**. Once the two current
class catalogues satisfy this level-30 gate,
continue Human Warrior/Knight and Human
Wizard/Cleric, then the other original
class/race branches; independently author
all player-facing DungeonMMO class, skill,
NPC, monster and quest expression. This is
a revised release *scope*, not an already
enforced game level cap or a finished
first-transfer catalogue. No Roblox publish,
`main` merge, production DataStore write
or Desktop Commander source editing.
The independently maintained humanoid/
quadruped animation roadmaps remain current.

**Previous DungeonMMO class backend: v2.01 — real client-caused first-transfer combat and negative-cast acceptance.**
[Latest class backend roadmap](
DungeonMMO_Roadmap_v2_01_Real_Original_Combat_20260923.md)
and [executed two-client Studio test record](
../testing/original-first-transfer-real-combat-v2-01-20260923.md).
Both original level-20 first-transfer careers now have
two implemented trainable abilities each. The new
level-24 Ashenblade Opening and Greenward Renewal
also passed real unpublished two-client instanced
Dungeon **combat**, not merely skill-definition or
trainer tests. An actual Human client hit a physical
current-room enemy with Opening and spent actual
stamina/cooldown; a wrong-weapon client request
did not damage the enemy or begin a cooldown.
A separate actual Elf client healed only its
own Humanoid with Renewal, spent actual mana
and began its server cooldown; an unpurchased
client heal did not trigger that effect. The
test tolerates small ordinary regeneration.
Prior source quests, level-20 awards and owned
skill ranks were prepared in disposable Studio
profiles to isolate new combat; this is **not**
an uninterrupted cross-place quest acceptance
or proof of rank-two live effects. The accepted
rank-two training and stronger effect
definitions remain covered by v2.00.
**2/18** original careers have real physical
class awards and two trainable abilities each;
**0/18** complete original first-transfer class
catalogues or uninterrupted real journeys.
No Roblox publish, production DataStore write,
`main` merge or local code/doc edits via
Desktop Commander. Animation roadmaps remain
independent and untouched.

**Previous DungeonMMO class backend: v2.00 — original level-24/28 skill progression and live trainer safeguards.**
[Latest backend roadmap](
DungeonMMO_Roadmap_v2_00_First_Transfer_Skills_20260923.md)
and [actual focused/real-client Studio acceptance](
../testing/c4-original-first-transfer-v2-00-20260923.md).
Original **Ashenblade** and **Greenward Scout** still
require their genuine earned level-20 class transfer.
Each now has **two implemented trainable abilities**:
the class's earlier level-20 ability plus the new
level-24/28 ranked Ashenblade Opening or Greenward
Renewal. Their unique trainer catalogues and combat
runtime require the matching persisted class,
correct player race/level, purchased starting-skill
ranks, earned proficiency and, for Ashenblade
Opening, a real equipped dagger. The new abilities
use the existing authoritative damage/healing
executors with actual stronger rank-two effects,
not client-supplied HP or damage. Actual Base/Dungeon
Rojo builds passed; focused Base Studio **2/2 PASS**
(93 original class/skill/runtime/persistence
assertions and 8 adjacent migration checks).
Unpublished real **two-client trainer PASS**:
each client saw the actual in-game physical
trainer catalogue and purchased the appropriate
new level-24 skill using a real client remote.
Out-of-range requests, a foreign trainer ID and
exhausted legitimately earned SP were rejected.
Earlier quest completion and prerequisite mastery
were prepared within this disposable test to avoid
replaying earlier accepted quest stages. A new
skill's actual live enemy hit/self-heal cast and
an uninterrupted cross-place journey are **not**
yet accepted. **2/18** original first-transfer
identities have physical award and two trainable
skills each; **0/18** are complete entire class
catalogues or full real cross-place acceptance.
Keep the separate humanoid/quadruped animation
roadmaps current and independent. No Roblox
publication, `main` merge, source edits using
Remote Desktop Commander or production DataStore
mutation.

**Previous original first-transfer class backend: v1.99 — genuine level-20 careers and physical mentors.**
[Latest class backend roadmap](
DungeonMMO_Roadmap_v1_99_Original_First_Transfers_20260923.md)
and [executed unpublished Studio tests](
../testing/c4-original-first-transfer-v1-99-20260923.md).
Two independently named DungeonMMO careers now have
real server-verified first-transfer identities:
**Ashenblade** (Human Fighter/Rogue source) and
**Greenward Scout** (Elf Fighter/Scout source).
Physical **Marshal Briar** and **Pathwarden Siora**
ProximityPrompts require actual level-20 eligible
quest owners, one-use server mentor receipts,
matching saved race/branch and complete source
proof before an atomic profile-backed award.
Separate physical advanced trainer stations
allow each newly earned class to **purchase**
exactly one already implemented class skill;
ordinary legacy Rogue/Ranger specialist skill
catalogues cannot be claimed by a new Fighter
class simply by changing a ClassId. Profile
schema v15 preserves earned classes/receipts
across save/reload and rejects unbacked raw
ClassId changes. Focused server tests passed
**2/2** (47 award/skill/persistence assertions
and 8 adjacent migration checks). The dedicated
real two-client physical mentor playtest passed
both original first-transfer awards and actual
server-side purchases after production prompt
collision/visibility fixes. That final focused
test **seeded completed source quests in a
disposable unpublished Base**, rather than
repeating the earlier genuine source quest
tests; it did not exercise real live cross-place
transport or the full training UI remote flow.
**2/18** careers now have level-20 class awards
and one trainable skill each; **0/18** are
accepted as feature-complete first-transfer
skill catalogues or as uninterrupted real
cross-place journeys. The separately maintained
quadruped/humanoid animation roadmaps remain
unaffected. No Roblox publish, `main` merge
or production DataStore mutation; scripts,
tests and docs edited in GitHub only.

**Current DungeonMMO source-quest backend: v1.98 — Scout Cael rescue, real Bracken Warden and final hub reports.**
[Newest backend roadmap](
DungeonMMO_Roadmap_v1_98_Scout_Cael_Warden_Source_20260923.md)
and [actual v1.98 unpublished Studio acceptance](
../testing/c4-scout-cael-source-v1-98-20260923.md).
A selected, active Elf Fighter can now find the
physical Scout Cael actor in an instanced dungeon,
trigger an authenticated stage-five discovery
prompt, defeat a unique stage-six Bracken Warden
and earn one personally bound Bracken Ward Sigil.
A second actual owner prompt refuses a missing
sigil and consumes the real item atomically
when rescuing Cael; replay and unrelated Human
clients cannot advance the Elf's quest. The
existing physical Warden Thorne and Pathfinder
Elyra hub NPCs handle ordered stage-eight and
stage-nine reports. Actual two-client Dungeon
rescue and separate Base hub tests passed
without awarding advanced classes; the Base
fixture explicitly seeded previously completed
rescue state. Focused Base **5/5 PASS**
(170 source assertions), Dungeon **3/3 PASS**
(10 + 24 + 13 assertions) and shared-store
coordinator save/fresh-profile handoff **66
assertions PASS**. Human Rogue and Elven Scout
source quests can now each reach `Ready`;
**actual uninterrupted cross-place gameplay,
entirely client-controlled victory sequences,
level-20 class identities and skill/trainer
authorization remain pending. Fully playable
first-transfer advanced classes: 0/18.**
All source and roadmap edits remained in GitHub;
no Roblox publish, `main` merge, production
DataStore mutation or local source edit.

**Current DungeonMMO C4-inspired backend: v1.97 — source quest handoff, original Cinder recovery and physical captain final report.**
[Newest source quest backend roadmap](
DungeonMMO_Roadmap_v1_97_Source_Cinder_Quest_Handoff_20260923.md)
and [executed Studio acceptance record](
../testing/c4-original-quest-stage5-7-handoff-v1-97-20260923.md).
The first real extended two-client Dungeon test exposed a
zero-XP/empty-bestiary quest-enemy reward error that blocked
room clearing; this was fixed in GitHub. The subsequent
two-client live combat test passed first-room physical
Crypt Sentinel/Bracken Raider progression and a later
registered Cinder Brigand fight in the next room,
including a genuine client normal-attack hit and
server-authenticated lethal proof granting all four
personally owned original supply items. The Base two-client
physical NPC test passed ordered Captain Ashford stage
five and seven prompts, missing-item rejection,
atomic four-item consumption and the original
Human Rogue **source quest Ready** state, without
granting an unfinished advanced class. Real coordinator
save and fresh destination-profile handoff fixtures passed
**58 assertions**, preserving Human ten fragments,
Elf four report pieces and subsequent Cinder supplies
on two separate mocked returns. Focused Base **5/5 PASS**
(165 source assertions); Dungeon **3/3 PASS**
(10 ledger, 24 physical quest pack/reward, 13 contribution
assertions). **Real continuous cross-place transport,
all ten/four player-controlled kills, late Elven rescue,
level-20 trainer/skill/class awards and full advanced
classes are not accepted. Fully playable original
first-transfer classes: 0/18.** All scripts, tests
and documents changed only in GitHub. No `main`
merge, Roblox publish or production DataStore edit.

**Current C4 backend: v1.96 — physical stage-three quest fights and original stage-four NPC turn-ins.**
[Latest backend roadmap](
DungeonMMO_Roadmap_v1_96_Source_Quest_Combat_And_Return_20260923.md)
and [actual two-client Studio acceptance](
../testing/c4-original-quest-stage3-4-v1-96-20260923.md).
Active quest owners now encounter two original-name
Crypt Sentinels or Bracken Raiders per ordinary instanced
combat-pack room; the server registers exact physical
monster lives and applies one owner-bound source drop per
qualified kill. A disposable two-client Dungeon playtest
passed real room entry, both monster archetypes, one
genuine client normal-attack hit and genuine server-authority
lethal proof for one rightful source item per player.
The real Base Vela/Thorne physical prompts now accept
a later stage-four return **only** with personally owned
complete source materials and proof; they atomically
consume ten/four items, then leave the player at
stage five with no free class award. A second genuine
two-client Base playtest passed missing-item denial,
real physical turn-ins, replay protection and spent-item
checks. Focused Dungeon combat **3/3 PASS**;
Base class/quest/migration **5/5 PASS** with **153**
quest assertions. Both unpublished Rojo compositions built.
**The cross-place continuous quest journey, complete ten/four
player-controlled kills, later story stages and original
level-20 transfer remain untested/unimplemented. Fully
playable original first-transfer classes: 0/18.**
Retain original DungeonMMO visual/writing identity,
stable saved legacy keys, one Gathering and one
Crafting profession per character, separate animation
roadmaps, no `main` merge and no Roblox publish.

**Current C4 backend: v1.95 — original DungeonMMO advancement quest names and combat ledger.**
[Newest class/quest backend roadmap](
DungeonMMO_Roadmap_v1_95_Original_Quest_Names_Combat_Ledger_20260923.md)
and [executed unpublished Studio tests](
../testing/c4-original-naming-and-monster-ledger-v1-95-20260923.md).
The player-facing source quest mentors and enemies now have
distinct DungeonMMO names (Captain Ashford, Quartermaster Vela,
Pathfinder Elyra, Warden Thorne, Crypt Sentinel and Bracken Raider).
The two quest titles, visible item labels and class UI were updated
without changing the underlying saved legacy inventory/quest keys.
The Base focused source/skill suite passed **5/5** (148 original
quest/naming assertions); the actual **two-client physical Base NPC**
playtest passed with all four new prompt labels; the separate
Dungeon focused combat-ledger and damage-observer suites
passed **2/2** (10 registration and 13 contribution/fan-out
assertions). The optional original quest ledger is now
connected to the real Dungeon session's accepted server
damage callback without replacing ordinary combat rewards.
Both unpublished local Rojo compositions built. **No actual
source quest monster has been registered in a playable
instanced room yet, so genuine quest combat remains untested**;
no completed quest or original level-20 class award is claimed,
and fully playable original first-transfer branches remain
**0/18**. Preserve independent game art/writing, one Gathering
plus one Crafting profession, legacy saves, separate animation
roadmaps and no `main` merge/Roblox publish.

**Current C4 backend: v1.94 — source-monster quest drop foundation (not live combat).**
[Newest original C4 backend roadmap](
DungeonMMO_Roadmap_v1_94_C4_Quest_Drop_Foundation_20260923.md).
The server-only source quest service now binds unique
monster-life receipts to exactly one character's
stage-three progress and owner-bound Spartoi bones
or four individually earned Prias letter fragments.
Rogue skeleton proof requires the actual Neti trial
weapon equipped, ten distinct receipts and ten
personally owned bones. The ordered Neti/Moretti
return stages require corresponding personally
owned evidence. The focused source fixture has
been extended, and disposable Base/Dungeon Rojo
builds succeeded. **Actual Studio verification of
the new fixture remains pending; the genuine
instanced skeleton/Ol Mahum monsters and real
combat/death receipt adapter are not yet wired.**
The already verified v1.93 physical hub NPC stages
remain the last genuine two-client source quest
playtest. Original C4 complete class paths:
**0/18**. No original level-20 transfer, main
merge or Roblox publish.

**Current C4 backend: v1.93 — real Neti and Guard Moretti original quest stage two.**
[Newest original C4 class backend roadmap](
DungeonMMO_Roadmap_v1_93_C4_Neti_Moretti_Quest_20260923.md)
and [actual focused and two-client Studio test record](
../testing/c4-original-second-npc-v1-93-20260923.md).
The live Base now binds two distinct physical
source NPCs for **each** of the selected original
Human Rogue and Elven Scout first-transfer quests:
Captain Bezique → Neti and Master Reisa →
Guard Moretti. The actual Human Fighter receives
one separately owned, personally bound,
non-tradeable and genuinely equippable
Neti trial dagger and bow **atomically with
the authenticated real Neti NPC stage**.
The Elf's separate Moretti meeting never
grants the Human's trial weapons. Both
quests stop honestly at their still-unbuilt
instanced source-monster stage three.
The actual unpublished **two-client** Base
playtest passed both physically triggered
NPC quest paths, rightful trial item
ownership/equip, cross-branch denial,
forged event refusal and stage replay
protection. Focused affected source
quest/rank/migration tests passed **5/5**,
including **125** source quest assertions
and saved/reloaded trial equipment.
The previous genuine Bezique first-NPC
playtest also passed with the new
second-stage availability.
**No original level-20 class award
has been implemented: 0/18 paths
fully playable.** The original Fighter/
Mystic fresh starters, exactly one
Gathering plus one Crafting profession,
hub/instanced dungeon structure,
separate latest humanoid/quadruped
art roadmap, no-publish policy and
legacy save preservation remain
unchanged.

**Current C4 backend: v1.92 — genuine first-stage original C4 quest NPCs.**
[Newest C4 backend roadmap](
DungeonMMO_Roadmap_v1_92_C4_Original_NPC_Quest_20260923.md)
and [actual one-client physical NPC and backend test record](
../testing/c4-original-first-npc-v1-92-20260923.md).
The live Base now contains server-controlled
Captain Bezique and Master Reisa source
quest prompts. A genuine Human Fighter
client at disposable test level 18 explicitly
chose Human Rogue, physically interacted
with Bezique, started and saved only the
first authentic original C4 quest step
and observed the correct pending-stage
status in the actual class GUI. Unchosen
NPC visits, replayed first NPC and
forged future dungeon quest events
were rejected. Original class remains
Fighter; **no original level-20
class transfer or unearned skill rank
was awarded**. The separately authored
full Rogue/Elven Scout original quests
still need their actual Neti/Moretti
actors, instanced source monsters,
quest-only items, transfer NPCs and
atomic class/skill authorization.
Original first-transfer paths fully
playable: **0/18**. Current 396
functional analogue ranks across
six partial inventories are NOT
proof of complete original C4
source skill parity. Preserve
Fighter/Mystic original starts,
one-Gathering/one-Crafting careers,
the separate humanoid/quadruped
art roadmap and no-publish policy.

**Current C4 backend: v1.91 — original class QUESTS and SKILLS are both active workstreams.**
[Newest C4 quest and skill roadmap](
DungeonMMO_Roadmap_v1_91_C4_Quest_And_Skills_20260923.md)
and [actual focused Studio test evidence](
../testing/c4-original-quest-skill-scope-v1-91-20260923.md).
The [previous v1.90 client-tested level-18 class choice](
DungeonMMO_Roadmap_v1_90_C4_Explicit_First_Transfer_Choice_20260923.md)
remains accepted; it has not been repeated. In v1.91
the source-specific Human Rogue and Elven Scout quests
were researched and converted into separate **ordered
server-authoritative original C4 stage and loot-proof
rules**, with protected character progress and
save/reload. A missing real NPC/monster/quest-item
world binding causes the live service to **fail closed**;
both paths are source-authored and testable through
a simulated server-only world fixture but **not yet
playable**. Skill coverage now audits all 18 original
first transfers separately from the old six-list
**396/396 DungeonMMO analogue rank** figure.
The first **28 original C4 level-20 rank entries**
have been individually inventoried for Human Warrior
(12) and Human Knight (16), with none falsely
marked functional. Original Rogue/Elven Scout
analogues still require exact source parity
verification and post-transfer trainer gates.
Targeted unpublished Studio quest/skill and
profile regressions **5/5 PASS**, including
**117** new quest/skill assertions; Base and
Dungeon disposable builds and Luau parse PASS.
Original C4 first transfers fully playable:
**0/18**, original first-transfer class
catalogue incomplete. Keep Fighter/Mystic
fresh starting classes, explicit quests
and original branch skill gates together.
Preserve the independent humanoid/quadruped
animation roadmap, one Gathering plus
one Crafting profession and no-publish rule.

**Current C4 class backend: v1.90 — real first-transfer choice, quests still pending.**
[Newest C4 class roadmap](
DungeonMMO_Roadmap_v1_90_C4_Explicit_First_Transfer_Choice_20260923.md)
and [executed focused and two-client Studio evidence](
../testing/c4-explicit-first-transfer-choice-v1-90-20260923.md).
Fresh characters begin **Fighter or Mystic** (temporary
internal Mystic ID `Mage`) and at original
level 18 may explicitly select an original
race/family-specific C4 first-transfer path
in the new closable Base class-choice UI.
The actual server persists that one chosen
branch and prohibits forged other-race
choices, early selection and replacement
without awarding any advanced class
or fake quest. The old automatic
Vanguard/Arcanist/Thornwarden trial
cannot start on a new Fighter/Mystic.
Already-started old quests may still be
claimed and historical custom classes,
skills, economy and profession slots
remain intact for the explicit
versioned migration yet to come.
Final expanded unpublished focused
Studio closeout: **8/8 PASS**, including
the original five suites plus quest
advancement migration, race-change
migration and race-change service
regressions. Actual unpublished
**one-client GUI/remote playtest PASS**
and **two-client Base playtest PASS**: two Human Fighter
clients saw their respective source
choices, independently chose Rogue
and Human Knight, and could not
claim an unearned automatic class
or change their first source choice.
The GUI was observed and real
client remotes executed; the test
did not manually click the UI card.
The underlying original branch-specific
advancement quests and level-20 class
award remain **unimplemented**:
**0/18 original first transfers are
fully playable**, notwithstanding
396/396 mapped ranks in six previously
inventoried starter/Rogue/Scout lists.
Preserve the separate newer
humanoid/quadruped art roadmap,
one-Gathering/one-Crafting policy
and no Roblox publish/main merge.

**Current C4 class backend: v1.89 — Fighter/Mystic-only fresh starters confirmed.**
[Newest C4 starter-class roadmap](
DungeonMMO_Roadmap_v1_89_C4_Starter_Classes_20260923.md).
Fresh DungeonMMO characters now follow the user's
chosen Chronicle 4 starting-class rule: choose race,
then begin as **Fighter or Mystic** (the current
internal compatibility ID for Mystic remains
`Mage`). Fresh Ranger and Rogue selection is
rejected; those definitions stay loadable only for
legacy saves and migration. Existing Human/Elf
identity UI already exposes Fighter/Mystic only.
Focused unpublished Studio identity acceptance
passed **3/3**: 58 existing identity assertions,
26 Mystic assertions and 26 fresh-starter assertions.
The full v1.88 original five-race / 18 first-transfer
source structure remains authoritative for later
advancement. Legacy Ranger/Rogue saves must be
migrated without deleting progression or awarding
an unearned original branch. Preserve one
Gathering + one Crafting profession, no publish,
and the separate animation/art roadmap.

**Current C4 class backend: v1.88 — original C4 advancement paths confirmed.**
[Newest original C4 class roadmap](
DungeonMMO_Roadmap_v1_88_Original_C4_Class_Structure_20260923.md)
and [source structure / Studio acceptance record](
../testing/c4-original-five-race-class-structure-v1-88-20260923.md).
The user's chosen design is to follow the
**actual original Lineage 2 Chronicle 4
race/class trees and first, second and third
advancement paths**; similar custom
DungeonMMO role names are not substitutes.
Previous updates incorrectly treated the
**nine** original Human/Elf first transfers
as the full source scope. The complete
original five-race source first-transfer
tree contains **18 distinct branches**:
nine Human/Elf, four Dark Elf,
three Orc and two Dwarf. All eighteen
are now explicitly catalogued and
their distinct source quests/level-18
start and level-20 transfer metadata
recorded; an explicit source-class
validator rejects wrong-race choices,
legacy-class shortcuts, insufficient
levels and unimplemented source quests.
Focused unpublished Studio acceptance
passed **3/3** (144 class-source, 14
choice/quest and 7 strict coverage
assertions). Source rank mapping of
**396/396** refers *only* to the
four existing Human/Elf starter lists
and the currently mapped Human Rogue/
Elven Scout lists. It is **not** the
whole original C4 catalogue: only
Human and Elf profiles are playable,
the other sixteen first-transfer
branches have no completed original
gameplay implementations, and the
aggregate complete flag remains
**0/18**. The current legacy custom
secondary-class runtime and starting
role profiles must still undergo
explicit backwards-compatible
migration before the actual original
class-choice quest UI is live.
Preserve the separate latest
humanoid/quadruped animation roadmap,
the one-Gathering/one-Crafting career
rule and no-publish policy.

**Current C4 backend: v1.87 — all 396 ranks in six audited source inventories now implemented.**
[Latest C4 backend roadmap](
DungeonMMO_Roadmap_v1_87_C4_Scout_Source_Environment_20260923.md)
and [actual focused/real-client Studio acceptance evidence](
../testing/c4-scout-environment-equipment-sprint-v1-87-2026-09-23.md).
Both currently inventoried first-transfer
source lists reached numerical source-rank
parity: Human Rogue **99/99**, Elven Scout
**129/129**, alongside the four original
starting-class lists **168/168**.
The seven new source entries are authentic
purchased level-20 expert-equipment,
breathing and fall mitigation ranks
for both classes plus Human Rogue
Sprint. A genuine single-career
Leatherworker manufactured and sold
the expertise-gated vest through
the real profession and market
services; the Rogue buyer could not
equip it before training and gained
real maximum HP only on legitimate
equip. Actual one-client unpublished
Dungeon tests passed real paid Sprint
client activation/speed/expiry,
real Terrain water submersion,
drowning Humanoid HP and controlled
server fall-injury mitigation.
Focused Studio **5/5** passed,
including **106**, **28**, **1,183**
and **38** assertions in the relevant
skill, expert-gear market, C4
inventory and existing equipment
suites. **Source rank parity of
396/396 is not full C4 catalogue
completion**: seven *other* original
first-transfer classes still have no
source inventory implementation;
the authoritative full class-path
gate remains **0/9 complete** and
`Completed=false`. Preserve the
separate current humanoid/quadruped
art roadmap, the one-Gathering/one-
Crafting career rule and the
no-publish policy.

**Current C4 backend: v1.86 — secure Rogue/Scout Lockpicking.**
[Newest C4 backend roadmap](
DungeonMMO_Roadmap_v1_86_C4_Scout_Lockpicking_20260923.md)
and [actual focused Studio / physical one-client test record](
../testing/c4-scout-lockpicking-v1-86-2026-09-23.md).
Human Rogue and Elven Scout each gained all five
separately purchased source Lockpicking ranks at
levels **20/24/28/32/36**. The real Dungeon runtime
registers server-owned physical room cache prompts
with authenticated party/session/class/rank, living
player, proximity and checkpoint gates, and
once-per-member-per-run personal inventory loot.
The targeted unpublished Studio suite passed **3/3**,
including **104** skill/loot and **1,176** strict source
inventory assertions. The actual one-client Dungeon
playtest passed genuine ProximityPrompt rank-one
and rank-two interactions, persistent replay
prevention, server checkpoint and spectator/distance
security. The test advanced room two via a
disposable server checkpoint operation; it did
not visually clear all five rooms. Six-inventory
original C4 coverage is now **389/396**: starting
classes **168/168**, Human Rogue **95/99**, Elven
Scout **126/129**. Seven remaining ranks are
Equipment Expertise, Lung Capacity and Fall
Resistance for each class plus Human Rogue
Sprint. **Seven additional original first-transfer
class inventories remain wholly unmapped and
0/9 first-transfer paths are completely finished.**
The one-Gathering-plus-one-Crafting rule, separate
humanoid/quadruped animation roadmap and no-publish
policy remain unchanged.

**Current C4 backend: v1.85 — tested Rogue/Scout ranked crafting.**
[Newest C4 backend roadmap](
DungeonMMO_Roadmap_v1_85_C4_Scout_Ranked_Crafting_20260923.md)
and [actual focused Studio and two-client test evidence](
../testing/c4-scout-ranked-crafting-v1-85-2026-09-23.md).
The original Human Rogue and Elven Scout each gained three
separately purchased crafting ranks at levels 20/28/36
behind actual Recipe Reading and **one selected crafting
profession per character**. Four creation careers now
have twelve genuine tiered material-consuming alternate
recipes with atomic server validation, profession XP
and cross-career marketplace dependencies. The unpublished
focused Studio run passed **5/5**, including **290**
new crafting and **1,150** strict source-inventory
assertions. A separate real **two-client Base gameplay**
test verified an actual Rogue smith crafting two bars,
the Elf Alchemist's forged Smithing request being denied,
genuine Smith-to-Alchemist market purchase, and the
Alchemist's real client crafting a rank-two recipe
consuming the traded bar. Current six-class original
C4 source coverage: **379/396**. Four starting classes
remain complete, Human Rogue **90/99**, Elven Scout
**121/129**; seven other original first-transfer
class inventories remain entirely unmapped and **0/9**
first-transfer paths are complete. Preserve the
separate humanoid/quadruped animation roadmap,
no-publish policy and one-Gathering/one-Crafting rule.

**Current C4 backend: v1.84 — real Scout Accuracy toggle.**
[Newest C4 backend roadmap](
DungeonMMO_Roadmap_v1_84_C4_Scout_Accuracy_20260923.md)
and [executed focused Studio / actual Dungeon client record](
../testing/c4-scout-accuracy-toggle-v1-84-2026-09-23.md).
Human Rogue and Elven Scout each gained a genuine, separately
purchased level-24 Accuracy stance: client-on/off, actual
three-stamina activation and three-stamina-per-second upkeep,
revocation on resource exhaustion/skill loss and +0.12
server-authoritative melee/bow hit probability against NPCs
with explicitly authored evasiveness. NPCs without the new
evasion attribute preserve previous physical hit behavior.
A real admitted Dungeon client activated/deactivated the
stance; deterministic server physical damage contexts
verified identical off/on/off misses and HP hits, actual
stamina upkeep and exhaustion. Focused Studio suites passed
**7/7**, including updated source audit. Current six-class
original C4 source mapping is **373/396**: four starting
classes 168/168, Human Rogue **87/99** and Elven Scout
**118/129**. The other seven original first-transfer class
catalogues remain unmapped, and **0/9** paths are fully
complete. Agreed one-Gathering/one-Crafting profession and
no-publish policies and separate humanoid/quadruped animation
roadmap remain unchanged.

**Current C4 backend: v1.83 — live Scout Critical Power toggle.**
[Newest C4 backend roadmap](
DungeonMMO_Roadmap_v1_83_C4_Scout_Critical_Power_20260923.md)
and [focused Studio plus real-client gameplay evidence](
../testing/c4-scout-critical-toggle-and-snare-v1-83-2026-09-23.md).
The previously pending genuine client-to-NPC Elven Snaring Shot
impact, damage, timed 35% slow and expiry were verified.
Human Rogue and Elven Scout each gained five actual original
C4 Critical Power toggle source ranks with learned/rank-gated
on/off, real stamina upkeep, non-free melee/bow critical damage
and automatic revocation on exhaustion/character restrictions.
The targeted unpublished Studio run passed **6/6**; actual
Dungeon client critical-toggle gameplay passed. Six currently
inventoried C4 classes stand at **371/396** real rank analogues,
with 13 Human Rogue and 12 Elven Scout source ranks missing;
seven other original first-transfer class catalogues remain
entirely unmapped and **0/9** paths are fully complete.
Existing one-Gathering/one-Crafting limits, no-publish policy,
independent humanoid/quadruped animation roadmap and separate
v1.78 Mystic hostile-weakening release gate remain unchanged.

**Current C4 backend: v1.82 — tested Elven Scout support.**
[Newest C4 backend roadmap](
DungeonMMO_Roadmap_v1_82_Elven_Scout_Support_20260923.md)
and [actual Studio / one-client Dungeon test record](
../testing/c4-elf-scout-v1-82-2026-09-23.md).
Four additional source ranks have real purchased analogues:
Elf Scout self-only Cure Wounds, physical-attack Battle Focus,
cast-only Wind Run and Ranger longbow Snaring Shot. The focused
unpublished Studio run passed 5/5 suites, and the real one-client
Dungeon test verified HP recovery, real melee/bow damage bonus,
actual WalkSpeed and expiry. Actual client-to-NPC Snaring Shot
impact is still pending. Current six-inventory source mapping:
**361/396**; Human Rogue **81/99**, Elven Scout **112/129**.
Seven other original first-transfer class inventories remain
unmapped, and **0/9** paths are fully complete. WoW-style
one-Gathering-plus-one-Crafting limits remain enforced. The
v1.78 Mystic weakening client combat test and the separate
humanoid animation roadmap remain open. No publish or main merge.

**Current C4 backend: v1.81 — verified first-tier Party Heal.**
[Latest C4 roadmap](
DungeonMMO_Roadmap_v1_81_C4_Party_Heal_20260923.md)
and [actual two-client Dungeon/Studio gameplay record](
../testing/c4-party-heal-v1-81-2026-09-23.md).
Human and Elven Mystics now have all three genuine
level-fourteen group-healing source ranks, authorized by the
actual server-owned Dungeon party roster. The focused Studio
source/healing suite passed 5/5, and the final unpublished
two-client Dungeon combat test verified effective HP recovery
for both players, healing-generated NPC threat, cooldown,
real 3D range and spectator/solo exclusion.
**All four Human/Elf starting-class source inventories are
168/168; six currently inventoried classes total 357/396.**
Thirty-nine partial Rogue/Scout source ranks and seven
additional entirely unmapped first-transfer catalogues remain;
0/9 original first-transfer paths are complete. The unrelated
v1.78 hostile-weakening live-combat acceptance and separate
humanoid-animation roadmap remain open. No `main` merge,
publishing or production DataStore mutation took place.

**Current C4 and professions backend: v1.80 — verified craft skills.**
[Latest backend roadmap](
DungeonMMO_Roadmap_v1_80_C4_Crafting_Playtest_20260923.md)
and [executed Studio + two-client gameplay evidence](
../testing/c4-exclusive-professions-v1-80-2026-09-23.md).
Purchased level-one C4 RecipeReading and level-five
CommonItemCreation now authorize actual blueprint study and
four material-backed recipes **only for the character's single
selected crafting profession**. The final unpublished Studio
focused run passed 12/12 cases and an independent actual two-client
Base playtest verified UI choices, client/server craft rejection
and live market delivery. Source inventory is now 351/396,
with six Mystic PartyHeal and 39 Rogue/Scout ranks outstanding
within the currently mapped six inventories; seven additional
original first-transfer catalogues remain unmapped and 0/9
paths are complete. The prior Mystic weakening in-combat
client check and the independent humanoid animation roadmap
remain open. No main merge or publishing took place.

**Current professions/economy backend: v1.79 exclusive careers.**
[Latest roadmap and acceptance gates](
DungeonMMO_Roadmap_v1_79_Exclusive_Professions_20260923.md).
One character may explicitly choose one Gathering and one Creation
profession, independently. Server authority now rejects unauthorized
gathering, skinning, recipe learning and crafting. Schema v14 retains
old profession XP but does not auto-select multiple careers. The
existing player market provides cross-career iron bars, alchemical
reagents and crafted gear; a new two-character focused trade test
is authored but **has not run in Studio**. Initial Base/Dungeon
Rojo builds and changed-file Luau parser checks passed. Six
previously unrestricted-profession fixtures have been rewritten for
selected careers, including real two- and four-character market
dependency chains. Focused Studio execution and broader regression
acceptance remain pending. C4 v1.78 skill acceptance and the separate humanoid
animation production roadmap remain open. No main merge, publish,
paid operations or production DataStore change.

**Current C4 backend implementation: v1.78 enemy weakening.**
[Backend roadmap](DungeonMMO_Roadmap_v1_78_C4_Enemy_Weakening_20260923.md).
Human/Elf first-tier Mystics now have authored level-14
hostile physical-attack weakening; Elf Mystics also gain
attack-rate impairment. The implementation is wired into
genuine NPC damage and future attack intervals. Base/Dungeon
Rojo builds passed, but the new focused Studio tests and
real-client combat acceptance are **still pending**.
The 340/396 tested ledger from v1.77 remains authoritative
until the three new candidate rank entries are executed
and audited. Seven original first-transfer inventories
remain unmapped and 0/9 original paths are complete.
The separate newest humanoid animation roadmap retains
all its visual gates. No publish or main merge.

# Canonical Roadmap

**Separate quadruped animation foundation (23 September 2026):**
[Canine master-rig inspection, engine and gameplay-motion acceptance](
DungeonMMO_Quadruped_Animation_Pipeline_20260923.md).
A source-controlled, rig-independent Walk/Trot paw-target and
two-segment IK mathematics helper, plus a read-only animal-rig
audit, now live under `tools/animation/quadruped/`. These
development tools are **not an animated wolf**: no canine master
rig has passed skinning/foot-contact review, no Studio playback
has been performed, and no game scripts or published assets
were changed. The next gate is an approved, standing and
properly skinned four-legged rig, not the welded dungeon
placeholder. Humanoid R15 approvals remain independent.


**Humanoid creature-animation production workflow (22 September 2026):**
[Authoring, Studio validation, and rollout roadmap](DungeonMMO_Humanoid_Animation_Pipeline_20260922.md).
Astra's isolated R15 guardian overhead strike and a separate
ChatGPT-authored horizontal sweep demonstrate distinct editable
KeyframeSequences, an Impact marker, real Studio playback,
foot/grip checks and neutral-pose reset. This is an **unpublished
proof of authoring**, not an approved production animation or
DungeonMMO combat integration. Next: a visually finished, correctly
skinned humanoid and user-approved normal-monster/mini-boss/boss
moves; separate rig-family proofs for wolves, birds and harpies.


**Current C4 backend increment: v1.77 poison and curing.**
[Backend roadmap](DungeonMMO_Roadmap_v1_77_C4_Poison_Cure_20260922.md)
and [unpublished Studio evidence](../testing/c4-poison-status-v1-77-2026-09-22.md).
Human Mystic gained an actual projectile-delivered three-tick
poison curse and both original Human/Elf Mystic sources gained
real friendly poison cleansing. The Elven Scout first-transfer
inventory gained self-only Poison Recovery. All three skills
passed authentic client hotbar-to-server effect tests.
Six inventoried classes have **340/396** functional analogue
rank entries, **56** missing, and all nine original first-transfer
paths remain incomplete; seven source skill inventories are still
unmapped. The latest separate humanoid animation authoring
roadmap above remains authoritative for art/rig/animation work.
No `main` merge, Roblox publish or production save change.


**Previous C4 backend increment: v1.76 conditional recovery.**
[Roadmap](DungeonMMO_Roadmap_v1_76_C4_Recovery_20260922.md)
and [focused source/test receipts](../testing/c4-conditional-recovery-v1-76-2026-09-22.md).
Six inventoried original Human/Elf basic and partial
first-transfer source classes now have **336/396**
functional rank analogues; **60** source ranks remain,
seven original first-transfer skill catalogues have
not been enumerated and **0/9** C4 first-transfer paths
are complete. Real server Stamina seated/running
recovery now uses purchased rank and actual Humanoid
conditions; the live seated Stamina regeneration test
passed. Strict `C4CatalogueCoverage.report().Completed`
is FALSE. No `main` merge, Roblox publish or PROD
DataStore changes.


**Previous tested C4 continuation: Battle Heal + Scout active statuses.**
[Current roadmap](DungeonMMO_Roadmap_v1_75_C4_Status_Heal_20260922.md)
and [source/test ledger](../testing/c4-source-catalogue-v1-75-2026-09-22.md).
**331/396** functional analogues across six currently enumerated
original Human/Elf base/partial-first-transfer source inventories,
**65** missing ranks, SEVEN unenumerated first-transfer class
catalogues, and **0/9** C4 first-transfer paths complete.
Focused status/progression tests and unpublished 18-effect
real client Play passed. The source-backed
`C4CatalogueCoverage.report().Completed` flag remains FALSE.
No `main` merge, publishing or live DataStore mutation.


**Previous C4 backend increment v1.75 — Scout evasion and first-tier
Mystic healing.** [Roadmap](DungeonMMO_Roadmap_v1_75_C4_Scout_Evasion_Mystic_20260922.md)
and [focused source/tests](../testing/c4-scout-evasion-base-healing-2026-09-22.md).
New genuine bought Scout direct-melee/running evasion,
three-rank Battle Heal and Human-only two-rank Life Drain
passed focused trainer/progression tests and actual
unpublished client combat effects. Six inventoried C4
source classes have 328/396 functional analogue ranks;
68 missing ranks PLUS seven separate first-transfer class
skill inventories still need implementation. All nine
source first-transfer paths remain incomplete.
The strict `C4CatalogueCoverage.report().Completed`
is FALSE. No publish, `main` merge or production
DataStore change occurred.


**Latest focused backend increment: v1.74 C4 base + first
transfer source coverage.** [Working roadmap](DungeonMMO_Roadmap_v1_74_C4_Base_First_Transfer_20260922.md)
and [audited test receipts](../testing/c4-base-first-transfer-coverage-2026-09-22.md).
The six enumerated Human/Elf base and partial Scout
source classes currently have 316/396 functional analogue
rank entries, with 80 missing. Only two of NINE original
first-transfer classes even have partial source skill
inventories; NONE is complete. New starting Mystic
worn-robe casting/mana/basic-attack passives and novice
level-limited damage protection are real backend effects.
Focused tests and Base/Dungeon TEMP builds passed;
`C4CatalogueCoverage.report().Completed == false`
correctly prevents a false full-catalogue claim.
No `main` merge, publish or production DataStore edits.


**Latest working C4 backend increment: v1.73.**
[Roadmap and exact completion gates](DungeonMMO_Roadmap_v1_73_Scout_Catalogue_20260922.md)
and [Studio test receipts](../testing/c4-scout-source-catalogue-2026-09-22.md).
C4 first-transfer Human Rogue 75/99, Elven Scout 102/129
source ranks now have DungeonMMO functional analogues.
Real Human critical power and Human/Elf critical rate,
shared level-28 Scout movement, Human level-36 attack speed,
both class/race trainer
gates and actual combat/client effects passed focused tests.
The remaining **24 Human + 27 Elf first-transfer ranks**,
earlier Fighter/Mage rank gaps and advanced-class trees
remain OPEN. This is **not a completed C4 catalogue**.
No `main` merge, Roblox publish or production DataStore change.


**Latest working backend increment: v1.72 Rogue
bleeding.** [Working roadmap](DungeonMMO_Roadmap_v1_72_Rogue_Bleed_20260922.md)
and [focused Studio receipt](../testing/c4-rogue-bleed-2026-09-22.md).
Two genuine level-24/32 bleed ranks now deliver
server-owned, non-stacking delayed NPC damage;
19 rank gates, 20 real isolated trainer purchases/
reload assertions and three actual real-client
bleed ticks with expiry passed. C4's equivalent
requires a dagger whereas our temporary Rogue
equipment is still a sword. Exact rank/equipment
parity and the overall C4 catalogue remain OPEN;
the separate Phase2A paid-revive auto-test failure
also remains unresolved. No `main` merge, Roblox
publish or production DataStore change.


**Latest working backend increment: v1.71 —
real Ranger/Rogue control progression.**
[Working roadmap v1.71](DungeonMMO_Roadmap_v1_71_Ranger_Rogue_Control_20260922.md)
and [focused acceptance](../testing/c4-ranger-rogue-control-skills-2026-09-22.md).
Briar Volley hits and slows two physical targets;
Disrupting Cut actually staggers. Both have three
5/10/15 level-gated ranks, 40/110 earned mastery
requirements and class/trainer/weapon authority.
Unpublished live-client effect, 41 focused content,
46 production service purchase/persistence and 45
corrected Rogue trainer assertions passed. The C4
source-volume manifest is still incomplete, real
saved-character trainer GUI remains untested, and
the separate Phase2A auto-test failure remains open.
Do not merge to `main` or publish merely because
this focused backend slice passed.


**C4 client-effects focus (22 September 2026):**
[Focused Studio Play acceptance](../testing/c4-new-skill-live-client-2026-09-22.md)
verifies Dawn Ward, Cinder Bolt, Archer Draw and Vital Blow
through a real client hotbar and server combat effects.
Temporary profiles/snapshots were used, so real trainer
UI and saved-profile interactions are still pending. Two
unrelated automatic Dungeon-test failures are not accepted.
C4 quantitative skill-rank gaps remain open. Continue
GitHub-first backend work without repeating old dungeon
wipe/aggro/revive/play-again tests.


**Latest v1.70 — all four current class families now have
C4-inspired level, skill-rank and earned-proficiency gates.**
[Roadmap v1.70](DungeonMMO_Roadmap_v1_70_All_Four_C4_Class_Families_20260922.md)
and [focused acceptance](../testing/c4-all-four-class-families-2026-09-22.md).
Fighter, Mage, Ranger and Rogue gained new actual
role-appropriate combat/mastery content. Every current
race-specific advanced class has progression-gated
trainer skills; Mage gained two advanced skills and
Rogue specialist skills require genuine prior mastery.
The 74-assertion four-family contract passed, and
Base/Dungeon Rojo builds passed after the main changes.
The final metadata-only Rogue mastery change passed
the same focused contract and Base build at `687e27c`.
**Do not claim exact C4 completeness:** 13/16 measured
Fighter/Mage source rank brackets still mismatch; Ranger/
Rogue rank-volume reference mapping and real-client new
skill impacts remain pending. No old dungeon recovery
matrix was rerun.


**Latest v1.69 — two real early Mage skills and honest unlock UI.**
[Roadmap v1.69](DungeonMMO_Roadmap_v1_69_Mage_Starter_Unlock_Visibility_20260922.md)
and [focused evidence](../testing/c4-mage-starter-ward-bolt-trainer-2026-09-22.md).
Dawn Ward and Cinder Bolt now offer server-owned rank 1/2/3 at
levels 1/7/14 and require mastery 35/100 for upgrades. The
player's actual skill menu hides abilities absent from their
authoritative unlocked snapshot; the trainer disables higher
ranks and explains level/mastery requirements. One Base build,
39 focused assertions and one read-only rank count audit ran.
**13/16 mapped C4 level brackets still mismatch**; do not
claim full rank parity or completed in-client visual verification.


**Latest v1.68 — two more C4-style rank families with real HP/heal effects.**
[Roadmap v1.68](DungeonMMO_Roadmap_v1_68_Vitality_Restoration_Ranks_20260922.md)
and [focused test report](../testing/c4-vitality-restoration-rank-effects-2026-09-22.md).
Fighter Stalwart Training and Mage Restorative Training each
have six SP/level-gated passive ranks with live authoritative
max-HP or heal-multiplier effects. A Base build and
64 new + 64 affected existing passive assertions passed
at `3be5de3`. The C4 count audit still shows 13/16
mapped brackets mismatched, including a Human Fighter
level-10 **overcount**. No numerical C4 parity or
normal-client combat-balance claim; do not rerun the old
dungeon wipe/aggro/revive matrix for these passives.


**Latest v1.67 — C4-style class passives with actual damage effects.**
[Roadmap](DungeonMMO_Roadmap_v1_67_C4_Passive_Ranks_20260922.md)
and [focused acceptance](../testing/c4-passive-rank-effects-2026-09-22.md).
Six rank- and level-gated Fighter Iron Discipline and
Mage Arcane Discipline passives now modify authoritative
physical/magical damage multipliers, respectively.
One Base build and 64 focused assertions passed at
`08710c1`. The source-mapped audit still reports
16/16 C4 brackets short; do not claim parity. Next
work is genuine early skill/utility/crafting content,
not a repeat of old dungeon recovery tests.


**Latest active C4 skill-volume increment: v1.66.**
[Updated content roadmap](DungeonMMO_Roadmap_v1_66_C4_Early_Rank_Content_20260922.md)
and [focused acceptance](../testing/c4-early-fighter-mage-skill-ranks-2026-09-22.md).
Two Fighter nine-rank combat families at level 5/10/15,
one Mage six-rank heal at level 7/14, and per-skill
mastery/profile migration were implemented and locally
focused-tested. C4's mapped reference-volume requirement
is **NOT complete: 16/16 verified brackets remain short**.
Next: real passive/utility/craft families and remaining
mapped rank offerings, not another dungeon recovery suite.


**Latest active requirement (v1.65): Chronicle 4 skill-RANK
volume per corresponding class and level, not just a few
additional active skills.**
[Skill-volume roadmap](DungeonMMO_Roadmap_v1_65_C4_Skill_Volume_20260922.md)
and [source-backed parity specification](
../design/C4_Skill_Count_Parity_20260922.md).
The first 16 verified Human/Elf Fighter/Mystic early-level
brackets all show real authored-rank gaps, so C4 skill-volume
parity is **NOT COMPLETE**. Fighter-style new basic rank
milestones now begin 5/10/15 and Mystic-style 7/14/20,
with focused level/mastery acceptance. Expand real,
reachable active/passive/utility families and rank
schedules; never pad quotas with inert catalogue entries.


**Latest active work: v1.64 — earned skill mastery, level-bracket training
and prerequisite-gated class advancement.**
[Roadmap v1.64](DungeonMMO_Roadmap_v1_64_Skill_Mastery_Level_Gates_20260922.md)
and [focused local evidence](../testing/dungeon-skill-mastery-lineage-style-2026-09-22.md).
New basic abilities at levels 8/14/20, level-20 trials requiring
two fully mastered class skills, level-24/28/32 specialist skill
ranks and an extended level-40 cap now have local focused
tests. The taunt-proficiency integration was corrected and
tested separately. This is a *first connected progression
ladder*, not a complete Lineage II C4 skill catalogue.
Do not rerun old dungeon wipe/aggro/revive regressions
for isolated skill-data edits.


**Latest v1.63: race-specific advanced classes and playable-skill
foundations (Lineage II / WoW-inspired structure, original content).**
[Roadmap v1.63](DungeonMMO_Roadmap_v1_63_Class_Progression_Role_Skills_20260922.md)
and [focused skill/class acceptance](../testing/dungeon-class-progression-expansion-2026-09-22.md).
Four new Fighter/Ranger advancement paths, level-gated
trials, four specialist active abilities and trainers
were added. Server skill use requires the persisted
active advanced class. One Base and one Dungeon build;
66 class, 40 quest and 60 advanced ability assertions
passed (skills tested in the Dungeon composition at
`b017fbc`). A full real-client combat impact and
the quest/trainer UI remain next **new feature** work;
no repeated dungeon wipe/aggro/revive matrix was run.


**Latest v1.62 — new story quest backend content, NOT another
dungeon recovery-test cycle.**
[Roadmap v1.62](DungeonMMO_Roadmap_v1_62_Story_Quest_Backend_20260922.md)
and [focused acceptance](../testing/story-quest-backend-slice-2026-09-22.md).
Two one-time cross-class Temple → Mine story quests, one bound
relic and server-authoritative atomic Gold/item claims were
implemented with Base quest remotes. One Base build and 40
QuestService assertions passed at `89d8e7e`; there was no
full Dungeon regression. A visible quest board and targeted
real-client remote interaction are **still pending**.


**Consolidated active backend backlog (22 September 2026):**
[Gap audit and stop-retesting plan](DungeonMMO_Consolidated_Backend_Audit_20260922.md).
This is the practical NEXT-WORK list across dungeon, progression,
professions, world boss/raid, guild/PvP, quests/economy and
release gates. It does not overwrite historical canonical
`DungeonMMO_Roadmap_v1_47.docx` or reclassify older local
passes as published acceptance. Finish only the missing
ordinary-combat dungeon integration, then move to new
progression/content systems; do not repeat all accepted
wipe/aggro/revive fixtures after unrelated edits.


**Latest v1.61: all-member higher-difficulty unlock,
spectator combat exclusion and party Play again.**
[Roadmap](DungeonMMO_Roadmap_v1_61_Party_Unlock_Spectator_Replay_20260922.md)
and [unpublished Studio acceptance](../testing/dungeon-party-unlock-spectator-replay-2026-09-22.md).
Every member must independently unlock the selected dungeon
depth; Base, new-run transport and replay enforce it.
Six builds, 23 coordinator checks, 28 replay checks,
Dungeon backend 30/30, real two-client spectator and replay
fixtures passed at `c6925c0`. Base UI now identifies
the locked member; all six builds and the focused Base
party regression passed at `b6fe3be`. A real same-account
published reserved-server reconnect is still outstanding.


**v1.60 same-server reconnect is now locally verified.**
[Updated v1.60 roadmap](DungeonMMO_Roadmap_v1_60_Same_Server_Reconnect_20260922.md)
and [same-head Studio acceptance](../testing/dungeon-same-server-reconnect-local-acceptance-2026-09-22.md).
At gameplay source `87a19ba`, all six Rojo builds, the
30-assertion simulated same-user reconnect contract, Dungeon
backend 30/30, death/revive 46, focused threat 51, Base
professions 14/14, actual-client failed-run UI and real
four-client Room1 recovery passed. A real Roblox same-account
network return to the original published reserved server
remains unverified. No place publish or main merge.


**v1.60 same-server reconnect is staged in GitHub, not yet
locally tested.** [Roadmap](DungeonMMO_Roadmap_v1_60_Same_Server_Reconnect_20260922.md)
and [pending acceptance report](../testing/dungeon-same-server-reconnect-stage-2026-09-22.md).
Remote Desktop reported no online device, so no Rojo
build or Studio regression was run for the new source
head. The accepted v1.59 physical multiplayer tests
belong to earlier gameplay code. Initial handoff still
requires a nonce; returning members require an
already-bound server, persisted disconnect and a
separate profile writer lease. Published same-account
network reconnect and routing remain unverified.


**Latest GitHub roadmap supplement: v1.59 — physical
four-player SecretArena boss, Depth4 mini-boss and live
boss peer-disconnect recovery.** See
[v1.59](DungeonMMO_Roadmap_v1_59_Secret_Depth4_Disconnect_20260921.md)
and [local acceptance evidence](../testing/dungeon-secret-depth4-disconnect-recovery-2026-09-21.md).
All three unpublished Studio multiplayer fixtures passed.
The higher-depth terminal wipe service regression passed
392 assertions. Same-account published rejoin, full normal
combat/boss rewards and reserved-server replay remain
outstanding. No `main` merge or place publish.


**Latest GitHub progress: v1.58 — real four-client Room1,
Room3 boss and optional EventArena wipe/re-entry; replay
party voting verified (21 September 2026).**
[Roadmap v1.58](DungeonMMO_Roadmap_v1_58_Four_Party_Boss_Replay_20260921.md)
and [local evidence](../testing/dungeon-four-client-room-boss-event-replay-2026-09-21.md).
A physical partial-kill wipe did not duplicate any
of four players' monster rewards. A repeated Failed
state broadcast was fixed so party replay votes remain
visible. Secret/higher-depth bosses, actual published
cross-place replay and cloud persistence remain pending.
No place publish or `main` merge.


**Latest GitHub roadmap supplement: v1.57 — physical Room1
wipe/re-entry and Play again.** Read
[v1.57](DungeonMMO_Roadmap_v1_57_Room_Reset_Play_Again_20260921.md)
and [local proof](../testing/dungeon-room-reset-play-again-2026-09-21.md).
The unpublished one-client physical Room1 test verified old
enemy retirement and newly spawned full-health enemies after a
genuine player death and checkpoint revive. Both terminal
end-screen replay buttons passed real-client UI Play; replay
party-consent contract passed 17 assertions. Published
reserved-server Play again and multi-client boss-room recovery
remain pending. No place published or main merged.


**Latest GitHub roadmap supplement: v1.56 (terminal dungeon wipe,
Base return and fresh-run retry, 21 September 2026).**
Read [the v1.56 backend roadmap](DungeonMMO_Roadmap_v1_56_Terminal_Wipe_Base_Retry_20260921.md)
and [local test evidence](../testing/dungeon-terminal-wipe-return-fresh-run-2026-09-21.md).
Failed dungeon sessions remain terminal, their connected members can
return to Base, and the existing Base entry creates a fresh session
rather than reopening the failed run. Legitimate paid revives follow
the actual committed purchase ordering; repeated and late callbacks
cannot respawn a failed run. Six Rojo builds, Dungeon backend
30/30, integrated paid-retry service and real failed-run UI Play
passed. **In-place room/encounter health/spawn reset and complete
party checkpoint retry are not yet implemented**. No Roblox
publish or main merge occurred.


**Latest GitHub roadmap progress supplement: v1.55 (real
four-client combat, world-boss support and threat-only full-wipe
cleanup, 21 September 2026).**
Read [v1.55 combat and wipe progress](DungeonMMO_Roadmap_v1_55_Combat_Threat_Wipe_20260921.md)
and [the real multiplayer test receipt](../testing/four-player-full-wipe-threat-reset-2026-09-21.md).
All six local Rojo compositions, 51 focused threat assertions,
30/30 Dungeon backend and 14/14 Base profession regressions
passed at `739e747`. Real four-client, two-enemy gameplay proved
actual player departure and all-dead threat cleanup; genuine
world-boss aggro and support passed on the **correct isolated
world-boss composition**. This is threat-only cleanup, not enemy
health/spawn or full session restart. No main merge, place
publish or production DataStore change was made.


**Earlier roadmap supplement: v1.53 (Leatherworking / Enchanting staged, 21 September 2026).**
Read [the v1.53 pending-verification roadmap](DungeonMMO_Roadmap_v1_53_Professions_Pending_Verification.md)
and [the staged verification plan](../testing/profession-leatherworking-enchanting-pending-verification-2026-09-21.md).
GitHub now contains Skinning, Leatherworking and Enchanting progression,
items, recipes, placeholder Base acquisition/stations, a multi-profession
equipment chain, migration/contract/dependency tests and a per-player
server craft-request guard. **These v1.53 changes are not locally accepted
yet** because the authorized Windows desktop is offline. No new Studio
PASS counts, Rojo build results or cloud release are claimed. The accepted
v1.52 results remain the latest verified checkpoint. No Remote Desktop,
local pull, TEST/PROD publish, real player DataStore mutation, force-push
or main merge occurred for v1.53 staging.

**Earlier roadmap supplement: v1.52 (non-boss Event variations and cross-profession backend, 20 September 2026).**
Read [the v1.52 backend roadmap](DungeonMMO_Roadmap_v1_52_Event_Variations_And_Professions.md)
and [the dated local Studio test report](../testing/phase4-nonboss-event-profession-chain-2026-09-20.md).
The existing, separately gated after-Room2 Event room can now host
an opted-in four-enemy Ambush or eight-enemy Surge in Temple/Mine:
one server-frozen pack, not an additional boss, second scheduler,
staggered wave or cave-in. Both variations passed assisted physical
walking and two-/four-client mid-Event disconnect/replay-proof
completion tests. New deterministic matrix: 144 assertions;
25/25 focused optional suites, 30/30 broad backend suites,
four local Rojo builds, original optional-enabled and
optional-disabled Temple Depth2 physical regressions PASS.

**Next major backend work has begun:** the existing Blacksmithing
and Alchemy services now have a bidirectional material chain,
`iron_bar` → Alchemy `forging_flux` → Blacksmithing
`runic_ironbound_gloves`. New items and recipes use the
existing atomic crafting/inventory/profile pipeline.
46 new cross-profession assertions and 7/7 profession
regressions passed in both local Base and Dungeon builds.
Leatherworking, Enchanting, real station/minigame authority
and larger raid/guild backend work are not yet complete.
All new Event release/placeholder flags remain OFF by default;
this checkpoint did not publish Roblox places, change real
player DataStores, create finished art or overwrite the
historical canonical v1.47 Word roadmap. v1.48–v1.51 remain
historical supplements.

**Latest ChatGPT-authored roadmap update: v1.51 (late Event physical and multiplayer acceptance, 20 September 2026).**
Read [the v1.51 late Event acceptance roadmap](DungeonMMO_Roadmap_v1_51_Late_Event_Physical_Acceptance.md)
and [its verified physical/multiplayer test report](../testing/phase4-late-event-physical-multiplayer-2026-09-20.md).
The after-Room2 Event now has its own **replaceable, walkable,
independently gated TEMP Studio side room** in Temple and Mine
at Depth2–4, with dedicated trigger, checkpoint and boss spawn.
The old after-Room1 Event/Secret routes are preserved. Room2
must be cleared before the late gate opens; unselected Event
gates remain closed. Local tests: 85 physical/gate assertions;
24/24 optional-focused and 30/30 broader backend suites; four
Rojo builds; assisted Temple Depth2/Mine Depth4 late-Event walking
playtests; two-client Temple and four-client Mine actual Studio
disconnect/recovery and replay-proof party completion tests;
original optional-enabled and optional-disabled Temple Depth2
routes all PASS. The new after-Room2 path is **not published**:
its server/workspace opt-ins and higher-depth release flags
remain OFF in source. No real player DataStore, authored art
or canonical v1.47 Word roadmap was modified. Earlier v1.48,
v1.49 and v1.50 updates remain available as historical
checkpoints; v1.51 supersedes v1.50's now-outdated statement
that the late route has no physical placeholder.

**Latest ChatGPT-authored roadmap update: v1.50 (configurable optional Event placement, 20 September 2026).**
Read [the v1.50 optional Event placement roadmap](DungeonMMO_Roadmap_v1_50_Optional_Event_Placement.md)
and [its verified local test report](../testing/phase4-optional-event-placement-templates-2026-09-20.md).
The accepted after-Room1 Event and before-Final Secret routes remain
the defaults. An independent server-only, default-OFF opt-in now
issues a run-frozen `EventAfterRoom2` template at Depth2–4, with its
own `EventArenaLate` slot/encounter identity, per-run Event/Secret
frequency caps, room-slot conflict rejection and fail-closed physical
readiness. **The late room and its bridge/gate are not yet registered
or physically playable.** The new backend template is not a published
event, a cave-in effect or an additional mob-pack mechanic.
Local tests: 274 template assertions, 23/23 optional-focused suites,
30/30 broader gameplay backend suites, four Rojo builds, original
Temple Depth2 assisted physical route and previous alternate-boss
Temple Depth2 assisted physical route with reward replay all PASS.
Release switches remain OFF, and no cloud place or player DataStore
was modified. The historical v1.47 Word roadmap and v1.48/v1.49
supplements remain intact.

**Latest ChatGPT-authored roadmap update: v1.49 (dynamic optional boss variants, 20 September 2026).**
Read [the v1.49 dynamic optional boss roadmap update](DungeonMMO_Roadmap_v1_49_Phase4_Dynamic_Optional_Variants.md)
and its [verified multiplayer/physical test report](../testing/phase4-dynamic-optional-boss-variants-2026-09-20.md).
Two server-issued Event/Secret variants per Temple/Mine dungeon are
now supported behind a new independent server-only opt-in, using
already implemented boss factories as placeholders. Their identities
are frozen per run; the previous two hard-coded Secret identities
were generalized in the existing discovery service, and reused
optional/miniboss factories now earn separate encounter-scoped rewards.
A 2,205-assertion variant matrix, 232 discovery assertions, 80 distinct
reward assertions, 22/22 focused suites, 30/30 broader backend suites,
two assisted alternate-boss physical routes, one variant-disabled
baseline and a 4-client Mine Depth4 alternate party run all passed
locally. No TEST/PROD publish, DataStore change, authored art,
released depth or historical canonical DOCX modification occurred.

**20 September higher-depth multiplayer lifecycle checkpoint (after v1.48):**
Two- and four-client local Temple/Mine Depth2/4 runs passed shared
frozen optional-boss plans, one boss for concurrent Event/Secret
trigger entry, actual member disconnect during either boss, survival
of the other 1/3 players and dungeon completion. Strict Temple
Depth2 2→1 and Mine Depth4 4→3 reruns verified persisted per-member
completion and exactly-once reward replay. Disposable earlier-depth
profile clears were required by the existing progression service;
the real save barrier was not weakened. New service-level 1/2/4-member
party-wipe/auto-revive tests: 392 assertions; 19/19 optional-focused,
30/30 broad backend suites and four local Rojo builds PASS. These
tests do **not** prove real same-account network rejoin, new reserved
server recreation or unassisted party combat. Existing Depth2–4 and
optional release locks remain OFF. Full dated evidence:
`docs/testing/phase4-higher-depth-multiplayer-lifecycle-2026-09-20.md`.
The ChatGPT-authored v1.48 roadmap supplement records the new status;
historical canonical v1.47 DOCX is preserved.

**Historical v1.48 Phase 4 backend supplement (20 September 2026).**
Read [the v1.48 Phase 4 backend roadmap update](DungeonMMO_Roadmap_v1_48_Phase4_Backend_Update.md)
for completed higher-depth optional physical playtesting, precise
local-vs-cloud acceptance boundaries, and the former next milestone, multiplayer lifecycle at Depth 2–4,
which is now accepted locally as recorded above. This is a *versioned supplement*,
not a replacement for the retained historical long-form
`DungeonMMO_Roadmap_v1_47.docx`. The v1.48 supplement was authored in ChatGPT and the historical
long-form Word roadmap remains preserved.

**Current engineering checkpoint:** Integration branch
`wip/phase-4-test-hud-integration-v1`; pre-roadmap-update accepted
physical-playtest commit `cfb35d0c98c8701ec34388be8dad4ce72a57e3f9`.
The v1.48 update does not imply a merge to main, production release,
Roblox publish or real user DataStore mutation.

**20 September Depth2–4 optional physical checkpoint (after v1.47):**
GitHub-first edits added separate, opt-in TEMP Event/Secret side rooms,
bridges, physical gates and unique anchors to Temple and Mine Depth2,
Depth3 and Depth4. All six independent local Studio Play-mode routes
passed actual walking traversal into/out of both optional rooms,
server encounter activation/spawn identity and final dungeon
completion with assisted combat (6/7/8 encounters by difficulty).
A seventh Mine Depth4 run physically skipped Secret, returned to
clear it and then defeated Final, using a TEMP-only final-spawn hold.
New structural test: 139 assertions; optional focused suites 18/18;
broad backend matrix 30/30. The original optional-disabled Temple
Depth2 four-room route passed and all four local Rojo compositions
built. High-depth release flags, authored models, Roblox cloud places,
user DataStores and the canonical DOCX remain untouched. Evidence:
`docs/testing/phase4-depth2-4-optional-physical-playtest-2026-09-20.md`.

**20 September depth-specific optional event backend checkpoint
(after v1.47):** Existing Temple/Mine Event/Secret encounter definitions
were validated across Depth1–4 and all independent eligibility
combinations, including expired global event windows preserving a
previously eligible saved run. Two issues were reproduced RED and fixed:
Secret side gates now use the preceding required room from the frozen
plan (rather than opening at Room2 for all depths), and Mine placeholder
side entrances are now synchronized by the existing server gate
controller. Local Studio: 712/116/32 assertions in new depth, timed-event
and gate suites; 17/17 optional suites; 30/30 broader backend suites;
assisted Temple and Mine Depth1 physical optional routes PASS. All four
local Rojo compositions built. Depth2–4 optional physical side arenas
and bridge routes are **not** registered or playable from this change,
and high-depth release flags remain OFF. No TEST/PROD cloud, player
DataStore, authored art or canonical DOCX modification. Evidence:
`docs/testing/phase4-optional-depth-events-and-side-gates-2026-09-20.md`.

**20 September four-depth integration checkpoint (after v1.47):**
Both Temple and Abandoned Mine Depth1–4 ladders passed a new
454-assertion profile/session/encounter integration test, including
3/4/5/6 required rooms, Depth4 returning miniboss identities,
ordered unlocks, interrupted miniboss checkpoints, and actual
CompletionService one-time rewards. Five focused Studio suites,
30/30 broad backend suites, four local Rojo builds, Base Play mode,
and a fresh assisted Temple Depth2 physical route passed. The
previous six separate Temple/Mine Depth2–4 physical tests retain
their dated evidence; an attempted all-six-in-one Studio runner
stopped after its first case and was removed. Higher-depth release
locks remain unchanged, with injected readiness used only inside
test storage. No production-code, authored model, Roblox cloud,
DataStore, main branch or canonical DOCX change. See
`docs/testing/phase4-depth1-4-progression-integration-2026-09-20.md`.

**20 September full session-recovery checkpoint (after v1.47):**
The existing session/encounter backend has passed a new 42-assertion
persisted two-member recovery regression and all 15 local optional
focused suites. A fresh assisted physical Temple Secret backtracking
fixture also passed. The test constructs new session, controller and
reward services over a shared in-memory store; it is not a genuine
same-account Roblox reconnect or cloud server restart. No production
gameplay, model, DataStore, TEST/PROD place or original roadmap DOCX
was changed. The user separately confirms a successful manual solo
optional-boss playtest. See
`docs/testing/phase4-optional-full-session-recovery-2026-09-20.md`.

**20 September consecutive optional-combat follow-up (after v1.47):**
Two local two-client Temple tests passed ordinary-health Event -> Secret
combat with regular client attack requests. In the second run the server
confirmed Dodge and a slotted healing skill, restoring ~32 party HP
before Secret; final-room progression passed with test assistance.
This does not supersede the failed injured-solo attempt, and
required-room/final-boss manual combat, true rejoin and cloud
verification remain open. See
`docs/testing/phase4-optional-boss-consecutive-skill-defense-2026-09-20.md`.

**20 September normal-combat follow-up (after v1.47):** Local
GitHub-first normal-combat fixtures independently defeated Temple
Event and Secret bosses with real client attacks and normal player HP.
The consecutive attempt FAILED: the solo survivor entered Secret
injured after Event and died before defeating Secret. In a separate
healthy two-client run, Secret was defeated and the final route
completed (other rooms assisted). Both isolated boss wins are accepted
as local evidence; combined unassisted gameplay, legitimate recovery,
manual navigation and true same-account rejoin are not accepted.
See `docs/testing/phase4-optional-boss-normal-combat-playtest-2026-09-20.md`.
Cloud verification and art remain deferred.

The canonical long-form roadmap stored here is:

`DungeonMMO_Roadmap_v1_47.docx`

Version: **1.47**
Last updated: **20 September 2026**

SHA-256:

`f5ebe50872510067a671a67d7844d521adc512e6683322b8a99f37c811d13abf`

**Current phase: Phase 4 Content Alpha remains ACTIVE.** Phases 2 and 3 remain accepted. The 19 September Event/Secret backend milestone is complete historically and is not a reason to repeat the closed backend work.

**20 September local backend follow-up (after v1.47):** Normal/Event start
and optional Secret-skip persistence failures now roll back in-memory
progression so players can retry without bypassing a required encounter.
Focused Studio tests, all five local Rojo compositions, assisted Temple
placeholder backtracking, normal Dungeon Play mode, and a two-client
session-disconnect fixture passed. The local two-client optional-boss fight has since passed: one Event
boss despite simultaneous entry, a real mid-Event disconnect with the
other player continuing, isolated interrupted-boss state recovery,
Event reward replay protection and Secret/final boss completion.
Same-account network rejoin is still unproven. Evidence:
`docs/testing/phase4-optional-boss-two-client-playtest-2026-09-20.md`
and `docs/testing/phase4-optional-boss-lifecycle-hardening-2026-09-20.md`.
This is a working engineering update, not a new canonical DOCX version
or cloud release. Finished models and cloud verification remain deferred.

**20 September TEST evidence and scope:** The published TEST Lobby race/class flow worked after repairing seven semantic environment anchors and restoring the TEST profile DataStore, and the player entered/cleared normal TEST Temple rooms. One observed Secret objective stated that the secret route was not unlocked for that run; the visible branches are **EventArena after Room 1** and **SecretArena after Room 2**, not two guaranteed Secret rooms. A distinct Base-origin eligibility source correction was made; it must be verified on a *new cloud session*, not assumed to change old persisted runs.

On the combined integration branch `wip/phase-4-test-hud-integration-v1`, source `52222db` supports eligible Secret backtracking before dungeon completion; `f6d6401` adds **server-controlled placeholder side-entry gates** so Event opens after Room 1 and Secret after Room 2 only when that run is eligible. Local physical/regression and TEST-style composition tests passed. Final authored room art, normal-player unassisted optional boss fights and real multiplayer/recovery acceptance remain open.

**TEST Temple publish status is UNVERIFIED:** The latest gated-placeholder Publish As attempt on 20 September targeted the existing TEST Dungeon place `117293035754309` but Roblox Scripts publishing/version-history calls returned HTTP 429 rate limits. A publish timing marker and local tests do not prove that this newest gate/script version is playable in Roblox. Before any repeat publish, inspect the current TEST Temple Version History and join a genuinely fresh TEST Dungeon server; avoid rapid retries, preserve a current cloud rollback, and never overwrite the authored Lobby `134132328219009`, PROD or player DataStores.

Detailed evidence: `docs/testing/phase4-test-temple-optional-entrance-gates-2026-09-20.md`, `docs/testing/phase4-deferred-secret-backtracking-2026-09-20.md` and `docs/testing/phase4-test-lobby-optional-boss-origin-fix-2026-09-20.md`. Historical 19 September release-lock and unpublished-status entries below describe their **dated source checkpoints**, not the current TEST-only integration or uncertain 20 September publish attempt. The definitive updated status, next actions and restart brief are in v1.47 Sections 10 and Appendix J.

Historical note: Roadmap v1.45 added the four-step Event/Secret Boss **isolated backend**
checkpoint: recovery and reward replay, Mine live integration, four distinct
server-owned two-phase boss attack patterns, and fresh Base/Dungeon Studio
regressions. Gameplay source was validated at `3700dba`; the final regular
Base/Dungeon and static validation ran at `c86a904`.

See `docs/testing/phase4-optional-boss-four-backend-steps-closeout-2026-09-19.md`
for the exact source/log evidence and outstanding network-reconnect, authored
physical-arena, unassisted combat, and multiplayer release gates. Optional boss
rollout remains disabled in both dungeons; **no merge to main or game publish**
is implied by this roadmap update. The v1.45 DOCX passed zip/structure checks;
a visual PDF/page-render review is still pending after the Word export stalled.

Version 1.43 formally closes **Phase 3 - Systems Alpha** and opens
**Phase 4 - Content Alpha**.

The accepted Phase 3 gameplay release checkpoint is:

`84662948127eb1a37c9f184c6abbafe6f2daddb6`

That checkpoint was pushed to the Phase 3 feature branch and to `main`, then
verified against the GitHub server `main` ref before the documentation
closeout.

Published TEST environment:

- Universe: `10765241947`
- Starting Base: `134132328219009`
- Dungeon: `117293035754309`

The Dungeon and Starting Base both reached Roblox Studio
`PublishSuccessful` during the Phase 3 release. No PROD publish or Robux
action occurred.

Phase 3 accepts the Quest/Secondary-Class Advancement foundation,
Damage/Tank/Support Contribution, Blueprint/Recipe Knowledge,
Bestiary/Reputation, Rogue fourth-archetype breadth, deterministic Dungeon
modifiers, Guild/Hall, limited Market, DEV/TEST Race Change migration and the
economy/audit/stress hardening boundary. Progression catch-up and Transmog are
explicitly deferred.

Roadmap v1.43 opened Phase 4 with Starting Base presentation as the first
default gate. On 18 September 2026 the project owner explicitly parked modelling
and presentation work and moved Phase 4 through backend-only Dungeon gates.

The **Progressive Dungeon Depth + Difficulty** foundation is locally green at
`1230e6c`: schema v13 progression, 3/4/5/6 logical depths, authoritative
solo/party/session routing, fail-closed higher depths, combat/reward scaling and
completion unlock integration all passed the local acceptance matrix.

The follow-on **Generic Dungeon Encounter Runtime** is locally green at
`5ba9f4d`. The live Depth1 runtime now uses generic sequencer authority with
stable encounter checkpoints and reconnect state. The backend supports
Combat/MiniBoss/Boss/FinalBoss plus future EventBoss/SecretBoss insertion from
server-owned conditions. Unbound optional content fails closed, no Event/Secret
boss content is enabled, and Depth2-Depth4 remain fail closed.

The next **Encounter Execution / Spawn Registry** gate is locally green at
`fe1856e`. Encounter descriptors now select stable CombatPack/Boss executors;
combat packs resolve through server-owned catalogue data; boss-family content
resolves through stable BossId -> factory registration; live DungeonRuntime no
longer chooses concrete Marauder/Captain/Foreman factories. Transactional
startup cleans partial spawns and returns the generic sequence to Pending on
failure. Boss duplicate claims are scoped by session + encounter ID, which
supports multiple miniboss/boss/event/secret encounters in a single future run.
Temple and forced Abandoned Mine live execution proofs passed. Depth2-Depth4
remain fail closed, and no Event/Secret boss content is enabled.

The follow-on **Multi-Depth Physical Room-Binding Runtime** is locally green at
`1aa81b5`. Physical room-slot metadata, triggers, spawn anchors, barriers and
checkpoints are now resolved generically from layout data; live progression no
longer branches on fixed Room1/Room2/Boss cases. Real Temple compatibility and
forced Abandoned Mine + event/rare compatibility each passed 23/23 assertions.
Both current dungeons explicitly reject unimplemented Depth2-Depth4 physical
layouts, so higher depths remain fail closed while the runtime is ready for
future authored room sets and later Event/Secret boss bindings.

The follow-on **Dungeon Runtime Content Readiness Registry** is locally green at
`2e2420b`. Static layout/pack/boss/executor/factory registrations now live in
one shared catalogue usable by both Base and Dungeon. The old `RuntimeReady`
boolean is removed: `RuntimeReleaseEnabled` is only a rollout switch, while
`DungeonRuntimeContentReadiness` computes content completeness and final
readiness. Base progression entry and TeleportCoordinator use the computed
result, so incomplete content is rejected before server reservation. Current
Depth1 is complete+enabled+ready; Depth2-Depth4 remain
incomplete+release-disabled+not-ready with explicit diagnostics.

The follow-on **Generic Enemy Archetype + Heterogeneous Combat Pack Registry**
is locally green at `464bd44`. CombatPack execution is no longer
Marauder-specific: ordered pack entries resolve stable enemy archetypes and
server-owned factory IDs, while Deep Echoes / Crystal Bloom bonuses target
explicit entries. Current Temple/Mine Depth1 counts and naming remain
compatible. A synthetic 2-Marauder + 1-Elite pack proves mixed-factory
execution and rollback without enabling Elite as production content.

The follow-on **Authoritative Runtime Layout Selection + Environment
Activation** gate is locally green at `ccd289b`. Runtime startup now preserves
the selected DifficultyId and resolves its LayoutId before environment setup.
Encounter triggers and exit barriers are activated from registered layout data,
not hard-coded Temple/Mine arrays. A synthetic four-slot layout proves arbitrary
slot-count activation while current Depth1 boot/admission remains compatible.

The follow-on **Binding-Owned Spawn Groups + Exit Barriers** gate is locally
green at `cfbf2ea`. Combat-capable physical bindings now carry their own
enemy-spawn groups, while exit-barrier progression uses physical binding
anchors. Generic encounter spawning and recovery no longer require Temple/Mine
room-ID translation maps, so future Room4+ combat slots can be registered
without editing dungeon-specific adapter maps.

The follow-on **Selected-Layout Environment Contract** gate is locally green at
`405dde5`. Runtime environment resolution now derives exact room anchors and
combat spawn groups from the selected physical layout. A synthetic Room4
contract resolves through the real EnvironmentAnchorResolver, removing the
remaining static Depth1 contract dependency from production bootstrap/router
resolution.

The follow-on **Studio Difficulty / Session Parity** gate is locally green at
`d9297f8`. Studio-created dungeon sessions now preserve the difficulty already
selected by runtime/environment routing through session creation,
DungeonInstanceDirector and Studio routing data. This closes the final
demonstrated generic higher-depth framework mismatch before deliberate
Depth2-Depth4 content registration.

The follow-on **Depth2 Backend Combat + Boss Content** gate is locally green at
`b525235`. Both current dungeons now have registered Depth2 combat packs and
distinct Depth2 boss identities/factories. Depth2 readiness now fails only
because its physical layout is deliberately absent; the release switch remains
disabled. No higher-depth room geometry or anchors were authored.

The follow-on **Depth3 Backend Combat + Boss Content** gate is locally green at
`092bd99`. Both current dungeons now have registered Depth3 combat packs at
4/5/6/7 base counts plus distinct Depth3 boss identities/factories. Depth2 and
Depth3 readiness now fail only on their deliberately absent physical layouts;
both release switches remain disabled. The Depth3 boss IDs are available for
the locked Depth4 miniboss chain.

The follow-on **Depth4 Final-Difficulty Backend Content** gate is locally green
at `8bcb58b`. Both current dungeons now have complete backend content across
Depth1-Depth4. Depth4 preserves the locked six-encounter sequence: combat,
Depth1 miniboss, combat, Depth2 miniboss, Depth3 miniboss, then a new true final
boss. Depth2-Depth4 readiness now fails only on deliberately absent physical
layouts; all release switches remain disabled.

The following early Phase 4 evidence records remain historical; the latest
isolated optional-boss candidate has been committed and pushed to its feature
branch, but **has not been merged to main or published to Roblox**. Earlier
backend gates had separate local acceptance at the checkpoints listed below:

- `docs/testing/phase4-progressive-dungeon-depth-backend-acceptance-record.md`;
- `docs/testing/phase4-generic-dungeon-encounter-runtime-acceptance-record.md`;
- `docs/testing/phase4-encounter-execution-registry-acceptance-record.md`;
- `docs/testing/phase4-multi-depth-room-runtime-acceptance-record.md`;
- `docs/testing/phase4-runtime-content-readiness-acceptance-record.md`;
- `docs/testing/phase4-enemy-archetype-combat-pack-acceptance-record.md`;
- `docs/testing/phase4-runtime-layout-selection-acceptance-record.md`;
- `docs/testing/phase4-environment-binding-runtime-acceptance-record.md`;
- `docs/testing/phase4-layout-environment-contract-acceptance-record.md`;
- `docs/testing/phase4-studio-difficulty-parity-acceptance-record.md`;
- `docs/testing/phase4-depth2-content-acceptance-record.md`;
- `docs/testing/phase4-depth3-content-acceptance-record.md`;
- `docs/testing/phase4-depth4-content-acceptance-record.md`.

`docs/ai/CURRENT_STATE.md` is the fast engineering-status layer. It does not
replace this roadmap's LOCKED/WORKING/LATER/OPEN design decisions.

When the roadmap is deliberately revised, add the new canonical DOCX, update
its version/hash here, refresh `CURRENT_STATE.md`, and preserve an acceptance
or handoff record for the superseded engineering boundary.


The Phase 4 UI/HUD overhaul has a locally tested working candidate on
wip/phase-4-ui-overhaul-v1 (baseline ff2baa0). Shared dark-fantasy styling,
combat HUD/hotbar, refreshed core windows and entrance-/service-bound
dungeon/market windows are implemented. Parse, four builds, Base and
repeat Dungeon regressions passed. Visual/live interaction acceptance
remains OPEN; no push, merge or publish occurred.
Evidence: docs/testing/phase4-ui-hud-overhaul-candidate-acceptance-record.md.
The canonical roadmap DOCX remains v1.43 pending explicit revision.
