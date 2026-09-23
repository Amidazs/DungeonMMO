# C4 Scout Accuracy Toggle — focused Studio and real-client evidence

Date: 23 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`

## What was implemented

- Original level-24 `AccuracyToggle` source rank for Human Rogue
  and Elven Scout: separately purchased at the real Rogue/Ranger
  trainers, with correct race/class/level/loadout authority.
- `ScoutAccuracyToggle` genuinely toggles using the existing
  client-to-server `SkillRequest`. Activation costs three stamina;
  ongoing upkeep costs three actual stamina every second.
  The client cannot provide its own strength or a hit/miss result.
- An active, learned skill grants a bounded +0.12 hit probability
  **against server-tagged NPCs with server-authored
  `CombatEvasionChance`**. The real `DamageService.apply_damage`
  checks this on both player melee and physical bow damage.
  For example an NPC with 0.12 authored evasiveness has 0.88
  base hit chance and 1.00 while the skill is legitimately active.
  Ordinary NPCs without authored evasiveness retain their
  previous guaranteed-contact behavior; the new system does
  not introduce arbitrary misses to all existing dungeon NPCs.
- A true miss applies no HP damage, no damage contribution,
  and no NPC stagger, threat reduction or slowing effect.
  Activating the stance does not increase critical damage or
  grant a second profession. The separately implemented
  five-rank Critical Power toggle is unchanged.
- A second client cast turns Accuracy off without charging
  another activation cost. Exhaustion automatically removes
  the bonus; the active effect is also revoked when the
  purchased rank, selected skill, authorized class/session
  or living original character is no longer valid.
- Shared hit-chance resolution is isolated in
  `ScoutAccuracyRules`. A server-only `accuracy_roll`
  test input permits deterministic proof of real combat
  paths without allowing the client to submit hit results.

## Executed results

- `luau-compile --only-parse` passed for all fourteen
  modified/new gameplay and focused-test Luau sources.
  Disposable focused and full Dungeon Rojo builds succeeded.
- In actual unpublished Studio, the focused runner reported
  **7/7 passed, 0 failed**. This included the new
  `C4ScoutAccuracyToggleTest` (**39 assertions**) and
  strict Scout inventory audit (**1,112 assertions**).
- A separate actual unpublished Studio execution of the pre-existing
  `DamageServiceTest` passed **15/15 assertions** after this
  integration. It verifies existing non-evasive attack damage,
  deterministic critical damage and dead-target handling
  remain unchanged for legacy combat contexts.
- The real unpublished one-client Dungeon session ran
  `scripts/studio/c4_scout_accuracy_toggle_live.luau`.
  The actual client sent real Accuracy on/off requests;
  a genuine admitted player and its server-owned progression,
  stamina and combat authority participated.
  The server then applied the *same deterministic physical
  attack roll* (0.90) against a tagged living NPC with
  `CombatEvasionChance=0.12` through actual
  `DamageService.apply_damage`.
  Before activation the real melee and ranged physical
  damage paths both missed (zero damage); after actual client
  activation the same melee and bow damage paths both hit.
  The test also required stamina consumption over time,
  client-requested OFF restoring misses, and automatic
  expiration on real stamina exhaustion. The runner returned
  `[C4 Scout Accuracy Live]
  VERIFIED_REAL_CLIENT_ACCURACY_PASS`.
- This is a real-client **skill-cast** and authentic
  server melee/ranged damage integration test. The actual
  weapon input/projectile against an evasive NPC was
  *not* used for the deterministic comparison; do not
  describe the server-created hit contexts as client-fired
  melee swings or arrows. v1.83 separately verified
  the true client-fired Snaring Shot projectile impact.
- Changes to scripts, project maps, test runners and
  documents were made exclusively through GitHub.
  The authorized desktop was used solely for clean
  pull, read-only inspection, parser/build and disposable
  unpublished Studio test execution. No local source
  edits, `main` merge, publishing, reset, paid operations
  or production DataStore modifications were performed.

## Exact six-inventory source-rank accounting

| Original C4 inventory | Implemented / raw | Remaining |
| --- | ---: | ---: |
| Human Fighter | 39 / 39 | 0 |
| Elven Fighter | 43 / 43 | 0 |
| Human Mystic | 44 / 44 | 0 |
| Elven Mystic | 42 / 42 | 0 |
| Human Rogue (partial first transfer) | 87 / 99 | 12 |
| Elven Scout (partial first transfer) | 118 / 129 | 11 |
| **Six inventoried classes** | **373 / 396** | **23** |

The other seven original first-transfer class source catalogues
remain entirely unmapped. **0/9 original first-transfer paths
have reached full completion.**

**v1.84: Accuracy source tests PASS; real-client activation,
actual melee/ranged hit calculation and upkeep PASS. Complete
original C4 catalogue remains INCOMPLETE.**
