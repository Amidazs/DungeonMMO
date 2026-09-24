# DungeonMMO v2.51 — pinned C4 equipment stats across nine paths

Date: 25 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v2.50](
DungeonMMO_Roadmap_v2_50_C4_Nine_Class_Unified_Stat_Source_20260925.md).

## Original source item IDs rather than guessed Roblox gear bonuses

New `C4SourceItemReference` pins a deliberately small verified
selection of **nine C4 item IDs** from the same source commit as
the original nine class templates: short sword (1), club (4),
apprentice wand (6), dagger (10), short bow (13), light
leather shirt (22), heavy piece-bone chest (25), apprentice
robe tunic (425) and round shield (102). Exact original SQL
weapon/armour types, item slots and individual XML stat values
are recorded in a **read-only** reference. These historical IDs
are not current DungeonMMO inventory item IDs; no original
equipment or bonus is granted to a live character.

The new `C4EquippedStatReference` stages source weapon sets at
the original 0x08 order, original equipped chest P.Def at
0x10, the correct Fighter-versus-Mystic paperdoll chest
deduction and original level factor at 0x20, and source
STR/INT/DEX weapon multipliers. Robe's 0x60 MP grant runs
after passive operations. Short bow prohibits an offhand
shield, wrong-slot/unrecognised source item IDs fail closed,
and a round shield has its own defence rate/power and
-8 evasion rather than being treated as extra P.Def.

`C4UnifiedStatReference.get_with_source_items` now uses
the previously verified nine-class HP/MP/CP and passive
reference, but admits original gear only through this
trusted source-item resolver. Combined original item
stats and permitted source passive ranks are applied in
their source order across ALL four Human/Elf starter
and five first-transfer paths; no cross-class passive
or higher-level rank is silently granted.

A disposable unpublished Base/Dungeon Rojo build PASS and
focused Base Studio test
`C4OriginalItemStatReferenceTest` PASS **46 assertions**
for nine individual class HP profiles, pinned item
arithmetic, Mage versus Fighter chest, physical weapon
stats, Scout Bow+Light passive, Knight Heavy+Shield,
wrong item ID/slot/two-handed/offhand and foreign rank
denials. [Evidence](
../testing/c4-nine-class-pinned-equipment-source-v2-51-20260925.md).

## Important remaining gaps before live C4 switch

Nine **reference equipment items** are NOT a complete C4
item database. Live creative sword, heavy/light/robe,
two-handed inventory IDs still have unrelated custom
damage percentages; no verified original item linkage
or full head/legs/hands/feet/jewellery/set/enchantments
has been integrated. This limited source-only calculator
does not simulate active skills or complete CP, regen,
formulas and HUD/profiles. It is not the live Humanoid
MaxHealth/Mana/CP, or exact final C4 gear/effect parity.

Next: complete the original item catalogue/class grade
eligibility and creative-to-original item IDs, and the
remaining 22 explicit source skill tree gaps (including
nine Scout Elemental Heal ranks). Then migrate ALL nine
classes through one server-authoritative HP/MP/CP,
equipment/skill formula, persistence and HUD switch,
with prior anti-exploit regressions retained. Keep
exact original source values separate from game-specific
blocking/stamina/dodge adaptations and test their effects.

No main merge, public place publish, production DataStore
changes or unrelated art/animation work. Permanent edits
to script, test, roadmap and handoff occurred in GitHub;
local PC used only to fast-forward, build disposable places
and run focused unpublished Studio testing.
