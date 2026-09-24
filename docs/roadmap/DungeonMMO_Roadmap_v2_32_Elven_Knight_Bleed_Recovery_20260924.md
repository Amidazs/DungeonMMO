# DungeonMMO backend v2.32 — Greenward Warden player bleed recovery

Date: 24 September 2026. Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v2.31](DungeonMMO_Roadmap_v2_31_Elven_Knight_Common_Creation_20260924.md).

## Last rank schedule now authored

`GreenwardWardenBleedRecovery` is the Elven Knight's separate
level-24, personally purchased and race/class/mentor-gated skill.
It spends genuine mana with a cooldown only when the owner's
real player character has a server-tracked curable bleed. It cannot
heal HP, cure poison, target a different player or clear a copied
client-written status attribute.

A new `PlayerBleedStatusService` owns a non-stacking, bounded,
three-tick bleed on the actual connected, world-spawned player.
Only the real tagged `DungeonMarauderCaptain` controller's
unblocked `CaptainSlash`, after a verified positive HP hit
and matching dungeon encounter, can start it. A parry, dodge,
blocked hit, absorbed hit, detached avatar, dead character and
wrong encounter cannot mint the effect. Delayed ticks use the
server DamageService, only for the original living avatar.
A genuine Warden cleanse invalidates earlier timers, so no old
tick can reapply harm after cure or respawn.

## Audit and acceptance

All **56/56 Elven Knight historical training-rank schedules are now
mapped**; no more missing level-20/24/28 source rows. Source
inventories recorded 5/18, all-rank-schedule paths mapped 5/18,
and **0/18** original first-transfer classes are certified for
complete C4 mechanical equivalence and release. Roblox formulae,
Charm and aura targeting, actual physical quest monsters,
cross-place save/rejoin, and real client boss/bleed/cleanse Play
are still OPEN.

The focused source-rank tests expect 56/56 and the isolated
trainer test now buys the level-24 recovery. These assertions
are not yet Studio-executed; a Rojo package build alone is not
a source test or genuine combat Play. A targeted real-client
Captain Slash and no-free-cure/no-late-bleed acceptance is
needed before claiming the new status effect complete.

No main merge, public publish, production DataStore mutations
or separate animation-worktree edits. GitHub-only source/doc edits.
