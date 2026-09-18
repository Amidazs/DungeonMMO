# DungeonMMO AI Automation Boundary

**State date:** 18 September 2026
**Current phase:** Phase 4 - Content Alpha
**Accepted gameplay release checkpoint:** 84662948127eb1a37c9f184c6abbafe6f2daddb6

## Goal

Use automation to reduce manual repetition while keeping repository state,
Roblox environment boundaries and value-bearing actions explicit and
recoverable.

Ordinary ChatGPT must always be able to continue from the repository handoff;
the project must not depend on one transient autonomous session.

## Preferred control paths

Use the simplest trusted path that fits the task:

1. repository/filesystem work through the authorised Desktop Commander bridge;
2. Rojo for deterministic source composition and Studio sync;
3. Roblox Studio's authenticated editor for TEST runtime validation and
   explicitly approved TEST publishing;
4. Studio MCP when it provides useful DataModel/playtest control.

Do not extract or expose Roblox browser/session cookies. If command-line Rojo
upload has no configured Open Cloud/API credential, use the already-authenticated
Studio + Rojo sync path rather than harvesting credentials.

## Allowed autonomous actions

An agent may:

- inspect Git status, branches, commits and worktrees;
- modify local repository source/docs inside the approved worktree;
- run parsers, static checks and git diff --check;
- build Base/Dungeon Rojo projects to TEMP;
- start/stop Rojo serve sessions;
- inspect or run TEST/DEV Studio sessions;
- inspect Studio output and viewport state;
- update handoff, test and roadmap documentation;
- create deliberate feature commits/branches;
- push/merge only when the user has explicitly approved that release action;
- publish the approved TEST place only when the user has explicitly approved
  publishing for that release.

## Prohibited without separate explicit approval

An agent must not:

- publish PROD;
- mutate PROD DataStores or production save data;
- activate live paid revives or monetisation;
- spend Robux;
- create/alter Developer Products;
- force-push;
- rewrite Git history;
- run git reset --hard or broad git clean;
- delete unrelated user files/worktrees;
- mark a roadmap gate accepted without the required fresh evidence;
- expose credentials, cookies or API keys.

## Current TEST publish boundary

Published TEST environment:

- Universe: 10765241947
- Starting Base: 134132328219009
- Dungeon: 117293035754309

For the Phase 3 release the safe publish sequence was:

1. build/validate the TEST Rojo composition;
2. open the existing cloud Dungeon place in authenticated Studio;
3. connect the Rojo plugin to the local TEST Dungeon project;
4. confirm the Studio process has an established localhost Rojo connection;
5. use Studio's normal Publish to Roblox command;
6. verify the Studio publish state reaches PublishSuccessful;
7. repeat for Starting Base;
8. inspect Studio logs for the final success messages.

Dungeon should be published before Base during a coordinated update so the entry
place does not point players at a half-updated Dungeon.

## Build commands

Dungeon:

rojo build default.project.json -o "$env:TEMP\DungeonMMO_AI_Dungeon.rbxl"

Starting Base:

rojo build base.project.json -o "$env:TEMP\DungeonMMO_AI_Base.rbxl"

Published composition validation:

rojo build published-dungeon.project.json -o "$env:TEMP\DungeonMMO_AI_Dungeon_Published.rbxl"

rojo build published-base.project.json -o "$env:TEMP\DungeonMMO_AI_Base_Published.rbxl"

Published TEST environments must fail closed unless
ServerScriptService.DungeonMMOEnvironment resolves to TEST or PROD.
For TEST, the Base must also point at the TEST Dungeon Place ID.

## Phase 4 automation rule

Phase 4.A is presentation/content integration work. Automation may inspect,
assemble and validate environment changes, but semantic anchors and server-owned
service boundaries remain authoritative.

Do not allow visual polish to silently change:

- Travel destinations/ranges;
- Bank/Market/Guild/trainer interaction ownership;
- spawn or Dungeon handoff semantics;
- collision/pathing safety;
- persistence or profile authority.

Run targeted gameplay regressions after any environment integration that could
affect those contracts.

## Credit/tool fallback

If a higher-autonomy tool is unavailable:

1. read CURRENT_STATE.md, HANDOFF.md and TEST_MATRIX.md;
2. inspect current Git branch/status;
3. continue with ordinary ChatGPT + Desktop Commander/PowerShell;
4. use manual Studio input only where automation cannot safely prove the result;
5. update the same continuity documents before handing off again.

There is one canonical DungeonMMO repository state, not separate AI-specific
versions.
