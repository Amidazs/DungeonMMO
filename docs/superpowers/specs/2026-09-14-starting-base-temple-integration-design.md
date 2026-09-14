# Starting Base + Temple Integration Design

**Project:** DungeonMMO
**Date:** 14 September 2026
**Status:** APPROVED design direction; implementation candidate until fresh Studio evidence
**Baseline:** `08d071136ebbdeb0f02649f360d767e17f8c439e`
**Canonical roadmap:** DungeonMMO Roadmap v1.34

## 1. Purpose

This gate turns the existing visual environments into one repeatable gameplay loop without reopening accepted combat, class, progression, persistence or equipment architecture.

Current environment candidates:

- Starting Base / town: `LobbyScene_001_V3_1_P11_SurfaceArchitecture(1).glb`
- Dungeon: `Temple.rbxl`

The gate proves one integrated flow:

**LobbyScene Starting Base -> Temple dungeon -> rewards -> LobbyScene Starting Base**

These two environment files are working test candidates, not permanent geometry contracts. They may be substantially revised, replaced or rebuilt later.

## 2. Core architectural rule: gameplay must not depend on current geometry

The environment is replaceable presentation/content. Gameplay systems must not depend on:

- fixed world coordinates scattered through scripts;
- current GLB node names;
- current Temple model hierarchy;
- exact mesh dimensions;
- exact room geometry;
- specific decorative models.

Instead, each environment provides a small semantic anchor contract. Gameplay resolves anchors by stable semantic IDs through one environment adapter/registry.

A future Lobby V4 or Temple V2 is compatible when it provides the same required semantic anchors, even if its geometry and hierarchy are completely different.

## 3. Environment contract

Use one neutral anchor mechanism for both Base and Dungeon. The implementation may use invisible anchored Parts, Attachments or equivalent Roblox instances, but every anchor must be discoverable through a stable semantic ID rather than by coordinate or art hierarchy.

Recommended contract:

- tag: `DungeonMMOEnvironmentAnchor`;
- attribute: `EnvironmentId`;
- attribute: `AnchorId`;
- optional attribute: `AnchorRole`;
- optional attribute: `AnchorVersion`.

The resolver must reject missing required anchors and duplicate required anchor IDs. It must fail loudly during TEST/Studio validation instead of silently falling back to hard-coded coordinates.

## 4. Starting Base environment

`LobbyScene_001_V3_1_P11_SurfaceArchitecture(1).glb` becomes the current Starting Base visual candidate.

The town remains one integrated social hub. Existing Human, Elf, Dwarf and Orc architectural flavour is environmental identity only; this gate does not add Dwarf or Orc as selectable player races.

Required Base anchors:

- `Base.PlayerSpawn`
- `Base.ArrivalFromTemple`
- `Base.TemplePortal`
- `Base.DungeonBoard`
- `Base.Trainer.Fighter`
- `Base.Trainer.Mage`
- `Base.Trainer.Ranger`
- `Base.Service.Equipment`
- `Base.Service.Progression`
- `Base.Service.BankPlaceholder`
- `Base.Service.TravelPlaceholder`
- `Base.Profession.BlacksmithingPlaceholder`
- `Base.Profession.AlchemyPlaceholder`
- `Base.TrainingArea`

The placeholder service/profession anchors reserve sensible physical locations but do not implement those later systems in this gate.

The existing town art should be used where sensible. For example, the Blacksmith/forge area is the natural future Blacksmithing location, and the Dwarf mine area is a natural future Mining-related location. These associations are not hard-coded gameplay dependencies.

## 5. Base gameplay integration

Accepted services are relocated into the environment rather than rewritten.

The following accepted behaviour must remain authoritative and unchanged:

- race then class identity flow;
- Fighter, Mage and Ranger selection;
- class trainer catalogue authority;
- equipment management;
- progression/skill management;
- persistent Inventory/Equipment authority;
- Base-only permanent equipment mutation;
- schema-v5 persistence.

The Dungeon Board and Temple portal become presentation/interaction surfaces for the existing dungeon-entry flow. Decorative portal geometry never grants authority by itself.

The server remains responsible for validating that a character is eligible to enter the dungeon and for creating the accepted handoff/session state.

## 6. Temple dungeon environment

`Temple.rbxl` becomes the current production-style Test Dungeon visual candidate.

Its visual progression is mapped to the accepted three-stage dungeon runtime:

1. **Room 1 — root/cavern approach**
2. **Room 2 — ruined temple interior**
3. **Room 3 — altar/sanctum Captain encounter**

Temple art does not own encounter authority. The existing dungeon runtime remains responsible for encounter state, checkpoints, enemies, death/revive state, rewards, completion and return.

Required Temple anchors:

- `Temple.EntrySpawn`
- `Temple.Room1.Checkpoint`
- `Temple.Room1.Trigger`
- one or more `Temple.Room1.EnemySpawn.*`
- `Temple.Room2.Checkpoint`
- `Temple.Room2.Trigger`
- one or more `Temple.Room2.EnemySpawn.*`
- `Temple.Room3.Checkpoint`
- `Temple.Room3.Trigger`
- `Temple.Room3.CaptainSpawn`
- `Temple.CompletionPosition`
- `Temple.ReturnToBase`

Optional reserved anchors may be added for later rare rooms, gathering nodes or event variants, but those systems are not implemented in this gate.

## 7. Checkpoint and encounter rules

The accepted room-start checkpoint rule remains unchanged.

- entering/activating a room advances the authoritative checkpoint only through the accepted runtime;
- death/revive returns to the correct semantic checkpoint anchor;
- enemy spawns resolve from semantic spawn anchors;
- the Captain resolves from `Temple.Room3.CaptainSpawn`;
- completion remains tied to validated Captain death and accepted completion eligibility;
- Return to Base uses the accepted save-before-return/handoff path.

No gameplay service may infer encounter progression from a mesh, doorway or decorative object being present.

## 8. Collision, navigation and environment validation

Integration includes functional environment QA, not an art redesign.

The gate must verify:

- player spawn positions are safe and not inside geometry;
- checkpoints are safe and reachable;
- enemy spawn points are on valid playable surfaces;
- players cannot trivially fall through required floors/routes;
- required stairs/routes are usable;
- blockers/walls prevent obvious out-of-bounds shortcuts where needed;
- camera collision is acceptable for normal play;
- the Captain can navigate/fight in the altar room;
- projectiles and line attacks have usable combat space;
- Mage, Ranger and Fighter all have enough room to use their accepted combat kits.

Small invisible blockers, simple collision volumes and anchor parts are allowed. Rebuilding visual meshes belongs to the separate art workflow.

## 9. Accepted combat/class regression boundary

This gate must preserve all accepted player-facing class contracts.

### Fighter

- sword/shield presentation and authority;
- Block/parry;
- Dodge;
- Shield Bash;
- Mend;
- Arc Slash where learned/equipped.

### Mage

- Apprentice Arcane Wand authority;
- Spirit Orb basic sequence;
- Wind Strike;
- Arcane Ward;
- Mage Heal;
- accepted Mana and movement-commitment/cancellation behaviour.

### Ranger

- Apprentice Longbow authority;
- OffHand reservation;
- no Block while Longbow is equipped;
- Normal / Precision / Full Draw;
- Dodge cancellation;
- Piercing Shot;
- Crippling Shot;
- Volley;
- server-owned slow behaviour.

The environment must adapt to these systems; class systems are not retuned to compensate for bad map integration during this gate.

## 10. Persistence and Base/Dungeon handoff

The accepted profile and Dungeon run-lock architecture remains unchanged.

Base entry into Temple carries the accepted authoritative character snapshot/handoff containing identity, progression, Inventory/Equipment state and related session data.

Dungeon Equipment remains deep-cloned/run-locked. Temple cannot authorize permanent equipment changes during a run.

Completion must remain exactly-once, save before return, and restore the player to `Base.ArrivalFromTemple` with accepted progression preserved.

No schema bump is introduced solely for environment integration.

## 11. Source-control and environment ownership

Gameplay integration starts only from canonical main:

`08d071136ebbdeb0f02649f360d767e17f8c439e`

Use an isolated gameplay/content worktree. Do not work inside or merge wholesale from `art/dungeon-environment-prototype`.

The uploaded LobbyScene GLB and Temple RBXL are source environment inputs for this gate. Preserve original copies so future revisions can be compared or replaced safely.

Environment-specific integration data should live in focused source-controlled files rather than inside unrelated combat/progression modules.

## 12. Presentation scope

Functional integration only.

Allowed:

- trainer labels/prompts;
- Dungeon Board identification;
- Temple entry interaction;
- arrival/spawn feedback;
- invisible anchors/blockers/collision helpers;
- minimal interaction prompts needed to understand the loop.

Deferred:

- final UI reskin;
- final animation pass;
- final VFX/audio;
- ambient NPC population;
- cinematic entrances;
- final lighting polish;
- final town/dungeon art revision.

The current LobbyScene and Temple are specifically acceptable as testing environments even if they are later replaced or substantially modified.

## 13. Explicitly out of scope

This gate does not add:

- Mining/Blacksmithing implementation;
- Herbalism/Alchemy implementation;
- bank/storage persistence;
- auction/market systems;
- full party-forming UX;
- rare Temple states;
- timed events;
- a second production dungeon;
- Dwarf/Orc selectable identities;
- secondary classes;
- quests;
- final animation/VFX/audio/balance;
- Robux/monetisation activation.

## 14. Acceptance evidence

Candidate acceptance requires all of the following:

1. exact canonical baseline and isolated-worktree verification;
2. environment-anchor contract tests reject missing and duplicate required anchors;
3. fresh TEMP Base and Dungeon Rojo builds;
4. accepted Core/Base/Dungeon automated regressions remain green;
5. Base Studio proof that the player spawns in LobbyScene and can reach/use Fighter, Mage and Ranger trainer/service locations;
6. Base Studio proof that the Dungeon Board/Temple portal enters the accepted dungeon handoff rather than bypassing authority;
7. Temple Studio proof of Room 1 -> Room 2 -> Room 3 progression, safe checkpoints, enemy spawns, Captain encounter, completion rewards and Return to Base;
8. Return proof that the player arrives back in LobbyScene with progression/rewards preserved;
9. one complete Temple run with one accepted class and focused combat spot checks with the other two starting classes;
10. no Roblox publish, PROD, Robux, monetisation or art-worktree action during local candidate acceptance unless separately approved.

## 15. Gate completion statement

This gate is accepted when the project owner can truthfully say:

> I spawn in our real town, prepare my character, enter our real Temple dungeon, fight through it using the class systems we already built, get rewarded, return to the town, and everything I earned and equipped is still correct.

Acceptance of this gate does not freeze LobbyScene or Temple art. It freezes only the gameplay/environment integration contract so future environments can change without forcing gameplay rewrites.
