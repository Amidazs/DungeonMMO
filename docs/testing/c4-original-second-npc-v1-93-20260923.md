# DungeonMMO v1.93 — actual original C4 second quest NPCs

Date: 23 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Scope: **real second physical NPC interaction for two original
first-transfer quests; later combat and class transfer still blocked.**

## Implemented directly in GitHub

- The original Human Rogue **Neti** and Elven Scout
  **Guard Moretti** now exist as separate server-owned,
  non-blocking placeholder NPC parts with genuine
  `ProximityPrompt` interactions in the live Base.
  Captain Bezique and Master Reisa remain their respective
  first-stage actors. Source NPC availability is now
  evaluated **per current ordered quest step**, not by
  assuming the first NPC is the only available actor.
- All physical NPC interactions resolve an authenticated
  connected `Player`, loaded selected profile, existing
  explicit original race/Fighter/class choice, living
  humanoid, real server-measured ten-stud proximity,
  correct active quest stage, 0.65-second interaction
  cooldown and a **single-use exact server-owned receipt**.
  The stage and corresponding NPC part/target must match
  before the original quest service persists progression.
  Neither clients nor an unrelated NPC can submit a
  forged Neti, Moretti, monster, item, or transfer receipt.
- On the **real ordered Neti stage only**, the original
  quest service adds exactly one personal
  `neti_trial_dagger` and one `neti_trial_bow` in
  the **same authoritative profile mutation** that
  advances the quest. The transaction verifies both
  existing/added inventory quantities; any failure
  prevents stage advancement and item creation together.
  Both pieces are genuine equippable original Human
  Fighter weapons with the appropriate Dagger/Longbow
  combat tags, personal binding and server-enforced
  no-trade/no-bank restrictions. Models and game-balance
  statistics remain placeholder work. No other
  character, branch, or second NPC receives those items.
- The real Guard Moretti meeting advances only the
  Elven Scout's own quest to the pending Ol Mahum letter
  fragment stage. It **does not** invent the four fragment
  drops, release Prias, or grant an advanced class.
- Both original quest snapshots and the existing closable
  class-choice GUI identify Neti/Moretti as available
  after the first NPC. Stage three correctly reports
  `OriginalQuestWorldNotReady` because real
  quest-specific instanced monster combat, drops and
  transfer NPCs have not been bound. A stage-two
  authenticated physical NPC is not a fully playable
  historical quest.

## Executed unpublished Studio tests

1. **Actual two-client Base playtest PASS**:
   `scripts/studio/c4_original_second_npc_two_client_live.luau`
   ran `StudioTestService:ExecuteMultiplayerTestAsync(2, ...)`.
   The genuine Human Fighter client selected Human Rogue
   and triggered Captain Bezique, then the real Neti
   `ProximityPrompt`. The real authoritative profile
   granted both one-of-one personal trial weapons,
   and the live equipment service successfully
   equipped each weapon. A forged Neti receipt,
   a Human visiting the unrelated Moretti,
   replaying an already completed NPC interaction
   and attempting to enter unbuilt monster
   stages did not bypass the source gates.

   The independent genuine Elf Fighter client
   selected Elven Scout, triggered the real
   Master Reisa and Moretti prompts and reached
   the correct separate step three. It received
   **none** of the Human's trial weapons;
   the Human retained their own separate
   equipment and progress. Neither client
   received an advanced class, a free
   level-20 transfer, or fake monster drops.
   Studio reported
   `[C4 Original Second NPC Live] VERIFIED_TWO_CLIENT_STAGE_TWO_PASS`.
2. **Focused regression 5/5 PASS**:
   `scripts/studio/c4_original_quest_skill_scope_focus.luau`.
   The original source-stage suite passed **125
   assertions**, including stage-two owned
   equipment, no trade/bank, wrong-branch
   reward denial, and successful owner-specific
   item persistence through profile
   save/release/reload. Original selection,
   race/family class rules, strict 0/18
   full class-path coverage and quest-profile
   migration suites also passed.
3. **Previous one-client first NPC compatibility
   PASS**, rerun only because the same NPC
   availability changed: the original real
   Captain Bezique prompt still starts the
   source quest without any class award.
   Its updated test now correctly expects
   Neti to be physically available while
   rejecting a client-forged Neti stage.
   Studio reported
   `[C4 Original NPC Live] VERIFIED_REAL_CLIENT_FIRST_STAGE_PASS`.

Affected Luau sources and both disposable
Base/Dungeon Rojo compositions passed the
local parser/build checks. All scripts,
tests, and documentation were changed
**directly through GitHub**. The desktop
was used only for clean fast-forward pulls,
read-only logs, disposable local build and
unpublished Studio tests. The unrelated
untracked quadruped Python caches were
left untouched. No `main` merge, Roblox
publishing, production DataStore changes,
paid operations, or destructive local
repository resets occurred.

## Exact boundaries and next engineering gate

Stage three of Human Rogue requires genuine
server-owned instanced skeleton/Spartoi
combat, the earned/actually equipped trial
weapon and **ten distinct authenticated bone
proofs**. The subsequent Cats Eye Bandit
stage needs its separately earned four stolen
items, then Bezique's return and the authentic
level-20 Ramos class transfer. Elven Scout
stage three needs genuine Ol Mahum patrols
yielding four distinct letter fragments,
Moretti's real turn-in, a real Prias
rescue and sentry key, Reisa's return
and Rains's own level-20 transfer.
The new NPCs do not satisfy or shortcut
any of these requirements.

No actual dungeon quest monsters, combat/drop
proof ledger, full historical source skill
parity or atomic original class award is
claimed implemented by this v1.93 stage.
**Original first-transfer classes fully
playable: 0/18.** Only Human and Elf
Fighter/Mystic starting families are
currently exposed; the other original
races and branches remain future
scope. Exactly one gathering and one
crafting profession per character
remains the DungeonMMO rule.
