# DungeonMMO Roadmap v3.47
## FRIEND TEST READY — PRE-SECTION-D HOLD
**Date:** 28 September 2026

This checkpoint does not start Section D.

It turns the accepted v3.46 pre-D slice into a real two-player published TEST
build for manual testing with a friend.

## Published TEST experience

Universe:

- TEST universe: `10765241947`;
- TEST Base/start place: `134132328219009`;
- TEST Dungeon place: `117293035754309`.

Both places are now freshly published from the current pre-D source.

Independent cloud reloads prove:

- Base: profile schema 15;
- Base: tutorial definitions present;
- Base: physical quest-giver definitions present;
- Dungeon: profile schema 15;
- Dungeon: tutorial definitions present;
- Dungeon: `DungeonQuestFeedbackRuntime` present;
- Dungeon: `NewPlayerDungeonTutorial` present;
- Dungeon environment remains TEST.

## Access

Creator Dashboard currently reports:

- Audience: **Limited**;
- Playtesters: **ON**;
- Friends: **ON**;
- Public: **OFF**.

The TEST experience therefore stays non-public while allowing the owner's
Roblox friends to join.

Stable start-place link:

`https://www.roblox.com/games/134132328219009`

The Creator Dashboard Copy Link control currently provides:

`https://ro.blox.com/Ebh5?af_dp=roblox%3A%2F%2Fnavigation%2Fgame_details%3FgameId%3D10765241947&af_web_dp=https%3A%2F%2Fwww.roblox.com%2Fgames%2F134132328219009`

## New-player tutorial

The Base tutorial now guides a fresh player through:

1. movement, jumping and camera;
2. finding the Worldroot Keeper;
3. using the physical Talk prompt;
4. accepting A Relic Beneath the World Tree;
5. finding the Temple entrance;
6. creating a party;
7. inviting a friend;
8. both members setting Ready;
9. the leader selecting Depth 1 and starting the dungeon;
10. attack, block/parry, dodge, view lock, skills and HUD keys;
11. the fact that hidden rooms can exist.

The first-expedition Dungeon tutorial reinforces:

- stay together;
- clear rooms before moving on;
- checkpoints;
- teammate recovery;
- core combat controls;
- watching world prompts/objective feedback;
- hidden mechanisms and secret spaces.

No tutorial action can fabricate quest progress or rewards.

## Quest-giver layout

The eight placeholder Adventure quest givers are no longer arranged around one
board.

They now bind to semantic hub locations such as:

- travel/Worldroot area;
- training area;
- player-spawn/captain area;
- Temple entrance;
- Dwarf area;
- Dungeon Board expedition area;
- Dwarf travel/survey area;
- market/quartermaster area.

The authored lobby can omit the optional Dwarf quest-hub anchor. Mine Warden
then falls back to the existing Dwarf travel anchor instead of failing Base
startup.

The current authored-lobby runtime spawns all eight quest givers successfully.

## Release-composition fix

Published Base testing exposed a real packaging bug: current progression code
depends on six `ServerScriptService.Combat` services, while
`published-base.project.json` and `test-lobby-sync.project.json` did not
package that Combat subtree.

Both project files now include the same Base Combat runtime dependencies as
`base.project.json`.

The exact published Base composition now starts successfully.

## Two-player route

The existing trusted route remains:

Base party -> leader starts Dungeon -> reserved Dungeon server -> party members
teleport together -> Dungeon session validates membership -> return portal uses
the session's server-owned return place.

Party rules remain:

- up to four members;
- invite/accept is server-owned;
- changing dungeon/difficulty clears readiness;
- multi-player entry requires members to be ready;
- higher difficulty still requires every member to have the unlock;
- Depths 2-4 remain release-disabled.

## Final build checks

Source checkpoint before this documentation:

`bb16fb7a1fa278dfcb648941f19019a20e1393a7`

Fresh checks:

- `git diff --check`: PASS;
- `published-base.project.json` build: PASS;
- `published-dungeon.project.json` build: PASS;
- `test-lobby-sync.project.json` build: PASS;
- authored TEST Base runtime startup: PASS;
- authored TEST Dungeon runtime startup: PASS;
- fresh TEST Base cloud reload: schema 15 / tutorial present;
- fresh TEST Dungeon cloud reload: schema 15 / tutorial and quest feedback
  present.

Untracked `_tmp_*.rbxlx`/lock/cache artifacts remain local-only and are not
part of source control.

## HOLD

**STOP HERE FOR THE USER'S TWO-PLAYER MANUAL TEST.**

Do not implement world boss, raids, guild competition, territory or castle/PvP
until the user reports the friend test and explicitly releases the Section D
hold.
