# DungeonMMO backend v2.36 — Greenward Warden physical quest acceptance

Date: 24 September 2026. Branch: `wip/phase-4-test-hud-integration-v1`.
Latest executed source head: `b752df98f084b8ce6fbf25a04e011c5f098e0c3d`.
Previous: [v2.35](DungeonMMO_Roadmap_v2_35_Greenward_Player_Bleed_Client_Play_20260924.md).

## Corrected original-C4 versus grandfathered legacy mastery regression

The old `SkillMasteryGatesTest` treated a newly created Human Fighter
as able to start the now-retired automatic HumanVanguard path. The
test has been corrected, **not** production advancement rules:
new Human Fighters must choose one of their three original C4
first-transfer paths. Legacy mastery rank, use proficiency and
character-level predicates are still independently checked, and an
explicitly pre-existing, unfinished legacy quest can still be claimed.
Focused unpublished Base Studio:
`Skill Mastery Gates Tests PASS: 65 assertions`;
`Skill Mastery Focus RESULT passed=1 total=1 failed=0`.
No prior failure is reclassified as a passing run.

## Actual two-client Warden Base (a5567be2)

Fresh disposable, unpublished Base Rojo build and two-client Studio
Play `c4_greenward_warden_base_physical_live.luau` passed
`VERIFIED_LIVE_BASE_PASS`. Both clients were real Studio
players. The selected Elf Fighter physically held Sentinel Ilyra
and Warden Caer prompts, returning correctly bound patrol reports
and the guardian seal through authentic NPC prompt transactions.
The actual physical mentor refused an underlevel award, then
granted Greenward Warden at level 20; the client physically
accessed its trainer and purchased Steel Training through
the production skill remote and server-owned profile.
The previously earned three patrol reports and guardian seal were
seeded **only in this disposable Base fixture**: this alone does not
prove physical cross-place combat persistence. The runtime bridge
used a temporary ModuleScript instead of a global variable.

## Actual two-client Warden Dungeon (b752df98)

A new disposable `c4_greenward_warden_dungeon_two_client_live.luau`
ran on a fresh, unpublished Dungeon Rojo build and reported
`VERIFIED_TWO_CLIENT_WORLD_PROOFS_PASS`. Two real clients, with
different personally staged original Warden quests, entered the
same instanced combat room. Their real client normal attacks caused
HP damage to the original tagged Rootbound Marauder and Thornbound
Colossus models, after which a server-only **test finishing hit**
accelerated each kill through the existing DamageService. The real
server contribution/quest ledger awarded exactly one personal
report and a separate personal guardian seal, without granting
the unrelated player's loot. This is **not** a fully client-landed
lethal kill; the source-room fixture does not award all three
reports and does not naturally transport between Base/Dungeon.

See [v2.36 evidence](../testing/greenward-warden-v2-36-physical-client-quest-20260924.md).

## Still open and scope

Greenward Warden's 56/56 historical C4 *training rank schedules*
remain mapped (not equivalent to exact C4 combat formulas or
mechanical/release acceptance). Uninterrupted player-driven 3-report
quest, actual natural enemy lethal hit, natural Captain AI bleed,
genuine Base -> Dungeon -> Base/rejoin and persistent save/handoff,
full multiplayer/balance and original 18-branch release remain OPEN.
A future cross-place persistence test requires proper isolated
session/persistence authority; no public publish or production
DataStore mutations are authorized.

No main merge, Roblox publish or unrelated animation worktree edits.
Permanent source, drivers and roadmap changes were made in GitHub;
local desktop actions were fast-forward, temporary Rojo build and
unpublished Studio tests only.
