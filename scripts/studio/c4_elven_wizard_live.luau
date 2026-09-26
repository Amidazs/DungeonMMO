--!strict
-- Runs the built unpublished Moonweaver Play rehearsal harness.

local ServerScriptService = game:GetService("ServerScriptService")

local harness = require(
    ServerScriptService.Core.Tests.C4ElvenWizardLiveHarness
)

assert(
    harness == true,
    "Moonweaver live harness did not complete successfully"
)
