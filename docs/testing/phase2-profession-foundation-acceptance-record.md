# Phase 2 Profession Foundation Acceptance Record

**Acceptance date:** 16 September 2026
**Status:** ACCEPTED / MERGED / PUSHED
**Integration parent:** `c7fe89ebda3c97634c97e89ad12e52ec23983ae9`
**Accepted gameplay checkpoint:** `ce1577990f2795bf208d7b897e645f32a4a39a4f`
**Roadmap:** DungeonMMO Roadmap v1.35

## Accepted scope

The accepted Phase 2 Profession Foundation proves two complete starting supply
chains: Mining -> Blacksmithing and Herbalism -> Alchemy. It adds schema-v6
profession persistence, server-authoritative crafting, profession/inventory UI,
crafted equipment, a cross-profession Tempering Oil dependency and personal
reconnect-safe gathering in the authored Temple.

## Locked profession behaviour

- Mining, Blacksmithing, Herbalism and Alchemy persist Level and cumulative XP.
- Foundation level cap is 5; cumulative thresholds are 30, 60, 100 and 150 XP.
- Base gathers award 8 profession XP; Temple gathers award 12.
- Iron Bar awards 10 Blacksmithing XP.
- Ironbound Gloves award 20 Blacksmithing XP.
- Tempering Oil awards 20 Alchemy XP.
- Tempered Ironbound Gloves award 30 Blacksmithing XP and require
  Blacksmithing Level 2.
- Tempering Oil is distilled from 3 Silverleaf and proves the first accepted
  cross-profession recipe dependency.
- Craft preparation does not mutate ownership; atomic completion remains
  server-authoritative.

## Locked resource behaviour

- Dungeon resource depletion is personal, not global.
- Each node is single-use per player per run.
- Claims persist on the Dungeon member session and reconstruct on reconnect.
- Duplicate claims fail and failed profile mutation releases a provisional
  claim.
- Room 1 and Room 2 each expose multiple gatherable nodes.
- Nodes only spawn after valid real-surface raycasts and remain partially
  embedded in floor/wall/rock geometry.
- Invalid nodes are skipped rather than floated into the room.
- Resource visuals are non-colliding/non-queryable.
- Each Temple room uses a placement group; resolved nodes in the same group must
  remain at least 18 studs apart.
- Primary/fallback probes are spread across distinct room sides/quadrants.

## Final closeout evidence

Before the user-visible gate, the closeout runner recorded:

- v4 source contract PASS;
- `git diff --check` PASS;
- all four Rojo compositions built successfully.

Project-owner Studio evidence then confirmed:

- `[Profession Resource Distribution Tests] PASS`;
- Room 1 resource placement is room-wide rather than clustered;
- Room 2 resource placement is room-wide rather than clustered;
- no new red runtime error was observed during the final distribution check.

The project owner accepted this gate while noting that the authored Temple nodes could be spread substantially farther apart. Wider room-scale distribution is explicitly deferred as non-blocking environment/presentation polish; it does not reopen the accepted 18-stud minimum-spacing, valid-surface, personal-depletion or reconnect-safe gathering contracts.

All other profession/gathering behaviour had already been accepted before this
final spacing refinement.

## Safety and qualifications

No Roblox publish, PROD, Robux or monetisation action was part of the closeout.
The art worktree remained isolated.

The live legacy migration proof remains waived only for the pre-player TEST
state. This is not a live migration PASS; schema v6 requires explicit live
migration evidence before a release with real existing player profiles.
