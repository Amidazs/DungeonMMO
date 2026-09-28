--!strict
-- Live Base contract for generated physical Adventure quest givers.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage.Core.Shared
local QuestGiverDefinitions = require(
    Shared.QuestGiverDefinitions
)

local checks = 0

--[[
Counts one physical quest-giver assertion.

Args:
    condition (boolean): Expected world presentation invariant.
    label (string): Diagnostic failure description.

Returns:
    nil: Increments the assertion count or raises.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(
        condition,
        "[Base Quest Givers] " .. label
    )
end

--[[
Validates every generated giver, prompt, label and dialogue remote.

Args:
    None.

Returns:
    nil: Prints a stable pass marker after all checks succeed.
]]
local function main()
    local folder = Workspace:WaitForChild(
        "DungeonMMOQuestGivers",
        10
    )
    check(
        folder ~= nil and folder:IsA("Folder"),
        "physical quest-giver folder exists"
    )

    local givers = QuestGiverDefinitions.all()
    check(
        #folder:GetChildren() == #givers,
        "physical giver count matches definitions"
    )

    for _, definition in ipairs(givers) do
        local anchor = folder:FindFirstChild(definition.Id)
        check(
            anchor ~= nil and anchor:IsA("BasePart"),
            definition.Id .. " physical anchor exists"
        )
        check(
            anchor:GetAttribute("DungeonMMOQuestGiverId")
                == definition.Id
                and anchor:GetAttribute("DungeonMMOQuestSpeaker")
                    == definition.Speaker,
            definition.Id .. " exposes stable presentation attributes"
        )

        local prompt = anchor:FindFirstChild(
            "QuestGiverPrompt"
        )
        check(
            prompt ~= nil
                and prompt:IsA("ProximityPrompt"),
            definition.Id .. " owns a Talk prompt"
        )
        check(
            prompt.ActionText == "Talk"
                and prompt.ObjectText == definition.Speaker
                and prompt.MaxActivationDistance == 12,
            definition.Id .. " prompt uses reviewed interaction text"
        )

        local label = anchor:FindFirstChild(
            "QuestGiverLabel"
        )
        check(
            label ~= nil
                and label:IsA("BillboardGui"),
            definition.Id .. " has a visible role label"
        )
    end

    local remote = ReplicatedStorage.Core.Remotes:
        FindFirstChild("QuestDialogueOpen")
    check(
        remote ~= nil and remote:IsA("RemoteEvent"),
        "quest-giver dialogue remote exists"
    )

    print(
        ("[Base Quest Givers] PASS: %d assertions")
            :format(checks)
    )
end

main()
