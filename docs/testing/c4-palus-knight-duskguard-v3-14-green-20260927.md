# Palus Knight / Duskguard v3.14 — GREEN

Date: 27 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Accepted candidate:
`07d8c6f83bf1965e7b685c702496b1db527053d3`.

## Build and Studio

- `git diff --check`: PASS.
- Base Rojo build: PASS.
- Dungeon Rojo build: PASS.
- Fresh critical Studio batch: 5 / 5 PASS.
- Fresh complete Duskguard backend batch: **23 / 23 PASS**.
- Final project CreatorError count: **0**.

## Source catalogue

- Palus Knight source rows: **50 / 50 mapped**.
- Creative families: **13**.
- Missing Palus Knight source rows: **0**.
- Tracked source totals: **14 paths / 880 rows / 117 skill IDs**.

## Play-mode evidence

Fresh unpublished Play place:
`DungeonMMO_Duskguard_Acceptance5.rbxlx`.

Observed real runtime evidence:

- `CHALLENGE_PASS threat=803 damage=0`;
- `LAST_STAND_PASS duration=30 immobile=true`;
- `UMBRAL_SIPHON_PASS damage=282.90185546875 heal=28.9453125`;
- `CHALLENGE_PLUS_LAST_STAND_PLUS_DRAIN_PASS`;
- `VERIFIED_PLAY_MODE_PASS`.

The test used an actual admitted Studio player, authentic Duskguard progression,
the real source cutover coordinator, live ThreatService, live player
immobility, real NPC HP mutation and live drain healing.

## Integration fix discovered by Play

The first Play attempt correctly failed at Challenge with
`OriginalMagicTimingRequired`. This identified a real backend defect rather
than a rehearsal problem.

The source timing service was corrected to support non-magic active skills
using P.Atk.Spd and PHYSICAL_SKILL_REUSE while retaining M.Atk.Spd,
MAGICAL_SKILL_REUSE and shot acceleration for magic skills. A dedicated
physical-timing regression now passes in fresh Studio.

No production state was changed and nothing was published.
