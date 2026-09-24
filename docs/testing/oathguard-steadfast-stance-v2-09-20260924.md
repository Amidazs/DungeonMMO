# v2.09 Oathguard defensive stance — executed acceptance

Date: 24 September 2026 (local)
Branch: `wip/phase-4-test-hud-integration-v1`
Play-tested source commit: `eb4842c8a93f94a71e1c860197a1469f9b01d0a5`

## Focused and build checks

- Fresh, disposable `base.project.json` and
  `default.project.json` Rojo builds **PASS** at `28013ca`,
  the same source candidate plus subsequently added *test-only*
  stance Play driver. Original place files untouched.
- Unpublished `scripts/studio/c4_oathguard_quest_focus.luau`
  in `0.740.0.7400927_20260924T083901Z_Studio_2D564_last.log`:
  `[Oathguard Quest] PASS: 70 assertions`;
  `[Oathguard Foundation] PASS: 67 assertions`, both explicit
  verification markers.
- Separate unpublished
  `scripts/studio/c4_level30_launch_coverage_focus.luau` in
  `0.740.0.7400927_20260924T083926Z_Studio_F3173_last.log`:
  `[Level 30 Launch] PASS: 27 assertions` and
  `VERIFIED_SOURCE_RANK_AUDIT_PASS`; **38/54** Knight source
  ranks trainer-mapped and **16** remain unimplemented.

## Real client and actual player health

New source-controlled
`scripts/studio/c4_oathguard_stance_client_live.luau`
ran in a fresh unpublished disposable Dungeon Play instance.
The independent process log
`0.740.0.7400927_20260924T084038Z_Studio_404B1_last.log`
contains actual client `CombatInputActions.request_skill_slot(1)`,
a real server-owned timed `PhysicalGuard` status and genuine
Humanoid HP measurements:

- `REAL_EnemyMelee_90_PASS` and `REAL_EnemyArea_90_PASS`
  from 100 base damage during the authenticated self-buff.
- `REAL_EnemyMagic_100_PASS` and `REAL_Melee_100_PASS`:
  no magic or player-attack shield from this ability.
- A rapid second client cast did not extend the server expiry;
  `REAL_EnemyMelee_100_PASS` occurred after the actual 10-second
  buff expired. Actual stamina decreased by at least 13.5 when
  the nominal 14-stamina first cast was executed.
- Copied skill on a Fighter without a genuine Knight receipt was
  rejected by the runtime skill-use gate.
- `ALL_REAL_CLIENT_TIMED_GUARD_PASS` and
  `VERIFIED_PLAY_MODE_PASS` were emitted on the exact fresh run.

**Scope:** this Play driver uses a test-only internally consistent
Knight quest/mentor, purchased rank and loadout *snapshot*. Genuine
physical quest, owned trainer purchases and their persisted save
have independently passed focused services and a two-client Base
test with one input retry, but an uninterrupted natural player
quest → paid stance purchase → actual hotbar cast in the same
saved player session has **not** been proven. Nor has a real
second party member's HP, early cooldown rejected skill-result
or insufficient-stamina denial been independently measured.
Do not certify the full release level-30 class catalogue.

Historical v2.08 Knight magic/heal and intermittent physical
prompt evidence is linked from the [previous test record](
oathguard-shield-mastery-github-candidate-v2-08-20260924.md).
No `main` merge, Roblox publication, production DataStore or
paid operations.
