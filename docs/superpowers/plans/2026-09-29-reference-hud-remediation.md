# Reference HUD repair and completion plan

Goal: implement the user-supplied 29 September reference UI brief in the existing HUD worktree. The master screenshot and all 24 UIphotos images are the visual specification. This supersedes the September 18 procedural-art direction. No backend redesign, publication, push or merge.

Execution: inline, test-first for changed behavior. Existing authority and client controllers remain; shared art geometry and presentation helpers own sizing/layering. Preserve all existing untracked work.

- [x] Reconcile HEAD 5a17304a with stale continuity notes; inspect current Base and all supplied images.
- [ ] Shared geometry: fit actual panel bounds, put X targets on painted X, keep painted button text above art. Verify normal viewport and 1920x1080.
- [ ] HUD: one profile, hotbar, command strip and quest tracker per composition; wire MP correctly; retain HP/XP/loadout/cooldowns and status information.
- [ ] Commands: all six open real views; Map uses truthful location information; Settings exposes working local presentation controls only.
- [ ] Windows: use reference chrome, dynamic inventory/stats/skills/quests/guild/party data, explicit buttons and dismissal. Preserve trainer-only learning and authoritative attribute/Guild permissions.
- [ ] Fresh Base and Dungeon playtests, real input, screenshots of all requested windows, geometry assertions and regression checks.
- [ ] Four timestamped TEMP Rojo builds; exact diff review; evidence and continuity updates; focused local commits. Record remaining gaps honestly.

Ownership: ProfileHud owns portrait/HP/MP; LobbyActionBar (Base) or CombatHotbar (Dungeon) owns skills/XP, never both. HudCommandMenu owns six commands. HudWindowController coordinates player windows. QuestJournal owns tracker/journal. InventoryPanel, StatsMenu, SkillsMenu and GuildPanel own their dynamic views. BaseUi owns entrance-bound party authority. LegacyUiPolish must not touch reference windows. New navigation/settings views must consume existing state only.

Initial failing runtime evidence: Stats at (452,-33.5), size (680,850), viewport (1584,841); ManaFill path assertion fails at StatusCard and exists under ManaTrack. Missing Map/Settings registrations confirmed by source audit. Existing v3 Base Play had manually disabled ScreenGuis; use fresh builds for acceptance.
