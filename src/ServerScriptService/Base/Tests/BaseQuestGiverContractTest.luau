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

    local environment_mode = Workspace:GetAttribute(
        "DungeonMMOResolvedEnvironmentMode"
    )
    local strict_layout =
        environment_mode ~= "Synthetic"
    local positions = {}

    for _, definition in ipairs(givers) do
        local model = folder:FindFirstChild(definition.Id)
        check(
            model ~= nil and model:IsA("Model"),
            definition.Id .. " humanoid model exists"
        )

        local anchor = model:FindFirstChild(
            "HumanoidRootPart"
        )
        local head = model:FindFirstChild("Head")
        local humanoid = model:FindFirstChild("Humanoid")

        check(
            anchor ~= nil and anchor:IsA("BasePart"),
            definition.Id .. " interaction root exists"
        )
        check(
            head ~= nil and head:IsA("BasePart")
                and humanoid ~= nil
                and humanoid:IsA("Humanoid"),
            definition.Id .. " has a humanoid silhouette"
        )
        check(
            model:GetAttribute("DungeonMMOQuestGiverId")
                == definition.Id
                and model:GetAttribute("DungeonMMOQuestSpeaker")
                    == definition.Speaker
                and type(model:GetAttribute(
                    "DungeonMMOQuestGiverSourceAnchor"
                )) == "string",
            definition.Id .. " exposes stable presentation attributes"
        )
        if strict_layout then
            check(
                model:GetAttribute(
                    "DungeonMMOQuestGiverWalkable"
                ) == true
                    and model:GetAttribute(
                        "DungeonMMOQuestGiverApproachClear"
                    ) == true,
                definition.Id
                    .. " is marked walkable and approach-clear"
            )
        end

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

        local label = head:FindFirstChild(
            "QuestGiverLabel"
        )
        check(
            label ~= nil
                and label:IsA("BillboardGui"),
            definition.Id .. " has a visible role label"
        )

        positions[definition.Id] = anchor.Position
    end

    for first_index = 1, #givers do
        for second_index = first_index + 1, #givers do
            local first = givers[first_index]
            local second = givers[second_index]
            local distance = (
                positions[first.Id] - positions[second.Id]
            ).Magnitude

            if strict_layout then
                check(
                    distance >= 30,
                    first.Id
                        .. " and "
                        .. second.Id
                        .. " are spread at least 30 studs apart"
                )
            end
        end
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
