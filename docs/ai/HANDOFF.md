## 25 September 2026 — v2.90 runtime cutover rehearsal GREEN

[Roadmap](../roadmap/DungeonMMO_Roadmap_v2_90_C4_Runtime_Rehearsal_20260925.md);
[green evidence](../testing/c4-runtime-rehearsal-v2-90-20260925.md).
The actual Dungeon coordinator is now bound by the place runtime and exposed
only through an unpublished Studio-only ServerStorage bridge for rehearsal.
Fresh focused Base 24/24 and Dungeon 27/27 passed. In genuine Play with one
connected player, all gates moved OFF -> ON together, the player entered source
resource authority (MaxHealth 98), then all gates returned ON -> OFF together
and current MaxHealth ~113.4 was restored. Test-only spatial scale=1/daylight
was explicit and is not production tuning. Next rehearse one real
player-to-NPC source hit through the existing combat input and verify
contribution/threat/quest callbacks before rollback. Permanent edits remain
GitHub-only; no main merge/publish/prod saves.

## 25 September 2026 — v2.89 atomic C4 combat cutover GREEN

[Roadmap](../roadmap/DungeonMMO_Roadmap_v2_89_C4_Atomic_Combat_Cutover_20260925.md);
[green evidence](../testing/c4-atomic-combat-cutover-v2-89-20260925.md).
The independent source combat gates are now orchestrated by one server-only
transaction. Audit readiness, explicit participants and explicit spatial/night
rules are required; partial player failure or late dispatch failure reverses
everything. Fresh focused Base 22/22 and Dungeon 25/25 passed; coordinator
7 assertions passed. Nothing invokes source cutover during normal bootstrap.
Next run a genuine unpublished Dungeon cutover/revert rehearsal against real
runtime services and connected Studio players. Permanent edits remain
GitHub-only; no main merge/publish/prod saves.

## 25 September 2026 — v2.88 level-30 dispatch audit GREEN

[Roadmap](../roadmap/DungeonMMO_Roadmap_v2_88_C4_Level30_Dispatch_Audit_Closure_20260925.md);
[green evidence](../testing/c4-level30-dispatch-audit-closure-v2-88-20260925.md).
All intended level-30 player-to-NPC C4 damage families now have a reviewed
source disposition and the activation blocker list is empty. Legacy RangerArea
is explicitly outside current source scope: the old Ranger class is legacy and
C4 Burst Shot begins at source magic level 44, so Volley is not falsely mapped
into level-30 progression. Base 21/21 and Dungeon 24/24 focused tests pass;
family audit reports blockers=0/activation_ready=true. Next build an atomic,
reversible server-only cutover coordinator. Permanent edits remain GitHub-only;
no main merge/publish/prod saves.

## 25 September 2026 — v2.87 live C4 periodic status GREEN

[Roadmap](../roadmap/DungeonMMO_Roadmap_v2_87_C4_Live_Periodic_Status_20260925.md);
[green evidence](../testing/c4-live-periodic-status-v2-87-20260925.md).
Source DEBUFF execution is now live-executor capable but disabled by default.
Wayfinder Wound routes to reviewed Bleed 13 x 4 @ 5s; Mystic Poison Curse
routes to Poison 8 x 10 @ 3s. Periodic damage cannot kill, resisted casts
schedule nothing, same-source reapplication invalidates stale callbacks, and
legacy creative StatusPhysical/StatusMagic ticks are suppressed after source
cutover. Fresh focused Base 21/21 and Dungeon 24/24 passed. Only RangerArea
remains in the dispatch activation blocker list. Next review its exact pinned
C4 source equivalent before implementation. Permanent edits remain GitHub-only;
no main merge/publish/prod saves.

## 25 September 2026 — v2.86 C4 periodic-status source GREEN

[Roadmap](../roadmap/DungeonMMO_Roadmap_v2_86_C4_Periodic_Status_Source_20260925.md);
[green evidence](../testing/c4-periodic-status-source-v2-86-20260925.md).
C4 Bleed rank one is pinned at 13 x4 every 5s; Poison rank one at 8 x10 every
3s. Exact CON/MEN save, magic M.Atk/M.Def, shot, level, vulnerability and
0-99 roll arithmetic is implemented, and ticks are source-nonlethal. Fresh
focused Studio Base 21/21 and Dungeon 24/24 passed; status reference 14
assertions passed. Live status dispatch is still blocked. Next build the
source DEBUFF calculation/executor path. Permanent edits remain GitHub-only;
no main merge/publish/prod saves.

## 25 September 2026 — v2.85 MagicBasic source-normal routing GREEN

[Roadmap](../roadmap/DungeonMMO_Roadmap_v2_85_C4_Magic_Basic_Normal_Routing_20260925.md);
[green evidence](../testing/c4-magic-basic-normal-routing-v2-85-20260925.md).
Spirit Orb keeps its original visual/contact presentation, while disabled
source-mode damage now routes through the accepted C4 ordinary attack
calculation. Remaining dispatch blockers are RangerArea, StatusPhysical and
StatusMagic, so production activation is still impossible. Fresh focused
Studio Base 20/20 and Dungeon 23/23 passed; family audit 24 and dispatch 17
assertions passed. Next migrate C4 Bleed/Poison as true DEBUFF/status paths,
not PDAM/MDAM. Permanent edits remain GitHub-only; no main merge/publish/prod
saves.

## 25 September 2026 — v2.84 C4 damage-family audit GREEN

[Roadmap](../roadmap/DungeonMMO_Roadmap_v2_84_C4_Damage_Family_Audit_20260925.md);
[green evidence](../testing/c4-damage-family-audit-v2-84-20260925.md).
Current player-to-NPC DamageService families are audited. Source-ready:
Melee, RangedPhysical, Skill and MagicSkill. Activation blockers: MagicBasic,
RangerArea, StatusPhysical and StatusMagic. Periodic bleed/poison ticks now use
explicit status kinds and cannot be routed as fresh PDAM/MDAM. The production
dispatch gate itself refuses enable while blockers remain. Fresh focused
Studio Base 20/20 and Dungeon 23/23 passed; family audit 24 and dispatch 17
assertions passed. Next migrate exact source Bleed/Poison periodic execution.
Permanent edits remain GitHub-only; no main merge/publish/prod saves.

## 25 September 2026 — v2.81 C4 NPC source boundary GREEN

[Roadmap](../roadmap/DungeonMMO_Roadmap_v2_81_C4_NPC_Source_Boundary_20260925.md);
[green evidence](../testing/c4-npc-source-boundary-v2-81-20260925.md).
Creative Marauder and Wolf now map internally to pinned C4 NPC source records
without exposing source NPC names. Spawned combat-pack enemies carry
`DungeonEnemyArchetypeId`, and source normal/PDAM/MDAM formulas accept
reviewed NPC boundaries with correct C4 race and non-PvP semantics. Fresh
focused Studio Base 18/18 and Dungeon 20/20 passed; NPC boundary 13 and source
combat 38 assertions passed; combat-pack identity 16 assertions passed. Next:
extend the disabled live executor to actual NPC Models and preserve existing
damage callbacks. Permanent edits remain GitHub-only; no main
merge/publish/prod saves.

## 25 September 2026 — v2.80 live C4 skill execution GREEN

[Roadmap](../roadmap/DungeonMMO_Roadmap_v2_80_C4_Live_Skill_Execution_20260925.md);
[green evidence](../testing/c4-live-skill-execution-v2-80-20260925.md).
The gated live executor now covers ordinary attacks plus source PDAM, MDAM and
caster-only HEAL. Damage is applied CP-first then HP; heals mutate only
server-owned caster HP. PDAM carries trusted spatial state into shield
resolution. Fresh focused Studio Base 17/17 and Dungeon 19/19 passed; executor
13 assertions passed. No gameplay dispatch has been switched yet. Next build the source-ready C4 NPC stat boundary before the reversible dispatch adapter. Permanent edits
remain GitHub-only; no main merge/publish/prod saves.

## 25 September 2026 — v2.79 live C4 executor foundation GREEN

[Roadmap](../roadmap/DungeonMMO_Roadmap_v2_79_C4_Live_Combat_Executor_20260925.md);
[green evidence](../testing/c4-live-combat-executor-v2-79-20260925.md).
The first disabled live source-combat executor now derives server transforms,
requires an explicit source elevation scale/night provider, calls the accepted
source normal-attack calculation, routes PvP through CP first and then mutates
server Humanoid HP. All independent gates remain required. Fresh focused
Studio Base 17/17 and Dungeon 19/19 passed; executor fixture 10 assertions
passed. Dungeon runtime composes resource authority but stays disabled; Base
cannot enable because live resource authority is intentionally absent. Next:
PDAM/MDAM/HEAL executor paths. Permanent edits remain GitHub-only; no main
merge/publish/prod saves.

## 25 September 2026 — v2.78 spatial combat inputs GREEN

[Roadmap](../roadmap/DungeonMMO_Roadmap_v2_78_C4_Spatial_Combat_20260925.md);
[green evidence](../testing/c4-spatial-combat-v2-78-20260925.md).
The source combat provider now derives reviewed front/side/back hit conditions
and 120-degree shield facing from trusted server spatial context. Exact
elevation/night bonuses are represented; height remains explicit in source
coordinate units so the future live executor must own the Roblox conversion.
Fresh focused Studio Base 16/16 and Dungeon 18/18 passed; spatial 11, formula
51 and source combat 30 assertions passed. Next build the disabled live
source-combat executor. Permanent edits remain GitHub-only; no main
merge/publish/prod saves.

## 25 September 2026 — v2.77 PDAM skill criticals GREEN

[Roadmap](../roadmap/DungeonMMO_Roadmap_v2_77_C4_PDAM_Criticals_20260925.md);
[green evidence](../testing/c4-pdam-criticals-v2-77-20260925.md).
The source-only combat provider now implements exact SkillPdam criticals using
authored baseCritRate ×10 × source STR bonus with a strict server-owned roll,
then doubles final PDAM without using normal critical-power modifiers. Fresh
Studio Base 15/15 and Dungeon 17/17 passed; formula 51 and source combat 30
assertions passed. Next close spatial hit-condition/shield-facing authority,
then build the separately gated live executor. Permanent edits remain
GitHub-only; no main merge/publish/prod saves.

## 25 September 2026 — v2.76 normal attack/PvP composition GREEN

[Roadmap](../roadmap/DungeonMMO_Roadmap_v2_76_C4_Normal_Attack_PvP_Composition_20260925.md);
[green evidence](../testing/c4-normal-attack-pvp-composition-v2-76-20260925.md).
The source-only combat provider now has complete ordinary single-target attack
composition plus source weapon vulnerability and player PvP modifiers for
normal, PDAM and MDAM paths. Deflect Arrow is exercised on a valid Oathguard
target and produces reviewed BOW_WPN_VULN 0.84. Misses preserve Soulshot;
successful attacks consume it once. Fresh Studio Base 15/15 and Dungeon 17/17
passed; source combat 30 assertions passed. Next close authoritative spatial
hit/shield inputs, then build the separately gated live source-combat executor.
Permanent edits remain GitHub-only; no main merge/publish/prod saves.

## 25 September 2026 — v2.75 C4 source shot authority GREEN

[Roadmap](../roadmap/DungeonMMO_Roadmap_v2_75_C4_Source_Shot_Authority_20260925.md);
[green evidence](../testing/c4-source-shot-authority-v2-75-20260925.md).
Private server shot authority now charges from real authoritative inventory,
using exact reviewed weapon grade/count, and source combat consumes the one-use
physical/magical charge for PDAM/MDAM/HEAL. Creative item names remain
DungeonMMO-original. Fresh Studio Base 15/15 and Dungeon 17/17 passed; shot
service 11 and source combat 25 assertions passed. Next audit PvP/source-target
formula modifiers and compose the full normal-attack source result before live
source damage. Permanent edits remain GitHub-only; no main merge/publish/prod
saves.

## 25 September 2026 — v2.74 C4 elemental resolution GREEN

[Roadmap](../roadmap/DungeonMMO_Roadmap_v2_74_C4_Elemental_Resolution_20260925.md);
[green evidence](../testing/c4-elemental-resolution-v2-74-20260925.md).
The disabled source-combat provider now resolves the reviewed six C4 skill
elements against authenticated final player-target elemental vulnerability
stats. Fresh Studio Base 14/14 and Dungeon 16/16 passed; formula 49 and source
combat 24 assertions passed. NPC template vulnerabilities remain a later
NPC/live boundary rather than guessed data. Next add source shot authority,
then PvP/source-target modifiers and the live executor. Permanent edits remain
GitHub-only; no main merge/publish/prod saves.

## 25 September 2026 — v2.73 C4 magic failure/critical GREEN

[Roadmap](../roadmap/DungeonMMO_Roadmap_v2_73_C4_Magic_Failure_Critical_20260925.md);
[green evidence](../testing/c4-magic-failure-critical-v2-73-20260925.md).
The disabled source-combat provider now owns M.Crit rolls from authenticated
final source stats and represents the exact optional magic-failure algorithm.
Pinned source behavior keeps MagicFailures OFF by default. Fresh Studio Base
14/14 and Dungeon 16/16 passed; formula 46 and source-combat 23 assertions
passed. Continue with elemental resolution, then shots/PvP and the separately
gated live source executor. Permanent edits remain GitHub-only; no main
merge/publish/prod saves.

## 25 September 2026 — v2.72 source shield resolution GREEN

[Roadmap](../roadmap/DungeonMMO_Roadmap_v2_72_C4_Shield_Resolution_20260925.md);
[green evidence](../testing/c4-shield-resolution-v2-72-20260925.md).
The disabled source-combat provider now resolves reviewed shield rate/power,
DEX scaling, bow x1.3 rate, strict block/perfect rolls and applies the result
to PDAM. A shielded target requires trusted server facing state; missing facing
fails closed and no client-facing authority was added. Fresh focused Studio
Base 14/14 and Dungeon 16/16 passed; formula 37 and source combat 21 assertions
passed. Next move directly to magic failure/resistance and magic critical
resolution. Permanent edits remain GitHub-only; no main merge/publish/prod
saves.

## 25 September 2026 — v2.71 physical random variance GREEN

[Roadmap](../roadmap/DungeonMMO_Roadmap_v2_71_C4_Physical_Random_Variance_20260925.md);
[green evidence](../testing/c4-physical-random-variance-v2-71-20260925.md).
Pinned rnd_dam is now present for all eight reviewed source weapons. The
disabled source-combat provider owns the exact inclusive C4 random roll,
supports the original level-based unarmed fallback and feeds the resulting
multiplier into PDAM calculations. Fresh Studio: Base **14/14**, Dungeon
**16/16**, launch gear **12 assertions**, formula **30 assertions**, source
combat **15 assertions**. No live HP/CP damage. Next integrate shield success,
shield defence power and perfect-shield handling. Permanent edits remain
GitHub-only; no main merge/publish/prod saves.

## 25 September 2026 — v2.70 physical critical resolution GREEN

[Roadmap](../roadmap/DungeonMMO_Roadmap_v2_70_C4_Physical_Critical_Resolution_20260925.md);
[green evidence](../testing/c4-physical-critical-resolution-v2-70-20260925.md).
Ordinary physical critical resolution now uses authenticated final source
critical rate, the C4 500/1000 cap and a private server 0-999 roll with exact
strict-greater-than semantics. Source stat candidates carry critical-power
multiplier 1/additive 0 before reviewed passive/active modifiers. Fresh Studio
focus: Base **14/14**, Dungeon **16/16**, formula **26 assertions**, source
combat **13 assertions**. An initial broad runner hit one unrelated stale
heavy-armour expected-value test; the targeted v2.70 paths were green and no
production behaviour was altered to mask it. Physical-skill/magic criticals
remain open. Next implement source weapon random variance. No main
merge/publish/prod saves.

## 25 September 2026 — v2.69 normal-attack hit resolution GREEN

[Roadmap](../roadmap/DungeonMMO_Roadmap_v2_69_C4_Normal_Attack_Hit_Resolution_20260925.md);
[green evidence](../testing/c4-normal-attack-hit-resolution-v2-69-20260925.md).
The source-combat provider owns ordinary C4 hit rolls using authenticated final
Accuracy/Evasion and an internal server Random 0-999 roll. Formula coverage
includes source condition multiplication, final 275-980 caps, equal roll = hit
and above-chance = miss. PDAM remains separate because reviewed C4 SkillPdam
does not call normal-attack calcHitMiss. Fresh unpublished Studio focus is green:
Base **14/14**, Dungeon **16/16**, formula **22 assertions**, source combat
**11 assertions**. Runtime position/night/elevation condition mapping remains
neutral and explicit. Next: source physical critical roll + critical-power
components. Permanent edits stayed GitHub-only; no main merge/publish/prod
saves.

## 25 September 2026 — v2.68 C4 source combat calculation provider GREEN

[Roadmap](../roadmap/DungeonMMO_Roadmap_v2_68_C4_Source_Combat_Calculation_Provider_20260925.md);
[evidence](../testing/c4-source-combat-calculation-provider-v2-68-20260925.md).
C4SourceCombatCalculationService now provides disabled source-only PDAM/MDAM/
HEAL calculations from authenticated final source stats plus actually-owned
reviewed source skill ranks. Power Strike3r1/power25, WindStrike1177r1/power12
and SelfHeal1216r1/heal42 are covered. No HP/MP is modified and the gate is OFF
by default. Fresh Base 13/13 and Dungeon 15/15 focused suites are green at
0e859222. Next make hit/critical/random weapon/shield/magic-failure/element/
shots/PvP inputs server-authoritative, then add a separately gated live source
combat executor. v2.67 live resource cutover remains reversible and default
OFF. No main merge/publish/production saves.

## 25 September 2026 — v2.67 reversible C4 resource cutover GREEN

[Roadmap](../roadmap/DungeonMMO_Roadmap_v2_67_C4_Reversible_Resource_Cutover_20260925.md);
[evidence](../testing/c4-reversible-resource-cutover-v2-67-20260925.md).
C4ResourceCutoverService is now wired into CombatService but remains
disabled-by-default. Explicit server opt-in switches real HP/MP/CP to the
authenticated source candidate, preserves resource fractions, runs source
three-second regen, routes playable damage through CP, lets NPC damage bypass
CP, reapplies on respawn and rolls back cleanly. Base focus 12/12 and Dungeon
14/14 are green. Final genuine two-player Play passed with both
`DEFAULT_OFF_FRACTION_CP_REGEN_RESPAWN_ROLLBACK_PASS` and
`VERIFIED_PLAY_MODE_PASS` at e2fb63d1. Earlier timeouts were caused by the
test runner admitting only one Studio client; production code was not the
cause. Keep the production gate OFF. Next build a similarly reversible,
disabled source-combat formula provider for physical/magic/healing paths. No
main merge/publish/production saves.

## 25 September 2026 — v2.66 resource regen + armor sets GREEN

[Roadmap](../roadmap/DungeonMMO_Roadmap_v2_66_C4_Resource_Regen_Armor_Sets_20260925.md);
[evidence](../testing/c4-resource-regen-armor-sets-v2-66-20260925.md).
Before live cutover, source audit found two real gaps and fixed them:
C4 REG_HP/MP/CP stats now exist in unified candidates, and current one-slot
Body equipment now expands to reviewed source Chest+Legs sets. Exact
ConditionUsingItemType semantics require matching Heavy/Light/Magic chest plus
legs (or FullArmor), and FuncPDefMod now includes source Legs deductions.
Apprentice Tunic is correctly Magic, with Stockings 461; both deferred MP
adds are staged. Base retry 12/12 and Dungeon 13/13 are green at b610d05c.
Clean migration prerequisites remain blocker-free, but live resources remain
off. Next implement reversible disabled-by-default HP/MP/CP cutover and source
three-second regen. No publish/prod saves/main merge.

## 25 September 2026 — v2.65 C4 Combat Point runtime GREEN

[Roadmap](../roadmap/DungeonMMO_Roadmap_v2_65_C4_Combat_Point_Runtime_20260925.md);
[evidence](../testing/c4-combat-point-runtime-v2-65-20260925.md).
Pinned C4 Formulas/Config/PcStatus were rechecked: CP regenerates every three
seconds from BaseHpRegen + level band, level mod and CON with movement
1.5/1.1/1/0.7; only L2Playable attackers consume CP, so NPC damage bypasses
it. C4CombatPointRuntime is server-only and disabled by default. Its public
configuration accepts only certified migration-boundary SourceStatCandidate
MAX_CP. Resource boundary now has zero blockers for clean reviewed characters,
while CanApplyLive and all live HP/MP/CP flags remain false. Fresh Base 11/11
and Dungeon 12/12 focused suites are green at 2aae5124. Next implement the
reversible disabled-by-default coordinated HP/MP/CP cutover. No publish/prod
saves/main merge.

## 25 September 2026 — v2.64 active-effect boundary GREEN

[Roadmap](../roadmap/DungeonMMO_Roadmap_v2_64_C4_Active_Effect_Boundary_20260925.md);
[evidence](../testing/c4-active-effect-boundary-v2-64-20260925.md).
Timed CombatStatusService buffs + Ironvow Endurance Surge now mirror into the
private active C4 registry, which keeps unresolved live effects fail-closed.
The launch persistent catalogue is now 21 skills / 25 reachable ranks with
25/25 reviewed ACTIVE/TOGGLE source coverage. Ironvow Battle Call invented
first-transfer ranks 2/3 were removed and Oathguard Arrow Ward rank 2 was
corrected to level 32. C4ResourceMigrationBoundary now consumes the private
active snapshot and composes it with source equipment/passives. Base 10/10,
Dungeon 11/11 green at 1e01640f. Only fixed blocker: CP runtime authority.
No live HP/MP/CP switch, publish, production saves or main merge.

## 25 September 2026 — v2.62 authoritative active source state GREEN

[Roadmap](../roadmap/DungeonMMO_Roadmap_v2_62_C4_Authoritative_Active_Source_State_20260925.md);
[evidence](../testing/c4-authoritative-active-source-state-v2-62-20260925.md).
C4ActiveSourceEffectResolver + server-only C4ActiveSourceEffectState now
represent real runtime activation rather than learned-skill inference. Scout
Accuracy/Critical and Ironvow Accuracy/Critical toggle executors register and
remove reviewed source ranks through this state. Respawn/player removal clear
it; replicated attributes are irrelevant. Fresh Base 9/9 and Dungeon 10/10
focused suites PASS at d379e966. Next bridge timed CombatStatusService buffs
and Endurance Surge, expose the authoritative snapshot to the resource
boundary, fail closed for unsupported live effects, then close the active
blocker. CP authority follows. No publish/prod saves/main merge.

## 25 September 2026 — v2.61 C4 active-effect calculator ordering GREEN

[Roadmap](../roadmap/DungeonMMO_Roadmap_v2_61_C4_Active_Effect_Calculator_Ordering_20260925.md);
[evidence](../testing/c4-active-effect-calculator-ordering-v2-61-20260925.md).
C4CombinedStatEffectReference now merges owned passive and supplied
ACTIVE/TOGGLE source functions into one calculator queue, including named
stack-group priority and shared 0x30/0x40 ordering. Unified source stats can
compose gear + owned passives + active effects, but deliberately report
ActiveEffectStateAuthoritative=false. Base 8/8 and Dungeon 9/9 focused Studio
suites are green at 08015086. Next create a server-only active source-effect
registry and connect real live toggle/buff services; do not remove the
active-effect blocker until learned-but-inactive skills cannot enter the
snapshot. CP remains after that. No publish/prod saves/main merge.

## 25 September 2026 — v2.60 actually-owned C4 passive resolution GREEN

[Roadmap](../roadmap/DungeonMMO_Roadmap_v2_60_C4_Owned_Passive_Source_Resolution_20260925.md);
[evidence](../testing/c4-owned-passive-source-resolution-v2-60-20260925.md).
C4OwnedPassiveSourceResolver now translates only real Known/PurchasedRank
creative passives into the highest actually owned C4 source rank, combining
inherited starter and current first-transfer scopes. It does not infer passive
ownership from level. Unmapped custom combat passives and saved ranks beyond
reviewed source coverage are explicit blockers. C4ResourceMigrationBoundary
now composes reviewed source equipment + owned source passives through the
unified source calculator. Base 7/7 and Dungeon 8/8 focused Studio suites are
green at e6925d66 after a clean Base retry. Remaining fixed blockers:
active-effect ordering, then CP authority. No publish/prod saves/main merge.

## 25 September 2026 — v2.59 six-slot C4 paperdoll GREEN

[Roadmap](../roadmap/DungeonMMO_Roadmap_v2_59_C4_Six_Slot_Paperdoll_Expertise_20260925.md);
[evidence](../testing/c4-six-slot-paperdoll-expertise-v2-59-20260925.md).
All 27 current Equipment definitions now map to reviewed C4 source items.
Head/Body/Gloves/Feet source P.Def is staged using the exact original
paperdoll deductions (12, Fighter/Mystic 31/15, 8, 7) before level
multiplication. C4 Expertise skill 239 thresholds D20/C40/B52/A61/S76 are
represented; under-level D-grade loadouts fail closed. Authenticated valid
six-slot loadouts now set OriginalInventoryIntegrated=true. Fresh Base
build/focus 6/6 PASS and Dungeon 7/7 PASS at e93d46bd. Next implement
actually-owned passive source resolution; do not infer passives from level.
Permanent edits GitHub-only; no publish/prod saves/main merge.

## 25 September 2026 — v2.58 focused local acceptance complete

Fresh local unpublished Base/Dungeon builds and focused Studio RunScript
acceptance are GREEN at
`e61eeb803bd0725aa89581a352583017d32f9fc5`. Base v2.55-v2.58 focus 5/5
PASS; Dungeon 6/6 PASS including ManaService. Assertion counts: runtime rules
13, ManaService 13, authenticated nine-class skills 554, resource boundary 42,
creative item mapping 43, launch core gear 8. Initial reruns found and fixed
two test-only harness defects (Base Combat.Tests assumption and an invalid
Runtime.get_character call). Production code did not need a regression repair.
Continue with the remaining C4 inventory paperdoll slots or the owned-passive
translation blocker; do not activate live C4 HP/MP/CP until inventory,
passives, active effects and CP authority are coherent. No main merge/publish/
production DataStore action.

## 25 September 2026 — v2.58 complete reviewed core-slot item mapping

[Roadmap](../roadmap/DungeonMMO_Roadmap_v2_58_C4_Launch_Core_Gear_Source_Expansion_20260925.md);
[test scope](../testing/c4-launch-core-gear-source-v2-58-20260925.md).
Added pinned C4 Trident291, NetiBow1181, NetiDagger1182, Brigandine352 and
Manticore395 values. C4CreativeItemSourceMap now covers all 18 current
Weapon/Body/OffHand creative items, including Warrior polearm, all three
class-specific D-grade heavy bodies and the exact Neti quest weapons. Current
Helmet/Gloves/Boots now fail closed instead of being silently ignored.
C4ResourceMigrationBoundary exposes reviewed server-owned source core-loadout
IDs but keeps OriginalInventoryIntegrated=false and CanApplyLive=false.
Tests for v2.55-v2.58 are authored; user has re-enabled local playtesting, so
fast-forward/build/focused Studio execution is the immediate next action.
Permanent edits remain GitHub-only; no main merge/publish/production saves.

## 25 September 2026 — v2.57 reviewed creative-to-C4 item links

[Roadmap](../roadmap/DungeonMMO_Roadmap_v2_57_C4_Creative_Item_Source_Map_20260925.md);
[pending test scope](../testing/c4-creative-item-source-map-v2-57-20260925.md).
Added C4CreativeItemSourceMap. Nine reviewed current items now resolve to the
nine pinned C4 source item IDs; current CombatModifiers are explicitly ignored
for source math. Loadout conversion requires every equipped Weapon/Body/OffHand
item to have a reviewed link and rejects current polearm/D-grade gear instead
of guessing. Naked loadout is allowed. v2.56's
OriginalInventoryMappingIncomplete blocker remains because the launch item
catalogue is not complete. Tests authored, not executed. Next extend the C4
source item catalogue for actual launch gear, then feed reviewed server-owned
loadouts into the authenticated resource boundary before owned-passive and
active-effect/CP work. GitHub-only permanent edits; no merge/publish/prod save
or animation changes.

## 25 September 2026 — v2.56 fail-closed C4 resource migration boundary

[Roadmap](../roadmap/DungeonMMO_Roadmap_v2_56_C4_Resource_Migration_Boundary_20260925.md);
[pending test scope](../testing/c4-resource-migration-boundary-v2-56-20260925.md).
Added C4ResourceMigrationBoundary and authenticated
ProgressionRuntimeState.get_c4_resource_migration_boundary(user_id). All nine
current original paths expose exact reviewed source base HP/MP/CP, but live
activation deliberately stays false behind four explicit blockers: incomplete
original inventory mapping, actually owned passive mapping, active-effect
ordering and missing CP runtime authority. This prevents current custom
equipment/passives/buffs being silently stacked onto C4 base resources. Added
nine-path/forgery/level-cap regression, **not yet executed**. Next close those
four blockers in dependency order, then perform one coherent HP/MP/CP cutover
before enabling Scout Elemental Heal or other C4 active families. Permanent
edits GitHub only; no main merge/publish/production saves/animation edits.

## 25 September 2026 — v2.55 shared C4 heal/split-MP runtime rules

[Roadmap](../roadmap/DungeonMMO_Roadmap_v2_55_C4_Shared_Heal_And_Split_MP_Rules_20260925.md);
[pending test scope](../testing/c4-shared-skill-runtime-rules-v2-55-20260925.md).
Added pure C4SkillRuntimeRules from pinned source for combined pre-cast
MP affordability, initial MP at cast start, launch MP reduction/clamp,
instant Heal power with Spiritshot 1.3x/Blessed 1.5x and magic cast-time
shot acceleration/500ms floor. ManaService now exposes reusable
try_begin_split_spend + finish_split_spend without changing current
try_spend callers. Scout skill58 rank4-12 source contracts now record
certified exact instant-heal amounts and split-MP lifecycle but remain
SourceOnly, LiveLearnable=false, LiveCastable=false and CreativeLink
Missing; existing ElvenRenewal is still not the C4 heal. Heal amount
certification does NOT cover threat/hate, Spiritshot item economy,
live source MaxHP/MaxMP/CP or regen. Added C4SkillRuntimeRulesTest,
extended ManaServiceTest and nine-class authenticated preview checks.
**No v2.55 Studio/Rojo execution claimed.** All permanent edits were
made directly in GitHub, no Remote Desktop Commander. Source inventory
stays 476 rows /454 candidates /22 missing; nine Scout heal rows stay
missing until real trainer/resource/executor integration. Next migrate
the live all-nine resource boundary coherently with source gear/passive/
active-buff ordering before enabling one class's C4 skill; then continue
all-class effect families and the remaining 13 explicit source gaps.
No main merge/publish/production saves/animation edits.

## 25 September 2026 — v2.54 independent C4 Scout heal source migration

[Roadmap](../roadmap/DungeonMMO_Roadmap_v2_54_Elven_Scout_C4_Heal_Migration_Plan_20260925.md).
Added read-only C4ScoutHealMigrationPlan for original skill58 ranks
4–12 (creative Scout-only planned ranks1–9). It resolves original SP,
self-heal power, split MP, cast/reuse and level20/24/28 brackets from
pinned source tree/XML, checks authentic earned GreenwardScout identity
and level<=30 and attaches source-only plans to the nine Scout preview
rows. Rows REMAIN Missing with no live skill ID, trainer, cast or MP
transaction; no Warden skill borrowing or made-up HP-power conversion.
Extended C4NineClassAuthenticatedSkillPreviewTest with nine exact
source comparisons, level bracket and cross-class denial regression.
**No Studio/Rojo tests tonight:** owner says Remote Desktop Commander
offline, test only after owner confirms availability. Existing v2.53
500-pass evidence is for earlier commit, not this v2.54. Next implement
original source MP/HP healing formula and separate purchased Scout
skill, then address remaining 13 row gaps. Current 476 total/
454 candidate/22 missing source rows not relabelled prematurely.
No main merge/publish/production saves/animation edits.

## 25 September 2026 — v2.53 all-nine-class original skill source from authenticated runtime

[Roadmap](../roadmap/DungeonMMO_Roadmap_v2_53_C4_Authenticated_Nine_Class_Skill_Source_20260925.md); [evidence](../testing/c4-authenticated-nine-class-source-skill-preview-v2-53-20260925.md). Added read-only C4AuthenticatedSkillSourcePreview + ProgressionRuntimeState.get_c4_source_skill_tree(user_id), using actual complete original server-owned owner and mentor receipt. Returns historical original SP, split MP costs, source target/type/reuse/cast and Effects/Modifiers/Conditions only for class/level-accessible source rows; CreativeLinkStatus Candidate vs Missing, never parity. Focused unpublished Base Studio PASS 500 assertions over all 476 original nine-path rows (454 candidate,22 explicit missing), Base/Dungeon Rojo both PASS. Scout historical Elemental Heal skill58 rank4 was checked original power95/53MP/TARGET_SELF and still Missing; level20 excludes Scout skill rank7 until lvl24. This is NOT a live HP/MP/CP, C4 item/active skill economy, ownership, source combat balance migration. Next close Scout heal+remaining gaps and prepare coherently integrated nine-class profiles/gear/HPMP/CP/HUD/skills with anti-exploit tests. No main merge/publish/production saves/animation edits.

## 25 September 2026 — v2.52 server-authenticated nine-class C4 source vitals preview

[Roadmap](../roadmap/DungeonMMO_Roadmap_v2_52_C4_Nine_Class_Authoritative_Stat_Preview_20260925.md); [Studio evidence](../testing/c4-nine-class-authoritative-runtime-stat-preview-v2-52-20260925.md). Added ProgressionRuntimeState.get_c4_source_vitals(user_id) returning exact read-only original C4 HP/MP/CP for actual server-owned complete original Human/Elf Fighter/Mage and five first transfers only with authentic original branch quest/mentor receipt; deny fake class/other race/unreviewed level31. Focused Base Studio 31 source-only assertions PASS, both disposable Rojo builds PASS at ab53b207. Does not switch live Humanoid MaxHealth, ManaService, CP, HUD, skill resource costs, real source item inventory, damage or passive mechanics. Previous v2.51 46 source-item assertions PASS, 454/476 skill links candidates and 22 explicit source gaps. Next: close source skill tree gaps and finish nine-class coherent equipment/HP/MP/CP and actual skill executor migration with anti-exploit checks. No main merge/public publish/production saves/art-animation edits.

## 25 September 2026 — v2.51 C4 source equipment items/stat arithmetic

[Roadmap](../roadmap/DungeonMMO_Roadmap_v2_51_C4_Nine_Class_Pinned_Item_Stats_20260925.md), [Studio evidence](../testing/c4-nine-class-pinned-equipment-source-v2-51-20260925.md). Added source-only C4SourceItemReference for 9 item IDs pinned to 07f85363 source SQL+XML: sword1, club4, wand6, dagger10, short bow13, leather shirt22, heavy chest25, robe425, round shield102. Strict original ID/slot/two-hand checks; new C4EquippedStatReference performs weapon stat set before class STR/INT/DEX, class-specific chest subtraction before level multiplier, robe MP 0x60 after passives; C4UnifiedStatReference.get_with_source_items composes all 9 class C4 HP/MP/CP with source gear and owned, level-gated source passive ranks. Both disposable Base/Dungeon Rojo builds PASS, Base Studio focused SOURCE_ONLY_PASS 46 assertions. Does not assign source item IDs to current creative inventory, change live game HP/MP/CP/gear/damage/HUD, or certify C4 full balance; gear database, 22 skill link gaps including Scout 9 heal ranks, actual nine-class live stat migration remain OPEN. GitHub-only permanent edits; no merge/publish/production saves/animation edits.

## 25 September 2026 — v2.50 all-nine-path shared source stat composition

[Roadmap](../roadmap/DungeonMMO_Roadmap_v2_50_C4_Nine_Class_Unified_Stat_Source_20260925.md); [Studio evidence](../testing/c4-nine-class-unified-stat-reference-v2-50-20260925.md). Extended C4PassiveStatReference with validated simultaneous Weapon/Body/OffHand original-kind loadout and combined modifier order; fixed nil-slot iteration and wrong-slot equipment borrowing. New C4UnifiedStatReference combines verified nine-path source level-30 HP/MP/CP and derived naked stats with class/level-authorized original passive rank data (inherited starter path allowed) but NO original item additive stats or active buffs. Final commits e9914c53,21fa3fdd,4ea8f0d7; disposable Base/Dungeon Rojo PASS, Base Studio 35 focused SOURCE_ONLY assertions PASS, exact final stats/live combat=false. User wants same C4 stats/effects for ALL nine paths; do not mistake nine-path source references, 454 candidate learning rows or 56/56 Warden rank schedules for full runtime parity. Next real original gear source stats + combined calculator, 22 skill gaps including Scout 9-rank elemental heal, then coherent HP/MP/CP/profile/HUD and class effect migration with exploit regressions. No main merge/public publish/production DataStore/animation edits.

## 24 September 2026 — v2.49 all original classes skill ID/rank candidate map and passive source arithmetic

[Roadmap](../roadmap/DungeonMMO_Roadmap_v2_49_C4_Nine_Class_Creative_Mapping_20260924.md); [test evidence](../testing/c4-nine-class-creative-skill-map-and-passive-source-v2-49-20260924.md). Every one of 476 nine-path C4 learning rows classified in C4CreativeSkillSourceMap: exact source ID/rank -> explicit creative ID/rank candidate, or documented gap. First Base audit 451 candidates/25 gaps; found MysticFeebleCurse and ElvenMysticLanguor existed in trainer but were absent from Mage teachable list; class and map fixed, rerun PASS 454 candidate rows/22 missing/0 broken and 94 numeric mana mismatches. ElvenScout original Elemental Heal nine ranks remain genuinely missing; existing ElvenRenewal is not automatically equivalent. C4PassiveStatReference added read-only source 0x30 multiplier then 0x40 additive stat operations, using-kind equipment gates, one rank per mastery, no active aura as permanent passive; Base Studio pure source 9 assertions PASS. Base/Dungeon Rojo builds PASS. No LIVE HP/MP/equipment/combat stat migration or exact C4 balance certification; creative extra skill families still logged. No main merge/publish/production saves or animation edits. Local __pycache__ from separate quadruped engine was untouched.

## 24 September 2026 — v2.48 all nine paths, 75 C4 source effects

Generated structured, pinned C4 source effect data for every one of
the 75 source skill IDs used by the v2.47 nine-path level<=30 tree,
covering 272 unique source rank pairs behind 476
class-scoped learning rows. Data resolves source sets plus passive
modifiers/effects/weapon conditions, split by XML range and surfaced
through C4SkillEffectSource. This is source metadata only; current
creative skill executors still use old Roblox values. Next create
complete source->creative family/rank map, compare divergences, then
port C4 item/passive calculator order and coherent live migration.
No main merge/publish/production saves/animation edits.

## 24 September 2026 — v2.47 all nine original paths C4 learning rows

Added C4Level30SkillTreeSource for ALL current original paths:
HF39, HM44, EF43, EM42, Warrior62, Knight54, Rogue59,
ElfKnight56, ElfScout77 = 476 rows /75 unique source skill IDs through
lv30. 457 rows come from pinned C4 skill_trees.sql; 19 missing automatic
common rows are explicitly sourced from C4 L2Hub (Create Common Item
for 4 starters; ExpertiseD + Create Common ranks2/3 for 5 transfers).
Rows preserve source ID/level/name/SP/min level/origin. This is source
metadata only, not current effect parity. Next parse exact C4 skill XML
for the 75 IDs then map each family to current creative IDs before any
live migration. No main merge/publish/production saves/animation edits.

## 24 September 2026 — v2.46 pinned C4 combat formula layer

Added read-only C4CombatFormulaReference from the same pinned C4 source:
main physical formula, magic 91*sqrt(MAtk)/MDef*power, source instant
heal + Spiritshot/BSS multipliers, PAtkSpd delay, skill cast-speed,
hit-chance table and magic level threshold. This establishes how
historical skill power must be consumed, so NEVER set Roblox HP damage
equal to the source power. Pure source tests precede equipment/buff
calculator and live migration. Next ingest full level<=30 source skill
rows from skill_trees + exact skill XML for all nine original paths,
then equipment/calculator and coherent runtime migration. No current
gameplay values changed; no main merge/publish/production saves.

## 24 September 2026 — v2.45 C4 derived-stat reference engine

Added read-only C4DerivedStatReference on pinned C4 source
`Neco-spain/l2jadmins_C4-Scions-of-Destiny@07f85363`.
It implements source stat-bonus equations, level modifier, naked
PAtk/PDef/MAtk/MDef, physical/cast/run speed, accuracy/evasion and
critical-rate units on top of v2.44 exact nine HP/MP/CP templates.
It intentionally excludes equipment, mastery, buffs/dyes and target
mods until C4 calculator order is ported. Live AttributeConfig,
CharacterCombatStats, ManaService, HP/HUD and skills remain untouched.
Next port equipment + physical/magic damage/heal/status formula layer,
then coherent live migration and all-class skill source values.
No main merge/publish/production saves/animation edits.

## 24 September 2026 — v2.44 exact C4 nine-template growth source

Pinned actual C4 Scions of Destiny source/datapack
`Neco-spain/l2jadmins_C4-Scions-of-Destiny@07f85363`.
C4PrimaryStatReference now records exact source template IDs and
class-specific HP/MP/CP bases/growth for Human Fighter/Mystic,
Elven Fighter/Mystic, Human Warrior/Knight/Rogue and Elven
Knight/Scout, plus base combat template fields. Exact HP/MP/CP source
formulas from FuncMax* and C4 CON/MEN bonuses are represented through
level30. Representative source lv30 integer results:
HF 922/319/418, HM 699/466/366, EF 792/324/353,
EM 666/469/348, Warrior 1070/320/849, Knight 1018/320/610,
Rogue 983/320/399, ElfKnight 902/325/453, Scout 874/325/354.
Read-only source milestone only; production AttributeConfig,
Humanoid health, ManaService, CP, damage and all skills are NOT yet
migrated. Next build C4 derived-stat/formula engine then coherent
profile/runtime/HUD migration before replacing every class skill.
No main merge/publish/production saves/animation edits.

## 24 September 2026 — v2.43 first actual nine-path primary stat source

[Roadmap](../roadmap/DungeonMMO_Roadmap_v2_43_C4_Nine_Class_Primary_Stat_Reference_20260924.md).
Owner wants the same C4 HP/MP/CP and per-level character stats across
ALL currently implemented original classes before migrating skill
effects/damage/costs, with creative renaming but no arbitrary rebalance.
Added read-only C4PrimaryStatReference for six original attributes:
Human Fighter 40/30/43/21/11/25, Human Mystic
22/21/27/41/20/39, Elven Fighter 36/35/36/23/14/26,
Elven Mystic 21/24/25/37/23/40 in STR/DEX/CON/INT/WIT/MEN
order; all five original Fighter first-transfers inherit matching
race Fighter six-stat baseline. Unsupported legacy/forged identities
fail closed. get_level_vitals refuses to fabricate unsourced
C4-level HP/MP/CP; ZERO original class-growth curves verified.
Unpublished Base and Dungeon Rojo builds PASS; Base focus Studio
SOURCE_ONLY_PASS 77 assertions and VERIFIED_SOURCE_ONLY_NOT_LIVE_PARITY.
Local quadruped __pycache__ untracked was preserved untouched during
fast-forward pull. No production stat/skill numbers changed.
v2.42 all-class inventory 13 scopes /1353 current rank occurrences /
32 independently sourced historic rows, not mechanical parity.
Next source C4-specific class-level HP/MP/CP full table,
CON/MEN multipliers, shared formula and safe migration, then each
class's skill effects and real-client tests. No main merge, Roblox
publish, production save mutation or animation edits.

## 24 September 2026 — v2.42 C4 all-class stat baseline is owner-approved TARGET

[Roadmap](../roadmap/DungeonMMO_Roadmap_v2_42_C4_All_Classes_Stat_Baseline_20260924.md); [design](../design/C4_All_Classes_Stats_And_Skills_Target_20260924.md). Owner wants actual original Chronicle 4 class-and-level HP/MP/CP and STR/DEX/CON/INT/WIT/MEN, with historical per-rank skill powers/costs, defence, passives, threat and formula semantics for ALL playable Human/Elf Fighter/Mystic starting and five first-transfer paths, not just Warden. Current game custom AttributeConfig 100 HP and five stats/RaceDefinitions 1.08 Human HP /0.92 Elf, current mana/XP/stamina do not match. Do NOT copy original skill power directly into direct Roblox HP damage, or declare archival generic class-base HP charts C4-certified without proper chronicle verification. Implement authoritative shared stat/class-level layer and profile migration, then across-class skill fidelity and anti-exploit tests. This v2.42 commit only documents source/versioning requirements, NO live stats changed, no main merge/publish/production saves/animation changes.

## 24 Sep 2026 — v2.42 ALL implemented class scopes audited (NOT C4 mechanical parity)

[Roadmap](../roadmap/DungeonMMO_Roadmap_v2_42_All_Implemented_Class_Skill_Fidelity_20260924.md); [class-by-class evidence](../testing/c4-all-implemented-class-skill-fidelity-20260924.md). User clarified ALL classes so far, not just Warden. Added C4CrossClassSkillSamples for starter Human/Elven Fighter/Mystic and transfer HumanRogue/ElvenScout/HumanWarrior/HumanKnight/ElvenKnight first verified exemplar each; C4AllImplementedClassSkillAudit returns every inherited/starter/purchased skill rank through30 per 13 race-class scopes, complete current combat and progression/passive fields and source status. Focused unpublished Dungeon Studio at 58cfe32c PASS inventory: 1353 class-scoped current ranks (shared skills repeated), 32 source-number rank occurrences, 1321 without individual verified reference. Legacy Human/Elven Ranger/Rogue explicitly no direct C4 one-to-one origin. No exact C4 effect/damage/balance parity claimed for any class; work on full historical source rows and shared formula/stats next. All permanent edits GitHub; no production combat edits, public publish/main merge/saves/art/animation changes.

## 24 September 2026 — v2.41 C4 skill fidelity audit, old custom-stat directive superseded

[Roadmap](../roadmap/DungeonMMO_Roadmap_v2_41_C4_Skill_Effect_Parity_Audit_20260924.md); [full findings](../design/C4_Skill_Effect_Fidelity_Audit_20260924.md); [Studio evidence](../testing/c4-skill-effect-source-runtime-differences-20260924.md). Owner now wants *actual C4 power/effects/passives/costs* as target, names changed, not just skill rank counts. Existing game does not meet that target: Warden first heal C4 source skill rank4 power95/53MP vs game rank1 24HP/13mana, Charm C4 power132/37MP vs 10% threat/7mana, Aggression C4 power655/20MP vs 24 threat/9mana, passive flat P.Def versus 0.006 damage mitigation per rank. Human Warrior first Power Smash C4 power90/22MP vs Ironvow 25 BASE_DAMAGE/21 stamina. Original skill POWER must not be copied as direct Roblox damage! Added 24 source-only rank power+MP entries over Warden heal/charm/aggression, source/runtime reporter + test, Studio verified AUDIT_ONLY 3 families/24 rows/different MP 24 and exact_parity NOT_CERTIFIED. Historical 56/56 Warden rank SCHEDULES and earlier live gameplay PASS do not prove original effect parity. Fill all original classes' source stats and shared formula layer first, keep known anti-exploit constraints. No gameplay stat edits, publish/main merge/production saves.

## 24 September 2026 — C4 skill numerical/mechanical fidelity is NOT certified

Owner requested actual original C4 mechanics, damage, passives and rank-specific costs/effects, with independent creative names, replacing earlier rank-volume-only target. See [mechanical audit](../design/C4_Skill_Effect_Fidelity_Audit_20260924.md). Current actual Warden heal r1 24 Roblox heal/13 mana vs C4 Elemental Heal source r4 power95/53MP; Charm 10% threat/7mana vs C4 power132/37MP; Aggression24 threat/9mana vs C4 power655/20MP; heavy passive uses 0.006 mitigation per rank vs C4 P.Def. Human Warrior Power Smash original power90/22MP vs IronvowDrivingStrike25 BASE_DAMAGE/21 stamina. Original C4 skill power is NOT direct HP damage. New source-only 24 rank manifest and report compare three Warden families, mark exact parity false. Previous 56/56 Warden rank SCHEDULES and real Play are retained; no blanket C4 effect parity. Update other five branches and starting-class formulas before release; no production combat/stat edit from speculative direct power conversion.

## 24 September 2026 — v2.40 saved-profile reload across independent cache instances

[Roadmap](../roadmap/DungeonMMO_Roadmap_v2_40_Warden_Disposable_Profile_Handoff_20260924.md) and [evidence](../testing/greenward-warden-v2-40-profile-cache-reload-20260924.md). At 8a1c2a5f actual isolated Base Studio 52 assertions PASS: Warden test-seeded bound three reports/stage4 survive save/release and distinct Dungeon-like/Base-like ProfileService reloads on ONE disposable in-memory adapter; actual quest service consumes reports/seal from one-use test-signed NPC events, authentic OriginalFirstTransferService mentor awards Warden at20, real rank-purchase service grants Steel Training1, final independent cache reload keeps class/rank/ready quest and no bound items. Separate other owner has none. Not actual Roblox teleport or persistent DataStore/lease, and earlier real-client report kills and physical Base NPC return happened in SEPARATE disposable Play sessions. v2.38 three genuine reports/2 rooms and v2.39 natural Captain AI bleed cure separately PASS. Warden 56/56 C4 source rank schedules mapped; five of 18 first-transfer paths scheduled, 0/18 fully mechanically/release certified. True cross-place and remaining classes OPEN. No publish/main merge/production saves/animation changes.

## 24 September 2026 — v2.39 natural Captain slash -> Warden client cleanse; training-rig regression

[Roadmap](../roadmap/DungeonMMO_Roadmap_v2_39_Natural_Captain_Bleed_Rig_20260924.md); [evidence](../testing/greenward-warden-v2-39-natural-captain-ai-and-rig-20260924.md). New unpublished Play at fd50f8b6 verified UNMODIFIED Captain AI itself delivered 24HP CaptainSlash, naturally minted actual player bleed, real client used earned-but-test-prepared Warden Bleed Recovery and spent mana to cancel old ticks (VERIFIED_NATURAL_CAPTAIN_PLAY_PASS). AI was disabled only after the first authentic bleed to isolate delayed tick; alive model remained. Previous background infinite-yield MarauderRigContractTest assumed obsolete Arena model names in synthetic Dungeon; replaced only fixture with real MarauderFactory-built 4 disposable physical rigs and focused Studio VERIFIED_FOCUS_PASS at fd7f8d0c. No production factory/art/animation changes and no overall background suite claim. Prior Warden 3 reports across two real dungeon rooms and server hit/reward race/base/class owner gates passed at v2.38. Seamless Base->Dungeon->Base/rejoin saved profile and exact C4 effects/18-branch release remain OPEN. No main merge/publish/production saves.

## 24 September 2026 — v2.38 Warden three real reports plus hit/reward owner gates

[Roadmap](../roadmap/DungeonMMO_Roadmap_v2_38_Warden_Three_Reports_Owner_Gates_20260924.md); [evidence](../testing/greenward-warden-v2-38-three-reports-ledger-20260924.md). Targeted original source-quest ledger now rejects copied race/base/class/branch, underlevel and changed stage at both hit and one-use reward. Focused 58 ledger +21 pack +13 contribution assertions PASS (3/3 suites). Disposable two-client Dungeon v2.38 three-report runner initially FAIL at 267397ac due displaced test avatar; stabilized test-only aim and HP in 598ce9f2 then VERIFIED_THREE_REPORTS_TWO_ROOMS_PASS: stage3 owner normal client killed two Room1 RootboundMarauders and third Room2, gained exactly three personal reports, true aggregate proof and Step4; other owner normal client killed ThornboundColossus and alone got boss seal. Room1 ordinary monsters were test-assisted to reach real physical Room2, quest monsters were all genuinely client-lethal. Not natural pack survival, uninterrupted Base/Dungeon/Base persistent saves/rejoin or natural Captain AI bleed. No main merge, publish, production saves, animation edits.

## 24 September 2026 — v2.37 Warden two-client genuine lethal quest Play

[Roadmap](../roadmap/DungeonMMO_Roadmap_v2_37_Warden_Client_Lethal_Quest_20260924.md); [evidence](../testing/greenward-warden-v2-37-real-client-lethal-quest-20260924.md). At `1e9178838b045923c24ebd600cc3bb63b10e7767`, disposable unpublished two-client Dungeon test moved past v2.36's server-assisted finishing hits: both players used real normal combat input to deal every hit including lethal on RootboundMarauder/ThornboundColossus, independently triggering actual server-issued owner-only patrol report/guardian seal and no cross-owner loot. RunScript VERIFIED_TWO_CLIENT_WORLD_PROOFS_PASS. This is separate test-prepared stages, not yet an uninterrupted all-three-reports real quest or persistent Base->Dungeon->Base/rejoin. Warden historical schedules 56/56 mapped; true C4 formula parity and full 18-path release not certified. GitHub edits only; no main merge, publish, production saves or animation changes.

## 24 September 2026 — v2.36 Warden physical Base and Dungeon Play

[Roadmap](../roadmap/DungeonMMO_Roadmap_v2_36_Warden_Real_Client_Quest_20260924.md) and [test evidence](../testing/greenward-warden-v2-36-physical-client-quest-20260924.md). Fixed stale automatic SkillMasteryGatesTest by separating new original C4 mandatory first-transfer choice from prior legacy trial mastery: Base focused 65 assertions PASS at 39b0674d; production gate unchanged. Disposable two-client Warden Base Play at a5567be2 reports VERIFIED_LIVE_BASE_PASS: real physical SentinelIlyra/WardenCaer report and seal turn-ins, underlevel mentor denial, earned level20 Warden, genuine Warden trainer remote purchase; earlier report/seal loot test-seeded in Base. Two-client Warden Dungeon at b752df98 VERIFIED_TWO_CLIENT_WORLD_PROOFS_PASS: actual client normal first-hit HP on RootboundMarauder/ThornboundColossus, server test-assisted lethal hits, distinct personal report/seal awards and cross-owner denial. Still OPEN actual fully player lethal kills/all 3 reports, natural Base-Dungeon-Base save/rejoin and exact C4 effect balance. No main merge/publish/production saves/animation edits; GitHub-only source/doc edits.

## 24 September 2026 — v2.35 real client Warden Bleed Recovery

[Roadmap](../roadmap/DungeonMMO_Roadmap_v2_35_Greenward_Player_Bleed_Client_Play_20260924.md) and [test evidence](../testing/greenward-warden-v2-35-player-bleed-live-20260924.md). At `0fd05cbe`, disposable unpublished Dungeon Play PASS: tagged real Captain model plus explicit trusted server post-hit callback applied owner-only bleed after 15HP hit, pre-cure 3HP ticks occurred; real client cast paid Warden self-cure, spent mana, never healed via MageHealPulse, cleared server status and prevented post-cure ticks. First test `8f3ffccd` FAIL was its overly broad static HP check, corrected to heal pulse and post-cure HealthChanged listening; fixed runner VERIFIED_PLAY_MODE_PASS. Natural Captain AI slash and real earned/persisted end-to-end quest remain OPEN. Background automatic SkillMasteryGatesTest legacy Human Fighter advancement assertion failed (original C4 path choice now precedes custom trial), so do not claim full automatic suite green; unrelated earlier MarauderRigContractTest CollisionBody warning also unresolved. Source schedules 56/56 Warden mapped, 0/18 complete release acceptance. Permanent scripts/docs GitHub-only; no publish/main merge/production saves/animation edits.

## 24 September 2026 — v2.34 executed Warden tests and spawn hardening

[Roadmap](../roadmap/DungeonMMO_Roadmap_v2_34_Greenward_Studio_Acceptance_20260924.md); [evidence](../testing/greenward-warden-v2-34-source-world-guard-20260924.md). Corrected zero-threat Charm and exclusive self-only nonhealing BleedRecovery validators after actual Studio module-load failures. Unpublished Base source suites PASS: 224 Warden rank/craft, 24 Warden quest, 32 launch audit; Dungeon source world PASS 14 then 16 after race/base gate, generic combat ledger/source pack/contribution PASS 10/21/13 (3/3). Actual one-client Warden DefenseAura+heavy Body+shield-block PASS: blocked hits 38.7 HP each, guard break 86 HP, exhausted reblock denied. Initial live fixture typo ElvenWarden failed, corrected to ElvenKnight; do not count earlier failed run. Unrelated MarauderRigContractTest CollisionBody infinite-yield warning seen. Full live player-led quest kill/drops/mentor/trainer/cross-place save and CaptainSlash bleed/cure remain OPEN; all 56 source rank SCHEDULES mapped but 0/18 complete mechanical/release certifications. GitHub edits only; no publish/main merge/production saves/animation edits.

## 24 September 2026 — v2.33 Warden physical quest enemy binder

[Roadmap](../roadmap/docs/roadmap/DungeonMMO_Roadmap_v2_33_Elven_Knight_Physical_Quest_Enemies_20260924.md). `C4QuestEncounterSpawns` now adds two RootboundMarauders per eligible instanced room at ElvenKnight quest stage3 and exactly one ThornboundColossus at stage5, using existing actual Marauder factory/runtimes, unique server encounter registration and owned quest kill ledger. Existing Base stage1/2/4/6 NPCs and personal report/seal rules remain. New isolated world-model contract test/runner is Studio-pending; actual live human Play and Base/Dungeon/rejoin still OPEN. All 56/56 Warden source rank schedules mapped, no mechanical/release certification. No main merge/publish/production saves/animation changes.

## v2.32 focused tests corrected

The v2.32 Elven Knight source test now expects independently mapped
56/56 ranks without release acceptance. The rank-purchase/crafting
fixture restores level 28 after the level-24 bleed purchase and asserts
self-only non-healing bleed cure costs and tier. Both remain Studio-pending;
build success alone does not certify functional tests.

## 24 September 2026 — v2.32 Elven Knight source rank map 56/56

[Roadmap](../roadmap/docs/roadmap/DungeonMMO_Roadmap_v2_32_Elven_Knight_Bleed_Recovery_20260924.md). A real tagged CaptainSlash positive, unblocked HP hit can now apply bounded, non-stacking server-owned player bleed through PlayerBleedStatusService; genuine Warden only, purchased level24 GreenwardWardenBleedRecovery mana/cooldown clears only owner active bleed and cancels old ticks. No client-attribute cure. All 56/56 original C4 source training rank SCHEDULES now mapped, 5 of 18 first-transfer paths fully rank-scheduled, 0 mechanically/release certified. Full physical Captain bleed/cure Play and all prior Warden focused source tests still need Studio execution. No main merge/publish/production saves/animation edits.

## 24 September 2026 — v2.31 Warden crafting

[Roadmap](../roadmap/docs/roadmap/DungeonMMO_Roadmap_v2_31_Elven_Knight_Common_Creation_20260924.md). Two independently bought GreenwardWardenCommonItemCreation ranks (20/28) now authorize eight material-backed recipes across one selected creation career, with original Elven item identities and real armor expertise gate. Focused service test covers genuine material-consuming crafts but has not run inside Studio. Warden rank map 55/56; only real player Bleed Recovery remains unimplemented. No main merge/publish/production saves/animation edits.

## 24 September 2026 — v2.30 Warden defensive utilities

[Roadmap](../roadmap/docs/roadmap/DungeonMMO_Roadmap_v2_30_Elven_Knight_Defensive_Utility_20260924.md). Greenward Warden now maps 53/56 rank schedules; missing common creation 2 and real player-bleed recovery 1. Independently paid Warden equipment expertise + own D Body, shield mastery with OffHand check and bounded hostile mitigation, timed self-status defensive/attack auras and ultimate defence, server poison cleanse and bow-only ward registered. Historical C4 aura target/formula parity NOT verified; actual physical quest monsters and live-client skill play pending. Updated source-audit/training tests not executed in Studio. No main merge/publish/production saves/animation changes.

## 24 September 2026 — v2.29 Warden active heal and aggro

[Roadmap](../roadmap/docs/roadmap/DungeonMMO_Roadmap_v2_29_Elven_Knight_Heal_Charm_Taunt_20260924.md). Warden's ElementalHeal (9), Charm (9), Aggression (6) new separately bought combat families use actual MageHealService and single-target ThreatService owner-only reduce/taunt with MP spend and zero-damage threat skills. Six Warden families now map 45/56 source training ranks; 11 remaining. Focused in-memory rank purchase driver updated but NOT Studio run. Full C4 balancing/formula/source range parity and actual client/physical dungeon quest Play remain OPEN. No main merge/publish/production saves/animation changes.

## 24 September 2026 — v2.28 focused Warden passive test fixture

New `C4GreenwardWardenPassiveTrainingTest` and unpublished Base runner exercise earned class, full 21 individually purchased passive ranks, actual EquipmentService sword/dagger/HeavyArmor toggling and copied-class/receipt/race denials. Test has NOT run in Studio. The four original Fighter branch schedules are unchanged; Elven Knight 21/56 mapped, 35 remaining. Do not claim actual live hostile-hit Play from build success.

## 24 September 2026 — v2.28 first three Greenward Warden passives

[Roadmap](../roadmap/docs/roadmap/DungeonMMO_Roadmap_v2_28_Elven_Knight_Three_Passive_Families_20260924.md). Elven Knight now has its own real class-restricted three-family trainer: `GreenwardWardenSteelTraining` 4 ranks (20/24/28/28), `GreenwardWardenHeavyArmorTraining` 9 (3/3/3) and `GreenwardWardenMagicResistance` 8 (2/3/3). Purchased owner-only server effects use registered Sword/Blunt, HeavyArmor Body and hostile-magic-only bounded reduction. Coverage 21/56 mapped, 35 remaining, zero full mechanical/release certifications. Greenward Warden physical quest NPCs/monster combat Play and new skill regressions remain OPEN, prior Warrior stored avatar tests pending. No main merge/publish/production saves/animation edits.

## 24 September 2026 — CURRENT v2.27 Greenward Warden quest transaction backend

[Current roadmap](../roadmap/DungeonMMO_Roadmap_v2_27_Elven_Knight_Quest_Transactions_20260924.md). Elven Knight's authored six-step advancement quest now has complete owner-bound backend transactions: 3 distinct Rootbound Marauder receipts -> 3 Verdant Patrol Reports -> Warden Caer consumes them; Thornbound Colossus receipt -> one Verdant Guardian Seal -> Sentinel Ilyra consumes it. New isolated test then uses the real one-use transfer service to award GreenwardWarden at level20. Items cannot trade/bank, and the Dungeon quest combat ledger has branch-specific proof IDs. Physical enemy spawning/live combat is still missing, so do not call the quest Play-complete. Trainer remains empty and skill mapping 0/56. New transaction runner is pending Studio. No main merge/publish/production saves/animation edits.

## 24 September 2026 — CURRENT v2.26 Elven Knight gated quest/identity

[Current roadmap](../roadmap/docs/roadmap/DungeonMMO_Roadmap_v2_26_Elven_Knight_Quest_Foundation_20260924.md). New `GreenwardWarden` earned-class ID, Elf-only empty trainer/physical mentor, `VerdantOathTrial` with first two Base physical NPCs, Elf-only source quest rule. Stage3/5 monsters, unique drops, and completion are NOT implemented; actual world binder fails closed at stage3 and cannot award the class. Separate 56 C4 source rows remain 0 implemented/purchased. New in-memory focus test and local Studio runner created, pending actual execution and physical quest Play. No borrowed Scout/Human Knight skill rights. Preserve previous four mapped source-rank schedules and incomplete release gates, no main merge/publish/production saves or animation edits.

## 24 September 2026 — CURRENT v2.25 distinct Elven Knight source inventory

[Current roadmap](../roadmap/docs/roadmap/DungeonMMO_Roadmap_v2_25_Elven_Knight_Source_Inventory_20260924.md). Historical C4 Elven Knight **56** level-20/24/28 source rank opportunities (18/18/20) were recorded in standalone `C4ElvenKnightLevel30Sources.luau`; `C4Level30LaunchCoverage` now reports this fifth source-inventoried branch as `SourceRanksAuditedClassUnimplemented`, with 0 mapped rows and no player-career ID. The original 4 mapped first-transfer branches are unchanged, 13 of 18 historical source inventories remain and 0/18 classes have whole-game mechanical release acceptance. The new focused audit test enforces Human Fighter 3 choices, Elven Fighter 2 choices and Elf Knight 56-source/0-mapped distinction. These new assertions have NOT run in Studio. Prior Warrior stored-avatar Play regressions remain pending. Next: create the earned original Elven Knight quest, separate career/trainer and functional ranks; never alias existing Greenward Scout or human Oathguard. No main merge/publish/production saves/animation edits.

## 24 September 2026 — CURRENT v2.24 Fighter class-tree correction

[Class tree and follow-up roadmap](../roadmap/docs/roadmap/DungeonMMO_Roadmap_v2_24_Human_Elven_Fighter_Path_Gap_20260924.md). Human level-1 Fighter branches at 20 into Warrior/Ironvow, Knight/Oathguard or Rogue/Ashenblade. Elven level-1 Fighter branches into Scout/GreenwardScout or **unimplemented Elven Knight** (proposed display name Greenward Warden; do not rename existing Scout). Human/Elf starter Fighter are separate source inventories despite the shared internal Fighter ID; do not count starter skills as first-transfer ranks. Existing first-transfer mapping 4/18, mechanically release-certified 0/18; Elven Knight is not one of the four. Focused source-audit test now guards three Human/two Elf first transfers and missing Elf Knight, not yet executed in Studio. New v2.23 stored-avatar recovery/surge Play tests remain pending. No main merge/publish/production saves or animation changes.

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

## 24 September 2026 — v2.08 Knight shield focused and live HP checkpoint

Resume from [v2.08 roadmap](
../roadmap/DungeonMMO_Roadmap_v2_08_Oathguard_Shield_Masteries_20260924.md)
and [test checklist](
../testing/oathguard-shield-mastery-github-candidate-v2-08-20260924.md).
Committed two genuinely bought Oathguard shield ranks (20/28),
class/trainer/quest receipt gates, equipment-dependent server
physical reduction, damage bridge and focused automated test
fixtures. Actual Studio tests and Rojo builds were **not run**
because remote desktop is unavailable. Source-mapped Oathguard
training candidate: 37/54, 17 missing; Ironvow: 27/62, 35
missing. Run `scripts/studio/c4_oathguard_quest_focus.luau`
and `scripts/studio/c4_level30_launch_coverage_focus.luau`
on the next fast-forward pulled disposable Base; then verify
equipped shield physical hits and previously pending client
Knight heal/magic effects. Do not imply Studio PASS based on
GitHub edits or old logs. Keep all source/doc changes in GitHub,
desktop for fast-forward pull, disposable builds, unpublished
Studio tests and logs only. Never merge main or publish without
owner approval. Separate animation roadmap is unaffected.

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

# DungeonMMO Development Handoff

## 22 September 2026 — v1.77 C4 poison/cure, still INCOMPLETE

Read `docs/testing/c4-poison-status-v1-77-2026-09-22.md`
and `docs/roadmap/DungeonMMO_Roadmap_v1_77_C4_Poison_Cure_20260922.md`.
The roadmap index's separate and newer humanoid-animation
authoring plan remains intact. This backend scope continues
from C4 v1.76; it does not replace the rig, no-manual-Blender
or user visual-approval requirements.

Current SIX enumerated Human/Elf original C4 basic and
partial-first-transfer inventories: **340/396 functional
analogue ranks, 56 missing**. Base 151/168, two Scout
source inventories 189/228. Human Fighter 37/39,
Elf Fighter 41/43, Human Mystic 38/44, Elf Mystic
35/42, Human Rogue 81/99, Elven Scout 108/129.
Seven further original first-transfer source class
inventories remain UNMAPPED; **0/9** transfer paths complete.
`C4CatalogueCoverage.report().Completed` remains FALSE.

New actual runtime: Human Mystic level-seven poison curse
requires a confirmed hostile spell hit, then deals three
non-stacking server damage ticks; Mystic Cure Poison removes
a real friendly server poison at full health, and Elf-only
Scout Poison Recovery is self-only. Disposable unpublished
Play: all THREE authenticated hotbar skills and their
true NPC/player health/status effects PASS; source/skill
test 20, base audit 49, Scout inventory 1080, strict
overall audit 7 assertions PASS. Base and Dungeon
temporary Rojo builds succeed. Authored ordinary NPC/boss
poison attacks and full persisted-player trainer/party
UI remain untested/unimplemented. Prior separate Phase2A
paid-revive automatic failure is still OPEN.

NEXT: finish 17 base and 39 Scout sourced rank gaps,
then source-map/implement seven wholly missing original
C4 first-transfer class trees. No merge, publish, paid
action, production saves or old dungeon regression loop.
All source/tests/docs edited in GitHub only; remote
desktop limited to clean pull, TEMP unpublished tests
and log inspection.


## 22 September 2026 — previous v1.76 C4 recovery, PARTIAL

Read `docs/testing/c4-conditional-recovery-v1-76-2026-09-22.md`
and `docs/roadmap/DungeonMMO_Roadmap_v1_76_C4_Recovery_20260922.md`.
The six currently source-inventoried original C4 Human/Elf
basic/partial-first-transfer classes now have **336/396**
functional DungeonMMO analogue rank entries; **60** are missing.
Base 148/168; partial Scout inventories 188/228. Exactly
**0/9** original first-transfer paths are complete and
SEVEN source career inventories have not been enumerated.

New: Human Fighter bought seated recovery at level 5;
Human Rogue seated recovery at 24/32; both Scout races'
moving recovery at 36. Genuine server StaminaService
Heartbeat now applies bounded rank bonuses only when
the actual Humanoid is seated or moving. Normal Stamina
regen pause/delay/maximum are preserved; unrelated or
foreign-race/class ownership fails closed. Focused
42 recovery, 1079 Scout inventory, 55 base-source
and 7 overall C4 assertions PASS. Disposable real
Studio Play client physically occupied a Seat and
recovered spent Stamina faster with its purchased rank;
`REAL_SEATED_STAMINA_PASS` and
`VERIFIED_PLAY_MODE_PASS`. Actual client running
movement recovery is not yet independently Play tested.

NEXT: finish 20 basic + 40 Scout source rank gaps,
then source-map and implement the seven entirely
missing original C4 first-transfer career inventories.
Overall completion flag remains FALSE. Prior unrelated
Phase2A paid-revive automated failure remains open.
All source/test/docs edits via GitHub; remote only
clean pull, TEMP builds, unpublished Studio/tests/logs.
No `main` merge, Roblox publish, production saves or
paid operations.


## 22 September 2026 — previous C4 status/heal follow-up, PARTIAL

Read `docs/testing/c4-source-catalogue-v1-75-2026-09-22.md`
and `docs/roadmap/DungeonMMO_Roadmap_v1_75_C4_Status_Heal_20260922.md`.
The six **source-inventoried** Human/Elf starting and partial first-
transfer classes now have **331/396 real functional analogue ranks**,
with **65** source rank entries still unmapped. The original C4
first-transfer source tree remains **0/9 complete**, and seven distinct
class inventories have yet to be source-enumerated/implemented.
`C4CatalogueCoverage.report().Completed` still correctly returns FALSE.

New: three real level-14 Mystic Battle Heal ranks, bought Scout
standing/running melee evasion, the timed active Scout evade, and
Elf-only physical guard. Focused Studio: Battle Heal 28, passive
286, Scout inventory 1073, active status 24, Base source 57,
strict coverage 7 assertions PASS. An unpublished real Play client
verified **18** hotbar skill effects including actual server
`ScoutEvasiveFocus` and `ElvenScoutGuard` statuses. Existing
stale Fighter trainer four-row regression was corrected in GitHub;
focused TrainerCataloguesTest now PASSES 13 assertions.

NEXT: implement the remaining **21** base and **44** Scout
functional source rank entries, plus seven entire original
first-transfer class source inventories and real abilities.
No `main` merge or publish; no production DataStore work.
All scripts and documents straight through GitHub; remote only
for fast-forward pull, TEMP builds, unpublished Play and logs.
The separate Phase2A paid-revive automated failure is still open.


## 22 September 2026 — v1.75 C4 Scout evasion and first-tier heals

Read `docs/testing/c4-scout-evasion-base-healing-2026-09-22.md`
and `docs/roadmap/DungeonMMO_Roadmap_v1_75_C4_Scout_Evasion_Mystic_20260922.md`.
Current actual C4 source coverage is Human Fighter 36/39,
Elf Fighter 41/43, Human Mystic 36/44, Elf Mystic 34/42,
Human Rogue 77/99 and Elven Scout 104/129.
**328/396** mapped functional analogue ranks for the SIX
source-inventoried classes; **68** still missing in these
six, plus SEVEN first-transfer source class catalogues not
yet inventoried. ZERO of nine original Human/Elf C4
first-transfer classes are complete.

New server mechanics: Scout level-24 evasion chance +3%
on direct enemy melee, level-28 moving-only additional
+2.5%; Mage Battle Heal three levels at 14 with genuine
MageHeal delivery and rank prerequisites; Human-only
Life Drain two ranks at level 14 that actually heal
the living original caster by 20/30% of confirmed
hostile NPC damage. All source/race/class/trainer gates
are server owned. Unpublished Studio: 286 Scout passive,
1070 Scout inventory, 28 Battle Heal, 11 Life Drain,
37 actual saved-profile trainer/proficiency, 57 base
source, 7 strict overall-coverage assertions PASS.
Real Play client 16 hotbar-to-combat abilities PASS,
including authentic Battle Heal and Life Drain impacts.
Base and Dungeon disposable Rojo compositions PASS.
The strict completion gate correctly remains FALSE.

NEXT: real recipe crafting, Human sitting recovery,
party heals, poison cure/status and attack debuffs for
21 remaining base rank entries; Scout missing-family
ledger currently 22 Human and 25 Elf. Separately
source-enumerate/build all seven untouched C4 first
transfer classes and integrate their class quests/trainers.
Do NOT treat analogous DungeonMMO role classes or rank
metadata alone as source parity. Real saved-player
trainer GUI, RNG dodge real-hit sample, multiplayer and
the unrelated Phase2A paid-revive auto-test remain open.
No main merge, publish, real DataStore or paid operation.
All code/docs edited in GitHub; Remote Desktop only for
fast-forward pull, TEMP build, unpublished Studio tests
and diagnostic log reads.


## 22 September 2026 — v1.74 C4 basic and first-transfer audit PARTIAL

Read `docs/testing/c4-base-first-transfer-coverage-2026-09-22.md`
and `docs/roadmap/DungeonMMO_Roadmap_v1_74_C4_Base_First_Transfer_20260922.md`.
The current source-backed completion test is
`scripts/studio/c4_catalogue_coverage_tests.luau` and its production
audit is `C4CatalogueCoverage.report()`. The final audited
Human/Elf starting rank counts are Human Fighter **36/39**,
Elven Fighter **41/43**, Human Mystic **31/44**, Elven Mystic
**31/42**. The two partially mapped C4 first-transfer
inventory totals remain Human Rogue **75/99** and Elven Scout
**102/129**. This is **316 functional analogue ranks of 396
sourced rows**, with 80 missing; seven OTHER first-transfer
class catalogues are still UNMAPPED. Exactly **0/9 original
Human/Elf C4 first-transfer paths are complete**.

The latest real additions are three worn-robe-only Mystic
level-one passives (actual basic attack rate, ManaService
regen and server magic skill cast wind-up) and level-one
Novice Protection (2% real physical NPC mitigation until
character level 20). Base Rojo now mounts the required
CombatStatusService; old missing-Combat error is fixed.
Focused tests PASS: Mage robe 38, novice 36, production
isolated-profile trainer/save/reload 32, branch-tree 44,
latest base audit 63, unified completion gate 7 assertions.
Both Base/Dungeon TEMP Rojo compositions succeeded. No
new full live-client, saved-profile trainer GUI or cloud
test is claimed after these changes.

NEXT: complete exact missing skill families shown in the
linked source-audit ledger, then source-inventory and
implement Human Warrior/Knight/Wizard/Cleric and Elven
Knight/Wizard/Oracle as SEPARATE first-transfer choices.
The current game's Ranger/Rogue starter and original
secondary class trees cannot be silently labeled as
the nine original C4 first-transfer classes. The separate
Phase2A paid-revive auto-test remains open. All scripts,
tests and docs through GitHub only; Remote Desktop only
fast-forward pull, TEMP builds, unpublished Studio tests
and log reads. No merge, publish, paid work, PROD save
mutation or repeat old dungeon wipe/aggro/revive loops.


## 22 September 2026 — C4 Scout catalogue v1.73, PARTIAL and tested

Read `docs/testing/c4-scout-source-catalogue-2026-09-22.md`
and `docs/roadmap/DungeonMMO_Roadmap_v1_73_Scout_Catalogue_20260922.md`
before changing more source or trainer data. The complete *first-transfer*
C4 Human Rogue (99 rows) and Elven Scout (129 rows) inventories at
20/24/28/32/36 are in `C4ScoutSkillInventory.luau`. Functional
DungeonMMO analogue coverage is currently Human **75/99**, Elf
**102/129**, with **24 Human + 27 Elf source ranks still missing**.
The inventory's `audit(race_id).MissingFamilies` lists every
unimplemented source family and exact rank count. Its test explicitly
fails completion while any source ranks are missing. These figures
are source FIRST-TRANSFER coverage, not the whole C4 game.

Latest additions: Human critical-power rank 1/2 at level 24/32,
Human critical-rate rank at 28, Elf critical-rate at 32, shared
Scout Fleet Foot at level 28, and Human level-36 Scout Rapid Hands
which reduces real basic-attack timing by a bought 6% rate boost.
Race/class/level/actual purchased
rank gate and real server crit damage/chance and Humanoid movement
are wired. Focused tests: **254 passive**, **1066 source-audit**,
**38 actual trainer/save-reload** assertions, plus actual
unpublished Play client eight skill effects, light armour,
`SCOUT_REAL_MOVEMENT_SPEED_PASS`,
`HUMAN_CRIT_REAL_DAMAGE_PASS` and
`VERIFIED_PLAY_MODE_PASS`.
All project scripts/docs/fixtures were changed in GitHub;
remote connection only clean-pulled and ran TEMP builds/tests.

**NEXT:** implement remaining missing source families as *real*
server behaviours with their own focused tests, not dummy ranks:
continuous-MP toggles, genuine evasion/recovery, support cleanses,
movement debuffs, key/door and crafting systems. Then reconcile
historic Fighter/Mage 13/16 mismatched base-class brackets and
source-map later class paths. FULL C4 CATALOGUE IS NOT COMPLETE.
The old Phase2A paid-revive automatic regression is separate and
unresolved; do not claim full Dungeon green. No `main` merge,
Roblox publish, real DataStore operations or repeat of old dungeon
wipe/aggro/revive/Play Again tests.


## 22 September 2026 — v1.72 Rogue bleeding backend

Read `docs/testing/c4-rogue-bleed-2026-09-22.md`
and `docs/roadmap/DungeonMMO_Roadmap_v1_72_Rogue_Bleed_20260922.md`.
Final focused live-client fixture `2ea9152` passed
server-confirmed Rogue Lacerating Cut and all
previous Ranger/Rogue control skills. The real
tagged NPC lost three additional 3-HP server
bleed ticks after initial damage, then the effect
expired with no fourth tick. Existing DamageService,
threat, contribution and skill proficiency credit
are used. The server cancels ticks on invalid
attacker/target and replaces instead of stacking.

Lacerating Cut rank 1 at lv24 requires fully
purchased and use-mastered Vital Blow/Disrupting
Cut; rank 2 at lv32 requires use-earned skill
proficiency 120. Focused 19 progression assertions
and isolated real trainer purchase/save/reload
20 assertions PASS. Base and Dungeon builds PASS.
C4 source Bleed level bands match, but exact
C4 uses a DAGGER: current one-handed sword is
a compatibility path, never claim weapon parity.

**NEXT:** continue source-backed shared first-transfer
Rogue/Scout and Fighter/Mage rank-volume inventory;
build real remaining utility/passive/combat effects
instead of padding counts; add dagger support before
exact C4 equipment claims. Full C4 catalogue is NOT
complete. Real player trainer GUI/ordinary physical
input and production or published multiplayer were
not tested. The unrelated Phase2A paid-revive
auto-test remains open before release.

All code/docs/test edits through GitHub only.
Remote Desktop permitted solely for clean pull,
TEMP Rojo build, unpublished Studio tests and logs.
Do not re-run unrelated old Dungeon wipe/aggro/
revive/replay loops or merge/publish without approval.


## 22 September 2026 — v1.71 Ranger/Rogue control slice verified

Read `docs/testing/c4-ranger-rogue-control-skills-2026-09-22.md`
and `docs/roadmap/DungeonMMO_Roadmap_v1_71_Ranger_Rogue_Control_20260922.md`.
Latest gameplay source: `f927f0d`. Two rank-1/2/3
abilities are actual server-owned combat, not inert
catalogue entries. Ranger BriarVolley uses a two-target
penetrating projectile and 1.5/2/2.5 s Human or
2/2.5/3 s Elf slow; Rogue DisruptingCut applies
0.35/0.50/0.70 s stagger after confirmed melee
damage. New ranks unlock at 5/10/15 and require
40/110 earned proficiency for ranks 2/3. Both are
owned class/trainer/weapon-gated.

Evidence: 41 focused class/effect assertions, 46
real isolated SkillProgressionService purchase/persistence
assertions, and a real unpublished Play client slowing
TWO tagged targets and staggering one; final live
fixture `19cfeb5` PASS. Stale RogueDefinitionsTest
now asserts raw five-skill catalogue vs gated visible
offers; isolated test 45 assertions PASS. Prior
auto-run Rogue error came from older TEMP binary;
the separate Phase2A paid-revive test is still open.

**NEXT:** source-map C4 Human Rogue/Elven Scout level-20
shared and divergent ranks without doubling reference
counts for both current Ranger and Rogue; implement
additional real control/utility/passive content with
focused tests and later a real saved-character trainer
GUI-to-combat test. Do not claim exact C4 parity,
real-client trainer purchase or general Dungeon green.
All edits via GitHub ONLY. Remote access only for
clean pull/TEMP build/Studio test/logs. No publish,
`main` merge, force-push, production data or old
Dungeon wipe/revive/aggro/replay regression cycle.


## 22 September 2026 — real-client C4 skill effects verified

Read `docs/testing/c4-new-skill-live-client-2026-09-22.md`.
Latest gameplay composition `755fab0`; final test fixture `c944ddd`.
An unpublished Dungeon Studio Play client used the real
CombatInputActions hotbar path to apply DawnWard (ward and
12 actual mana), CinderBolt (TrainingDummy damage and
10 actual mana), Ranger ArcherDraw (damage) and Rogue
Vital Blow (rear-positioned damage). Existing server
combat handlers were not bypassed. Actual SkillsMenu
rendered a *simulated* learned-rank snapshot and hid
foreign-class skills; no live saved-profile trainer
transaction, physical keyboard input or rear-bonus
comparison was claimed. Focused `VERIFIED_PLAY_MODE_PASS`.

The same automatic Dungeon boot reported unrelated failing
`Phase2AFailurePathTest` and `RogueDefinitionsTest` suites.
Investigate these separately before broader regression/release;
do not label this run full Dungeon green. C4 Fighter/Mage
rank-volume mismatch 13/16 and Ranger/Rogue source-rank
mapping remain open.

**NEXT:** source-map and implement additional *real-effect*
C4-inspired skills/ranks (Ranger/Rogue and later advanced
classes), then target real saved-profile/trainer progression
and rear-damage comparison in one focused client test.
Do not repeat old wipe/revive/aggro/replay loops. Code,
fixture and docs edits **only through GitHub**; Remote
Desktop may fast-forward pull, build and run Studio tests.
No place publish, main merge, force-push or production data.


## 22 September 2026 — v1.70 all-family C4 progression PASS (partial catalogue)

Read:
`docs/roadmap/DungeonMMO_Roadmap_v1_70_All_Four_C4_Class_Families_20260922.md`
and
`docs/testing/c4-all-four-class-families-2026-09-22.md`.
Latest focused-tested gameplay source: `687e27c`.

C4-style skill progression now spans every **currently
implemented** base family: Fighter, Mage, Ranger and
Rogue (Human/Elf). Original, server-owned skills reuse
existing physical/rear/ranged projectile/ward/heal/
control executors. Added nine-rank Ranger Archer Draw
and Rogue Vital Blow, six-rank weapon damage masteries,
Arcanist Ember and Spellweaver Aegis, and level/
previous-skill prerequisites across 8 existing
race-specific class paths. A Rogue advanced finisher
requires **full Vital Blow rank 9/proficiency 350**.
Shared server gates check owned advanced race/class,
earned history, level, purchased rank and use-earned
proficiency at trainer, preview, quest start/claim
and skill use. Generic Mage projectile mana-release
spending and source attribution were corrected.

Focus evidence: Base and Dungeon builds; the all-family
test passed **74 assertions** at the final gameplay
head. Directly affected advancement **66** and earlier
specialist skill **60** suites passed at the earlier
`02154e8` head. No claim of normal-client impact.
The read-only volume audit remains **13/16 mismatch**
for its Fighter/Mage source rank brackets; Ranger/Rogue
are not covered by its reference manifest. This work
is NOT a complete C4 skill clone or quantitative parity.

**NEXT:** one targeted real-client Mage + Ranger/Rogue
skill effect/visibility test, then add actual missing
C4-inspired class effects and source-mapped rank
milestones, *without dummy skills or further unrelated
dungeon wipe/revive/aggro regressions*. All source/docs
edits through GitHub only. No Roblox place publish,
`main` merge or production data operations.


## 22 September 2026 — v1.69 Mage starter rank/visibility slice

Read `docs/roadmap/DungeonMMO_Roadmap_v1_69_Mage_Starter_Unlock_Visibility_20260922.md`
and `docs/testing/c4-mage-starter-ward-bolt-trainer-2026-09-22.md`.
Focused tested gameplay head: `e6033e0c1a024837eef62fdea6cecc1c280beb8a`.

New Mage level-one Dawn Ward and Cinder Bolt each have **three
real ward/projectile ranks** trained at 1/7/14, mastery
35/100 for ranks 2/3, SP and class restrictions. New
combat definitions reuse existing server-owned effects.
The SkillsMenu now hides unoffered foreign/future skills
rather than revealing every public skill definition;
ProgressionTrainer shows locked NEXT ranks and their
actual level/prerequisite blockers. Known skills remain
visible, including ones not currently usable in a
different advanced class.

One clean Base Rojo build + **39 focused assertions PASS**;
one read-only source rank audit: **13/16 C4 brackets
mismatched** and 14 older unmapped rank occurrences.
The Mage level-one mapped bracket now explicitly offers
2 new ranks versus a C4 target of 7. Do NOT invent missing
ranks or treat UI source edits as real-client GUI acceptance.

**NEXT:** one *targeted* real-client Mage trainer/Skills
menu visibility + actual new Ward/Bolt input/impact test.
Then explicitly map starter ranks and implement more
genuine C4-era role-skill content until each mapped
rank bracket is satisfied. Do not rerun old dungeon
wipe/aggro/revive tests. Continue GitHub-only code/docs
edits; remote restricted to clean pull/build/Studio logs.
No Roblox publish or main merge.


## 22 September 2026 — v1.68 NEW MAX-HP / HEAL PASSIVES PASS

Read:
`docs/roadmap/DungeonMMO_Roadmap_v1_68_Vitality_Restoration_Ranks_20260922.md`
and
`docs/testing/c4-vitality-restoration-rank-effects-2026-09-22.md`.

Focused tested gameplay source
`3be5de3316c16a531537feb175d119f171a44b67`.
Two **new actual rank/effect families**: Fighter
Stalwart Training (six ranks at 5/10, +5 flat maximum
HP per rank) and Mage Restorative Training (six
ranks at 7/14, +0.012 additive healing multiplier
per rank). They are server-owned, require each
player's class, SP and level, and do not require
proficiency from impossible passive casts. The
existing Base progression refresh applies their
stats after training.

The first focused test exposed missing
`ClassProgressionDefinitions.TeachableSkills`
entries. Those were fixed directly in GitHub,
without bypassing training guards. One clean
Base build, 64 NEW HP/heal assertions and
64 EXISTING damage-passive assertions passed.
The read-only reference audit showed 13/16 C4
brackets mismatched and 14 unmapped skill-rank
occurrences, including Human Fighter level-10
13 authored versus 12 C4 reference. Count equality
at other brackets does NOT prove equivalent skill
content or real client balance.

**NEXT:** source-align missing starter-rank families
and create genuinely usable early defensive/utility/
support content and an honest player-facing trainer
preview. Preserve saved characters/legacy skill
ranks and test only the new feature's focused
contract. Do NOT run the full dungeon
wipe/aggro/Play Again matrix or publish Roblox.
GitHub-only code/docs edits; Remote Desktop
restricted to clean pulls, builds and test logs.


## 22 September 2026 — v1.67 C4-STYLE PASSIVE SKILLS PASS

Read:
`docs/roadmap/DungeonMMO_Roadmap_v1_67_C4_Passive_Ranks_20260922.md`
and
`docs/testing/c4-passive-rank-effects-2026-09-22.md`.

Focused tested gameplay source `08710c1ce8e2390804080d826925e5346b1a48a6`.
Iron Discipline (Fighter) and Arcane Discipline (Mage)
each have six bought ranks; their level 5/10 and 7/14
trainer brackets modify server-owned physical/magic
damage scaling by 0.01 and 0.015 per rank. Passive
rank training needs SP and level, NOT proficiency
that can only come from casting an active ability.
All active mastery/advancement prerequisites remain.

One clean Base build and 64 focused assertions passed.
One read-only audit reports 16/16 C4 mapped brackets
still short, with Fighter 10 authored ranks at 5/10,
Mage 7 at 7/14; no parity or real-client combat
balance claim. NEXT implement other genuinely missing
early skill/rank effects and source-aligned training
schedules, then one targeted actual client-combat test.
Do not rerun full dungeon wipe/aggro/revive suites.
Only edit scripts/docs via GitHub; local remote use
is restricted to clean pull, builds, tests, diagnostics.
No Roblox publish or `main` merge.


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


## 22 September 2026 — C4 EXACT SKILL VOLUME IS A NEW, OPEN REQUIREMENT

User requests Lineage II **Chronicle 4**, specifically
the **same number of skill rank offerings per level
and corresponding class**, not just structural inspiration
or four new basic ability icons. Read
`docs/design/C4_Skill_Count_Parity_20260922.md`
and `docs/roadmap/DungeonMMO_Roadmap_v1_65_C4_Skill_Volume_20260922.md`
first. Level-5 C4 Human Fighter has 13 listed rank
entries, many multiple ranks of the SAME ability.
The original 3-rank DungeonMMO prototype is nowhere
near complete C4 density. Do not claim that v1.64
completed the newer exact-volume user request.

Initial GitHub count manifest contains 16 verified
Human/Elf Fighter/Mystic level brackets, including
race-specific differences; `c4_skill_volume_audit.luau`
reports all **16 mismatched** and **14 race/class occurrences of unmapped skills
(7 distinct existing skill families)** at first source
`29d117a`. The report is intentionally conservative
because legacy skills lack explicit rank-level data.
No source gaps should be padded with nonexistent or
effectless skills. The Ranger/Rogue level-one split
does NOT correspond one-to-one to C4's level-20
Rogue/Elven Scout hybrid bow/dagger class; document
shared skill trunks before copying counts.

New basic Fighter/Ranger/Rogue rank milestones aligned
to C4-style levels 5/10/15; Mage Aether Bolt to
7/14/20. One Base Rojo build, focused level/mastery
test and read-only volume audit executed successfully.
The auditer is forward-compatible and should
eventually report parity for each completed source
slice, not require the gap to remain positive.

**NEXT CONTENT WORK:** build full original class
skill rank inventories at verified C4 brackets;
implement active, passive, craft and utility effects
with level-gated rank upgrades; expand the reference
count manifest to all branches and levels. Preserve
existing progression/proficiency/profile services,
no invented rank offerings, and no old dungeon-wide
test loops. Exact full C4 parity is NOT YET DELIVERED.
All script and doc edits MUST be made in GitHub;
remote access is for clean pull/build/focused tests,
never file editing. No place publish or main merge.


## 22 September 2026 — v1.64 skill mastery and taunt XP: local PASS

Primary [roadmap](docs/roadmap/DungeonMMO_Roadmap_v1_64_Skill_Mastery_Level_Gates_20260922.md)
and [focused acceptance](docs/testing/dungeon-skill-mastery-lineage-style-2026-09-22.md).
Level/mastery source `bf93f07`; latest taunt XP source
`e0e2f39`. All source and documentation edits via GitHub.

The user wants an original Lineage II C4-inspired
**earned skill ladder**, not skill access simply from
choosing a class. Fighter/Mage/Ranger/Rogue gain one
additional *real combat* basic skill at levels
8/14/20. Initial class trial requires level 20 and
two core skills at purchased rank 3 plus full earned
proficiency. Specialist Fighter/Ranger skills require
their specific active advanced class, basic mastery,
level 24 to learn and levels 28/32 for later ranks.
Unknown skills are hidden from trainer/journal until
eligibility; the server independently guards purchase,
class claim and combat use. The level cap is now 40,
preserving the previous level-1-to-20 XP curve.

After the preceding message timeout, checked the
existing local focused receipts: 62 mastery assertions,
44 level/XP assertions and five directly affected
existing contracts PASS at `bf93f07`. Found that
successful zero-health-damage Taunt/VanguardChallenge
had generated threat but no proficiency, making later
ranks unattainable through normal use. The combat server
now awards meaningful capped control proficiency after
a confirmed NPC taunt. A clean fast-forward, one Dungeon
Rojo build and seven focused taunt mastery assertions
passed at `e0e2f39`. No old Dungeon boss/wipe/revive
matrix was rerun.

**NEXT:** extend actual basic and specialist class
skills, notably Mage/Rogue, while preserving the
current profile's existing skill histories. Then make
locked/available requirements readable in the player's
trainer/advancement UI and run a *single targeted*
real-input skill effect check. Do not assert a complete
C4-sized skill tree, final progression balance,
published network reconnect or cloud acceptance.
No Roblox publishing, `main` merge, force-push or
production data mutation was performed.


## 22 September 2026 — v1.63 NEW class/role skill content

Latest gameplay/test source:
`b017fbce6aceb2a9ba301057a145697a471320ab`.
[Roadmap](docs/roadmap/DungeonMMO_Roadmap_v1_63_Class_Progression_Role_Skills_20260922.md)
and [evidence](docs/testing/dungeon-class-progression-expansion-2026-09-22.md).

Lineage II/WoW design reference is earned class evolution
and legible party roles, **not** reuse of their IP or
an obligation to make more regression fixtures. New
race-specific level-20 paths: Human Vanguard and
Elf Thornwarden (tank), Human Sharpshooter and Elf
Windrunner (ranged damage). Temple/Mine advancement
trials persist through existing Quest/Class services.
Base class advancement remotes expose Start/Claim/Snapshot.

Four actual ranked skills now use the existing combat
executors: Vanguard Challenge threat, Thornwarden
Bash stagger, Sharpshooter Pierce and Windrunner Volley.
Specialist trainers + server-side advanced-class gating
deny cross-class use even after a learned skill persists.
Generic client RangerVolley aim now supports the new
skill. Base class advancement **66 assertions**, prior
story quest **40 assertions** and advanced abilities
**60 assertions** passed with focused local builds.
No full room/aggro/revive/backend regression was run.

**NEXT:** Implement/accept ONE targeted real-client
specialist ability flow and the visible Base quest/
class/trainer board, then continue real item and class
content. New ability hit effects and balance are
NOT proven merely by the data/service tests. No
published cross-place travel/cloud acceptance,
`main` merge or public game release. Any source/docs
edits MUST stay in GitHub; remote use only for clean
pull/build/Studio verification.


## 22 September 2026 — started NEW progression content (v1.62)

Read:
`docs/roadmap/DungeonMMO_Roadmap_v1_62_Story_Quest_Backend_20260922.md`
and
`docs/testing/story-quest-backend-slice-2026-09-22.md`.

The previous consolidated audit found real-client individual
Temple/Mine boss wins and assisted multi-client reward completion.
Only one representative fully normal-input party journey remains
as later integration evidence; DO NOT rerun the complete
dungeon matrix, wipe/revive, aggro or replay fixtures now.

New GitHub gameplay source `89d8e7e` adds two one-time,
same-character prerequisite story quests (Temple Worldroot
relic -> Mine ore), atomic Gold/item claim via QuestService,
and validated Base QuestActionRequest/QuestActionResult/
QuestSnapshot remotes. Class advancement remains separate.
One Base Rojo build and 40 focused QuestService assertions
passed in unpublished Studio. No finished Base quest board/
journal UI or actual client request journey is claimed.

**NEXT:** wire a minimal visible quest board to the existing
Base remotes and do ONE focused client story start/claim test.
Then add truly new class/loot/profession game content using
current services, not another foundation. Published TEST
rejoin, cross-place travel and real cloud data stay deferred.
Only GitHub may edit code/docs; no publish or `main` merge.


## 22 September 2026 — consolidated backend gap audit / STOP repeated test loops

Read `docs/roadmap/DungeonMMO_Consolidated_Backend_Audit_20260922.md`
before proposing the next task. The user requested one
remaining-work inventory rather than another cycle of
wipe/aggro/revive/Play-again regression. Existing v1.61
local acceptance remains valid at its recorded commits;
no new gameplay source or tests were changed by this
GitHub-only audit.

Next: inspect for an **already existing** representative
four-player normal-input dungeon clear → per-member
reward/unlock → next-depth entry fixture. Create or
complete only its genuinely missing integration parts;
if adequate evidence already exists, do not rerun it.
Then move to NEW MMO content: class/quest/loot
progression, tiered professions/economy, weekly boss/raid
mechanics, and separately scoped guild/castle competition.
No new framework for already accepted session, reward,
aggro or party authorities. Run focused tests per change,
a relevant integrated test per milestone, broad regression
only for closeout/merge/release. Published TEST, genuine
same-account network rejoin and cloud persistence remain
separate approval-gated activities.

Audit scope is GitHub Markdown roadmap index/supplements,
current-state and source inventory; the historical v1.47
Word file was not independently parsed. No Remote Desktop,
Roblox publish, `main` merge, force-push or production
profile operation was performed.


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


## 21 September 2026 — SecretArena, Depth4 mini-boss, boss peer-leave VERIFIED

Latest focused tested source:
`9a63c6d25ac45cd67c9a4c5a684fa4c5a26adb24`.

Four real unpublished Studio clients successfully wiped/re-entered
a physical Temple SecretArena boss (optional gate opened only in
the disposable fixture) and a separate physical Depth4 Room2
mini-boss (using the **Depth4** layout anchors, not Depth1).
Earlier room clears, six-depth encounter planning, the current
checkpoint and full-health new boss spawning were preserved.

A genuine fourth client disconnected **during** the active
Depth1 Room3 boss fight. The remaining three clients kept the
boss active, then wiped and free-revived at the saved checkpoint.
The absent member remained disconnected with their free
revive unused. Re-entry spawned one full-health boss and
earlier rooms stayed cleared. The new fixture awaits
persisted post-wipe encounter states, avoiding a previously
observed false-negative immediate read.

The existing Depth2/Depth4 optional party wipe regression
was aligned with the production fix for one-shot terminal
Failed broadcasts and passed **392 assertions** across
Temple/Mine and 1/2/4-person parties. Six Rojo builds,
Dungeon backend 30/30, death/revive 41 assertions and
independent physical SecretArena, Depth4 and disconnected
boss tests passed in local unpublished Studio.

**Remaining**: actual same-account rejoin, normal client-attack
and boss reward reattempt, higher-depth completion and
fresh-session replay, and published TEST reserved/cloud
continuity. None of the latter should be claimed from the
current tests. No Roblox publish, `main` merge or force-push.

Evidence:
`docs/testing/dungeon-secret-depth4-disconnect-recovery-2026-09-21.md`.
Roadmap:
`docs/roadmap/DungeonMMO_Roadmap_v1_59_Secret_Depth4_Disconnect_20260921.md`.


## 21 September 2026 — real four-party room/boss/event + replay closeout

Latest locally verified gameplay head:
`a5c0637888f8400703d07290f790a24d3b8406bf`.
Four **real unpublished Studio clients** recovered together
from a physical Temple Room1 wipe. One monster had already
produced four actual RewardService receipts; the same
monster's post-wipe second kill granted **no duplicate**
Gold/XP/Level/bestiary count to any party member.
The Room1 checkpoint revived all four players; fresh
full-health enemies spawned after physical re-entry.

The real Room3 boss, and a Temple optional EventArena boss
enabled **only in the disposable Studio fixture**, also
passed four-client death/automatic revive/re-entry tests.
Earlier cleared rooms persisted and each retired boss was
replaced by exactly one new full-health boss.

A new real-client Play again regression exposed a gameplay
bug: terminal `DungeonDeathService:tick` announced failure
on every subsequent tick and wiped out the party's
`ReplayWaiting` UI. Fixed to announce the transition
once and added a backend assertion. A repeat two-client
test then passed authenticated replay requests, waiting
for the other player and simulated replay displayed on
both clients. This test seeded a temporary Failed
session and did not publish or teleport across places.

At latest gameplay head: all six Rojo builds; Dungeon
backend 30/30 and death/revive 41 assertions PASS.
At the preceding fix head: ThreatService 51, Base
professions 14/14 and paid retry 15 PASS.
All source/doc edits through GitHub only.

**NEXT local-only:** secret/higher-depth boss recovery;
actual player disconnect/reconnect during a physical
encounter and boss reward idempotence across full fights.
Published reserved-server Play again/cloud persistence
need separate approval. No place published, `main` merged,
force-pushed or PROD datastore mutated.

Receipt:
`docs/testing/dungeon-four-client-room-boss-event-replay-2026-09-21.md`.
Roadmap:
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


## 21 September 2026 — next backend handoff after four-client wipe

Verified source/test head:
`739e747d88d93ff00ed30497e9473edd17b037f4`.
The real four-client two-Marauder fixture passed nearest fallback,
server-authorized damage/heal/Taunt threat, independent ledgers,
dead-healer fallback, genuine DPS client departure and a complete
death of all remaining clients. A previously engaged enemy now
clears **only threat and eligible target cache** after three
continuous seconds with no valid target. Actual fixture and
server logs: `REAL_DISCONNECT_CLEANUP_PASS`,
`REAL_FULL_WIPE_THREAT_RESET_PASS`,
`VERIFIED_FOUR_CLIENT_PASS`.

Six Rojo builds; focused ThreatService 51; Dungeon backend 30/30;
Base professions 14/14; genuine two-client world-boss aggro and
support-skill Play on the correct isolated world-boss composition
all PASS at this source. The former boss timeout came from
using the ordinary Dungeon composition and is superseded.
One moving-enemy Taunt miss during the new wipe fixture was
handled by a genuine cooldown-respecting retry; server skill
validation was not weakened.

**NEXT (local-only):** full dungeon-session wipe/retry and
respawn/checkpoint/reward invariants. The current controller does
not restore enemy health/position or restart the boss; do not
describe threat-only cleanup as full dungeon reset. Preserve
existing accepted Play gates. Keep all source, tests and docs
in GitHub; desktop may only fast-forward pull/build/test/diagnose.
No Roblox publishing, main merge, force-push or PROD data writes
without separate approval.

Receipts:
`docs/testing/four-player-full-wipe-threat-reset-2026-09-21.md`
and roadmap v1.55 Markdown supplement.


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

## 21 September 2026 — aggro/threat and Taunt handoff

The active branch now has one shared `ThreatService` for ordinary
Marauders, Dungeon Captain-style enemies and the isolated world boss.
Target rule: nearest eligible player while no eligible positive threat
exists; highest eligible threat after that, with distance only as an
equal-threat tie-breaker. Damage threat comes only from actual
DamageService-applied health damage and is isolated per enemy.

Fighter `Taunt` is a real learnable/rankable zero-damage skill from
the Fighter Trainer. It passes the ordinary client skill request,
server skill authority, melee target geometry and cooldown/stamina
checks before applying server-owned Taunt threat. Real normal-enemy
and world-boss multiplayer logs both showed `SKILL ACCEPT Taunt` and
`THREAT TAUNT` with no fabricated damage.

Rogue ThreatDrop and existing combat aggro suppression are honored by
both target controllers. Enemy death/reset clears threat. A later
test-only rerun also proves a dead current threat leader drops out and
the living eligible player becomes the target.

Accepted runtime source:
`9c744d0cfe4ecabd5b372229e446ceadc6653861`.
Six builds; ThreatService 14; real normal aggro PASS; real world-boss
aggro PASS; Fighter Trainer 12; profile exit 18; weekly reward retry
17 Base + 17 Dungeon; Base professions 14/14; Dungeon backend 30/30.
One-hit lethal contribution/reward and accepted two-client boss Play
also passed. Death fallback passed in both two-client fixtures at
test-only head `e041bf2203c8b73b0c1c9b59aebc175a2c8cbddd`.

**NEXT, local only:** support/healing/ward threat policy and real
support-skill Play, then four-player tank/DPS/support threat changes,
multi-enemy room ledgers, full-wipe/reset cleanup and controller-level
disconnect cases. Do not publish or start cloud persistence without
new user approval.

Receipt:
`docs/testing/combat-aggro-threat-taunt-local-2026-09-21.md`.
All edits stay GitHub-only; Remote Desktop remains pull/build/test/
diagnostics only.

## Earlier 21 September local-only continuation handoff (historical)

## 21 September 2026 — LOCAL-ONLY backend continuation handoff

**User direction:** do not publish or configure a published TEST
journey yet. Do any backend work possible locally. Source, test and
documentation edits belong in GitHub; Remote Desktop must only be
used for a clean fast-forward pull, local Rojo/Studio tests and
read-only diagnostics when it is available.

World-boss first-hit kill contribution is now fixed: DamageService
passes server-observed lethal-hit evidence via CombatService into
DungeonContributionBridge, and the boss authority allows the
matched fatal hit after Humanoid health reaches zero without
accepting ordinary post-defeat support or unrelated targets.
The separate one-client one-hit fixture passed all four acceptance
markers on source
`5b7edc2675fd8fc6e9b6d0908bdf263742cf88b6`.
An earlier source with the combat callback change also passed
the pre-existing full-client and two-client Play regressions.
The initial one-hit fixture *failed* because it was out of range;
the corrected position produced the accepted result.

Local in-memory reward recovery (17 assertions in Base and Dungeon)
and failed departure-save lease retention (11 assertions) previously
passed. The newly added post-save **lease-release** failure and lethal
impostor filter assertions are pushed to the branch, but not accepted
yet because the authorized desktop became unavailable before a new
same-head test run. Do not confuse successful earlier assertions
with a passing test of the new code.

A real MageHeal two-client experiment failed on inconsistent
Studio injured-target health and was reverted from the accepted
melee/defeat fixture. Mend now records effective pulses, but neither
client-driven peer Heal nor Ward is certified in the world-boss
encounter. Keep a dedicated support test separate from the
accepted real two-client melee fixture.

**NEXT, still no publishing:** safe GitHub pull and six Rojo builds,
one-hit client Play, existing two-client Play, expanded damage
filter, post-save profile-exit and Base/Dungeon reward-retry
contracts. Run profession and Dungeon backend regressions.
Then tackle dedicated real peer healing/ward skill verification,
four-player party/death/wipe/individual return and additional
in-memory adapter failure/recovery cases. Only after fresh user
approval revisit published TEST travel and cloud persistence.

Receipt: `docs/testing/weekly-world-boss-v154-local-backend-continuation-2026-09-21.md`.
No place publish, cloud player-data mutation, force-push or
main merge has been performed in this continuation.

## Earlier 21 September party handoff (historical)

## 21 September 2026 — two-client world-boss party resilience handoff

The active branch now has a reusable `WorldBossMemberLifecycle`,
an opt-in geometric `WorldBossArenaLayout`, and verified two-client
world-boss Play. Two real Studio clients independently damage one
guardian, persist contribution and each receive their own weekly
reward once. One client then dies through its owning client Humanoid,
the server persists Dead mode, respawns that member into the same
session as Active and proves death/respawn cannot duplicate reward.
One client can then leave while the surviving peer remains active.

ContributionService and DungeonContributionBridge now accept negative
integral Roblox Studio multiplayer UserIds **only in Studio**. This
was required because ExecuteMultiplayerTestAsync clients use negative
IDs. Production/live identities remain positive-only and all malformed
IDs/events remain rejected.

Current wipe policy: connected dead members may respawn independently
into the same frozen encounter; wipe/death does not reroll event/week
or reset reward history. The arena helper is primitive geometry for
backend testing only and can be replaced by final authored art while
preserving `WorldBossArenaSpawn`.

Final accepted source:
`e83e4fae522582ec98bfc9cf4938ffdca9aa810b`.
Final local matrix: six Rojo builds; multiplayer
`VERIFIED_MULTIPLAYER_PASS`; lifecycle/wipe 14 assertions;
contribution 20; Base travel 18; Base return 22; Dungeon session 33;
Base professions 14/14; Dungeon backend 30/30.

**NEXT:** published TEST-only handoff. Configure explicit TEST Base
and world-boss place IDs, keep the event off outside the controlled
window, then prove Base → ReserveServer boss → Base using genuine
profile lease and MemoryStore/DataStore handoff. That is also where
same-account network reconnect and cross-server reward recovery must
be accepted. Separately add a real two-client healing/ward skill test
against the guardian before public release.

Roadmap: `docs/roadmap/DungeonMMO_Roadmap_v1_54_Weekly_World_Boss_Foundation.md`.
Receipt: `docs/testing/weekly-world-boss-v154-party-resilience-2026-09-21.md`.
All source/test/docs editing remains GitHub-only. Remote Desktop is
restricted to clean fast-forward pulls, Rojo builds, Studio tests and
read-only diagnostics. No cloud publish, production player DataStore,
force-push or main merge.

## Earlier 21 September real-combat handoff (historical)

## 21 September 2026 — real world-boss combat handoff

The active branch now includes the existing CombatService/client
controls and Marauder Captain AI in the isolated world-boss
composition. The world-boss runtime marks admitted characters with
the frozen weekly encounter ID and binds the shared contribution
bridge through WorldBossCombatAuthority.

Damage contribution now requires the exact active guardian Model and
an admitted player. The authority also verifies connected/non-abandoned
session membership, matching encounter attributes, a live guardian and
an undefeated weekly snapshot. Healing/ward support must target an
admitted member. Ordinary Dungeon behavior is unchanged because the
damage-target validator is optional and unset there.

A genuine unpublished Studio client used the normal attack RemoteEvent.
The guardian lost health through CombatService/DamageService, the
same hit persisted ContributionService damage, the existing guardian
AI damaged the player, and the player killed the guardian without
direct health injection. The session bridge persisted defeat, server
contribution certified completion eligibility, first weekly claim
paid 100 provisional gold and the immediate duplicate paid zero.
All final combat markers passed.

The real-client test found/fixed:
- nil indexing when weekly event state was missing/malformed;
- an `event` local shadowing the actual combat event, causing
  `InvalidWorldBossContribution` on genuine hits.

Post-kill reward delivery now retries from the runtime's existing
periodic loop. A contributor with an earned but unsaved reward is
kept in the recoverable boss session instead of being handed to Base.

Final accepted source:
`7605c811bb9f9a13ce2fb56f6b68a76f8c63ae89`.
Six Rojo builds, damage filter 7 assertions, contribution 14,
weekly 40 + factory 8, Base professions 14/14 and Dungeon backend
30/30 passed. Default-off boss-place Play also still passed.

**NEXT:** add a minimal authored WorldBossArenaSpawn/basic arena and
run actual multi-client boss combat. Test shared damage/support,
player death/wipe semantics, one member disconnecting while others
continue, reconnect after defeat, retry of unsaved reward and
independent Base return. Only after that should we configure
TEST-only real place IDs and run the first published Base →
ReserveServer boss → Base journey with real lease and cloud
persistence. Production event flags remain off.

Receipt:
`docs/testing/weekly-world-boss-v154-real-combat-2026-09-21.md`.
All source/test/docs edits remain GitHub-only. Remote Desktop was used
only for clean pulls, Rojo builds, Studio Play and diagnostics.
No cloud publish, production DataStore write, force-push or main merge.

## Earlier 21 September world-boss travel handoff (historical)

## 21 September 2026 — isolated world-boss travel handoff

On `wip/phase-4-test-hud-integration-v1`, the Base weekly entry
now has an optional independent physical gateway using the existing
DungeonBoard. Server-owned explicit UTC event settings and existing
ready-party validation guard reserved-session issuance. The
TeleportCoordinator uses the existing profile/lease handoff,
reserves the separately configured boss place and persists the
world-boss destination/party/week before transfer. An independent
world-boss Rojo place validates the stored session/member and nonce.
Normal Dungeon refuses all boss sessions.

Per-member Base return after a verified defeat uses the existing
coordinator. Its old session index is cleared only after Base
actually loads the member. If the Base teleport fails, the pending
return flag is rolled back to preserve boss reconnect. The runtime
also binds the first verified session before yielding on admission
to avoid cross-party collision in one reserved server.

The real ContributionService.get_player_snapshot returns top-level
Damage/Tank/Support. The original isolated runtime incorrectly
looked for `snapshot.snapshot`, making all actual rewards
unavailable. WorldBossContributionRules fixes that response
interpretation; 14 focused actual-service tests in Base and Dungeon
passed, including saved damage/healing and adapter-style recovery.
This does NOT mean player attacks are yet wired into the isolated
place. Ordinary dungeon/Temple and v1.53 professions remain
unchanged.

Acceptance receipts: isolated travel = six Rojo builds, Base and
Dungeon travel 18 assertions each, Base return 22, ordinary
Dungeon admission 10, destination factory 5, default-off Play,
Base professions 14/14, Dungeon gameplay 30/30 and material-chain
Play PASS. Hardening = Base and Dungeon contribution 14 assertions
each, six final Rojo builds, Base return 22, Base travel 18,
and final session regression 33 assertions in Base and Dungeon PASS.

**NEXT:** integrate the existing combat/client/controller safely
into the independent world-boss place, author a basic arena anchor,
run a real unassisted boss encounter and verify server-validated
damage/support, disconnect/reward retries and individual returns.
Only then consider explicit TEST-only place configuration and
published reserved-server networking. The boss place is
currently disabled/unplayable; no published real-place journey
or cloud MemoryStore/DataStore proof exists. Do not enable
production events or claim the whole travel milestone is released.

Roadmap:
`docs/roadmap/DungeonMMO_Roadmap_v1_54_Weekly_World_Boss_Foundation.md`.
Receipts:
`docs/testing/weekly-world-boss-v154-isolated-travel-2026-09-21.md`,
`docs/testing/weekly-world-boss-v154-travel-hardening-2026-09-21.md`.
All source/test/roadmap/handoff changes through GitHub; remote
desktop restricted to clean fast-forward pulls, unpublished
builds/Studio tests and read-only diagnostics. No cloud publish,
force-push, main merge or production DataStore write.

## Earlier 21 September session handoff (historical)

## 21 September 2026 — frozen weekly boss session handoff

The active branch contains `WeeklyWorldBossSessionBridge` and
`WeeklyWorldBossService.restore_instance`, both composed
server-side into Base/Dungeon RuntimeServices. After an **existing
server-authorized** DungeonSessionService run has InstanceState,
`issue` may store one immutable weekly boss/window/party snapshot.
A matching dead tagged guardian's defeat is written into the
same stored session state. A newly created bridge/service reading
the same map can resume the recorded state and deliver the
once-per-week reward only to a non-abandoned member whose existing
session completion eligibility was certified server-side.

Base and Dungeon session contract tests each passed **30 assertions**
in real unpublished Studio. Original weekly policy 40 each, boss
factory eight, Base professions 14/14 and Dungeon regression 30/30
passed too. Four Rojo compositions were built successfully.

**Immediate next backend:** dedicated world-boss destination/place,
server-authorized default-off Base gateway, reserved-session
handoff via existing coordinator and genuine destination admission.
Do not route an existing ordinary dungeon place to a world-boss
snapshot: the current ordinary DungeonRuntime remains unaware of
this bridge and would continue its normal encounter sequence.
Before release add validated contribution, disconnect and
pending reward semantics in the actual dedicated boss runtime.

The bridge is not hooked into normal portal gameplay.
Tests shared a Studio in-memory session adapter and profile store,
not real Roblox cross-server persistence. No cloud publish,
production DataStore, force-push or main merge took place.
All source/test/roadmap changes were via GitHub; local desktop
only fast-forward-pulled, built and tested.

Receipt: `docs/testing/weekly-world-boss-v154-session-bridge-2026-09-21.md`.

## Earlier 21 September weekly handoff (historical)

## 21 September 2026 — v1.54 weekly world-boss foundation handoff

Source at the active `wip/phase-4-test-hud-integration-v1` branch
contains `WeeklyWorldBossWindow`,
`WeeklyWorldBossService` and the default-off
`DungeonWeeklyWorldBossFactory`. Shared Base/Dungeon
`RuntimeServices` composes the weekly service but no client
RemoteEvent or normal-game entry route invokes it. A trusted
server-issued instance captures the active event window, an
approved party and a stable week ID. A matching tagged dead
guardian is required before the existing character profile can
receive the provisional 100 gold once per week; repeat kills
in another local instance pay zero. Monday 00:00 UTC is the
current calendar reset and the maximum allowed entry window
is two hours, both preliminary rules.

Studio accepted 40 policy assertions in BOTH Base/Dungeon,
eight factory assertions in Dungeon, 14/14 existing Base
profession and 30/30 Dungeon backend regressions. The
unpublished physical Play fixture used a real client prompt,
then spawned and assisted-defeated two guardians: first paid
100 gold in the loaded Dungeon profile and second paid none.
The final fixture disables incompatible autorun layout unit
tests only in its disposable DataModel; the dedicated factory
and general backend regressions were run independently.

**Next backend job:** connect server-authorized schedule/rollout,
real Base portal, existing session/teleport admission, reserved
boss place, persistent instance state and participation-based
reward eligibility without reimplementing the already accepted
dungeon/party/reward services. Test same-account network
rejoin and cloud TEST before enabling any live events.
No public entry, cloud publish, production DataStore writes,
main merge, final guardian rig or dedicated phase attacks.

Roadmap: `docs/roadmap/DungeonMMO_Roadmap_v1_54_Weekly_World_Boss_Foundation.md`.
Receipt: `docs/testing/weekly-world-boss-v154-local-foundation-2026-09-21.md`.
Keep all source, fixtures, roadmap and handoff edits through
GitHub only; Remote Desktop is restricted to a safe fast-forward
pull, unpublished Rojo/Studio runs and read-only inspection.

## Earlier 21 September v1.53 handoff (historical)

## 21 September 2026 — interrupted craft and same-UserId recovery handoff

Active source includes unique craft lock tickets and post-preparation
checks of both ticket ownership and the exact original Player.
This closes the stale-completion/new-lock-release risk on a same-UserId
rejoin within one server's runtime. The pure same-UserId lifecycle
uses a shared in-memory adapter: old request paused → release/save →
same UserId reload → old request resumes but cannot consume/award →
new request successfully crafts and persists exactly once.

Studio Base/Dungeon profession focused suites now pass **14/14**
each (21 craft-guard and 20 reconnect assertions). A real two-client
Base Play test paused server-side crafting and made the originating
client actually leave. The same UserId was reloaded **by the test
driver**, not by a new network connection. The old handler resumed
without touching the reloaded materials; an independent player
continued, and a distinct replacement account joined. Material-backed
Base crafting, wolf Dungeon encounter and the 30-suite Dungeon
regression were rerun and passed after the source fix.

Next: only if permitted by release scope, test *actual* same-account
relogin to a published TEST environment and cross-server lease/
DataStore handoff; do not use real-player production data to satisfy
the Studio test. Keep finished wolf art and dedicated animal AI as a
separate content gate. For any further source/fixture/roadmap changes,
edit **in GitHub only**, fast-forward a clean Windows worktree,
then build and run disposable unpublished Studio validation.
No production publish, force push or main merge occurred.

Receipt: `docs/testing/profession-v153-interrupted-reconnect-local-2026-09-21.md`.

## Earlier 21 September handoff (historical)

## 21 September 2026 — v1.53 latest local backend handoff

The active branch now includes an opt-in `ForestWolf` factory and
`Wolf` archetype. **No production/default packs include wolves**:
Temple Room1 was changed to a two-wolf pack only inside the
unpublished Studio Play fixture. The existing Marauder controller
rig provides temporary animal-like placeholder behaviour and
silhouette; final animal models/AI have not been authored.

The actual disposable Dungeon client/server encounter test passed:
Room1 physical trigger → two wolf spawns → assisted kills → ordinary
reward/room clear → retained looted corpse → real client Skinning →
one server-granted hide and disabled repeat. A genuine Base Play
client also crafted through all material-backed professions to
`warded_leatherbound_gloves`, including repeat/burst checks.
Two actual Studio clients independently crafted, contested one
corpse for exactly one hide and passed a peer disconnect check.
The in-memory two-user contest passed in rebuilt Base/Dungeon
focused runners (13/13 each). The broader Dungeon backend
matrix remained 30/30.

The *initial* burst fixture incorrectly assumed the Base starter
inventory lacked ore; both requests legitimately succeeded. The
corrected, source-versioned fixture cleared starter ore in a
disposable in-memory player and seeded exactly one craft's inputs:
one success/one rejection, no duplicated bar. The *initial*
two-user focused run hung on missing source in a stale Rojo build;
both rebuilds then passed. Do not report these earlier attempts
as passes.

Next backend step: same-account reconnect and interrupted
craft-request cleanup, with an explicit distinction between an
actual network disconnect and pure guard unit tests. Then decide
on release-eligible animal encounters/models only when requested.
Do not enable wolves in default packs merely to satisfy a test.
Do not claim public deployment or real-user DataStore validation.
Keep all future script, roadmap and handoff edits inside GitHub,
then clean fast-forward pull for Rojo/Studio only.

Evidence: `docs/testing/profession-v153-wolf-and-crafting-local-acceptance-2026-09-21.md`.

## Prior 21 September checkpoints (historical)

## 21 September 2026 — local animal-only Skinning test closeout

The server-only species allowlist, beast-tag requirement, defeated/
looted/corpse-once rules, temporary corpse prompt and animal-only
Dungeon cleanup have now passed actual unpublished Roblox Studio
tests. Four Rojo builds, Base/Dungeon focused professions 12/12 each
(363 assertions each), Dungeon cleanup 11 assertions and broad backend
30/30 PASS. Base Play tests proved real server grant and client
depletion at RawHideCache, as well as a server-authored test wolf
producing exactly one hide after death and loot. Existing Marauders
and unregistered enemies remain unskinnable; there are still no
authored animal factories/encounters in gameplay.

The Studio MCP bridge's direct client continued reporting an
unreachable Studio despite MCP being enabled. The official Studio
RunScript CLI successfully ran the unchanged GitHub test runners
and the StudioTestService Play-mode fixtures. Avoid asking the user
to toggle MCP merely to repeat tests already verified by this route.

Continue backend-first with a proper animal factory/content hook
only if needed, then actual combat → server loot → retained corpse →
skin interaction, a two-player contested skin claim, material-backed
Leatherworking → Enchanting client completion and craft
disconnect/retry. The local worktree must remain clean; create code,
new tests, roadmap and handoff edits **in GitHub**, then safely
fast-forward pull only for build/test. No publish, user DataStore
migration, force-push or main merge.

Receipt:
`docs/testing/animal-only-corpse-skinning-studio-verified-2026-09-21.md`.

## Historical staging checkpoint — before the above tests

## 21 September 2026 — animal-only Skinning test handoff

Latest GitHub-first branch is clean and locally fast-forwarded through
`8655c7e19bc97a9b9c803fc011e2e5a3080c47f3`. All four Rojo builds
passed. `SkinningEligibility`, `CorpseSkinningRuntime` and the shared
profession runtime now deny all unregistered and non-Beast enemies.
DungeonEnemyCleanup preserves only registered, defeated animal-like
corpses after reward processing; it never makes Marauders or bosses
skinnable. These are server logic and example future wolf/boar/bear
identities, **not a claim that animal enemies already exist**. The
temporary Base hide cache is still available separately.

The two new focused suites and expanded Dungeon cleanup suite exist in
GitHub but have **not** been executed in Studio. Direct Studio MCP
discovery returned `Unable to reach Roblox Studio right now`, and
delegated Codex Studio testing hit a usage limit. Restore the Studio
Assistant MCP-server connection, then run the versioned focused runner
in disposable Base/Dungeon, Dungeon cleanup tests, broad regression,
and a real server-authored animal corpse Play test. Re-run the Base hide
prompt diagnostic; it previously timed out and is not accepted.
Avoid editing scripts/docs via Remote Desktop: create any revisions in
GitHub, then safely fast-forward pull for local builds/Studio only.

Detailed receipt:
`docs/testing/animal-only-corpse-skinning-pending-studio-2026-09-21.md`.
No publishing, player DataStore migration, force-push or main merge.

## 21 September 2026 — local profession verification handoff

The active `wip/phase-4-test-hud-integration-v1` branch has passed
all four Rojo builds, ten focused profession suites in BOTH disposable
Dungeon/Base Studio places, 30 Dungeon backend suites and the generic
Base Play smoke. The first GitHub-authored live Base client fixture
passed actual near/far RemoteEvent routing at Leatherworking and
Enchanting but **failed** to obtain a Gather result when simulating a
RawHideCache ProximityPrompt hold. Do not promote v1.53 to full local
acceptance or assume the fault is in production gathering rather than
the test-input mechanism.

Next: diagnose the live prompt through a new Github-only test fixture
or actual client action in an unpublished disposable Studio place,
then verify one-time hide claim, live material-backed cross-profession
crafts, rapid same-player requests, independent players and disconnect/
retry. Inspect Base-only unrelated Dungeon test autorun messages.
Use `docs/testing/profession-v153-local-validation-2026-09-21.md`
for exact test results and logs. Keep edits to source, fixtures,
roadmap and documentation **on GitHub**; use Remote Desktop only for
safe fast-forward pulling, local builds, Studio execution and log reads.
No TEST/PROD publish, player DataStore acceptance, main merge or
force-push is authorized.

## 21 September 2026 — GitHub-only initial staging (historical)

The active branch contains unverified-in-Studio profession work above
the accepted v1.52 checkpoint. Do **not** rebuild these changes from
scratch. Read:
docs/roadmap/DungeonMMO_Roadmap_v1_53_Professions_Pending_Verification.md
and
docs/testing/profession-leatherworking-enchanting-pending-verification-2026-09-21.md.

Staged: Skinning/Leatherworking/Enchanting definitions and profile state,
raw-hide Base placeholder acquisition, separate temporary
Leatherworking/Enchanting station roots, cured-leather/warding material
chain, leatherbound and warded equipment, full cross-profession recipe
dependencies, migration/definition/atomic dependency tests, and a
per-player craft RemoteEvent request guard. Craft requests still require
the server-known station and distance; the RemoteEvent accepts recipe_id
only and no client-provided success outcome.

Desktop was intentionally not contacted. Tomorrow first confirm the
existing Windows worktree is clean and at v1.52, then fast-forward pull
the current branch, build all four Rojo compositions, run the focused
profession suite in Base and Dungeon, run the broad backend matrix, then
perform a Base Play-mode near/far/rapid-duplicate/disconnect crafting
interaction. Keep v1.53 status **pending** until those pass.

No cloud publish, real player DataStore migration, force-push or main
merge has been authorized.

## 20 September 2026 — v1.52 Event variation / profession backend handoff

Read docs/roadmap/
DungeonMMO_Roadmap_v1_52_Event_Variations_And_Professions.md
and docs/testing/
phase4-nonboss-event-profession-chain-2026-09-20.md.
Previous after-Room2 side room now has eight spawn anchors and
supports one independently opted-in 4-enemy Ambush or 8-enemy
Surge per run via the existing CombatPack executor. Temple/Mine
Depth2–4 supported. Saved run mechanic ID, encounter ID and
pack ID prevent rerolls or reward identity collisions.
Both normal Event-boss paths, optional Secret and original
Depth1/Depth2 default routes remain compatible. No actual
timed staggered wave, cave-in or novel enemy AI is included.

The existing two profession services also gained a two-way
Blacksmithing/Alchemy recipe dependency using two registered
items: forging_flux and runic_ironbound_gloves. No new
crafting service or new UI. New 46-assertion recipe chain
and seven service/regression suites passed in both local
Dungeon and Base places. All four Rojo builds, 25/25
optional-focused and 30/30 broad backend suites passed.
Independent assisted physical and actual party/disconnect
runs passed for both combat pack sizes; see dated receipts.

Continue backend-first with additional professions:
Leatherworking and Enchanting definitions, acquisition,
recipes, saved progression and anti-dupe/real station
interaction tests. Reuse ProfessionService/Runtime,
ProfessionDefinitions/Recipes, InventoryService and
RecipeKnowledgeService, and avoid model/presentation changes.
Only local test variants enabled new independently default-OFF
Event switches; no TEST/PROD, actual DataStore, main
merge or same-account network reconnect was performed.

## 20 September 2026 — v1.51 late Event physical/multiplayer closeout

Read the latest
docs/roadmap/DungeonMMO_Roadmap_v1_51_Late_Event_Physical_Acceptance.md
and docs/testing/
phase4-late-event-physical-multiplayer-2026-09-20.md.
The previous v1.50 backend-only EventAfterRoom2 insertion now has a
**dedicated, replaceable, physical TEMP side route** for Temple/Mine
Depth2–4. The original EventAfterRoom1 and SecretBeforeFinal
routes still work. Workspace DungeonMMOPlaceholderLateEventPlayEnabled
opts in to the placeholder geometry/layout; independent
ServerScriptService DungeonMMOOptionalBossTemplatesEnabled opts
in to server issuance. Both default OFF, alongside existing
optional/higher-depth release locks. An unissued or uncleared
late Event cannot open its gate; no production release was enabled.

Accepted local receipts: six structural dungeon/depth route
combinations, 85 physical assertions, 24/24 optional-focused
and 30/30 broad backend suites, four Rojo compositions,
assisted Temple Depth2 and Mine Depth4 actual late-bridge
walking Play-mode passes, separate two-client Temple Depth2
and four-client Mine Depth4 shared-run boss/disconnect/
checkpoint/reward lifecycle passes, plus original optional
and optional-disabled Temple Depth2 physical regressions.
True same-account cross-server rejoin, published TEST and
PROD verification, full-party unassisted combat and
finished meshes remain independent future gates.

Do not repeat the accepted fixed-side-room backend. If staying
within dungeon development, add **a genuinely new non-boss event
mechanic** through the existing encounter/executor system, with
explicit room capabilities, run frequency and recovery. Otherwise
prioritise remaining larger MMORPG backends (crafting professions,
raids/world bosses, guild competition/economy) after reading
the roadmap and accepted test matrix. Continue GitHub-first
script changes and local Studio only; no forced merges/publish.

## 20 September 2026 — v1.50 optional placement handoff

Current branch: wip/phase-4-test-hud-integration-v1. Read
docs/roadmap/DungeonMMO_Roadmap_v1_50_Optional_Event_Placement.md
and docs/testing/
phase4-optional-event-placement-templates-2026-09-20.md.
This GitHub-first checkpoint adds an independent default-OFF
DungeonMMOOptionalBossTemplatesEnabled server switch and a shared
EventAfterRoom1/EventAfterRoom2/SecretBeforeFinal catalogue.
The second Event placement is available only at Depth2–4, is saved
at run creation and uses a new EventArenaLate physical room identity.
Existing two original optional routes and selected boss variants
are unchanged. Policy enforces one Event and Secret per run,
rejects duplicate room claims and fails closed if the late slot
lacks an explicitly verified matching after-Room2 placement.

**Do not enable late placement:** No physical EventArenaLate room,
gate, bridge, trigger or spawn is registered. The new template has
only synthetic planning/recovery tests, not a walking playtest or
released boss. Before opening it, register actual replaceable
physical content and synchronize its gate using the saved plan;
validate physical traversal, concurrent party trigger/disconnect
and per-member rewards. Baseline Temple Depth2 normal/variant
routes, 274 template assertions, 23/23 focused suites, 30/30 broad
backend suites and four local Rojo compositions passed. Revisit
other MMORPG backends after this event-location capability is
accepted; do not keep remaking the completed dungeon runtime.
No cloud publish, real account DataStore or authored art changes.

## 20 September 2026 — dynamic optional variant backend closeout

Start from docs/roadmap/
DungeonMMO_Roadmap_v1_49_Phase4_Dynamic_Optional_Variants.md
and docs/testing/phase4-dynamic-optional-boss-variants-2026-09-20.md.
GitHub-first changes reuse DungeonOptionalBossRunState,
DungeonOptionalBossContent, existing boss factories/arena slots and
DungeonSecretDiscoveryService. When
DungeonMMOOptionalBossVariantsEnabled is set by the server only,
a new eligible run chooses one of two event/secret identities from
its deterministic seed and saves that choice; default is OFF.
After an initial physical Secret timeout, the legacy-only discovery
check was repaired to validate the matching saved dungeon-specific
Secret identity. A strict reward test also caught shared inherited
MarauderCaptain IDs between an alternate boss and a returning miniboss:
EventBoss/SecretBoss/MiniBoss/FinalBoss rewards are now scoped to
BossId + runtime encounter ID; Depth1 legacy Boss remains unchanged.

Final acceptance: dynamic variant matrix 2,205; discovery 232;
reward 80; focused 22/22; broader backend 30/30; all four local
Rojo compositions PASS. Temple Depth2 and Mine Depth4 alternate
physical runs, normal variant-disabled Temple Depth2 baseline and
4-client Mine Depth4 alternate multiplayer with one real disconnect,
separate reused-factory rewards and exactly-once three-member final
completion PASS. These are local Studio assisted-combat fixtures:
same-account network reconnect, new reserved-server reconstruction,
real player DataStore, cloud TEST/PROD and unassisted balance remain
outside current acceptance. Do not replace existing dungeon planner
or create a second event scheduler. Next backend step: add more
configurable event templates/explicit insertion capabilities under
the existing fail-closed authority and test each on Depth1–4.

## 20 September 2026 — higher-depth multiplayer backend closeout

Current integration branch wip/phase-4-test-hud-integration-v1.
GitHub-first two- and four-client local Studio TEMP fixtures verify shared
Temple/Mine Depth2/4 eligible runs, simultaneous Event and Secret touch
without duplicate boss spawns, real mid-Event or mid-Secret member removal,
continued party progression and member-specific reward replay protection.
The two-member Temple Depth2 and four-member Mine Depth4 strict completion
reruns passed real CompletionService persistence and idempotence for
1/3 surviving recipients. One initial stricter run failed because fresh
Studio profiles had not earned previous difficulties; fixture now awards
only disposable earlier-depth clears through the authoritative
progression service. A new Depth2/4, 1/2/4-member wipe/auto-revive
service-level suite passed 392 assertions, optional focused 19/19 and
broad backend 30/30; four local Rojo compositions built.
Read docs/testing/phase4-higher-depth-multiplayer-lifecycle-2026-09-20.md
for dated parent/child Studio logs and all caveats.
Next backend candidate: dynamic dungeon-event/secret variety using
the existing issuer, planner, boss registry and reward replay system,
without new schedulers or new art. Retain real same-account rejoin/cloud
acceptance as a separate deferred gate. No production release changes.

## 20 September 2026 — ChatGPT-authored roadmap v1.48 handoff

Read `docs/roadmap/DungeonMMO_Roadmap_v1_48_Phase4_Backend_Update.md`
after the unchanged historical v1.47 long-form roadmap. Local
Depth2–4 optional geometry and six assisted walking routes have passed.
The next backend gate is higher-depth party lifecycle across the existing
Temple/Mine Event/Secret systems: 1/2/4-member frozen shared runs, duplicate
spawn rejection on simultaneous touches, interrupted encounter/wipe/
checkpoint recovery, and exactly-once per-member boss/completion rewards.
Keep higher-depth and optional release locks OFF. Continue GitHub-first
source edits and local Studio tests, but do not assume main merge, cloud
publish, real same-account server rejoin or user DataStore acceptance.

## 20 September 2026 — six higher-depth optional physical routes

Current integration branch: wip/phase-4-test-hud-integration-v1.
GitHub-first placeholder geometry + physical layout + active-depth gate
changes add separate Event/Secret bridges to the existing TEMP Temple
and Mine Depth2/3/4 blockouts, without enabling release flags or
changing required room sequences. The tests physically walked into/out
of both side rooms and passed all six dungeon/depth combinations using
assisted enemy defeats. One more Mine Depth4 Play-mode run demonstrated
physical Secret bypass and backtracking before final completion, using
a TEMP-only final-spawn hold. Structural test: 139 PASS; focused optional
suite 18/18 PASS; broad backend matrix 30/30 PASS; optional-disabled
Temple Depth2 baseline and all four local Rojo builds PASS. Full paths
and seven Studio Play-mode log receipts:
docs/testing/phase4-depth2-4-optional-physical-playtest-2026-09-20.md.
These were automated Studio movement tests, not unassisted manual
combat or live same-account reconnect. The user previously verified
manual solo optional boss combat separately. No cloud push/publish or
player DataStore/art modification. Next: preserve accepted backend,
finish remaining Phase4 release/UX gates when requested.

## 20 September 2026 — optional depth/event backend continuation

Active integration branch: wip/phase-4-test-hud-integration-v1.
The existing generic optional encounter catalogue already defines
Event/Secret positions for Temple/Mine Depth1–4. Added focused
per-depth plan/eligibility and timed-entry expiry/recovery regressions.
RED tests exposed a hard-coded Room2 Secret gate that would open before
higher-depth prerequisites, and Mine placeholder gates that remained
closed forever. Fixed the shared gate prerequisite using frozen ordered
bindings, and enabled the existing server-owned gate lifecycle and
short blocked-entrance messaging for both named placeholder dungeons.
Fresh 17/17 Studio focused suites PASS (712 optional depth, 116 event
recovery, 32 gate assertions); assisted Temple/Mine Depth1 optional
physical routes, 30/30 broad gameplay suites and four local Rojo builds
PASS. See docs/testing/
phase4-optional-depth-events-and-side-gates-2026-09-20.md.
No Depth2–4 optional physical layout/bridge integration or higher-depth
release switch has been done. Work next on explicitly opted-in TEMP
higher-depth side-room physical layouts and route/recovery playtests,
without touching finished art, TEST/PROD cloud places or DataStores.

## 20 September 2026 — Depth1–4 integration handoff

Current branch: wip/phase-4-test-hud-integration-v1, worktree:
DungeonMMO_Phase4_HUD_Integration_v1. New GitHub-first
DungeonDepthLadderIntegrationTest (and focused Studio runner) passed
454 assertions / 5 suites on Temple+Mine Depth1–4. It uses the actual
CompletionService for persisted profile unlock and reward replay
rather than recording depth clears directly. Checks increasing 3/4/5/6
rooms, ordered miniboss lineage, recovered checkpoints and single
spawn/clear protection. 30/30 gameplay backend suites, Base Play mode
and all four local Rojo compositions passed. A fresh assisted Temple
Depth2 physical case passed; individual higher-depth Temple/Mine cases
are documented historically. One attempted multi-Play Studio runner
stopped after the first case and was removed (never count all six
as fresh). Full evidence:
docs/testing/phase4-depth1-4-progression-integration-2026-09-20.md.
Depth2–4 and optional release switches remain unchanged. Continue
using placeholders and GitHub-first edits; cloud, same-user rejoin,
PROD, player DataStores and art remain out of scope.

## 20 September 2026 — persisted session recovery follow-up

Current integration branch wip/phase-4-test-hud-integration-v1.
Added DungeonOptionalFullSessionRecoveryTest to the focused Studio
runner; 42 checks pass for interrupted Event/Final/deferred Secret,
checkpoint, two-member reconnect flags, original frozen eligibility,
optional entrance barriers and persisted reward replay protection.
15/15 focused suites and the existing assisted Temple backtracking
physical fixture passed. Evidence and exact Studio logs:
docs/testing/phase4-optional-full-session-recovery-2026-09-20.md.
There were no production runtime changes or cloud/DataStore mutations.
True same-account admission and a recreated live reserved Roblox server
still require separate acceptance; cloud verification is deferred.
The user explicitly confirmed a successful manual solo optional-boss
playtest; do not repeat that test as an outstanding gameplay blocker.

## 20 September 2026 — optional Event/Secret consecutive gameplay

The old no-healing injured-solo test remains FAILED. Do not conflate it
with two newly passing two-client cases: both players fought Event then
Secret using normal client combat without forced health changes; a
separate run used an equipped heal (+32 party HP) and server-confirmed
Dodge between those encounters, then cleared Secret and the final route.
Room1/Room2 and the final boss were assisted in these disposable local
Studio tests. All new fixtures and notes were committed on GitHub first
and pulled into the existing Windows integration worktree. See
docs/testing/phase4-optional-boss-consecutive-skill-defense-2026-09-20.md.
Next: if desired, verify solo survivability via legitimate defense/
healing, unassisted required rooms, true same-account rejoin. Cloud
verification and art remain intentionally deferred.

## 20 September 2026 — normal combat follow-up

GitHub-first source changes were fast-forward pulled for local Studio
combat fixtures. Real client attacks defeated Event independently
and Secret independently with normal player health. The same injured
surviving player died attempting Secret immediately after Event; do NOT
claim the combined sequence passed. Secret succeeded in a separate
healthy two-player run; all optional boss defeats used normal server
combat damage. Prerequisite packs and final room were assisted, and
player positioning was scripted. See docs/testing/
phase4-optional-boss-normal-combat-playtest-2026-09-20.md.
Next: legit healing/defense and consecutive optional boss survivability;
manual end-to-end and true rejoin remain separate acceptance gates.

## 20 September 2026 — two-client optional-boss gameplay tested

Current integration branch wip/phase-4-test-hud-integration-v1;
starting implementation c571552. TEMP local Studio two-client fight
passed: shared frozen eligible run; one Event boss for two simultaneous
clients; one player leaves during Active Event; peer preserves session
and checkpoint, defeats Event and Secret, blocks Event reward replay
and clears final boss. A saved-state detached sequencer validates
interrupted Event returns Pending; it does not reconnect the original
account or restart the actual live Dungeon server. Fixture:
scripts/studio/phase4_optional_boss_two_client_fight.luau.
Receipts and limits:
docs/testing/phase4-optional-boss-two-client-playtest-2026-09-20.md.
Continue backend with server-recreation/true rejoin validation when
possible, without cloud publication or any modelling work.

## 20 September 2026 — optional lifecycle continuation

Active worktree: DungeonMMO_Phase4_HUD_Integration_v1; branch:
wip/phase-4-test-hud-integration-v1. Starting checkpoint: 92b31be.
The shared encounter runtime now reverts unsaved Event/required startup
and unsaved optional Secret skip, preserving retry and normal-route
progression. New failure regression and expanded two-member/gate tests
PASS; five Rojo builds, local Temple physical backtracking, normal
Dungeon and two-client disconnect PASS. Full logs and qualifications:
docs/testing/phase4-optional-boss-lifecycle-hardening-2026-09-20.md.
Next gameplay gate: exercise Event/Secret side fights with two real
Studio clients, including interrupted boss recovery and repeat rewards;
same-account reconnection still needs separate evidence. Continue using
TEMP placeholders. Cloud verification/publishing is deliberately deferred.

## 20 September 2026 — side-gate recovery handoff

Continue on DungeonMMO_Phase4_HUD_Integration_v1,
wip/phase-4-test-hud-integration-v1. The optional Event/Secret side-bridge
gates already exist at f6d6401; roadmap v1.47 at 1083c01 documents
release status. This follow-up adds three isolated recovery assertions in
DungeonOptionalEntranceGatesTest; fresh Studio focused suite 13/13 and
all 16 gate assertions PASS. Log:
20260920T151636Z_Studio_1BE9F_last.log. Fresh TEMP physical Temple traversal and skipped-Secret backtracking
also passed in Studio log 20260920T151909Z_Studio_C434B_last.log,
including both gates initially closed, prerequisite unlocks and final
room completion. Full evidence is in
phase4-test-temple-optional-entrance-gates-2026-09-20.md.
The attempted cloud TEST Dungeon publish has unverified script/whole-place
state due to HTTP 429. Do NOT assume gates are live or retry publish
blindly. Confirm cloud version, back up existing TEST Dungeon, then verify
fresh cloud server before declaring release; preserve Lobby, PROD,
DataStores, authored branches and the existing rollback tag.

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

**Date:** 18 September 2026
**Active workstream:** Phase 4 - Content Alpha
**Canonical roadmap:** DungeonMMO Roadmap v1.44
**Phase 3 - Systems Alpha:** FORMALLY COMPLETE / ACCEPTED
**Gameplay release checkpoint:** 84662948127eb1a37c9f184c6abbafe6f2daddb6

## Where the project is now

Phase 2 and Phase 3 are closed.

The accepted Phase 3 gameplay checkpoint 84662948127eb1a37c9f184c6abbafe6f2daddb6 was:

1. pushed to wip/phase-3-systems-alpha-completion-v1;
2. fast-forwarded into local main;
3. pushed to origin/main;
4. independently verified against the GitHub server main ref.

The documentation closeout is layered on top of that accepted gameplay release.

## Published TEST environment

- Starting Base Place ID: 134132328219009
- Dungeon Place ID: 117293035754309
- Universe ID: 10765241947
- environment namespace: TEST

The Dungeon was Rojo-synced into the authenticated cloud place and published
first. Studio reported PublishSuccessful. The Starting Base was then synced and
published, and Studio again reported PublishSuccessful.

No PROD publish or Robux/monetisation action occurred.

## Accepted Phase 3 boundary

Do not recreate or replace these systems when continuing:

- Quest + race-specific Secondary-Class Advancement foundation;
- Damage/Tank/Support Contribution;
- Blueprint / Recipe Knowledge;
- Bestiary + Scholars Reputation;
- Fighter, Mage, Ranger and Rogue prototype starting archetypes;
- Rogue skill-tree breadth and Human Duelist / Elf Windstalker advancement
  targets;
- deterministic Fortified / Rich Deposits / Bounty Dungeon modifiers;
- personal reconnect-safe profession gathering and modifier interaction;
- Guild membership/progression/roles + private Guild Hall;
- limited fixed-price escrowed Market;
- DEV/TEST Race Change migration/archive/restore;
- economy audit and request/replay/ownership safeguards;
- shared persisted entity adapter.

Current profile schema: v13.

Schema v13 adds independent persistent Dungeon difficulty progression while
preserving legacy `DungeonProgress`.

## Final accepted evidence

The 18 September consolidated Studio run kept the earlier accepted combat,
progression, equipment, Dungeon, profession, Bank, Travel and reward suites
green while also passing the Phase 3 Rogue, contribution, bestiary/reputation,
guild, market, race-change, audit, modifier and entity-adapter families.

The Phase 3 stress harness passed:

profiles=250 market=1000 replay=1000 guild=250 sessions=100 race_roundtrips=100

The dedicated record is:

docs/testing/phase3-systems-alpha-acceptance-record.md

## Deliberate deferrals

- progression catch-up;
- Transmog.

Do not silently pull either back into the immediate plan. Revisit them only when
the roadmap conditions that justified deferral change.

## Phase 4 backend gate result

The earlier **Progressive Dungeon Depth + Difficulty backend foundation**
remains local green at `1230e6c`.

The follow-on **Generic Dungeon Encounter Runtime** is locally complete and
green at implementation checkpoint:

`5ba9f4d`

The accepted local proof now includes:

- generic ordered encounter-plan materialization;
- Combat, MiniBoss, Boss, FinalBoss, EventBoss and SecretBoss kinds;
- server-owned optional before/after insertion;
- required versus optional completion semantics;
- immutable persisted materialized run plans;
- reconnect-safe stable encounter-ID lifecycle state;
- legacy Room1/Room2/Boss checkpoint migration;
- stable `EncounterStart:<EncounterId>` checkpoints;
- Depth1 physical/logical compatibility bindings;
- live DungeonRuntime Room1 -> Room2 -> boss authority moved to the generic
  sequencer;
- required inserted encounters cannot be bypassed;
- activated optional encounters fail closed when physical bindings are absent;
- existing EncounterService IDs, rewards, doors and Captain/Foreman behaviour
  preserved;
- Depth2-Depth4 remain fail closed;
- Event/Secret boss content remains disabled.

The follow-on **Encounter Execution / Spawn Registry** is locally complete and
green at implementation checkpoint:

`fe1856e`

Accepted proof now also includes:

- stable CombatPack and Boss executor selection from encounter descriptors;
- server-owned combat-pack spawn catalogue;
- stable BossId -> factory registration;
- MarauderCaptain + CorruptedForeman registered as current boss content;
- DungeonRuntime concrete factory decisions removed;
- transactional startup and rollback to Pending on execution failure;
- cleanup on partial pack failure, boss factory failure and downstream
  EncounterService rejection;
- encounter-scoped boss duplicate claims, allowing several distinct boss-family
  encounters in one dungeon run;
- future boss content fails closed until its BossId/catalogue/factory/binding is
  deliberately registered;
- real Temple execution-registry acceptance: 15 assertions PASS;
- forced Abandoned Mine DeepEchoes + CrystalBloom execution-registry
  acceptance: 16 assertions PASS;
- 494 repository Lua/Luau files parsed with 0 failures;
- all four Rojo compositions build cleanly;
- final repeat committed Dungeon regression has no project errors;
- final committed Base regression has no project errors;
- Phase 3 Systems Stress remains green;
- 26 changed code/test files from `c6e181c`, 0
  art/model/mesh/terrain/image files.

Evidence:
`docs/testing/phase4-encounter-execution-registry-acceptance-record.md`

No push, merge or Roblox publish has been performed for this Phase 4 gate.

The follow-on **Multi-Depth Physical Room-Binding Runtime** is now locally
complete and green at implementation checkpoint:

`1aa81b5`

Accepted proof now also includes:

- generic physical room-slot definitions for current Dungeon layouts;
- logical encounter -> room/trigger/spawn/barrier/checkpoint binding;
- generic live progression instead of fixed Room1/Room2/Boss branches;
- binding-specific boss spawn anchors;
- legacy Depth1 checkpoint recovery compatibility;
- Temple real-trigger compatibility: 23/23 assertions PASS;
- forced Abandoned Mine DeepEchoes + CrystalBloom compatibility:
  23/23 assertions PASS;
- explicit fail-closed production binding checks for Depth2, Depth3 and Depth4
  in both current dungeons;
- 501 repository Lua/Luau files parsed with 0 failures;
- all four Rojo compositions build cleanly;
- final committed Dungeon and Base regressions green;
- Phase 3 Systems Stress remains green;
- 12 changed code/test files from `2deb540`, 0
  art/model/mesh/terrain/image files.

Evidence:
`docs/testing/phase4-multi-depth-room-runtime-acceptance-record.md`

Depth2-Depth4 remained fail closed at this checkpoint. Event/Secret boss
content remains disabled. No modelling, meshes, terrain, authored rooms or
presentation work was performed.

The follow-on **Dungeon Runtime Content Readiness Registry** is locally
complete and green at implementation checkpoint:

`2e2420b`

Accepted proof now also includes:

- shared static content catalogue for layouts, packs, bosses, executor IDs and
  boss-factory IDs;
- old `RuntimeReady` property removed;
- explicit rollout switch renamed to `RuntimeReleaseEnabled`;
- computed `ContentComplete`, `ReleaseEnabled`, `Ready` and issue list;
- Base progression entry uses computed readiness;
- TeleportCoordinator uses computed readiness before server reservation;
- Depth1 is complete+enabled+ready for both current dungeons;
- Depth2-Depth4 are incomplete+disabled+not-ready for both current dungeons;
- missing higher-depth layouts/content are reported diagnostically;
- Dungeon bootstrap verifies shared implemented executor/factory declarations
  match actual server-side registrations;
- 504 repository Lua/Luau files parsed with 0 failures;
- all four Rojo compositions build cleanly;
- final committed Base and Dungeon regressions green;
- Phase 3 Systems Stress remains green;
- 13 source/test files from `a942f6d`, 0
  art/model/mesh/terrain/image files.

Evidence:
`docs/testing/phase4-runtime-content-readiness-acceptance-record.md`

No push, merge or Roblox publish has been performed for this gate.

The follow-on **Generic Enemy Archetype + Heterogeneous Combat Pack Registry**
is locally complete and green at implementation checkpoint:

`464bd44`

Accepted proof now also includes:

- stable shared enemy archetypes;
- stable server-only enemy factory IDs;
- a dedicated `DungeonEnemyFactoryRegistry`;
- ordered heterogeneous combat-pack entries;
- generic `CombatPackEncounterExecutor`;
- old Marauder-specific combat-pack executor removed;
- Deep Echoes / Crystal Bloom pack bonuses targeting explicit EntryIds;
- exact existing Temple/Mine Depth1 pack-count compatibility;
- synthetic 2-Marauder + 1-Elite execution proof without enabling Elite as
  production content;
- mixed-pack transactional cleanup on factory failure;
- readiness validation for pack entries/archetypes/factories/bonus targets;
- 507 repository Lua/Luau files parsed with 0 failures;
- all four Rojo compositions build cleanly;
- final committed Base and clean-repeat Dungeon regressions green;
- Phase 3 Systems Stress remains green;
- Training Dummy and Combat Target Rules green;
- live Dungeon player admission succeeded;
- 11 source/test files from `5298699`, 0
  art/model/mesh/terrain/image files.

Evidence:
`docs/testing/phase4-enemy-archetype-combat-pack-acceptance-record.md`

No new production enemy archetype was enabled.
Depth2-Depth4 remain release-disabled/content-incomplete.
No push, merge or Roblox publish has been performed for this gate.

The follow-on **Authoritative Runtime Layout Selection + Environment
Activation** gate is locally complete and green at:

`ccd289b`

Accepted proof now also includes:

- authoritative DungeonId + DifficultyId + LayoutId selection;
- TeleportData difficulty preservation in production;
- optional Studio difficulty selection with default fallback;
- explicit physical exit-barrier anchors in layout metadata;
- generic arbitrary-slot trigger/barrier activation;
- no hard-coded Temple/Mine trigger/barrier arrays in environment bootstrap;
- readiness validation for missing physical barrier bindings;
- Runtime Selection: 7 assertions PASS;
- Environment Layout Activation: 12 assertions PASS;
- 510 repository Lua/Luau files parsed with 0 failures;
- all four Rojo compositions build cleanly;
- final committed Base and Dungeon regressions green;
- Phase 3 Systems Stress remains green;
- 7 source/test files from `0177b17`, 0
  art/model/mesh/terrain/image files.

Evidence:
`docs/testing/phase4-runtime-layout-selection-acceptance-record.md`

No push, merge or Roblox publish has been performed for this gate.

The follow-on **Binding-Owned Spawn Groups + Exit Barriers** gate is locally
complete and green at:

`cfbf2ea`

Accepted proof now also includes:

- combat-capable slots carry EnemySpawnGroup;
- encounter bindings carry EnemySpawnGroup and ExitBarrierAnchor;
- CombatPack execution uses binding-owned environment groups rather than
  room-ID spawn maps;
- DungeonRuntime encounter-clear and recovery barriers use physical binding
  anchors rather than room-ID barrier maps;
- readiness rejects combat bindings without spawn groups;
- Dungeon Encounter Bindings: 34 assertions PASS;
- Dungeon Encounter Environment Runtime: 8 assertions PASS;
- Combat Pack Encounter Executor: 15 assertions PASS;
- Encounter Executors: 21 assertions PASS;
- Encounter Execution Bootstrap: 4 assertions PASS;
- Runtime Content Readiness: 64 assertions PASS;
- 512 repository Lua/Luau files parsed with 0 failures;
- all four Rojo compositions build cleanly;
- final committed Base and Dungeon regressions green;
- Phase 3 Systems Stress remains green;
- 11 source/test files from `caf56c5`, 0
  art/model/mesh/terrain/image files.

Evidence:
`docs/testing/phase4-environment-binding-runtime-acceptance-record.md`

No push, merge or Roblox publish has been performed for this gate.

The follow-on **Selected-Layout Environment Contract** gate is locally complete
and green at:

`405dde5`

Accepted proof now also includes:

- production room-anchor resolution derived from the selected physical layout;
- combat spawn-group prefix/minimum metadata owned by physical slots;
- runtime base contracts reduced to environment-wide completion/return anchors;
- bootstrap and router using the same selected-layout contract builder;
- legacy adapter full-contract compatibility preserved;
- synthetic Room4 resolution through the real EnvironmentAnchorResolver:
  14 assertions PASS;
- Encounter Bindings: 34 assertions PASS;
- Runtime Content Readiness: 64 assertions PASS;
- clean-repeat Combat Target Rules: 9 assertions PASS;
- 514 repository Lua/Luau files parsed with 0 failures;
- all four Rojo compositions build cleanly;
- final committed Base regression green;
- clean-repeat committed Dungeon regression green;
- Phase 3 Systems Stress remains green;
- 9 source/test files from `87a88c1`, 0
  art/model/mesh/terrain/image files.

Evidence:
`docs/testing/phase4-layout-environment-contract-acceptance-record.md`

No push, merge or Roblox publish has been performed for this gate.

The follow-on **Studio Difficulty / Session Parity** gate is locally complete
and green at:

`d9297f8`

Accepted proof now also includes:

- explicit Studio difficulty propagation into session creation;
- explicit Studio difficulty propagation into DungeonInstanceDirector;
- Studio routing data preserving DifficultyId;
- reused Studio sessions preferring authoritative session difficulty;
- DungeonRuntime using the environment-resolved DifficultyId;
- Studio Session Factory: 7 assertions PASS;
- Layout Environment Contract: 14 assertions PASS;
- Encounter Bindings: 34 assertions PASS;
- Runtime Content Readiness: 64 assertions PASS;
- clean-repeat Training Dummy: 9 assertions PASS;
- clean-repeat Combat Target Rules: 9 assertions PASS;
- 514 repository Lua/Luau files parsed with 0 failures;
- all four Rojo compositions build cleanly;
- final committed Base regression green;
- clean-repeat committed Dungeon regression green;
- Phase 3 Systems Stress remains green;
- 3 source/test files from `5fb3491`, 0
  art/model/mesh/terrain/image files.

Evidence:
`docs/testing/phase4-studio-difficulty-parity-acceptance-record.md`

No push, merge or Roblox publish has been performed for this gate.

The follow-on **Depth2 Backend Combat + Boss Content** gate is locally complete
and green at:

`b525235`

Accepted proof now also includes:

- three registered Depth2 combat packs per current dungeon;
- 3/4/5 Marauder base counts;
- Mine Deep Echoes and Crystal Bloom Depth2 bonus preservation;
- TempleDepth2Boss / Temple Warden factory identity;
- AbandonedMineDepth2Boss / Deep Overseer factory identity;
- both Depth2 bosses retaining accepted Captain controller behavior;
- Depth2 readiness failing only on DungeonLayoutNotRegistered;
- Depth2 remaining release-disabled and physically unregistered;
- Depth2 Content: 32 assertions PASS;
- Depth2 Boss Factory: 8 assertions PASS;
- Encounter Spawn Catalog: 17 assertions PASS;
- Runtime Content Readiness: 66 assertions PASS;
- 518 repository Lua/Luau files parsed with 0 failures;
- all four Rojo compositions build cleanly;
- final committed Base and Dungeon regressions green;
- Phase 3 Systems Stress remains green;
- 8 source/test files from `468cf76`, 0
  art/model/mesh/terrain/image files.

Evidence:
`docs/testing/phase4-depth2-content-acceptance-record.md`

No push, merge or Roblox publish has been performed for this gate.

The follow-on **Depth3 Backend Combat + Boss Content** gate is locally complete
and green at:

`092bd99`

Accepted proof now also includes:

- four registered Depth3 combat packs per current dungeon;
- 4/5/6/7 Marauder base counts;
- Mine Deep Echoes and Crystal Bloom Depth3 bonus preservation;
- TempleDepth3Boss / Relic Guardian factory identity;
- AbandonedMineDepth3Boss / Hollow Taskmaster factory identity;
- both Depth3 bosses retaining accepted Captain controller behavior;
- Depth2 and Depth3 readiness failing only on DungeonLayoutNotRegistered;
- Depth3 remaining release-disabled and physically unregistered;
- Depth3 Content: 36 assertions PASS;
- Depth3 Boss Factory: 8 assertions PASS;
- Encounter Spawn Catalog: 19 assertions PASS;
- Runtime Content Readiness: 68 assertions PASS;
- 522 repository Lua/Luau files parsed with 0 failures;
- all four Rojo compositions build cleanly;
- final committed Base and Dungeon regressions green;
- Phase 3 Systems Stress remains green;
- 8 source/test files from `3d978af`, 0
  art/model/mesh/terrain/image files.

Evidence:
`docs/testing/phase4-depth3-content-acceptance-record.md`

No push, merge or Roblox publish has been performed for this gate.

The follow-on **Depth4 Final-Difficulty Backend Content** gate is locally
complete and green at:

`8bcb58b`

Accepted proof now also includes:

- two registered Depth4 combat packs per current dungeon;
- 5/7 Marauder base counts;
- Mine Deep Echoes and Crystal Bloom Depth4 bonus preservation;
- the locked Depth1 -> Depth2 -> Depth3 miniboss reuse chain;
- TempleDepth4Boss / Sanctum Ascendant final-boss identity;
- AbandonedMineDepth4Boss / Buried Tyrant final-boss identity;
- both final bosses preserving BossRole = FinalBoss;
- Depth2, Depth3 and Depth4 readiness failing only on
  DungeonLayoutNotRegistered;
- all Depth1-Depth4 encounter content registered;
- Depth2-Depth4 remaining release-disabled and physically unregistered;
- Depth4 Content: 38 assertions PASS;
- Depth4 Boss Factory: 10 assertions PASS;
- Encounter Spawn Catalog: 20 assertions PASS;
- Encounter Executors: 21 assertions PASS;
- Runtime Content Readiness: 70 assertions PASS;
- 526 repository Lua/Luau files parsed with 0 failures;
- all four Rojo compositions build cleanly;
- final committed Base and Dungeon regressions green;
- Phase 3 Systems Stress remains green;
- 10 source/test files from `230f7f5`, 0
  art/model/mesh/terrain/image files.

Evidence:
`docs/testing/phase4-depth4-content-acceptance-record.md`

No push, merge or Roblox publish has been performed for this gate.

## Exact next action

Stop at this local-green boundary until the project owner chooses the next
backend gate or release closeout. Push, merge and Roblox publish each require an
explicit instruction.

Generic higher-depth framework blockers remain cleared through
`d9297f8`; Depth2 content is complete at `b525235`, Depth3 content at
`092bd99`, and Depth4 final-difficulty content at `8bcb58b`.

Depth1-Depth4 backend encounter content is now complete for both current
dungeons. Keep Depth2-Depth4 release-disabled and do not register physical
layouts until authored rooms exist. The next backend-only dungeon gate may
cover Event/Secret boss content and insertion policy without authoring models or
rooms.

Carry forward these readiness rules:

- `RuntimeReleaseEnabled` is only the explicit rollout switch;
- production entry may use only computed `DungeonRuntimeContentReadiness`;
- Depth2-Depth4 must remain release-disabled until their complete content and
  physical bindings are deliberately implemented and accepted;
- Event/Secret boss content remains disabled until its own content/binding gate
  is approved.

No modelling, meshes, terrain, authored rooms, visual polish or difficulty UI
was performed in this gate.

## Safety and repository paths

Primary repo:

C:\Users\Remko\Documents\Roblox\DungeonMMO

Active Phase 4 Depth4-content worktree:

C:\Users\Remko\Documents\Roblox\DungeonMMO_Phase4_Depth4Content_v1

Active branch:

wip/phase-4-depth4-content-v1

Phase 3 completion worktree:

C:\Users\Remko\Documents\Roblox\DungeonMMO_Phase3_Completion_v1

Art worktree remains isolated:

C:\Users\Remko\Documents\Roblox\DungeonMMO_Art

No hard reset, clean, force-push or history rewrite. Do not use PROD DataStores
or publish PROD without a separate explicit approval.

## Event/Secret Boss backend candidate (19 September 2026)

A separate backend candidate exists in DungeonMMO_Phase4_EventSecretPolicy_v1, based on ff2baa0. The four distinct optional-boss identities and their server-only event-window/secret-unlock triggers are implemented. Secret-boss direct-successor skip is persisted through the existing generic encounter controller. Dungeon Studio: policy 49, flow 9, factories 24 and release locks 14 assertions PASS; 537 Lua/Luau files parse; four Rojo builds PASS. The Base gameplay regressions also passed. Both current dungeons remain rollout-disabled, with no optional arenas; Depth2-4 physical layouts remain unregistered. This is CODE-ONLY BACKEND VERIFIED and NOT RELEASED. Authored arenas, authoritative boss-event schedule/secret-unlock issuers and physical gameplay acceptance are future gates. No push, merge, publish or UI changes. Evidence: docs/testing/phase4-optional-boss-policy-progress.md.

Backend closeout (19 September 2026): server-issued optional-boss
run-state regression passed 28 offline Luau assertions; four
Rojo builds and diff check passed. Physical arenas, event
schedules and secret-route release settings remain gated.\r\n\r\n
## UI candidate handoff - 19 September 2026

Continue at DungeonMMO_Phase4_UIOverhaul_v1, branch
wip/phase-4-ui-overhaul-v1. Parser, four builds and Base/Dungeon Studio
regressions passed; see UI candidate acceptance record.
Before merging/publishing, visually test normal gameplay at desktop and
small viewports, player/target/hotbar spacing, Guild/Inventory/Skills close,
DungeonEntryPrompt and AuctionHousePrompt open/close/distance behaviour,
party entry and dungeon HUD with active boss/completion.
Preserve backend, physical depth locks and isolated art worktree.
No push, merge or Roblox publish has been performed.


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
