# C4 first-tier heal and Scout evasion backend — focused acceptance

Date: 22 September 2026
Working branch: `wip/phase-4-test-hud-integration-v1`
Scope: Human/Elf starting classes and previously mapped first-transfer
Rogue/Elven Scout rank families. This is NOT full Chronicle 4 parity.

## Actual new server-owned mechanics

- **Scout Evasion**: one source level-24 Ranger/Rogue passive rank
  increases chance to completely avoid an incoming direct enemy melee
  attack by 3%. A separate source level-28 *Running Evasion* rank adds
  another 2.5% only when the server's live Humanoid is actually
  moving and its WalkSpeed is positive. Both ranks require the
  character's genuine Human/Elf Scout-analogue class and purchased
  skill state. Normal physical mitigation, wards and NPC contribution
  callbacks remain unchanged when a hit is not evaded. No free
  avoidance is granted against magic, area attacks or PvP; evaded
  attacks deal zero HP damage and trigger no contribution callback.
  The RNG-driven actual avoidance path is wired in DamageService,
  but the focused test validates its authoritative chance and gates,
  **not** a statistically reliable live-player dodge-rate sample.
- **Mystic Battle Heal**: three source level-14 ranks for Human and
  Elven starting Mages. Bought rank 3 of MysticHealingPrayer is
  required first; subsequent purchased ranks require actual skill
  proficiency 55/125. The authenticated spell uses the real
  MageHeal executor, heals a genuine selected injured friendly
  player, and consumes mana/cooldown. It is a DungeonMMO functional
  analogue, not a claim that original C4 heal timing, power or
  party mechanics are numerically identical.
- **Human Mystic Life Drain**: two source level-14 ranks, with
  bought rank 2 of MysticWindBolt as prerequisite and earned
  proficiency 65 for rank 2. The real magic projectile must deal
  positive health damage to a legitimate hostile NPC before
  MageHealService credits the still-authenticated original caster
  with 20%/30% of that damage as healing. Dead/removed/replaced
  casters cannot gain health from a stale projectile. Elven Mages
  cannot buy or use this Human-only spell.

No NPC dodge, Life Drain or heal effect is awarded merely by
inserting skill names in the catalogue. Every newly mapped rank
has a class/race/level-owned backend effect.

## Exact six-class source coverage after this increment

| Original C4 source class | Mapped analogue ranks | Source total | Still missing |
| --- | ---: | ---: | ---: |
| Human Fighter | 36 | 39 | 3 |
| Elven Fighter | 41 | 43 | 2 |
| Human Mystic | 36 | 44 | 8 |
| Elven Mystic | 34 | 42 | 8 |
| Human Rogue | 77 | 99 | 22 |
| Elven Scout | 104 | 129 | 25 |
| **Six-class total** | **328** | **396** | **68** |

The real base-class audit is `C4BaseImplementationAudit.audit`:
147/168 mapped, 21 still missing. The Scout first-transfer audit
is `C4ScoutSkillInventory.audit`: 181/228 mapped, 47 missing.

**Seven other original Human/Elf first-transfer source-class
catalogues are still NOT enumerated or implemented. Zero of the
nine first-transfer source classes are functionally complete.**
These seven class inventories are not included in the 396-rank
denominator. Orc/Dwarf and later advancement class catalogues
also cannot be represented as complete by these six sources.

## Studio tests observed on this code increment

- Scout passive authority: **286 assertions PASS**, including
  race/class/level-gated 3% standing versus 5.5% moving chance.
- First-transfer Scout source audit: **1,070 assertions PASS**,
  Human 77/99 and Elf 104/129 with actual missing-family ledgers.
- Battle Heal level/prerequisite/mana/real executor:
  **28 assertions PASS**.
- Human Life Drain rank/prerequisite/race/actual effect definition:
  **11 assertions PASS**.
- Actual SkillProgressionService purchases through isolated
  in-memory profiles, progression-earned rank upgrades, denial
  for an Elven Life Drain purchase, saved profile release/reload:
  **37 assertions PASS**.
- Final base source audit: **57 assertions PASS**, printing each
  remaining unmapped Fighter/Mystic source family.
- Unified C4 completion gate: **7 assertions PASS**,
  `Base=147/168, Scout=181/228, class paths=0/9,
  unmapped=7, overall complete=false`.
- Both unpublished Base and Dungeon Rojo builds succeeded.
- Disposable real Dungeon Studio Play client using the existing
  actual SkillsMenu and CombatInputActions hotbar passed **16
  skill cases**, including Battle Heal increasing the real player
  Humanoid's HP and a Life Drain projectile that damaged an NPC
  and returned exactly 20% of the actual damage as caster healing.
  The live fixture printed
  `LIFE_DRAIN_REAL_DAMAGE_HEAL_PASS`,
  `MysticBattleHeal REAL_CLIENT_EFFECT_PASS`,
  `ALL_SIXTEEN_C4_SKILL_EFFECTS_PASS` and
  `VERIFIED_PLAY_MODE_PASS`.

Receipts are local disposable TEMP logs, not user Library files:
`%TEMP%\DungeonMMO_C4_EvasionPassives.log`;
`%TEMP%\DungeonMMO_C4_EvasionInventory.log`;
`%TEMP%\DungeonMMO_C4_LifeDrainRank_Closeout.log`;
`%TEMP%\DungeonMMO_C4_BaseAudit_Closeout.log`;
`%TEMP%\DungeonMMO_C4_Catalogue_Closeout.log`;
`%TEMP%\DungeonMMO_C4_HealingTrainer_Current.log`;
`%TEMP%\DungeonMMO_C4_Live16_Closeout.log`.

The Play-client progression snapshot was intentionally synthetic;
real saved-player trainer UI, ordinary physical input, multiple
live party clients and cloud/published multiplayer have not been
tested. The separate Phase2A paid-revive automatic failure has
not been rechecked or resolved by this focused source work.

## Still open — do not mark the original request complete

Basic Human Fighter: CommonItemCreation, RecipeReading,
SittingRecovery (one each). Basic Elf Fighter: the former two.
Human Mystic: CommonItemCreation 1, CurePoison 1, PartyHeal 3,
PhysicalAttackDebuff 1, PoisonCurse 1, RecipeReading 1.
Elf Mystic: AttackSpeedDebuff 1, CommonItemCreation 1,
CurePoison 1, PartyHeal 3, PhysicalAttackDebuff 1,
RecipeReading 1. Scout's exact remaining 22/25 family names
are printed by the source-inventory focused test.

Build genuine crafting/recipe/stance/cleanse/party heal/status,
conditional skill and exploration executors rather than padding
rank metadata. Then source-map and implement the distinct
Human Warrior/Knight/Wizard/Cleric and Elven Knight/Wizard/Oracle
first-transfer paths; integrate class-quest and real trainer
authorization across the actual saved-character UI.

All scripts, tests and documents were changed through GitHub.
Remote Desktop was used only for fast-forward pull, disposable
TEMP Rojo builds, unpublished Studio tests and diagnostic logs.
No merge to `main`, Roblox publish, real DataStore mutation,
paid operation, force push or old dungeon wipe/revive test loop.
