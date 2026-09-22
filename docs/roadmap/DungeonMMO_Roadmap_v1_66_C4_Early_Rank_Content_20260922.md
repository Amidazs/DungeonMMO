# DungeonMMO roadmap v1.66 — first real C4 rank-volume expansion

Date: 22 September 2026  
Branch: `wip/phase-4-test-hud-integration-v1`  
Last focused tested gameplay source:
`cdecfc76ff4450dc329c1612e7834b8042f9b98b`

## Completed in this content increment

- [x] Add **Iron Cleave** and **Pursuit Step** as distinct,
  learnable, nine-rank Fighter combat skills. Each rank
  improves actual server melee damage; Pursuit Step
  uses a larger server-owned forward movement step.
  Ranks 1–3, 4–6, 7–9 are level-gated at 5, 10, 15.
- [x] Add **Renewing Light**, a six-rank Mage heal with
  actual increasing healing and a stronger sustained
  component. Ranks 1–3, 4–6 are available at 7, 14.
- [x] Reuse the existing base trainers, skill point
  authority, loadout, ranked combat, proficiency and
  inventory/profile systems. A hidden new rank-1
  ability never appears before its initial bracket.
- [x] Introduce per-skill rank thresholds so long
  ladders do not rewrite old three-rank mastery costs.
  Correct production profile migration to preserve
  legitimately earned multi-rank proficiency.
- [x] One Base build; Fighter **133 assertions** PASS;
  new Mage **37 assertions** PASS and affected existing
  class/quest/trainer/progression contracts **5/5** PASS.
  Source-count audit reports honest remaining gaps:
  **16/16 verified reference brackets still short**.

[Focused source/content acceptance](../testing/c4-early-fighter-mage-skill-ranks-2026-09-22.md)  
[Full reference mapping and gap specification](../design/C4_Skill_Count_Parity_20260922.md)

## Next actual content, not old dungeon tests

1. Fill early Fighter/Mage C4 reference gaps with real,
   usable bow/dagger or class-equivalent attacks,
   defence/weapon/armour passives, healing/support and
   common-crafting skills. Existing Fighter 5/10/15
   brackets now have **7** authored ranks each, below
   C4's 13/12(13)/12. Mage 7/14 has **4** each,
   below C4's 15(14)/21(20). Levels 1 and 5
   and legacy rank schedules remain unfilled.
2. Implement passive/utility/crafting effects in the
   existing combat/stat/profession authorities; do not
   count inert metadata or replicate foreign game IP.
   Validate each implemented rank is purchasable,
   changes a real effect, and has a correct level.
3. Finish the Human/Elf early-rank source inventory,
   then resolve shared Fighter/Rogue/Scout roots
   before mapping existing DungeonMMO Ranger/Rogue.
   Continue corresponding post-20 class training
   and later class transfers as actual content arrives.
4. Show separately optional future requirements in
   a compact character progression interface without
   revealing unknown locked skills in the trainer
   catalogue. Keep server checks on every purchase.
5. Accept one normal-input live strike/heal playtest
   when the new combat-content slice is ready.
   Published TEST/cloud/same-account reconnect
   remain a separately approved release gate.

**Not yet complete:** exact C4 skill-rank volume,
all-race/class trees, passives, skill-balance, fully
authored quest/trainer UI or published persistence.
Do not report C4 parity while any mapped source bracket
lacks real, available rank effects.

All scripts and documentation edited in GitHub only.
No repeated dungeon wipe, aggro, boss or Play Again tests,
Roblox publish, `main` merge, force-push or production
DataStore/purchase mutation.
