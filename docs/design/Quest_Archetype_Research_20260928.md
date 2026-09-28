# DungeonMMO Quest Archetype Research
## 28 September 2026

### Goal

Increase launch quest variety without weakening DungeonMMO's server-authority
rules or turning the launch path into a sequence of repeated kill bounties.

The guiding rule remains:

> A quest objective is not shippable until the game has a trusted server-owned
> publisher for the action that completes it.

### Useful quest archetypes

Research across MMO/RPG quest design points to a broad set of reusable tasks:

- combat / defeat targets;
- defeat targets and recover personal proof items;
- gather or collect world items;
- exploration / reach a location;
- activate or interact with world objects;
- hidden discovery / puzzles and secret spaces;
- delivery / breadcrumb quests;
- escort / protect an NPC or object;
- defend a location for waves or time;
- use a quest item on an enemy or world object;
- crafting / profession requests;
- timed or scripted encounters;
- mixed-objective investigation chains.

The important design lesson is to combine these patterns rather than treating
each quest as one isolated counter.

### Launch implementation order

#### 1. Interaction + hidden discovery + item collection

Implement first because the released Temple already has a natural place to
teach the player that hidden rooms exist.

**Whispers Behind the Stone**:

1. reach the Temple after Room 1;
2. activate a faded stone panel;
3. reveal a small hidden alcove;
4. collect a bound Hidden Ward Fragment;
5. return/claim the quest, consuming the fragment.

This introduces reusable trusted objective types:

- `WorldInteraction`;
- `ItemCollected`.

The hidden room is deterministic tutorial content. It is separate from the
existing optional Secret Boss roll: the tutorial teaches the concept without
promising that every secret route appears every run.

#### 2. Escort / protection

Build next as a dedicated server-owned escort authority rather than a client
movement counter.

DungeonMMO escort rules should be:

- the escort NPC moves at or near player running speed;
- it pauses at safe scripted points, not because the player must slow-walk;
- it does not deliberately charge into unrelated enemy packs;
- scripted ambushes use the normal encounter/combat authority;
- party members may help without taking turns;
- progress is session-owned and survives a valid reconnect;
- failure/retry rules are explicit;
- completion publishes a trusted `EscortCompleted` event.

A good first use would be rescuing an NPC from a dungeon side route and
escorting them to a checkpoint or exit.

#### 3. Defend / survive

A server-owned encounter can require protecting a ward, NPC, cart, ritual or
door for a number of waves. This reuses combat but changes positioning and
priority decisions.

#### 4. Use-item / puzzle interaction

Examples:

- place a recovered rune into a socket;
- use an antidote on a corrupted creature;
- light braziers in an authored order;
- carry a key to a sealed gate;
- disable two mechanisms before a boss.

These should publish explicit server-authored interaction events.

#### 5. Delivery / breadcrumb

Use sparingly to connect hubs, NPCs, professions and dungeon entrances. A
delivery should normally reveal new information, a new character or a new
location rather than exist only as walking time.

#### 6. Profession requests

Profession quests can request crafted or gathered goods, but the main story
must remain completable without choosing a particular profession. Tradeable
materials can let non-specialists participate through the market.

### Advancement quests

First class transfer must be a **quest chain**, not one generic dungeon-clear
trial.

Every one of the 18 mapped first-transfer branches is presented as three
distinct quests over the existing trusted ordered source-stage ledger:

1. **The Call** — meet mentors, establish the branch and learn the problem;
2. **Field Trial** — the substantial travel/combat/item/proof portion;
3. **Final Proof** — resolve the branch-specific climax and return for
   transfer approval.

The exact underlying steps remain branch-specific. A short six-step branch and
the longer Gearwright, Deepclaimer, Human Rogue and Elven Scout paths therefore
keep their existing mechanics while still appearing to the player as a
three-quest advancement story.

Legacy single-clear advancement trials remain only for compatibility with
already-started old profiles. Fresh original Fighter/Mage progression must use
the branch-specific first-transfer chain and final mentor handoff.

### Design constraints

- No client-reported "I pressed it", "I found it" or "I escorted it" proof.
- A party interaction may unlock shared geometry, while personal collectibles
  remain independently claimable for each eligible quest owner.
- Quest items required at turn-in are consumed atomically with reward grant.
- Optional side quests must not block the core story unless intentionally
  promoted to a story-chain requirement.
- Depths 2-4 remain unavailable until their physical content is accepted.
- Placeholder quest geometry must expose stable interaction contracts so final
  art can replace it without rewriting quest logic.
- Quest variety should improve pacing and teach systems, not create arbitrary
  chores.

### Research notes

Common MMO quest patterns include gathering, kill-and-loot, delivery, escort,
exploration, profession tasks and using quest items on targets. Mission-design
literature also commonly groups objectives into combat, travel, gathering and
crafting, with escort and composite missions inside those families.

Escort quests have a consistent failure mode: slow or reckless NPCs remove
player control. The DungeonMMO version should therefore keep pace with the
player, use safe pauses and meaningful ambushes, and integrate with the same
combat mechanics the player already knows.

Hidden/interactable objectives are particularly useful early because a quest
can teach a persistent game rule: walls, mechanisms and side spaces are worth
examining even when no quest marker later points directly at them.
