# Greenward Warden independent saved-profile handoff — v2.40

Date: 24 September 2026. Executed `8a1c2a5fb39ec0ae65d0c1b4613dfac9cd0b2b93`.
GitHub fixture:
`src/ServerScriptService/Core/Tests/C4GreenwardWardenProfileHandoffTest.server.luau`.
Disposable Base runner:
`scripts/studio/c4_greenward_warden_profile_handoff_focus.luau`.
Log: `%TEMP%\\DungeonMMO_v246_warden_handoff\\handoff.log`.

## Exact test boundaries

- Multiple independently instantiated, separately cached
  ProfileServices shared a single disposable InMemoryProfileAdapter;
  each genuine `save` and `release` preceded the next service
  instance's `load`. No Roblox TeleportService, live
  DataStore, distributed session lease or genuine separate
  place was involved.
- Test-seeded three personally bound Warden reports and proof
  at quest stage four survived new profile caches. A second
  loaded user retained zero reports and zero boss seals.
- An unsigned NPC event failed. A matching single-use test-signed
  Warden Caer event went through the normal original quest
  service, consumed all three reports and advanced the saved
  original quest to stage five.
- A **test-seeded** personally owned boss seal and stage-six
  proof survived another save/release/load. The signed
  Sentinel Ilyra quest event consumed the seal, readied the
  original quest, and the level-20 owner received
  Greenward Warden through a one-use test-signed mentor
  receipt and the actual OriginalFirstTransferService.
- The actual SkillProgressionService purchased
  GreenwardWardenSteelTraining rank one, and a final fresh
  ProfileService reload preserved class, receipt, level,
  rank, quest completion and zero obsolete quest materials.

Unpublished Base Studio log printed
`[Warden Handoff] PASS: 52 assertions` and
`[Warden Handoff] VERIFIED_FOCUS_PASS`.
A passing isolated store contract does not certify a
published Base->Dungeon->Base player session or real
persistent DataStore/rejoin across physical places.

Separately established earlier: genuine real-client
kills for three reports in one Dungeon (v2.38), physical
Base NPC return/mentor/trainer interactions with seeded
loot (v2.36), and natural Captain AI Bleed Recovery
(v2.39). Do not combine these separate sessions into
a claim that any one character finished an uninterrupted
live cross-place adventure.
