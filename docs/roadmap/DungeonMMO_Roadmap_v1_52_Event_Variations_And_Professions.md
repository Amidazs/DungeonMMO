# DungeonMMO Roadmap v1.52 — non-boss Event variations → profession backend

**Date:** 20 September 2026

**Status:** ChatGPT-authored, GitHub-backed local backend acceptance
supplement on `wip/phase-4-test-hud-integration-v1`. The v1.51
late-Event placeholder route remains the accepted prior checkpoint.
This supplement does not replace the historical canonical
`DungeonMMO_Roadmap_v1_47.docx` or v1.48–v1.51 supplements.

## Completed: two non-boss Event variations

The existing optional after-Room2 side arena in Temple and Mine now
supports two independently server-selected non-boss **combat-pack**
variations in each dungeon: an immediate four-enemy Ambush or
eight-enemy Surge. The server selects **one** eligible Event for
the run, saves the exact variant, and reuses the existing timed
window, frozen encounter plan, CombatPack executor, entrance gate,
boss-independent per-enemy reward transactions, checkpoints and
multiplayer/disconnect recovery. It does not create a second
scheduler or permit two Event encounters in one run. An
independent `DungeonMMOOptionalEventCombatEnabled` server flag
defaults OFF. The original early/late Event boss and Secret
routes are preserved, and the new variation requires an
explicitly opted-in, physical `EventArenaLate` with eight
spawn anchors.

**What is not included:** The two packs differ by size/identity,
not by staggered timed waves, different enemy AI, changing
terrain, cave-ins, environmental damage or a new dungeon
event executor. These would require separate implementation
and testing. The new combat variation is not live/published.

**Acceptance:** 144 new deterministic variation assertions,
25/25 optional-focused suites, actual assisted walking
Temple Depth2 four-enemy Ambush and Mine Depth4 eight-enemy
Surge with per-enemy reward replay denial, two-client Temple
and four-client Mine real simulated Studio party/disconnect
and per-member completion replay checks. Original after-Room1
Event/Secret six-encounter Temple Depth2 Play mode and
optional-disabled four-required-room Temple Depth2 Play mode
also passed. All four local Rojo compositions and 30/30
broader gameplay backend suites passed.

## Begun: deeper cross-profession crafting backend

The existing Blacksmithing, Alchemy, Mining and Herbalism
services and atomic crafting/recipe-learning pipeline now
support a **bidirectional material chain**, without a second
profession service: Blacksmithing supplies an iron bar to
Alchemy; Alchemy combines it with silverleaf into forging
flux; Blacksmithing then consumes flux, an iron bar and
the existing ironbound gloves to make equippable runic
ironbound gloves. The two new recipes and two item definitions
are added to the existing catalogues and exposed by the
existing station/recipe snapshot pipeline. Required levels,
ingredients, correct minigame identity, equipped-item
protection and profile persistence use existing authoritative
rules; no direct client inventory mutation was introduced.

**Acceptance:** 46 new atomic chain assertions and 7/7
focused profession suites in both unpublished Dungeon
and Base Studio compositions. The new runic gloves were
persisted and recovered exactly once using an in-memory
profile adapter. This is a first profession **backend**
increment, not proof of newly implemented visual crafting
minigames, real-user DataStore migration, authored stations
or complete Leatherworking/Enchanting professions.

Read the full dated local test receipts, including a
corrected disposable walking-test fixture:
`docs/testing/phase4-nonboss-event-profession-chain-2026-09-20.md`.

## Next backend milestones (no art or cloud release implied)

1. **Extend professions on the same services.** Add
   Leatherworking and Enchanting definition, skill and
   recipe/catalogue coverage; define their material
   gathering/sourcing and at least one meaningful
   multi-profession equipment recipe. Verify progression,
   character migration, learned blueprints, ingredient
   ownership and atomic material/output transactions
   in both Base and Dungeon test compositions. Keep
   presentation as replaceable placeholders.
2. **Close profession interaction authority.** Verify a
   real station/client request is distance-checked and
   server-validated, cannot submit fabricated minigame
   success, and remains safe on simultaneous requests,
   disconnect and retry. Previously green service-level
   recipe tests do not prove these live interaction boundaries.
3. After the profession backend checkpoint, resume the
   next major MMORPG backend feature: a weekly raid/world-
   boss lifecycle or guild hall/castle ownership, scoped
   against existing party, rewards, economy and save
   services. These larger features remain separate
   milestones rather than prerequisites to this local
   Event-variation acceptance.

**Deferred independent acceptance:** Genuine same-account
rejoin to a recreated reserved Roblox server, cloud
TEST/PROD release verification, real player DataStores,
unassisted full-party combat/balance, finished map/meshes
and additional dynamic environmental event mechanics.

## Operational handoff

Read `docs/ai/CURRENT_STATE.md`, `docs/ai/HANDOFF.md`,
`docs/ai/TEST_MATRIX.md`, this roadmap and its report.
Author source and roadmap updates in ChatGPT via GitHub,
then fast-forward pull to the existing authorized Windows
worktree for unpublished local Rojo/Studio testing.
Leave source content release flags OFF and preserve the
historical canonical Word roadmap. No force-push, merge,
TEST/PROD publish, DataStore migration or art update is
implied by this checkpoint.
