# DungeonMMO Roadmap v3.26
## Dwarf world infrastructure GREEN — creation still disabled
**Date:** 28 September 2026

This checkpoint closes the server/world infrastructure needed by the two Dwarf
first-transfer quests. It does **not** enable fresh Dwarf character creation and
therefore does not claim a normal-player end-to-end Dwarf quest playthrough.

## Base world binding

The Base environment now has an optional, explicit
`Base.DwarfQuestHub` anchor.

- Existing Base environments remain valid when that optional anchor is absent.
- Dwarf quest actors and transfer actors never fall back to
  `Base.PlayerSpawn`.
- Synthetic Studio Base supplies a dedicated Dwarf quest-hub anchor.
- Candidate-world resolution can locate a Dwarf/Dwarven mine landmark without
  hard-coding quest gameplay to one art-object name.

The dedicated Dwarf hub now owns eight quest actors:

- Forgekeeper Orda
- Master Smith Varka
- Smith Dorrin
- Salvage Master Veyda
- Quartermaster Brel
- Prospector Nessa
- Gatewarden Harl
- Wanderer Kest

It also owns both first-transfer mentors and both class trainers:

- Forgekeeper Orda -> Gearwright transfer
- Gearwright Trainer
- Salvage Master Veyda -> Deepclaimer transfer
- Deepclaimer Trainer

All names are DungeonMMO-original. Source quest mechanics and values remain
separate from player-facing names.

## Quest NPC runtime

`C4OriginalQuestNpcRuntime` is now target-driven instead of depending on a
small set of hard-coded step-number remaps.

For every bound branch it:

1. reads the authored quest step,
2. maps `NpcTalk` steps to their exact `TargetId`,
3. verifies the actual physical prompt/player range on the server,
4. creates a one-use server receipt,
5. permits progression only when the saved current step and physical actor
   match.

This preserves the already-green Human/Elf flows while allowing the longer
interleaved Dwarf quests to reuse the same authority.

## Dwarf quest-combat binding

The shared quest combat ledger now accepts any authored
`QuestMonsterDefeat` step rather than only the older 3/5/6 shapes.

Deepclaimer combat proof additionally requires the killed model to carry the
same player's unclaimed server-owned source Spoil mark. Source skills accepted
for that proof are exact Spoil **254** and Spoil Festival **302**. A missing,
foreign, invented or already-claimed mark cannot satisfy the quest.

The real Dungeon source-pack augmenter now physically supports all five Dwarf
quest targets:

- Gearwright step 2: `TunnelGnawer`
- Gearwright step 3: `TunnelGnawerChief`
- Gearwright step 7: `AshclanForgeThief`
- Deepclaimer step 4: `HoneybackBear`
- Deepclaimer step 6: `TunnelTarantula`

These currently reuse the existing reviewed room combat rig. No new Dwarf
monster balance numbers were invented: where a Dwarf challenge has no reviewed
individual HP template, its temporary rig inherits the room seed enemy's
authoritative MaxHealth.

Final bespoke monster meshes, animations and reviewed individual combat
templates remain content work.

## Validation

Fresh Base and Dungeon Rojo builds and `git diff --check` pass.

Fresh Base Play proved:

- ordinary Base boot succeeds with no duplicate-anchor failure;
- profile lifecycle reaches ready state;
- 8 Dwarf quest actors are physically present around the Dwarf hub;
- 2 Dwarf transfer mentors and 2 Dwarf trainers are physically present;
- all corresponding prompts exist.

Accepted Base evidence:

- `VERIFIED_DWARF_BASE_RUNTIME_ACTORS_V5_PASS`
- Original Quest NPC Binding: **46 assertions PASS**
- First Transfer Mentor Binding: **21 assertions PASS**
- Dwarf Quest Hub Contract: **5 assertions PASS**

Fresh Dungeon Play proved:

- Dwarf quest target augmentation uses the real encounter source-pack path;
- all five Dwarf target identities bind to their exact branch and quest step;
- temporary Dwarf rigs inherit reviewed room health rather than guessed HP;
- each physical enemy registers into the real server quest ledger;
- owner-bound Spoil proof remains enforced.

Accepted Dungeon evidence:

- C4 Source Pack: **61 assertions PASS**
- C4 Quest Combat Ledger: **114 assertions PASS**
- `VERIFIED_DWARF_WORLD_V6_BACKEND_PASS 25`

The existing 25-suite Dwarf backend remained green after the world changes.

## Validation bug fixed

The first fresh Base v4 check found that
`BaseDwarfQuestHubContractTest.server.luau` auto-ran during ordinary Base
Play and temporarily created a second tagged synthetic Base. Production
duplicate-anchor validation correctly rejected that contamination.

The test is now a focused ModuleScript and resolves only its isolated
ServerStorage fixture. Production duplicate-anchor checks were not weakened.

## What is GREEN

- optional dedicated Dwarf Base hub anchor;
- Dwarf quest NPC placement and prompt authority;
- Dwarf transfer mentor/trainer placement and proximity authority;
- target-driven ordered NPC talk progression;
- generic ordered quest-monster ledger support;
- Deepclaimer same-owner source Spoil proof;
- all five Dwarf quest monster identities in the real Dungeon augmentation
  path;
- prior Gearwright/Deepclaimer backend, progression and salvage contracts.

## What remains deliberately pending

- Fresh Dwarf character creation is still disabled.
- A normal player therefore cannot yet run Q417/Q418 from character creation
  through transfer without a test-seeded Dwarf identity.
- Dwarf quest monsters currently use temporary reviewed room combat rigs;
  unique final art/AI/templates are pending.
- Spoil Festival source radius **200** still has no reviewed Roblox spatial
  conversion.
- The source salvage cast bridge remains default-off.
- Final Dwarf quest dialogue presentation, VFX and animation polish remain
  content work.
- No production publish or main-branch merge is part of this checkpoint.

## Next development gate

Review the project's existing C4 range/radius conversion conventions and bind
Spoil Festival's exact source radius **200** to a single documented,
server-owned Roblox area resolver. Do not guess a new scale.

After that, move into professions/economy content and broader launch-level
quest/content work.
