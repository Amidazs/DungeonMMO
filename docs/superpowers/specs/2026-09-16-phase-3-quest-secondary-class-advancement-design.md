# Phase 3 Quest + Secondary-Class Advancement Foundation — Design

**Date:** 16 September 2026
**Phase:** Phase 3 — Systems Alpha
**Status:** Approved for implementation
**Starting local-main baseline:** `c7d6721b1c30eb52660b620d02f9bcf9e5d180f2`
**Remote note:** `origin/main` intentionally remains `60fc0dfd9954e2d580157a580da2425e2b71dd70`.

## Purpose

Phase 2 is formally complete. The first Phase 3 backend gate proves two roadmap requirements together:

1. a reusable server-authoritative quest/objective foundation; and
2. the first race-specific secondary-class advancement split.

This gate proves the architecture with the existing Mage base class because Human Mage and Elf Mage already share the same accepted Phase 2 base-class contract. The advancement result therefore demonstrates genuine race divergence without requiring another combat-content phase.

## Scope

The gate adds:

- persistent quest state;
- persistent race-specific secondary-class advancement state;
- a reusable normalized quest-event API;
- an advancement trial quest driven by a real dungeon-completion event;
- Human Mage -> **Arcanist**;
- Elf Mage -> **Spellweaver**;
- Base-only start/claim authority for advancement;
- schema v7 -> v8 migration through the existing migration/deep-fill pipeline;
- automated service, migration and dungeon-bridge coverage.

The gate does **not** add:

- new Mage combat skills;
- new equipment families;
- a broad secondary-class skill tree;
- Fighter/Ranger secondary classes;
- final advancement NPC/UI/art;
- Race Change;
- guilds, reputation, bestiary, market, raids, world bosses or castle systems;
- monetisation or Robux behavior;
- any Starting Base presentation work.

## Compatibility model

Existing accepted systems treat `Identity.ClassId` / `Identity.BaseClassId` as the Phase 2 gameplay family (`Fighter`, `Mage`, `Ranger`). Replacing `Identity.ClassId` with a new secondary-class ID in this first gate would force unrelated equipment, trainer, combat and item-eligibility systems to understand the full future lineage graph immediately.

Instead, v1 keeps the accepted base-family identity stable and adds a separate persistent advancement state:

```luau
ClassAdvancement = {
    Version = 1,
    ActiveClassId = nil,
    CompletedByRace = {},
}
```

After advancement:

- Human Mage keeps `Identity.BaseClassId == "Mage"` and `Identity.ClassId == "Mage"`;
- `ClassAdvancement.ActiveClassId == "HumanArcanist"`;
- completion is recorded under `CompletedByRace.Human.HumanArcanist`;
- Elf Mage uses `ElfSpellweaver` in the equivalent state.

This is a deliberate lineage boundary, not client presentation state. Existing base-class compatibility remains authoritative for Phase 2 systems; Phase 3 content can query the advanced identity explicitly.

A future Race Change system can deactivate/restore `ActiveClassId` according to `CompletedByRace` without manufacturing advancement completion.

## Persistent schema v8

Each character gains:

```luau
Quests = {
    Version = 1,
    Active = {},
    Completed = {},
}

ClassAdvancement = {
    Version = 1,
    ActiveClassId = nil,
    CompletedByRace = {},
}
```

Active quest state:

```luau
Quests.Active[questId] = {
    Objectives = {
        [objectiveId] = currentCount,
    },
    AppliedEvents = {
        [eventId] = true,
    },
    Ready = false,
}
```

Rules:

- quest event IDs are deduplicated per active quest;
- objective counts clamp to their configured requirement;
- a quest becomes `Ready` only after every objective is satisfied;
- an advancement quest is moved from `Active` to `Completed` in the **same profile mutation** that applies the secondary class;
- malformed/missing new tables are repaired by the existing versioned profile migration/deep-fill path;
- Bank, professions, Inventory, Equipment, progression and all prior profile data remain unchanged.

## Definitions

### Secondary classes

The first proof contains exactly two definitions:

| Race | Base class | Secondary class ID | Display |
|---|---|---|---|
| Human | Mage | `HumanArcanist` | Arcanist |
| Elf | Mage | `ElfSpellweaver` | Spellweaver |

Both use `MageAdvancementTrial`.

These names establish the proof only. Broader class-tree naming and balance remain later Phase 3 work.

### Mage advancement trial

`MageAdvancementTrial` is a data definition, not hard-coded service behavior.

Prototype eligibility:

- complete character identity;
- Race = Human or Elf;
- BaseClassId = Mage;
- Level >= 20;
- not already completed for that race.

Prototype objective:

- complete the accepted Temple dungeon once **after the quest is started**.

The level-20 requirement uses the current accepted Phase 2 cap as a convenient proof threshold. It is configuration, not a permanent launch-balance promise.

Normal dungeon completion remains valid for players without the quest.

## Quest event contract

Quest progression consumes normalized server-owned events:

```luau
{
    EventId = "stable-server-event-id",
    Type = "DungeonClear",
    TargetId = "TestDungeon",
    Amount = 1,
}
```

v1 implements the generic matching path but only wires the event source needed for this gate: `DungeonClear`.

The API intentionally leaves room for later trusted producers such as:

- enemy kills;
- gathering;
- crafting;
- item acquisition;
- interactions;
- dungeon conditions.

Those producers are not wired in this gate.

Clients never submit authoritative quest progress.

## Services

### `QuestService`

Responsibilities:

- validate quest existence and prerequisites;
- start a quest;
- record normalized trusted events;
- deduplicate events;
- update objective counts;
- mark a quest Ready;
- build a read-only snapshot;
- expose a character-level helper used by another server service to atomically consume a ready quest.

Stable rejection reasons:

- `ProfileNotLoaded`
- `IdentityIncomplete`
- `UnknownQuest`
- `QuestUnavailable`
- `QuestAlreadyActive`
- `QuestAlreadyCompleted`
- `InvalidQuestEvent`
- `QuestMutationFailed`

### `ClassAdvancementService`

Responsibilities:

- resolve the race/base-class advancement candidate;
- enforce Base-only start and claim actions;
- start the candidate's advancement quest through `QuestService`;
- atomically claim a ready advancement quest and persist the race-specific secondary class;
- prevent duplicate completion;
- expose a backend snapshot for future UI.

Stable rejection reasons:

- `BaseOnlyAction`
- `ProfileNotLoaded`
- `IdentityIncomplete`
- `AdvancementUnavailable`
- `AdvancementAlreadyCompleted`
- `AdvancementQuestNotReady`
- `QuestStartFailed`
- `ProfileMutationFailed`

## Dungeon integration

The existing accepted `CompletionService` remains the completion/reward save barrier.

After an eligible player's normal completion reward succeeds, it sends exactly one normalized `DungeonClear` event into `QuestService` using:

```text
EventId = <session_id>:DungeonClear
TargetId = session.DungeonId
```

The event is recorded before the existing completion save barrier. Therefore quest progress persists with the same profile save that already protects completion rewards.

If the completion transaction is retried, `AppliedEvents` prevents duplicate quest progress.

The bridge is optional at the `CompletionService` constructor boundary so existing focused tests/callers that do not supply QuestService remain valid.

## Runtime composition

`RuntimeServices` creates one `QuestService` and one `ClassAdvancementService` from the existing shared `ProfileService`.

- Base: quests + advancement start/claim are available.
- Dungeon: quest event recording is available; advancement mutation is rejected by `BaseOnlyAction`.
- no parallel datastore or MemoryStore system is introduced.

## UI and player interaction

This is intentionally a backend-first gate.

There is no final advancement panel/NPC in v1. The service API is the stable seam for the later UI/content slice. This prevents the first Phase 3 backend gate from becoming a presentation redesign.

A Studio acceptance harness may call the server services/test fixtures to prove the full persistence bridge. No client is allowed to directly grant objective progress or advancement.

## Testing

Automated coverage must prove:

1. definitions resolve Human Mage -> Arcanist and Elf Mage -> Spellweaver;
2. non-Mage/non-level-20 characters cannot start the trial;
3. quest start is idempotently rejected on duplicate start;
4. an unrelated dungeon clear does not progress the Temple objective;
5. the Temple event progresses once;
6. replaying the same event ID does not progress twice;
7. Ready is reached only at the configured count;
8. Dungeon context cannot start/claim advancement;
9. claim before Ready is rejected;
10. Human claim records `HumanArcanist`;
11. Elf claim records `ElfSpellweaver`;
12. duplicate claim is rejected;
13. claiming moves the quest to Completed atomically;
14. schema v7 migration becomes v8 while preserving accepted Bank/profession state;
15. CompletionService emits the normalized event and does not emit it again after the session is already committed;
16. all existing Rojo projects still build.

## Acceptance boundary

Automated acceptance requires:

- RED tests installed before production modules;
- GREEN static/source-contract verification after implementation;
- `git diff --check`;
- all four Rojo projects build to TEMP;
- no unrelated worktree changes.

Manual Studio evidence is required only for behavior we cannot prove outside Roblox runtime, principally the real Base -> Dungeon -> Base profile handoff/persistence path. The user is not needed before that gate.

## Safety

- Work occurs on `wip/phase-3-quest-advancement-v1`.
- Worktree target: `C:\Users\Remko\Documents\Roblox\DungeonMMO_Phase3_QuestAdvancement_v1`.
- Start from `c7d6721b1c30eb52660b620d02f9bcf9e5d180f2`.
- Do not modify the art worktree.
- Do not reset/clean existing worktrees.
- Do not push or publish.
- Do not touch PROD, Robux or monetisation.
- Preserve unrelated primary-repo untracked files.
