# v3.44 Physical Adventure Quest Givers — Test Evidence
**Date:** 28 September 2026

## Scope

Physical Base quest-giver roles reusing the v3.43 Adventure dialogue system.

## Validation

Current Base package:

- Rojo build: PASS;
- BaseRuntime direct compile probe: PASS;
- `VERIFIED_QUEST_VARIETY_FOCUS_PASS 10`;
- `VERIFIED_PROFESSION_QUEST_CONTENT_FOCUS_PASS 11`;
- `VERIFIED_PHYSICAL_QUEST_GIVER_DIALOGUE_PASS 1`.

## Definition coverage

`QuestGiverDefinitionsTest` proves:

- eight stable quest-giver roles;
- every role has a physical offset and readable speaker;
- every mapped ID resolves to a real Adventure;
- narrative speaker equals quest-giver speaker;
- no Adventure belongs to two givers;
- all 13 current Adventures have a physical quest-giver role.

## Physical Base contract

`BaseQuestGiverContractTest` proves:

- generated quest-giver folder exists;
- physical count matches the definitions;
- each giver has stable ID/speaker attributes;
- each giver owns a Talk ProximityPrompt;
- prompts use 12-stud contextual distance;
- each giver has a world-space role label;
- `QuestDialogueOpen` exists.

## Live client path

Fresh Base Play moved the live test character beside the generated
Worldroot Keeper and sent the same presentation payload used by the runtime.

The client returned:

`VERIFIED_PHYSICAL_QUEST_GIVER_DIALOGUE_PASS 1`

Verified:

- shared conversation opened;
- speaker was Worldroot Keeper;
- title was A Relic Beneath the World Tree;
- start narrative was present;
- Accept Quest control was present.

## Authority

The new remote is presentation-only.

All Start/Claim requests still pass through the previously accepted
`BaseQuestRuntime` and `QuestService`.

## Acceptance

**GREEN.**
