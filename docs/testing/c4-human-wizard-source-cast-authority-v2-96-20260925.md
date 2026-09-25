# Human Wizard Source Cast Authority v2.96 — Acceptance

Date: 25 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.

## Result

**GREEN — exact source cast metadata and split-MP resource phases are
server-authoritative and independently tested. Live damage remains disabled.**

## Candidate

`c1a2f68e089c1b4bb33477da467765aaef70c5fd`.

## Exact cast contract

`C4SourceCastContractService` accepts only:

- authenticated runtime owner UserId;
- server-selected creative skill ID.

It reads the purchased creative rank itself, resolves the authenticated source
scope/rank, then reads the exact source effect fields.

Rank-6 `EmberweaverEmberBolt` resolves:

- creative rank 6;
- source scope `HumanWizard`;
- source skill 1220;
- source rank 6;
- `MDAM`;
- `ACTIVE`;
- `TARGET_ONE`;
- magic=true;
- `mpInitialConsume=6`;
- `mpConsume=21`;
- total=27;
- `hitTime=4000`;
- `reuseDelay=6000`;
- `castRange=750`;
- `effectRange=1250`.

The contract explicitly reports source-only state and no live resource/timing
integration.

Focused marker:

`[C4 Source Cast] SOURCE_ONLY_PASS: 11 assertions rank=true mp=true
timing=true range=true live=false`.

## Split-MP lifecycle

`C4SourceCastResourceService` uses the exact contract plus the existing source
resource and mana authorities.

A pending cast has a private monotonically generated receipt owned by the
server lifecycle. Only one pending cast exists per owner.

### Normal completion

At 30 MP:

- pre-cast total affordability for 27 MP passes;
- cast start spends 6 MP -> 24 MP;
- launch spends 21 MP -> 3 MP;
- receipt is cleared.

### Insufficient MP

At 26 MP:

- cast start fails;
- no initial MP is spent;
- no receipt is created.

### Interruption

At 30 MP:

- cast start spends 6 MP -> 24 MP;
- cancelling the receipt leaves 24 MP;
- launch cost is never spent;
- replay of the cancelled receipt is rejected.

### Authority changes

After cast start:

- changing the purchased rank invalidates launch;
- source-cutover withdrawal invalidates launch;
- initial MP remains spent in both cases;
- no launch MP is charged.

This prevents a stale receipt from surviving a class/rank/resource-authority
change.

Focused marker:

`[C4 Source Cast Resource] SOURCE_ONLY_PASS: 12 assertions
split=true cancel=true revalidate=true live=false`.

## Source combat regression

The existing Human Wizard direct MDAM proof remains green:

`[C4 Source Combat] SOURCE_ONLY_PASS: 43 assertions ... wizard=true ...
live=false`.

Combined runner:

`[Human Wizard Source Cast] RESULT passed=3 total=3`.

## Build/static evidence

- `git diff --check`: PASS;
- Base Rojo build: PASS;
- Dungeon Rojo build: PASS.

The only local untracked paths remain the pre-existing quadruped-animation
Python `__pycache__` directories. They were not edited or committed.

## Boundary

No live source spell is exposed yet. The next required gate is exact final
cast timing/reuse planning, including source M.Atk.Spd and shot acceleration,
before scheduling a live source launch.
