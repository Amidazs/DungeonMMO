# Phase 2 Travel Services Design

**Date:** 16 September 2026
**Status:** APPROVED DESIGN — awaiting written-spec review
**Roadmap:** DungeonMMO Roadmap v1.40
**Starting gameplay baseline:** local `main` `17b27085badf9a27cb1fcf78750e686115ab6de0`
**Bank gameplay checkpoint:** `446dd12c73d5e82d988cca7792b2816d3ea9ffd1`
**Remote baseline:** `origin/main` `60fc0dfd9954e2d580157a580da2425e2b71dd70`

## Goal

Add the first server-authoritative Travel service to the Starting Base.

Travel v1 is **local movement within the Starting Base only**. It does not create a new Roblox Place, does not use the Dungeon handoff/session pipeline, and does not create fake persistent travel progression before a second real Base exists.

The interaction is deliberately physical:

1. Player walks to the Travel Gem.
2. Player **holds E for 1 second** on the gem.
3. The Travel menu opens.
4. Player chooses one of four destinations.
5. Server validates the request.
6. Server moves that player to the authoritative semantic arrival anchor.

## Initial destinations

Travel v1 exposes exactly four Starting Base destinations:

1. **Market**
2. **Dwarven Area**
3. **Dungeon Portals**
4. **Orc Area**

These are gameplay destinations, not art-object names.

Each destination resolves through a semantic environment anchor so later lobby/GLB art changes do not require TravelService changes.

Recommended semantic IDs:

```text
Base.Travel.Market
Base.Travel.Dwarves
Base.Travel.Portals
Base.Travel.Orcs
```

The Travel Gem itself resolves through:

```text
Base.Service.Travel
```

### Market

The Market destination represents the central Market / Tree of Life hub.

It should land the player at a safe walkable arrival point near the market rather than directly on top of stalls, NPCs or the Travel Gem.

### Dwarven Area

The Dwarven destination represents the mountain/mine district.

Its semantic arrival anchor must be calibrated to a safe walkable point at or immediately outside the usable Dwarven area. Travel gameplay must not depend directly on the authored mine mesh or landmark name.

### Dungeon Portals

The Portals destination represents the central dungeon-portal area.

The arrival point must be offset from the portal interaction volume so the player is not teleported directly inside a portal trigger.

### Orc Area

The Orc destination represents the farm/orc district.

Its semantic arrival anchor must be calibrated to a safe walkable point inside the Orc area without placing the character inside farm props, fences or terrain.

## Interaction

The Travel service is represented by a physical **Travel Gem**.

The Travel Gem receives a `ProximityPrompt` with:

```text
KeyboardKeyCode = E
HoldDuration = 1.0
ActionText = "Travel"
ObjectText = "Travel Gem"
```

The player must complete the hold before the Travel menu opens.

A quick tap of E must not open the menu.

The ProximityPrompt is a convenience/input layer only. It is not the server authorization boundary.

## Access distance

The Travel Gem interaction and subsequent destination request use an **18-stud** server-side maximum distance.

A player who opens the menu and then moves outside the allowed range cannot travel.

The client also closes the Travel UI when the player walks outside the allowed distance, but server validation remains authoritative.

## Cost

Travel v1 is **free**.

No Gold, item, Robux, cooldown consumable or other resource is spent.

This keeps the first slice focused on authoritative routing and destination behavior. A future travel economy can be designed when there are multiple real Bases, long-distance routes or meaningful economic trade-offs.

## Cooldown

A successful Travel starts a **5-second server-side cooldown** for that player.

The cooldown:

- is session-only;
- is not profile-persisted;
- begins only after a successful movement;
- is not started by rejected requests;
- blocks repeated local Travel spam;
- does not alter Dungeon teleport cooldowns or session state.

The server returns `TravelCooldown` while the cooldown is active.

The client may display remaining cooldown approximately, but the server clock is authoritative.

## Ownership and persistence

Travel v1 adds **no profile schema change**.

Profile schema remains **v7**.

There is no persistent destination-unlock table in this gate because all four destinations exist inside the same Starting Base and are available after character creation is complete.

Future Base-to-Base travel can add persistent unlock/discovery state when actual additional Bases exist.

The accepted account-wide Bank remains unchanged.

## Eligibility

A Travel request is eligible only when all of the following are true:

- the server context is Base;
- the player's profile is loaded;
- character identity is complete;
- the player is not already in a pending Dungeon teleport/handoff;
- the player does not have a recoverable active Dungeon session that should take routing precedence;
- the player's character exists;
- `HumanoidRootPart` exists;
- the player is within 18 studs of `Base.Service.Travel`;
- the requested destination ID is known;
- the destination semantic anchor exists;
- the player is not still on Travel cooldown;
- the player is not already effectively at the requested destination.

Any rejection changes no player position and starts no cooldown.

## Dungeon/session separation

Local Travel must not use `TeleportCoordinator`.

Travel v1 must not:

- reserve a Roblox server;
- call `TeleportService`;
- create a DungeonSession;
- modify an existing DungeonSession;
- begin or cancel a profile lease handoff;
- save the profile as a teleport handoff;
- set Dungeon handoff nonces;
- clear reconnect state.

The existing Dungeon/Base teleport architecture remains authoritative for cross-Place Dungeon routing.

Local Travel is a separate Base movement concern.

## Active Dungeon-session rule

A recoverable Dungeon session takes precedence over optional local Base travel.

If the player's existing DungeonSession is still in a state that the current reconnect-routing logic considers recoverable, Travel rejects with:

```text
ActiveDungeonSession
```

This prevents local Travel from becoming a way to ignore or accidentally obscure an existing Dungeon rejoin path.

Expired/failed/completed non-recoverable sessions do not block Travel.

## Party behavior

Travel v1 moves **only the requesting player**.

Travel does not:

- teleport the full party;
- disband the party;
- change the party leader;
- alter invitations;
- reset readiness;
- change the selected dungeon;
- create a Travel-specific party state.

A player may locally Travel while remaining in the same Base-local party.

Whole-party travel is deferred until real Base-to-Base routing exists.

## Destination definitions

Create a shared `TravelDestinationDefinitions` module.

Each destination contains only stable gameplay metadata, for example:

```luau
Market = {
    Id = "Market",
    Name = "Market",
    AnchorId = "Base.Travel.Market",
    SortOrder = 1,
}
```

Equivalent definitions exist for Dwarves, Portals and Orcs.

Arrival CFrame/position authority remains in the environment semantic anchors rather than in TravelService.

This keeps lobby-art calibration out of gameplay definitions.

## TravelConfig

Create shared configuration with at least:

```luau
TravelConfig.HOLD_DURATION = 1.0
TravelConfig.ACCESS_DISTANCE = 18
TravelConfig.COOLDOWN_SECONDS = 5
TravelConfig.ARRIVAL_HEIGHT_OFFSET = 3
TravelConfig.ALREADY_THERE_DISTANCE = 10
```

The arrival height offset protects against spawning partially inside the floor.

The already-there distance prevents a destination request from pointlessly repositioning a player already at that destination.

## TravelService

Create a focused `TravelService` under Core Services.

Responsibilities:

- build the authoritative Travel snapshot;
- validate destination IDs;
- validate identity/profile eligibility;
- validate active Dungeon-session state;
- validate pending teleport/handoff state through injected runtime callbacks/state;
- own per-user Travel cooldown state;
- decide whether a request may proceed;
- record cooldown only after successful movement.

TravelService does **not** directly move Roblox characters and does not know Workspace geometry.

Recommended public API:

```luau
TravelService.new(config)

TravelService:build_snapshot(user_id)
TravelService:validate_request(user_id, destination_id, now)
TravelService:record_success(user_id, now)
TravelService:remaining_cooldown(user_id, now)
TravelService:clear_user(user_id)
```

The service receives/injects only the profile/session/pending-state authorities it needs.

## BaseTravelRuntime

Create a Base-specific runtime adapter.

Responsibilities:

- resolve `Base.Service.Travel`;
- resolve all destination semantic anchors;
- wire Travel remotes;
- perform physical proximity validation;
- verify `HumanoidRootPart`;
- call TravelService for logical authorization;
- move the character to the destination anchor;
- start cooldown only after successful movement;
- return the authoritative result/snapshot;
- clear session-only cooldown state when the player leaves.

Movement uses `Model:PivotTo(...)` with the configured safe height offset.

The runtime rechecks destination availability at the moment of travel.

## Remotes

Add:

```text
TravelSnapshotRequest
TravelSnapshot
TravelRequest
TravelActionResult
```

The client sends only:

```luau
destination_id
```

The client never sends:

- destination coordinates;
- a CFrame;
- cooldown values;
- eligibility flags;
- identity/profile state;
- party authority.

The server resolves all of those independently.

## Snapshot

Recommended Travel snapshot:

```luau
{
    ok = true,
    CooldownRemaining = number,
    Destinations = {
        {
            Id = "Market",
            Name = "Market",
            Available = true,
            Reason = nil,
        },
        ...
    },
}
```

The snapshot contains only presentation-safe information.

## Travel UI

Create a small `TravelPanel.client.luau`.

The menu opens only after the Travel Gem's hold-E prompt completes.

The panel shows:

- title: `Travel`
- Market
- Dwarven Area
- Dungeon Portals
- Orc Area
- current status/error
- cooldown state when relevant
- close button

Destination buttons send only destination IDs.

No drag/drop or map screen is required.

No final art styling is required in this gate.

## Closing behavior

The Travel UI closes when:

- player manually closes it;
- player walks outside 18 studs from the Travel Gem;
- the character disappears/respawns;
- a successful Travel occurs;
- a Dungeon teleport begins.

After a successful local Travel, reopening the menu requires returning to the Travel Gem and holding E again.

## Stable rejection reasons

At minimum:

```text
BaseOnlyAction
ProfileNotLoaded
IdentityIncomplete
UnknownDestination
DestinationUnavailable
CharacterUnavailable
TooFarFromTravelService
TravelCooldown
TeleportPending
ActiveDungeonSession
AlreadyAtDestination
TravelFailed
```

The UI converts these stable reasons into readable messages.

## Environment anchors

The existing Travel placeholder becomes functional:

```text
Base.Service.TravelPlaceholder
```

becomes:

```text
Base.Service.Travel
```

The following destination anchors become required Base semantic anchors:

```text
Base.Travel.Market
Base.Travel.Dwarves
Base.Travel.Portals
Base.Travel.Orcs
```

Synthetic Base mode receives deterministic versions of all five Travel anchors so automated/runtime Studio tests do not depend on authored art.

Candidate mode calibrates the destination anchors against the current lobby scene.

Gameplay code must not directly reference candidate landmark/model names.

## Candidate calibration

The implementation may reuse existing accepted semantic anchors when they already represent the correct area, but the Travel destination itself still receives its own semantic Travel anchor.

For example:

- Market may calibrate near the central Market/Tree landmark.
- Portals may calibrate near the existing portal zone.
- Dwarves must calibrate against a stable current mountain/mine landmark.
- Orcs must calibrate against a stable current farm/orc landmark.

If the current candidate scene does not contain an unambiguous Dwarven or Orc landmark, implementation must stop and report the exact missing anchor evidence rather than guessing coordinates.

This is the one environment-related condition that could require human visual input before final Studio acceptance.

## Player movement safety

Before moving:

- destination anchor must be a valid BasePart;
- destination must still be registered;
- character must still exist;
- HumanoidRootPart must still exist;
- cooldown/session state is revalidated.

Movement target:

```text
destination anchor CFrame + vertical safe offset
```

The Travel system does not raycast arbitrary client coordinates.

## Anti-exploit behavior

Every Travel request is independently authorized server-side.

Examples that must fail:

- firing TravelRequest remotely from across the Base;
- sending a fake destination ID;
- sending a destination while on cooldown;
- sending while Dungeon teleport is pending;
- sending while a recoverable Dungeon session exists;
- sending before identity completion;
- spamming repeated requests in one frame.

No rejected request moves the character.

## Studio/debug behavior

No production bypass is required.

Synthetic Base mode is sufficient for deterministic automated checks.

If a Studio-only convenience is added for visual test setup, it must be guarded by `RunService:IsStudio()` and must not change production Travel eligibility.

## Automated acceptance

Automated tests must prove at minimum:

1. TravelConfig hold duration is exactly 1 second.
2. Travel access distance is exactly 18 studs.
3. Cooldown is exactly 5 seconds.
4. Profile schema remains v7.
5. Bank profile data remains unchanged.
6. Exactly four destinations are registered.
7. Destination IDs/names/semantic anchors match the accepted design.
8. Unknown destination rejects.
9. Incomplete identity rejects.
10. Pending Dungeon teleport rejects.
11. Recoverable active Dungeon session rejects.
12. Non-recoverable session does not block.
13. Cooldown begins only after recorded successful travel.
14. Rejected requests do not start cooldown.
15. Cooldown boundary expires correctly.
16. Already-at-destination rejects.
17. 18-stud interaction boundary is inclusive.
18. More than 18 studs rejects.
19. Destination anchor unavailable rejects without moving.
20. Client cannot provide coordinates/CFrame.
21. Party service state is not mutated by Travel.
22. Travel creates no DungeonSession.
23. Travel invokes no TeleportCoordinator handoff.
24. New semantic Travel anchors resolve in Synthetic mode.
25. Candidate definitions contain Travel Gem plus four arrival anchors.
26. Travel Gem receives a hold-E ProximityPrompt.
27. Travel remotes exist.
28. Travel UI references only semantic Travel Gem/destination IDs.
29. Existing Bank tests/contracts remain valid.
30. Existing Dungeon/party/progression/profession/equipment/Skill Book contracts remain buildable.
31. All four Rojo projects build successfully.

## Studio gameplay acceptance

Only after automated/build verification is green:

1. Open the fresh Base build.
2. Complete/select identity if needed.
3. Walk to the Travel Gem.
4. Tap E briefly and confirm the Travel menu does not open.
5. Hold E for about one second and confirm the Travel menu opens.
6. Travel to Market and verify safe arrival.
7. Return to Travel Gem.
8. Travel to Dwarven Area and verify safe arrival.
9. Return to Travel Gem.
10. Travel to Dungeon Portals and verify safe arrival outside portal trigger geometry.
11. Return to Travel Gem.
12. Travel to Orc Area and verify safe arrival.
13. Confirm immediate repeated Travel is blocked by the 5-second cooldown.
14. Confirm the UI closes after successful Travel.
15. Confirm walking out of Travel range closes the UI.
16. Confirm party state remains intact if tested while in a party.
17. Confirm no new red DungeonMMO runtime errors.

## Deferred scope

- Base-to-Base Roblox Place teleport
- persistent travel unlocks/discovery
- travel Gold cost
- Travel economy
- whole-party Travel
- guild Travel
- Travel during Dungeons
- Travel from arbitrary menus
- world map
- waypoint discovery
- mounts
- recall/hearthstone
- destination favorites
- final Travel Gem art/VFX/audio
- final Travel UI art

## Safety

- Work from an isolated Travel gameplay worktree.
- No direct feature development on `main`.
- No destructive Git.
- No push.
- No Roblox publish.
- No PROD DataStore.
- No Robux/monetization changes.
- Art worktree remains untouched.
- Build outputs go to TEMP.
- Do not overwrite root `DungeonMMO.rbxl`.
