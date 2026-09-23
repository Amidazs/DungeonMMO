# DungeonMMO roadmap v1.80 — C4 crafting ranks and live playtest

Date: 23 September 2026
Working branch: `wip/phase-4-test-hud-integration-v1`

## Precedence

This is the latest **backend/economy/C4 source-rank supplement**,
following [v1.79 exclusive professions](
DungeonMMO_Roadmap_v1_79_Exclusive_Professions_20260923.md).
The separately maintained humanoid-animation roadmap remains the
authority for animation production and visual approvals. This
increment supersedes none of its rig/animation tasks.

## Completed first-tier crafting backend

- [x] Human/Elf Fighter and Mage source `RecipeReading`: purchased
  rank one, level-one, class-trainer offered **only after** the
  character chooses its one creation profession. Genuine
  server-owned recipe-literacy authorization gates consuming and
  learning another blueprint for that selected career.
- [x] Human/Elf Fighter and Mage `CommonItemCreation`: purchased
  rank one, level-five, requires learned `RecipeReading`.
  The server refuses missing-skill, wrong-career, incorrect-level,
  unknown/unequipped/missing materials, learned-recipe violations,
  wrong station, and client-forged minigame outcomes.
- [x] Four ordinary alternate recipes produce real, tradable
  material-backed outputs: Blacksmithing iron bar, Alchemy tempering
  oil, Leatherworking cured leather and Enchanting warding rune.
  Each is exclusively available to its one chosen creation
  profession and consumes real ingredients and awards actual
  profession XP. The server revalidates again inside the atomic
  inventory/profile mutation; it does not unlock all professions.
- [x] The existing closable profession panel uses authoritative
  per-recipe `Unlocked` and displays a locked skill/recipe state
  instead of offering invalid client craft requests.
- [x] Retained prior learned recipes, profession XP, inventory and
  market transactions across schema-v14 migration. New blueprints
  now require actually purchased `RecipeReading`.

## Executed unpublished Studio acceptance

- [x] Both disposable Base and Dungeon builds succeeded; the
  twelve changed new-skill Luau files passed parser checks.
- [x] **12/12** focused real Studio tests passed in the final run,
  including the new 96-assertion actual C4 trainer/read/craft test
  and existing two-/four-character marketplace dependency cases.
- [x] Real **two-client** local Base playtest passed through
  `StudioTestService:ExecuteMultiplayerTestAsync`: both clients'
  selection UIs appeared and closed after choosing, one smith
  crafted a bar, the Alchemist's second-crafting-profession request
  was denied, and a genuine market purchase delivered the smith's
  bar to the Alchemist. Automated UI/state verification was used;
  no manual visual/art acceptance was claimed.
- [x] Read-only source-rank diagnostic identified stale expectations
  from the prior Mystic weakening increment, which were corrected
  in the **tests** without artificially changing source inventory
  or audit rules. Exact current first-tier source mapping:
  Human Fighter 39/39; Elf Fighter 43/43; Human Mystic 41/44;
  Elven Mystic 39/42.
- [x] Updated [executed Studio and live gameplay record](
../testing/c4-exclusive-professions-v1-80-2026-09-23.md).
- [x] Scripts/documents edited **only through GitHub**. Local
  desktop was used for read-only checks, clean pull, disposable
  test builds, source parser and unpublished Studio gameplay.
  No publish, paid operations, `main` merge, force reset or
  production DataStore mutation.

## Honest remaining C4 coverage

- Four sourced starting class inventories: **162/168**, only
  **six** `PartyHeal` ranks unimplemented (three Human Mystic,
  three Elf Mystic).
- Two sourced partial Rogue/Scout inventories: **189/228**;
  **39** still missing.
- Combined currently inventoried: **351/396** real analogues;
  **45** source-ranked entries remain **in those six inventories**.
- Original nine C4 first-transfer class paths: **0/9 complete**;
  seven distinct first-transfer skill catalogues remain unmapped
  entirely. These are **additional work**, not part of the
  45 remaining in the presently inventoried six classes.

## Next focused backend work

- [ ] Add legitimate **party-only multi-target healing** with
  party membership, same-session/instance, living-ally checks,
  range, per-target actual HP restoration, resource and rank
  scaling, cooldown, hate/threat, anti-spam and genuine client
  invocation; map three source-level-14 rank entries for each
  Human and Elven Mystic only after executed server + two-client
  healing verification.
- [ ] Continue source mapping of missing Human Rogue/Elven Scout
  world/resource skills, and then all seven separate original C4
  first-transfer classes with class-advancement gating and
  real server-authoritative skill effects.
- [ ] The v1.78 hostile-weakening in-combat client acceptance
  is separate and remains open; do not confuse profession
  multiplayer acceptance with that earlier combat acceptance.
- [ ] Decide whether to permit switching one chosen profession,
  including cooldown, progression loss and legacy XP policy,
  before implementing any retraining/unlearning.
- [ ] Retire or update the old
  `scripts/studio/profession_two_client_live.luau` test,
  which assumes every character may craft and skin; the new
  `profession_exclusive_two_client_live.luau` is the source of
  multiplayer profession acceptance after v1.79.

**Exclusive-professions + C4 craft ranks: VERIFIED in focused Studio
and automated two-client local gameplay. Full C4 catalogue: INCOMPLETE.**
