# DungeonMMO backend v2.10 — C4 reference fidelity / Knight drain

Date: 24 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Continues [v2.09](DungeonMMO_Roadmap_v2_09_Knight_Steadfast_Stance_20260924.md).
[Executed v2.10 test evidence](
../testing/oathguard-umbral-siphon-v2-10-20260924.md).

## Binding game-design direction

Use the **original Chronicle 4** class and advancement paths as the
reference for intended release skills up to level 30. Keep distinct
source skill families: do **not** substitute another ability with a
similar label, do not credit an unimplemented effect as completed
just because it has matching purchase rows, and do not merge
race/class-specific ranks. Copy verified numerical *game rules*
where their quantities and meanings are known, and adapt visuals,
names, stories, NPCs and assets independently for DungeonMMO.

**Important:** Using C4's numbers does not automatically carry across
C4's actual balance to Roblox. Attack/defence formulas, physical
movement, attack cadence, skill casting, enemy HP, progression/SP,
economy and PvP differ. Distinguish:
(1) historical source inventory and rank levels;
(2) actually purchasable DungeonMMO rows;
(3) correctly implemented source mechanics and costs;
(4) live full-session verification; and
(5) playtested balance within DungeonMMO. Only (1–4) can be established
by current source audits and isolated Studio tests. Do not claim (5)
without representative multi-class, multi-level encounters.

Authoritative reference:
https://l2hub.info/c4/classes/knight
and rank details:
https://l2hub.info/c4/skills/70-drain-energy%3A2/levels

## Implementation completed in this increment

- [x] Separate Knight `OathguardUmbralSiphon` with **7**
  individually bought ranks at **20/20, 24/24, 28/28/28**.
- [x] Source reference power **20, 22, 24, 26, 28, 29, 31**,
  MP **12, 13, 14, 15, 15, 17, 17**, **20% of actual dealt
  enemy damage returned as owner's HP**. No positive damage,
  no health return. No wand prerequisite for Knight.
- [x] Own earned Human Fighter → Oathguard quest/class/trainer
  ownership required. Tests deny forged class and premature
  higher-bracket purchases.
- [x] Fresh disposable Base/Dungeon builds PASS; focused
  quest/foundation **88/84 PASS**, launch audit **27 PASS**;
  actual client hotbar, NPC damage and owner heal at ranks 1/7
  **PASS**, mana spent and wrong-class rejection **PASS**.
  See precise process logs in linked test evidence.
- [ ] The existing global magical-damage executor still scales
  source power as *flat damage times a Roblox magic multiplier*.
  Do not claim the exact source damage formula, animation or
  game-wide balance is identical until a separately verified,
  maintainable conversion and representative encounter tests exist.

## Level-30 mapping: training rows only

| Original branch | Recorded C4 rows | Trainer-mapped rows | Still unmapped |
|---|---:|---:|---:|
| Human Rogue → Ashenblade | 59 | 59 | 0 |
| Elf Scout → Greenward Scout | 77 | 77 | 0 |
| Human Warrior → Ironvow | 62 | 27 | 35 |
| Human Knight → Oathguard | 54 | 45 | 9 |

The **nine** missing Knight rows are source equipment expertise
(1), common-item crafting (2), **sword AND blunt** mastery (4),
Ultimate Defence analogue (1) and a specific bow-defence buff (1).
Do not mark sword/blunt mastery as present with a sword-only passive;
the actual registered blunt weapon, both weapon tags and attack
executor must work. Universal crafting cannot bypass the agreed
one gathering + one crafting profession limit.

## C4 discrepancies in earlier DungeonMMO skill candidates

The previous mapped rows are not all fully C4-equivalent:
- C4 Knight's level-20 **Majesty** strengthens physical defence
  **7%**, reduces evasion by **2**, costs **10 MP** and lasts
  approximately **5 minutes**. Current
  `OathguardSteadfastStance` is a **10%, ten-second, 14-stamina**
  physical-only guard with no evasion penalty. Correct this
  mismatch before certifying the family, retaining the one
  separately purchased level-20 row.
- C4 **Ultimate Defense** is a **separate** level-20 ability,
  greatly improves **physical AND magical** defence and prevents
  movement. Current physical-only guard is not a substitute.
- The C4 Knight's late **Heal** ranks have reference
  healing powers **143/150/157** and MP costs **75/79/83**.
  Current `OathguardMendingOath` 30/37/44 HP at 15 MP is an
  adapted spell; its seven late-drain ranks must not count as
  this heal. Reconcile source combat formulas, available mana
  and timing before claiming exact source healing efficacy.
- C4 **Shield Mastery** improves shield defence, not simply flat
  damage reduction in every hostile melee/area hit.
  C4 **Shield Stun** provides crowd-control immunity interaction
  while stunned. The current general mitigation/short stagger
  still require distinct parity checks.
- C4 **Magic Resistance** improves magic defence rather than
  directly subtracting fixed damage percentage. The current
  `OathguardRunicResistance` has an authentic actual game
  effect, but not the exact original magic-defence formula.

These items remain *mechanic-fidelity tasks even when rank mapping
shows all rows present*. Details:
https://l2hub.info/c4/classes/knight
https://l2hub.info/c4/skills/82-majesty%3A1/levels
https://l2hub.info/c4/skills/110-ultimate-defence%3A1/enchanting-1

## Next steps

1. Fix the C4 mechanics of existing skills **before** marking a
   complete Knight skill catalogue or moving on from it. Begin with
   Majesty's defence/evasion tradeoff, then separate immobile dual
   defence, bow defence, real sword/blunt mastery and crafting.
2. Source-audit and implement Warrior's remaining 35
   genuinely distinct rows, then all other original C4
   advancement branches and starter levels 1–19.
3. Live actual saves, party-owner isolation, cooldown denial,
   full Base → Dungeon → Base and multiple-class performance
   remain unverified for this latest spell.

No `main` merge, Roblox publish, production DataStore mutation
or changes to humanoid/quadruped animation roadmaps. All permanent
script/docs changes through GitHub; desktop is for fast-forward
pull, disposable builds, unpublished Studio playtests and logs.
