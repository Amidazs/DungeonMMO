# v2.23 — Warrior 62/62 source-rank schedule closeout

Date: 24 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Base/Dungeon source candidate: `efa2f0e1fef8a4e2ad1b30633d1ebb420024f171`.
Subsequent GitHub commits change **test drivers only**.

## Scope and C4 accuracy

The previously missing six recorded Warrior training-rank
opportunities now have distinct owned skills: three ranks
of MP-upkeep critical stance, one accuracy MP toggle, one
level-24 passive HP recovery and one level-28 maximum-HP/
restoration surge. All are separately paid from the earned
Warrior trainer, with server-side class/rank authorization.

**62/62 means source training rows mapped, NOT complete C4
mechanical, numerical, economic or release equivalence.**
Combat stat conversions, cooldowns, target effects and
resource regen remain Roblox-specific unless individually
verified. The current effect demonstrations do not certify
C4 balance, full class progression or all 18 class paths.

## Focused and client tests actually executed

Fresh disposable, unpublished Base and Dungeon Rojo builds
both PASS at `efa2f0e1`; no production places or saves.
Original earned Warrior Quest / trainer Award with in-memory
save-reload / Foundation at the same code revision:
**31 / 198 / 160 assertions PASS** in
`0.740.0.7400927_20260924T125113Z_Studio_819DB_last.log`.

Critical stance real-client test, earlier increment:
`0.740.0.7400927_20260924T121628Z_Studio_796C6_last.log`
records `REAL_CLIENT_MP_NPC_CRIT_REVOKE_PASS 82.5->85.7`
and `VERIFIED_PLAY_MODE_PASS`. An actual client hotbar
activated rank-three MP upkeep; a true NPC lost more HP
from a server-known critical hit, and revocation removed
the benefit. This pre-dates the final surge code.

Accuracy stance real-client test, earlier increment:
`0.740.0.7400927_20260924T122354Z_Studio_7681C_last.log`
records `REAL_CLIENT_MP_NPC_HIT_REVOKE_PASS` and
`VERIFIED_PLAY_MODE_PASS` with deterministic NPC
evasion and server-owned MP/owner authority checks.
This pre-dates the final surge code.

Passive recovery initially **FAILED** two actual Play
tests despite an owned rate of 1.1 HP/s. The diagnostic
in `0.740.0.7400927_20260924T125427Z_Studio_6CDA4_last.log`
showed `playerParent=Players characterParent=nil`:
the unpublished test retained an unparented character,
which the server correctly rejects as not live.
The disposable test fixture now explicitly spawns and
waits for a real world-parented `Player.Character`
rather than removing the server security condition.
Re-run at source `efa2f0e1`, driver
`759a7a3986657cbd3ba5c950a21321806cdad9de`,
in `0.740.0.7400927_20260924T125548Z_Studio_C9E7D_last.log`:
`OWNER_HP_CAP_REVOKED_DEAD_PASS` and
`VERIFIED_PLAY_MODE_PASS`.
Actual owner Humanoid gained 1.1 HP, never exceeded its
MaxHealth, and source-rank revocation, class forging and
dead-player healing were all rejected.

The NEW source-controlled real-client surge fixture
`scripts/studio/c4_ironvow_endurance_surge_client_live.luau`
at `8a9abe0b9235e6042801c4500c63592ef659f5ac`
used the **unchanged** `efa2f0e1` disposable Dungeon.
`0.740.0.7400927_20260924T125726Z_Studio_65402_last.log`
records:
`REAL_CLIENT_HP_MP_NONSTACK_REVOKE_PASS`,
base MaxHealth **108**, buffed MaxHealth **118.8**,
one restored heal **11.88 HP**, and actual hostile melee
**100 HP** damage (the buff does not grant invulnerability).
The genuine client slot-one cast consumed **13 MP**.
An immediate second client request did not restore
additional HP, stack max HP or refresh the same 600-second
server-issued expiry. Revoked rank removed the status,
returned max HP to its original value and rejected
a copied Fighter ability. `VERIFIED_PLAY_MODE_PASS`
appears in the same Studio log.

Final strict source-rank audit against the same Base
in `0.740.0.7400927_20260924T125831Z_Studio_50C82_last.log`:
**27 assertions PASS**, explicit
`VERIFIED_SOURCE_RANK_AUDIT_PASS`;
Warrior **62/62 mapped**, Knight **55/55 mapped**.
The audit requires `ExactSourceRankCoverageCertified=false`
and `LaunchSkillCatalogueReady=false`.

## Outstanding work

The 600-second surge deadline was verified as an
issued timestamp, not observed for ten minutes of
natural wall-clock play. This Play used a genuine client
and an **internally valid disposable earned-class/rank
snapshot**, not a natural persistent quest->trainer->
Dungeon->save/rejoin journey. Competitive multiplayer
concurrent effects, boss/world-boss block stacking,
full C4 P.Atk/P.Def/accuracy/damage/regen formula and
skill timing parity, additional classes and first
1–19 starter skills remain incomplete. Prior focused
Marauder/Captain shield chip results do not certify
every encounter. No `main` merge, Roblox publish,
production DataStore access or animation worktree edit.
