# DungeonMMO roadmap v1.87 — tested C4 Scout source-rank parity

Date: 23 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`

## Which roadmap is authoritative

This is the newest **C4 backend / original
skill-source catalogue** supplement, after
[v1.86 tested Lockpicking](
DungeonMMO_Roadmap_v1_86_C4_Scout_Lockpicking_20260923.md).
The separate newer humanoid/quadruped
rig, animation and Blender/Studio art
roadmap remains authoritative for
characters, models, animation pipelines
and visual approvals. Do not publish,
merge to `main` or edit local scripts
without a new explicit user request.
Keep WoW-style **exactly one selected
gathering plus one selected crafting
profession** per character; require
other-profession trade/market dependency.

## Completed and verified in v1.87

- [x] Human Rogue and Elven Scout source
  level-20 `EquipmentExpertise`,
  `LungCapacity` and `FallResistance`
  now have distinct real, purchased
  progression skills through existing
  class trainers and source-level gates.
  Human Rogue's original level-20
  `Sprint` is now a distinct real
  bought/equipped active support skill,
  **not** the existing Elf Wind Run
  or the level-28 Fleet Foot passive.
- [x] An expert Scout leather vest has
  actual +12 maximum HP, genuine
  level-20 expertise equip restrictions
  in preview and inside the equipment
  mutation, and a real Leatherworking
  Level-2 recipe consuming three
  cured leather, one iron bar and
  one tempering oil. A different
  profession character can purchase
  the finished vest through the
  existing market, but may not
  craft the vest without choosing
  Leatherworking. Equipping requires
  its **own** earned source rank.
- [x] The live Dungeon server owns
  water breathing using actual
  server-sampled Terrain at the
  avatar's Head; baseline 12 seconds
  air, +15 from purchased Lung
  Capacity, real zero-oxygen
  Humanoid drowning damage and
  refill on surfacing. The current
  physically dry layouts simply
  have no natural diving content
  yet; gameplay works with actual
  Terrain water when present.
- [x] The live Dungeon server tracks
  real Humanoid Freefall/Landed
  states and peak downward
  AssemblyLinearVelocity; injurious
  landing calculations call real
  `Humanoid:TakeDamage`. The
  original purchased Fall Resistance
  reduces *only that fall injury*
  by 40%, not NPC attacks,
  magic, drowning or PvP.
- [x] Human Rogue Sprint uses
  existing real client SkillRequest,
  20 server-spent stamina,
  28-second cooldown, +18%
  server-scaled Humanoid WalkSpeed
  for seven seconds, then expiry.
  Combat's normal movement scale
  continues to enforce casting,
  dead/dodging and root locks;
  Sprint never directly trusts
  client-written WalkSpeed.
- [x] The v1.87 focused original
  Studio suite passed **5/5**,
  including **106** new progression/
  gear/air/fall/Sprint assertions,
  **28** genuine two-profile
  crafted-and-auctioned expert
  vest assertions, **1,183**
  strict Rogue/Elven Scout
  source-rank assertions and
  **38** original equipment
  regression assertions.
- [x] Actual **one-client
  unpublished Dungeon Sprint
  playtest PASS**: real skill
  purchase, real client cast,
  server stamina, cooldown,
  actual WalkSpeed and expiry.
- [x] Actual **one-client
  unpublished Dungeon world
  environment test PASS**:
  server Terrain water covered
  a real avatar's head;
  server Heartbeat decreased
  real oxygen, drowning reduced
  actual Humanoid HP, and
  surfacing recovered the
  earned 27-second reserve.
  Actual HP also changed
  with/without purchased fall
  mitigation on an injected
  **controlled server landing
  speed**, not a claim to have
  visually completed a naturally
  falling cliff/platform test.
  See [executed v1.87 evidence](
../testing/c4-scout-environment-equipment-sprint-v1-87-2026-09-23.md).
- [x] Luau parse and disposable
  Base/Dungeon Rojo builds
  passed. Source edits,
  test scripts and documents
  committed through GitHub;
  local desktop used only
  for read-only state, clean
  pull and local unpublished
  builds/Studio verification.

## Accurate original C4 source-rank accounting

| Original inventory | Functional / raw | Missing |
| --- | ---: | ---: |
| Human Fighter | 39 / 39 | 0 |
| Elven Fighter | 43 / 43 | 0 |
| Human Mystic | 44 / 44 | 0 |
| Elven Mystic | 42 / 42 | 0 |
| Human Rogue source inventory | 99 / 99 | 0 |
| Elven Scout source inventory | 129 / 129 | 0 |
| **Six currently inventoried source lists** | **396 / 396** | **0** |

**396/396 refers only to the six enumerated
original C4 rank lists. It does NOT mean
DungeonMMO has finished all original
first-transfer class skill trees.**
The two implemented first-transfer
analogues are still classified
**Partial** by the full class-path
audit; the seven **other**
original first-transfer classes
remain wholly unmapped.
The authoritative aggregate
`C4CatalogueCoverage.report().Completed`
remains **false**, with
**0/9 original first-transfer
paths fully complete**. Original
skills beyond these six audited
lists, class-advancement quests,
item breadth, original dual-weapon
mechanics and actual finished
content are not covered by
this numeric rank parity.

## Next backend work — no false completion

- [ ] Source-enumerate each of the
  **seven remaining distinct C4
  first-transfer classes** and
  implement original class-specific
  skill ranks, unlock levels,
  real weapon-appropriate effects,
  prerequisite skill proficiency,
  trainer, class advancement
  quests and authentic server
  execution. The source rank
  catalogue is NOT finished
  until these seven inventories
  and full original nine
  class-path acceptance are
  implemented and independently
  verified.
- [ ] Validate a **natural**
  Freefall-to-Landed physical
  drop test from an actual
  walkable Dungeon platform.
  The v1.87 controlled landing
  test verifies true Humanoid
  damage integration and
  purchased resistance but
  does not prove every
  physics/network-ownership
  edge case in a production
  obstacle course.
- [ ] Add authored diving water
  encounters and final HUD
  oxygen presentation only
  when creating actual water
  dungeon content. The
  server-side oxygen mechanic
  and live Terrain test already
  work without a finished art
  model; do not claim a
  current dry dungeon contains
  a swimming encounter.
- [ ] Preserve the separate
  v1.78 Mystic enemy-weakening
  client/NPC acceptance and
  documented proficiency
  regression. Do not rerun
  accepted aggro/wipe/revive
  suites unless relevant code
  changes.
- [ ] Economy/art/content
  pass: review advanced
  armor drop/crafting balance,
  visual chest assets, natural
  fall obstacle design and
  actual market supply.
  These do not override the
  one-Gathering/one-Crafting
  restriction or justify
  unearned cross-profession
  recipes.

**v1.87: inventoried original C4
source ranks 396/396 and focused/
live environmental, trading and
Sprint integration PASS. Entire
original nine-path C4 catalogue:
INCOMPLETE.**
