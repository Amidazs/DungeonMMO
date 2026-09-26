# Human Wizard Targeted Cast Batch v3.01 — Acceptance

Date: 26 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.

## Result

**GREEN — the staged Human Wizard targeted-cast backend is validated through
the real unpublished Dungeon runtime and a live Play rehearsal.**

Validated code candidate:

`4f22314542ba6a1e2f18b5cf0c82e711bdb03d26`.

## Static and build checks

Fresh validation completed:

- `git diff --check`: PASS;
- Base Rojo build: PASS;
- Dungeon Rojo build: PASS.

The only local untracked paths remain the pre-existing quadruped animation
Python `__pycache__` folders. They were not edited or committed.

## Focused cast acceptance

The current Human Wizard cast-focused runner passes:

`[Human Wizard Source Cast] RESULT passed=15 total=15`.

It covers:

- owned source passives;
- unified/source stats;
- resource migration boundary;
- C4 runtime rules;
- cast contract;
- split-MP resource lifecycle;
- exact cast timing/reuse;
- private cast scheduler;
- direct MDAM bridge;
- periodic poison bridge;
- real source cast runtime composition;
- cross-service staged Wizard casting;
- source combat calculation;
- source combat executor;
- real Dungeon source cast runtime composition.

## Big backend acceptance

The expanded backend runner now includes **35 suites** and passes:

`[Human Wizard Big Backend] RESULT passed=35 total=35`.

The two extra suites are the Dungeon failure-path and encounter-binding
regressions, so the large run now reaches beyond Wizard-only services into
Dungeon mutation/revive and encounter-binding contracts.

During this validation the wider run found one stale paid-revive fixture.
Production `DungeonDeathService` correctly requires
`grant_paid_revive_once` to record the purchase and switch the member to
Active before `complete_paid_revive` performs the respawn. The test was
updated to simulate that real grant sequence and now also proves an ungranted
paid revive cannot be completed.

## Play-mode regression isolation

Two Dungeon regression scripts were still auto-running during live Play and
produced false project errors against the deliberately modified rehearsal
environment.

They now return immediately while `RunService:IsRunning()`, but remain
available to the explicit Edit-mode test runner.

The final live rehearsal log contains:

- project `CreatorError` count: **0**;
- Wizard live PASS marker count: **1**.

## Live Human Wizard rehearsal

The unpublished Dungeon Play rehearsal passed the full staged sequence for a
real admitted player and a reviewed Marauder NPC.

### Ember Bolt

`EmberweaverEmberBolt`:

- source skill 1220 rank 6;
- real cast timing and split MP;
- charged Spiritshot consumed once at source calculation;
- real NPC damage: approximately **469.180**;
- contribution/threat bookkeeping updated.

### Flame Burst

`EmberweaverFlameBurst`:

- source skill 1172 rank 6;
- neutral non-elemental C4 magic path;
- real NPC damage: approximately **370.405**;
- contribution/threat bookkeeping updated.

### Focused Bolt

`EmberweaverFocusedBolt`:

- source skill 1274 rank 3;
- neutral non-elemental C4 magic path;
- real NPC damage: approximately **234.590**;
- contribution/threat bookkeeping updated.

### Venom Hex

`EmberweaverVenomHex`:

- source Poison 1168 rank 3;
- exact source periodic plan;
- one Spiritshot consumed;
- source roll landed in the accepted rehearsal;
- first nonlethal poison tick applied exactly **24 damage**;
- contribution/threat bookkeeping updated.

Final markers:

`[Wizard Targeted Cast Live] THREE_DIRECT_PLUS_POISON_PASS`

`[Wizard Targeted Cast Live] VERIFIED_PLAY_MODE_PASS`

## Runtime safety

The staged cast bridges remain disabled by default.

The rehearsal explicitly enabled them only inside the unpublished Studio test,
then disabled source casting and C4 cutover again before cleanup.

No ordinary client spell input is connected to these bridges yet.

## v3.00 closure

The v3.01 result subsumes the earlier v3.00 direct-MDAM pending gate. The
direct scheduler-to-executor bridge is therefore now validated as part of this
larger batch.

## Remaining Human Wizard backend work

Still separate future gates include:

- Frost Lance slow semantics;
- Ember Field and other AOE magic;
- Life Siphon/drain healing;
- Slumber and other non-periodic control/debuff effects;
- corpse/mana conversion skills;
- summon/servitor authority;
- ordinary client-facing spell activation and HUD/input wiring.

No `main` merge, Roblox publish, production DataStore mutation or animation
work occurred.
