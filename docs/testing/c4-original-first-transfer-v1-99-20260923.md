# DungeonMMO v1.99 — first-transfer class and trainer acceptance

Date: 23 September 2026
Development branch: `wip/phase-4-test-hud-integration-v1`
Environment: disposable unpublished Base/Dungeon Rojo compositions
and unpublished Roblox Studio only. No Roblox publication, `main`
merge, production DataStore mutation or local source editing.

## GitHub-first implementation

- Independently named, distinct level-20 DungeonMMO first-transfer
  identities: **Ashenblade** (Human Fighter / Human Rogue source)
  and **Greenward Scout** (Elf Fighter / Elven Scout source). These
  are not aliases for old Ranger/Rogue or secondary specialist
  profiles. Fighter remains the saved starting family.
- Physical mentor **Marshal Briar** or **Pathwarden Siora** is the
  only place that can mint a server-only one-use transfer event.
  Its server checks live player/proximity, own race, saved exact
  chosen branch and source quest `Ready`, every required earned
  proof, level >= 20, absent prior/legacy class and the active
  profile owner. Revalidation, mentor receipt, new current ClassId
  and awarded class ID are committed inside one profile mutation.
  An arbitrary client RemoteEvent cannot submit an award.
- Profile schema **v15** preserves correctly earned original
  class identities and their source quest/mentor receipts on
  save/reload while declining a lone unbacked ClassId. Existing
  legacy profiles and opaque saved quest/item IDs are preserved.
  Legacy secondary class claims cannot silently overwrite an
  already earned original first-transfer class.
- Separately authored advanced training stations and race/class
  restricted catalogues offer exactly one **already implemented**
  level-20 ability per class: Ashenblade's Human Scout Sprint
  and Greenward Scout's Elven Scout Guard. These use retained
  internal combat ability IDs, distinct from player-facing
  class/mentor names. Skill purchase remains subject to actual
  class receipt, current level, required SP, server-owned
  trainer proximity and the normal rank/proficiency rules.
  No skill is automatically granted on transfer, and no
  later unimplemented class skills are exposed.
- Original source quest/class-choice/progression snapshots now
  show the genuine earned class and current mentor objective.
  Existing hub/Fighter trainers and their remotes remain
  separate from new transfer trainers.

## Actual tests and regressions

1. Disposable local Rojo Base **PASS** and Dungeon **PASS**.
2. Focused first-transfer server-authority Studio suite:
   `scripts/studio/c4_original_first_transfer_focus.luau` —
   **2/2 PASS**, including **47** original transfer assertions
   and **8** adjacent existing quest/advancement migration checks.
   Verified level-18 refusal, forged event rejection, wrong
   race/branch denial, exact first class and receipt creation,
   one-time replay refusal, per-class skill/trainer unlock,
   first class save/reload into a separate profile service,
   and rejection of an unbacked forged raw ClassId.
   This is a server-fixture world verifier; it does **not**
   substitute for a genuine client-held physical mentor prompt.
3. Initial full two-client physical Base quest/mentor test reached
   the previously accepted completed source-quest reports but
   **FAILED** at the newly added mentor because competing
   Advance/Train prompts on the same part hid the actual
   advancement prompt. After separating the physical trainer
   and mentor, the subsequent full test verified a real Human
   Ashenblade transfer but **FAILED** to show the Elf's
   advancement prompt through the temporary hub scenery.
   The mentor now has a separately placed training station
   outside its prompt range and disables line-of-sight display
   restrictions; actual server-side live proximity and receipt
   checks are unchanged.
4. The focused follow-up real **two-client** unpublished Base
   playtest then **PASSED**:
   `scripts/studio/c4_original_first_transfer_two_client_live.luau`.
   This separate test **explicitly seeds source quests as
   completed at level 18** in its disposable Studio profiles
   to avoid unnecessarily rerunning the previously accepted
   quest-chain playtests. Each real client physically held
   the appropriate named mentor's ProximityPrompt; level-18
   attempts and opposite-race mentor interactions did not
   transfer a class. The real level-20 prompt awarded its own
   original class and persistent receipt only once.
   A real isolated trainer station near each class mentor
   then allowed the owner to **purchase** its implemented
   level-20 ability using the actual server skill-progression
   service; the other player received no class or ability
   from those interactions. Actual Roblox Studio marker:
   `VERIFIED_TWO_CLIENT_FIRST_TRANSFER_PASS`, with
   `REAL_FIRST_TRANSFER_Ashenblade_PASS` and
   `REAL_FIRST_TRANSFER_GreenwardScout_PASS`.
   The distinct trainer remote's UI/proximity handshake
   was not separately tested end to end; its server-side
   proximity gate and actual skill purchase were tested.
5. No tests in this record prove an uninterrupted Base →
   Dungeon → Base cross-place journey, all ten/four
   player-controlled monster victories, or full class
   catalogue parity. The final focused test used
   test-only prior source completion, and prior Dungeon
   combat tests used server-side finishing blows.

## Remaining acceptance

The two real level-20 career identities, physical mentor
awards, saved receipts and **one skill each** are integrated.
The remaining first-transfer skill inventories and other
16 classes are not complete. Until the full respective
class skill trees, real non-seeded journey and production
cross-place/persistence acceptance are finished, do not
describe all first-transfer classes as fully playable or
claim exact source-game skill parity. Keep original
DungeonMMO visual identities, dialogue and game-specific
quest narrative independently authored.
