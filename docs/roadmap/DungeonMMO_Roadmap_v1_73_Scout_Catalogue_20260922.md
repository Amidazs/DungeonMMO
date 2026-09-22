# DungeonMMO roadmap v1.73 — C4 Scout catalogue continuation

Date: 22 September 2026
Working branch: `wip/phase-4-test-hud-integration-v1`

## Completed focused backend gate

[Full source/implementation audit and Studio receipts](../testing/c4-scout-source-catalogue-2026-09-22.md)

- [x] Complete **source-row inventory** for C4 Human Rogue and
  Elven Scout first-transfer levels 20/24/28/32/36, retaining
  all family names, race-dependent levels and counts.
- [x] Split shared C4 bow/dagger rows across DungeonMMO's separate
  Ranger/Rogue owners without falsely double-counting source ranks.
- [x] Actual 15-rank Ranger and Rogue attack ladders, dagger-specific
  Rogue bleeding, 33 extra weapon/armour passives, Elf-only 15-rank
  self-heal and 15-rank per-NPC threat reduction, bow range and
  arrow-speed passives; prior focused combat and rank tests passed.
- [x] Human critical power ranks at 24/32, Human/Elf critical-rate
  ranks at their distinct source levels 28/32, and both Scout class
  movement passives at level 28; actual physical critical-hit damage,
  critical chance and server Humanoid speed are changed by purchases.
- [x] Source audit counts: Human **74/99 functional analogues,
  25 missing**; Elf **102/129 functional analogues, 27 missing**.
  Missing family names and counts are surfaced by `MissingFamilies`
  and tested; do not mark this catalogue complete while nonzero.
- [x] Unpublished Studio focused tests: 241 passive assertions;
  1065 source/functional inventory assertions; 38 trainer and
  save/reload assertions; actual Play client authenticated eight
  skill effects, light armour, human critical damage and Scout
  movement speed.

## Still open — C4 catalogue completion criteria

- [ ] Human Rogue: 25 source rank entries across 14 remaining
  families (including continuous-MP critical/accuracy toggles,
  lockpicking/keys, common item creation, environmental/underwater
  and fall abilities, and real evasion and recovery mechanics).
- [ ] Elven Scout: 27 source rank entries across 17 remaining
  families (including continuous-MP toggles, lockpicking, crafting,
  environmental/underwater, buff/debuff cleansing, movement control,
  actual evasion and recovery). See the linked audit for exact names.
- [ ] Reconcile previous Fighter/Mage source brackets (historical
  read-only audit mismatched 13 of 16), and source-map/build later
  specialisations and class branches with distinct race ownership.
  First-transfer Scout totals alone cannot certify whole-game C4.
- [ ] Build genuine server executors for each missing effect, with
  correct class/race/level/mastery/SP/equipment gates. Do not pad
  volume with inert rank entries or claim exact Chronicle 4 costs,
  physics, class trees or balance for original DungeonMMO analogues.
- [ ] Integrate the actual persisted-player trainer GUI and normal
  physical input; run focused real-client acceptance, then one
  broad regression at a milestone. The separate Phase2A paid-revive
  auto-test remains an unresolved release blocker.
- [ ] No `main` merge, Roblox cloud publishing, paid purchases,
  live DataStore edits, unrelated asset worktree changes or
  repeated historical dungeon wipe/aggro/revive/replay loops.

## Next implementation order

Prioritize common backend mechanics that can be reused without
copying skills or generating placeholder content: continuous-mana
toggle lifecycle, actual guarded-hit evasion and movement/recovery
conditions, server-owned poison/bleed cleanse and buff/debuff
modifiers. Then add environment/crafting/lock/key capabilities
against genuine world interaction objects, with focused receipts.

Maintain `docs/ai/HANDOFF.md`, `CURRENT_STATE.md` and
`TEST_MATRIX.md` from GitHub. Remote Desktop is authorized
for **read-only inspection and local testing**: fast-forward
pull, disposable TEMP Rojo builds, unpublished Studio play
and logs. All document/script edits belong in GitHub only.

**Overall C4 catalogue status: INCOMPLETE.**
