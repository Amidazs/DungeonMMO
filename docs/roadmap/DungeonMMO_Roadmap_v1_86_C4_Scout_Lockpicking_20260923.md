# DungeonMMO roadmap v1.86 — secure C4 world Lockpicking

Date: 23 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`

## Precedence and project constraints

This is the newest **C4 backend and original class
source-catalogue supplement**, following
[v1.85 tested ranked crafting](
DungeonMMO_Roadmap_v1_85_C4_Scout_Ranked_Crafting_20260923.md).
The independently maintained newer humanoid/quadruped
rig and animation roadmap still governs character
models, meshes and animation/visual production.
The agreed **one gathering + one crafting
profession per character**, existing trade
economy and no-publish-until-requested rule
remain unchanged.

## Backend implementation completed and tested

- [x] Registered a real server-authoritative
  `ScoutLockpicking` passive with five separately
  bought original C4 levels **20/24/28/32/36**
  at both Rogue/Ranger class trainers.
  Neither skill ownership nor a passive icon
  bypasses required level or the next purchased
  rank.
- [x] Implemented `ScoutLockpickingService`:
  physical server-registered lock prompts,
  server-side party/DungeonID/SessionId/active
  member checks, real humanoid vitality,
  server-measured proximity, reached
  checkpoint and class/race/owned-rank gates.
  Optional quest-specific locks require
  authentic completed-quest state on the
  authoritative character profile.
- [x] The real Dungeon runtime registers
  simple backend-only wooden cache parts
  beside the first five **normal** resolved
  room checkpoints (only the rooms actually
  present in that dungeon difficulty).
  Original five-rank lock skill works with
  the same service in TestDungeon and
  AbandonedMine layouts; eventual art can
  replace the placeholder models.
- [x] Each eligible member can claim each
  authored cache **once per dungeon run**,
  independently of other party members.
  Session-side atomic resource claims
  and a session-keyed character loot
  ledger prevent prompt/reconnect/restart
  reward replay. Character inventory
  rewards are added in the same atomic
  mutation that marks them granted.
  Reward retry after a session claim is
  supported if the inventory transaction
  did not commit. The hard-coded reward
  is a legitimate captain-emblem item,
  **not** a stolen/private inventory item
  or gathering-profession-locked resource.
- [x] Genuine server-driven `ProximityPrompt`
  updates the successful member's real
  inventory snapshot. No client-supplied
  rank, loot amount or arbitrary
  chest/bank ID is trusted.
- [x] Unpublished Studio focused original
  source + loot + combined C4 audit:
  **3/3 suites PASS**, including
  **104** lock/source/ledger assertions
  and **1,176** strict source audit
  assertions. Direct source training
  through ranks one to five, early/sixth
  purchase rejection, physical target
  registration, profile save/release/
  reload idempotency and a legitimate
  new-run reward were exercised.
- [x] **Real one-client unpublished Dungeon
  playtest PASS**: the client used the
  genuine engine ProximityPrompt; the
  server observed `Triggered`, refused
  missing skill rank, awarded and
  preserved rank-one loot across repeated
  presses, required server checkpoint
  advancement plus purchased rank two,
  awarded rank-two loot and refused
  spectator/out-of-range/private-bank
  attempts. The test manually advanced
  the second room checkpoint in the
  disposable session; this is *not*
  a claim to have visually cleared
  the second encounter.
  See [v1.86 executed test record](
../testing/c4-scout-lockpicking-v1-86-2026-09-23.md).
- [x] All game-code, tests and documentation
  authored directly through GitHub.
  Local desktop used only for clean
  fast-forward pulls, read-only
  diagnostics, disposable Luau/Rojo
  builds and unpublished Studio tests.
  No `main` merge, Roblox publishing,
  production DataStore change, destructive
  local reset or paid operation.

## Original source rank accounting

| Original C4 inventory | Functional / raw | Missing |
| --- | ---: | ---: |
| Human Fighter | 39 / 39 | 0 |
| Elven Fighter | 43 / 43 | 0 |
| Human Mystic | 44 / 44 | 0 |
| Elven Mystic | 42 / 42 | 0 |
| Human Rogue (partially inventoried first transfer) | 95 / 99 | 4 |
| Elven Scout (partially inventoried first transfer) | 126 / 129 | 3 |
| **Six original inventoried classes** | **389 / 396** | **7** |

The original four starting classes remain
**168/168** complete. The remaining seven
source ranks cover only the two currently
partially inventoried first-transfer
classes. The **seven other original**
first-transfer class catalogues have not
been enumerated/implemented and are not
part of the remaining seven.
**0/9 original first-transfer class paths
are fully complete.**

## Remaining backend work

- [ ] Implement **Equipment Expertise**
  for Human Rogue and Elven Scout as an
  authentic, level/proficiency-gated
  equipment permission/mitigation or
  other explicit mechanical benefit.
  Verify actual equip/unequip and
  unauthorized equipment restrictions;
  never give an unowned second career.
- [ ] Implement **Lung Capacity** for each
  original source class: actual underwater
  oxygen/drain/breathing rules with
  proper humanoid and world-water tests,
  not just a passive icon or unobserved
  attribute.
- [ ] Implement **Fall Resistance** for
  each class: genuine server-owned fall
  injury calculation, real height/impact
  tests and safeguards against dodging
  other combat damage.
- [ ] Implement original Human Rogue
  **Sprint** with purchased rank,
  movement effects, bounded resource
  use and normal combat immobilization
  restrictions. Preserve independent
  Elven Scout movement skills.
- [ ] Optional future *content* acceptance:
  human/visual full five-room traversal;
  final cache chest art and secret-room
  placement; optional quest-specific
  cache definitions, multi-client
  personal-loot playtest and market
  reward balance. None is evidence
  that an unimplemented source ability
  can be counted as complete.
- [ ] Source-enumerate and implement the
  **seven additional original C4 first-
  transfer class catalogues**, with
  full rank/level/skill-proficiency
  prerequisites and advancement quests.
- [ ] The independent v1.78 Mystic
  hostile-weakening real-client NPC
  acceptance and separate previously
  documented proficiency regression
  remain open. Do not rerun accepted
  wipe/aggro/paid-revive suites without
  relevant subsystem changes.

**v1.86 original C4 lock skills:
focused source, persisted loot and
real physical client interaction PASS.
Full original C4 catalogue INCOMPLETE.**
