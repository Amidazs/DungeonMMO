# C4-inspired Ranger/Rogue control-skill increment

Date: 22 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Backend implementation head: `f927f0d8aa63e03b62ce86d5e92fdf0aa73c616e`
Final live fixture: `19cfeb53652610b256419d1ec5623776a9a9f457`
Final focused training test: `3fe8b70c1054603e91b9063b7077769aee7a6603`

## Scope

Two *original DungeonMMO* level/rank/mastery-gated combat abilities
extend real mechanical options; neither is presented as an exact C4
ability copy or proof of Chronicle 4 skill-count parity.

| Family | Skill | Levels | Effect at rank 1/2/3 |
| --- | --- | --- | --- |
| Ranger | Briar Volley | 5 / 10 / 15 | Two-target penetrating arrow; base damage 9/12/15; Human slow 20% for 1.5/2/2.5 s, Elf slow 25% for 2/2.5/3 s. |
| Rogue | Disrupting Cut | 5 / 10 / 15 | Melee hit with base damage 5/7/9 and interrupting stagger 0.35/0.50/0.70 s; does not apply Feint's exposed-target debuff. |

Both require genuine previously purchased rank, level and use-earned
proficiency 40/110 for ranks 2/3. Class trainers and teachable-skill
lists are authoritative. The Ranger variant generalizes the existing
server-only projectile slow routing to data-authored slow definitions;
the Rogue variant routes positive stagger duration through the
existing `StaggerService` after a confirmed living-target melee hit.
Control contribution continues to use the existing encounter bridge,
not client-reported target results. Both retain role-appropriate
weapons and ordinary server combat admission.

## Focused test evidence

The first isolated Base Studio test was RED with
`Missing progression definition BriarVolley`. After GitHub-only
implementation, the same test passed **41 assertions**, covering
rank-1 visibility, correct trainer/class ownership, 5/10/15 level
gates, increasing server control values, both weapons and
server-runtime skill usability.

In the unpublished Dungeon client Play fixture, one real
`CombatInputActions.request_skill_slot(1)` invocation for Briar
Volley damaged **both** separately tagged TrainingDummy models.
Both models acquired a live server-authored slow attribute, with
the second target hit after the first. Disrupting Cut damaged the
real dummy and produced a live `CombatStaggeredUntil` effect.
The log contains `TWO_TARGET_SLOW_PASS`,
`SERVER_STAGGER_PASS`, `BOTH_CONTROL_SKILLS_PASS` and
`VERIFIED_PLAY_MODE_PASS`. Only test character identity,
equipment and client skill-menu/loadout snapshot were synthetic.
No combat remote was spoofed and no target health was directly
subtracted by the test.

An independent production `SkillProgressionService` test on
in-memory, isolated profiles passed **46 assertions**:
level-one and wrong-class learning denied; ranks 1/2/3 required
levels 5/10/15 and earned proficiency 40/110; max rank rejected;
both fully trained skills survived test-profile save/release/reload.
It did **not** simulate earning proficiency through an actual combat
session or operate on real player DataStores.

The previously stale `RogueDefinitionsTest` assertion was corrected:
the raw Duelist catalogue registers five abilities, but unearned
skills remain hidden in the character-filtered trainer response.
A level-32, properly earned and mastered Duelist sees all five.
The isolated test passed **45 assertions**. The earlier
unscoped Dungeon Play run still contains the old failure because
that run used a disposable binary built *before* this test
correction. The separately focused current-source Rogue
test is green; no broad regression acceptance is inferred.

Successful Rojo compositions: Base at the implementation head
and the latest training-test commit; Dungeon after implementing
the new combat/skills and again after the Rogue-test correction.
The existing unrelated `Phase2AFailurePathTest` paid-revive
automatic failure has not been investigated here.

Local evidence (not uploaded):
- `%TEMP%\DungeonMMO_C4Control_RED.log`
- `%TEMP%\DungeonMMO_C4Control_GREEN_f927f0d.log`
- `%TEMP%\DungeonMMO_C4_ControlLive_19cfeb5.log`
- `%TEMP%\DungeonMMO_C4_RogueCatalogue_7668d4c.log`
- `%TEMP%\DungeonMMO_C4ControlTraining_3fe8b70.log`

## Boundaries and next gate

The first two new level-five ability families add three usable
rank entries each. Ranger/Rogue are not yet covered by a
source-verified C4 rank-count manifest; existing Fighter/Mage
13/16 mismatched bracket evidence remains historical and was
not rerun for this Ranger/Rogue-only change. No exact skill
parity or general balance claim is made. No full dungeon
wipe/aggro/revive/Play Again tests were repeated.

Next: map source-verified Ranger/Rogue role/rank counts without
double-counting shared C4 level-20 rogue/scout branches, then add
genuinely missing base/advanced mechanics and a focused actual
saved-profile trainer-to-combat progression playtest. Investigate
the separate Phase2A auto-test failure before any broad release.

All code, fixtures and documentation were changed directly
through GitHub. The authorized local machine was used solely for
clean fast-forward pulls, TEMP Rojo builds, unpublished Studio
tests and diagnostics. No `main` merge, Roblox publishing,
production profile operation or destructive Git command occurred.
