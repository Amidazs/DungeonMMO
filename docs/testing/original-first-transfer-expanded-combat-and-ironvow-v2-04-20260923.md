# DungeonMMO v2.04 — new actual combat and unearned Warrior foundation

Date: 23 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Supersedes no previous gameplay acceptance; extends the
[v2.03 rank-purchase record](
original-first-transfer-level30-ranks-v2-03-20260923.md).
All permanent code and documentation changes were made through GitHub.
The desktop was used for clean Git pulls, disposable local Rojo builds
and unpublished Studio playtests only. No Roblox publication,
`main` merge or production DataStore update.

## Executed: real expanded two-client Dungeon combat

New GitHub-owned runner:
`scripts/studio/original_first_transfer_expanded_combat_two_client_live.luau`.
Unpublished local Dungeon Rojo build **PASS** and complete
two-client Studio test **PASS**. Real players entered an actual
active instanced first combat room and sent existing production
`SkillRequest` remotes from genuine client LocalScripts.

- `WAYFINDER_CUT_RANK_NINE_PASS`: the prepared personally earned
  Ashenblade skill rank nine hit a real room enemy, reduced its
  server Humanoid health and started the skill cooldown.
- `WAYFINDER_WOUND_TICKS_PASS`: separately equipped and
  purchased Wayfinder Wound hit the same living enemy; its actual
  health decreased again after impact during the server-owned
  damage-over-time ticks, with an authenticated cooldown.
- `WAYFINDER_ARROW_RANK_NINE_PASS`: a real Greenward Scout
  bow projectile hit that enemy, reduced health, added genuine
  enemy threat and started the skill cooldown.
- `GREENWARD_CALMING_THREAT_PASS`: a second genuine Elf
  client-originating projectile hit the enemy; after the real
  hit, the server-owned threat ledger for the caster rose by
  **less than the effective damage** because the registered
  calming effect reduced the existing threat. Its cooldown
  started. The test does not claim the exact post-hit fraction
  was independently measured against every possible modifier.
- `TWO_CLIENT_EXPANDED_COMBAT_PASS` and
  `VERIFIED_TWO_CLIENT_EXPANDED_COMBAT_PASS` confirm all checks
  completed in one full two-client Studio run.

This live test prepares previous quest proofs, true original class
receipt, correct weapon and the purchased skill ranks in **disposable
test profiles**, then reads genuine enemy health/threat/cooldown.
Earlier v2.03 focused tests had actually purchased all recorded
20/24/28 skill ranks through SkillProgressionService. The live test
does not demonstrate a natural level-1→30 grind, every rank's live
damage, every passive/utility effect, UI hotbar click or an
uninterrupted cross-place quest journey.

## Executed: first original Human Warrior skill foundation

Initial independently named **Ironvow** Human Warrior class
definition is non-creatable. Three skill families have real
server-authoritative definitions but **no player can earn the class
yet**:

- `IronvowDrivingStrike`: nine individually defined 20/24/28
  sword-attack ranks with a purchased Fighter precursor and real
  increasing authoritative melee impact values.
- `IronvowBladeTraining`: three level-20/24/28 purchased
  passives whose physical-damage contribution is bound to an
  authentic first-transfer receipt; forged claims return zero.
- `IronvowBattleCall`: three level-20/24/28 temporary
  server-owned self-buff ranks; no permanent passive benefit
  from buying the active skill.

**Both** unpublished Base and Dungeon Rojo builds **PASS**.
`scripts/studio/c4_ironvow_foundation_focus.luau` **PASS,
33 assertions**: correct authored rank levels, class-only
skill listings, stronger rank effects, and denial of a forged
Human Fighter → Ironvow class ID, borrowed purchased skills
and unearned mastery passive. The existing
`OriginalFirstTransferDefinitions.for_branch("HumanWarrior")`
is deliberately still nil and the Human Warrior branch
remains not implemented. No human Warrior quest NPC,
monster proof, mentor prompt or usable trainer has been
claimed or provided yet. These 15 authored ranks are an
initial **subset**, not a complete C4-through-30 Warrior
training catalogue or an additional playable class.

## Remaining acceptance

Implement and playtest the independently authored Human Warrior
source quest, personally earned monster/item evidence, true
level-20 physical mentor, atomic original class receipt,
class-exclusive nearby trainer and the rest of the skill families.
Only then allow a genuine character to buy and cast Ironvow
abilities. Reconcile all starter-level 1–19 and first-transfer
20/24/28 historical references separately for every advertised
launch career. The prior 59/77 source-rank figures describe the
repository's recorded first-transfer inventories, not certified
full mechanical parity or comprehensive release acceptance.
Keep the initial proposed level-30 cap and do not enable a
production cap or publish places without explicit approval.
