# DungeonMMO Roadmap v3.09 — Human Cleric Level 30 Complete

Date: 26 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v3.08](
DungeonMMO_Roadmap_v3_08_Human_Wizard_Level30_Complete_20260926.md).

## Status

**GREEN — Human Cleric / Dawnkeeper level-30 backend is complete and
accepted in Studio.**

Accepted branch HEAD:

`ab4a778ddf6eb673fe6c11c1722980e1e555a13a`.

Evidence:
[Human Cleric level-30 completion v3.09](
../testing/c4-human-cleric-level30-complete-v3-09-20260926.md).

## Level-30 source coverage

The Human Cleric branch now maps every reviewed source skill rank through the
initial level-30 launch cap:

- source rank rows through cap: **88**;
- trainer-mapped rows: **88**;
- missing rows: **0**;
- creative-extra rows: **0**;
- broken creative/source links: **0**.

The creative advancement identity remains **Dawnkeeper**, with the existing
Human Cleric C4 advancement schedule preserved.

## Friendly support families

The scheduled support bridge reviews all 14 implemented friendly Cleric
families:

- Healing Light / Heal 1011;
- Battle Mend / Battle Heal 1015;
- Group Mend / Group Heal 1027;
- Revive / Resurrection 1016;
- Mind Ward / Mental Shield 1035;
- Stone Ward / Shield 1040;
- Sacred Edge / Holy Weapon 1043;
- Might / Might 1068;
- Breath Blessing / Kiss of Eva 1073;
- Focus / Focus 1077;
- Concentration / Concentration 1078;
- Insight / Acumen 1085;
- Fire Ward / Resist Fire 1191;
- Windstep / Wind Walk 1204.

Targeted support casts bind the server target privately, validate exact source
cast range before initial MP, revalidate effect range at launch and use the
existing source cast scheduler/resource pipeline.

Group Mend uses a server-owned Dungeon party roster and does not accept a
client-provided target list.

## Resurrection

Dawnkeeper Revive preserves the source Resurrection 1016 contract and uses a
server-owned confirmation offer rather than reviving immediately on cast.

The flow is:

`cast -> dead party target validation -> resurrection offer -> target UI ->
target accepts -> server respawn at death/checkpoint position -> Active mode`.

The target remains authoritative over acceptance. The client cannot fabricate
the source restore power or caster identity.

The current game does not yet implement C4 death-XP loss, so the exact source
Resurrection restore-power value is retained as evidence rather than creating
a fictional XP refund.

## Hostile Cleric magic

Three hostile Cleric families now use the reviewed direct-magic pipeline:

- Exorcism / Disrupt Undead 1031 rank 6;
- Slumber / Sleep 1069 rank 6;
- Rootbind / Dryad Root 1201 rank 12.

Exorcism is server-restricted to reviewed undead NPC targets. Slumber uses the
shared source Sleep authority. Rootbind uses the shared NPC root authority and
suppresses movement without inventing an attack-speed penalty.

The direct-magic service now reviews 12 total spell families across Human
Wizard and Human Cleric, and its capability regression was updated to include
the Cleric undead/root families.

## Studio backend acceptance

The exact 24-fixture Human Cleric backend runner set was executed in fresh
`DungeonMMO_HumanCleric_Full_Test9.rbxlx` after the final direct-magic count
fix.

Result:

**24 / 24 PASS.**

Important green evidence included:

- Human Cleric Foundation: **156 assertions**;
- Human Cleric Source Effects: **36 assertions**;
- Human Cleric Direct Magic: **4 assertions**;
- Support Magic Cast: **10 assertions**;
- Dungeon Death/Revive: **54 assertions**;
- Source Combat Calculation/Executor: PASS;
- source cast contract/resource/timing/scheduler: PASS;
- runtime composition/default binding/Dungeon runtime: PASS.

A second Play-mode critical subset also passed **4 / 4** on the real Server
DataModel:

- Human Cleric Source Effects;
- Human Cleric Direct Magic Bridge;
- Source Support Magic Cast;
- Dungeon Death/Revive.

## Genuine Play resurrection rehearsal

A real unpublished Play client/server rehearsal exercised the resurrection UI
and request round trip.

The server created a valid source resurrection proposal with restore power 20.
The actual Dungeon UI displayed:

- title: `RESURRECTION OFFER`;
- action button: `Accept Revive`;
- timer text: `Accept to revive at your defeat location.`;
- party-resurrection hint.

The client then sent `SkillResurrectionAccept` through the real
`ReviveRequest` RemoteEvent. The server-owned death service accepted it,
recorded the original caster, preserved restore power 20, invoked respawn at
the reviewed location `(12, 5, -8)`, moved the member to `Active`, and the
client revive panel closed.

The Test9 Studio log contained **0 CreatorErrors** after backend and Play
acceptance.

## Build validation

Final local validation:

- `git diff --check`: PASS;
- Base Rojo build: PASS;
- Dungeon Rojo build: PASS;
- only the pre-existing quadruped Python `__pycache__` folders remain
  untracked.

## Scope boundary

This closes the Human Cleric / Dawnkeeper backend through level 30.

It does not claim final spell VFX, animations, icons or production publishing.
Those remain presentation/content work and do not represent missing backend
skill rows.

No `main` merge, Roblox publish or production DataStore mutation was done.
