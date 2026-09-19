# Phase 4 UI / HUD Overhaul - Implementation Plan

**Baseline:** `ff2baa0`
**Branch:** `wip/phase-4-ui-overhaul-v1`

## Task 1 - Shared UI system

Create UiTheme and UiComponents with reusable palette, typography, panels,
buttons, progress bars, responsive scaling and auto-styling support.

## Task 2 - Combat HUD

Rebuild ProfileHud as a compact bottom-left status card with Health, XP and
currency/progression counters.

Restyle Stamina, Mana and Ward into one coherent resource stack.

Add the missing desktop six-slot combat hotbar with key hints and cooldown
feedback. Restyle mobile controls to match.

## Task 3 - Dungeon HUD

Rebuild objective, boss, revive and completion presentation using the shared
UI system without changing dungeon-state payloads or revive/return behavior.

## Task 4 - Core menus

Rebuild Inventory and Skills around clear header/body/footer hierarchy,
selected-state feedback and consistent tabs/buttons.

## Task 5 - Contextual Base interaction windows

Remove the global Expeditions launcher. Bind the dungeon-entry window directly
to physical DungeonEntryPrompt instances and use each entrance's DungeonId as
the authoritative context. Present difficulty, party readiness, invites and
entry controls only after that interaction, and close the window on distance.

Keep Auction House, Bank, Equipment, Trainer and Travel world-bound. Their
windows must start closed, open from their service prompt and remain
dismissible. Keep Inventory, Skills and Guild as closed-by-default global
character/system windows, with Guild using J.

## Task 6 - Remaining panel polish

Apply the shared style system to existing Base and profession/service panels so
the rest of the game no longer looks visually disconnected.

## Task 7 - Acceptance

Run:

- changed-file and repository Luau parse;
- all four Rojo builds;
- Base Studio regression;
- Dungeon Studio regression;
- visual structure inspection in PlayerGui;
- source-boundary audit proving no gameplay or art content changed.

Document the gate and close locally. Do not push, merge or publish.
