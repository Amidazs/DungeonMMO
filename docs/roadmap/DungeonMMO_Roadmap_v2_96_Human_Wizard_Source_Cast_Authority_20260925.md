# DungeonMMO Roadmap v2.96 — Human Wizard Source Cast Authority

Date: 25 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v2.95](
DungeonMMO_Roadmap_v2_95_Human_Wizard_Source_Combat_20260925.md).

## Status

**GREEN — Human Wizard source cast costs and split-MP lifecycle now have a
server-owned authority boundary, still isolated from live damage.**

## What changed

v2.95 proved an authenticated Emberweaver direct spell could resolve exact C4
source skill/effect/stat data through the source-only MDAM calculator.

v2.96 adds the resource side required before a real cast can safely use that
damage path.

### Source cast contract

New `C4SourceCastContractService` resolves the currently purchased,
server-owned creative rank to exact source cast metadata.

For `EmberweaverEmberBolt` rank 6 it preserves:

- source skill ID: **1220**;
- source rank: **6**;
- `mpInitialConsume`: **6**;
- `mpConsume`: **21**;
- total pre-cast affordability: **27 MP**;
- authored `hitTime`: **4000 ms**;
- authored `reuseDelay`: **6000 ms**;
- cast range: **750 source units**;
- effect range: **1250 source units**;
- source type: `MDAM`;
- target: `TARGET_ONE`;
- magic flag: true.

The caller does not provide a rank. The service reads the actual purchased rank
from `ProgressionRuntimeState`, preventing a client/request payload from
choosing another source rank or cost.

### Split-MP source lifecycle

New `C4SourceCastResourceService` composes the cast contract with the
existing source-resource authority and `ManaService` split-spend primitives.

The lifecycle now models the already-pinned Chronicle 4 sequence:

1. require active source-resource cutover;
2. require current MP to cover the full initial + launch cost;
3. spend only `mpInitialConsume` at cast start;
4. retain that initial spend if the cast is interrupted;
5. revalidate class/skill/rank authority before launch;
6. spend `mpConsume` only when the cast is committed/launched;
7. allow only one pending source cast per owner;
8. invalidate replayed, cancelled or stale cast receipts.

The service remains server-only and does not apply damage.

### Dependency isolation

The cast-resource lifecycle uses explicit dependencies and lazy-loads
Dungeon-only production authorities. This keeps Base-focused tests isolated
without weakening the real Dungeon resource boundary.

The new services were refactored into small validation/resolution/evidence
helpers rather than one long procedural cast function.

## Focused acceptance

Accepted candidate:

`c1a2f68e089c1b4bb33477da467765aaef70c5fd`.

Fresh results:

- `git diff --check`: PASS;
- Base Rojo build: PASS;
- Dungeon Rojo build: PASS;
- source cast contract: **11 assertions PASS**;
- source cast resource lifecycle: **12 assertions PASS**;
- source combat calculation: **43 assertions PASS**;
- Human Wizard source-cast focused runner: **3/3 PASS**.

The lifecycle acceptance proves:

- rank-6 Ember Bolt at 30 MP spends 6 MP on start and 21 MP on commit, leaving
  3 MP;
- 26 MP rejects the 27-MP cast before any partial spend;
- interruption leaves the initial 6 MP spent but does not spend the 21-MP
  launch charge;
- a changed purchased rank invalidates the pending receipt before launch;
- source-cutover withdrawal invalidates the pending receipt without refunding
  initial MP;
- duplicate/replayed receipts cannot spend again.

## Corrected test-environment dependency issue

The first lifecycle-focused Base run exposed a test-environment dependency:
the new service eagerly required Dungeon-only `ManaService` through
`C4ResourceCutoverService` before injected test authorities could be used.

The production contract was not weakened. Dependencies are now lazy-loaded only
when defaults are actually needed, and the full focused rerun passed.

## Safety boundary

v2.96 does **not**:

- expose cast authority to clients;
- enable source combat by default;
- apply source spell damage;
- schedule a live cast timer;
- start a live source cooldown;
- convert source range units to studs;
- consume or accelerate Spiritshots during a live cast;
- certify all Human Wizard effect families;
- implement companion/servitor rows.

## Next implementation

Add server-owned final cast-time/reuse planning before applying live source
damage.

The next slice should combine:

- the exact source `hitTime` / `reuseDelay`;
- the authenticated final Human Wizard M.Atk.Spd;
- existing pinned C4 magic-cast scaling;
- charged Spiritshot/Blessed Spiritshot state without consuming it early;
- a private cast deadline/launch timestamp;
- cancellation/authority revalidation before launch.

Only after that timing gate is proven should one bounded Emberweaver direct-MDAM
cast be connected to the existing source executor.

No `main` merge, Roblox publish, production DataStore mutation or animation
work.
