# DungeonMMO Roadmap v3.44
## Physical Adventure Quest Givers GREEN
**Date:** 28 September 2026

This checkpoint moves the accepted v3.43 Adventure dialogue out of the
Adventure Board alone and into physical Base quest-giver presentation.

## Physical quest-giver roles

Eight stable presentation roles now exist around the Base Adventure area:

- Worldroot Keeper;
- Huntmaster;
- Village Captain;
- Temple Archivist;
- Mine Warden;
- Expedition Pathfinder;
- Survey Corps;
- Expedition Quartermaster.

Together they cover all 13 current launch Adventures exactly once.

The current physical bodies are replaceable anchored placeholders. Their stable
IDs, speaker roles, prompt contract and quest ownership are the accepted layer;
final NPC meshes, clothing, animation, portraits and names may replace the
presentation later.

## Shared dialogue

Physical quest givers reuse the existing:

- `QuestNarrativeDefinitions`;
- `QuestNarrativePresenter`;
- `QuestActionRequest` server authority.

A new presentation-only `QuestDialogueOpen` remote lets the server tell one
client which already-defined quest conversation should be shown.

The server selects the conversation from authoritative state in this order:

1. ready quest -> Claim;
2. active unfinished quest -> Review;
3. eligible unstarted quest -> Start;
4. completed quest -> Complete.

A physical NPC cannot grant rewards or fabricate progress.

## Adventure Board role

The Adventure Board remains available as an overview/catalogue.

Physical quest givers now provide the story-facing interaction path, while the
board remains useful for seeing the broader Adventure list.

The same conversation UI is reused for both sources.

## Contextual distance

The conversation UI now tracks the physical object that opened it.

- Board conversations close when the player leaves the board context.
- NPC conversations close when the player leaves that NPC context.
- Opening an NPC conversation no longer incorrectly measures distance from the
  Adventure Board.

## Fresh validation

Source head before later feedback fix:

`c5901aeaa8ed658f095afc5fab2b2058548b8be9`

Current-head Base code remains unchanged by the later Dungeon-only rune fix.

Fresh validation:

- Base Rojo build: PASS;
- BaseRuntime compile probe: PASS;
- `VERIFIED_QUEST_VARIETY_FOCUS_PASS 10`;
- `VERIFIED_PROFESSION_QUEST_CONTENT_FOCUS_PASS 11`;
- `VERIFIED_PHYSICAL_QUEST_GIVER_DIALOGUE_PASS 1`.

The 11-suite Base regression includes the new
`BaseQuestGiverContractTest`.

## What is GREEN

- eight stable physical quest-giver roles;
- all 13 current Adventures mapped exactly once;
- narrative speaker/quest-giver role consistency;
- Talk prompts;
- world-space role labels;
- server-selected Start/Review/Claim/Complete conversation mode;
- shared conversation UI;
- physical giver -> client dialogue presentation;
- contextual close against the correct physical source;
- existing server-owned Start/Claim authority.

## What remains presentation debt

- final NPC models and names;
- final animation/idle sets;
- portraits;
- voice/audio;
- cinematic cameras;
- authored final hub positioning.

Those are art/presentation replacements over the accepted contract.

## Next gate

Finish visible in-dungeon objective feedback for the already-accepted hidden
room, escort, puzzle and defend/survive mechanics. Do not add another objective
family before Section D.
