# DungeonMMO v2.52 — authenticated C4 vitals preview for nine paths

Date: 25 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`. Executed candidate `ab53b20701db23fad272f12b77fe4c472ca72743`.
Previous: [v2.51](DungeonMMO_Roadmap_v2_51_C4_Nine_Class_Pinned_Item_Stats_20260925.md).

## Source vitals via the actual server-owned class identity

`ProgressionRuntimeState.get_c4_source_vitals(user_id)` now
reads exclusively the authoritative, currently seeded server
character snapshot. It verifies the complete race/class
identity and, for any first-transfer class, the saved original
quest proof and mentor receipt via
`C4PrimaryStatReference.for_character`. Original archived
class/level HP, MP and CP then resolve through the pinned
source growth provider for levels 1-30.

The result explicitly identifies its C4 source commit and
has `SourceOnly=true`, `LiveApplied=false`,
`ItemBonusesIntegrated=false` and
`ActiveEffectsIntegrated=false`. No client-submitted
class name can grant a first-transfer stat curve. Missing
server state, forged receipt, wrong original race and
unverified level 31 fail closed.

## Focused Studio and build evidence

Both unpublished disposable Base and Dungeon Rojo builds
passed. The focused unpublished Base Studio runner
`c4_authoritative_runtime_stat_preview_focus.luau`
reported `SOURCE_ONLY_PASS: 31 assertions nine_paths=9
live=false` and `VERIFIED_SOURCE_ONLY_NOT_LIVE`.
Every one of the four original starters and five authentic
first-transfer test fixtures matched its distinct C4
level-30 HP/MP/CP source vector. The test also checked
missing profile, forged mentor, wrong race and unsupported
level 31. [Evidence](
../testing/c4-nine-class-authoritative-runtime-stat-preview-v2-52-20260925.md).

The earlier v2.51 46-assertion source-gear test was separately
executed; its nine pinned source sample item IDs are NOT
creative game inventory IDs or a full equipment catalog.

## The next migration gates

This is a reliable server-authoritative *preview*, NOT the
live player's Humanoid MaxHealth, ManaService max MP, CP,
HUD, regeneration, damage or healed HP. The live custom
Vitality/Spirit/mana and bespoke Roblox passive values
remain unchanged. Switching just the health getter while
leaving skill costs, equipment, stat persistence and HUD
on a different scale would break balance; plan and validate
the entire nine-class live stat/skill migration together.

The all-nine source tree contains 476 original learning
rows, of which 454 still have candidate creative links,
22 explicit gaps (including nine Scout Elemental Heal
ranks). Candidate link != equal skill effect; the exact
C4 combat formula/equipment/status/reuse and normal MP
economy still need coherent live integration.

Do not merge to main, publish Roblox places, alter
production DataStore saves or change unrelated art/animation.
Permanent code/docs were edited in GitHub. The desktop was
used only to pull fast-forward, build disposable Rojo
places and run the focused unpublished Studio test.
