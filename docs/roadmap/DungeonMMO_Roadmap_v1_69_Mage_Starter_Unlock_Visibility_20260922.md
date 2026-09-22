# DungeonMMO roadmap v1.69 — early Mage skills and actual unlock UI

Date: 22 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Focused tested gameplay source:
`e6033e0c1a024837eef62fdea6cecc1c280beb8a`

## New functionality, focused locally verified

- [x] Add two **real** introductory Mage active skills: Dawn Ward
  (protective ward: 14/21/29) and Cinder Bolt (magic projectile
  damage: 12/18/25), with training at levels **1/7/14**.
- [x] Rank 2 requires earned proficiency 35; rank 3 requires 100.
  All ranks require real character level and SP and use the
  existing profile-backed trainer and combat authority.
- [x] Prevent class-restricted and not-yet-available abilities
  from appearing as locked rows in the actual player skill
  menu. Reuse the already filtered authoritative snapshot.
  Already learned skills remain visible; higher *ranks*
  on known skills remain visibly locked until eligible.
- [x] Trainer UI describes missing level, prerequisite skill
  rank or mastery and disables locked purchases. The server
  revalidates regardless of client behaviour.
- [x] One Base Rojo build and 39 focused assertions PASS for
  both abilities, rank gates, character restrictions,
  snapshot/trainer hiding, combat definition effects and
  profile save/reload.
- [x] One read-only C4 volume audit: **13/16 brackets still
  mismatched** and 14 older unmapped skill-rank occurrences.
  Mage level-1 now has 2 explicit new offerings versus
  7 in both mapped C4 races. Not source content parity.

[Focused test report](../testing/c4-mage-starter-ward-bolt-trainer-2026-09-22.md)

## Next actual work, without repeated dungeon tests

1. Verify one real client can open its trainer, see Dawn Ward
   and Cinder Bolt at level one but not the level-seven
   abilities, then use the new Ward and projectile through
   normal input. The 39 service assertions do not establish
   actual GUI or combat effects.
2. Map **existing** level-one Fighter and Mage starter
   rank offerings explicitly before adding extra abilities
   solely to reach a source count. Separate real effects,
   class/race applicability and C4 training-level schedules.
3. Fill remaining C4 rank gaps with implemented active,
   passive, defence, support and class-appropriate utility
   effects. Resolve the Human Fighter level-10 overcount
   by source-family mapping rather than deleting existing
   player skills or adding fake rank entries.
4. Expand the early-rank manifest to the corresponding
   advanced classes/races and eventually the remainder of
   the progression tree. Retain prerequisite mastery and
   character-level gates for every future class transition.

The actual user goal of C4-like per-level skill **rank volume**
is still OPEN; this increment adds two usable original
abilities and player-facing unlock rules, not a finished
Chronicle 4 skill catalogue, C4 name/asset clone or final
combat balance. Publishing, cloud continuity and real
cross-place recovery remain separate approval-gated work.

All scripts/docs edited directly in GitHub; remote machine
used only for focused local build/test and read-only audit.
No `main` merge, force-push or Roblox publish.
