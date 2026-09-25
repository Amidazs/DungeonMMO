# Human Wizard First-Transfer Foundation v2.94 — Acceptance

Date: 25 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.

## Result

**GREEN — the Human Wizard path now has an original DungeonMMO first-transfer
foundation, an authenticated level-18-to-20 quest transaction, a class-bound
trainer and exact non-servitor training schedules through level 30.**

This is a backend foundation, not full C4 effect parity or release
certification.

## Accepted candidate

`3d31e7344a379fc3808c59d5551dd21990179c2c`.

## Creative class identity

The historical Human Wizard source path now resolves to the independently named
DungeonMMO class **Emberweaver**.

It remains:

- Human-only;
- based on the existing Mystic/Mage starter family;
- unavailable at fresh character creation;
- obtainable only after the separately selected first-transfer branch,
  completed authenticated quest, level-20 gate and one-use mentor receipt.

Its physical mentor is **Magister Orwyn** and its class trainer is
`EmberweaverTrainer`.

## Creative advancement quest

The new **Emberglass Trial** preserves the existing first-transfer architecture:

1. Magister Orwyn starts the trial;
2. Archivist Neris provides the field task;
3. three distinct Ashveil Acolyte lives each grant one bound
   `aetherglass_shard`;
4. the Archivist turn-in consumes all three shards;
5. one Cinderbound Conjurer grants one bound
   `cinderbound_ember_sigil`;
6. the final Magister turn-in consumes the sigil and readies the transfer.

The transaction test proves unique monster receipts, personal bound inventory
and ordered proof are used by the same authoritative profile mutation path.

The test then proves the completed quest is still insufficient below level 20.
At level 20 a separate one-use server mentor receipt awards Emberweaver while
preserving `BaseClassId = "Mage"`.

## Mage-family authorization fix

The existing first-transfer skill authorization was still conditional on
`BaseClassId == "Fighter"`.

That was safe for the five previously implemented Fighter paths but would have
allowed a forged Mage first-transfer identity to bypass the intended mentor
receipt boundary.

`SkillUnlockRules` now requires an authenticated
`AllowedFirstTransferClasses` receipt for **every** starter family.

The focused test proves a bare Human Mystic cannot train an Emberweaver spell,
while an authentically awarded Emberweaver can.

## Level-30 training schedule

The source inventory remains **93 rank rows** through level 30.

The new creative schedule maps **74/93** rows into 24 independently named
Emberweaver families.

The remaining **19/93** rows are deliberately unmapped because they depend on
a real server-authoritative companion system:

- Servitor Heal;
- Servitor Recharge;
- mana-support summon;
- combat summon.

No placeholder pet, inert skill or fake rank was added to make the count look
complete.

## Verification

Fresh unpublished Base focus:

- `C4HumanWizardFoundationTest`: **166 assertions PASS**;
- `C4HumanWizardQuestTransactionTest`: **22 assertions PASS**;
- `C4Level30LaunchCoverageTest`: **37 assertions PASS**;
- focused runner: **3/3 PASS**.

Fresh source/build checks:

- `git diff --check`: PASS;
- Base Rojo build: PASS;
- Dungeon Rojo build: PASS.

## Current launch audit

Human Wizard now reports:

- source rows: **93**;
- trainer-mapped rows: **74**;
- deliberately unmapped rows: **19**;
- source-rank schedule complete: false;
- status: `SkillRankParityOutstanding`.

The overall release gate remains closed.

## Safety boundary

v2.94 does not:

- claim the 74 mapped rows have exact C4 live effects;
- implement or fake the 19 companion-dependent rows;
- enable source combat by default;
- publish Roblox places;
- merge to `main`;
- mutate production DataStores;
- change animation assets.

## Next backend slice

Continue Human Wizard effect fidelity using the already accepted C4
source/formula layer. Start with ordinary spell/passive families that do not
depend on companions, then build server-owned companions before mapping the
remaining 19 rows.
