# DungeonMMO Development Handoff

**Date:** 16 September 2026
**Active workstream:** Phase 2 - Vertical Slice
**Phase 2C:** FUNCTIONALLY COMPLETE
**Starting Base + Temple integration:** ACCEPTED
**Profession Foundation:** ACCEPTED / MERGED / PUSHED
**Canonical roadmap:** DungeonMMO Roadmap v1.35

## Accepted gameplay boundary

- Phase 1, Phase 2A and all Phase 2B gates are accepted.
- Phase 2C.A through Phase 2C.E are accepted; Fighter, Mage and Ranger remain
  the accepted starting-archetype foundation.
- Starting Base + Temple integration is accepted at
  `c7fe89ebda3c97634c97e89ad12e52ec23983ae9`.
- Profession Foundation gameplay checkpoint is `ce1577990f2795bf208d7b897e645f32a4a39a4f`.

## Profession Foundation contracts

The accepted starting profession set is Mining, Blacksmithing, Herbalism and
Alchemy. Mining -> Blacksmithing and Herbalism -> Alchemy are complete playable
supply chains.

Schema v6 persists `{Level, XP}` for all four professions. The foundation level
cap is 5 with cumulative thresholds 30 / 60 / 100 / 150 XP. Profession XP is
separate from character XP.

Blacksmithing supports Iron Bars, Ironbound Gloves and Tempered Ironbound
Gloves. Alchemy supports Tempering Oil from Silverleaf. Tempering Oil is the
first accepted cross-profession input. Tempered Ironbound Gloves require
Blacksmithing Level 2.

Crafting uses server-authoritative prepare/complete boundaries. A future
minigame may determine a result, but it cannot directly mutate Inventory or
award items. The current foundation auto-success remains server-owned.

Inventory presentation consumes authoritative snapshots. Equipment remains a
separate Base service, and Dungeon Equipment remains read-only/run-locked.

## Personal Temple resource contracts

Each Dungeon gathering node is single-use per player per run. Resource claims
live on the Dungeon member session record so reconnect reconstructs depleted
nodes. Duplicate claims fail. If profile mutation fails after a provisional
claim, the claim is released.

One player's claim never globally depletes another player's node.

Every Temple resource placement must:

- raycast a real floor, wall or rock surface;
- be partially embedded into that surface;
- remain non-colliding and non-queryable;
- avoid invalid/floating placement by skipping unresolved candidates;
- belong to its room placement group;
- remain at least 18 studs from already resolved resources in that group.

Room 1 and Room 2 each have multiple nodes with probes deliberately spread
across distinct room sides/quadrants.

## Final acceptance evidence

The project owner previously accepted the functional profession/gathering loop.
The final distribution closeout additionally requires and records:

- `[Profession Resource Distribution Tests] PASS` in Studio;
- visually distributed Room 1 nodes;
- visually distributed Room 2 nodes;
- no new red runtime error during that test.

The project owner accepted the gate while noting that the resource nodes could be distributed much farther across the authored Temple rooms. Record this as deferred visual/environment polish only; do not reopen personal depletion, reconnect claims, valid-surface embedding, combat-path safety or the accepted 18-stud minimum spacing contract.

The closeout script requires v4 source verification, clean diff checks and all
four Rojo builds before it can offer the Studio gate. It performs no commit or
push if the user reports FAIL.

## Safety / worktrees

Primary repository:
`C:\Users\Remko\Documents\Roblox\DungeonMMO`

Profession worktree:
`C:\Users\Remko\Documents\Roblox\DungeonMMO_ProfessionFoundation_v1`

Profession branch:
`wip/phase-2-profession-foundation-v1`

The separate art worktree/branch remains isolated. Do not reset, clean,
force-checkout, force-push or history-rewrite any preserved worktree.

No Roblox place was published by this closeout. No PROD / Robux /
monetisation action is authorized.

## Exact next action

Read Roadmap v1.35 and `docs/ai/CURRENT_STATE.md`, then select the next remaining
Phase 2 gate. Prioritise the second modular dungeon / rare-state + time-limited
event proof unless a demonstrated regression in the accepted loop requires a
repair first.

Do not reopen accepted Base/Temple integration, profession architecture,
Fighter/Mage/Ranger, Equipment, persistence, progression, revive or completion
contracts without evidence of a real defect. Secondary-class advancement
remains Phase 3.
