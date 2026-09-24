# Greenward Warden three-report and loot-gate acceptance — v2.38

Date: 24 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`; latest executed candidate `598ce9f2719b51b2f2d7711d86be41806fe2b5e7`.

## Real Play with three unique source enemy lives

Driver:
`scripts/studio/c4_greenward_warden_three_reports_two_rooms_live.luau`.
Fresh unpublished disposable Dungeon Rojo build, two real Play
clients sharing the same instanced dungeon. The stage-three owner
personally killed the *two* physical Rootbound Marauders in the
first real combat room through actual `CombatInputActions`
requests. Only that owner received the first and second
`verdant_patrol_report`, verified against its authoritative
profile after each kill. The second player independently used
client attacks to kill Thornbound Colossus and alone received
`verdant_guardian_seal`.

The disposable driver killed **ordinary room-one pack members
only** to allow room-clear and physical second-room movement;
it did not kill any source-quest monster on the player's behalf.
The player traversed the real Room2 trigger, and the original
production encounter spawned new registered quest enemies.
The original stage-three owner used its actual client normal
attacks for the lethal third Rootbound Marauder and then
held exactly three patrol reports, source proof
`VerdantPatrolReports3=true` and `Quest.Step=4`. The
other player still had zero patrol reports.

The initial `267397ac` run **FAILED** at
`ServerScriptService.GreenwardCombatServer_TEMP:143` with
`Genuine client failed to land a lethal quest-monster hit`.
The server logs showed several enemy attacks and only partial
player damage while the test player was displaced. The
`598ce9f2` candidate anchored its test-only player during
individual target combat, re-aimed before each ordinary client
attack, restored mobility for physical Room2 traversal and
increased disposable test-only player HP to prevent pack-wide
survival masking the quest-credit contract. Enemy HP and all
server kill-credit authorities were unchanged.
`%TEMP%\\DungeonMMO_v243_warden_three_reports\\three_reports.log`
reported `[Greenward Live] VERIFIED_THREE_REPORTS_TWO_ROOMS_PASS`.
The fresh child's Studio log also recorded
`FIRST_TWO_REAL_REPORTS_PASS`,
`REAL_BOSS_CLIENT_LETHAL_OWNER_SEAL_PASS` and
`THREE_REAL_CLIENT_REPORTS_STAGE4_PASS`.
This is **not** an ordinary pack survival or live cross-place
persistence result; its stage-three/five owners are test-prepared.

## Quest kill-credit hardening — 823fab36

The shared production
`C4QuestMonsterCombatLedger.is_owner_eligible` now denies
source proof unless real owner race, base class, current Fighter
class, selected branch, exact quest step, unfinished quest and
minimum level all match server source metadata. Both hit and
award paths call the same check, preventing a stale contributor
from earning a later personally bound drop after changed
progression data. Targeted source fixtures cover valid and
copied identities across Human Rogue, Warrior, Knight,
Elven Scout, and Elven Knight stage three/five.

Focused unpublished Dungeon Studio
`%TEMP%\\DungeonMMO_v242_quest_owner_gates\\owner_gate.log`:
`[C4 Quest Combat Ledger] PASS: 58 assertions`,
`[C4 Source Pack] PASS: 21 assertions`,
`[Contribution Damage Bridge Tests] PASS: 13 assertions`,
and `[C4 Quest Combat Focus] RESULT passed=3 total=3`.

## Not yet claimed

No real Base-to-Dungeon-to-Base save/rejoin with the same
persistent player profile, full physical NPC quest interaction
from unseeded beginning to final mentor in one journey,
natural CaptainSlash AI bleed, exact original C4 combat
balance or complete 18-branch original first-transfer
release certification. No main merge or publish.
