# C4 Resource Regen + Armor Sets v2.66 — Acceptance

Date: 25 September 2026.  
Branch: `wip/phase-4-test-hud-integration-v1`.

## Commit tested

`b610d05cbe6cc950b37f3cedc06c19eb96de0d17`.

## Fresh builds

- Base Rojo build: PASS;
- Dungeon Rojo build: PASS.

Evidence directory:

`%TEMP%\DungeonMMO_v266_body_legs_focus`

## Focused Studio

Base retry: **12/12 PASS**.  
Dungeon: **13/13 PASS**.

## New regeneration acceptance

`C4ResourceRegenSourceTest` passes **17 assertions** covering:

- exact level-30 Human Fighter HP/CP base regen arithmetic;
- exact level-30 MP integer-band arithmetic;
- Sitting 1.5 / Standing 1.1 / Walking 1 / Running 0.7;
- three-second source period;
- level-10 HP/CP half-point branch;
- level-10 MP zero-band addition;
- invalid movement fail-closed;
- Fast HP Recovery +1.1 source HP regen;
- Relax +5 source HP regen;
- Mana Recovery x1.2 only with complete Magic chest+legs;
- Apprentice Tunic alone does not satisfy Magic armor;
- Tunic + Stockings adds both deferred MP operations;
- pinned source commit/default rate metadata.

## New paperdoll acceptance

`C4CreativeItemSourceMapTest` passes **69 assertions** and confirms all eight
creative Body items resolve to their reviewed C4 Chest+Legs set.

`C4SixSlotPaperdollSourceTest` passes **14 assertions** and locks:

- Leather Pants 29 = P.Def 27;
- Piece Bone Gaiters 32 = P.Def 39;
- Brigandine Gaiters 2378 = D-grade P.Def 64;
- Manticore Skin Gaiters 417 = D-grade XML P.Def 51;
- Apprentice's Stockings 461 = P.Def 10 and deferred MaxMP +10;
- Human Fighter level-30 reviewed gradeless set P.Def = 180;
- Human Mystic level-30 reviewed apprentice set P.Def = 92;
- complete apprentice set deferred MaxMP = +29;
- exact source Expertise threshold behaviour remains intact.

## Migration result

The authenticated boundary now explicitly requires
`OriginalBodyLegSemanticsReady=true` before inventory migration is ready.

Clean reviewed launch characters still have zero source prerequisite blockers,
but no live resource cutover is enabled.

No place was published and no production save was modified.
