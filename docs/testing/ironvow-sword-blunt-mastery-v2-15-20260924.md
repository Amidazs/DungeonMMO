# v2.15 — Warrior sword and blunt mastery, executed acceptance

Date: 24 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Verified source: `1584f8b0d3a6e7602e5c7735a9270736f287c05e`.

## Change and security scope

Retained the existing saved `IronvowBladeTraining` ID to avoid
breaking real owner ranks. It is now a genuine server-equipped
Sword **or** Blunt passive, purchased separately at source
levels 20/24/28/28 after authentic Human Warrior -> Ironvow
advancement. A real registered blunt item
(`stonewatch_training_mace`) can execute the melee hit path.
Neither an unequipped player, an unrelated Longbow/Dagger item,
a fabricated weapon tag nor an unawarded Fighter receives the
passive. Trainer learning no longer requires a sword to be worn.

## Focused and actual live tests

Fresh `base.project.json` and `default.project.json`
disposable Rojo compositions **PASS**, diff check clean,
on `1584f8b` with untracked quadruped animation caches untouched.

Unpublished Base `scripts/studio/c4_ironvow_quest_focus.luau`
in `0.740.0.7400927_20260924T101151Z_Studio_ACA2B_last.log`:
personal quest **31 assertions PASS**, genuine award/trainer/equip/
save **81 PASS**, forged-profile foundation **60 PASS**,
`VERIFIED_QUEST_AWARD_SKILLS_PASS`.

Unpublished full-Dungeon Play
`scripts/studio/c4_ironvow_sword_blunt_mastery_live.luau`
in `0.740.0.7400927_20260924T101229Z_Studio_DFB73_last.log`:
a real spawned player's server-owned melee damage was applied
to an actual NPC Humanoid, with 100 base damage:
Sword rank 0 = **110 HP**, sword rank 4 = **115.6 HP**;
Blunt rank 0 = **110 HP**, blunt rank 4 = **115.6 HP**.
Rank1/4 server bonus, unknown/unequipped/dagger and copied
Fighter denial assertions also passed. Markers
`ALL_REAL_FAMILY_HP_TESTS_PASS` and
`VERIFIED_PLAY_MODE_PASS` appear in this exact log.
The Play fixture uses internally valid synthetic earned class
and purchased rank snapshots, not a natural saved mouse-input
equipment/quest journey.

Separate strict level-30 audit in
`0.740.0.7400927_20260924T101314Z_Studio_1A402_last.log`:
**27 assertions PASS** and
`VERIFIED_SOURCE_RANK_AUDIT_PASS`, Warrior **31/62**
source training rows mapped with **31 missing**; Knight
**55/55** schedules mapped with mechanics release gate false.

## Remaining parity and security work

The per-rank 0.014 Roblox damage multiplier is **provisional**,
not C4's exact P.Atk. calculation, despite the matched class
training levels and sword-and-blunt weapon selection.
Full natural client click/equipment animations, live party
isolation, all boss/world-boss blocked-hit paths and full
cross-place saved progression remain open. Earlier actual
Marauder/Captain stacked shield block exploit fix and Knight
craft anti-duplication proof remain historically accepted;
this focused Warrior test is not evidence that every NPC
attack family is exploit-free.

No `main` merge, Roblox publication, production DataStore
mutation or changes to the parallel animation projects.
