# DungeonMMO Current Engineering State

**State date:** 16 September 2026
**Canonical long-form roadmap:** `docs/roadmap/DungeonMMO_Roadmap_v1_37.docx`
**Current phase:** Phase 2 - Vertical Slice
**Phase 2C:** FUNCTIONALLY COMPLETE
**Starting Base + Temple integration:** ACCEPTED
**Profession Foundation:** ACCEPTED
**Second Modular Dungeon + Rare-State/Event Proof:** ACCEPTED

## Canonical accepted gameplay boundary

- Phase 1: ACCEPTED / functionally complete.
- Phase 2A: ACCEPTED / functionally complete.
- Phase 2B.A/B/C: ACCEPTED; Phase 2B functionally complete.
- Phase 2C.A through Phase 2C.E: ACCEPTED; Phase 2C functionally complete.
- Starting Base + Temple integration: `c7fe89ebda3c97634c97e89ad12e52ec23983ae9`.
- Profession Foundation gameplay checkpoint:
  `ce1577990f2795bf208d7b897e645f32a4a39a4f`.
- Second Dungeon / Rare-State / Event gameplay checkpoint:
  `d361348ec045873eed0fd992ceb04bfee908b06a`.

The documentation closeout commit containing this file and Roadmap v1.37 is
fast-forwarded to local `main` by the approved local-merge closeout. The exact
post-closeout local-main SHA is printed in the closeout receipt. `origin/main`
is deliberately not pushed by this option.

## Accepted second-dungeon architecture

The second functional dungeon is **Abandoned Mine**.

Its functional route is:

- Entry Shaft;
- Room 1: Ore Gallery or Rooted Cavern;
- Room 2: Winch Chamber or Flooded Cut;
- Foreman's Vault.

The Room 1 and Room 2 module selections are deterministic per session. The
current Mine is a synthetic functional candidate, not final authored art.

Run-scoped instance variation is server-owned and persisted once on
`DungeonSessionService.InstanceState`. Reconnect/reconstruction reuses the same
state instead of rerolling it.

### Crystal Bloom

`CrystalBloom` is the accepted first rare dungeon state. The current prototype
chance for an ordinary new Abandoned Mine session is 20 percent. Studio may
force it for deterministic tests.

It adds Room 2 encounter pressure, visible crystal presentation and the rare
completion-reward definition without invalidating the normal completion route.

### Deep Echoes

`DeepEchoes` is the accepted first time-limited event proof. Eligibility is
controlled by an operations start/end Unix window and is resolved only when a
new eligible Abandoned Mine session is created. Already-created sessions do not
change.

It adds Room 1 encounter pressure, event presentation and the event completion
reward. Crystal Bloom and Deep Echoes may coexist; event completion rewards take
precedence while normal completion remains valid.

## Accepted evidence

The project owner completed both required Studio runs and reported that all
requested checks worked as expected.

Normal Abandoned Mine evidence:

- focused new test families reported PASS;
- player spawned in the synthetic Abandoned Mine rather than Temple;
- `[Second Dungeon State]` printed two module IDs;
- Room 1 used two enemies and Room 2 used three;
- the boss was presented as Corrupted Foreman;
- completion and Studio Return-to-Base simulation worked.

Forced Crystal Bloom + Deep Echoes evidence:

- output reported `Rare=CrystalBloom` and `Event=DeepEchoes`;
- purple Deep Echo presentation appeared in Room 1;
- cyan Crystal Bloom presentation appeared in Room 2;
- Room 1 used three enemies and Room 2 used four;
- Corrupted Foreman and completion still worked;
- no new red runtime errors were reported.

Before Studio testing, the implementation runner also completed its automated
baseline proof, static contract check, `git diff --check` and fresh Base,
Dungeon, published Base and published Dungeon Rojo builds.

Detailed evidence is recorded in
`docs/testing/phase2-second-dungeon-rare-event-acceptance-record.md`.

## Existing accepted contracts preserved

The gate reuses rather than duplicates:

- semantic environment anchors;
- `DungeonSessionService`, handoff and reconnect;
- server-authoritative combat/rewards;
- completion eligibility and exactly-once rewards;
- save-before-return and Base recovery;
- schema-v6 Profile / Inventory / Equipment / Professions;
- Dungeon Equipment run-lock;
- Fighter, Mage and Ranger;
- Mining / Blacksmithing and Herbalism / Alchemy;
- personal reconnect-safe Temple resource claims.

No profile-schema bump was required.

## Qualifications / deferred work

- The synthetic Abandoned Mine is gameplay proof, not launch art.
- Exact rare/event balance values remain tuning data.
- Final Mine art must use the isolated environment asset-library workflow.
- The pre-player live legacy migration waiver remains a qualification, not a
  migration PASS.
- Wider Temple resource spread remains deferred presentation/environment polish.
- No Roblox place was published by this gate.
- No PROD, Robux or monetisation action occurred.

## Exact next engineering action

The selected next Phase 2 gate is **real party formation + 1-4-player group
entry**.

Design/spec it before source work. Reuse the accepted
`DungeonSessionService`, `TeleportCoordinator`, reconnect/completion authority
and both Temple and Abandoned Mine definitions. Do not create a parallel
persistent party system.

The design still needs to lock invite flow, leader authority, membership
changes, ready/entry rules, UI presentation and leave/reconnect behaviour.
Public matchmaking, guild-party breadth and cross-server social discovery are
not part of the first proof unless explicitly selected.
