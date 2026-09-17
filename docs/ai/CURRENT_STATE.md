# DungeonMMO Current Engineering State

**State date:** 16 September 2026
**Canonical long-form roadmap:** `docs/roadmap/DungeonMMO_Roadmap_v1_38.docx`
**Current phase:** Phase 2 - Vertical Slice
**Phase 2C:** FUNCTIONALLY COMPLETE
**Starting Base + Temple integration:** ACCEPTED
**Profession Foundation:** ACCEPTED
**Second Modular Dungeon + Rare-State/Event Proof:** ACCEPTED
**Party Formation + 1-4-Player Group Entry:** ACCEPTED

## Canonical accepted gameplay boundary

- Phase 1: ACCEPTED / functionally complete.
- Phase 2A: ACCEPTED / functionally complete.
- Phase 2B.A/B/C: ACCEPTED; Phase 2B functionally complete.
- Phase 2C.A through Phase 2C.E: ACCEPTED; Phase 2C functionally complete.
- Starting Base + Temple integration: `c7fe89ebda3c97634c97e89ad12e52ec23983ae9`.
- Profession Foundation gameplay checkpoint: `ce1577990f2795bf208d7b897e645f32a4a39a4f`.
- Second Dungeon / Rare-State / Event gameplay checkpoint: `d361348ec045873eed0fd992ceb04bfee908b06a`.
- Second-dungeon documentation closeout / previous local-main baseline: `304ab0535d4de7e77313b7e0aef8d3b7bd899449`.
- Party Formation / Group Entry gameplay checkpoint: `726299322fb31689e5e321878f287cccfcb07d81`.

The approved local-merge closeout fast-forwards local `main` to a documentation
closeout commit after rebuilding the merged result. The exact post-closeout
local-main SHA is printed in the closeout receipt. `origin/main` is deliberately
left untouched by this option and remains at
`60fc0dfd9954e2d580157a580da2425e2b71dd70` unless a later explicit push changes it.

## Accepted party architecture

Party authority is deliberately Base-local and temporary. `PartyService` owns
same-server party state only; it does not use DataStore, MemoryStore, Profile or
DungeonSession persistence directly.

Accepted party rules:

- 1-4 players;
- creator becomes leader;
- same-Base-server invite / accept flow;
- one party per player;
- leader kick and ordinary member leave;
- deterministic leader transfer to the longest-standing remaining member;
- party dissolves when the final member leaves;
- multi-member parties require every member Ready;
- membership changes clear readiness;
- changing the selected dungeon clears readiness;
- solo entry remains available without a redundant Ready step.

`PartyEntryCoordinator` revalidates the accepted member set immediately before
entry and hands the player array plus dungeon id into the existing
`TeleportCoordinator:start_dungeon(...)` path. Once admission succeeds,
`DungeonSessionService` becomes run membership authority; the Base party is not
a second source of truth inside the dungeon.

Both accepted dungeon definitions are supported:

- Temple / `TestDungeon`;
- Abandoned Mine / `AbandonedMine`.

Existing reconnect, revive/spectating, completion eligibility, rewards and
return-to-Base architecture remain authoritative after dungeon admission.

## Studio multiplayer compatibility

Roblox Local Server synthetic `Player1`, `Player2`, etc. use negative UserIds.
The accepted compatibility fix permits negative lease UserIds only when
`RunService:IsStudio()` is true. Positive UserIds remain mandatory outside
Studio. The existing ProfileLeaseService test now covers Studio negative-id
claim, renew and release.

Because Roblox Studio CoreGui/ChatScript failures could block the manual identity
screen in local-server clients, the Base identity client contains a Studio-only
`PlayerN` harness that submits Human -> Fighter through the existing authoritative
`IdentitySelectionRequest` flow. It does not bypass `IdentityService` and does
not activate for ordinary production users.

## Accepted evidence

The implementation candidate passed its automated RED/GREEN/static/build gates
before Studio acceptance. The project owner then completed the four-player Local
Server gate and reported that every requested check worked.

Multiplayer evidence:

- `[Profile Lease Tests] PASS` after the Studio synthetic-UserId fix;
- Player1 through Player4 reached authoritative identity `Complete` through the
  Studio-only Human/Fighter harness;
- Player 1 created a party and invited Players 2, 3 and 4;
- all four accepted and the UI showed the correct 4/4 membership;
- starting before everyone was Ready was rejected;
- all four could become Ready;
- kicking a member updated clients and cleared stale readiness;
- after rebuilding the party, leader leave transferred leadership to the
  longest-standing remaining member;
- a rebuilt/ready party produced the expected Temple Studio entry proof;
- a rebuilt/ready party produced the expected Abandoned Mine Studio entry proof;
- no new red DungeonMMO runtime errors were reported.

The local Studio proof does not constitute a published reserved-server teleport
test. It validates the new party/entry layer while reusing the already accepted
TeleportCoordinator / DungeonSession group-capable lower layer. A later published
TEST integration/release gate may still recheck real cross-Place group teleport.

Detailed evidence is recorded in
`docs/testing/phase2-party-entry-acceptance-record.md`.

## Existing accepted contracts preserved

The party gate reuses rather than duplicates:

- schema-v6 Profile / Inventory / Equipment / Professions;
- Character identity and Fighter/Mage/Ranger;
- DungeonSessionService 1-4-player membership;
- TeleportCoordinator handoff/nonces;
- reconnect routing;
- revive/spectating;
- completion eligibility and exactly-once rewards;
- save-before-return and Base recovery;
- Temple and Abandoned Mine definitions;
- immutable Mine InstanceState, Crystal Bloom and Deep Echoes;
- profession gathering/crafting and equipment run-lock.

No profile-schema bump was required.

## Qualifications / deferred work

- Published TEST real group teleport remains a later integration/release check.
- Public matchmaking, cross-server party discovery and guild-party breadth are
  not part of this proof.
- Party membership is intentionally not persistent player-profile state.
- Final party UI art/presentation remains polish.
- Final authored Abandoned Mine art remains later environment integration.
- The pre-player live legacy migration waiver remains a qualification.
- No Roblox place was published by this gate.
- No PROD, Robux or monetisation action occurred.

## Exact next engineering action

The selected next Phase 2 gate is **one targetable rare Skill Book acquisition
path**.

Design/spec it before source work. The first proof must let a player deliberately
pursue a specific rare skill-book reward through gameplay rather than relying
only on the generic unidentified skill-book roll or the guaranteed Temple
first-clear Arc Slash book.

The design still needs to lock the target skill, source encounter/dungeon/state,
rarity and eligibility, repeatability, duplicate handling, any smart-loot or pity
behaviour, reward transaction rules and whether persistent targeting progress is
needed. Reuse existing LootTableConfig, RewardService, InventoryService and
skill-book learning authority. Bank/storage, Travel and broader economy/loot
rebalance remain separate later Phase 2 breadth.

<!-- PHASE3_BLUEPRINT_RECIPE_LEARNING_ACCEPTED_20260917 -->
## Phase 3 Blueprint / Recipe-Learning Foundation â€” ACCEPTED

Runtime acceptance was completed on 17 September 2026.

Accepted implementation commit: `c89419e4f54aa098048aab4214fcd73d486d7402`
Local gameplay merge commit: `3162b0fe918fc6d827c67485daddf8ca3232b4dd`

Accepted behavior:
- profile schema v9 persists `CraftingKnowledge.LearnedRecipes`;
- blueprint/recipe learning is authoritative and consumes exactly one owned
  teaching item atomically with learned knowledge;
- duplicate learning is rejected without consuming another item;
- missing profession state rejects with `ProfessionUnavailable`;
- learned recipes remain gated by profession level, station/context and
  ingredient requirements;
- default recipes remain definition-driven;
- Blacksmithing and Alchemy learned-recipe proofs are covered;
- no blueprint drop/vendor/market/reputation wiring was added in this gate.

Fresh Studio acceptance:
- Base: Recipe Knowledge Crafting Gate 12/12 PASS;
- Base: Recipe Knowledge Service 23/23 PASS;
- Base: Quest Advancement Migration 8/8 PASS;
- Base identity flow completed Elf / Ranger;
- Dungeon: Recipe Knowledge Service 23/23 PASS;
- Dungeon: Recipe Knowledge Crafting Gate 12/12 PASS;
- Dungeon: Quest Advancement Migration 8/8 PASS;
- Dungeon full loop reached ready state and admitted the player.

Known non-blocking environment debt:
- four Temple profession resource placements currently log
  `Skipping resource without valid surface` in the synthetic Dungeon
  environment; profession runtime tests and dungeon admission still pass.

No push or publish was part of this closeout.
