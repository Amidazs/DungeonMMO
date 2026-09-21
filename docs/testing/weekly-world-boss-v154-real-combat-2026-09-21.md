# v1.54 weekly world boss — real combat integration acceptance

**Date:** 21 September 2026  
**Branch:** `wip/phase-4-test-hud-integration-v1`  
**Accepted source head:** `7605c811bb9f9a13ce2fb56f6b68a76f8c63ae89`  
**Status:** Existing combat, guardian AI and authoritative contribution
pipeline are now integrated into the isolated world-boss composition
and verified in unpublished Studio Play. Published cross-place travel,
a production arena, multi-client network recovery and cloud persistence
remain pending.

## What changed

The separate world-boss Rojo compositions now include the project's
existing full combat server/client runtime and the existing
`MarauderCaptainController`, while explicitly excluding the ordinary
prototype `ArenaBuilder`. This reuses accepted combat rather than
creating a second world-boss attack system.

On real world-boss admission, the runtime marks the player's character
as the active dungeon-run participant and assigns the frozen weekly
encounter ID. The captain controller can therefore acquire only members
of that world-boss encounter.

`DungeonContributionBridge` now supports a server-bound damage-target
validator. The world-boss runtime binds it to the exact authoritative
guardian model and admitted player, preventing an unrelated hostile
NPC or a same-name model from becoming weekly-boss contribution.

`WorldBossCombatAuthority` adds a second server-side boundary around
all contribution events. It requires the current active member,
live guardian, correct participant/encounter attributes and an
undefeated stored weekly event. Damage must target the actual guardian;
healing/ward support must target another admitted member.

The world-boss return path now retries post-defeat reward grants during
the existing periodic session loop. A player who has real qualifying
contribution but whose weekly reward is not yet durably granted is not
allowed to hand off to Base; they remain in the recoverable encounter
until the reward succeeds.

## Bugs found by real combat Play

The first real-client Play fixture exposed two issues that the earlier
contract tests did not:

1. The combat authority assumed a stored weekly event table was always
   present and could index `Defeated` directly. It now fails closed
   for missing/malformed event state instead of throwing.
2. A local variable named `event` shadowed the incoming combat event.
   That caused genuine guardian hits to be rejected as
   `InvalidWorldBossContribution`. The stored event is now named
   `weekly_event`, preserving the actual combat event.

Both failures were reproduced through real CombatService client input,
not by direct health changes, and were fixed before acceptance.

## Unpublished real-client Play acceptance

Output directory:
`%TEMP%\DungeonMMO_WorldBoss_Combat_Acceptance\`.

The fixture uses a real Studio client and the normal
`CombatService` attack RemoteEvent. It does **not** set guardian
health to zero and does not directly insert contribution records.
The fixture lowers only the disposable guardian's initial health
multiplier so the encounter completes quickly.

Observed markers:

- `REAL_CLIENT_HIT_PASS`: normal client attack input reduced the
  authoritative guardian Humanoid health.
- `SERVER_CONTRIBUTION_PASS`: the same hit created persisted
  server contribution through the normal DamageService callback.
- `GUARDIAN_ATTACK_PASS`: the existing captain AI attacked and
  damaged the participating player.
- `REAL_CLIENT_BOSS_DEFEAT_PASS`: the client defeated the guardian
  through normal combat without assisted health injection.
- `WEEKLY_REWARD_ONCE_PASS`: server contribution certified that
  player, the verified defeat paid the weekly reward once, and an
  immediate second claim paid zero.
- `VERIFIED_PLAY_MODE_PASS`: complete fixture passed.

Final acceptance on the same source head also produced:

- six Rojo builds PASS: Base, Dungeon, published-style Base,
  published-style Dungeon, local world-boss and published-style
  world-boss;
- damage-target spoof/off-encounter filter: **7 assertions PASS**;
- world-boss default-off Play: PASS;
- actual contribution-service contract: **14 assertions PASS**;
- weekly policy/factory: **40 + 8 assertions PASS**;
- existing Base professions: **14/14 PASS**;
- existing Dungeon gameplay backend: **30/30 PASS**.

## Important boundary

This proves the **combat backend path** can run in the isolated
world-boss composition: client intent → CombatService → legal guardian
target → DamageService → scoped contribution → real guardian death →
verified weekly reward.

It does **not** prove the whole production journey. The dedicated
runtime still requires an authored `WorldBossArenaSpawn` in the real
place. The acceptance fixture manually creates its disposable session
and guardian so it does not exercise Base entry, Roblox ReserveServer,
real teleport arrival, profile lease transfer or Base return in one
networked Play session. It is single-client; multi-player support,
deaths/wipes, simultaneous disconnect/rejoin and published
DataStore/MemoryStore behavior are still release gates.

The event stays disabled by default. No cloud publish, production
DataStore write, force-push or merge to `main` was performed.
All source/test/documentation editing remained GitHub-only; Remote
Desktop was used only for clean pulls, local Rojo builds, Studio Play
and diagnostics.
