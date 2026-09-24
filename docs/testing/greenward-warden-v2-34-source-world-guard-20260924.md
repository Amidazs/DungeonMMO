# Greenward Warden focused Studio evidence — v2.34

Date: 24 September 2026. WIP branch
`wip/phase-4-test-hud-integration-v1`. Unpublished local disposable place
files; no production DataStore. Tests below are separate, scoped
observations, not an end-to-end cross-place journey.

## Why two first attempts failed

At `c09d5c43` the Base passive test **FAILED** during module
load: `SkillDefinitions:2539 Taunt threat must be positive and
finite`; the independently authored Charm had zero taunt bonus.
Commit `5069af03` preserved normal positive-taunt validation and
allowed bounded non-damaging threat reduction. The next Base run
**FAILED** during module load at the MageHeal validator because
the Warden's distinct non-healing bleed cure did not count as a
poison cure. Commit `2a45dec1` added strict exclusive bleed-cure
validation. Neither failed test is reported as a pass.

## Corrected unpublished isolated tests (2a45dec1)

| Studio script | Result | What it actually verified |
| --- | --- | --- |
| `c4_greenward_warden_passive_training_focus.luau` | PASS, 224 assertions | Genuine in-memory class/mentor award, all 56 individually purchased ranks, equipment and crafting with one chosen profession, forged-class denial, support contract. |
| `c4_greenward_warden_quest_world_focus.luau` | PASS, 14 assertions | Physical disposable stage-three and stage-five model/ledger binding in existing Dungeon encounter. |
| `c4_level30_launch_coverage_focus.luau` | PASS, 32 assertions | Historical 18-branch audit and all 56 independent Warden level-30 rank schedules. |
| `c4_greenward_warden_quest_transaction_focus.luau` | PASS, 24 assertions | Server-only quest report, guardian seal and advancement transaction. |

Only the explicit source runner markers
`VERIFIED_FOCUS_PASS`, `VERIFIED_SOURCE_RANK_AUDIT_PASS`
and `VERIFIED_TRANSACTION_PASS` support these claims.
A Rojo build is not a test of functional game mechanics.

## True one-client block-and-guard defence (789c147f)

The new
`scripts/studio/c4_greenward_warden_shield_guard_live.luau`
was derived from the existing Oathguard anti-exploit live runner,
but seeds distinct `ElvenKnight` personally earned class identity,
Warden shield mastery rank2, heavy armour mastery rank9, and paid
Warden DefenseAura. Its initial `6f0bfaa0` run **FAILED**:
the disposable copied fixture accidentally named the nonexistent
`ElvenWarden` branch. After correcting exactly those three test
identifiers in `789c147f`, real Play logged:

- `SKILL ACCEPT GreenwardWardenDefenseAura` and
  `BUFF APPLIED GreenwardWardenDefenseAura`;
- `Blocked_REAL_HP_PASS 38.7` on each of three separate hits;
- `GuardBroken_REAL_HP_PASS 86`;
- `ZERO_STAMINA_REBLOCK_DENIED_PASS`;
- `ALL_REAL_CLIENT_ANTI_EXPLOIT_CHECKS_PASS` and
  `VERIFIED_PLAY_MODE_PASS`.

Both actual client control and authoritative server HP damage
were checked. The test uses disposable test-owned purchases and
enemy strikes; it does not prove naturally earned progression,
exact C4 damage math, untested dungeon combinations or a PvP
outcome. The broader automatic dungeon Play log also printed an
unrelated `MarauderRigContractTest` infinite-yield warning
for `TrainingMarauder.CollisionBody`; investigation is open.

## Cross-race quest spawn isolation (aeafc885)

`C4QuestEncounterSpawns` now requires both the server-owned
owner race and base class match the real original career metadata.
A Human or Mage carrying copied Elven Knight quest state cannot
spawn the Warden's personal enemies. Existing separate original
Human Rogue/Elven Scout/Human Warrior/Human Knight test
characters were updated with accurate race and base identity.
The fresh unpublished Dungeon runs reported:

- Original combat ledger: PASS 10 assertions.
- Generic source pack: PASS 21 assertions.
- Contribution bridge: PASS 13 assertions.
- Combined combat runner: 3/3 PASS.
- Elven Knight quest world: PASS 16 assertions, including copied
  race and base-class spawn denial.

No full real player-led kill/drop, no cross-place owner rejoin, no
genuine live Captain bleed/cure and no complete 18-path class
release acceptance is claimed.
