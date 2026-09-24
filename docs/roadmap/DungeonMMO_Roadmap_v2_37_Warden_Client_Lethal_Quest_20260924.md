# DungeonMMO backend v2.37 — actual client lethal Warden quest kills

Date: 24 September 2026. Branch: `wip/phase-4-test-hud-integration-v1`.
Executed candidate: `1e9178838b045923c24ebd600cc3bb63b10e7767`.
Previous: [v2.36](DungeonMMO_Roadmap_v2_36_Warden_Real_Client_Quest_20260924.md).

## The server-finishing-hit shortcut is no longer required

`scripts/studio/c4_greenward_warden_dungeon_two_client_live.luau`
now drives repeated genuine client normal attacks until the physical
quest enemy's actual server Humanoid HP reaches zero. It does not
require, import or call server DamageService for a test finishing hit.
The server still independently validates every normal client hit
and mints personally earned quest loot only from its actual
one-use registered lethal enemy life. It checks actual client
attack transport and an HP change for each accepted attack
attempt, with bounded retries and an explicit failure if a client
cannot kill its assigned enemy.

Two actual unpublished Studio Dungeon clients with different
test-prepared personal Warden quest stages entered the same
instance. One killed a Rootbound Marauder and received exactly
one bound patrol report; the other killed a Thornbound Colossus
and received its own guardian seal. Neither player received
the other player's item. The final disposable Studio RunScript
reported `[Greenward Live] VERIFIED_TWO_CLIENT_WORLD_PROOFS_PASS`
at `1e9178838b045923c24ebd600cc3bb63b10e7767` after the previously described server
finishing-hit path was removed. See
[v2.37 testing evidence](../testing/greenward-warden-v2-37-real-client-lethal-quest-20260924.md).

## Other completed acceptance

Prior [v2.36](DungeonMMO_Roadmap_v2_36_Warden_Real_Client_Quest_20260924.md)
separately passed Warden Base physical NPC/mentor/trainer
transactions (with test-seeded previous loot) and 65 legacy/C4
mastery regression assertions. [v2.35](
DungeonMMO_Roadmap_v2_35_Greenward_Player_Bleed_Client_Play_20260924.md)
verified a real owner-paid Bleed Recovery client cast after a
trusted server Captain status application. All 56/56 historical
Warden training-rank schedules are mapped; precise original
C4 effect formulas and release acceptance remain OPEN.

## Remaining gameplay/launch gates

This v2.37 dungeon test deliberately prepares the two owners at
quest stages three and five in a temporary unpublished place.
It proves one actual client-landed lethal hit per owner, **not**
three sequential report kills, all intervening physical NPC
returns, a single naturally played end-to-end quest, natural
Captain AI slash, save/rejoin, or a persistent
Base -> Dungeon -> Base cross-place handoff. Those and full
party/balance, all 18 first-transfer classes and release tests
remain OPEN.

No main merge, Roblox publication, production DataStore
mutation or animation worktree edit. All permanent script/doc
edits occurred in GitHub. Local actions were fast-forward pull,
temporary Rojo builds and unpublished Studio tests only.
