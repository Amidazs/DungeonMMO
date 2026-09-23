# v1.95 original naming and quest combat foundation — actual checks

Date: 23 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Scope: Distinct DungeonMMO names for the currently live original
advancement quests and an isolated, unpublished instanced-monster
receipt ledger. **No finished stage-three playable quest is claimed.**

## GitHub-first source changes

- Player-visible NPCs: Captain Ashford, Quartermaster Vela,
  Pathfinder Elyra and Warden Thorne. The later planned characters
  are scout Cael, Marshal Briar and Pathwarden Siora.
- Named source enemies now use Crypt Sentinel, Cinder Brigand,
  Bracken Raider and Bracken Warden. The two quest titles are
  `The Ashen Blade Trial` and `The Greenward Search`.
- Player-facing equipment and quest drops display Vela's trial
  dagger/bow, Crypt Sentinel Fragment, and Cael's four
  field-report fragments. First-transfer UI text no longer
  advertises another game's title or links to its walkthrough.
- Historical persisted inventory IDs (`neti_trial_*`,
  `spartoi_bone`, `prias_letter_*`), quest IDs, proof
  ledger keys and existing character choices are deliberately
  left intact. The original names are no longer player-facing;
  rewriting those storage keys without a versioned migration
  would risk losing legitimate saved equipment and quest progress.
- Added `C4QuestMonsterCombatLedger`, a server-only per-session
  registrar. It requires the exact physical Model, registered
  source-monster ID, original quest branch, encounter ID, living
  Humanoid and unique life GUID. Its future combat callback
  rejects client-shaped attackers, disconnected/invalid party
  members, wrong branch/stage, non-damaging hits and missing
  equipped trial weapons; it emits individual source proof
  only from an authenticated lethal server damage callback.
  Its world verifier consumes one exact event per owner,
  and requires an already registered live quest encounter.
  **This ledger is not yet attached to a live spawned challenge,
  damage callback, dungeon quest service or return-trip UI.**

## Executed unpublished Roblox Studio tests

- Base disposable Rojo build: **PASS**.
- Dungeon disposable Rojo build: **PASS**.
- `scripts/studio/c4_original_quest_skill_scope_focus.luau`
  in the unpublished local Base: **5/5 PASS**.
  Original quest and naming assertions: **148 PASS**;
  first-choice selection 46, class paths 14, catalogue
  7 and quest migration 8 assertions also passed.
  Verified original names, removed external quest links,
  saved opaque legacy item IDs and their new visible labels,
  independently owned stage-three mock proof and rollback.
  These source-stage mock kills are **not real client combat**.
- `scripts/studio/c4_source_quest_combat_ledger_focus.luau`
  in the unpublished local Dungeon: **1/1 PASS**, 10
  assertions. Registered a real Humanoid Model in Workspace
  with canonical server encounter and monster attributes;
  rejected wrong-branch, wrong-room, duplicate life,
  attacker table and forged world evidence; verified
  stage-specific availability and wipe cleanup.
  This does **not** verify a real player attacking a monster.
- `scripts/studio/c4_original_second_npc_two_client_live.luau`
  in the unpublished local Base: **PASS**:
  `VERIFIED_TWO_CLIENT_STAGE_TWO_PASS`. The test checked
  all four physical ProximityPrompt display names, distinct
  Human/Elf owner-specific progress and the existing genuine
  NPC/equippable trial weapon safeguards. No advanced class
  was issued.

All code and documentation changes were made through GitHub.
Remote Desktop Commander was used only for a fast-forward pull,
disposable Rojo build, starting Studio and reading test output.
The unrelated quadruped caches were not modified. There was
no `main` merge, Roblox publish or production DataStore mutation.

## Explicit follow-up required

1. Author **original** art, dialogue, enemy silhouettes and
   distinct quest narrative—not copied assets, text or visual
   designs. Changing labels alone is not a copyright clearance.
2. Create a real isolated source-quest dungeon challenge
   whose server creates Crypt Sentinel/Bracken Raider models
   with authenticated encounter and source IDs. Register each
   physical model in the new ledger and attach the ledger
   to the existing server DamageService callback without
   overriding the contribution/threat listeners.
3. Persist one earned fragment per qualifying owner, test
   real client impact/kill, disconnection, wipe/retry,
   party outsider and wrong-equipment denials, then
   authenticate the stage-four return at the actual NPC.
4. Implement the later distinct challenge stages, quest turn-in,
   original class skill gates and authoritative level-20 award.
   **Fully playable original first-transfer branches: 0/18.**
