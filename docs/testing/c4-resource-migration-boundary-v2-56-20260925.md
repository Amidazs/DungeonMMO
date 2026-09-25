# C4 Resource Migration Boundary v2.56 — Test Status

Date: 25 September 2026.  
Branch: `wip/phase-4-test-hud-integration-v1`.

## Scope

v2.56 defines a server-authenticated, fail-closed boundary for eventually
switching all nine current original Human/Elf paths from the existing custom
resource model to source C4 HP/MP/CP.

## Authored coverage

`C4ResourceMigrationBoundaryTest.server.luau` checks:

- exact level-30 source HP/MP/CP for all nine supported original paths;
- all four coordinated blockers remain present;
- `CanApplyLive` remains false;
- live health, mana and CP flags remain false;
- a missing authoritative owner is denied;
- a copied first-transfer class without the original mentor receipt is denied;
- level 31 is rejected because the current reviewed launch source stops at 30.

Expected exact level-30 vectors:

- Human Fighter 922 / 319 / 418;
- Human Mystic 699 / 466 / 366;
- Elven Fighter 792 / 324 / 353;
- Elven Mystic 666 / 469 / 348;
- Ironvow 1070 / 320 / 849;
- Oathguard 1018 / 320 / 610;
- Ashenblade 983 / 320 / 399;
- GreenwardWarden 902 / 325 / 453;
- GreenwardScout 874 / 325 / 354.

## Not yet executed

No Rojo build, Studio test runner or client Play execution is claimed for
v2.56.

The earlier v2.53 500-assertion source-skill preview and previous C4 stat
reference passes do not validate these new files.

## Deliberate non-claims

This milestone does not certify live C4 balance or resource adoption. The
following still block live cutover:

- complete current-item to original-item migration;
- actually owned passive-rank translation;
- active buff/status ordering;
- CP runtime authority;
- Humanoid, ManaService and HUD integration;
- multiplayer/interruption/exploit acceptance after the switch.
