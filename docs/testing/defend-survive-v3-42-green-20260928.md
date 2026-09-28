# v3.42 Defend / Survive Adventure — Test Evidence
**Date:** 28 September 2026

## Scope

Acceptance of the first server-owned Defend/Survive quest:

**Hold the Resonance** (`TempleWardDefense`).

Contract:

- level 13;
- prerequisite `TempleResonancePuzzle`;
- Room 1 must be clear before start;
- real ward prompt within 10 studs;
- 18-stud protected zone;
- 3-second absence grace period;
- reset and restart after excessive absence;
- completion requires genuine Room-2 clear;
- objective event: `DefenseCompleted`;
- reward: 85 Gold + 1 Warding Essence.

## Source head tested

`1509ff65b785827670c72e42407ea9b064e1a203`

## Static/build checks

- `git diff --check 13422ba9..HEAD`: PASS.
- current Base Rojo build: PASS.
- current Dungeon Rojo build: PASS.

Final unpublished packages:

- `_tmp_quest_defense_base_v2.rbxlx`;
- `_tmp_quest_defense_dungeon_v2.rbxlx`.

## Runtime compile regression

The first live defense build exposed a genuine Luau compiler limit in
`DungeonRuntime.server.luau`:

`Out of local registers when trying to allocate admit_player: exceeded limit
200`.

This was not treated as a presentation-test failure.

After moving the defense runtime dependency to lazy loading, the same direct
compile probe returned:

- source class: Script;
- disabled: false;
- `compileOk=true`.

The live runtime then created the defense prompt correctly.

## Quest-variety acceptance

Fresh Base Play returned:

`VERIFIED_QUEST_VARIETY_FOCUS_PASS 8`

Included:

1. QuestDefinitionsTest;
2. AdventureEligibilityTest;
3. HiddenRoomQuestIntegrationTest;
4. LostSurveyorEscortIntegrationTest;
5. TempleResonancePuzzleIntegrationTest;
6. TempleWardDefenseIntegrationTest;
7. C4OriginalFirstTransferQuestArcsTest;
8. C4OriginalFirstTransferQuestStagesTest.

Result: **8/8 PASS**.

## Broader quest/profession regression

Fresh Base Play returned:

`VERIFIED_PROFESSION_QUEST_CONTENT_FOCUS_PASS 10`

Result: **10/10 PASS**.

This keeps the existing Adventure Board, profession rewards, economy topology,
blueprint acquisition and gathering-tier contracts green.

## Dungeon regression

Fresh Dungeon Play returned:

`VERIFIED_CHECKPOINT_ADVENTURE_FOCUS_PASS 5`

Result: **5/5 PASS**.

The accepted checkpoint, Ruin Survey and Fracture Trail integrations remain
green underneath the new defense runtime.

## Live ward presentation

Fresh current-head Dungeon Play returned:

`VERIFIED_TEMPLE_WARD_DEFENSE_PRESENTATION_PASS 1`

Verified:

- synthetic Temple exists;
- Resonance Defense Ward exists;
- server-created `DefensePrompt` exists;
- trusted defense ID attribute is present;
- prompt text is correct;
- prompt is unavailable before Room 1 is cleared;
- 18-stud zone definition remains intact;
- 3-second grace definition remains intact.

## Defense lifecycle coverage

`TempleWardDefenseIntegrationTest` proves:

- cannot start before Room 1 is clear;
- remote start is rejected;
- nearby quest owner can start;
- duplicate party start is idempotent;
- oversized fabricated heartbeat is rejected;
- occupied ward advances trusted defense state;
- short absence stays inside the grace window;
- absence beyond grace resets the defense;
- reset state can be restarted;
- multiple party holders do not multiply progress;
- Room-2 clear completes the active defense;
- both active quest owners receive trusted completion;
- completion heartbeat replay is idempotent;
- exact 85 Gold + 1 Warding Essence reward;
- save/reload retains quest completion and reward.

## Acceptance

**GREEN.**

The launch quest system now includes trusted defeat, clear, checkpoint,
interaction, collection, escort, puzzle and defend/survive objective families.
The next content gate should emphasize dialogue, narrative continuity and final
presentation rather than adding objective types by default.
