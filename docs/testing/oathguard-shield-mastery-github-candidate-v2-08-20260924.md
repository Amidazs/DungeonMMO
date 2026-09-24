# Oathguard shield-mastery v2.08 — GitHub-only test status

Date: 24 September 2026 (local)
Branch: `wip/phase-4-test-hud-integration-v1`

The user reported Remote Desktop Commander unavailable. No local
Roblox Studio or Rojo build was run. Do not carry forward older v2.07
PASS results as verification of these new shield changes.

## Implemented and staged in GitHub

- `C4OathguardFoundationTest.server.luau`: source ranks at 20/28,
  forged/unawarded character must receive zero purchased protection;
  copied shield ranks may not bypass own-class trainer authority.
- `C4OathguardQuestAwardTest.server.luau`: purchases two ranks on a
  genuinely quest-awarded Oathguard, verifies 0.8% at rank one,
  zero without shield and 1.6% at rank two with registered
  `marauder_shield`; rejects unknown and wrong-slot items, reads the
  authenticated combat snapshot and denies copied ranks to a Fighter.
  The fixture sets a registered OffHand item ID directly in an isolated
  test profile; it does **not** prove normal inventory/equip UI flow.
- `C4Level30LaunchCoverageTest.server.luau`: asserts 37/54 mapped
  Knight source-rank opportunities and 17 unmapped, while the
  release-complete flag remains false.
- `PassiveSkillEffects.oathguard_shield_reduction` validates the real
  OffHand item category/slot and original awarded class before applying
  an earned rank. `ProgressionRuntimeState` accesses its immutable
  equipment snapshot; `DamageService` consumes it only on hostile
  `EnemyMelee`/`EnemyArea` branches.

## 24 September — desktop returned: executed v2.08 focused validation

The source-controlled branch fast-forwarded cleanly from
`1ad9e53` to `485c693`. The pre-existing unrelated quadruped
`__pycache__` directories were left untouched. Both disposable
v2.08 Base and Dungeon Rojo compositions **PASS**; the canonical
`DungeonMMO.rbxl` was not overwritten.

Unpublished Studio `c4_oathguard_quest_focus.luau` executed on the
fresh Base: Knight quest **66 assertions PASS**, foundation
**62 assertions PASS**; both suite verification markers appear in
the specific `20260924T081822Z_Studio_D8441_last.log` process log.
The separately launched `c4_level30_launch_coverage_focus.luau`
reported **27 assertions PASS** and its verification marker in
`20260924T081854Z_Studio_9DE3E_last.log`. These results
verify the isolated training, ownership and shield-equipment test
fixtures, not actual client damage.

The one fresh two-client Base physical playtest
`c4_oathguard_base_physical_live.luau` **FAILED**, not passed:
the client confirmed `PROMPT_VISIBLE=true`, and the prompt was
enabled at distance 4 studs, but its held input never produced
the server-side `CaptainRowan` `ProximityPrompt.Triggered` event.
See the server instance
`20260924T081936Z_Studio_ECDA7_last.log`:
`[Oathguard Physical] FAIL ... Client hold never triggered
actual server NPC CaptainRowan, visible=true, enabled=true, distance=4`.
It failed *before* mentor, purchase or shield gameplay; the
existing v2.06 physical PASS is historical and does not override this
v2.08 failure. Do not classify the failure as a proved shield-code
regression without a controlled comparison.

Still open: diagnose the physical prompt transport once (avoid
repeating the full quest without a concrete fix), live client-controlled
Knight first/third self-heal and enemy spell mitigation, actual
equipped-shield hostile physical hit measurements, multiplayer owner
isolation and end-to-end saved cross-place journey. No publication
or production DataStore mutation occurred.

## Remaining live gameplay verification

- [x] Focused Knight quest/foundation suites: **66 + 62 PASS**;
  level-30 audit: **27 PASS**, verified from separate Studio logs.
- [x] Disposable Base and Dungeon Rojo builds both PASS;
  canonical `DungeonMMO.rbxl` unchanged.
- [ ] Two-client Base physical NPC input: **FAILED** at visible,
  enabled four-stud Captain Rowan prompt; needs targeted diagnosis.
- [ ] Real client: genuine Oathguard with bought rank 1 and rank 2
  receives the correct reduction from the **same** enemy melee/area
  hit with an equipped shield. Unequipping eliminates the bonus.
- [ ] Real client: spell hits, player damage, unawarded Fighter,
  another party member and invalid OffHand gear do not receive it.
- [ ] Check prior v2.07 `OathguardMendingOath` owner-only healing and
  `OathguardRunicResistance` enemy spell mitigation with genuine
  client casts, cooldown, resources and wrong-class rejection.
- [ ] Save/rejoin, cross-place transfer and existing dungeon
  multiplayer/party-difficulty rules require independent proof.

Status: **GITHUB IMPLEMENTED / STUDIO PENDING**, not physically
accepted, release-ready, published or merged. No production DataStore
or paid-product operations were performed.
