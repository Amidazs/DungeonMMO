# C4-inspired Rogue bleeding skill — focused backend acceptance

Date: 22 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Final focused contract: `dee6d9688bfedf513ba2c990abf51c20a31825a7`
Final live-client fixture: `2ea91520f5d669da63f0b405961acc6557ac9a73`

## C4 source and DungeonMMO adaptation

The Chronicle 4 **Rogue** and **Elven Scout** class pages both
list Bleed rank 1 at level 24 and rank 2 at level 32:
- https://l2hub.info/c4/classes/rogue
- https://l2hub.info/c4/classes/elven_scout

Chronicle 4 requires a **dagger** for its Bleed skill.
DungeonMMO currently equips its Rogue with a temporary
**one-handed sword** because the dagger equipment/animation path
is not yet implemented. Lacerating Cut is an original
DungeonMMO analogue, **not exact C4 equipment, cost, timing,
damage or skill-count parity**. Do not mark source parity complete
until a real dagger path and source-mapped catalogue exist.

## Implemented effect

- `LaceratingCut`: Rogue-only, level 24 / level 32, rank 1/2,
  requires purchased Vital Blow rank 9 / use-earned proficiency
  350 and Disrupting Cut rank 3 / proficiency 110.
- Real server-only sword melee hit does 6 / 9 base damage,
  then three delayed noncritical ticks of 3 / 5 damage,
  at 0.6-second intervals. Rank two requires proficiency
  120 earned by using this skill and purchases through the
  normal SP-backed trainer service.
- Only an actual damaging hit on a living tagged NPC begins
  bleed. One active effect per NPC: refresh replaces, never
  multiplicatively stacks, and stale pending ticks cannot
  hurt a refreshed target. Periodic damage uses existing
  `DamageService` with the original attacker/skill source,
  threat/contribution bridge and capped earned-proficiency
  bridge. There is no client-supplied damage or tick timing.
- The service cancels if the attacker dies, is disconnected,
  changes character, loses combat admission, the NPC dies,
  or the target leaves the world. Maximum six ticks,
  maximum 50 damage per tick and bounded tick interval.
  The actual skill uses three bounded ticks.

## Observed focused evidence

- Unpublished **Base** Rojo build and a dedicated isolated
  progression contract passed: **19 assertions** on level,
  skill-rank, earned proficiency, class, trainer, equipment
  and nonplaceholder damage-tick metadata.
- The production `SkillProgressionService`, backed by an
  isolated in-memory profile adapter, passed **20 assertions**:
  wrong stage/missing prerequisite blocked; level 24
  mastery earned rank one; level 32 plus skill use proficiency
  120 earned rank two; an undefined third rank was denied;
  save/release/reload preserved purchased rank two.
- Fresh unpublished **Dungeon** Rojo build at the current
  source and genuine Play client verified the existing
  `CombatInputActions.request_skill_slot(1)` path and
  server NPC impact. The actual bleeding melee hit landed,
  followed by **three 3-HP delayed damage ticks** against
  the tagged TrainingDummy; the effect then expired and
  a fourth tick did not occur. The real client fixture
  reported `SERVER_BLEED_TICK_PASS`,
  `THREE_TICKS_AND_EXPIRY_PASS`,
  `ALL_FOUR_CONTROL_SKILLS_PASS` and
  `VERIFIED_PLAY_MODE_PASS`.
- Only the disposable Studio server character/equipment
  and client skill snapshot were test-seeded. This was NOT
  a real player's stored-profile trainer GUI transaction,
  normal physical keyboard press, full multiplayer stress
  run or published-cloud acceptance.

Local receipts (not uploaded):
`%TEMP%\DungeonMMO_C4_Bleed_Base_ff7302d.log`,
`%TEMP%\DungeonMMO_C4_Bleed_Training_dee6d96.log`,
`%TEMP%\DungeonMMO_C4_Bleed_Dungeon_FINAL_2ea9152.log`.

The final live Dungeon log also reports the **unrelated**
`Phase2AFailurePathTest` paid-revive auto-test failure.
No general Dungeon regression acceptance is claimed.
The stale Rogue trainer test had already been separately
corrected and focused-tested in v1.71.

## Remaining C4 catalogue work

The earlier Fighter/Mage audit had 13 of 16 source brackets
mismatched and Ranger/Rogue reference rank-volume still
is not mapped to distinct owned DungeonMMO career phases.
This increment implements one genuine DoT family, not a
completed C4 class catalogue. Other first-transfer abilities
and shared Ranger/Rogue passive/utility roles, a proper
dagger class/equipment path, later career transfers and
true source-rank parity remain open. Follow the established
REUSE > VARIANT > NEW-ASSET rule for any eventual art,
but continue backend work without unrelated dungeon
wipe/aggro/revive/replay cycles.

All scripts, tests and documents were written directly
through GitHub. The local machine was only used for clean
pulls, TEMP builds, unpublished Studio play and log review.
No `main` merge, Roblox publish, production DataStore
mutation or destructive Git operation occurred.
