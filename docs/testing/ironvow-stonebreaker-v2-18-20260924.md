# v2.18 — real-client Warrior blunt-only stun and authority

Date: 24 September 2026. Branch:
`wip/phase-4-test-hud-integration-v1`.
Tested source head:
`a163d0947d6d9bfdbd714a9ee0f5a017b44dc21f`.

## Mechanic and original source inventory

Nine independently purchased original Warrior blunt-control
rank opportunities at 20/20/20, 24/24/24, 28/28/28
are implemented as `IronvowStonebreaker`. Source C4 Warrior
Stun Attack powers 30/33/35, 41/44/48, 55/59/64,
MP 22/22/22, 23/24/25, 27/29/30. The source skill
requires a blunt weapon and prevents repeated shock
while target is already dazed; its original player-facing
name is **not copied**. Reference:
https://l2hub.info/c4/classes/warrior

Actual DungeonMMO implementation requires the player's
personally earned Warrior advancement, own trainer,
paid Sword/Blunt mastery prerequisite and real server
OneHandedBlunt equipment tag. Single-target melee hitbox,
one NPC per swing, genuine rank-specific MP cost and
source power metadata. Roblox 0.3 × source power HP
damage adapter, 1.1-second stagger and nine-second
cooldown are provisional independent combat balance,
NOT a claim of exact C4 P.Atk or original stun duration.
The existing combat executor checks its own authoritative
StaggerService state and refuses to reapply *this ability*
when a target remains stunned or the hit dealt no HP.
Other already-authored skills retain prior stagger logic.

## Exact executed tests

Fresh disposable unpublished Base and Dungeon Rojo builds
PASS at `a163d094`. Actual earned Warrior Quest,
Award/Trainer/Save-Reload and forged-class Foundation
in `0.740.0.7400927_20260924T104637Z_Studio_0C011_last.log`:
**31 / 137 / 119 assertions PASS**.

Actual full Dungeon client Play using
`scripts/studio/c4_ironvow_stonebreaker_client_live.luau`:
`0.740.0.7400927_20260924T104721Z_Studio_27892_last.log`
records `REAL_CLIENT_NPC_HP_STUN_MP_PASS`: current actual
client `CombatInputActions.request_skill_slot(1)` sent
a genuine hotbar request; the actual spawned training
NPC lost **21.3887939453125 HP**, the owner spent
**30 MP**, and target received **1.0999 seconds**
server-authoritative shock. The premature second
request did not damage twice, real server sword gear
was rejected for a blunt-only skill, and a copied
unearned Fighter skill was rejected. Markers
`ALL_REAL_CLIENT_AUTHORITY_PASS` and
`VERIFIED_PLAY_MODE_PASS` appear in this exact log.

Separate strict level-30 launch audit
`0.740.0.7400927_20260924T104919Z_Studio_5DD3A_last.log`
reports **27 assertions PASS**: Warrior 53/62 source
rank schedules mapped, nine utility rows still missing,
Knight 55/55 mapped training rows. Neither is certified
to match every C4 effect or release-ready.

## Limitations and what NOT to infer

Live Play uses a disposable internally valid personal
quest/advancement + skill rank fixture rather than a
naturally quested, persisted, cross-place player.
Real multi-player competing stun attempts while target
is already dazed are **not yet tested end-to-end**.
The second hotbar cast demonstrates normal cooldown
rejection, not two concurrent owners' no-re-stun outcome.
The original nine-second source stun is NOT reproduced
by the current short Roblox 1.1-second stagger.
Other boss/world-boss blocking, natural save/rejoin,
weapon meshes/animation and all cross-class PvE/PvP
balance remain open. No main merge, public publication
or production DataStore interaction.
