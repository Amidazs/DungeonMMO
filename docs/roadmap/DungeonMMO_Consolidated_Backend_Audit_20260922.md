# DungeonMMO — consolidated backend gap audit

**Audit date:** 22 September 2026  
**Working branch:** `wip/phase-4-test-hud-integration-v1`  
**Purpose:** one actionable backlog; stop reopening already-accepted dungeon
regressions after unrelated changes.

## Scope, evidence and interpretation

Reviewed the GitHub roadmap index, v1.48–v1.61 Markdown supplements,
`docs/ai/CURRENT_STATE.md`, current service/source directories,
and the implemented definition catalogues for quests, class
advancement, professions and guilds. Relevant source-of-truth links:

- [Roadmap index](README.md) (includes the accepted Phase 3 scope and the
  status of the retained long-form v1.47 Word roadmap).
- [Current engineering state](../ai/CURRENT_STATE.md).
- [Phase 4 depth and optional-content supplement](DungeonMMO_Roadmap_v1_48_Phase4_Backend_Update.md).
- [Profession progress](DungeonMMO_Roadmap_v1_53_Professions_Pending_Verification.md).
- [Weekly world-boss status](DungeonMMO_Roadmap_v1_54_Weekly_World_Boss_Foundation.md).
- [Latest party unlock / replay](DungeonMMO_Roadmap_v1_61_Party_Unlock_Spectator_Replay_20260922.md).
- [Accepted Phase 3 scope](../superpowers/specs/2026-09-17-phase-3-systems-alpha-completion-design.md).

**Reading limitation:** the historical
`DungeonMMO_Roadmap_v1_47.docx` is retained in GitHub but was not
parsed as a Word document in this connector-only audit. Its phase
status and completed/explicitly deferred systems were cross-checked
against the roadmap index and current-state Markdown. A future item
appearing *only* in the Word file could be absent from this audit.
This is a practical engineering backlog, not a claim that every
historical design sentence has been inspected or that local Play
equals a released game. Historical "pending" statements superseded
by later documented passes are not reopened.

## System inventory: what exists versus what is actually missing

| Area | Verified existing foundation | Remaining work, distinctly classified |
| --- | --- | --- |
| Character, combat and equipment | Phases 1–3 accepted basic combat, attributes/progression, equipment, loadouts, defense, Mage/Ranger/Rogue prototypes and role threat. Latest dungeon spectator-combat guard and Taunt/aggro have local evidence. | **New content:** expand race/class advancement lines, complete skill families and passives beyond the current prototype paths, item/loot tiers, enemy variety and ability/boss balancing. **Acceptance:** one ordinary end-to-end party fight through completion; do not redo each isolated attack/aggro test. |
| Dungeon run/difficulty/party | Two dungeon backends, Depth1–4 3/4/5/6 required encounters, earlier bosses as Depth4 minibosses, optional/event/secret slots, checkpoints, wipes, revives, all-member difficulty unlocks, Play again, reward receipts and tested local two-/four-client recovery. | **Near-term integration:** one representative normal-combat run through final boss, individual rewards and next-depth unlocking; check a locked party member in the same journey. **Release/content:** higher-depth physical layouts remain opt-in/placeholder and release-locked; authored rooms/bosses and real published instance travel remain separate. Do not rebuild the sequencer/aggro/wipe service. |
| Reconnection and persistence | Profile leases, same-server reconnect admission, saved session/member/checkpoint and in-memory recovery, spectator mode and no-duplicate reward contracts have local evidence. | **External acceptance, not a new backend milestone:** genuine same-account network rejoin to an existing published TEST reserved server, valid Roblox join routing, lease reacquisition and cross-server DataStore/MemoryStore continuity. Keep fail-closed routing; do not simulate this repeatedly and call it a real reconnect. |
| Professions/crafting | Seven registered professions (Mining, Blacksmithing, Herbalism, Alchemy, Skinning, Leatherworking and Enchanting), a level-5 prototype, four-profession material chain, server-checked stations/crafts, animal-only corpse Skinning, two-player/interrupt guards. | **New content:** real resource and animal placement, broader recipe/blueprint and equipment tiers, profession-specific player interactions/minigames if retained in design, XP/material balancing and useful market demand. Wolf/animal art and dedicated AI are still placeholder work. **Release:** real cloud profile migration/cross-server craft recovery. Do not remake atomic inventory or revalidate the same one-bar recipe for each content addition. |
| Quest/advancement/loot/reputation | Quest/objective, class advancement, blueprint teaching, bestiary and reputation services exist. Current `QuestDefinitions` declares two class-trial quests, and `SecondaryClassDefinitions` declares four Human/Elf Mage/Rogue paths. | **Substantial new game content:** quest chains beyond advancement trials, more race/class splits and associated skills, bestiary/reputation unlock uses, rare drops, dungeon-specific loot tables, item progression and NPC/trainer catalogue. Reuse existing event/profile/reward authorities instead of adding a parallel quest system. |
| Guilds, halls and market | Accepted Phase 3 guild creation/membership/roles/level/XP/Gold, private hall and limited fixed-price escrow market with server ownership/replay protections. | **Expansion, not another foundation test:** meaningful guild goals, progression spend/benefits, market supply/sinks and player economy balance. Guild-versus-guild castle/territory PvP, if retained as a game goal, has no accepted implementation in the inspected server-service inventory and needs its own scoped rules/content milestone; do not label the existing hall as castle PvP. |
| Weekly world boss and raids | Default-OFF weekly window/session, isolated world-boss runtime, real local boss attacks, threat/contribution, exactly-once weekly reward, two-client party resilience and Base-return contracts. | **Feature completion:** authentic scheduled entry and eligibility policy, more encounter mechanics/team roles, four-player ordinary fight and recovery, raid mechanics/rooms/puzzles as a *separate* content system if desired. **Release:** authored arena/guardian and published TEST Base → boss → Base transport/persistence. Do not reimplement ordinary dungeon sessions/rewards or retest the same 2-client guardian loop. |
| Daily/weekly retention and PvP | Weekly boss timer/reward exists; guild progression and limited market exist. | **Not accepted as broad systems:** daily quests/rotations, wider weekly activities, PvP match/castle rewards and guild competition rules. Confirm intended cadence/reward economy before designing; use current profile receipts, guild service and event-window patterns. |
| Player-facing places and art | Base/Dungeon UI and temporary physical dungeon layouts exist; current assets/worktree have separate art workflows. | **Intentionally parked:** final authored hubs, castle/raid/boss arenas, NPC/monster models, dungeon visual quality, animations/audio, final UI and performance/accessibility. These are not blockers to designing the next local backend feature, but **are** blockers to calling the game playable/content-complete or releasing higher depths. |

**Status key:** an accepted *foundation* is not finished MMORPG content;
a local Studio *pass* is not published/cloud acceptance; an intentional
content/art deferral is not a repeatedly failing backend test.

## Single development backlog — in this order, no duplicate milestones

### A. Close the current dungeon slice once, then freeze routine re-tests

Build only missing glue found during one representative four-player
normal-input route: enter the unlocked dungeon, kill room mobs/boss,
complete, issue every member's single reward/unlock, then verify an
unqualified member blocks the next-depth start and all eligible
members can opt into Play again. This is **one integrated acceptance
scenario**, not independent re-acceptance of room reset, all 4 boss
types, Taunt, every difficulty and every reward service. Fix only an
observed failure; otherwise mark the local dungeon integration
milestone closed. Genuine same-account reconnect/cross-place remains
a later published TEST gate, not a reason to keep extending local
wipe fixtures.

### B. Expand the player progression and content catalogue

Add a coherent content slice using existing class/skill,
QuestService, RewardService, inventory and equipment authorities:
additional class branches/skills, quest objectives, meaningful
dungeon loot and item tiers, and progression rewards. Scope one
representative class/quest/reward chain end to end, then make other
entries data-driven rather than writing a fresh framework for each.
This supplies actual gameplay progression that the existing dungeon
engine currently lacks at scale.

### C. Expand gathering, crafting and economy into a game loop

Keep existing seven professions and atomic station/craft authority.
Define several tiered item/recipe/material chains and sources,
profession cross-dependencies, repeatable player interactions and
profitable but bounded market sinks. Introduce separate profession
minigames only after their inputs/rewards and desired UX are agreed.
Add authored animal/resource content later without changing
the already accepted Skinning eligibility rules.

### D. Complete weekly-boss/raid gameplay, then guild competition

Reuse the isolated world-boss session, contribution/threat,
weekly-window and reward authorities. Implement actual party
encounter mechanics, boss skills and a representative four-player
normal-combat completion before adding raid rooms/puzzles.
Treat a raid and castle/territory PvP as **new bounded gameplay
features**, not as tests of GuildService or the existing Dungeon.
Specify eligibility, ownership, score/point issuance, cooldown,
disconnect and no-duplicate reward policy before coding castle
capture. Guild hall and market foundations should be extended
to support those loops, not rebuilt.

### E. Fill out retention systems and content/release readiness

Once there is enough playable content, add daily/weekly objectives
and rotations, economy/progression tuning, NPC/trainer content and
operational audit/admin tools as needed. Art, authored higher-depth
rooms, launch UX and real cloud migration have their own release
plan rather than being counted as unfinished local backend logic.

## Test policy — a stop rule, not a new test programme

**For a small isolated edit:** run only that component's focused
contract. **For a completed new feature:** run its own player-visible
flow and a directly affected integration contract. **At a milestone
closeout:** run the appropriate Base/Dungeon build and one relevant
integrated scenario. **Before a branch merge, release candidate or
published TEST rollout:** run the broad suite once at that exact
head, not after every documentation, error-message or fixture edit.
If a suite fails, fix the cause and rerun that failed suite plus
its affected dependants, not every old dungeon test.

Retain prior green receipts as historical evidence and distinguish
their tested commits from the current source. Do not manufacture a
numerical percent-complete estimate from assertion counts or from
the presence of a service file. Do not enable release-locked optional
or higher-depth content as a side effect of this audit.

## External gate, parked until separately authorised

One approved **published TEST** journey should cover actual
Base admission → reserved dungeon server → ordinary clear/
per-member unlock → Play again/return; an actual same-account
disconnect/rejoin; and a separate boss travel/reward journey.
Include cloud DataStore/MemoryStore and profile-lease continuity.
Do not substitute further Studio test simulations for this gate.
Production migration, purchases, PROD place and public event rollout
remain outside this audit and require their own approvals.

## Next execution task

**Begin A by inspecting the existing normal-combat/complete-run
fixture inventory** and completing only a missing normal-input
party integration flow. If equivalent evidence already exists,
record the existing receipt and immediately move to B:
the first additional quest/class/loot content slice. Do not
start by rerunning the full dungeon/backend regression matrix.
