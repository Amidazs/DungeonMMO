# DungeonMMO Roadmap v3.40
## Quest Variety Foundation GREEN
**Date:** 28 September 2026

This checkpoint expands launch quest design beyond kill, clear and checkpoint
objectives while preserving the server-authority rules established in v3.38
and v3.39.

## Research direction

Quest-design research was reviewed before implementation. Useful reusable MMO/RPG
patterns include combat, gather/collect, kill-and-loot, exploration, world
interaction, hidden discovery, delivery/breadcrumb, escort, defend/survive,
quest-item use, profession requests and composite quest chains.

The project-specific design notes are recorded in:

`docs/design/Quest_Archetype_Research_20260928.md`

DungeonMMO keeps one stricter rule than a generic quest catalogue:
**every objective must have a trusted server-owned publisher before it can ship.**

## New trusted objective types

### WorldInteraction

Published only after a server-bound physical interaction passes:

- known interaction identity;
- correct dungeon/difficulty;
- active session membership;
- server-computed distance;
- required encounter state;
- active matching quest objective.

### ItemCollected

Published only after:

- the relevant server interaction has opened access;
- the player owns the active matching objective;
- server distance passes;
- the quest item is granted through authoritative inventory mutation.

Personal collection is independent per party member.

### EscortCompleted

Published only by the server-owned escort lifecycle after:

- the escort was genuinely started in the correct dungeon;
- its start encounter prerequisite is clear;
- its route state exists in the dungeon session;
- its final safety encounter is server-confirmed clear.

No client is allowed to report escort completion.

## New Adventure: Whispers Behind the Stone

Quest ID: `HiddenWardDiscovery`.

- minimum level: 6;
- prerequisite: Worldroot Relic;
- optional;
- activate the faded Temple panel;
- reveal the tutorial hidden alcove;
- collect one bound Hidden Ward Fragment;
- turn the fragment in;
- reward: 50 Gold + 1 Warding Essence.

The hidden room teaches players early that secret spaces and mechanisms exist.
It is deterministic tutorial content and does not replace the existing random
optional-secret/boss systems.

The current synthetic Temple and the placeholder physical-content path both use
the same stable hidden-panel, door and collectible contracts.

Quest item turn-in is now atomic with QuestService reward claiming. A ready
quest cannot pay out when its required turn-in item is missing.

## New Adventure: Guide the Lost Surveyor

Quest ID: `MineSurveyorEscort`.

- minimum level: 9;
- prerequisite: Mine Echoes;
- optional;
- objective: `EscortCompleted / AbandonedMine:MineSurveyor`;
- reward: 70 Gold + 2 Deep Iron Ore.

The current synthetic Abandoned Mine includes a server-owned escort route.

The escort is intentionally not a slow suicidal follower:

1. the surveyor becomes relevant after CombatRoom1 is safe;
2. the surveyor moves at a normal player-like running pace;
3. it stops at a safe point before Room 2;
4. the party fights Room 2 using normal dungeon combat;
5. it resumes only after CombatRoom2 is server-confirmed Cleared;
6. reaching the final route marker publishes `EscortCompleted`.

If the party is too far away, the escort waits safely rather than failing
because the NPC ran off alone. Escort phase is persisted in session state for
runtime recovery.

The NPC model/animation is deliberately replaceable presentation.

## Advancement quests are multiple quests

The first-transfer path is now formally exposed as **three player-facing quests
for every one of the 18 mapped first-transfer branches**.

Each branch keeps its existing trusted, branch-specific ordered source-stage
ledger underneath. The presentation layer groups that ledger into:

1. **The Call**;
2. **Field Trial**;
3. **Final Proof**.

Short six-step branches and longer Human Rogue, Elven Scout, Gearwright and
Deepclaimer branches keep their actual source-specific steps. The three-quest
presentation does not flatten their mechanics.

A real catalogue defect was found during this work:
`C4OriginalFirstTransferQuestStages.inventoried()` contained all 18
definitions in the source table but returned only 13. The five omitted
already-defined branches are now included, restoring 18/18 enumeration.

The original first-transfer service now exposes:

- quest arc ID;
- current quest ID/title;
- current quest index;
- quest count = 3.

The first-transfer UI displays Quest 1/3 through Quest 3/3.

The old single-clear generic advancement trials remain only as compatibility for
profiles that had already started one before the C4 migration. Fresh original
Fighter/Mage starters are explicitly blocked from starting them by
`OriginalC4BranchChoiceRequired`.

## Fresh validation

Source head before documentation:

`352d91f8c0d9d3a37388fdaba11cc6d1ff560ed7`

Static/build:

- `git diff --check 48e47f35..HEAD`: PASS;
- Base Rojo build: PASS;
- Dungeon Rojo build: PASS.

Fresh Base Play:

`VERIFIED_QUEST_VARIETY_FOCUS_PASS 6`

The package covers:

- Adventure definitions;
- creation-enabled race/level eligibility;
- hidden-room interaction + item + turn-in integration;
- Lost Surveyor escort lifecycle integration;
- 18-branch three-quest advancement arc coverage;
- existing first-transfer source-stage integration.

Broader Base regression:

`VERIFIED_PROFESSION_QUEST_CONTENT_FOCUS_PASS 10`

Fresh current Temple presentation:

`VERIFIED_HIDDEN_ROOM_PRESENTATION_PASS 1`

Fresh current Abandoned Mine presentation:

`VERIFIED_LOST_SURVEYOR_PRESENTATION_PASS 1`

Existing Dungeon checkpoint/adventure regression remained:

`VERIFIED_CHECKPOINT_ADVENTURE_FOCUS_PASS 5`

## Current launch variety

The launch catalogue now contains examples of:

- dungeon clear;
- enemy defeat;
- checkpoint exploration;
- mixed checkpoint + clear;
- world interaction;
- hidden-room discovery;
- personal quest-item collection;
- real item turn-in;
- escort progression;
- profession-aware rewards;
- multi-quest class advancement.

## Presentation status

The server contracts are real.

Still replaceable/pending:

- final hidden-room environment art;
- final panel/button model and activation VFX;
- final Hidden Ward Fragment art;
- final Lost Surveyor NPC model;
- escort locomotion/idle/talk animations;
- quest dialogue and voice/text presentation;
- environmental storytelling;
- final quest markers and journal polish.

## Next gate

Do not return to a sequence of repetitive bounties.

Next useful quest families are:

1. server-owned **Defend/Survive** objectives;
2. **Use Quest Item** / socket / ritual / puzzle interactions;
3. delivery/breadcrumb quests where they introduce a real NPC or location;
4. richer dialogue and narrative continuity around the accepted quests.

A later protection escort may allow enemies to threaten the escort NPC, but it
must use explicit target/health/failure rules and should not turn the first
escort tutorial into a frustrating failure-state exercise.

Depths 2-4 remain release-disabled until their physical content is ready.
