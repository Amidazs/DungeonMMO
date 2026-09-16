# Phase 2 Rare Skill Book RNG Design

**Date:** 16 September 2026
**Status:** APPROVED
**Baseline:** local `main` at `d43f75f9cbfa22102650fb611712952493694615`

## Goal

Replace the guaranteed Arc Slash first-clear reward and unidentified production skill-book roll with a reusable personal RNG skill-book system. Skill books are named when they drop, can drop for any class, remain valuable as duplicates, and can come from both bosses and dungeon completion.

## Player-facing rules

- Skill books are RNG loot. Players do not select or target a book.
- A dropped book tells the player exactly what it is.
- Normal dungeon parties use personal loot: each eligible player rolls independently.
- Drop eligibility does not filter by class. A Mage or Ranger may receive an Arc Slash Skill Book.
- Books are tradable. A player may keep, sell, or trade an off-class book when trading exists.
- A book may still drop when the player already knows the skill.
- Learning remains class-restricted. Receiving an off-class book does not allow learning the skill.
- Bosses and dungeon completion are separate independent opportunities to roll a book.
- Future world bosses and raids may use shared drops plus a Need/Greed-style roll system; that is explicitly outside this gate.
- Future secret bosses can have unique book pools and exceptionally small chances without changing reward architecture.

## Initial Arc Slash tuning

The first production proof has one RNG book:

| Source | Personal chance | Pool |
| --- | ---: | --- |
| Supported dungeon boss | 2% | Arc Slash Skill Book |
| Supported dungeon completion | 1% | Arc Slash Skill Book |

Supported initial boss IDs:
- `MarauderCaptain`
- `CorruptedForeman`

Supported initial dungeon IDs:
- `TestDungeon`
- `AbandonedMine`

These values are balance data, not hard-coded reward logic. They can be changed later without rewriting the reward pipeline.

## Item model

Create a new production item:

- ID: `arc_slash_book`
- Name: `Arc Slash Skill Book`
- Kind: `SkillBook`
- Rarity: `Rare`
- Skill: `ArcSlash`
- Learnable: `true`
- Stackable: `true`
- Bound: `false`
- Tradeable: `true`

Keep `arc_slash_book_bound` as a legacy-compatible item so an existing profile that already owns the old reward is not broken. It remains learnable.

Keep `skill_book_test` only as legacy/test data and mark it test-only. It must no longer appear in a production loot table.

## Reward architecture

The new book roll is a bonus roll. It does not replace Gold, ordinary equipment/material loot, rare-state rewards, event rewards, or existing completion rewards.

### Boss kill

`EncounterService` already dispatches one exactly-once monster reward transaction per enemy death. For a boss it also supplies the boss ID to `RewardService`.

`RewardService:grant_monster_reward`:
1. applies existing XP/Gold behavior;
2. looks up an optional boss skill-book definition;
3. performs one independent book roll per eligible member;
4. adds a successful book to that member's inventory in the same profile mutation;
5. stores the book item ID in the existing monster reward-history record.

Replaying the same enemy transaction therefore returns the stored result and cannot roll or grant another book.

### Dungeon completion

`CompletionService` passes the completed session's `DungeonId` into the existing `RewardService:grant_completion` call.

`RewardService:grant_completion`:
1. performs the existing Gold and normal personal-loot work;
2. looks up an optional completion skill-book definition;
3. performs the independent bonus book roll;
4. adds a successful book in the same profile mutation;
5. stores the book item ID in the existing completion reward-history record.

Replaying the same completion transaction cannot roll another book.

## Guaranteed first-clear removal

`CompletionService` must no longer call `grant_arc_slash_first_clear`.

Remove the obsolete first-clear grant method and its dedicated test. Leave old persisted `OneTimeRewards.ArcSlashFirstClear` data alone for compatibility; it simply stops controlling new rewards.

## Learning rules

Do not create a second learning path. `SkillProgressionService:learn_skill` remains authoritative.

The new tradable Arc Slash book has the same `SkillId = "ArcSlash"` and `Learnable = true`, so:
- Fighter + sufficient SP + owned book: succeeds and consumes one book;
- Mage/Ranger: `ClassCannotTeachSkill`; book remains owned;
- duplicate ownership is allowed;
- already-known skill learning remains rejected by the existing service.

## Presentation

Completion presentation shows the exact named bonus book when `skill_book_item_id` is present. Boss and completion reward handling emit concise server logs for a successful rare-book grant so real wiring is visible in Studio evidence.

## Studio-only deterministic proof

Production uses the configured RNG.

For Studio gameplay proof only:
- `Workspace.TEST_ForceSkillBookDrop = true` forces a configured book roll to succeed;
- `Workspace.TEST_BlockSkillBookDrop = true` forces it to fail;
- the override is ignored outside Studio.

This is only a validation control. It does not persist and does not alter production chances.

## No profile schema change

No new profile field is required. Book ownership already lives in inventory, and reward idempotency already lives in monster/completion reward history. The new optional `SkillBookItemId` field is stored inside existing history records and remains backward-compatible when absent.

## Out of scope

- player trading UI/backend;
- auction house/market;
- Need/Greed/Pass;
- raid/world-boss shared loot;
- pity counters;
- fragments/currencies;
- loot targeting;
- unidentified books;
- new Mage/Ranger rare combat skills;
- secret-boss implementation itself;
- final economy/drop-rate balancing.

## Acceptance

Automated/static acceptance proves:
- exact 2% boss and 1% completion config;
- named tradable stackable Arc Slash book;
- no production `skill_book_test` roll;
- boss and completion success/failure RNG;
- personal rolls for multiple members;
- off-class receipt;
- duplicate receipt even when the skill is already known;
- transaction replay cannot duplicate a book;
- Fighter can consume the new book to learn Arc Slash;
- Mage cannot learn Arc Slash and keeps the book;
- guaranteed first-clear call/path is removed;
- legacy bound book remains defined;
- all relevant Rojo projects build;
- `git diff --check` passes.

Studio gameplay acceptance proves the real dungeon wiring with the Studio force switch, including at least one boss drop and one completion drop visible in server output/inventory.
