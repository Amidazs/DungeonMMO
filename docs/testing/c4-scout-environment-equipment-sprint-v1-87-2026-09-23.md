# C4 Human Rogue / Elven Scout remaining source skills — v1.87

Date: 23 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`

## Actual gameplay implementations

- Human Rogue and Elven Scout source level-20
  `ScoutEquipmentExpertise`, `ScoutLungCapacity`
  and `ScoutFallResistance` have separately
  purchased one-rank progression definitions
  and appear at the existing original Rogue/
  Ranger trainers. Human Rogue alone may buy
  the distinct `HumanScoutSprint` support
  skill at original level 20. The previous
  Elven Scout Wind Run remains independent.
- Equipment Expertise unlocks an **actual**
  tradable crafted `scout_expert_leather_vest`,
  with +12 equipment-resolved maximum HP.
  Equipping is denied before the owner buys
  Expertise even when the vest is already
  owned. The existing equipment service
  validates the skill both in the eligibility
  preview and again in the authoritative
  inventory/profile equip mutation. A real
  Level-2 Leatherworking recipe consumes
  three cured leather, one iron bar and one
  tempering oil to manufacture the vest.
  Trading the gear does **not** grant a second
  crafting profession.
- Lung Capacity increases the actual submerged
  air reserve from 12 to 27 seconds. The
  new Dungeon server service samples the
  real player's **Head** in server-owned
  Terrain water, updates a real oxygen
  attribute, and inflicts 6 Humanoid HP
  drowning damage per second only after
  oxygen expires. Surfacing refills earned
  air; skill revocation removes the extra
  reserve. It does not rely on an icon or a
  client-reported swimming status.
- Fall Resistance reduces only real-world
  landing injury by **40%**. The Dungeon
  server observes Humanoid Freefall and
  Landed transitions, tracks downward
  AssemblyLinearVelocity during the fall
  and applies bounded landing injury with
  `Humanoid:TakeDamage`. It does not
  reduce NPC, PvP, drowning or other
  incoming damage. It does not double
  damage an already resolved landing.
- Sprint is a genuine combat-state-aware
  client-requested self-buff: **20 stamina
  activation cost**, **28-second server
  cooldown**, **+18% Humanoid walking
  speed for 7 seconds**. It uses the
  existing combat movement-scaling path
  which retains zero movement in blocked
  states; the temporary bonus expires
  server-side instead of allowing a
  client-written permanent WalkSpeed.

## Executed focused Studio acceptance

Unpublished Studio test runner:
`scripts/studio/c4_scout_environment_focus.luau`.

**5/5 focused suites passed; 0 failed**, including:
- `C4ScoutEnvironmentEquipmentTest`:
  **106 assertions PASS**. Paid real source
  training on Human Rogue and Elven Ranger;
  level-19 refusal; wrong-class/race loss
  of environmental effects; paid oxygen
  reserve and fall-impact calculations;
  genuine Base equipment equip/unequip
  and +12 authoritative max-HP effect;
  purchased, equipped vs unselected Sprint
  and actual stamina/cooldown definitions.
- `C4ScoutExpertGearTradeTest`:
  **28 assertions PASS**. A separate Elf
  Ranger selected Skinning + Leatherworking,
  manufactured the expert vest through
  real server recipe preparation and
  minigame completion, consuming all
  three authored ingredients. It listed
  the finished gear through actual market
  escrow; an independent Human Rogue
  selecting Mining + Blacksmithing bought
  it. The buyer could **not** craft
  Leatherworking goods or equip the
  purchased vest until it purchased
  Equipment Expertise at its own trainer.
  Equipping the genuinely traded vest
  then increased real resolved maximum HP
  by 12 without granting Leatherworking.
  Disposable source ingredients and
  Leatherworking XP were seeded solely to
  isolate this flow; gathering those
  materials was not re-tested.
- Strict original Human Rogue/Elven Scout
  source inventory audit: **1,183
  assertions PASS**, reconciled to
  **99/99 Human Rogue** and **129/129
  Elven Scout**. The separate starting-
  class inventory remains **168/168**.
  The strict aggregate **396/396** rank
  count suite also passed, explicitly
  reporting **class paths=0/9** and
  **seven other original first-transfer
  class catalogues unmapped**.
- Existing EquipmentService regression
  remained **38 assertions PASS**.
  Original previously accepted aggro/
  wipe/paid-revive tests were not
  pointlessly repeated.

Changed Luau sources parsed with the
local compiler; disposable Base and
Dungeon Rojo compositions built.

## Actual one-client Dungeon Sprint playtest

`scripts/studio/c4_scout_sprint_client_live.luau`
used a real unpublished Studio multiplayer
client admitted to the actual Dungeon
runtime. It purchased real Human Rogue
Sprint, equipped its loadout entry and
activated it through the existing client
`SkillRequest` remote. The real server
deducted stamina, set the timed movement
status, increased actual original-avatar
Humanoid WalkSpeed, started the actual
cooldown, and restored original speed
when the effect expired. The run returned:

`[C4 Rogue Sprint Live] VERIFIED_REAL_CLIENT_SPRINT_PASS`

## Actual one-client Dungeon environmental test

`scripts/studio/c4_scout_environment_world_live.luau`
used an actually admitted original
Dungeon avatar and the original bound
`ScoutEnvironmentService`. In a
**disposable unpublished test place only**,
server Terrain water was created around
the real avatar's head. Its true server
Heartbeat sampled that real voxel water
and reduced oxygen, updated the character
oxygen attribute and inflicted genuine
Humanoid HP drowning damage. Removing
the Terrain water refilled the legitimate
earned 27-second oxygen reserve.

For the fall check, the test passed a
**controlled peak downward speed of
100 studs/s and elapsed freefall state**
into the real server environment
landing handler rather than claiming to
visually drop the avatar off a physical
cliff. The actual original Humanoid
lost 10.8 HP with purchased Fall
Resistance and 18 HP after the actual
source rank was revoked. Re-invoking
a resolved landing did not cause a
second injury. The run returned:

`[C4 Scout Environment Live] VERIFIED_WATER_AND_HP_PASS`

This proves actual live Terrain water,
drowning HP and server landing damage
integration; **a natural freefall-to-landed
physical traversal remains a separate
real-play acceptance check**. The
test-only water, profile grants,
source-level adjustments, skill
revocation and controlled fall speed
were never written to the production
game or persistent DataStore.

## Exact source-rank scope versus full C4

| Inventoried original C4 source | Functional / raw | Missing |
| --- | ---: | ---: |
| Four original starting classes | 168 / 168 | 0 |
| Original Human Rogue rank inventory | 99 / 99 | 0 |
| Original Elven Scout rank inventory | 129 / 129 | 0 |
| **Six inventoried source lists** | **396 / 396** | **0** |

**This is original source-rank enumeration/parity
for six inventoried lists, NOT completion of
the entire original C4 skill/class catalogue.**
The game has two *partial original
first-transfer class analogues*, seven other
original first-transfer classes still entirely
unmapped, and **0/9 original first-transfer
class paths completely finished**. Original
Lineage 2 item catalogue, advancement quests,
complete dual-weapon behavior, final gear
balance and all visual/art acceptance are
not claimed complete. The strict aggregate
catalogue `Completed` flag correctly
remains **false**.

All changes to scripts, tests, maps,
roadmaps and documentation were made
**through GitHub only**. Desktop access
was restricted to clean fast-forward
pulls, read-only state/diagnostics,
disposable local parser/build and
unpublished Roblox Studio execution.
No `main` merge, Roblox publish,
production DataStore write, forced
repository reset or paid operation
was performed.

**v1.87 source-rank mapping 396/396
PASS; gameplay tests PASS; complete
original first-transfer C4 catalogue
remains INCOMPLETE.**
