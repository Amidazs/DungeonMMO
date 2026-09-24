# DungeonMMO v2.53 — authenticated source skills across all nine paths

Date: 25 September 2026. Branch: `wip/phase-4-test-hud-integration-v1`.
Executed candidate `71aa000d430c3515b5126eb9ecf312d3e20065b3`.
Previous: [v2.52](
DungeonMMO_Roadmap_v2_52_C4_Nine_Class_Authoritative_Stat_Preview_20260925.md).

## Source-only C4 skill-tree integration with real server identity

`C4AuthenticatedSkillSourcePreview.for_character`
returns pinned historical C4 rank-level, original SP,
split initial/ongoing MP cost, source target/type,
reuse and cast timing, exact source effects, modifiers
and equipment conditions for the verified current
original character path. Source skill *power* remains
in original units, separate from existing custom Roblox
damage and healing calculations.

`ProgressionRuntimeState.get_c4_source_skill_tree(user_id)`
uses the current server-owned selected character, never
a client-supplied race, class or skill ID. Inherited
original mentor proof/receipt and the complete current
class identity are required for first-transfer paths.
Source learning rows above the current character level
are not returned, and level 31 is explicitly refused
until original class growth and skill availability
beyond 30 have been independently verified.

The preview is learnability metadata, **not** proof of
owned/purchased source skills or available original SP.
Creative skill links are explicitly labelled Candidate
or Missing, with `ExactC4EffectCertified=false`
and `LiveIntegrated=false`. A first-transfer Scout
does not silently borrow Warden's independently
registered heal because both contain original skill 58.

## Executed unpublished Studio source audit

Base and Dungeon disposable Rojo builds both PASS.
Focused Base Studio
`c4_nine_class_authenticated_skill_preview_focus.luau`:
**500 assertions PASS**, all nine original paths, **476
historical level-30 learning rows**, **454 candidate
creative links**, **22 explicit unresolved ranks**.
The Scout's Elemental Heal ranks 4–12 remain nine
genuine gaps. For its first level-20 original source
rank 4 the pinned XML specifies self-targeting,
95 heal power, total 53 MP; a current legacy
self-HoT or the independently owned Warden heal
cannot be marked equivalent by a shared name.
Source-backed future rank 7 is absent at level20.

[Focused evidence](
../testing/c4-authenticated-nine-class-source-skill-preview-v2-53-20260925.md).

## Still required for the intended C4 game rules

1. Author distinct original C4 candidate identities for
   the 22 unresolved learning rows, especially Scout's
   nine separate Elemental Heal ranks, and re-audit any
   creative skills with different targeting/effect
   semantics. Do not insert historical skill power as
   arbitrary live Roblox HP damage; original healing
   specifically uses its pinned C4 effect/heal formula.
2. Expand original item IDs, source rarity/grade and
   equipment slots, map creative actual inventory items
   to *explicit reviewed* source counterparts and finish
   active buff, set, enchant and jewellery operations.
3. Migrate ALL nine character paths coherently from the
   current bespoke HP/Mana/stamina/attributes to server-
   authoritative original HP/MP/CP, skill costs/heals,
   physical/magic formulae and stat-based passives,
   including profiles, runtime, UI/HUD and source
   equipment. C4-sourced base attacks and cooldowns
   must be tested with existing active blocking/dodge
   and bounded damage anti-exploit rules.
4. Run per-rank source formula fixtures, focused two-
   client gameplay, party effects, saved/rejoin and
   cross-class balance acceptance. C4 data alone does
   not automatically make Roblox's custom combat loop
   exactly C4-equivalent.

Prior v2.51 nine original sample item reference:
46 source-only Studio assertions PASS; v2.52 original
nine-path HP/MP/CP server preview: 31 source-only
assertions PASS. Neither is live stat rollout; v2.53
also does NOT activate original C4 live skills.

No main merge, public Roblox publish, production
DataStore mutation or unrelated art/animation edit.
Permanent code, test and docs changes in GitHub;
local computer only for fast-forward, disposable
Rojo builds and unpublished Studio testing.
