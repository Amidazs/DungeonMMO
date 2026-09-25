# DungeonMMO Roadmap v2.64 — C4 Active Effect Boundary

Date: 25 September 2026.  
Branch: `wip/phase-4-test-hud-integration-v1`.  
Previous documented checkpoint: [v2.62](
DungeonMMO_Roadmap_v2_62_C4_Authoritative_Active_Source_State_20260925.md).

## Goal

Finish the active-effect side of the Chronicle 4 resource migration boundary.

This checkpoint includes the v2.63 timed-effect bridge and the v2.64
authenticated resource-boundary composition.

## Timed active state

The private `C4ActiveSourceEffectState` registry now supports:

- indefinite live toggles;
- timed server-owned effects with monotonic expiry;
- resolved C4 ACTIVE/TOGGLE ranks;
- unresolved live effects retained as explicit fail-closed rows;
- respawn invalidation;
- duplicate source-family collapse to the highest active source rank.

`CombatStatusService` now reports successfully applied timed self-buffs to
the registry using the authoritative purchased rank paired with the cast.

`IronvowEnduranceSurgeService` reports activation and early termination.

Migration diagnostics cannot reject or alter the existing pre-cutover timed
buff gameplay path; unresolved effects are recorded instead of disappearing.

## Persistent active catalogue gate

A launch-cap audit now proves every currently trainable persistent stat-effect
rank through level 30 has a reviewed ACTIVE/TOGGLE C4 source mapping.

Current coverage:

- 21 persistent creative skills;
- 25 launch-reachable ranks;
- 25/25 mapped;
- 0 missing;
- 0 mapping-review rows.

The audit also caught two progression mistakes:

- Ironvow Battle Call incorrectly exposed invented first-transfer ranks 2/3.
  Human Warrior C4 War Cry rank 1 is the only first-transfer rank through this
  stage; source rank 2 belongs to a later second-transfer class at level 43.
  Ironvow is now capped at rank 1.
- Oathguard Arrow Ward rank 2 incorrectly unlocked at level 28. C4 Human
  Knight Deflect Arrow rank 2 unlocks at level 32, so only rank 1 is reachable
  in the initial level-30 game.

An accidental unrelated Ashenblade rank edit made during that correction was
identified from the GitHub commit diff and reverted before acceptance.

## Active source composition at the migration boundary

`C4ResourceMigrationBoundary` now accepts a private authoritative active
snapshot and validates it independently:

- authority flag is mandatory;
- unresolved live effects reject active readiness;
- malformed source rows reject;
- duplicate source skill IDs reject;
- active source ranks are rechecked against the character's real class and
  level by `C4UnifiedStatReference`.

Owned passives and currently active effects are then composed together in the
same C4 calculator queue, preserving 0x30/0x40 ordering and stack-group rules.

`ProgressionRuntimeState` receives the private active snapshot through an
injected server provider. `CombatService` owns that provider wiring, avoiding
a require cycle between the progression runtime and active registry.

For a clean current character the active-effect blocker is now closed. The
only fixed coordinated resource-migration blocker is:

1. `LiveCPRuntimeUnavailable`.

No HP/MP/CP live cutover has occurred yet.

## Fresh local acceptance

Final tested commit:

`1e01640f5eda5729d6feb1564dbe2f1edf2b2204`

Fresh disposable builds:

- Base Rojo build: PASS;
- Dungeon Rojo build: PASS.

Focused Studio:

- Base: **10/10 PASS**;
- Dungeon: **11/11 PASS**.

Key assertion counts:

- C4ResourceMigrationBoundaryTest — 47;
- C4CombinedStatEffectReferenceTest — 14;
- C4ActiveSourceEffectStateTest — 17;
- C4PersistentActiveCoverageTest — 4;
- C4NineClassAuthenticatedSkillPreviewTest — 554;
- C4CreativeItemSourceMapTest — 61;
- C4SixSlotPaperdollSourceTest — 11;
- C4OwnedPassiveSourceResolverTest — 7;
- ManaServiceTest — 13 in Dungeon.

Evidence directory:

`%TEMP%\DungeonMMO_v264_active_boundary_r2`

Studio emitted OpenXR runtime warnings during startup on the second run. The
requested focused scripts still completed and all acceptance results were
green.

## Next backend implementation

Implement a server-authoritative C4 Combat Point runtime without allowing CP
to leak into ordinary dungeon PvE damage.

The next checkpoint should:

1. create authoritative current/max CP lifecycle state;
2. derive max CP only from the authenticated C4 source candidate;
3. preserve the C4 rule that CP is a PvP resource rather than generic monster
   damage absorption;
4. clear/reset CP safely on respawn and player removal;
5. expose CP readiness to the migration boundary;
6. leave the actual HP/MP/CP cutover disabled until the full transition is
   accepted.

Permanent scripts/documents remain GitHub-only. Remote Desktop Commander is
restricted to fast-forwarding, disposable builds and unpublished tests.
