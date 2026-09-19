# Phase 4 — placeholder physical layout integration checkpoint

Date: 19 September 2026
Branch: `wip/phase-4-event-secret-policy-v1`
Gameplay/test implementation through `e3b3022eb1819cc07949babfc6bb7b72ad4eea77`;
combat regression startup test fixes through `37cef9b6a497afa0d9e7ab787835aaccf9916aab`.

**Status: isolated unpublished Studio placeholder-playability checkpoint passed,
NOT production physical/content release.**

## Implemented

- `DungeonPlaceholderPlayableLayouts.luau` supplies a TEMP-only physical
  layout overlay for both TestDungeon/Temple and AbandonedMine at Depth1–4.
  Depth1 exposes EventArena and SecretArena slot bindings only under the
  separate explicit optional-play opt-in. Depth2, Depth3, Depth4 have
  respectively 4, 5, 6 rooms, matching existing encounter sequences.
  Depth4 slot 2/4/5 houses earlier-depth bosses as minibosses, slot 6
  the final boss.
- `DungeonPlaceholderPhysicalContent.luau` places checkpoint, trigger,
  enemy spawn and boss spawn anchors on the corresponding solid preview
  floors when requested explicitly in a TEMP Studio place. Existing
  profession auxiliary checkpoint anchors are preserved for the higher
  depths. The first room entrance was corrected to stand on its floor.
- The overlay is available only when RunService:IsStudio(), PlaceId=0,
  GameId=0, synthetic environment mode, and both placeholder physical
  content and placeholder playable opt-ins are true. Ordinary builds
  still use `DungeonRuntimeContentCatalog`; it registers Depth1 only.
  Shared `RuntimeReleaseEnabled` for Depth2–4 and both
  `OptionalBossRuntimeEnabled` switches remain false.
- The standalone `content/placeholder/DungeonMMO_PhysicalBlockouts_v1.rbxlx`
  is a separately editable *geometry-only* scene, not a game place with
  live runtime bindings. The live test fixtures use the source builder
  for anchors and playable geometry, not that standalone scene file.

## Live TEMP Studio evidence

On the source through `e3b3022`:

- `phase4_placeholder_depth_full_progression.luau` completed
  TestDungeon Depth2 (4 rooms), Depth3 (5), Depth4 (6);
  AbandonedMine Depth2 (4), Depth3 (5), Depth4 (6).
  Each run activated actual room triggers, spawned the bound combat
  pack or boss, cleared every encounter, and reached run completion.
  Depth4 printed and checked all three distinct returning miniboss IDs
  in both dungeons.
- `phase4_placeholder_{temple,mine}_event_secret_{fight,skip}.luau`
  passed four separate physically bound Depth1 optional-boss cases:
  each dungeon fought its Secret boss or skipped it via the successor,
  while the Event boss stayed required.
- `phase4_placeholder_{temple,mine}_walk_live.luau` passed both physical
  navigation cases. Humanoids walked on the connected Temple/Mine floors
  and side bridges to all five encounter triggers without per-room
  player CFrame teleport. All encountered paths were completed.

Six full-depth result logs:
`20260919T194624Z_Studio_196EF_last.log`,
`20260919T194742Z_Studio_72A42_last.log`,
`20260919T194815Z_Studio_1412A_last.log`,
`20260919T194850Z_Studio_00935_last.log`,
`20260919T194934Z_Studio_B9161_last.log`,
`20260919T195009Z_Studio_75BBF_last.log`.
The four optional cases are in Studio logs
`20260919T195157Z_Studio_7A6E4_last.log`,
`20260919T195242Z_Studio_5287A_last.log`,
`20260919T195306Z_Studio_E3FFC_last.log`,
`20260919T195327Z_Studio_B765E_last.log`.
Temple/Mine walking result logs:
`20260919T195518Z_Studio_412CC_last.log` and
`20260919T195610Z_Studio_E6AC6_last.log`.

**Assistance/limitations:** the high-depth progression fixtures increased
player HP, used MoveTo and explicitly defeated spawned enemies. The
optional-path fixture also assisted combat. These passes establish
server encounter, physical anchor, route and checkpoint wiring;
they do **not** establish unassisted player combat, normal difficulty,
finished models, fully authored high-depth content, art presentation,
or publish readiness.

## Final regression after combat test timing fix

On `e3b3022` four Rojo compositions built, 549 source files and 30
Studio runner files compiled, and 11/11 optional-boss focused Studio
edit-mode suites passed. A fresh Base live regression passed with
107 test markers and zero Creator errors.

Two fresh Dungeon baseline runs initially reached
`VERIFIED_PLAY_MODE_PASS` but each intermittently failed unrelated
existing combat smoke tests which allowed only 2 seconds to spawn
TrainingDummy and 5 seconds for a Studio player. The test-only waits
were extended to 25 seconds, preserving their original assertions
and fail-on-absence behaviour; no production combat was modified.
A fresh Dungeon live run on `37cef9b` passed both tests, the
Dungeon live baseline, 221 test-pass markers and **zero Creator errors**.
Its evidence log is
`20260919T201449Z_Studio_166F8_last.log`.
The previously failing attempts must not be described as clean runs.

## Release boundary and next gates

No main merge, Roblox TEST/PROD publish or DataStore mutation was performed.
Physical higher depths and optional bosses are still disabled in normal
gameplay and require real authored replacement content, non-assisted
fight/balance tests, player-facing content and release acceptance
before activation. Do not promote TEMP fixture flags or debug kills
into released code. A separately authorised TEST place would be
needed for production-like cross-place or genuine same-user reconnect.
