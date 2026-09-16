# DungeonMMO Agent Operating Rules

These rules apply to autonomous or semi-autonomous development agents working
in this repository.

## Startup sequence

Before modifying source:

1. Read `docs/ai/CURRENT_STATE.md`.
2. Read `docs/ai/HANDOFF.md`.
3. Read `docs/ai/TEST_MATRIX.md`.
4. Read `docs/ai/AUTOMATION.md`.
5. Treat `docs/roadmap/DungeonMMO_Roadmap_v1_38.docx` as the canonical
   long-form roadmap.
6. Read the active approved design and implementation plan under
   `docs/superpowers/specs/` and `docs/superpowers/plans/`.
7. Inspect branch, HEAD, status, worktrees, remotes and `git diff --check`
   before changing source.

If repository state disagrees with continuity documents, stop source
modification and reconcile without destructive Git operations.

## Current accepted boundary

- Phase 1: ACCEPTED / functionally complete.
- Phase 2A: ACCEPTED / functionally complete.
- Phase 2B.A/B/C: ACCEPTED; Phase 2B functionally complete.
- Phase 2C.A through Phase 2C.E: ACCEPTED; Phase 2C functionally complete.
- Starting Base + Temple integration: ACCEPTED.
- Profession Foundation: ACCEPTED.
- Second Modular Dungeon + Rare-State/Event Proof: ACCEPTED.
- Party Formation + 1-4-Player Group Entry: ACCEPTED.
- Party gameplay checkpoint: `726299322fb31689e5e321878f287cccfcb07d81`.
- Selected next gate: one targetable rare Skill Book acquisition path,
  design not yet locked.

Do not reopen accepted architecture merely for cosmetic polish unless a real
regression or readability blocker is demonstrated.

## Git safety

- `main` is for deliberately accepted checkpoints.
- Do not develop directly on `main`.
- New gameplay gates use an isolated feature branch/worktree.
- Never reset hard, clean, force-push, rewrite history or discard local work
  without explicit user approval.
- Review exact diffs before deliberate commits.
- Commit, push, merge and Roblox publish are consequential actions. Follow the
  user's explicit choice for each closeout.
- A local-merge choice does not imply a remote push.

## Build and validation rules

- `default.project.json` builds the Dungeon Place.
- `base.project.json` builds the Starting Base Place.
- `published-dungeon.project.json` and `published-base.project.json` are also
  required for final cross-composition gates.
- Write validation `.rbxl` files only to timestamped TEMP paths.
- Never overwrite `DungeonMMO.rbxl`.
- Run `git diff --check` after source changes.
- Preserve relevant accepted regression families.
- New behaviour follows test-first RED -> GREEN development.
- A Rojo build does not prove Roblox runtime tests passed. Fresh Studio
  evidence is required for genuinely runtime/visual behaviour.

## Roblox authority and environment rules

Combat, progression, inventory, equipment, professions, party/session state,
rewards, saves and handoff remain server-authoritative.

Do not autonomously:
- publish PROD;
- publish TEST without explicit approval;
- enable live paid-revive Developer Products;
- spend Robux;
- mutate production DataStores;
- alter monetisation;
- bypass TEST/PROD guards.

TEST-only debug hooks must remain rejected or disabled in PROD.

## Accepted party invariants

- PartyService is temporary same-Base-server authority only.
- Party membership is not Profile/DataStore persistence.
- Party size is 1-4.
- Multi-member parties require all members Ready.
- Membership changes and selected-dungeon changes invalidate readiness.
- Leader transfer is deterministic to the longest-standing remaining member.
- Server revalidation occurs immediately before entry.
- Accepted members are handed to existing TeleportCoordinator /
  DungeonSessionService authority; the Base party is not parallel dungeon
  membership authority.
- Both Temple and Abandoned Mine entry are supported.
- Studio negative synthetic UserIds are allowed only under
  `RunService:IsStudio()`.
- The Studio `PlayerN` Human/Fighter auto-identity harness must never become a
  production identity shortcut.

## Selected next-gate discipline

The next gate is a targetable rare Skill Book acquisition proof.

Reuse:
- `LootTableConfig`;
- `RewardService`;
- `InventoryService`;
- skill-book learning / binding rules;
- completion eligibility and idempotency;
- accepted dungeon / rare-state / event definitions where appropriate.

Do not create a client-trusted reward-selection path. Avoid a schema bump unless
an approved persistent target/pity mechanic genuinely requires it; if it does,
lock migration/rollback first.

Do not broaden the first proof into Bank, Travel, marketplace, public
matchmaking or a full loot/economy rebalance.

## Separate environment-art branch

`art/dungeon-environment-prototype` is a separate art worktree/branch.

Do not switch to it, merge it, reset it, clean it, apply its stash or wholesale
copy it into gameplay. Follow the canonical asset-library REUSE -> VARIANT ->
NEW ASSET workflow for later authored environment work.

## Handoff discipline

At every meaningful WIP checkpoint:
- update `docs/ai/CURRENT_STATE.md`;
- update `docs/ai/HANDOFF.md`;
- update `docs/ai/TEST_MATRIX.md` when evidence changes;
- record branch/checkpoint and exact next action;
- record known defects and unresolved evidence.

At an accepted gate, update the canonical roadmap.

No critical implementation knowledge may exist only in an agent chat.
