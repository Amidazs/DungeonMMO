# v2.19 — actual Warrior D-grade item and paid original expertise

Branch: `wip/phase-4-test-hud-integration-v1`
Date: 24 September 2026. Verified candidate
`e39cf350c652b29414eef8756cc311c754486a63`.

## What changed

A genuinely first-transfer-awarded Human Warrior at level20
may separately purchase `IronvowEquipmentExpertise` from
its own trainer, granting permission to equip a physically
owned server-registered `ironroot_d_grade_armor` Body
item. The rank does NOT create armour or borrow Knight's
rank/gear. Actual `EquipmentRules` checks correct Grade D,
rank1, level20+ and the genuine character's own awarded
class. Equipping provides real +20 MaxHealthFlat, not a
cosmetic icon; a forged class or level19 copied skill is
inert. The functional item's final model/appearance
is deferred by the existing backend-only art scope.

## Actual focused proof

Fresh safe fast-forward on the HUD integration worktree,
untracked parallel animation caches preserved. Disposable
`base.project.json` and `default.project.json` Rojo
builds and `git diff --check` PASS at `e39cf350`.

Unpublished Base
`scripts/studio/c4_ironvow_quest_focus.luau` in
`0.740.0.7400927_20260924T105422Z_Studio_AB403_last.log`:
**31 quest / 144 award / 125 foundation assertions PASS**.
Actual in-memory ProfileService/InventoryService/
EquipmentService first rejects equipped owned D-grade
without the skill, then pays the real awarded class
trainer, equips actual owned item, applies +20 max-HP
equipment modifier, denies copied/underlevel ranks,
saves and reopens the real test owner profile with
both gear and rank intact.

Separate `c4_level30_launch_coverage_focus.luau` in
`0.740.0.7400927_20260924T105422Z_Studio_FEAC7_last.log`:
**27 assertions PASS**, Warrior **54/62** original
rank schedules mapped, eight utility rows missing.
Knight **55/55** mapped training schedules. These are
rank schedules, not complete original C4 gameplay parity.

## Not yet established

A natural real-client quest/trainer/equipment UI
journey ending in persistent cross-place rejoin, full
original C4 gear tier/stat/economy parity, all boss/
world-boss defensive stacking and multiplayer exploit
checks. No main merge, Roblox publication, production
save writes or unrelated animation work.
