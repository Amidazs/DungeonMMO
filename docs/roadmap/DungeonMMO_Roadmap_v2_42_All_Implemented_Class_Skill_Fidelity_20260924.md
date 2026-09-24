# DungeonMMO v2.42 — Whole-current-class C4 fidelity inventory

Date: 24 September 2026; branch `wip/phase-4-test-hud-integration-v1`.
Code baseline `58cfe32c3fac47289523786e8260546e848287b8`.
Previous: [v2.41](DungeonMMO_Roadmap_v2_41_C4_Skill_Effect_Parity_Audit_20260924.md).

## Scope corrected: ALL currently authored classes, not only Warden

`C4AllImplementedClassSkillAudit.report()` resolves EVERY
authored current rank through level 30 for all four race-specific
base Fighter/Mystic paths, all five original first-transfer paths
(Human Rogue, Warrior, Knight; Elven Scout, Knight), and the four
distinct Human/Elven legacy Ranger/Rogue variants. It includes
inherited base skills, starter skills, individually purchased class
ranks, active combat definitions, all authored progression and
passive/stat fields, current stamina/mana costs and cooldowns.

Each class-specific row is tagged with its source evidence state.
The source side is **not** fabricated: the existing 24 source
Warden heal/charm/taunt ranks plus first reviewed exemplar rows
for the four starter paths and the other four original
first-transfer paths (32 class-scoped reference rows in total).
Four legacy variants explicitly have NO direct 1:1 original
C4 source class at their original level-one creation rules.

A separate source sample registry records the C4 rank/MP/power
and exact original C4 class page for each of the NINE genuine
original starting and first-transfer class paths. The
`C4AllImplementedClassSkillAuditTest` fails if an original class
is silently excluded, if a source row disappears, if a current
rank has no progression definition or nonpassive executor,
or if a row falsely claims historical formula certification.
It is an inventory and discrepancy report, **not** a
mechanics-matching implementation or a balance certification.

## Executed first broad run

The unpublished disposable Dungeon Rojo build and focused Studio
`c4_all_implemented_class_skill_fidelity_focus.luau`
on `58cfe32c3fac47289523786e8260546e848287b8` reported **13/13 race-class scopes**,
**1,353 class-scoped rank occurrences** through level 30,
**32 individually sourced C4 rank-row occurrences**, and
**1,321 occurrences still lacking an individually verified
source-number row**. The totals count shared/inherited skills
repeated for every race/class context in which they are
actually registered, **not 1,353 unique skills**. The
full per-scope measurements appear in [test evidence](
../testing/c4-all-implemented-class-skill-fidelity-20260924.md).

All classes remain UNVERIFIED for full C4 mechanics.
Current examples that already demonstrate non-equivalence:
base Fighter first power strike versus IronCleave Roblox
damage/stamina, base Mystic WindStrike12 power/9MP
versus 30 Roblox base damage/25 mana, Rogue/Scout
PowerShot rank10 power239/43MP versus WayfinderArrow
22 Roblox base damage/17 stamina, Human Knight
ShieldStun22 MP versus OathguardShieldImpact19 stamina
and 0.7s stagger, Warrior PowerSmash90 power/22MP
versus IronvowDrivingStrike25 base damage/21 stamina;
Elven Knight source heal r4 power95/53MP currently
24 Roblox HP/13 mana and can target others.
Historic C4 power is NOT equivalent to direct Roblox damage,
and inherited skill reuse is NOT evidence of source parity.

## Next backend step

Extend individually verified C4 source rank/MP/stat/effect
tables for all class families; fill missing precise passive
P.Atk/P.Def/M.Def values, stance drain, heal, threat, status
chance, target rules, duration, skill-weapon restrictions,
area targets, over-hit, SP costs and C4 effect stack order.
Use the shared C4 stat/damage model before replacing live
combat numbers: keep chip damage, no free self-cures and
server-owned hit/quest-credit validation. Conduct cross-class
actual gameplay acceptance after formula fixtures.

Do not call all 1,353 rank occurrences verified C4 skills:
only their **CURRENT** live numeric definitions have been
enumerated; original source rows remain unverified for
1,321 class-scoped occurrences. No main merge, Roblox
publish, production DataStore changes or art/animation edits.
