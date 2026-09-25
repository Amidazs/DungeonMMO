# DungeonMMO Roadmap v2.86 — C4 Periodic Status Source

Date: 25 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v2.85](
DungeonMMO_Roadmap_v2_85_C4_Magic_Basic_Normal_Routing_20260925.md).

## Goal

Build the exact source arithmetic and stat boundary required to replace the
remaining creative Bleed/Poison periodic-damage tuning safely.

This milestone does not yet activate live source statuses.

## Reviewed source behaviour

Pinned source commit:

`07f8536384e799f128d44198dd7ab23519660eea`.

C4 skill 96 Bleed rank one:

- skill type: DEBUFF;
- effect type: BLEED;
- save stat: CON;
- effect power: 100;
- magic level: 24;
- effect: 13 damage;
- count: 4;
- interval: 5 seconds;
- non-magical.

C4 skill 1168 Curse:Poison rank one:

- skill type: DEBUFF;
- effect type: POISON;
- save stat: MEN;
- effect power: 70;
- magic level: 7;
- effect: 8 damage;
- count: 10;
- interval: 3 seconds;
- magical.

The reviewed `SkillDebuff` handler calls `Formulas.calcEffectSuccess` before
creating the effect. Magic debuffs may consume Spiritshot/Blessed Spiritshot;
DEBUFF skills do not consume Soulshot through `useSoulShot()`.

The reviewed Bleed and Poison effect implementations are nonlethal: a tick can
reduce the target only to one HP.

## Implementation

New pure source module:

`C4StatusEffectReference`.

It provides:

- exact source Bleed/Poison periodic-plan extraction;
- source save-stat bonus input;
- magical M.Atk/M.Def exponent handling;
- exact Spiritshot/Blessed Spiritshot effect-success adjustment;
- source skill/attacker/target level delta;
- source integer truncation and 1-99 pre-vulnerability clamp;
- target vulnerability application;
- strict 0-99 random-roll comparison;
- exact nonlethal periodic-tick arithmetic.

The player source boundary now exposes CON and MEN bonuses. Final source stat
candidates now carry neutral `BLEED_VULN=1` and `POISON_VULN=1`, ready for
future reviewed source modifiers.

The reviewed NPC boundary now exposes the same status-resistance inputs.

## Fresh acceptance

Candidate:

`d490faa2a285c31957ec2c082132320da5688e46`.

Fresh unpublished Rojo:

- Base: PASS;
- Dungeon: PASS;
- git diff validation: PASS.

Focused Studio:

- Base: **21/21 PASS**;
- Dungeon: **24/24 PASS**;
- periodic status reference: **14 assertions PASS**;
- existing source combat: **38 assertions PASS**;
- dispatch: **17 assertions PASS**;
- Dungeon resource cutover: **7 assertions PASS**.

Status marker:

`SOURCE_STATUS_PASS: 14 assertions bleed=13x4@5 poison=8x10@3 nonlethal=true`.

## Safety boundary

The live creative bleed/poison services have not yet been replaced.

`StatusPhysical` and `StatusMagic` remain dispatch activation blockers, so
production source dispatch still cannot enable.

No publish, production persistence mutation, `main` merge or animation edit
occurred.

## Next backend implementation

Use the accepted status reference to add a source DEBUFF calculation path and a
server-owned live NPC periodic-status executor.

The adapter must intercept `WayfinderWound` and `MysticPoisonCurse` as
DEBUFF casts before the generic PDAM/MDAM paths, schedule exact nonlethal source
ticks, preserve contribution/quest/threat bookkeeping, and leave the existing
creative status services untouched whenever source dispatch is disabled.
