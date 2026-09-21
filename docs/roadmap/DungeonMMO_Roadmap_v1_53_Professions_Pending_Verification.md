# DungeonMMO Roadmap v1.53 — Leatherworking / Enchanting staged

**Date:** 21 September 2026  
**Status:** GitHub implementation checkpoint, **pending local verification**  
**Branch:** `wip/phase-4-test-hud-integration-v1`

This supplement follows the accepted v1.52 Event-variation /
Blacksmithing-Alchemy checkpoint. It records source work completed while
the authorized Windows desktop is offline. It does **not** claim a new
Studio acceptance result and does not replace the historical canonical
`DungeonMMO_Roadmap_v1_47.docx`.

## Implemented in GitHub

### 1. Profession coverage expanded

The shared profession system now covers:

- Mining ↔ Blacksmithing
- Herbalism ↔ Alchemy
- Skinning ↔ Leatherworking
- Enchanting as a creation profession consuming products from multiple
  other profession chains

Leatherworking and Enchanting retain the same Level/XP progression
framework, recipe catalogue, inventory authority and server-side
completion boundary already used by Blacksmithing and Alchemy.

### 2. Multi-profession dependency chain

The staged backend can produce `warded_leatherbound_gloves` through
one connected chain:

`raw_hide`
→ Leatherworking + Alchemy oil → `cured_leather`
→ Leatherworking + Blacksmithing bar → `leatherbound_gloves`
→ Alchemy/Blacksmithing reagents → `warding_essence`
→ Enchanting + Blacksmithing bar → `warding_rune`
→ Enchanting + Leatherworking gloves + Alchemy flux
→ `warded_leatherbound_gloves`.

The result intentionally requires contributions from more than one
profession instead of allowing each creation profession to be entirely
self-contained.

### 3. Placeholder acquisition/stations

A server-claimed Base `RawHideCache` supplies Skinning material until
creature harvesting is authored. Leatherworking and Enchanting use
separate temporary station roots derived from existing Base profession
anchors. These are backend placeholders, not final models or art.

### 4. Craft request authority tightened

The server-side Base crafting RemoteEvent still accepts only the recipe
identity. A client does not submit a craft-success/minigame-success
payload. The server checks the recipe's required station and player
distance before crafting.

A new per-player request guard rejects overlapping craft requests from
the same player with `CraftRequestInProgress`. The guard releases after
the request finishes or the player leaves; other players use independent
request lanes. Ingredient/output mutation remains inside
`ProfessionService` and `ProfileService`.

## Tests written but not yet executed

The staged source includes:

- expanded profession-definition contract coverage;
- new-profile and legacy-profile migration checks;
- a complete Skinning/Leatherworking/Alchemy/Blacksmithing/Enchanting
  dependency test using actual service APIs and in-memory persistence;
- equipped-item and wrong-minigame rejection;
- duplicate output prevention and save/reload assertions;
- server station-distance and overlapping-request guard tests;
- an expanded focused profession runner.

The exact staged test plan and scope are recorded in:

`docs/testing/profession-leatherworking-enchanting-pending-verification-2026-09-21.md`.

## Acceptance boundary

Because the Windows desktop is offline, this v1.53 checkpoint is
**implemented, not accepted**. No new assertion/suite/build counts should
be quoted as passing until the branch is pulled and executed locally.

Tomorrow's intended acceptance gate is:

1. safe fast-forward pull into the existing clean worktree;
2. all four Rojo build compositions;
3. focused profession suites in Base and Dungeon builds;
4. broad backend regression matrix;
5. real Base Play-mode station interaction test:
   - too-far request rejected;
   - correct station request accepted;
   - rapid duplicate request cannot double-consume/double-create;
   - Skinning hide claim is one-time per Base visit;
   - Leatherworking and Enchanting chain reaches final equipment;
   - disconnect/retry does not leave the request guard stuck.

Only after those pass should v1.53 be promoted from pending to locally
accepted.

## Remaining profession backend after this staged increment

Even if tomorrow's tests pass, the profession backend will still need
later content/acceptance work rather than being considered the whole
MMORPG crafting system:

- authored/real Skinning from creatures rather than the hide-cache
  placeholder;
- final interactive minigames rather than foundation server auto-success;
- broader recipe/blueprint catalogue and item tiers;
- balancing profession XP/material quantities;
- market/economy integration of crafted materials/equipment;
- real-user DataStore migration/cloud TEST acceptance.

After the profession interaction checkpoint, backend priority should move
to the next large MMORPG milestone rather than continuing to expand
placeholder crafting indefinitely: raid/weekly-world-boss lifecycle,
then guild/castle competition and full progression/economy integration.

## Operational constraint

No Remote Desktop, local pull, Studio run, Roblox publish, DataStore
mutation, force-push or main merge was performed for this v1.53 staging
work. Continue GitHub-first until the desktop is available again.
