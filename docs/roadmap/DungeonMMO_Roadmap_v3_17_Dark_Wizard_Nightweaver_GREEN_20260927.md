# DungeonMMO Roadmap v3.17 — Dark Wizard / Nightweaver GREEN

Date: 27 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v3.16](
DungeonMMO_Roadmap_v3_16_Dark_Wizard_Source_Audit_20260927.md).

## Status

**GREEN — Dark Wizard / Nightweaver backend accepted through level 30.**

Evidence:
[Nightweaver v3.17 green acceptance](
../testing/c4-dark-wizard-nightweaver-v3-17-green-20260927.md).

Accepted code/test HEAD before documentation:
`a0f32be57fa0daed96733a0deba86fccf55c0d4d`.

## Class and source coverage

Nightweaver is the independent DungeonMMO career for the original Dark Wizard
first-transfer branch:

- race: Dark Elf;
- base family: Mage;
- source class: Dark Wizard;
- source class ID: 39;
- transfer branch: `DarkWizard`;
- creative class: `Nightweaver`;
- exact level-30 source rows: **86 / 86 mapped**;
- distinct reviewed source families: **25**;
- source-map gaps: **0**.

The exact source inventory remains pinned to C4 commit
`07f8536384e799f128d44198dd7ab23519660eea`.

Level-30 source vitals are **672 HP / 482 MP / 338 CP** with the exact Dark
Elf Wizard primary-stat template, including MEN bonus **1.45**.

## Skill/runtime completion

The class now preserves all reviewed level-30 active/passive families through
the shared source runtime rather than reimplementing Human/Elven Wizard
mechanics with guessed values.

Key accepted families include:

- WIND direct magic through Gale Bolt / source Twister;
- DARK direct magic through Shadow Spark;
- Umbral Siphon drain;
- Frost Lance slow;
- Flame Burst and Ember Field damage families;
- Slumber Hex sleep;
- Venom Hex and Venom Cloud poison;
- Venom Rend / Surrender To Poison;
- Blood To Mana and Corpse Siphon utility;
- both reviewed summon families plus Servitor Heal/Recharge;
- all eight genuine passive families;
- Concentration as an **ACTIVE 20-minute target buff**, not a passive.

The Concentration audit also corrected the same source classification for the
Human and Elven Wizard creative definitions.

## C4 cast interruption

Nightweaver acceptance closed the previously missing live meaning of
`ATTACK_CANCEL_RATE`.

The server now preserves the pinned C4 `calcAtkBreak` sequence for a target
that is actively casting:

1. start from 15;
2. add `sqrt(13 * damage)`;
3. subtract the target MEN bonus above 1.0;
4. apply the signed `ATTACK_CANCEL_RATE` source modifier;
5. clamp the final chance to 1..99 percent;
6. compare against a server-owned integer roll from 0..99.

Concentration rank two contributes the exact source **-25** attack-cancel
offset. Damage observation happens only after trusted player damage resolution;
no client controls the damage value, MEN value, source modifier, pending cast
receipt or production random roll.

The live rehearsal exposed a real cross-service defect: interruption originally
cancelled the shared scheduler but left the owning cast bridge's private
pending receipt. The runtime composition now routes interruption cancellation
through the bridge that owns the receipt, which clears both layers while
preserving the scheduler's normal reuse-on-cancel behavior.

## Fresh validation

Final post-fix acceptance:

- `git diff --check`: PASS;
- Base Rojo build: PASS;
- Dungeon Rojo build: PASS;
- focused bridge/interruption regression: **4 / 4 PASS**;
- final broad Nightweaver/backend regression: **25 / 25 PASS**;
- latest Studio log: **0 CreatorErrors**;
- only the pre-existing quadruped Python `__pycache__` folders remain
  untracked.

## Genuine unpublished Play rehearsal

`C4NightweaverLiveHarness` passed against a fresh unpublished Dungeon build.

The accepted run proved:

- source cutover for the real level-30 Nightweaver boundary;
- deterministic trusted damage interrupted an unprotected Gale Bolt;
- Concentration applied source 1078:2 for 1200 seconds;
- the combined active source stat candidate carried
  `ATTACK_CANCEL_RATE = -25`;
- the same damage/roll scenario did **not** interrupt protected Shadow Spark;
- the surviving Shadow Spark launched and dealt
  **858.20751953125 real NPC HP** as DARK source damage;
- threat bookkeeping observed that live NPC damage;
- Venom Rend resolved source 1224:2 through the real poison-vulnerability
  executor and landed in the accepted run;
- the landed debuff applied `POISON_VULN = 1.25` for 15 seconds;
- cutover and cast bridges rolled back cleanly;
- final marker: `VERIFIED_PLAY_MODE_PASS`.

## Next backend class

Continue in original first-transfer source order with Dark Elf
**Shillien Oracle**. It is the remaining Dark Mystic first-transfer branch and
is still unaudited/unimplemented in the level-30 launch catalogue.

Use the same acceptance gate:

source audit -> independent creative career -> exact level-30 rank mapping ->
source mechanics -> focused Studio -> broad regression -> unpublished Play ->
documentation.

No `main` merge, Roblox publish, production DataStore mutation or animation
work was performed.
