# DungeonMMO Current Engineering State

**State date:** 18 September 2026
**Canonical long-form roadmap:** docs/roadmap/DungeonMMO_Roadmap_v1_43.docx
**Current phase:** Phase 4 - Content Alpha
**Phase 2 - Vertical Slice:** FORMALLY COMPLETE / ACCEPTED
**Phase 3 - Systems Alpha:** FORMALLY COMPLETE / ACCEPTED
**Phase 3 gameplay release checkpoint:** 84662948127eb1a37c9f184c6abbafe6f2daddb6

## Canonical release boundary

Phase 3 is closed. The accepted gameplay release checkpoint was pushed to the
Phase 3 feature branch and to main, then independently verified so local main,
origin/main and the GitHub server main ref all resolved to 84662948127eb1a37c9f184c6abbafe6f2daddb6 before
the documentation closeout.

Published TEST places:

- Starting Base: 134132328219009
- Dungeon: 117293035754309
- Universe: 10765241947

The Dungeon was published first and the Starting Base second. Roblox Studio's
publish state machine reached PublishSuccessful for both places. No PROD place,
Robux purchase flow or production DataStore action was used.

## Accepted Phase 3 systems

The accepted Systems Alpha boundary now includes:

- reusable Quest/objective state and first race-specific Secondary-Class
  Advancement architecture;
- persistent, server-authoritative contribution channels for Damage, Tank and
  Support;
- schema-backed Blueprint / Recipe Knowledge and authoritative teaching-item
  consumption;
- persistent Bestiary and Scholars Reputation foundations;
- Rogue as the deliberately selected fourth prototype starting archetype;
- Human Duelist and Elf Windstalker as prototype race-specific Rogue
  advancement targets;
- broader Rogue skill-tree/progression architecture while retaining the
  accepted limited active loadout;
- deterministic Dungeon modifiers: Fortified, Rich Deposits and Bounty;
- Rich Deposits interaction with reconnect-safe personal profession gathering;
- Guild creation, membership, Leader/Officer/Member roles, Guild XP, Guild
  Gold, leader-only level upgrades and a private functional Guild Hall;
- a limited fixed-price player-market proof with escrow, tax, tradability
  checks, buy/cancel/expiry recovery and replay-safe transactions;
- DEV/TEST Race Change preview/apply with per-race advancement history,
  incompatible skill/proficiency archive, SP release and restore-on-return;
- shared economy audit events and request-rate/replay/ownership validation;
- the reusable persisted entity-adapter boundary used by shared MMO entities.

The current profile schema is v13. Schema v13 adds independent persistent
Dungeon difficulty progression while preserving legacy `DungeonProgress`.

## Final runtime and stress evidence

The final consolidated Studio regression round on 18 September 2026 included,
among other accepted families:

- Rogue Definitions: 43 assertions PASS;
- Rogue Progression: 17 assertions PASS;
- Rogue Advancement: 12 assertions PASS;
- Class Advancement: 29 assertions PASS;
- Contribution Service: 36 assertions PASS;
- Contribution Damage Bridge: 9 assertions PASS;
- Contribution Support Bridge: 13 assertions PASS;
- Contribution real-session persistence: 10 assertions PASS;
- Bestiary Service: 33 assertions PASS;
- Bestiary/Reputation reward integration: 25 assertions PASS;
- Guild membership authority: 21 assertions PASS;
- Guild Service / Guild Hall / Dungeon progression: PASS;
- Market listing, purchase recovery, cancel/expiry and remote contracts: PASS;
- Race Change planner, migration, service and remote-contract tests: PASS;
- Economy Audit Integration: 27 assertions PASS;
- Entity Adapter Contract: PASS;
- Dungeon Modifier Definitions: 6 assertions PASS;
- Profession Resource Distribution: PASS;
- existing Phase 1/2 combat, progression, equipment, Bank, Travel, Dungeon,
  reward, revive and session regressions remained green in the same run.

The Phase 3 stress harness passed:

- 250 profile cycles;
- 1,000 market operations;
- 1,000 duplicate/replay attempts;
- 250 guild operations;
- 100 session cycles;
- 100 race-change round trips.

No duplicate/lost value or invalid final profile state was accepted by the
stress gate.

Detailed closeout evidence is recorded in
docs/testing/phase3-systems-alpha-acceptance-record.md.

## Explicit Phase 3 deferrals

Two roadmap concepts were intentionally not implemented:

- **Progression catch-up** - defer until real player population/progression data
  demonstrates a need.
- **Transmog** - defer until the equipment/content catalogue is mature enough to
  justify wardrobe engineering.

These are future work, not missing Phase 3 exit criteria.

## Phase 4 progressive-depth backend gate

Phase 4 - Content Alpha remains active.

The user has explicitly parked Starting Base presentation, modelling, meshes and
environment-art work for now.

The **Progressive Dungeon Depth + Difficulty backend foundation** is now
**LOCAL GREEN / AWAITING PROJECT-OWNER CLOSEOUT**.

Implementation checkpoint:

`1230e6c`

Accepted local engineering result:

- Depth1/2/3/4 expose progressively deeper 3/4/5/6-encounter logical plans;
- each depth has monotonic server-owned health, damage and reward scaling;
- the final depth reuses the three earlier bosses as minibosses before a new
  true final boss;
- Fortified, Rich Deposits and Bounty remain independent run modifiers;
- Fortified composes with depth HP and Bounty applies after depth reward
  scaling;
- schema v13 stores difficulty progress separately from legacy
  `DungeonProgress`;
- completion records sequential, idempotent clears before the save barrier;
- solo/party/session/reconnect/TeleportData contracts carry and validate
  difficulty;
- Depth1 remains the current runtime-ready compatibility baseline;
- Depth2-Depth4 remain `RuntimeReady = false` and fail closed until their
  physical/runtime content exists;
- no modelling, meshes, terrain, authored-room or environment-art work was
  performed.

Final local evidence includes 467 Luau files parsed with 0 failures, clean
`git diff --check`, all four Rojo compositions building, final Base/Dungeon
Studio suites green, and the Phase 3 stress harness still passing.

Active worktree:
C:\Users\Remko\Documents\Roblox\DungeonMMO_Phase4_DungeonDepth_v1

Active branch:
wip/phase-4-dungeon-depth-difficulty-v1

Design/spec:
docs/superpowers/specs/2026-09-18-phase-4-progressive-dungeon-depth-difficulty-design.md

Acceptance evidence:
docs/testing/phase4-progressive-dungeon-depth-backend-acceptance-record.md

No push, merge or Roblox publish has been performed for this Phase 4 gate.

## Repository safety

Primary gameplay repo:

C:\Users\Remko\Documents\Roblox\DungeonMMO

Phase 3 completion worktree/branch remains preserved for history:

- worktree:
  C:\Users\Remko\Documents\Roblox\DungeonMMO_Phase3_Completion_v1
- branch: wip/phase-3-systems-alpha-completion-v1

Do not reset hard, clean, force-push, rewrite history or merge the art worktree
into gameplay. Validation builds belong in TEMP locations.
