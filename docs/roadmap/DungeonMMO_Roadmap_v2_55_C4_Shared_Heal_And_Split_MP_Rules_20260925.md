# DungeonMMO Roadmap v2.55 — Shared C4 Heal and Split-MP Rules

Date: 25 September 2026.  
Branch: `wip/phase-4-test-hud-integration-v1`.  
Previous: [v2.54](
DungeonMMO_Roadmap_v2_54_Elven_Scout_C4_Heal_Migration_Plan_20260925.md).

## Goal

Continue the all-class Chronicle 4 migration without turning one class into
a special-case balance island. The immediate blocker from v2.54 was not the
Scout trainer itself: the project first needed one shared, source-backed
interpretation of original split MP costs and instant healing.

This milestone therefore adds reusable Chronicle 4 skill-runtime rules and a
server ManaService transaction shape that later C4 skills can share. It does
**not** switch live character HP/MP/CP, grant the Scout heal, or relabel
candidate creative skills as exact C4 equivalents.

Pinned source remains:

`Neco-spain/l2jadmins_C4-Scions-of-Destiny`  
commit `07f8536384e799f128d44198dd7ab23519660eea`.

## Source semantics now represented

The reviewed C4 casting path establishes a two-stage MP transaction:

1. before casting, the player must have enough MP for
   `mpInitialConsume + mpConsume`;
2. cast start spends only `mpInitialConsume`;
3. successful skill launch spends `mpConsume`;
4. MP reduction clamps at zero.

This matters for interruption. A cast interrupted after it begins has already
paid the initial MP portion but never reaches the launch-time charge.

The reviewed C4 instant-heal handler also establishes that ordinary Heal
effects use source effect power directly before MaxHP clamping:

- no charged shot: `power`;
- Spiritshot: `power * 1.3`;
- Blessed Spiritshot: `power * 1.5`.

The reviewed cast path scales authored magic `hitTime` by final M.Atk.Spd,
then applies the 70-percent Spiritshot/Blessed Spiritshot cast-time
acceleration. Authored skills of at least 500 ms retain the source 500 ms
minimum.

These statements describe the pinned source path only. Spiritshot inventory,
charge/discharge, complete healing threat, source HP/MP regeneration and all
active status interactions are **not** yet live-certified in DungeonMMO.

## GitHub implementation

### Shared C4 runtime rules

Added
`src/ReplicatedStorage/Core/Shared/C4SkillRuntimeRules.luau`.

It provides pure source-backed helpers for:

- split MP cost construction;
- combined pre-cast affordability;
- cast-start initial MP reduction;
- launch-time MP reduction with source clamp behavior;
- instant Heal power with Spiritshot multipliers;
- magic cast-time scaling and shot acceleration;
- pinned source provenance.

The module is intentionally reusable across all current original Human/Elf
starter and first-transfer paths. It does not know about Scout ownership,
creative class names or a particular trainer.

### ManaService transaction support

Extended
`src/ServerScriptService/Combat/ManaService.luau` with:

- `try_begin_split_spend(subject, initial_amount, completion_amount)`;
- `finish_split_spend(subject, completion_amount)`.

Existing `try_spend` behavior remains unchanged for current live skills.
No existing skill has been silently moved to the new C4 transaction API.

This is infrastructure, not a claim that the current custom ManaService pool
already equals C4 MaxMP. The authenticated nine-path source MaxMP reference
exists separately, but the live pool still needs coordinated resource
migration.

### Scout source contract tightened

`C4ScoutHealMigrationPlan` now uses the shared runtime rules for the nine
historical Elven Scout Elemental Heal ranks 4–12. Each source-only contract
records:

- uncharged heal output;
- ordinary Spiritshot heal output;
- Blessed Spiritshot heal output;
- initial, ongoing and total source MP;
- original SP, learn level, self-target, cast and reuse fields.

`ExactC4HealFormulaCertified=true` now means the reviewed instant-HP amount
formula for that source effect is certified. It does **not** mean the complete
live skill is certified: healing threat, shot item economy, live source MP
pool, live source MaxHP and the trainer/executor still remain outside this
milestone.

`SplitMPTransactionCertified=true` means the source transaction lifecycle is
represented. The Scout contracts remain:

- `SourceOnly=true`;
- `LiveLearnable=false`;
- `LiveCastable=false`;
- `CreativeLinkStatus="Missing"` in the authenticated source preview.

The existing custom `ElvenRenewal` HoT is still not treated as a substitute
for C4 Elemental Heal, and the Warden's separate heal ownership is not borrowed
by the Scout.

## Tests authored, execution pending

Added
`C4SkillRuntimeRulesTest.server.luau` with deterministic source vectors for:

- rank-four Elemental Heal MP 11 + 42 = 53;
- 52 MP rejection and 53 MP acceptance;
- initial and launch deductions;
- MP clamp behavior;
- heal 95 / 123.5 / 142.5;
- magic cast scaling and the 500 ms minimum.

Extended `ManaServiceTest.server.luau` for the split transaction API and
extended the authenticated nine-class skill preview regression for certified
Scout heal outputs and split-MP semantics.

**No v2.55 Rojo build or Studio execution is claimed yet.** Permanent edits
were made directly in GitHub without Remote Desktop Commander. The v2.53
500-assertion Studio result remains evidence for its earlier candidate only.

## All-class status

The all-nine original-path source inventory remains:

- 476 historical learning rows through level 30;
- 454 creative candidate links;
- 22 explicit missing rows.

The nine Scout Elemental Heal rows remain inside those 22 missing rows until
a genuine live skill, trainer ownership and resource/executor integration
exist. This milestone intentionally does not improve the mapping count merely
because the source formula is now understood.

The remaining 13 missing learning rows still require individual source
semantic review. They include historical common/passive families such as
Lucky, Common Craft, Magicians Movement, Spellcraft and Human Rogue Vital
Force; they must not be replaced with invented equivalents simply to make the
gap count reach zero.

## Next implementation

The next migration should stay shared across all implemented original classes:

1. define the coordinated live C4 resource boundary for authenticated
   nine-path characters, using exact class/level HP/MP/CP source vitals;
2. reconcile source item/passive/active-buff ordering before switching
   Humanoid MaxHealth or ManaService MaxMP, so old custom modifiers are not
   accidentally mixed with the historical model;
3. add the independent creative Scout Elemental Heal family only after it can
   use the same live source resource and formula path as every other C4 skill;
4. continue family-by-family source effect migration for all nine paths,
   including threat, statuses, passives and costs;
5. resolve the remaining 13 explicit source gaps from actual source semantics,
   followed by exploit, multiplayer and interruption regressions.

Legacy Ranger/Rogue content that has no direct original C4 one-to-one origin
remains compatibility content, not evidence of Chronicle 4 parity.

No main merge, Roblox publication, production DataStore mutation or
art/animation worktree changes. All permanent script/document edits stay in
GitHub.
