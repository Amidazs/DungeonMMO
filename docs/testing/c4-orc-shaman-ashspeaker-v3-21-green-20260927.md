# C4 Orc Shaman / Ashspeaker v3.21 Green Acceptance

Date: 27 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Accepted code/test HEAD:
`f28824bdc0f3d2b6fbdf1b1940ec17b3f78cb1c5`.

## Scope

This record closes the level-30 Orc Mystic -> Orc Shaman / Ashspeaker
backend gate.

It covers exact class-49 starter inheritance, class-50 source inventory,
independent DungeonMMO progression, exact rank schedules, source effects,
passives, unified stats, resource migration, physical casting, hostile
magic/control, periodic effects, caster-centred seals, support chants,
Soul Cry toggle authority, NPC fear/accuracy state, and genuine unpublished
Play behavior.

No production publish, `main` merge, production DataStore mutation, animation
work, or Dwarf implementation is included.

## Source result

- starter source class: **Orc Mystic**, class ID **49**;
- inherited starter source rows: **35 / 35**;
- inherited creative starter families: **19**;
- first-transfer source class: **Orc Shaman**, class ID **50**;
- creative class: **Ashspeaker**;
- exact first-transfer rows through level 30: **77 / 77**;
- source brackets: **24 / 26 / 27** at levels **20 / 25 / 30**;
- Ashspeaker first-transfer families: **29**;
- source-map gaps: **0**;
- exact level-30 resources: **869 HP / 504 MP / 436 CP**.

The source catalogue remains pinned to C4 commit
`07f8536384e799f128d44198dd7ab23519660eea`.

Current aggregate source coverage after Ashspeaker acceptance:

- **21 paths / 1305 learning rows / 162 unique source skill IDs**;
- source-effect catalogue:
  **162 skills / 634 unique rank-effect pairs**;
- first-transfer source audits: **16 / 18**;
- mapped first-transfer rank schedules: **16 / 18**.

The two remaining first-transfer branches are the Dwarf branches and were not
started in this acceptance.

## Exact class-50 stats

Ashspeaker preserves the pinned class-50 Orc Shaman template through the
authenticated resource boundary:

- **869 HP / 504 MP / 436 CP** at level 30;
- STR 27 / DEX 24 / CON 31;
- INT 31 / WIT 15 / MEN 42.

Inherited Orc Mystic source skills and passives remain resolvable after first
transfer through the current Ashspeaker source scope.

## Runtime completion

The reviewed Ashspeaker runtime covers:

- inherited Orc Mystic active magic;
- Skullshock physical damage plus exact source stun handling;
- Life Drain;
- Fear with landed/resisted source result and NPC fear authority;
- Dreaming Spirit;
- Madness;
- Venom;
- Frost Flame;
- Blaze Quake;
- Aura Sink;
- Poison Seal;
- Binding Seal caster-centred Root aura;
- Chaos Seal caster-centred accuracy-debuff aura;
- Soul Shield;
- Flame Chant;
- War Power;
- Fire Chant;
- Battle Chant;
- Shielding Chant;
- Life Chant regeneration;
- Soul Cry source toggle and upkeep;
- source resource migration and complete cutover rollback.

### Fear and NPC behavior

Fear uses the exact source effect-success calculation. A landed result enters
the server-owned NPC fear state; a resisted result does not fabricate fear.
Supported NPC controllers consume that state as flee movement rather than
ordinary chase/attack behavior.

### Binding and Chaos seals

Binding Seal and Chaos Seal are caster-centred source-radius skills.

The executor discovers reviewed NPC targets at launch from the caster's live
encounter, performs independent exact source success rolls and applies only
landed results:

- Binding Seal -> movement-only Root authority;
- Chaos Seal -> accuracy-debuff authority;
- both keep the reviewed **200 source-unit** aura radius.

The Play harness initially exposed an invalid test fixture encounter ID. The
runtime correctly rejected those NPCs from the caster-centred scan. The final
harness binds disposable Marauders to the player's actual
`DungeonEncounterId` and both aura paths pass.

### Support and toggle authority

Soul Shield reaches the exact target-buff path.

Flame/Fire/Battle/Shielding chants use the server-owned party roster and source
party radius. Life Chant reaches the server-owned party HealOverTime path.

Soul Cry uses the source toggle service, resolves exact source identity and
rank, activates authoritatively, and deactivates cleanly.

## Regression evidence

Final closure on the accepted code/test HEAD:

- `git diff --check`: PASS;
- fresh Base Rojo build: PASS;
- fresh Dungeon Rojo build: PASS;
- focused Ashspeaker/backend set: **21 / 21 PASS**;
- source learning-tree coverage:
  **21 paths / 1305 rows / 162 unique source skill IDs**;
- source-effect catalogue:
  **162 skills / 634 unique rank-effect pairs**;
- launch source audit: **16 / 18 branches**;
- launch mapped schedules: **16 / 18 branches**;
- accepted Play log `FLog::CreatorError` count: **0**;
- accepted Play marker: `VERIFIED_PLAY_MODE_PASS`.

A separate old `C4FirstTransferTrainingTest` Ranger/Rogue fixture remains
outside this Ashspeaker acceptance. Its legacy identity seed is rejected by
the current original-first-transfer rules with `IdentityIncomplete`. The
diagnostic is explicit; no Ashspeaker runtime was weakened to satisfy that
obsolete fixture.

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

The run used a real authenticated level-30 Ashspeaker state, exact inherited
Orc Mystic ranks, exact class-50 ranks, reviewed blunt equipment, reviewed
Marauder NPC boundaries, source timing/reuse, physical and magical combat,
NPC status authorities, server-owned party support, source toggles and full
rollback.

## Dwarf boundary

Ashspeaker completes the Orc first-transfer backend work currently scheduled
before the Dwarf branches.

The next source-order branches are:

- `DwarfArtisan`;
- `DwarfScavenger`.

Per project direction, development stops here before any Dwarf source audit,
race/class foundation, creative naming, profession/crafting interaction, or
combat implementation is authored.
