# v2.16 — real Warrior polearm, source ranks and anti-shield abuse

Date: 24 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Last actually focused-tested code commit:
`a4512b956a28c6fe983361e33137225a98eb6819`

## Source contract

C4 reference:
https://l2hub.info/c4/skills/216-polearm-mastery%3A4/classes
https://l2hub.info/c4/skills/216-polearm-mastery%3A20/levels

Source Warrior has Polearm Mastery four ranks through launch
at levels **20 / 24 / 28 / 28**. Their recorded C4
flat P.Atk values are **+4.5 / +7.3 / +8.9 / +10.7**
and the passive adds **five** polearm hit targets.
DungeonMMO's distinct saved ID `IronvowPolearmTraining`
preserves this ordering and source data. It uses a
**provisional source-P.Atk × 0.001 additive Roblox physical
multiplier**; this is NOT the original C4 P.Atk/damage
formula and cannot be claimed to reproduce C4 balance.
The registered two-handed `ironroot_training_halberd`
has its own Polearm category/tag and explicit OffHand reservation.

## Focused and real NPC HP tests — PASS

- Fresh `base.project.json` and `default.project.json`
  disposable unpublished Rojo builds PASS; diff check clear;
  no edits to canonical place or animation worktrees.
- Genuine first-transfer Warrior quest/award/equipment
  on freshly pulled `831484c`:
  `0.740.0.7400927_20260924T102018Z_Studio_CF9C0_last.log`.
  Quest **31**, Award **93**, Foundation **73** assertions PASS;
  four source-rank purchases/registered polearm equip,
  forged-class rank and extra-target denial.
- Actual twelve-tagged-NPC world-health/cap suite on
  `0ce99dc`:
  `0.740.0.7400927_20260924T102317Z_Studio_0A52B_last.log`.
  `[Warrior Polearm Hit Cap] PASS: 26 actual NPC HP assertions`;
  one swing with no source mastery damages **at most and
  exactly five** real tagged Humanoids, and with earned
  +five source target privilege damages **exactly ten**;
  repeated sampling/body parts never duplicate hits.
  This test supplies the source-authored 5/10 cap directly
  to `MeleeHitService`, while the actual server combat
  dispatcher uses the authenticated profile passive to
  select that same cap.
- Genuine spawned-player plus real training NPC HP Play,
  code commit `982040664a92c82abd2432de7caea4882d26b3a6`:
  `0.740.0.7400927_20260924T102618Z_Studio_6F5AF_last.log`.
  100-base hit with real polearm: untrained **110 HP**,
  four purchased ranks **111.07 HP**; rank one/four
  bonus and owner five-extra-target privilege verified.
  Sword, blunt, dagger, no weapon and forged Fighter
  cannot get extra targets or polearm power; explicit
  `ALL_REAL_OWNER_NPC_HP_CHECKS_PASS` and
  `VERIFIED_PLAY_MODE_PASS`. Uses internally valid
  synthetic quest/rank snapshots in Play, not a naturally
  saved end-to-end quest/equip/click journey.
- Additional two-handed gear abuse check in real
  `EquipmentService`: BOTH polearm-first then shield,
  and shield-first then polearm, are rejected. Removing
  the shield permits legal polearm equip. Verified on final
  source `a4512b9` in
  `0.740.0.7400927_20260924T102837Z_Studio_5C033_last.log`:
  Quest **31**, Award **99**, Foundation **73** assertions PASS,
  with `VERIFIED_QUEST_AWARD_SKILLS_PASS`.
- Independent level-30 source audit on polearm feature
  source `9820406`:
  `0.740.0.7400927_20260924T102701Z_Studio_829D0_last.log`:
  **27 assertions PASS**, Warrior **35/62** source
  training rows mapped, **27 still missing**, Knight
  **55/55**, no release/complete C4 mechanical certification.
  The later `a4512b9` changes only focused equip-test code,
  not the underlying source map.

## Unverified scope and exploit caveats

The target-cone cap suite uses twelve real constructed world
NPCs, but not a full user-controlled multiplayer polearm
sweep with ten naturally spawned monsters. Its separate
player/NPC HP test uses actual server damage but synthetic
owned rank/equipment snapshots. Do not claim complete
client click/equip, actual final Tool visuals/animation,
cross-place save/rejoin or exact C4 damage/accuracy balance.

Previously fixed Marauder/Captain held-shield HP immunity
and guard-break abuse remain regression-covered in v2.12,
but **boss/world-boss/event attack paths and mixed-class
PvP/group-stacking have not been broadly certified**.
Actual polearm+shield cannot be simultaneously equipped
in either equip order. This does not prove absence of all
combat exploits.

Desktop Commander reported **87% monthly usage** at
this checkpoint; avoid repeated broad Studio tests and
preserve remaining credits for focused blockers and
natural multiplayer acceptance. No main merge, public
Roblox publish, production DataStore or parallel
animation-worktree changes occurred.
