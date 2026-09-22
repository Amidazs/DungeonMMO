# DungeonMMO roadmap v1.68 — earned health and restoration passives

Date: 22 September 2026
Feature branch: `wip/phase-4-test-hud-integration-v1`
Focused tested gameplay source:
`3be5de3316c16a531537feb175d119f171a44b67`

## Added and locally verified

- [x] Six **Stalwart Training** Fighter ranks: three purchasable
  at level 5 and three more at level 10. Real server max-health
  increase of five HP per purchased rank (+30 at rank six).
- [x] Six **Restorative Training** Mage ranks: three purchasable
  at level 7 and three more at level 14. Real server healing
  multiplier increases by 0.012 per rank (+0.072 at six).
- [x] Existing class authority, SP, persisted ranks, trainer
  level gates, profile migration and runtime stat refresh
  reused. Unknown future skills remain hidden before
  unlocking; passives do not demand impossible cast XP.
  Existing Fighter/Mage damage passives and level-20
  active-skill mastery/advancement checks remain intact.
- [x] One Base Rojo build; 64 new HP/heal rank assertions
  and 64 directly affected legacy damage-passive assertions
  passed at the same source head. Initial missing base-class
  teachability was caught and fixed, not bypassed.
- [x] Read-only C4 audit: 16 mapped early class brackets,
  13 still mismatched, 14 unmapped skill-rank occurrences.
  Fighter 5 and Elf Fighter 10 match their numeric targets,
  but Human Fighter 10 has 13 authored versus 12 target
  and needs a source-aligned family/rank mapping before
  claiming parity.

[Focused test and measured reference gaps](../testing/c4-vitality-restoration-rank-effects-2026-09-22.md)
[C4 source and count mapping](../design/C4_Skill_Count_Parity_20260922.md)

## Next genuinely missing C4-inspired content

1. Map the currently unmapped **existing** starter skills to their
   C4-corresponding character/race/level family before adding more
   unrelated buttons. Preserve saved ranks when adding schedules.
2. Author additional actual physical, defensive, healing and utility
   *rank effects* at verified level 1/5/7/10/14/15 brackets, with
   SP cost, mastery/level unlock and practical combat effects.
   Avoid padding counts with inert entries or reshuffling a
   useful skill merely to force a table to appear green.
3. Address the Human Fighter level-10 overcount and distinct
   Elf Fighter / Human and Elf Mystic gaps with explicit
   per-family source mapping, not blanket copying ranks.
4. Expand the Rangers/Rogues only after documenting how their
   current level-one split relates to C4's shared post-20
   scout/rogue roots; do not double-count common ranks.
5. Show the currently learnable skills at the trainer and a
   separate **future progression preview** listing levels,
   purchased ranks and unfulfilled prerequisites. Retain
   authoritative server purchase/quest gates.
6. Once this skill-content slice is playable, run one targeted
   normal client combat/heal acceptance. Repeating completed
   dungeon wipe, revive, Play Again or world-boss regressions
   after each new skill is not part of this workstream.

No full C4 parity, final class tree, real-client balance,
published reserved-server continuity or production readiness
is claimed. Nothing was merged into `main` or published.
