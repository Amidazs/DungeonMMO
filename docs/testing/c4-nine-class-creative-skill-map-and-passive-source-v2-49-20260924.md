# v2.49 — nine-class C4 creative mapping and source passive calculation

Date: 24 September 2026. Branch: `wip/phase-4-test-hud-integration-v1`.
Pinned historical reference:
`Neco-spain/l2jadmins_C4-Scions-of-Destiny@07f8536384e799f128d44198dd7ab23519660eea`.
This is a pinned open-source C4 server implementation, not
independent proof of every original retail-server behavior.

## Creative rank linkage

`C4CreativeSkillSourceMap` links all source skill IDs in
the nine-path `C4Level30SkillTreeSource` to a specifically
reviewed existing creative candidate or an explicit gap.
`C4CreativeSkillLinkAudit` verifies original skill rank
offsets and actual class teachability/learning-level
metadata. Missing source-data or a missing class skill
fails the focused test. Any candidate remains marked
`ExactC4MechanicsCertified=false`.

Initial Base Studio after `5974d41c`:
`%TEMP%\\DungeonMMO_v249_c4_creative_mapping\\mapping.log`
printed 9 paths /476 ranks /451 candidates /25 gaps /0
broken and `VERIFIED_SOURCE_MAPPING_PARITY_NOT_CERTIFIED`.
A real finding was that two debuffs already present in the
trainer were absent from Mage class teaching. Corrected
Mage teaching and exact source IDs in `1865a9e0`.

Retest:
`%TEMP%\\DungeonMMO_v249_c4_creative_mapping_fix\\mapping.log`:
`[C4 CREATIVE LINK] AUDIT_PASS paths=9 rows=476
candidate=454 explicitGap=22 broken=0 differentMP=94
liveEffectParity=NOT_CERTIFIED` and
`VERIFIED_SOURCE_MAPPING_PARITY_NOT_CERTIFIED`.
Both disposable Base and Dungeon Rojo builds passed.

These are *creative ID/rank candidate* counts, NOT 454
matching effects. Deliberately unresolved examples:
HumanRogue Vital Force versus game's resting stamina,
all nine ElvenScout Elemental Heal ranks versus current
`ElvenRenewal`, four shared starter Lucky rows,
four shared starter Common Craft rows, and Mystic
Magicians Movement/Spellcraft. Unmapped creative extras
are logged separately for each original path.

## Passive reference source arithmetic

At `d665a3e0`, added read-only
`C4PassiveStatReference` and focused disposable Base
Studio runner. It uses authentic stat names, original
modifier order and exact using-kind conditions, and
rejects unknown rank, duplicate same-skill rank, active
aura and unsupported operations. No existing live
CombatService, DamageService, passive/equipment manager
or HP/MP progression is changed by this source module.

`%TEMP%\\DungeonMMO_v249_c4_passive_reference\\passive.log`
prints `SOURCE_ONLY_PASS: 9 assertions` and
`VERIFIED_SOURCE_ONLY_NOT_LIVE`.
Representative source arithmetic:
Bow Mastery +its exact rank9 source modifier only when
equipped Bow; Dagger Mastery rank1 +3.6 physical attack
on Dagger only; Knight Heavy Armor rank1 +17.7 P.Def
on Heavy only; Light Armor rank1 +1.3 P.Def/+4 Evasion
on Light only; Mystic Weapon Mastery on example naked
100 P.Atk /100 M.Atk yields 146.5 /118.9 after
source-order 0x30 multiply and 0x40 flat addition.

The pure reference does NOT prove cross-skill stacked
source category semantics, original live equipment
conversions, buff stacking, stamina, player HP damage
or exact multi-class PVP balance. Those need separate
formula, runtime and physical Play acceptance.
