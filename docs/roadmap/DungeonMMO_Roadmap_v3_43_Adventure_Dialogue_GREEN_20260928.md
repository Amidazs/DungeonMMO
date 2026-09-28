# DungeonMMO Roadmap v3.43
## Adventure Dialogue and Narrative Presentation GREEN
**Date:** 28 September 2026

This checkpoint begins the presentation-focused phase after the initial launch
quest-variety foundation.

The quest backend is unchanged: Start, progress, completion, rewards and
persistence remain server-owned. This checkpoint adds a reusable player-facing
conversation layer over those accepted contracts.

## Reusable Adventure narrative catalogue

Every current launch Adventure now has presentation text for four states:

1. **Start** — why the quest matters before acceptance;
2. **Progress** — contextual reminder while the quest is active;
3. **Ready** — turn-in dialogue after objectives are complete;
4. **Complete** — short closure after the reward is claimed.

The catalogue covers all 13 current Adventures:

- A Relic Beneath the World Tree;
- Wolves at the Worldroot;
- The Captain's Price;
- Whispers Behind the Stone;
- Echoes from the Abandoned Mine;
- Survey the Broken Ways;
- Guide the Lost Surveyor;
- The Foreman's Reckoning;
- The Resonant Seal;
- Follow the Fracture;
- Hold the Resonance;
- Break the Chain;
- Provisions for the Next Expedition.

## Narrative continuity

The launch story now has a deliberate through-line instead of isolated board
contracts.

The principal early story reads as:

Worldroot disturbance
-> Temple relic
-> Mine echoes
-> comparative ruin survey
-> hidden ward / resonance discoveries
-> ordered Resonant Seal
-> fracture linking Temple and Mine
-> stabilising the Temple through Hold the Resonance.

Optional combat, escort and provisioning Adventures remain side content rather
than blockers unless their explicit prerequisite says otherwise.

The Temple investigation uses a consistent **Temple Archivist** presentation
voice across:

- Whispers Behind the Stone;
- The Resonant Seal;
- Follow the Fracture;
- Hold the Resonance.

Speaker roles are presentation identities and may later be replaced by final NPC
names/models without changing quest IDs or server contracts.

## Adventure Board conversation flow

The Adventure Board no longer immediately sends a Start or Claim request when a
player presses the quest action button.

The accepted presentation flow is now:

- available quest -> **Start Quest** -> start conversation -> **Accept Quest**;
- active unfinished quest -> **Review** -> progress conversation;
- active ready quest -> **Claim Reward** -> turn-in conversation ->
  **Complete Quest**;
- successful claim -> completion dialogue;
- completed quest -> disabled **Completed** state;
- locked quest -> disabled **Locked** state.

The final Start/Claim request is still sent to the existing server-owned
`BaseQuestRuntime`. No dialogue choice can fabricate quest progress or reward
state.

## Reusable presentation modules

New shared modules:

- `QuestNarrativeDefinitions.luau` — content only;
- `QuestNarrativePresenter.luau` — action-state and dialogue-selection rules.

This keeps narrative content and presentation logic outside the already-large
Adventure Board LocalScript.

## First-transfer advancement remains multi-quest

This checkpoint does not change first-transfer authority.

All **18** mapped first-transfer branches still expose exactly **three
player-facing quests** over their branch-specific trusted source ledgers:

1. The Call;
2. Field Trial;
3. Final Proof.

The older one-clear advancement prototypes remain legacy compatibility only and
must not replace the branch-specific quest chains.

## Fresh validation

Source head before documentation:

`468836309cfd7fcf2de73aa99aac3999ab6355b4`

Static/build checks:

- `git diff --check facee19da..HEAD`: PASS;
- Base Rojo build: PASS;
- Dungeon Rojo build: PASS.

Fresh unpublished Base Play:

`VERIFIED_QUEST_VARIETY_FOCUS_PASS 9`

`VERIFIED_PROFESSION_QUEST_CONTENT_FOCUS_PASS 10`

Fresh client presentation check:

`VERIFIED_QUEST_CONVERSATION_UI_PASS 1`

## Quest narrative acceptance coverage

`QuestNarrativePresentationTest` verifies:

- every current Adventure has a narrative entry;
- every narrative has a readable speaker;
- Start, Progress, Ready and Complete phases are non-empty;
- the Temple investigation keeps one consistent narrative voice;
- available quests open Start mode;
- prerequisite failures remain Locked;
- active unfinished quests open Review mode;
- ready quests open Claim mode;
- completed quests cannot be accepted again;
- puzzle dialogue preserves the reviewed Moon -> Root -> Flame order;
- defense dialogue explains the Resonance Ward;
- missing narrative content fails to readable fallback text.

## Live UI validation

The current Base client successfully creates:

- `QuestConversation` frame;
- speaker label;
- quest-title label;
- dialogue label;
- Back button;
- Confirm button.

The conversation begins hidden and is opened only from a quest action.

## What is GREEN

- reusable launch Adventure narrative catalogue;
- Start/Progress/Ready/Complete narrative phases;
- consistent Temple story continuity;
- shared presenter logic;
- Start confirmation before server request;
- in-progress Review flow;
- Claim confirmation before server request;
- completion dialogue after successful claim;
- existing Base quest/profession regression;
- existing 18 x three-quest first-transfer advancement rule.

## Placeholder / presentation status

Speaker roles and visible dialogue are now real presentation content, but final
NPC embodiment is still pending.

Later work can replace:

- role labels with final NPC names;
- board-only presentation with physical quest-giver NPC interactions;
- placeholder NPC models;
- portrait art;
- voice/audio cues;
- cinematic camera work.

These replacements should reuse the narrative catalogue and existing trusted
quest state rather than duplicating quest logic.

## Next development gate

The next presentation gate should connect the reusable narrative content to
**physical quest-giver NPCs** and improve moment-to-moment quest feedback.

Priority:

1. map major narrative roles to Base NPC anchors;
2. allow the same conversation presenter to open from those NPCs;
3. keep the Adventure Board as a useful overview, not the only storyteller;
4. add clearer in-dungeon objective feedback for hidden rooms, escorts, puzzles
   and defense;
5. begin replacing the highest-impact NPC/enemy presentation placeholders;
6. keep Depths 2-4 release-disabled until their physical content is accepted.
