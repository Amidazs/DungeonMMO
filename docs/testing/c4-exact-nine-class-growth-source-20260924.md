# Exact C4 nine-class template/growth evidence — v2.44

Pinned Chronicle 4 source:
`Neco-spain/l2jadmins_C4-Scions-of-Destiny`,
commit `07f8536384e799f128d44198dd7ab23519660eea`.

Primary files:
- `L2jAdmins_Data/data/xml/stats/charTemplates.xml`
- `L2jAdmins_Data/data/xml/stats/statBonus.xml`
- `FuncMaxHpAdd.java` / `FuncMaxHpMul.java`
- `FuncMaxMpAdd.java` / `FuncMaxMpMul.java`
- `FuncMaxCpAdd.java` / `FuncMaxCpMul.java`

Exact source template IDs mapped in DungeonMMO:
0 Human Fighter, 10 Human Mage, 18 Elf Fighter, 25 Elf Mage,
1 Warrior, 4 Knight, 7 Rogue, 19 Elf Knight, 22 Scout.

The source regression independently checks all six primary stats,
source IDs/base levels, representative raw HP/MP/CP values and
integer final maxima through level 30. It also rejects legacy
Ranger/Rogue identities, cross-race classes, first-transfer levels
below 20 and forged first-transfer labels.

This is a source-data/formula pass only. A passing test does not
mean live `Humanoid.MaxHealth`, ManaService, CP, damage, HUD,
items or skills already use the C4 engine.
