# DungeonMMO backend v2.25 — Elven Knight source inventory

Date: 24 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous [fighter class-tree checkpoint](
DungeonMMO_Roadmap_v2_24_Human_Elven_Fighter_Path_Gap_20260924.md).

## Historical source rows now recorded

Reference: https://l2hub.info/c4/classes/elven_knight
(C4 Elven Knight class skill listing, level 20, 24 and 28 only).
`C4ElvenKnightLevel30Sources.luau` stores independently counted
skill-family rank opportunities, not game skills or copied names.
It preserves the separately levelled Charm (enemy threat reduction)
and Aggression (enemy taunt) families, elemental healing,
shield/armour/magic defence, physical attack aura and cure skills.

| Source class | Level 20 | Level 24 | Level 28 | Total rows | Playable mapped rows |
|---|---:|---:|---:|---:|---:|
| Elven Knight | 18 | 18 | 20 | **56** | **0** |

Only the **source inventory** is complete. There is no Elven Knight
class award, distinct trainer, quest or new character-facing ability.
The proposed display name **Greenward Warden** is not registered
as a playable career, and `GreenwardScout` remains its own
independent Elven Scout class. Do not count Knight ranks toward
Scout, or Human Knight's mapped ranks toward Elven Knight.

`C4Level30LaunchCoverage` now reads the independent Elven Knight
source and reports `SourceRanksAuditedClassUnimplemented`,
`MissingRankScheduleEntries=56`, with no mapped career. The
focused launch-coverage test asserts this and the original Human
three/Elf two Fighter advancement options. New assertions are
written and built, not yet executed in Studio.

Across all 18 original first transfers: **5** source inventories
audited (the prior four + Elven Knight), **4** rank schedules
mapped, **13** source inventories still unaudited and **0**
classes certified for complete C4 mechanics or release.

## Implementation order and non-negotiable tests

1. Finish v2.23 stored-avatar recovery/surge real-client Play checks
   and do not attribute old-client evidence to the new source.
2. Create a distinct Elven Knight quest, trainer and saved
   first-transfer career, separate from Human Oathguard and Elven
   Scout. Verify player choice and race/class/receipt anti-forgery.
3. Implement the historical 56 rank rows as independent purchasable
   skills and server-owned effects, beginning with non-stacking
   armour and sword/blunt mastery, then shield/elemental heal,
   two opposing threat skills, cure and auras. Keep source numbers
   explicit and distinguish Roblox combat-stat adapters from
   mathematically proven C4 balance.
4. Run focused test coverage for real enemy HP, player HP/MP,
   healing owner isolation, threat, stun/defence stacking and
   two clients before increasing any release-readiness indicator.
   Then validate authentic saved level-1-to-30 cross-place play.

Preserve one gathering/one crafting profession, no `main`
merge, public Roblox publish, production DataStore mutation
or unrelated humanoid/quadruped animation edits. Permanent
source and docs through GitHub; desktop only for targeted
disposable unpublished builds/Studio tests.
