# v2.17 — independently purchased Warrior polearm area skill

Date: 24 September 2026. Branch:
`wip/phase-4-test-hud-integration-v1`.
Tested source head: `e944ebb039d96f521aebf1dd7f463b6648bb169b`.

## Verified level-30 source scope

Historical C4 Warrior Wild Sweep has nine original ranks in
the 20/24/28 training bands, three per band; source power
90/97/105, 123/132/143 and 165/177/191. MP costs are
22/22/22, 23/24/25 and 27/29/30. Reference:
https://l2hub.info/c4/classes/warrior
The C4 patch notes describe a 20-target PvE cap for
player area attacks including Wild Sweep:
https://lineage2wiki.com/c4/patch-notes/

DungeonMMO uses the original player-facing name **Crescent Sweep**,
stable original skill ID `IronvowCrescentSweep`. This is a
distinct combat skill, NOT a renamed regular polearm basic hit.
An actually quest-awarded Human Ironvow owner must separately
purchase source ranks from their own trainer, learn polearm
mastery first and equip a genuine server-registered two-handed
polearm. The active combat definition costs source MP on cast,
0 stamina, preserves source rank power as `SOURCE_POWER`
and uses a **provisional** 0.15 × original skill power Roblox
HP adapter (13.5 through 28.65 damage before actual attributes).
Its cone is 125 degrees and 7 studs with independent maximum
20 NPCs, even if basic polearm normal-hit cap is 5/10.
Server acquisition disallows repeated damage to a target across
all four hitbox samples. Stun is 0 for this source skill.

## What was actually executed

Safe fast-forward from GitHub into pre-existing HUD worktree;
untracked parallel animation Python caches left untouched.
Fresh unpublished `base.project.json` and
`default.project.json` Rojo compositions **PASS**.
Local disposable full-Dungeon Studio source test
`scripts/studio/c4_ironvow_crescent_sweep_focus.luau`
in `0.740.0.7400927_20260924T103907Z_Studio_40789_last.log`:
**46 genuine Humanoid HP assertions PASS**. Distinct rank1
and rank9 definitions both hit exactly 20 of 22 physically
spawned tagged NPCs once, excluding the two over cap.
Marker `VERIFIED_REAL_NPC_AREA_PASS` printed.
This fixture has an independent real server hit/damage
callback but uses a scripted attacker, not user mouse input.

Fresh unpublished Base test
`scripts/studio/c4_ironvow_quest_focus.luau` in
`0.740.0.7400927_20260924T103949Z_Studio_128DD_last.log`:
Quest **31**, genuine Award/Trainer/Reload **118**,
Foundation/Source numeric/forgery **96** assertions PASS.
Strict level-30 audit in
`0.740.0.7400927_20260924T103949Z_Studio_1EFA9_last.log`:
**27 assertions PASS**, Warrior **44/62 rank rows mapped,
18 missing**, Knight **55/55 scheduled**, neither
release-certified.

## Still open

Normal human client skill-button→server MP spending and
all active skill animation/telegraph chains are not
proven by the scripted-attacker fixture; neither is
end-to-end natural quest/progression save across places.
Roblox skill damage scaling, cooldown and 7-stud cone
are explicit provisional adaptations rather than C4's
original P.Atk formula/timing/balance. All other NPC
boss/world-boss blocked-hit exploit paths are pending,
and the Warrior's remaining distinct BluntControl and
non-attack skill source families require actual server
implementations and appropriate tests.

No `main` merge, Roblox publishing or production saves.
