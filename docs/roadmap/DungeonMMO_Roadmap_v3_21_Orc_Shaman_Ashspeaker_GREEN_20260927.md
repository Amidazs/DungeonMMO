# DungeonMMO Roadmap v3.21 — Orc Shaman / Ashspeaker GREEN

Date: 27 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous:
[Roadmap v3.20](
DungeonMMO_Roadmap_v3_20_Orc_Monk_Spiritclaw_GREEN_20260927.md).

## Status

**GREEN — Orc Mystic -> Orc Shaman / Ashspeaker backend accepted through
level 30.**

Evidence:
[Ashspeaker v3.21 green acceptance](
../testing/c4-orc-shaman-ashspeaker-v3-21-green-20260927.md).

Accepted code/test HEAD before documentation:
`f28824bdc0f3d2b6fbdf1b1940ec17b3f78cb1c5`.

## Class and source coverage

Ashspeaker is the independent DungeonMMO career for the original Orc Shaman
first-transfer branch:

- race: Orc;
- starter family: Mage;
- inherited source starter class: Orc Mystic, class ID 49;
- source first-transfer class: Orc Shaman, class ID 50;
- transfer branch: `OrcShaman`;
- creative class: `Ashspeaker`;
- Orc Mystic starter source rows: **35 / 35**;
- Orc Mystic inherited creative families: **19**;
- Orc Shaman level-30 source rows: **77 / 77 mapped**;
- Orc Shaman source brackets: **24 / 26 / 27** at levels
  **20 / 25 / 30**;
- distinct Ashspeaker first-transfer families: **29**;
- source-map gaps: **0**.

The source catalogue remains pinned to C4 commit
`07f8536384e799f128d44198dd7ab23519660eea`.

Tracked source learning coverage is now **21 paths / 1305 rows /
162 unique source skill IDs**. The common source-effect catalogue covers
**162 source skills / 634 unique rank-effect pairs**.

Launch audit coverage is **16 / 18 first-transfer branches source-audited**
and **16 / 18 rank schedules mapped**.

## Exact class-50 stats

The accepted Ashspeaker source template preserves exact class-50 level-30
resources:

- **869 HP / 504 MP / 436 CP**;
- STR 27 / DEX 24 / CON 31;
- INT 31 / WIT 15 / MEN 42.

Inherited Orc Mystic skills and passives remain resolvable after first
transfer through authenticated Ashspeaker source scope.

## Runtime completion

The reviewed Ashspeaker runtime covers inherited Orc Mystic active magic,
Skullshock, Life Drain, Fear, Dreaming Spirit, Madness, Venom, Frost Flame,
Blaze Quake, Aura Sink, Poison Seal, Binding Seal, Chaos Seal, Soul Shield,
party chants, Life Chant, Soul Cry, source stats/resource migration and full
source-cutover rollback.

Fear preserves the exact source success calculation. Landed casts enter
server-owned NPC fear state; resisted casts do not fabricate status. Supported
NPC controllers consume fear as flee movement.

Binding Seal and Chaos Seal discover reviewed NPCs from the caster's live
encounter at launch and use the exact **200 source-unit** radius. Binding Seal
applies movement-only Root; Chaos Seal applies the reviewed accuracy debuff.

The Play rehearsal exposed a test-fixture mistake: disposable enemies had
initially been stamped with an artificial encounter ID. The runtime correctly
excluded them. The accepted harness uses the player's actual
`DungeonEncounterId`.

Soul Shield crosses the target-buff authority. Flame, Fire, Battle and
Shielding chants use the server-owned party roster. Life Chant reaches the
party HealOverTime authority. Soul Cry enters the source-toggle authority and
deactivates cleanly.

## Fresh validation

Final closure at the accepted code/test HEAD:

- `git diff --check`: PASS;
- fresh Base Rojo build: PASS;
- fresh Dungeon Rojo build: PASS;
- focused Ashspeaker/backend acceptance: **21 / 21 PASS**;
- source-effect catalogue:
  **162 skills / 634 unique rank-effect pairs**;
- source learning-tree coverage:
  **21 paths / 1305 rows / 162 unique source skill IDs**;
- launch source audit: **16 / 18 branches**;
- launch rank schedules mapped: **16 / 18 branches**;
- accepted Play log: **0 CreatorErrors**;
- accepted Play log contains `VERIFIED_PLAY_MODE_PASS`.

A separate legacy `C4FirstTransferTrainingTest` Ranger/Rogue fixture remains
outside this Ashspeaker acceptance. Its old identity seed is now rejected as
`IdentityIncomplete` by the current original-first-transfer rules. No
Ashspeaker runtime was weakened to satisfy that obsolete fixture.

## Genuine unpublished Play rehearsal

`C4OrcShamanLiveHarness` passed against a fresh unpublished Dungeon build and
the real source cutover/cast runtime.

Accepted markers:

- `CORE_COMBAT_PASS inherit_stun_drain_fear=true`;
- `SEAL_PASS root_accuracy_aura=true`;
- `PERIODIC_PASS venom=true`;
- `SUPPORT_PASS shield_chant_regen=true`;
- `TOGGLE_PASS soul_cry=true`;
- `COMBAT_SUPPORT_AURA_TOGGLE_ROLLBACK_PASS`;
- `VERIFIED_PLAY_MODE_PASS`.

## Dwarf boundary — intentional stop

Ashspeaker completes the non-Dwarf first-transfer backend work currently
scheduled before the Dwarf branches.

The only first-transfer branches still outside the source audit/mapping gate
are:

- `DwarfArtisan`;
- `DwarfScavenger`.

**Development intentionally stops here before any Dwarf source audit or
implementation**, per project direction.

Before continuing, Dwarf-specific design decisions should be discussed,
especially how the original Artisan/Scavenger paths interact with DungeonMMO's
WoW-like profession model, gathering/crafting limits, spoil/sweep-style
mechanics, trading, and the existing Dwarven hub/cavern identity.

No Dwarf race/class code, creative Dwarf naming, skill mapping, profession
integration or live mechanics were authored in v3.21.

No `main` merge, Roblox publish, production DataStore mutation or animation
work was performed.
