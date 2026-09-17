# DungeonMMO Development Handoff

**Date:** 16 September 2026
**Active workstream:** Phase 2 - Vertical Slice
**Canonical roadmap:** DungeonMMO Roadmap v1.38
**Party Formation + 1-4-Player Group Entry:** ACCEPTED

## Accepted gameplay checkpoints

- Starting Base + Temple integration:
  `c7fe89ebda3c97634c97e89ad12e52ec23983ae9`
- Profession Foundation:
  `ce1577990f2795bf208d7b897e645f32a4a39a4f`
- Second Dungeon / Rare-State / Event:
  `d361348ec045873eed0fd992ceb04bfee908b06a`
- Previous local-main docs closeout:
  `304ab0535d4de7e77313b7e0aef8d3b7bd899449`
- Party Formation / Group Entry:
  `726299322fb31689e5e321878f287cccfcb07d81`

The approved local-merge closeout fast-forwards local `main` to the party
documentation closeout commit after merged-result verification. It deliberately
does not push `origin/main`.

## Accepted party contract

`PartyService` is temporary Base-server authority. It supports 1-4 members,
creator leadership, invite/accept, leader kick, member leave, deterministic
leader transfer, dissolution on empty, readiness and selected-dungeon state.

Multi-member entry requires all members Ready. Membership changes and dungeon
selection changes invalidate readiness. Solo entry remains available without a
Ready requirement.

`PartyEntryCoordinator` validates the final member set and passes it into the
existing `TeleportCoordinator` / `DungeonSessionService` architecture. Once a
run is admitted, DungeonSession membership is authoritative and temporary party
state does not become persistent run/profile state.

Temple and Abandoned Mine are both supported.

## Studio acceptance

The project owner completed the required four-player Studio Local Server gate and
reported every requested check worked:

- Profile Lease regression PASS;
- Player1-Player4 identity auto-harness reached authoritative Complete;
- create + invite/accept to 4/4;
- not-ready start rejection;
- all-member Ready flow;
- kick updates and readiness reset;
- leader leave -> longest-standing member leadership transfer;
- Temple party entry Studio proof;
- Abandoned Mine party entry Studio proof;
- no new red DungeonMMO runtime errors.

Roblox CoreGui/ChatScript CreatorType errors encountered during the gate were
Studio CoreScript failures, not DungeonMMO runtime errors. The test-only identity
harness and negative synthetic-UserId lease allowance remain Studio-gated.

## Qualification

The Studio party-entry proof does not itself perform a published reserved-server
cross-Place teleport. The accepted lower-layer TeleportCoordinator /
DungeonSession contracts already support player arrays; real published group
teleport can be rechecked in a later published TEST/release gate.

## Safety

- Primary repo: `C:\Users\Remko\Documents\Roblox\DungeonMMO`
- Party feature worktree:
  `C:\Users\Remko\Documents\Roblox\DungeonMMO_PartyEntry_v1`
- Feature branch:
  `wip/phase-2-party-entry-v1`
- Environment: TEST
- No Roblox publish occurred.
- Live paid revives remain disabled.
- No PROD / Robux / monetisation action is authorized.
- `art/dungeon-environment-prototype` remains isolated.

## Exact next action

Design the **targetable rare Skill Book acquisition proof** before source work.

Reuse current server-authoritative loot/reward/inventory/skill-learning systems.
Keep the first proof narrow: one deliberate target path for one specific rare
book. Do not turn it into a broad loot-table, market or economy rewrite.

Bank/storage, Travel, public matchmaking, guild-party breadth and final UI/art
polish remain later scope.

<!-- PHASE3_BLUEPRINT_RECIPE_LEARNING_ACCEPTED_20260917 -->
## Accepted Phase 3 recipe-learning checkpoint

The Blueprint / Recipe-Learning Foundation is runtime accepted as of
17 September 2026.

Feature commit: `c89419e4f54aa098048aab4214fcd73d486d7402`
Local gameplay merge: `3162b0fe918fc6d827c67485daddf8ca3232b4dd`

The accepted public learning boundary remains
`RecipeKnowledgeService:learn_from_item(user_id, item_id)`. Do not re-add
a character-table guard to the numeric `user_id` argument.

The missing-profession regression is intentionally modeled through a focused
test-only profile proxy because `ProfileService:mutate` sanitizes successful
mutations and restores default profession structure.

Fresh Base and Dungeon Studio runs passed Recipe Knowledge Service, Recipe
Knowledge Crafting Gate, Quest Advancement Migration, and the normal
identity/admission runtime paths.

The four synthetic Temple profession-resource `invalid surface` skips are
tracked as environment/polish debt, not a recipe-learning blocker.

Local-only closeout: nothing was pushed or published.
