# DungeonMMO backend roadmap v1.95 — distinct quest names and combat ledger

Date: 23 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Supersedes: [v1.94 source drop foundation](
DungeonMMO_Roadmap_v1_94_C4_Quest_Drop_Foundation_20260923.md)
for the original class advancement backend only.
The newer humanoid/quadruped animation roadmap remains independent.

## Original DungeonMMO names, original game identity

| Purpose | Player-facing DungeonMMO name |
| --- | --- |
| Rogue quest captain | Captain Ashford |
| Rogue quest equipment mentor | Quartermaster Vela |
| Scout quest mentor | Pathfinder Elyra |
| Scout quest warden | Warden Thorne |
| Later rescue NPC | Scout Cael |
| Later Human transfer NPC | Marshal Briar |
| Later Elf transfer NPC | Pathwarden Siora |
| Rogue quest skeleton archetype | Crypt Sentinel |
| Rogue later brigand archetype | Cinder Brigand |
| Scout quest raider archetype | Bracken Raider |
| Scout later sentry archetype | Bracken Warden |
| Rogue quest title | The Ashen Blade Trial |
| Scout quest title | The Greenward Search |

New player-facing text also names Vela's trial weapons,
Crypt Sentinel Fragments and Cael's field report.
The already-owned trial equipment, quest IDs and legacy
source-proof/inventory keys are **not renamed in storage**;
changing those identifiers requires a separate tested
versioned migration. No external source quest URL is sent
as an original DungeonMMO quest snapshot.

The original Fighter/Mystic starting-family and class
advancement *structure* remains the desired reference.
All final writing, encounter layouts, ability visuals,
character designs, assets and game-specific quests must
be independently authored; a name change alone is not
a guarantee against intellectual-property issues.

## Implemented, committed and verified

- [x] Rename the two currently playable source-quest
  chains' NPCs, pending enemies, item display labels,
  quest titles and visible class-choice text.
- [x] Preserve legacy persisted character progress and
  personally owned trial equipment through the rename.
- [x] New optional server-only
  `C4QuestMonsterCombatLedger`:
  requires a registered real instanced source enemy,
  current physical encounter, exact monster ID,
  one unique enemy-life receipt, live qualified
  contributor, appropriate selected quest stage
  and equipped trial weapon when applicable.
  It now observes accepted server DamageService
  callbacks through the existing contribution bridge
  and has its own Dungeon-only source-quest service.
  **No physical source quest monster is registered
  in the live dungeon encounter yet.**
- [x] Actual unpublished Base focused
  original-quest/skill suite **5/5 PASS**, including
  **148** quest/naming assertions.
- [x] Actual unpublished Dungeon focused combat
  suite **2/2 PASS**: physical-model ledger
  **10 assertions** and existing contribution/
  quest-observer fan-out **13 assertions**,
  including accepted/lethal damage forwarding,
  zero/ownerless damage refusal and unchanged
  ordinary contribution recording.
- [x] Actual unpublished Base **two-client**
  physical-NPC stage-one/two playtest PASS,
  including four original displayed NPC names,
  separate owners, earned trial weapons and
  wrong-branch/replay denial.
- [x] Disposable local Base and Dungeon Rojo
  builds PASS. All permanent scripts, tests
  and documents edited in GitHub only.
  [Detailed actual v1.95 test record](
../testing/c4-original-naming-and-monster-ledger-v1-95-20260923.md).

## Next executable engineering work — stage three

- [ ] Design separately authored **instanced** challenge
  room(s) reached from the existing hub/party flow,
  with physical Crypt Sentinel and Bracken Raider
  enemies. Use registered NPC factories and
  genuine damage/death callbacks. A normal dungeon
  Marauder/Wolf kill must never count as a source quest.
- [x] The existing contribution bridge forwards
  accepted DamageService hits to the optional
  original quest ledger without replacing
  threat or ordinary party/world-boss contribution.
  The Dungeon session attaches its own original
  source-quest service and wipes old receipts.
- [ ] Register actual dedicated room enemy models
  and test the one-use world verifier with genuine
  players. Prevent outsider, spectator,
  disconnected, wrong-branch, stale-session
  and unequipped-trial-weapon evidence.
- [ ] Source-item grant, receipt and stage-three
  advancement must commit on the rightful profile,
  survive Dungeon-to-Base handoff and never
  double-grant across retries or reconnects.
  Test both branches with real two-client combat,
  successful kills, distinct personally owned
  drops and secure stage-four NPC turn-in.
- [ ] Build the later independently authored
  brigand/warden challenge steps and real
  Scout Cael return, Ashford/Elyra recommendations,
  final transfer mentor NPCs and atomic level-20
  original class/skill/trainer authorization.
  Keep character level, race, original Fighter/
  Mystic branch, class prerequisites and mastery
  gates enforced by the server.
- [ ] Original C4 level-20 Warrior/Knight source
  skill inventories beyond the existing 28
  entries, remaining original class branches,
  second/third transfer and legacy specialist
  versioned migration remain separate work.
- [ ] Audit final original NPC/monster/quest item
  names, story beats, dialogue, icons, meshes,
  animations and UI to avoid using protected
  source-game expression; get qualified legal
  advice before commercial release if needed.

## Status and safeguards

Authentic original first-transfer classes fully
playable: **0/18**. Human/Elf Fighter/Mystic starters
and explicit class choices remain supported.
Live NPC steps one/two for Human Rogue and
Elven Scout are accepted. Stage three now
has a tested ledger wired to accepted Dungeon
damage callbacks but **no registered live
quest-monster encounter**. Actual quest enemies,
drops earned through real client attacks,
late quest turn-in and final class awards
remain unavailable. Exactly one Gathering
and one Crafting profession per character,
trade economy, hub-based instanced travel,
party gating, legacy save preservation,
separate animation work and the no-publish/
no-`main`-merge policy remain unchanged.
