# Phase 4 Base race/class selection regression and fix — 20 September 2026

**Scope:** Isolated HUD + TEST-placeholder integration branch `wip/phase-4-test-hud-integration-v1`. The original backend and visual-UI branches, the tagged previous combined candidate and all current Roblox cloud places were left unchanged. No character profile, race, DataStore, live place version or other player data was edited by this QA.

## Cause and changes

The original `IdentitySelection.client.luau` called `show_race_selection()` and `show_class_selection()` on **every** incoming progression snapshot even when `Identity.CreationStage` had not changed. Those functions clear and recreate the cards, resetting `selected_race` / `selected_class` and the pending selection feedback. A snapshot arriving between a player clicking a card and confirming it could silently discard the choice. Commit `72deb046bc543a385f0baad68f8f3a2aaca3023d` keeps existing cards/selection through redundant same-stage snapshots but still rebuilds on an actual stage change.

The restored `LegacyUiPolish.client.luau` also styled the mandatory full-screen `IdentitySelectionUi` and its buttons, overriding the picker’s authored selected-card appearance. Commit `d5b10f2d5a8fd702a447483221b10ea9920965d4` excludes this one mandatory picker from generic restyling. Other HUD windows remain styled. Neither change alters authoritative race validation or permanent race/class profiles.

## Focused local Studio test

`scripts/studio/phase4_base_race_selection_snapshot_live_probe.luau` runs only in an unpublished local **Base** Studio Play DataModel, and applies synthetic client-local progression snapshots without sending any race-choice request, modifying profile data or publishing the place.

The first attempt to use `PlayerGui:GetGuiObjectsAtPosition` failed because it returned an **empty array** in headless Studio Play, not because it identified another ScreenGui covering the picker. The fixture now reports that limitation rather than claiming an occlusion. It is **not a physical mouse-click test**; actual card clicking must still be checked manually.

Corrected run: `20260920T075916Z_Studio_3C93F_last.log`. `HITTEST_NOT_AVAILABLE_IN_HEADLESS_PLAY 0`; RACE_CARDS_SURVIVE_SNAPSHOT_REFRESH_PASS; CLASS_CARDS_SURVIVE_SNAPSHOT_REFRESH_PASS; MANDATORY_PICKER_CLOSES_ON_COMPLETE_PASS; LIVE_CLIENT_REGRESSION_PASS; VERIFIED_PLAY_MODE_PASS; **zero Creator errors**.

## Post-fix regression

At source commit `562f82af361e79b4e5f918b7893f8c438a2e1a6e`:

- Rojo builds PASS: `base.project.json`, `default.project.json`, `test-temple-publish.project.json`, `test-lobby-sync.project.json`. The lobby-sync build must **not** be published as a standalone lobby replacement.
- Luau compilation PASS: 559 source files and 45 Studio test runners, zero failures.
- Base ordinary Play regression PASS: 107 pass markers, zero Creator errors, log `20260920T080017Z_Studio_B6E9A_last.log`.
- Base restored HUD Play regression PASS: 107 pass markers, zero Creator errors, log `20260920T080045Z_Studio_1921B_last.log`.
- Dungeon ordinary Play regression PASS: 221 pass markers, zero Creator errors, log `20260920T080140Z_Studio_C703C_last.log`.
- Exact TEST Temple restored-HUD composition PASS, zero Creator errors, log `20260920T080205Z_Studio_7ADE5_last.log`.
- TEST Lobby sync-only restored-HUD composition PASS, zero Creator errors, log `20260920T080219Z_Studio_554B6_last.log`.

The user still needs to try selecting Human/Elf and confirming race/class by actually clicking in an interactive Studio session. The local automated fixture does not synthesize physical mouse input, and no cloud TEST publish has been performed in this session. Before any publish, save and verify the **current cloud place’s** rollback copy and confirm exact target ID. Do not treat a Git source tag as a cloud place or DataStore backup.
