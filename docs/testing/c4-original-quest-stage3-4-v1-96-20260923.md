# DungeonMMO v1.96 — first quest-monster fights and NPC turn-in tests

Date: 23 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Scope: Original DungeonMMO *Human Rogue* / *Elven Scout* source quests;
instanced stage-three combat, personal bound drops and real stage-four
Hub NPC returns. All playtests ran in disposable unpublished Studio places.

## What changed in GitHub

- Optional, original-name Crypt Sentinels and Bracken Raiders now spawn
  inside each active ordinary Dungeon combat-pack encounter **only when
  an active, connected party member has the corresponding selected
  original class quest at stage three**. Two per qualifying branch per
  combat room; inactive or spectating members do not trigger a spawn.
  Ordinary encounter ownership, boss/room cleanup, rewards and
  progression are retained. Each generated model is a real physical
  server-spawned Humanoid with its own encounter, enemy and life
  identity, then explicitly registered with the quest combat ledger.
- Real combat damage is observed through the existing contribution
  bridge, without replacing threat or ordinary combat rewards.
  Registered-monster ownership, actual connected party contribution,
  equipment, precise selected stage and unique monster life must pass
  before a personal quest event can grant one bound item and increment
  the source quest. Ordinary unrelated enemy deaths cannot grant
  source quest progress.
- The *same physical* Quartermaster Vela and Warden Thorne prompt now
  accepts the respective stage-four return **only after** real
  personally owned quest materials and accumulated proof exist.
  A successful return consumes the ten personal Crypt Sentinel
  Fragments or all four separate Cael report fragments atomically
  within the profile transaction; the earned proof stays saved.
  Replay, missing materials and unrelated branch/player rejection
  still apply. No advanced class is awarded by either return.
- Visible source quest UI provides the correct original mentor return
  objective. Existing saved legacy item IDs/proof IDs are retained;
  actual player-visible names remain original DungeonMMO names.

## Executed unpublished Studio verification

1. Disposable Base/Dungeon Rojo compositions: **PASS**.
2. Focused Dungeon quest combat suite: **3/3 PASS**, covering **10**
   physical model/forged receipt assertions, **12** mixed-branch
   actual physical-spawn/registration assertions and **13** existing
   contribution/quest damage-observer assertions.
3. **Actual two-client Dungeon live test PASS**:
   `scripts/studio/c4_source_quest_two_client_dungeon_live.luau`.
   Both real clients were admitted to the same active TestDungeon
   instance, with temporary test-only seeded level-18 original
   Fighter stage-three profiles. Both branches' dedicated physical
   monsters appeared after a real room trigger. A wrong-branch
   attack did not grant another player's proof. An actual normal
   client attack hit the registered Crypt Sentinel; server-applied
   lethal follow-up went through the unchanged DamageService.
   Each separately contributing client earned exactly one correct
   personal stage-three material and quest credit; neither received
   the other branch's loot or an unimplemented class.
   Studio reported
   `[C4 Source Two Client] VERIFIED_REAL_DUNGEON_COMBAT_PASS`.
   **The lethal finishing blows were applied by the server-side
   playtest, not by sustained player input.** Full ten-kill/four-kill
   real-player completion across multiple rooms/runs was not tested.
4. **Actual two-client Base NPC live test PASS**:
   `scripts/studio/c4_original_second_npc_two_client_live.luau`.
   Existing genuine first/second-stage physical prompt acceptance
   retained its previous behaviour. Separately, the disposable
   test seeded completed stage-three personal items/proofs for both
   clients **in the Base test place** to exercise stage-four turn-in.
   Real client ProximityPrompts rejected missing progress and
   missing personally owned loot, accepted the completed rightful
   branch, consumed the ten/four materials, advanced to stage five
   and rejected repeated interactions. Both original characters
   remained Fighters, without a free class award.
   Studio reported
   `VERIFIED_TWO_CLIENT_STAGE_TWO_PASS` and
   `VERIFIED_STAGE_FOUR_TURNIN_PASS`.
5. Focused Base class/quest/profile suite: **5/5 PASS** after the
   new atomic turn-in, including **153** source quest/consumption
   assertions. Saved/reloaded profiles do not regain spent items.
   Quest-choice, class-path, skill-catalogue and migration suites
   also passed their focused checks.

## Boundaries and next acceptance

These are working optional source enemies **inside existing instanced
dungeon combat packs**, not a separate fully authored quest dungeon.
The original placeholders use existing Marauder rigs and temporary
spawn offsets; independently authored appearances, arena layouts,
dialogue and NPC/monster assets remain required.

The Base-to-Dungeon-to-Base profile handoff and progression to the
actual stage-four NPC have **not yet been exercised as one continuous
real two-client journey**: the Dungeon and Base live tests used
independent, clearly test-only source-profile seeding. Finish that
cross-place acceptance, including reconnect/wipe/retry, 10/4 distinct
actual client-combat victories and no duplicate personal drops.

Later Captain Ashford / Scout Cael stages, independent brigand/key
encounters, original level-20 class transfer, skills and trainer
gating remain unfinished. **Fully playable original first-transfer
classes: 0/18.** No `main` merge, published Roblox place,
production DataStore mutation or unrelated local file change.
