# Phase 4 Event and Secret Gameplay Rules Plan
Spec: ../specs/2026-09-19-phase4-event-secret-gameplay-rules-design.md
Execution: inline, user requested no intermediate approvals; step-end report.
No commits, pushes, merges or publishing are implied.

1. Finish baseline visual smoke: identity, movement, combat/defeat, UI observations.
2. RED: add scheduling/discovery tests and optional reward-source/identity tests.
   Run in Studio against cb29a7c and retain expected failures.
3. GREEN: implement server rule resolution and issuer integration; persist eligible
   side-route discovery using session state and validate at the real runtime trigger.
   Explicitly configure optional book drops and isolate boss reward identities.
4. Verify all relevant regression families, 4 TEMP builds, source parse and diff.
5. Visual fixture: TEMP-only registered side arenas and disabled-test rollout override;
   traverse, fight, inspect discovery/reward state, normal final completion and skip.
6. Fresh independent code review; fix significant findings with RED/GREEN evidence.
7. Update continuity/evidence, report limitations and stop at the step-2 checkpoint.

## Ledger
- Baseline visual: synthetic Temple entry/enemy pursuit/defeat visible.
- Small 638x503 capture exposes existing objective/profile/debug overlap.
- Step-1 source cb29a7c unchanged; step-1 documentation WIP preserved.
- Ruling: existing isolated optional-boss worktree is reused for this continuation;
  source remains separate from main/UI/art.
- Ruling: user autonomy instruction supersedes extra design approval prompts.
- Tasks 2-7 pending.
