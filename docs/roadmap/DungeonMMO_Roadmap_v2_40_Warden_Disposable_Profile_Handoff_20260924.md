# DungeonMMO backend v2.40 — Warden multi-service profile persistence

Date: 24 September 2026. Branch: `wip/phase-4-test-hud-integration-v1`.
Executed candidate `8a1c2a5fb39ec0ae65d0c1b4613dfac9cd0b2b93`.
Previous: [v2.39](DungeonMMO_Roadmap_v2_39_Natural_Captain_Bleed_Rig_20260924.md).

## Actual independent profile-service save and reload

A new focused unpublished Base test
`C4GreenwardWardenProfileHandoffTest` uses multiple separately
created `ProfileService` instances sharing exactly **one
disposable InMemoryProfileAdapter**. Each place-like service
actually saves and releases its writable owner cache before a
new service loads the same saved profile. A second user is loaded
independently and cannot receive either private quest material.

The first test-only Base profile is intentionally prepared at
original Elven Knight quest stage four with three bound
`verdant_patrol_report` items and the saved aggregate source
proof. The reports are **test-seeded in this specific persistence
fixture**; their authentic real client-earned creation was
separately proven in [v2.38](
DungeonMMO_Roadmap_v2_38_Warden_Three_Reports_Owner_Gates_20260924.md).

The actual profile cache is then released, loaded by an
independently constructed Dungeon-like profile service and
released again. A new Base-like service reloads the same
three reports, stage and branch, and the real original quest
transaction consumes all three through a one-use **test-only
world-signed** Warden Caer NPC event. The test-only boss seal
is prepared for a later step and survives yet another
independent saved reload; the real quest service consumes it
through a second signed NPC event. The now-ready original
quest and level-20 owner gain Greenward Warden only from a
fresh, signed one-use mentor event, then buy Steel Training
rank one through the actual skill progression authority.
A final independent profile-service reload verifies the
quest's ready/completed stage, authentic class award, paid
rank and zero remaining report materials.

The focused Rojo Base build and Studio run recorded
`[Warden Handoff] PASS: 52 assertions` and
`[Warden Handoff] VERIFIED_FOCUS_PASS` in
`%TEMP%\\DungeonMMO_v246_warden_handoff\\handoff.log`.
See [v2.40 evidence](../testing/greenward-warden-v2-40-profile-cache-reload-20260924.md).

## Scope and next backend work

This validates state migration, save/release and reload
across distinct service instances with one in-memory store.
It is **not** a real Roblox Base->Dungeon TeleportService
handoff, a shared production DataStore/rejoin, a real
cross-place session lease or an uninterrupted physical
player quest. Do not merge those independent evidence
categories into a single claimed end-to-end live pass.
The existing v2.36 physical Base NPC/mentor/trainer,
v2.38 full 3/3 client-earned report stage in two real
Dungeon rooms, and v2.39 natural CaptainSlash->real client
Bleed Recovery remain separately passed.

Elven Knight 56/56 historical training *rank schedules*
remain mapped, but exact original C4 effect and combat
balance parity and complete mechanical/release acceptance
remain OPEN. Five of 18 original first-transfer paths
have complete source-rank schedules; none of 18 are
fully mechanically/release certified. Continue remaining
original C4 classes/skills and targeted cross-class tests.
Real published cross-place travel/save/rejoin remains
deferred until authorization for a safe test environment.

No main merge, public publish, production DataStore mutation,
or unrelated animation/art source modification. Permanent
scripts and docs through GitHub; local desktop used only
for fast-forward pull, disposable builds and Studio Play.
