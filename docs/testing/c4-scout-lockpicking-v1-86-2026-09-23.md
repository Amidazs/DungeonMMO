# C4 Rogue / Elven Scout Lockpicking — v1.86 test record

Date: 23 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`

## Implemented backend

- `ScoutLockpicking` has five distinct **purchased** C4 source
  ranks at character levels **20, 24, 28, 32 and 36** for
  Human Rogue and Elven Scout analogues. Ranger/Rogue class
  lists and real trainers expose the skill, while
  server-authoritative unlock/training rejects incorrect
  source level, race/class and unearned rank.
- `ScoutLockpickingService` registers genuine server-owned
  `ProximityPrompt` interactions on physically present
  world cache parts. The Dungeon runtime creates simple
  placeholder caches beside registered normal-room
  checkpoints. The first five eligible ordered rooms
  have ranks one through five, where those physical rooms
  exist. Secret-boss rooms are excluded and harder
  layouts may expose more of the five ranks. Future
  finished art can replace the backend-only cache parts.
- Interactions validate exact active dungeon SessionId,
  server-selected DungeonId, connected and non-abandoned
  active party membership, a living original player
  character, server-measured **10-stud** proximity,
  reached checkpoint sequence, purchased lock rank,
  source character level/race/class and the original
  server-registered lock target. Optional authored
  `QuestId` locks additionally require the completed
  quest on the server profile. Current default cache
  definitions do **not** require a quest.
- Each properly qualified party member may claim each
  world cache **once per dungeon run**; party members
  receive separate personal rewards rather than allowing
  one person to empty another's inventory. A server
  session-side resource claim and a bounded,
  per-character SessionId/lock reward ledger protect
  against simultaneous repeated prompts, reconnect
  and duplicate grants after a successful inventory
  transaction. If the session claim succeeded but
  inventory persistence failed, replay may retry the
  profile grant; the profile ledger still forbids a
  second successful grant. The existing authoritative
  profile mutation grants only a server-authored
  `captain_emblem` quantity (one through five by rank).
  These dungeon rewards do not confer a gathering/
  crafting profession or profession-locked node access.
- Client input supplies no reward quantity, item ID,
  skill rank, session ID, container ownership or
  checkpoint advancement. An arbitrary bank, private
  inventory or auction-house item is never registered
  as an unlockable dungeon cache. The real ProximityPrompt
  path refreshes the successful claimant's inventory
  snapshot on the server.

## Focused original source/loot acceptance

Final executed unpublished Dungeon Studio test runner:
`scripts/studio/c4_scout_lockpicking_focus.luau`.

- **3/3 focused suites PASS, 0 failed**.
- New `C4ScoutLockpickingTest`: **104 assertions PASS**.
  Tested source level brackets, race/class trainers,
  actual sequential server-bought ranks, early and
  sixth-rank purchase rejection, real physical prompt
  registration and duplicate/unknown-item refusal.
  Tested actual inventory grant, same-session repeat
  denial, **save + release + reload** to a new profile
  service against the same in-memory persistence adapter,
  and a separate legitimate run earning its own loot.
- Strict six-source inventory: **1,176 assertions PASS**.
  Human Rogue: **95/99**, Elven Scout: **126/129**.
  Original four starter classes: **168/168**.
  Combined strict source coverage suite also passed.
- Changed Luau scripts parsed with the local Luau parser;
  disposable Base and Dungeon Rojo compositions built
  successfully. No unrelated accepted wipe/aggro/
  paid-revive test suite was repeatedly executed.

## Real one-client physical-world playtest

`scripts/studio/c4_scout_lockpicking_client_live.luau`
used `StudioTestService:ExecuteMultiplayerTestAsync(1, ...)`
in an **unpublished** disposable Dungeon composition.
Temporary Studio instrumentation exposed the real
Dungeon services to the test driver; it did not
modify any checked-in game runtime or production save.
A genuine LocalScript held the actual registered
`ProximityPrompt` through `InputHoldBegin` /
`InputHoldEnd`; the production server's prompt
`Triggered` event was observed with the actual
connected player as its argument.

The test confirmed: a player without the purchased
source rank received no loot; a Human Rogue purchasing
rank one received one real inventory item through
the actual world prompt; repeated client presses
did not duplicate that personal loot; room-two
access was refused until the **server checkpoint
was advanced in this test-only session**, and
rank-one ownership alone could not open the
rank-two cache. After an actual server rank-two
purchase, the genuine client prompt granted the
two-item reward. A spectating member, an
out-of-reach member and an arbitrary private-bank
lock ID were denied. The final real-client
Studio run reported:

`[C4 Scout Lock Live] VERIFIED_REAL_CLIENT_LOCKPICKING_PASS`

The first client test attempt timed out because the
test driver issued prompt input immediately after
moving the test player. The test runner was updated
to allow 0.4 seconds for movement replication before
the genuine client prompt input. The subsequent
run observed actual server prompt events and
passed the full targeted client acceptance.
Only test-runner instrumentation was changed
for that timing fix.

**Boundaries of this proof:** Ranks three through five
are purchased and their matching physical locks are
registered when the room layouts have enough normal
rooms, but an entire real-client playthrough of
all five rooms and a human review of final chest art
have not yet occurred. Test-only checkpoint
advancement is not proof of combat-clearing
a real second room. Optional quest-specific
cache content and a separate multi-client
personal-loot playtest remain future content
acceptance; the underlying quest flag and per-member
session/ledger checks are implemented server-side.

## Original C4 inventory accounting

| Original source inventory | Implemented / raw | Remaining |
| --- | ---: | ---: |
| Four starting classes | 168 / 168 | 0 |
| Human Rogue (partial first transfer) | 95 / 99 | 4 |
| Elven Scout (partial first transfer) | 126 / 129 | 3 |
| **Six inventoried classes** | **389 / 396** | **7** |

Pending six-inventory source families are
Equipment Expertise, Lung Capacity and Fall
Resistance for **each** of the two first-transfer
classes, plus Human Rogue's Sprint. Seven
**other original C4 first-transfer class
catalogues remain unmapped**, excluded from
the remaining seven. **0/9 first-transfer
class paths are fully complete.**

All scripts, tests, composition code and docs
were edited in GitHub. The desktop was used
only for read-only diagnostics, clean fast-
forward pulls, parser/build and unpublished
Studio playtesting. No `main` merge,
Roblox publishing, production DataStore
mutation, paid operation or force reset.

**v1.86 focused C4/loot PASS; actual client
physical prompt and ranks one/two PASS.
Full original C4 catalogue INCOMPLETE.**
