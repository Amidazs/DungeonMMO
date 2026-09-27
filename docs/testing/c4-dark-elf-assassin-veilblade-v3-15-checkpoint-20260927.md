# Dark Elf Assassin / Veilblade v3.15 — GREEN Acceptance

Date: 27 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Accepted code/test HEAD before documentation:
`519185ca0c41d2969901d2454045d45ea3527315`.

## Accepted backend scope

Dark Elf Assassin source class 35 is represented by the independent creative
first-transfer class **Veilblade** through level 30.

Accepted coverage:

- **72 / 72** source rank rows;
- **23** creative skill families;
- **0** source-map gaps;
- exact primary stats STR 41 / DEX 34 / CON 32 / INT 25 / WIT 12 / MEN 26;
- exact level-30 resources HP 831 / MP 325 / CP 337;
- six Veilblade-specific source-cast families;
- shared Scout/Wayfinder passives, toggles, lockpicking, bow and dagger
  families;
- raw source DEX and neutral `BLOW_RATE` available to live combat;
- C4 Mortal Blow / Wayfinder Cut `BLOW` success and damage resolution;
- real blow misses preserved without mutating target HP.

## Focused Studio acceptance

Fresh unpublished acceptance completed on the generated Dungeon place.

- `git diff --check`: PASS;
- Dungeon Rojo build: PASS;
- focused backend/formula set: **29 / 29 PASS**;
- C4 combat formula regression: PASS;
- source combat calculation regression: PASS;
- live source combat executor regression: PASS;
- Veilblade cast bridge and Dungeon cast composition: PASS.

The additional 29th focused suite was the common C4 combat-formula regression,
added after Play exposed that Mortal Blow was still rejected as an unsupported
physical skill type.

## Defects closed during acceptance

The acceptance cycle found and fixed genuine project defects rather than
weakening the test gate:

1. Defense Aura live rehearsal expected source rank 1 instead of mapped rank 2.
2. The live harness did not yet exercise poison, shared dagger/blow or a shared
   passive path.
3. Source combat accepted `PDAM` but not C4 `BLOW`.
4. Raw DEX had been read from the derived naked record, which only exposes
   `DEXBonus`; raw DEX now comes from retained primary stats.
5. Staged unified-stat candidates did not retain `PrimaryStats`.
6. The new formula used `Behind` while the existing authoritative spatial
   vocabulary uses `Back`.

## Unpublished Play acceptance

The genuine Play rehearsal passed through the live runtime.

Observed accepted markers:

- `SCOUT_FLEET_FOOT_PASS multiplier=1.06`;
- `DEFENSE_AURA_PASS duration=1200`;
- `UMBRAL_SIPHON_PASS` with real NPC damage and caster healing;
- `VENOM_HEX_PASS landed=true`;
- `WAYFINDER_CUT_PASS damage=870.1875 chance=79.80000000000001`;
- `CRIMSON_STING_PASS` with real damage and landed bleed;
- `AURA_DRAIN_VENOM_BLOW_STING_PASS`;
- `VERIFIED_PLAY_MODE_PASS`.

Final accepted Play log: **0 project CreatorErrors**.

The Wayfinder Cut chance is the expected C4 rear-position calculation for
Veilblade DEX 34: base 70 multiplied by `1 + (34 - 20) / 100` = **79.8%**.
The live implementation keeps the source server-owned random roll, so a miss is
a valid result and does not deal zero-damage bookkeeping as a hit.

## Boundaries

No `main` merge, Roblox publish, production DataStore mutation or animation
changes were performed.
