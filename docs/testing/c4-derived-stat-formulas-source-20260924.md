# C4 derived-stat formula evidence — v2.45

Pinned C4 source commit:
`Neco-spain/l2jadmins_C4-Scions-of-Destiny@07f85363`.

Source files used include `statBonus.xml`,
`L2Character.getLevelMod()`, FuncPAtkMod, FuncPDefMod,
FuncMAtkMod, FuncMDefMod, FuncPAtkSpeed, FuncMAtkSpeed,
FuncMoveSpeed, FuncAtkCritical, FuncAtkAccuracy and FuncAtkEvasion.

The test deliberately labels outputs as naked/unbuffed source stats.
Equipment and skills are not silently folded in. Representative
level-30 source vectors include Human Fighter naked PAtk5/PDef95,
MAtk5/MDef62, attack speed330, cast speed213, run126; Human Mystic
PAtk2/PDef64, MAtk12/MDef72, attack speed303, cast speed333.
These small naked attack numbers are expected because weapon/item
stats are a separate C4 calculator layer.

A passing test certifies that the source formula transcription
matches its selected vectors. It is not yet a live Roblox migration
or proof that current skills use C4 damage.
