# Chronicle 4 all-class character stats and skill fidelity target

Decision date: 24 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Scope: EVERY currently implemented original Human/Elf Fighter and Mystic
starter and first-transfer class, plus any older playable Rogue/Ranger
content. Apply the same source-target rule to future C4 classes.

## Owner decision — one shared C4 numerical ruleset

Preserve historical C4 **character growth and stats** together with
C4 **skills**, not just the number of skill ranks. Source the original
character creation stats (STR/DEX/CON/INT/WIT/MEN), class-and-level
HP/MP/CP, HP/MP regeneration, P.Atk/P.Def/M.Atk/M.Def,
speed/attack/cast speeds, weapon and armour conditions, crit/evasion,
experience thresholds, per-rank skill damage/heal/effect powers,
MP/HP costs, reuse, durations, passive modifiers, resistance,
stacking, party targeting, threat and status rules.

Do not use the current Roblox 100-base-HP, Vitality and Spirit
formulas or fixed threat percentages as the target values.
Do not take historical skill *power* as damage deducted from target
HP: preserve the original formula and both parties' stats. Keep
a permanent source URL, original C4 rank, units and verification
status with EVERY migrated row. Mark unknown historical formulae
unverified, not copied from a newer chronicle or arbitrarily
converted.

The existing custom block/parry/iframes, stamina, Roblox party
combat and instanced dungeon encounters can still have deliberately
different dynamics from the historical game. Preserve anti-exploit
damage floors and explicit ownership gates; test those additions
separately and record any departure from literal C4 behavior.
Matching original raw values alone does not guarantee identical
balance where these game rules differ.

## Currently coded baselines are not original C4 stats

- `AttributeConfig`: BASE_VALUE=5, base health=100,
  +5 HP per effective Vitality, base mana=100, custom soft-cap
  and per-second mana regeneration.
- `RaceDefinitions`: custom five-attribute race baselines and
  static MaxHealthMultiplier=1.08 for Human /0.92 for Elf.
  No authoritative original class-level HP or CON calculation.
- `CharacterCombatStats.max_health`: uses the custom Vitality
  and race multipliers, independent of character level and
  original Fighter/Mystic/first-transfer HP growth.
- `ProgressionConfig`: custom XP thresholds and growth curve;
  the project currently supports levels through 40 while
  the initial source skill audit is scoped through level 30.
- `ManaService` refreshes the custom per-second max/regen.
  Skill costs are partly stamina substitutes for original MP.

Do not silently replace these before every calling service,
profile migration, health/mana persistence and test fixture is
ready to change coherently. The current Warden 56/56 original
rank *schedule* is not 56/56 identical effect or stat parity.

## Example historical class HP data: verify C4 version before migration

The archival class-base-HP charts distinguish **base HP before
CON and gear** from the final displayed HP value. Recorded chart
samples include Human Fighter lv1=80, lv20=327; Human Warrior
lv30=670.50, Human Knight lv30=636.15, Human Rogue lv30=613.25;
Elven Fighter lv1=89, lv20=355, Elven Knight lv30=698.50,
Elven Scout lv30=675.60; Human Mystic lv1=101, lv20=424,
Elven Mystic lv1=104. These are **archival chart candidates,
not yet independently certified as a C4-specific datapack**.
Never place these class-base numbers directly into a user's
displayed HP without the original CON and modifier formula.

Source chart URLs:
- Human Fighter:
  https://home.achor.net/community/lineage2/info/formula/?cv=community&f=l2_formula&p=hfbhp
- Elven Fighter:
  https://home.achor.net/community/lineage2/info/formula/?cv=community&f=l2_formula&p=efbhp
- Human Mystic:
  https://home.achor.net/community/lineage2/info/formula/?cv=community&f=l2_formula&p=hmbhp
- Elven Mystic:
  https://ns.achor.net/community/lineage2/info/formula/?cv=community&f=l2_formula&p=embhp
- Formula and CON modifier:
  https://www.l2p.l2wh.org/link.hp

A contemporary class overview reports starting **displayed** HP
of Human Fighter 126, Human Mage 99, Elven Fighter 113 and
Elven Mage 96, distinct from the base-HP table values.
Period source: https://gathering.tweakers.net/forum/list_messages/907324///
Such figures may use differing character creation buffs and
stat/chronicle assumptions; check C4-era original character
tables before calling them exact in-game acceptance fixtures.

## Baseline migration order — applies to all classes, never Warden alone

1. Freeze a C4-specific, versioned full class/level reference
   for every Human/Elf Fighter and Mystic starter and the five
   authored first transfers through lv30. Review archival HP,
   MP, CP and six base attributes against a genuine C4
   datapack or contemporaneous game evidence. Extend through
   lv40 only once the source class growth tables are verified.
2. Implement one server-authoritative primary-stat and
   class/level progression provider that all seven implemented
   race/class paths share. Do not give all Fighters the same
   HP after their first transfer, or treat Mystic as Fighter.
   Include equipment, dyes, buffs and passive stat effects in
   the correct source order/units.
3. Integrate the provider with all MaxHealth/MaxMana/CP,
   regeneration, physical/magical defence, resistance,
   critical/accuracy, damage/healing, HUD, load/rejoin and
   progression paths. Preserve owner security and bounded
   anti-exploit physical block/dodge behavior.
4. Audit and apply ALL base Fighter/Mystic skills and each
   Human Rogue/Warrior/Knight and Elven Scout/Knight skill
   family through lv30, including rank-specific mana and
   passive stat values. Legacy playable classes are separately
   inventoried. Unverified damage power is not directly
   substituted for Roblox HP damage.
5. Run exact-source pure stat snapshots for each race/class
   at representative levels including 1, 19, 20, 24, 28,
   30, and zero/with equipment, buffs and CON changes; then
   whole-runtime migrations and genuine client combat tests.
   Record formula variance where stamina/block/dodge preserve
   DungeonMMO-specific controls.

The current v2.41 audit's 24 Warden source power/MP rows are
a starting subset of this all-class undertaking, not evidence
that any entire class's original skill effects are done.

NO production stat or damage tables were changed by this
requirements commit. No main merge or public Roblox publish.
