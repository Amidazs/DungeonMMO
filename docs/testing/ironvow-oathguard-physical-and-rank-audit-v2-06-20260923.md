# DungeonMMO v2.06 — Warrior/Knight physical acceptance and launch-rank gaps

Date: 23 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Continues [v2.05 Ironroot personal quest and class backend](
ironvow-quest-world-class-v2-05-20260923.md).
This is an unpublished Studio/isolated-profile acceptance record.
Permanent scripts and docs changed **only in GitHub**; the local
desktop was used to fast-forward pull, build temporary Rojo places
and run/read unpublished Studio tests. No Roblox publication,
production DataStore mutation, local source edits or `main` merge.

## Corrected real first-transfer trainer security

The Base runtime previously applied the physical ten-stud trainer
proximity gate only to the two existing Scout career IDs. A new
original first-transfer trainer could therefore reach the normal
training controller without its independent nearby-station check.
The server now discovers **every registered original transfer
trainer** through the authoritative career registry and applies
the identical server proximity requirement to trainer snapshots,
first skill purchases and rank purchases. The class, race, proof,
owned skill, SP and proficiency gates remain separate and required.

An unpublished two-client Ironvow run exposed that temporary hub
geometry occluded the trainer's visible Roblox prompt even when the
character was four studs away. The physical trainer's
`RequiresLineOfSight` is now disabled, while the server's
authenticated alive-character and ten-stud range check remains.
The corrected build passed the real trainer test.

## Executed Ironvow physical Base and server skill acceptance

Dedicated `scripts/studio/c4_ironvow_base_live.luau` uses two
genuine unpublished Base clients. Final **PASS**, with these
actual client-held `ProximityPrompt` and production remote
observations:

- `REAL_IRONROOT_TWO_NPCS_PASS`: the Human Fighter chose the
  independent Warrior source and held physical Marshal Torren
  and Smith Orla prompts, reaching ordered combat stage three.
- `REAL_FOUR_MARKER_TURNIN_PASS`: four earlier source monster
  marker drops were prepared **only in the disposable Base
  fixture**; a genuine client prompt handed in and consumed
  all four owner-bound items.
- `REAL_BOSS_SEAL_TURNIN_PASS`: a previously earned unique
  boss seal was separately prepared only in the test profile;
  its genuine physical final NPC prompt consumed the item
  and completed the source quest without prematurely
  awarding a class.
- `REAL_CLIENT_IRONVOW_TRAINER_PASS` and
  `VERIFIED_WARRIOR_BASE_PASS`: the real physical mentor
  denied a level-18 advancement, awarded the personally
  completed quest's correct class at level 20, refused the
  unrelated Elf mentor and replay, and the owner's physical
  trainer displayed its actual catalogue. Real client
  learning requests were denied at fifty studs and for
  an unadvanced Elf at the nearby station, but allowed
  the genuine Human owner to buy the first Blade Training
  rank. Earlier Ironvow Driving Strike was bought through
  the real server skill service by the shared driver.

The isolated `c4_ironvow_quest_focus.luau` subsequently **PASS**:
31 source quest assertions, **79** authenticated class/rank/
armour/HP/recovery/save assertions and **58** first-skill and
forged-class guard assertions. New earned Warrior passives:
`IronvowFortitude` ranks at levels 20 and 28 add
**16 maximum HP total** through the real server MaxHealth
calculation; `IronvowRestRecovery` at level 24 improves
the server stamina recovery multiplier **only when seated**.
Both are actual SP-bought ranks with required purchased
starter skills and are reloaded from saved character state.
A forged Fighter class ID gains neither advanced passive.

The scoped original quest, starter/class/skill migration
runner separately **PASS 5/5**, including 170 original
quest-stage assertions, after updating a stale assertion
to require the current correct first-transfer receipt
denial rather than the former generic wrong-class reason.

## Executed Oathguard physical Base / Dungeon acceptance

The pre-existing independent Human Knight/Oathguard quest and
three-family skill foundation were inspected rather than
re-created. Its unpublished physical test contained two
stale copied identifiers: a four-token proof when this quest
requires **three Stonewatch badges**, and an unregistered
Driving Strike skill ID instead of the real
`OathguardShieldImpact`. The test was corrected in GitHub.
Its first initial actual physical NPC test then failed:
the Captain Rowan placeholder was within another career's
mentor prompt range. Knight quest NPCs and its distinct
mentor were separated from the existing Ironvow stations
inside the **temporary test hub**, and the test client's
detached camera override was removed. The rerun **PASS**.

- Focused isolated Knight source/award/skill tests:
  **29 + 38 assertions PASS**.
- Genuine two-client physical Base test
  `c4_oathguard_base_physical_live.luau`: **PASS**,
  including `REAL_NPC_START_PASS`,
  `REAL_OWNER_ITEM_TURNINS_PASS`,
  `REAL_MENTOR_CLASS_PASS`,
  `REAL_CLIENT_TRAINER_PURCHASE_PASS` and
  `VERIFIED_LIVE_BASE_PASS`. The client held the
  separate actual Captain Rowan/Quartermaster Dena
  quest prompts, consumed owner-bound earlier earned
  badge and boss-seal fixtures in real physical
  turn-ins, received the authenticated level-20
  Oathguard award and bought its first genuine
  shield skill using the production client remote.
- Dedicated physical Dungeon world/ledger fixture
  **11 assertions PASS**.
- The existing real two-client instanced Dungeon
  `c4_oathguard_dungeon_two_client_live.luau`
  contained the same stale four-token test proof and
  was corrected. Complete unpublished real-client
  run **PASS** (`VERIFIED_TWO_CLIENT_WORLD_PROOFS_PASS`):
  both clients actually damaged their respective
  physical Gloam Striker or Bulwark, then the
  authoritative server test driver provided the
  finishing hits. Genuine quest combat callbacks
  granted the right player's personal badge/seal,
  not cross-owner loot. This does **not** prove
  every death was fully client-controlled or the
  entire quest was played uninterrupted across places.

## Precise level-30 source-rank audit

`c4_level30_launch_coverage_focus.luau` on the updated Base
build: **PASS, 27 assertions**. The machine-audited reference
inventory in this repository now reports:

| First transfer | Recorded source rank entries at 20/24/28 | Class/trainer rank schedule mapped | Still unmapped |
|---|---:|---:|---:|
| Human Rogue → Ashenblade | 59 | 59 | 0 |
| Elf Scout → Greenward Scout | 77 | 77 | 0 |
| Human Warrior → Ironvow | 62 | 27 | 35 |
| Human Knight → Oathguard | 54 | 24 | 30 |

An entry is a distinct historical **rank purchase at a bracket**,
not a distinct skill icon. The new Ironvow map now includes actual
purchased armour, sword impact, battle call, fortitude and seated
recovery training rows. Knight maps only authentic shield impact,
heavy armour and taunt ranks. Neither class is complete;
unimplemented blunt, polearm, magic resistance, life drain and
other source families are not assigned to unrelated executors.
The historical ranks here are the **repository's reference
inventory**, not an independent verification that every original
source-game rank/mechanic or starter level-1–19 catalogue is present.

The two Scouts' complete recorded schedule mapping is similarly
not a claim that each distinct passive/utility effect has passed
real-client use. The release-cap level remains **planned 30**,
not server enforced; complete mechanically verified,
uninterrupted level-1–30 careers remain **0/18**.
