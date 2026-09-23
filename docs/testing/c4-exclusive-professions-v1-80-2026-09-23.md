# C4 exclusive-profession backend and Studio playtest evidence

Date: 23 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Pre-documentation live-play commit:
`115539a1f89b9b8569b696fb2228356fd278ec4a`

## Scope and safety

All gameplay code and test scripts were edited and committed **through
GitHub only**. The local desktop was used exclusively to check an
unchanged worktree, fast-forward pull, build temporary unpublished
`.rbxlx` compositions, parse source and run disposable Studio
tests. No local source or roadmap edit, `main` merge, publish,
paid operation or production DataStore mutation occurred.

## Directly executed Studio evidence

1. Disposable Base and Dungeon Rojo builds succeeded at the
   original new-skill candidate. Twelve changed Luau sources passed
   `luau-compile --only-parse`.
2. The first **actual Studio** focused run of
   `scripts/studio/profession_exclusive_focus_tests.luau`
   had **10/12** passing fixtures. Two source-rank audit assertions
   were stale: they did not include the three actual v1.78 Mystic
   hostile weakening source ranks. The source audit itself was
   not weakened or changed to manufacture parity.
3. The read-only `scripts/studio/c4_source_rank_diagnostic.luau`
   printed the real current inventory: Human Fighter 39/39,
   Elf Fighter 43/43, Human Mage 41/44, Elf Mage 39/42.
   The **only remaining basic-class source family** is
   `PartyHeal`: three Human Mystic and three Elven Mystic ranks.
4. Updated test expectations and reran the actual Studio fixture:
   **12/12 passed, 0 failed**, including actual in-memory market
   escrow/purchases between two and four different character
   professions, profile reload, blueprint literacy, four real
   common-item recipes, restricted trainer purchase and strict C4
   source coverage. `C4ProfessionCraftSkillsTest` passed
   **96 assertions**; the base source test passed **27 assertions**.
   C4 source audit: **351/396** ranks represented across the six
   inventoried classes; **45** ranks still unimplemented there.
   This is not the complete original first-transfer catalogue.
5. The disposable **real two-client Base playtest** used
   `scripts/studio/profession_exclusive_two_client_live.luau`
   with `StudioTestService:ExecuteMultiplayerTestAsync(2,...)`,
   actual spawned player characters, actual StarterPlayerScripts
   profession UI and real client->server remote requests.
   The Studio runner returned:
   `[C4 Profession Playtest] VERIFIED_TWO_CLIENT_PLAY_PASS`.
   The script's passing condition proves both clients' selection
   panels opened before choice and closed afterwards, that a
   Miner/Blacksmith's real client craft produced exactly one iron
   bar, that the Herbalist/Alchemist's forged Blacksmithing request
   was denied with `ProfessionNotSelected`, and that the existing
   live Base market escrow/buy transferred the genuine smith bar
   into the alchemist character's inventory.
   This is automated multiplayer **gameplay**, not a manual
   visual/art review or a published-server test.
6. The desktop local worktree remained clean and synchronized with
   the working branch after the two-client result.

## Shipped first-tier skill effects

- `C4RecipeReading`, one bought level-one source rank shared by
  Human/Elf Fighter and Mystic. It must be purchased at a legitimate
  class trainer *after* choosing exactly one creation profession;
  only the selected profession's blueprint is readable.
- `C4CommonItemCreation`, one bought source rank at level five,
  requiring purchased `C4RecipeReading`. Every authored
  material-backed alternate recipe requires its actual selected
  profession, the bought passive, valid inventory and its real
  station; the server repeats validation in the atomic craft
  mutation. Four alternatives use Blacksmithing, Alchemy,
  Leatherworking and Enchanting. Common creation is not free
  material creation or permission to work in every profession.
- The station UI uses the server's per-recipe unlocked status and
  refuses to display a clickable button for a missing C4 skill.
- Already learned pre-migration blueprints remain in character
  knowledge. Reading a **new** blueprint requires the actual C4
  purchased rank and its independently selected creation career.

## Remaining validation and scope

- A human-led art/UX review of the profession panel and stations is
  still optional; automated UI state and client remote checks passed.
- Existing `scripts/studio/profession_two_client_live.luau` is a
  **legacy unrestricted-career fixture** and must not be used as
  v1.80 acceptance. The new
  `profession_exclusive_two_client_live.luau` supersedes it.
- The prior v1.78 Mystic enemy-weakening *physical combat* live
  acceptance remains open; these profession runs did not test it.
- Six basic-class `PartyHeal` ranks, 39 Human Rogue/Elven Scout
  ranks and seven entirely unmapped original C4 first-transfer
  class catalogues remain for separate future implementation.

**v1.80 focused profession backend: PASS. Automated two-client
unpublished playtest: PASS. Complete original C4 catalogue: NO.**
