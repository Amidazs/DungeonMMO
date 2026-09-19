# Phase 4 UI / HUD Overhaul - Design

**Date:** 18 September 2026
**Phase:** Phase 4 - Content Alpha
**Gate:** Player-Facing UI / HUD Overhaul
**Baseline:** `ff2baa0`
**Scope:** client presentation only

## Problem

The current UI is functional but visibly prototype-stage:

- every screen builds its own visual language;
- resource bars are disconnected floating rectangles;
- desktop combat has skill keybinds but no visible hotbar;
- profile/progression data is presented as one debug text string;
- dungeon objective, boss, revive and completion UI lacks hierarchy;
- inventory/skills/service panels use raw controls and weak spacing;
- the party/dungeon-entry panel occupies too much screen space;
- dynamic rows and buttons have inconsistent states and feedback.

## Visual direction

Use a restrained dark-fantasy interface:

- charcoal/stone backgrounds;
- warm bronze/gold emphasis;
- cream primary text and cool grey secondary text;
- red Health, green Stamina, blue Mana and cyan Ward;
- subtle strokes and gradients instead of flat default Roblox controls;
- rounded but not playful geometry;
- strong typography hierarchy;
- compact information density during combat;
- larger, calmer modal layouts outside combat.

No image assets are required for this pass. The system must support later icon,
texture and frame-art replacement without rewriting gameplay code.

## Usability goals

The player should be able to understand, at a glance:

- current health and combat resources;
- level, XP progress and currency;
- six active skill slots and their keyboard bindings;
- current dungeon objective;
- boss name and remaining health;
- revive state and available action;
- dungeon completion rewards and return timing;
- inventory category, item count, rarity and quantity;
- learned/locked skills and their assigned hotbar slots;
- the dungeon represented by the current physical entrance;
- available difficulty, party readiness and who may start the run.

Menus must be dismissible, visually consistent and responsive to common desktop
viewport sizes.

## Interaction model

Follow the interaction expectations established by classic MMORPGs such as
Lineage 2 and World of Warcraft without copying their visual assets.

- Persistent combat HUD shows only information needed during play.
- Inventory and Skills are character windows: closed by default, globally
  available, keyboard accessible and always dismissible.
- Guild is a system window: closed by default, opened with J and dismissible.
- Dungeon entry is world-bound. There is no Expeditions launcher or global
  dungeon browser. Interacting with a physical DungeonEntryPrompt opens the
  entry window for that entrance's DungeonId.
- Dungeon difficulty is chosen inside that entrance-bound window.
- Auction House, Bank, Equipment, Trainer and Travel are world services.
  Their windows open only from the relevant NPC, building or service prompt.
- Contextual world-service windows close when the player leaves interaction
  range as well as through their explicit close control.
- Individual player-to-player trading is intentionally out of scope for this
  pass and can be added later as its own contextual interaction.

## Architecture

Add reusable client-safe shared modules under
`ReplicatedStorage/Core/Shared`:

- `UiTheme`: palette, typography, spacing and low-level styling;
- `UiComponents`: reusable panel, button, label, progress bar and modal
  constructors.

High-frequency screens use those modules directly.

Legacy Base service panels may opt into shared automatic styling so Bank,
Equipment, Guild, Market, Progression, Travel, Race Change and Profession UIs
stop looking like separate prototypes even before deeper screen-specific
redesign.

## High-frequency rebuild

Rebuild or substantially restyle:

- Profile HUD;
- Health presentation inside the profile/status HUD;
- Stamina HUD;
- Mana HUD;
- Ward HUD;
- desktop combat hotbar;
- mobile combat controls;
- Dungeon objective HUD;
- Boss health bar;
- Revive overlay;
- Completion overlay;
- Inventory;
- Skills / loadout;
- Base dungeon / party entry panel.

## Safety

This gate must not modify:

- gameplay balance;
- combat rules;
- dungeon encounter logic;
- networking contracts;
- persistence;
- monetisation;
- physical layouts or art assets.

All existing RemoteEvent names and payload contracts remain unchanged.
