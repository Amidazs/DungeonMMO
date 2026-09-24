# DungeonMMO backend v2.35 — Warden client bleed recovery

Date: 24 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Candidate: `0fd05cbe7961fb2d4d1efd0daec200c41b492c9c`.
Previous: [v2.34](DungeonMMO_Roadmap_v2_34_Greenward_Studio_Acceptance_20260924.md).

## New unpublished client Play acceptance

The Warden's separately purchased level-24 Bleed Recovery is now
verified against a real Roblox Play avatar and genuine hotbar/client
input. A disposable tagged Captain model inflicted actual hostile HP
damage using the server DamageService, after which the server-only
`PlayerBleedStatusService.apply_from_captain` callback was invoked
from the isolated test driver. Its real timed bleed affected the
same player; the real client then cast its purchased Warden cure.
The server accepted the skill, spent mana, cleared the original
server-only bleed and observed no later bleed damage over 3.5 seconds.
A copied replicated bleed attribute could not mint a curable status.
The cure produced no MageHealPulse. The test **does not** wait for
natural Captain AI to land its slash, and the purchased character
is deliberately seeded only in the disposable fixture.

The first Play test at `8f3ffccd` **FAILED** because its assertion
forbade all positive HP change during the cast, including unrelated
regeneration. At `0fd05cbe`, it checks the authoritative heal pulse
and listens for actual subsequent HP loss instead. The final
`VERIFIED_PLAY_MODE_PASS` and
`REAL_CLIENT_CURE_NO_LATE_TICK_PASS` were observed in
`%TEMP%\\DungeonMMO_v240_bleed_play\\bleed.log`.
See [v2.35 test evidence](../testing/greenward-warden-v2-35-player-bleed-live-20260924.md).

## Current scope

The prior Warden trainer/skill/crafting, source quest, world registration
and actual shield/guard chip-damage Play results are retained from
[v2.34](DungeonMMO_Roadmap_v2_34_Greenward_Studio_Acceptance_20260924.md).
All **56/56 Elven Knight historical training-rank schedules** remain
mapped, but exact C4 formula/effect parity is not certified. Complete
mechanical and release acceptance across the original 18 first-transfer
paths is still **0/18**.

OPEN: naturally attacking Captain's bleed, genuine player-driven
stage-three/five quest enemy kills and owner-bound drops, physical NPC
turn-ins and mentor/trainer UI, persistent Base/Dungeon/Base rejoin
journey, other classes' source audits and precise party aura behavior.
A separate automatic `SkillMasteryGatesTest` emitted a failure in the
full Play log: its older Human Fighter fixture expects legacy custom
trial mastery checks while production now requires original C4 branch
choice first. Do not classify the entire background test suite as
green or change original C4 production gates to appease that fixture.

No main merge, Roblox publish, production DataStore mutation,
local permanent script edits, or unrelated animation worktree changes.
