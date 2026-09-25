# DungeonMMO Roadmap v2.65 — C4 Combat Point Runtime

Date: 25 September 2026.  
Branch: `wip/phase-4-test-hud-integration-v1`.  
Previous: [v2.64](
DungeonMMO_Roadmap_v2_64_C4_Active_Effect_Boundary_20260925.md).

## Goal

Close the final coordinated Chronicle 4 resource-migration prerequisite by
adding a server-authoritative Combat Point (CP) runtime without changing
ordinary Dungeon PvE or enabling the live HP/MP/CP cutover.

Pinned source remains:

`Neco-spain/l2jadmins_C4-Scions-of-Destiny`  
commit `07f8536384e799f128d44198dd7ab23519660eea`.

## Pinned C4 CP behaviour verified

The pinned C4 source was rechecked before acceptance.

`Formulas.calcCpRegen` and `Formulas.getRegeneratePeriod` establish:

- one regeneration task every **3 seconds**;
- CP starts from the class template's `BaseHpRegen`;
- levels 1–10 add 0.5;
- above level 10, Java integer division adds
  `(level - 1) / 10`;
- the result is multiplied by the C4 level modifier and CON bonus;
- sitting multiplies by 1.5;
- standing multiplies by 1.1;
- walking/moving without running remains x1;
- running multiplies by 0.7;
- the default `CpRegenMultiplier` is 100%, represented as 1.0.

`PcStatus.reduceHp` establishes the damage rule:

- only an attacker that is an `L2Playable` consumes defender CP;
- CP absorbs that damage first;
- damage exceeding CP continues to HP;
- NPC/non-playable damage bypasses CP.

That means CP remains a PvP/playable-attacker resource and does **not** become
a generic extra health bar against dungeon monsters.

## Source rules

Added
`C4CombatPointSourceRules.luau`.

It provides:

- exact source CP regeneration per three-second tick;
- all four movement multipliers;
- playable-attacker CP-first damage resolution;
- NPC/non-playable bypass;
- pinned source provenance and capability metadata.

## Server CP runtime

Added
`C4CombatPointRuntime.luau`.

The runtime owns current/max CP in private server state and supports:

- character-bound lifecycle state;
- detached authoritative snapshots;
- CP restoration clamped to source maximum;
- playable-attacker CP absorption;
- NPC damage bypass;
- stale-state invalidation on character replacement;
- explicit clear;
- fail-neutral behaviour while unconfigured.

The runtime is **not configured automatically**. Merely installing the module
does not alter current damage.

### Source-only maximum

The public configuration route is now
`configure_from_boundary(...)`.

It does not accept an arbitrary maximum CP value. The supplied migration
boundary must certify:

- all coordinated source prerequisites are ready;
- the source stat candidate is ready;
- base source vitals are certified;
- source commit matches the pinned C4 commit;
- the final `SourceStatCandidate.MAX_CP` is finite and non-negative.

This ensures the future CP maximum comes from the authenticated C4 source
candidate rather than a client value or custom Roblox stat.

## Resource boundary

`ProgressionRuntimeState` supplies the isolated CP runtime capability to
`C4ResourceMigrationBoundary`.

The boundary strictly requires:

- server authority;
- character-bound runtime state;
- source-derived max-CP configuration;
- playable-attacker-only absorption;
- NPC bypass;
- three-second source regeneration timing;
- lifecycle clear support;
- pinned source commit;
- disabled-by-default live configuration.

For a clean reviewed character there are now **zero coordinated migration
blockers**.

This means the source prerequisites are ready. It does **not** enable live
resources:

- `CutoverPrerequisitesReady=true`;
- `CanApplyLive=false`;
- `LiveHealthIntegrated=false`;
- `LiveManaIntegrated=false`;
- `LiveCPIntegrated=false`.

The live switch remains deliberately disabled.

## Fresh local acceptance

Commit tested:

`2aae512409e00bb1f706ae11b7ebe689c4e4ce60`.

Fresh disposable builds:

- Base Rojo build: PASS;
- Dungeon Rojo build: PASS.

Focused Studio:

- Base: **11/11 PASS**;
- Dungeon: **12/12 PASS**.

Key assertions:

- C4ResourceMigrationBoundaryTest — 47;
- C4CombatPointRuntimeTest — 18;
- C4CombinedStatEffectReferenceTest — 14;
- C4ActiveSourceEffectStateTest — 17;
- C4PersistentActiveCoverageTest — 4;
- C4NineClassAuthenticatedSkillPreviewTest — 554;
- C4CreativeItemSourceMapTest — 61;
- C4SixSlotPaperdollSourceTest — 11;
- C4OwnedPassiveSourceResolverTest — 7;
- ManaServiceTest — 13 in Dungeon.

CP-specific acceptance proves:

- exact level-30 Human Fighter source regeneration arithmetic;
- exact sitting/standing/walking/running multipliers;
- exact level-1–10 half-point rule;
- exact three-second period/default multiplier/provenance;
- CP-first playable damage;
- NPC damage bypass;
- unconfigured runtime leaves damage unchanged;
- uncertified arbitrary max CP is rejected;
- certified source-boundary max CP is accepted;
- restore clamps to source max;
- non-refill reconfiguration preserves/clamps current CP;
- character replacement invalidates old CP state.

Evidence directory:

`%TEMP%\DungeonMMO_v265_cp_runtime`

No Roblox publish, production DataStore mutation or main merge occurred.

## Next backend implementation

Build the coordinated **disabled-by-default live resource cutover service**.

The next checkpoint should:

1. use the authenticated migration boundary as the sole source of final
   HP/MP/CP maxima;
2. preserve current resource fractions safely when maxima change;
3. keep the feature disabled by default so current Dungeon gameplay is
   unchanged;
4. configure/clear CP only while the C4 resource mode is explicitly active;
5. route player-vs-player/playable damage through CP without routing NPC
   Dungeon damage through CP;
6. move ManaService maximum/current authority to the source candidate only
   while C4 mode is active;
7. move Humanoid MaxHealth/current health to the same source candidate only
   while C4 mode is active;
8. include an explicit rollback/disable path;
9. acceptance-test enable, update, respawn, PvP CP absorption, NPC bypass,
   disable and rollback before considering default activation.

Permanent scripts/documents remain GitHub-only. Remote Desktop Commander is
restricted to fast-forwarding, disposable builds and unpublished tests.
