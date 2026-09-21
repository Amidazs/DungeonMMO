# Local support-threat and four-player aggro contract acceptance

**Date:** 21 September 2026
**Branch:** `wip/phase-4-test-hud-integration-v1`
**Accepted GitHub source/test head:**
`df33735b10010b8aed8e7acc5193970b8f4cc9b1`

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
- Real two-client ordinary enemy support:
  `REAL_TAUNT_ENGAGEMENT_PASS`,
  `REAL_PEER_HEAL_THREAT_PASS`,
  `REAL_WARD_ABSORB_THREAT_PASS`, and
  `VERIFIED_MULTIPLAYER_PASS`.

The support fixture equipped a genuine Mage client with its
server-authorized wand, MageHeal and ArcaneWard. It injured a real
Fighter client, executed MageHeal through the ordinary client
skill RemoteEvent, observed 32 actual instant HP restored and
positive caster threat, and used the ordinary client skill path
to apply Ward to that same Fighter. A separate fixture-owned,
server-side incoming hit then went through the *production*
DamageService/WardService absorption callback and generated
additional support threat. This last incoming hit was deliberately
injected by the test server; **it was not a genuine NPC attack**.

The test also exposed and corrected missing Mage skill equipment
and a Ward request issued while the Heal state was still Recovery.
Neither required weakening server skill authority.

## Remaining local acceptance, not yet claimed

- Client-driven Mend pulses with threat and an actual NPC-generated
  attack absorbed by a client-cast Ward.
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
