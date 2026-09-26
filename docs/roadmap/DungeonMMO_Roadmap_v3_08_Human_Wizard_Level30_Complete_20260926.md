# DungeonMMO Roadmap v3.08 — Human Wizard level-30 backend complete

Date: 26 September 2026

## Scope

This gate closes the Human Wizard / Emberweaver first-transfer skill catalogue
through the agreed level-30 launch cap. It preserves the independently named
DungeonMMO presentation while keeping the reviewed Chronicle 4 source IDs,
rank schedules, costs, timing and effect semantics behind server authority.

This is a backend completion claim for the level-30 skill catalogue, not a
claim that final summon meshes, animations, VFX or companion NPC combat
content are finished.

## Completed source coverage

The Human Wizard source tree now has **93/93 rank rows mapped** and
**0 unmapped Human Wizard rows** through level 30.

The remaining companion-dependent source families are now represented by
server-owned DungeonMMO skills:

- Emberweaver Mana Companion -> source summon 1111.
- Emberweaver Servitor Recharge -> source skill 1126.
- Emberweaver Servitor Heal -> source skill 1127.
- Emberweaver Combat Companion -> source summon 1225.

The broader ten-path source-link inventory is now **569 total / 547 candidate /
22 explicit gaps / 0 broken**. The 22 remaining gaps belong to other tracked
class paths; none belong to Human Wizard.

## Human Wizard runtime closure

The staged source runtime now covers the previously outstanding level-30
families in addition to the already accepted direct spells:

- Venom Cloud uses source Poisonous Cloud 1167 as a server-selected
  TARGET_AREA periodic poison. One magical-shot snapshot is shared by the
  area cast and landed targets receive independent exact periodic status
  generations.
- Blood To Mana uses source Body To Mind 1157. The source HP consume is
  applied at hit time, cannot reduce the caster below one HP, and restores
  the authored MP amount through the authoritative mana service.
- Corpse Siphon uses source Corpse Life Drain 1151. A reviewed dead NPC
  boundary is required, fixed source absorption is applied, then the corpse
  is consumed so it cannot be drained repeatedly.
- Mana and Combat companions use a server-owned one-companion-per-owner
  lifecycle with source NPC identity, EXP penalty, source lifetime loss,
  initial Spirit Ore consumption and source over-time reagent thresholds.
- Servitor Heal and Servitor Recharge require the owner's current server
  companion. Heal uses the source heal/shot formula. Recharge uses source
  power multiplied by the server-owned companion recharge-MP rate.

The creative inventory item **Arcane Spirit Ore** is the DungeonMMO-facing
representation of source reagent item 1458.

## Companion boundary

The backend companion authority intentionally uses a replaceable placeholder
Model while preserving the reviewed source summon identity and lifecycle.
It does **not** invent C4 NPC combat statistics that have not yet been imported
and reviewed. Final companion meshes, animations, autonomous combat behaviour
and reviewed NPC stat templates are creature-content work, not missing skill
rank mappings.

## Validation

Fresh unpublished Studio validation on the final backend candidate produced:

- Human Wizard source-cast focused suites: **18/18 PASS**.
- Expanded Human Wizard backend regression: **39/39 PASS**.
- Human Wizard foundation: **199 assertions PASS**.
- Companion lifecycle: **9 assertions PASS**.
- Companion cast bridge: **6 assertions PASS**.
- Cast runtime composition: **3 assertions PASS**.

A genuine unpublished Dungeon Play session also passed the companion runtime
smoke:

- server summon created and replicated to the client;
- source NPC ID 12006 and Mana role replicated;
- three initial Arcane Spirit Ore were consumed by the source plan;
- Servitor Heal moved companion HP 35 -> 100;
- Servitor Recharge moved companion MP 20 -> 61;
- owner cleanup removed the companion and left no active companion state.

Base and Dungeon Rojo builds plus git diff validation are the final local
acceptance gate after this document update.

## Next backend direction

Human Wizard level-30 skill catalogue work is closed. Continue with the next
first-transfer class/catalogue or broader MMORPG systems from the main roadmap
rather than adding more Human Wizard skill rows below the launch cap.

No main merge, publish or production save mutation is part of this gate.
