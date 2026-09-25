# DungeonMMO Roadmap v2.62 — C4 Authoritative Active Source State

Date: 25 September 2026.  
Branch: `wip/phase-4-test-hud-integration-v1`.  
Previous: [v2.61](
DungeonMMO_Roadmap_v2_61_C4_Active_Effect_Calculator_Ordering_20260925.md).

## Goal

Begin replacing "learned skill" assumptions with real server-owned runtime
effect state. A C4 active/toggle source rank now exists in the source
calculator only after an existing authoritative combat executor actually turns
the corresponding creative skill on.

## Implementation

Added `C4ActiveSourceEffectResolver`.

It resolves a server-selected creative skill/rank to an exact reviewed C4
ACTIVE or TOGGLE source row while enforcing:

- complete authenticated original Human/Elf identity;
- launch level <= 30;
- actual saved `Known=true` ownership;
- purchased creative rank >= the activated rank;
- current or inherited starter source scope;
- reviewed source mapping only;
- ACTIVE/TOGGLE source operate type only.

Added server-only
`Core/Services/C4ActiveSourceEffectState`.

The registry:

- never accepts source skill IDs from clients;
- resolves source IDs again from private `ProgressionRuntimeState`;
- binds every active record to the exact current Roblox character instance;
- invalidates stale records after respawn;
- removes individual effects on deactivation;
- clears all effects on respawn/player removal;
- returns detached, sorted source-rank snapshots;
- ignores display attributes when deciding whether an effect is active.

The four existing live toggle executors now bridge into this registry:

- Scout Accuracy;
- Scout Critical Power;
- Ironvow Accuracy;
- Ironvow Critical Stance.

Activation is registered only after the toggle's ordinary server authorization.
Explicit deactivation, upkeep failure, invalid authorization, respawn and
player removal all remove the source record.

## Fresh acceptance

Tested commit:
`d379e9662fd780ed8428db72eb79bb6e4a6ba7ba`.

Both disposable Rojo builds PASS.

Focused Studio:

- Base: **9/9 PASS**;
- Dungeon: **10/10 PASS**.

New `C4ActiveSourceEffectStateTest`: **12 assertions PASS**.

It verifies:

- owned-but-inactive toggles do not appear;
- forged display fields cannot mint source effects;
- Warrior Accuracy maps to source skill 256 rank 1;
- Warrior critical stance maps to source skill 312 rank 3;
- two genuine toggles coexist;
- unowned ranks are denied;
- explicit deactivation removes only the ended effect;
- respawn invalidates stale records;
- first-transfer characters can resolve genuinely owned inherited starter
  active skills;
- passives cannot enter the active-effect registry;
- learnable-but-unowned active skills are denied.

Evidence directory:

`%TEMP%\DungeonMMO_v262_active_source_state`

The two Studio plugin-settings parse warnings are unrelated to these tests;
all focused assertions completed successfully.

No place was published, no production DataStore was changed and no main merge
occurred.

## Remaining active-effect work

The registry currently receives the four live toggle families. Timed
`CombatStatusService` buffs and the separate Ironvow Endurance Surge still
need authoritative activation/expiry bridges.

The `ActiveEffectOrderingIncomplete` resource blocker therefore remains.

Next:

1. bridge timed server-owned buffs into the source-effect registry;
2. bridge Endurance Surge;
3. expose the registry snapshot to the authenticated C4 resource boundary;
4. make unsupported live custom effects fail closed rather than disappearing
   from a source stat candidate;
5. remove the active-effect blocker only after that complete runtime boundary
   is green.

CP runtime authority remains the final fixed coordinated blocker after active
effects are complete.

Permanent scripts/documents stay GitHub-only. Remote Desktop Commander is used
only for fast-forwarding, disposable builds and unpublished Studio tests.
