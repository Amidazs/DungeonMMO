# DungeonMMO v2.54 — independent Elven Scout source-heal contract

Date: 25 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v2.53](
DungeonMMO_Roadmap_v2_53_C4_Authenticated_Nine_Class_Skill_Source_20260925.md).

## Source-only backend work committed; Studio deferred

The latest verified v2.53 baseline contains original C4 HP/MP/CP,
gear references and historical skill metadata for all nine currently
implemented Human/Elf starter and first-transfer paths. That data is
**not yet the live HP/MP/CP, inventory or skill executor**.

A new `C4ScoutHealMigrationPlan` creates nine distinct Scout-only
Elemental Heal source contracts directly from the pinned C4 level-30
skill tree and rank-resolved XML, not from the Warden's owned heal or
the Scout's existing 15-rank custom healing-over-time ability.
The original C4 skill 58 ranks 4–12 map to planned independent
creative ranks 1–9, in groups of three at character levels 20, 24
and 28. Each contract preserves its original SP, initial/ongoing
MP, power, self-target, cast time and reuse time. C4 skill power is
**not** direct Roblox HP healing; the original healing formula
and server-owned source MP pool remain prerequisites for live casting.

The source-only plan checks the actual complete character identity,
awarded original Elven Scout mentor receipt and supported level 20–30.
`C4AuthenticatedSkillSourcePreview` exposes it only on the nine
Scout-specific historical learning rows. It remains explicitly
`CreativeLinkStatus="Missing"`, `LiveLearnable=false` and
`LiveCastable=false`. No class trainer, player inventory, live skill
registry, mana cost, healing executor or profile has been changed.
The Warden retains its separate original 58 source preview and is
not granted Scout's planned family.

## Regression added in GitHub, NOT executed tonight

The existing nine-class source-preview test now checks all nine
Scout ranks against the pinned original rank XML and learning-tree
SP/level, authentic Scout level brackets 20/24/28/30, unearned
character and Warden denials, and that no missing creative skill is
misreported as live. The prior nine-path aggregate is still
476 historical learning rows, 454 candidate links and 22 explicit
missing rows until real skills and their source-equivalent executors
are independently implemented.

**No Rojo build or Studio execution is claimed for v2.54.**
Remote Desktop Commander is unavailable tonight at the owner's
request. Run the existing
`scripts/studio/c4_nine_class_authenticated_skill_preview_focus.luau`
in disposable unpublished Base Studio only when the owner explicitly
says Remote Desktop Commander is back online. Fix source/test failures
through GitHub, not through desktop script editing.

## Next implementation

After the source-only contract is verified, author the shared
source-formula HP/MP/CP healing and original split MP transaction
before adding this skill to the Scout trainer or live combat executor.
Then resolve the other 13 historical source learning-row gaps
across the nine paths without silently certifying candidate skills.
Review source-mapped gear, active buffs and status mechanics before
coordinated live migration, with anti-exploit and multiplayer tests.
The current separate v2.53 Studio results remain valid for the
previous candidate, not for this new untested commit.

No main merge, Roblox publication, production DataStore mutation or
separate animation/art worktree changes. All permanent edits in GitHub.
