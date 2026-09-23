# DungeonMMO v2.01 — live original first-transfer combat acceptance

Date: 23 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Test source: [real two-client original transfer combat](
../../scripts/studio/original_first_transfer_combat_two_client_live.luau).
Previous: [v2.00 class skill/trainer acceptance](
c4-original-first-transfer-v2-00-20260923.md).

## Actual executed results

A disposable, unpublished **Dungeon** Rojo build succeeded. The
actual Studio multiplayer test joined two real clients in one active
instanced Dungeon session, entered the physical first combat room,
and used its actual `DungeonGameplayRuntime.DungeonEnemies` models.

**Final complete two-client Studio result: PASS**.
The test verified these independently observable server effects:

1. The Human owner's **Ashenblade Opening** was sent by a genuine
   client over the existing production `SkillRequest` remote
   and hit a real current-room physical enemy. The enemy's actual
   Humanoid health decreased. The Human spent real combat stamina
   and acquired the corresponding server cooldown.
2. With a sword equipped in place of the required dagger,
   a genuine client request for Opening did not damage that enemy
   or start the skill cooldown. Restoring the real dagger and
   reseeding the authentic server combat snapshot allowed the
   genuine paid attack. The unrelated Elf did not receive a
   Human class award.
3. With Greenward Renewal absent from the owner's purchased
   skill state, a genuine Elf client request did not produce
   a substantive 35-health self-heal or start the ability
   cooldown. The prior purchased rank was restored in the
   disposable test profile for the subsequent positive cast.
4. The genuine Elf client's **Greenward Renewal** cast
   restored real owner Humanoid health, spent real mana and
   started its own server cooldown. The other client's health
   did not show the substantial cross-owner increase that
   would indicate an unauthorized shared heal. The registered
   skill remains `SELF_ONLY`.

Actual Studio markers:

- `WRONG_WEAPON_CLIENT_CAST_DENIED_PASS`
- `REAL_ASHENBLADE_ENEMY_HIT_PASS`
- `UNPURCHASED_CLIENT_HEAL_DENIED_PASS`
- `REAL_GREENWARD_OWNER_HEAL_PASS`
- `TWO_CLIENT_ORIGINAL_CASTS_PASS`
- `VERIFIED_TWO_CLIENT_REAL_CASTS_PASS`

Earlier iterations of the **extended negative test** failed
because asserting exactly unchanged Humanoid health confused
ordinary regeneration with an ability cast. Restoring the
purchased class after the unpurchased cast also applied the
normal runtime health recalculation and invalidated the
original test injury baseline. The final test records its
injured baseline **after** that runtime restoration and rejects
a substantial unintended heal while tolerating small natural
health changes. These were test-fixture assertions; no
production healing/damage code was changed.

The existing v2.00 focused server suite had passed 2/2 tests,
including 93 first-transfer progression/runtime assertions and
eight adjacent migration assertions. The v2.01 change adds
live combat acceptance, not a repeat of all earlier suites.

## Accurate boundaries

- Earlier personal source quests, level-20 mentor awards,
  current class identity, purchased first rank and starter
  mastery are **prepared in this disposable combat test
  profile**. Their separate real physical mentor/trainer
  and saved-rank acceptance remains documented in v1.99
  and v2.00. This test does not prove a single uninterrupted
  Base → Dungeon → Base progression journey.
- These genuine skill remote requests originate from a
  test-only client LocalScript and go through the production
  combat RemoteEvent, server eligibility/cooldown and
  live executor. The test does **not** click the player's
  actual hotbar icon or measure animation presentation.
- This test validates the new abilities' **rank-one**
  real effects; stronger purchased rank-two values
  were verified in the v2.00 actual combat definition,
  purchase and profile persistence tests, **not**
  in live rank-two gameplay.
- An ordinary physically spawned current-room enemy was
  damaged. No claim is made that the full quest chain
  or all ten/four kills were player-controlled or
  executed without preparing prior quest progress.
- No Roblox publish, production DataStore write,
  `main` merge, local source/document edit using
  Desktop Commander or new model/mesh was performed.
