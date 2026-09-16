# DungeonMMO Current Engineering State

**State date:** 16 September 2026
**Canonical long-form roadmap:** `docs/roadmap/DungeonMMO_Roadmap_v1_35.docx`
**Current phase:** Phase 2 - Vertical Slice
**Phase 2C status:** FUNCTIONALLY COMPLETE
**Starting Base + Temple integration:** ACCEPTED
**Profession Foundation:** ACCEPTED / MERGED / PUSHED

## Canonical accepted baseline

- Phase 1: ACCEPTED / functionally complete.
- Phase 2A: ACCEPTED / functionally complete.
- Phase 2B.A/B/C: ACCEPTED; Phase 2B functionally complete.
- Phase 2C.A through Phase 2C.E: ACCEPTED; Phase 2C functionally complete.
- Starting Base + Temple integration checkpoint:
  `c7fe89ebda3c97634c97e89ad12e52ec23983ae9`.
- Phase 2 Profession Foundation gameplay checkpoint:
  `ce1577990f2795bf208d7b897e645f32a4a39a4f`.

The documentation closeout commit containing this state file becomes the
canonical `main`. No Roblox place was published by this closeout.

## Accepted environment integration boundary

The authored Starting Base and Temple are integrated through semantic
environment anchors rather than hard-coded mesh hierarchy or scattered world
coordinates. The accepted loop preserves Base -> Temple -> Base admission,
checkpoints, Captain completion, rewards, save-before-return and reconnect /
recovery contracts.

Environment art remains replaceable. Gameplay must continue to resolve stable
semantic anchors and must not depend on current GLB/RBXL object names or exact
geometry.

## Accepted Profession Foundation

The first complete profession supply chains are:

- Mining -> Blacksmithing;
- Herbalism -> Alchemy.

Persistent schema v6 adds profession state for Mining, Blacksmithing,
Herbalism and Alchemy. Each profession stores Level and cumulative XP. The
foundation cap is Level 5, with cumulative level thresholds 30, 60, 100 and
150 XP.

Foundation profession XP awards are profession XP only, not character XP:

- Base gathering: 8 profession XP;
- Temple gathering: 12 profession XP;
- Iron Bar: 10 Blacksmithing XP;
- Ironbound Gloves: 20 Blacksmithing XP;
- Tempering Oil: 20 Alchemy XP;
- Tempered Ironbound Gloves: 30 Blacksmithing XP.

Blacksmithing smelts Iron Bars and forges Ironbound Gloves. Alchemy distils
Tempering Oil from Silverleaf. Tempered Ironbound Gloves require Blacksmithing
Level 2 and combine Ironbound Gloves, Iron Bar and Tempering Oil. This proves a
cross-profession dependency while keeping basic Blacksmithing independently
usable.

Crafting remains server-authoritative. The accepted boundary separates
non-mutating preparation from atomic completion. The current foundation uses a
server-owned auto-success result; future crafting minigames may provide an
outcome but may not grant items directly.

The shared Inventory panel is authoritative ownership presentation driven by
InventorySnapshot. Equipment remains a separate Base service, and Dungeon
Equipment remains read-only/run-locked.

## Accepted Temple gathering rules

Dungeon resource nodes are personal and single-use per player per run. One
player gathering a resource does not remove it for another player. Claims are
stored on the Dungeon member session record, restored on reconnect and rejected
when duplicated. A provisional claim rolls back if the authoritative profile
mutation fails.

Temple nodes must resolve against real floor, wall or rock geometry and remain
partially embedded. Invalid placement is skipped. Resource visuals are
non-colliding and non-queryable so they do not obstruct combat/navigation or
interfere with later resource raycasts.

Room 1 and Room 2 each contain multiple resources. Each room uses a placement
group and successfully resolved resource positions in that group must be at
least 18 studs apart. Primary/fallback probes are deliberately spread across
room sides/quadrants. Surface validity and room-wide spacing are both required.

## Acceptance evidence

Project-owner evidence accepted all Profession Foundation behaviour before the
final distribution refinement, including profession UI, Inventory tabs,
Mining/Blacksmithing, Herbalism/Alchemy, cross-profession crafting, profession
XP, multiple personal Temple nodes, per-player depletion and reconnect-safe
claims.

The final closeout Studio gate additionally confirmed:

- `[Profession Resource Distribution Tests] PASS`;
- Room 1 resources are visibly distributed around the room rather than
  clustered at one anchor;
- Room 2 resources are visibly distributed around the room rather than
  clustered at one anchor;
- no new red runtime error was reported during the distribution check.

The current Temple distribution is accepted. The project owner noted that nodes could be spread much farther across each room; treat that as deferred presentation/environment polish rather than a Profession Foundation blocker. The accepted functional floor remains the 18-stud same-group spacing contract plus valid embedded surfaces and combat-path safety.

Before that Studio gate, the closeout script also requires the v4 static source
contract, `git diff --check`, and fresh Rojo builds of all four compositions.

Detailed evidence is recorded in
`docs/testing/phase2-profession-foundation-acceptance-record.md`.

## Qualifications that remain visible

The pre-player live legacy migration waiver remains a qualification, not a
migration PASS. Schema v6 must receive a real live migration proof before any
release that must safely migrate real existing player profiles.

Historical Phase 2C.C / Phase 2C.D evidence qualifications remain historical
notes and are not rewritten by this closeout.

Final animation, VFX, audio, environment polish, broader Temple resource spread, broad economy/trading and additional profession families remain later scope.

## Environment and safety

- Primary repo: `C:\Users\Remko\Documents\Roblox\DungeonMMO`.
- Profession worktree:
  `C:\Users\Remko\Documents\Roblox\DungeonMMO_ProfessionFoundation_v1`.
- Profession branch: `wip/phase-2-profession-foundation-v1`.
- `base.project.json` = Starting Base.
- `default.project.json` = Temple/Test Dungeon composition.
- Environment: TEST.
- Live paid revives: disabled.
- No PROD / Robux / monetisation action is authorized by this closeout.
- `art/dungeon-environment-prototype` remains isolated and must not be mixed
  into gameplay work.

## Exact next engineering action

Do not infer a new gate number automatically. Select the next remaining Phase 2
vertical-slice gate from Roadmap v1.35 before source work. The strongest
remaining breadth is the second modular dungeon / rare-state proof plus its
time-limited event interaction.

Preserve semantic environment anchors, schema-v6 profession state, personal
resource claims, crafting authority, Fighter/Mage/Ranger behaviour, Equipment
run-lock, progression/loadout/proficiency, revive/completion and TEST/PROD
contracts. Secondary-class advancement remains Phase 3 scope.
