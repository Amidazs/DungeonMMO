# C4 Rogue / Elven Scout ranked crafting — v1.85 evidence

Date: 23 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`

## Implemented original skill progression

The original C4 first-transfer Human Rogue and Elven Scout
`CommonItemCreation` entries at levels **20, 28 and 36**
now map to a real separately purchased three-rank passive
`ScoutCommonItemCreation`. Rank two requires rank one;
rank three requires rank two. Characters must select **one**
creation profession and buy `C4RecipeReading` before
purchasing the first rank. Ranger/Rogue class skill lists
and their actual trainers now offer Recipe Reading as well
as the three earned creation ranks. Fighter/Mage starting
class level-five `C4CommonItemCreation` remains distinct
and unchanged; Rogue/Scout do not automatically inherit it.

All four creation careers have three material-consuming
Scout alternate recipes (12 total), with rank-specific
yields of two, three and five existing tradeable crafting
materials, respectively. Every tier uses the actual
profession workstation, requires its authored crafting
profession level and actual bought Scout skill rank,
consumes the full ingredients, grants actual profession
XP and stays within the character's **one selected
creation career**. Higher tiers include genuine
materials produced by other professions. The selected
gathering slot is not modified or implicitly granted.

The authoritative `ProfessionService` checks the
character's owned skill/career/rank in the station
snapshot, before preparing a minigame **and again inside
the atomic inventory/profile mutation on completion**.
Revoking a previously purchased rank between preparation
and completion denies the output and preserves materials.
The station UI displays locked ranks instead of
offering an unauthorized craft button.

## Actual focused Studio execution

The final unpublished local Base focused execution of
`scripts/studio/c4_scout_ranked_crafting_focus.luau`
reported **5/5 PASS, 0 failed**, including:
- New `C4ScoutRankedCraftingTest`: **290 assertions**.
  Four isolated Human Rogue/Elf Ranger characters chose
  independent gathering and crafting careers; each
  purchased Reading and all three first-transfer creation
  ranks from its real skill authority. All 12 authored
  recipes were executed through real material inventory,
  preparation and atomic commit. Both premature-rank
  attempts and a revoked prepared rank-three craft were
  rejected. Rank-three revocation consumed no ingredients.
- Four genuine player-to-player marketplace escrow
  purchases transferred each career's produced material
  to another career and each received ingredient was
  consumed in a subsequent **real ranked recipe**.
  The test uses explicitly supplied disposable starting
  ingredients where it is not itself testing the original
  gathering or auction-house production sequence.
- Original C4 Scout source inventory: **1,150
  assertions PASS**; actual implemented 90/99 Human
  Rogue and 121/129 Elven Scout. The strict combined
  catalogue audit also passed.
- Existing starter-class C4 crafting and separate
  Smith/Alchemist market dependency suites passed
  without altering their accepted behavior.

Luau parse checks for changed core modules, source-audit
fixtures and the Studio runner passed. Disposable
Base and Dungeon Rojo builds passed.

## Actual two-client gameplay acceptance

`scripts/studio/c4_scout_ranked_crafting_two_client_live.luau`
ran an independent unpublished Base multiplayer session
with **two actual Studio clients**, real characters, real
profession selection panels and the actual existing
client-to-server profession crafting request remotes.

The Human Rogue selected Mining + Blacksmithing; the
Elf Ranger selected Herbalism + Alchemy. Both genuinely
purchased the level-20 Reading and creation ranks through
the authoritative skill service after selecting a
creation profession. An actual client request crafted
two iron bars through the real Blacksmithing station.
The Alchemist's client attempt to forge that rank-one
Blacksmithing recipe was rejected as
`ProfessionNotSelected`. The Smith listed one of
those bars in the real marketplace and the Alchemist
bought it. In this *disposable test session only*,
the Alchemist was given source level 28, 30 Alchemy
XP and two silverleaf to isolate the rank-two client
request rather than repeat previously accepted
gathering/XP tests. It purchased its real second
crafting skill rank, moved to the Alchemy station
and crafted three tempering oils through its actual
client remote, **consuming the Smith's purchased
iron bar**. The test returned:

`[C4 Scout Craft Live] VERIFIED_TWO_CLIENT_RANKED_TRADE_PASS`

This proves client-to-server station crafting, real
two-player market delivery, different careers and
material consumption at rank two. Ranks two and three
in all four professions were independently executed
in real server services via the focused Studio tests;
they have not each received their own human visual
review or separate two-client playthrough.

## Exact original C4 inventory and remaining scope

| Original source inventory | Implemented / raw | Remaining |
| --- | ---: | ---: |
| Four starting classes | 168 / 168 | 0 |
| Human Rogue (partial first transfer) | 90 / 99 | 9 |
| Elven Scout (partial first transfer) | 121 / 129 | 8 |
| **Six inventoried classes** | **379 / 396** | **17** |

The 17 pending ranks are ten Lockpicking ranks,
two Equipment Expertise, two Lung Capacity, two
Fall Resistance and the Human Rogue's Sprint.
The **seven other original first-advancement class
catalogues remain unmapped** and are not part of
those 17. **0/9** original first-advancement paths
are yet entirely complete.

The source-rank mapping represents functional
DungeonMMO analogues, not a claim that Lineage 2's
identical item catalogue, craft balance, loot ecology
or animations have all been reproduced. The higher
recipe yields and XP are provisional economy values
requiring future balance and market-volume checks.

All game-code, test and documentation edits were
made **directly through GitHub**. Desktop Commander
was used only for clean pull, parser/build, read-only
test diagnostics and disposable unpublished Studio
playtesting. No `main` merge, Roblox publishing,
production DataStore modification, destructive local
repository command or paid operation was performed.

**v1.85 focused 5/5 PASS. Two-client ranked trading
and crafting gameplay PASS. Full C4 catalogue INCOMPLETE.**
