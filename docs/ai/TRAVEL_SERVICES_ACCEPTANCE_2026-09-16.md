# Travel Services Acceptance — 16 September 2026

**Gate:** Phase 2 Travel Services
**Status:** ACCEPTED
**Automated gate:** PASS
**Studio interaction gate:** PASS

## Accepted behavior

- Physical Starting Base Travel Gem.
- ProximityPrompt requires holding `E` for 1 second.
- Four destinations: Market, Dwarven Area, Dungeon Portals, Orc Area.
- Server-authoritative 18-stud service range.
- Free individual local movement.
- 5-second session-only cooldown.
- Profile schema remains v7.
- Account Bank remains unchanged.
- Local Travel does not use `TeleportCoordinator`, `TeleportService`, DungeonSession creation or profile handoff.
- Pending/recoverable Dungeon routing continues to take precedence.
- Party state is not mutated by local Travel.
- Successful Travel closes the UI.
- Leaving the Travel Gem range closes the UI.

## Studio evidence

The project owner completed the full requested interaction proof in the fresh Base build and reported **no issues**:

1. Base Travel automated tests reported PASS.
2. Brief E tap did not open the menu.
3. Holding E for about one second opened the Travel menu.
4. Menu exposed Market, Dwarven Area, Dungeon Portals and Orc Area.
5. Market travel arrived safely.
6. Dwarven Area travel arrived safely.
7. Dungeon Portals travel arrived safely outside the portal trigger.
8. Orc Area travel arrived safely.
9. Successful travel closed the Travel UI.
10. Moving outside the Travel Gem range closed the UI.
11. Party state remained intact where applicable.
12. No new red DungeonMMO runtime errors were observed.

## Git closeout

- Travel gameplay checkpoint: `cbb499567b77ff1e0bb47d1dde2cc96acf17e413`
- Local main merge checkpoint: `ef15f55e802ec4332186b025b9473767184fcaae`
- `origin/main` intentionally remains `60fc0dfd9954e2d580157a580da2425e2b71dd70`
- No push or Roblox publish occurred during this closeout.
- Travel feature worktree/branch are preserved.

## Next selected gate

Starting Base presentation polish. Its compact design is not yet locked.
