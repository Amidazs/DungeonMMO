# C4-inspired Mage starter skills and actual level-gated presentation

Date: 22 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Focused tested gameplay source: `e6033e0c1a024837eef62fdea6cecc1c280beb8a`

## New player progression content

The existing Mage starter set (Wind Strike, Arcane Ward, Mage Heal)
remains intact. Two **additional** server-authorized Mage skills are
available through the existing trainer at level one:

| Original DungeonMMO skill | Rank-1 effect | Rank-2 effect | Rank-3 effect | Rank levels |
| --- | --- | --- | --- | --- |
| Dawn Ward | 14 protection | 21 protection | 29 protection | 1 / 7 / 14 |
| Cinder Bolt | 12 magic damage | 18 magic damage | 25 magic damage | 1 / 7 / 14 |

Each skill has a separate, actual ward/projectile effect using the
already-validated server combat executors. New rank purchases require
the character's level, available SP and earned skill proficiency:
35 for rank 2 and 100 for rank 3. The value is checked again by the
server at purchase; clients do not set their own training proficiency.
Only Mage characters can learn them. They can be earned and ranked
without a new engine or replacing old character skill records.

The actual player skill menu now hides skill rows **absent from the
authoritative filtered progression snapshot**. Previously it created
and displayed buttons for *every* public combat definition, including
future, foreign-class skills that the server did not offer. Already
learned skills remain visible so players do not lose access to their
history when an advanced class changes.

The Base trainer receives new snapshot fields for its next rank's
level/mastery blocker. A known ability stays listed, but its next
rank is disabled with an explanation (required level, prerequisite
rank or proficiency); an unknown skill below its first unlock level
is omitted from the trainer. The server remains the sole purchase
authority even if a client ignores the UI.

## Focused verification and limits

- Clean GitHub feature fast-forward; one unpublished Base Rojo build
  passed at source `e6033e0`.
- `scripts/studio/c4_starter_mage_skill_tests.luau` passed
  **39 assertions**. It exercises both new learn/purchase paths,
  level-1/7/14 gates, proficiency 35/100 gates, server combat
  definition values at all three ranks, trainer/snapshot hiding of
  unreached abilities, class exclusion and save/reload durability.
  The fixture seeds earned proficiency through its isolated
  authoritative test profile; it is **not** a real live-combat
  claim.
- The existing **read-only** C4 source-rank volume audit was run
  once at the same source. It still reports **13/16 mapped
  brackets mismatched and 14 unmapped older skill-rank occurrences**.
  In both mapped Mage races, level-1 explicit ranks increased from
  0 to 2 and level-7/14 counts increased from 10 to 12. The
  Human Mage levels 1/7/14 still lack 5/3/9 mapped ranks;
  the Elf Mage levels 1/7/14 still lack 5/2/8.
  Human Fighter level-10 is still over by 1. Count parity,
  skill-role parity, completed race trees and source-faithful
  numerical balance **have not been achieved**.

**Still outstanding:** a focused in-client visual trainer/skill-menu
interaction and actual Ward/projectile impacts; the service
snapshot and combat definitions were tested, not a full Play
session showing the live GUI and combat. Full C4 rank
parity requires more *real* early abilities/passives and
explicit mapping of existing starter ranks, not invented
dummy icons or further dungeon wipe/revive tests.

All scripts and docs were authored directly in GitHub.
Remote access was used only for a clean pull, a Base build,
focused unpublished Studio test and read-only count audit.
No `main` merge, place publishing, paid transaction or
production DataStore operation occurred.
