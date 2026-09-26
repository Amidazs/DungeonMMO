# DungeonMMO Roadmap v3.14 — Palus Knight / Duskguard level 30

Date: 27 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.

## Status

**GREEN — backend catalogue, Studio acceptance and unpublished Play rehearsal pass.**

Accepted candidate:
`07d8c6f83bf1965e7b685c702496b1db527053d3`.

Evidence:
[Duskguard v3.14 green](
../testing/c4-palus-knight-duskguard-v3-14-green-20260927.md).

## Level-30 source coverage

Palus Knight / Duskguard now has:

- 50 / 50 source rank rows mapped;
- 13 reviewed creative skill families;
- zero explicit Palus Knight source gaps;
- exact Dark Elf / Fighter / Duskguard first-transfer identity;
- reviewed passive, buff, debuff, drain, aggression and physical-status paths.

Tracked source coverage is now 14 paths, 880 rows and 117 unique source skill IDs.

## Physical cast timing closure

The genuine Play rehearsal exposed a real integration gap hidden by fake
schedulers: non-magic active skills were rejected by the source timing service
with `OriginalMagicTimingRequired`.

The timing pipeline now follows the pinned C4 source for both skill families:

- magic skills use M.Atk.Spd and MAGICAL_SKILL_REUSE;
- physical skills use P.Atk.Spd and PHYSICAL_SKILL_REUSE;
- both use the source 333 / attack-speed cast scaling;
- the 500 ms authored-hit floor applies to both;
- Spiritshot acceleration remains magic-only;
- physical skills never read or consume magical shot state.

This closes real scheduling for Challenge, Crimson Sting and other physical
Duskguard actives instead of allowing only their mocked tests to pass.

## Fresh Studio acceptance

Fresh unpublished Studio acceptance on
`DungeonMMO_Duskguard_Acceptance5.rbxlx`:

- focused changed/critical batch: 5 / 5 PASS;
- complete Duskguard backend batch: **23 / 23 PASS**;
- CreatorError count: **0**.

## Genuine unpublished Play rehearsal

The real Play-mode rehearsal passed:

1. authentic level-30 Dark Elf Duskguard progression bound;
2. source cutover enabled for the actual connected Studio player;
3. **Challenge** applied 803 threat and zero damage;
4. **Last Stand** applied its 30-second self buff and live immobility;
5. **Umbral Siphon** dealt about 282.90 real NPC HP damage;
6. Umbral Siphon restored about 28.95 real caster HP;
7. source cutover and owner state were cleanly rolled back;
8. final marker: `VERIFIED_PLAY_MODE_PASS`;
9. project CreatorErrors: **0**.

## Next class

Continue the Dark Elf Fighter first-transfer catalogue with the other C4 path:
**Assassin**, using a copyright-safe DungeonMMO creative class name while
preserving the exact level-30 source progression and skill values.

No `main` merge, Roblox publish, production DataStore mutation or animation
work was performed.
