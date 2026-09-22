# DungeonMMO roadmap v1.67 — real passive rank progression

Date: 22 September 2026
Feature branch: `wip/phase-4-test-hud-integration-v1`
Focused tested gameplay source:
`08710c1ce8e2390804080d826925e5346b1a48a6`

## Completed: next NEW class skill content

- [x] Add six-rank **Fighter Iron Discipline** (level brackets
  5 and 10): each trained rank increases authoritative physical
  damage scaling for that Fighter; six ranks add 0.06.
- [x] Add six-rank **Mage Arcane Discipline** (level brackets
  7 and 14): each trained rank increases authoritative magical
  damage scaling for that Mage; six ranks add 0.09.
- [x] Reuse existing class trainers, SP, skill ranks,
  character profiles and runtime combat multipliers. Passives
  cost SP and require character level, but cannot be cast:
  they have no cast-proficiency training requirement.
  All active skill mastery gates and advancement quest
  prerequisites continue to use purchased ranks and
  legitimately earned proficiency.
- [x] One Base Rojo build and **64 focused passive-rank
  assertions** PASS. Read-only skill-volume audit at the
  same gameplay source: **16/16 mapped C4 brackets still
  below their reference counts**; no C4 parity claim.

[Focused acceptance, counts and boundaries](../testing/c4-passive-rank-effects-2026-09-22.md)
[Earlier C4 rank-count mapping](../design/C4_Skill_Count_Parity_20260922.md)

## Next actual gameplay authoring

1. Map foundational level-1 and level-5 training choices
   against verified source brackets. Specify actual role
   and effects for the missing physical, defensive, magic,
   healing, support and crafting families. Do not count
   inert buttons as finished rank content.
2. Give existing starter abilities explicit rank-level
   schedules only where source and existing saved-character
   compatibility have been checked. Preserve learned
   ranks and migration rules; do not invent C4 rank
   levels to make a comparison chart turn green.
3. Extend the same meaningful skill breadth into the
   Ranger/Rogue class branches once their shared C4
   ancestry and race-dependent role mappings have
   been explicitly resolved.
4. Implement a compact trainer/advancement UI: unknown
   skills remain hidden below their current level/mastery
   gate, while the earned quest requirements may be shown
   as a future checklist. Keep validation server-side.
5. Run ONE normal-input passive combat integration when
   this content milestone is sufficiently playable.
   Do not repeat existing dungeon wipe, boss, aggro,
   revive or Play Again suites after each added skill.

Full original MMORPG class content, C4 count parity,
live passive combat balance, published TEST travel,
actual account reconnection and cloud continuity
remain distinct future milestones. No Roblox publish,
`main` merge or force-push was performed.
