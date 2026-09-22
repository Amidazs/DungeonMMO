# DungeonMMO roadmap v1.63 — class identity and first specialist skills

Date: 22 September 2026
GitHub branch: `wip/phase-4-test-hud-integration-v1`
Focused verified gameplay source:
`b017fbce6aceb2a9ba301057a145697a471320ab`

## Implemented and focused-local accepted

- [x] Preserve Mage/Arcanist/Spellweaver and Rogue/Duelist/
  Windstalker progression. Add Human Vanguard, Elf Thornwarden,
  Human Sharpshooter and Elf Windrunner at level 20.
- [x] Class advancement is character- and race-specific, gated by
  the appropriate Temple or Mine trial, and persisted through
  current QuestService, ProfileService and race-history rules.
  New class identity supplies an explicit party-role label.
- [x] Add Base-only server-authorized StartTrial/ClaimTrial/
  Snapshot remotes using the existing class service. No
  client-chosen advanced-class identity or client-generated
  dungeon-clear event.
- [x] Add four exclusive specialist trainers and actual
  rankable combat abilities: threat-focused Vanguard Challenge,
  stagger-focused Thornwarden Bash, high-damage Sharpshooter
  Pierce, and fast Windrunner Volley. Reuse accepted
  melee-threat, stagger and ranged/area combat executors.
- [x] Add active-advanced-class checks to the authoritative
  skill-use runtime: a previously learned class-exclusive
  skill cannot be used after leaving its advanced class.
- [x] Fix the client ground-aim dispatch so new
  `RangerVolley`-kind skills receive a valid aim vector.
- [x] Focused Base and Dungeon builds plus class advancement
  **66 assertions**, existing story quests **40 assertions**
  and advanced ability **60 assertions** passed. Do NOT
  conflate data/authorization tests with real-client combat
  impact or published persistence.

[Focused acceptance and limitations](../testing/dungeon-class-progression-expansion-2026-09-22.md)

## Next new gameplay work — avoid old dungeon test loops

1. **One actual specialist combat integration:** exercise
   representative tank threat/stagger and ranger aimed-area
   skills from real client inputs against a server target;
   balance values only after empirical combat evidence.
   This is NEW skill acceptance, not another Dungeon
   room-reset/Play Again/aggro matrix.
2. Add a simple player-visible advancement/trainer and
   quest-board flow backed by the already implemented
   Base remotes. Players should see their class role,
   trial requirement and only their own learnable skills.
3. Expand equipment/loot tiers and role-based dungeon
   drops using existing inventory/equipment/reward
   authorities; do not duplicate item or reward services.
4. Continue class evolution (additional meaningful
   paths/talents) and existing seven-profession crafting
   content, then raid encounters and guild competition.

### Design reference

Use Lineage II's **earned, race-inflected class evolution**
and World of Warcraft's **legible party roles, abilities
and class progression** as design references. Keep all
DungeonMMO class names, skills, lore, item art, quests
and tuning original. The present paths represent only
a first role-skill increment, not a complete class tree,
finished class balance or finished NPC interface.

Broad suite only at a meaningful merge/release closeout.
Published TEST cross-place travel, same-account network
rejoin and real cloud persistence still require separate
authorization. No place publish, `main` merge,
force-push or production data mutation was performed.
