# DungeonMMO backend v2.39 — Natural Captain slash and rig regression

Date: 24 September 2026. Branch: `wip/phase-4-test-hud-integration-v1`.
Executed candidate: `fd7f8d0c023b32241412bf37537488e670f40816`.
Previous: [v2.38](DungeonMMO_Roadmap_v2_38_Warden_Three_Reports_Owner_Gates_20260924.md).

## Natural Captain AI bleeding and actual client Warden cure

New disposable, unpublished one-client Dungeon Play:
`c4_greenward_warden_natural_captain_bleed_live.luau`.
A genuine registered Captain using the unchanged
`MarauderCaptainController` naturally acquired a real world-spawned
player and delivered an unblocked `CaptainSlash`. The test does
**not** call `DamageService.apply_damage` or
`PlayerBleedStatusService.apply_from_captain` to manufacture
this first hit or the resulting server-owned status.

Studio observed a real **24 HP CaptainSlash**, actual private
tier-one bleed, the player's client skill request
`GreenwardWardenBleedRecovery` being accepted, and a real
server `MAGE_CURE APPLIED`. The test removes the Captain's
attack-controller tag *after* the first natural slash so another
fresh enemy hit cannot be mistaken for a delayed bleed tick;
the alive physical enemy remains in Workspace so any existing
uncured timer would still be observable. The real player paid
mana and received no heal pulse; no bleed returned or dealt
further HP loss during the 3.5-second post-cure observation.

Unpublished Studio:
`%TEMP%\\DungeonMMO_v244_natural_captain_bleed\\natural_bleed.log`
reported `NATURAL_CAPTAIN_AI_SLASH_BLEED_PASS`,
`REAL_CLIENT_CURE_NO_LATE_TICK_PASS` and
`VERIFIED_NATURAL_CAPTAIN_PLAY_PASS`.
The character's earlier advancement and purchase records were
prepared in the disposable Play fixture, not naturally transferred
from Base; this does not certify saved cross-place journeys.

## Repair stale automatic Marauder rig fixture, not production mesh

During that full Play, the unrelated automatic
`MarauderRigContractTest` had an infinite-yield warning awaiting
a legacy root under a named `TrainingMarauder` in a synthetic
Dungeon map. The source test had assumed an old arena model layout
which is not present in the current instanced dungeon.

It now directly creates all four configured variants through the
actual `MarauderFactory` in an isolated temporary Workspace folder
and checks each real rig's anchored root, independently welded
colliding body, named Motor6Ds with neutral transform attributes,
and non-colliding visual components. Test fixtures are always
destroyed, including on failure. Production animation, art,
factory and combat scripts were not changed.

Focused unpublished Dungeon Rojo build and Studio runner
`marauder_rig_factory_focus.luau` PASS:
`[Marauder Rig Contract Tests] PASS: four factory rigs`
and `VERIFIED_FOCUS_PASS`.
This checks the factory's output, not any future unique art mesh
or full Dungeon combat configuration. The *entire* automatic
background suite was not separately certified by this focused run.

See [v2.39 testing evidence](../testing/greenward-warden-v2-39-natural-captain-ai-and-rig-20260924.md).

## Still open

All 56/56 Elven Knight historical training rank **schedules**
are mapped, but exact original C4 formulas, party aura behavior
and mechanical/release certification remain OPEN. The prior
[v2.38](DungeonMMO_Roadmap_v2_38_Warden_Three_Reports_Owner_Gates_20260924.md)
verified three personally earned reports across two real
dungeon rooms, with **ordinary room-one enemies** test-assisted
and party owners' quest stages test-prepared. The seamless
unseeded Base->Dungeon->Base journey, actual persistent character
save/rejoin and physical NPC turn-ins of *those same transferred
reports* remain OPEN. All 18 original first-transfer pathways,
PvP, progression/economy and release acceptance remain OPEN.

No main merge, public Roblox publish, production DataStore write,
or unrelated humanoid/quadruped animation worktree edit.
Permanent source, fixture and documentation changes made in GitHub.
