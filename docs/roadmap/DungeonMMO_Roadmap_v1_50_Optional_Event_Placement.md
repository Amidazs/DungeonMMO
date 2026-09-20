# DungeonMMO Roadmap v1.50 — configurable optional Event placement

**Date:** 20 September 2026

**Status:** ChatGPT-authored, GitHub-backed Phase 4 backend supplement.
The historical canonical `DungeonMMO_Roadmap_v1_47.docx` and v1.48/v1.49
supplements remain preserved; this file updates the current engineering
milestone, not the published Roblox experience or the main branch.
**Active integration branch:** `wip/phase-4-test-hud-integration-v1`.

## Completed locally: configurable encounter placement contract

The generic Temple/Mine optional-boss backend now supports an explicitly
catalogued, server-issued Event placement per run instead of treating the
after-Room1 insertion as an unchangeable code location. The existing
`EventAfterRoom1` and `SecretBeforeFinal` paths remain compatible.
A new `EventAfterRoom2` template is supported at Depth2–4 using a
separate, stable `EventArenaLate` physical-room identity and
encounter-scoped reward identity. At Depth4, Room2 is the first returning
miniboss; the new Event insertion follows it rather than assuming
Room2 always contains ordinary combat.

A separate server-only `DungeonMMOOptionalBossTemplatesEnabled`
opt-in defaults OFF and never enables the original optional-boss or
higher-depth release switches. An eligible, opted-in new run uses
a deterministic server seed to choose its template once and persists
that choice with its boss identity and encounter plan. A recovered
run cannot reroll, move or duplicate the selected encounter.
The existing policy enforces one Event and one Secret per run and
rejects incompatible or duplicate physical-room claims.

**Release/readiness boundary:** Only the original Event/Secret arenas are
physically registered. The newly specified `EventArenaLate` has no
authored or replaceable placeholder bridge, gate, trigger or spawn yet.
Its template is **backend-ready, not locally playable or released**.
The server rejects a selected late Event against the current layout
rather than inserting a boss into an unrelated room. Synthetic physical
metadata in unit tests is not a substitute for an actual traversable
route. This work has not created a cave-in, mining, environmental hazard,
ordinary mob-pack event, second event scheduler or other new event
*mechanic*; those are separate options for future development.

## Acceptance evidence

- New deterministic template/placement/frequency/recovery matrix:
  **274 assertions PASS** for both dungeons and supported depths,
  including unprepared-room rejection and a default-compatibility
  check at Depth1–4.
- Focused optional boss suites: **23/23 PASS**. Broader gameplay backend
  matrix: **30/30 PASS**. Four local Rojo build compositions succeeded.
- Fresh assisted physical Temple Depth2 playtest passed with the
  original Event and Secret routes, and a separate Temple Depth2
  playtest passed with both previous alternate boss variants and
  encounter-scoped reward replay checks. These were tests of existing
  physical routes, **not** a physical test of `EventArenaLate`.

Full dated receipts, fixture correction and safety constraints:
`docs/testing/phase4-optional-event-placement-templates-2026-09-20.md`.

## Next backend/release-gated steps

1. **Complete the late-Event physical contract, if this event location
   is wanted in playable content.** Add a separate replaceable
   `EventArenaLate` room, reachable bridge, server-owned gate,
   depth-specific trigger/boss/checkpoint anchors and matching
   authoritative placement metadata, without moving or breaking the
   existing EventArena or required rooms. Prove walking traversal,
   concurrent party entry, disconnect/recovery, exactly-once rewards
   and optional-disabled compatibility in independent Studio runs
   before ever switching on late placements for real users.
2. **Broaden event mechanics deliberately, not by accumulating boss
   aliases.** Candidate templates such as a cave-in, timed monster pack
   or gathering bonus need an explicit event effect/executor and
   reward policy registered through the existing encounter runtime.
   Each new event must declare its allowed physical slots, one-run
   frequency, prerequisites and saved restart behaviour. Do not
   implement an alternative scheduler or give clients authority to
   select or reroll events.
3. **Then shift backend effort to the larger MMORPG features** rather
   than repeating accepted dungeon foundations: remaining
   crafting/profession and cross-profession progression depth, raid
   and weekly world-boss gameplay, guild castle competition, and
   end-to-end economy/party integration. Scope each feature against
   existing systems and accept it through its own regression/playtest
   matrix rather than interpreting a locally green Dungeon backend as
   a finished whole-game backend.

**Separately deferred acceptance:** Actual same-account network rejoin
into a recreated Roblox server, published cloud TEST verification and
unassisted higher-depth multiplayer combat/balance. No PROD publish,
live player DataStore change, authored art change, force-push or merge
to main is included in the v1.50 checkpoint.

## Handoff

Start with `docs/ai/CURRENT_STATE.md`,
`docs/ai/HANDOFF.md`,
`docs/ai/TEST_MATRIX.md`,
this supplement and its dated test report. Continue GitHub-first
source changes and unpublished local Studio verification until the
user explicitly authorizes cloud release work. Preserve accepted
Depth1–4 progression, optional routes, the pre-existing
reward/disconnect hardening and current default-OFF switches.
