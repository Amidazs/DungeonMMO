# DungeonMMO v1.92 — real original C4 quest starter NPCs

Date: 23 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Scope: **first server-authenticated hub quest step only**.

## What is genuinely available in the Base

- The existing authoritative original C4 level-18 class choice
  remains unchanged: Human/Elf Fighter or Mystic must explicitly
  select an appropriate historical first-transfer branch.
  A source choice does not grant a class or quest completion.
- `C4OriginalQuestNpcRuntime` now registers two genuine
  `ProximityPrompt` world actors in the Base, using simple,
  non-blocking placeholder parts positioned relative to the
  resolved Base player spawn:
  - Human Rogue: **Captain Bezique**.
  - Elven Scout: **Master Reisa**.
  No models/meshes or final art were required.
- The actual **server** handles each prompt's `Triggered`
  callback. It requires a live authenticated Roblox
  `Player`, existing ready profile, original selected
  race/family/branch, living character and server-measured
  proximity of at most ten studs. Requests are throttled.
  No public client quest-evidence remote or client-authored
  item/kill/loot fields were added.
- A first NPC interaction starts the historical branch's
  ordered quest ledger only for its chosen character,
  and advances **exactly the first NPC talk step** using
  a single-use, server-created event receipt. The world
  adapter verifies that exact in-memory event, user,
  server-owned physical NPC and expected quest step;
  a replay or arbitrary future NPC/monster event is
  rejected. The quest progression is committed through
  the existing server-owned `ProfileService:mutate`.
- The existing Base class-choice snapshot now includes
  the authoritative `OriginalQuest` stage. The closable
  GUI shows a successful first NPC interaction and
  explicitly states that the **remaining dungeon quest
  stages and full advancement quest are still in
  development**. Source selection, class, gold, profession
  slots, skill ranks and inventory are unchanged by
  talking to the first NPC.
- The first-stage binder advertises physical availability
  **only for stage one**. After that step, the service's
  `WorldReady` becomes false and
  `OriginalQuestWorldNotReady` blocks all unbuilt future
  stages. `FirstNpcReady` and `FullWorldReady` are
  separate fields, so an early NPC does **not** falsely
  advertise a completed or playable entire quest.

## Actual unpublished Studio gameplay proof

Checked-in real-client test:
`scripts/studio/c4_original_quest_npc_live.luau`
using the source-controlled
`C4OriginalQuestNpcLiveDriver`.

A genuine Studio client used the original Base place and
the actual server-created physical `CaptainBezique`
`ProximityPrompt` through
`InputHoldBegin` / `InputHoldEnd`. Its first attempt
without a chosen original class did not create a quest.
In the *disposable test session only*, the test
set the authentic Human Fighter profile to level 18,
then selected Human Rogue through the existing
server-owned selection authority.

A second genuine client NPC prompt started and saved
`C4PathToRogue`, advanced the first source NPC step
to **step two** and sent that state to the actual
client GUI. The original class remained **Fighter**
and the first-transfer award remained absent.
A forged next quest stage was rejected as
`OriginalQuestWorldNotReady`; repeating the
first NPC prompt did not skip the missing Neti stage.
The playtest reported:

`[C4 Original NPC Live] VERIFIED_REAL_CLIENT_FIRST_STAGE_PASS`

The initial test-runner instrumentation inserted a
temporary test-only binding inside a parenthesized
Base statement and failed to start the Base runtime.
Only the test runner was corrected **in GitHub** to
inject after the complete call. The final real-client
test then passed. The later stage-specific world
availability assertion also passed on a fresh
unpublished Base build. An engine prompt input test
can require movement replication before the local
prompt becomes visible; the runner requires the
genuine server `Triggered` event and does not count
a local input acknowledgement as a successful quest.

## Backend regression

Re-executed the affected existing
`scripts/studio/c4_original_quest_skill_scope_focus.luau`
suite on the unpublished v1.92 Base composition:
**5/5 PASS, zero failures**. This includes
**117 original C4 quest-stage and source-skill scope
assertions**, original selected-class persistence,
quest/class selection rules, exact aggregate source
coverage and versioned quest-profile migration.
Existing v1.90 real two-client *class choice* acceptance
was not redundantly repeated; it remains a distinct,
previously passed acceptance.

Changed Luau files passed parser checks; disposable
Base and Dungeon Rojo builds passed. Local unrelated
untracked quadruped `__pycache__` files were left
untouched. All authored scripts/docs were edited via
GitHub; desktop was only used for clean fast-forward
pull, read-only QA, parser/build and unpublished
Studio testing. No `main` merge, Roblox publish,
production DataStore write or paid operation.

## Not yet implemented; no false C4 class completion

The real Hub can now begin only the first physical
original quest step. Original Human Rogue still needs
real Neti interactions, trial weapons, authenticated
instanced skeleton and Cats Eye Bandit kills,
distinct actual quest drops, Bezique return and
Ramos transfer. Elven Scout still needs Moretti,
letter fragments, real Prias rescue and sentry key,
Reisa return and Rains transfer; its live physical
first-NPC client playtest has not been independently
run yet. No artificial world adapter from the
source-only Studio quest progression tests is wired
into the production Base or Dungeon runtime.

The genuine historical **level-20 atomic class award**
and its original **class-specific trainer/skill
authorization** are still pending, along with the
full source skill inventories for the other classes.
Even the six-list `396/396` DungeonMMO functional
analogue rank tally is not a complete C4 source audit.

**Original first-transfer class paths fully
playable: 0/18.** A successful first quest NPC
interaction is not a completed original C4 quest.
