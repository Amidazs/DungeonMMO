# DungeonMMO Roadmap v3.31
## Profession-aware Adventure content GREEN
**Date:** 28 September 2026

This checkpoint closes the first profession-aware launch Adventure after the
v3.30 live Skinning checkpoint.

## Adventure chain

The Base Adventure catalogue now contains three ordered one-time quests:

1. Worldroot Relic;
2. Echoes from the Abandoned Mine;
3. **Provisions for the Next Expedition**.

The new Provisioning Adventure requires one fresh clear of both current launch
dungeons after its prerequisite is completed:

- Temple / TestDungeon: 1 clear;
- Abandoned Mine: 1 clear.

Profession selection is not required to start, progress or claim it.

## Reward design

The Provisioning reward is server-owned and atomic:

- **75 Gold**;
- **2 Deep Iron Ore**;
- **2 Moonpetal**;
- **2 Thick Hide**.

The three materials are intentionally tradeable advanced profession inputs.
The quest therefore gives ordinary adventurers a way to feed the player market
without bypassing Mining, Herbalism or Skinning progression.

A real-service integration proves an off-profession quest character can claim
the bundle, sell Deep Iron through MarketService, and a Blacksmith who selected
Herbalism instead of Mining can buy that ore and use it in the profession
economy.

## Reward authority

QuestService now supports both legacy single-item rewards and reviewed
multi-item Adventure bundles.

Reward application remains inside one profile mutation:

- quest readiness is rechecked;
- completion is committed once;
- every item grant must succeed;
- Gold and all items are applied atomically;
- replayed claims are rejected;
- persisted quest completion/rewards survive reload.

No client-authored item or Gold values are accepted.

## Physical Adventure Board

The existing Base dungeon board anchor now exposes the contextual
**Adventure Board** prompt.

Server contract:

- board resolves from the Base environment;
- prompt action is Browse;
- prompt label is Adventure Board;
- activation distance is 12 studs;
- the old unused Dungeon Board prompt is not duplicated.

The board UI is contextual rather than a permanent HUD window.

## Client presentation

The Adventure Board renders one card per server Adventure with:

- quest title and minimum level;
- objective progress;
- reward text;
- Start Quest / In Progress / Claim Reward / Locked / Completed state.

The latest client refactor split card shell/header/details/action rendering
without changing observable behavior.

Current-head Studio snapshots proved:

- initial cards:
  Worldroot Relic = Start Quest,
  Mine Echoes = Locked,
  Expedition Provisioning = Locked;
- provisioning reward text:
  75 Gold + 2 Deep Iron Ore + 2 Moonpetal + 2 Thick Hide;
- ready provisioning:
  both dungeon objectives 1/1 and Claim Reward;
- contextual close:
  moving to 40 studs closes the board automatically.

## Studio acceptance

Fresh Rojo builds from source head
`fcaaa5549fa2881271bd7aca86a0fbac00e3fb3f` passed:

- `git diff --check`;
- `base.project.json` build;
- `default.project.json` build.

Current-head focused package:

`VERIFIED_PROFESSION_QUEST_CONTENT_FOCUS_PASS 8`

Current-head renderer markers:

- `VERIFIED_ADVENTURE_BOARD_V2_INITIAL_RENDER_PASS`;
- `VERIFIED_ADVENTURE_BOARD_V2_READY_RENDER_PASS`;
- `VERIFIED_ADVENTURE_BOARD_V2_DISTANCE_CLOSE_PASS`.

The prior v1 live rehearsal also proved a real server quest start through the
Adventure Board path before the presentation-only card refactor.

## What is GREEN

- ordered Adventure catalogue;
- Provisioning prerequisite and dual-dungeon objectives;
- atomic multi-item Adventure rewards;
- profession-optional quest completion;
- quest reward -> market -> profession use;
- physical Base Adventure Board prompt contract;
- contextual Adventure Board client rendering;
- current-head ready/locked/action presentation;
- distance-based automatic close;
- v3.28 economy, v3.29 blueprint acquisition and v3.30 live Skinning
  regressions used by the focused package remain green.

## What remains content work

This checkpoint does not claim the launch quest catalogue is complete.

Still open:

- broader launch-level Adventure/side-quest coverage;
- review of which creation-enabled races/classes should receive each Adventure;
- profession-aware optional objectives/rewards beyond this first provisioning
  quest;
- final NPC/board art and quest-writing polish;
- final profession station/resource presentation and crafting minigames;
- production publish or main-branch merge.

## Next development gate

Audit the **launch quest catalogue and eligibility** against the currently
creation-enabled races/classes, then expand launch-level content without making
profession participation mandatory for core progression.

Keep trade pressure intact: profession materials may be valuable optional
rewards, but normal quest completion must not require a player to own a
specific profession.
