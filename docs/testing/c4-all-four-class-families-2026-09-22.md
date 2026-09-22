# C4-inspired skill families — focused local acceptance

Date: 22 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Final focused gameplay/test source:
`687e27c7ee8b0b41aa37c15030b4df2d14d4600f`

## Scope and design reference

All **currently supported base combat families** (Fighter, Mage,
Ranger and Rogue, Human and Elf) now have multiple functional
server-authored basic combat abilities, repeating skill-rank
training, additional passive mastery, and specialist rank/quest
prerequisites. These are original DungeonMMO skill names and
values with analogous **mechanical roles** to Chronicle 4.
Do not claim this is an exhaustive transcription of every L2
race, class, skill rank, spell, summon, enchant, debuff or
published balance value.

C4 references used for the skill-role map:
- https://lineage2wiki.com/c4/class/ (class paths);
- https://l2hub.info/c4/classes/mage (basic Mystic attack/healing);
- https://l2hub.info/c4/classes/rogue (bow/dagger archetype);
- https://l2hub.info/c4/classes/elven_scout (power-shot,
  mobility and bow/precision archetype);
- https://lineage2wiki.com/c4/patch-notes/ (C4 tank, caster,
  fighter and archer skill effects).

| Family | Actual DungeonMMO combat behaviour |
| --- | --- |
| Fighter | Repeated Iron Cleave strike and Pursuit Step mobility ranks; Shield Bash / Guard Breaker stagger, Taunt threat without damage; Iron Discipline damage and Stalwart Training max HP. Advanced Vanguard Challenge raises threat; Thornwarden Bash extends stagger. |
| Mage | Rankable Wind Strike, Cinder Bolt and Aether Bolt magical projectiles; Dawn Ward / Arcane Ward protection; Mage Heal and Renewing Light; damage/heal passives. Advanced Human Arcanist Ember is a harder magical projectile; Elf Spellweaver Aegis provides a stronger timed ward. |
| Ranger | Rankable Piercing and Tracker shots; **new nine-rank Archer Draw** high-power single-target arrow, Crippling Shot slowdown, Volley area damage and **six-rank Bow Mastery** server damage bonus. Sharpshooter Pierce and Windrunner Volley require previous skill mastery. |
| Rogue | Quick Strike / Backstab and **new nine-rank Vital Blow** rear-damage attack; Feint, Shadow Dash, Evasive Step and threat reduction; **six-rank Blade Mastery** server damage bonus. Duelist and Windstalker specializations use skill-specific prerequisite pairs and class-exclusive level-24/28/32 ranks. |

Existing 1/7/14 Mage introductory skill milestones and
5/10/15 Fighter/Ranger/Rogue training groups are kept.
Foundational starters now gate later ranks by character
level. Specialists require their own earned advanced
class, level brackets and full prerequisite skill ranks
with use-earned proficiency. A learned specialist skill
does not remain trainable or visible after a genuine
race/class change. The Rogue nine-rank Vital Blow
prerequisite is **rank 9 / proficiency 350**, not rank 3
of a nine-rank skill.

## Required server-side enforcement

- Shared `SkillUnlockRules` checks real purchased rank,
  earned proficiency, current level, allowed base class,
  owned active advanced class, race and persisted
  CompletedByRace advancement history.
- Profile-backed `SkillProgressionService` validates
  learning and rank purchases inside each profile mutation;
  class advancement checks its prerequisites before both
  starting and claiming the trial.
- Trainer offerings and skill snapshots do not advertise
  an unknown skill before its conditions are met.
  An already owned, but no longer valid foreign-class
  skill cannot be shown or trained as an available skill.
- Bow/Blade Mastery bonuses are read by existing combat
  multipliers, not inert inventory flags.
- Generic Mage projectiles spend mana **on server release**;
  the older Wind Strike-only branch would otherwise have
  made the new Mage spells free. Impact attribution now
  carries the actual Mage skill ID.

## Focused testing and precise limits

At earlier source `02154e8`, the new cross-family contract
passed **74 assertions**; directly affected
ClassAdvancementService passed **66 assertions**, and
the four earlier Fighter/Ranger advanced abilities passed
**60 assertions**. The first cross-family fixture needed
one correction: a C4-style training bracket permits
several ranks at the same character level, so the test
now checks the next *level bracket*, not an assumed
increase at every individual rank.

At `d1ca4fa`, both Base and Dungeon Rojo compositions
built, and the **74-assertion** cross-family test passed.
A separate read-only C4 rank-volume audit reported
**13 of 16 mapped Fighter/Mage race/level brackets
still mismatched**, with zero unmapped authored ranks
in its present coverage. **This audit does not cover
the new Ranger/Rogue source rank mapping yet**.
Do not mistake four-family *mechanic* coverage for
full C4 rank-count parity.

At final source `687e27c`, the Base composition built
and the focused **74 assertions** passed again after
raising the Rogue finisher's prerequisite to full
nine-rank mastery. This last metadata-only change
was not followed by a separate Dungeon rebuild.
New Mage spell client input, target impact, mana use
and finished UI presentation still need **one**
targeted real-client acceptance; a passing data/service
contract is not a physical playtest or balance result.

All script and document edits took place in GitHub.
Remote Desktop was used only for clean pulls, local
Rojo builds, focused Studio tests and read-only rank
audits. No `main` merge, Roblox place publish,
force-push or production profile operation occurred.
