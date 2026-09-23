# DungeonMMO roadmap v1.81 — verified first-tier C4 Party Heal

Date: 23 September 2026
Backend branch: `wip/phase-4-test-hud-integration-v1`

## Roadmap precedence

This is the latest **C4/source-ranked backend supplement** after
[v1.80 C4 crafting and professions](
DungeonMMO_Roadmap_v1_80_C4_Crafting_Playtest_20260923.md).
The separate, newer humanoid animation production roadmap
remains authoritative for rigs, poses, animations and visual
acceptance; no animation work was performed by this backend step.

## C4 Human/Elf starting classes — completed source inventory

- [x] Human Mystic `PartyHeal`, three real rank levels at source
  character level 14 with increasing per-member HP.
- [x] Elven Mystic `PartyHeal`, three real rank levels at source
  character level 14 with increasing per-member HP.
- [x] Purchased Healing Prayer prerequisite, correct Mage race
  and base class, legitimate trainer, Arcane Wand, current rank,
  loadout, mana, skill cooldown and live member eligibility
  gate real combat. Client-provided target IDs or party lists
  never establish actual membership or override rank effects.
- [x] The Dungeon-only server roster is based on the original
  session authority and checks active state, connected members,
  neither abandoned nor spectators, and combat eligibility.
  Each injured ally must also be alive, within the authored
  true 3D radius and visible to the caster.
- [x] One client-requested cast can heal several eligible members
  only once each, capped by true missing HP. Healing calls the
  existing progression, contribution and threat callback per
  actual amount restored.
- [x] No out-of-party, solo-active, dead or spectating player can
  receive a fake multi-target heal; no separate free/lingering
  effects after member eligibility changes.
- [x] Focused real unpublished Studio: five dedicated suites PASS,
  actual rank trainer gates, 168/168 base source audit and existing
  Mage Heal primitive.
- [x] **Actual two-client Dungeon** playtest PASS after correcting
  test timing mistakes that confused passive HP regeneration with
  cast completion and a second cast. Real admission, original
  client combat remote, dual-target HP, NPC support threat,
  no immediate recast, radius rejection and spectator exclusion
  were all observed. See [v1.81 execution record](
../testing/c4-party-heal-v1-81-2026-09-23.md).
- [x] All scripts and documents edited only through GitHub;
  the local desktop was used only for safe fast-forward pulls,
  disposable unpublished Studio tests/builds and read-only
  diagnostics. No publishing, `main` merge or production
  DataStore migration occurred.

## Precise source coverage

| Original C4 source class | Functional analogue ranks | Remaining |
| --- | ---: | ---: |
| Human Fighter | 39/39 | 0 |
| Elven Fighter | 43/43 | 0 |
| Human Mystic | 44/44 | 0 |
| Elven Mystic | 42/42 | 0 |
| Human Rogue (partially mapped first transfer) | 81/99 | 18 |
| Elven Scout (partially mapped first transfer) | 108/129 | 21 |
| **Currently inventoried six classes** | **357/396** | **39** |

All four original starting class *source rank inventories* are now
mapped to a real playable analogue. This is **not** a declaration
that their animations, entire game backend, art or the full original
C4 class catalogue are finished. Seven additional original
first-transfer class catalogues remain unmapped entirely; only
two of nine paths have partial inventories and **0/9 original
first-transfer paths are complete**.

## What to implement next

- [ ] Complete the remaining original Human Rogue (18 ranks)
  and Elven Scout (21 ranks) with proper world interactions,
  skill progression, conditional effects and server authority.
  Keep WoW-style one Gathering and one Creation profession
  enforced during any new resource interactions.
- [ ] Source-inventory and implement the seven distinct,
  unmapped original C4 first-transfer class paths, including
  class-specific quests and purchased skill prerequisites.
  Existing DungeonMMO similarly named classes are not a
  substitute for their original C4 source inventories.
- [ ] Close separate v1.78 Mystic hostile-weakening real
  combat acceptance when appropriate. The broad
  `SkillProgressionServiceTest` proficiency purchase assertion
  observed in an unrelated auto-enabled Studio server test
  still requires an independently scoped review.
- [ ] Audit ordinary party-heal UI/feedback/animations visually
  when later working on the art/HUD milestone; automated
  server/client checks do not certify polished presentation.
- [ ] Continue backend-only, GitHub-first changes, using the
  local desktop exclusively for necessary Studio gameplay
  and targeted source verification. Do not rerun prior dungeon
  wipe/paid revive suites without a specific regression reason.

**Human/Elf basic C4 source inventories: 168/168. Entire original
first-transfer C4 catalogue: INCOMPLETE.**
