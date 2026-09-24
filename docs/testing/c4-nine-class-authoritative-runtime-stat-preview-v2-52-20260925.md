# C4 authoritative nine-class vitals preview — v2.52

Date: 25 September 2026.
Candidate `ab53b20701db23fad272f12b77fe4c472ca72743`. Unpublished disposable Base
Studio log: `%TEMP%\\DungeonMMO_v252_authoritative_preview\\preview.log`.
Base/Dungeon Rojo builds both passed.

## Exact executed contract

The real server `ProgressionRuntimeState` now exposes
`get_c4_source_vitals(user_id)`, seeded by its existing
`set_character` authority, not by a remote supplying
race or class IDs. It checks a complete original class
identity; original first transfers require the appropriate
server-owned source quest, full proof and one-use mentor
receipt. `C4PrimaryStatReference.get_level_vitals`
returns the historical nine-class level/HP/MP/CP values.

Original level-30 reference source vectors verified:
Human Fighter 922/319/418; Human Mystic 699/466/366;
Elven Fighter 792/324/353; Elven Mystic 666/469/348;
Human Warrior 1070/320/849; Human Knight 1018/320/610;
Human Rogue 983/320/399; Elven Knight 902/325/453;
Elven Scout 874/325/354. This fixture's completed
original transfer quests and receipts were independently
test-prepared in the unpublished environment.

The test denied missing runtime profile, a forged copied
first-transfer ClassId without mentor receipt, the wrong
race for an Elven Knight and level 31 outside the
currently verified 1-30 source growth range. The Studio
log reported:
`[C4 Runtime Stat Preview] SOURCE_ONLY_PASS: 31 assertions
nine_paths=9 live=false`
and `VERIFIED_SOURCE_ONLY_NOT_LIVE`.

## Crucial non-claim

These are server-owned **source previews only**.
No real Humanoid MaxHealth, ManaService regen/max mana,
CP, status effect, source item attachment or live damage
formula was changed. v2.51's nine *sample original*
gear IDs and 46-pass source test remain separate and
do not imply all inventory items are C4-equivalent.
