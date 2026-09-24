# DungeonMMO backend v2.27 — Greenward Warden quest transactions

Date: 24 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v2.26](DungeonMMO_Roadmap_v2_26_Elven_Knight_Quest_Foundation_20260924.md).

## Backend quest path completed, physical encounter still pending

The independent Elven Knight / Greenward Warden route now has complete
server transaction rules for its six-step authored advancement quest.
Three distinct `RootboundMarauder` kills grant three personal
`verdant_patrol_report` items and aggregate
`VerdantPatrolReports3` proof. Warden Caer consumes all three.
A distinct `ThornboundColossus` kill grants one personal
`verdant_guardian_seal`; Sentinel Ilyra consumes it at final return.

Both items are bound and non-tradeable/non-bankable. Stable monster-life
receipts remain mandatory; replayed receipts cannot generate extra proof.
The shared dungeon quest combat ledger now knows the Elven Knight proof
families but still requires a genuine registered physical monster model.

A new isolated transaction test walks the entire ordered quest, validates
inventory ownership/consumption, reaches level 20 and exercises the actual
one-use `OriginalFirstTransferService` award into `GreenwardWarden`.
This proves profile and transaction contracts only. It does **not** prove
that Rootbound Marauders or the Thornbound Colossus currently spawn in a
real dungeon. The disposable Studio runner exists but has not yet run.

## State

- Elven Knight source inventory: **56** historical ranks.
- Elven Knight mapped trainer ranks: **0/56**.
- Quest transaction backend: complete for the authored six-step route.
- Physical dungeon quest enemies and true combat Play: OPEN.
- Greenward Warden trainer: intentionally empty.
- Whole-game C4 mechanical/release acceptance: OPEN.

Next: bind real disposable dungeon quest enemy instances to the quest
combat ledger, run the real owner drop/return/class-award Play, then begin
the 56 rank skill implementation with Sword/Blunt, Heavy Armour, Magic
Resistance, Elemental Heal, Charm/Aggression, shield/aura/cure utilities.
Historical source MP/power values remain reference data; Roblox adapters
must be labelled provisional until source combat formulas are reproduced.

No main merge, publish, production saves or animation-worktree changes.
Permanent changes via GitHub; desktop only for fast-forward, disposable
Rojo builds and unpublished targeted Studio tests.
