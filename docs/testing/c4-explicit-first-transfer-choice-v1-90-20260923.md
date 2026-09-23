# v1.90 — Original C4 first-transfer class choice, executed acceptance

Date: 23 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`

## Implemented gameplay and non-destructive migration

- Fresh Human/Elf characters continue to start exclusively as
  **Fighter or Mystic** (temporary internal family ID: `Mage`).
  Ranger/Rogue remain loadable as old-game class IDs, not selectable
  as fresh starting classes.
- The new **real Base** `C4FirstTransferSelectionService` resolves
  the player's selected race, genuine starting family, and exact original
  C4 source-class options. At **level 18**, a player explicitly chooses
  one branch from their own race/family. The server validates and
  persists `ClassAdvancement.OriginalFirstTransferChoiceId` inside a
  profile mutation. Wrong race, wrong starting family, forged ID,
  early level and overwriting an already selected branch are rejected.
- A new **closable C4 class-path window** uses the existing
  `ClassAdvancementRequest`, `ClassAdvancementSnapshot` and
  `ClassAdvancementResult` remotes. It shows the real race/family
  options, the original class name, original quest name, currently
  selected class and **honest pending-quest status**. Its server
  snapshot contains no unearned advanced class.
- The original branch choice survives actual profile
  save/release/reload. It does **not** grant a level-20 transfer,
  fake quest completion, advanced skill, profession, gold or loot.
  Class-specific original advancement quests and actual class-transfer
  grants are still to be implemented.
- The old `ClassAdvancementService` can no longer start an
  **automatic custom Vanguard/Arcanist/Thornwarden trial** for a
  Fighter/Mystic starter, with or without the new source choice.
  Its new-character snapshot no longer advertises an automatic
  legacy candidate. An already-started old trial is **claimable**
  under its existing original server objective/proficiency gates,
  and an already-completed historical old class remains persisted
  and replay-proof. No old quest/skill/item/profession is deleted.
  Old Ranger/Rogue specialist IDs remain loadable solely for migration;
  actual source branch transfer is not inferred from them.
- Version-14 profile migration now sanitizes a chosen original
  branch by current race, original Fighter/Mystic family and
  currently unadvanced class state, without overwriting old
  `CompletedByRace` records. An existing old active/completed
  advancement cannot be overwritten through the source-choice
  endpoint. A development-only race change is rejected after an
  original race-specific source path has been selected, including
  inside its atomic mutation, to avoid stranding a foreign class
  choice. Previously approved race changes without such a chosen
  original branch remain unaffected.

## Executed focused Studio acceptance

The final unpublished, locally built Base focused runner
`scripts/studio/c4_explicit_first_transfer_focus.luau`
returned **5/5 PASS, 0 failed**, including:

| Checked-in fixture | Verified assertions |
| --- | ---: |
| C4FirstTransferSelectionServiceTest | 46 |
| ClassAdvancementServiceTest (updated for original C4 and legacy claim) | 40 |
| C4FirstTransferBranchesTest | 144 |
| C4ClassPathRulesTest | 14 |
| C4CatalogueCoverageTest | 7 |
| **Total across five tests** | **251** |

The tests include wrong-race and cross-family choices, early level,
actual three independent Human/Elf choices, class choice idempotency,
saved/reloaded selection, no free class or reward, preserving an old
in-progress and completed quest, old class replay denial, and
development race-change protection. The source catalogue remains
**18 original first transfers, 2 partially mapped source skill lists,
16 unimplemented full original paths, 0/18 fully playable**.

Eleven changed/new Luau source files passed parser checks.
Disposable Base **and** Dungeon Rojo builds passed.

## Actual two-client Studio gameplay

The unpublished Base gameplay driver is
`scripts/studio/c4_explicit_first_transfer_two_client_live.luau`
with its full source-controlled
`src/ServerScriptService/Core/Tests/C4ChoiceTwoClientLiveDriver.luau`.
The short Studio entry point avoids command-line run-script source-size
limits; game scripts were edited **only through GitHub**, and temporary
live-test hooks existed only in the disposable Studio instance.

Two real Studio clients created **Human Fighter** characters through
the existing authentic character creation flow. In the disposable
test session, their levels were set to 18 via real server profile
mutations rather than replaying previously accepted leveling tests.

Both clients observed the **actual open C4 class-path UI and correct
race-specific choice card**, then issued normal client-to-server
class-selection requests. One chose **Human Rogue**; the other chose
**Human Knight**. The production server saved each distinct choice
but retained both characters as Fighters with no advanced class
or completed advancement quest. Attempts to start the old
automatic Vanguard trial, and to replace a previously chosen
class after the server committed it, were denied.

Actual Studio logs reported:

`[C4 Choice Live] TWO_REAL_CLIENTS_DIFFERENT_SOURCE_PATHS_PASS`

`[C4 Choice Live] ORIGINAL_PATH_AUTHORITY_AND_LEGACY_DENIAL_PASS`

`[C4 Choice Live] VERIFIED_TWO_CLIENT_ORIGINAL_C4_SELECTION_PASS`

**Limitations:** The playtest verified genuine client GUI visibility,
source-choice card presence and authenticated client remote requests.
A test LocalScript sent the class-choice request directly after
checking the UI card; this was not a manual mouse-click acceptance of
the card's interaction styling. Level 18 was test-seeded. The source
branch quests and physical branch-transfer quest gameplay remain
unimplemented and were not claimed as tested.

## Current source and release gates

This implements **original first-transfer branch selection**, not
an actual first-transfer *class award*. The previously mapped
**396/396** ranks cover only four Human/Elf starting-class
source lists plus the Human Rogue/Elven Scout source inventories.
They do not cover all 18 original first transfers.

The only currently playable starting races remain Human and Elf.
Full original C4 first-transfer completions remain **0/18**.
Next: implement historically sourced, branch-specific quest
definitions, genuine objective events and the atomic level-20
chosen-branch transfer, then expand the other original classes.

All code, tests, game scripts and documentation were edited
directly on the working GitHub branch. Desktop Commander was
used only for clean fast-forward pull, disposable Luau/Rojo
builds and unpublished real Studio tests. No `main` merge,
Roblox publishing, production DataStore mutation, forced
repository reset or paid operation took place.


## Post-interruption closeout: migration and actual-client checks

The first focused run after the interrupted message
returned **4/5**, because its old advanced-class fixture
failed the migration-protection assertion. This was
not treated as a pass. The fixture's historical
`CompletedByRace`/active-class state was corrected
through GitHub and re-executed with no local source
editing. The final clean-pull unpublished Base run
of `c4_explicit_first_transfer_focus.luau` returned
**8/8 PASS, 0 failed**. This included the five v1.90
fixtures above plus the directly affected
`ProfileMigrationQuestAdvancementV8Test`,
`ProfileMigrationRaceChangeV12Test`
(13 assertions) and `RaceChangeServiceTest`
(23 assertions). The original class-selection
fixture passed **46 assertions**, and the
old-class claim fixture passed **40**.
The seven newly parsed key sources plus affected
client/service/test files parsed successfully,
and both Base and Dungeon disposable Rojo
builds passed. Previously accepted unrelated
dungeon combat/wipe/revive suites were not repeated.

A further genuine unpublished **one-client Base
GUI playtest** using
`scripts/studio/c4_first_transfer_client_live.luau`
returned
`[C4 First Transfer Live] VERIFIED_REAL_CLIENT_CHOICE_PASS`.
A real client observed the actual original Human
Fighter three-option GUI, the server refused a
forged Elven Scout choice from that Human account,
and a genuine client remote selected Human Rogue.
The selected branch appeared in the actual client
UI; the real profile retained Fighter and its
original gold without granting an advanced class.
This test verified GUI rendering and actual
client-to-server remotes, not an automated
mouse-click on the visual card. Its coverage
supplements rather than replaces the earlier
genuine **two-client** selection playtest.

**Final v1.90 closeout: focused 8/8 PASS,
one-client GUI/remote PASS, earlier two-client
independent branch-selection PASS, original
branch quest/class award still not implemented.**
