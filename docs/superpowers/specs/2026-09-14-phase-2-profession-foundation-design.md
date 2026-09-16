# Phase 2 Profession Foundation Design

**Project:** DungeonMMO
**Date:** 14 September 2026
**Status:** APPROVED autonomous design direction; implementation candidate until fresh Studio visual/runtime evidence
**Baseline:** `c7fe89ebda3c97634c97e89ad12e52ec23983ae9`
**Canonical roadmap:** DungeonMMO Roadmap v1.34

## 1. Purpose

The Profession Foundation completes the first two Phase 2 profession supply chains without opening the wider player economy. It proves that a player can deliberately gather useful materials, advance gathering/crafting professions, turn those materials into an equippable upgrade, use a stronger cross-profession recipe, and carry that persistent result through the accepted Base -> Temple -> Base loop.

The complete pairs are:

- Mining -> Blacksmithing;
- Herbalism -> Alchemy.

Every creation input used in this gate has a deliberate gathering route. Vendor-only materials, auction house, player trading and random-drop-only profession progression remain outside this gate.

## 2. Locked supply-chain content

### Mining + Blacksmithing

Mining gathers `iron_ore` from authored-world-adjacent ore outcrops. Blacksmithing uses:

1. `smelt_iron_bar`: 2 Iron Ore -> 1 Iron Bar;
2. `forge_ironbound_gloves`: 3 Iron Bars -> 1 Ironbound Gloves;
3. `temper_ironbound_gloves`: Ironbound Gloves + Iron Bar + Tempering Oil -> Tempered Ironbound Gloves.

Ironbound Gloves are the self-sufficient basic upgrade. Tempered Ironbound Gloves are the stronger connected recipe.

### Herbalism + Alchemy

Herbalism gathers `silverleaf` from deliberate herb patches. Alchemy uses:

- `distill_tempering_oil`: 3 Silverleaf -> 1 Tempering Oil.

Tempering Oil is a useful reagent because the stronger Blacksmithing recipe consumes it. This proves cross-profession demand without making basic Blacksmithing progress dependent on another profession.

## 3. Profession progression

The persistent profile becomes schema v6 and adds exactly four profession states under the active character:

- Mining;
- Blacksmithing;
- Herbalism;
- Alchemy.

Each state stores `Level` and `XP`. Foundation maximum level is 5. XP needed to advance from levels 1-4 is 30, 60, 100 and 150 respectively. Level is server-owned and recalculated/sanitized from valid progression mutations.

Foundation XP awards:

- Base gather: 8 XP;
- Temple gather: 12 XP;
- smelt Iron Bar: 10 Blacksmithing XP;
- forge Ironbound Gloves: 20 Blacksmithing XP;
- distill Tempering Oil: 20 Alchemy XP;
- temper Ironbound Gloves: 30 Blacksmithing XP.

The Tempered Ironbound Gloves recipe requires Blacksmithing level 2. Three Iron Bar smelts provide the 30 XP needed for level 2, so the first meaningful recipe progression occurs naturally while gathering enough ore for the basic gloves.

Recipes are level-derived in this gate. Rare blueprint ownership is not stored yet; that remains a later content/system gate.

## 4. Items and equipment

New stackable profession items:

- `iron_ore` - Material;
- `iron_bar` - Material;
- `silverleaf` - Material;
- `tempering_oil` - Material/Reagent.

New equipment:

- `ironbound_gloves`: Gloves, available to Fighter/Mage/Ranger, +5 flat MaxHealth;
- `tempered_ironbound_gloves`: Gloves, available to Fighter/Mage/Ranger, +6 flat MaxHealth and +2% CriticalChance.

The accepted EquipmentService remains authoritative for equipping. Crafting only creates inventory items; it never silently equips crafted gear.

## 5. Gathering authority and anti-exploit rules

Gathering is activated by server-owned ProximityPrompts. The client never supplies item IDs, quantities or XP values.

Each node definition owns:

- profession ID;
- output item ID;
- quantity;
- profession XP;
- per-player cooldown;
- placement relative to an accepted semantic environment anchor.

Base nodes use a 4-second personal cooldown. Temple nodes use a 20-second personal cooldown and yield two materials plus 12 XP. Cooldown is keyed by user + stable node ID, so one player gathering does not disable a node for the whole server.

## 6. World placement

No new authored environment contract is required. Profession presentation is derived from already accepted semantic anchors.

Base:

- Blacksmithing station prompt at `Base.Profession.BlacksmithingPlaceholder`;
- Alchemy station presentation/prompt at `Base.Profession.AlchemyPlaceholder`;
- Iron Outcrop placed near the Blacksmithing anchor;
- Silverleaf Patch placed near the Alchemy anchor.

Temple:

- Rich Iron Vein placed relative to `Temple.Room1.Checkpoint`;
- Ancient Silverleaf Patch placed relative to `Temple.Room2.Checkpoint`.

The runtime-created meshes/parts are functional prototype presentation only and must not replace the accepted lobby or Temple art.

## 7. Crafting authority

Crafting requests are server-authoritative and transactional through the existing ProfileService mutation boundary.

A request succeeds only when:

- the player has a loaded profile;
- the recipe ID exists;
- the recipe belongs to the station currently near the player;
- the relevant profession level meets the recipe requirement;
- all required inventory quantities exist;
- the output item definition exists.

Inputs are prevalidated, then consumed and output granted within one profile mutation. A rejected request cannot partially consume ingredients.

## 8. Client presentation

A functional profession client UI is available in both compositions but only opens at Base crafting stations.

The panel shows:

- station/profession name;
- current profession level and XP progress;
- known/locked recipes;
- ingredient owned/required counts;
- output name;
- Craft button;
- compact server-result status.

Gathering and crafting send compact profession toasts showing item gain and XP/level changes. Final UI art, icons, sound and animation are deferred.

## 9. Persistence and Dungeon compatibility

Profession state and profession inventory use the same profile lease/save/handoff contract as accepted progression/equipment.

Gathering in Temple mutates the authoritative leased profile and therefore survives return to Base. Crafted equipment selected in Base remains subject to the accepted run-lock rule: an active Dungeon run keeps the Equipment snapshot with which it entered; newly crafted/equipped gear only affects a later run.

## 10. Source-side Temple portal cleanup

The previously observed under-floor Candidate Temple portal was caused by relying on the imported Portal model pivot. The published Authored TEST Base was manually corrected and accepted.

The source Candidate path will be made deterministic by allowing a candidate selector to resolve against the visible bounding box of a landmark. `Base.TemplePortal` uses Portal_02 visible bounds at approximately 55% of portal height instead of the imported model pivot. This prevents future Candidate rebuilds from recreating the under-floor interaction while leaving published Authored anchors unchanged.

## 11. Explicit exclusions

This gate does not add:

- Leatherworking, Enchanting, Engineering, Tailoring, Cooking or other profession families;
- vendors as a substitute for gathering;
- auction house/player market/trading;
- rare blueprint acquisition;
- gathering tools or durability;
- random affixes or enhancement;
- profession quests;
- guild crafting progression;
- permanent world depletion;
- PROD publish or monetisation.

## 12. Acceptance boundary

Automated/code acceptance requires:

1. schema-v5 -> schema-v6 migration preserves all accepted state and creates four valid profession states;
2. profession definitions, recipe definitions and item definitions pass contract tests;
3. gathering rejects unknown nodes and awards only server-defined quantities/XP;
4. personal cooldown prevents rapid repeated gather without blocking another user;
5. crafting fails atomically for missing materials, wrong level, unknown recipe and wrong station;
6. three Iron Bar crafts unlock Blacksmithing level 2 and the tempered recipe;
7. basic gloves are craftable without Alchemy while tempered gloves require Tempering Oil;
8. crafted gloves are eligible through accepted EquipmentService for Fighter, Mage and Ranger;
9. Base and Dungeon Rojo compositions build cleanly and accepted regression tests remain present.

The project owner is only required for the final visual/runtime gate:

- profession nodes/stations are sensibly placed and readable in the accepted Base/Temple art;
- prompts and panel feel understandable;
- gather -> craft -> equip works visibly;
- a Temple gather persists on return;
- no profession presentation damages accepted environment collision/art.

Until that fresh Studio gate is observed, this remains an implementation candidate.

## 13. Approved inventory presentation and crafting-minigame extension (15 September 2026)

The first Base visual gate proved that profession gathering/crafting works, but also exposed a presentation defect: the legacy Profile HUD inventory preview renders only the first five inventory rows. Studio's accepted equipment test kit can fill those rows before newly gathered/crafted profession items, so valid persistent outputs can appear to be missing even though ProfessionService has granted them correctly.

The profession candidate therefore replaces that truncated preview with a full shared Inventory panel:

- the panel consumes the existing authoritative `InventorySnapshot` rather than creating a second inventory state;
- all owned item types are shown in a scrolling list with readable names, quantities, rarity/category metadata and stable grouping;
- duplicate stacks are aggregated for display only; persistent inventory structure remains unchanged;
- the panel is available in both Base and Dungeon and can request a fresh profile snapshot so it cannot miss an early server push;
- Equipment remains a separate Base service for equipping/unequipping; Inventory is ownership/read-only presentation.

Every creation profession is also required to declare a stable crafting-minigame identity. For this foundation:

- Blacksmithing -> `BlacksmithingForge`;
- Alchemy -> `AlchemyBrewing`.

The authoritative crafting service is split into a non-mutating `prepare_craft` eligibility phase and an atomic `complete_craft` commit phase. A future minigame runs between those boundaries. Completion revalidates profession level, materials and equipped ingredients inside the final profile mutation before consuming inputs or granting output/XP. The current foundation runtime deliberately supplies a server-owned auto-success outcome so gameplay remains testable before either minigame is designed; no client result can directly grant items.

The later profession-minigame gate will design the actual interaction, timing/scoring and how quality affects outcomes. This foundation does not invent those mechanics early.

## 14. Approved personal dungeon gathering refinement (15 September 2026)

The Temple gathering visual gate adds three locked behaviours.

First, every dungeon resource node is single-use **per player, per dungeon run**. A successful gather immediately removes that node from that player's local presentation, while other party members retain their own independent gather. The authoritative claim is stored on the member's dungeon-session record, not in client state, so reconnecting to the same recoverable run restores the same depleted-node set. Repeated requests for a claimed node fail closed. If the profile/inventory mutation fails after a provisional claim, the server rolls that claim back so a transient failure cannot permanently deprive the player of the resource.

Second, rooms may contain multiple independent resource nodes. The Temple foundation now deliberately exercises multiple nodes in both Room 1 and Room 2, including both floor and reachable-wall placement. Dungeon nodes are not spawned from an unchecked static CFrame: the runtime raycasts against actual world geometry and only creates a node after a valid surface hit. The presentation origin is moved slightly behind the hit plane so ore/herbs are visibly embedded rather than floating or merely resting on top. Wall probes include floor fallbacks; if no valid surface is found the node is skipped rather than spawned in empty space. Prototype resource parts remain non-colliding and non-queryable, so they cannot block combat/navigation or become false surfaces for later nodes.

Third, profession progression copy must never be confused with character-level XP. Recipe rows and gather/craft result toasts use explicit labels such as `+8 Mining XP` and `+12 Blacksmithing XP`, while station progression uses the phrase `Profession XP`. Character-level XP in the normal HUD remains unchanged.

Base teaching nodes remain personal to the current Base visit. The reconnect-safe per-run claim contract is specifically required for Dungeon gathering.

## Accepted Temple resource distribution refinement (2026-09-15)

Temple gathering remains personal and single-use per player per run, but resource presentation must also read as room exploration rather than a clustered pickup pile. Each gathering room therefore has a placement group with a minimum 18-stud separation between successfully resolved resource hit positions. Primary probe origins are intentionally spread across different sides/quadrants of the room and each node keeps multiple real-surface fallbacks. The existing embedding requirement remains unchanged: a node only appears after a valid floor/wall/rock raycast and is moved slightly into the hit surface. If a valid, sufficiently separated surface cannot be found, that node is skipped rather than spawned floating or tightly clustered.
