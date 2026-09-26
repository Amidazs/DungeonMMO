--!strict
-- Runs the built unpublished Lifebinder Play rehearsal harness.

local ServerScriptService = game:GetService("ServerScriptService")

local harness = require(
    ServerScriptService.Core.Tests.C4ElvenOracleLiveHarness
)

assert(
    harness == true,
    "Lifebinder live harness did not complete successfully"
)
