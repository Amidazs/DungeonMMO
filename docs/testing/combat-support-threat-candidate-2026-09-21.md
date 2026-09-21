# Local support-threat and four-player aggro contract acceptance

**Date:** 21 September 2026
**Branch:** `wip/phase-4-test-hud-integration-v1`
**Six-build/focused-regression head:**
`df33735b10010b8aed8e7acc5193970b8f4cc9b1`
**Latest successful real-client support Play head:**
`04c3f1eb5087d34e49ef4cb7bd38b731de9fd610`

All edits were made directly in GitHub. Remote Desktop was used
only for a clean feature-worktree fast-forward, TEMP Rojo builds,
unpublished Studio tests and read-only diagnostics.

## Implemented backend

- Actual server-applied healing (MageHeal including HoT and positive
  Mend pulses) and ArcaneWard damage absorption now add per-enemy
  support threat through the shared authoritative ThreatService.
- Provisional balance: 0.5 threat per effective support point.
  Overheal, a zero-heal pulse and an unused Ward generate no threat.
- An enemy must already have recorded threat and have both the
  support caster and recipient in its latest eligible candidate set.
  Healing elsewhere does not automatically pull nearby idle mobs.
- Enemy-specific threat totals remain independent. Clearing an enemy
  also clears its candidate snapshot. PlayerRemoving now removes
  the departing UserId's threat and candidacy from every enemy.
- Invalid support values, unbounded threat arithmetic and invalid
  player identities are rejected by server-owned guards.

## Fresh acceptance evidence

At head `df33735b10010b8aed8e7acc5193970b8f4cc9b1`:

- All **six** Rojo compositions built successfully.
- ThreatService focused Studio contract: **48 assertions PASS**.
  This includes a four-player **server-side simulated** tank/DPS/
  healer scenario, two independently engaged enemies, real-total
  vs idle-mob isolation, a tank Taunt, equal-threat tie, disconnect
  ledger removal and enemy wipe/reset. These are not four real clients.
- Dungeon backend matrix: **30/30 PASS**.
- Base profession regression: **14/14 PASS**.
- Real two-client ordinary Marauder aggro:
  `VERIFIED_MULTIPLAYER_PASS`.
- Real two-client world-boss aggro:
  `VERIFIED_MULTIPLAYER_PASS`.
- Real two-client ordinary enemy support at the final fixture head:
  `REAL_TAUNT_ENGAGEMENT_PASS`,
  `REAL_PEER_HEAL_THREAT_PASS`,
  `REAL_NPC_WARD_ABSORB_THREAT_PASS`,
  `REAL_FIGHTER_MEND_THREAT_PASS`, and
  `VERIFIED_MULTIPLAYER_PASS`.

The support fixture equipped a genuine Mage client with its
server-authorized wand, MageHeal and ArcaneWard. It injured a real
Fighter client, executed MageHeal through the ordinary client
skill RemoteEvent, observed 32 actual instant HP restored and
positive caster threat, and used the ordinary client skill path
to apply Ward to that same Fighter. The fixture then gave the Fighter
test-only server threat priority and observed a **genuine Marauder
NPC melee attack** pass through production DamageService/WardService,
reduce the client-cast Ward's remaining absorption and create
additional support threat for the Mage. No synthetic damage was
injected for that final Ward assertion.

The Fighter then used genuine client-driven Mend on his own injured
character, and the resulting effective healing pulse increased his
server-owned threat on the same enemy.

The test also exposed and corrected missing Mage skill equipment,
a Ward request issued during Heal Recovery, and a moving Marauder
turning outside the first Taunt's hit arc. The final fixture
repositions the Fighter at the enemy's live root before the skill.
None of these corrections weakened server combat authority.

## Remaining local acceptance, not yet claimed

- Real four-client tank/DPS/healer party aggro and independent
  multi-enemy room behavior, including actual player departure,
  respawn and full-party wipe/controller reset.
- Genuine healing/Ward in the isolated weekly world-boss instance;
  the dedicated boss support fixture remains a separate gate.
- Published TEST reserved travel, true same-account cross-server
  reconnect and cloud DataStore/MemoryStore recovery remain deferred.

No Roblox place was published, no main merge or force-push occurred,
and no production DataStore was accessed. The provisional 0.5
support-threat multiplier remains subject to multiplayer balancing.
