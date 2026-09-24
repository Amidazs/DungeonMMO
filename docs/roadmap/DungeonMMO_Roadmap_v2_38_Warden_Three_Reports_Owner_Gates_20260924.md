# DungeonMMO backend v2.38 — three earned Warden reports and private kill credit

Date: 24 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Executed candidate: `598ce9f2719b51b2f2d7711d86be41806fe2b5e7`.
Previous: [v2.37](DungeonMMO_Roadmap_v2_37_Warden_Client_Lethal_Quest_20260924.md).

## Three actual client-earned patrol reports across two real rooms

Unpublished disposable two-client Dungeon
`c4_greenward_warden_three_reports_two_rooms_live.luau` now
verifies the complete three-report combat stage, without modifying
production Warden enemy-count rules or using a server-only finishing
strike on any source-quest monster.

Player one uses normal client combat input to kill both registered
Rootbound Marauders in room one, receiving two personally earned
patrol reports. Player two separately kills the actual Thornbound
Colossus with real client hits and receives the personal guardian
seal, without sharing either reward with player one.
After the room-one **ordinary, nonquest** enemies are defeated
by the disposable server test driver (a deliberate progression
shortcut), the actual physical room-two trigger opens the next
existing instanced encounter. Player one kills a newly spawned
Rootbound Marauder using real client combat. The same server-owned
character now owns three reports, has proof
`VerdantPatrolReports3`, and naturally advances to quest stage
four. Player two owns no reports; player one owns no guardian seal.

The first extended driver attempt at `267397ac` **FAILED**:
the unanchored test avatar was knocked/redirected while swarmed
and did not land a lethal hit within the bounded attack window.
Commit `598ce9f2` stabilized its disposable attacker root and
increased *test-only* avatar HP to isolate quest kill credit,
while retaining the authentic client-originated damage and
unchanged registered enemy HP. No defence-balance or natural
ordinary-pack clearance is claimed from this fixture.
The corrected Studio log:
`%TEMP%\\DungeonMMO_v243_warden_three_reports\\three_reports.log`
ended with `VERIFIED_THREE_REPORTS_TWO_ROOMS_PASS`. Child Studio
logs separately recorded all three genuine lethal hits, the
individual report and seal milestones, and stage-four completion.
See [v2.38 evidence](../testing/greenward-warden-v2-38-three-reports-ledger-20260924.md).

## Revalidate personal source loot at both hit and reward time

`C4QuestMonsterCombatLedger` now checks the same authoritative
race, original base class, unadvanced Fighter identity, selected
branch, stage, character level and uncompleted quest state as the
quest-spawn gate. It checks both when recording a real contributor
and when awarding the one-use personally bound drop. Copying a
quest table, changing race/class/branch or advancing to a
different stage between hit and lethal processing cannot
authorize source loot. Original human and Elven branches use
the same shared rule.

Focused unpublished Dungeon Studio tests on `823fab36`:
**58** quest ledger assertions PASS; **21** source pack
assertions PASS; **13** contribution bridge assertions PASS;
**3/3** focused suites PASS. No public place or production save
was touched.

## Remaining original-class acceptance

All 56/56 historical Elven Knight training *rank schedules*
remain mapped; exact original C4 ability calculations, aura
targeting and full game release acceptance are not certified.
The genuine full Base->Dungeon->Base/rejoin saved journey and
uninterrupted physical NPC handoff for those exact three reports
are still OPEN: separate disposable Base and Dungeon profiles
were used. Natural Captain AI slash-to-Bleed Recovery is also
OPEN; the prior cure test explicitly invoked the trusted
post-hit status callback. Cross-class, PvP, real-economy and
all 18 first-transfer release gates remain OPEN.

No main merge, Roblox publication, production DataStore mutation,
or unrelated animation edits. Permanent source and docs through
GitHub; local desktop for fast-forward, disposable builds and Play.
