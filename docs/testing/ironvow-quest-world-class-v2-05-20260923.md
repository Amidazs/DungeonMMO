# DungeonMMO v2.05 — Ironroot quest and Ironvow class integration

Date: 23 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Previous accepted backend baseline:
[v2.04 expanded combat and Warrior foundation](
original-first-transfer-expanded-combat-and-ironvow-v2-04-20260923.md).

## Implemented in the real backend

- Original independent six-stage Human Fighter → **Ironvow** source
  quest, starting at level 18: physical Marshal Torren → Smith Orla,
  four individually defeated **Ridge Marauder** lives, return four
  owner-bound Ironroot Dispatch Markers to Orla, defeat one unique
  **Ridgebreaker**, then present its owner-bound Oath Seal to Torren.
  Saved quest proof, separate enemy-life receipt, stage/order,
  race/branch, personal inventory and repeat-action checks use the
  original common server-owned first-transfer services.
- Independent Base placeholder physical NPCs have server-side
  proximity, live-owner verification and one-use talk receipts.
  Instanced Dungeon first-room encounters now optionally spawn
  Warrior raiders at source step three or one unique boss at step
  five. Registered physical monster lives, actual server combat
  contributions and verified lethal hits grant personal quest items
  through one exclusive profile mutation. An unearned or unrelated
  party member receives no source drop.
- An actual physically separate **Marshal Torren** advancement
  prompt awards the newly registered original class ID
  `Ironvow` only for the owner's exact ready quest, personally
  earned proof, level >= 20, correct race/Fighter base, one-use
  world-created mentor receipt and no prior transfer. The separate
  **IronvowTrainer** offers only its three implemented sword,
  mastery and buff lines. Old legacy specialists and other
  original first transfers remain separate.
- Fixed a previously undefined encounter challenge variable,
  preventing it from determining the proper single-monster
  final-challenge count. Scoped the Elf Scout rescue actor to its
  own branch, so it cannot intercept the Warrior's stage-five
  registered boss availability. Earlier Cinder final encounter
  regression expectations were updated to one actual boss life.

## Actual executed and bounded acceptance

- Local unpublished Base and Dungeon Rojo builds: **PASS**.
- Dedicated isolated real ProfileService Ironroot source quest test:
  **31 assertions PASS**; verified ordered stages, four separate
  marker receipts, an unsupported fake proof refusal, actual
  item turn-ins, unique boss seal and saving/reloading the exact
  completed quest without regenerating spent items. Its world
  verifier is a **server test fixture**, not a live client.
- Separate one-use class award, real skill purchase and fresh
  writer reload: **17 assertions PASS**. The test separately
  prepared a completed quest, then rejected an early level-18
  award and a forged mentor event before accepting only its own
  server-side receipt at level 20. The owner purchased the first
  real Ironvow sword rank after the starter prerequisite and
  saved/reloaded the exact earned class and rank.
- Ironvow three-family rank and forged-class/passive safeguard
  test: **34 assertions PASS**.
- Physical Dungeon monster-spawn/ledger isolation fixture:
  **11 assertions PASS**, including distinct stage-three raiders,
  exactly one stage-five boss and no repeatable spawns after combat.
- Unpublished genuine **two-client instanced Dungeon** playtest:
  **PASS**, markers
  `REAL_RAIDER_CLIENT_HIT_OWNER_MARKER_PASS`,
  `REAL_BOSS_CLIENT_HIT_OWNER_SEAL_PASS` and
  `VERIFIED_TWO_CLIENT_WORLD_PROOFS_PASS`. Two real clients were
  prepared at separate test-only owned stages three and five,
  respectively. Each actually submitted a normal player attack
  and reduced the health of its own physically spawned enemy;
  the server-side test driver delivered the finishing blow using
  the existing authoritative DamageService to keep runtime
  short. The actual lethal combat callbacks granted the
  corresponding own-only personal quest item and advanced
  the boss owner's step. **The finishing blows were not
  client-controlled**; neither entire source sequence was
  completed naturally in this one session.
- Existing Ashenblade/Greenward profile, class and skill focused
  compatibility: **2/2 PASS**, 459 existing first-transfer
  assertions + 8 adjacent migration assertions.
- Level-30 coverage audit after Ironvow class registration:
  **25 assertions PASS**. Warrior is an implemented **partial**
  career with recorded source-rank gaps, not a third complete
  historical class catalogue.

## Boundaries before calling the third class fully playable

The separate genuine client-held *Base* physical Warrior
NPC turn-ins, level-20 mentor award and visible trainer UI
have **not yet passed an uninterrupted live playtest**.
An attempted additional test-script creation was not
accepted by the editing workflow, so no completed test
or successful result is claimed for it. The backend
physical actors/mentor/trainer exist and focused award
tests passed, but those do not substitute for a client
actually holding each prompt and purchasing a skill.

The Human Warrior source inventory records **62** historical
first-transfer level-20/24/28 rank opportunities; Ironvow
currently has **15 new authored skill ranks** across three
families, far short of its full recorded catalogue.
The repo's old starter level-1–19 source coverage and
many passive, polearm, blunt, armour, health and utility
mechanics still need separate implementation and proof.
No claim of complete C4 class, rank, gameplay, art or
copyright parity is made.

No Roblox publishing, production DataStore mutation or
`main` merge. All permanent changes were made in GitHub;
Remote Desktop Commander was used only for clean pulls,
temporary local Rojo builds and Studio execution/logs.
