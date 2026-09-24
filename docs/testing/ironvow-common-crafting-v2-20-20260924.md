# v2.20 — original Warrior common creation, actual material-backed service

Date: 24 September 2026. Branch:
`wip/phase-4-test-hud-integration-v1`.
Final focused test source head:
`c0589e5a062e86fe4e29161877ce35d57429367e`.

## Mechanic and original source scope

Historical C4 Warrior Common Item Creation source rank2
at level20 and rank3 at level28, already holding the
starter recipe/creation ranks. The original C4 learned
them automatically at its levels; DungeonMMO deliberately
uses independently purchased advanced class ranks
`IronvowCommonItemCreation` (1 at20, 2 at28) and
one chosen gathering + one chosen creation career,
per the agreed WoW-style trading economy.

This source ability does NOT create goods, a profession
or additional profession slots on learning. Eight
independently material-backed recipes, two each in
Blacksmithing, Leatherworking, Alchemy and Enchanting,
check the selected actual profession and paid owner
rank before **and within** the authoritative atomic
craft completion. Actual Blacksmithing first rank
makes a real usable two-handed `ironroot_training_halberd`,
second rank makes a real `ironroot_d_grade_armor`
whose equip remains gated by the *separate* paid
`IronvowEquipmentExpertise` level20 rank.
The other careers make normal tradeable materials from
other professions rather than granting every skill.
Refer to C4 class source:
https://l2hub.info/c4/classes/warrior

## Exact executed evidence

Safe fast-forward on the original WIP HUD branch,
parallel animation caches untouched. Fresh disposable
unpublished Base/Dungeon Rojo builds and diff check
PASS at `6fb4ba70f6fa691d7865611ccb54d3e00fb72994`.
Real isolated Quest/Award/Foundation tests at this
commit log
`0.740.0.7400927_20260924T105955Z_Studio_C3BE3_last.log`:
**31/174/131 assertions PASS**, with source rank audit
**27 PASS** in
`0.740.0.7400927_20260924T105955Z_Studio_28495_last.log`.
Warrior 56/62 rank schedules mapped, six remaining;
Knight 55/55 mapped (not release-certified).

Added additional server atomic regression at
`c0589e5a062e86fe4e29161877ce35d57429367e`.
In
`0.740.0.7400927_20260924T110124Z_Studio_43E13_last.log`
earned Warrior Quest/Award/Foundation
**31/182/131 assertions PASS**. A previously
prepared paid rank2 recipe cannot commit after its
source rank is revoked: the exact inputs are
not consumed, the output not duplicated; the
rank is restored only inside the disposable fixture.
Actual inventory recipe outputs, paid trainer ranks,
correct crafting career, save/reload and unawarded
skill denial were exercised through real server
services, not an icon-only audit.

## Still not established

Focused blacksmith transaction acceptance proves
both actual rank tiers. The other three professions
have authored/material-backed registrations and
server authority but not independent full item
consumption tests in this v2.20 fixture (the earlier
v2.14 Knight branch did test all four).
Real player UI clicking actual gathering nodes,
natural saved Base/Dungeon/Base flow, original
C4 economy and all cross-class boss/world-boss
block stacking remain open. No main merge,
Roblox publish, production DataStores or unrelated
animation work.
